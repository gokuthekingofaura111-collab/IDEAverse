# IDEAverse

IDEAverse is an early public-preview website for a learning-and-creation platform. It uses semantic HTML, CSS, browser JavaScript, and a Python 3.12 FastAPI server. The project database remains disabled. The currently published static release remains owner-only until the real OAuth flow is verified and the authorized hybrid build is published.

## Run locally

Install the pinned Python dependencies and start FastAPI:

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.lock
.venv/bin/python -m uvicorn src.app:app --host 127.0.0.1 --port 3000 --no-access-log
```

Open `http://localhost:3000`. For local OAuth testing, set `APP_ALLOWED_ORIGINS=http://localhost:3000`, `APP_COOKIE_SECURE=false`, and `APP_COOKIE_SAMESITE=lax` in the process environment. Plain HTTP is accepted only for a localhost origin. Manus OAuth can complete only where Manus-provided runtime values are available. Never commit `.env` files or copy private runtime values into browser code.

Run the unit tests with:

```sh
.venv/bin/python -m unittest discover -s tests -v
```

The listener uses `PORT` when supplied and defaults to 3000. The route manifest is available at `/manus-routes.json`.

## Sign-in and data boundaries

Browsing the authorized public release requires no account. Manus sign-in is optional and verifies identity only; it does not unlock features, create an IDEAverse profile, or save learning progress. There is no custom password form, password hash, database-backed profile, email waitlist, project upload, or public account-registration form. Sample puzzles and idea prompts run in the browser and retain only transient page state.

The browser starts Manus sign-in with a bounded same-origin JSON request using the custom `X-IDEAverse-Request` header and an allowlisted public origin from `window.location.origin`. Preview forwards the server-side request Origin as the exact internal value `http://127.0.0.1:3000`; the server accepts that precise proxy origin only when the submitted public origin is itself allowlisted. Other forwarded origins must exactly match the submitted allowed origin. The OAuth callback URL is constructed from the validated public origin, never the internal Host. The callback validates a one-time OAuth state bound to a short-lived nonce cookie, exchanges the authorization code server-to-server over TLS, requests only the Manus account identifier, and issues an HS256-signed `webdev_app_session` cookie. Provider access tokens and passwords are never sent to browser code or stored by IDEAverse.

HTTPS Preview and published sessions use `HttpOnly; Secure; SameSite=None`; local plain-HTTP development requires an explicit localhost-only configuration. The session expires after one hour. OAuth authenticates identity only. There is no personal account dashboard or feature-level authorization in this version.

The safety page describes what is live and what remains out of scope. Sign-in does not establish that future community moderation, child-safety operations, legal notices, custom-domain TLS, or pricing are ready. Hosting/CDN infrastructure may process operational requests even though project analytics are disabled.

## Security notes

FastAPI sets restrictive security headers, disables interactive API documentation and access logging, returns non-cacheable auth responses, and does not reflect callback/provider secrets in errors. OAuth callbacks use an exact allowlist of public origins. The session identity is in a signed browser cookie, not in a server-side database. Cookie signing relies on the platform-provided `MANUS_JWT_SECRET` at runtime.

Project visibility is a separate platform setting. The existing publication remains owner-only until a real Preview sign-in, callback, authenticated-session, and sign-out cycle succeeds. The user authorized the updated hybrid version to be published publicly only after that verification. Do not enable the database or add account registration without separate authorization. Before a broader product launch, review privacy/terms notices, age requirements, safety operations, abuse controls, and the intended retention model.

## Interface

The site includes Home, Explore, About, Safety & privacy, FAQ, preview information, and optional sign-in pages. Explore search and filters, the six-item idea-prompt picker, and the three sample number puzzles are browser-only. Page navigation, filter results, puzzle feedback, sign-in status, and sign-out remain accessible to keyboard and screen-reader users. Motion respects `prefers-reduced-motion`.

DM Sans and Space Grotesk are served from licensed local WOFF2 files; no Google Fonts request is made. A locally served original SVG is the fallback for the managed hero illustration. Built-in site analytics are disabled and the Manus badge is hidden; this is not a claim that hosting/CDN operational telemetry is absent.

## Deployment status

The previously published version `2a57f6b170c09ef20df1edf84be7a2192b87279c` is a static release at `https://ideaverse-e7dkd9gp.manus.space` and predates FastAPI OAuth. The current hybrid source is not yet published; the existing release remains owner-only while the real Preview callback is verified. After successful sign-in, callback, session, and sign-out, publish the hybrid version and set it public under the user's explicit approval. The database and auto-publish remain disabled.
