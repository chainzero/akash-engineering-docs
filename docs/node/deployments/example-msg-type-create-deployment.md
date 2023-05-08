---
sidebar_position: 4
---

# Example Msg Type - Create Deployment

> [Source code reference location](https://github.com/akash-network/node/blob/52d5ee5caa2c6e5a5e59893d903d22fe450d6045/x/deployment/types/v1beta2/deploymentmsg.pb.go#L28)

```
type MsgCreateDeployment struct {
	ID      DeploymentID `protobuf:"bytes,1,opt,name=id,proto3" json:"id" yaml:"id"`
	Groups  []GroupSpec  `protobuf:"bytes,2,rep,name=groups,proto3" json:"groups" yaml:"groups"`
	Version []byte       `protobuf:"bytes,3,opt,name=version,proto3" json:"version" yaml:"version"`
	Deposit types.Coin   `protobuf:"bytes,4,opt,name=deposit,proto3" json:"deposit" yaml:"deposit"`
	// Depositor pays for the deposit
	Depositor string `protobuf:"bytes,5,opt,name=depositor,proto3" json:"depositor" yaml:"depositor"`
}
```