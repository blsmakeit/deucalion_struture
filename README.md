# Deucalion Workshop — Estrutura Base

Templates e scripts para usar o supercomputador Deucalion (HPC)
de forma autónoma. Desenvolvido pela equipa MakeIT.

Este repositório é a **estrutura mãe** — a `main` nunca se altera
após o setup inicial. Cada projeto tem a sua própria branch.

---

## Como funciona
```
git clone → bash setup.sh → git checkout -b projeto
→ ./new_project.sh → trabalhar → git push origin projeto
```

- `main` — estrutura base, templates, utils
- `nome_projeto` — uma branch por projeto

---

## Estrutura do Repo
```
deucalion-workshop/
├── setup.sh              # Configuração inicial (1x por utilizador)
├── new_project.sh        # Criar novo projeto
├── scripts/
│   └── utils.py          # Funções utilitárias partilhadas
├── templates/
│   ├── ml/               # Templates para treino/inferência
│   │   ├── train_template.py
│   │   ├── infer_template.py
│   │   ├── job_train_cpu.sh
│   │   ├── job_train_gpu.sh
│   │   └── requirements.txt
│   └── simulation/       # Templates para simulações
│       ├── sim_template.py
│       ├── job_sim_cpu.sh
│       └── requirements.txt
└── projects/             # Criado automaticamente por new_project.sh
    └── nome_projeto/     # Uma pasta por projeto
        ├── README.md
        ├── .gitignore
        ├── scripts/
        ├── jobs/
        ├── datasets/     # Não vai para GitHub
        ├── models/       # Não vai para GitHub
        ├── logs/         # Não vai para GitHub
        ├── results/      # Não vai para GitHub
        └── venvs/        # Não vai para GitHub
```

---

## Setup Inicial (fazer uma vez por utilizador)
```bash
# No Deucalion
ssh deucalion

git clone https://github.com/blsmakeit/deucalion_struture.git \
    /projects/F202500001INOVIAMAKEITTECH/SEU_USERNAME/deucalion-workshop

cd /projects/F202500001INOVIAMAKEITTECH/SEU_USERNAME/deucalion-workshop
chmod +x setup.sh new_project.sh
bash setup.sh
```

---

## Criar um Projeto
```bash
# No Deucalion — dentro do repo
cd /projects/F202500001INOVIAMAKEITTECH/SEU_USERNAME/deucalion-workshop

# 1. Criar branch com o nome do projeto
git checkout -b nome_projeto

# 2. Criar estrutura do projeto
./new_project.sh nome_projeto ml          # treino de modelos
./new_project.sh nome_projeto simulation  # simulações

# 3. Push para GitHub
git add projects/nome_projeto/
git commit -m "projeto: nome_projeto"
git push origin nome_projeto
```

---

## Workflow de um Projeto ML
```bash
# 1. No PC/WSL — enviar dados
scp dados.csv deucalion:.../projects/nome_projeto/datasets/

# 2. No Deucalion — submeter job
sbatch .../projects/nome_projeto/jobs/train_cpu.sh
sbatch .../projects/nome_projeto/jobs/train_gpu.sh

# 3. No Deucalion — monitorizar
squeue -u $USER
tail -f .../projects/nome_projeto/logs/*.out

# 4. No PC/WSL — descarregar modelo
scp -r deucalion:.../projects/nome_projeto/models/ ./
```

## Workflow de um Projeto de Simulação
```bash
# 1. No Deucalion — editar parâmetros
nano .../projects/nome_projeto/scripts/sim.py

# 2. Submeter job
sbatch .../projects/nome_projeto/jobs/sim_cpu.sh

# 3. No PC/WSL — descarregar resultados
scp -r deucalion:.../projects/nome_projeto/results/ ./
```

---

## O que vai para o GitHub

| Ficheiro | GitHub | Porquê |
|---|---|---|
| `scripts/*.py` | ✅ | Código do projeto |
| `jobs/*.sh` | ✅ | Configuração SLURM |
| `README.md` | ✅ | Documentação |
| `datasets/` | ❌ | Dados — demasiado grande |
| `models/` | ❌ | Modelos — demasiado grande |
| `logs/` | ❌ | Logs — não relevante |
| `results/` | ⚠️ | Só se forem pequenos |
| `venvs/` | ❌ | Gerado automaticamente |

---

## Recursos

- Documentação Deucalion: https://docs.macc.fccn.pt
- Portal: https://portal.deucalion.macc.fccn.pt
- Suporte: deucalion@support.macc.fccn.pt
- Projeto: F202500001INOVIAMAKEITTECH