"""
utils.py — Funções utilitárias partilhadas por todos os projetos
Não editar diretamente — é copiado pelo setup.sh para o workspace
"""

import os
import pickle
import json
import numpy as np
from datetime import datetime
from pathlib import Path


# =============================================================
# PATHS
# =============================================================

def get_workspace() -> Path:
    """
    Retorna o caminho base do workspace — dinâmico para qualquer utilizador.
    Prioridade:
      1. Symlink ~/workshop (criado pelo setup.sh)
      2. Variável de ambiente DEUCALION_WORKSPACE
      3. Construção automática a partir de $USER
    """
    # 1. Symlink ~/workshop
    workshop_link = Path.home() / 'workshop'
    if workshop_link.is_symlink() and workshop_link.exists():
        return workshop_link.resolve()

    # 2. Variável de ambiente
    ws = os.environ.get('DEUCALION_WORKSPACE')
    if ws and Path(ws).exists():
        return Path(ws)

    # 3. Construção automática
    user = os.environ.get('USER') or os.environ.get('LOGNAME')
    if not user:
        raise RuntimeError("Não foi possível determinar o username ($USER não definido)")

    projects_base = Path('/projects')
    if projects_base.exists():
        for proj_dir in projects_base.iterdir():
            candidate = proj_dir / user / 'deucalion-workshop'
            if candidate.exists():
                return candidate

    raise RuntimeError(
        f"Workspace não encontrado para '{user}'.\n"
        "Corre setup.sh primeiro ou define a variável DEUCALION_WORKSPACE."
    )


def get_paths(project_name: str) -> dict:
    """Retorna os caminhos padrão para um projeto específico"""
    base = get_workspace()
    return {
        'data':    base / 'datasets' / project_name,
        'models':  base / 'models'   / project_name,
        'logs':    base / 'logs'     / project_name,
        'results': base / 'results'  / project_name,
        'scripts': base / 'scripts',
        'venv':    base / 'venvs'    / project_name,
    }


# =============================================================
# GUARDAR / CARREGAR MODELOS
# =============================================================

def save_model(model, project_name: str, suffix: str = '') -> Path:
    """Guarda modelo treinado com timestamp"""
    paths = get_paths(project_name)
    paths['models'].mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    name = f"{project_name}_model_{timestamp}"
    if suffix:
        name += f"_{suffix}"
    name += ".pkl"

    filepath = paths['models'] / name
    with open(filepath, 'wb') as f:
        pickle.dump(model, f)

    print(f"Modelo guardado: {filepath}")
    return filepath


def load_model(project_name: str, filename: str = None) -> object:
    """
    Carrega modelo treinado.
    Se filename=None, carrega o modelo mais recente do projeto.
    """
    paths = get_paths(project_name)
    models_dir = paths['models']

    if filename:
        filepath = models_dir / filename
    else:
        # Carregar o mais recente
        models = sorted(models_dir.glob("*.pkl"))
        if not models:
            raise FileNotFoundError(f"Nenhum modelo encontrado em {models_dir}")
        filepath = models[-1]
        print(f"A carregar modelo mais recente: {filepath.name}")

    with open(filepath, 'rb') as f:
        model = pickle.load(f)

    print(f"Modelo carregado: {filepath}")
    return model


# =============================================================
# MÉTRICAS E RESULTADOS
# =============================================================

def _to_json_serializable(obj):
    """Converte tipos numpy para tipos Python nativos (JSON serializable)"""
    if isinstance(obj, np.integer):
        return int(obj)
    if isinstance(obj, np.floating):
        return float(obj)
    if isinstance(obj, np.ndarray):
        return obj.tolist()
    if isinstance(obj, dict):
        return {k: _to_json_serializable(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [_to_json_serializable(i) for i in obj]
    return obj


def log_metrics(metrics: dict, project_name: str, suffix: str = '') -> Path:
    """Guarda métricas de treino em JSON"""
    paths = get_paths(project_name)
    paths['logs'].mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    name = f"metrics_{timestamp}"
    if suffix:
        name += f"_{suffix}"
    name += ".json"

    filepath = paths['logs'] / name
    clean = _to_json_serializable(metrics)

    with open(filepath, 'w') as f:
        json.dump(clean, f, indent=2)

    print(f"Métricas guardadas: {filepath}")
    return filepath


def save_results(results, project_name: str, filename: str = None) -> Path:
    """Guarda resultados de inferência ou simulação"""
    paths = get_paths(project_name)
    paths['results'].mkdir(parents=True, exist_ok=True)

    if filename is None:
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f"results_{timestamp}.json"

    filepath = paths['results'] / filename
    clean = _to_json_serializable(results)

    with open(filepath, 'w') as f:
        json.dump(clean, f, indent=2)

    print(f"Resultados guardados: {filepath}")
    return filepath


# =============================================================
# UTILITÁRIOS
# =============================================================

def print_project_info(project_name: str):
    """Imprime informação sobre o projeto e os caminhos"""
    paths = get_paths(project_name)
    print(f"\n{'='*50}")
    print(f"  Projeto: {project_name}")
    print(f"{'='*50}")
    for key, path in paths.items():
        exists = "OK" if path.exists() else "NAO EXISTE"
        print(f"  {key:<10} {path}  [{exists}]")
    print(f"{'='*50}\n")
