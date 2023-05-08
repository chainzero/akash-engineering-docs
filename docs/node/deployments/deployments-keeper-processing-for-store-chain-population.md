---
sidebar_position: 6
---

# Deployments Keeper Processing for Store/Chain Population

[Source code reference location](https://github.com/akash-network/node/blob/52d5ee5caa2c6e5a5e59893d903d22fe450d6045/x/deployment/keeper/keeper.go#L123)

The `Create` method takes in Deployment details as an argument and writes the new Deployment to the blockchain.

```
func (k Keeper) Create(ctx sdk.Context, deployment types.Deployment, groups []types.Group) error {
	store := ctx.KVStore(k.skey)

	key := deploymentKey(deployment.ID())

	if store.Has(key) {
		return types.ErrDeploymentExists
	}

	store.Set(key, k.cdc.MustMarshal(&deployment))

	for idx := range groups {
		group := groups[idx]

		if !group.ID().DeploymentID().Equals(deployment.ID()) {
			return types.ErrInvalidGroupID
		}
		gkey := groupKey(group.ID())
		store.Set(gkey, k.cdc.MustMarshal(&group))
	}

	ctx.EventManager().EmitEvent(
		types.NewEventDeploymentCreated(deployment.ID(), deployment.Version).
			ToSDKEvent(),
	)

	telemetry.IncrCounter(1.0, "akash.deployment_created")

	return nil
}
```