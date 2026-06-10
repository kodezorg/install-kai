# install-kai

One-liner to set up GitHub CLI + kai + Azure CLI + AWS CLI on macOS.

## Install

**Recommended (process substitution, no temp file):**

```bash
bash <(curl -fsSL "https://raw.githubusercontent.com/kodezorg/install-kai/main/install-kai.sh")
```

**Alternative (download then run):**

```bash
curl -fsSL -o /tmp/kai-setup.sh "https://raw.githubusercontent.com/kodezorg/install-kai/main/install-kai.sh" \
  && bash /tmp/kai-setup.sh
```

> **Do not use the GitHub "blob" URL** (`/blob/main/...`). It returns an HTML page, not the script.
> Always use the `raw.githubusercontent.com` URL shown above.

## What it does

- Ensures Homebrew is present
- Installs GitHub CLI (`gh`) if missing, then runs `gh auth login`
- Taps `kodezorg/homebrew-kai` and installs `kai`
- Installs Azure CLI (`az`) + guides through `az login`
- Installs AWS CLI + optionally runs `aws configure`