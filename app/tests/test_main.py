from fastapi.testclient import TestClient

from ratings_api.main import app


client = TestClient(app)


def test_healthz_returns_ok():
    response = client.get("/healthz")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_rating_requires_database_config():
    response = client.get("/ratings/sku-123")
    assert response.status_code == 503


def test_short_product_id_is_rejected(monkeypatch):
    monkeypatch.setenv("DATABASE_URL", "postgresql://example")
    response = client.get("/ratings/ab")
    assert response.status_code == 400
