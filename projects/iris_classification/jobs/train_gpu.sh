#!/bin/bash
#SBATCH --job-name=iris_classification_gpu
#SBATCH --account=DEUCALION_PROJECT_IDg
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --output=/projects/F202500001INOVIAMAKEITTECH/brunosousa/deucalion-workshop/projects/iris_classification/logs/iris_classification/%j_train_gpu.out
#SBATCH --error=/projects/F202500001INOVIAMAKEITTECH/brunosousa/deucalion-workshop/projects/iris_classification/logs/iris_classification/%j_train_gpu.err

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
WORKSPACE="/projects/F202500001INOVIAMAKEITTECH/brunosousa/deucalion-workshop/projects/iris_classification"
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
python scripts/iris_classification_train.py

echo ""
echo "========================================="
echo "  Job completo: $(date)"
echo "========================================="
