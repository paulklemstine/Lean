#!/usr/bin/env python3
"""
Visualization 2: Log-Concavity from Lorentzian Structure

Shows how the Lorentzian condition on the Hessian implies log-concavity
of coefficient sequences. Visualizes Newton's inequalities and the
log-concavity of elementary symmetric polynomials.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def elem_sym_poly(b_values, k):
    """Compute k-th elementary symmetric polynomial of b_values."""
    n = len(b_values)
    if k < 0 or k > n:
        return 0.0
    if k == 0:
        return 1.0

    # Dynamic programming
    dp = [0.0] * (k + 1)
    dp[0] = 1.0
    for b in b_values:
        for j in range(min(k, len(b_values)), 0, -1):
            dp[j] += b * dp[j - 1]
    return dp[k]


def univariate_coeffs(n_edges, b_values):
    """Compute all coefficients of prod(1 + b_i * t)."""
    coeffs = [1.0]
    for b in b_values:
        new_coeffs = [0.0] * (len(coeffs) + 1)
        for k in range(len(coeffs)):
            new_coeffs[k] += coeffs[k]
            new_coeffs[k + 1] += b * coeffs[k]
        coeffs = new_coeffs
    return coeffs


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Log-concavity of elementary symmetric polynomials
ax = axes[0, 0]
for n in [4, 6, 8, 10]:
    b = np.ones(n)
    coeffs = univariate_coeffs(n, b)
    log_coeffs = [np.log(c) if c > 0 else 0 for c in coeffs]
    ax.plot(range(len(coeffs)), log_coeffs, 'o-', label=f'n={n}', markersize=4)

ax.set_xlabel('Degree k')
ax.set_ylabel('log(eₖ)')
ax.set_title('Log of elementary symmetric polynomials\n(uniform inputs: all bᵢ = 1)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: Newton's inequality gaps
ax = axes[0, 1]
rng = np.random.default_rng(42)
for n in [5, 8, 12]:
    b = rng.uniform(0.5, 3.0, size=n)
    coeffs = univariate_coeffs(n, b)

    # Newton gaps: e_k^2 - e_{k-1} * e_{k+1}
    gaps = []
    for k in range(1, len(coeffs) - 1):
        gap = coeffs[k]**2 - coeffs[k-1] * coeffs[k+1]
        gaps.append(gap)

    ax.bar(np.arange(len(gaps)) + (n-5)*0.25/7, gaps,
           width=0.25, alpha=0.7, label=f'n={n}')

ax.set_xlabel('Position k')
ax.set_ylabel('eₖ² − eₖ₋₁·eₖ₊₁')
ax.set_title("Newton's inequality gaps (all ≥ 0)")
ax.legend()
ax.axhline(y=0, color='red', linewidth=1, linestyle='--')
ax.grid(True, alpha=0.3)

# Plot 3: AM-GM / Newton's inequality visualization
ax = axes[1, 0]
a_vals = np.linspace(0, 5, 200)
b_val = 2.0

sum_sq = (a_vals + b_val)**2
product4 = 4 * a_vals * b_val

ax.fill_between(a_vals, product4, sum_sq, alpha=0.3, color='green',
                label='Gap: (a+b)² − 4ab = (a−b)²')
ax.plot(a_vals, sum_sq, 'b-', linewidth=2, label='(a+b)²')
ax.plot(a_vals, product4, 'r-', linewidth=2, label='4ab')
ax.axvline(x=b_val, color='gray', linestyle=':', label=f'a = b = {b_val} (equality)')
ax.set_xlabel('a')
ax.set_ylabel('Value')
ax.set_title(f"Newton's inequality: (a+b)² ≥ 4ab  (b={b_val})")
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 4: Log-concavity for Ising partition function
ax = axes[1, 1]
for n in [4, 5, 6]:
    edges = list(combinations(range(n), 2))
    z_fixed = np.ones(n)

    # Compute univariate specialization keeping variable 0 free
    incident_b = []
    other_factor = 1.0
    for u, v in edges:
        if u == 0 or v == 0:
            other = v if u == 0 else u
            incident_b.append(z_fixed[other])  # coupling = 1
        else:
            other_factor *= (1 + z_fixed[u] * z_fixed[v])

    coeffs = univariate_coeffs(len(incident_b), incident_b)
    coeffs = [c * other_factor for c in coeffs]

    # Normalize for comparison
    total = sum(coeffs)
    normalized = [c / total for c in coeffs]

    ax.plot(range(len(normalized)), normalized, 'o-',
            label=f'K_{n} (normalized)', markersize=5)

ax.set_xlabel('Degree k')
ax.set_ylabel('Normalized coefficient')
ax.set_title('Ising partition function coefficients\n(unimodal + log-concave)')
ax.legend()
ax.grid(True, alpha=0.3)

plt.suptitle('Log-Concavity from Lorentzian Polynomial Structure',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_logconcavity.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_logconcavity.png")
