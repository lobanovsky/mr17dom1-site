#!/usr/bin/env bash
set -euo pipefail
release=$(cd -- "$(dirname -- "$0")/.." && pwd)
[[ $(basename -- "$(dirname -- "$release")") == releases ]] || { echo 'Run this script inside a server release directory.' >&2; exit 1; }
base=$(dirname -- "$(dirname -- "$release")")
[[ -f "$base/.env" ]] || { echo "Configure $base/.env first." >&2; exit 1; }
exec 9>"$base/.deploy.lock"
flock -n 9 || { echo 'Another deployment is running.' >&2; exit 1; }
revision=$(basename -- "$release")
[[ "$revision" =~ ^[a-f0-9]{40}$ ]] || { echo 'Release name must be a full Git commit SHA.' >&2; exit 1; }
export SITE_IMAGE="mr17dom1-site:$revision"
compose=(docker compose --project-name mr17dom1-site --env-file "$base/.env" -f "$release/compose.yaml")
"${compose[@]}" config --quiet
docker build --pull -t "$SITE_IMAGE" "$release"
previous=$(readlink -f "$base/current" 2>/dev/null || true)
if ! "${compose[@]}" up -d --wait --wait-timeout 90; then
    echo 'Deployment failed.' >&2
    if [[ -n "$previous" && -f "$previous/compose.yaml" ]]; then
        echo 'Restoring previous release.' >&2
        SITE_IMAGE="mr17dom1-site:$(basename -- "$previous")" docker compose \
            --project-name mr17dom1-site --env-file "$base/.env" \
            -f "$previous/compose.yaml" up -d --wait --wait-timeout 90
    fi
    exit 1
fi
ln -sfn "$release" "$base/current.next"
mv -Tf "$base/current.next" "$base/current"
echo "Deployed $revision (container health verified; check public HTTPS separately)."
