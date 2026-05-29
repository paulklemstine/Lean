#!/usr/bin/env python3
"""
Visualization: Phase Transition Diagram for Modular Collatz Topology

This script produces a phase transition diagram showing how topological
invariants of modular Collatz graphs vary with the prime p and the
multiplicative order ord_p(2). The key insight is that primes with
different arithmetic properties (encoded by ord_p(2) and residue class)
exhibit distinct topological phases.
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


K = 12
primes = [p for p in range(5, 250) if is_prime(p)]

# Compute all data
data = []
for p in primes:
    d = multiplicative_order(2, p)
    adj, edges = build_symmetric_graph(p, K)
    vertices = set(range(p))
    c = connected_components(adj, vertices)
    beta1 = len(edges) - len(vertices) + c

    # Check if -3 ∈ ⟨2⟩
    subgroup = set()
    val = 1
    for _ in range(d):
        subgroup.add(val)
        val = (val * 2) % p
    neg3_in = ((-3) % p) in subgroup

    data.append({
        'p': p, 'd': d, 'beta1': beta1, 'beta1_norm': beta1/p,
        'edges': len(edges), 'edge_density': 2*len(edges)/(p*(p-1)),
        'neg3_in': neg3_in, 'mod8': p % 8,
    })

fig, axes = plt.subplots(2, 2, figsize=(16, 12))
fig.suptitle('Phase Transition Diagram: Arithmetic Control of Collatz Topology',
             fontsize=14, fontweight='bold')

# Panel 1: Phase diagram (ord vs β₁/p, colored by -3 ∈ ⟨2⟩)
ax = axes[0, 0]
for d_item in data:
    color = '#e41a1c' if d_item['neg3_in'] else '#377eb8'
    marker = 'o' if d_item['neg3_in'] else 's'
    ax.scatter(d_item['d'] / d_item['p'], d_item['beta1_norm'],
              c=color, marker=marker, s=25, alpha=0.6)

ax.scatter([], [], c='#e41a1c', marker='o', label='-3 ∈ ⟨2⟩')
ax.scatter([], [], c='#377eb8', marker='s', label='-3 ∉ ⟨2⟩')
ax.set_xlabel('Normalized order d/p')
ax.set_ylabel('β₁/p')
ax.set_title('Phase Diagram: Subgroup Condition')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: β₁/p vs p, with trend lines for each mod 8 class
ax = axes[0, 1]
mod_colors = {1: '#e41a1c', 3: '#377eb8', 5: '#4daf4a', 7: '#984ea3'}
mod_data = defaultdict(lambda: ([], []))

for d_item in data:
    m = d_item['mod8']
    if m in mod_colors:
        mod_data[m][0].append(d_item['p'])
        mod_data[m][1].append(d_item['beta1_norm'])

for m in sorted(mod_colors.keys()):
    ps, betas = mod_data[m]
    if ps:
        ax.scatter(ps, betas, c=mod_colors[m], s=20, alpha=0.5, label=f'p ≡ {m} (mod 8)')
        # Moving average
        if len(ps) > 3:
            sorted_idx = np.argsort(ps)
            ps_sorted = np.array(ps)[sorted_idx]
            betas_sorted = np.array(betas)[sorted_idx]
            window = min(5, len(ps_sorted))
            ma = np.convolve(betas_sorted, np.ones(window)/window, mode='valid')
            ax.plot(ps_sorted[window-1:], ma, c=mod_colors[m], linewidth=2, alpha=0.8)

ax.set_xlabel('Prime p')
ax.set_ylabel('β₁/p')
ax.set_title('Topology by Residue Class (mod 8)')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 3: Edge density vs ord/p
ax = axes[1, 0]
for d_item in data:
    ax.scatter(d_item['d'] / d_item['p'], d_item['edge_density'],
              c=d_item['p'], cmap='viridis', s=20, alpha=0.6)
ax.set_xlabel('Normalized order d/p')
ax.set_ylabel('Edge density 2|E|/(p(p-1))')
ax.set_title('Edge Density vs Multiplicative Order')
ax.grid(True, alpha=0.3)

# Panel 4: Statistical test - within vs between class variance
ax = axes[1, 1]
moduli = [4, 6, 8, 10, 12]
within_vars = []
between_vars = []

for M in moduli:
    class_vals = defaultdict(list)
    for d_item in data:
        class_vals[d_item['p'] % M].append(d_item['beta1_norm'])

    means = []
    vars_list = []
    for r, vals in class_vals.items():
        if len(vals) >= 3:
            means.append(np.mean(vals))
            vars_list.append(np.var(vals))

    if len(means) >= 2:
        within_vars.append(np.mean(vars_list))
        between_vars.append(np.var(means))

ax.bar(np.arange(len(moduli)) - 0.15, within_vars, 0.3,
       label='Within-class var', color='#377eb8', alpha=0.7)
ax.bar(np.arange(len(moduli)) + 0.15, between_vars, 0.3,
       label='Between-class var', color='#e41a1c', alpha=0.7)
ax.set_xticks(range(len(moduli)))
ax.set_xticklabels([f'mod {M}' for M in moduli])
ax.set_ylabel('Variance')
ax.set_title('Within vs Between Class Variance')
ax.legend()
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('collatz_phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved: collatz_phase_transition.png")
