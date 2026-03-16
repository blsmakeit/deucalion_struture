#!/bin/bash
#SBATCH --job-name=heat_diffusion_sim
#SBATCH --account=f202500001inoviamakeittechx
#SBATCH --partition=normal-x86
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=08:00:00
#SBATCH --output=/projects/F202500001INOVIAMAKEITTECH/brunosousa/deucalion-workshop/projects/heat_diffusion/logs/heat_diffusion/%j_sim.out
#SBATCH --error=/projects/F202500001INOVIAMAKEITTECH/brunosousa/deucalion-workshop/projects/heat_diffusion/logs/heat_diffusion/%j_sim.err

echo "========================================="
echo "  Projeto:    heat_diffusion"
echo "  Tipo:       Simulação"
echo "  Job ID:     $SLURM_JOB_ID"
echo "  Node:       $SLURMD_NODENAME"
echo "  CPUs:       $SLURM_CPUS_PER_TASK"
echo "  Memória:    $SLURM_MEM_PER_NODE MB"
echo "  Início:     $(date)"
echo "========================================="

# Workspace e venv
WORKSPACE="/projects/F202500001INOVIAMAKEITTECH/brunosousa/deucalion-workshop/projects/heat_diffusion"
VENV="$WORKSPACE/venvs/heat_diffusion"

# Verificar que o venv existe
if [ ! -d "$VENV" ]; then
    echo "ERRO: venv não encontrado em $VENV"
    echo "Corre: ./new_project.sh heat_diffusion simulation"
    exit 1
fi

# Carregar Python e ativar venv
module load Python/3.11.3-GCCcore-12.3.0
source "$VENV/bin/activate"

echo "Python: $(python --version)"
echo "Venv:   $VENV"
echo ""

# Correr simulação
cd "$WORKSPACE"
python scripts/sim.py

echo ""
echo "========================================="
echo "  Job completo: $(date)"
echo "========================================="
