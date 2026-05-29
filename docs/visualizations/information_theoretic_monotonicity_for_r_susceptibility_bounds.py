"""
Visualization: Susceptibility Bounds Under Robust Lorentzianity
================================================================

Plots the spin susceptibility χ vs the certified upper bound ε·n²
for uniform matroid distributions U(k,n) across varying n.

Shows that negative dependence (Lorentzian negativity) forces
the susceptibility to remain bounded, demonstrating the
statistical mechanics bridge theorem.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb, log
from itertools import combinations


def coord_prob_matroid(n, k):
    return k / n

def coord_cov_matroid(n, k):
    """Exact covariance for uniform matroid U(k,n)."""
    if n <= 1:
        return 0.0
    return k * (k - 1) / (n * (n - 1)) - (k / n) ** 2

def estimate_gap_matroid(n, k):
    p = k / n
    cov = abs(coord_cov_matroid(n, k))
    return cov / (p * p) if p > 0 else 0

def susceptibility_matroid(n, k):
    cov = abs(coord_cov_matroid(n, k))
    return n * (n - 1) * cov

# Generate data
ns = list(range(4, 25))
data = []

for n in ns:
    k = n // 2
    eps = estimate_gap_matroid(n, k)
    chi = susceptibility_matroid(n, k)
    bound = eps * n ** 2
    sum_marg_var = n * (k / n) * (1 - k / n)
    fisher = sum_marg_var + bound
    data.append((n, k, eps, chi, bound, sum_marg_var, fisher))

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Susceptibility vs bound
ax = axes[0]
ns_arr = [d[0] for d in data]
chis = [d[3] for d in data]
bounds = [d[4] for d in data]
ax.plot(ns_arr, chis, 'bo-', label='χ (susceptibility)', markersize=5)
ax.plot(ns_arr, bounds, 'r^--', label='ε·n² (bound)', markersize=5)
ax.set_xlabel('n (number of coordinates)')
ax.set_ylabel('Value')
ax.set_title('Susceptibility vs Certified Bound')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: Gap parameter ε vs n
ax = axes[1]
epsilons = [d[2] for d in data]
ax.plot(ns_arr, epsilons, 'gs-', markersize=5)
ax.set_xlabel('n')
ax.set_ylabel('ε (Lorentzian gap)')
ax.set_title('Robustness Gap for U(⌊n/2⌋, n)')
ax.grid(True, alpha=0.3)

# Plot 3: Fisher info bound decomposition
ax = axes[2]
marg_vars = [d[5] for d in data]
fishers = [d[6] for d in data]
ax.fill_between(ns_arr, 0, marg_vars, alpha=0.3, color='blue', label='∑ pᵢ(1-pᵢ)')
ax.fill_between(ns_arr, marg_vars, fishers, alpha=0.3, color='red', label='ε·(∑pᵢ)²')
ax.plot(ns_arr, fishers, 'k-', linewidth=2, label='Fisher bound')
ax.plot(ns_arr, [d[3] + d[5] for d in data], 'ko', markersize=4, label='χ + ∑pᵢ(1-pᵢ)')
ax.set_xlabel('n')
ax.set_ylabel('Value')
ax.set_title('Fisher Information Bound Decomposition')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

plt.suptitle('Information-Theoretic Bounds from Robust Lorentzianity', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_susceptibility.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_susceptibility.png")
