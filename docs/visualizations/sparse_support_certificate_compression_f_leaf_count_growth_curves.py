"""
Visualization: Leaf Count Growth Curves

Plots the growth of nonzero quadratic leaves as a function of the ground
set size n, for several matroid families. Compares:
  - Uniform matroid U_{r,n}: leaves = C(n, r-2) (maximum possible)
  - Restricted matroid (k active variables): leaves = C(k, r-2) (constant!)
  - The gap between them shows the power of support compression.

This visualization makes the key theorem tangible: for matroids whose
bases use only a small fraction of the ground set, certification
complexity stays bounded even as n grows.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# ── Left panel: Fixed rank r=4 ──
ax = axes[0]
r = 4
n_range = np.arange(r, 26)

# Uniform matroid (upper bound)
uniform_leaves = [comb(n, r-2) for n in n_range]
ax.plot(n_range, uniform_leaves, 'b-o', markersize=4, linewidth=2,
        label=f'Uniform U_{{{r},n}}: C(n,{r-2})')

# Restricted matroids with different active variable counts
for k, color, marker in [(6, 'green', 's'), (8, 'orange', '^'), (10, 'red', 'D')]:
    restricted = [comb(min(k, n), r-2) for n in n_range]
    ax.plot(n_range, restricted, f'{color[0]}--{marker}', markersize=4, linewidth=1.5,
            label=f'Restricted (k={k}): C({k},{r-2})={comb(k,r-2)}',
            color=color)

ax.set_xlabel('Ground Set Size n', fontsize=12)
ax.set_ylabel('Nonzero Quadratic Leaves', fontsize=12)
ax.set_title(f'Leaf Count Growth (rank r = {r})', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

# ── Right panel: Varying rank ──
ax = axes[1]
n = 20

r_range = np.arange(3, 12)

# Ambient bound
ambient = [comb(n, r-2) for r in r_range]
ax.bar(r_range - 0.2, ambient, width=0.35, color='steelblue', alpha=0.7,
       label=f'Ambient C({n}, r−2)')

# Restricted (k=8 active vars)
k = 8
restricted = [comb(min(k, n), r-2) if r-2 <= k else 0 for r in r_range]
ax.bar(r_range + 0.2, restricted, width=0.35, color='coral', alpha=0.7,
       label=f'Compressed C({k}, r−2)')

ax.set_xlabel('Rank r', fontsize=12)
ax.set_ylabel('Leaf Count', fontsize=12)
ax.set_title(f'Ambient vs Compressed (n={n}, k={k} active)', fontsize=13)
ax.legend(fontsize=10)
ax.set_xticks(r_range)
ax.grid(True, alpha=0.3, axis='y')
ax.set_yscale('log')

plt.tight_layout()
plt.savefig('viz_leaf_growth.png', dpi=150, bbox_inches='tight')
print("Saved viz_leaf_growth.png")
