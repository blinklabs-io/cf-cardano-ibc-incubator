package helpers

type AutoGenerated struct {
	Validators struct {
		SpendHandler struct {
			Title      string `json:"title"`
			Script     string `json:"script"`
			ScriptHash string `json:"scriptHash"`
			Address    string `json:"address"`
			RefUtxo    struct {
				TxHash      string `json:"txHash"`
				OutputIndex int    `json:"outputIndex"`
				Address     string `json:"address"`
				Assets      struct {
					Lovelace int `json:"lovelace"`
				} `json:"assets"`
				DatumHash string `json:"datumHash"`
				Datum     string `json:"datum"`
				ScriptRef struct {
					Type   string `json:"type"`
					Script string `json:"script"`
				} `json:"scriptRef"`
			} `json:"refUtxo"`
		} `json:"spendHandler"`
		SpendClient struct {
			Title      string `json:"title"`
			Script     string `json:"script"`
			ScriptHash string `json:"scriptHash"`
			Address    string `json:"address"`
			RefUtxo    struct {
				TxHash      string `json:"txHash"`
				OutputIndex int    `json:"outputIndex"`
				Address     string `json:"address"`
				Assets      struct {
					Lovelace int `json:"lovelace"`
				} `json:"assets"`
				DatumHash string `json:"datumHash"`
				Datum     string `json:"datum"`
				ScriptRef struct {
					Type   string `json:"type"`
					Script string `json:"script"`
				} `json:"scriptRef"`
			} `json:"refUtxo"`
		} `json:"spendClient"`
		MintClient struct {
			Title      string `json:"title"`
			Script     string `json:"script"`
			ScriptHash string `json:"scriptHash"`
			Address    string `json:"address"`
			RefUtxo    struct {
				TxHash      string `json:"txHash"`
				OutputIndex int    `json:"outputIndex"`
				Address     string `json:"address"`
				Assets      struct {
					Lovelace int `json:"lovelace"`
				} `json:"assets"`
				DatumHash string `json:"datumHash"`
				Datum     string `json:"datum"`
				ScriptRef struct {
					Type   string `json:"type"`
					Script string `json:"script"`
				} `json:"scriptRef"`
			} `json:"refUtxo"`
		} `json:"mintClient"`
		MintConnection struct {
			Title      string `json:"title"`
			Script     string `json:"script"`
			ScriptHash string `json:"scriptHash"`
			Address    string `json:"address"`
			RefUtxo    struct {
				TxHash      string `json:"txHash"`
				OutputIndex int    `json:"outputIndex"`
				Address     string `json:"address"`
				Assets      struct {
					Lovelace int `json:"lovelace"`
				} `json:"assets"`
				DatumHash string `json:"datumHash"`
				Datum     string `json:"datum"`
				ScriptRef struct {
					Type   string `json:"type"`
					Script string `json:"script"`
				} `json:"scriptRef"`
			} `json:"refUtxo"`
		} `json:"mintConnection"`
		SpendConnection struct {
			Title      string `json:"title"`
			Script     string `json:"script"`
			ScriptHash string `json:"scriptHash"`
			Address    string `json:"address"`
			RefUtxo    struct {
				TxHash      string `json:"txHash"`
				OutputIndex int    `json:"outputIndex"`
				Address     string `json:"address"`
				Assets      struct {
					Lovelace int `json:"lovelace"`
				} `json:"assets"`
				DatumHash string `json:"datumHash"`
				Datum     string `json:"datum"`
				ScriptRef struct {
					Type   string `json:"type"`
					Script string `json:"script"`
				} `json:"scriptRef"`
			} `json:"refUtxo"`
		} `json:"spendConnection"`
		MintChannel struct {
			Title      string `json:"title"`
			Script     string `json:"script"`
			ScriptHash string `json:"scriptHash"`
			Address    string `json:"address"`
			RefUtxo    struct {
				TxHash      string `json:"txHash"`
				OutputIndex int    `json:"outputIndex"`
				Address     string `json:"address"`
				Assets      struct {
					Lovelace int `json:"lovelace"`
				} `json:"assets"`
				DatumHash string `json:"datumHash"`
				Datum     string `json:"datum"`
				ScriptRef struct {
					Type   string `json:"type"`
					Script string `json:"script"`
				} `json:"scriptRef"`
			} `json:"refUtxo"`
		} `json:"mintChannel"`
		SpendChannel struct {
			Title      string `json:"title"`
			Script     string `json:"script"`
			ScriptHash string `json:"scriptHash"`
			Address    string `json:"address"`
			RefUtxo    struct {
				TxHash      string `json:"txHash"`
				OutputIndex int    `json:"outputIndex"`
				Address     string `json:"address"`
				Assets      struct {
					Lovelace int `json:"lovelace"`
				} `json:"assets"`
				DatumHash string `json:"datumHash"`
				Datum     string `json:"datum"`
				ScriptRef struct {
					Type   string `json:"type"`
					Script string `json:"script"`
				} `json:"scriptRef"`
			} `json:"refUtxo"`
			RefValidator struct {
				ChanOpenConfirm struct {
					Script     string `json:"script"`
					ScriptHash string `json:"scriptHash"`
					RefUtxo    struct {
						TxHash      string `json:"txHash"`
						OutputIndex int    `json:"outputIndex"`
						Address     string `json:"address"`
						Assets      struct {
							Lovelace int `json:"lovelace"`
						} `json:"assets"`
						DatumHash string `json:"datumHash"`
						Datum     string `json:"datum"`
						ScriptRef struct {
							Type   string `json:"type"`
							Script string `json:"script"`
						} `json:"scriptRef"`
					} `json:"refUtxo"`
				} `json:"chan_open_confirm"`
				ChanOpenAck struct {
					Script     string `json:"script"`
					ScriptHash string `json:"scriptHash"`
					RefUtxo    struct {
						TxHash      string `json:"txHash"`
						OutputIndex int    `json:"outputIndex"`
						Address     string `json:"address"`
						Assets      struct {
							Lovelace int `json:"lovelace"`
						} `json:"assets"`
						DatumHash string `json:"datumHash"`
						Datum     string `json:"datum"`
						ScriptRef struct {
							Type   string `json:"type"`
							Script string `json:"script"`
						} `json:"scriptRef"`
					} `json:"refUtxo"`
				} `json:"chan_open_ack"`
				AcknowledgePacket struct {
					Script     string `json:"script"`
					ScriptHash string `json:"scriptHash"`
					RefUtxo    struct {
						TxHash      string `json:"txHash"`
						OutputIndex int    `json:"outputIndex"`
						Address     string `json:"address"`
						Assets      struct {
							Lovelace int `json:"lovelace"`
						} `json:"assets"`
						DatumHash string `json:"datumHash"`
						Datum     string `json:"datum"`
						ScriptRef struct {
							Type   string `json:"type"`
							Script string `json:"script"`
						} `json:"scriptRef"`
					} `json:"refUtxo"`
				} `json:"acknowledge_packet"`
				SendPacket struct {
					Script     string `json:"script"`
					ScriptHash string `json:"scriptHash"`
					RefUtxo    struct {
						TxHash      string `json:"txHash"`
						OutputIndex int    `json:"outputIndex"`
						Address     string `json:"address"`
						Assets      struct {
							Lovelace int `json:"lovelace"`
						} `json:"assets"`
						DatumHash string `json:"datumHash"`
						Datum     string `json:"datum"`
						ScriptRef struct {
							Type   string `json:"type"`
							Script string `json:"script"`
						} `json:"scriptRef"`
					} `json:"refUtxo"`
				} `json:"send_packet"`
				RecvPacket struct {
					Script     string `json:"script"`
					ScriptHash string `json:"scriptHash"`
					RefUtxo    struct {
						TxHash      string `json:"txHash"`
						OutputIndex int    `json:"outputIndex"`
						Address     string `json:"address"`
						Assets      struct {
							Lovelace int `json:"lovelace"`
						} `json:"assets"`
						DatumHash string `json:"datumHash"`
						Datum     string `json:"datum"`
						ScriptRef struct {
							Type   string `json:"type"`
							Script string `json:"script"`
						} `json:"scriptRef"`
					} `json:"refUtxo"`
				} `json:"recv_packet"`
				TimeoutPacket struct {
					Script     string `json:"script"`
					ScriptHash string `json:"scriptHash"`
					RefUtxo    struct {
						TxHash      string `json:"txHash"`
						OutputIndex int    `json:"outputIndex"`
						Address     string `json:"address"`
						Assets      struct {
							Lovelace int `json:"lovelace"`
						} `json:"assets"`
						DatumHash string `json:"datumHash"`
						Datum     string `json:"datum"`
						ScriptRef struct {
							Type   string `json:"type"`
							Script string `json:"script"`
						} `json:"scriptRef"`
					} `json:"refUtxo"`
				} `json:"timeout_packet"`
			} `json:"refValidator"`
		} `json:"spendChannel"`
		MintPort struct {
			Title      string `json:"title"`
			Script     string `json:"script"`
			ScriptHash string `json:"scriptHash"`
			Address    string `json:"address"`
			RefUtxo    struct {
				TxHash      string `json:"txHash"`
				OutputIndex int    `json:"outputIndex"`
				Address     string `json:"address"`
				Assets      struct {
					Lovelace int `json:"lovelace"`
				} `json:"assets"`
				DatumHash string `json:"datumHash"`
				Datum     string `json:"datum"`
				ScriptRef struct {
					Type   string `json:"type"`
					Script string `json:"script"`
				} `json:"scriptRef"`
			} `json:"refUtxo"`
		} `json:"mintPort"`
		MintIdentifier struct {
			Title      string `json:"title"`
			Script     string `json:"script"`
			ScriptHash string `json:"scriptHash"`
			Address    string `json:"address"`
			RefUtxo    struct {
				TxHash      string `json:"txHash"`
				OutputIndex int    `json:"outputIndex"`
				Address     string `json:"address"`
				Assets      struct {
					Lovelace int `json:"lovelace"`
				} `json:"assets"`
				DatumHash string `json:"datumHash"`
				Datum     string `json:"datum"`
				ScriptRef struct {
					Type   string `json:"type"`
					Script string `json:"script"`
				} `json:"scriptRef"`
			} `json:"refUtxo"`
		} `json:"mintIdentifier"`
		SpendTransferModule struct {
			Title      string `json:"title"`
			Script     string `json:"script"`
			ScriptHash string `json:"scriptHash"`
			Address    string `json:"address"`
			RefUtxo    struct {
				TxHash      string `json:"txHash"`
				OutputIndex int    `json:"outputIndex"`
				Address     string `json:"address"`
				Assets      struct {
					Lovelace int `json:"lovelace"`
				} `json:"assets"`
				DatumHash string `json:"datumHash"`
				Datum     string `json:"datum"`
				ScriptRef struct {
					Type   string `json:"type"`
					Script string `json:"script"`
				} `json:"scriptRef"`
			} `json:"refUtxo"`
		} `json:"spendTransferModule"`
		SpendMockModule struct {
			Title      string `json:"title"`
			Script     string `json:"script"`
			ScriptHash string `json:"scriptHash"`
			Address    string `json:"address"`
			RefUtxo    struct {
				TxHash      string `json:"txHash"`
				OutputIndex int    `json:"outputIndex"`
				Address     string `json:"address"`
				Assets      struct {
					Lovelace int `json:"lovelace"`
				} `json:"assets"`
				DatumHash string `json:"datumHash"`
				Datum     string `json:"datum"`
				ScriptRef struct {
					Type   string `json:"type"`
					Script string `json:"script"`
				} `json:"scriptRef"`
			} `json:"refUtxo"`
		} `json:"spendMockModule"`
		MintVoucher struct {
			Title      string `json:"title"`
			Script     string `json:"script"`
			ScriptHash string `json:"scriptHash"`
			Address    string `json:"address"`
			RefUtxo    struct {
				TxHash      string `json:"txHash"`
				OutputIndex int    `json:"outputIndex"`
				Address     string `json:"address"`
				Assets      struct {
					Lovelace int `json:"lovelace"`
				} `json:"assets"`
				DatumHash string `json:"datumHash"`
				Datum     string `json:"datum"`
				ScriptRef struct {
					Type   string `json:"type"`
					Script string `json:"script"`
				} `json:"scriptRef"`
			} `json:"refUtxo"`
		} `json:"mintVoucher"`
		VerifyProof struct {
			Title      string `json:"title"`
			Script     string `json:"script"`
			ScriptHash string `json:"scriptHash"`
			Address    string `json:"address"`
			RefUtxo    struct {
				TxHash      string `json:"txHash"`
				OutputIndex int    `json:"outputIndex"`
				Address     string `json:"address"`
				Assets      struct {
					Lovelace int `json:"lovelace"`
				} `json:"assets"`
				DatumHash string `json:"datumHash"`
				Datum     string `json:"datum"`
				ScriptRef struct {
					Type   string `json:"type"`
					Script string `json:"script"`
				} `json:"scriptRef"`
			} `json:"refUtxo"`
		} `json:"verifyProof"`
	} `json:"validators"`
	HandlerAuthToken struct {
		PolicyID string `json:"policyId"`
		Name     string `json:"name"`
	} `json:"handlerAuthToken"`
	Modules struct {
		Handler struct {
			Identifier string `json:"identifier"`
			Address    string `json:"address"`
		} `json:"handler"`
		Transfer struct {
			Identifier string `json:"identifier"`
			Address    string `json:"address"`
		} `json:"transfer"`
		Mock struct {
			Identifier string `json:"identifier"`
			Address    string `json:"address"`
		} `json:"mock"`
	} `json:"modules"`
	Tokens struct {
		Mock string `json:"mock"`
	} `json:"tokens"`
}
