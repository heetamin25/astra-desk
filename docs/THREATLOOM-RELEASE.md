# Threatloom 2.0

Threatloom replaces the earlier Astra Desk interface with a horizontal workspace, an editorial report ledger, a research companion, and a casebook. The plum, lavender and copper identity, serif headings, login page and task ribbon were designed for this version. Advanced database tools use the same horizontal workbench layout. Original source attribution remains in UPSTREAM.md.

Website: https://threatloom.vercel.app

The existing astra-desk-three.vercel.app alias remains connected to the same production deployment. The GitHub repository and MongoDB database identifiers remain stable so existing records and deployment credentials continue to work.

## Gemini diagnosis

Production logs showed Gemini HTTP 503 errors during text generation, while embedding retrieval succeeded. The REST client now retries transient Gemini HTTP 500, 502, 503 and 504 failures at most twice, with one- and two-second delays. Credentials, unavailable models and exhausted quota are not automatically retried. Provider errors remain visible; no substitute answer is fabricated.

A real production answer was generated and saved to MongoDB in 3.9 seconds after deployment, then restored after reloading the conversation. This verifies one successful live request, not a guarantee of future provider availability.

## Validation

- 138 Python tests passed, including transient Gemini recovery, retry limits and credential/quota handling.
- Chat UI and delayed-history regression checks passed.
- Desktop preview inspected; the responsive layout was checked at the mobile breakpoint for horizontal page overflow.
- Existing Atlas data is retained. Feed records describe published claims, not confirmed attacks.

The public application image remains at heetamin25/mongodb-lab18. Version 2.0.0 is the Threatloom redesign; version 1.0.0 is the earlier interface. MongoDB runs separately through the supplied Compose stack. Credentials and private Atlas data are not included in the image.
