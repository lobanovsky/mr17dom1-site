#!/usr/bin/env bash
set -euo pipefail
hostname
id
docker compose version
docker ps --format '{{.Names}}\t{{.Image}}\t{{.Ports}}'
python3 - <<'PY'
import json
import subprocess

ids = subprocess.check_output(['docker', 'ps', '-q'], text=True).split()
if not ids:
    raise SystemExit('No running containers')
containers = json.loads(subprocess.check_output(['docker', 'inspect', *ids]))
for c in containers:
    labels = c['Config'].get('Labels') or {}
    is_proxy = 'traefik' in c['Config']['Image'].lower()
    if not is_proxy and not any(k.startswith('traefik.') for k in labels):
        continue
    print('\nContainer:', c['Name'])
    print('Networks:', ', '.join(c['NetworkSettings']['Networks']))
    if is_proxy:
        for arg in c['Config'].get('Cmd') or []:
            if arg.lower().startswith(('--entrypoints.', '--certificatesresolvers.', '--providers.docker.network')):
                # Show names and challenge type, never DNS credentials or account data.
                key = arg.split('=', 1)[0]
                if any(x in key.lower() for x in ('email', 'token', 'secret', 'key', 'storage')):
                    continue
                print('Traefik option:', key)
    for k, v in sorted(labels.items()):
        if k == 'traefik.docker.network' or k.endswith(('.entrypoints', '.tls.certresolver')):
            print(k, '=', v)
PY

