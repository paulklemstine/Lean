"""
Visualization: Uniqueness Landscape across Graph Families

Shows how the support separation hypothesis and uniqueness theorem
apply across different graph families. Displays a grid of small graphs
with their canonical generator counts and separation status.
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict
from itertools import combinations


def graph_laplacian(adj):
    n = adj.shape[0]
    L = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            if i == j:
                L[i, j] = int(np.sum(adj[i]))
            elif adj[i, j]:
                L[i, j] = -1
    return L


def fun_support(f):
    return frozenset(i for i in range(len(f)) if f[i] != 0)


def pairwise_disjoint_supports(family):
    supports = [fun_support(f) for f in family]
    for i in range(len(supports)):
        for j in range(i + 1, len(supports)):
            if supports[i] & supports[j]:
                return False
    return True


def nontrivial_on_support(family):
    for f in family:
        supp = fun_support(f)
        if len(supp) < 2:
            return False
        vals = {f[i] for i in supp}
        if len(vals) < 2:
            return False
    return True


def find_component_indicators(adj, q, S):
    n = adj.shape[0]
    S_set = set(S)
    vertices = [v for v in range(n) if v != q]
    visited = set()
    components = []
    for start in vertices:
        if start in visited:
            continue
        comp = set()
        queue = [start]
        visited.add(start)
        while queue:
            v = queue.pop(0)
            comp.add(v)
            for w in range(n):
                if w != q and adj[v, w] and w not in visited:
                    visited.add(w)
                    queue.append(w)
        components.append(comp)
    indicators = []
    for comp in components:
        if comp & S_set:
            indicator = np.zeros(n, dtype=int)
            for v in comp & S_set:
                indicator[v] = 1
            indicators.append(indicator)
    return indicators


def find_cycle_basis_indicators(adj, S):
    n = adj.shape[0]
    sub_adj = defaultdict(list)
    edges = []
    for i in S:
        for j in S:
            if adj[i, j] and i < j:
                edges.append((i, j))
                sub_adj[i].append(j)
                sub_adj[j].append(i)
    if not S:
        return []
    visited = set()
    tree_edges = set()
    parent = {}
    queue = [S[0]]
    visited.add(S[0])
    parent[S[0]] = -1
    while queue:
        v = queue.pop(0)
        for w in sub_adj.get(v, []):
            if w not in visited:
                visited.add(w)
                parent[w] = v
                tree_edges.add((min(v, w), max(v, w)))
                queue.append(w)
    indicators = []
    for (u, v) in edges:
        if (u, v) not in tree_edges:
            path_u, x = [], u
            while x != -1:
                path_u.append(x)
                x = parent.get(x, -1)
            path_v, x = [], v
            while x != -1:
                path_v.append(x)
                x = parent.get(x, -1)
            set_u = set(path_u)
            lca = next(x for x in path_v if x in set_u)
            cycle = set()
            x = u
            while x != lca:
                cycle.add(x); x = parent[x]
            cycle.add(lca)
            x = v
            while x != lca:
                cycle.add(x); x = parent[x]
            indicator = np.zeros(n, dtype=int)
            for c in cycle:
                indicator[c] = 1
            indicators.append(indicator)
    return indicators


def canonical_family(adj, q, S):
    return find_cycle_basis_indicators(adj, S) + find_component_indicators(adj, q, S)


def is_connected(adj):
    n = adj.shape[0]
    if n == 0:
        return True
    visited = {0}
    queue = [0]
    while queue:
        v = queue.pop(0)
        for w in range(n):
            if adj[v, w] and w not in visited:
                visited.add(w)
                queue.append(w)
    return len(visited) == n


# Named graph families
graphs = {}

# Path graphs
for n in range(3, 8):
    adj = np.zeros((n, n), dtype=int)
    for i in range(n - 1):
        adj[i, i+1] = adj[i+1, i] = 1
    graphs[f'P{n}'] = adj

# Cycle graphs
for n in range(3, 8):
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        adj[i, (i+1) % n] = adj[(i+1) % n, i] = 1
    graphs[f'C{n}'] = adj

# Complete graphs
for n in range(3, 7):
    adj = np.ones((n, n), dtype=int) - np.eye(n, dtype=int)
    graphs[f'K{n}'] = adj

# Star graphs
for n in range(4, 8):
    adj = np.zeros((n, n), dtype=int)
    for i in range(1, n):
        adj[0, i] = adj[i, 0] = 1
    graphs[f'S{n}'] = adj

# Analyze each graph
results = []
for name, adj in graphs.items():
    n = adj.shape[0]
    q = 0
    S = list(range(1, n))
    family = canonical_family(adj, q, S)
    num_gen = len(family)
    disjoint = pairwise_disjoint_supports(family) if family else True
    nontrivial = nontrivial_on_support(family) if family else True
    unique = disjoint and nontrivial
    num_cycles = len(find_cycle_basis_indicators(adj, S))
    num_comps = len(find_component_indicators(adj, q, S))
    results.append({
        'name': name,
        'n': n,
        'num_gen': num_gen,
        'num_cycles': num_cycles,
        'num_comps': num_comps,
        'disjoint': disjoint,
        'nontrivial': nontrivial,
        'unique': unique,
    })

# Sort by family then size
family_order = {'P': 0, 'C': 1, 'K': 2, 'S': 3}
results.sort(key=lambda r: (family_order.get(r['name'][0], 9), r['n']))

# Create the visualization
fig, axes = plt.subplots(1, 2, figsize=(15, 7))
fig.suptitle('Tropical Kernel Uniqueness Across Graph Families',
             fontsize=14, fontweight='bold')

# Left panel: Bar chart of generator counts
ax = axes[0]
names = [r['name'] for r in results]
cycles = [r['num_cycles'] for r in results]
comps = [r['num_comps'] for r in results]
colors_cycle = ['#2196F3'] * len(results)
colors_comp = ['#4CAF50'] * len(results)

x = np.arange(len(names))
width = 0.35
bars1 = ax.bar(x - width/2, cycles, width, label='Cycle indicators', color='#2196F3', alpha=0.8)
bars2 = ax.bar(x + width/2, comps, width, label='Component indicators', color='#4CAF50', alpha=0.8)

# Mark uniqueness with stars
for i, r in enumerate(results):
    if r['unique']:
        ax.text(i, r['num_gen'] + 0.1, '★', ha='center', fontsize=14, color='gold')

ax.set_xlabel('Graph', fontsize=11)
ax.set_ylabel('Number of Generators', fontsize=11)
ax.set_title('Canonical Generator Decomposition\n(★ = uniqueness theorem applies)', fontsize=11)
ax.set_xticks(x)
ax.set_xticklabels(names, rotation=45, ha='right')
ax.legend()
ax.grid(axis='y', alpha=0.3)

# Right panel: Uniqueness status grid
ax = axes[1]

families = ['Path', 'Cycle', 'Complete', 'Star']
family_prefix = ['P', 'C', 'K', 'S']
sizes = sorted(set(r['n'] for r in results))

# Build grid
grid = np.full((len(families), len(sizes)), np.nan)
for r in results:
    fam_idx = family_prefix.index(r['name'][0])
    if r['n'] in sizes:
        size_idx = sizes.index(r['n'])
        grid[fam_idx, size_idx] = 1 if r['unique'] else 0

# Custom colormap: gray for NaN, red for non-unique, green for unique
from matplotlib.colors import ListedColormap
cmap = ListedColormap(['#FF6B6B', '#4CAF50'])
cmap.set_bad(color='#EEEEEE')

masked = np.ma.masked_where(np.isnan(grid), grid)
im = ax.imshow(masked, cmap=cmap, aspect='auto', vmin=0, vmax=1)

ax.set_xticks(range(len(sizes)))
ax.set_xticklabels(sizes)
ax.set_yticks(range(len(families)))
ax.set_yticklabels(families)
ax.set_xlabel('Number of Vertices', fontsize=11)
ax.set_title('Uniqueness Theorem Applicability\n(Green = applies, Red = does not)', fontsize=11)

for i in range(len(families)):
    for j in range(len(sizes)):
        if not np.isnan(grid[i, j]):
            symbol = '✓' if grid[i, j] == 1 else '✗'
            color = 'white'
            ax.text(j, i, symbol, ha='center', va='center',
                    fontsize=16, color=color, fontweight='bold')

plt.tight_layout()
plt.savefig('uniqueness_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: uniqueness_landscape.png")
