# JWT Decoder

A lightweight, client-side JWT decoder at [jwt.ropean.org](https://jwt.ropean.org).

Paste any token to instantly inspect its header, payload, and signature. Nothing leaves your browser.

## Features

- Decodes header, payload, and signature
- Interprets registered claims (`sub`, `iss`, `aud`, `exp`, `nbf`, `iat`, `jti`) with human-readable labels and UTC timestamps
- Flags expired tokens
- Auto-decodes on paste
- No dependencies, no build step — single `index.html`

## Deploy

```bash
./deploy.sh
```

Publishes `index.html` to the `gh-pages` branch with a `CNAME` for `jwt.ropean.org`.
