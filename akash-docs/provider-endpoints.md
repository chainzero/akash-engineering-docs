# Provider Endpoints

The section details the provider REST and gRPC endpoints that may be used following initial build and ongoing health verifications.

### Provider Status gRPC Endpoint

This endpoint provides detailed info on a Proviider's total allocatable and currently allocated host resources including GPU model type/status and CPU/memory/storage levels on a per node basis.

> _**NOTE**_ - to use this endpoint ensure that gRPC Curl is installed on the machine executing the command

#### Template

```
grpcurl -insecure <provider-domain>:8444 akash.provider.v1.ProviderRPC.GetStatus
```

#### Example

```
grpcurl -insecure provider.hurricane.akash.pub:8444 akash.provider.v1.ProviderRPC.GetStatus
```

### Provider Status Endpoint

This endpoint provides high level details on the status of the Provider including the number of active leases and the hardware specs of those leases.

#### Template

```
curl -ks https://<provider-domain>:8443/status
```

#### Example

```
curl -ks https://provider.hurricane.akash.pub:8443/status
```

### Provider Version Endpoint

This endpoint is not necessarily useful for a general health check following Provider install but may become useful if/when detailed package versions need to be reviewed in troubleshooting exercises.  The lengthy output of this endpoint reveals Akash Provider, Go, and many other packages versions involved in the implementation.

Template

```
curl -ks https://<provider-domain>:8443/version
```

#### Example

```
curl -ks https://provider.hurricane.akash.pub:8443/version
```
