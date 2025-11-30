#!/usr/bin/env bash
set -euo pipefail

VERSION="v9.3.1"
ZIP_NAME="diagnostics-9.3.1-dist.zip"
DIR_NAME="diagnostics-9.3.1"

echo "==========================================="
echo " Elastic Support Diagnostics – Auto Runner "
echo "==========================================="
echo

# ---- Prompt for connection details ----
read -rp "Elasticsearch host [127.0.0.1]: " ES_HOST
ES_HOST=${ES_HOST:-127.0.0.1}

read -rp "Elasticsearch HTTP port [9200]: " ES_PORT
ES_PORT=${ES_PORT:-9200}

read -rp "Use SSL (https)? [y/N]: " USE_SSL
USE_SSL=${USE_SSL:-n}

read -rp "Username: " ES_USER
read -srp "Password: " ES_PASS
echo
echo

echo "[*] Using:"
echo "    Host    : ${ES_HOST}"
echo "    Port    : ${ES_PORT}"
echo "    SSL     : ${USE_SSL}"
echo "    User    : ${ES_USER}"
echo

# ---- Install Java + tools (Debian/Ubuntu) ----
echo "[*] Installing Java, curl, unzip (apt)..."
apt update -y >/dev/null
apt install -y default-jre curl unzip >/dev/null

if ! command -v java >/dev/null 2>&1; then
  echo "[!] Java is still not available after install. Aborting."
  exit 1
fi

echo "[*] Java OK: $(java -version 2>&1 | head -n 1)"

# ---- Download diagnostics ----
if [ -f "${ZIP_NAME}" ]; then
  echo "[*] Found existing ${ZIP_NAME}, reusing it."
else
  echo "[*] Downloading Elastic support-diagnostics ${VERSION}..."
  curl -sSL -o "${ZIP_NAME}" \
    "https://github.com/elastic/support-diagnostics/releases/download/${VERSION}/${ZIP_NAME}"
fi

if [ ! -s "${ZIP_NAME}" ]; then
  echo "[!] Download failed or file is empty: ${ZIP_NAME}"
  exit 1
fi

# ---- Extract ----
echo "[*] Extracting ${ZIP_NAME}..."
unzip -o "${ZIP_NAME}" >/dev/null

if [ ! -d "${DIR_NAME}" ]; then
  echo "[!] Directory ${DIR_NAME} not found after unzip."
  exit 1
fi

cd "${DIR_NAME}"

# ---- Build diagnostics command ----
CMD=( "./diagnostics.sh" "--host" "${ES_HOST}" "--port" "${ES_PORT}" "--user" "${ES_USER}" "--password" "${ES_PASS}" )

if [[ "${USE_SSL}" =~ ^[Yy]$ ]]; then
  CMD+=( "--ssl" )
fi

echo "[*] Running: ${CMD[*]}"
echo

# ---- Run diagnostics ----
"${CMD[@]}"

echo
echo "[*] Diagnostics finished. Look for a ZIP like:"
ls -1 diagnostics-*.zip 2>/dev/null || echo "    (No diagnostics-*.zip found? Check output above.)"
echo
echo "[*] Location: $(pwd)"
