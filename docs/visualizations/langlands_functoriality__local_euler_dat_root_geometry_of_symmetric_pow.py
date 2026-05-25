#!/usr/bin/env python3
"""
Visualization: Root geometry of symmetric power Euler polynomials.

Shows the multiplicative structure of roots α^{n-i}β^i on a log scale,
and the inversion symmetry for self-dual parameters.
"""

import numpy as np
import matplotlib.pyplot as plt


def symm_pow_roots(n, alpha, beta):
    return [alpha**(n - i) * beta**i for i in range(n + 1)]


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle("Root Geometry of Symmetric Power Transfer\n"
             "$\\mathrm{Sym}^n(\\alpha, \\beta)$: roots $= \\alpha^{n-i}\\beta^i$",
             fontsize=13, fontweight='bold')

# Panel 1: Root magnitudes on log scale
ax = axes[0]
alpha, beta = 2.0, 3.0
for n in [2, 4, 6, 8, 10]:
    roots = symm_pow_roots(n, alpha, beta)
    log_roots = [np.log(abs(r)) for r in roots]
    ax.plot(range(n+1), log_roots, 'o-', label=f"$n={n}$", markersize=5)
ax.set_title(f"Root magnitudes ($\\alpha={alpha}, \\beta={beta}$)", fontsize=11)
ax.set_xlabel("Root index $i$")
ax.set_ylabel("$\\ln|\\alpha^{n-i}\\beta^i|$")
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 2: Self-dual root symmetry
ax = axes[1]
alpha = 2.0
n_vals = [4, 6, 8, 10]
for n in n_vals:
    roots = symm_pow_roots(n, alpha, 1.0/alpha)
    log_roots = [np.log(abs(r)) for r in roots]
    ax.plot(range(n+1), log_roots, 'o-', label=f"$n={n}$", markersize=5)
ax.axhline(0, color='red', linestyle='--', alpha=0.5, label='$|r|=1$')
ax.set_title(f"Self-dual: $\\beta=\\alpha^{{-1}}$ ($\\alpha={alpha}$)", fontsize=11)
ax.set_xlabel("Root index $i$")
ax.set_ylabel("$\\ln|\\alpha^{n-2i}|$")
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 3: Determinant product growth
ax = axes[2]
alpha_vals = [1.5, 2.0, 3.0]
n_range = range(1, 16)
for alpha in alpha_vals:
    beta = 2.0
    products = [(alpha * beta) ** (n * (n + 1) // 2) for n in n_range]
    ax.semilogy(list(n_range), products, 'o-',
                label=f"$\\alpha={alpha}, \\beta={beta}$", markersize=4)
ax.set_title("Determinant growth: $(\\alpha\\beta)^{n(n+1)/2}$", fontsize=11)
ax.set_xlabel("$n$")
ax.set_ylabel("$\\det(\\mathrm{Sym}^n)$")
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("root_geometry.png", dpi=150, bbox_inches='tight')
print("Saved root_geometry.png")
