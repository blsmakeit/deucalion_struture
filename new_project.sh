#!/bin/bash
# =============================================================
# Deucalion Workshop — Criar Novo Projeto
#
# Uso:
#   ./new_project.sh <nome_projeto> <tipo>
#
# Tipos disponíveis:
#   ml          — treino e inferência de modelos
#   simulation  — simulações numéricas
#
# Exemplos:
#   ./new_project.sh cancer_detection ml
#   ./new_project.sh fluid_dynamics simulation
# =============================================================

set -e

# --- Validar argumentos ---
if [ $# -lt 2 ]; then
    echo ""
    echo "Uso: ./new_project.sh <nome_projeto> <tipo>"
    echo ""
    echo "Tipos:"
    echo "  ml          — treino e inferência de modelos"
    echo "  simulation  — simulações numéricas"
    echo ""
    echo "Exemplos:"
    echo "  ./new_project.sh cancer_detection ml"
    echo "  ./new_project.sh fluid_dynamics simulation"
    exit 1
fi

PROJECT=$1
TYPE=$2

if [[ "$TYPE" != "ml" && "$TYPE" != "simulation" ]]; then
    echo "Erro: tipo inválido '$TYPE'. Usar: ml ou simulation"
    exit 1
fi

# --- Carregar configuração ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$SCRIPT_DIR/.config"

if [ ! -f "$CONFIG" ]; then
    echo "Erro: ficheiro .config não encontrado."
    echo "Corre primeiro: ./setup.sh"
    exit 1
fi

source "$CONFIG"

TEMPLATE_DIR="$REPO_DIR/templates/$TYPE"

if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Erro: templates não encontrados em $TEMPLATE_DIR"
    echo "Verifica se o REPO_DIR no .config está correto: $REPO_DIR"
    exit 1
fi

echo ""
echo "============================================="
echo "  A criar projeto: $PROJECT"
echo "  Tipo:            $TYPE"
echo "  Utilizador:      $USERNAME"
echo "============================================="

# --- 1. Criar estrutura de pastas ---
echo ""
echo "[1/3] A criar pastas..."
mkdir -p "$WORKSPACE/datasets/$PROJECT"
mkdir -p "$WORKSPACE/models/$PROJECT"
mkdir -p "$WORKSPACE/logs/$PROJECT"
mkdir -p "$WORKSPACE/results/$PROJECT"
echo "      OK"

# --- 2. Criar venv e instalar packages ---
echo ""
echo "[2/3] A criar ambiente virtual e instalar packages..."
echo "      (pode demorar 2-3 minutos)"
echo ""

module load Python/3.11.3-GCCcore-12.3.0 2>/dev/null || \
module load python/3.10 2>/dev/null || \
echo "AVISO: não foi possível carregar módulo Python — a usar Python do sistema"

VENV_DIR="$WORKSPACE/venvs/$PROJECT"
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

pip install --quiet --upgrade pip
pip install --quiet -r "$TEMPLATE_DIR/requirements.txt"

# Guardar requirements no venv para referência futura
cp "$TEMPLATE_DIR/requirements.txt" "$VENV_DIR/requirements.txt"

deactivate
echo "      Venv criado em: $VENV_DIR"

# --- 3. Copiar e personalizar scripts e jobs ---
echo ""
echo "[3/3] A copiar e configurar scripts e jobs..."

if [ "$TYPE" == "ml" ]; then

    # Scripts
    TRAIN_SCRIPT="$WORKSPACE/scripts/${PROJECT}_train.py"
    INFER_SCRIPT="$WORKSPACE/scripts/${PROJECT}_infer.py"
    cp "$TEMPLATE_DIR/train_template.py" "$TRAIN_SCRIPT"
    cp "$TEMPLATE_DIR/infer_template.py" "$INFER_SCRIPT"

    for SCRIPT in "$TRAIN_SCRIPT" "$INFER_SCRIPT"; do
        sed -i "s/PROJECT_NAME/$PROJECT/g"       "$SCRIPT"
        sed -i "s|WORKSPACE_PATH|$WORKSPACE|g"   "$SCRIPT"
    done

    # Jobs
    CPU_JOB="$WORKSPACE/jobs/${PROJECT}_train_cpu.sh"
    GPU_JOB="$WORKSPACE/jobs/${PROJECT}_train_gpu.sh"
    cp "$TEMPLATE_DIR/job_train_cpu.sh" "$CPU_JOB"
    cp "$TEMPLATE_DIR/job_train_gpu.sh" "$GPU_JOB"

    for JOB in "$CPU_JOB" "$GPU_JOB"; do
        sed -i "s/PROJECT_NAME/$PROJECT/g"         "$JOB"
        sed -i "s|WORKSPACE_PATH|$WORKSPACE|g"     "$JOB"
        sed -i "s/DEUCALION_USER/$USERNAME/g"      "$JOB"
        sed -i "s/DEUCALION_PROJECT_ID/$PROJECT_ID/g" "$JOB"
    done

elif [ "$TYPE" == "simulation" ]; then

    # Script
    SIM_SCRIPT="$WORKSPACE/scripts/${PROJECT}_sim.py"
    cp "$TEMPLATE_DIR/sim_template.py" "$SIM_SCRIPT"
    sed -i "s/PROJECT_NAME/$PROJECT/g"       "$SIM_SCRIPT"
    sed -i "s|WORKSPACE_PATH|$WORKSPACE|g"   "$SIM_SCRIPT"

    # Job
    SIM_JOB="$WORKSPACE/jobs/${PROJECT}_sim.sh"
    cp "$TEMPLATE_DIR/job_sim_cpu.sh" "$SIM_JOB"
    sed -i "s/PROJECT_NAME/$PROJECT/g"              "$SIM_JOB"
    sed -i "s|WORKSPACE_PATH|$WORKSPACE|g"          "$SIM_JOB"
    sed -i "s/DEUCALION_USER/$USERNAME/g"           "$SIM_JOB"
    sed -i "s/DEUCALION_PROJECT_ID/$PROJECT_ID/g"   "$SIM_JOB"

fi

echo "      OK"

# --- Resumo final ---
echo ""
echo "============================================="
echo "  Projeto '$PROJECT' criado com sucesso!"
echo "============================================="
echo ""
echo "Estrutura criada:"
echo "  ~/ml/datasets/$PROJECT/    <- coloca os dados aqui"
echo "  ~/ml/models/$PROJECT/      <- modelos treinados"
echo "  ~/ml/logs/$PROJECT/        <- logs do SLURM"
echo "  ~/ml/results/$PROJECT/     <- resultados e métricas"
echo ""

if [ "$TYPE" == "ml" ]; then
echo "Scripts:"
echo "  ~/ml/scripts/${PROJECT}_train.py"
echo "  ~/ml/scripts/${PROJECT}_infer.py"
echo ""
echo "Jobs:"
echo "  ~/ml/jobs/${PROJECT}_train_cpu.sh   <- treino em CPU"
echo "  ~/ml/jobs/${PROJECT}_train_gpu.sh   <- treino em GPU (mais rápido)"
echo ""
echo "Próximos passos:"
echo ""
echo "  1. Enviar dados (do teu PC/WSL):"
echo "     scp dados.csv deucalion:~/ml/datasets/$PROJECT/"
echo ""
echo "  2. Submeter job de treino (CPU):"
echo "     sbatch ~/ml/jobs/${PROJECT}_train_cpu.sh"
echo ""
echo "  3. Ou GPU (recomendado para deep learning):"
echo "     sbatch ~/ml/jobs/${PROJECT}_train_gpu.sh"
echo ""
echo "  4. Monitorizar:"
echo "     squeue -u \$USER"
echo "     tail -f ~/ml/logs/$PROJECT/*.out"
echo ""
echo "  5. Descarregar modelo (do teu PC/WSL):"
echo "     scp -r deucalion:~/ml/models/$PROJECT/ ./"

elif [ "$TYPE" == "simulation" ]; then
echo "Script:"
echo "  ~/ml/scripts/${PROJECT}_sim.py"
echo ""
echo "Job:"
echo "  ~/ml/jobs/${PROJECT}_sim.sh"
echo ""
echo "Próximos passos:"
echo ""
echo "  1. Editar parâmetros da simulação:"
echo "     nano ~/ml/scripts/${PROJECT}_sim.py"
echo ""
echo "  2. Submeter job:"
echo "     sbatch ~/ml/jobs/${PROJECT}_sim.sh"
echo ""
echo "  3. Monitorizar:"
echo "     squeue -u \$USER"
echo "     tail -f ~/ml/logs/$PROJECT/*.out"
echo ""
echo "  4. Descarregar resultados (do teu PC/WSL):"
echo "     scp -r deucalion:~/ml/results/$PROJECT/ ./"
fi
echo ""
