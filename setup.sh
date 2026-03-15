#!/bin/bash
# =============================================================
# Deucalion Workshop — Criar Novo Projeto
#
# Uso:
#   ./new_project.sh <nome_projeto> <tipo>
#
# Tipos:
#   ml          — treino e inferência de modelos
#   simulation  — simulações numéricas
#
# Exemplos:
#   ./new_project.sh iris_classification ml
#   ./new_project.sh heat_diffusion simulation
# =============================================================

set -e

# --- Validar argumentos ---
if [ $# -lt 2 ]; then
    echo ""
    echo "Uso: ./new_project.sh <nome_projeto> <tipo>"
    echo ""
    echo "Tipos disponíveis:"
    echo "  ml          — treino e inferência de modelos"
    echo "  simulation  — simulações numéricas"
    echo ""
    echo "Exemplos:"
    echo "  ./new_project.sh iris_classification ml"
    echo "  ./new_project.sh heat_diffusion simulation"
    exit 1
fi

PROJECT=$1
TYPE=$2

if [[ "$TYPE" != "ml" && "$TYPE" != "simulation" ]]; then
    echo "Erro: tipo inválido '$TYPE'. Usar: ml ou simulation"
    exit 1
fi

# --- Paths ---
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$REPO_DIR/templates/$TYPE"
PROJECT_DIR="$REPO_DIR/projects/$PROJECT"

# Verificar se o projeto já existe
if [ -d "$PROJECT_DIR" ]; then
    echo "Erro: projeto '$PROJECT' já existe em $PROJECT_DIR"
    exit 1
fi

echo ""
echo "============================================="
echo "  A criar projeto: $PROJECT"
echo "  Tipo:            $TYPE"
echo "  Localização:     $PROJECT_DIR"
echo "============================================="

# --- 1. Criar estrutura de pastas ---
echo ""
echo "[1/4] A criar estrutura de pastas..."
mkdir -p "$PROJECT_DIR/scripts"
mkdir -p "$PROJECT_DIR/jobs"
mkdir -p "$PROJECT_DIR/datasets"
mkdir -p "$PROJECT_DIR/models"
mkdir -p "$PROJECT_DIR/logs"
mkdir -p "$PROJECT_DIR/results"
mkdir -p "$PROJECT_DIR/venvs"
echo "      OK"

# --- 2. Criar .gitignore do projeto ---
echo ""
echo "[2/4] A criar .gitignore..."
cat > "$PROJECT_DIR/.gitignore" << 'EOF'
# Dados, modelos, logs — nunca vão para o GitHub
datasets/
models/
logs/
results/
venvs/

# Python
__pycache__/
*.pyc
*.pyo
*.pkl
*.pt
*.pth
*.h5
*.tar.gz
*.zip
.env
EOF
echo "      OK"

# --- 3. Criar venv e instalar packages ---
echo ""
echo "[3/4] A criar venv e instalar packages..."
echo "      (pode demorar 2-3 minutos)"

module load Python/3.11.3-GCCcore-12.3.0 2>/dev/null || \
    echo "      AVISO: module load não disponível — a usar Python do sistema"

python3 -m venv "$PROJECT_DIR/venvs/$PROJECT"
source "$PROJECT_DIR/venvs/$PROJECT/bin/activate"
pip install --quiet --upgrade pip
pip install --quiet -r "$TEMPLATE_DIR/requirements.txt"
cp "$TEMPLATE_DIR/requirements.txt" "$PROJECT_DIR/venvs/requirements.txt"
deactivate
echo "      OK — venv em: $PROJECT_DIR/venvs/$PROJECT"

# --- 4. Copiar e personalizar templates ---
echo ""
echo "[4/4] A copiar e configurar scripts e jobs..."

if [ "$TYPE" == "ml" ]; then

    # Scripts
    cp "$TEMPLATE_DIR/train_template.py" "$PROJECT_DIR/scripts/train.py"
    cp "$TEMPLATE_DIR/infer_template.py" "$PROJECT_DIR/scripts/infer.py"

    for SCRIPT in "$PROJECT_DIR/scripts/train.py" "$PROJECT_DIR/scripts/infer.py"; do
        sed -i "s/PROJECT_NAME/$PROJECT/g"           "$SCRIPT"
        sed -i "s|WORKSPACE_PATH|$PROJECT_DIR|g"     "$SCRIPT"
    done

    # Jobs
    cp "$TEMPLATE_DIR/job_train_cpu.sh" "$PROJECT_DIR/jobs/train_cpu.sh"
    cp "$TEMPLATE_DIR/job_train_gpu.sh" "$PROJECT_DIR/jobs/train_gpu.sh"

    for JOB in "$PROJECT_DIR/jobs/train_cpu.sh" "$PROJECT_DIR/jobs/train_gpu.sh"; do
        sed -i "s/PROJECT_NAME/$PROJECT/g"       "$JOB"
        sed -i "s|WORKSPACE_PATH|$PROJECT_DIR|g" "$JOB"
    done

elif [ "$TYPE" == "simulation" ]; then

    # Script
    cp "$TEMPLATE_DIR/sim_template.py" "$PROJECT_DIR/scripts/sim.py"
    sed -i "s/PROJECT_NAME/$PROJECT/g"           "$PROJECT_DIR/scripts/sim.py"
    sed -i "s|WORKSPACE_PATH|$PROJECT_DIR|g"     "$PROJECT_DIR/scripts/sim.py"

    # Job
    cp "$TEMPLATE_DIR/job_sim_cpu.sh" "$PROJECT_DIR/jobs/sim_cpu.sh"
    sed -i "s/PROJECT_NAME/$PROJECT/g"       "$PROJECT_DIR/jobs/sim_cpu.sh"
    sed -i "s|WORKSPACE_PATH|$PROJECT_DIR|g" "$PROJECT_DIR/jobs/sim_cpu.sh"

fi

echo "      OK"

# --- README do projeto ---
cat > "$PROJECT_DIR/README.md" << EOF
# $PROJECT

Tipo: $TYPE
Criado: $(date '+%Y-%m-%d')

## Descrição
TODO: descrever o projeto

## Dados
TODO: descrever os dados e como os enviar

## Como correr

### Enviar dados (do PC/WSL)
\`\`\`bash
scp dados.csv deucalion:$PROJECT_DIR/datasets/
\`\`\`

### Submeter job (no Deucalion)
EOF

if [ "$TYPE" == "ml" ]; then
cat >> "$PROJECT_DIR/README.md" << EOF
\`\`\`bash
# CPU
sbatch $PROJECT_DIR/jobs/train_cpu.sh

# GPU (recomendado para deep learning)
sbatch $PROJECT_DIR/jobs/train_gpu.sh
\`\`\`

### Descarregar modelo (do PC/WSL)
\`\`\`bash
scp -r deucalion:$PROJECT_DIR/models/ ./
\`\`\`
EOF
elif [ "$TYPE" == "simulation" ]; then
cat >> "$PROJECT_DIR/README.md" << EOF
\`\`\`bash
sbatch $PROJECT_DIR/jobs/sim_cpu.sh
\`\`\`

### Descarregar resultados (do PC/WSL)
\`\`\`bash
scp -r deucalion:$PROJECT_DIR/results/ ./
\`\`\`
EOF
fi

# --- Resumo final ---
echo ""
echo "============================================="
echo "  Projeto '$PROJECT' criado!"
echo "============================================="
echo ""
echo "Estrutura:"
echo "  $PROJECT_DIR/"
echo "  ├── README.md"
echo "  ├── scripts/"
if [ "$TYPE" == "ml" ]; then
echo "  │   ├── train.py"
echo "  │   └── infer.py"
echo "  └── jobs/"
echo "      ├── train_cpu.sh"
echo "      └── train_gpu.sh"
elif [ "$TYPE" == "simulation" ]; then
echo "  │   └── sim.py"
echo "  └── jobs/"
echo "      └── sim_cpu.sh"
fi
echo ""
echo "Próximos passos:"
echo ""
echo "  1. Criar branch no GitHub:"
echo "     git checkout -b $PROJECT"
echo ""
if [ "$TYPE" == "ml" ]; then
echo "  2. Enviar dados (do PC/WSL):"
echo "     scp dados.csv deucalion:$PROJECT_DIR/datasets/"
echo ""
echo "  3. Submeter job:"
echo "     sbatch $PROJECT_DIR/jobs/train_cpu.sh"
echo "     sbatch $PROJECT_DIR/jobs/train_gpu.sh"
elif [ "$TYPE" == "simulation" ]; then
echo "  2. Editar parâmetros:"
echo "     nano $PROJECT_DIR/scripts/sim.py"
echo ""
echo "  3. Submeter job:"
echo "     sbatch $PROJECT_DIR/jobs/sim_cpu.sh"
fi
echo ""
echo "  4. Push para GitHub:"
echo "     git add projects/$PROJECT/"
echo "     git commit -m 'projeto: $PROJECT'"
echo "     git push origin $PROJECT"
echo ""
```
