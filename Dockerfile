# Build Python package and dependencies
FROM python:3.11-alpine AS python-build
RUN apk add --no-cache \
        gcc \
        build-essential \
        libssl-dev 

#RUN rm -rf /var/lib/apt/lists/*
RUN mkdir -p /opt/venv
WORKDIR /opt/venv
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN mkdir -p /src
WORKDIR /src

# Install bot package and dependencies
COPY . .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Package everything
FROM python:3.11-alpine AS final
# Update system first
RUN apk update

# Install optional native tools (for full functionality)
RUN apk add --no-cache \
        gcc \
        build-essential \
        libssl-dev 
# Install native dependencies
RUN apk add --no-cache \
        gcc \
        build-essential \
        libssl-dev 

# Setup runtime files
RUN mkdir -p /app
WORKDIR /app
COPY . .

# Copy Python venv
ENV PATH="/opt/venv/bin:$PATH"
COPY --from=python-build /opt/venv /opt/venv

# Set runtime settings
CMD ["python3", "-m", "main.py"]
