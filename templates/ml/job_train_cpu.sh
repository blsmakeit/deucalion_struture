#!/bin/bash
#SBATCH --job-name=PROJECT_NAME_cpu
#SBATCH --account=DEUCALION_PROJECT_IDx
#SBATCH --partition=normal-x86
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --output=WORKSPACE_PATH/logs/PROJECT_NAME/%j_train_cpu.out
#SBATCH --error=WORKSPACE_PATH/logs/PROJECT_NAME/%j_train_cpu.err

echo "========================================="
echo "  Projeto:    PROJECT_NAME"
echo "  Tipo:       Treino CPU"
echo "  Job ID:     $SLURM_JOB_ID"
echo "  Node:       $SLURMD_NODENAME"
echo "  CPUs:       $SLURM_CPUS_PER_TASK"
echo "  Memória:    $SLURM_MEM_PER_NODE MB"
echo "  Início:     $(date)"
echo "========================================="

# Workspace e venv
WORKSPACE="WORKSPACE_PATH"
VENV="$WORKSPACE/venvs/PROJECT_NAME"

# Verificar que o venv existe
if [ ! -d "$VENV" ]; then
    echo "ERRO: venv não encontrado em $VENV"
    echo "Corre: ./new_project.sh PROJECT_NAME ml"
    exit 1
fi

# Carregar Python e ativar venv
module load Python/3.11.3-GCCcore-12.3.0
source "$VENV/bin/activate"

echo "Python: $(python --version)"
echo "Venv:   $VENV"
echo ""

# Correr treino
cd "$WORKSPACE"
python scripts/train.py

echo ""
echo "========================================="
echo "  Job completo: $(date)"
echo "========================================="
