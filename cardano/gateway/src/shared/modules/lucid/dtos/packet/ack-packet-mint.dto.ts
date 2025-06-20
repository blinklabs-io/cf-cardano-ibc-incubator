import { UTxO, PolicyId } from '@lucid-evolution/lucid';
import { AuthToken } from '../../../../types/auth-token';

export type UnsignedAckPacketMintDto = {
  channelUtxo: UTxO;
  connectionUtxo: UTxO;
  clientUtxo: UTxO;
  transferModuleUtxo: UTxO;

  encodedSpendChannelRedeemer: string;
  encodedSpendTransferModuleRedeemer: string;
  encodedMintVoucherRedeemer: string;
  encodedUpdatedChannelDatum: string;

  channelTokenUnit: string;
  voucherTokenUnit: string;
  transferAmount: bigint;
  senderAddress: string;
  denomToken: string;
  constructedAddress: string;

  ackPacketPolicyId: PolicyId;
  channelToken: AuthToken;

  verifyProofPolicyId: PolicyId;
  encodedVerifyProofRedeemer: string;
};
