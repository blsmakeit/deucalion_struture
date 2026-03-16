#!/bin/bash
# =============================================================
# Deucalion Workshop — Setup Inicial
#
# Corre UMA VEZ por utilizador no Deucalion, após o git clone:
#   bash setup.sh
# =============================================================

set -e

echo ""
echo "============================================="
echo "  Deucalion Workshop — Setup Inicial"
echo "============================================="
echo ""

# --- Pedir informação ao utilizador ---
read -p "  Username Deucalion (ex: joao.silva): " USERNAME
read -p "  Project ID (ex: F202500001INOVIAMAKEITTECH): " PROJECT_ID

# Validar entradas
if [ -z "$USERNAME" ] || [ -z "$PROJECT_ID" ]; then
    echo "Erro: username e project ID são obrigatórios"
    exit 1
fi

# Verificar que /projects/PROJECT_ID existe
PROJECTS_PATH="/projects/$PROJECT_ID"
if [ ! -d "$PROJECTS_PATH" ]; then
    echo ""
    echo "Erro: '$PROJECTS_PATH' não existe."
    echo "Verifica se o Project ID está correcto: $PROJECT_ID"
    exit 1
fi

# --- Paths ---
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSHOP_LINK="$HOME/workshop"

echo ""
echo "  Workspace: $REPO_DIR"
echo "  Symlink:   $WORKSHOP_LINK → $REPO_DIR"
echo ""

# --- Criar symlink ~/workshop → repo ---
if [ -L "$WORKSHOP_LINK" ]; then
    echo "  A substituir symlink ~/workshop existente..."
    rm "$WORKSHOP_LINK"
elif [ -e "$WORKSHOP_LINK" ]; then
    echo "Erro: '$WORKSHOP_LINK' já existe e não é um symlink."
    echo "Remove manualmente e volta a correr setup.sh."
    exit 1
fi
ln -s "$REPO_DIR" "$WORKSHOP_LINK"
echo "  OK — ~/workshop criado"

# --- Guardar .config ---
CONFIG_FILE="$REPO_DIR/.config"
cat > "$CONFIG_FILE" << EOF
USERNAME=$USERNAME
PROJECT_ID=$PROJECT_ID
EOF
echo "  OK — .config guardado"

# --- Permissões ---
chmod +x "$REPO_DIR/new_project.sh"
echo "  OK — new_project.sh executável"

echo ""
echo "============================================="
echo "  Setup completo!"
echo "============================================="
echo ""
echo "  ~/workshop  →  $REPO_DIR"
echo ""
echo "Próximos passos — criar um projecto:"
echo "  cd ~/workshop"
echo "  git checkout -b nome_projecto"
echo "  ./new_project.sh nome_projecto ml"
echo "  ./new_project.sh nome_projecto simulation"
echo ""
