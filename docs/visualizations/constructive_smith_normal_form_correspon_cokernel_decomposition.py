"""
Visualization: Cokernel Decomposition as Cyclic Group Product

This script visualizes how the Laplacian cokernel decomposes as a
product of cyclic groups for separated subsets. Shows the invariant
factor structure for several graph families.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import gcd
from functools import reduce

def graph_laplacian(adj):
    return np.diag(np.sum(adj, axis=1)) - adj

def make_path(n):
    adj = np.zeros((n,n), dtype=int)
    for i in range(n-1):
        adj[i,i+1] = adj[i+1,i] = 1
    return adj

def make_cycle(n):
    adj = make_path(n)
    adj[0,n-1] = adj[n-1,0] = 1
    return adj

def make_star(n):
    adj = np.zeros((n,n), dtype=int)
    for i in range(1,n):
        adj[0,i] = adj[i,0] = 1
    return adj

def make_complete_bipartite(p, q):
    n = p + q
    adj = np.zeros((n,n), dtype=int)
    for i in range(p):
        for j in range(p, n):
            adj[i,j] = adj[j,i] = 1
    return adj

def is_separated(adj, S):
    for i in range(len(S)):
        for j in range(i+1, len(S)):
            if adj[S[i],S[j]] != 0:
                return False
    return True

def find_max_independent_set(adj):
    n = adj.shape[0]
    best = []
    for mask in range(1, 1 << n):
        S = [i for i in range(n) if mask & (1 << i)]
        if len(S) > len(best) and is_separated(adj, S):
            best = S
    return best

# Collect data for visualization
data = []

graphs = [
    ("P₃", make_path(3)),
    ("P₄", make_path(4)),
    ("P₅", make_path(5)),
    ("P₆", make_path(6)),
    ("C₄", make_cycle(4)),
    ("C₅", make_cycle(5)),
    ("C₆", make_cycle(6)),
    ("Star₄", make_star(4)),
    ("Star₅", make_star(5)),
    ("K₂,₂", make_complete_bipartite(2, 2)),
    ("K₂,₃", make_complete_bipartite(2, 3)),
    ("K₃,₃", make_complete_bipartite(3, 3)),
]

for name, adj in graphs:
    S = find_max_independent_set(adj)
    L = graph_laplacian(adj)
    degrees = [int(np.sum(adj[s])) for s in S]
    order = reduce(lambda x, y: x*y, degrees, 1)
    data.append({
        'name': name,
        'n': adj.shape[0],
        'S': S,
        'degrees': degrees,
        'order': order,
        'num_factors': len([d for d in degrees if d > 1])
    })

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Cokernel orders across graph families
ax = axes[0, 0]
names = [d['name'] for d in data]
orders = [d['order'] for d in data]
colors = ['#2196F3' if 'P' in n else '#4CAF50' if 'C' in n 
          else '#FF9800' if 'Star' in n else '#9C27B0' for n in names]
bars = ax.bar(range(len(names)), orders, color=colors)
ax.set_xticks(range(len(names)))
ax.set_xticklabels(names, rotation=45, ha='right')
ax.set_ylabel('|Cokernel| = ∏ deg(s)', fontsize=12)
ax.set_title('Cokernel Order by Graph Family', fontsize=14, fontweight='bold')
for bar, order in zip(bars, orders):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5,
           str(order), ha='center', va='bottom', fontsize=10)
ax.set_yscale('log')
ax.set_ylim(0.5, max(orders) * 3)

# Plot 2: Independent set size vs graph size
ax = axes[0, 1]
ns = [d['n'] for d in data]
is_sizes = [len(d['S']) for d in data]
for i, d in enumerate(data):
    marker = 'o' if 'P' in d['name'] else 's' if 'C' in d['name'] else '^' if 'Star' in d['name'] else 'D'
    ax.scatter(d['n'], len(d['S']), c=colors[i], s=100, marker=marker, 
              edgecolors='black', linewidth=0.5, zorder=3)
    ax.annotate(d['name'], (d['n'], len(d['S'])), textcoords="offset points",
               xytext=(5, 5), fontsize=8)
ax.set_xlabel('Graph size |V|', fontsize=12)
ax.set_ylabel('Max independent set |S|', fontsize=12)
ax.set_title('Independent Set Size', fontsize=14, fontweight='bold')
ax.grid(True, alpha=0.3)

# Plot 3: Degree distribution at separated sets
ax = axes[1, 0]
all_degrees = []
all_labels = []
for d in data:
    for deg in d['degrees']:
        all_degrees.append(deg)
        all_labels.append(d['name'])

degree_counts = {}
for deg in all_degrees:
    degree_counts[deg] = degree_counts.get(deg, 0) + 1

degs = sorted(degree_counts.keys())
counts = [degree_counts[d] for d in degs]
ax.bar(range(len(degs)), counts, color='#FF5722', alpha=0.8)
ax.set_xticks(range(len(degs)))
ax.set_xticklabels([str(d) for d in degs])
ax.set_xlabel('Vertex degree at separated set', fontsize=12)
ax.set_ylabel('Frequency', fontsize=12)
ax.set_title('Distribution of Invariant Factors\n(= Vertex Degrees at S)', 
            fontsize=14, fontweight='bold')

# Plot 4: Torsion rank (number of nontrivial factors)
ax = axes[1, 1]
ranks = [d['num_factors'] for d in data]
ax.barh(range(len(names)), ranks, color=colors, alpha=0.8)
ax.set_yticks(range(len(names)))
ax.set_yticklabels(names)
ax.set_xlabel('Torsion rank (# factors > 1)', fontsize=12)
ax.set_title('Torsion Rank of Cokernel', fontsize=14, fontweight='bold')
for i, (r, name) in enumerate(zip(ranks, names)):
    if r > 0:
        d = data[i]
        label = " × ".join(f"ℤ/{deg}" for deg in d['degrees'] if deg > 1)
        ax.text(r + 0.1, i, label, va='center', fontsize=9)

plt.suptitle('Cokernel Decomposition: Tropical → Arithmetic Correspondence',
            fontsize=16, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_cokernel_decomposition.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_cokernel_decomposition.png")
