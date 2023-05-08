---
sidebar_position: 4
---

# Example Msg Type - Create Lease

> [Source code reference location](https://github.com/akash-network/node/blob/52d5ee5caa2c6e5a5e59893d903d22fe450d6045/x/market/types/v1beta2/lease.pb.go#L301)

```
type MsgCreateLease struct {
	BidID BidID `protobuf:"bytes,1,opt,name=bid_id,json=bidId,proto3" json:"id" yaml:"id"`
}
```