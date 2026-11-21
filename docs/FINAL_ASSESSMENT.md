# Threatloom final assessment

Adapted from SOLANKYYY/signal-desk. See UPSTREAM.md for source attribution.

## Implementation

The integrated UI uses an authenticated Flask API. The Docker entrypoint wraps it with FastAPI. Gemini generates answers and real embeddings. Imported public reports are split into chunks, stored in MongoDB, retrieved by similarity, and included with the last five completed exchanges. Completed answers and citations persist in MongoDB. Partial/failed responses do not become completed conversation history.

## Retrieval

Default `CHAT_RETRIEVAL=exact` computes cosine similarity in Python over at most 3,000 matching chunks. It is not indexed Atlas Vector Search. For Atlas mode, create `chat_vector_index` on the `chat_chunks` collection using `appendix-a/vector-index.json`, wait for it to be queryable, then set `CHAT_RETRIEVAL=atlas`. This index has 3072 dimensions for `gemini-embedding-001`. Re-import documents after changing embedding model or dimensions.

## Deployment

Root `START.ps1` runs Gemini plus authenticated MongoDB with Docker Compose. Root `PUBLISH-DOCKER.ps1` builds and pushes the app image to `heetamin25/astra-desk`. MongoDB uses the separate official image and persistent volume. Vercel uses `app.py` with private environment settings and MongoDB Atlas. Read README.md for both deployment paths.

## Submission scope

The included chapter 8/9 kits and chapter 11-18 evidence catalogue come from the reference. New catalogues start with no measured evidence. Upstream Docker links are explicitly labelled references. Do not submit the upstream author's identity or historical measurements as your own.

The attached assignment additionally requests a report with abstract, introduction, literature review, objectives, methodology, results, conclusion, future work and relevant diagrams. The lab report has a separate page per experiment. These reports require the student's actual identity and measured results and are separate deliverables from this application package.

## Verification

Mocked regression tests verify application logic, not live API quota or cloud connectivity. Demonstrate a successful live Gemini answer with citations, reopen the stored conversation after restart, and retain real Docker/Atlas evidence before claiming end-to-end completion.
