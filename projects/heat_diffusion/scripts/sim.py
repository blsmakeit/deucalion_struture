#!/usr/bin/env python3
"""
Script de simulação — Projeto: heat_diffusion
Gerado automaticamente pelo new_project.sh

Exemplo incluído: simulação de difusão de calor (equação do calor 1D)
É um exemplo simples e real de simulação numérica que demonstra
o poder do HPC — pode ser substituído pela simulação real do projeto.

Edita as secções marcadas com TODO conforme o teu projeto.
"""

import sys
import os

sys.path.append('/projects/F202500001INOVIAMAKEITTECH/brunosousa/deucalion-workshop/projects/heat_diffusion/scripts')
from utils import get_paths, save_results, print_project_info

import numpy as np
import json
from datetime import datetime

# =============================================================
# CONFIGURAÇÃO
# TODO: ajustar os parâmetros conforme a tua simulação
# =============================================================

heat_diffusion = "heat_diffusion"
paths = get_paths(heat_diffusion)

# Parâmetros da simulação (equação do calor 1D)
PARAMS = {
    # Domínio espacial
    'L':       1.0,      # comprimento do domínio (metros)
    'nx':      200,      # número de pontos espaciais

    # Tempo
    't_max':   0.5,      # tempo total de simulação (segundos)
    'dt':      0.0001,   # passo de tempo

    # Propriedades do material
    'alpha':   0.01,     # difusividade térmica (m²/s)

    # Condições iniciais
    'T_init':  20.0,     # temperatura inicial (°C)
    'T_left':  100.0,    # temperatura na fronteira esquerda (°C)
    'T_right': 20.0,     # temperatura na fronteira direita (°C)
}


# =============================================================
# SIMULAÇÃO
# TODO: substituir por implementar a tua simulação aqui
# =============================================================

def run_simulation(params):
    """
    Simula a difusão de calor em 1D usando diferenças finitas.

    Equação do calor: dT/dt = alpha * d²T/dx²

    Este é um exemplo clássico de simulação numérica — substitui
    pelo teu solver quando tiveres o código real.
    """
    print("A inicializar simulação...")
    print(f"Parâmetros: {json.dumps(params, indent=2)}")

    # Extrair parâmetros
    L       = params['L']
    nx      = params['nx']
    t_max   = params['t_max']
    dt      = params['dt']
    alpha   = params['alpha']
    T_init  = params['T_init']
    T_left  = params['T_left']
    T_right = params['T_right']

    # Setup espacial
    dx = L / (nx - 1)
    x  = np.linspace(0, L, nx)

    # Verificar estabilidade (critério CFL)
    r = alpha * dt / dx**2
    if r > 0.5:
        raise ValueError(
            f"Simulação instável! r = {r:.4f} > 0.5\n"
            f"Reduz dt ou aumenta nx."
        )
    print(f"Número de Fourier r = {r:.4f} (estável se < 0.5) ✓")

    # Condição inicial
    T = np.full(nx, T_init)
    T[0]  = T_left
    T[-1] = T_right

    # Número de passos de tempo
    nt = int(t_max / dt)
    print(f"\nInício da simulação:")
    print(f"  Pontos espaciais: {nx}")
    print(f"  Passos de tempo:  {nt}")
    print(f"  Tempo total:      {t_max}s")
    print("")

    # Guardar estados em instantes específicos
    save_times   = [0, 0.1, 0.25, 0.5]
    saved_states = {}
    T_new        = T.copy()

    start_time = datetime.now()

    for step in range(nt):
        # Diferenças finitas — equação do calor
        T_new[1:-1] = T[1:-1] + r * (T[2:] - 2*T[1:-1] + T[:-2])

        # Condições de fronteira
        T_new[0]  = T_left
        T_new[-1] = T_right
        T = T_new.copy()

        # Guardar estado em instantes específicos
        t_current = (step + 1) * dt
        for t_save in save_times:
            if abs(t_current - t_save) < dt / 2:
                saved_states[f"t={t_save:.2f}s"] = T.tolist()

        # Progress report
        if step % (nt // 10) == 0:
            progress = (step / nt) * 100
            t_elapsed = (datetime.now() - start_time).seconds
            print(f"  {progress:5.1f}% — t = {t_current:.4f}s — "
                  f"T_max = {T.max():.2f}°C — elapsed: {t_elapsed}s")

    elapsed = (datetime.now() - start_time).total_seconds()
    print(f"\nSimulação completa em {elapsed:.2f}s")

    return {
        'x':            x.tolist(),
        'params':       params,
        'final_state':  T.tolist(),
        'saved_states': saved_states,
        'elapsed_s':    elapsed,
        'n_steps':      nt,
        'stability_r':  r,
    }


# =============================================================
# MAIN
# =============================================================

def main():
    print_project_info(heat_diffusion)

    # 1. Correr simulação
    results = run_simulation(PARAMS)

    # 2. Guardar resultados
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    filename  = f"simulation_{timestamp}.json"
    save_results(results, heat_diffusion, filename=filename)

    # 3. Resumo
    T_final = np.array(results['final_state'])
    print(f"\nResultados finais:")
    print(f"  T_min = {T_final.min():.2f}°C")
    print(f"  T_max = {T_final.max():.2f}°C")
    print(f"  T_med = {T_final.mean():.2f}°C")
    print(f"\nFicheiro de resultados: {filename}")
    print(f"\nPara descarregar (do teu PC/WSL):")
    print(f"  scp -r deucalion:{paths['results']}/ ./resultados_{heat_diffusion}/")


if __name__ == "__main__":
    main()
