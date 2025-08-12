import { UTxO } from '@lucid-evolution/lucid';
import { ClientDatum } from '../../../shared/types/client-datum';
import { Header } from '../../../shared/types/header';
import { Any } from '@plus/proto-types/build/google/protobuf/any';

export type UpdateClientOperatorDto = {
  clientId: string;
  header: Header;
  constructedAddress: string;
  clientDatum: ClientDatum;
  clientTokenUnit: string;
  currentClientUtxo: UTxO;
  txValidFrom: bigint;
};

export type UpdateOnMisbehaviourOperatorDto = {
  clientId: string;
  clientMessage: Any;
  constructedAddress: string;
  clientDatum: ClientDatum;
  clientTokenUnit: string;
  currentClientUtxo: UTxO;
};
