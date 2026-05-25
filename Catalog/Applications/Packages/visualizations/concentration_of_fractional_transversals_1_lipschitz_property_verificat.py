"""
Visualization 2: 1-Lipschitz Property of τ* Under Edge Addition.

Visualizes the proven theorem: |τ*(H ∪ {e}) - τ*(H)| ≤ 1 for any edge e.
Shows that the change in τ* is always bounded by 1, while the change in τ
can equal 1 with much higher probability (creating "jumps").
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from scipy.optimize import linprog


def compute_tau_star(n, edges):
    m = len(edges)
    if m == 0:
        return 0.0
    c = np.ones(n)
    A_ub = np.zeros((m, n))
    for i, edge in enumerate(edges):
        for v in edge:
            A_ub[i, v] = -1.0
    b_ub = -np.ones(m)
    bounds = [(0, None)] * n
    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
    return result.fun if result.success else 0.0


def compute_tau(n, edges):
    if not edges:
        return 0
    try:
        from scipy.optimize import milp, LinearConstraint, Bounds
        c_obj = np.ones(n)
        A = np.zeros((len(edges), n))
        for i, edge in enumerate(edges):
            for v in edge:
                A[i, v] = 1.0
        constraints = LinearConstraint(A, lb=1.0)
        integrality = np.ones(n)
        bounds = Bounds(lb=0, ub=1)
        result = milp(c_obj, constraints=constraints, integrality=integrality, bounds=bounds)
        if result.success:
            return int(round(result.fun))
    except ImportError:
        pass
    for size in range(n + 1):
        for subset in combinations(range(n), size):
            s = set(subset)
            if all(s & set(e) for e in edges):
                return size
    return n


n = 15
k = 3
c_param = 2.0
p = c_param / (n ** (k - 1))
rng = np.random.default_rng(42)
num_trials = 500

deltas_star = []
deltas_int = []

for _ in range(num_trials):
    # Generate base hypergraph
    edges = [frozenset(combo) for combo in combinations(range(n), k)
             if rng.random() < p]

    ts_before = compute_tau_star(n, edges)
    ti_before = compute_tau(n, edges)

    # Add a random edge
    new_verts = tuple(sorted(rng.choice(n, size=k, replace=False)))
    new_edge = frozenset(new_verts)
    edges_new = list(set(edges + [new_edge]))

    ts_after = compute_tau_star(n, edges_new)
    ti_after = compute_tau(n, edges_new)

    deltas_star.append(ts_after - ts_before)
    deltas_int.append(ti_after - ti_before)

deltas_star = np.array(deltas_star)
deltas_int = np.array(deltas_int)

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Histogram of Δτ*
ax1 = axes[0]
bins_star = np.linspace(-0.1, 1.1, 50)
ax1.hist(deltas_star, bins=bins_star, density=True, alpha=0.7,
         color='steelblue', edgecolor='black', linewidth=0.5)
ax1.axvline(x=0, color='gray', linestyle='--', alpha=0.5)
ax1.axvline(x=1, color='red', linestyle='--', alpha=0.7, label='Upper bound = 1')
ax1.set_xlabel(r'$\Delta\tau^* = \tau^*(H \cup \{e\}) - \tau^*(H)$', fontsize=12)
ax1.set_ylabel('Density', fontsize=12)
ax1.set_title(r'Change in $\tau^*$ when adding one edge', fontsize=13)
ax1.legend(fontsize=11)
ax1.text(0.5, 0.85, f'Mean: {np.mean(deltas_star):.3f}\nMax: {np.max(deltas_star):.3f}',
         transform=ax1.transAxes, fontsize=11,
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

# Histogram of Δτ
ax2 = axes[1]
unique_vals, counts = np.unique(deltas_int, return_counts=True)
ax2.bar(unique_vals, counts / len(deltas_int), width=0.3, alpha=0.7,
        color='coral', edgecolor='black', linewidth=0.5)
ax2.set_xlabel(r'$\Delta\tau = \tau(H \cup \{e\}) - \tau(H)$', fontsize=12)
ax2.set_ylabel('Probability', fontsize=12)
ax2.set_title(r'Change in $\tau$ when adding one edge', fontsize=13)
ax2.set_xticks(sorted(unique_vals))

# Annotate probabilities
for v, c in zip(unique_vals, counts):
    ax2.text(v, c/len(deltas_int) + 0.02, f'{c/len(deltas_int):.2f}',
             ha='center', fontsize=10)

plt.suptitle(f'1-Lipschitz Property: Edge Addition Sensitivity\n'
             f'(n={n}, k={k}, p={p:.4f}, {num_trials} trials)',
             fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('lipschitz_property.png', dpi=150, bbox_inches='tight')
print(f"Max |Δτ*| = {np.max(np.abs(deltas_star)):.6f} (should be ≤ 1)")
print(f"All Δτ* in [0, 1]: {np.all((deltas_star >= -1e-8) & (deltas_star <= 1 + 1e-8))}")
print("Saved: lipschitz_property.png")
