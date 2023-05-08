---
sidebar_position: 6
---

# Create Lease Keeper Processing for Store/Chain Population

[Source code reference location](https://github.com/akash-network/node/blob/52d5ee5caa2c6e5a5e59893d903d22fe450d6045/x/market/keeper/keeper.go#L144)

The `CreateLease` method within `node/x/market/keeper/keeper.go` takes in Bid details as an argument and writes the new Lease to the blockchain.

```
func (k Keeper) CreateLease(ctx sdk.Context, bid types.Bid) {
	store := ctx.KVStore(k.skey)

	lease := types.Lease{
		LeaseID:   types.LeaseID(bid.ID()),
		State:     types.LeaseActive,
		Price:     bid.Price,
		CreatedAt: ctx.BlockHeight(),
	}

	// create (active) lease in store
	key := keys.LeaseKey(lease.ID())
	store.Set(key, k.cdc.MustMarshal(&lease))

	ctx.Logger().Info("created lease", "lease", lease.ID())
	ctx.EventManager().EmitEvent(
		types.NewEventLeaseCreated(lease.ID(), lease.Price).
			ToSDKEvent(),
	)

	secondaryKeys := keys.SecondaryKeysForLease(lease.ID())
	for _, secondaryKey := range secondaryKeys {
		store.Set(secondaryKey, key)
	}
}
```