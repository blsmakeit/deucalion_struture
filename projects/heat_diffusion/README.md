# heat_diffusion

Tipo: simulation
Criado: 2026-03-16
Utilizador: brunosousa

## Descrição
TODO: descrever o projeto

## Estrutura
```
heat_diffusion/
├── scripts/     <- código do projeto
├── jobs/        <- job scripts SLURM
├── datasets/    <- dados (não vai para GitHub)
├── models/      <- modelos treinados (não vai para GitHub)
├── logs/        <- logs SLURM (não vai para GitHub)
└── results/     <- resultados (não vai para GitHub)
```

## Como correr

### Enviar dados (do PC/WSL)
```bash
scp dados.csv deucalion:/projects/F202500001INOVIAMAKEITTECH/brunosousa/deucalion-workshop/projects/heat_diffusion/datasets/
```

### Submeter job (no Deucalion)
```bash
sbatch /projects/F202500001INOVIAMAKEITTECH/brunosousa/deucalion-workshop/projects/heat_diffusion/jobs/sim_cpu.sh
```

### Descarregar resultados (do PC/WSL)
```bash
scp -r deucalion:/projects/F202500001INOVIAMAKEITTECH/brunosousa/deucalion-workshop/projects/heat_diffusion/results/ ./
```
