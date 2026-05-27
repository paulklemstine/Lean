#!/usr/bin/env python3
"""
Visualization 1: Kesten-McKay Moments vs Catalan Numbers

Visualizes how the Kesten-McKay moment formula μ_{2k} = C_k · d · (d-1)^{k-1}
decomposes into the Catalan enumeration factor and the degree correction.
Shows the spectral bound C_k ≤ 4^k and its tightness.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

def catalan(n):
    return comb(2 * n, n) // (n + 1)

def kesten_mckay_moment(d, k):
    if k == 0:
        return 1.0
    return float(catalan(k) * d * (d - 1) ** (k - 1))

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Catalan numbers vs 4^k bound
ks = list(range(12))
catalans = [catalan(k) for k in ks]
bounds = [4**k for k in ks]

axes[0].semilogy(ks, catalans, 'bo-', label=r'$C_k$ (Catalan)', markersize=8, linewidth=2)
axes[0].semilogy(ks, bounds, 'r--', label=r'$4^k$ (upper bound)', linewidth=2)
axes[0].fill_between(ks, catalans, bounds, alpha=0.15, color='red')
axes[0].set_xlabel('k', fontsize=13)
axes[0].set_ylabel('Value', fontsize=13)
axes[0].set_title(r'Catalan Numbers: $C_k \leq 4^k$', fontsize=14)
axes[0].legend(fontsize=11)
axes[0].grid(True, alpha=0.3)

# Panel 2: Kesten-McKay moments for different d
for d in [3, 4, 5, 6]:
    moments = [kesten_mckay_moment(d, k) for k in ks]
    axes[1].semilogy(ks, moments, 'o-', label=f'd={d}', markersize=6, linewidth=2)

axes[1].set_xlabel('k', fontsize=13)
axes[1].set_ylabel(r'$\mu_{2k}$', fontsize=13)
axes[1].set_title('Kesten-McKay Moments by Degree', fontsize=14)
axes[1].legend(fontsize=11)
axes[1].grid(True, alpha=0.3)

# Panel 3: Ratio μ_{2k} / (4(d-1))^k showing tightness
for d in [3, 4, 5, 6]:
    ratios = []
    for k in ks:
        mu = kesten_mckay_moment(d, k)
        bound = (4 * (d - 1)) ** k * d if k > 0 else 1.0
        ratios.append(mu / bound if bound > 0 else 0)
    axes[2].plot(ks, ratios, 'o-', label=f'd={d}', markersize=6, linewidth=2)

axes[2].set_xlabel('k', fontsize=13)
axes[2].set_ylabel(r'$\mu_{2k} / [(4(d-1))^k \cdot d]$', fontsize=13)
axes[2].set_title('Moment Bound Tightness', fontsize=14)
axes[2].legend(fontsize=11)
axes[2].grid(True, alpha=0.3)
axes[2].set_ylim(0, 1.1)

plt.suptitle('The Noncrossing Bridge: Moments, Catalan Numbers, and Spectral Bounds',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_moments.png', dpi=150, bbox_inches='tight')
print("Saved viz_moments.png")
