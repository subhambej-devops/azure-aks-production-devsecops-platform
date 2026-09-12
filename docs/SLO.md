# Service Level Objectives

## Ratings API

| Indicator | Target | Measurement |
|---|---:|---|
| Availability | 99.9% monthly | Successful `/healthz` checks |
| Latency | p95 < 500 ms | Application Insights and Prometheus histogram |
| Error rate | 5xx < 2% | Ingress and application metrics |
| Recovery time | < 30 minutes | Incident timeline |
| Recovery point | < 24 hours | PostgreSQL backup policy |

## Error Budget

Monthly 99.9% availability allows about 43 minutes of downtime.

If the burn rate exceeds 50% before mid-month:

- Freeze non-critical production releases.
- Review recent deployments and infrastructure changes.
- Prioritize remediation work over feature work.

