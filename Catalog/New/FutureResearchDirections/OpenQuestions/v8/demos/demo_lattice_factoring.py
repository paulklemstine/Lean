#!/usr/bin/env python3
"""
Lattice Reduction Factoring Demo

Demonstrates how LLL lattice reduction can be used for integer factoring,
connecting to the Coppersmith method and SVP-factoring relationship.

Formally verified foundations:
- factoring_lattice_exists: Lattice construction for factoring
- minkowski_2d_bound: Short vector existence (stated)
- normSq_nonneg: Norm properties
"""

import math
import random

def gcd(a, b):
    """Greatest common divisor."""
    while b:
        a, b = b, a % b
    return abs(a)

def gram_schmidt_2d(v1, v2):
    """Gram-Schmidt orthogonalization for 2D."""
    b1 = v1
    mu = (v2[0]*b1[0] + v2[1]*b1[1]) / (b1[0]**2 + b1[1]**2) if (b1[0]**2 + b1[1]**2) > 0 else 0
    b2 = (v2[0] - mu*b1[0], v2[1] - mu*b1[1])
    return b1, b2, mu

def norm_sq(v):
    """Squared Euclidean norm."""
    return v[0]**2 + v[1]**2

def lll_reduce_2d(v1, v2):
    """
    LLL reduction for a 2D lattice.
    Returns an LLL-reduced basis.
    """
    max_iter = 100
    for _ in range(max_iter):
        # Size reduce
        if norm_sq(v1) > 0:
            mu = round((v2[0]*v1[0] + v2[1]*v1[1]) / norm_sq(v1))
            v2 = (v2[0] - mu*v1[0], v2[1] - mu*v1[1])

        # Lovász condition
        if norm_sq(v2) < 0.75 * norm_sq(v1):
            v1, v2 = v2, v1
        else:
            break

    return v1, v2

def lattice_factor(N, verbose=True):
    """
    Attempt to factor N using lattice reduction.

    Idea: Construct a lattice where short vectors correspond to factors.
    For N = pq, the lattice {(a, b) : a + bx ≡ 0 (mod N)} for appropriate x
    contains a short vector related to (p, q).
    """
    if verbose:
        print(f"\n  Lattice factoring N = {N}")

    sqrt_N = int(math.sqrt(N))

    # Try different lattice constructions
    for attempt in range(20):
        # Random multiplier approach
        if attempt == 0:
            c = sqrt_N
        else:
            c = random.randint(max(2, sqrt_N - 10), sqrt_N + 10)

        # Construct lattice with basis [[N, 0], [c, 1]]
        v1 = (N, 0)
        v2 = (c, 1)

        # LLL reduce
        u1, u2 = lll_reduce_2d(v1, v2)

        # Check if short vectors give factors
        for v in [u1, u2]:
            for component in v:
                if component == 0:
                    continue
                g = gcd(abs(component), N)
                if 1 < g < N:
                    if verbose:
                        print(f"    Found factor: {g} (from vector {v})")
                    return g

        # Also try linear combinations
        for a in range(-3, 4):
            for b in range(-3, 4):
                if a == 0 and b == 0:
                    continue
                combo = (a*u1[0] + b*u2[0], a*u1[1] + b*u2[1])
                for component in combo:
                    if component == 0:
                        continue
                    g = gcd(abs(component), N)
                    if 1 < g < N:
                        if verbose:
                            print(f"    Found factor: {g} (from combination {a}v1 + {b}v2)")
                        return g

    if verbose:
        print("    No factor found via lattice reduction")
    return None

def coppersmith_demo(N, verbose=True):
    """
    Simplified Coppersmith-style small root finding.

    For N = pq with p close to √N, we look for small x₀ with
    f(x₀) = (√N + x₀)² - N ≡ 0 (mod p).
    """
    if verbose:
        print(f"\n  Coppersmith-style factoring N = {N}")

    sqrt_N = int(math.sqrt(N))

    # f(x) = (sqrt_N + x)² - N = 2*sqrt_N*x + x² + (sqrt_N² - N)
    c = sqrt_N * sqrt_N - N  # Small if N is close to a perfect square

    # For small x, f(x) ≈ 2*sqrt_N*x + c
    # If p | f(x₀), then gcd(f(x₀), N) might give p

    for x in range(-sqrt_N, sqrt_N + 1):
        val = (sqrt_N + x) ** 2 - N
        if val == 0:
            if verbose:
                print(f"    N is a perfect square!")
            return sqrt_N + x

        g = gcd(abs(val), N)
        if 1 < g < N:
            if verbose:
                print(f"    Found factor: {g} via f({x}) = {val}")
            return g

    if verbose:
        print("    No factor found via Coppersmith approach")
    return None

def demo_lll_properties():
    """Demonstrate LLL reduction properties."""
    print("=" * 70)
    print("LLL LATTICE REDUCTION PROPERTIES")
    print("=" * 70)

    # Example lattices
    examples = [
        ((100, 0), (37, 1), "Factoring-style"),
        ((256, 0), (197, 1), "Large modulus"),
        ((1000, 0), (314, 1), "N=1000"),
    ]

    for v1, v2, name in examples:
        u1, u2 = lll_reduce_2d(v1, v2)
        det = abs(v1[0]*v2[1] - v1[1]*v2[0])

        print(f"\n  {name}:")
        print(f"    Input:  v1={v1}, v2={v2}")
        print(f"    Output: u1={u1}, u2={u2}")
        print(f"    |u1|² = {norm_sq(u1):.1f}")
        print(f"    |u2|² = {norm_sq(u2):.1f}")
        print(f"    det = {det}")
        print(f"    Minkowski bound: |v|² ≤ {2*det}")
        print(f"    LLL guarantee met: {'✓' if norm_sq(u1) <= 2*det else '✗'}")

def demo_factoring_comparison():
    """Compare lattice factoring with other methods."""
    print("\n" + "=" * 70)
    print("FACTORING METHOD COMPARISON")
    print("=" * 70)

    test_cases = [
        (143, "11 × 13"),
        (323, "17 × 19"),
        (1073, "29 × 37"),
        (2021, "43 × 47"),
        (10403, "101 × 103"),
        (25117, "149 × 167 (or prime?)"),
    ]

    print(f"\n{'N':>8s} {'Expected':>15s} {'Lattice':>10s} {'Coppersmith':>12s} {'Trial':>10s}")
    print("-" * 60)

    for N, expected in test_cases:
        lat = lattice_factor(N, verbose=False)
        cop = coppersmith_demo(N, verbose=False)

        # Trial division
        trial = None
        for d in range(2, int(math.sqrt(N)) + 1):
            if N % d == 0:
                trial = d
                break

        lat_str = str(lat) if lat else "—"
        cop_str = str(cop) if cop else "—"
        trial_str = str(trial) if trial else "prime"

        print(f"{N:8d} {expected:>15s} {lat_str:>10s} {cop_str:>12s} {trial_str:>10s}")

def demo_svp_connection():
    """Demonstrate the SVP-factoring connection."""
    print("\n" + "=" * 70)
    print("SVP-FACTORING CONNECTION")
    print("The Shortest Vector Problem encodes factoring")
    print("=" * 70)

    N = 77  # = 7 × 11
    print(f"\nN = {N} = 7 × 11")
    print(f"√N ≈ {math.sqrt(N):.2f}")

    # Construct the factoring lattice
    print(f"\nFactoring lattice basis:")
    print(f"  v1 = (N, 0) = ({N}, 0)")
    print(f"  v2 = (⌈√N⌉, 1) = ({int(math.ceil(math.sqrt(N)))}, 1)")

    v1 = (N, 0)
    v2 = (int(math.ceil(math.sqrt(N))), 1)

    u1, u2 = lll_reduce_2d(v1, v2)

    print(f"\nAfter LLL reduction:")
    print(f"  u1 = {u1}, |u1|² = {norm_sq(u1)}")
    print(f"  u2 = {u2}, |u2|² = {norm_sq(u2)}")

    print(f"\nChecking GCDs with N = {N}:")
    for v in [u1, u2]:
        for c in v:
            if c != 0:
                g = gcd(abs(c), N)
                if 1 < g < N:
                    print(f"  gcd({abs(c)}, {N}) = {g} ← FACTOR!")
                else:
                    print(f"  gcd({abs(c)}, {N}) = {g}")

if __name__ == "__main__":
    demo_lll_properties()
    demo_factoring_comparison()
    demo_svp_connection()

    print("\n" + "=" * 70)
    print("DETAILED LATTICE FACTORING EXAMPLES")
    print("=" * 70)

    for N, name in [(91, "7×13"), (221, "13×17"), (1517, "37×41")]:
        lattice_factor(N, verbose=True)
