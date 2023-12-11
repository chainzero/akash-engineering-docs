# Akash End to End Testing Overview

## Overview

In this section we review the implementation of Akash end to end testing - both for the Node and Provider repositories - allowing insight into the current coverage and to allow community contributions with less friction.

## Source Code Locales of Associated Testing Strategies

#### Akash Provider Framework Source Code

* [Current End to End Testing Implementation](https://github.com/akash-network/provider/tree/main/integration)

* [Current SDLs Used in E2E Test Invokes](https://github.com/akash-network/provider/tree/main/testdata)

## Exploration of Testing Strategies - Akash Provider

### Go Test Suite

The Akash Provider repository defines current end to end testing coverage in the i[ntegration package](https://github.com/akash-network/provider/tree/main/integration).

The E2E testing strategy and execution uses the [Testify package suite](https://github.com/stretchr/testify) with the current suite of tests listed in the `e2e_test.go` file such as:

```
func TestIntegrationTestSuite(t *testing.T) {
	integrationTestOnly(t)

	suite.Run(t, new(E2EContainerToContainer))
	suite.Run(t, new(E2EAppNodePort))
	suite.Run(t, new(E2EDeploymentUpdate))
	suite.Run(t, new(E2EApp))
	suite.Run(t, new(E2EPersistentStorageDefault))
	suite.Run(t, new(E2EPersistentStorageBeta2))
	suite.Run(t, new(E2EPersistentStorageDeploymentUpdate))
	suite.Run(t, new(E2EMigrateHostname))
	suite.Run(t, new(E2EJWTServer))
	suite.Run(t, new(E2ECustomCurrency))
	suite.Run(t, &E2EIPAddress{IntegrationTestSuite{ipMarketplace: true}})
}
```

# Akash End to End Testing (Provider)

## Overview

The Akash Provider repository defines current end to end testing coverage in the i[ntegration package](https://github.com/akash-network/provider/tree/main/integration).

The E2E testing strategy and execution uses the [Testify package suite](https://github.com/stretchr/testify) with the current suite of tests listed in the `e2e_test.go` file such as:

```
func TestIntegrationTestSuite(t *testing.T) {
	integrationTestOnly(t)

	suite.Run(t, new(E2EContainerToContainer))
	suite.Run(t, new(E2EAppNodePort))
	suite.Run(t, new(E2EDeploymentUpdate))
	suite.Run(t, new(E2EApp))
	suite.Run(t, new(E2EPersistentStorageDefault))
	suite.Run(t, new(E2EPersistentStorageBeta2))
	suite.Run(t, new(E2EPersistentStorageDeploymentUpdate))
	suite.Run(t, new(E2EMigrateHostname))
	suite.Run(t, new(E2EJWTServer))
	suite.Run(t, new(E2ECustomCurrency))
	suite.Run(t, &E2EIPAddress{IntegrationTestSuite{ipMarketplace: true}})
}
```

#### Structure of Testing Logic

Using the first listed element in the Testify suite declaration above - which is `E2EContainerToContainer` - we can review the logic of the remainder of the testing logic.

_**Test Method**_

* Using Go convention and Testify expected values a corresponding test method exists with the typical `Test` prefix.  The example method for the  `E2EContainerToContainer` exists in the file `container2container_test.go` within the same `integration` package as `TestIntegrationTestSuite` exist within.&#x20;
* Review of the called `TestE2EContainerToContainer` has a lot of the logic removed for brevity but as we see the package `deploycli` is used to create a deployment and similarly  `mcli` (short for market) is used for lease creation and the `ptestutil` (provider) for manifest send to provider.

```
func (s *E2EContainerToContainer) TestE2EContainerToContainer() {
	...

	// Create Deployments
	res, err := deploycli.TxCreateDeploymentExec(
		s.validator.ClientCtx,
		s.keyTenant.GetAddress(),
		deploymentPath,
		cliGlobalFlags(deploymentUAktDeposit,
			fmt.Sprintf("--dseq=%v", deploymentID.DSeq))...,
	)
	...
	)
	...

	// create lease
	_, err = mcli.TxCreateLeaseExec(
		s.validator.ClientCtx,
		bidID,
		s.keyTenant.GetAddress(),
		cliGlobalFlags()...,
	)
	...

	// Send Manifest to Provider ----------------------------------------------
	_, err = ptestutil.TestSendManifest(
		s.validator.ClientCtx.WithOutputFormat("json"),
		lid.BidID(),
		deploymentPath,
	)
	...
}
```

_**DeployCLI Creation of Test Deployment/Lease/Manifest Send**_

* In the previous section the use of the testing packages used for deployment/lease creation and manifest send operations.
* Those packages are imported in the `container2container_test.go` file with:

```
	deploycli "github.com/akash-network/node/x/deployment/client/cli"
	mcli "github.com/akash-network/node/x/market/client/cli"
	ptestutil "github.com/akash-network/provider/testutil/provider"
```

* Using the deployment creation example the referenced `deploycli` package contains the called function of `TxCreateDeploymentExec` within the `cli` package.
* This logic in the create deployment example exists in the Akash Node repository and within the associated Cosmos SDK module type (I.e. `node/blob/main/x/deployment/`).

```
func TxCreateDeploymentExec(clientCtx client.Context, from fmt.Stringer, filePath string, extraArgs ...string) (sdktest.BufferWriter, error) {
	...

	return testutilcli.ExecTestCLICmd(context.Background(), clientCtx, cmdCreate(key), args...)
}
```

_**SDLs Utilized in Testing Framework**_

* Within the example used above and the `container2container_test.go` file we can find the SDL used for testing currently.
* In this example the SDL is called here from the `testdata` directory within the Provider repository.

```
func (s *E2EContainerToContainer) TestE2EContainerToContainer() {
	// create a deployment
	deploymentPath, err := filepath.Abs("../testdata/deployment/deployment-v2-c2c.yaml")
```

### Coverage

Based on the testing framework review in this documentation section, we can now review test coverage with two focuses:

* Workload types tested via example SDL.  SDL coverage review is covered here.
* End to End Test use of available test SDLs.  Ensures that not only test SDLs exist to cover a particular feature test but also an E2E test is actually using these available SDLs.  E2E logic coverage is covered here.



## SDL Tests - Current Coverage

* [Current SDLs Used in E2E Testing](providerRepoCoverage.md)