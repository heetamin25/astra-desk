# Astra Desk

A charcoal-and-mint intelligence and MongoDB research workspace adapted from [Signal Desk](https://github.com/SOLANKYYY/signal-desk). See [source attribution](UPSTREAM.md).

## Included

- Gemini chatbot with real embeddings, source citations, and MongoDB conversation memory.
- Public threat feeds, shared indicators, file/message checks, investigation notes, exports.
- Database comparisons, experiment evidence workflows, chapter 8/9 lab kits.
- Authentication, rate limits, metrics, health checks, and authenticated MongoDB Docker service.

## Start with Docker

Install/start Docker Desktop with Linux containers. Extract this entire project and run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\START.ps1
```

The first run creates private `.env` credentials. Add your Google AI Studio key to `GEMINI_API_KEY` there and run `docker compose up -d` to apply it. Open http://localhost:8019. Username: `admin`. Password: the generated `APP_PASSWORD` value in `.env`.

Open **Ask Astra Desk**, import a public report or paste an advisory excerpt with its original HTTPS URL, then ask a question. Generation needs a valid Gemini key, model access and quota. The app shows configuration/provider failures explicitly.

MongoDB data persists in the `astra-data` volume. `docker compose down` preserves it; `down -v` deletes it. MongoDB is only reachable inside the Compose network, with no host port published.

## Publish to Docker Hub

Docker Hub stores **built images**, not a source ZIP uploaded through its website. The source ZIP is your build input.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\PUBLISH-DOCKER.ps1 -Version 1.0.0
```

Enter your Docker Hub access token only into Docker's login prompt. The script builds and pushes `heetamin25/astra-desk:1.0.0` and `latest`. Create that Docker Hub repository with your chosen visibility if needed. The app image contains the frontend, backend, labs and bundled public data. MongoDB runs from official `mongo:8.0` with its own volume. Never include private database exports, keys or `.env` in an image.

After publishing, another computer with the Compose files and its own `.env` runs:

```powershell
docker compose -f docker-compose.yml -f docker-compose.pull.yml up -d --no-build --pull always
```

## Vercel and MongoDB Atlas

Import your GitHub repo in Vercel with the Flask framework and root directory. Set these private Vercel environment variables before deployment:

| Variable | Value |
| --- | --- |
| APP_USERNAME | Your chosen username |
| APP_PASSWORD | Unique password with 16+ characters |
| MONGODB_URI | Your Atlas application connection string |
| MONGODB_DB | astra_desk |
| LLM_BACKEND | gemini |
| GEMINI_API_KEY | Your Google AI Studio key |
| GEMINI_MODEL | gemini-3.1-flash-lite, or a model your project supports |
| EMBEDDING_MODEL | gemini-embedding-001 |
| EMBEDDING_DIMENSIONS | 3072 |
| CHAT_RETRIEVAL | exact |
| CRON_SECRET | Random secret with 32+ characters |

Use a dedicated Atlas application user restricted to this project's database and network access appropriate for the deployment. `exact` computes cosine similarity over at most 3,000 matching MongoDB chunks in Python. It works without an Atlas search index and is not indexed Atlas Vector Search. For indexed mode use `CHAT_RETRIEVAL=atlas` and `appendix-a/vector-index.json`. Re-import evidence after changing the embedding model/dimensions.

The retained `appendix-a/START.ps1` runs the optional original Ollama stack. Use **root START.ps1** for this Gemini version.

## Verification

```powershell
python -m pip install -r requirements-dev.txt -r appendix-a/requirements.txt
python -m unittest discover -s tests -v
node tests/test_assistant_ui.cjs
docker compose config --quiet
docker compose logs --tail 100 app mongo
```

Check `/health`, sign in, import evidence, generate a cited answer, restart the app and reopen the conversation. Regression tests use mock databases/providers and do not prove live Gemini quota, Atlas connectivity or Docker deployment.

## Coursework scope

The assignment requires ingestion, embeddings, RAG, MongoDB memory, Docker and operational checks. The screenshot separately requests two reports; those are separate from this application package. See `docs/DELIVERY-STATUS.md` and retained `docs/FINAL_ASSESSMENT.md`. Do not claim labs or measured results you have not run.
