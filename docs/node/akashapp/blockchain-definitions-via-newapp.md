---
sidebar_position: 7
---

# Blockchain Definitions Via NewApp

> [Source code reference location](https://github.com/akash-network/node/blob/52d5ee5caa2c6e5a5e59893d903d22fe450d6045/app/app.go#L179)

When called the `NewApp` function creates many definitions for the blockchain including:

* Keepers for blockchain store definitions for all modules
* Blockchain store key values

The `NewApp` function returns an instance of the `AkashApp` struct.

```
func NewApp(
	logger log.Logger, db dbm.DB, tio io.Writer, loadLatest bool, invCheckPeriod uint, skipUpgradeHeights map[int64]bool,
	homePath string, appOpts servertypes.AppOptions, options ...func(*bam.BaseApp),
) *AkashApp {
...
}
```

The `AkashApp` struct is defined as:

```
type AkashApp struct {
	*bam.BaseApp
	cdc               *codec.LegacyAmino
	appCodec          codec.Codec
	interfaceRegistry codectypes.InterfaceRegistry

	invCheckPeriod uint

	keys    map[string]*sdk.KVStoreKey
	tkeys   map[string]*sdk.TransientStoreKey
	memkeys map[string]*sdk.MemoryStoreKey

	keeper struct {
		acct     authkeeper.AccountKeeper
		authz    authzkeeper.Keeper
		bank     bankkeeper.Keeper
		cap      *capabilitykeeper.Keeper
		staking  stakingkeeper.Keeper
		slashing slashingkeeper.Keeper
		mint     mintkeeper.Keeper
		distr    distrkeeper.Keeper
		gov      govkeeper.Keeper
		crisis   crisiskeeper.Keeper
		upgrade  upgradekeeper.Keeper
		params   paramskeeper.Keeper
		ibc      *ibckeeper.Keeper
		evidence evidencekeeper.Keeper
		transfer ibctransferkeeper.Keeper

		// make scoped keepers public for test purposes
		scopedIBCKeeper      capabilitykeeper.ScopedKeeper
		scopedTransferKeeper capabilitykeeper.ScopedKeeper

		// akash keepers
		escrow     escrowkeeper.Keeper
		deployment dkeeper.IKeeper
		market     mkeeper.IKeeper
		provider   pkeeper.IKeeper
		audit      audit.Keeper
		cert       cert.Keeper
		inflation  inflation.Keeper
	}

	mm *module.Manager

	// simulation manager
	sm *module.SimulationManager

	// module configurator
	configurator module.Configurator
}
```