"""
Visualization: Independent Set Complex Structure

Visualizes the f-vector of the independent set complex for different
matroid families, showing how the complex structure determines
certification complexity at each derivative level.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import comb


def graphic_bases(nv, edges):
    """Enumerate spanning trees."""
    rank = nv - 1
    bases = []
    for combo in combinations(range(len(edges)), rank):
        parent = list(range(nv))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        ok = True
        for idx in combo:
            u, v = edges[idx]
            pu, pv = find(u), find(v)
            if pu == pv:
                ok = False
                break
            parent[pu] = pv
        if ok and len(set(find(i) for i in range(nv))) == 1:
            bases.append(frozenset(combo))
    return bases


def f_vector(bases, r):
    """Compute the f-vector: f_k = number of independent k-sets."""
    if not bases:
        return [0] * (r + 1)
    ground = frozenset().union(*bases)
    fvec = [1]  # f_0 = 1 (empty set)
    for k in range(1, r + 1):
        count = 0
        for combo in combinations(sorted(ground), k):
            subset = frozenset(combo)
            if any(subset <= b for b in bases):
                count += 1
        fvec.append(count)
    return fvec


fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Panel 1: f-vector of K4 graphic matroid
ax1 = axes[0, 0]
n = 4
edges = [(i,j) for i in range(n) for j in range(i+1,n)]
r = n - 1
bases = graphic_bases(n, edges)
fv = f_vector(bases, r)
ambient_fv = [comb(len(edges), k) for k in range(r + 1)]

x = np.arange(len(fv))
width = 0.35
ax1.bar(x - width/2, ambient_fv, width, label='Ambient C(m,k)',
        color='#ff6b6b', alpha=0.8)
ax1.bar(x + width/2, fv, width, label='Independent k-sets',
        color='#4ecdc4', alpha=0.8)
ax1.set_xlabel('k', fontsize=11)
ax1.set_ylabel('Count', fontsize=11)
ax1.set_title(f'K₄ Graphic Matroid\n(m={len(edges)}, r={r})', fontsize=12)
ax1.set_xticks(x)
ax1.legend(fontsize=9)

# Panel 2: f-vector comparison across graph types
ax2 = axes[0, 1]
n = 5
graphs = [
    ('Path P₅', [(i,i+1) for i in range(n-1)]),
    ('Cycle C₅', [(i,(i+1)%n) for i in range(n)]),
    ('K₅', [(i,j) for i in range(n) for j in range(i+1,n)]),
]
colors = ['#2196F3', '#FF9800', '#4CAF50']

for (name, edges), color in zip(graphs, colors):
    r = n - 1
    bases = graphic_bases(n, edges)
    if not bases:
        continue
    fv = f_vector(bases, r)
    # Normalize by ambient
    m = len(edges)
    ratios = [fv[k] / comb(m, k) if comb(m, k) > 0 else 0
              for k in range(len(fv))]
    ax2.plot(range(len(ratios)), ratios, 'o-', label=name, color=color,
            markersize=7, linewidth=2)

ax2.set_xlabel('k (subset size)', fontsize=11)
ax2.set_ylabel('Ratio f_k / C(m,k)', fontsize=11)
ax2.set_title('Compression at Each Level\n(5 vertices)', fontsize=12)
ax2.legend(fontsize=9)
ax2.set_ylim(0, 1.1)
ax2.grid(True, alpha=0.3)

# Panel 3: Quadratic leaf level highlighted
ax3 = axes[1, 0]
n = 6
edges_cycle = [(i, (i+1) % n) for i in range(n)]
r = n - 1
bases = graphic_bases(n, edges_cycle)
if bases:
    fv = f_vector(bases, r)
    m = len(edges_cycle)
    ambient_fv = [comb(m, k) for k in range(r + 1)]

    x = np.arange(len(fv))
    colors_bar = ['#4ecdc4'] * len(fv)
    colors_bar[r - 2] = '#e74c3c'  # Highlight quadratic leaf level

    ax3.bar(x, fv, color=colors_bar, alpha=0.8, label='Independent k-sets')
    ax3.bar(x, [a - f for a, f in zip(ambient_fv, fv)],
            bottom=fv, color='lightgray', alpha=0.5, label='Pruned branches')

    ax3.annotate(f'Quadratic leaves\n(k={r-2})',
                xy=(r-2, fv[r-2]),
                xytext=(r-2+0.5, fv[r-2]*1.5),
                fontsize=10, fontweight='bold',
                arrowprops=dict(arrowstyle='->', color='red'),
                color='red')

    ax3.set_xlabel('k (subset size)', fontsize=11)
    ax3.set_ylabel('Count', fontsize=11)
    ax3.set_title(f'C₆ Cycle Graph\nQuadratic leaf level highlighted', fontsize=12)
    ax3.set_xticks(x)
    ax3.legend(fontsize=9)

# Panel 4: Summary statistics
ax4 = axes[1, 1]

families = []
ns_range = range(4, 8)
for n in ns_range:
    for graph_name, graph_fn in [
        ('Path', lambda n: [(i,i+1) for i in range(n-1)]),
        ('Cycle', lambda n: [(i,(i+1)%n) for i in range(n)]),
        ('K_n', lambda n: [(i,j) for i in range(n) for j in range(i+1,n)]),
    ]:
        edges = graph_fn(n)
        r = n - 1
        bases = graphic_bases(n, edges)
        if bases and r >= 2:
            m = len(edges)
            fv = f_vector(bases, r)
            ambient = comb(m, r-2)
            actual = fv[r-2]
            families.append({
                'type': graph_name, 'n': n,
                'ratio': actual/ambient if ambient > 0 else 0,
                'actual': actual, 'ambient': ambient
            })

# Plot compression ratio trends
for gtype, marker, color in [('Path', 's', '#2196F3'),
                               ('Cycle', '^', '#FF9800'),
                               ('K_n', 'o', '#4CAF50')]:
    subset = [f for f in families if f['type'] == gtype]
    if subset:
        ax4.plot([f['n'] for f in subset],
                [f['ratio'] for f in subset],
                marker=marker, color=color, label=gtype,
                linewidth=2, markersize=8)

ax4.set_xlabel('n (vertices)', fontsize=11)
ax4.set_ylabel('Compression Ratio at k=r-2', fontsize=11)
ax4.set_title('Compression at Quadratic Level\nAcross Graph Families', fontsize=12)
ax4.legend(fontsize=10)
ax4.set_ylim(0, 1.1)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('independent_complex.png', dpi=150, bbox_inches='tight')
print("Saved independent_complex.png")
