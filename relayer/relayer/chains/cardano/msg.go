package cardano

import (
	"fmt"
	"github.com/gogo/protobuf/proto"

	"github.com/cardano/relayer/v1/relayer/provider"
	"github.com/cosmos/cosmos-sdk/codec"
	sdk "github.com/cosmos/cosmos-sdk/types"
	"go.uber.org/zap/zapcore"
)

type CardanoMessage struct {
	Msg              sdk.Msg
	SetSigner        func(string) //callback to update the Msg Signer field
	FeegrantDisabled bool         //marks whether this message type should ALWAYS disable feegranting (use the default signer)
}

// After call getting unsigned msg from gateway pls set UnsignedTx
func NewCardanoMessage(msg sdk.Msg, optionalSetSigner func(string)) provider.RelayerMessage {
	return CardanoMessage{
		Msg:       msg,
		SetSigner: optionalSetSigner,
	}
}

func CardanoMsg(rm provider.RelayerMessage) sdk.Msg {
	if val, ok := rm.(CardanoMessage); !ok {
		fmt.Printf("got data of type %T but wanted provider.CosmosMessage \n", val)
		return nil
	} else {
		return val.Msg
	}
}

func CardanoMsgs(rm ...provider.RelayerMessage) []sdk.Msg {
	sdkMsgs := make([]sdk.Msg, 0)
	for _, rMsg := range rm {
		if val, ok := rMsg.(CardanoMessage); !ok {
			fmt.Printf("got data of type %T but wanted provider.CosmosMessage \n", rMsg)
			return nil
		} else {
			sdkMsgs = append(sdkMsgs, val.Msg)
		}
	}
	return sdkMsgs
}

func (cm CardanoMessage) Type() string {
	return sdk.MsgTypeURL(cm.Msg)
}

func (cm CardanoMessage) MsgBytes() ([]byte, error) {
	return proto.Marshal(cm.Msg)
}

// MarshalLogObject is used to encode cm to a zap logger with the zap.Object field type.
func (cm CardanoMessage) MarshalLogObject(enc zapcore.ObjectEncoder) error {
	// Using plain json.Marshal or calling cm.Msg.String() both fail miserably here.
	// There is probably a better way to encode the message than this.
	j, err := codec.NewLegacyAmino().MarshalJSON(cm.Msg)
	if err != nil {
		return err
	}
	enc.AddByteString("msg_json", j)
	return nil
}
