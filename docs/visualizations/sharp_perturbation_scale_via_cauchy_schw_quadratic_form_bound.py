#!/usr/bin/env python3
"""
Visualization: Quadratic Form Bound Comparison

Visualizes the sharp vs crude quadratic form bound for entrywise-bounded
matrices. Shows how the Cauchy-Schwarz improvement reduces the bound
from n²·B to n·B, with concrete examples for various dimensions.
"""

import numpy as np
from numpy.linalg import eigvalsh
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def quad_form(A, v):
    """Compute v^T A v."""
    return v @ A @ v


def max_quad_form_ratio(n, B=1.0, n_samples=10000):
    """
    Empirically find max |Q_A(v)| / ||v||^2 over random A with |A_ij| ≤ B
    and random unit vectors v.
    """
    max_ratio = 0
    for _ in range(n_samples):
        A = np.random.uniform(-B, B, (n, n))
        A = (A + A.T) / 2  # symmetrize
        v = np.random.randn(n)
        v = v / np.linalg.norm(v)
        ratio = abs(quad_form(A, v))
        max_ratio = max(max_ratio, ratio)
    return max_ratio


np.random.seed(42)

ns = list(range(2, 26))
B = 1.0

empirical_max = []
for n in ns:
    empirical_max.append(max_quad_form_ratio(n, B, 5000))

ns_arr = np.array(ns, dtype=float)
emp_arr = np.array(empirical_max)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Quadratic Form Bound: Sharp n·B vs Crude n²·B', fontsize=14, fontweight='bold')

# Plot 1: Bounds comparison
ax = axes[0]
ax.plot(ns, emp_arr, 'ko-', markersize=5, label='Empirical max |Q_A(v)|/||v||²', zorder=3)
ax.plot(ns, [n * B for n in ns], 'r-', linewidth=2, label='Sharp bound: n·B')
ax.plot(ns, [n**2 * B for n in ns], 'b--', linewidth=2, label='Crude bound: n²·B')
ax.set_xlabel('Dimension n', fontsize=11)
ax.set_ylabel('Bound on |Q_A(v)|/||v||²', fontsize=11)
ax.set_title('Quadratic Form Bounds', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Plot 2: Tightness of sharp bound
ax = axes[1]
tightness = emp_arr / ns_arr
ax.plot(ns, tightness, 'ro-', markersize=5)
ax.axhline(y=B, color='r', linestyle='--', alpha=0.5, label=f'B = {B}')
ax.set_xlabel('Dimension n', fontsize=11)
ax.set_ylabel('Empirical max / n', fontsize=11)
ax.set_title('Tightness: max|Q|/(n·||v||²) → B', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Plot 3: Gap between bounds
ax = axes[2]
gap_ratio = np.array([n**2 for n in ns]) / np.array(ns)
ax.bar(ns, gap_ratio, color='orange', alpha=0.7, edgecolor='darkorange')
ax.set_xlabel('Dimension n', fontsize=11)
ax.set_ylabel('Crude/Sharp ratio', fontsize=11)
ax.set_title('Overestimation Factor = n', fontsize=12)
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_quadform.png', dpi=150, bbox_inches='tight')
print("Saved viz_quadform.png")
