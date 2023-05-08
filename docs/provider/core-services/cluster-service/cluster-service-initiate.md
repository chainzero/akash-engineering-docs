---
sidebar_position: 2
---

# Cluster Service Initiation

### Provider Service Calls/Initiates the Cluster Service

> [Source code reference location](https://github.com/akash-network/provider/blob/e7aa0b5b81957a130f1dc584f335c6f9e41db6b1/service.go#L101)

```
	cluster, err := cluster.NewService(ctx, session, bus, cclient, ipOperatorClient, waiter, clusterConfig)
	if err != nil {
		cancel()
		<-bc.lc.Done()
		return nil, err
	}
```

The parameters for `cluster.NewService` include the Provider's Kubernetes cluster settings.

```
	clusterConfig := cluster.NewDefaultConfig()
	clusterConfig.InventoryResourcePollPeriod = cfg.InventoryResourcePollPeriod
	clusterConfig.InventoryResourceDebugFrequency = cfg.InventoryResourceDebugFrequency
	clusterConfig.InventoryExternalPortQuantity = cfg.ClusterExternalPortQuantity
	clusterConfig.CPUCommitLevel = cfg.CPUCommitLevel
	clusterConfig.MemoryCommitLevel = cfg.MemoryCommitLevel
	clusterConfig.StorageCommitLevel = cfg.StorageCommitLevel
	clusterConfig.BlockedHostnames = cfg.BlockedHostnames
	clusterConfig.DeploymentIngressStaticHosts = cfg.DeploymentIngressStaticHosts
	clusterConfig.DeploymentIngressDomain = cfg.DeploymentIngressDomain
	clusterConfig.ClusterSettings = cfg.ClusterSettings
```

These settings are defined in the flags used when the `provider-services run` command is issued.

Example flag made available within the `provider/cmd/provider-services/cmd/run.go` file for Ingress Domain declaration.

```
const (
	...
	FlagDeploymentIngressDomain          = "deployment-ingress-domain"
	....
)
```