#!/usr/bin/env python3
"""
Demo: Sierpiński Numbers and Covering Systems

Demonstrates the mathematical machinery behind proving that 78557 is a Sierpiński number.
"""

from algorithms import (
    verify_sierpinski_certificate,
    is_covering_system,
    covering_density,
    multiplicative_order,
    chinese_remainder_theorem,
    find_covering_system_for_sierpinski,
    SIERPINSKI_78557_CLASSES,
    SIERPINSKI_78557_PRIMES,
)
from math import gcd, lcm
from functools import reduce


def demo_covering_verification():
    """Verify the Sierpiński certificate for 78557."""
    print("=" * 70)
    print("  DEMO 1: Verifying the Sierpiński Certificate for k = 78557")
    print("=" * 70)
    print()
    valid, msgs = verify_sierpinski_certificate(
        78557, SIERPINSKI_78557_CLASSES, SIERPINSKI_78557_PRIMES
    )
    for msg in msgs:
        print(f"  {msg}")
    print(f"\n  Certificate valid: {valid}")
    print(f"  Covering density: {covering_density(SIERPINSKI_78557_CLASSES):.6f}")
    print()


def demo_coverage_map():
    """Show how the covering system covers all residues mod LCM."""
    print("=" * 70)
    print("  DEMO 2: Coverage Map (mod LCM)")
    print("=" * 70)
    print()

    classes = SIERPINSKI_78557_CLASSES
    primes = SIERPINSKI_78557_PRIMES
    L = reduce(lcm, [m for _, m in classes])
    print(f"  LCM of moduli: {L}")
    print()

    for n in range(L):
        covers = []
        for i, (r, m) in enumerate(classes):
            if n % m == r:
                covers.append(primes[i])
        print(f"  n={n:2d}: {covers}")
    print()


def demo_multiplicative_orders():
    """Show multiplicative orders of 2 modulo the covering primes."""
    print("=" * 70)
    print("  DEMO 3: Multiplicative Orders of 2")
    print("=" * 70)
    print()

    print(f"  {'Prime':>6s}  {'ord_p(2)':>8s}  {'Modulus':>7s}  {'Divides?':>8s}")
    print(f"  {'─'*6}  {'─'*8}  {'─'*7}  {'─'*8}")
    for (r, m), p in zip(SIERPINSKI_78557_CLASSES, SIERPINSKI_78557_PRIMES):
        ord_val = multiplicative_order(2, p)
        print(f"  {p:>6d}  {ord_val:>8d}  {m:>7d}  {'Yes' if m % ord_val == 0 else 'No':>8s}")
    print()


def demo_crt_consistency():
    """Show CRT compatibility of covering classes."""
    print("=" * 70)
    print("  DEMO 4: CRT Compatibility")
    print("=" * 70)
    print()

    classes = SIERPINSKI_78557_CLASSES
    for i in range(len(classes)):
        for j in range(i + 1, len(classes)):
            r1, m1 = classes[i]
            r2, m2 = classes[j]
            g = gcd(m1, m2)
            result = chinese_remainder_theorem([r1, r2], [m1, m2])
            if result:
                x, M = result
                print(f"  ({r1} mod {m1}) ∩ ({r2} mod {m2}): overlap at n≡{x} (mod {M})")
            else:
                print(f"  ({r1} mod {m1}) ∩ ({r2} mod {m2}): disjoint")
    print()


def demo_other_sierpinski():
    """Search for covering systems for other known Sierpiński numbers."""
    print("=" * 70)
    print("  DEMO 5: Finding Covering Systems for Other Sierpiński Numbers")
    print("=" * 70)
    print()

    small_primes = [p for p in range(3, 300) if all(p % d != 0 for d in range(2, int(p**0.5)+1))]

    for k in [271129, 271577, 322523]:
        print(f"  k = {k}:")
        result = find_covering_system_for_sierpinski(k, small_primes, max_modulus=60)
        if result:
            classes, primes = result
            valid, _ = verify_sierpinski_certificate(k, classes, primes)
            print(f"    Found: {len(classes)} classes, density={covering_density(classes):.3f}, valid={valid}")
            for (r, m), p in zip(classes, primes):
                print(f"      n≡{r} (mod {m}) → p={p}")
        else:
            print("    No covering found with given parameters")
        print()


def demo_remaining_candidates():
    """Status of the Sierpiński problem."""
    print("=" * 70)
    print("  DEMO 6: The Sierpiński Problem — Status")
    print("=" * 70)
    print()

    print("  78557 is PROVEN to be a Sierpiński number (by covering system).")
    print()
    print("  To show it is the SMALLEST, we must eliminate all odd k < 78557.")
    print("  Remaining candidates (no prime k·2^n+1 found yet):")
    print()
    for k in [21181, 22699, 24737, 55459, 67607]:
        # Quick check for small n
        found = None
        for n in range(1, 25):
            val = k * (2 ** n) + 1
            is_prime = val > 1
            d = 2
            while d * d <= val and is_prime:
                if val % d == 0:
                    is_prime = False
                d += 1
            if is_prime:
                found = n
                break
        if found:
            print(f"    k={k}: PRIME at n={found} ({k}·2^{found}+1 = {k * 2**found + 1})")
        else:
            print(f"    k={k}: No prime found for n ≤ 24 (need large-scale search)")
    print()


if __name__ == "__main__":
    demo_covering_verification()
    demo_coverage_map()
    demo_multiplicative_orders()
    demo_crt_consistency()
    demo_other_sierpinski()
    demo_remaining_candidates()


#!/usr/bin/env python3
"""
Visualization: Sierpiński Covering System for 78557

Creates a heatmap showing how the covering system partitions integers
into classes, each associated with a prime divisor.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from math import lcm
from functools import reduce

# Covering system for 78557
CLASSES = [(0, 2), (1, 4), (1, 3), (11, 12), (15, 18), (27, 36), (3, 9)]
PRIMES = [3, 5, 7, 13, 19, 37, 73]
COLORS = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', '#a65628', '#f781bf']

L = reduce(lcm, [m for _, m in CLASSES])

# Build coverage matrix
coverage = np.zeros((L,), dtype=int)
for n in range(L):
    for i, (r, m) in enumerate(CLASSES):
        if n % m == r:
            coverage[n] = i + 1
            break

# Reshape for grid visualization
cols = 6
rows = (L + cols - 1) // cols
grid = np.zeros((rows, cols), dtype=int)
for n in range(L):
    grid[n // cols, n % cols] = coverage[n]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Coverage grid
ax = axes[0]
for i in range(rows):
    for j in range(cols):
        n = i * cols + j
        if n < L:
            color = COLORS[grid[i, j] - 1]
            ax.add_patch(plt.Rectangle((j, rows - 1 - i), 1, 1, facecolor=color, edgecolor='white', linewidth=0.5))
            ax.text(j + 0.5, rows - 0.5 - i, str(n), ha='center', va='center', fontsize=7, fontweight='bold')

ax.set_xlim(0, cols)
ax.set_ylim(0, rows)
ax.set_aspect('equal')
ax.set_title(f'Covering System for 78557\n(n mod {L}, colored by covering prime)', fontsize=11)
ax.set_xticks([])
ax.set_yticks([])

patches = [mpatches.Patch(color=COLORS[i], label=f'p={PRIMES[i]} (n≡{CLASSES[i][0]} mod {CLASSES[i][1]})')
           for i in range(len(PRIMES))]
ax.legend(handles=patches, loc='upper right', fontsize=7, framealpha=0.9)

# Plot 2: Density contribution
ax2 = axes[1]
densities = [1.0 / m for _, m in CLASSES]
labels = [f'p={p}\n1/{m}' for (_, m), p in zip(CLASSES, PRIMES)]
colors_bar = COLORS[:len(PRIMES)]
bars = ax2.bar(range(len(PRIMES)), densities, color=colors_bar, edgecolor='black', linewidth=0.5)
ax2.axhline(y=1.0 / len(PRIMES), color='gray', linestyle=':', alpha=0.5)
ax2.set_xticks(range(len(PRIMES)))
ax2.set_xticklabels(labels, fontsize=8)
ax2.set_ylabel('Density contribution (1/m)', fontsize=10)
ax2.set_title(f'Density Contributions\nΣ = {sum(densities):.4f} ≥ 1', fontsize=11)
ax2.set_ylim(0, max(densities) * 1.2)

plt.tight_layout()
plt.savefig('covering_system_78557.png', dpi=150, bbox_inches='tight')
print("Saved covering_system_78557.png")
