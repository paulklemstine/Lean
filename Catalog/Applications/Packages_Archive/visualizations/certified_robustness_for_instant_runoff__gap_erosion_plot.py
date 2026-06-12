#!/usr/bin/env python3
"""Visualization: Gap Erosion Under Perturbation"""
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np

    gamma = 3.0
    eps_vals = np.linspace(0, 2.0, 200)
    residual = gamma - 2 * eps_vals

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.plot(eps_vals, residual, 'b-', linewidth=2, label=r'Residual gap $\gamma - 2\varepsilon$')
    ax.axhline(y=0, color='r', linestyle='--', linewidth=1, label='Stability threshold')
    ax.axvline(x=gamma/2, color='orange', linestyle=':', linewidth=1.5, label=rf'Critical $\varepsilon = \gamma/2 = {gamma/2}$')
    ax.fill_between(eps_vals, residual, 0, where=residual > 0, alpha=0.15, color='green', label='Stable region')
    ax.fill_between(eps_vals, residual, 0, where=residual <= 0, alpha=0.15, color='red', label='Unstable region')

    ax.set_xlabel(r'Perturbation $\varepsilon$', fontsize=13)
    ax.set_ylabel('Residual gap', fontsize=13)
    ax.set_title(rf'Gap Erosion: $\gamma = {gamma}$', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('gap_erosion.png', dpi=150)
    print('Saved gap_erosion.png')
except ImportError:
    print('matplotlib not available; skipping visualization')
