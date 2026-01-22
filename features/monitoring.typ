// features/monitoring.typ
#import "../lib/lib.typ": *

#feature("Monitoring & Observability", id: "F-MONITOR", concrete: true, parent: "ROOT", tags: (
  priority: "P1",
  owner: "DevOps Team"
))[
  Comprehensive system monitoring and observability.
]

#req("REQ-MON-001", 
  belongs_to: "F-MONITOR",
  tags: (
    type: "non-functional",
    category: "observability"
))[
  The system shall expose health check endpoints for liveness and readiness probes.
]

#req("REQ-MON-002", 
  belongs_to: "F-MONITOR",
  tags: (
    type: "non-functional",
    category: "metrics"
))[
  The system shall collect and expose metrics in Prometheus format.
]

#req("REQ-MON-003", 
  belongs_to: "F-MONITOR",
  tags: (
    type: "non-functional",
    category: "availability"
))[
  Monitoring dashboards shall have 99.9% availability.
]

#req("REQ-MON-002", 
  belongs_to: "F-MONITOR",
  tags: (
    type: "non-functional",
    category: "metrics"
))[
  The system shall collect and expose metrics in Prometheus format.
]

#req("REQ-MON-003", 
  belongs_to: "F-MONITOR",
  tags: (
    type: "non-functional",
    category: "availability"
))[
  Monitoring dashboards shall have 99.9% availability.
]


#feature("Application Metrics", id: "F-METRICS", concrete: true, parent: "F-MONITOR", tags: (
  priority: "P1"
))[
  Application performance and business metrics.
]

#req("REQ-METRICS-001", 
  belongs_to: "F-METRICS",
  tags: (type: "functional"))[
  The system shall track request rate, error rate, and duration for all endpoints (RED metrics).
]

#req("REQ-METRICS-002", 
  belongs_to: "F-METRICS",
  tags: (type: "functional"))[
  The system shall track authentication success/failure rates.
]

#req("REQ-METRICS-003", 
  belongs_to: "F-METRICS",
  tags: (type: "functional"))[
  The system shall track active user sessions count.
]

#req("REQ-METRICS-004", 
  belongs_to: "F-METRICS",
  tags: (type: "functional"))[
  Metrics shall be aggregated and exposed every 15 seconds.
]


#feature("Distributed Tracing", id: "F-TRACING", concrete: true, parent: "F-MONITOR", tags: (
  priority: "P2",
  cost-impact: "+25 EUR"
))[
  Request tracing across microservices.
]

#req("REQ-TRACE-001", 
  belongs_to: "F-TRACING",
  tags: (type: "functional"))[
  The system shall implement distributed tracing using OpenTelemetry.
]

#req("REQ-TRACE-002", 
  belongs_to: "F-TRACING",
  tags: (type: "functional"))[
  All requests shall be assigned a unique trace ID propagated across service boundaries.
]

#req("REQ-TRACE-003", 
  belongs_to: "F-TRACING",
  tags: (type: "functional"))[
  Traces shall be sampled at 10% for normal traffic and 100% for errors.
]

#req("REQ-TRACE-004", 
  belongs_to: "F-TRACING",
  tags: (type: "functional"))[
  Trace data shall be retained for 7 days.
]

#feature("Health Checks", id: "F-HEALTH", concrete: true, parent: "F-MONITOR", tags: (
  priority: "P1"
))[
  Service health and dependency monitoring.
]

#req("REQ-HEALTH-001", 
  belongs_to: "F-HEALTH",
  tags: (type: "functional"))[
  The system shall provide /health/live endpoint returning 200 if application is running.
]

#req("REQ-HEALTH-002", 
  belongs_to: "F-HEALTH",
  tags: (type: "functional"))[
  The system shall provide /health/ready endpoint checking database and cache connectivity.
]

#req("REQ-HEALTH-003", 
  belongs_to: "F-HEALTH",
  tags: (type: "functional"))[
  Health checks shall complete within 1 second.
]

#req("REQ-HEALTH-004", 
  belongs_to: "F-HEALTH",
  tags: (type: "functional"))[
  The system shall expose detailed health status including dependency states at /health/detailed.
]

#feature("Alerting", id: "F-ALERT", concrete: true, parent: "F-MONITOR", tags: (
  priority: "P1"
))[
  Proactive incident alerting.
]

#req("REQ-ALERT-MON-001", 
  belongs_to: "F-ALERT",
  tags: (type: "functional"))[
    The system shall alert when error rate exceeds 1% for 5 consecutive minutes.
  ]

#req("REQ-ALERT-MON-002", 
  belongs_to: "F-ALERT",
  tags: (type: "functional"))[
  The system shall alert when response time p95 exceeds 500ms.
]

#req("REQ-ALERT-MON-003", 
  belongs_to: "F-ALERT",
  tags: (type: "functional"))[
  The system shall alert when database connection pool utilization exceeds 80%.
]

#req("REQ-ALERT-MON-004", 
  belongs_to: "F-ALERT",
  tags: (type: "functional"))[
  Critical alerts shall be sent via PagerDuty, Slack, and email.
]

#feature("Dashboard & Visualization", id: "F-DASHBOARD", concrete: true, parent: "F-MONITOR", tags: (
  priority: "P2"
))[
  Real-time monitoring dashboards.
]

#req("REQ-DASH-001", 
  belongs_to: "F-DASHBOARD",
  tags: (type: "functional"))[
  The system shall provide Grafana dashboards for all key metrics.
]

#req("REQ-DASH-002", 
  belongs_to: "F-DASHBOARD",
  tags: (type: "functional"))[
  Dashboards shall update in real-time with 5-second refresh interval.
]

#req("REQ-DASH-003", 
  belongs_to: "F-DASHBOARD",
  tags: (type: "functional"))[
  The system shall provide pre-built dashboards for: overview, authentication, API, database.
]

#feature("Log Aggregation", id: "F-LOG-AGG", concrete: true, parent: "F-MONITOR", tags: (
  priority: "P2"
))[
  Centralized log collection and search.
]

#req("REQ-LOGAGG-001", 
  belongs_to: "F-LOG-AGG",
  tags: (type: "functional"))[
  Application logs shall be structured in JSON format.
]

#req("REQ-LOGAGG-002", 
  belongs_to: "F-LOG-AGG",
  tags: (type: "functional"))[
  Logs shall include trace ID, user ID, timestamp, level, message, and context.
]

#req("REQ-LOGAGG-003", 
  belongs_to: "F-LOG-AGG",
  tags: (type: "functional"))[
  Log search results shall be returned within 3 seconds for time-range queries.
]

#feature("Performance Profiling", id: "F-PROFILING", concrete: true, parent: "F-MONITOR", tags: (
  priority: "P3",
  cost-impact: "+15 EUR"
))[
  Runtime performance analysis and optimization.
]

#req("REQ-PROF-001", 
  belongs_to: "F-PROFILING",
  tags: (type: "functional"))[
  The system shall support CPU and memory profiling via HTTP endpoints.
]

#req("REQ-PROF-002", 
  belongs_to: "F-PROFILING",
  tags: (type: "functional"))[
  Profiling data shall be exportable in pprof format.
]

#req("REQ-PROF-003", 
  belongs_to: "F-PROFILING",
  tags: (type: "functional"))[
  Continuous profiling shall sample application performance with less than 2% overhead.
]
