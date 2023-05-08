---
sidebar_position: 7
---

# Leases API Amino Definitions

> [Source code reference location](https://github.com/akash-network/node/blob/52d5ee5caa2c6e5a5e59893d903d22fe450d6045/x/market/types/v1beta2/codec.go)

Based on the use of the Tendermint RPC implementation and the associated amino client encoding standards the Lease messages are registered with the Amino Codec.

```
func init() {
	RegisterLegacyAminoCodec(amino)
	cryptocodec.RegisterCrypto(amino)
	amino.Seal()
}

// RegisterCodec registers the necessary x/market interfaces and concrete types
// on the provided Amino codec. These types are used for Amino JSON serialization.
func RegisterLegacyAminoCodec(cdc *codec.LegacyAmino) {
	cdc.RegisterConcrete(&MsgCreateBid{}, ModuleName+"/"+MsgTypeCreateBid, nil)
	cdc.RegisterConcrete(&MsgCloseBid{}, ModuleName+"/"+MsgTypeCloseBid, nil)
	cdc.RegisterConcrete(&MsgCreateLease{}, ModuleName+"/"+MsgTypeCreateLease, nil)
	cdc.RegisterConcrete(&MsgWithdrawLease{}, ModuleName+"/"+MsgTypeWithdrawLease, nil)
	cdc.RegisterConcrete(&MsgCloseLease{}, ModuleName+"/"+MsgTypeCloseLease, nil)
}
```

The Messages types are defined in Protobuf file `node/proto/akash/market/v1beta2/lease.proto`.  The `MsgCreateLease` Protobuf file is referenced below as an example.

```
// MsgCreateLease is sent to create a lease
message MsgCreateLease {
  option (gogoproto.equal) = false;

  BidID bid_id = 1 [
    (gogoproto.customname) = "BidID",
    (gogoproto.nullable)   = false,
    (gogoproto.jsontag)    = "id",
    (gogoproto.moretags)   = "yaml:\"id\""
  ];
}

// MsgCreateLeaseResponse is the response from creating a lease
message MsgCreateLeaseResponse {}
```