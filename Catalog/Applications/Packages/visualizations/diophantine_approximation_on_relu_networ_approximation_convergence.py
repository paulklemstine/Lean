"""
Visualization: How ReLU Networks Approximate π

Shows the convergence of the Leibniz series and the corresponding
network complexity required at each precision level. Demonstrates
the key theorem: error ≤ 1/(2N+1) where N = w^L pieces.
"""

import numpy as np
import matplotlib.pyplot as plt

# Compute Leibniz series partial sums
def leibniz_partial_sums(max_n):
    """Compute all partial sums S_1, S_2, ..., S_max_n of the Leibniz series."""
    sums = []
    current = 0.0
    for k in range(max_n):
        current += (-1)**k / (2*k + 1)
        sums.append(4 * current)
    return np.array(sums)

max_n = 500
n_values = np.arange(1, max_n + 1)
partial_sums = leibniz_partial_sums(max_n)
errors = np.abs(partial_sums - np.pi)
bounds = 4.0 / (2 * n_values + 1)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Partial sums converging to π
ax1 = axes[0, 0]
ax1.plot(n_values[:100], partial_sums[:100], 'b-', linewidth=0.8, label='4·S_N')
ax1.axhline(y=np.pi, color='r', linestyle='--', linewidth=1.5, label='π')
ax1.fill_between(n_values[:100], np.pi - bounds[:100], np.pi + bounds[:100],
                  alpha=0.15, color='orange', label='Error bound ±4/(2N+1)')
ax1.set_xlabel('Number of terms (N)', fontsize=11)
ax1.set_ylabel('Partial sum value', fontsize=11)
ax1.set_title('Leibniz Series Converging to π', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: Error decay (log scale)
ax2 = axes[0, 1]
ax2.semilogy(n_values, errors, 'b-', linewidth=0.8, alpha=0.7, label='Actual error')
ax2.semilogy(n_values, bounds, 'r--', linewidth=1.5, label='Bound: 4/(2N+1)')
ax2.semilogy(n_values, 1.0/n_values, 'g:', linewidth=1.0, label='1/N reference')
ax2.set_xlabel('Number of terms (N)', fontsize=11)
ax2.set_ylabel('Approximation error', fontsize=11)
ax2.set_title('Error Decay: Bound vs Actual', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Plot 3: Network depth needed vs precision
ax3 = axes[1, 0]
precisions = range(1, 11)
for w in [2, 4, 8, 16]:
    depths = []
    for k in precisions:
        eps = 10**(-k)
        # Need 4/(2*w^L + 1) < eps, so w^L > 2/eps
        L = max(1, int(np.ceil(np.log(2.0/eps) / np.log(w))))
        depths.append(L)
    ax3.plot(list(precisions), depths, 'o-', markersize=5, label=f'w={w}')

ax3.set_xlabel('Decimal digits of accuracy', fontsize=11)
ax3.set_ylabel('Required depth (L)', fontsize=11)
ax3.set_title('Network Depth vs Precision', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

# Plot 4: Comparison of π, e, √2 approximation rates
ax4 = axes[1, 1]

# π via Leibniz
pi_errors = errors

# e via Taylor
e_errors = []
e_sum = 0.0
factorial = 1
for k in range(1, max_n + 1):
    if k > 1:
        factorial *= (k - 1)
    e_sum += 1.0 / factorial
    e_errors.append(abs(np.e - e_sum))
e_errors = np.array(e_errors)

# √2 via Newton's method iterations (simulating convergence)
sqrt2_errors = []
x = 1.0
for k in range(1, max_n + 1):
    x = (x + 2.0/x) / 2.0
    sqrt2_errors.append(abs(np.sqrt(2) - x))
sqrt2_errors = np.array(sqrt2_errors)
sqrt2_errors = np.maximum(sqrt2_errors, 1e-16)  # floor at machine epsilon

ax4.semilogy(n_values[:50], pi_errors[:50], 'b-', linewidth=1.5, label='π (Leibniz, algebraic)')
ax4.semilogy(n_values[:50], e_errors[:50], 'r-', linewidth=1.5, label='e (Taylor, factorial)')
ax4.semilogy(n_values[:min(50, len(sqrt2_errors))], 
             sqrt2_errors[:50], 'g-', linewidth=1.5, label='√2 (Newton, quadratic)')
ax4.set_xlabel('Number of iterations/terms', fontsize=11)
ax4.set_ylabel('Approximation error', fontsize=11)
ax4.set_title('Convergence Rate Comparison', fontsize=13)
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)
ax4.set_ylim(bottom=1e-16)

plt.suptitle('Diophantine Approximation by ReLU Networks', 
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_approximation.png', dpi=150, bbox_inches='tight')
print("Saved viz_approximation.png")
