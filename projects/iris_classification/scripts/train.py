#!/usr/bin/env python3
"""
Projeto: iris_classification
Treino de classificação com o dataset Iris (sklearn built-in)
Não precisa de dados externos — dataset incluído no sklearn
"""

import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', '..', 'scripts'))
from utils import get_paths, save_model, log_metrics, print_project_info

from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report

# =============================================================
PROJECT_NAME = "iris_classification"
PROJECT_DIR  = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

RANDOM_STATE = 42
TEST_SIZE    = 0.2
MODEL_PARAMS = {
    'n_estimators': 100,
    'max_depth':    5,
    'random_state': RANDOM_STATE,
    'n_jobs':       -1,
}
# =============================================================

def get_project_paths():
    return {
        'models':  os.path.join(PROJECT_DIR, 'models'),
        'logs':    os.path.join(PROJECT_DIR, 'logs'),
        'results': os.path.join(PROJECT_DIR, 'results'),
    }

def main():
    paths = get_project_paths()

    print("=============================================")
    print(f"  Projeto: {PROJECT_NAME}")
    print(f"  Localização: {PROJECT_DIR}")
    print("=============================================")

    # 1. Carregar dataset built-in
    print("\nA carregar dataset Iris...")
    iris        = load_iris()
    X, y        = iris.data, iris.target
    class_names = list(iris.target_names)
    print(f"Dataset: {X.shape[0]} amostras, {X.shape[1]} features")
    print(f"Classes: {class_names}")

    # 2. Dividir
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=TEST_SIZE, random_state=RANDOM_STATE
    )
    print(f"Treino: {len(X_train)} | Teste: {len(X_test)}")

    # 3. Normalizar
    scaler  = StandardScaler()
    X_train = scaler.fit_transform(X_train)
    X_test  = scaler.transform(X_test)

    # 4. Treinar
    print("\nA treinar modelo...")
    model = RandomForestClassifier(**MODEL_PARAMS)
    model.fit(X_train, y_train)

    # 5. Avaliar
    preds    = model.predict(X_test)
    accuracy = accuracy_score(y_test, preds)
    report   = classification_report(y_test, preds, target_names=class_names)
    print(f"\nAccuracy: {accuracy:.4f}")
    print(report)

    # 6. Guardar modelo
    import pickle, datetime
    os.makedirs(paths['models'], exist_ok=True)
    timestamp  = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
    model_path = os.path.join(paths['models'], f"model_{timestamp}.pkl")
    with open(model_path, 'wb') as f:
        pickle.dump({'model': model, 'scaler': scaler, 'classes': class_names}, f)
    print(f"\nModelo guardado: {model_path}")

    # 7. Guardar métricas
    import json
    os.makedirs(paths['logs'], exist_ok=True)
    metrics_path = os.path.join(paths['logs'], f"metrics_{timestamp}.json")
    with open(metrics_path, 'w') as f:
        json.dump({'accuracy': float(accuracy), 'report': report}, f, indent=2)
    print(f"Métricas guardadas: {metrics_path}")

    print("\nTreino completo!")

if __name__ == "__main__":
    main()
