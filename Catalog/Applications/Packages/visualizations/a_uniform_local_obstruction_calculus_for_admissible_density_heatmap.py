#!/usr/bin/env python3
"""
Visualization: Admissible Density Heatmap for Biquadratic Sums

Visualizes the density of representable residues for x₁⁴+x₂⁴+x₃⁴+x₄⁴ ≡ k (mod m)
across varying numbers of variables s and moduli m.
Dark cells indicate obstruction moduli where not all residues are representable.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def nth_power_residues(n, m):
    return {pow(a, n, m) for a in range(m)}


def diagonal_residue_sums(n, s, m):
    if s <= 0:
        return {0}
    residues = nth_power_residues(n, m)
    current = {0}
    for _ in range(s):
        current = {(a + r) % m for a in current for r in residues}
    return current


n = 4
max_m = 60
max_s = 10

# Compute density matrix
density = np.zeros((max_s, max_m - 1))
for s in range(1, max_s + 1):
    for m in range(2, max_m + 1):
        res = diagonal_residue_sums(n, s, m)
        density[s - 1, m - 2] = len(res) / m

fig, ax = plt.subplots(figsize=(16, 6))
im = ax.imshow(density, aspect='auto', cmap='RdYlGn',
               vmin=0, vmax=1, interpolation='nearest',
               extent=[2, max_m + 0.5, max_s + 0.5, 0.5])

ax.set_xlabel('Modulus m', fontsize=13)
ax.set_ylabel('Number of variables s', fontsize=13)
ax.set_title(f'Density of Representable Residues: Sums of s Fourth Powers mod m\n'
             f'(Green = surjective, Red = obstructed)', fontsize=14)

# Mark integer ticks
ax.set_yticks(range(1, max_s + 1))

cbar = plt.colorbar(im, ax=ax, label='Density |R(n,s,m)| / m')

# Annotate obstruction moduli for s=4
for m in range(2, max_m + 1):
    if density[3, m - 2] < 1.0:
        ax.plot(m, 4, 'kx', markersize=6, markeredgewidth=1.5)

ax.legend(['Obstruction (s=4)'], loc='upper right', fontsize=10)

plt.tight_layout()
plt.savefig('viz_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_heatmap.png")
