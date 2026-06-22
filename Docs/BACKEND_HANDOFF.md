# Backend handoff — deliberately not enabled in the MVP

## Local-first boundary

The iOS client has no backend SDK, service-role key, network request, analytics SDK or external AI call. `DocumentExplaining` is a protocol whose only implementation throws `notConfigured`.

## Supabase later

Use a separate authenticated user id as the owner of every row and storage path. Proposed entities: `care_cases`, `todos`, `document_metadata`, `document_summaries`, and `consent_records`.

- Enable RLS on every exposed table and write owner-scoped `SELECT`, `INSERT`, `UPDATE`, and `DELETE` policies.
- Keep documents in a private bucket at `<auth.uid()>/<case-id>/<document-id>`; never use a public bucket for care documents.
- Store derived metadata separately from raw files; offer deletion of both.
- Use a publishable client key only. A service-role/secret key belongs only in a server environment.

## Future document explanation

An Edge Function (or equivalent server) may call an AI provider only after the product has added: a purpose-bound consent screen, clearly described recipient and retention policy, authentication, rate limits, redacted server logs, deletion handling and a privacy/legal review. The app must send a document or OCR text only after the user actively confirms that specific transfer.
