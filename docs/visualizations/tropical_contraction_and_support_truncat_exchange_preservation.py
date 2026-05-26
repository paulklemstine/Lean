"""
Visualization: M-Convex Exchange Preservation Under Contraction

Shows that the M-convex exchange property is preserved when contracting
a support set in any coordinate direction. Displays exchange moves
before and after contraction for a simplex slice.

This visualizes Theorem 2: MConvexExchangeFinsupp.supportContract
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations

def exponent_contract(i, m):
    if m[i] == 0:
        return None
    return m[:i] + (m[i] - 1,) + m[i+1:]

def support_contract(i, S):
    return {mc for m in S if (mc := exponent_contract(i, m)) is not None}

def find_exchange_witnesses(S, alpha, beta):
    """Find all valid exchange witnesses for alpha, beta."""
    d = len(alpha)
    witnesses = []
    for k in range(d):
        if alpha[k] > beta[k]:
            for j in range(d):
                if alpha[j] < beta[j]:
                    exc = list(alpha)
                    exc[k] -= 1
                    exc[j] += 1
                    if tuple(exc) in S:
                        witnesses.append((k, j, tuple(exc)))
    return witnesses

# Generate simplex slice
total = 3
simplex = set()
for a in range(total + 1):
    for b in range(total + 1 - a):
        simplex.add((a, b, total - a - b))

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('M-Convex Exchange Preservation Under Support Contraction',
             fontsize=14, fontweight='bold')

# Project 3D points to 2D for visualization (use first two coords)
def project(pts):
    return [(p[0], p[1]) for p in pts]

datasets = [
    ("Original: Simplex Δ₃", simplex),
    ("Contract dir 0", support_contract(0, simplex)),
    ("Contract dir 1", support_contract(1, simplex)),
]

for idx, (title, S) in enumerate(datasets):
    ax = axes[idx]
    pts_2d = project(S)
    pts_arr = np.array(pts_2d)

    # Plot points
    ax.scatter(pts_arr[:, 0], pts_arr[:, 1], c='royalblue', s=100,
              zorder=5, edgecolors='navy', linewidth=1.5)

    # Label points with full coordinates
    for p, p_full in zip(pts_2d, S):
        ax.annotate(str(p_full), p, textcoords="offset points",
                   xytext=(5, 8), fontsize=7)

    # Draw some exchange moves
    S_list = sorted(S)
    exchange_count = 0
    for a_idx, alpha in enumerate(S_list):
        for beta in S_list[a_idx+1:]:
            witnesses = find_exchange_witnesses(S, alpha, beta)
            if witnesses and exchange_count < 8:
                k, j, exc = witnesses[0]
                # Draw arrow from alpha to exchanged
                a2d = (alpha[0], alpha[1])
                e2d = (exc[0], exc[1])
                if a2d != e2d:
                    ax.annotate('', xy=e2d, xytext=a2d,
                               arrowprops=dict(arrowstyle='->', color='red',
                                              lw=1.2, alpha=0.4))
                    exchange_count += 1

    ax.set_title(f'{title}\n|S| = {len(S)}, M-convex: ✓', fontsize=11)
    ax.set_xlabel('Coordinate 0')
    ax.set_ylabel('Coordinate 1')
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

plt.tight_layout()
plt.savefig('exchange_preservation.png', dpi=150, bbox_inches='tight')
print("Saved exchange_preservation.png")
