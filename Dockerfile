FROM python:3.12-slim AS builder

WORKDIR /app

COPY docker/requirements.txt /app/requirements.txt
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r /app/requirements.txt

FROM python:3.12-slim AS runtime

WORKDIR /app

COPY --from=builder /wheels /wheels
COPY --from=builder /app/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir --no-index --find-links=/wheels -r /app/requirements.txt

COPY etl/ ./etl
COPY dataviz/ ./dataviz
COPY tests/ ./tests
COPY scripts/run_etl.sh ./scripts/run_etl.sh
RUN chmod +x ./scripts/run_etl.sh

CMD ["./scripts/run_etl.sh"]
