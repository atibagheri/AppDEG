# ---------- Stage 1: Build React Frontend ----------
FROM node:18 AS react-builder

WORKDIR /app/degviz

# Copy the frontend source and package.json
COPY degviz ./    # this includes src/, public/, etc.
COPY package*.json ../          # move the package.json to parent

WORKDIR /app

RUN mv package*.json degviz/ && \
    cd degviz && \
    npm install && npm run build


# ---------- Stage 2: Python + R Backend ----------
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Step 1: Base packages
RUN apt-get update && apt-get install -y \
    python3 python3-pip \
    r-base \
    git \
    curl

# Step 2: R system libraries
RUN apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfreetype6 \
    libharfbuzz0b \
    libfribidi0 \
    libjpeg-dev

# Step 3: Install Plumber
RUN R -e "install.packages('plumber', repos='https://cloud.r-project.org/')"

# Step 4: Copy backend and install Python deps
WORKDIR /app
COPY . .
RUN pip3 install -r backend/requirements.txt

# Step 5: Copy React build output
COPY --from=react-builder /app/degviz/build /app/degviz/build

# Step 6: Start services
RUN chmod +x start.sh
EXPOSE 5050 8000
CMD ["./start.sh"]
