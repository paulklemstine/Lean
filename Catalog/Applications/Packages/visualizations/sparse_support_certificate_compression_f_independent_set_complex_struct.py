"""
Visualization 2: Independent Set Complex Structure

Visualizes the structure of independent sets across matroid types,
showing how the independent-set complex governs derivative survival
in Lorentzian recognition. Plots the full independent-set profile
f_k = #{independent k-sets} for different matroid families.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations


def graphic_matroid_bases(edges, num_vertices):
    """Compute spanning forest bases of a graphic matroid."""
    m = len(edges)
    parent = list(range(num_vertices))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    components = num_vertices
    for u, v in edges:
        pu, pv = find(u), find(v)
        if pu != pv:
            parent[pu] = pv
            components -= 1
    rank = num_vertices - components
    bases = []
    for subset in combinations(range(m), rank):
        par = list(range(num_vertices))
        def find2(x):
            while par[x] != x:
                par[x] = par[par[x]]
                x = par[x]
            return x
        ok = True
        c = num_vertices
        for idx in subset:
            u, v = edges[idx]
            pu, pv = find2(u), find2(v)
            if pu == pv:
                ok = False
                break
            par[pu] = pv
            c -= 1
        if ok and c == components:
            bases.append(frozenset(subset))
    return bases, rank


def count_indep_sets(bases, k, ground_size):
    """Count k-element independent sets."""
    ground = set()
    for b in bases:
        ground |= b
    count = 0
    for subset in combinations(sorted(ground), k):
        fs = frozenset(subset)
        for b in bases:
            if fs <= b:
                count += 1
                break
    return count


fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Panel 1: f-vector for uniform matroids
ax = axes[0, 0]
for n, r in [(6, 3), (8, 4), (10, 5)]:
    ks = list(range(r + 1))
    fk = [comb(n, k) for k in ks]
    ax.plot(ks, fk, 'o-', label=f'$U_{{{r},{n}}}$', markersize=6)
    # Mark the quadratic leaf position
    ax.axvline(x=r-2, color='gray', linestyle=':', alpha=0.3)

ax.set_xlabel('k (set size)', fontsize=12)
ax.set_ylabel('$f_k$ = #independent k-sets', fontsize=12)
ax.set_title('f-vector: Uniform Matroids', fontsize=13)
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

# Panel 2: f-vector for graphic matroids
ax = axes[0, 1]
graphs = [
    ('$P_5$', [(i, i+1) for i in range(4)], 5),
    ('$C_5$', [(i, (i+1) % 5) for i in range(5)], 5),
    ('$K_4$', [(i,j) for i in range(4) for j in range(i+1,4)], 4),
]

for name, edges, nv in graphs:
    m = len(edges)
    bases, rank = graphic_matroid_bases(edges, nv)
    if not bases:
        continue
    ks = list(range(rank + 1))
    fk = [count_indep_sets(bases, k, m) for k in ks]
    ax.plot(ks, fk, 's-', label=f'{name} (m={m},r={rank})', markersize=5)

ax.set_xlabel('k (set size)', fontsize=12)
ax.set_ylabel('$f_k$ = #independent k-sets', fontsize=12)
ax.set_title('f-vector: Graphic Matroids', fontsize=13)
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 3: Ratio f_k / C(m, k) showing compression at each level
ax = axes[1, 0]
for name, edges, nv in graphs:
    m = len(edges)
    bases, rank = graphic_matroid_bases(edges, nv)
    if not bases:
        continue
    ks = list(range(1, rank + 1))
    ratios = []
    for k in ks:
        fk = count_indep_sets(bases, k, m)
        amb = comb(m, k)
        ratios.append(fk / amb if amb > 0 else 0)
    ax.plot(ks, ratios, 'D-', label=f'{name}', markersize=5)

ax.set_xlabel('k (set size)', fontsize=12)
ax.set_ylabel('$f_k / \\binom{m}{k}$', fontsize=12)
ax.set_title('Compression Ratio by Level', fontsize=13)
ax.legend()
ax.set_ylim(0, 1.1)
ax.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)
ax.grid(True, alpha=0.3)

# Panel 4: Quadratic leaf counts as bar chart
ax = axes[1, 1]
examples = [
    ('$U_{3,6}$', comb(6, 1), comb(6, 1)),
    ('$U_{4,8}$', comb(8, 2), comb(8, 2)),
]

for name, edges, nv in graphs:
    m = len(edges)
    bases, rank = graphic_matroid_bases(edges, nv)
    if not bases or rank < 2:
        continue
    leaves = count_indep_sets(bases, rank - 2, m)
    amb = comb(m, rank - 2)
    examples.append((name, leaves, amb))

names = [e[0] for e in examples]
actual = [e[1] for e in examples]
ambient = [e[2] for e in examples]

x = np.arange(len(names))
width = 0.35
ax.bar(x - width/2, ambient, width, label='Ambient $\\binom{m}{r-2}$',
       color='#e74c3c', alpha=0.7)
ax.bar(x + width/2, actual, width, label='Actual leaves',
       color='#2ecc71', alpha=0.7)
ax.set_xticks(x)
ax.set_xticklabels(names, fontsize=10)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('Quadratic Leaves: Actual vs Ambient', fontsize=13)
ax.legend()
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_independent_sets.png', dpi=150, bbox_inches='tight')
print("Saved viz_independent_sets.png")
