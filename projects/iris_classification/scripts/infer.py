#!/usr/bin/env python3
"""
Script de inferência — Projeto: iris_classification
Gerado automaticamente pelo new_project.sh
Edita as secções marcadas com TODO conforme o teu projeto.
"""

import sys
import os

sys.path.append('/projects/F202500001INOVIAMAKEITTECH/brunosousa/deucalion-workshop/projects/iris_classification/scripts')
from utils import get_paths, load_model, save_results, print_project_info

import pandas as pd
import numpy as np

# =============================================================
# CONFIGURAÇÃO
# =============================================================

iris_classification = "iris_classification"
paths = get_paths(iris_classification)

# TODO: ficheiro com os dados para inferência
INFER_FILE = paths['data'] / 'infer.csv'


# =============================================================
# FUNÇÕES
# =============================================================

def load_infer_data():
    """
    Carrega dados para inferência.
    TODO: adaptar se os teus dados tiverem estrutura diferente.
    """
    print(f"A carregar dados de inferência de: {INFER_FILE}")

    if not INFER_FILE.exists():
        raise FileNotFoundError(
            f"Ficheiro não encontrado: {INFER_FILE}\n"
            f"Envia com:\n"
            f"  scp infer.csv deucalion:{paths['data']}/"
        )

    df = pd.read_csv(INFER_FILE)
    print(f"Dados carregados: {df.shape[0]} amostras")
    return df


def run_inference(df):
    """Corre inferência com o modelo treinado"""
    # Carregar modelo mais recente
    model_bundle = load_model(iris_classification)
    model  = model_bundle['model']
    scaler = model_bundle['scaler']

    # Preparar dados
    # TODO: adaptar se os teus dados tiverem estrutura diferente
    X = df.values
    X = scaler.transform(X)

    # Inferência
    predictions  = model.predict(X)
    probabilities = None

    if hasattr(model, 'predict_proba'):
        probabilities = model.predict_proba(X).tolist()

    return predictions, probabilities


# =============================================================
# MAIN
# =============================================================

def main():
    print_project_info(iris_classification)

    # 1. Carregar dados
    df = load_infer_data()

    # 2. Correr inferência
    predictions, probabilities = run_inference(df)

    print(f"\nInferência completa: {len(predictions)} amostras processadas")
    print(f"Distribuição: {dict(zip(*np.unique(predictions, return_counts=True)))}")

    # 3. Guardar resultados
    results = {
        'n_samples':     len(predictions),
        'predictions':   predictions.tolist(),
        'probabilities': probabilities,
    }
    save_results(results, iris_classification)

    print("\nInferência completa!")


if __name__ == "__main__":
    main()
