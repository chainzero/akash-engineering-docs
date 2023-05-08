---
sidebar_position: 4
---

# NewService Function Calls Several Foundational Provider Services

The `NewService` function initiates various services required by a running Akash Provider.

> [Source code reference location](https://github.com/akash-network/provider/blob/e7aa0b5b81957a130f1dc584f335c6f9e41db6b1/service.go#L57)

```
func NewService(ctx context.Context,
	cctx client.Context,
	accAddr sdk.AccAddress,
	session session.Session,
	bus pubsub.Bus,
	cclient cluster.Client,
	ipOperatorClient operatorclients.IPOperatorClient,
	waiter waiter.OperatorWaiter,
	cfg Config) (Service, error)
```

The `NewService` function calls several subordinate `NewService` functions to initiate several sub-services. &#x20;

Sub-services are expanded upon in their own, individual sections.  Access these per sub-service sections via available hyperlinks.

#### **Cluster Service**

* The code snippet below reveals the call of the `.cluster.NewService` method.  A through review of this Cluster NewService method and associated logic is found in this [section](../cluster-service/cluster-service-overview.md).

```
	cluster, err := cluster.NewService(ctx, session, bus, cclient, ipOperatorClient, waiter, clusterConfig)
	if err != nil {
		cancel()
		<-bc.lc.Done()
		return nil, err
	}
```

#### **BidEngine Service**

The code snippet below reveals the call of the .bidEngine.NewService method. A through review of the Bidengine NewService method and associated logic is found in this [section](../bid-engine-service/bid-engine-overview.md).

```
	bidengine, err := bidengine.NewService(ctx, session, cluster, bus, waiter, bidengine.Config{
		PricingStrategy: cfg.BidPricingStrategy,
		Deposit:         cfg.BidDeposit,
		BidTimeout:      cfg.BidTimeout,
		Attributes:      cfg.Attributes,
		MaxGroupVolumes: cfg.MaxGroupVolumes,
	})
```

#### **Manifest Service**

The code snippet below reveals the call of the .manifest.NewService method. A through review of the Manifest NewService method and associated logic is found in this [section](../manifest-service/manifest-service-overview.md).

```
	manifest, err := manifest.NewService(ctx, session, bus, cluster.HostnameService(), manifestConfig)
	if err != nil {
		session.Log().Error("creating manifest handler", "err", err)
		cancel()
		<-cluster.Done()
		<-bidengine.Done()
		<-bc.lc.Done()
		return nil, err
	}
```