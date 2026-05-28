#!/usr/bin/env python3
"""
Visualization 3: Combinatorial Entropy and the Thermodynamic Analogy

Visualizes the combinatorial entropy (log of support/shadow cardinality)
across different polynomial families and scales, illustrating the
cross-domain bridge to statistical physics. The key insight: positive
Hessian aggregation cannot collapse entropy below the shadow threshold,
analogous to the second law of thermodynamics.
"""

import itertools
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def elementary_symmetric_support_size(n: int, k: int) -> int:
    return math.comb(n, k)


def shadow_size_exact(n: int, k: int) -> int:
    """Shadow of e_k over n vars = C(n, k-2) for k >= 2."""
    if k < 2:
        return 0
    return math.comb(n, k - 2)


def comb_entropy(size: int) -> float:
    if size <= 0:
        return 0.0
    return math.log(size)


# Compute data
ns = list(range(4, 25))
degrees = [3, 4, 5, 6]
degree_colors = {3: '#E53935', 4: '#1E88E5', 5: '#43A047', 6: '#FB8C00'}

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Entropy of support vs shadow
ax1 = axes[0]
for d in degrees:
    support_entropies = [comb_entropy(elementary_symmetric_support_size(n, d))
                         for n in ns if n >= d]
    shadow_entropies = [comb_entropy(shadow_size_exact(n, d))
                        for n in ns if n >= d]
    valid_ns = [n for n in ns if n >= d]
    ax1.plot(valid_ns, support_entropies, '-', color=degree_colors[d],
             linewidth=2, label=f'H(supp e_{d})')
    ax1.plot(valid_ns, shadow_entropies, '--', color=degree_colors[d],
             linewidth=2, alpha=0.6, label=f'H(shadow e_{d})')

ax1.set_xlabel('Number of variables n', fontsize=12)
ax1.set_ylabel('Combinatorial entropy H = log|S|', fontsize=12)
ax1.set_title('Support vs Shadow Entropy', fontsize=14, fontweight='bold')
ax1.legend(fontsize=8, ncol=2, loc='upper left')
ax1.grid(True, alpha=0.3)

# Panel 2: Entropy gap (support - shadow)
ax2 = axes[1]
for d in degrees:
    valid_ns = [n for n in ns if n >= d]
    gaps = [
        comb_entropy(elementary_symmetric_support_size(n, d)) -
        comb_entropy(shadow_size_exact(n, d))
        for n in valid_ns
    ]
    ax2.plot(valid_ns, gaps, 'o-', color=degree_colors[d],
             linewidth=2, markersize=4, label=f'degree {d}')

ax2.set_xlabel('Number of variables n', fontsize=12)
ax2.set_ylabel('Entropy gap H(support) - H(shadow)', fontsize=12)
ax2.set_title('Entropy Reduction Under Shadow\n(bounded by rigidity)', 
              fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Thermodynamic analogy — entropy vs "temperature"
ax3 = axes[2]
n_fixed = 10
betas = np.linspace(0, 3, 50)

support = list(itertools.combinations(range(n_fixed), 4))
shadow = set()
for q in support:
    for pair in itertools.combinations(q, 2):
        shadow.add(pair)
shadow = list(shadow)

# "Energy" = spread of indices
support_energies = [max(s) - min(s) for s in support]
shadow_energies = [max(s) - min(s) if len(s) > 1 else 0 for s in shadow]

support_entropies_thermo = []
shadow_entropies_thermo = []

for beta in betas:
    Z_sup = sum(math.exp(-beta * e) for e in support_energies)
    Z_sh = sum(math.exp(-beta * e) for e in shadow_energies)
    support_entropies_thermo.append(math.log(Z_sup) if Z_sup > 0 else 0)
    shadow_entropies_thermo.append(math.log(Z_sh) if Z_sh > 0 else 0)

ax3.plot(betas, support_entropies_thermo, '-', color='#1E88E5',
         linewidth=2.5, label='Support (microstates)')
ax3.plot(betas, shadow_entropies_thermo, '-', color='#E53935',
         linewidth=2.5, label='Shadow (response)')
ax3.fill_between(betas, shadow_entropies_thermo, support_entropies_thermo,
                 alpha=0.15, color='#9C27B0')
ax3.axhline(y=math.log(len(shadow)), color='#E53935', linestyle='--',
            alpha=0.4, label=f'Zero-temp shadow: log({len(shadow)})')

ax3.set_xlabel('Inverse temperature β', fontsize=12)
ax3.set_ylabel('Free energy log Z(β)', fontsize=12)
ax3.set_title('Thermodynamic Analogy\n(n=10, degree=4)', 
              fontsize=14, fontweight='bold')
ax3.legend(fontsize=9, loc='upper right')
ax3.grid(True, alpha=0.3)

# Add annotation about entropy gap
mid_beta = 1.5
idx = int(len(betas) * mid_beta / 3)
ax3.annotate(
    'Entropy gap:\ncannot collapse\nbelow shadow',
    xy=(betas[idx], (support_entropies_thermo[idx] + shadow_entropies_thermo[idx])/2),
    xytext=(2.2, (support_entropies_thermo[0] + shadow_entropies_thermo[0])/2),
    fontsize=9, ha='center',
    arrowprops=dict(arrowstyle='->', color='#9C27B0'),
    bbox=dict(boxstyle='round,pad=0.4', facecolor='#F3E5F5', edgecolor='#9C27B0')
)

plt.tight_layout()
plt.savefig('entropy_thermodynamics.png', dpi=150, bbox_inches='tight')
print("Saved entropy_thermodynamics.png")
