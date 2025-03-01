import { PolicyId, UTxO } from '@lucid-evolution/lucid';

export type UnsignedConnectionOpenAckDto = {
  connectionUtxo: UTxO;
  clientUtxo: UTxO;
  constructedAddress: string;

  spendConnectionRefUtxo: UTxO;
  verifyProofRefUTxO: UTxO;

  connectionTokenUnit: string;
  encodedSpendConnectionRedeemer: string;
  encodedUpdatedConnectionDatum: string;

  verifyProofPolicyId: PolicyId;
  encodedVerifyProofRedeemer: string;
};
