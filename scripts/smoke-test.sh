#!/usr/bin/env bash
set -euo pipefail
image=${1:-mr17dom1-site:test}
container=$(docker run -d --read-only --tmpfs /var/cache/nginx --tmpfs /var/run \
    --tmpfs /tmp -p 127.0.0.1::80 "$image")
trap 'docker rm -f "$container" >/dev/null' EXIT
port=$(docker port "$container" 80/tcp | head -1 | sed 's/.*://')
url="http://127.0.0.1:$port"
curl --fail --silent --show-error --retry 10 --retry-delay 1 --retry-connrefused "$url/healthz"
curl --fail --silent --show-error "$url/" | python3 -c 'import sys; assert "МР17дом1" in sys.stdin.read()'
curl --fail --silent --show-error "$url/css/tilda-grid-3.0.min.css" >/dev/null
[[ $(curl -s -o /dev/null -w '%{http_code}' "$url/does-not-exist") == 404 ]]
[[ $(curl -s -o /dev/null -w '%{http_code}' "$url/mr17dom1") == 301 ]]
[[ $(curl -s -o /dev/null -w '%{http_code}' "$url/.env") == 403 ]]
echo 'OK: Nginx homepage, assets, health, redirects, 404 and hidden-file protection.'

