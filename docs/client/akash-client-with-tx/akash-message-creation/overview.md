---
sidebar_position: 1
---

# Akash Message Creation Overview

> [Source code reference location](https://github.com/chainzero/akash-client/tree/main/akashrpcclient\_withtx)

## Overview

When an Akash transaction is created and broadcast to the network it must contain a message that the RPC node which receives the communication recognizes and is capable of routing to the correct module.

In this section we explore an example of message creation for the Create Deployment transaction type. &#x20;

Following the formation of the Create Deployment message, we will then proceed into the mechanics of broadcasting that message - stored within the transaction - to the network.
