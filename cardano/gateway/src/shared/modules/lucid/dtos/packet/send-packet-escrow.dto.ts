import { PolicyId, UTxO } from '@lucid-evolution/lucid';
import { AuthToken } from '@shared/types/auth-token';

export type UnsignedSendPacketEscrowDto = {
  channelUTxO: UTxO;
  connectionUTxO: UTxO;
  clientUTxO: UTxO;
  transferModuleUTxO: UTxO;

  encodedSpendChannelRedeemer: string;
  encodedSpendTransferModuleRedeemer: string;
  encodedUpdatedChannelDatum: string;

  transferAmount: bigint;
  senderAddress: string;
  receiverAddress: string;

  spendChannelAddress: string;
  channelTokenUnit: string;
  transferModuleAddress: string;
  denomToken: string;

  constructedAddress: string;

  sendPacketPolicyId: PolicyId;
  channelToken: AuthToken;
};
