import { MsgUpdateClientResponse } from '@plus/proto-types/build/ibc/core/client/v1/tx';
import { TxBuilder, UTxO, fromHex } from '@lucid-evolution/lucid';
import { Inject, Injectable, Logger } from '@nestjs/common';
import { LucidService } from 'src/shared/modules/lucid/lucid.service';
import { GrpcInternalException } from '~@/exception/grpc_exceptions';
import {
  MsgConnectionOpenAck,
  MsgConnectionOpenAckResponse,
  MsgConnectionOpenConfirm,
  MsgConnectionOpenConfirmResponse,
  MsgConnectionOpenInit,
  MsgConnectionOpenInitResponse,
  MsgConnectionOpenTry,
  MsgConnectionOpenTryResponse,
} from '@plus/proto-types/build/ibc/core/connection/v1/tx';
import { RpcException } from '@nestjs/microservices';
import { HandlerDatum } from 'src/shared/types/handler-datum';
import { HandlerOperator } from 'src/shared/types/handler-operator';
import { AuthToken } from 'src/shared/types/auth-token';
import { ConnectionDatum } from 'src/shared/types/connection/connection-datum';
import { State } from 'src/shared/types/connection/state';
import { MintConnectionRedeemer, SpendConnectionRedeemer } from '@shared/types/connection/connection-redeemer';
import { ConfigService } from '@nestjs/config';
import { parseClientSequence } from 'src/shared/helpers/sequence';
import { convertHex2String, convertString2Hex, toHex } from '@shared/helpers/hex';
import { ClientDatum } from '@shared/types/client-datum';
import { isValidProofHeight } from './helper/height.validate';
import {
  validateAndFormatConnectionOpenAckParams,
  validateAndFormatConnectionOpenConfirmParams,
  validateAndFormatConnectionOpenInitParams,
  validateAndFormatConnectionOpenTryParams,
} from './helper/connection.validate';
import { VerifyProofRedeemer, encodeVerifyProofRedeemer } from '../shared/types/connection/verify-proof-redeemer';
import { getBlockDelay } from '../shared/helpers/verify';
import { connectionPath } from '../shared/helpers/connection';
import { ConnectionEnd, State as ConnectionState } from '@plus/proto-types/build/ibc/core/connection/v1/connection';
import { clientStatePath } from '~@/shared/helpers/client-state';
import { Any } from '@plus/proto-types/build/google/protobuf/any';
import { getMithrilClientStateForVerifyProofRedeemer } from '../shared/helpers/mithril-client';
import { ClientState as MithrilClientState } from '@plus/proto-types/build/ibc/lightclients/mithril/mithril';
import {
  ConnectionOpenAckOperator,
  ConnectionOpenConfirmOperator,
  ConnectionOpenInitOperator,
  ConnectionOpenTryOperator,
} from './dto';
import { CLIENT_PREFIX, CONNECTION_ID_PREFIX, DEFAULT_MERKLE_PREFIX } from '~@/constant';
import { UnsignedConnectionOpenAckDto } from '~@/shared/modules/lucid/dtos';

@Injectable()
export class ConnectionService {
  constructor(
    private readonly logger: Logger,
    private configService: ConfigService,
    @Inject(LucidService) private lucidService: LucidService,
  ) {}
  /**
   * Processes the connection open init tx.
   * @param data The message containing connection open initiation data.
   * @returns A promise resolving to a message response for connection open initiation include the unsigned_tx.
   */
  async connectionOpenInit(data: MsgConnectionOpenInit): Promise<MsgConnectionOpenInitResponse> {
    try {
      this.logger.log('Connection Open Init is processing');
      const { constructedAddress, connectionOpenInitOperator } = validateAndFormatConnectionOpenInitParams(data);
      // Build and complete the unsigned transaction
      const unsignedConnectionOpenInitTx: TxBuilder = await this.buildUnsignedConnectionOpenInitTx(
        connectionOpenInitOperator,
        constructedAddress,
      );
      const unsignedConnectionOpenInitTxValidTo: TxBuilder = unsignedConnectionOpenInitTx.validTo(
        Date.now() + 100 * 1e3,
      );

      // Todo: signing should be done by the relayer in the future
      const signedConnectionOpenInitTxCompleted = await (await unsignedConnectionOpenInitTxValidTo.complete()).sign
        .withWallet()
        .complete();

      this.logger.log(signedConnectionOpenInitTxCompleted.toHash(), 'connection open init - unsignedTX - hash');
      const response: MsgConnectionOpenInitResponse = {
        unsigned_tx: {
          type_url: '',
          value: fromHex(signedConnectionOpenInitTxCompleted.toCBOR()),
        },
      } as unknown as MsgUpdateClientResponse;
      return response;
    } catch (error) {
      this.logger.error(`connectionOpenInit: ${error}`);
      if (!(error instanceof RpcException)) {
        throw new GrpcInternalException(`An unexpected error occurred. ${error}`);
      } else {
        throw error;
      }
    }
  }
  /**
   * Processes the connection open try tx.
   * @param data The message containing connection open try data.
   * @returns A promise resolving to a message response for connection open try include the unsigned_tx.
   */
  /* istanbul ignore next */
  async connectionOpenTry(data: MsgConnectionOpenTry): Promise<MsgConnectionOpenTryResponse> {
    try {
      const { constructedAddress, connectionOpenTryOperator } = validateAndFormatConnectionOpenTryParams(data);
      // Build and complete the unsigned transaction
      const unsignedConnectionOpenTryTx: TxBuilder = await this.buildUnsignedConnectionOpenTryTx(
        connectionOpenTryOperator,
        constructedAddress,
      );
      const unsignedConnectionOpenTryTxValidTo: TxBuilder = unsignedConnectionOpenTryTx.validTo(Date.now() + 100 * 1e3);

      // Todo: signing should be done by the relayer in the future
      const signedConnectionOpenTryTxCompleted = await (await unsignedConnectionOpenTryTxValidTo.complete()).sign
        .withWallet()
        .complete();

      this.logger.log(signedConnectionOpenTryTxCompleted.toHash(), 'connection open try - unsignedTX - hash');
      const response: MsgConnectionOpenTryResponse = {
        unsigned_tx: {
          type_url: '',
          value: fromHex(signedConnectionOpenTryTxCompleted.toCBOR()),
        },
      } as unknown as MsgConnectionOpenTryResponse;
      return response;
    } catch (error) {
      this.logger.error(`connectionOpenTry: ${error}`);
      if (!(error instanceof RpcException)) {
        throw new GrpcInternalException(`An unexpected error occurred. ${error}`);
      } else {
        throw error;
      }
    }
  }
  /**
   * Processes the initiation of a connection open ack tx.
   * @param data The message containing connection open ack data.
   * @returns A promise resolving to a message response for connection open ack include the unsigned_tx.
   */
  async connectionOpenAck(data: MsgConnectionOpenAck): Promise<MsgConnectionOpenAckResponse> {
    this.logger.log('Connection Open Ack is processing', 'connectionOpenAck');
    try {
      const { constructedAddress, connectionOpenAckOperator } = validateAndFormatConnectionOpenAckParams(data);
      // Build and complete the unsigned transaction
      const unsignedConnectionOpenAckTx: TxBuilder = await this.buildUnsignedConnectionOpenAckTx(
        connectionOpenAckOperator,
        constructedAddress,
      );
      const unsignedConnectionOpenAckTxValidTo: TxBuilder = unsignedConnectionOpenAckTx.validTo(Date.now() + 100 * 1e3);
      // Todo: signing should be done by the relayer in the future
      const signedConnectionOpenAckTxCompleted = await (await unsignedConnectionOpenAckTxValidTo.complete()).sign
        .withWallet()
        .complete();

      this.logger.log(signedConnectionOpenAckTxCompleted.toHash(), 'connection open ack - unsignedTX - hash');
      const response: MsgConnectionOpenAckResponse = {
        unsigned_tx: {
          type_url: '',
          value: fromHex(signedConnectionOpenAckTxCompleted.toCBOR()),
        },
      } as unknown as MsgConnectionOpenAckResponse;
      return response;
    } catch (error) {
      console.error(error);

      this.logger.error(error, 'connectionOpenAck');
      this.logger.error(`connectionOpenAck: ${error.stack}`);
      if (!(error instanceof RpcException)) {
        throw new GrpcInternalException(`An unexpected error occurred. ${error}`);
      } else {
        throw error;
      }
    }
  }
  /**
   * Processes the initiation of a connection open confirm tx.
   * @param data The message containing connection open confirm data.
   * @returns A promise resolving to a message response for connection open confirm include the unsigned_tx.
   */
  /* istanbul ignore next */
  async connectionOpenConfirm(data: MsgConnectionOpenConfirm): Promise<MsgConnectionOpenConfirmResponse> {
    try {
      this.logger.log('Connection Open Confirm is processing');
      const { constructedAddress, connectionOpenConfirmOperator } = validateAndFormatConnectionOpenConfirmParams(data);
      // Build and complete the unsigned transaction
      const unsignedConnectionOpenConfirmTx: TxBuilder = await this.buildUnsignedConnectionOpenConfirmTx(
        connectionOpenConfirmOperator,
        constructedAddress,
      );
      const unsignedConnectionOpenConfirmTxValidTo: TxBuilder = unsignedConnectionOpenConfirmTx.validTo(
        Date.now() + 150 * 1e3,
      );

      // Todo: signing should be done by the relayer in the future
      const signedConnectionOpenConfirmTxCompleted = await (
        await unsignedConnectionOpenConfirmTxValidTo.complete()
      ).sign
        .withWallet()
        .complete();

      this.logger.log(signedConnectionOpenConfirmTxCompleted.toHash(), 'connection open confirm - unsignedTX - hash');
      const response: MsgConnectionOpenConfirmResponse = {
        unsigned_tx: {
          type_url: '',
          value: fromHex(signedConnectionOpenConfirmTxCompleted.toCBOR()),
        },
      } as unknown as MsgConnectionOpenConfirmResponse;
      return response;
    } catch (error) {
      this.logger.error(`connectionOpenConfirm: ${error}`);
      if (!(error instanceof RpcException)) {
        throw new GrpcInternalException(`An unexpected error occurred. ${error}`);
      } else {
        throw error;
      }
    }
  }

  //   =======
  /**
   * Builds an unsigned transaction for initiating a connection open.
   * @param connectionOpenInitOperator Input data.
   * @param constructedAddress The constructed address use for build tx.
   * @returns The unsigned transaction.
   */
  async buildUnsignedConnectionOpenInitTx(
    connectionOpenInitOperator: ConnectionOpenInitOperator,
    constructedAddress: string,
  ): Promise<TxBuilder> {
    const handlerUtxo: UTxO = await this.lucidService.findUtxoAtHandlerAuthToken();
    const handlerDatum: HandlerDatum = await this.lucidService.decodeDatum<HandlerDatum>(handlerUtxo.datum!, 'handler');
    // Get the token unit associated with the client
    const clientTokenUnit = this.lucidService.getClientTokenUnit(connectionOpenInitOperator.clientId);
    // Find the UTXO for the client token
    const clientUtxo = await this.lucidService.findUtxoByUnit(clientTokenUnit);
    // Retrieve the current client datum from the UTXO
    const updatedHandlerDatum: HandlerDatum = {
      ...handlerDatum,
      state: {
        ...handlerDatum.state,
        next_connection_sequence: handlerDatum.state.next_connection_sequence + 1n,
      },
    };
    const spendHandlerRedeemer: HandlerOperator = 'HandlerConnOpenInit';
    const [mintConnectionPolicyId, connectionTokenName] = this.lucidService.getConnectionTokenUnit(
      handlerDatum.state.next_connection_sequence,
    );
    const connectionTokenUnit = mintConnectionPolicyId + connectionTokenName;
    const connToken: AuthToken = {
      policyId: mintConnectionPolicyId,
      name: connectionTokenName,
    };
    const connectionDatum: ConnectionDatum = {
      state: {
        client_id: CLIENT_PREFIX + convertString2Hex('-' + connectionOpenInitOperator.clientId),
        counterparty: connectionOpenInitOperator.counterparty,
        delay_period: 0n,
        versions: connectionOpenInitOperator.versions,
        state: State.Init,
      },
      token: connToken,
    };
    const mintConnectionRedeemer: MintConnectionRedeemer = {
      ConnOpenInit: {
        handler_auth_token: this.configService.get('deployment').handlerAuthToken,
      },
    };
    const encodedMintConnectionRedeemer: string = await this.lucidService.encode<MintConnectionRedeemer>(
      mintConnectionRedeemer,
      'mintConnectionRedeemer',
    );

    const encodedSpendHandlerRedeemer: string = await this.lucidService.encode<HandlerOperator>(
      spendHandlerRedeemer,
      'handlerOperator',
    );
    const encodedUpdatedHandlerDatum: string = await this.lucidService.encode<HandlerDatum>(
      updatedHandlerDatum,
      'handler',
    );
    const encodedConnectionDatum: string = await this.lucidService.encode<ConnectionDatum>(
      connectionDatum,
      'connection',
    );
    return this.lucidService.createUnsignedConnectionOpenInitTransaction(
      handlerUtxo,
      encodedSpendHandlerRedeemer,
      connectionTokenUnit,
      clientUtxo,
      encodedMintConnectionRedeemer,
      encodedUpdatedHandlerDatum,
      encodedConnectionDatum,
      constructedAddress,
    );
  }

  /* istanbul ignore next */
  public async buildUnsignedConnectionOpenTryTx(
    connectionOpenTryOperator: ConnectionOpenTryOperator,
    constructedAddress: string,
  ): Promise<TxBuilder> {
    const handlerUtxo: UTxO = await this.lucidService.findUtxoAtHandlerAuthToken();
    const handlerDatum: HandlerDatum = await this.lucidService.decodeDatum<HandlerDatum>(handlerUtxo.datum!, 'handler');
    // Get the token unit associated with the client
    const clientTokenUnit = this.lucidService.getClientTokenUnit(connectionOpenTryOperator.clientId);
    // Find the UTXO for the client token
    const clientUtxo = await this.lucidService.findUtxoByUnit(clientTokenUnit);
    // Retrieve the current client datum from the UTXO
    const updatedHandlerDatum: HandlerDatum = {
      ...handlerDatum,
      state: {
        ...handlerDatum.state,
        next_connection_sequence: handlerDatum.state.next_connection_sequence + 1n,
      },
    };
    const spendHandlerRedeemer: HandlerOperator = 'HandlerConnOpenTry';
    const [mintConnectionPolicyId, connectionTokenName] = this.lucidService.getConnectionTokenUnit(
      handlerDatum.state.next_connection_sequence,
    );
    const connectionTokenUnit = mintConnectionPolicyId + connectionTokenName;
    const connToken: AuthToken = {
      policyId: mintConnectionPolicyId,
      name: connectionTokenName,
    };
    const connectionDatum: ConnectionDatum = {
      state: {
        client_id: CLIENT_PREFIX + convertString2Hex('-' + connectionOpenTryOperator.clientId),
        counterparty: connectionOpenTryOperator.counterparty,
        delay_period: 0n,
        versions: connectionOpenTryOperator.versions,
        state: State.TryOpen,
      },
      token: connToken,
    };
    const mintConnectionRedeemer: MintConnectionRedeemer = {
      ConnOpenTry: {
        handler_auth_token: this.configService.get('deployment').handlerAuthToken,
        client_state: connectionOpenTryOperator.counterpartyClientState,
        proof_init: connectionOpenTryOperator.proofInit,
        proof_client: connectionOpenTryOperator.proofClient,
        proof_height: connectionOpenTryOperator.proofHeight,
      },
    };
    const encodedMintConnectionRedeemer: string = await this.lucidService.encode<MintConnectionRedeemer>(
      mintConnectionRedeemer,
      'mintConnectionRedeemer',
    );
    const encodedSpendHandlerRedeemer: string = await this.lucidService.encode<HandlerOperator>(
      spendHandlerRedeemer,
      'handlerOperator',
    );
    const encodedUpdatedHandlerDatum: string = await this.lucidService.encode<HandlerDatum>(
      updatedHandlerDatum,
      'handler',
    );
    const encodedConnectionDatum: string = await this.lucidService.encode<ConnectionDatum>(
      connectionDatum,
      'connection',
    );
    return this.lucidService.createUnsignedConnectionOpenTryTransaction(
      handlerUtxo,
      encodedSpendHandlerRedeemer,
      connectionTokenUnit,
      clientUtxo,
      encodedMintConnectionRedeemer,
      encodedUpdatedHandlerDatum,
      encodedConnectionDatum,
      constructedAddress,
    );
  }

  private async buildUnsignedConnectionOpenAckTx(
    connectionOpenAckOperator: ConnectionOpenAckOperator,
    constructedAddress: string,
  ): Promise<TxBuilder> {
    // Get the token unit associated with the client
    const [mintConnectionPolicyId, connectionTokenName] = this.lucidService.getConnectionTokenUnit(
      BigInt(connectionOpenAckOperator.connectionSequence),
    );
    const connectionTokenUnit = mintConnectionPolicyId + connectionTokenName;
    // Find the UTXO for the client token
    const connectionUtxo = await this.lucidService.findUtxoByUnit(connectionTokenUnit);
    const spendConnectionRedeemer: SpendConnectionRedeemer = {
      ConnOpenAck: {
        counterparty_client_state: connectionOpenAckOperator.counterpartyClientState,
        proof_try: connectionOpenAckOperator.proofTry,
        proof_client: connectionOpenAckOperator.proofClient,
        proof_height: connectionOpenAckOperator.proofHeight,
      },
    };

    const connectionDatum: ConnectionDatum = await this.lucidService.decodeDatum<ConnectionDatum>(
      connectionUtxo.datum!,
      'connection',
    );

    const clientSequence = parseClientSequence(convertHex2String(connectionDatum.state.client_id));
    const updatedConnectionDatum: ConnectionDatum = {
      ...connectionDatum,
      state: {
        ...connectionDatum.state,
        state: State.Open,
        counterparty: {
          ...connectionDatum.state.counterparty,
          connection_id: connectionOpenAckOperator.counterpartyConnectionID,
        },
      },
    };
    // Get the token unit associated with the client
    const clientTokenUnit = this.lucidService.getClientTokenUnit(clientSequence);
    const clientUtxo = await this.lucidService.findUtxoByUnit(clientTokenUnit);
    const clientDatum: ClientDatum = await this.lucidService.decodeDatum<ClientDatum>(clientUtxo.datum!, 'client');
    // Get the keys (heights) of the map and convert them into an array
    const heightsArray = Array.from(clientDatum.state.consensusStates.keys());

    if (!isValidProofHeight(heightsArray, connectionOpenAckOperator.proofHeight.revisionHeight)) {
      throw new GrpcInternalException(`Invalid proof height: ${connectionOpenAckOperator.proofHeight.revisionHeight}`);
    }
    const encodedSpendConnectionRedeemer = await this.lucidService.encode<SpendConnectionRedeemer>(
      spendConnectionRedeemer,
      'spendConnectionRedeemer',
    );
    const encodedUpdatedConnectionDatum: string = await this.lucidService.encode<ConnectionDatum>(
      updatedConnectionDatum,
      'connection',
    );

    const verifyProofPolicyId = this.configService.get('deployment').validators.verifyProof.scriptHash;
    const [_, consensusState] = [...clientDatum.state.consensusStates.entries()].find(
      ([key]) => key.revisionHeight === connectionOpenAckOperator.proofHeight.revisionHeight,
    );
    const cardanoConnectionEnd: ConnectionEnd = {
      client_id: convertHex2String(connectionDatum.state.counterparty.client_id),
      versions: connectionDatum.state.versions.map((version) => ({
        identifier: convertHex2String(version.identifier),
        features: version.features.map((feature) => convertHex2String(feature)),
      })),
      state: ConnectionState.STATE_TRYOPEN,
      counterparty: {
        client_id: convertHex2String(connectionDatum.state.client_id),
        connection_id: `${CONNECTION_ID_PREFIX}-${connectionOpenAckOperator.connectionSequence}`,
        prefix: { key_prefix: fromHex(DEFAULT_MERKLE_PREFIX) },
      },
      delay_period: connectionDatum.state.delay_period,
    };

    const mithrilClientState: MithrilClientState = getMithrilClientStateForVerifyProofRedeemer(
      connectionOpenAckOperator.counterpartyClientState,
    );
    const mithrilClientStateAny: Any = {
      type_url: '/ibc.clients.mithril.v1.ClientState',
      value: MithrilClientState.encode(mithrilClientState).finish(),
    };
    const verifyProofRedeemer: VerifyProofRedeemer = {
      BatchVerifyMembership: [
        [
          {
            cs: clientDatum.state.clientState,
            cons_state: consensusState,
            height: connectionOpenAckOperator.proofHeight,
            delay_time_period: updatedConnectionDatum.state.delay_period,
            delay_block_period: BigInt(getBlockDelay(updatedConnectionDatum.state.delay_period)),
            proof: connectionOpenAckOperator.proofTry,
            path: {
              key_path: [
                updatedConnectionDatum.state.counterparty.prefix.key_prefix,
                convertString2Hex(
                  connectionPath(convertHex2String(updatedConnectionDatum.state.counterparty.connection_id)),
                ),
              ],
            },
            value: toHex(ConnectionEnd.encode(cardanoConnectionEnd).finish()),
          },
          {
            cs: clientDatum.state.clientState,
            cons_state: consensusState,
            height: connectionOpenAckOperator.proofHeight,
            delay_time_period: updatedConnectionDatum.state.delay_period,
            delay_block_period: BigInt(getBlockDelay(updatedConnectionDatum.state.delay_period)),
            proof: connectionOpenAckOperator.proofClient,
            path: {
              key_path: [
                updatedConnectionDatum.state.counterparty.prefix.key_prefix,
                convertString2Hex(
                  clientStatePath(convertHex2String(updatedConnectionDatum.state.counterparty.client_id)),
                ),
              ],
            },
            value: toHex(Any.encode(mithrilClientStateAny).finish()),
          },
        ],
      ],
    };

    const encodedVerifyProofRedeemer: string = encodeVerifyProofRedeemer(
      verifyProofRedeemer,
      this.lucidService.LucidImporter,
    );

    const unsignedConnectionOpenAckParams: UnsignedConnectionOpenAckDto = {
      connectionUtxo,
      encodedSpendConnectionRedeemer,
      connectionTokenUnit,
      clientUtxo,
      encodedUpdatedConnectionDatum,
      constructedAddress,
      verifyProofPolicyId,
      encodedVerifyProofRedeemer,
    };
    return this.lucidService.createUnsignedConnectionOpenAckTransaction(unsignedConnectionOpenAckParams);
  }
  /* istanbul ignore next */
  async buildUnsignedConnectionOpenConfirmTx(
    connectionOpenConfirmOperator: ConnectionOpenConfirmOperator,
    constructedAddress: string,
  ): Promise<TxBuilder> {
    // Get the token unit associated with the client
    const [mintConnectionPolicyId, connectionTokenName] = this.lucidService.getConnectionTokenUnit(
      BigInt(connectionOpenConfirmOperator.connectionSequence),
    );
    const connectionTokenUnit = mintConnectionPolicyId + connectionTokenName;
    // Find the UTXO for the client token
    const connectionUtxo = await this.lucidService.findUtxoByUnit(connectionTokenUnit);
    const spendConnectionRedeemer: SpendConnectionRedeemer = {
      ConnOpenConfirm: {
        proof_height: connectionOpenConfirmOperator.proofHeight,
        proof_ack: connectionOpenConfirmOperator.proofAck,
      },
    };
    const connectionDatum: ConnectionDatum = await this.lucidService.decodeDatum<ConnectionDatum>(
      connectionUtxo.datum!,
      'connection',
    );
    if (connectionDatum.state.state !== State.Init) {
      throw new Error('ConnOpenAck to a Connection not in Init state');
    }
    const clientSequence = parseClientSequence(convertHex2String(connectionDatum.state.client_id));
    const updatedConnectionDatum: ConnectionDatum = {
      ...connectionDatum,
      state: {
        ...connectionDatum.state,
        state: State.Open,
      },
    };
    // Get the token unit associated with the client
    const clientTokenUnit = this.lucidService.getClientTokenUnit(clientSequence);
    const clientUtxo = await this.lucidService.findUtxoByUnit(clientTokenUnit);
    const encodedSpendConnectionRedeemer = await this.lucidService.encode<SpendConnectionRedeemer>(
      spendConnectionRedeemer,
      'spendConnectionRedeemer',
    );
    const encodedUpdatedConnectionDatum = await this.lucidService.encode<ConnectionDatum>(
      updatedConnectionDatum,
      'connection',
    );
    return this.lucidService.createUnsignedConnectionOpenConfirmTransaction(
      connectionUtxo,
      encodedSpendConnectionRedeemer,
      connectionTokenUnit,
      clientUtxo,
      encodedUpdatedConnectionDatum,
      constructedAddress,
    );
  }
}
