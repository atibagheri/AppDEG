# ---------- Stage 1: Build React App ----------
FROM node:18 AS react-builder

WORKDIR /app
COPY degviz/ ./degviz
WORKDIR /app/degviz
RUN npm install && npm run build


# ---------- Stage 2: Final image with Python + R + Plumber + Flask ----------
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

# Step 4: Set working directory and copy backend
WORKDIR /app
COPY . .

# Step 5: Install Python dependencies
RUN pip3 install -r backend/requirements.txt

# Step 6: Copy built React files from builder
COPY --from=react-builder /app/degviz/build /app/degviz/build

# Step 7: Expose ports and start
RUN chmod +x start.sh
EXPOSE 5050 8000
CMD ["./start.sh"]
