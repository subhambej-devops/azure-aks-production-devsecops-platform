import http from "k6/http";
import { check } from "k6";

export const options = {
  vus: 2,
  iterations: 10,
  thresholds: {
    http_req_failed: ["rate<0.01"],
    http_req_duration: ["p(95)<500"],
  },
};

const baseUrl = __ENV.BASE_URL || "http://localhost:8080";

export default function () {
  const health = http.get(`${baseUrl}/healthz`);
  const ready = http.get(`${baseUrl}/readyz`);

  check(health, {
    "health status is 200": (r) => r.status === 200,
  });
  check(ready, {
    "ready status is 200": (r) => r.status === 200,
  });
}

