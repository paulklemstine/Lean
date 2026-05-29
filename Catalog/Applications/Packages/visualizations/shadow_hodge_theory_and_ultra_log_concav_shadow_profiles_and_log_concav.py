#!/usr/bin/env python3
"""
Visualization: Shadow Profile Log-Concavity and ULC Ratios

This script visualizes the core mathematical concepts:
1. Shadow profiles C(n,k) for several values of n
2. Log-concavity ratios C(n,k)^2 / (C(n,k-1)*C(n,k+1))
3. The ULC failure for D = max degree (counterexample region)

Uses matplotlib to produce a multi-panel figure showing the interplay
between shadow profiles, their log-concavity ratios, and the ULC threshold.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def compute_log_concavity_ratio(n, k):
    """Compute C(n,k)^2 / (C(n,k-1)*C(n,k+1))."""
    if k < 1 or k >= n:
        return None
    num = comb(n, k) ** 2
    den = comb(n, k - 1) * comb(n, k + 1)
    return num / den if den > 0 else float('inf')


def compute_ulc_ratio(n, r, k):
    """Compute a_k^2 * C(r,k-1)*C(r,k+1) / (a_{k-1}*a_{k+1}*C(r,k)^2) for a_k = C(n,k)."""
    if k < 1 or k >= r:
        return None
    lhs = comb(n, k) ** 2 * comb(r, k - 1) * comb(r, k + 1)
    rhs = comb(n, k - 1) * comb(n, k + 1) * comb(r, k) ** 2
    return lhs / rhs if rhs > 0 else float('inf')


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Shadow Profiles: Log-Concavity and Ultra-Log-Concavity',
             fontsize=16, fontweight='bold')

# Panel 1: Shadow profiles for various n
ax1 = axes[0, 0]
for n in [6, 8, 10, 12]:
    ks = list(range(n + 1))
    profile = [comb(n, k) for k in ks]
    ax1.plot(ks, profile, 'o-', label=f'n={n}', markersize=4)
ax1.set_xlabel('Degree k')
ax1.set_ylabel('Shadow size C(n,k)')
ax1.set_title('Shadow Profiles of Uniform Matroids')
ax1.legend()
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Log-concavity ratios
ax2 = axes[0, 1]
for n in [6, 8, 10, 12]:
    ks = list(range(1, n))
    ratios = [compute_log_concavity_ratio(n, k) for k in ks]
    ax2.plot(ks, ratios, 'o-', label=f'n={n}', markersize=4)
ax2.axhline(y=1.0, color='red', linestyle='--', label='LC threshold (=1)')
ax2.set_xlabel('Degree k')
ax2.set_ylabel('C(n,k)² / (C(n,k-1)·C(n,k+1))')
ax2.set_title('Log-Concavity Ratios (all ≥ 1)')
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)

# Panel 3: ULC ratios with D = r (showing failure)
ax3 = axes[1, 0]
n_val = 8
for r in [3, 4, 5, 6, 7]:
    ks = list(range(1, r))
    ratios = [compute_ulc_ratio(n_val, r, k) for k in ks]
    valid_ks = [k for k, ratio in zip(ks, ratios) if ratio is not None]
    valid_ratios = [ratio for ratio in ratios if ratio is not None]
    color = 'green' if all(ratio >= 1 for ratio in valid_ratios) else 'red'
    marker = 'o' if all(ratio >= 1 for ratio in valid_ratios) else 'x'
    ax3.plot(valid_ks, valid_ratios, f'{marker}-', label=f'r={r}',
             markersize=6, color=None)

ax3.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='ULC threshold')
ax3.set_xlabel('Degree k')
ax3.set_ylabel('ULC ratio (D = r)')
ax3.set_title(f'ULC with D=max|α| for n={n_val} (FAILS for r < n)')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)

# Panel 4: Quantitative excess (n+1)/(k(n-k))
ax4 = axes[1, 1]
for n in [8, 12, 20, 50]:
    ks = list(range(1, n))
    excess = [(n + 1) / (k * (n - k)) for k in ks]
    ax4.plot(ks, excess, '-', label=f'n={n}', linewidth=1.5)
ax4.set_xlabel('Degree k')
ax4.set_ylabel('Excess over LC threshold')
ax4.set_title('Quantitative LC Excess: (n+1)/(k(n-k))')
ax4.legend()
ax4.set_yscale('log')
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('shadow_profiles_ulc.png', dpi=150, bbox_inches='tight')
plt.close()

print("Visualization saved to shadow_profiles_ulc.png")
