#!/usr/bin/env python3
"""
Visualization: Effective Resistance vs Cyclic Distance

Plots R_eff(0, j) as a function of cyclic distance d(0, j) for cycle graphs
of various sizes, demonstrating the exact parabolic formula:
    R(i,j) = d · (n - d) / n

This reveals that resistance is a concave function of distance on cycles,
achieving its maximum at the antipodal point — the GFF variance of the
potential difference φ_0 - φ_j is maximized when j is as far as possible
from 0, which matches the physical intuition from electrical networks.
"""

import numpy as np
import matplotlib.pyplot as plt


def cycle_laplacian(n):
    L = np.zeros((n, n))
    for k in range(n):
        i, j = k, (k + 1) % n
        L[i, i] += 1; L[j, j] += 1
        L[i, j] -= 1; L[j, i] -= 1
    return L


def effective_resistance_matrix(L):
    Lp = np.linalg.pinv(L)
    diag = np.diag(Lp)
    return diag[:, None] + diag[None, :] - 2 * Lp


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))
fig.suptitle("Effective Resistance as a Gaussian Fluctuation Observable",
             fontsize=14, fontweight='bold')

# Left panel: R vs distance for various n
colors = plt.cm.viridis(np.linspace(0.1, 0.9, 6))
for idx, n in enumerate([6, 8, 10, 15, 20, 30]):
    L = cycle_laplacian(n)
    R = effective_resistance_matrix(L)
    distances = [min(abs(j), n - abs(j)) for j in range(n)]
    # Sort by distance
    pairs = sorted(zip(distances, R[0, :]))
    ds = [p[0] for p in pairs]
    rs = [p[1] for p in pairs]
    ax1.plot(ds, rs, 'o-', color=colors[idx], markersize=3,
             linewidth=1.2, label=f'$C_{{{n}}}$')

    # Overlay exact formula
    d_cont = np.linspace(0, n // 2, 100)
    r_exact = d_cont * (n - d_cont) / n
    ax1.plot(d_cont, r_exact, '--', color=colors[idx], alpha=0.3, linewidth=1)

ax1.set_xlabel("Cyclic distance $d(0, j)$", fontsize=12)
ax1.set_ylabel("Effective resistance $R(0, j)$", fontsize=12)
ax1.set_title("$R = d(n-d)/n$: Concave in Distance", fontsize=12)
ax1.legend(fontsize=9, ncol=2)
ax1.grid(True, alpha=0.3)

# Right panel: Var(φ_0 - φ_j) = R(0,j) demonstration
n = 10
L = cycle_laplacian(n)
R = effective_resistance_matrix(L)
K = (R[:, 0][:, None] + R[:, 0][None, :] - R) / 2  # base=0

distances = [min(abs(j), n - abs(j)) for j in range(n)]
variances = [K[0,0] + K[j,j] - 2*K[0,j] for j in range(n)]
resistances = [R[0, j] for j in range(n)]

ax2.bar(range(n), resistances, alpha=0.4, color='steelblue',
        label='$R_{\\mathrm{eff}}(0,j)$')
ax2.plot(range(n), variances, 'ro-', markersize=5,
         label='$\\mathrm{Var}(\\phi_0 - \\phi_j)$')
ax2.set_xlabel("Vertex $j$", fontsize=12)
ax2.set_ylabel("Value", fontsize=12)
ax2.set_title(f"$C_{{{n}}}$: Resistance = Variance (Flagship Theorem)", fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xticks(range(n))

plt.tight_layout()
plt.savefig("viz_resistance_vs_distance.png", dpi=150, bbox_inches='tight')
print("Saved viz_resistance_vs_distance.png")
