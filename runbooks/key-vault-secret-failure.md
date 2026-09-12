# Key Vault Secret Failure

## Symptoms

- Pods start but readiness fails.
- Events mention `secrets-store.csi.k8s.io`.
- Application logs show missing `DATABASE_URL`.

## Checks

```powershell
kubectl -n ratings describe pod -l app.kubernetes.io/name=ratings-api
kubectl -n ratings describe secretproviderclass ratings-api-kv
az keyvault secret show --vault-name "<key-vault-name>" --name ratings-database-url
```

## Fix

1. Verify `workloadIdentityClientId`, `keyVaultName`, and `tenantId` in GitOps values.
2. Confirm federated identity subject is `system:serviceaccount:ratings:ratings-api`.
3. Confirm the managed identity has `Key Vault Secrets User`.
4. Re-sync the Argo CD app.

