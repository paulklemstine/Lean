#!/usr/bin/env python3
"""
Semantic Fiber Theory — Demonstrations

Numerical examples illustrating the key theorems:
1. Pointed group semantic separation
2. Ring enrichment divergence (ℤ[i] vs ℤ×ℤ)
3. Automorphism orbit counting (semantic fiber sizes)
4. Isomorphism torsor structure
"""

from itertools import product, permutations
from math import gcd
from collections import defaultdict


def demo_pointed_separation():
    """
    Demonstrate that the identity is semantically fixed:
    in any group, no automorphism moves the identity.
    Example: ℤ/nℤ for various n.
    """
    print("=" * 60)
    print("Demo 1: Pointed Group Semantic Separation")
    print("=" * 60)
    print()

    for n in [2, 3, 4, 5, 6, 8, 12]:
        # Automorphisms of ℤ/nℤ are multiplication by units mod n
        units = [k for k in range(1, n) if gcd(k, n) == 1]
        auts = [(lambda x, k=k, n=n: (k * x) % n) for k in units]

        # Check: every automorphism fixes 0 (identity)
        all_fix_zero = all(aut(0) == 0 for aut in auts)
        print(f"ℤ/{n}ℤ: |Aut| = {len(units)}, all fix identity: {all_fix_zero}")

        # Show orbits
        orbits = compute_orbits(n, units)
        print(f"  Orbits (semantic classes): {len(orbits)}")
        for i, orb in enumerate(orbits):
            print(f"    Class {i}: {sorted(orb)}")
        print()


def compute_orbits(n, units):
    """Compute orbits of Aut(ℤ/nℤ) on ℤ/nℤ."""
    visited = set()
    orbits = []
    for g in range(n):
        if g not in visited:
            orbit = set()
            for k in units:
                orbit.add((k * g) % n)
            orbits.append(orbit)
            visited |= orbit
    return orbits


def demo_ring_divergence():
    """
    Demonstrate that ℤ[i] and ℤ×ℤ have the same additive structure
    but different multiplicative structure.
    """
    print("=" * 60)
    print("Demo 2: Ring Enrichment Divergence")
    print("=" * 60)
    print()

    # ℤ[i] multiplication: (a+bi)(c+di) = (ac-bd) + (ad+bc)i
    def mul_zi(z1, z2):
        a, b = z1
        c, d = z2
        return (a * c - b * d, a * d + b * c)

    # ℤ×ℤ multiplication: componentwise
    def mul_prod(z1, z2):
        return (z1[0] * z2[0], z1[1] * z2[1])

    print("Additive structure (identical):")
    for (a, b), (c, d) in [((1, 2), (3, 4)), ((0, 1), (1, 0)), ((-1, 3), (2, -1))]:
        sum_val = (a + c, b + d)
        print(f"  ({a},{b}) + ({c},{d}) = {sum_val}  [same in both]")

    print()
    print("Multiplicative structure (different!):")
    test_pairs = [((1, 0), (0, 1)), ((1, 1), (1, -1)), ((2, 1), (1, 3))]
    for z1, z2 in test_pairs:
        prod_zi = mul_zi(z1, z2)
        prod_pp = mul_prod(z1, z2)
        print(f"  {z1} × {z2}:")
        print(f"    ℤ[i]:  {prod_zi}")
        print(f"    ℤ×ℤ:  {prod_pp}")
        if prod_zi != prod_pp:
            print(f"    → DIFFERENT!")

    print()
    print("Zero divisor test:")
    zd1, zd2 = (1, 0), (0, 1)
    print(f"  In ℤ×ℤ: {zd1} × {zd2} = {mul_prod(zd1, zd2)} (ZERO DIVISOR!)")
    print(f"  In ℤ[i]: {zd1} × {zd2} = {mul_zi(zd1, zd2)} (nonzero — no zero divisors)")
    print(f"  → ℤ[i] is an integral domain, ℤ×ℤ is not")
    print(f"  → No ring isomorphism can exist")
    print()


def demo_torsor():
    """
    Demonstrate the torsor structure: all isomorphisms between
    two copies of ℤ/nℤ differ by automorphisms.
    """
    print("=" * 60)
    print("Demo 3: Isomorphism Torsor Structure")
    print("=" * 60)
    print()

    n = 7  # prime, so Aut(ℤ/7ℤ) = (ℤ/7ℤ)* has 6 elements
    units = [k for k in range(1, n) if gcd(k, n) == 1]

    print(f"Group: ℤ/{n}ℤ")
    print(f"Aut(ℤ/{n}ℤ) = {{x ↦ kx | k ∈ {units}}} (size {len(units)})")
    print()

    # Fix reference isomorphism φ₀ = identity
    print("Reference isomorphism φ₀ = id")
    print("All isomorphisms = {φ₀ ∘ α | α ∈ Aut}:")
    for k in units:
        mapping = {x: (k * x) % n for x in range(n)}
        print(f"  α: x ↦ {k}x mod {n}  →  φ = φ₀∘α: {mapping}")

    print()
    print(f"Total isomorphisms: {len(units)} = |Aut(ℤ/{n}ℤ)| ✓")
    print()


def demo_semantic_fiber_sizes():
    """
    Compute semantic fiber sizes (orbit counts) for small groups.
    """
    print("=" * 60)
    print("Demo 4: Semantic Fiber Sizes")
    print("=" * 60)
    print()
    print(f"{'Group':<15} {'|G|':>5} {'|Aut|':>6} {'Orbits':>7} {'Rigid?':>7}")
    print("-" * 45)

    for n in range(2, 25):
        units = [k for k in range(1, n) if gcd(k, n) == 1]
        orbits = compute_orbits(n, units)
        is_rigid = len(orbits) == n
        print(f"ℤ/{n}ℤ{'':<9} {n:>5} {len(units):>6} {len(orbits):>7} {'YES' if is_rigid else 'no':>7}")

    print()
    print("Note: A group is semantically rigid iff #orbits = |G|")
    print("      (i.e., Aut(G) is trivial)")
    print("      For ℤ/nℤ, Aut ≅ (ℤ/nℤ)*, so rigid iff φ(n) = 1 iff n ∈ {1, 2}")
    print()


def demo_burnside_counting():
    """
    Apply Burnside's lemma to count semantic fibers.
    """
    print("=" * 60)
    print("Demo 5: Burnside Counting of Semantic Fibers")
    print("=" * 60)
    print()

    for n in [6, 8, 10, 12, 15, 20]:
        units = [k for k in range(1, n) if gcd(k, n) == 1]

        # Burnside: orbits = (1/|Aut|) Σ_{φ ∈ Aut} |Fix(φ)|
        total_fixed = 0
        for k in units:
            fixed = sum(1 for x in range(n) if (k * x) % n == x)
            total_fixed += fixed

        burnside_count = total_fixed / len(units)

        # Direct count
        orbits = compute_orbits(n, units)

        print(f"ℤ/{n}ℤ: Burnside = {total_fixed}/{len(units)} = {burnside_count:.0f}, "
              f"Direct = {len(orbits)} ✓" if burnside_count == len(orbits)
              else f"ℤ/{n}ℤ: MISMATCH!")

    print()


if __name__ == "__main__":
    demo_pointed_separation()
    demo_ring_divergence()
    demo_torsor()
    demo_semantic_fiber_sizes()
    demo_burnside_counting()


#!/usr/bin/env python3
"""
Visualization: Semantic Fiber Sizes for Cyclic Groups

Plots the number of orbits of Aut(ℤ/nℤ) on ℤ/nℤ as a function of n,
revealing the structure of semantic ambiguity.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import gcd, log2


def euler_phi(n: int) -> int:
    """Euler's totient function."""
    return sum(1 for k in range(1, n + 1) if gcd(k, n) == 1)


def semantic_fiber_size(n: int) -> int:
    """Number of orbits of Aut(ℤ/nℤ) on ℤ/nℤ."""
    if n <= 1:
        return n
    units = [k for k in range(1, n) if gcd(k, n) == 1]
    visited = set()
    orbits = 0
    for g in range(n):
        if g not in visited:
            orbit = set()
            for k in units:
                orbit.add((k * g) % n)
            visited |= orbit
            orbits += 1
    return orbits


def is_prime(n: int) -> bool:
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


# Compute data
N_MAX = 100
ns = list(range(2, N_MAX + 1))
fibers = [semantic_fiber_size(n) for n in ns]
phis = [euler_phi(n) for n in ns]
primes = [n for n in ns if is_prime(n)]
prime_fibers = [semantic_fiber_size(n) for n in primes]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Semantic Fiber Theory: Orbits of Aut(ℤ/nℤ) on ℤ/nℤ', fontsize=14, fontweight='bold')

# Plot 1: Fiber sizes
ax1 = axes[0, 0]
colors = ['red' if is_prime(n) else 'steelblue' for n in ns]
ax1.scatter(ns, fibers, c=colors, s=15, alpha=0.7)
ax1.plot(ns, fibers, 'k-', alpha=0.2, linewidth=0.5)
ax1.set_xlabel('n')
ax1.set_ylabel('Number of orbits')
ax1.set_title('Semantic Fiber Size')
ax1.legend(['All n', 'Prime n (red)'], loc='upper left')

# Plot 2: Fiber size / n ratio (semantic rigidity spectrum)
ax2 = axes[0, 1]
ratios = [f / n for f, n in zip(fibers, ns)]
ax2.scatter(ns, ratios, c=colors, s=15, alpha=0.7)
ax2.axhline(y=1.0, color='green', linestyle='--', alpha=0.5, label='Rigid (ratio=1)')
ax2.set_xlabel('n')
ax2.set_ylabel('Orbits / n')
ax2.set_title('Semantic Rigidity Spectrum')
ax2.set_ylim(0, 1.05)
ax2.legend()

# Plot 3: Fiber vs Aut size
ax3 = axes[1, 0]
ax3.scatter(phis, fibers, c=colors, s=15, alpha=0.7)
ax3.set_xlabel('|Aut(ℤ/nℤ)| = φ(n)')
ax3.set_ylabel('Number of orbits')
ax3.set_title('Fibers vs Automorphism Group Size')

# Plot 4: Fiber sizes for primes only
ax4 = axes[1, 1]
ax4.scatter(primes, prime_fibers, c='red', s=25, alpha=0.7)
ax4.plot(primes, [2] * len(primes), 'g--', alpha=0.5, label='Lower bound (=2)')
# For prime p, orbits = 1 + (number of orbits of (ℤ/pℤ)* on (ℤ/pℤ)*)
# Since (ℤ/pℤ)* is cyclic of order p-1, it acts on itself by multiplication
# and has exactly the divisors of p-1 as orbit sizes
ax4.set_xlabel('Prime p')
ax4.set_ylabel('Number of orbits')
ax4.set_title('Semantic Fibers for Prime-Order Groups')
ax4.legend()

plt.tight_layout()
plt.savefig('semantic_fibers.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved: semantic_fibers.png")
print(f"Computed semantic fiber sizes for n = 2..{N_MAX}")
print(f"Range of fiber sizes: {min(fibers)} to {max(fibers)}")
print(f"Groups with fiber size 2 (minimal for |G|≥2): "
      f"{[n for n, f in zip(ns, fibers) if f == 2]}")
