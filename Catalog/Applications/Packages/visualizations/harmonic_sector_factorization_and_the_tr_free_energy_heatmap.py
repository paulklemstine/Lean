#!/usr/bin/env python3
"""
Visualization 3: Free Energy Decomposition Heatmap

Shows a 2D heatmap of the topological fraction of free energy
(F_harm / F_total) as a function of two edge lengths in the theta graph
Θ(a, b, 1), revealing how topology dominates for graphs with
large cycles (long edges) and combinatorial structure dominates
for graphs with small cycles.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


def compute_zpin_inline(n, det_Lred):
    if det_Lred <= 0:
        return np.nan
    return (2 * np.pi) ** ((n - 1) / 2) / np.sqrt(det_Lred)


def compute_covol_inline(a, b, c):
    val = a * b + b * c + c * a
    if val <= 0:
        return np.nan
    return np.sqrt(val)


matplotlib.rcParams.update({'font.size': 12})
fig, axes = plt.subplots(1, 3, figsize=(17, 5))

N = 100
a_vals = np.linspace(0.3, 6, N)
b_vals = np.linspace(0.3, 6, N)
A, B = np.meshgrid(a_vals, b_vals)
c_fixed = 1.0

# Compute quantities on the grid
F_total = np.zeros_like(A)
F_pin = np.zeros_like(A)
F_harm = np.zeros_like(A)
topo_fraction = np.zeros_like(A)
covol_grid = np.zeros_like(A)

for i in range(N):
    for j in range(N):
        a, b = A[i, j], B[i, j]
        w = 1/a + 1/b + 1/c_fixed
        zpin = compute_zpin_inline(2, w)
        covol = compute_covol_inline(a, b, c_fixed)
        if np.isnan(zpin) or np.isnan(covol) or zpin <= 0 or covol <= 0:
            F_total[i, j] = np.nan
            F_pin[i, j] = np.nan
            F_harm[i, j] = np.nan
            topo_fraction[i, j] = np.nan
            covol_grid[i, j] = np.nan
        else:
            fp = -np.log(zpin)
            fh = -np.log(covol)
            ft = fp + fh
            F_total[i, j] = ft
            F_pin[i, j] = fp
            F_harm[i, j] = fh
            topo_fraction[i, j] = fh / ft if ft != 0 else np.nan
            covol_grid[i, j] = covol

# Panel 1: Tropical Jacobian covolume
ax = axes[0]
im = ax.pcolormesh(A, B, covol_grid, cmap='viridis', shading='auto')
ax.set_xlabel('Edge length a')
ax.set_ylabel('Edge length b')
ax.set_title(r'Tropical Jacobian Volume $\sqrt{ab+bc+ca}$')
plt.colorbar(im, ax=ax, label='covol(Λ_Γ)')
ax.set_aspect('equal')

# Panel 2: Free energy decomposition (F_harm)
ax = axes[1]
im = ax.pcolormesh(A, B, -F_harm, cmap='RdYlGn', shading='auto')
ax.set_xlabel('Edge length a')
ax.set_ylabel('Edge length b')
ax.set_title(r'Topological Free Energy $-F_{\mathrm{harm}}$')
plt.colorbar(im, ax=ax, label=r'$\log(\mathrm{covol})$')
ax.set_aspect('equal')

# Panel 3: Cross-section comparison
ax = axes[2]
a_line = np.linspace(0.3, 6, 200)
for b_val, color, style in [(0.5, '#e41a1c', '-'), (1.0, '#377eb8', '--'),
                              (2.0, '#4daf4a', '-.'), (4.0, '#984ea3', ':')]:
    covols = [compute_covol_inline(a, b_val, c_fixed) for a in a_line]
    zpins = [compute_zpin_inline(2, 1/a + 1/b_val + 1/c_fixed) for a in a_line]
    fts = [-np.log(zp * cv) for zp, cv in zip(zpins, covols)]
    fps = [-np.log(zp) for zp in zpins]
    fracs = [fp / ft if abs(ft) > 1e-10 else np.nan for fp, ft in zip(fps, fts)]
    ax.plot(a_line, fracs, color=color, linestyle=style, lw=2,
            label=f'b = {b_val}')

ax.set_xlabel('Edge length a')
ax.set_ylabel(r'$F_{\mathrm{pin}} / F_{\mathrm{total}}$')
ax.set_title('Pinned Fraction of Free Energy')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 1)

plt.tight_layout()
plt.savefig('viz_free_energy_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_free_energy_heatmap.png")
