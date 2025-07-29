# ---------- Stage 1: Build React Frontend ----------
FROM node:18 AS react-builder

WORKDIR /app

# Copy root-level package.json and package-lock.json
COPY package*.json ./

# Copy React source code
COPY degviz ./degviz

# Install and build React
RUN npm install && npm run build


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

# Step 4: Copy backend files and install Python deps
WORKDIR /app
COPY . .
RUN pip3 install -r backend/requirements.txt

# Step 5: Copy built React app into correct location
COPY --from=react-builder /app/build /app/degviz/build

# Step 6: Entrypoint
RUN chmod +x start.sh
EXPOSE 5050 8000
CMD ["./start.sh"]
