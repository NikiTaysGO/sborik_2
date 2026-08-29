#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <github-owner> <github-repo> [branch] [path-in-repo]"
  echo "Example: $0 nikitays0987 mc-modpack main packwiz"
  exit 1
fi

OWNER="$1"
REPO="$2"
BRANCH="${3:-main}"
SUBDIR="${4:-}"

cd "$(dirname "$0")"

if [ -n "$SUBDIR" ]; then
  BASE_URL="https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}/${SUBDIR}"
else
  BASE_URL="https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}"
fi

for f in mods/*.pw.toml; do
  sed -i.bak "s#{{PACK_BASE_URL}}#${BASE_URL}#g" "$f"
  rm -f "${f}.bak"
done

python3 - "$BASE_URL" <<'PYEOF'
import re, hashlib

def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()

with open("index.toml") as f:
    content = f.read()

def repl(m):
    file_rel = m.group(1)
    h = sha256_file(file_rel)
    return f'file = "{file_rel}"\nhash = "{h}"'

pattern = re.compile(r'file = "([^"]+\.pw\.toml)"\nhash = "[0-9a-f]+"')
content = pattern.sub(repl, content)

with open("index.toml", "w") as f:
    f.write(content)

index_hash = sha256_file("index.toml")
with open("pack.toml") as f:
    pack = f.read()

pack = re.sub(
    r'(\[index\]\nfile = "index\.toml"\nhash-format = "sha256"\nhash = ")[0-9a-f]+(")',
    lambda m: m.group(1) + index_hash + m.group(2),
    pack,
)

with open("pack.toml", "w") as f:
    f.write(pack)
PYEOF

echo ""
echo "Done."
echo "Base URL:  ${BASE_URL}"
echo "Pack URL (use this one link everywhere): ${BASE_URL}/pack.toml"
