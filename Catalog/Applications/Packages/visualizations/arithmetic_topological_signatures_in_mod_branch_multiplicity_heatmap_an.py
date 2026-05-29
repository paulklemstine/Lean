#!/usr/bin/env python3
"""
Visualization: Branch Multiplicity Heatmap Across Primes

This script visualizes how branch multiplicity varies across vertices x ∈ Z/pZ
for different primes p. Each row is a prime, each column is a vertex.
The color intensity shows the branch multiplicity μ_{p,K}(x).

The periodicity theorem (branch_periodic_mod_order) predicts that the
multiplicity pattern repeats with period ord_p(2), which is visible as
regular bands in the heatmap.
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def multiplicative_order(a, p):
    r, val = 1, a % p
    while val != 1:
        val = (val * a) % p
        r += 1
    return r


def branch_admissible(p, x, k):
    x = x % p
    if x == 0: return True
    return pow(2, k, p) * x % p != 1


def branch_multiplicity(p, K, x):
    return sum(1 for k in range(K + 1) if branch_admissible(p, x, k))


def build_symmetric_graph(p, K):
    inv3 = pow(3, -1, p)
    adj = defaultdict(set)
    edges = set()
    for x in range(p):
        for k in range(K + 1):
            y = (pow(2, k, p) * x - 1) * inv3 % p
            if y != x and y != 0:
                edge = (min(x, y), max(x, y))
                if edge not in edges:
                    edges.add(edge)
                    adj[x].add(y)
                    adj[y].add(x)
    return dict(adj), edges


def connected_components(adj, vertices):
    visited = set()
    components = 0
    for v in vertices:
        if v not in visited:
            components += 1
            queue = [v]
            while queue:
                u = queue.pop()
                if u in visited: continue
                visited.add(u)
                for w in adj.get(u, set()):
                    if w in vertices and w not in visited:
                        queue.append(w)
    return components


K = 10
primes = [p for p in range(5, 80) if is_prime(p)]

fig, axes = plt.subplots(2, 2, figsize=(16, 12))
fig.suptitle('Arithmetic Topological Signatures in Modular Collatz Dynamics',
             fontsize=14, fontweight='bold')

# Panel 1: Branch multiplicity heatmap
ax = axes[0, 0]
max_p = max(primes)
data = np.zeros((len(primes), max_p))
for i, p in enumerate(primes):
    for x in range(p):
        data[i, x] = branch_multiplicity(p, K, x)
    for x in range(p, max_p):
        data[i, x] = np.nan

im = ax.imshow(data, aspect='auto', cmap='viridis', interpolation='nearest')
ax.set_xlabel('Vertex x')
ax.set_ylabel('Prime index')
ax.set_yticks(range(0, len(primes), 3))
ax.set_yticklabels([str(primes[i]) for i in range(0, len(primes), 3)])
ax.set_title(f'Branch Multiplicity μ(x) (K={K})')
plt.colorbar(im, ax=ax, label='Multiplicity')

# Panel 2: Cycle rank vs prime, colored by p mod 8
ax = axes[0, 1]
cycle_ranks = []
colors_mod8 = []
color_map = {1: '#e41a1c', 3: '#377eb8', 5: '#4daf4a', 7: '#984ea3'}

for p in primes:
    adj, edges = build_symmetric_graph(p, K)
    vertices = set(range(p))
    c = connected_components(adj, vertices)
    beta1 = len(edges) - len(vertices) + c
    cycle_ranks.append(beta1 / p)
    colors_mod8.append(color_map.get(p % 8, '#999999'))

ax.scatter(primes, cycle_ranks, c=colors_mod8, s=40, alpha=0.8, edgecolors='black', linewidth=0.5)
ax.set_xlabel('Prime p')
ax.set_ylabel('Normalized cycle rank β₁/p')
ax.set_title('Cycle Rank by Prime (colored by p mod 8)')

# Legend
for r, c in color_map.items():
    ax.scatter([], [], c=c, label=f'p ≡ {r} (mod 8)', s=40)
ax.legend(fontsize=8, loc='upper left')

# Panel 3: Multiplicative order vs normalized cycle rank
ax = axes[1, 0]
orders = [multiplicative_order(2, p) for p in primes]
ax.scatter(orders, cycle_ranks, c=[p for p in primes], cmap='plasma',
           s=40, alpha=0.8, edgecolors='black', linewidth=0.5)
ax.set_xlabel('ord_p(2)')
ax.set_ylabel('Normalized cycle rank β₁/p')
ax.set_title('Multiplicative Order vs Topology')

# Panel 4: Multiplicity distribution comparison
ax = axes[1, 1]
# Compare two residue classes
class1_mults = []
class3_mults = []
for p in primes:
    mults = [branch_multiplicity(p, K, x) / (K + 1) for x in range(1, p)]
    if p % 8 == 1:
        class1_mults.extend(mults)
    elif p % 8 == 3:
        class3_mults.extend(mults)

if class1_mults and class3_mults:
    bins = np.linspace(0, 1.05, 25)
    ax.hist(class1_mults, bins=bins, alpha=0.5, label='p ≡ 1 (mod 8)',
            density=True, color='#e41a1c')
    ax.hist(class3_mults, bins=bins, alpha=0.5, label='p ≡ 3 (mod 8)',
            density=True, color='#377eb8')
    ax.set_xlabel('Normalized multiplicity μ(x)/(K+1)')
    ax.set_ylabel('Density')
    ax.set_title('Multiplicity Distribution by Residue Class')
    ax.legend()

plt.tight_layout()
plt.savefig('collatz_topological_signatures.png', dpi=150, bbox_inches='tight')
print("Saved: collatz_topological_signatures.png")
