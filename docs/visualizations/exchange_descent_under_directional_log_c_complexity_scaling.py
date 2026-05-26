#!/usr/bin/env python3
"""
Visualization 2: Complexity Scaling of Exchange Descent

Plots the empirical relationship between problem size (n, |S|) and the number
of exchange descent steps required to reach the global optimum. Tests the
conjectural bound O(|α|^{d-k} · diam(S)).

Self-contained — all functions defined inline.
"""

import itertools
import numpy as np
import matplotlib.pyplot as plt


def make_bases(n, r):
    bases = set()
    for subset in itertools.combinations(range(n), r):
        v = tuple(1 if i in subset else 0 for i in range(n))
        bases.add(v)
    return bases, n


def run_descent(carrier, n, f, x0):
    x = x0
    steps = 0
    while True:
        best = None
        best_val = f(x)
        for i in range(n):
            for j in range(n):
                if i == j:
                    continue
                y = list(x)
                y[i] += 1
                y[j] -= 1
                y = tuple(y)
                if y in carrier and f(y) < best_val - 1e-15:
                    best_val = f(y)
                    best = y
        if best is None:
            break
        x = best
        steps += 1
    return steps


# Collect data
configs = [
    (4, 2), (5, 2), (6, 2), (6, 3), (7, 3), (8, 3), (8, 4), (9, 4), (10, 4), (10, 5)
]

results = []
for n, r in configs:
    carrier, dim = make_bases(n, r)
    num_bases = len(carrier)

    if num_bases > 1000:
        continue

    # Use structured weights for reproducibility
    weights = np.arange(n, 0, -1, dtype=float)
    f = lambda x, w=weights: float(sum(w[i] * x[i] for i in range(len(x))))

    all_steps = []
    for b in carrier:
        s = run_descent(carrier, dim, f, b)
        all_steps.append(s)

    avg_steps = np.mean(all_steps)
    max_steps = max(all_steps)

    # Compute diameter
    bases_list = list(carrier)
    diam = 0
    for b1 in bases_list[:50]:
        for b2 in bases_list[:50]:
            d = sum(abs(b1[k] - b2[k]) for k in range(n))
            diam = max(diam, d)

    results.append({
        'n': n, 'r': r, 'num_bases': num_bases,
        'avg_steps': avg_steps, 'max_steps': max_steps,
        'diameter': diam
    })

# Plot
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: max steps vs |S|
ns = [r['num_bases'] for r in results]
max_steps = [r['max_steps'] for r in results]
avg_steps = [r['avg_steps'] for r in results]

axes[0].scatter(ns, max_steps, c='crimson', s=80, zorder=3, label='Max steps')
axes[0].scatter(ns, avg_steps, c='steelblue', s=80, zorder=3, label='Avg steps')
axes[0].plot([min(ns), max(ns)], [min(ns), max(ns)], 'k--', alpha=0.3, label='y = |S|')
axes[0].set_xlabel('|S| (number of bases)', fontsize=12)
axes[0].set_ylabel('Descent steps', fontsize=12)
axes[0].set_title('Steps vs Feasible Set Size', fontsize=13, fontweight='bold')
axes[0].legend()
axes[0].set_xscale('log')
axes[0].set_yscale('log')

# Plot 2: max steps vs dimension n
dims = [r['n'] for r in results]
axes[1].scatter(dims, max_steps, c='crimson', s=80, zorder=3, label='Max steps')
axes[1].scatter(dims, avg_steps, c='steelblue', s=80, zorder=3, label='Avg steps')
axes[1].set_xlabel('Dimension n', fontsize=12)
axes[1].set_ylabel('Descent steps', fontsize=12)
axes[1].set_title('Steps vs Dimension', fontsize=13, fontweight='bold')
axes[1].legend()

# Plot 3: steps / diameter ratio
diams = [r['diameter'] for r in results]
ratios = [r['max_steps'] / max(r['diameter'], 1) for r in results]
axes[2].bar(range(len(results)), ratios, color='mediumpurple', alpha=0.8)
axes[2].set_xticks(range(len(results)))
axes[2].set_xticklabels([f"U({r['r']},{r['n']})" for r in results],
                         rotation=45, ha='right', fontsize=9)
axes[2].set_ylabel('Max steps / Diameter', fontsize=12)
axes[2].set_title('Normalized Complexity', fontsize=13, fontweight='bold')
axes[2].axhline(y=1, color='gray', linestyle='--', alpha=0.5, label='ratio = 1')
axes[2].legend()

plt.suptitle('Exchange Descent: Empirical Complexity Scaling',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_complexity_scaling.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_complexity_scaling.png")
