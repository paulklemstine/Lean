#!/usr/bin/env python3
"""Ghost Map Explorer: Interactive demos for the Berggren ghost map.

Explores factoring via the ghost map (inverse of Berggren B₂ matrix),
including orbits, unit probe descent, deficit channel, multi-triplet voting,
trace identity, eigenstructure, two-invariant recovery, and benchmarking.
"""

import math
from collections import Counter
from typing import Tuple, List, Optional


# ── Ghost Map Definition ──────────────────────────────────────────────

def ghost(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Apply the ghost map G(a,b,c) = B₂⁻¹(a,b,c)."""
    return (a + 2*b - 2*c,
            2*a + b - 2*c,
            -2*a - 2*b + 3*c)


def deficit(a: int, b: int, c: int) -> int:
    """Lorentz deficit δ = a² + b² - c²."""
    return a*a + b*b - c*c


def trace_sum(a: int, b: int, c: int) -> int:
    """Component sum of the triple (= a + b + c, but ghost trace = a + b - c)."""
    return a + b + c


def ghost_trace(a: int, b: int, c: int) -> int:
    """The ghost trace identity: gp + gq + gh = a + b - c."""
    p, q, h = ghost(a, b, c)
    return p + q + h  # Should equal a + b - c


# ── Demo 1: Ghost Map Orbits ─────────────────────────────────────────

def demo_orbits():
    """Trace the ghost map orbit of several triples."""
    print("=" * 60)
    print("Demo 1: Ghost Map Orbits")
    print("=" * 60)

    triples = [(3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25)]

    for triple in triples:
        a, b, c = triple
        print(f"\nOrbit of ({a}, {b}, {c}):  deficit = {deficit(a, b, c)}")
        for i in range(6):
            d = deficit(a, b, c)
            t = a + b - c  # ghost trace
            print(f"  G^{i}: ({a:6d}, {b:6d}, {c:6d})  δ={d:6d}  τ={t:6d}")
            a, b, c = ghost(a, b, c)


# ── Demo 2: Unit Probe Descent Chain ─────────────────────────────────

def demo_unit_probe():
    """Show the unit probe (1, N, N) descent chain."""
    print("\n" + "=" * 60)
    print("Demo 2: Unit Probe Descent Chain")
    print("=" * 60)

    for N in [15, 21, 35, 77]:
        print(f"\nUnit probe (1, {N}, {N}):  deficit = {deficit(1, N, N)}")
        a, b, c = 1, N, N
        for step in range(min(N, 20)):
            p, q, h = ghost(a, b, c)
            print(f"  Step {step}: p={p}, q={q}, h={h}")
            if abs(h) <= 2:
                print(f"  → Reached base case at step {step}")
                break
            a, b, c = p, abs(q), abs(h)

        # Factor discovery via GCD
        factors_found = set()
        a, b, c = 1, N, N
        for step in range(N):
            p, q, h = ghost(a, b, c)
            g = math.gcd(abs(q), N)
            if 1 < g < N:
                factors_found.add(g)
            a, b, c = p, q, h
        if factors_found:
            print(f"  Factors found: {sorted(factors_found)}")
        else:
            print(f"  No proper factors found (N={N} is prime?)")


# ── Demo 3: Deficit Channel ──────────────────────────────────────────

def demo_deficit_channel():
    """Scan the deficit channel for factor clues."""
    print("\n" + "=" * 60)
    print("Demo 3: Deficit Channel Scan")
    print("=" * 60)

    for N in [15, 21, 35, 91]:
        print(f"\nDeficit channel for N = {N}:")
        hits = []
        for x in range(1, min(N, 50)):
            c_approx = round(math.sqrt(x*x + N*N))
            d = deficit(x, N, c_approx)
            g = math.gcd(abs(d), N)
            if 1 < g < N:
                hits.append((x, d, g))
        if hits:
            for x, d, g in hits[:5]:
                print(f"  x={x}: deficit={d}, gcd(|δ|, N)={g}")
        else:
            print("  No hits found in scan range")


# ── Demo 4: Multi-Triplet Voting ─────────────────────────────────────

def demo_multi_triplet():
    """Use multiple triplet types and vote on factors."""
    print("\n" + "=" * 60)
    print("Demo 4: Multi-Triplet Factor Voting")
    print("=" * 60)

    def find_factors_voting(N: int) -> Optional[int]:
        """Try to find a non-trivial factor of N using multi-triplet voting."""
        votes: Counter = Counter()

        # Channel 1: Linear triplets (x, N, x+N)
        for x in range(1, min(N, 100)):
            d = deficit(x, N, x + N)
            g = math.gcd(abs(d), N)
            if 1 < g < N:
                votes[g] += 2  # Higher weight

        # Channel 2: Diff triplets (x, N-x, N)
        for x in range(1, N):
            d = deficit(x, N - x, N)
            g = math.gcd(abs(d), N)
            if 1 < g < N:
                votes[g] += 1

        # Channel 3: Ghost map GCDs
        for x in range(1, min(N, 50)):
            a, b, c = x, N, x + N
            for _ in range(5):
                p, q, h = ghost(a, b, c)
                for val in [p, q, h, p + q, p - q]:
                    g = math.gcd(abs(val), N)
                    if 1 < g < N:
                        votes[g] += 1
                a, b, c = p, q, h

        if votes:
            return votes.most_common(1)[0][0]
        return None

    # Test on semiprimes
    semiprimes = [(3, 5), (7, 11), (13, 17), (23, 29), (31, 37), (41, 43)]
    success = 0
    total = len(semiprimes)

    for p, q in semiprimes:
        N = p * q
        factor = find_factors_voting(N)
        if factor and N % factor == 0:
            success += 1
            print(f"  N = {p} × {q} = {N}: found factor {factor} ✓")
        else:
            print(f"  N = {p} × {q} = {N}: no factor found ✗")

    print(f"\n  Success rate: {success}/{total} = {100*success/total:.0f}%")


# ── Demo 5: Trace Identity ───────────────────────────────────────────

def demo_trace_identity():
    """Verify the ghost trace identity: gp + gq + gh = a + b - c."""
    print("\n" + "=" * 60)
    print("Demo 5: Ghost Trace Identity Verification")
    print("=" * 60)

    import random
    random.seed(42)

    for _ in range(10):
        a = random.randint(-100, 100)
        b = random.randint(-100, 100)
        c = random.randint(-100, 100)
        p, q, h = ghost(a, b, c)
        lhs = p + q + h
        rhs = a + b - c
        status = "✓" if lhs == rhs else "✗"
        print(f"  ({a:4d}, {b:4d}, {c:4d}) → G sum = {lhs:6d}, a+b-c = {rhs:6d}  {status}")


# ── Demo 6: Eigenvalue Analysis ──────────────────────────────────────

def demo_eigenvalues():
    """Compute and verify the eigenvalues of the ghost matrix."""
    print("\n" + "=" * 60)
    print("Demo 6: Ghost Matrix Eigenvalue Analysis")
    print("=" * 60)

    import numpy as np

    G = np.array([[1, 2, -2],
                   [2, 1, -2],
                   [-2, -2, 3]], dtype=float)

    eigenvalues, eigenvectors = np.linalg.eig(G)

    print(f"  Ghost matrix G:")
    for row in G:
        print(f"    {row}")

    print(f"\n  Eigenvalues: {eigenvalues}")
    print(f"  Expected: -1, 3+2√2 ≈ {3+2*math.sqrt(2):.4f}, 3-2√2 ≈ {3-2*math.sqrt(2):.4f}")

    print(f"\n  Eigenvectors (columns):")
    for i in range(3):
        v = eigenvectors[:, i]
        print(f"    λ = {eigenvalues[i]:.4f}: v = ({v[0]:.4f}, {v[1]:.4f}, {v[2]:.4f})")

    print(f"\n  Characteristic polynomial: λ³ - 5λ² - 5λ + 1")
    print(f"  = (λ+1)(λ²-6λ+1)")
    print(f"  det(G) = {np.linalg.det(G):.0f}")
    print(f"  tr(G) = {np.trace(G):.0f}")


# ── Demo 7: Two-Invariant Recovery ───────────────────────────────────

def demo_two_invariant():
    """Demonstrate the two-invariant product formula: 2ab = τ² + 2τc - δ."""
    print("\n" + "=" * 60)
    print("Demo 7: Two-Invariant Product Recovery")
    print("=" * 60)

    test_cases = [(3, 4, 5), (5, 12, 13), (7, 24, 25), (8, 15, 17),
                  (3, 5, 15), (7, 11, 77), (2, 3, 6)]

    for a, b, c in test_cases:
        tau = a + b - c
        delta = deficit(a, b, c)
        recovered = tau**2 + 2*tau*c - delta
        actual = 2 * a * b
        status = "✓" if recovered == actual else "✗"
        print(f"  ({a:2d}, {b:2d}, {c:3d}): τ={tau:4d}, δ={delta:6d}, "
              f"2ab={actual:6d}, recovered={recovered:6d}  {status}")


# ── Demo 8: Benchmarking ─────────────────────────────────────────────

def demo_benchmark():
    """Benchmark ghost-based factoring vs trial division."""
    print("\n" + "=" * 60)
    print("Demo 8: Factoring Benchmark")
    print("=" * 60)

    import time

    def trial_division(N: int) -> Optional[int]:
        for i in range(2, int(math.sqrt(N)) + 1):
            if N % i == 0:
                return i
        return None

    def ghost_factor(N: int, max_iter: int = 1000) -> Optional[int]:
        """Try ghost-based factoring using multiple channels."""
        # Try linear triplets
        for x in range(1, min(N, max_iter)):
            d = -2 * x * N
            g = math.gcd(abs(d), N)
            if 1 < g < N:
                return g
        # Try diff triplets
        for x in range(1, N):
            d = -2 * x * (N - x)
            g = math.gcd(abs(d), N)
            if 1 < g < N:
                return g
        return None

    # Generate semiprimes
    primes = [p for p in range(3, 200) if all(p % i != 0 for i in range(2, int(p**0.5)+1))]
    semiprimes = []
    for i in range(len(primes)):
        for j in range(i+1, len(primes)):
            N = primes[i] * primes[j]
            if N < 10000:
                semiprimes.append((primes[i], primes[j], N))

    print(f"  Testing {len(semiprimes)} semiprimes < 10000...")

    t0 = time.time()
    td_success = sum(1 for _, _, N in semiprimes if trial_division(N) is not None)
    t1 = time.time()

    t2 = time.time()
    gf_success = sum(1 for _, _, N in semiprimes if ghost_factor(N) is not None)
    t3 = time.time()

    print(f"  Trial division: {td_success}/{len(semiprimes)} success, {(t1-t0)*1000:.1f}ms")
    print(f"  Ghost factor:   {gf_success}/{len(semiprimes)} success, {(t3-t2)*1000:.1f}ms")


# ── Main ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Ghost Map Explorer: Factoring via Berggren Descent     ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_orbits()
    demo_unit_probe()
    demo_deficit_channel()
    demo_multi_triplet()
    demo_trace_identity()

    try:
        import numpy as np
        demo_eigenvalues()
    except ImportError:
        print("\n[Skipping Demo 6: numpy not available]")

    demo_two_invariant()
    demo_benchmark()

    print("\n" + "=" * 60)
    print("All demos complete!")
    print("=" * 60)
