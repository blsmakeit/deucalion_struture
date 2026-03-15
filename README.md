# Deucalion Workshop — Estrutura Base

Templates e scripts para usar o supercomputador Deucalion (HPC) 
de forma autónoma. Desenvolvido pela equipa MakeIT.

Este repositório é a **estrutura main** — não se fazem alterações 
diretas aqui após o setup inicial. Cada projeto cria a sua própria 
branch com apenas o necessário.

---

## Como funciona
```
Este repo (estrutura mãe)
    ↓ git clone (uma vez, no Deucalion)
    ↓ bash setup.sh (uma vez, por utilizador)
    ↓ ./new_project.sh <nome> <tipo>
Projeto criado localmente no Deucalion
    ↓ git checkout -b nome_projeto
    ↓ adicionar só o necessário (scripts, job, README)
    ↓ git push origin nome_projeto
Branch do projeto no GitHub
```

---

## Estrutura do Repo
```
deucalion-workshop/
├── setup.sh              # Configuração inicial (1x por utilizador)
├── new_project.sh        # Criar novo projeto
├── scripts/
│   └── utils.py          # Funções utilitárias partilhadas
└── templates/
    ├── ml/               # Templates para treino/inferência
    │   ├── train_template.py
    │   ├── infer_template.py
    │   ├── job_train_cpu.sh
    │   ├── job_train_gpu.sh
    │   └── requirements.txt
    └── simulation/       # Templates para simulações
        ├── sim_template.py
        ├── job_sim_cpu.sh
        └── requirements.txt
```

---

## Setup Inicial (fazer uma vez por utilizador)

### 1. No Deucalion
```bash
ssh deucalion

git clone https://github.com/blsmakeit/deucalion_struture.git \
    /projects/F202500001INOVIAMAKEITTECH/SEU_USERNAME/deucalion-workshop

cd /projects/F202500001INOVIAMAKEITTECH/SEU_USERNAME/deucalion-workshop
bash setup.sh
```

Quando pedir:
- **Username:** o teu username do Deucalion (ex: joao.silva)
- **Project ID:** F202500001INOVIAMAKEITTECH

Após o setup tens:
- `~/workshop` → symlink para o teu workspace em /projects
- `~/workshop/new_project.sh` → para criar novos projetos

---

## Criar um Projeto
```bash
# No Deucalion
cd ~/workshop

# Projeto de ML (treino/inferência)
./new_project.sh nome_projeto ml

# Projeto de simulação
./new_project.sh nome_projeto simulation
```

O comando cria automaticamente:
- Pastas: `datasets/`, `models/`, `logs/`, `results/`
- Venv próprio com packages instalados
- Scripts e jobs prontos a usar

---

## Workflow de um Projeto

### Treino de modelo
```bash
# 1. No PC/WSL — enviar dados
scp dados.csv deucalion:~/workshop/datasets/nome_projeto/

# 2. No Deucalion — submeter job
sbatch ~/workshop/jobs/nome_projeto_train_cpu.sh
# ou GPU:
sbatch ~/workshop/jobs/nome_projeto_train_gpu.sh

# 3. No Deucalion — monitorizar
squeue -u $USER
tail -f ~/workshop/logs/nome_projeto/*.out

# 4. No PC/WSL — descarregar modelo
scp -r deucalion:~/workshop/models/nome_projeto/ ./
```

### Simulação
```bash
# 1. No Deucalion — editar parâmetros
nano ~/workshop/scripts/nome_projeto_sim.py

# 2. No Deucalion — submeter job
sbatch ~/workshop/jobs/nome_projeto_sim.sh

# 3. No PC/WSL — descarregar resultados
scp -r deucalion:~/workshop/results/nome_projeto/ ./
```

---

## Guardar o Projeto no GitHub

Só o necessário vai para o GitHub — **nunca** dados, modelos ou logs.
```bash
# No Deucalion — criar branch para o projeto
cd /projects/F202500001INOVIAMAKEITTECH/SEU_USERNAME/deucalion-workshop
git checkout -b nome_projeto

# Copiar só os ficheiros do projeto
cp ~/workshop/scripts/nome_projeto_*.py scripts/
cp ~/workshop/jobs/nome_projeto_*.sh templates/

# Criar README do projeto
nano README_nome_projeto.md

# Commit e push
git add scripts/nome_projeto_*.py
git add templates/nome_projeto_*.sh  
git add README_nome_projeto.md
git commit -m "projeto: nome_projeto — descrição breve"
git push origin nome_projeto
```

### O que vai para o GitHub ✅

| Ficheiro | Vai? | Porquê |
|---|---|---|
| Scripts Python | ✅ | Código do projeto |
| Job scripts .sh | ✅ | Configuração do job |
| README do projeto | ✅ | Documentação |
| requirements.txt | ✅ | Dependências |
| datasets/ | ❌ | Demasiado grande |
| models/ | ❌ | Demasiado grande |
| logs/ | ❌ | Não relevante |
| results/ | ⚠️ | Só se forem pequenos |
| venvs/ | ❌ | Gerado automaticamente |

---

## Recursos

- Documentação Deucalion: https://docs.macc.fccn.pt
- Portal: https://portal.deucalion.macc.fccn.pt  
- Suporte: deucalion@support.macc.fccn.pt
- Projeto: F202500001INOVIAMAKEITTECH