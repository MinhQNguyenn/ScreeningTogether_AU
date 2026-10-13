from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# import routers here:
from routers import choropleth, gp, mock_call, rag_admin, stats

app = FastAPI(title="ScreeningTogether API", docs_url=None,  redoc_url=None, openapi_url=None)

origins = [
    "http://localhost:5173",
    "http://localhost:5174",
    "http://127.0.0.1:5173",
    "http://127.0.0.1:5174",
    "https://d3dsx64353i3rp.cloudfront.net",
    "https://screeningtogether.app"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health_check():
    return {"status": "ok"}

# include routers here:
app.include_router(choropleth.router)
app.include_router(gp.router)
app.include_router(stats.router)
app.include_router(mock_call.router)
app.include_router(rag_admin.router)
