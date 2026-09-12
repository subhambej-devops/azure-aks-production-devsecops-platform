import http from "k6/http";
import { check, sleep } from "k6";

export const options = {
  thresholds: {
    http_req_failed: ["rate<0.02"],
    http_req_duration: ["p(95)<500"],
  },
  stages: [
    { duration: "1m", target: 20 },
    { duration: "3m", target: 50 },
    { duration: "1m", target: 0 },
  ],
};

const baseUrl = __ENV.BASE_URL || "http://localhost:8080";

export default function () {
  const response = http.get(`${baseUrl}/healthz`);
  check(response, {
    "status is 200": (r) => r.status === 200,
  });
  sleep(1);
}

