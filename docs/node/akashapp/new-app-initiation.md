---
sidebar_position: 6
---

# New App Initiation

> [Source code reference location](https://github.com/akash-network/node/blob/52d5ee5caa2c6e5a5e59893d903d22fe450d6045/cmd/akash/cmd/root.go#L103)

When the Cosmos SDK `AddCommands` method was called with the Akash `initRootCmd` function - included anew below for ease of reference - the `newApp` function is passed in as an argument.

```
func initRootCmd(rootCmd *cobra.Command, encodingConfig params.EncodingConfig) {
	....

	server.AddCommands(rootCmd, app.DefaultHome, newApp, createAppAndExport, addModuleInitFlags)

	....
}
```

The `newApp` function calls the `NewApp` method located in `node/app/app.go`.  The `NewApp` method initiates and defines the base parameters of the blockchain.

```
func newApp(logger log.Logger, db dbm.DB, traceStore io.Writer, appOpts servertypes.AppOptions) servertypes.Application {
	...

	return app.NewApp(
		logger, db, traceStore, true, cast.ToUint(appOpts.Get(server.FlagInvCheckPeriod)), skipUpgradeHeights,
		cast.ToString(appOpts.Get(flags.FlagHome)),
		appOpts,
		baseapp.SetPruning(pruningOpts),
		baseapp.SetMinGasPrices(cast.ToString(appOpts.Get(server.FlagMinGasPrices))),
		baseapp.SetHaltHeight(cast.ToUint64(appOpts.Get(server.FlagHaltHeight))),
		baseapp.SetHaltTime(cast.ToUint64(appOpts.Get(server.FlagHaltTime))),
		baseapp.SetMinRetainBlocks(cast.ToUint64(appOpts.Get(server.FlagMinRetainBlocks))),
		baseapp.SetInterBlockCache(cache),
		baseapp.SetTrace(cast.ToBool(appOpts.Get(server.FlagTrace))),
		baseapp.SetIndexEvents(cast.ToStringSlice(appOpts.Get(server.FlagIndexEvents))),
		baseapp.SetSnapshotStore(snapshotStore),
		baseapp.SetSnapshotInterval(cast.ToUint64(appOpts.Get(server.FlagStateSyncSnapshotInterval))),
		baseapp.SetSnapshotKeepRecent(cast.ToUint32(appOpts.Get(server.FlagStateSyncSnapshotKeepRecent))),
	)
}
```