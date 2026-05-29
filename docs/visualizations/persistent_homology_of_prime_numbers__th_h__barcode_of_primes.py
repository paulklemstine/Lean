"""
Visualization 1: H₀ Barcode of the Prime Point Cloud

Visualizes the persistent homology barcode for primes up to N,
showing how connected components merge as the scale parameter ε increases.
Each horizontal bar represents a topological feature (connected component)
that exists from birth (ε=0) to death (ε = gap size).

The distribution of bar lengths directly encodes the prime gap structure.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


# Compute primes and gaps
N = 500
primes = sieve_primes(N)
gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]

# Sort gaps for barcode display
sorted_gaps = sorted(gaps, reverse=True)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Barcode diagram
ax1 = axes[0]
for i, death in enumerate(sorted_gaps):
    color = '#e74c3c' if death == 2 else '#3498db' if death <= 6 else '#2ecc71'
    ax1.barh(i, death, left=0, height=0.8, color=color, alpha=0.7, edgecolor='none')

ax1.set_xlabel('Scale ε (gap size)', fontsize=12)
ax1.set_ylabel('Bar index (sorted by persistence)', fontsize=12)
ax1.set_title(f'H₀ Barcode of Primes up to {N}', fontsize=14, fontweight='bold')
ax1.axvline(x=2, color='red', linestyle='--', alpha=0.5, label='ε = 2 (twin primes)')
ax1.legend(fontsize=10)
ax1.invert_yaxis()

# Panel 2: Gap histogram vs exponential distribution
ax2 = axes[1]
log_N = math.log(N)
bins = np.arange(0.5, max(gaps) + 1.5, 1)
counts, _, _ = ax2.hist(gaps, bins=bins, density=True, alpha=0.7, color='#3498db',
                         edgecolor='white', label='Observed gaps')

# Overlay exponential distribution
x = np.linspace(0, max(gaps), 100)
exp_pdf = (1/log_N) * np.exp(-x/log_N)
ax2.plot(x, exp_pdf, 'r-', linewidth=2, label=f'Exp(1/log({N})) = Exp(1/{log_N:.1f})')

ax2.set_xlabel('Gap size', fontsize=12)
ax2.set_ylabel('Density', fontsize=12)
ax2.set_title('Gap Distribution vs Cramér Model', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)

# Panel 3: Connected components vs scale
ax3 = axes[2]
eps_values = list(range(0, max(gaps) + 2))
component_counts = []
for eps in eps_values:
    n_components = 1 + sum(1 for g in gaps if g > eps)
    component_counts.append(n_components)

ax3.step(eps_values, component_counts, where='post', color='#2ecc71', linewidth=2)
ax3.fill_between(eps_values, component_counts, alpha=0.2, color='#2ecc71', step='post')
ax3.set_xlabel('Scale ε', fontsize=12)
ax3.set_ylabel('Number of connected components (β₀)', fontsize=12)
ax3.set_title('Filtration: Components vs Scale', fontsize=14, fontweight='bold')
ax3.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
ax3.annotate(f'Full connectivity at ε = {max(gaps)}',
             xy=(max(gaps), 1), xytext=(max(gaps)*0.5, len(primes)*0.3),
             arrowprops=dict(arrowstyle='->', color='gray'),
             fontsize=10, color='gray')

plt.tight_layout()
plt.savefig('viz_barcode.png', dpi=150, bbox_inches='tight')
print("Saved viz_barcode.png")
