# syntax=docker/dockerfile:1
FROM python:3.11-slim
ENV PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1
RUN pip install --no-cache-dir pytest httpx
WORKDIR /tests
COPY tests/test_showcase.py ./
CMD ["pytest", "-v", "-ra", "--no-header", "--tb=short"]
