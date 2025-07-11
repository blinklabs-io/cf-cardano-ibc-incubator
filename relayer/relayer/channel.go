package relayer

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/cardano/relayer/v1/relayer/processor"
	"github.com/cardano/relayer/v1/relayer/provider"
	chantypes "github.com/cosmos/ibc-go/v7/modules/core/04-channel/types"
	host "github.com/cosmos/ibc-go/v7/modules/core/24-host"
	"go.uber.org/zap"
)

// CreateOpenChannels runs the channel creation messages on timeout until they pass.
func (c *Chain) CreateOpenChannels(
	ctx context.Context,
	dst *Chain,
	maxRetries uint64,
	timeout time.Duration,
	srcPortID, dstPortID, order, version string,
	override bool,
	memo string,
	pathName string,
) error {
	// // client and connection identifiers must be filled in
	// if err := ValidateConnectionPaths(c, dst); err != nil {
	// 	return err
	// }

	// // port identifiers and channel ORDER must be valid
	// if err := ValidateChannelParams(srcPortID, dstPortID, order); err != nil {
	// 	return err
	// }
	c.log.Info("Start CreateOpenChannels", zap.Time("time", time.Now()))
	if !override {
		channel, err := QueryPortChannel(ctx, c, srcPortID)
		if err == nil && channel != nil {
			return fmt.Errorf("channel {%s} with port {%s} already exists on chain {%s}", channel.ChannelId, channel.PortId, c.ChainID())
		}

		channel, err = QueryPortChannel(ctx, dst, dstPortID)
		if err == nil && channel != nil {
			return fmt.Errorf("channel {%s} with port {%s} already exists on chain {%s}", channel.ChannelId, channel.PortId, dst.ChainID())
		}
	}

	// Timeout is per message. Four channel handshake messages, allowing maxRetries for each.
	processorTimeout := timeout * 4 * time.Duration(maxRetries)

	ctx, cancel := context.WithTimeout(ctx, processorTimeout)
	defer cancel()

	if strings.HasPrefix(c.PathEnd.ClientID, "07-tendermint-") {
		c.PathEnd.ClientID = "ibc_client-" + strings.TrimPrefix(c.PathEnd.ClientID, "07-tendermint-")
	}

	pp := processor.NewPathProcessor(
		c.log,
		processor.NewPathEnd(pathName, c.PathEnd.ChainID, c.PathEnd.ClientID, "", []processor.ChainChannelKey{}),
		processor.NewPathEnd(pathName, dst.PathEnd.ChainID, dst.PathEnd.ClientID, "", []processor.ChainChannelKey{}),
		nil,
		memo,
		DefaultClientUpdateThreshold,
		DefaultFlushInterval,
		DefaultMaxMsgLength,
	)

	c.log.Info("Starting event processor for channel handshake",
		zap.String("src_chain_id", c.PathEnd.ChainID),
		zap.String("src_port_id", srcPortID),
		zap.String("dst_chain_id", dst.PathEnd.ChainID),
		zap.String("dst_port_id", dstPortID),
	)

	return processor.NewEventProcessor().
		WithChainProcessors(
			c.chainProcessor(c.log, nil),
			dst.chainProcessor(c.log, nil),
		).
		WithPathProcessors(pp).
		WithInitialBlockHistory(0).
		WithMessageLifecycle(&processor.ChannelMessageLifecycle{
			Initial: &processor.ChannelMessage{
				ChainID:   c.PathEnd.ChainID,
				EventType: chantypes.EventTypeChannelOpenInit,
				Info: provider.ChannelInfo{
					PortID:             srcPortID,
					CounterpartyPortID: dstPortID,
					ConnID:             c.PathEnd.ConnectionID,
					Version:            version,
					Order:              OrderFromString(order),
				},
			},
			Termination: &processor.ChannelMessage{
				ChainID:   dst.PathEnd.ChainID,
				EventType: chantypes.EventTypeChannelOpenConfirm,
				Info: provider.ChannelInfo{
					PortID:             dstPortID,
					CounterpartyPortID: srcPortID,
				},
			},
		}).
		Build().
		Run(ctx)
}

// CloseChannel runs the channel closing messages on timeout until they pass.
func (c *Chain) CloseChannel(
	ctx context.Context,
	dst *Chain,
	maxRetries uint64,
	timeout time.Duration,
	srcChanID,
	srcPortID string,
	memo string,
	pathName string,
) error {
	// Timeout is per message. Two close channel handshake messages, allowing maxRetries for each.
	processorTimeout := timeout * 2 * time.Duration(maxRetries)

	// Perform a flush first so that any timeouts are cleared.
	flushCtx, flushCancel := context.WithTimeout(ctx, processorTimeout)
	defer flushCancel()

	flushProcessor := processor.NewEventProcessor().
		WithChainProcessors(
			c.chainProcessor(c.log, nil),
			dst.chainProcessor(c.log, nil),
		).
		WithPathProcessors(processor.NewPathProcessor(
			c.log,
			processor.NewPathEnd(pathName, c.PathEnd.ChainID, c.PathEnd.ClientID, "", []processor.ChainChannelKey{}),
			processor.NewPathEnd(pathName, dst.PathEnd.ChainID, dst.PathEnd.ClientID, "", []processor.ChainChannelKey{}),
			nil,
			memo,
			DefaultClientUpdateThreshold,
			DefaultFlushInterval,
			DefaultMaxMsgLength,
		)).
		WithInitialBlockHistory(0).
		WithMessageLifecycle(&processor.FlushLifecycle{}).
		Build()

	c.log.Info("Starting event processor for flush before channel close",
		zap.String("src_chain_id", c.PathEnd.ChainID),
		zap.String("src_port_id", srcPortID),
		zap.String("dst_chain_id", dst.PathEnd.ChainID),
	)

	if err := flushProcessor.Run(flushCtx); err != nil {
		return err
	}

	ctx, cancel := context.WithTimeout(ctx, processorTimeout)
	defer cancel()

	c.log.Info("Starting event processor for channel close",
		zap.String("src_chain_id", c.PathEnd.ChainID),
		zap.String("src_port_id", srcPortID),
		zap.String("dst_chain_id", dst.PathEnd.ChainID),
	)

	return processor.NewEventProcessor().
		WithChainProcessors(
			c.chainProcessor(c.log, nil),
			dst.chainProcessor(c.log, nil),
		).
		WithPathProcessors(processor.NewPathProcessor(
			c.log,
			processor.NewPathEnd(pathName, c.PathEnd.ChainID, c.PathEnd.ClientID, "", []processor.ChainChannelKey{}),
			processor.NewPathEnd(pathName, dst.PathEnd.ChainID, dst.PathEnd.ClientID, "", []processor.ChainChannelKey{}),
			nil,
			memo,
			DefaultClientUpdateThreshold,
			DefaultFlushInterval,
			DefaultMaxMsgLength,
		)).
		WithInitialBlockHistory(0).
		WithMessageLifecycle(&processor.ChannelCloseLifecycle{
			SrcChainID:   c.PathEnd.ChainID,
			SrcChannelID: srcChanID,
			SrcPortID:    srcPortID,
			SrcConnID:    c.PathEnd.ConnectionID,
			DstConnID:    dst.PathEnd.ConnectionID,
		}).
		Build().
		Run(ctx)
}

// ValidateChannelParams validates a set of port-ids as well as the order.
func ValidateChannelParams(srcPortID, dstPortID, order string) error {
	if err := host.PortIdentifierValidator(srcPortID); err != nil {
		return err
	}
	if err := host.PortIdentifierValidator(dstPortID); err != nil {
		return err
	}
	if (OrderFromString(order) == chantypes.ORDERED) || (OrderFromString(order) == chantypes.UNORDERED) {
		return nil
	}
	return fmt.Errorf("invalid order input (%s), order must be 'ordered' or 'unordered'", order)
}
