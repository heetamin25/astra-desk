FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements.txt requirements.txt
COPY appendix-a/requirements.txt appendix-a/requirements.txt
RUN pip install --no-cache-dir -r appendix-a/requirements.txt
COPY backend backend
COPY frontend frontend
COPY tools tools
COPY data data
COPY labs labs
COPY docs docs
RUN useradd --uid 10001 --create-home appuser
USER appuser
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=5 CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health', timeout=4)"
CMD ["uvicorn", "backend.chat_app:app", "--host", "0.0.0.0", "--port", "8000"]
