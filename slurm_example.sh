#!/usr/bin/env bash
#SBATCH --job-name=pylk
#SBATCH --output=pylk-%j.out
#SBATCH --error=pylk-%j.err
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
# #SBATCH --partition=<your-partition>   # uncomment and set if required
# #SBATCH --account=<your-account>       # uncomment and set if required

# Example sbatch script for running a PyLk calculation on a cluster.
# Edit the PYLK_VENV and SCRIPT variables, then submit with `sbatch slurm_example.sh`.

set -euo pipefail

# --- environment ---------------------------------------------------------
# Load any modules your venv depends on (same ones used when PyLk was built).
# module load python/3.11 gcc

# Path to the existing venv that PyLk was installed into.
PYLK_VENV="${HOME}/path/to/your/venv"
SCRIPT="${HOME}/Dev/PyLk/test.py"

# shellcheck disable=SC1091
source "${PYLK_VENV}/bin/activate"

# Send numba's JIT cache to node-local scratch so concurrent jobs don't
# thrash a shared filesystem. Comment out if your cluster has no TMPDIR.
export NUMBA_CACHE_DIR="${TMPDIR:-/tmp}/numba_cache_${SLURM_JOB_ID:-$$}"
mkdir -p "${NUMBA_CACHE_DIR}"

# Pin thread counts for reproducibility; tune to --cpus-per-task.
export OMP_NUM_THREADS="${SLURM_CPUS_PER_TASK:-1}"
export NUMBA_NUM_THREADS="${SLURM_CPUS_PER_TASK:-1}"

# --- run -----------------------------------------------------------------
echo "host: $(hostname)"
echo "python: $(which python) ($(python --version))"
echo "cpus: ${SLURM_CPUS_PER_TASK:-?}, job: ${SLURM_JOB_ID:-local}"

srun python "${SCRIPT}"
