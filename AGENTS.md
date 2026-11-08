# Repository Guidelines

## Project Structure & Module Organization

This repository hosts the static Tilda export for `mr17dom1.ru`.

- `mr17dom1-from-tilda/page56734223.html`: the homepage, served at `/`.
- `mr17dom1-from-tilda/{css,js,images}/`: exported styles, scripts, and assets.
- `deploy/nginx.conf`, `Dockerfile`, `compose.yaml`: Nginx and Traefik integration.
- `scripts/`: asset validation, HTTP smoke tests, server inspection, and deployment.
- `.github/workflows/deploy.yml`: pull request checks and production deployment.
- `README.md`: public project overview, editing, and local development.

The exported `files/` fragment is not served. Edit the main HTML for page changes.

## Build, Test, and Development Commands

- `python3 scripts/check-site.py`: verify required pages and local HTML/CSS assets.
- `docker build -t mr17dom1-site:test .`: build the Nginx image and validate its configuration.
- `bash scripts/smoke-test.sh mr17dom1-site:test`: test HTTP behavior in a temporary container.
- `docker run --rm -p 127.0.0.1:8080:80 mr17dom1-site:test`: preview locally.

No Node.js dependency installation is needed. Use Python 3.9+ and Docker.

## Coding Style & Naming Conventions

Use two spaces in YAML and four spaces in Python and Nginx configuration. Shell scripts use Bash with `set -euo pipefail`. Quote shell paths and variables. Preserve generated Tilda filenames and avoid reformatting minified assets. No formatter or linter is configured.

## Testing Guidelines

Run asset checks and container smoke tests before submitting changes. Smoke tests cover the homepage, CSS, health endpoint, legacy redirect, 404 responses, and hidden-file protection. There is no coverage threshold. Inspect visual changes in a browser; automated checks do not verify appearance or external Tilda services.

## Commit & Pull Request Guidelines

Use concise, imperative commit subjects, such as `Add initial page layout`, and keep commits focused.

Pull requests should describe the change, its purpose, and validation performed. Link relevant issues and include screenshots for visible interface changes. Explicitly identify any setup changes or checks that could not be run.

## Security & Configuration

Keep operational documentation in ignored `private/`. Never publish server addresses, SSH settings, deployment paths, actual network names, keys, or server `.env` files. Public configuration must use generic examples; deployment settings belong in GitHub Actions secrets. Pushes to `main` deploy automatically. Preserve strict SSH host verification and change only this project's resources.
