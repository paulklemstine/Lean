"""
Circuit Lower Bound Tower Visualization
=========================================
Visualizes the tower of circuit lower bounds for k-th derivative
computation, showing how the optimal derivative order varies
with dimension and degree.

The key insight: there exists an optimal k* that maximizes the
lower bound, balancing shadow shrinkage against channel explosion.
"""
import numpy as np
import matplotlib.pyplot as plt
from math import comb, log2


def circuit_lower_bound(d: int, m: int, k: int) -> float:
    """C(m - k + d - 1, d - 1) / d^k"""
    if k > m or d <= 0:
        return 0.0
    shadow_card = comb(m - k + d - 1, d - 1)
    channels = d ** k
    return shadow_card / channels if channels > 0 else 0.0


def optimal_k(d: int, m: int) -> tuple[int, float]:
    """Find the optimal k maximizing the circuit lower bound."""
    best_k, best_lb = 0, 0.0
    for k in range(m + 1):
        lb = circuit_lower_bound(d, m, k)
        if lb > best_lb:
            best_k, best_lb = k, lb
    return best_k, best_lb


fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Panel 1: Lower bound curves for fixed d, varying m
ax = axes[0, 0]
d = 4
for m in [5, 10, 15, 20, 30]:
    ks = range(m + 1)
    bounds = [circuit_lower_bound(d, m, k) for k in ks]
    ax.semilogy(ks, [max(b, 0.01) for b in bounds], 'o-', markersize=3, label=f'm = {m}')
    # Mark optimal
    ok, ob = optimal_k(d, m)
    ax.plot(ok, ob, '*', markersize=12, color='red', zorder=5)

ax.set_xlabel('Derivative order k', fontsize=11)
ax.set_ylabel('Circuit lower bound', fontsize=11)
ax.set_title(f'Circuit Bounds vs k (d = {d})', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Lower bound curves for fixed m, varying d
ax = axes[0, 1]
m = 15
for d in [2, 3, 4, 5, 8, 12]:
    ks = range(m + 1)
    bounds = [circuit_lower_bound(d, m, k) for k in ks]
    ax.semilogy(ks, [max(b, 0.01) for b in bounds], 'o-', markersize=3, label=f'd = {d}')

ax.set_xlabel('Derivative order k', fontsize=11)
ax.set_ylabel('Circuit lower bound', fontsize=11)
ax.set_title(f'Circuit Bounds vs k (m = {m})', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: Optimal k as function of m for various d
ax = axes[1, 0]
for d in [2, 3, 5, 8, 12]:
    ms = range(2, 40)
    opt_ks = [optimal_k(d, m)[0] for m in ms]
    ax.plot(ms, opt_ks, 'o-', markersize=3, label=f'd = {d}')

ax.set_xlabel('Degree m', fontsize=11)
ax.set_ylabel('Optimal derivative order k*', fontsize=11)
ax.set_title('Optimal k* vs Degree', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: Maximum lower bound growth
ax = axes[1, 1]
for d in [3, 5, 8, 12]:
    ms = range(2, 50)
    max_bounds = [optimal_k(d, m)[1] for m in ms]
    ax.semilogy(ms, max_bounds, '-', linewidth=2, label=f'd = {d}')

ax.set_xlabel('Degree m', fontsize=11)
ax.set_ylabel('Max circuit lower bound', fontsize=11)
ax.set_title('Maximum Lower Bound Growth', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Higher-Order Shadow Tower: Circuit Complexity Lower Bounds',
             fontsize=15, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('circuit_bounds_tower.png', dpi=150, bbox_inches='tight')
plt.show()
