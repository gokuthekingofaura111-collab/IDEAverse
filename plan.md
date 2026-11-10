# IDEAverse — Authentication and hybrid-runtime plan

## Approved scope and constraints

The user approved Manus OAuth, enabling the one-way managed server capability, and leaving the managed database disabled. The latest instruction authorizes publishing the updated hybrid release publicly only after the real Manus OAuth callback succeeds in Preview; until then, keep the current release owner-only and do not publish. The implementation will not collect local passwords, create password hashes, persist profiles/progress, or add a database. The HTML/CSS/JavaScript interface will be served from the existing `public/` output; Python FastAPI will provide OAuth/session and health endpoints.

## Implementation approach

- Preserve the existing static site, its routes, local-only demos, branding, and responsive design. The static output remains `public/`, with no-build declaration `command: "true"`.
- Enable `features.server: true` and explicitly retain `features.database: false`. The server capability is one-way and this project has explicit user approval for it.
- Add a Python FastAPI service with narrowly scoped routes: `POST /api/auth/login`, `GET /api/auth/callback`, `GET /api/auth/session`, `POST /api/auth/logout`, and an unauthenticated `/healthz`. During Preview, FastAPI serves the committed static files and direct page routes; in the published hybrid shape, the platform serves `public/` and routes only `/api/*` plus `/healthz` to the container.
- Use the platform OAuth contract: `MANUS_PROJECT_ID`, `MANUS_OAUTH_PORTAL_URL`, and `MANUS_OAUTH_API_URL`. Exchange authorization codes server-side, retrieve the Manus identity server-side, discard access/refresh tokens after the identity lookup, and expose only a signed-in boolean to browser code. Never simulate an authenticated Preview user.
- Bind OAuth `state` to a single-use random nonce in a short-lived HttpOnly cookie. Validate the callback's code/state/nonce, require an allowlisted exact HTTPS frontend origin, and redirect only to a fixed local route. Start login through a bounded same-origin JSON request with a custom non-simple CSRF header and an exact allowlisted origin supplied from `window.location.origin`; if Preview forwards the exact internal `http://127.0.0.1:3000` Origin, accept it only alongside the exact allowlisted public origin submitted by browser code. Other forwarded origins must exactly match the submitted allowlisted public origin. The callback URL always uses the public origin, never the proxy value. Browser cross-origin form requests lack the custom header/JSON content type and cross-origin script requests have no CORS permission. Never construct callback URLs from the internal request `Host`.
- Sign a short-lived application session with the platform project secret. Use the exact `webdev_app_session` cookie name, verify HS256 signature plus `appId`, `openId`, and expiry on protected requests, and clear the session and state cookies on logout. For public HTTPS Preview, session cookies must be `HttpOnly; SameSite=None; Secure; Path=/`; handle plain-HTTP local development through an explicit local cookie configuration rather than `NODE_ENV` or internal request security flags.
- Keep the currently deployed release owner-private until Preview completes a real sign-in/callback/sign-out cycle. After that evidence, publish the approved hybrid release and request public visibility under the user's explicit authorization. Public availability is not public registration: browsing requires no account, and Manus sign-in authenticates identity only; do not add SQL, custom password login, a third-party email provider, new credentials, analytics, or persistent user storage.
- Preserve port `3000` for the Preview HTTP process. The container listens on `0.0.0.0:$PORT` (default `3000`), has a non-sensitive `/healthz` 2xx response, and installs only pinned Python runtime dependencies from committed declarations. A committed Dockerfile supplies the production entrypoint.
- Configure published hybrid routing with server routes before the static fallback: `/api/*` and `/healthz` to `server`, then `/*` to `static` with SPA fallback. `manus-routes.json` remains a manifest of user-facing HTML routes only.

## Project structure

- `public/index.html`: accessible application shell and OAuth controls; no client secrets.
- `public/app.js`: client-side page routing, truthful public-preview/sign-in status, and same-origin JSON auth requests using relative URLs.
- `public/styles.css`, `public/favicon.svg`, `public/hero-visual.svg`, `public/fonts/`: existing UI, first-party brand assets, typography, and reduced-motion states.
- `src/app.py`: FastAPI endpoints, static Preview serving, health route, and security middleware.
- `src/auth.py`: OAuth state/nonce, server-to-server token exchange, minimal signed session issuance/verification, and cookie clearing.
- `Dockerfile` plus pinned Python requirements/lock data: reproducible non-root published API image.
- `public/manus-routes.json`: existing user-facing page declarations; no API endpoints.
- `README.md`, `HANDOVER.md`, `TODO.md`: local operation, honest security boundaries, and acceptance state.

## Design

**Design movement:** Preserve the IDEAverse cosmic editorial interface: quiet orbital geometry around clear, readable content.

**Core principles:** Security state is explicit; current product scope is stated plainly; optional account verification is separated from public browsing; motion reinforces orientation rather than hiding content.

**Color philosophy:** Keep the deep ink/navy base and restrained violet, electric blue, and cyan accents, but soften gradients and glows so the interface reads as a real early product rather than a concept render; use status color sparingly and never convey authentication state by color alone.

**Layout paradigm:** Keep the existing open editorial rhythm, use concrete examples and clear availability labels, and present optional Manus sign-in as one compact panel rather than a mock waitlist, password form, or dense account dashboard.

**Signature elements:** the IDEAverse orbital mark; status pills that distinguish preview/planned/active; small-progress and route-aware controls.

**Interaction and animation:** Provider login is a real browser redirect initiated only after a bounded same-origin JSON/CSRF request; logout is an explicit JSON POST; loading/error states are text-led and announced accessibly. Honor `prefers-reduced-motion`; no scroll reveal may hide content. Keyboard focus and empty/error states remain visible.

**Typography:** Continue first-party DM Sans for body and Space Grotesk for display, with existing responsive sizing and contrast.

**Brand essence:** A curious, welcoming learning-and-creation destination for students and lifelong learners; personality: bright, grounded, encouraging.

**Brand voice:** Headlines feel optimistic but specific; account/security microcopy is calm and precise. Examples: “Continue with Manus” and “You are signed in. Your learning progress is not stored in this preview.”

**Wordmark and logo:** Preserve the existing IDEAverse starburst/orbit SVG mark and wordmark.

**Signature brand color:** the existing electric violet/blue orbital gradient; reserve saturated green for success state and use text labels for all states.
