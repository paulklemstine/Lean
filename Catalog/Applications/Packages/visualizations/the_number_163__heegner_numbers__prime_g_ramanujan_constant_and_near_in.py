"""
Visualization 3: The Ramanujan Constant and Near-Integer Phenomenon

Shows how e^(π√d) approaches integers for Heegner numbers d,
with the dramatic case d = 163 where the distance is ~7.5×10⁻¹³.
This visualization connects the algebraic (class number 1) property
to the transcendental (exponential) world.
"""

import matplotlib.pyplot as plt
import numpy as np
import math


def is_prime(n):
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Distance to nearest integer for e^(π√d)
ax1 = axes[0, 0]
heegner_3mod4 = [3, 7, 11, 19, 43, 67, 163]
distances = []
for d in heegner_3mod4:
    val = math.exp(math.pi * math.sqrt(d))
    dist = abs(val - round(val))
    distances.append(dist)

ax1.semilogy(heegner_3mod4, distances, 'o-', color='#e74c3c',
             markersize=10, linewidth=2, markeredgecolor='white')
for d, dist in zip(heegner_3mod4, distances):
    ax1.annotate(f'd={d}\n{dist:.1e}', (d, dist),
                textcoords="offset points", xytext=(10, 5),
                fontsize=8, color='#ecf0f1')
ax1.set_xlabel('Heegner number d', fontsize=13)
ax1.set_ylabel('|e^(π√d) - nearest integer|', fontsize=13)
ax1.set_title('The Ramanujan Phenomenon:\ne^(π√d) Nearly Integer for Heegner Numbers',
              fontsize=13, fontweight='bold')
ax1.set_facecolor('#2c3e50')
ax1.grid(True, alpha=0.3)

# Plot 2: Non-Heegner comparison
ax2 = axes[0, 1]
all_d = list(range(3, 170, 4))  # d ≡ 3 mod 4
distances_all = []
is_heegner = []
for d in all_d:
    try:
        val = math.exp(math.pi * math.sqrt(d))
        dist = abs(val - round(val))
        distances_all.append(dist)
        is_heegner.append(d in heegner_3mod4)
    except OverflowError:
        distances_all.append(None)
        is_heegner.append(False)

colors = ['#e74c3c' if h else '#95a5a6' for h in is_heegner]
sizes = [80 if h else 20 for h in is_heegner]
valid = [(d, dist, c, s) for d, dist, c, s in zip(all_d, distances_all, colors, sizes)
         if dist is not None and dist > 0]
if valid:
    ds, dists, cs, ss = zip(*valid)
    ax2.scatter(ds, [math.log10(d) if d > 0 else -15 for d in dists],
                c=cs, s=ss, alpha=0.7, edgecolors='white', linewidths=0.5)
ax2.set_xlabel('d (≡ 3 mod 4)', fontsize=13)
ax2.set_ylabel('log₁₀(distance to integer)', fontsize=13)
ax2.set_title('Heegner vs Non-Heegner:\nOnly Class Number 1 Gives Near-Integers',
              fontsize=13, fontweight='bold')
ax2.set_facecolor('#2c3e50')
ax2.grid(True, alpha=0.3)
from matplotlib.patches import Patch
ax2.legend(handles=[Patch(facecolor='#e74c3c', label='Heegner'),
                     Patch(facecolor='#95a5a6', label='Non-Heegner')],
           fontsize=10)

# Plot 3: Prime density of Euler polynomials from different Heegner numbers
ax3 = axes[1, 0]
heegner_primes = {163: 41, 67: 17, 43: 11}
for d, p in heegner_primes.items():
    ns = list(range(50))
    prime_count = []
    total = 0
    for n in ns:
        val = n * n + n + p
        if is_prime(val):
            total += 1
        prime_count.append(total / (n + 1))
    label = f'd={d}, p={p}'
    ax3.plot(ns, prime_count, linewidth=2, label=label)

# Baseline: n²+1
ns = list(range(50))
baseline = []
total = 0
for n in ns:
    if is_prime(n * n + 1):
        total += 1
    baseline.append(total / (n + 1))
ax3.plot(ns, baseline, '--', linewidth=1.5, color='gray', label='n²+1 (baseline)')

ax3.set_xlabel('n', fontsize=13)
ax3.set_ylabel('Cumulative prime density', fontsize=13)
ax3.set_title('Prime Density: Heegner Polynomials\nvs Baseline', fontsize=13, fontweight='bold')
ax3.legend(fontsize=10)
ax3.set_facecolor('#2c3e50')
ax3.grid(True, alpha=0.3)

# Plot 4: The six Euler lucky primes and their generating ranges
ax4 = axes[1, 1]
euler_lucky = [(2, 1), (3, 2), (5, 4), (11, 10), (17, 16), (41, 40)]
ps = [p for p, _ in euler_lucky]
ranges = [r for _, r in euler_lucky]

bars = ax4.barh(range(len(ps)), ranges, color=['#1abc9c', '#2ecc71', '#3498db',
                                                 '#9b59b6', '#e67e22', '#e74c3c'],
                alpha=0.8, edgecolor='white')
ax4.set_yticks(range(len(ps)))
ax4.set_yticklabels([f'p = {p}' for p in ps], fontsize=12)
ax4.set_xlabel('Prime-generating range (# consecutive primes)', fontsize=13)
ax4.set_title('The Six Euler Lucky Primes\nand Their Prime-Generating Power',
              fontsize=13, fontweight='bold')
ax4.set_facecolor('#2c3e50')

for i, (p, r) in enumerate(euler_lucky):
    d = 4 * p - 1
    ax4.text(r + 0.5, i, f'd = {d}', va='center', fontsize=10, color='#ecf0f1')

plt.tight_layout()
plt.savefig('viz_ramanujan.png', dpi=150, bbox_inches='tight')
print("Saved viz_ramanujan.png")
