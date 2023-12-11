---
sidebar_position: 1
slug: /
---

# Documentation Map

Akash Engineering documentation is broken out into the following primary categories.

# Akash Contributor Guidance and Standards

* [Akash Code Contributors - Policies and Standards](./akashContributors/contributors-overview.md)

# Akash Development Environment Setup

* [Create Local Development Environment](akash-dev-env.md)

# Akash Provider Repo

* [Akash Provider Code Overview](./provider/provider-repo-overview)

# Akash Node Repo

* [Akash Node Code Overview](./node/node-repo-overview)
* [Akash Node Repo - Directory Glossary](./node/akash-node-glossary.md)


### Akash Node Repo Table of Contents

| Directory | Brief Description                                          | Prominent SubDirectories/Files                                                                                                        | Available Docs                                                      |
| --------- | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| app       | Cosmos SDK module registration and store definitions       | app.go                                                                                                                              | [Akash App](./intro.md#akash-app)         |
| cmd       | Cobra registration of `akash` root/sub-commands and flags. |  node/cmd/akash/main.go <br/> node/cmd/akash/cmd/root.go| [Deployments CLI](./intro.md#akash-cli) |                                                                    |
| proto     | Akash API definitions via protobuf                         | node/proto/akash/deployment <br/> node/proto/akash/market <br/> node/proto/akash/provider                                           | [Akash API](./intro.md#akash-api)         |
| types     | Types derived from protobuf's Go client (protoc)           | node/types/v1beta2/                                                                                                                   |                                                                     |
| x         | Cosmos SDK Modules                                         | node/x/<module_name>/client <br/> node/x/<module_name>/handler <br/> node/x/<module_name>/keeper  | |

### Akash Node Repo Available Documentation

#### Akash App

* [Akash App Overview - App.go Initiation and Blockchain Definitions](./node/akashapp/akash-app-overview.md)


#### Akash API

* [Akash API - Deployment Creation](./node/deployments/deployments-tendermint-rpc-endpoint-overview.md)

* [Akash API - Lease Creation](./node/leases/leases-api-overview.md)

#### Akash CLI

* [Akash CLI/CMD - Root CMD (Akash)](./node/akashapp/root-command-registration.md)


* [Akash CLI/CMD - Deployments](./node/deployments/deployments-cli-client.md)

