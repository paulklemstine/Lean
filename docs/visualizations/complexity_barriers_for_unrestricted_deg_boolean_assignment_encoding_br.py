#!/usr/bin/env python3
"""
Visualization: Boolean Assignment to Multiindex Encoding

Visualizes the injection from Boolean assignments on n variables to
multiindices in 2n variables. Shows how the encoding maps satisfying
and unsatisfying assignments of a CNF formula to distinct points in
multiindex space.

This illustrates Theorem C: the cross-domain bridge between
satisfiability and derivative-tree structure.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct
from math import comb


def assignment_to_multiindex(tau):
    """Encode Boolean assignment as multiindex in 2n variables."""
    result = []
    for b in tau:
        result.extend([1, 0] if b else [0, 1])
    return tuple(result)


def multiindex_count(n, d):
    if n == 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Encoding visualization for n=3
ax1 = axes[0]
n = 3
assignments = list(iterproduct([False, True], repeat=n))
multiindices = [assignment_to_multiindex(tau) for tau in assignments]

# Use first two principal components for visualization
mi_array = np.array(multiindices, dtype=float)
# Simple 2D projection: sum of even indices vs sum of odd indices
x_proj = mi_array[:, 0::2].sum(axis=1)  # "true" dimensions
y_proj = mi_array[:, 1::2].sum(axis=1)  # "false" dimensions

# CNF formula: (x0 ∨ x1) ∧ (¬x0 ∨ x2) ∧ (¬x1 ∨ ¬x2)
def check_sat(tau):
    clauses = [
        [(0, True), (1, True)],
        [(0, False), (2, True)],
        [(1, False), (2, False)]
    ]
    for clause in clauses:
        if not any(tau[v] == p for v, p in clause):
            return False
    return True

colors = ['green' if check_sat(tau) else 'red' for tau in assignments]
markers = ['o' if check_sat(tau) else 'x' for tau in assignments]

for i, (x, y, c, tau) in enumerate(zip(x_proj, y_proj, colors, assignments)):
    label_str = ''.join('1' if b else '0' for b in tau)
    marker = 'o' if check_sat(tau) else 'X'
    ax1.scatter(x, y, c=c, s=150, marker=marker, edgecolors='black', linewidths=1, zorder=5)
    ax1.annotate(label_str, (x, y), textcoords="offset points",
                xytext=(8, 8), fontsize=8, fontweight='bold')

ax1.set_xlabel('# True assignments (Σ α_{2i})', fontsize=11)
ax1.set_ylabel('# False assignments (Σ α_{2i+1})', fontsize=11)
ax1.set_title('Boolean → Multiindex Encoding\n(n=3, green=SAT, red=UNSAT)', fontsize=12)
ax1.grid(True, alpha=0.3)

# Add line x + y = n
xx = np.linspace(-0.5, n + 0.5, 100)
ax1.plot(xx, n - xx, 'b--', alpha=0.3, label=f'x + y = {n}')
ax1.legend(fontsize=9)

# Panel 2: Encoding density — how many multiindices are "used"
ax2 = axes[1]
ns = list(range(1, 13))
used = [2**nn for nn in ns]
total = [multiindex_count(2*nn, nn) for nn in ns]
density = [u/t for u, t in zip(used, total)]

ax2.semilogy(ns, total, 'b^-', label='Total multiindices C(2n, n)', markersize=6)
ax2.semilogy(ns, used, 'ro-', label='Boolean assignments 2^n', markersize=6)

ax2.set_xlabel('Number of Boolean variables n', fontsize=11)
ax2.set_ylabel('Count (log scale)', fontsize=11)
ax2.set_title('Encoding Density:\nAssignments vs Total Multiindices', fontsize=12)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Panel 3: Density ratio
ax3 = axes[2]
ax3.plot(ns, [d * 100 for d in density], 'ko-', markersize=6, linewidth=2)
ax3.axhline(y=100, color='gray', linestyle='--', alpha=0.5, label='100% density')

ax3.set_xlabel('Number of Boolean variables n', fontsize=11)
ax3.set_ylabel('Encoding density (%)', fontsize=11)
ax3.set_title('Fraction of Multiindex Space\nUsed by Boolean Encoding', fontsize=12)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(0, 110)

plt.suptitle('Cross-Domain Bridge: Boolean Satisfiability ↔ Derivative Trees',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_boolean_encoding.png', dpi=150, bbox_inches='tight')
print("Saved viz_boolean_encoding.png")
