use cardano/transaction.{placeholder}
use ibc/client/ics_007_tendermint_client/client_datum.{ClientDatumState}
use ibc/client/ics_007_tendermint_client/client_state.{ClientState} as client_state_mod
use ibc/client/ics_007_tendermint_client/consensus_state.{ConsensusState}
use ibc/client/ics_007_tendermint_client/height.{Height} as height_mod
use ibc/client/ics_007_tendermint_client/types/unchecked_rational.{
  UncheckedRational,
}
use ibc/client/ics_007_tendermint_client/types/verify_proof_redeemer.{
  BatchVerifyMembership, VerifyMembership, VerifyMembershipParams,
  VerifyNonMembership,
}
use ibc/core/ics_003_connection_semantics/types/connection_end.{ConnectionEnd}
use ibc/core/ics_003_connection_semantics/types/counterparty.{Counterparty}
use ibc/core/ics_003_connection_semantics/types/state as conn_state_mod
use ibc/core/ics_003_connection_semantics/types/version.{Version}
use ibc/core/ics_004/types/packet.{Packet} as packet_mod
use ibc/core/ics_023_vector_commitments/ics23/proofs.{
  CommitmentProof, CommitmentProof_Exist, CommitmentProof_Nonexist,
  ExistenceProof, InnerOp, InnerSpec, LeafOp, NonExistenceProof, ProofSpec,
}
use ibc/core/ics_023_vector_commitments/merkle.{
  MerklePath, MerkleProof, MerkleRoot,
}
use ibc/core/ics_023_vector_commitments/merkle_prefix.{MerklePrefix}
use ibc/core/ics_024_host_requirements/packet_keys
use verifying_proof

type MockData {
  client_datum_state: ClientDatumState,
  connection: ConnectionEnd,
  port_id: ByteArray,
  channel_id: ByteArray,
  proof_height: Height,
}

fn setup() -> MockData {
  //========================Client==============================

  let cons_state =
    ConsensusState {
      timestamp: 1577923295000000000,
      next_validators_hash: #"be42d79cf15375efd54cf594c9f016db8c8b8dc4e91f35f11bba000ec7e9f439",
      root: MerkleRoot {
        hash: #"3d89dd39e1f1c7a0cec08f3ebf31fcb485f42068fcb79a8aeb3a9ca9f4e7091d",
      },
    }

  let trust_level = unchecked_rational.new(1, 3)

  let proof_specs =
    [
      ProofSpec {
        leaf_spec: LeafOp {
          hash: 1,
          prehash_value: 1,
          length: 1,
          prefix: #"00",
          prehash_key: 0,
        },
        inner_spec: InnerSpec {
          child_order: [0, 1],
          child_size: 33,
          min_prefix_length: 4,
          max_prefix_length: 12,
          hash: 1,
          empty_child: #"",
        },
        max_depth: 0,
        min_depth: 0,
        prehash_key_before_comparison: False,
      },
      ProofSpec {
        leaf_spec: LeafOp {
          hash: 1,
          prehash_value: 1,
          length: 1,
          prefix: #"00",
          prehash_key: 0,
        },
        inner_spec: InnerSpec {
          child_order: [0, 1],
          child_size: 32,
          min_prefix_length: 1,
          max_prefix_length: 1,
          hash: 1,
          empty_child: #"",
        },
        max_depth: 0,
        min_depth: 0,
        prehash_key_before_comparison: False,
      },
    ]

  let client_state =
    ClientState {
      chain_id: "testchain1-1",
      trust_level,
      trusting_period: 1209600000000000,
      unbonding_period: 1814400000000000,
      max_clock_drift: 10000000000,
      frozen_height: height_mod.zero_height(),
      latest_height: Height { revision_number: 1, revision_height: 13 },
      proof_specs,
    }

  let init_height = Height { revision_number: 1, revision_height: 13 }

  let client_datum_state =
    ClientDatumState {
      client_state,
      consensus_states: [Pair(init_height, cons_state)],
    }

  //========================Connection==============================
  let connection =
    ConnectionEnd {
      client_id: "ibc_client-10",
      versions: [
        Version {
          identifier: "1",
          features: ["ORDER_ORDERED", "ORDER_UNORDERED"],
        },
      ],
      state: conn_state_mod.Open,
      counterparty: Counterparty {
        client_id: "07-tendermint-0",
        connection_id: "connection-0",
        prefix: MerklePrefix { key_prefix: "ibc" },
      },
      delay_period: 0,
    }

  let proof_height = Height { revision_number: 0, revision_height: 15 }

  MockData {
    client_datum_state,
    connection,
    port_id: "port-1",
    channel_id: "channel-0",
    proof_height,
  }
}

fn insert_proof_cons_state(
  client_datum_state: ClientDatumState,
  proof_height: Height,
  proof_cons_state: ConsensusState,
) -> ClientDatumState {
  let updated_cons_states =
    [
      Pair(proof_height, proof_cons_state),
      ..client_datum_state.consensus_states
    ]

  ClientDatumState {
    ..client_datum_state,
    consensus_states: updated_cons_states,
  }
}

test verify_non_membership_succeed() {
  let mock = setup()

  let proof_cons_state =
    ConsensusState {
      timestamp: 1577923365000000000,
      next_validators_hash: #"020402703976bb4e91f05e69c25627e1b813bfeca54f4825afee49efe8acdbd7",
      root: MerkleRoot {
        hash: #"2a2a5880ec8d4d978eaace39e4d256a7d1dbd024f3c471aa8fa14a955d3eb102",
      },
    }

  let client_datum_state =
    insert_proof_cons_state(
      mock.client_datum_state,
      mock.proof_height,
      proof_cons_state,
    )

  let proof_unreceived =
    MerkleProof {
      proofs: [
        CommitmentProof {
          proof: CommitmentProof_Nonexist {
            non_exist: NonExistenceProof {
              key: #"72656365697074732f706f7274732f706f72742d312f6368616e6e656c732f6368616e6e656c2d302f73657175656e6365732f31",
              left: ExistenceProof {
                key: #"6e65787453657175656e636553656e642f706f7274732f706f72742d312f6368616e6e656c732f6368616e6e656c2d30",
                value: #"0000000000000001",
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
                    prefix: #"02041a2069fe4c2aa5110a8a5c97f267c34267d36f7ba2cf991cf3fd3624660aee2e746b20",
                    suffix: #"",
                  },
                  InnerOp {
                    hash: 1,
                    prefix: #"04081a20ae5dc2363c0f0d1336872b4849c4e7a2041e3c3fec05c0337ab5cf34310a591820",
                    suffix: #"",
                  },
                  InnerOp {
                    hash: 1,
                    prefix: #"060c1a2094ccea99bc1c0dfeb3076d2e23d97768e40ce76732c03fef3e4d4294f86bab3e20",
                    suffix: #"",
                  },
                  InnerOp {
                    hash: 1,
                    prefix: #"08142420408185c9c7a64d80e582a667d4c43c4c75f6f70b31973c1cc9566949f2ff4c4a20",
                    suffix: #"",
                  },
                  InnerOp {
                    hash: 1,
                    suffix: #"",
                    prefix: #"0a282420fe7b9f8701623b31b2cd0081bc29eeb8d8820342762d2291f99d0b87c45d2dad20",
                  },
                  InnerOp {
                    hash: 1,
                    suffix: #"",
                    prefix: #"0c4c242042ffb12ab52829ebe99314eb358efc1cb2c0c9bc351c26f1e8807cff1a0ab46d20",
                  },
                ],
              },
              right: ExistenceProof {
                key: #"",
                value: #"",
                leaf: LeafOp {
                  hash: 0,
                  prehash_key: 0,
                  prehash_value: 0,
                  length: 0,
                  prefix: #"",
                },
                path: [],
              },
            },
          },
        },
        CommitmentProof {
          proof: CommitmentProof_Exist {
            exist: ExistenceProof {
              key: #"696263",
              value: #"61ab6bc2f730e4b47b25ecbd63b19016dbbed90882db668aa9b904e4dc440b48",
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
                  prefix: #"011ff6dd57644f3deb80dc6cf90b299a9d3b524446c6c939887fbe332ec5cf001a",
                  suffix: #"",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"01",
                  suffix: #"1eac9a45c80ab2a8e4cf596213fe46583ee60b37ae47a49bb801d487f22cb301",
                },
              ],
            },
          },
        },
      ],
    }

  let merkle_path =
    merkle.apply_prefix(
      MerklePrefix { key_prefix: "ibc" },
      merkle.new_merkle_path(
        [packet_keys.packet_receipt_path(mock.port_id, mock.channel_id, 1)],
      ),
    )

  //========================arrange redeemer=======================
  let redeemer =
    VerifyNonMembership {
      cs: client_datum_state.client_state,
      cons_state: proof_cons_state,
      height: mock.proof_height,
      delay_time_period: 0,
      delay_block_period: 0,
      proof: proof_unreceived,
      path: merkle_path,
    }

  verifying_proof.verify_proof.mint(
    redeemer,
    #"2aa9c1557fcf8e7caa049fa0911a8724a1cdaf8037fe0b431c6ac663",
    placeholder,
  )
}

test verify_membership_succeed() {
  let mock = setup()

  let packet =
    Packet {
      sequence: 1,
      source_port: mock.port_id,
      source_channel: mock.channel_id,
      destination_port: "port-1",
      destination_channel: "channel-0",
      data: "mock packet data",
      timeout_height: Height { revision_number: 0, revision_height: 0 },
      timeout_timestamp: 1735689600000000000,
    }
  let packet_commitment = packet_mod.commit_packet(packet)

  let proof_cons_state =
    ConsensusState {
      timestamp: 1577923295000000000,
      next_validators_hash: #"7c3af87e2c224be7f3b2d7b2ab467e69b1a4ef5947fbe76d55e9091e16172346",
      root: MerkleRoot {
        hash: #"11a648b10463e8a96c77976940ee316117bb8214bd380e267aa31cf39ef8a09a",
      },
    }

  let client_datum_state =
    insert_proof_cons_state(
      mock.client_datum_state,
      mock.proof_height,
      proof_cons_state,
    )

  let proof_commitment =
    MerkleProof {
      proofs: [
        CommitmentProof {
          proof: CommitmentProof_Exist {
            exist: ExistenceProof {
              key: #"636f6d6d69746d656e74732f706f7274732f706f72742d312f6368616e6e656c732f6368616e6e656c2d302f73657175656e6365732f31",
              value: #"fa365cf5deedf3169bfe56010f101be23eac638d3bc9f43c7634f78ef718aa10",
              leaf: LeafOp {
                hash: 1,
                prehash_value: 1,
                length: 1,
                prefix: #"000224",
                prehash_key: 0,
              },
              path: [
                InnerOp {
                  hash: 1,
                  prefix: #"020424205fd25b3dc1314970dcbf74075f9d165af4a185eea459128edf21cfacc14b9c9e20",
                  suffix: #"",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"04062420",
                  suffix: #"2067b76c7b82d60ebee7f41dd11a02534c1a16efa70c217310356230dfd5ad0c20",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"060a2420",
                  suffix: #"20f21e95601cbd0028a9c3c4effd8afbbe068f086ab152ec0edb9cde2fdd6c568f",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"08162420",
                  suffix: #"2038afa1cc8688eedde1256daab2bff7aade39a6db7320d62f47581fb65d9e8024",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"0a2424203dd3101284b12a1c86ec48897aaf11781985de6f1eb75fdb6c8011a7d3e4d2ad20",
                  suffix: #"",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"0c462420617a9deebfac19d019bc9f7179c90ed228ee21d7330bc10568918f6f26cbb75320",
                  suffix: #"",
                },
              ],
            },
          },
        },
        CommitmentProof {
          proof: CommitmentProof_Exist {
            exist: ExistenceProof {
              key: #"696263",
              value: #"6cfc3a7872f9703bcd5027ba7197890652bf545bd77a4ae7fa8b780746c91e42",
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
                  prefix: #"01ef0d5a163ae333b43e2956b2d9660e65aaa9a1e2f90b30a91d97b5d0f12fb1fc",
                  suffix: #"",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"01",
                  suffix: #"04634f3eedce1a4677cef6f418f7671437db345ad7e26581393b7cc6e722a2c7",
                },
              ],
            },
          },
        },
      ],
    }

  let merkle_path =
    merkle.apply_prefix(
      MerklePrefix { key_prefix: "ibc" },
      merkle.new_merkle_path(
        [
          packet_keys.packet_commitment_path(
            packet.source_port,
            packet.source_channel,
            packet.sequence,
          ),
        ],
      ),
    )

  //========================arrange redeemer=======================
  let redeemer =
    VerifyMembership {
      cs: client_datum_state.client_state,
      cons_state: proof_cons_state,
      height: mock.proof_height,
      delay_time_period: 0,
      delay_block_period: 0,
      proof: proof_commitment,
      path: merkle_path,
      value: packet_commitment,
    }

  verifying_proof.verify_proof.mint(
    redeemer,
    #"2aa9c1557fcf8e7caa049fa0911a8724a1cdaf8037fe0b431c6ac663",
    placeholder,
  )
}

test batch_verify_membership_succeed() {
  let mock = setup()

  let packet =
    Packet {
      sequence: 1,
      source_port: mock.port_id,
      source_channel: mock.channel_id,
      destination_port: "port-1",
      destination_channel: "channel-0",
      data: "mock packet data",
      timeout_height: Height { revision_number: 0, revision_height: 0 },
      timeout_timestamp: 1735689600000000000,
    }
  let packet_commitment = packet_mod.commit_packet(packet)

  let proof_cons_state =
    ConsensusState {
      timestamp: 1577923295000000000,
      next_validators_hash: #"7c3af87e2c224be7f3b2d7b2ab467e69b1a4ef5947fbe76d55e9091e16172346",
      root: MerkleRoot {
        hash: #"11a648b10463e8a96c77976940ee316117bb8214bd380e267aa31cf39ef8a09a",
      },
    }

  let client_datum_state =
    insert_proof_cons_state(
      mock.client_datum_state,
      mock.proof_height,
      proof_cons_state,
    )

  let proof_commitment =
    MerkleProof {
      proofs: [
        CommitmentProof {
          proof: CommitmentProof_Exist {
            exist: ExistenceProof {
              key: #"636f6d6d69746d656e74732f706f7274732f706f72742d312f6368616e6e656c732f6368616e6e656c2d302f73657175656e6365732f31",
              value: #"fa365cf5deedf3169bfe56010f101be23eac638d3bc9f43c7634f78ef718aa10",
              leaf: LeafOp {
                hash: 1,
                prehash_value: 1,
                length: 1,
                prefix: #"000224",
                prehash_key: 0,
              },
              path: [
                InnerOp {
                  hash: 1,
                  prefix: #"020424205fd25b3dc1314970dcbf74075f9d165af4a185eea459128edf21cfacc14b9c9e20",
                  suffix: #"",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"04062420",
                  suffix: #"2067b76c7b82d60ebee7f41dd11a02534c1a16efa70c217310356230dfd5ad0c20",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"060a2420",
                  suffix: #"20f21e95601cbd0028a9c3c4effd8afbbe068f086ab152ec0edb9cde2fdd6c568f",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"08162420",
                  suffix: #"2038afa1cc8688eedde1256daab2bff7aade39a6db7320d62f47581fb65d9e8024",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"0a2424203dd3101284b12a1c86ec48897aaf11781985de6f1eb75fdb6c8011a7d3e4d2ad20",
                  suffix: #"",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"0c462420617a9deebfac19d019bc9f7179c90ed228ee21d7330bc10568918f6f26cbb75320",
                  suffix: #"",
                },
              ],
            },
          },
        },
        CommitmentProof {
          proof: CommitmentProof_Exist {
            exist: ExistenceProof {
              key: #"696263",
              value: #"6cfc3a7872f9703bcd5027ba7197890652bf545bd77a4ae7fa8b780746c91e42",
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
                  prefix: #"01ef0d5a163ae333b43e2956b2d9660e65aaa9a1e2f90b30a91d97b5d0f12fb1fc",
                  suffix: #"",
                },
                InnerOp {
                  hash: 1,
                  prefix: #"01",
                  suffix: #"04634f3eedce1a4677cef6f418f7671437db345ad7e26581393b7cc6e722a2c7",
                },
              ],
            },
          },
        },
      ],
    }

  let merkle_path =
    merkle.apply_prefix(
      MerklePrefix { key_prefix: "ibc" },
      merkle.new_merkle_path(
        [
          packet_keys.packet_commitment_path(
            packet.source_port,
            packet.source_channel,
            packet.sequence,
          ),
        ],
      ),
    )

  //========================arrange redeemer=======================
  let item =
    VerifyMembershipParams {
      cs: client_datum_state.client_state,
      cons_state: proof_cons_state,
      height: mock.proof_height,
      delay_time_period: 0,
      delay_block_period: 0,
      proof: proof_commitment,
      path: merkle_path,
      value: packet_commitment,
    }

  let redeemer = BatchVerifyMembership([item])
  verifying_proof.verify_proof.mint(
    redeemer,
    #"2aa9c1557fcf8e7caa049fa0911a8724a1cdaf8037fe0b431c6ac663",
    placeholder,
  )
}

test try_non_mock_data() {
  let redeemer =
    VerifyMembership {
      cs: ClientState {
        chain_id: #"76657373656c6f7261636c65",
        trust_level: UncheckedRational { numerator: 1, denominator: 3 },
        trusting_period: 129600000000000,
        unbonding_period: 1814400000000000,
        max_clock_drift: 600000000000,
        frozen_height: Height { revision_number: 0, revision_height: 0 },
        latest_height: Height { revision_number: 0, revision_height: 3307 },
        proof_specs: [
          ProofSpec {
            leaf_spec: LeafOp {
              hash: 1,
              prehash_key: 0,
              prehash_value: 1,
              length: 1,
              prefix: #"00",
            },
            inner_spec: InnerSpec {
              child_order: [0, 1],
              child_size: 33,
              min_prefix_length: 4,
              max_prefix_length: 12,
              empty_child: #"",
              hash: 1,
            },
            max_depth: 0,
            min_depth: 0,
            prehash_key_before_comparison: False,
          },
          ProofSpec {
            leaf_spec: LeafOp {
              hash: 1,
              prehash_key: 0,
              prehash_value: 1,
              length: 1,
              prefix: #"00",
            },
            inner_spec: InnerSpec {
              child_order: [0, 1],
              child_size: 32,
              min_prefix_length: 1,
              max_prefix_length: 1,
              empty_child: #"",
              hash: 1,
            },
            max_depth: 0,
            min_depth: 0,
            prehash_key_before_comparison: False,
          },
        ],
      },
      cons_state: ConsensusState {
        timestamp: 1740134865942839294,
        next_validators_hash: #"2b36af6d125b96f467ee9922d7e550139273287d192519bbf5dd1ed048e7afcf",
        root: MerkleRoot {
          hash: #"632ee6ce53b34cc2c482c264c98a38a9f92e62bd70fe605b023c08a16964ca55",
        },
      },
      height: Height { revision_height: 3307, revision_number: 0 },
      delay_time_period: 0,
      delay_block_period: 0,
      proof: MerkleProof {
        proofs: [
          CommitmentProof {
            proof: CommitmentProof_Exist {
              exist: ExistenceProof {
                key: #"636f6d6d69746d656e74732f706f7274732f76657373656c6f7261636c652f6368616e6e656c732f6368616e6e656c2d302f73657175656e6365732f31",
                value: #"2bdba8b2cb52bb179ddc46dc965e41a3cc1ba6df644284c49a2350fbd39af3b9",
                leaf: LeafOp {
                  hash: 1,
                  prehash_key: 0,
                  prehash_value: 1,
                  length: 1,
                  prefix: #"0002d433",
                },
                path: [
                  InnerOp {
                    hash: 1,
                    prefix: #"0204d433207237e3837bff42e016f5ff6cd23b9d6c3f22164f6817bdc8582fe21f06e81d1e20",
                    suffix: #"",
                  },
                  InnerOp {
                    hash: 1,
                    prefix: #"0406d43320d71290e60feeab3523516b51b69caaa897f6141205a29835c6ecaf2ab44c75b720",
                    suffix: #"",
                  },
                  InnerOp {
                    hash: 1,
                    prefix: #"060ed433203846074654705176bcfdea0f07626ab4e4d384e1d0a6fc1a31a5a928397db52020",
                    suffix: #"",
                  },
                  InnerOp {
                    hash: 1,
                    prefix: #"081ed433204cf1a0bce464357a563e68ea671f4b8606e0e2cdcabfbc453147199abdea6f7620",
                    suffix: #"",
                  },
                  InnerOp {
                    hash: 1,
                    prefix: #"0a2ed4332071120390fcf5eb89c0834a27c0e82ee4799ff4f90332c27e81abe7cb6aecd58020",
                    suffix: #"",
                  },
                  InnerOp {
                    hash: 1,
                    prefix: #"0c48d43320",
                    suffix: #"20d9b9bb45b9bddf83b25e448ce9b05f890ccf415c42f12f3694220014afe00ff6",
                  },
                  InnerOp {
                    hash: 1,
                    prefix: #"0e78d433208d844f45eae593f5477ae6374bead82d92907f4fac10c656c9109fcb9b9f8fb320",
                    suffix: #"",
                  },
                  InnerOp {
                    hash: 1,
                    prefix: #"10b601d433203ad034592c524d132ea8c3942aa6554fddfabf5612d243690976dda820820c2520",
                    suffix: #"",
                  },
                  InnerOp {
                    hash: 1,
                    prefix: #"14b404d4332042c9e6f4cb3d9634b13fef525fe8cc517853de84dc48d587a5ad89323a7232c720",
                    suffix: #"",
                  },
                ],
              },
            },
          },
          CommitmentProof {
            proof: CommitmentProof_Exist {
              exist: ExistenceProof {
                key: #"696263",
                value: #"79ad06badc77cfcec6da8216711c5b2743af77395c8c3f6b3c7e7bd3c08cef4e",
                leaf: LeafOp {
                  hash: 1,
                  prehash_key: 0,
                  prehash_value: 1,
                  length: 1,
                  prefix: #"00",
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
                    prefix: #"0124409a1441553dd16e3e14d0545222d206e3deaf20e7556054ed528c9f5d8eed",
                    suffix: #"",
                  },
                  InnerOp {
                    hash: 1,
                    prefix: #"0125d2f842ecb6275406c1725cf008cf592e4ac24ab06b3620ef298cdf04be3757",
                    suffix: #"",
                  },
                  InnerOp {
                    hash: 1,
                    prefix: #"01",
                    suffix: #"bcef0d671ce00b0ac164b07380af799318183fe147932dc79d72ade0bbca1875",
                  },
                ],
              },
            },
          },
        ],
      },
      path: MerklePath {
        key_path: [
          #"696263",
          #"636f6d6d69746d656e74732f706f7274732f76657373656c6f7261636c652f6368616e6e656c732f6368616e6e656c2d302f73657175656e6365732f31",
        ],
      },
      value: #"2bdba8b2cb52bb179ddc46dc965e41a3cc1ba6df644284c49a2350fbd39af3b9",
    }

  verifying_proof.verify_proof.mint(
    redeemer,
    #"fab5154f5008ec54a97b7693db78924e4bb9ccdbea2ea7db282bedb2",
    placeholder,
  )
}
