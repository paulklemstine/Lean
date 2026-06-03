#!/usr/bin/env python3
import matplotlib.pyplot as plt
import numpy as np
from collections import Counter
import random

def privacy_index_from_fibers(fibers):
    return sum(k * (k - 1) for k in fibers)

def balanced_privacy(n, k):
    q, r = divmod(n, k)
    return r * (q + 1) * q + (k - r) * q * (q - 1)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
n = 10
budget = n * (n - 1)
functions = {'Injective': list(range(10)), 'Mod 5': [x%5 for x in range(10)], 'Mod 3': [x%3 for x in range(10)], 'Mod 2': [x%2 for x in range(10)], 'Constant': [0]*10}
names = list(functions.keys())
pi_vals = [privacy_index_from_fibers(Counter(v).values()) for v in functions.values()]
sigma_vals = [budget - p for p in pi_vals]
ax = axes[0]
x_pos = np.arange(len(names))
ax.bar(x_pos, pi_vals, color='#2196F3', label='Privacy')
ax.bar(x_pos, sigma_vals, bottom=pi_vals, color='#FF5722', label='Surveillance')
ax.axhline(y=budget, color='black', linestyle='--', label=f'Budget={budget}')
ax.set_xticks(x_pos); ax.set_xticklabels(names, fontsize=8)
ax.set_title(f'Conservation Law (n={n})'); ax.legend(fontsize=8)
n = 20
k_values = list(range(1, n+1))
collision_prob = [balanced_privacy(n,k)/(n*(n-1)) for k in k_values]
utility = [k/n for k in k_values]
ax = axes[1]
ax.plot(collision_prob, utility, 'o-', color='#4CAF50', markersize=4)
ax.set_xlabel('Collision Probability'); ax.set_ylabel('Utility')
ax.set_title(f'Pareto Frontier (n={n})'); ax.grid(True, alpha=0.3)
n = 12; ax = axes[2]; random.seed(42)
for k in [2,3,4,6]:
    vals = []
    for _ in range(500):
        parts = [1]*k; rem = n-k
        for _ in range(rem): parts[random.randint(0,k-1)] += 1
        vals.append(privacy_index_from_fibers(parts))
    ax.hist(vals, alpha=0.4, label=f'k={k}', bins=range(min(vals),max(vals)+2))
    ax.axvline(x=balanced_privacy(n,k), color='red', linestyle='--', linewidth=1)
ax.set_title(f'Balanced Minimality (n={n})'); ax.legend(fontsize=8)
plt.tight_layout(); plt.savefig('conservation_viz.png', dpi=150); plt.close()