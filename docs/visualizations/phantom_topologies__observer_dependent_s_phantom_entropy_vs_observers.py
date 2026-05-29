"""
Visualization: Phantom Entropy vs Number of Observers
======================================================
Shows how phantom entropy (average pairwise disagreement) changes as
we add observers to a phantom system. Illustrates the key theorem:
adding observers can only increase entropy (more disagreement to average)
but the consensus topology becomes coarser (more agreement required).
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations, chain
import random

random.seed(42)


def powerset(s):
    s = list(s)
    return list(chain.from_iterable(combinations(s, r) for r in range(len(s) + 1)))


def is_topology(X, opens):
    opens_set = {frozenset(o) for o in opens}
    X_frozen = frozenset(X)
    if frozenset() not in opens_set or X_frozen not in opens_set:
        return False
    for a in opens_set:
        for b in opens_set:
            if (a & b) not in opens_set:
                return False
    opens_list = list(opens_set)
    for subset_indices in powerset(list(range(len(opens_list)))):
        union = frozenset()
        for i in subset_indices:
            union = union | opens_list[i]
        if union not in opens_set:
            return False
    return True


def enumerate_topologies(X):
    all_subsets = [tuple(sorted(s)) for s in powerset(X)]
    topologies = []
    for r in range(len(all_subsets) + 1):
        for combo in combinations(all_subsets, r):
            if is_topology(X, list(combo)):
                topologies.append({frozenset(o) for o in combo})
    return topologies


def consensus_size(topologies):
    if not topologies:
        return 0
    result = topologies[0].copy()
    for t in topologies[1:]:
        result &= t
    return len(result)


def phantom_entropy(topologies, total_subsets):
    n = len(topologies)
    if n <= 1:
        return 0.0
    total = 0
    pairs = 0
    for i in range(n):
        for j in range(i + 1, n):
            total += len(topologies[i].symmetric_difference(topologies[j]))
            pairs += 1
    return total / (pairs * total_subsets) if pairs > 0 else 0.0


# Setup
X = [0, 1, 2]
all_tops = enumerate_topologies(X)
total_subsets = 2 ** len(X)

# Run multiple trials of adding random observers
num_trials = 50
max_observers = min(len(all_tops), 15)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# ---- Left: Entropy vs observers ----
all_entropies = []
all_consensus_sizes = []

for trial in range(num_trials):
    shuffled = random.sample(all_tops, min(max_observers, len(all_tops)))
    entropies = []
    con_sizes = []
    for k in range(1, len(shuffled) + 1):
        subset = shuffled[:k]
        ent = phantom_entropy(subset, total_subsets)
        cs = consensus_size(subset)
        entropies.append(ent)
        con_sizes.append(cs)
    all_entropies.append(entropies)
    all_consensus_sizes.append(con_sizes)

# Plot individual trials (faint)
for entropies in all_entropies:
    ax1.plot(range(1, len(entropies) + 1), entropies,
             color='#2196F3', alpha=0.1, linewidth=0.5)

# Plot average
max_len = max(len(e) for e in all_entropies)
avg_ent = []
for k in range(max_len):
    vals = [e[k] for e in all_entropies if k < len(e)]
    avg_ent.append(np.mean(vals))

ax1.plot(range(1, len(avg_ent) + 1), avg_ent,
         color='#1565C0', linewidth=2.5, label='Average', zorder=10)

ax1.set_xlabel('Number of Observers', fontsize=12)
ax1.set_ylabel('Phantom Entropy', fontsize=12)
ax1.set_title('Phantom Entropy vs Observers', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# ---- Right: Consensus size vs observers ----
for con_sizes in all_consensus_sizes:
    ax2.plot(range(1, len(con_sizes) + 1), con_sizes,
             color='#FF9800', alpha=0.1, linewidth=0.5)

avg_con = []
for k in range(max_len):
    vals = [c[k] for c in all_consensus_sizes if k < len(c)]
    avg_con.append(np.mean(vals))

ax2.plot(range(1, len(avg_con) + 1), avg_con,
         color='#E65100', linewidth=2.5, label='Average', zorder=10)

ax2.set_xlabel('Number of Observers', fontsize=12)
ax2.set_ylabel('Consensus Size (# open sets)', fontsize=12)
ax2.set_title('Consensus Size vs Observers', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Add annotation
ax2.axhline(y=2, color='red', linestyle='--', alpha=0.5)
ax2.text(max_len * 0.6, 2.3, 'Indiscrete (minimum)',
         fontsize=9, color='red', alpha=0.7)

plt.tight_layout()
plt.savefig('viz_phantom_entropy.png', dpi=150, bbox_inches='tight')
print("Saved viz_phantom_entropy.png")
