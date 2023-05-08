---
sidebar_position: 4
---

# Broadcast Transaction

// TODO - include additional details on the call of the BroadcastTX function from the client package

```
...TRUNCATED...
// Broadcast a transaction from account with the message
// to create a post store response in txResp
txResp, err := client.BroadcastTx(ctx, account, msg)
if err != nil {
	log.Fatal(err)
}

// Print response from broadcasting a transaction
fmt.Print("Transaction broadcast result:\n\n")
fmt.Println(txResp)
...TRUNCATED...
```