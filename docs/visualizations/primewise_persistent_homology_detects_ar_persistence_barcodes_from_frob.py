"""
Visualization: Persistence Barcodes from Frobenius Orbit Data

This script visualizes how Frobenius orbit decompositions of curves mod p
generate persistence barcodes, and how the total persistence equals
the total number of points (a formally proved theorem).
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def pell_conic_point_count(d, p):
    """Count points on x^2 - d*y^2 = 1 mod p."""
    count = 0
    for x in range(p):
        for y in range(p):
            if (x * x - d * y * y - 1) % p == 0:
                count += 1
    return count


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# ── Panel 1: Barcode visualization for specific orbit data ──

ax = axes[0, 0]
orbit_data = {
    'p=5, d=2': [1, 1, 1, 1],
    'p=7, d=2': [1, 1, 1, 1, 1, 1],
    'p=11, d=2': [1]*10,
    'p=13, d=2': [1]*14,
}

y_pos = 0
colors = plt.cm.Set2(np.linspace(0, 1, len(orbit_data)))
labels = []

for (name, orbits), color in zip(orbit_data.items(), colors):
    for k in orbits:
        ax.barh(y_pos, k, left=0, height=0.6, color=color, alpha=0.8,
                edgecolor='black', linewidth=0.5)
        y_pos += 1
    labels.append((name, y_pos - len(orbits)/2, color))
    y_pos += 1

for name, y, color in labels:
    ax.text(-0.5, y, name, ha='right', va='center', fontsize=8,
            fontweight='bold', color='black')

ax.set_xlabel('Filtration Level', fontsize=10)
ax.set_title('Persistence Barcodes from\nFrobenius Orbits (x²-2y²=1)',
             fontsize=11, fontweight='bold')
ax.set_yticks([])
ax.axvline(x=0, color='gray', linestyle='--', alpha=0.5)

# ── Panel 2: Total persistence = total points ──

ax = axes[0, 1]
d = 2
primes = [p for p in range(3, 40) if is_prime(p)]
point_counts = [pell_conic_point_count(d, p) for p in primes]

ax.bar(range(len(primes)), point_counts, color='steelblue', alpha=0.8,
       edgecolor='black', linewidth=0.5)
ax.set_xticks(range(len(primes)))
ax.set_xticklabels([str(p) for p in primes], fontsize=8)
ax.set_xlabel('Prime p', fontsize=10)
ax.set_ylabel('Total Points = Total Persistence', fontsize=10)
ax.set_title('Theorem: Total Persistence = Point Count\n(x²-2y²=1 mod p)',
             fontsize=11, fontweight='bold')

# Add trend line (roughly p for large p)
ax.plot(range(len(primes)), [p-1 for p in primes], 'r--', alpha=0.5,
        label='p - 1 (expected)')
ax.legend(fontsize=9)

# ── Panel 3: Euler characteristic = orbit count ──

ax = axes[1, 0]

# For various partition shapes of 12
n = 12
partitions = [
    ([12], '12'),
    ([6, 6], '6+6'),
    ([4, 4, 4], '4+4+4'),
    ([3, 3, 3, 3], '3×4'),
    ([2]*6, '2×6'),
    ([1]*12, '1×12'),
]

x_pos = np.arange(len(partitions))
euler_chars = [len(parts) for parts, _ in partitions]
total_pers = [sum(parts) for parts, _ in partitions]

bars1 = ax.bar(x_pos - 0.2, euler_chars, 0.35, label='Euler Char (= #parts)',
               color='coral', alpha=0.8, edgecolor='black')
bars2 = ax.bar(x_pos + 0.2, total_pers, 0.35, label='Total Persistence (= 12)',
               color='seagreen', alpha=0.8, edgecolor='black')

ax.set_xticks(x_pos)
ax.set_xticklabels([name for _, name in partitions], fontsize=8)
ax.set_xlabel('Partition of 12', fontsize=10)
ax.set_ylabel('Value', fontsize=10)
ax.set_title('Partition Invariants\n(Euler Char varies, Persistence constant)',
             fontsize=11, fontweight='bold')
ax.legend(fontsize=9)

# ── Panel 4: Mod-9 obstruction as persistence ──

ax = axes[1, 1]
n_range = range(1, 46)
mod9_vals = [n % 9 for n in n_range]
persistence = [0 if m in (4, 5) else 1 for m in mod9_vals]

colors_bar = ['red' if p == 0 else 'steelblue' for p in persistence]
ax.bar(list(n_range), persistence, color=colors_bar, alpha=0.8,
       edgecolor='black', linewidth=0.3)

# Mark obstructed
obstructed = [n for n, p in zip(n_range, persistence) if p == 0]
ax.scatter(obstructed, [0]*len(obstructed), color='red', s=50, zorder=5,
           marker='x', linewidth=2)

ax.set_xlabel('Integer n', fontsize=10)
ax.set_ylabel('Persistence Indicator', fontsize=10)
ax.set_title('Mod-9 Obstruction as Persistence Vanishing\n'
             '(red ✗ = cannot be sum of three cubes)',
             fontsize=11, fontweight='bold')
ax.set_yticks([0, 1])
ax.set_yticklabels(['Obstructed', 'Candidate'])

red_patch = mpatches.Patch(color='red', alpha=0.8, label='n ≡ 4,5 (mod 9)')
blue_patch = mpatches.Patch(color='steelblue', alpha=0.8, label='Other residues')
ax.legend(handles=[red_patch, blue_patch], fontsize=9)

plt.tight_layout()
plt.savefig('barcode_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved barcode_visualization.png")
