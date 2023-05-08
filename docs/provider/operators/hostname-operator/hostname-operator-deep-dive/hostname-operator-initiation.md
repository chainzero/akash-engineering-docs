---
sidebar_position: 2
---

# Hostname Controller Initiation

The Akash Provider Hostname Operator command -  `hostname-operator`  invokes initial controller variable and logging settings.

> [Source code reference location](https://github.com/akash-network/provider/blob/e7aa0b5b81957a130f1dc584f335c6f9e41db6b1/operator/hostnameoperator/hostname\_operator.go)

This logic begins with the call of the `doHostnameOperator` function from Hostname Operator command.  Eventually in this function the `run` method is called with an operator struct passed in.  The `run` function - covered in detail shortly - will begin a listening loop for new ingress controller entries.

```
func doHostnameOperator(cmd *cobra.Command) error {
    ....
    	group.Go(func() error {
		return op.run(ctx)
	})
    ....
}
```

The `operator` struct of which `op` of type `hostnameOperator` is passed into the `run` method as mentioned.

```
type hostnameOperator struct {
	hostnames map[string]managedHostname

	leasesIgnored operatorcommon.IgnoreList

	client cluster.Client

	log log.Logger

	cfg    operatorcommon.OperatorConfig
	server operatorcommon.OperatorHTTP

	flagHostnamesData  operatorcommon.PrepareFlagFn
	flagIgnoreListData operatorcommon.PrepareFlagFn
}
```