#!/usr/bin/env python3
"""
Visualization: Lorentzian Recognition Complexity Landscape

Shows the phase transition between polynomial (fixed-degree) and
exponential (unbounded-degree) complexity regimes for recursive
Lorentzian polynomial recognition.

Produces a heatmap of log(certificate_size) as a function of
(number of variables n, degree d), with the polynomial/exponential
boundary clearly marked.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def certificate_size(n: int, d: int) -> float:
    """Exact number of quadratic leaves: C(n + d - 3, d - 2)."""
    if d < 2 or n < 1:
        return 1.0
    k = d - 2
    try:
        return float(math.comb(n + k - 1, k))
    except (ValueError, OverflowError):
        # Use Stirling approximation for large values
        return math.exp(k * math.log(n + k - 1) - k * math.log(k) + k)


def central_lower_bound(n: int, d: int) -> float:
    """Lower bound: C(n, d-2)."""
    if d < 2 or n < 1:
        return 1.0
    k = d - 2
    if k > n:
        return 0.0
    return float(math.comb(n, k))


# Create figure with 2 subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Parameters
n_max = 30
d_max = 30
n_vals = np.arange(2, n_max + 1)
d_vals = np.arange(2, d_max + 1)

# Compute certificate sizes (log scale)
Z = np.zeros((len(d_vals), len(n_vals)))
for i, d in enumerate(d_vals):
    for j, n in enumerate(n_vals):
        size = certificate_size(int(n), int(d))
        Z[i, j] = math.log2(max(size, 1))

# Plot 1: Heatmap of log₂(certificate size)
im1 = ax1.imshow(Z, aspect='auto', origin='lower',
                  extent=[n_vals[0]-0.5, n_vals[-1]+0.5, d_vals[0]-0.5, d_vals[-1]+0.5],
                  cmap='inferno', interpolation='nearest')

# Mark the d = n/2 + 2 line (exponential regime boundary)
n_line = np.linspace(2, n_max, 100)
d_boundary = n_line / 2 + 2
ax1.plot(n_line, d_boundary, 'c--', linewidth=2, label='d = n/2 + 2 (exp regime)')

# Mark d = log₂(n) + 2 (polynomial regime)
d_poly = np.log2(n_line) + 2
ax1.plot(n_line, d_poly, 'g--', linewidth=2, label='d = log₂n + 2 (poly regime)')

ax1.set_xlabel('Number of variables (n)', fontsize=13)
ax1.set_ylabel('Degree (d)', fontsize=13)
ax1.set_title('log₂(Certificate Size) for Lorentzian Recognition', fontsize=14)
ax1.legend(loc='upper left', fontsize=10)
cbar1 = plt.colorbar(im1, ax=ax1, shrink=0.85)
cbar1.set_label('log₂(number of Hessian checks)', fontsize=11)

# Plot 2: Comparison of upper and lower bounds along d = n/2 + 2
k_vals = np.arange(2, 16)
upper_bounds = []
lower_bounds = []
exact_counts = []
two_pow_k = []

for k in k_vals:
    n = int(2 * k)
    d = int(k + 2)
    exact = certificate_size(n, d)
    upper = n ** k if n > 0 else 1
    lower = 2 ** k
    exact_counts.append(math.log2(max(exact, 1)))
    upper_bounds.append(math.log2(max(upper, 1)))
    lower_bounds.append(math.log2(max(lower, 1)))
    two_pow_k.append(k)

ax2.fill_between(k_vals, lower_bounds, upper_bounds, alpha=0.2, color='blue',
                  label='Gap between bounds')
ax2.plot(k_vals, exact_counts, 'ro-', linewidth=2, markersize=6,
         label='Exact: C(2k + k - 1, k)')
ax2.plot(k_vals, upper_bounds, 'b^--', linewidth=1.5,
         label='Upper: (2k)^k')
ax2.plot(k_vals, two_pow_k, 'gs--', linewidth=1.5,
         label='Lower: 2^k (proved)')

ax2.set_xlabel('k (where n = 2k, d = k + 2)', fontsize=13)
ax2.set_ylabel('log₂(leaf count)', fontsize=13)
ax2.set_title('Upper vs Lower Bounds on Certificate Size', fontsize=14)
ax2.legend(fontsize=10, loc='upper left')
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('complexity_landscape.png', dpi=150, bbox_inches='tight')
print("Saved complexity_landscape.png")
