# 1️⃣ Base image (Linux + Python)
FROM python:3.10-slim

# 2️⃣ Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# 3️⃣ Install system dependencies (needed for some Python packages)
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 4️⃣ Working directory inside container
WORKDIR /app

# 5️⃣ Copy requirements
COPY requirements.txt .

# 6️⃣ Install dependencies
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# 7️⃣ Copy entire project
COPY . .

# 8️⃣ Expose port
EXPOSE ${PORT:-8000}

# 9️⃣ Start the app
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:${PORT:-8000}"]