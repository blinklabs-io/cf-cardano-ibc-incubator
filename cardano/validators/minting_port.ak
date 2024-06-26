use aiken/dict.{Dict}
use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/transaction.{
  InlineDatum, Input, Mint, Output, OutputReference, Redeemer, ScriptContext,
  ScriptPurpose, Spend, Transaction, TransactionId,
}
use aiken/transaction/credential.{Script}
use aiken/transaction/value.{PolicyId}
use ibc/auth.{AuthToken}
use ibc/core/ics_005/port_redeemer.{MintPortRedeemer}
use ibc/core/ics_005/types/keys as port_keys
use ibc/core/ics_025_handler_interface/handler.{HandlerState}
use ibc/core/ics_025_handler_interface/handler_datum.{HandlerDatum}
use ibc/core/ics_025_handler_interface/handler_redeemer.{
  HandlerBindPort, HandlerOperator,
}
use ibc/utils/string as string_utils
use ibc/utils/validator_utils

validator {
  fn mint_port(redeemer: MintPortRedeemer, context: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = context
    expect Mint(port_minting_policy_id) = purpose
    let Transaction { inputs, outputs, mint, redeemers, .. } = transaction
    trace @"mint_port: extracted context data"

    let MintPortRedeemer {
      handler_token,
      spend_module_script_hash,
      port_number,
    } = redeemer

    expect Some(handler_input) =
      list.find(
        inputs,
        fn(input) { input.output |> auth.contain_auth_token(handler_token) },
      )
    // spent handler redeemer is HandlerBindPort operator
    expect Some(spent_handler_redeemer) =
      redeemers |> dict.get(Spend(handler_input.output_reference))
    expect handler_operator: HandlerOperator = spent_handler_redeemer
    expect handler_operator == HandlerBindPort
    trace @"mint_port: handler redeemer is valid"

    let port_token_name =
      string_utils.int_to_string(port_number)
        |> auth.generate_token_name(handler_token, port_keys.port_prefix, _)
    let port_token =
      AuthToken { policy_id: port_minting_policy_id, name: port_token_name }
    expect auth.mint_auth_token(mint, port_token)
    trace @"mint_port: mint valid token"

    expect [module_output] =
      outputs
        |> transaction.find_script_outputs(spend_module_script_hash)
    expect module_output |> auth.contain_auth_token(port_token)
    trace @"mint_port: module output contain token"

    True
  }
}

//=========================================Test=======================================
pub type MockData {
  handler_token: AuthToken,
  port_minting_policy_id: PolicyId,
  spend_module_script_hash: Hash<Blake2b_224, Script>,
  handler_input: Input,
  port_number: Int,
  port_token: AuthToken,
}

fn setup() -> MockData {
  let handler_token =
    AuthToken { policy_id: "mock handler policy_id", name: "mock name" }

  let port_minting_policy_id = "mock port_minting_policy_id"

  let port_number = 100

  let spend_module_script_hash = "mock spend_module_script_hash"

  let spend_handler_output_reference =
    OutputReference {
      transaction_id: TransactionId { hash: "tx_hash" },
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

  let handler_input =
    Input {
      output_reference: spend_handler_output_reference,
      output: Output {
        address: credential.from_script("mock handler script hash"),
        value: value.from_asset(handler_token.policy_id, handler_token.name, 1),
        datum: InlineDatum(handler_datum),
        reference_script: None,
      },
    }

  let port_token_name =
    string_utils.int_to_string(port_number)
      |> auth.generate_token_name(handler_token, port_keys.port_prefix, _)
  let port_token =
    AuthToken { policy_id: port_minting_policy_id, name: port_token_name }

  MockData {
    handler_token,
    port_minting_policy_id,
    spend_module_script_hash,
    handler_input,
    port_number,
    port_token,
  }
}

test mint_port_succeed() {
  let mock = setup()

  //==============================arrange redeemer============================
  let redeemer =
    MintPortRedeemer {
      handler_token: mock.handler_token,
      spend_module_script_hash: mock.spend_module_script_hash,
      port_number: mock.port_number,
    }

  //===============================arrange inputs===============================
  let inputs =
    [mock.handler_input]

  //==============================arrange outputs==============================
  let module_output =
    Output {
      address: credential.from_script(mock.spend_module_script_hash),
      value: value.from_asset(
        mock.port_token.policy_id,
        mock.port_token.name,
        1,
      ),
      datum: InlineDatum(Void),
      reference_script: None,
    }
  let outputs =
    [module_output]
  //==============================arrange mint==============================
  let mint =
    value.from_asset(mock.port_token.policy_id, mock.port_token.name, 1)
      |> value.to_minted_value()

  //==============================arrange redeemers==============================
  let handler_redeemer: Redeemer = HandlerBindPort

  let redeemers: Dict<ScriptPurpose, Redeemer> =
    dict.new()
      |> dict.insert(
          Spend(mock.handler_input.output_reference),
          handler_redeemer,
          validator_utils.compare_purpose,
        )
      |> dict.insert(
          Mint(mock.port_minting_policy_id),
          redeemer,
          validator_utils.compare_purpose,
        )

  //==========================arrange context=========================
  let context =
    ScriptContext {
      purpose: Mint(mock.port_minting_policy_id),
      transaction: Transaction {
        ..transaction.placeholder(),
        inputs: inputs,
        outputs: outputs,
        mint: mint,
        redeemers: redeemers,
      },
    }

  mint_port(redeemer, context)
}
