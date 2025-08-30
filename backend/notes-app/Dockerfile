FROM python:3.9-slim

# Set working directory
WORKDIR /usr/src/app

# Install dependencies first (better layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app source
COPY . .

# Expose app port
EXPOSE 5002

# Use ENTRYPOINT only
ENTRYPOINT ["python", "app.py"]

