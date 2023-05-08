---
sidebar_position: 4
---

# Root Command Initiation

> [Source code reference location](https://github.com/akash-network/node/blob/52d5ee5caa2c6e5a5e59893d903d22fe450d6045/cmd/akash/cmd/root.go#L103)

The `initRootCmd` function calls method `AddCommands` within the Cosmos SDK `server` package.  Per Cosmos documentation:

> The server package is responsible for providing the mechanisms necessary to start an ABCI CometBFT application and provides the CLI framework (based on cobra) necessary to fully bootstrap an application. The package exposes two core functions: StartCmd and ExportCmd which creates commands to start the application and export state respectively.

```
func initRootCmd(rootCmd *cobra.Command, encodingConfig params.EncodingConfig) {
	....
	server.AddCommands(rootCmd, app.DefaultHome, newApp, createAppAndExport, addModuleInitFlags)
	....
}
```

