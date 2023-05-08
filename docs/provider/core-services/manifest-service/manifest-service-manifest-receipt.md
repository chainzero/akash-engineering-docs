---
sidebar_position: 5
---

# Receipt of Manifest from Tenant Send to Provider

A method of name `Submit` is included in `provider/manifest/service.go` which accepts incoming manifest sends from the deployer/tenant to the provider.  The function is initiated via an incoming HTTP post detailed subsequently.

```
func (s *service) Submit(ctx context.Context, did dtypes.DeploymentID, mani manifest.Manifest) error {
	....
	select {
	case <-ctx.Done():
		return ctx.Err()
	case s.mreqch <- req:
	case <-s.lc.ShuttingDown():
		return ErrNotRunning
	case <-s.lc.Done():
		return ErrNotRunning
	}

	...
}
```

The `Submit` method is called when a HTTP post - which contains the Akash manifest in the body - is received on an endpoint and handler written/registered in `provider/gateway/rest/router.go`.

_**HTTP Endpoint**_

```
	drouter.HandleFunc("/manifest",
		createManifestHandler(log, pclient.Manifest())).
		Methods(http.MethodPut)

	lrouter := router.PathPrefix(leasePathPrefix).Subrouter()
	lrouter.Use(
		requireOwner(),
		requireLeaseID(),
	)
```

_**Request Handler**_

Note the call of the `Submit` method which is the provider/manifest/service.go function shown prior.  The Deployment ID and manifest are sent to `Submit` as received in the HTTP post from the tenant's send manifest action following lease creation with a provider.

```
func createManifestHandler(log log.Logger, mclient pmanifest.Client) http.HandlerFunc {
	....
		if err := mclient.Submit(subctx, requestDeploymentID(req), mani); err != nil {
			if errors.Is(err, manifestValidation.ErrInvalidManifest) {
				http.Error(w, err.Error(), http.StatusUnprocessableEntity)
				return
	....
	}
}
```