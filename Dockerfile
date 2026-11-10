FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

RUN groupadd --system app && useradd --system --gid app --home-dir /app app

COPY requirements.lock /app/requirements.lock
RUN python -m pip install --no-cache-dir --requirement /app/requirements.lock

COPY --chown=app:app src/ /app/src/
COPY --chown=app:app public/ /app/public/

USER app
EXPOSE 3000

CMD ["sh", "-c", "exec uvicorn src.app:app --host 0.0.0.0 --port ${PORT:-3000} --no-access-log"]
