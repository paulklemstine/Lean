"""
Sharp GOE Failure Bound Visualization

Visualizes the sharp failure upper bound exp(−(max(ε−2σ,0))²n/(Cσ²))
from the GOE theory, showing how it transitions from 1 (no suppression)
below the edge to exponentially small above the edge. The bound governs
the probability that random perturbation destroys Lorentzian signature.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def sharp_failure_bound(C, sigma, epsilon, n):
    """Compute exp(-(max(ε-2σ,0))²·n / (C·σ²))."""
    excess = max(epsilon - 2 * sigma, 0)
    if C * sigma**2 <= 0:
        return 1.0
    return np.exp(-(excess**2) * n / (C * sigma**2))


sigma = 1.0
C = 4.0
eps_range = np.linspace(0, 5, 200)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Failure bound vs ε for multiple n
ax = axes[0]
for n, color, ls in [(10, '#e74c3c', '-'), (50, '#3498db', '-'),
                      (200, '#2ecc71', '-'), (1000, '#9b59b6', '-')]:
    bounds = [sharp_failure_bound(C, sigma, e, n) for e in eps_range]
    ax.plot(eps_range, bounds, ls, linewidth=2, color=color, label=f'n = {n}')

ax.axvline(x=2*sigma, color='black', linestyle='--', linewidth=2, alpha=0.7)
ax.set_xlabel('Signal gap ε', fontsize=13)
ax.set_ylabel('Failure bound P(misclassification)', fontsize=13)
ax.set_title('Sharp GOE Failure Bound', fontsize=15, fontweight='bold')
ax.set_yscale('log')
ax.set_ylim(1e-15, 2)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.annotate('Edge: 2σ', xy=(2, 0.5), fontsize=12, ha='center',
            color='black', fontweight='bold')

# Panel 2: Exponent surface (ε vs n)
ax = axes[1]
n_range = np.linspace(1, 200, 100)
eps_range2 = np.linspace(0, 5, 100)
N, E = np.meshgrid(n_range, eps_range2)
Z = np.zeros_like(N)
for i in range(len(eps_range2)):
    for j in range(len(n_range)):
        Z[i, j] = sharp_failure_bound(C, sigma, eps_range2[i], n_range[j])

levels = [1e-10, 1e-8, 1e-6, 1e-4, 1e-2, 0.1, 0.5, 0.9, 0.99]
cs = ax.contourf(E, N, Z, levels=20, cmap='RdYlGn_r')
ax.contour(E, N, Z, levels=[0.5], colors='black', linewidths=2)
ax.axvline(x=2*sigma, color='white', linestyle='--', linewidth=2)
plt.colorbar(cs, ax=ax, label='Failure probability')
ax.set_xlabel('Signal gap ε', fontsize=13)
ax.set_ylabel('Dimension n', fontsize=13)
ax.set_title('Failure Landscape', fontsize=15, fontweight='bold')

# Panel 3: Bits of precision (how many bits of safety above edge?)
ax = axes[2]
deltas = np.linspace(0.01, 3, 100)
for n, color in [(10, '#e74c3c'), (50, '#3498db'), (200, '#2ecc71')]:
    bits = [(max(d, 0))**2 * n / (C * sigma**2) / np.log(2)
            for d in deltas]
    ax.plot(deltas, bits, '-', linewidth=2, color=color, label=f'n = {n}')

ax.set_xlabel('Excess gap δ = ε − 2σ', fontsize=13)
ax.set_ylabel('Bits of certification', fontsize=13)
ax.set_title('Certification Strength Above Edge', fontsize=15,
             fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.annotate('More bits = stronger guarantee', xy=(1.5, 30),
            fontsize=11, ha='center', style='italic')

plt.tight_layout(pad=2.0)
plt.savefig('viz_failure_bound.png', dpi=150, bbox_inches='tight')
print("Saved viz_failure_bound.png")
