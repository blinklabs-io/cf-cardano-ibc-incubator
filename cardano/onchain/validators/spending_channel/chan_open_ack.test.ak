use cardano/transaction.{
  Input, Mint, Redeemer, ScriptPurpose, Spend, Transaction,
}
use ibc/client/ics_007_tendermint_client/client_datum.{
  ClientDatum, ClientDatumState,
}
use ibc/client/ics_007_tendermint_client/cometbft/protos/channel_pb
use ibc/client/ics_007_tendermint_client/consensus_state.{ConsensusState}
use ibc/client/ics_007_tendermint_client/height.{Height} as height_mod
use ibc/client/ics_007_tendermint_client/types/verify_proof_redeemer.{
  VerifyMembership,
}
use ibc/core/ics_003_connection_semantics/connection_datum.{ConnectionDatum}
use ibc/core/ics_003_connection_semantics/types/connection_end.{ConnectionEnd}
use ibc/core/ics_003_connection_semantics/types/counterparty.{Counterparty} as conn_counterparty_mod
use ibc/core/ics_003_connection_semantics/verify as verify_mod
use ibc/core/ics_004/channel_datum.{ChannelDatum,
  ChannelDatumState} as channel_datum_mod
use ibc/core/ics_004/channel_redeemer.{ChanOpenAck}
use ibc/core/ics_004/types/channel.{Channel}
use ibc/core/ics_004/types/counterparty.{ChannelCounterparty}
use ibc/core/ics_004/types/keys as chan_keys_mod
use ibc/core/ics_004/types/order as chan_order_mod
use ibc/core/ics_004/types/state as chan_state_mod
use ibc/core/ics_005/types/ibc_module_redeemer.{Callback, OnChanOpenAck}
use ibc/core/ics_023_vector_commitments/ics23/proofs.{
  CommitmentProof, CommitmentProof_Exist, ExistenceProof, InnerOp, LeafOp,
}
use ibc/core/ics_023_vector_commitments/merkle.{MerkleProof, MerkleRoot}
use ibc/core/ics_024_host_requirements/channel_keys
use ibc/utils/test_utils
use ibc/utils/validator_utils
use spending_channel/chan_open_ack
use spending_channel/spending_channel_fixture.{MockData, setup}

test succeed_chan_open_ack() {
  let mock_data = setup()

  //========================arrange inputs=======================
  let input_channel =
    Channel {
      state: chan_state_mod.Init,
      ordering: chan_order_mod.Ordered,
      counterparty: ChannelCounterparty { port_id: "port-1", channel_id: "" },
      connection_hops: [mock_data.connection_id],
      version: "mock-version",
    }

  let input_channel_datum =
    ChannelDatum {
      state: ChannelDatumState {
        channel: input_channel,
        next_sequence_send: 1,
        next_sequence_recv: 1,
        next_sequence_ack: 1,
        packet_commitment: [],
        packet_receipt: [],
        packet_acknowledgement: [],
      },
      port_id: mock_data.port_id,
      token: mock_data.channel_token,
    }

  let channel_input =
    test_utils.build_channel_input(input_channel_datum, mock_data.channel_token)

  let inputs = [mock_data.module_input, channel_input]

  //========================arrange reference_inputs=======================
  let proof_height = Height { revision_number: 1, revision_height: 14 }

  let cons_state =
    ConsensusState {
      timestamp: 1577923295000000000,
      next_validators_hash: #"f184766fc80a33423ebdb0c94b9e1200995204d84b4527e48d49a62e556d719e",
      root: MerkleRoot {
        hash: #"a87ef44a0eaf1770ec5b89029afd80ac1c46bc42c94c3daafcc9b45b9fd021d1",
      },
    }

  let client_input =
    test_utils.update_client(proof_height, cons_state, mock_data.client_input)

  let reference_inputs = [mock_data.connection_input, client_input]

  //========================arrange outputs=======================
  let output_channel =
    Channel {
      state: chan_state_mod.Open,
      ordering: chan_order_mod.Ordered,
      counterparty: ChannelCounterparty {
        port_id: "port-1",
        channel_id: "channel-0",
      },
      connection_hops: [mock_data.connection_id],
      version: "mock-version",
    }

  let output_channel_datum =
    ChannelDatum {
      state: ChannelDatumState {
        channel: output_channel,
        next_sequence_send: 1,
        next_sequence_recv: 1,
        next_sequence_ack: 1,
        packet_commitment: [],
        packet_receipt: [],
        packet_acknowledgement: [],
      },
      port_id: mock_data.port_id,
      token: mock_data.channel_token,
    }

  let channel_output =
    test_utils.build_channel_output(
      output_channel_datum,
      mock_data.channel_token,
    )

  let outputs = [channel_output]

  //========================arrange validity_range=======================
  let validity_range = mock_data.validity_range

  //========================arrange redeemers=======================
  let proof_try =
    MerkleProof {
      proofs: [
        CommitmentProof {
          proof: CommitmentProof_Exist {
            exist: ExistenceProof {
              key: #"6368616e6e656c456e64732f706f7274732f706f72742d312f6368616e6e656c732f6368616e6e656c2d30",
              value: #"080210021a130a06706f72742d3112096368616e6e656c2d30220c636f6e6e656374696f6e2d302a0c6d6f636b2d76657273696f6e",
              leaf: LeafOp {
                hash: 1,
                prehash_value: 1,
                length: 1,
                prefix: #"00021a",
                prehash_key: 0,
              },
              path: [
                InnerOp {
                  hash: 1,
                  prefix: #"02041a20",
                  suffix: #"20072452876773f4e9b67456f4fd55fe48c9492aa788251556eab0975eb57ac2ca",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"04081a20",
                  suffix: #"20d37e05016b4cd45e7e0454178e811a7b2b53f7092387ae95383a3b7fcdd39092",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"060e1a20",
                  suffix: #"20d27ed71739a2421431b123e9154cee8cfcc27f08cbff5ad8c405452229870bb2",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"08181a20",
                  suffix: #"20406bc53ced9da540989fc85e1dbd662b4076abf82f3188c0318cb65028d7eb37",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"0c3c1a20",
                  suffix: #"200691f65010caeb9e5cfc62a8a60a80a8ffbc07a6a2c5dfc2a725512411bbd091",
                },
              ],
            },
          },
        },
        CommitmentProof {
          proof: CommitmentProof_Exist {
            exist: ExistenceProof {
              key: #"696263",
              value: #"7020ef1e10a4625f68ad8d581f940051c413d2e2d95764b215767e66d1c3a4d8",
              leaf: LeafOp {
                hash: 1,
                prehash_value: 1,
                length: 1,
                prefix: #"00",
                prehash_key: 0,
              },
              path: [
                InnerOp {
                  hash: 1,
                  prefix: #"0106b99c0d8119ff1edbcbe165d0f19337dbbc080e677c88e57aa2ae767ebf0f0f",
                  suffix: #"",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"01",
                  suffix: #"102be2509e02c885c7493d6e0fa2792b08de6bcc7157707f39f39163f6e68efd",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"01168116e3f4be1a4955b203aa979d29f890ccc0e6d2214f7125aa1f61e826b77b",
                  suffix: #"",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"0159cd7e1a11b0e9e8cef7773569a5efa2cc01ee93fe6e09e0e4cbb3e434bb614c",
                  suffix: #"",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"01",
                  suffix: #"1f55e6131b22078945a0cb93c65fe5fef6d4a361a4a573c00e4d1d02b476040f",
                },
              ],
            },
          },
        },
      ],
    }
  let counterparty_version = "mock-version"

  let spend_channel_redeemer: Redeemer =
    ChanOpenAck { counterparty_version, proof_try, proof_height }

  let channel_id =
    chan_keys_mod.format_channel_identifier(mock_data.channel_sequence)
  let module_redeemer: Redeemer = Callback(OnChanOpenAck { channel_id })

  expect client_datum: ClientDatum =
    validator_utils.get_inline_datum(client_input.output)
  expect connection_datum: ConnectionDatum =
    validator_utils.get_inline_datum(mock_data.connection_input.output)

  let connection = connection_datum.state

  let time_delay = connection.delay_period
  let block_delay = verify_mod.get_block_delay(connection)

  let merkle_path =
    merkle.apply_prefix(
      connection.counterparty.prefix,
      merkle.new_merkle_path(
        [
          channel_keys.channel_path(
            output_channel_datum.state.channel.counterparty.port_id,
            output_channel_datum.state.channel.counterparty.channel_id,
          ),
        ],
      ),
    )

  let counterparty_hops = [connection.counterparty.connection_id]

  let expected_counterparty =
    ChannelCounterparty { port_id: output_channel_datum.port_id, channel_id }

  let expected_channel =
    Channel {
      state: chan_state_mod.TryOpen,
      ordering: output_channel_datum.state.channel.ordering,
      counterparty: expected_counterparty,
      connection_hops: counterparty_hops,
      version: counterparty_version,
    }

  let channel_bz =
    channel_pb.marshal_for_channel(
      channel.convert_to_channel_proto(expected_channel),
    ).2nd

  let verify_proof_redeemer: Redeemer =
    VerifyMembership {
      cs: client_datum.state.client_state,
      cons_state,
      height: proof_height,
      delay_time_period: time_delay,
      delay_block_period: block_delay,
      proof: proof_try,
      path: merkle_path,
      value: channel_bz,
    }

  let chan_open_ack_redeemer: Redeemer = mock_data.channel_token

  let redeemers: Pairs<ScriptPurpose, Redeemer> =
    [
      Pair(Spend(mock_data.module_input.output_reference), module_redeemer),
      Pair(Spend(channel_input.output_reference), spend_channel_redeemer),
      Pair(Mint(mock_data.chan_open_ack_policy_id), chan_open_ack_redeemer),
      Pair(Mint(mock_data.verify_proof_policy_id), verify_proof_redeemer),
    ]

  //==========================arrange context=========================
  let transaction =
    Transaction {
      ..transaction.placeholder,
      inputs: inputs,
      reference_inputs: reference_inputs,
      outputs: outputs,
      redeemers: redeemers,
      validity_range: validity_range,
    }

  chan_open_ack.chan_open_ack.mint(
    mock_data.client_minting_policy_id,
    mock_data.connection_minting_policy_id,
    mock_data.port_minting_policy_id,
    mock_data.verify_proof_policy_id,
    mock_data.channel_token,
    mock_data.chan_open_ack_policy_id,
    transaction,
  )
}
