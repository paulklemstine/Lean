"""
Visualization: Subgroup Lattice Heatmap for S_3

This script creates a heatmap showing the Möbius function values μ(H, K)
for all pairs of subgroups H ≤ K in S_3. The heatmap reveals the
alternating-sign structure characteristic of Möbius inversion.

The key visual insight is that the Möbius matrix is the inverse of the
zeta matrix (the incidence matrix of the partial order), and its entries
exhibit the sign-alternation pattern that drives the exact formula.
"""

import matplotlib.pyplot as plt
import numpy as np
import itertools
from collections import defaultdict

# ── Self-contained permutation utilities ──

def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    inv = [0] * len(p)
    for i in range(len(p)):
        inv[p[i]] = i
    return tuple(inv)

def identity(n):
    return tuple(range(n))

def generated_subgroup(gens, n):
    e = identity(n)
    subgroup = {e}
    for g in gens:
        subgroup.add(g)
    queue = list(subgroup - {e})
    while queue:
        g = queue.pop(0)
        for h in list(subgroup):
            for new in [compose(g, h), compose(h, g), inverse(g)]:
                if new not in subgroup:
                    subgroup.add(new)
                    queue.append(new)
    return frozenset(subgroup)

# ── Compute subgroup lattice of S_3 ──
n = 3
perms = list(itertools.permutations(range(n)))
subgroups_set = {frozenset([identity(n)]), frozenset(perms)}
for p in perms:
    subgroups_set.add(generated_subgroup([p], n))
for p in perms:
    for q in perms:
        subgroups_set.add(generated_subgroup([p, q], n))

# Sort by size
subgroups = sorted(subgroups_set, key=lambda s: len(s))
num_sg = len(subgroups)

# ── Compute full Möbius function μ(H, K) for all pairs ──

# First compute zeta matrix (incidence matrix)
zeta = np.zeros((num_sg, num_sg), dtype=int)
for i in range(num_sg):
    for j in range(num_sg):
        if subgroups[i] <= subgroups[j]:
            zeta[i, j] = 1

# Compute Möbius function by recursion
mu = np.zeros((num_sg, num_sg), dtype=int)
for i in range(num_sg):
    mu[i, i] = 1  # μ(H, H) = 1
for i in range(num_sg):
    for j in range(i + 1, num_sg):
        if subgroups[i] <= subgroups[j]:
            # μ(i, j) = -Σ_{i ≤ k < j} μ(i, k)
            mu[i, j] = -sum(mu[i, k] for k in range(i, j) if subgroups[k] <= subgroups[j] and k != j)

# ── Create labels ──
labels = []
for sg in subgroups:
    if len(sg) == 1:
        labels.append('{e}')
    elif len(sg) == len(perms):
        labels.append(f'S_{n}')
    elif len(sg) == len(perms) // 2 and n >= 3:
        labels.append(f'A_{n}')
    else:
        labels.append(f'|H|={len(sg)}')

# Deduplicate labels
seen = defaultdict(int)
unique_labels = []
for l in labels:
    if seen[l] > 0:
        unique_labels.append(f'{l}({seen[l]+1})')
    else:
        unique_labels.append(l)
    seen[l] += 1

# ── Plot ──
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Zeta matrix
im1 = ax1.imshow(zeta, cmap='YlOrRd', aspect='equal', interpolation='nearest')
ax1.set_xticks(range(num_sg))
ax1.set_yticks(range(num_sg))
ax1.set_xticklabels(unique_labels, rotation=45, ha='right', fontsize=9)
ax1.set_yticklabels(unique_labels, fontsize=9)
ax1.set_title(f'Zeta Matrix ζ(H, K) for $S_{n}$\n(1 if H ≤ K, else 0)', fontsize=13)
for i in range(num_sg):
    for j in range(num_sg):
        ax1.text(j, i, str(zeta[i, j]), ha='center', va='center', fontsize=10,
                color='white' if zeta[i, j] else 'gray')
plt.colorbar(im1, ax=ax1, shrink=0.8)

# Right: Möbius matrix
vmax = max(abs(mu.min()), abs(mu.max()))
im2 = ax2.imshow(mu, cmap='RdBu_r', aspect='equal', interpolation='nearest',
                  vmin=-vmax, vmax=vmax)
ax2.set_xticks(range(num_sg))
ax2.set_yticks(range(num_sg))
ax2.set_xticklabels(unique_labels, rotation=45, ha='right', fontsize=9)
ax2.set_yticklabels(unique_labels, fontsize=9)
ax2.set_title(f'Möbius Matrix μ(H, K) for $S_{n}$\n(inverse of zeta matrix)', fontsize=13)
for i in range(num_sg):
    for j in range(num_sg):
        val = mu[i, j]
        color = 'black' if abs(val) <= vmax/2 else 'white'
        ax2.text(j, i, str(val), ha='center', va='center', fontsize=10, color=color)
plt.colorbar(im2, ax=ax2, shrink=0.8)

plt.suptitle(f'Incidence Algebra of the Subgroup Lattice of $S_{n}$\n'
             f'({num_sg} subgroups; ζ · μ = Identity)',
             fontsize=14, fontweight='bold', y=1.05)
plt.tight_layout()
plt.savefig('viz_subgroup_lattice.png', dpi=150, bbox_inches='tight')
print("Saved viz_subgroup_lattice.png")

# Verify: zeta @ mu should be identity
product = zeta @ mu
assert np.allclose(product, np.eye(num_sg)), "Zeta * Mu != Identity!"
print(f"Verified: ζ · μ = I for S_{n} ({num_sg}×{num_sg} matrices)")
