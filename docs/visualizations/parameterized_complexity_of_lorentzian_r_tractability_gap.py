"""
Visualization: The Tractability Gap in Lorentzian Recognition

This script visualizes how bounded-treewidth (support-bounded) multiindex
counts grow polynomially in degree d, while unrestricted counts grow
exponentially. The gap between them demonstrates why treewidth is the
right structural parameter for Lorentzian recognition complexity.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def bounded_support_count_exact(n: int, d: int, k: int) -> int:
    """Exact count of multiindices with support ≤ k."""
    if d == 0:
        return 1
    return sum(
        comb(n, j) * comb(d - 1, j - 1)
        for j in range(1, min(k, n) + 1)
        if d >= j
    )


def general_multiindex_count(n: int, d: int) -> int:
    """Total multiindex count C(n+d-1, d)."""
    return comb(n + d - 1, d)


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# --- Plot 1: Log-scale growth comparison ---
ax1 = axes[0]
n = 10
degrees = list(range(2, 25))

for k, color, label in [(1, '#e74c3c', 'Support ≤ 1'),
                          (2, '#f39c12', 'Support ≤ 2'),
                          (3, '#2ecc71', 'Support ≤ 3'),
                          (None, '#3498db', 'Unrestricted')]:
    counts = []
    for d in degrees:
        if k is None:
            counts.append(general_multiindex_count(n, d - 2))
        else:
            counts.append(max(bounded_support_count_exact(n, d - 2, k), 1))
    ax1.semilogy(degrees, counts, 'o-', color=color, label=label,
                 markersize=4, linewidth=2)

ax1.set_xlabel('Degree d', fontsize=12)
ax1.set_ylabel('Number of Hessian checks (log scale)', fontsize=12)
ax1.set_title(f'Lorentzian Leaf Count: n = {n} variables', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10, loc='upper left')
ax1.grid(True, alpha=0.3)

# --- Plot 2: Speedup factor ---
ax2 = axes[1]
for n_val, color, marker in [(5, '#e74c3c', 's'),
                               (10, '#3498db', 'o'),
                               (20, '#2ecc71', '^')]:
    speedups = []
    ds = list(range(4, 20))
    for d in ds:
        gen = general_multiindex_count(n_val, d - 2)
        bounded = max(bounded_support_count_exact(n_val, d - 2, 2), 1)
        speedups.append(gen / bounded)
    ax2.semilogy(ds, speedups, f'{marker}-', color=color,
                 label=f'n = {n_val}', markersize=5, linewidth=2)

ax2.set_xlabel('Degree d', fontsize=12)
ax2.set_ylabel('Speedup factor (log scale)', fontsize=12)
ax2.set_title('Speedup from Support Bound k = 2', fontsize=13, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

# --- Plot 3: Heatmap of the tractability landscape ---
ax3 = axes[2]
n_vals = list(range(3, 16))
k_vals = list(range(1, 8))
d = 10

data = np.zeros((len(k_vals), len(n_vals)))
for i, k in enumerate(k_vals):
    for j, n_val in enumerate(n_vals):
        gen = general_multiindex_count(n_val, d - 2)
        bounded = max(bounded_support_count_exact(n_val, d - 2, k), 1)
        ratio = np.log10(max(gen / bounded, 1))
        data[i, j] = ratio

im = ax3.imshow(data, aspect='auto', cmap='YlOrRd',
                extent=[n_vals[0]-0.5, n_vals[-1]+0.5,
                        k_vals[-1]+0.5, k_vals[0]-0.5])
ax3.set_xlabel('Number of variables n', fontsize=12)
ax3.set_ylabel('Support bound k', fontsize=12)
ax3.set_title(f'log₁₀(Speedup) at degree d = {d}', fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax3, label='log₁₀(general/bounded)')

plt.tight_layout()
plt.savefig('tractability_gap.png', dpi=150, bbox_inches='tight')
print("Saved tractability_gap.png")
