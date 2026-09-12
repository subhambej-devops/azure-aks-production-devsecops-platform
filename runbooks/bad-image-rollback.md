# Bad Image Rollback

## Symptoms

- New pods fail with `ImagePullBackOff` or `CrashLoopBackOff`.
- Argo CD shows degraded application health.
- 5xx alerts fire after a promotion.

## Immediate Actions

1. Freeze further production promotions.
2. Confirm current image tag:

```powershell
kubectl -n ratings get deploy ratings-api -o jsonpath="{.spec.template.spec.containers[0].image}"
```

3. Revert `gitops/overlays/production/values.yaml` to the last known good tag.
4. Commit and push the revert.
5. Confirm Argo CD sync and rollout:

```powershell
kubectl -n ratings rollout status deploy/ratings-api
```

## Recovery Evidence

- Failed image tag.
- Reverted commit SHA.
- Argo CD sync status.
- Post-rollback smoke test result.

