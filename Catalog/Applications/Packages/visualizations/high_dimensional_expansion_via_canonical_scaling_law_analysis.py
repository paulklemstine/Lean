#!/usr/bin/env python3
"""
Visualization: Scaling Law for the Canonical Filling Method

Tests the conjecture that λ₁⁺ · W scales polynomially in n for the complete
2-complex. Plots the product λ₁⁺ · W against n and fits a polynomial to
reveal the scaling law. This is a falsifiable prediction of the theory.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def compute_gap_and_weight(n):
    """Compute spectral gap and filling weight for complete 2-complex on n vertices."""
    vertices = list(range(n))
    edges = list(combinations(vertices, 2))
    triangles = list(combinations(vertices, 3))
    edge_index = {e: i for i, e in enumerate(edges)}
    ne, nt = len(edges), len(triangles)

    b2 = np.zeros((ne, nt))
    for t_idx, (i, j, k) in enumerate(triangles):
        b2[edge_index[(j, k)], t_idx] += 1
        b2[edge_index[(i, k)], t_idx] -= 1
        b2[edge_index[(i, j)], t_idx] += 1

    b1 = np.zeros((n, ne))
    for e_idx, (i, j) in enumerate(edges):
        b1[j, e_idx] += 1
        b1[i, e_idx] -= 1

    L_up = b2 @ b2.T
    eigs = np.linalg.eigvalsh(L_up)
    pos_eigs = eigs[eigs > 1e-10]
    gap = np.min(pos_eigs) if len(pos_eigs) > 0 else 0

    U, S, Vt = np.linalg.svd(b1)
    rank = np.sum(S > 1e-10)
    cycles = Vt[rank:, :]

    W = 0
    for i in range(cycles.shape[0]):
        z = cycles[i]
        F, _, _, _ = np.linalg.lstsq(b2, z, rcond=None)
        W += np.sum(F**2)

    return gap, W


ns = list(range(4, 12))
gaps = []
weights = []
products = []

for n in ns:
    g, w = compute_gap_and_weight(n)
    gaps.append(g)
    weights.append(w)
    products.append(g * w)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Scaling Law: Complete 2-Complex Canonical Fillings',
             fontsize=14, fontweight='bold')

# Plot 1: λ₁⁺ · W vs n
ax = axes[0]
ax.plot(ns, products, 'go-', linewidth=2, markersize=8, label='λ₁⁺ · W')
# Fit polynomial
coeffs = np.polyfit(ns, products, 2)
ns_fit = np.linspace(min(ns), max(ns), 100)
ax.plot(ns_fit, np.polyval(coeffs, ns_fit), 'r--', linewidth=1.5,
        label=f'Fit: {coeffs[0]:.2f}n² + {coeffs[1]:.2f}n + {coeffs[2]:.2f}')
ax.set_xlabel('Number of vertices n', fontsize=12)
ax.set_ylabel('λ₁⁺ · W', fontsize=12)
ax.set_title('Product λ₁⁺ · W (Poincaré Ratio)', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Plot 2: log-log plot to identify polynomial degree
ax = axes[1]
log_ns = np.log(ns)
log_prods = np.log(products)
ax.plot(log_ns, log_prods, 'go-', linewidth=2, markersize=8)
slope_coeffs = np.polyfit(log_ns, log_prods, 1)
ax.plot(log_ns, np.polyval(slope_coeffs, log_ns), 'r--', linewidth=1.5,
        label=f'Slope ≈ {slope_coeffs[0]:.2f}')
ax.set_xlabel('log(n)', fontsize=12)
ax.set_ylabel('log(λ₁⁺ · W)', fontsize=12)
ax.set_title('Log-Log Scaling', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 3: Certified bound tightness ratio
ax = axes[2]
ratios = [g / (1/w) if w > 0 else 0 for g, w in zip(gaps, weights)]
ax.plot(ns, ratios, 'mp-', linewidth=2, markersize=8)
ax.set_xlabel('Number of vertices n', fontsize=12)
ax.set_ylabel('λ₁⁺ / (1/W)', fontsize=12)
ax.set_title('Tightness Ratio: Actual / Certified', fontsize=12)
ax.grid(True, alpha=0.3)
ax.axhline(y=1, color='gray', linestyle=':', alpha=0.5, label='Perfect certificate')
ax.legend(fontsize=10)

plt.tight_layout()
plt.savefig('viz_scaling.png', dpi=150, bbox_inches='tight')
print("Saved viz_scaling.png")

# Print data table
print("\nScaling data:")
print(f"{'n':>3} {'λ₁⁺':>8} {'W':>10} {'λ₁⁺·W':>10} {'1/W':>10} {'ratio':>8}")
for i, n in enumerate(ns):
    cert = 1/weights[i] if weights[i] > 0 else 0
    print(f"{n:>3} {gaps[i]:>8.4f} {weights[i]:>10.4f} {products[i]:>10.4f} "
          f"{cert:>10.6f} {ratios[i]:>8.2f}")
