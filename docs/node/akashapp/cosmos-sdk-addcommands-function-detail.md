---
sidebar_position: 5
---

# Cosmos SDK AddCommands Function Detail

> [Source code reference location](https://github.com/cosmos/cosmos-sdk/blob/main/server/util.go)

Amongst other command registrations via the Cosmos SDK server package, note that the `startCmd` is registered via function `StartCmd`.

```
// add server commands
func AddCommands(rootCmd *cobra.Command, defaultNodeHome string, appCreator types.AppCreator, appExport types.AppExporter, addStartFlags types.ModuleInitFlags) {
	....

	startCmd := StartCmd(appCreator, defaultNodeHome)
	addStartFlags(startCmd)

	rootCmd.AddCommand(
		startCmd,
		cometCmd,
		ExportCmd(appExport, defaultNodeHome),
		version.NewVersionCommand(),
		NewRollbackCmd(appCreator, defaultNodeHome),
	)
}
```

> [Source code reference location](https://github.com/cosmos/cosmos-sdk/blob/main/server/start.go)

The `SmartCmd` function registers and allows Akash CLI use of command `akash start`.  This command provokes the initiation of an Akash RPC Node and Akash Validator instances.

```
func StartCmd(appCreator types.AppCreator, defaultNodeHome string) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "start",
		Short: "Run the full node",
		Long: `Run the full node application with CometBFT in or out of process. By
default, the application will run with CometBFT in process.
```