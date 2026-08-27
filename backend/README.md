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
