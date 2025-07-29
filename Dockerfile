FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Step 1: Base packages
RUN apt-get update && apt-get install -y \
    python3 python3-pip \
    r-base \
    git \
    curl

# Step 2: R and system libraries (in smaller chunk)
RUN apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfreetype6 \
    libharfbuzz0b \
    libfribidi0 \
    libjpeg-dev
    
# Install Node.js and npm from NodeSource (robust)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | tee /tmp/nodesource_setup.sh && \
    bash /tmp/nodesource_setup.sh && \
    apt-get install -y nodejs

# Optional: Verify installation
RUN node -v && npm -v

# Install Plumber
RUN R -e "install.packages('plumber', repos='https://cloud.r-project.org/')"

WORKDIR /app

COPY . .

RUN pip3 install -r backend/requirements.txt

WORKDIR /app/degviz
RUN npm install && npm run build

EXPOSE 5050 8000

WORKDIR /app
RUN chmod +x start.sh
CMD ["./start.sh"]
