"""
Visualization 3: Phase Transition in Tropical Kernel Feasibility

Shows how the probability of tropical kernel nonemptiness varies with
graph density and weight range. For random graphs with integer weights
in [-W, W], larger W increases the chance of weight degeneracy (two
neighbors achieving equal minimum values), making kernel feasibility
more likely. This illustrates the conjectured phase transition.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iproduct


def wnv_val(w_dict, phi, i, j):
    return w_dict.get((i, j), 0) + phi[j]


def is_balanced(adj, w_dict, phi, v):
    nbrs = adj.get(v, [])
    if len(nbrs) < 2:
        return False
    values = [wnv_val(w_dict, phi, v, j) for j in nbrs]
    min_val = min(values)
    return sum(1 for val in values if val == min_val) >= 2


def kernel_check(n, adj, w_dict, phi):
    return all(is_balanced(adj, w_dict, phi, v) for v in range(n))


def brute_search_small(n, adj, w_dict, bound=6):
    others = list(range(1, n))
    for combo in iproduct(range(-bound, bound + 1), repeat=len(others)):
        phi = {0: 0}
        for i, v in enumerate(others):
            phi[v] = combo[i]
        if kernel_check(n, adj, w_dict, phi):
            return True
    return False


np.random.seed(123)

n = 4  # Fixed graph size
edge_probs = [0.5, 0.7, 0.9, 1.0]
weight_ranges = list(range(1, 8))
n_trials = 30

fig, ax = plt.subplots(figsize=(9, 6))

for p in edge_probs:
    feasibility_rates = []
    for W in weight_ranges:
        feasible_count = 0
        valid_count = 0
        for _ in range(n_trials):
            adj = {v: [] for v in range(n)}
            w_dict = {}
            for i in range(n):
                for j in range(i + 1, n):
                    if np.random.random() < p:
                        weight = np.random.randint(-W, W + 1)
                        adj[i].append(j)
                        adj[j].append(i)
                        w_dict[(i, j)] = weight
                        w_dict[(j, i)] = weight

            # Check min degree >= 2
            min_deg = min(len(adj[v]) for v in range(n))
            if min_deg < 2:
                continue
            valid_count += 1

            if brute_search_small(n, adj, w_dict, bound=6):
                feasible_count += 1

        rate = feasible_count / max(valid_count, 1)
        feasibility_rates.append(rate)

    ax.plot(weight_ranges, feasibility_rates, 'o-', linewidth=2,
            markersize=7, label=f'Edge prob. p={p}')

ax.set_xlabel('Weight range W (weights in [-W, W])', fontsize=13)
ax.set_ylabel('Fraction with nonempty tropical kernel', fontsize=13)
ax.set_title(f'Tropical Kernel Feasibility vs. Weight Range (n={n})',
             fontsize=14)
ax.legend(fontsize=11)
ax.set_ylim(-0.05, 1.05)
ax.grid(True, alpha=0.3)

# Add annotation
ax.annotate('Higher density → more\nredundant routes → more balance',
            xy=(5, 0.9), fontsize=10, style='italic',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150)
print("Saved: phase_transition.png")
