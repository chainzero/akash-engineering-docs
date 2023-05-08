---
sidebar_position: 3
---

# Root Command Registration

> [Source code reference location](https://github.com/akash-network/node/blob/52d5ee5caa2c6e5a5e59893d903d22fe450d6045/cmd/akash/cmd/root.go#L46)

When the root command for the Akash CLI - which is the `akash` command prefix registration via Cobra - the `initRootCmd` function is called.

As detailed in the subsequent section, `initRootCmd` is located in `node/md/akash/cmd/root.go`.

```
func NewRootCmd() (*cobra.Command, params.EncodingConfig) {
	encodingConfig := app.MakeEncodingConfig()

	rootCmd := &cobra.Command{
		Use:               "akash",
		Short:             "Akash Blockchain Application",
		Long:              "Akash CLI Utility.\n\nAkash is a peer-to-peer marketplace for computing resources and \na deployment platform for heavily distributed applications. \nFind out more at https://akash.network",
		SilenceUsage:      true,
		PersistentPreRunE: GetPersistentPreRunE(encodingConfig, []string{"AKASH"}),
	}

	initRootCmd(rootCmd, encodingConfig)

	return rootCmd, encodingConfig
}
```