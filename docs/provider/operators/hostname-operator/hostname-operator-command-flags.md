---
sidebar_position: 5
---

# Operator Command Flag Registration

Note the Cobra command flag registration in the Cmd function:

```
	operatorcommon.AddOperatorFlags(cmd, "0.0.0.0:8085")
	operatorcommon.AddIgnoreListFlags(cmd)
	err := providerflags.AddKubeConfigPathFlag(cmd)
```

The referenced `operatorcommon` path pulls in command flags from `provider/oerator/operatorcommon/operator_flags.go`.  Amongst the flags enabled on the `provider-services hostname-operator` command is the --listen which allows the specification of a HTTP endpoint address/port of the operator.

By default and without explicitly calling the `--listen` flag, the hostname-operator will listen on all  local interfaces (0.0.0.0) and port 8085 based on the default established on the Cobra command flag registration arguments.

Within `operatorcommon` this specific flag - along with other command operator flags - are registered via these functions (Listen Address flag example):

```
	cmd.Flags().String(providerflags.FlagListenAddress, defaultListenAddress, "listen address for web server")
	if err := viper.BindPFlag(providerflags.FlagListenAddress, cmd.Flags().Lookup(providerflags.FlagListenAddress)); err != nil {
		panic(err)
	}
```