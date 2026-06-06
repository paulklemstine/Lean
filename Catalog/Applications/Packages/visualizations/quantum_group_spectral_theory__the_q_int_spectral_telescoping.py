"""
Visualization: Spectral Telescoping Convergence

Shows that sum_{k=1}^{N} 1/(k(k+1)) converges to 1 as N -> infinity,
demonstrating the spectral zeta normalization of the Casimir operator.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


Ns = list(range(1, 101))
partial_sums = []
s = 0.0
for N in range(1, 101):
    s += 1.0 / (N * (N + 1))
    partial_sums.append(s)

expected = [1 - 1 / (N + 1) for N in Ns]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
fig.suptitle('Spectral Telescoping: ∑ 1/(k(k+1)) = 1 − 1/(N+1) → 1',
             fontsize=14, fontweight='bold')

# Left: convergence
ax1.plot(Ns, partial_sums, 'b-', linewidth=2, label='∑ 1/(k(k+1))')
ax1.plot(Ns, expected, 'r--', linewidth=1, label='1 − 1/(N+1)')
ax1.axhline(y=1.0, color='g', linewidth=1, linestyle=':', label='Limit = 1')
ax1.set_xlabel('N', fontsize=12)
ax1.set_ylabel('Partial sum', fontsize=12)
ax1.set_title('Convergence to 1')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(0.4, 1.05)

# Right: error
errors = [abs(partial_sums[i] - expected[i]) for i in range(len(Ns))]
residuals = [1.0 - partial_sums[i] for i in range(len(Ns))]
ax2.semilogy(Ns, residuals, 'b-', linewidth=2, label='1 − partial sum')
ax2.semilogy(Ns, [1.0 / (N + 1) for N in Ns], 'r--', linewidth=1, label='1/(N+1)')
ax2.set_xlabel('N', fontsize=12)
ax2.set_ylabel('Residual (log scale)', fontsize=12)
ax2.set_title('Rate of convergence: O(1/N)')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_telescoping.png', dpi=150, bbox_inches='tight')
print("Saved spectral_telescoping.png")
