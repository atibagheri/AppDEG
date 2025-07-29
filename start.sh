#!/bin/bash

echo "🔁 Starting R Plumber API on port 8000..."
/usr/bin/Rscript -e "pr <- plumber::plumb('backend/degviz_api/plumber.R'); pr$run(host='0.0.0.0', port=8000)" &

echo "🌱 Activating Python virtual environment..."
source backend/venv/bin/activate

echo "🚀 Starting Flask app on port 5050..."
cd backend
python app.py
