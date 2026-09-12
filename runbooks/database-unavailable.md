# Database Unavailable

## Symptoms

- `/readyz` fails.
- API returns 503 for data routes.
- Application Insights shows dependency failures.

## Checks

```powershell
kubectl -n ratings logs deploy/ratings-api --tail=100
az postgres flexible-server show -g "<resource-group>" -n "<server-name>"
az network private-endpoint list -g "<resource-group>" -o table
```

## Fix

1. Confirm PostgreSQL server state is `Ready`.
2. Validate private DNS resolution from a debug pod.
3. Confirm Key Vault database URL points to the current PostgreSQL FQDN.
4. Fail over or restore if the service is unavailable.

