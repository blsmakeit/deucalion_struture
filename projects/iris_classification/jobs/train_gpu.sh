#!/bin/bash
#SBATCH --job-name=iris_classification_gpu
#SBATCH --account=f202500001inoviamakeittechg
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --output=/projects/F202500001INOVIAMAKEITTECH/%u/deucalion-workshop/projects/iris_classification/logs/%j_train_gpu.out
#SBATCH --error=/projects/F202500001INOVIAMAKEITTECH/%u/deucalion-workshop/projects/iris_classification/logs/%j_train_gpu.err

echo "========================================="
echo "  Projeto:    iris_classification"
echo "  Tipo:       Treino GPU"
echo "  Job ID:     $SLURM_JOB_ID"
echo "  Node:       $SLURMD_NODENAME"
echo "  CPUs:       $SLURM_CPUS_PER_TASK"
echo "  GPU:        $CUDA_VISIBLE_DEVICES"
echo "  Início:     $(date)"
echo "========================================="

# Workspace e venv
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$(dirname "$SCRIPT_DIR")"
VENV="$WORKSPACE/venvs/iris_classification"

# Verificar que o venv existe
if [ ! -d "$VENV" ]; then
    echo "ERRO: venv não encontrado em $VENV"
    echo "Corre: ./new_project.sh iris_classification ml"
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
python scripts/train.py

echo ""
echo "========================================="
echo "  Job completo: $(date)"
echo "========================================="
