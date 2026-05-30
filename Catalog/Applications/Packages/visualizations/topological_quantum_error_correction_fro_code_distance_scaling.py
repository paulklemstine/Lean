"""
Visualization: Code Distance and Qubit Scaling in Topological Codes

Shows the fundamental scaling relationships:
- d = L (linear distance growth)
- n = 2L² (quadratic qubit overhead)
- n/d² = 2 (constant overhead ratio)

These relationships are the mathematical core of why topological codes
provide scalable quantum error correction.
"""

import numpy as np
import matplotlib.pyplot as plt

L_values = np.arange(2, 33)
d_values = L_values  # d = L for toric code
n_values = 2 * L_values**2  # n = 2L²
overhead = n_values / d_values**2  # Should be constant = 2

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Topological Quantum Code: Scaling Laws', fontsize=16, fontweight='bold')

# Plot 1: Code distance vs system size
ax1 = axes[0, 0]
ax1.plot(L_values, d_values, 'b-o', markersize=4, linewidth=2, label='d = L')
ax1.plot(L_values, L_values, 'r--', alpha=0.5, label='d = L (theoretical)')
ax1.set_xlabel('System Size L', fontsize=12)
ax1.set_ylabel('Code Distance d', fontsize=12)
ax1.set_title('Code Distance Scaling', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: Qubits vs distance
ax2 = axes[0, 1]
ax2.plot(d_values, n_values, 'g-s', markersize=4, linewidth=2, label='n = 2d²')
d_smooth = np.linspace(2, 32, 100)
ax2.plot(d_smooth, 2 * d_smooth**2, 'r--', alpha=0.5, label='n = 2d² (fit)')
ax2.set_xlabel('Code Distance d', fontsize=12)
ax2.set_ylabel('Physical Qubits n', fontsize=12)
ax2.set_title('Qubit Overhead', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Plot 3: Overhead ratio
ax3 = axes[1, 0]
ax3.plot(L_values, overhead, 'm-^', markersize=4, linewidth=2, label='n/d² = 2')
ax3.axhline(y=2, color='r', linestyle='--', alpha=0.5, label='Constant = 2')
ax3.set_xlabel('System Size L', fontsize=12)
ax3.set_ylabel('Overhead Ratio n/d²', fontsize=12)
ax3.set_title('Constant Qubit Overhead', fontsize=13)
ax3.set_ylim(0, 4)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

# Plot 4: Protection exponent
c = 0.3
gap = 1.0
protection = c * gap * L_values
ax4 = axes[1, 1]
ax4.semilogy(L_values, np.exp(protection), 'r-D', markersize=4, linewidth=2,
             label=f'τ ~ exp({c}·Δ·L)')
ax4.set_xlabel('System Size L', fontsize=12)
ax4.set_ylabel('Protection Time τ (arb. units)', fontsize=12)
ax4.set_title('Exponential Memory Lifetime', fontsize=13)
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('code_distance_scaling.png', dpi=150, bbox_inches='tight')
plt.close()
