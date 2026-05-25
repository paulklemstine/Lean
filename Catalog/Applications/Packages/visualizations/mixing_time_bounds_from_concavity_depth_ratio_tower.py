#!/usr/bin/env python3
"""
Visualization 2: Ratio Tower

Visualizes the iterated ratio sequences of a k-fold log-concave distribution,
showing the tower of concavity constraints. Each level shows the ratio
sequence becoming smoother, illustrating how deeper concavity regularizes
the distribution.
"""

import numpy as np
import matplotlib.pyplot as plt
from algorithms import verify_klc, discrete_gaussian, stretched_exponential

fig, axes = plt.subplots(2, 3, figsize=(15, 8))

n = 40

# Top row: discrete Gaussian
pi_gauss = discrete_gaussian(n, a=0.05)
is_klc, tower = verify_klc(pi_gauss, k=5)

for col in range(3):
    ax = axes[0, col]
    if col < len(tower):
        seq = tower[col]
        ax.bar(range(len(seq)), seq, color='#2196F3', alpha=0.7, width=0.8)
        ax.set_title(f'Depth {col}: {"Original" if col == 0 else f"Ratio^{col}"}',
                     fontsize=11)

        # Check and annotate log-concavity
        from algorithms import is_log_concave
        lc = is_log_concave(seq)
        ax.annotate(f'Log-concave: {"✓" if lc else "✗"}',
                    xy=(0.02, 0.95), xycoords='axes fraction',
                    fontsize=10, color='green' if lc else 'red',
                    fontweight='bold', va='top')
    ax.set_xlabel('Index', fontsize=10)

axes[0, 0].set_ylabel('Discrete Gaussian\n(a=0.05)', fontsize=11)

# Bottom row: stretched exponential
pi_stretch = stretched_exponential(n, p=1.5, a=0.1)
is_klc2, tower2 = verify_klc(pi_stretch, k=5)

for col in range(3):
    ax = axes[1, col]
    if col < len(tower2):
        seq = tower2[col]
        ax.bar(range(len(seq)), seq, color='#FF5722', alpha=0.7, width=0.8)
        ax.set_title(f'Depth {col}: {"Original" if col == 0 else f"Ratio^{col}"}',
                     fontsize=11)

        from algorithms import is_log_concave
        lc = is_log_concave(seq)
        ax.annotate(f'Log-concave: {"✓" if lc else "✗"}',
                    xy=(0.02, 0.95), xycoords='axes fraction',
                    fontsize=10, color='green' if lc else 'red',
                    fontweight='bold', va='top')
    ax.set_xlabel('Index', fontsize=10)

axes[1, 0].set_ylabel('Stretched Exp.\n(p=1.5, a=0.1)', fontsize=11)

plt.suptitle('Ratio Tower: Iterated Ratio Sequences\n'
             'Each level shows progressively smoother structure',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('ratio_tower.png', dpi=150, bbox_inches='tight')
print("Saved ratio_tower.png")
