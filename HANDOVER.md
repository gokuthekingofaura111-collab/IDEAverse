# IDEAverse handover

## Product state

IDEAverse is an early public-preview website in source. The currently published static release remains owner-only until the real OAuth cycle is verified and the new hybrid version is published. The site has Home, Explore, About, Safety & privacy, FAQ, preview-information, and optional Sign in routes. There is no fake email waitlist or public account-registration form; the authorized updated release is intended to be browsable without an account.

Home and Explore contain three browser-only sample puzzles, and Home has six hand-written starter prompts. Search and interest filters run in the browser. These interactions do not save activity or scores. Page-reading progress, Back to top, navigation, challenge, and the safety walkthrough support keyboard use and reduced-motion preferences.

## Authentication architecture

FastAPI serves the site during Preview and implements `POST /api/auth/login`, `GET /api/auth/callback`, `GET /api/auth/session`, `POST /api/auth/logout`, and unauthenticated `GET /healthz`. The session endpoint returns only an authenticated boolean and login-availability flag; login start returns the authorization URL needed for the browser redirect. Provider tokens and passwords are never returned to the browser.

Login/logout use a bounded JSON request and non-simple `X-IDEAverse-Request` header. Preview rewrites the server-side request Origin to exactly `http://127.0.0.1:3000`; that precise internal origin is accepted only alongside an allowlisted public origin submitted by browser code. Other forwarded origins must exactly match the submitted allowlisted origin. OAuth callback URLs are constructed from the submitted public origin, never internal `Host`. OAuth state is bound to a short-lived nonce cookie; the callback exchanges the code with Manus over TLS, retrieves only `openId`, and issues a one-hour HS256 application session using the exact `webdev_app_session` cookie. Preview/public HTTPS uses `HttpOnly; Secure; SameSite=None`; local plain HTTP requires explicit localhost-only settings.

Manus OAuth authenticates identity only; it does not gate features or create a profile. There are no persistent profile, email, learning-progress, project-upload, or community records. The database is disabled. There is no custom password flow or password hashing.

## Current implementation and release state

- Managed server capability: enabled by the user's approval.
- Managed database capability: disabled, as approved.
- Hybrid publication declaration: `build.command: "true"`, `build.outputDirectory: "public"`; Dockerfile uses `/healthz`; published `/api/*` and `/healthz` route to the server and static pages/assets use the static fallback.
- Auto-publish: off.
- Existing owner-only release at `https://ideaverse-e7dkd9gp.manus.space`: checkpoint `2a57f6b170c09ef20df1edf84be7a2192b87279c`; it predates the FastAPI OAuth implementation.
- The user has explicitly approved one public publication of the updated release, but only after real Preview sign-in, callback, session, and sign-out verification. Do not publish or change visibility before that condition is met.

## Verification and publication gate

The actual Preview login initiation now returns an HTTPS Manus authorization URL after accepting the exact Preview-internal Origin under the strict public-origin allowlist. A full callback has not yet been verified. The latest browser attempt opened the Manus authorization page but did not produce a completed sign-in/callback result. Do not mark authentication complete or publish until the browser returns to IDEAverse, the server validates the nonce-bound state and code, the session endpoint reports authenticated, and sign-out clears that session.

Before publication, confirm `/healthz`, `/api/auth/session`, all declared page routes, and `/manus-routes.json`; publish the hybrid version and make it public only after the complete OAuth cycle succeeds. Keep the database and auto-publish disabled. Record any provider or Preview limitation rather than simulating a logged-in user.

## Local development

Create a venv, install pinned `requirements.lock`, then run `uvicorn src.app:app` on port 3000. See `README.md` for exact commands and explicit localhost-only cookie/origin settings. Use platform-injected OAuth values where available; never place them in frontend files or commit local environment files.

## Design and accessibility

The cosmic/editorial brand remains, but saturated glow, copy repetition, and promotional placeholders have been toned down in favor of direct preview language. Typography remains locally hosted and licensed. The hero illustration has an original SVG fallback. Animations and transitions respect `prefers-reduced-motion`; focus, labels, feedback, mobile navigation, and empty states remain visible and accessible.

## Remaining launch decisions

Before a broader product launch, decide age requirements and safety operations, provide reviewed privacy and terms pages, establish operational retention/deletion and abuse-response procedures, verify published route/TLS/security configuration, identify exactly which roadmap features are available, and announce pricing/launch details only when decided. Community and moderation are not active. Built-in project analytics are disabled, but hosting/CDN operational telemetry is not ruled out.
