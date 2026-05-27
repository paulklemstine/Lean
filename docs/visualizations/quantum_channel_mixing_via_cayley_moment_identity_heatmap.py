"""
Visualization: Purity-Return Probability Identity Heatmap

Shows the walk distribution on S₃ evolving over time, and demonstrates
the exact match between walkPurity(k) and momentKernel(2k) via a
side-by-side comparison heatmap.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations
from collections import defaultdict


# --- Inline group operations ---
def compose_perm(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse_perm(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)

def identity_perm(n):
    return tuple(range(n))

def symmetric_group(n):
    return [tuple(p) for p in permutations(range(n))]

def default_generators(n):
    sigma = list(range(n))
    sigma[0], sigma[1] = sigma[1], sigma[0]
    tau = tuple((i + 1) % n for i in range(n))
    return tuple(sigma), tau


n = 3
G = symmetric_group(n)
sigma, tau = default_generators(n)
gens = [sigma, inverse_perm(sigma), tau, inverse_perm(tau)]
g_to_idx = {g: i for i, g in enumerate(G)}
group_size = len(G)

# Labels for group elements
perm_labels = [str(g) for g in G]

# Compute distributions for k = 0 to 6
max_k = 6
distributions = []
for k in range(max_k + 1):
    dist = defaultdict(float)
    dist[identity_perm(n)] = 1.0
    weight = 0.25
    for _ in range(k):
        new_dist = defaultdict(float)
        for x, px in dist.items():
            if px == 0: continue
            for g in gens:
                new_dist[compose_perm(g, x)] += weight * px
        dist = new_dist
    distributions.append(dist)

fig = plt.figure(figsize=(16, 10))

# Top: Distribution evolution heatmap
ax1 = fig.add_subplot(2, 1, 1)
dist_matrix = np.zeros((max_k + 1, group_size))
for k, dist in enumerate(distributions):
    for g, p in dist.items():
        dist_matrix[k, g_to_idx[g]] = p

im = ax1.imshow(dist_matrix, aspect='auto', cmap='YlOrRd', interpolation='nearest')
ax1.set_xlabel('Group element index', fontsize=12)
ax1.set_ylabel('Steps k', fontsize=12)
ax1.set_title('Walk Distribution on S₃: Evolution from Point Mass to Uniform',
              fontsize=14, fontweight='bold')
plt.colorbar(im, ax=ax1, label='Probability')
ax1.set_yticks(range(max_k + 1))

# Bottom: Purity vs Return Probability comparison
ax2 = fig.add_subplot(2, 1, 2)

ks = list(range(max_k + 1))
purities = []
return_probs = []
for k in ks:
    # Purity
    dist_k = distributions[k]
    pur = sum(p**2 for p in dist_k.values())
    purities.append(pur)

    # Return probability at 2k
    dist_2k = defaultdict(float)
    dist_2k[identity_perm(n)] = 1.0
    weight = 0.25
    for _ in range(2 * k):
        new_dist = defaultdict(float)
        for x, px in dist_2k.items():
            if px == 0: continue
            for g in gens:
                new_dist[compose_perm(g, x)] += weight * px
        dist_2k = new_dist
    return_probs.append(dist_2k.get(identity_perm(n), 0.0))

width = 0.35
x = np.array(ks)
bars1 = ax2.bar(x - width/2, purities, width, label='walkPurity(k)',
                color='steelblue', edgecolor='black', linewidth=0.5)
bars2 = ax2.bar(x + width/2, return_probs, width, label='momentKernel(2k)',
                color='coral', edgecolor='black', linewidth=0.5)

ax2.axhline(y=1.0/group_size, color='gray', linestyle=':', linewidth=2,
            label=f'Uniform: 1/{group_size}')

ax2.set_xlabel('Steps k', fontsize=12)
ax2.set_ylabel('Value', fontsize=12)
ax2.set_title('Main Theorem: walkPurity(k) = momentKernel(2k) — Exact Match',
              fontsize=14, fontweight='bold')
ax2.legend(fontsize=11)
ax2.set_xticks(ks)
ax2.grid(True, alpha=0.3, axis='y')

# Add difference annotations
for k in ks:
    diff = abs(purities[k] - return_probs[k])
    if k <= 3:
        ax2.annotate(f'Δ={diff:.1e}', xy=(k, max(purities[k], return_probs[k])),
                     xytext=(0, 10), textcoords='offset points',
                     fontsize=8, ha='center', color='green')

plt.tight_layout()
plt.savefig('identity_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved identity_heatmap.png")
