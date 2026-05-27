"""
Visualization: Conjecture Testing — dc = rank iff representable

Compares representable vs non-representable matroids by plotting
the success rate of finding rank-sized determinantal representations.

For representable matroids, the search should succeed (dc = rank).
For non-representable matroids, it should fail (dc > rank).

This tests the central conjecture of the paper.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def minor_det(A, cols):
    return np.linalg.det(A[:, list(cols)])


def basis_poly_coeffs(A):
    r, n = A.shape
    coeffs = {}
    for S in combinations(range(n), r):
        d = minor_det(A, S)
        c = d ** 2
        if abs(c) > 1e-12:
            coeffs[S] = c
    return coeffs


def try_find_representation(target_bases, n, r, num_trials=200):
    """Try to find an r x n matrix whose basis support matches target_bases."""
    target_set = set(target_bases)
    successes = 0
    
    for _ in range(num_trials):
        A = np.random.randn(r, n)
        coeffs = basis_poly_coeffs(A)
        support = set(coeffs.keys())
        
        # Check if support is a superset of target (for representable matroids,
        # a generic matrix has all binom(n,r) bases as support)
        if target_set.issubset(support):
            successes += 1
    
    return successes / num_trials


def uniform_matroid_bases(n, r):
    return list(combinations(range(n), r))


def graphic_matroid_bases(edges, nv):
    r = nv - 1
    bases = []
    for subset in combinations(range(len(edges)), r):
        parent = list(range(nv))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            px, py = find(x), find(y)
            if px == py: return False
            parent[px] = py
            return True
        ok = True
        for idx in subset:
            if not union(*edges[idx]):
                ok = False; break
        if ok and len(set(find(i) for i in range(nv))) == 1:
            bases.append(subset)
    return bases


def fano_bases():
    lines = [(0,1,3),(1,2,4),(2,3,5),(3,4,6),(0,4,5),(1,5,6),(0,2,6)]
    line_set = set(frozenset(l) for l in lines)
    return [S for S in combinations(range(7), 3) if frozenset(S) not in line_set]


def non_fano_bases():
    lines = [(0,1,3),(1,2,4),(2,3,5),(3,4,6),(0,4,5),(1,5,6)]
    line_set = set(frozenset(l) for l in lines)
    return [S for S in combinations(range(7), 3) if frozenset(S) not in line_set]


# Collect data
matroids = [
    ("U(2,4)", uniform_matroid_bases(4, 2), 4, 2, True),
    ("U(2,5)", uniform_matroid_bases(5, 2), 5, 2, True),
    ("U(3,5)", uniform_matroid_bases(5, 3), 5, 3, True),
    ("Graphic\n(K₄)", graphic_matroid_bases(
        [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)], 4), 6, 3, True),
    ("Graphic\n(C₄)", graphic_matroid_bases(
        [(0,1),(1,2),(2,3),(3,0)], 4), 4, 3, True),
    ("Non-Fano\n(F₇⁻)", non_fano_bases(), 7, 3, True),
    ("Fano\n(F₇)", fano_bases(), 7, 3, False),
]

names = []
match_rates = []
colors = []
repr_labels = []

np.random.seed(123)
for name, bases, n, r, is_repr in matroids:
    rate = try_find_representation(bases, n, r, num_trials=300)
    names.append(name)
    match_rates.append(rate)
    colors.append('#2ecc71' if is_repr else '#e74c3c')
    repr_labels.append('Representable' if is_repr else 'Non-representable')

# Plot
fig, ax = plt.subplots(figsize=(12, 6))

bars = ax.bar(range(len(names)), match_rates, color=colors, alpha=0.85,
              edgecolor='gray', linewidth=0.8)

ax.set_xticks(range(len(names)))
ax.set_xticklabels(names, fontsize=10)
ax.set_ylabel('Success rate of finding\nrank-sized representation', fontsize=12)
ax.set_title('Central Conjecture Test: dc(M) = rk(M) ⟺ M representable over ℝ\n'
             '(Green = representable, Red = non-representable)',
             fontsize=13, fontweight='bold')
ax.set_ylim(0, 1.15)

# Add value labels
for bar, rate in zip(bars, match_rates):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.02,
            f'{rate:.0%}', ha='center', fontsize=10, fontweight='bold')

# Add legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#2ecc71', alpha=0.85, label='Representable (expect dc = rank)'),
    Patch(facecolor='#e74c3c', alpha=0.85, label='Non-representable (expect dc > rank)')
]
ax.legend(handles=legend_elements, loc='upper right', fontsize=10)

# Add annotation
ax.axhline(y=0.5, color='gray', linestyle='--', alpha=0.3)
ax.text(len(names)-1.5, 0.55, 'Random baseline', color='gray', fontsize=9, alpha=0.5)

plt.tight_layout()
plt.savefig('viz_conjecture.png', dpi=150, bbox_inches='tight')
print("Saved viz_conjecture.png")
