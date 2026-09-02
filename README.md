ScreeningTogether AU

1. Main Branch Overview

The main branch contains the complete ScreeningTogether AU application, consisting of three main parts:



Frontend — Vue 3 + TypeScript + Vite web application.

Backend — FastAPI API providing backend services and data access.

Godot Game — Godot 4.7 educational game prototype focused on cervical cancer screening awareness.

FIT5120_Luna_ScreeningTogether_AU/
├── frontend/
├── backend/
└── godot-game/

2. Folder Structure

frontend/

Contains the web application's user interface, navigation, pages, games interface, GP finder, cervical cancer information, statistics, and FAQs.



Main technologies:



Vue 3

TypeScript

Vite

Vue Router

Tailwind CSS



Main views include:



HomeView.vue — Landing page with cervical cancer information, dynamic statistics, and FAQs.

GameView.vue — Educational games page.

GPFinderView.vue — GP finder for locating a GP for cervical screening.

GpRunnerGameView.vue — Interface for the GP Runner educational game.

Placeholder.vue — Temporary coming-soon page.

backend/

Contains the FastAPI backend and API services used by the frontend.



Key dependencies:



FastAPI

Uvicorn

Pydantic

Pydantic Settings

SQLAlchemy

PostgreSQL (psycopg2-binary)

HTTPX

godot-game/

Contains the Godot 4.7 educational game prototype.



The current prototype is a 720 × 1280 endless-runner-style game focused on cervical cancer screening awareness.



Key scenes include:



main.tscn — Game state, HUD, scoring, start/game-over screens, and level lifecycle.

player.tscn — Player movement, jumping, camera, keyboard, and touch controls.

track_segment.tscn — Reusable path sections.

obstacle.tscn — Stigma and misconception barriers.

npc.tscn — Community voices and misconception messages.

support_pickup.tscn — Trusted-information and support pickups.

support_popup.tscn — Screening facts.

clinic_finish.tscn — Health-service destination and finish trigger.



The game supports keyboard and touch controls and can be exported for Web using the Web export preset.

3. Dependencies

Frontend

The frontend uses:



Vue 3.5.18

Vite 7.0.6

TypeScript 5.8.3

Vue Router 4.6.4

Tailwind CSS 3.4.17

Vue TypeScript Checker 2.2.12

Vitest 3.2.4

ESLint 9.32.0

Prettier 3.5.3

Backend

fastapi
uvicorn[standard]
pydantic
pydantic-settings
sqlalchemy
psycopg2-binary
httpx

Godot

Godot 4.7

Web-compatible GL Compatibility renderer

Web export preset

4. Startup

Frontend

cd frontend
npm install
npm run dev

Vite will provide the local development URL in the terminal.

Backend

Create and activate the Python virtual environment, install the dependencies, then start the FastAPI server:

cd backend
pip install -r requirements.txt
uvicorn main:app --reload

Godot Game

Open the godot-game folder containing project.godot in Godot 4.7, then run the project.



For a web build, use the included Web export preset.

5. Development

The three parts can be developed independently:

Frontend
   │
   ├── Website UI
   ├── Statistics
   ├── Cervical screening information
   ├── GP Finder
   └── Game interface
          │
          ▼
     Godot Game

Frontend
   │
   ▼
Backend (FastAPI)
   │
   └── API services and data

The main branch represents the integrated application containing the frontend, backend, and Godot game.
