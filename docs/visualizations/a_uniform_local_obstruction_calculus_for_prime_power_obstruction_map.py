#!/usr/bin/env python3
"""
Visualization: Obstruction Prime Powers for Diagonal Forms

Shows which prime powers cause local obstructions for x₁ⁿ+⋯+xₛⁿ=k
across degrees n=2..6 and variable counts s=n..2n.
Reveals the arithmetic structure underlying Waring-type problems.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import gcd


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


def is_surjective(n, s, m):
    return len(diagonal_residue_sums(n, s, m)) == m


def factorize(n):
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


# Compute obstruction data
primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
max_exp = 4
degrees = [2, 3, 4, 5, 6]

fig, axes = plt.subplots(len(degrees), 1, figsize=(14, 12), sharex=True)

for idx, n in enumerate(degrees):
    ax = axes[idx]
    s_values = list(range(n, 2 * n + 1))

    pp_labels = []
    for p in primes:
        for e in range(1, max_exp + 1):
            if p ** e <= 100:
                pp_labels.append(f"{p}^{e}" if e > 1 else str(p))

    matrix = np.zeros((len(s_values), len(pp_labels)))

    col = 0
    for p in primes:
        for e in range(1, max_exp + 1):
            m = p ** e
            if m > 100:
                continue
            for row, s in enumerate(s_values):
                density = len(diagonal_residue_sums(n, s, m)) / m
                matrix[row, col] = density
            col += 1

    im = ax.imshow(matrix[:, :col], aspect='auto', cmap='RdYlGn',
                   vmin=0, vmax=1, interpolation='nearest')

    ax.set_yticks(range(len(s_values)))
    ax.set_yticklabels([str(s) for s in s_values])
    ax.set_ylabel(f'n={n}\n(s vars)', fontsize=10)

    if idx == len(degrees) - 1:
        ax.set_xticks(range(col))
        ax.set_xticklabels(pp_labels[:col], rotation=45, ha='right', fontsize=8)
        ax.set_xlabel('Prime power modulus', fontsize=12)

    # Mark non-surjective cells
    for row in range(len(s_values)):
        for c in range(col):
            if matrix[row, c] < 1.0:
                ax.text(c, row, f'{matrix[row,c]:.1f}', ha='center', va='center',
                        fontsize=6, color='black')

fig.suptitle('Local Surjectivity at Prime Powers: Degrees 2–6\n'
             '(Green = surjective, Red = obstructed, numbers show density)',
             fontsize=14, fontweight='bold')

plt.tight_layout()
plt.savefig('viz_obstruction_primes.png', dpi=150, bbox_inches='tight')
print("Saved viz_obstruction_primes.png")
