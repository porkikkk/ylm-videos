#!/usr/bin/env bash
# Adds a SECOND GitHub Actions runner to the existing Oracle VM (telly-server) for porkikkk/ylm-kit.
# Telly's runner (~/actions-runner) is not touched. Playwright/Chromium/xvfb are already installed by Telly's setup.
# From Oracle Cloud Shell:
#   ssh -t telly 'bash <(curl -sL https://raw.githubusercontent.com/porkikkk/ylm-videos/main/tools/oracle/add_ylm_runner.sh) TOKEN'
# TOKEN = ylm-kit → Settings → Actions → Runners → New self-hosted runner → the long code after --token (valid 1 hour).
set -euo pipefail
TOKEN="${1:-}"
if [ -z "$TOKEN" ]; then echo "Paste the runner token and press Enter:"; read -r TOKEN; fi
R=~/actions-runner-ylm
if [ -f "$R/.runner" ]; then echo "ylm runner already registered"; sudo "$R/svc.sh" status | head -3; exit 0; fi
mkdir -p "$R" && cd "$R"
V=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r .tag_name | sed 's/^v//')
curl -sL -o r.tgz "https://github.com/actions/runner/releases/download/v$V/actions-runner-linux-arm64-$V.tar.gz"
tar xzf r.tgz && rm r.tgz
./config.sh --url https://github.com/porkikkk/ylm-kit --token "$TOKEN" \
    --name ylm-server --labels oracle,uk,ylm --work _work --unattended --replace
sudo ./svc.sh install "$USER"
sudo ./svc.sh start
sudo ./svc.sh status | grep -E "active|Active" | head -2
echo "YLM_RUNNER_DONE"
