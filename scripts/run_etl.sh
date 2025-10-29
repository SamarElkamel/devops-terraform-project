#!/bin/bash
set -e

echo "Running ETL..."
python3 etl/load_data_mysql.py
python3 etl/prepare_for_viz.py
echo "ETL done."
