use aiken/collection/list
use aiken/interval.{Finite, Interval, IntervalBound, PositiveInfinity}
use aiken/primitive/bytearray
use cardano/address.{from_script}
use cardano/assets.{
  PolicyId, ada_asset_name, ada_policy_id, add, from_asset, zero,
}
use cardano/transaction.{
  Datum, DatumHash, InlineDatum, Input, NoDatum, Output, OutputReference,
  Redeemer, ScriptPurpose, Spend, ValidityRange,
}
use ibc/auth.{AuthToken}
use ibc/client/ics_007_tendermint_client/client_datum.{
  ClientDatum, ClientDatumState,
}
use ibc/client/ics_007_tendermint_client/client_state
use ibc/client/ics_007_tendermint_client/consensus_state.{ConsensusState}
use ibc/client/ics_007_tendermint_client/height
use ibc/client/ics_007_tendermint_client/types/unchecked_rational
use ibc/core/ics_002_client_semantics/types/keys as client_keys
use ibc/core/ics_003_connection_semantics/connection_datum.{ConnectionDatum}
use ibc/core/ics_003_connection_semantics/types/connection_end.{ConnectionEnd}
use ibc/core/ics_003_connection_semantics/types/counterparty.{Counterparty}
use ibc/core/ics_003_connection_semantics/types/keys as connection_keys
use ibc/core/ics_003_connection_semantics/types/state as connection_state_mod
use ibc/core/ics_003_connection_semantics/types/version
use ibc/core/ics_004/types/keys as channel_keys
use ibc/core/ics_005/types/ibc_module_redeemer.{
  Callback, IBCModuleRedeemer, OnChanOpenInit,
}
use ibc/core/ics_005/types/keys as port_keys
use ibc/core/ics_023_vector_commitments/merkle
use ibc/core/ics_023_vector_commitments/merkle_prefix.{MerklePrefix}
use ibc/core/ics_025_handler_interface/handler.{HandlerState}
use ibc/core/ics_025_handler_interface/handler_datum.{HandlerDatum}
use ibc/core/ics_025_handler_interface/handler_redeemer.{
  CreateClient, HandlerConnOpenInit, HandlerOperator,
}
use ibc/utils/validator_utils

const hash_sample =
  #"a4a054a554354a85a54a054a554354a854a054a554a054a554a054a554a054a5"

test test_quantity_token_output() {
  let mock_policy_id = #"786a02f742015903c6c6fd852552d272912f4740e1584761"
  let mock_asset_name = "handler"
  let mock_outputs: List<Output> =
    [
      Output {
        address: from_script(hash_sample),
        value: from_asset(mock_policy_id, mock_asset_name, 1),
        datum: NoDatum,
        reference_script: None,
      },
      Output {
        address: from_script(hash_sample),
        value: from_asset(mock_policy_id, mock_asset_name, 2),
        datum: NoDatum,
        reference_script: None,
      },
      Output {
        address: from_script(hash_sample),
        value: from_asset(mock_policy_id, mock_asset_name, 3),
        datum: NoDatum,
        reference_script: None,
      },
    ]
  validator_utils.quantity_token_output(
    mock_outputs,
    mock_policy_id,
    mock_asset_name,
  ) == 6
}

test test_quantity_token_input() {
  let mock_policy_id = #"786a02f742015903c6c6fd852552d272912f4740e1584761"
  let mock_asset_name = "handler"
  let mock_inputs: List<Input> =
    [
      Input {
        output_reference: OutputReference {
          transaction_id: hash_sample,
          output_index: 0,
        },
        output: Output {
          address: from_script(hash_sample),
          value: from_asset(mock_policy_id, mock_asset_name, 1),
          datum: NoDatum,
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference {
          transaction_id: hash_sample,
          output_index: 1,
        },
        output: Output {
          address: from_script(hash_sample),
          value: from_asset(mock_policy_id, mock_asset_name, 2),
          datum: NoDatum,
          reference_script: None,
        },
      },
    ]
  validator_utils.quantity_token_input(
    mock_inputs,
    mock_policy_id,
    mock_asset_name,
  ) == 3
}

test test_get_tx_valid_to_succeed() {
  let expected_valid_to = 10
  let mock_validity_range: ValidityRange =
    Interval {
      lower_bound: IntervalBound { bound_type: Finite(1), is_inclusive: True },
      upper_bound: IntervalBound { bound_type: Finite(10), is_inclusive: True },
    }
  validator_utils.get_tx_valid_to(mock_validity_range) == expected_valid_to
}

// TODO: unable to set this value with Lucid
// test test_get_tx_valid_to_failed_with_upper_bound_is_not_inclusive() fail {
//   let expected_valid_to = 10
//   let mock_validity_range: ValidityRange =
//     Interval {
//       lower_bound: IntervalBound { bound_type: Finite(1), is_inclusive: True },
//       upper_bound: IntervalBound { bound_type: Finite(10), is_inclusive: False },
//     }
//   validator_utils.get_tx_valid_to(mock_validity_range) == expected_valid_to
// }

test test_get_tx_valid_to_failed_with_upper_bound_is_infinity() fail {
  let expected_valid_to = 10
  let mock_validity_range: ValidityRange =
    Interval {
      lower_bound: IntervalBound { bound_type: Finite(1), is_inclusive: True },
      upper_bound: IntervalBound {
        bound_type: PositiveInfinity,
        is_inclusive: False,
      },
    }
  validator_utils.get_tx_valid_to(mock_validity_range) == expected_valid_to
}

// Test for successfully getting inline datum from an output
test get_inline_datum_succeed() {
  let datum = InlineDatum(hash_sample)
  let output = create_output_sample(datum)
  expect data: ByteArray = validator_utils.get_inline_datum(output)
  data == hash_sample
}

// Test for failing to get inline datum when the output has NoDatum
test get_inline_datum_fail_when_no_datum() fail {
  let invalid_datum = NoDatum
  let output = create_output_sample(invalid_datum)
  expect data: ByteArray = validator_utils.get_inline_datum(output)
  data == hash_sample
}

// Test for failing to get inline datum when the output has DatumHash
test get_inline_datum_fail_when_datum_hash() fail {
  let invalid_datum = DatumHash(hash_sample)
  let output = create_output_sample(invalid_datum)
  expect data: ByteArray = validator_utils.get_inline_datum(output)
  data == hash_sample
}

fn create_output_sample(datum: Datum) -> Output {
  let output =
    Output {
      address: from_script(hash_sample),
      value: zero,
      datum,
      reference_script: None,
    }
  output
}

test test_validate_mint_succeed() {
  // Mock inputs
  let mock_minting_policy_id =
    #"ae402aa242a85d03dde0913882ec6cb0f36edec61ccd501692de1472"
  let mock_minting_token_name = #"68616e646c6572"
  let token_name_prefix = #"6368616e6e656c"
  let sequence = "0"

  let handler_token =
    AuthToken {
      policy_id: mock_minting_policy_id,
      name: mock_minting_token_name,
    }
  //get token name
  let token_name =
    auth.generate_token_name(handler_token, token_name_prefix, sequence)
  let mint =
    from_asset(
      policy_id: mock_minting_policy_id,
      asset_name: token_name,
      quantity: 1,
    )
  // Call the function under test
  let result =
    validator_utils.validate_mint(
      mint,
      mock_minting_policy_id,
      handler_token,
      token_name_prefix,
      sequence,
    )
  // Assert that the result is as expected
  result == AuthToken { ..handler_token, name: token_name }
}

test test_validate_mint_fail_when_mint_value_not_contains_auth_token() fail {
  // Mock inputs
  let mock_minting_policy_id =
    #"ae402aa242a85d03dde0913882ec6cb0f36edec61ccd501692de1472"
  let mock_minting_token_name = #"68616e646c6572"
  let token_name_prefix = #"6368616e6e656c"
  let sequence = "0"

  let handler_token =
    AuthToken {
      policy_id: mock_minting_policy_id,
      name: mock_minting_token_name,
    }
  //get token name
  let token_name =
    auth.generate_token_name(handler_token, token_name_prefix, sequence)
  let mint =
    from_asset(
      policy_id: mock_minting_policy_id,
      asset_name: token_name,
      quantity: 0,
    )
  // Call the function under test
  let result =
    validator_utils.validate_mint(
      mint,
      mock_minting_policy_id,
      handler_token,
      token_name_prefix,
      sequence,
    )
  // Assert that the result is as expected
  result == AuthToken { ..handler_token, name: token_name }
}

//==============================extract_module_redeemer===============================
fn setup_extract_module_redeemer() -> (
  List<Input>,
  Pairs<ScriptPurpose, Redeemer>,
  ByteArray,
  PolicyId,
  ByteArray,
  IBCModuleRedeemer,
) {
  let channel_token_name =
    auth.generate_token_name(
      AuthToken {
        policy_id: "mock handler policy_id",
        name: "mock handler name",
      },
      channel_keys.channel_prefix,
      "1",
    )

  let port_id = "port-100"
  let port_minting_policy_id = "mock port minting policy id"

  let port_number = port_keys.parse_port_id_number(port_id)
  let port_token_name =
    auth.generate_token_name_from_another(
      channel_token_name,
      port_keys.port_prefix,
      port_number,
    )
  let port_token =
    AuthToken { policy_id: port_minting_policy_id, name: port_token_name }

  let out_ref =
    OutputReference {
      transaction_id: #"30b9c5259b2a19052508957a025b5f150204027f1c6545fd886da6d281f6e926",
      output_index: 0,
    }

  let module_output =
    Output {
      address: from_script("mock module script hash"),
      value: from_asset(port_token.policy_id, port_token.name, 1),
      datum: InlineDatum(Void),
      reference_script: None,
    }

  let module_input = Input { output_reference: out_ref, output: module_output }

  let module_redeemer: Redeemer =
    Callback(OnChanOpenInit { channel_id: "channel-1" })

  let redeemers: Pairs<ScriptPurpose, Redeemer> =
    [Pair(Spend(out_ref), module_redeemer)]
  expect module_redeemer: IBCModuleRedeemer = module_redeemer

  (
    [module_input],
    redeemers,
    channel_token_name,
    port_minting_policy_id,
    port_id,
    module_redeemer,
  )
}

test extract_module_redeemer_succeed() {
  let (
    inputs,
    redeemers,
    channel_token_name,
    port_minting_policy_id,
    port_id,
    module_redeemer,
  ) = setup_extract_module_redeemer()

  validator_utils.extract_module_redeemer(
    inputs,
    redeemers,
    channel_token_name,
    port_minting_policy_id,
    port_id,
  ) == module_redeemer
}

test extract_module_redeemer_fail_if_inputs_not_contain_port_token() fail {
  let (
    _,
    redeemers,
    channel_token_name,
    port_minting_policy_id,
    port_id,
    module_redeemer,
  ) = setup_extract_module_redeemer()

  let inputs = []

  validator_utils.extract_module_redeemer(
    inputs,
    redeemers,
    channel_token_name,
    port_minting_policy_id,
    port_id,
  ) == module_redeemer
}

test extract_module_redeemer_fail_if_redeemers_not_contain_module_redeemer() fail {
  let (
    inputs,
    _,
    channel_token_name,
    port_minting_policy_id,
    port_id,
    module_redeemer,
  ) = setup_extract_module_redeemer()

  let redeemers = []

  validator_utils.extract_module_redeemer(
    inputs,
    redeemers,
    channel_token_name,
    port_minting_policy_id,
    port_id,
  ) == module_redeemer
}

test extract_module_redeemer_fail_if_found_redeemer_is_not_ibc_redeemer() fail {
  let (
    inputs,
    _,
    channel_token_name,
    port_minting_policy_id,
    port_id,
    module_redeemer,
  ) = setup_extract_module_redeemer()

  let invalid_module_redeemer: Redeemer = Void

  expect [module_input] = inputs

  let redeemers: Pairs<ScriptPurpose, Redeemer> =
    [Pair(Spend(module_input.output_reference), invalid_module_redeemer)]

  validator_utils.extract_module_redeemer(
    inputs,
    redeemers,
    channel_token_name,
    port_minting_policy_id,
    port_id,
  ) == module_redeemer
}

//==================================validate_token_remain================================
fn setup_validate_token_remain() -> (
  Output,
  List<Output>,
  List<AuthToken>,
  Output,
) {
  let tokens =
    [
      AuthToken { policy_id: "mock policy_id 1", name: "mock name" },
      AuthToken { policy_id: "mock policy_id 2", name: "mock name" },
    ]

  let output_value =
    list.reduce(
      tokens,
      zero,
      fn(acc, token) { add(acc, token.policy_id, token.name, 1) },
    )

  let spent_output =
    Output {
      address: from_script("mock script hash"),
      value: output_value,
      datum: InlineDatum(Void),
      reference_script: None,
    }

  let outputs = [spent_output]

  let updated_output = spent_output

  (spent_output, outputs, tokens, updated_output)
}

test validate_token_remain_succeed() {
  let (spent_output, outputs, tokens, updated_output) =
    setup_validate_token_remain()

  validator_utils.validate_token_remain(spent_output, outputs, tokens) == updated_output
}

test validate_token_remain_succeed_if_required_tokens_is_empty() {
  let (spent_output, outputs, _tokens, updated_output) =
    setup_validate_token_remain()

  validator_utils.validate_token_remain(spent_output, outputs, []) == updated_output
}

test validate_token_remain_fail_if_token_not_remained() fail {
  let (spent_output, outputs, tokens, _) = setup_validate_token_remain()

  expect [output, ..] = outputs

  let output = Output { ..output, value: zero }

  let result =
    validator_utils.validate_token_remain(spent_output, [output], tokens)
  result == result
}

//=====================================extract_token_unit===================================
fn setup_extract_token_unit() -> (ByteArray, ByteArray, ByteArray) {
  let policy_id = #"a0028f350aaabe0545fdcb56b039bfb08e4bb4d8c4d7c3c7d481c235"
  let name = "mock"

  let token_unit = bytearray.concat(policy_id, name)

  (token_unit, policy_id, name)
}

test extract_token_unit_succeed() {
  let (unit, policy_id, name) = setup_extract_token_unit()

  validator_utils.extract_token_unit(unit) == (policy_id, name)
}

test extract_token_unit_succeed_if_unit_is_lovelace() {
  validator_utils.extract_token_unit("lovelace") == (
    ada_policy_id,
    ada_asset_name,
  )
}

test extract_token_unit_fail_if_unit_length_invalid_too_long() fail {
  let too_long_unit =
    #"a0028f350aaabe0545fdcb56b039bfb08e4bb4d8c4d7c3c7d481c235a0028f350aaabe0545fdcb56b039bfb08e4bb4d8c4d7c3c7d481c235a0028f350aaabe0545fdcb56b039bfb08e4bb4d8c4d7c3c7d481c2"
  let result = validator_utils.extract_token_unit(too_long_unit)
  result == result
}

test extract_token_unit_fail_if_unit_length_invalid_too_short() fail {
  let too_short_unit = #"a0028f350aaabe0545fdcb56b039bfb08e4bb4d8c4d7c3c7d481c2"

  let result = validator_utils.extract_token_unit(too_short_unit)
  result == result
}

//===================================validate_handler_redeemer==========================
fn setup_validate_handler_redeemer() -> (
  List<Input>,
  Pairs<ScriptPurpose, Redeemer>,
  AuthToken,
  HandlerOperator,
  HandlerDatum,
) {
  let handler_token =
    AuthToken { policy_id: "mock policy_id", name: "mock name" }

  let out_ref =
    OutputReference {
      transaction_id: #"30b9c5259b2a19052508957a025b5f150204027f1c6545fd886da6d281f6e926",
      output_index: 0,
    }

  let handler_datum =
    HandlerDatum {
      state: HandlerState {
        next_client_sequence: 0,
        next_connection_sequence: 0,
        next_channel_sequence: 0,
        bound_port: [],
      },
      token: handler_token,
    }

  let handler_output =
    Output {
      address: from_script("mock script hash"),
      value: from_asset(handler_token.policy_id, handler_token.name, 1),
      datum: InlineDatum(handler_datum),
      reference_script: None,
    }

  let handler_input =
    Input { output_reference: out_ref, output: handler_output }

  let handler_redeemer: Redeemer = CreateClient

  let redeemers: Pairs<ScriptPurpose, Redeemer> =
    [Pair(Spend(out_ref), handler_redeemer)]

  expect handler_redeemer: HandlerOperator = handler_redeemer

  ([handler_input], redeemers, handler_token, handler_redeemer, handler_datum)
}

test validate_handler_redeemer_succeed() {
  let (inputs, redeemers, handler_token, handler_redeemer, handler_datum) =
    setup_validate_handler_redeemer()

  validator_utils.validate_handler_redeemer(
    inputs,
    redeemers,
    handler_token,
    handler_redeemer,
  ) == handler_datum
}

test validate_handler_redeemer_fail_inputs_not_contain_handler_input() fail {
  let (_inputs, redeemers, handler_token, handler_redeemer, _handler_datum) =
    setup_validate_handler_redeemer()

  let inputs = []

  let result =
    validator_utils.validate_handler_redeemer(
      inputs,
      redeemers,
      handler_token,
      handler_redeemer,
    )
  result == result
}

test validate_handler_redeemer_fail_redeemers_not_contain_handler_redeemer() fail {
  let (inputs, _redeemers, handler_token, handler_redeemer, _handler_datum) =
    setup_validate_handler_redeemer()

  let redeemers = []

  let result =
    validator_utils.validate_handler_redeemer(
      inputs,
      redeemers,
      handler_token,
      handler_redeemer,
    )
  result == result
}

test validate_handler_redeemer_fail_found_redeemer_is_not_handler_operator() fail {
  let (inputs, _redeemers, handler_token, handler_redeemer, _handler_datum) =
    setup_validate_handler_redeemer()

  let invalid_handler_redeemer: Redeemer = HandlerConnOpenInit
  expect [handler_input, ..] = inputs

  let redeemers: Pairs<ScriptPurpose, Redeemer> =
    [Pair(Spend(handler_input.output_reference), invalid_handler_redeemer)]

  let result =
    validator_utils.validate_handler_redeemer(
      inputs,
      redeemers,
      handler_token,
      handler_redeemer,
    )
  result == result
}

test validate_handler_redeemer_fail_found_redeemer_is_not_expected_operator() fail {
  let (inputs, _redeemers, handler_token, handler_redeemer, _handler_datum) =
    setup_validate_handler_redeemer()

  let invalid_handler_redeemer: Redeemer = HandlerConnOpenInit

  expect [handler_input, ..] = inputs

  let redeemers: Pairs<ScriptPurpose, Redeemer> =
    [Pair(Spend(handler_input.output_reference), invalid_handler_redeemer)]

  let result =
    validator_utils.validate_handler_redeemer(
      inputs,
      redeemers,
      handler_token,
      handler_redeemer,
    )
  result == result
}

test validate_handler_redeemer_fail_handler_datum_is_invalid() fail {
  let (inputs, redeemers, handler_token, handler_redeemer, _handler_datum) =
    setup_validate_handler_redeemer()

  expect [handler_input, ..] = inputs

  let handler_input =
    Input {
      ..handler_input,
      output: Output { ..handler_input.output, datum: InlineDatum(Void) },
    }

  let result =
    validator_utils.validate_handler_redeemer(
      [handler_input],
      redeemers,
      handler_token,
      handler_redeemer,
    )
  result == result
}

//=====================================validate_referred_client=========================================
fn setup_validate_referred_client() -> (
  List<Input>,
  ByteArray,
  PolicyId,
  ByteArray,
  ClientDatum,
) {
  let referrer_token_name =
    auth.generate_token_name(
      AuthToken {
        policy_id: "mock handler policy_id",
        name: "mock handler name",
      },
      channel_keys.channel_prefix,
      "1",
    )

  let client_id = "ibc_client-0"

  let client_minting_policy_id = "mock client policy id"

  let client_sequence = client_keys.parse_client_id_sequence(client_id)

  let client_token_name =
    auth.generate_token_name_from_another(
      referrer_token_name,
      client_keys.client_prefix,
      client_sequence,
    )

  let client_token =
    AuthToken { policy_id: client_minting_policy_id, name: client_token_name }

  let out_ref =
    OutputReference {
      transaction_id: #"30b9c5259b2a19052508957a025b5f150204027f1c6545fd886da6d281f6e926",
      output_index: 0,
    }

  let mock_client_state =
    client_state.new_client_state(
      "",
      unchecked_rational.from_int(1),
      1,
      1,
      1,
      height.zero_height(),
      [],
    )
  let mock_consensus_states =
    [
      Pair(
        height.zero_height(),
        ConsensusState {
          timestamp: 1,
          next_validators_hash: "mock_next_validators_hash",
          root: merkle.new_merkle_root("mock_app_hash"),
        },
      ),
    ]

  let client_datum =
    ClientDatum {
      state: ClientDatumState {
        client_state: mock_client_state,
        consensus_states: mock_consensus_states,
      },
      token: client_token,
    }

  let client_output =
    Output {
      address: from_script("mock script hash"),
      value: from_asset(client_token.policy_id, client_token.name, 1),
      datum: InlineDatum(client_datum),
      reference_script: None,
    }

  let client_input = Input { output_reference: out_ref, output: client_output }

  let reference_inputs = [client_input]

  (
    reference_inputs,
    referrer_token_name,
    client_minting_policy_id,
    client_id,
    client_datum,
  )
}

test validate_referred_client_succeed() {
  let (
    reference_inputs,
    referrer_token_name,
    client_minting_policy_id,
    client_id,
    client_datum,
  ) = setup_validate_referred_client()

  validator_utils.validate_referred_client(
    reference_inputs,
    referrer_token_name,
    client_minting_policy_id,
    client_id,
  ) == client_datum
}

test validate_referred_client_if_not_found_client_input() fail {
  let (
    _reference_inputs,
    referrer_token_name,
    client_minting_policy_id,
    client_id,
    _client_datum,
  ) = setup_validate_referred_client()

  let reference_inputs = []

  let result =
    validator_utils.validate_referred_client(
      reference_inputs,
      referrer_token_name,
      client_minting_policy_id,
      client_id,
    )
  result == result
}

test validate_referred_client_if_found_datum_is_not_client_datum() fail {
  let (
    reference_inputs,
    referrer_token_name,
    client_minting_policy_id,
    client_id,
    _client_datum,
  ) = setup_validate_referred_client()

  expect [client_input, ..] = reference_inputs

  let client_input =
    Input {
      ..client_input,
      output: Output { ..client_input.output, datum: InlineDatum(Void) },
    }

  let reference_inputs = [client_input]

  let result =
    validator_utils.validate_referred_client(
      reference_inputs,
      referrer_token_name,
      client_minting_policy_id,
      client_id,
    )
  result == result
}

// =====================================validate_referred_connection=========================================
fn setup_validate_referred_connection() -> (
  List<Input>,
  ByteArray,
  PolicyId,
  ByteArray,
  ConnectionDatum,
) {
  let referrer_token_name =
    auth.generate_token_name(
      AuthToken {
        policy_id: "mock handler policy_id",
        name: "mock handler name",
      },
      channel_keys.channel_prefix,
      "1",
    )

  let connection_id = "connection-0"

  let connection_minting_policy_id = "mock connection policy id"

  let connection_sequence =
    connection_keys.parse_connection_id_sequence(connection_id)

  let connection_token_name =
    auth.generate_token_name_from_another(
      referrer_token_name,
      connection_keys.connection_prefix,
      connection_sequence,
    )

  let connection_token =
    AuthToken {
      policy_id: connection_minting_policy_id,
      name: connection_token_name,
    }

  let out_ref =
    OutputReference {
      transaction_id: #"30b9c5259b2a19052508957a025b5f150204027f1c6545fd886da6d281f6e926",
      output_index: 0,
    }

  let connection_datum =
    ConnectionDatum {
      state: ConnectionEnd {
        client_id: "mock_client_id",
        versions: version.get_compatible_versions(),
        state: connection_state_mod.TryOpen,
        counterparty: Counterparty {
          client_id: "mock_counterparty_client_id",
          connection_id: "mock connection_id",
          prefix: MerklePrefix { key_prefix: "mock_key_prefix" },
        },
        delay_period: 1,
      },
      token: connection_token,
    }

  let connection_output =
    Output {
      address: from_script("mock script hash"),
      value: from_asset(connection_token.policy_id, connection_token.name, 1),
      datum: InlineDatum(connection_datum),
      reference_script: None,
    }

  let connection_input =
    Input { output_reference: out_ref, output: connection_output }

  let reference_inputs = [connection_input]

  (
    reference_inputs,
    referrer_token_name,
    connection_minting_policy_id,
    connection_id,
    connection_datum,
  )
}

test validate_referred_connection_succeed() {
  let (
    reference_inputs,
    referrer_token_name,
    connection_minting_policy_id,
    connection_id,
    connection_datum,
  ) = setup_validate_referred_connection()

  validator_utils.validate_referred_connection(
    reference_inputs,
    referrer_token_name,
    connection_minting_policy_id,
    connection_id,
  ) == connection_datum
}

test validate_referred_connection_if_not_found_connection_input() fail {
  let (
    _reference_inputs,
    referrer_token_name,
    connection_minting_policy_id,
    connection_id,
    _connection_datum,
  ) = setup_validate_referred_connection()

  let reference_inputs = []

  let result =
    validator_utils.validate_referred_connection(
      reference_inputs,
      referrer_token_name,
      connection_minting_policy_id,
      connection_id,
    )
  result == result
}

test validate_referred_connection_if_found_datum_is_not_connection_datum() fail {
  let (
    reference_inputs,
    referrer_token_name,
    connection_minting_policy_id,
    connection_id,
    _connection_datum,
  ) = setup_validate_referred_connection()

  expect [connection_input, ..] = reference_inputs

  let connection_input =
    Input {
      ..connection_input,
      output: Output { ..connection_input.output, datum: InlineDatum(Void) },
    }

  let reference_inputs = [connection_input]

  let result =
    validator_utils.validate_referred_connection(
      reference_inputs,
      referrer_token_name,
      connection_minting_policy_id,
      connection_id,
    )
  result == result
}
