#!/usr/bin/env python3
"""
Visualization 3: The Mod 9 Obstruction and Density Landscape

Shows the mod 9 structure of the three cubes problem:
- Left: bar chart of residue counts at n=9 for each residue class
- Right: the "density landscape" showing truncated singular series
  values for k=0..35, with obstructed values highlighted

This visualization makes the local-global principle tangible:
the mod 9 obstruction is the dominant source of impossibility,
and the truncated singular series quantifies the "ease" of
representation for admissible values.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def three_cube_residue_count(k, n):
    k_mod = k % n
    count = 0
    for a in range(n):
        a3 = (a * a * a) % n
        for b in range(n):
            ab3 = (a3 + b * b * b) % n
            for c in range(n):
                if (ab3 + c * c * c) % n == k_mod:
                    count += 1
    return count


def local_density(k, n):
    return three_cube_residue_count(k, n) / n**2


def sieve_primes(limit):
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: residue counts at n=9
residues = list(range(9))
counts = [three_cube_residue_count(r, 9) for r in residues]
colors_left = ['#2ecc71' if r % 9 not in (4, 5) else '#e74c3c' for r in residues]

bars = ax1.bar(residues, counts, color=colors_left, edgecolor='black', linewidth=0.5)
ax1.set_xlabel('Residue class k mod 9', fontsize=12)
ax1.set_ylabel('# Solutions in (ℤ/9ℤ)³', fontsize=12)
ax1.set_title('Solutions to x³+y³+z³ ≡ k (mod 9)\nGreen = admissible, Red = obstructed', fontsize=12)
ax1.set_xticks(residues)

for i, (r, c) in enumerate(zip(residues, counts)):
    ax1.text(r, c + 3, str(c), ha='center', va='bottom', fontsize=10, fontweight='bold')
    if r in (4, 5):
        ax1.text(r, c + 12, '✗ ZERO', ha='center', va='bottom', fontsize=9, color='red')

# Right panel: density landscape for k=0..35
k_range = list(range(36))
primes = sieve_primes(11)

singular_series_vals = []
for k in k_range:
    if k % 9 in (4, 5):
        singular_series_vals.append(0.0)
    else:
        product = 1.0
        for p in primes:
            product *= local_density(k, p)
        singular_series_vals.append(product)

colors_right = ['#e74c3c' if k % 9 in (4, 5) else '#3498db' for k in k_range]

ax2.bar(k_range, singular_series_vals, color=colors_right,
        edgecolor='black', linewidth=0.3, width=0.8)
ax2.set_xlabel('Target integer k', fontsize=12)
ax2.set_ylabel('S^sf_{≤11}(k)', fontsize=12)
ax2.set_title('Truncated Singular Series (primes ≤ 11)\nBlue = admissible, Red = obstructed (zero)', fontsize=12)

# Add vertical lines at obstructed values
for k in k_range:
    if k % 9 in (4, 5):
        ax2.axvline(x=k, color='red', alpha=0.15, linewidth=3)

plt.suptitle('The Mod 9 Obstruction and Density Landscape for x³ + y³ + z³ = k',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_mod9_obstruction.png', dpi=150, bbox_inches='tight')
print("Saved viz_mod9_obstruction.png")
