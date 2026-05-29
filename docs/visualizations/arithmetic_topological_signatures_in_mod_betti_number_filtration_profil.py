#!/usr/bin/env python3
"""
Visualization: Betti Number Profile Across Filtration Levels

This script visualizes how the first Betti number β₁ changes across
filtration levels for different primes. The filtration is by branch
multiplicity: at level ℓ, only vertices with μ(x) ≥ ℓ are included.

The key prediction is that primes in different congruence classes
exhibit qualitatively different Betti profiles — this is the
"arithmetic phase transition" phenomenon.
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


def compute_betti_profile(p, K):
    adj, all_edges = build_symmetric_graph(p, K)
    multiplicities = {x: branch_multiplicity(p, K, x) for x in range(p)}
    max_level = max(multiplicities.values()) if multiplicities else 0
    profile = []
    for level in range(max_level + 1):
        vertices = {x for x, m in multiplicities.items() if m >= level}
        if not vertices:
            break
        filtered_edges = {(u, v) for (u, v) in all_edges if u in vertices and v in vertices}
        adj_restricted = defaultdict(set)
        for (u, v) in filtered_edges:
            adj_restricted[u].add(v)
            adj_restricted[v].add(u)
        c = connected_components(dict(adj_restricted), vertices)
        beta1 = len(filtered_edges) - len(vertices) + c
        profile.append((level, len(vertices), len(filtered_edges), c, beta1))
    return profile


K = 10
primes = [p for p in range(5, 100) if is_prime(p)]

fig, axes = plt.subplots(2, 2, figsize=(16, 12))
fig.suptitle('Betti Number Profiles and Filtration Analysis', fontsize=14, fontweight='bold')

# Panel 1: β₁ profiles for selected primes
ax = axes[0, 0]
sample_primes = [7, 13, 17, 23, 31, 41, 47, 59, 67, 73]
colors = plt.cm.tab10(np.linspace(0, 1, len(sample_primes)))

for p, color in zip(sample_primes, colors):
    profile = compute_betti_profile(p, K)
    levels = [pr[0] for pr in profile]
    beta1s = [pr[4] / p for pr in profile]  # normalize
    d = multiplicative_order(2, p)
    ax.plot(levels, beta1s, 'o-', color=color, markersize=4,
            label=f'p={p} (d={d})', alpha=0.8)

ax.set_xlabel('Filtration level ℓ')
ax.set_ylabel('Normalized β₁/p')
ax.set_title('β₁ Profile Across Filtration')
ax.legend(fontsize=7, ncol=2)
ax.grid(True, alpha=0.3)

# Panel 2: Total persistence surrogate by residue class
ax = axes[0, 1]
class_persistence = defaultdict(list)
for p in primes:
    profile = compute_betti_profile(p, K)
    total = sum(pr[4] for pr in profile) / p  # total β₁ normalized
    class_persistence[p % 8].append((p, total))

for r in sorted(class_persistence.keys()):
    data = class_persistence[r]
    ps, totals = zip(*data)
    ax.scatter(ps, totals, label=f'p ≡ {r} (mod 8)', s=30, alpha=0.7)

ax.set_xlabel('Prime p')
ax.set_ylabel('Total persistence (Σβ₁)/p')
ax.set_title('Total Persistence Surrogate by Residue Class')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 3: Vertex count vs filtration level
ax = axes[1, 0]
for p in [11, 23, 41, 59, 79, 97]:
    if not is_prime(p): continue
    profile = compute_betti_profile(p, K)
    levels = [pr[0] for pr in profile]
    verts = [pr[1] / p for pr in profile]
    ax.plot(levels, verts, 'o-', markersize=4, label=f'p={p}', alpha=0.8)

ax.set_xlabel('Filtration level ℓ')
ax.set_ylabel('Fraction of vertices')
ax.set_title('Vertex Survival in Filtration')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 4: Edge density vs filtration level
ax = axes[1, 1]
for p in [11, 23, 41, 59, 79, 97]:
    if not is_prime(p): continue
    profile = compute_betti_profile(p, K)
    levels = [pr[0] for pr in profile]
    if any(pr[1] > 0 for pr in profile):
        densities = [2 * pr[2] / (pr[1] * (pr[1] - 1)) if pr[1] > 1 else 0 for pr in profile]
        ax.plot(levels, densities, 'o-', markersize=4, label=f'p={p}', alpha=0.8)

ax.set_xlabel('Filtration level ℓ')
ax.set_ylabel('Edge density')
ax.set_title('Edge Density vs Filtration Level')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('collatz_betti_profiles.png', dpi=150, bbox_inches='tight')
print("Saved: collatz_betti_profiles.png")
