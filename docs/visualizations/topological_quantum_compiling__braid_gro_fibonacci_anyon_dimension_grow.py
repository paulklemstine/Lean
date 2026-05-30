"""
Visualization 1: Fibonacci Anyon Dimension Growth
==================================================

Visualizes the exponential growth of Fibonacci anyon fusion space dimensions,
showing the golden ratio φ as the asymptotic growth rate. This connects
number theory (Fibonacci sequence) to quantum physics (Hilbert space dimension).
"""

import numpy as np
import matplotlib.pyplot as plt

# Compute Fibonacci dimensions
def fib_dim(n):
    if n <= 1:
        return 1
    a, b = 1, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b

phi = (1 + np.sqrt(5)) / 2
ns = np.arange(0, 16)
dims = [fib_dim(n) for n in ns]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: dimensions on log scale
ax1 = axes[0]
ax1.semilogy(ns, dims, 'o-', color='#e74c3c', markersize=8, linewidth=2, label='fibDim(n)')
ax1.semilogy(ns, [phi**n for n in ns], '--', color='#3498db', linewidth=2,
             label=f'φⁿ (φ = {phi:.4f})')
ax1.semilogy(ns, [n + 1 for n in ns], ':', color='#2ecc71', linewidth=2,
             label='Linear bound (n+1)')
ax1.set_xlabel('Number of anyons (n)', fontsize=12)
ax1.set_ylabel('Fusion space dimension', fontsize=12)
ax1.set_title('Fibonacci Anyon Dimension Growth', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_xticks(range(0, 16, 2))

# Annotate key points
ax1.annotate('SU(3) universality\n(4 anyons, dim=3)',
             xy=(3, fib_dim(3)), xytext=(5, 2),
             arrowprops=dict(arrowstyle='->', color='black'),
             fontsize=10, ha='center')

# Right panel: ratio convergence to golden ratio
ax2 = axes[1]
ratios = [fib_dim(n + 1) / fib_dim(n) for n in range(1, 15)]
ax2.plot(range(1, 15), ratios, 'o-', color='#9b59b6', markersize=8, linewidth=2)
ax2.axhline(y=phi, color='#e67e22', linestyle='--', linewidth=2, label=f'φ = {phi:.6f}')
ax2.set_xlabel('n', fontsize=12)
ax2.set_ylabel('fibDim(n+1) / fibDim(n)', fontsize=12)
ax2.set_title('Convergence to Golden Ratio', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0.9, 2.1)

plt.tight_layout()
plt.savefig('viz_fibonacci_growth.png', dpi=150, bbox_inches='tight')
print("Saved viz_fibonacci_growth.png")
