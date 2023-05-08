---
sidebar_position: 7
---

# Deployments API Amino Definitions

> [Source code reference location](https://github.com/akash-network/node/blob/9c376e978213fba72e1023b829d780f1f4ce64e5/x/deployment/types/v1beta2/codec.go)

Based on the use of the Tendermint RPC implementation and the associated amino client encoding standards the Deployment messages are registered with the Amino Codec.

```
func init() {
	RegisterLegacyAminoCodec(amino)
	cryptocodec.RegisterCrypto(amino)
	amino.Seal()
}

// RegisterLegacyAminoCodec register concrete types on codec
func RegisterLegacyAminoCodec(cdc *codec.LegacyAmino) {
	cdc.RegisterConcrete(&MsgCreateDeployment{}, ModuleName+"/"+MsgTypeCreateDeployment, nil)
	cdc.RegisterConcrete(&MsgUpdateDeployment{}, ModuleName+"/"+MsgTypeUpdateDeployment, nil)
	cdc.RegisterConcrete(&MsgDepositDeployment{}, ModuleName+"/"+MsgTypeDepositDeployment, nil)
	cdc.RegisterConcrete(&MsgCloseDeployment{}, ModuleName+"/"+MsgTypeCloseDeployment, nil)
	cdc.RegisterConcrete(&MsgCloseGroup{}, ModuleName+"/"+MsgTypeCloseGroup, nil)
	cdc.RegisterConcrete(&MsgPauseGroup{}, ModuleName+"/"+MsgTypePauseGroup, nil)
	cdc.RegisterConcrete(&MsgStartGroup{}, ModuleName+"/"+MsgTypeStartGroup, nil)
}
```

The Messages types are defined in Protobuf file `node/proto/akash/deployment/v1beta1/deployment.proto`.  The `MsgCreateDeployment` Protobuf file is referenced below as an example.

```
// MsgCreateDeployment defines an SDK message for creating deployment
message MsgCreateDeployment {
  option (gogoproto.equal) = false;

  DeploymentID id = 1 [
    (gogoproto.nullable)   = false,
    (gogoproto.customname) = "ID",
    (gogoproto.jsontag)    = "id",
    (gogoproto.moretags)   = "yaml:\"id\""
  ];
  repeated GroupSpec groups = 2
      [(gogoproto.nullable) = false, (gogoproto.jsontag) = "groups", (gogoproto.moretags) = "yaml:\"groups\""];
  bytes version = 3 [(gogoproto.jsontag) = "version", (gogoproto.moretags) = "yaml:\"version\""];

  cosmos.base.v1beta1.Coin deposit = 4
      [(gogoproto.nullable) = false, (gogoproto.jsontag) = "deposit", (gogoproto.moretags) = "yaml:\"deposit\""];
}
```
