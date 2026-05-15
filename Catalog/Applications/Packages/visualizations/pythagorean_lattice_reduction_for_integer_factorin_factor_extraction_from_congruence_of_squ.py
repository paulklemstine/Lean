#!/usr/bin/env python3
"""
Pythagorean Lattice Reduction — Applications

Demonstrates real-world applications of the Pythagorean lattice framework:
1. RSA-style modulus factoring
2. Lattice analysis for cryptographic parameter assessment
3. Congruence density estimation
"""

from math import gcd, isqrt, log2
from typing import List, Tuple, Optional
import numpy as np
from algorithms import (
    pythagorean_lattice_factor,
    berggren_bfs_congruence,
    extract_factor_from_congruence,
    BERGGREN_GENS, ROOT,
    lattice_norm_statistics
)
from collections import deque


# ============================================================
# Application 1: RSA-style Modulus Analysis
# ============================================================

def analyze_rsa_modulus(p: int, q: int):
    """
    Analyze an RSA-style modulus n = p*q through the Pythagorean lattice lens.

    Shows the density of congruence-satisfying triples and the minimum
    depth at which a factor-revealing triple appears.
    """
    n = p * q
    print(f"\n  RSA Modulus Analysis: n = {p} × {q} = {n}")
    print(f"  Bit length: {int(log2(n)) + 1} bits")

    # Search for factor
    factor = pythagorean_lattice_factor(n, max_depth=12, verbose=True)

    if factor:
        print(f"  ✓ Factor found: {n} = {factor} × {n // factor}")
    else:
        print(f"  ✗ No factor found within search depth")

    # Lattice statistics
    stats = lattice_norm_statistics(n, depth=8)
    print(f"\n  Lattice Statistics (depth ≤ 8):")
    print(f"    Congruence-satisfying triples: {stats['count']}")
    print(f"    Factor-revealing triples:      {stats['factor_revealing']}")
    if stats['count'] > 0:
        print(f"    Density:                       {stats['factor_revealing']/stats['count']:.1%}")
        print(f"    Minimum ℓ¹ norm:               {stats['min_norm']}")
        print(f"    Shortest triple:               {stats['min_triple']}")


# ============================================================
# Application 2: Congruence Density Estimation
# ============================================================

def congruence_density_analysis():
    """
    Estimate the density of factor-revealing triples in the Berggren tree
    as a function of n for various semiprimes.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Congruence Density Analysis")
    print("=" * 70)

    semiprimes = [
        (3, 5), (5, 7), (7, 11), (11, 13), (13, 17),
        (17, 19), (19, 23), (23, 29), (29, 31), (31, 37)
    ]

    print(f"\n{'n':>8} {'p×q':>10} {'total':>8} {'cong':>8} {'factor':>8} {'density':>10}")
    print("-" * 60)

    for p, q in semiprimes:
        n = p * q
        # Count triples at fixed depth
        depth = 6
        queue = deque([(ROOT, 0)])
        total = 0
        cong_count = 0
        factor_count = 0

        while queue:
            triple, d = queue.popleft()
            total += 1
            a, b, c = int(triple[0]), int(triple[1]), int(triple[2])

            if (a**2 - b**2) % n == 0:
                cong_count += 1
                f = extract_factor_from_congruence(n, a, b)
                if f is not None:
                    factor_count += 1

            if d < depth:
                for M in BERGGREN_GENS:
                    queue.append((M @ triple, d + 1))

        density = factor_count / total if total > 0 else 0
        print(f"{n:>8} {f'{p}×{q}':>10} {total:>8} {cong_count:>8} {factor_count:>8} {density:>10.4f}")


# ============================================================
# Application 3: Lattice Geometry Visualization Data
# ============================================================

def lattice_geometry_data(n: int = 35, depth: int = 6):
    """
    Generate data showing the geometric structure of the Berggren lattice mod n.
    Outputs coordinates for plotting.
    """
    print(f"\n  Lattice geometry for n = {n}, depth ≤ {depth}")

    queue = deque([(ROOT, 0)])
    all_points = []
    lattice_points = []
    factor_points = []

    while queue:
        triple, d = queue.popleft()
        a, b, c = int(triple[0]), int(triple[1]), int(triple[2])
        all_points.append((a % n, b % n))

        if (a**2 - b**2) % n == 0:
            lattice_points.append((a % n, b % n))
            f = extract_factor_from_congruence(n, a, b)
            if f is not None:
                factor_points.append((a % n, b % n))

        if d < depth:
            for M in BERGGREN_GENS:
                queue.append((M @ triple, d + 1))

    print(f"    Total triples: {len(all_points)}")
    print(f"    Lattice members: {len(lattice_points)}")
    print(f"    Factor-revealing: {len(factor_points)}")

    # Show the residue classes mod n
    print(f"\n    Residue classes (a mod {n}, b mod {n}) of lattice members:")
    seen = set()
    for a_mod, b_mod in lattice_points:
        if (a_mod, b_mod) not in seen:
            seen.add((a_mod, b_mod))
            print(f"      ({a_mod:3d}, {b_mod:3d})")
    print(f"    Distinct residue classes: {len(seen)} out of {n**2} possible")

    return all_points, lattice_points, factor_points


# ============================================================
# Application 4: Comparative Factoring
# ============================================================

def comparative_factoring():
    """
    Compare Pythagorean lattice factoring with trial division
    for various semiprimes.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Comparative Factoring Analysis")
    print("=" * 70)

    import time

    semiprimes = [
        (7, 13), (11, 17), (13, 19), (17, 23), (19, 29),
        (23, 31), (29, 37), (31, 41), (37, 43), (41, 47)
    ]

    print(f"\n{'n':>8} {'Trial div':>12} {'Pyth lattice':>14} {'Speedup':>10}")
    print("-" * 48)

    for p, q in semiprimes:
        n = p * q

        # Trial division
        t0 = time.perf_counter()
        for _ in range(100):
            for d in range(2, isqrt(n) + 1):
                if n % d == 0:
                    break
        td_time = (time.perf_counter() - t0) / 100

        # Pythagorean lattice
        t0 = time.perf_counter()
        for _ in range(100):
            pythagorean_lattice_factor(n, max_depth=8)
        pl_time = (time.perf_counter() - t0) / 100

        speedup = td_time / pl_time if pl_time > 0 else float('inf')
        print(f"{n:>8} {td_time*1e6:>10.1f}μs {pl_time*1e6:>12.1f}μs {speedup:>9.2f}×")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Pythagorean Lattice Reduction — Applications                      ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    print("\n" + "=" * 70)
    print("APPLICATION 1: RSA Modulus Analysis")
    print("=" * 70)

    analyze_rsa_modulus(7, 13)
    analyze_rsa_modulus(101, 103)

    congruence_density_analysis()

    print("\n" + "=" * 70)
    print("APPLICATION 3: Lattice Geometry")
    print("=" * 70)
    lattice_geometry_data(35, 5)

    comparative_factoring()
