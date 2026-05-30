"""
Visualization: The FPT Landscape for Lorentzian Recognition

This script maps the complexity landscape showing how treewidth and degree
jointly determine recognition complexity. The key insight: for any fixed
treewidth w, complexity is polynomial in degree, but grows with w.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from mpl_toolkits.mplot3d import Axes3D


def bounded_count(n, d, k):
    if d <= 0:
        return 1
    return max(sum(comb(n, j) * comb(d - 1, j - 1)
                   for j in range(1, min(k, n) + 1) if d >= j), 1)


def general_count(n, d):
    if d <= 0:
        return 1
    return comb(n + d - 1, d)


fig = plt.figure(figsize=(16, 6))

# --- Plot 1: 3D surface of complexity landscape ---
ax1 = fig.add_subplot(131, projection='3d')

n = 15
ds = np.arange(3, 16)
ks = np.arange(1, 8)
D, K = np.meshgrid(ds, ks)

Z = np.zeros_like(D, dtype=float)
for i in range(len(ks)):
    for j in range(len(ds)):
        Z[i, j] = np.log10(max(bounded_count(n, ds[j] - 2, ks[i]), 1))

surf = ax1.plot_surface(D, K, Z, cmap='viridis', alpha=0.8,
                        edgecolor='none')
ax1.set_xlabel('Degree d', fontsize=10)
ax1.set_ylabel('Support bound k', fontsize=10)
ax1.set_zlabel('log₁₀(leaf count)', fontsize=10)
ax1.set_title(f'FPT Landscape (n={n})', fontsize=12, fontweight='bold')
ax1.view_init(elev=25, azim=45)

# --- Plot 2: Phase diagram ---
ax2 = fig.add_subplot(132)

n_vals = range(4, 25)
d_vals = range(4, 25)

phase = np.zeros((len(list(d_vals)), len(list(n_vals))))
n_list = list(n_vals)
d_list = list(d_vals)

for i, d in enumerate(d_list):
    for j, n_val in enumerate(n_list):
        gen = general_count(n_val, d - 2)
        k_star = 2  # threshold support
        bnd = bounded_count(n_val, d - 2, k_star)
        if gen > 0 and bnd > 0:
            ratio = np.log10(gen / bnd)
        else:
            ratio = 0
        phase[i, j] = ratio

im = ax2.imshow(phase, aspect='auto', cmap='RdYlGn_r',
                extent=[n_list[0]-0.5, n_list[-1]+0.5,
                        d_list[-1]+0.5, d_list[0]-0.5],
                vmin=0)
ax2.set_xlabel('Variables n', fontsize=11)
ax2.set_ylabel('Degree d', fontsize=11)
ax2.set_title('Phase Diagram: Speedup from\nSupport Bound k=2',
              fontsize=12, fontweight='bold')
plt.colorbar(im, ax=ax2, label='log₁₀(speedup)')

# Draw the "tractability boundary"
boundary_d = []
boundary_n = []
for n_val in n_list:
    for d in d_list:
        gen = general_count(n_val, d - 2)
        bnd = bounded_count(n_val, d - 2, 2)
        if gen > 10 * bnd:
            boundary_d.append(d)
            boundary_n.append(n_val)
            break

if boundary_n and boundary_d:
    ax2.plot(boundary_n, boundary_d, 'w--', linewidth=2, label='10× speedup')
    ax2.legend(fontsize=9, loc='upper right')

# --- Plot 3: FPT conjecture verification ---
ax3 = fig.add_subplot(133)

# For each w, plot bounded_count(n, d-2, w+1) / (n^(w+1) * d^(w+1))
# If FPT holds, this ratio should be bounded by a constant

n_test = 15
for w, color in [(0, '#e74c3c'), (1, '#f39c12'), (2, '#2ecc71'), (3, '#3498db')]:
    ds_test = list(range(4, 20))
    ratios = []
    for d in ds_test:
        bnd = bounded_count(n_test, d - 2, w + 1)
        normalizer = n_test ** (w + 1) * d ** (w + 1)
        if normalizer > 0:
            ratios.append(bnd / normalizer)
        else:
            ratios.append(0)
    ax3.plot(ds_test, ratios, 'o-', color=color, label=f'w = {w}',
             markersize=4, linewidth=2)

ax3.set_xlabel('Degree d', fontsize=11)
ax3.set_ylabel('count / (n^(w+1) · d^(w+1))', fontsize=11)
ax3.set_title(f'FPT Conjecture Test (n={n_test})\nRatio should stabilize',
              fontsize=12, fontweight='bold')
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(bottom=0)

plt.tight_layout()
plt.savefig('fpt_landscape.png', dpi=150, bbox_inches='tight')
print("Saved fpt_landscape.png")
