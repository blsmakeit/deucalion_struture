#!/bin/bash
#SBATCH --job-name=PROJECT_NAME_gpu
#SBATCH --account=DEUCALION_PROJECT_IDg
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --output=WORKSPACE_PATH/logs/PROJECT_NAME/%j_train_gpu.out
#SBATCH --error=WORKSPACE_PATH/logs/PROJECT_NAME/%j_train_gpu.err

echo "========================================="
echo "  Projeto:    PROJECT_NAME"
echo "  Tipo:       Treino GPU"
echo "  Job ID:     $SLURM_JOB_ID"
echo "  Node:       $SLURMD_NODENAME"
echo "  CPUs:       $SLURM_CPUS_PER_TASK"
echo "  GPU:        $CUDA_VISIBLE_DEVICES"
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

# Carregar módulos
module load Python/3.11.3-GCCcore-12.3.0
module load CUDA/12.1.1

# Verificar GPU
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null || echo "nvidia-smi não disponível"

# Ativar venv
source "$VENV/bin/activate"

echo "Python: $(python --version)"
echo "Venv:   $VENV"
echo ""

# Correr treino
cd "$WORKSPACE"
python scripts/PROJECT_NAME_train.py

echo ""
echo "========================================="
echo "  Job completo: $(date)"
echo "========================================="
