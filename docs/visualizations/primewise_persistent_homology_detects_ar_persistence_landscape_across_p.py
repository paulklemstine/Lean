"""
Visualization: Persistence Landscape across Primes

This script visualizes how the persistence landscape (rank function)
of Frobenius orbit barcodes evolves across primes, showing the
cross-domain connection between arithmetic and topology.
"""

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.mplot3d import Axes3D


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def pell_conic_point_count(d, p):
    """Count points on x^2 - d*y^2 = 1 mod p."""
    count = 0
    for x in range(p):
        for y in range(p):
            if (x * x - d * y * y - 1) % p == 0:
                count += 1
    return count


def barcode_rank(orbit_sizes, t):
    """Rank function: count intervals alive at level t."""
    # Each orbit of size k gives interval [0, k)
    return sum(1 for k in orbit_sizes if 0 <= t < k)


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# ── Panel 1: Rank functions for different d values ──

ax = axes[0, 0]
d_values = [2, 3, 5, 7]
p = 23  # fixed prime

for d in d_values:
    n_pts = pell_conic_point_count(d, p)
    orbit_sizes = [1] * n_pts  # over F_p, all orbits size 1
    t_range = range(0, 5)
    ranks = [barcode_rank(orbit_sizes, t) for t in t_range]
    ax.plot(list(t_range), ranks, 'o-', label=f'd={d} ({n_pts} pts)',
            linewidth=2, markersize=6)

ax.set_xlabel('Filtration Level t', fontsize=10)
ax.set_ylabel('Rank β(t)', fontsize=10)
ax.set_title(f'Persistence Rank Functions (p={p})\nfor x²-dy²=1',
             fontsize=11, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ── Panel 2: Point counts vs primes for multiple d ──

ax = axes[0, 1]
primes = [p for p in range(3, 50) if is_prime(p)]
d_values_2 = [2, 3, 5]
colors = ['steelblue', 'coral', 'seagreen']

for d, color in zip(d_values_2, colors):
    counts = [pell_conic_point_count(d, p) for p in primes]
    ax.plot(primes, counts, 'o-', color=color, label=f'd={d}',
            linewidth=1.5, markersize=4, alpha=0.8)

# Reference line: p (expected average)
ax.plot(primes, primes, 'k--', alpha=0.3, label='y = p')

ax.set_xlabel('Prime p', fontsize=10)
ax.set_ylabel('Point Count = Persistence', fontsize=10)
ax.set_title('Point Counts across Primes\n(Total Persistence = Point Count)',
             fontsize=11, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ── Panel 3: Persistence vs prime for Hasse-Weil bound ──

ax = axes[1, 0]

# y^2 = x^3 + 1 (j=0 curve)
primes_ell = [p for p in range(5, 60) if is_prime(p)]
point_counts = []
for p in primes_ell:
    count = 0
    for x in range(p):
        rhs = (x*x*x + 1) % p
        for y in range(p):
            if (y*y) % p == rhs:
                count += 1
    point_counts.append(count + 1)  # +1 for point at infinity

traces = [p + 1 - N for p, N in zip(primes_ell, point_counts)]
hasse_bounds = [2 * np.sqrt(p) for p in primes_ell]

ax.bar(range(len(primes_ell)), traces, color='steelblue', alpha=0.7,
       edgecolor='black', linewidth=0.3, label='Trace a_p')
ax.plot(range(len(primes_ell)), hasse_bounds, 'r-', linewidth=1.5,
        label='2√p (Hasse bound)')
ax.plot(range(len(primes_ell)), [-h for h in hasse_bounds], 'r-',
        linewidth=1.5)

ax.set_xticks(range(0, len(primes_ell), 2))
ax.set_xticklabels([str(p) for p in primes_ell[::2]], fontsize=7)
ax.set_xlabel('Prime p', fontsize=10)
ax.set_ylabel('Trace a_p = p+1-N_p', fontsize=10)
ax.set_title('Hasse-Weil Bound Verification\ny² = x³ + 1',
             fontsize=11, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ── Panel 4: Orbit size distribution heatmap ──

ax = axes[1, 1]

# For different partition types, show barcode structure
partition_labels = ['[12]', '[6,6]', '[4,4,4]', '[3,3,3,3]', '[2]*6', '[1]*12']
partitions = [[12], [6,6], [4,4,4], [3,3,3,3], [2]*6, [1]*12]

max_t = 13
heatmap = np.zeros((len(partitions), max_t))

for i, parts in enumerate(partitions):
    for t in range(max_t):
        heatmap[i, t] = barcode_rank(parts, t)

im = ax.imshow(heatmap, cmap='Blues', aspect='auto', interpolation='nearest')
ax.set_xticks(range(max_t))
ax.set_xticklabels(range(max_t), fontsize=8)
ax.set_yticks(range(len(partitions)))
ax.set_yticklabels(partition_labels, fontsize=9)
ax.set_xlabel('Filtration Level t', fontsize=10)
ax.set_ylabel('Partition of 12', fontsize=10)
ax.set_title('Rank Functions for\nDifferent Orbit Partitions of 12',
             fontsize=11, fontweight='bold')

# Add annotations
for i in range(len(partitions)):
    for j in range(max_t):
        val = int(heatmap[i, j])
        if val > 0:
            ax.text(j, i, str(val), ha='center', va='center',
                    fontsize=7, color='white' if val > 3 else 'black')

plt.colorbar(im, ax=ax, label='Rank β(t)', shrink=0.8)

plt.tight_layout()
plt.savefig('persistence_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved persistence_landscape.png")
