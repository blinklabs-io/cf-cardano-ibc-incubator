import { Counterparty } from 'src/shared/types/connection/counterparty';
import { Version } from 'src/shared/types/connection/version';
import { Height } from 'src/shared/types/height';
import { CardanoClientState } from '@shared/types/cardano';
import { MerkleProof } from '@shared/types/isc-23/merkle';

export type ConnectionOpenTryOperator = {
  clientId: string;
  counterparty: Counterparty;
  versions: Version[];
  counterpartyClientState: CardanoClientState;
  proofInit: MerkleProof;
  proofClient: MerkleProof;
  proofHeight: Height;
};