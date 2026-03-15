#!/usr/bin/env python3
"""
Script de treino — Projeto: PROJECT_NAME
Gerado automaticamente pelo new_project.sh
Edita as secções marcadas com TODO conforme o teu projeto.
"""

import sys
import os

# Adicionar scripts ao path
sys.path.append('WORKSPACE_PATH/scripts')
from utils import get_paths, save_model, log_metrics, print_project_info

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report

# =============================================================
# CONFIGURAÇÃO
# =============================================================

PROJECT_NAME = "PROJECT_NAME"
paths = get_paths(PROJECT_NAME)

# TODO: ajustar conforme os teus dados
DATA_FILE    = paths['data'] / 'data.csv'
TEST_SIZE    = 0.2
RANDOM_STATE = 42

# TODO: ajustar hiperparâmetros do modelo
MODEL_PARAMS = {
    'n_estimators': 100,
    'max_depth':    10,
    'random_state': RANDOM_STATE,
    'n_jobs':       -1,   # usa todos os CPUs disponíveis
}


# =============================================================
# FUNÇÕES
# =============================================================

def load_data():
    """
    Carrega dados do CSV.
    TODO: adaptar se os teus dados tiverem estrutura diferente.
    Assume que a última coluna é o label (y) e o resto são features (X).
    """
    print(f"A carregar dados de: {DATA_FILE}")

    if not DATA_FILE.exists():
        raise FileNotFoundError(
            f"Ficheiro não encontrado: {DATA_FILE}\n"
            f"Envia os dados com:\n"
            f"  scp dados.csv deucalion:{paths['data']}/"
        )

    df = pd.read_csv(DATA_FILE)
    print(f"Dados carregados: {df.shape[0]} amostras, {df.shape[1]} colunas")

    # TODO: adaptar se a estrutura for diferente
    X = df.iloc[:, :-1].values
    y = df.iloc[:, -1].values

    return X, y


def train(X_train, y_train):
    """
    Treina o modelo.
    TODO: substituir RandomForest pelo modelo que precisas.
    """
    print("A treinar modelo...")
    model = RandomForestClassifier(**MODEL_PARAMS)
    model.fit(X_train, y_train)
    return model


def evaluate(model, X_test, y_test):
    """Avalia o modelo e imprime métricas"""
    preds    = model.predict(X_test)
    accuracy = accuracy_score(y_test, preds)
    report   = classification_report(y_test, preds)

    print(f"\nAccuracy: {accuracy:.4f}")
    print("Classification Report:")
    print(report)

    return {'accuracy': float(accuracy), 'report': report}


# =============================================================
# MAIN
# =============================================================

def main():
    print_project_info(PROJECT_NAME)

    # 1. Carregar dados
    X, y = load_data()

    # 2. Dividir em treino/teste
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=TEST_SIZE, random_state=RANDOM_STATE
    )
    print(f"Treino: {X_train.shape[0]} amostras | Teste: {X_test.shape[0]} amostras")

    # 3. Normalizar
    scaler  = StandardScaler()
    X_train = scaler.fit_transform(X_train)
    X_test  = scaler.transform(X_test)

    # 4. Treinar
    model = train(X_train, y_train)

    # 5. Avaliar
    metrics = evaluate(model, X_test, y_test)

    # 6. Guardar modelo (com scaler incluído)
    save_model({'model': model, 'scaler': scaler}, PROJECT_NAME)

    # 7. Guardar métricas
    log_metrics(metrics, PROJECT_NAME)

    print("\nTreino completo!")


if __name__ == "__main__":
    main()
