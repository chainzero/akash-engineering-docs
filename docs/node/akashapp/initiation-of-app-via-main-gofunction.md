---
sidebar_position: 2
---

# Initiation of App via Main.go Function

> [Source code reference location](https://github.com/akash-network/node/blob/master/cmd/akash/main.go)

The `main.go` file and associated main function fires the method call of `NewRootCmd`.  This method - as detailed in the subsequent section is located in `node/cmd/akash/cmd/root.go`

```
func main() {
	rootCmd, _ := cmd.NewRootCmd()

	if err := cmd.Execute(rootCmd, "AKASH"); err != nil {
		switch e := err.(type) {
		case server.ErrorCode:
			os.Exit(e.Code)
		default:
			os.Exit(1)
		}
	}
}
```




