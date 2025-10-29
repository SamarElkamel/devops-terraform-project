# Tourism Accessibility – Paris Open Data (End-to-End ETL + Dataviz)

Projet DevOps / Data : ingestion d’open-data de la Ville de Paris, stockage MySQL, traitement ETL et visualisation web statique.

- Source open-data : https://opendata.paris.fr/pages/home/
- Dataset utilisé : Accessibilité des hébergements en Île-de-France
- SGBD : MySQL 8.0
- Front-end : page statique avec Chart.js (servie via un serveur HTTP Python)
- Orchestration : Docker + Docker Compose
- Tests : smoke test minimal (pytest)

---

## Objectif

Analyser l’accessibilité des hébergements touristiques en Île-de-France en répondant aux questions suivantes :

1. Proportion globale d’hébergements accessibles.
2. Répartition par code postal et par commune.
3. Top 5 communes les plus accessibles et communes à faible accessibilité (<50%).

Le projet inclut extraction, transformation, chargement (ETL) et visualisation sous forme de graphiques.

---

## Architecture du projet

```
.
├─ docker/
│  ├─ docker-compose.yml      # db (MySQL), etl (job), app (static server)
│  ├─ init.sql                # création DB, table, utilisateur applicatif
│  └─ requirements.txt        # dépendances Python (pinnées)
├─ etl/
│  ├─ load_data_mysql.py      # Extraction + Chargement (E+L)
│  └─ prepare_for_viz.py      # Transformation + Export JSON
├─ dataviz/
│  ├─ index.html              # page Chart.js
│  └─ data_for_viz.json       # généré par l’ETL
├─ scripts/
│  └─ run_etl.sh              # lance les deux étapes ETL
├─ tests/
│  └─ test_smoke.py           # test minimal
├─ Dockerfile                 # image unique pour ETL + serveur statique
└─ README.md
```

---

## Fonctionnalités (réalisées)

- Ingestion des données via l’API Paris Open Data.
- Stockage en MySQL 8.0 (table `hebergements`).
- Transformations/Agrégations pour la dataviz :
  - Proportion globale d’accessibilité.
  - Répartition par code postal (totaux + % accessibles).
  - Agrégations par commune et Top 5 communes.
  - Communes < 50% d’accessibilité.
- Export JSON : `dataviz/data_for_viz.json`.
- Dataviz : 3 graphiques (doughnut global, barres par code postal, barres Top 5 communes).

---

## Prérequis

- Docker & Docker Compose
- Python 3.x (pour servir `dataviz/` en local si nécessaire)

---

## Démarrage rapide

1) Construire et lancer les services :

```bash
docker compose -f docker/docker-compose.yml up --build
```

- `db` : démarre MySQL et initialise la base/table.
- `etl` : attend la santé de la DB puis exécute `scripts/run_etl.sh` (insère les données et génère `dataviz/data_for_viz.json`).
- `app` : sert la dataviz (si votre navigateur bloque pour CORS, voir ci-dessous).

2) Ouvrir la dataviz (contournement CORS recommandé) :

- Windows :
```bash
python -m http.server 8000 --directory dataviz
```
- Linux / macOS :
```bash
python3 -m http.server 8000 --directory dataviz
```
- Ensuite, ouvrez : http://127.0.0.1:8000

3) Arrêt :
```bash
docker compose -f docker/docker-compose.yml down
```

Le volume `db_data` persiste entre les runs.

---

## Intégration Continue (CI)

Une pipeline GitHub Actions (`.github/workflows/ci.yml`) exécute à chaque push/PR :

- Lint Python avec `ruff`
- Vérification de formatage `black --check`
- Tests `pytest`
- Build Docker (Dockerfile racine) et `docker compose build`

Exécution locale équivalente :

```bash
pip install ruff black pytest
ruff check .
black --check .
pytest -q
docker build -t tourism-accessibility:local .
docker compose -f docker/docker-compose.yml build
```

---

## Variables d’environnement (utilisées)

- `MYSQL_HOST` (défaut `db`)
- `MYSQL_DATABASE` (défaut `tourismdb`)
- `MYSQL_USER` (défaut `root`)
- `MYSQL_PASSWORD` (défaut vide pour ce test local)
- `PORT` (serveur statique, défaut `8000`)

Les scripts ETL lisent ces variables via `os.getenv(...)`.

---

## Tests (réalisé)

- Smoke test minimal : `tests/test_smoke.py`.
- Exécution :
```bash
docker compose -f docker/docker-compose.yml run --rm etl pytest -q
```

---

## Détails techniques (réalisés)

- Extraction & Chargement : `etl/load_data_mysql.py`
  - Appel API sur le dataset (limit=100).
  - Mapping des champs (ex: `etablissement` → `nom`, `ville` → `commune`).
  - Dérivation de `accessibilite` (Oui/Non) selon les données source.
  - Insertions dans `hebergements`.

- Transformation & Export : `etl/prepare_for_viz.py`
  - Calculs globaux, par code postal, par commune, Top 5 et <50%.
  - Écriture JSON dans `dataviz/data_for_viz.json`.

- Dataviz : `dataviz/index.html`
  - Chart.js (CDN), `fetch("data_for_viz.json")`, rendu de 3 graphiques.

- Orchestration : `docker/docker-compose.yml`
  - Services `db`, `etl`, `app`, réseau `app-network`, volume `db_data`.
  - `depends_on` avec condition de santé pour lancer l’ETL après la DB.
  - Healthcheck HTTP ajouté pour `app`.

- Image : `Dockerfile`
  - Multi-stage build basé sur `python:3.12-slim`.
  - Installation des dépendances via `pip wheel` + runtime minimal.
  - `CMD ./scripts/run_etl.sh`.

- Script ETL : `scripts/run_etl.sh`
  - Séquence : `python3 etl/load_data_mysql.py` puis `python3 etl/prepare_for_viz.py`.

---

## Limites assumées (dans ce projet)

- Mot de passe root MySQL vide (facilite l’exécution locale du test).
- Une image unique pour ETL + serveur statique (simplicité pour ce test).
- Tests minimaux (smoke uniquement).

---

## Monitoring (basique)

- Healthchecks :
  - MySQL via `mysqladmin ping` (déjà en place dans Compose).
  - App via requête HTTP locale (healthcheck Compose).
- Logs :
  - Utiliser `docker logs tourism-app` / `tourism-etl` / `tourism-db`.
  - En CI, consulter les logs d’étapes pour diagnostiquer lint/tests/build.
- Uptime (option simple) :
  - Vérification périodique de `http://127.0.0.1:8000` (outil externe ou cron local).

---

## (Bonus) Terraform – Hébergement statique S3

Un exemple d’IaC Terraform se trouve dans `terraform/` pour créer un bucket S3 configuré en site statique (hébergement de `dataviz/`).

Prérequis : AWS credentials configurés (variables d’env `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`).

Commandes :

```bash
cd terraform
terraform init
terraform plan -var "bucket_name=mon-bucket-unique-mondial"
# terraform apply # (optionnel)
```

## Licence

Usage libre pour évaluation technique.
