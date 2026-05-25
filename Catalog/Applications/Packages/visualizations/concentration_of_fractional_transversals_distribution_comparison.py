"""
Visualization 3: Distribution Comparison — τ* vs τ on Random Hypergraphs.

Shows the empirical distributions of τ* and τ side by side, illustrating
that τ* has a smoother, more concentrated distribution while τ has a
discrete, more spread-out distribution.
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


n = 20
k = 3
c_param = 2.0
p = c_param / (n ** (k - 1))
num_samples = 800
rng = np.random.default_rng(42)

tau_stars = []
tau_ints = []

for _ in range(num_samples):
    edges = [frozenset(combo) for combo in combinations(range(n), k)
             if rng.random() < p]
    tau_stars.append(compute_tau_star(n, edges))
    tau_ints.append(compute_tau(n, edges))

ts = np.array(tau_stars)
ti = np.array(tau_ints)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top left: τ* histogram
ax1 = axes[0, 0]
ax1.hist(ts, bins=40, density=True, alpha=0.7, color='steelblue',
         edgecolor='black', linewidth=0.5)
ax1.axvline(np.mean(ts), color='red', linestyle='--', linewidth=2,
            label=f'Mean = {np.mean(ts):.2f}')
ax1.set_xlabel(r'$\tau^*$', fontsize=13)
ax1.set_ylabel('Density', fontsize=12)
ax1.set_title(r'Distribution of $\tau^*$ (Fractional)', fontsize=13)
ax1.legend(fontsize=11)
ax1.text(0.7, 0.85, f'Var = {np.var(ts, ddof=1):.3f}',
         transform=ax1.transAxes, fontsize=12,
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Top right: τ histogram
ax2 = axes[0, 1]
unique_vals, counts = np.unique(ti, return_counts=True)
ax2.bar(unique_vals, counts / num_samples, width=0.6, alpha=0.7,
        color='coral', edgecolor='black', linewidth=0.5)
ax2.axvline(np.mean(ti), color='red', linestyle='--', linewidth=2,
            label=f'Mean = {np.mean(ti):.2f}')
ax2.set_xlabel(r'$\tau$', fontsize=13)
ax2.set_ylabel('Probability', fontsize=12)
ax2.set_title(r'Distribution of $\tau$ (Integer)', fontsize=13)
ax2.legend(fontsize=11)
ax2.text(0.7, 0.85, f'Var = {np.var(ti, ddof=1):.3f}',
         transform=ax2.transAxes, fontsize=12,
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Bottom left: Overlay comparison
ax3 = axes[1, 0]
ax3.hist(ts, bins=40, density=True, alpha=0.5, color='steelblue',
         label=r'$\tau^*$ (fractional)')
ax3.hist(ti, bins=range(int(min(ti))-1, int(max(ti))+3),
         density=True, alpha=0.4, color='coral',
         label=r'$\tau$ (integer)')
ax3.set_xlabel('Value', fontsize=13)
ax3.set_ylabel('Density', fontsize=12)
ax3.set_title('Overlay Comparison', fontsize=13)
ax3.legend(fontsize=11)

# Bottom right: Gap distribution
ax4 = axes[1, 1]
gaps = ti - ts
ax4.hist(gaps, bins=30, density=True, alpha=0.7, color='mediumpurple',
         edgecolor='black', linewidth=0.5)
ax4.axvline(np.mean(gaps), color='red', linestyle='--', linewidth=2,
            label=f'Mean gap = {np.mean(gaps):.2f}')
ax4.set_xlabel(r'$\tau - \tau^*$ (integrality gap)', fontsize=13)
ax4.set_ylabel('Density', fontsize=12)
ax4.set_title('Integrality Gap Distribution', fontsize=13)
ax4.legend(fontsize=11)
ax4.text(0.7, 0.85, f'Var = {np.var(gaps, ddof=1):.3f}',
         transform=ax4.transAxes, fontsize=12,
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.suptitle(f'Distribution Comparison: Random {k}-Uniform Hypergraphs\n'
             f'n={n}, p={c_param}/n², {num_samples} samples',
             fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('distribution_comparison.png', dpi=150, bbox_inches='tight')
print("Saved: distribution_comparison.png")
print(f"\nSummary:")
print(f"  Var(τ*) = {np.var(ts, ddof=1):.4f}")
print(f"  Var(τ)  = {np.var(ti, ddof=1):.4f}")
print(f"  Ratio   = {np.var(ti, ddof=1)/max(np.var(ts, ddof=1), 1e-10):.2f}")
