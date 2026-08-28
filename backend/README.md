# Backend

FastAPI backend for ScreeningTogether.

## Setup

Requires Python 3.12.

Install into whichever virtual environment / conda environment you prefer.

From the `backend/` folder, in a terminal:

```bash
pip install -r requirements.txt
```

Copy contents of `.env.example` to `.env` and fill in real values (`.env` is gitignored).

### Adding a new API key or secret value

1. In `config.py`, add a typed field to the `Settings` class, using a meaningful name for the key:
   ```python
   api_key_1: SecretStr
   ```
2. Add the key to your local `.env` with a real value.
3. Add the same key to `.env.example` with a blank value, so the key name is documented for everyone's local `.env`.

## Run

From the `backend/` folder:

```bash
uvicorn main:app --reload
```

API available at `http://localhost:8000`, health check at `/health`.

## Structure

- `main.py` - app entrypoint: FastAPI instance, CORS config, router registration
- `config.py` - settings loaded from `.env` via `pydantic-settings`
- `schemas.py` - Pydantic request/response models
- `routers/` - endpoint definitions, one file per resource
- `services/` - clients for external APIs (e.g. healthdirect)
- `db/` - database connection/session setup and ORM models
- `scripts/` - standalone scripts (data ingestion, analysis) run outside the request/response cycle

## Deployment

Deployed on AWS EC2, with Nginx as a reverse proxy in front of Uvicorn.
