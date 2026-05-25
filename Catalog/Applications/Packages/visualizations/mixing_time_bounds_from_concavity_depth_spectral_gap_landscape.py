#!/usr/bin/env python3
"""
Visualization 1: Spectral Gap Landscape

Plots the rescaled spectral gap γ · n^{2/k} as a function of n
for different concavity depths k = 1, 2, 3, using discrete Gaussian
distributions. Shows how deeper concavity changes the scaling behavior.
"""

import numpy as np
import matplotlib.pyplot as plt
from algorithms import (
    discrete_gaussian, metropolis_birth_death, spectral_gap_dense,
    rescaled_spectral_gap, verify_klc
)

fig, axes = plt.subplots(1, 3, figsize=(15, 5), sharey=False)

ns = list(range(5, 61, 5))
a_values = [0.01, 0.05, 0.1, 0.2]
colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']

for idx, k in enumerate([1, 2, 3]):
    ax = axes[idx]

    for a_idx, a in enumerate(a_values):
        gaps = []
        valid_ns = []
        for n in ns:
            pi = discrete_gaussian(n, a=a)
            is_klc, _ = verify_klc(pi, k)
            if is_klc:
                P = metropolis_birth_death(pi)
                gap = spectral_gap_dense(P)
                rg = rescaled_spectral_gap(gap, n, k)
                gaps.append(rg)
                valid_ns.append(n)

        if valid_ns:
            ax.plot(valid_ns, gaps, 'o-', color=colors[a_idx],
                    label=f'a={a}', markersize=4, linewidth=1.5)

    ax.set_title(f'k = {k}  (exponent 2/k = {2/k:.2f})', fontsize=13)
    ax.set_xlabel('State space size n', fontsize=11)
    ax.set_ylabel(f'γ · n^{{2/{k}}}', fontsize=11)
    ax.legend(title='Gaussian param a', fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=0)

plt.suptitle('Rescaled Spectral Gap vs. State Space Size\n'
             'Concavity Depth Mixing Conjecture Test',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('spectral_landscape.png', dpi=150, bbox_inches='tight')
print("Saved spectral_landscape.png")
