---
sidebar_position: 2
---

# Akash Provider Service Initiation

The Akash Provider command is registered via Cobra allowing initiation of the provider service via provider-services run via the Akash CLI.

> [Source code reference location](https://github.com/akash-network/provider/blob/e7aa0b5b81957a130f1dc584f335c6f9e41db6b1/cmd/provider-services/cmd/run.go)

When the Provider service is initiated - via the `run` command - the `doRunCmd` function is called.

```
func RunCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:          "run",
		Short:        "run akash provider",
		SilenceUsage: true,

		RunE: func(cmd *cobra.Command, args []string) error {
			return common.RunForeverWithContext(cmd.Context(), func(ctx context.Context) error {
				return doRunCmd(ctx, cmd, args)
			})
		},
	}
```