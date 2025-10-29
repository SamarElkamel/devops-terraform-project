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
