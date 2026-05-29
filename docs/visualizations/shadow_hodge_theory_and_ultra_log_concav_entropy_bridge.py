#!/usr/bin/env python3
"""
Visualization: The Entropy Bridge — From Combinatorics to Information Theory

This script visualizes the cross-domain connection between log-concavity
of shadow profiles and information-theoretic entropy bounds.

The key insight (log_concave_ratio_antitone): log-concavity of C(n,k)
implies the ratio C(n,k+1)/C(n,k) is nonincreasing, which means the
discrete log-partition function log(C(n,k)) is concave — connecting
combinatorial structure to Shannon entropy bounds.

Panel 1: The ratio sequence C(n,k+1)/C(n,k) = (n-k)/(k+1) (decreasing)
Panel 2: log(C(n,k)) is concave (the entropy bridge)
Panel 3: Entropy of normalized shadow distribution vs. Gaussian bound
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb, log, log2, pi, e, sqrt


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Ratio monotonicity
ax1 = axes[0]
for n in [8, 12, 20, 30]:
    ks = list(range(0, n))
    ratios = [(n - k) / (k + 1) for k in ks]
    ax1.plot(ks, ratios, 'o-', label=f'n={n}', markersize=3, linewidth=1.5)

ax1.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)
ax1.set_xlabel('Degree k', fontsize=12)
ax1.set_ylabel('C(n,k+1) / C(n,k)', fontsize=12)
ax1.set_title('Ratio Monotonicity\n(Theorem: binomial_ratio_antitone)', fontsize=13)
ax1.legend()
ax1.grid(True, alpha=0.3)
ax1.annotate('Always\ndecreasing!',
            xy=(5, 2.5), fontsize=11, color='darkblue',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Panel 2: Concavity of log C(n,k)
ax2 = axes[1]
for n in [10, 20, 40]:
    ks = list(range(0, n + 1))
    log_vals = [log(comb(n, k)) if comb(n, k) > 0 else 0 for k in ks]
    ax2.plot(ks, log_vals, 'o-', label=f'n={n}', markersize=2, linewidth=1.5)
    
    # Show the concave envelope for n=20
    if n == 20:
        # Second differences should be negative (concavity)
        for k in range(1, n):
            second_diff = log_vals[k+1] - 2*log_vals[k] + log_vals[k-1]
            if k % 4 == 0:
                ax2.annotate(f'Δ²={second_diff:.2f}',
                           xy=(k, log_vals[k]), fontsize=7,
                           textcoords="offset points", xytext=(0, 10),
                           color='darkred', alpha=0.7)

ax2.set_xlabel('Degree k', fontsize=12)
ax2.set_ylabel('log C(n,k)', fontsize=12)
ax2.set_title('Concavity of log C(n,k)\n(Entropy bridge: discrete concavity)', fontsize=13)
ax2.legend()
ax2.grid(True, alpha=0.3)

# Panel 3: Entropy comparison
ax3 = axes[2]
ns = list(range(4, 51))
actual_entropies = []
gaussian_bounds = []

for n in ns:
    # Actual entropy of Bin(n, 1/2)
    H = 0
    for k in range(n + 1):
        p = comb(n, k) / 2**n
        if p > 0:
            H -= p * log2(p)
    actual_entropies.append(H)
    
    # Gaussian approximation: (1/2) * log2(2*pi*e*n/4)
    var = n / 4
    gaussian_bounds.append(0.5 * log2(2 * pi * e * var))

ax3.plot(ns, actual_entropies, 'b-', linewidth=2, label='H(Bin(n,1/2))')
ax3.plot(ns, gaussian_bounds, 'r--', linewidth=2, label='Gaussian bound')
ax3.plot(ns, [0.5 * log2(n + 1) for n in ns], 'g:', linewidth=1.5,
         label='(1/2)·log₂(n+1)')

ax3.set_xlabel('n (dimension)', fontsize=12)
ax3.set_ylabel('Entropy (bits)', fontsize=12)
ax3.set_title('Shadow Profile Entropy\nvs. Information-Theoretic Bounds', fontsize=13)
ax3.legend()
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('entropy_bridge.png', dpi=150, bbox_inches='tight')
plt.close()

print("Entropy bridge visualization saved to entropy_bridge.png")
