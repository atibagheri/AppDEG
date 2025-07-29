# ---------- Stage 1: Build React Frontend ----------
FROM node:18 AS react-builder

# Set working directory
WORKDIR /app

# Copy package.json files from root into container
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the React app source code
COPY degviz/ ./degviz

# Build the React app
WORKDIR /app/degviz
RUN npm run build

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

# Step 4: Copy backend code and everything else
WORKDIR /app
COPY . .

# Step 5: Install Python backend dependencies
RUN pip3 install -r backend/requirements.txt

# Step 6: Copy React build into final container
COPY --from=react-builder /app/degviz/build /app/degviz/build

# Step 7: Start script and ports
RUN chmod +x start.sh
EXPOSE 5050 8000
CMD ["./start.sh"]
