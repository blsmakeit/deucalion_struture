# Deucalion Workshop

Templates e scripts para usar o supercomputador Deucalion (HPC) de forma autónoma.
Desenvolvido pela equipa MakeIT.

## Estrutura do Repo

```
deucalion-workshop/
├── setup.sh              # Configuração inicial (correr UMA VEZ no Deucalion)
├── new_project.sh        # Criar novo projeto (ml ou simulation)
├── scripts/
│   └── utils.py          # Funções utilitárias partilhadas
└── templates/
    ├── ml/               # Templates para treino/inferência de modelos
    │   ├── train_template.py
    │   ├── infer_template.py
    │   ├── job_train_cpu.sh
    │   ├── job_train_gpu.sh
    │   └── requirements.txt
    └── simulation/       # Templates para simulações numéricas
        ├── sim_template.py
        ├── job_sim_cpu.sh
        └── requirements.txt
```

## Workflow Completo

### 1. No Deucalion — Setup inicial (só uma vez)

```bash
ssh deucalion
git clone https://github.com/REPO_URL/deucalion-workshop.git ~/deucalion-workshop
cd ~/deucalion-workshop
bash setup.sh
```

### 2. No Deucalion — Criar projeto

```bash
cd ~/ml
./new_project.sh cancer_detection ml          # projeto de ML
./new_project.sh fluid_dynamics simulation    # projeto de simulação
```

### 3. No teu PC/WSL — Enviar dados

```bash
scp dados.csv deucalion:~/ml/datasets/cancer_detection/
```

### 4. No Deucalion — Submeter job

```bash
sbatch ~/ml/jobs/cancer_detection_train_cpu.sh
# ou GPU:
sbatch ~/ml/jobs/cancer_detection_train_gpu.sh
```

### 5. Monitorizar

```bash
squeue -u $USER
tail -f ~/ml/logs/cancer_detection/*.out
```

### 6. No teu PC/WSL — Descarregar resultados

```bash
scp -r deucalion:~/ml/models/cancer_detection/ ./
```

## Recursos Úteis

- Documentação Deucalion: https://docs.macc.fccn.pt
- Portal de gestão: https://portal.deucalion.macc.fccn.pt
- Suporte MACC: deucalion@support.macc.fccn.pt
