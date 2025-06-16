package cmd_test

import (
	"log"
	"testing"

	"github.com/cardano/relayer/v1/relayer/chains/cardano"
	"github.com/cardano/relayer/v1/relayer/chains/cosmos"

	"github.com/cardano/relayer/v1/cmd"
	"github.com/cardano/relayer/v1/internal/relayertest"
)

func TestCreateClient(t *testing.T) {
	t.Parallel()

	sys := relayertest.NewSystem(t)

	_ = sys.MustRun(t, "config", "init")

	sys.MustAddChain(t, "cardano", cmd.ProviderConfigWrapper{
		Type: "cardano",
		Value: cardano.CardanoProviderConfig{
			ChainID:        "cardano",
			RPCAddr:        "http://192.168.10.32:5001",
			Key:            "cardano-key-test-2",
			KeyringBackend: "test",
			Timeout:        "10s",
			GasAdjustment:  1.2,
		},
	})

	sys.MustAddChain(t, "sidechain", cmd.ProviderConfigWrapper{
		Type: "cosmos",
		Value: cosmos.CosmosProviderConfig{
			ChainID:        "sidechain",
			RPCAddr:        "http://192.168.10.136:26657",
			Key:            "key",
			KeyringBackend: "test",
			AccountPrefix:  "cosmos",
			Timeout:        "10s",
			MinGasAmount:   1,
			GasAdjustment:  1.2,
		},
	})

	sys.MustRun(t, "keys", "restore", "sidechain", "key-cosmos-test", "engage vote never tired enter brain chat loan coil venture soldier shine awkward keen delay link mass print venue federal ankle valid upgrade balance")

	sys.MustRun(t, "keys", "use", "sidechain", "key-cosmos-test")
	sys.MustRun(t, "keys", "use", "cardano", "cardano-key-test-1")
	res := sys.MustRun(t, "paths", "add", "cardano", "sidechain", "demo-path", "--file", "/home/it/Documents/IBC/relayer/examples/demo/configs/paths/demo.json")

	res = sys.MustRun(t, "transact", "link", "demo-path")
	log.Println(res.Stdout)
}
