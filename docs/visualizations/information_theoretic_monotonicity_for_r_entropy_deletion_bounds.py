"""
Visualization: Entropy monotonicity under coordinate deletion.

Shows how Shannon entropy changes as coordinates are deleted from
robustly Lorentzian measures, demonstrating the certified bounds:
- H(π_k μ) ≤ H(μ)          (data processing inequality)
- H(π_k μ) ≥ H(μ) - log 2  (deletion lower bound)

Compares uniform matroids of different sizes to illustrate scaling.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import log, comb
from itertools import combinations

def xlogx(x):
    return x * np.log(x) if x > 0 else 0.0

def uniform_matroid_law(n, r):
    total = comb(n, r)
    return {frozenset(s): 1.0 / total for s in combinations(range(n), r)}

def total_entropy(law):
    return -sum(xlogx(w) for w in law.values())

def delete_coord_entropy(law, k):
    m = {}
    for s, w in law.items():
        t = s - {k}
        m[t] = m.get(t, 0.0) + w
    return -sum(xlogx(w) for w in m.values())

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Deletion entropy for different matroids
ax = axes[0]
for n, r, color in [(4, 2, '#2196F3'), (6, 3, '#4CAF50'), (8, 4, '#FF9800')]:
    law = uniform_matroid_law(n, r)
    H = total_entropy(law)
    del_H = [delete_coord_entropy(law, k) for k in range(n)]

    ax.bar([f'k={k}' for k in range(n)], del_H, alpha=0.7,
           label=f'U({n},{r})', color=color)
    ax.axhline(y=H, color=color, linestyle='--', alpha=0.5)
    ax.axhline(y=H - log(2), color=color, linestyle=':', alpha=0.5)

ax.set_ylabel('Entropy (nats)')
ax.set_title('Deletion Entropy by Coordinate')
ax.legend(fontsize=8)
ax.tick_params(axis='x', rotation=45, labelsize=7)

# Panel 2: Entropy drop vs log 2 bound
ax = axes[1]
ns = list(range(4, 11))
drops = []
for n in ns:
    r = n // 2
    law = uniform_matroid_law(n, r)
    H = total_entropy(law)
    max_drop = max(H - delete_coord_entropy(law, k) for k in range(n))
    drops.append(max_drop)

ax.plot(ns, drops, 'o-', color='#E91E63', label='Max entropy drop', linewidth=2)
ax.axhline(y=log(2), color='#9C27B0', linestyle='--', linewidth=2,
           label=f'log 2 = {log(2):.3f} (certified bound)')
ax.fill_between(ns, 0, log(2), alpha=0.1, color='#9C27B0')
ax.set_xlabel('Ground set size n')
ax.set_ylabel('Max entropy drop (nats)')
ax.set_title('Deletion Drop vs Certified Bound')
ax.legend(fontsize=8)

# Panel 3: Shearer bound check
ax = axes[2]
ns = list(range(4, 11))
entropies = []
avg_del_plus_log2 = []
for n in ns:
    r = n // 2
    law = uniform_matroid_law(n, r)
    H = total_entropy(law)
    avg_del = np.mean([delete_coord_entropy(law, k) for k in range(n)])
    entropies.append(H)
    avg_del_plus_log2.append(avg_del + log(2))

ax.plot(ns, entropies, 's-', color='#2196F3', label='H(μ)', linewidth=2)
ax.plot(ns, avg_del_plus_log2, '^-', color='#FF5722',
        label='avg H(π_k) + log 2 (Shearer bound)', linewidth=2)
ax.fill_between(ns, entropies, avg_del_plus_log2, alpha=0.15, color='#FF5722')
ax.set_xlabel('Ground set size n')
ax.set_ylabel('Entropy (nats)')
ax.set_title('Shearer Covering Inequality')
ax.legend(fontsize=8)

plt.suptitle('Entropy Monotonicity for Robustly Lorentzian Measures',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('entropy_deletion.png', dpi=150, bbox_inches='tight')
print("Saved entropy_deletion.png")
