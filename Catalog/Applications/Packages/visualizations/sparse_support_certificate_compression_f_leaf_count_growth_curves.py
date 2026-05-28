"""
Visualization: Leaf Count Growth Curves

Plots the growth of quadratic leaf counts as a function of ground set
size n for different matroid families:
- Uniform matroid (worst case): C(n, r-2)
- Single-basis family (best case): C(r, 2)
- Active-variable bound: C(omega, r-2)

Demonstrates the separation between ambient and compressed complexity.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

# Parameters
r = 5  # Fixed rank
n_range = list(range(r, 26))

# Compute leaf counts for each family
uniform_leaves = [comb(n, r - 2) for n in n_range]
single_leaves = [comb(r, 2)] * len(n_range)  # Always C(r, 2) = 10

# Two-basis (disjoint): active vars = 2r, so bound = C(2r, r-2)
two_basis_bound = [comb(min(2*r, n), r - 2) for n in n_range]

# Sparse matroid: active vars ~ sqrt(n) * r
sparse_leaves = [comb(min(int(np.sqrt(n) * r / 2), n), r - 2) for n in n_range]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Linear scale
ax1.plot(n_range, uniform_leaves, 'o-', color='#e74c3c', linewidth=2.5,
         markersize=5, label=f'Uniform U(r,n): C(n, {r-2})')
ax1.plot(n_range, two_basis_bound, 's-', color='#3498db', linewidth=2,
         markersize=5, label=f'2 Disjoint Bases: C(min(2r,n), {r-2})')
ax1.plot(n_range, sparse_leaves, '^-', color='#2ecc71', linewidth=2,
         markersize=5, label=f'Sparse: C(√n·r/2, {r-2})')
ax1.plot(n_range, single_leaves, 'D-', color='#9b59b6', linewidth=2,
         markersize=5, label=f'Single Basis: C(r, 2) = {comb(r, 2)}')

ax1.set_xlabel('Ground Set Size (n)', fontsize=13)
ax1.set_ylabel('Quadratic Leaf Count', fontsize=13)
ax1.set_title(f'Leaf Count Growth (rank r = {r})', fontsize=14)
ax1.legend(fontsize=10, loc='upper left')
ax1.grid(True, alpha=0.3)

# Log scale
ax2.semilogy(n_range, uniform_leaves, 'o-', color='#e74c3c', linewidth=2.5,
             markersize=5, label=f'Uniform: C(n, {r-2})')
ax2.semilogy(n_range, two_basis_bound, 's-', color='#3498db', linewidth=2,
             markersize=5, label=f'2 Disjoint Bases')
ax2.semilogy(n_range, sparse_leaves, '^-', color='#2ecc71', linewidth=2,
             markersize=5, label=f'Sparse')
ax2.semilogy(n_range, single_leaves, 'D-', color='#9b59b6', linewidth=2,
             markersize=5, label=f'Single Basis: {comb(r, 2)}')

# Shade the compression gap
ax2.fill_between(n_range, single_leaves, uniform_leaves,
                  alpha=0.1, color='gray', label='Compression gap')

ax2.set_xlabel('Ground Set Size (n)', fontsize=13)
ax2.set_ylabel('Quadratic Leaf Count (log scale)', fontsize=13)
ax2.set_title(f'Compression Gap (rank r = {r})', fontsize=14)
ax2.legend(fontsize=10, loc='upper left')
ax2.grid(True, alpha=0.3)

plt.suptitle('Support-Compressed Certificate Complexity\n'
             'Gap between ambient worst case and support-controlled cost',
             fontsize=15, y=1.02)

plt.tight_layout()
plt.savefig('leaf_growth.png', dpi=150, bbox_inches='tight')
print("Saved leaf_growth.png")
