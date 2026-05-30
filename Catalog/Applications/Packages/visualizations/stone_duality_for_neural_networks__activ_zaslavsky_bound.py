"""
Visualization: Zaslavsky Bound vs Actual Regions
===================================================
Shows how the number of realized activation regions compares to
the theoretical Zaslavsky bound and the naive 2^m bound,
for varying numbers of hyperplanes m in dimension n=2.

This illustrates the key insight: the activation Boolean algebra
has far fewer atoms than the naive 2^m bound suggests, because
many activation patterns are geometrically impossible.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def count_regions_random(n, m, n_samples=200000, bounds=10.0, seed=42):
    """Count realized activation regions for random hyperplanes."""
    rng = np.random.RandomState(seed)
    Ws = rng.randn(m, n)
    bs = rng.randn(m) * 0.5

    patterns = set()
    for _ in range(n_samples):
        x = rng.uniform(-bounds, bounds, size=n)
        pre = Ws @ x + bs
        pattern = tuple(p > 0 for p in pre)
        patterns.add(pattern)

    return len(patterns)


def zaslavsky_bound(n, m):
    return sum(comb(m, k) for k in range(n + 1))


# Compute data
n = 2  # dimension
ms = list(range(1, 16))
actual_regions = []
zas_bounds = []
exp_bounds = []

for m in ms:
    actual = count_regions_random(n, m, n_samples=300000)
    actual_regions.append(actual)
    zas_bounds.append(zaslavsky_bound(n, m))
    exp_bounds.append(2 ** m)

# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Left: Linear scale
ax1.plot(ms, actual_regions, 'bo-', linewidth=2, markersize=8, label='Actual regions (sampled)')
ax1.plot(ms, zas_bounds, 'rs--', linewidth=2, markersize=8, label=f'Zaslavsky bound (n={n})')
ax1.plot(ms, exp_bounds, 'g^:', linewidth=2, markersize=8, label='Naive bound 2^m')
ax1.set_xlabel('Number of hyperplanes m', fontsize=14)
ax1.set_ylabel('Number of regions', fontsize=14)
ax1.set_title('Activation Regions vs Bounds (Linear Scale)', fontsize=13)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Annotate the gap
m_annotate = 10
idx = ms.index(m_annotate)
ax1.annotate(f'Gap: {exp_bounds[idx]} vs {zas_bounds[idx]}',
             xy=(m_annotate, exp_bounds[idx]),
             xytext=(m_annotate - 3, exp_bounds[idx] * 0.8),
             arrowprops=dict(arrowstyle='->', color='green'),
             fontsize=10, color='green')

# Right: Log scale
ax2.semilogy(ms, actual_regions, 'bo-', linewidth=2, markersize=8, label='Actual regions')
ax2.semilogy(ms, zas_bounds, 'rs--', linewidth=2, markersize=8, label=f'Zaslavsky bound')
ax2.semilogy(ms, exp_bounds, 'g^:', linewidth=2, markersize=8, label='2^m bound')
ax2.set_xlabel('Number of hyperplanes m', fontsize=14)
ax2.set_ylabel('Number of regions (log scale)', fontsize=14)
ax2.set_title('Activation Regions vs Bounds (Log Scale)', fontsize=13)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

# Add text box with formulas
textstr = (f'Dimension n = {n}\n'
           f'Zaslavsky: Σ C(m,k) for k=0..{n}\n'
           f'  = 1 + m + m(m-1)/2\n'
           f'  = O(m²) for fixed n\n\n'
           f'Key: polynomial vs exponential!')
props = dict(boxstyle='round', facecolor='lightyellow', alpha=0.9)
ax2.text(0.05, 0.95, textstr, transform=ax2.transAxes, fontsize=10,
         verticalalignment='top', bbox=props)

plt.suptitle('The Zaslavsky Gap: Why Neural Networks Are Simpler Than They Look',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('zaslavsky_bound.png', dpi=150, bbox_inches='tight')
plt.close()

# Print summary table
print("Zaslavsky Bound Analysis")
print(f"{'m':>4} {'Actual':>10} {'Zaslavsky':>12} {'2^m':>10} {'Ratio':>10}")
print("-" * 50)
for i, m in enumerate(ms):
    ratio = actual_regions[i] / exp_bounds[i]
    print(f"{m:>4} {actual_regions[i]:>10} {zas_bounds[i]:>12} {exp_bounds[i]:>10} {ratio:>10.4f}")

print(f"\nSaved zaslavsky_bound.png")
