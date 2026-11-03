# ScreeningTogether AU

Cervical cancer is preventable, but screening participation is lower among women
from culturally and linguistically diverse (CALD) backgrounds in Australia.
ScreeningTogether AU aims to close that gap by making screening information
clear, approachable and easier to act on.

🌐 Live site: https://screeningtogetherau.app

## Features

- **Data stories**: interactive charts and a choropleth map showing screening
  participation rates and age-group statistics by statistical area, built from
  cleaned open data.
- **Three games**: one to move past stigma, one that shows what it is like
  inside a General Practice, and a Q&A game to build understanding.
- **AI practice call**: a simulated call with an AI to rehearse phoning a GP to
  get a test kit, a required step in the process.
- **GP finder**: find a GP by postcode.
- **Accessibility**: language options, theme changes and adjustable font size.

## Tech stack

| Layer | Technology |
|---|---|
| Frontend | Vue.js, React, Node.js |
| Backend | FastAPI (Python) |
| Database | Neon, hosting cleaned open data |
| Testing | Starlette test client (unit tests for the backend) |
| CI/CD | GitHub Actions, with automatic deployment to Azure |

## Team

A team of five from Monash University: one Master of Data Science student,
three Master of AI students and one Master of IT student. Developed for FIT5120.

## Development workflow

Each feature is built on its own branch and merged by pull request into the
development branch. Code-quality reviewers approve each pull request before it
goes to the live `main` branch. Credentials are kept out of the repository.
