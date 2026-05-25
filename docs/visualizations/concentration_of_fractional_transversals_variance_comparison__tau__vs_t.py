"""
Visualization 1: Variance Comparison — τ* vs τ across system sizes.

Visualizes the core phenomenon: the fractional transversal number τ* has
bounded variance while the integer transversal number τ has growing variance
on sparse random k-uniform hypergraphs. This is the empirical signature of
the "fractional smoothing" effect proved in the Lipschitz bound theorems.
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


# Parameters
k = 3
c_param = 2.0
ns = [8, 10, 12, 15, 18, 20]
num_samples = 200
rng = np.random.default_rng(42)

var_stars = []
var_ints = []

for n in ns:
    p = c_param / (n ** (k - 1))
    p = min(p, 1.0)
    stars = []
    ints = []
    for _ in range(num_samples):
        edges = [frozenset(combo) for combo in combinations(range(n), k)
                 if rng.random() < p]
        stars.append(compute_tau_star(n, edges))
        ints.append(compute_tau(n, edges))
    var_stars.append(np.var(stars, ddof=1))
    var_ints.append(np.var(ints, ddof=1))
    print(f"n={n}: Var(τ*)={var_stars[-1]:.4f}, Var(τ)={var_ints[-1]:.4f}")

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Variances
ax1 = axes[0]
ax1.plot(ns, var_stars, 'bo-', linewidth=2, markersize=8, label=r'Var($\tau^*$)')
ax1.plot(ns, var_ints, 'rs-', linewidth=2, markersize=8, label=r'Var($\tau$)')
ax1.set_xlabel('Number of vertices n', fontsize=12)
ax1.set_ylabel('Variance', fontsize=12)
ax1.set_title('Variance Comparison', fontsize=14)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Plot 2: Variance ratio
ax2 = axes[1]
ratios = [vi / max(vs, 1e-10) for vi, vs in zip(var_ints, var_stars)]
ax2.plot(ns, ratios, 'g^-', linewidth=2, markersize=8, color='purple')
ax2.set_xlabel('Number of vertices n', fontsize=12)
ax2.set_ylabel(r'Var($\tau$) / Var($\tau^*$)', fontsize=12)
ax2.set_title('Fluctuation Ratio', fontsize=14)
ax2.grid(True, alpha=0.3)
ax2.axhline(y=1, color='gray', linestyle='--', alpha=0.5)

# Plot 3: Fluctuation gap
ax3 = axes[2]
gaps = [vi - vs for vi, vs in zip(var_ints, var_stars)]
ax3.plot(ns, gaps, 'kD-', linewidth=2, markersize=8, color='darkgreen')
ax3.set_xlabel('Number of vertices n', fontsize=12)
ax3.set_ylabel(r'Var($\tau$) - Var($\tau^*$)', fontsize=12)
ax3.set_title('Fluctuation Gap', fontsize=14)
ax3.grid(True, alpha=0.3)
ax3.axhline(y=0, color='gray', linestyle='--', alpha=0.5)

plt.suptitle(f'Concentration of $\\tau^*$ vs $\\tau$ on Random {k}-Uniform Hypergraphs\n'
             f'(p = {c_param}/n², {num_samples} samples per size)',
             fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('concentration_comparison.png', dpi=150, bbox_inches='tight')
print("\nSaved: concentration_comparison.png")
