#!/usr/bin/env bash
# Compile PyLk's Cython extensions and install them into the currently
# active Python environment.
#
# Usage:
#     source /path/to/your/venv/bin/activate    # activate your env first
#     ./install_cluster.sh
#
# The script does NOT create or modify any environment — it just builds
# the .so files and pip-installs PyLk into whatever `python` / `pip`
# currently resolve to. It expects cython, numpy, setuptools and wheel to
# already be present in that env (they're listed as build deps in
# pyproject.toml, but we skip PEP 517 build isolation to reuse the env's
# copies rather than downloading them fresh).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "${VIRTUAL_ENV:-}" && -z "${CONDA_PREFIX:-}" ]]; then
    cat <<'EOF' >&2
Error: no virtualenv or conda env appears to be active.

Activate the env you want PyLk installed into first, e.g.:
    source /path/to/venv/bin/activate
then re-run this script.
EOF
    exit 1
fi

echo ">>> python:        $(python --version) at $(which python)"
echo ">>> installing into: ${VIRTUAL_ENV:-${CONDA_PREFIX}}"

# --no-build-isolation reuses the env's cython/numpy/setuptools instead of
# downloading a throwaway copy. Drop the flag if any of those are missing.
pip install --no-build-isolation "${REPO_DIR}"

echo ">>> verifying import"
# cd out of the repo so the stale in-tree .so files don't shadow the install.
( cd /tmp && python -c "import pylk; from pylk import _writhemap_cython, linkingnumber_cython; print('pylk OK ->', pylk.__file__)" )
