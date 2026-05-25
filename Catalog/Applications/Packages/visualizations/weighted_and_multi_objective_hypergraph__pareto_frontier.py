#!/usr/bin/env python3
"""
Visualization 1: Pareto Frontier for Bi-Objective Hypergraph Transversals

Visualizes how threshold rounding maps fractional Pareto-optimal points
to integral points, demonstrating the d_max approximation guarantee.
The fractional Pareto frontier (convex) and integral rounded points
are shown together, with the d_max bound region shaded.
"""

import numpy as np
from scipy.optimize import linprog
import matplotlib.pyplot as plt


def solve_lp(n, edges, w):
    A_ub = [[-1.0 if v in e else 0.0 for v in range(n)] for e in edges]
    b_ub = [-1.0] * len(edges)
    res = linprog(w, A_ub=A_ub, b_ub=b_ub, bounds=[(0, None)]*n, method='highs')
    return (res.x, res.fun) if res.success else (None, None)


n = 20
rng = np.random.default_rng(42)
edges = []
for _ in range(15):
    k = rng.choice([2, 3, 4])
    e = tuple(sorted(rng.choice(n, size=k, replace=False)))
    edges.append(e)
edges = list(set(edges))
d_max = max(len(e) for e in edges)

c1 = rng.uniform(0.5, 5.0, size=n)
c2 = rng.uniform(0.5, 5.0, size=n)

lambdas = np.linspace(0.001, 0.999, 50)
frac_pts = []
int_pts = []

for lam in lambdas:
    w = lam * c1 + (1 - lam) * c2
    x, _ = solve_lp(n, edges, w)
    if x is None:
        continue
    frac_pts.append((np.dot(c1, x), np.dot(c2, x)))
    S = np.where(x >= 1.0/d_max - 1e-12)[0]
    ind = np.zeros(n); ind[S] = 1.0
    int_pts.append((np.dot(c1, ind), np.dot(c2, ind)))

frac_pts = np.array(frac_pts)
int_pts = np.array(int_pts)

fig, ax = plt.subplots(1, 1, figsize=(10, 8))

# d_max bound region
bound_x = np.linspace(0, frac_pts[:, 0].max() * d_max * 1.1, 100)
for fp in frac_pts:
    pass

ax.fill_between(
    [0, frac_pts[:, 0].max() * d_max * 1.2],
    [0, 0],
    [frac_pts[:, 1].max() * d_max * 1.2, frac_pts[:, 1].max() * d_max * 1.2],
    alpha=0.05, color='red', label=None
)

# Fractional Pareto frontier
sorted_idx = np.argsort(frac_pts[:, 0])
ax.plot(frac_pts[sorted_idx, 0], frac_pts[sorted_idx, 1],
        'b-o', markersize=5, linewidth=2, label='Fractional Pareto frontier', zorder=3)

# Integral rounded points
ax.scatter(int_pts[:, 0], int_pts[:, 1],
           c='red', s=80, marker='s', zorder=4, label='Threshold-rounded (integral)', alpha=0.7)

# Connect fractional to integral
for i in range(len(frac_pts)):
    ax.annotate('', xy=(int_pts[i, 0], int_pts[i, 1]),
                xytext=(frac_pts[i, 0], frac_pts[i, 1]),
                arrowprops=dict(arrowstyle='->', color='gray', alpha=0.3, lw=0.8))

# d_max bound lines from a reference fractional point
ref_idx = len(frac_pts) // 2
ref_fp = frac_pts[ref_idx]
ax.axvline(x=ref_fp[0] * d_max, color='green', linestyle='--', alpha=0.5,
           label=f'd_max × fractional (d={d_max})')
ax.axhline(y=ref_fp[1] * d_max, color='green', linestyle='--', alpha=0.5)

ax.set_xlabel('Objective 1 (cost)', fontsize=14)
ax.set_ylabel('Objective 2 (cost)', fontsize=14)
ax.set_title(f'Bi-Objective Hypergraph Transversal: Pareto Frontier\n'
             f'n={n}, m={len(edges)}, d_max={d_max}', fontsize=15)
ax.legend(fontsize=12, loc='upper right')
ax.grid(True, alpha=0.3)

xlim = ax.get_xlim()
ylim = ax.get_ylim()
ax.set_xlim(0, xlim[1])
ax.set_ylim(0, ylim[1])

plt.tight_layout()
plt.savefig('viz_pareto_frontier.png', dpi=150, bbox_inches='tight')
print("Saved viz_pareto_frontier.png")
