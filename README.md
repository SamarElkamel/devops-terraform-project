# DevOps Technical Test – Containerized Data App (ETL + Web Visualization)

This project is a **personal adaptation of a previous data processing project** that I decided to **containerize and automate** as part of a **DevOps technical challenge**.

The goal is to demonstrate:
- The ability to **containerize a complete application** (multi-stage Dockerfile).
- The use of **Docker Compose** for orchestration.
- A **CI pipeline** (GitHub Actions) for build and lint automation.
- **Terraform** for simple cloud resource provisioning and **basic monitoring** setup.

---

## 📘 Project Overview

Originally, this project performed a simple **ETL pipeline** using open data from the City of Paris and generated a small **static visualization** (front-end).  
For this challenge, I **enhanced and containerized** it to fit a modern DevOps workflow.

**Main stack:**
- **Python** – for ETL scripts (data extraction, transformation, load)
- **MySQL 8.0** – database for structured data storage
- **Chart.js (HTML/JS)** – front-end visualization
- **Docker + Docker Compose** – orchestration
- **GitHub Actions** – CI automation (linting, testing, Docker build)
- **Terraform** – deploy a simple S3 bucket for hosting the visualization

---

## 🧱 Architecture

.
├── docker/
│ ├── docker-compose.yml
│ ├── init.sql
│ └── requirements.txt
├── etl/
│ ├── load_data_mysql.py
│ └── prepare_for_viz.py
├── dataviz/
│ ├── index.html
│ └── data_for_viz.json
├── scripts/
│ └── run_etl.sh
├── tests/
│ └── test_smoke.py
├── Dockerfile
├── .github/workflows/ci.yml
├── terraform/
│ └── main.tf
└── README.md


## 🐳 Containerization

### Multi-Stage Dockerfile
- Stage 1: build Python dependencies and wheel packages.
- Stage 2: create a minimal runtime image with only the required tools.
- Entry point: `scripts/run_etl.sh` (runs ETL + prepares data for visualization).

### Docker Compose
Defines 3 services:
- `db` → MySQL database
- `etl` → runs ETL job after database healthcheck
- `app` → serves static visualization via a lightweight Python server

Run everything with:
```bash
docker compose -f docker/docker-compose.yml up --build
```

Then open `http://127.0.0.1:8000` to view the visualization.

Stop the stack:
```bash
docker compose -f docker/docker-compose.yml down
```

Persistent data: the `db_data` volume keeps MySQL data between runs.

---

## 🚀 Quickstart

1) Build and start services:
```bash
docker compose -f docker/docker-compose.yml up --build
```

2) Wait for the `etl` container to finish (it loads data and generates `dataviz/data_for_viz.json`).

3) Open the app: `http://127.0.0.1:8000`.

---

## ⚙️ Configuration

Environment variables (used by ETL and app):
- `MYSQL_HOST` (default `db`)
- `MYSQL_DATABASE` (default `tourismdb`)
- `MYSQL_USER` (default `root`)
- `MYSQL_PASSWORD` (default empty for local dev)
- `PORT` (static server, default `8000`)

You can override these in `docker/docker-compose.yml` or via `--env` flags.

---

## ✅ CI Pipeline (GitHub Actions)

Workflow at `.github/workflows/ci.yml` runs on push/PR:
- Lint with `ruff`
- Format check with `black --check`
- Tests with `pytest`
- Docker build (root Dockerfile) and `docker compose build`

Run the same locally:
```bash
pip install ruff black pytest
ruff check .
black --check .
pytest -q
docker build -t tourism-accessibility:local .
docker compose -f docker/docker-compose.yml build
```

---

## 🧪 Tests

Minimal smoke test is provided:
```bash
docker compose -f docker/docker-compose.yml run --rm etl pytest -q
```

---

## 🔍 Monitoring & Health

- Compose healthchecks:
  - `db`: `mysqladmin ping` ensures MySQL is up before ETL runs
  - `app`: HTTP healthcheck on `http://localhost:8000`
- Logs:
  - `docker logs tourism-app` / `tourism-etl` / `tourism-db`
  - In CI, inspect job logs for lint/test/build results
- Simple uptime idea:
  - Periodically hit `http://127.0.0.1:8000` (external monitor or cron) when deployed

---

## ☁️ (Bonus) Terraform – Static Hosting on S3

An example IaC is provided in `terraform/` to create a public S3 bucket configured for static website hosting (to host `dataviz/`).

Prerequisites: AWS credentials configured (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`).

Commands:
```bash
cd terraform
terraform init
terraform plan -var "bucket_name=<globally-unique-bucket-name>"
# terraform apply # to create resources
```

Upload artifacts (example):
```bash
aws s3 cp ../dataviz/index.html s3://<bucket>/index.html --acl public-read
aws s3 cp ../dataviz/data_for_viz.json s3://<bucket>/data_for_viz.json --acl public-read
```

Outputs:
- `website_endpoint` – the S3 website URL

---

## 🧰 Troubleshooting

- Port 8000 in use: change `ports` mapping in `docker/docker-compose.yml`.
- ETL fails to connect to DB: ensure `db` is healthy; `docker ps` and `docker logs tourism-db`.
- CI fails on lint/format: run `ruff` and `black --check` locally and fix issues.

