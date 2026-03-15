#!/bin/bash
# =============================================================
# Deucalion Workshop — Setup Inicial
# Correr UMA VEZ no Deucalion, após git clone do repo
#
# Uso:
#   ./setup.sh
#   ./setup.sh <username> <project_id>
#
# Exemplo:
#   ./setup.sh joao.silva F202500001INOVIAMAKEITTECH
# =============================================================

set -e  # parar imediatamente se der erro

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "============================================="
echo "  Deucalion Workshop — Setup Inicial"
echo "============================================="
echo ""

# --- 1. Recolher informação ---
if [ $# -eq 2 ]; then
    USERNAME=$1
    PROJECT_ID=$2
else
    read -p "O teu username no Deucalion (ex: joao.silva): " USERNAME
    read -p "ID do projeto (ex: F202500001INOVIAMAKEITTECH): " PROJECT_ID
fi

# Confirmar
echo ""
echo "Configuração:"
echo "  Username:   $USERNAME"
echo "  Project ID: $PROJECT_ID"
echo ""
read -p "Confirmar? (s/n): " CONFIRM
if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
    echo "Setup cancelado."
    exit 0
fi

# --- 2. Definir paths ---
WORKSPACE="/projects/$PROJECT_ID/$USERNAME/ml_workspace"

# Verificar que a pasta do projeto existe
if [ ! -d "/projects/$PROJECT_ID" ]; then
    echo ""
    echo "ERRO: A pasta /projects/$PROJECT_ID não existe."
    echo "Verifica se o PROJECT_ID está correto e se tens acesso ao projeto."
    exit 1
fi

echo ""
echo "A criar workspace em: $WORKSPACE"

# --- 3. Criar estrutura de pastas base ---
mkdir -p "$WORKSPACE/datasets"
mkdir -p "$WORKSPACE/models"
mkdir -p "$WORKSPACE/logs"
mkdir -p "$WORKSPACE/results"
mkdir -p "$WORKSPACE/scripts"
mkdir -p "$WORKSPACE/jobs"
mkdir -p "$WORKSPACE/venvs"

# --- 4. Copiar ficheiros base ---
cp "$REPO_DIR/scripts/utils.py"   "$WORKSPACE/scripts/utils.py"
cp "$REPO_DIR/new_project.sh"     "$WORKSPACE/new_project.sh"
chmod +x "$WORKSPACE/new_project.sh"

# Guardar configuração (usada pelo new_project.sh)
cat > "$WORKSPACE/.config" << EOF
USERNAME=$USERNAME
PROJECT_ID=$PROJECT_ID
WORKSPACE=$WORKSPACE
REPO_DIR=$REPO_DIR
EOF

# --- 5. Criar symlink ~/workshop ---
if [ -L ~/workshop ]; then
    echo "Symlink ~/workshop já existe — a atualizar..."
    rm ~/workshop
elif [ -d ~/workshop ]; then
    echo "AVISO: ~/workshop é uma pasta real. A renomear para ~/workshop_backup..."
    mv ~/workshop ~/workshop_backup
fi

ln -s "$WORKSPACE" ~/workshop
echo "Symlink criado: ~/workshop → $WORKSPACE"

# --- 6. Resumo ---
echo ""
echo "============================================="
echo "  Setup completo!"
echo "============================================="
echo ""
echo "  Workspace: $WORKSPACE"
echo "  Atalho:    ~/workshop"
echo ""
echo "Para criar um projeto de treino de modelos:"
echo "  cd ~/workshop"
echo "  ./new_project.sh <nome> ml"
echo ""
echo "Para criar um projeto de simulação:"
echo "  cd ~/workshop"
echo "  ./new_project.sh <nome> simulation"
echo ""
