# Use Python 3.10 slim image for smaller size
FROM python:3.10-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PORT=5000

# Install system dependencies required for scikit-learn, numpy, scipy
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    gfortran \
    libopenblas-dev \
    liblapack-dev \
    && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Copy requirements first for better layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port (will be overridden by PORT env var in production)
EXPOSE 5000

# Use gunicorn as WSGI server for production
# Bind to all interfaces (0.0.0.0) and use PORT env variable (defaults to 5000)
# Note: Render and other platforms will set PORT environment variable
CMD gunicorn --bind 0.0.0.0:$PORT --workers 2 --threads 2 --timeout 120 app:app
