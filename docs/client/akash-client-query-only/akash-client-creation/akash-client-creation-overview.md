---
sidebar_position: 1
---

# Akash Client Creation

## Overview

The code reviewed in this section primarily lives within the following repository locations:

* The `main.go` file directly accessible [here](https://github.com/chainzero/akash-client/blob/main/akashrpcclient\_queryonly/main.go)
* The `client.go` file directly accessible [here](https://github.com/chainzero/akash-client/blob/main/akashrpcclient\_queryonly/client/client.go)

> The client directory and package holds the primary logic for connecting and interacting with the Akash blockchain.  The files in this directory will be explored greatly within this guide.

## Akash Client Initiation Within main.go

The build of a blockchain query begins via the following declarations and initiations:

* Creation of a new Go context via `context.Background()`
* Call of `New` method in the local `client` package.  Additional details of the `New` function can be found [here](client-new-function.md).
* instantiate a new query client which is defined in a Protobuf file in Akash source code and within the Deployment module.  Additional details on the `NewQueryClient` function can be found [here](newqueryclient-method.md).

```

func main() {
	ctx := context.Background()
	addressPrefix := "akash"

	// Create a Cosmos client instance
	client, err := client.New(ctx, client.WithAddressPrefix(addressPrefix))
	if err != nil {
		log.Fatal(err)
	}

	// Instantiate a query client
	queryClient := types.NewQueryClient(client.Context())
...<TRUNCATED>....
```
