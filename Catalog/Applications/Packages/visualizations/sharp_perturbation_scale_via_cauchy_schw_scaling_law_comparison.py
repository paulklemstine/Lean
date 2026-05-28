#!/usr/bin/env python3
"""
Visualization: Scaling Law Comparison

Visualizes the sharp ε/(2n) vs crude ε/(2n²) perturbation tolerance scaling,
with empirical threshold data overlaid. Shows that the correct dimensional
law for certified spectral stability is Θ(1/n), not Θ(1/n²).
"""

import numpy as np
from numpy.linalg import eigvalsh
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def signature(J):
    eigs = eigvalsh(J)
    tol = 1e-10
    return (int(np.sum(eigs > tol)), int(np.sum(eigs < -tol)), len(eigs) - int(np.sum(eigs > tol)) - int(np.sum(eigs < -tol)))


def find_critical_delta(J, n_samples=300, n_bisect=25):
    n = J.shape[0]
    sig_J = signature(J)
    eps_gap = np.min(np.abs(eigvalsh(J)))
    lo, hi = 0.0, eps_gap
    for _ in range(n_bisect):
        mid = (lo + hi) / 2
        preserved = True
        for _ in range(n_samples):
            E = np.random.uniform(-mid, mid, (n, n))
            E = (E + E.T) / 2
            if signature(J + E) != sig_J:
                preserved = False
                break
        if preserved:
            lo = mid
        else:
            hi = mid
    return lo


np.random.seed(42)

ns = list(range(2, 21))
empirical = []
for n in ns:
    J = np.eye(n)  # Identity: gap = 1
    empirical.append(find_critical_delta(J, 300, 25))

ns_arr = np.array(ns, dtype=float)
emp_arr = np.array(empirical)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Sharp Perturbation Scale: Dimensional Scaling Law', fontsize=14, fontweight='bold')

# Plot 1: Log-log comparison
ax = axes[0, 0]
ax.loglog(ns, emp_arr, 'ko-', markersize=6, label='Empirical δ*', zorder=3)
ax.loglog(ns, [1.0/(2*n) for n in ns], 'r--', linewidth=2, label='Sharp: ε/(2n)')
ax.loglog(ns, [1.0/(2*n**2) for n in ns], 'b--', linewidth=2, label='Crude: ε/(2n²)')
ax.fill_between(ns, [1.0/(2*n**2) for n in ns], [1.0/(2*n) for n in ns],
                alpha=0.15, color='green', label='Newly certified safe region')
ax.set_xlabel('Dimension n', fontsize=11)
ax.set_ylabel('Perturbation tolerance δ', fontsize=11)
ax.set_title('Tolerance Scaling (log-log)', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Plot 2: Constant products
ax = axes[0, 1]
prod_n = emp_arr * ns_arr
prod_n2 = emp_arr * ns_arr**2
ax.plot(ns, prod_n, 'ro-', markersize=6, label='δ*·n (should be const for 1/n)')
ax.axhline(y=np.mean(prod_n), color='r', linestyle=':', alpha=0.5)
ax.plot(ns, prod_n2, 'bs-', markersize=5, label='δ*·n² (should be const for 1/n²)')
ax.set_xlabel('Dimension n', fontsize=11)
ax.set_ylabel('Product', fontsize=11)
ax.set_title('Scaling Verification', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Plot 3: Improvement factor
ax = axes[1, 0]
improvement = ns_arr  # sharp/crude ratio = n
ax.bar(ns, improvement, color='mediumpurple', alpha=0.7, edgecolor='purple')
ax.set_xlabel('Dimension n', fontsize=11)
ax.set_ylabel('Improvement factor', fontsize=11)
ax.set_title('Sharp / Crude Tolerance Ratio = n', fontsize=12)
ax.grid(True, alpha=0.3, axis='y')

# Plot 4: Wasted safe region percentage
ax = axes[1, 1]
wasted_pct = (1 - 1.0/ns_arr) * 100
ax.plot(ns, wasted_pct, 'g^-', markersize=7)
ax.fill_between(ns, 0, wasted_pct, alpha=0.15, color='red')
ax.set_xlabel('Dimension n', fontsize=11)
ax.set_ylabel('Wasted safe region (%)', fontsize=11)
ax.set_title('Conservatism of Crude Bound', fontsize=12)
ax.set_ylim(0, 100)
ax.grid(True, alpha=0.3)
ax.annotate(f'{wasted_pct[-1]:.0f}% wasted at n={ns[-1]}',
            xy=(ns[-1], wasted_pct[-1]), xytext=(12, wasted_pct[-1]-15),
            arrowprops=dict(arrowstyle='->', color='red'),
            fontsize=10, color='red')

plt.tight_layout()
plt.savefig('viz_scaling.png', dpi=150, bbox_inches='tight')
print("Saved viz_scaling.png")
