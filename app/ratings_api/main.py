import os
import time
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException
from prometheus_client import Counter, Histogram, generate_latest
from starlette.responses import Response

REQUEST_COUNT = Counter(
    "ratings_api_requests_total",
    "Total API requests",
    ["method", "path", "status"],
)
REQUEST_LATENCY = Histogram(
    "ratings_api_request_duration_seconds",
    "API request latency in seconds",
    ["method", "path"],
)

APP_VERSION = os.getenv("APP_VERSION", "local")
ENVIRONMENT = os.getenv("ENVIRONMENT", "local")
app = FastAPI(title="ratings-api", version=APP_VERSION)


def require_database_url() -> str:
    database_url = os.getenv("DATABASE_URL", "")
    if not database_url:
        raise HTTPException(status_code=503, detail="DATABASE_URL is not configured")
    return database_url


@app.middleware("http")
async def metrics_middleware(request, call_next):
    start = time.perf_counter()
    response = await call_next(request)
    path = request.scope.get("route").path if request.scope.get("route") else request.url.path
    REQUEST_COUNT.labels(request.method, path, response.status_code).inc()
    REQUEST_LATENCY.labels(request.method, path).observe(time.perf_counter() - start)
    return response


@app.get("/healthz")
def healthz():
    return {"status": "ok", "version": APP_VERSION, "environment": ENVIRONMENT}


@app.get("/readyz")
def readyz():
    return {"status": "ready", "database_configured": bool(os.getenv("DATABASE_URL", ""))}


@app.get("/ratings/{product_id}")
def get_rating(product_id: str, _: Annotated[str, Depends(require_database_url)]):
    if len(product_id) < 3:
        raise HTTPException(status_code=400, detail="product_id must be at least 3 characters")

    score = (sum(ord(char) for char in product_id) % 50) / 10 + 1
    return {
        "product_id": product_id,
        "rating": round(min(score, 5), 1),
        "source": "demo-service",
    }


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type="text/plain; version=0.0.4")
