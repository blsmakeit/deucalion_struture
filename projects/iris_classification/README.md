# Iris Classification

**Tipo:** Machine Learning — Classificação  
**Branch:** iris_classification  
**Criado:** 2026-03-15  
**Autor:** brunosousa  

---

## Descrição

Classificação de espécies de flores do dataset Iris usando Random Forest.
Projeto de demonstração para o workshop HPC Deucalion.

O dataset Iris é um dos mais conhecidos em ML — contém 150 amostras
de 3 espécies de flores (setosa, versicolor, virginica) com 4 features
cada (comprimento e largura de sépalas e pétalas).

---

## Dataset

- **Fonte:** sklearn built-in (`sklearn.datasets.load_iris`)
- **Amostras:** 150
- **Features:** 4 (sepal length, sepal width, petal length, petal width)
- **Classes:** setosa, versicolor, virginica
- **Não precisa de dados externos** — incluído no sklearn

---

## Modelo

- **Algoritmo:** Random Forest Classifier
- **Parâmetros:** n_estimators=100, max_depth=5
- **Split:** 80% treino / 20% teste

---

## Resultados

| Métrica | Valor |
|---|---|
| Accuracy | 100% |
| Precision | 1.00 |
| Recall | 1.00 |
| F1-score | 1.00 |

---

## Estrutura
```
iris_classification/
├── README.md
├── scripts/
│   ├── train.py     <- script de treino
│   └── infer.py     <- script de inferência
├── jobs/
│   ├── train_cpu.sh <- job SLURM CPU
│   └── train_gpu.sh <- job SLURM GPU
├── datasets/        <- não vai para GitHub
├── models/          <- não vai para GitHub
├── logs/            <- não vai para GitHub
├── results/         <- não vai para GitHub
└── venvs/           <- não vai para GitHub
```

---

## Como Correr

### Treino (no Deucalion)
```bash
# CPU
sbatch jobs/train_cpu.sh

# GPU
sbatch jobs/train_gpu.sh
```

### Monitorizar
```bash
squeue -u $USER
tail -f logs/*.out
```

### Descarregar modelo (no PC/WSL)
```bash
scp -r deucalion:.../projects/iris_classification/models/ ./
```

---

## Packages
```
pandas
numpy
scikit-learn
matplotlib
seaborn
joblib
```
