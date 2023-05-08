---
sidebar_position: 4
---

# Cobra Registration of "hostname-operator" Command

Within the `hostname_operator.go` file the definitions of the customer controller are defined. &#x20;

> /provider/operator/hostnameoperator/hostname\_operator.go

The `hostname_operator.go` file registers a Cobra command and when executed - via `provider-services hostname-operator` - the Hostname custom controller is initialized.

```
func Cmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:          "hostname-operator",
		Short:        "kubernetes operator interfacing with k8s nginx ingress",
		SilenceUsage: true,
		RunE: func(cmd *cobra.Command, args []string) error {
			return doHostnameOperator(cmd)
		},
	}
```

Note the `RunE` invoke the `doHostnameOperator` function which will be reviewed as we continue into discussion of custom controller logic.