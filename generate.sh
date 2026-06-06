#!/usr/bin/env bash
# Regenerates public/ from packages.tsv.
# Usage: ./generate.sh
set -euo pipefail
cd "$(dirname "$0")"

ORG="klarlabs-studio"
HOST="go.klarlabs.de"

rm -rf public
mkdir -p public

# Per-package pages with go-import / go-source meta tags
while IFS=$'\t' read -r name repo; do
  [ -z "$name" ] && continue
  cat > "public/${name}.html" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="go-import" content="${HOST}/${name} git https://github.com/${ORG}/${repo}">
<meta name="go-source" content="${HOST}/${name} https://github.com/${ORG}/${repo} https://github.com/${ORG}/${repo}/tree/main{/dir} https://github.com/${ORG}/${repo}/blob/main{/dir}/{file}#L{line}">
<meta http-equiv="refresh" content="0; url=https://pkg.go.dev/${HOST}/${name}">
<title>${HOST}/${name}</title>
</head>
<body>
Redirecting to <a href="https://pkg.go.dev/${HOST}/${name}">pkg.go.dev/${HOST}/${name}</a>&hellip;
</body>
</html>
EOF
done < packages.tsv

# nginx vhost config: route package paths (incl. subpackages and /vN suffixes) to their page
PATTERN=$(cut -f1 packages.tsv | paste -sd'|' -)
cat > nginx-default.conf <<EOF
server {
    listen 8080;
    server_name ${HOST};
    root /usr/share/nginx/html;
    index index.html;

    location ~ ^/(${PATTERN})(/|\$) {
        rewrite ^/([^/]+).*\$ /\$1.html break;
    }
}
EOF

# Index page
{
  cat <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>go.klarlabs.de — Klarlabs Go packages</title>
<style>
  body { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; max-width: 42rem; margin: 4rem auto; padding: 0 1rem; color: #1a1a1a; }
  h1 { font-size: 1.2rem; }
  ul { list-style: none; padding: 0; }
  li { margin: .4rem 0; }
  a { color: #0550ae; text-decoration: none; }
  a:hover { text-decoration: underline; }
  footer { margin-top: 3rem; font-size: .8rem; color: #666; }
</style>
</head>
<body>
<h1>go.klarlabs.de</h1>
<p>Go packages by <a href="https://github.com/klarlabs-studio">Klarlabs</a>.</p>
<ul>
EOF
  while IFS=$'\t' read -r name repo; do
    [ -z "$name" ] && continue
    echo "<li><a href=\"https://pkg.go.dev/${HOST}/${name}\">${HOST}/${name}</a> — <a href=\"https://github.com/${ORG}/${repo}\">source</a></li>"
  done < packages.tsv
  cat <<'EOF'
</ul>
<footer>klarlabs.de</footer>
</body>
</html>
EOF
} > public/index.html

echo "Generated $(ls public/*.html | wc -l | tr -d ' ') pages + nginx-default.conf."
