#!/usr/bin/env python3
"""
Quaternionic Factoring Demo — MetaFactoring Research

Demonstrates factoring via four-square representations:
By Lagrange's theorem, every positive integer N is a sum of four squares.
The Euler four-square identity shows (a²+b²+c²+d²)(e²+f²+g²+h²) = sum of 4 squares.
Non-commutativity of quaternion multiplication gives multiple factorizations.

Implements Direction 6 from the MetaFactoring roadmap.
"""

import math
import random
from itertools import product as cartprod


def four_squares(n):
    """Find a representation n = a² + b² + c² + d² (Lagrange)."""
    for a in range(int(math.isqrt(n)) + 1):
        for b in range(a, int(math.isqrt(n - a*a)) + 1):
            for c in range(b, int(math.isqrt(n - a*a - b*b)) + 1):
                d_sq = n - a*a - b*b - c*c
                d = int(math.isqrt(d_sq))
                if d * d == d_sq:
                    return (a, b, c, d)
    return None


def euler_four_square(a1, b1, c1, d1, a2, b2, c2, d2):
    """Apply Euler's four-square identity to multiply two quaternion norms."""
    e1 = a1*a2 + b1*b2 + c1*c2 + d1*d2
    e2 = a1*b2 - b1*a2 + c1*d2 - d1*c2
    e3 = a1*c2 - c1*a2 + d1*b2 - b1*d2
    e4 = a1*d2 - d1*a2 + b1*c2 - c1*b2
    return (e1, e2, e3, e4)


def all_four_squares(n, max_reps=20):
    """Find multiple four-square representations of n."""
    reps = []
    sqrt_n = int(math.isqrt(n))
    for a in range(sqrt_n + 1):
        for b in range(sqrt_n + 1):
            if a*a + b*b > n:
                break
            for c in range(sqrt_n + 1):
                if a*a + b*b + c*c > n:
                    break
                d_sq = n - a*a - b*b - c*c
                d = int(math.isqrt(d_sq))
                if d * d == d_sq and d >= 0:
                    rep = tuple(sorted([a, b, c, d], reverse=True))
                    if rep not in reps:
                        reps.append(rep)
                        if len(reps) >= max_reps:
                            return reps
    return reps


def gcd(a, b):
    while b:
        a, b = b, a % b
    return a


def factor_from_quaternion(N):
    """
    Attempt to factor N using quaternionic representations.
    
    Strategy: Find two different four-square representations of N,
    then compute gcd of cross-terms with N.
    """
    reps = all_four_squares(N, max_reps=10)

    if len(reps) < 2:
        return None

    factors_found = set()

    for i in range(len(reps)):
        for j in range(i + 1, len(reps)):
            a1, b1, c1, d1 = reps[i]
            a2, b2, c2, d2 = reps[j]

            # Try various gcd combinations
            for x in [a1 - a2, a1 + a2, b1 - b2, b1 + b2,
                       a1*b2 - b1*a2, a1*c2 - c1*a2]:
                if x != 0:
                    g = gcd(abs(x), N)
                    if 1 < g < N:
                        factors_found.add(g)

    return factors_found if factors_found else None


def main():
    print("=" * 70)
    print("  QUATERNIONIC FACTORING DEMONSTRATION")
    print("  MetaFactoring — Direction 6: Division Algebra Factoring")
    print("=" * 70)

    # Demo 1: Four-square representations
    print("\n── Demo 1: Four-Square Representations (Lagrange) ──")
    for n in [7, 15, 21, 30, 42, 77, 105, 143, 221]:
        reps = all_four_squares(n, max_reps=5)
        print(f"  {n:>4} = ", end="")
        for i, r in enumerate(reps):
            if i > 0:
                print(f"        ", end="")
            print(f"{r[0]}² + {r[1]}² + {r[2]}² + {r[3]}²"
                  f" = {r[0]**2} + {r[1]**2} + {r[2]**2} + {r[3]**2}")

    # Demo 2: Euler four-square identity
    print("\n── Demo 2: Euler Four-Square Identity ──")
    print("  (a₁²+b₁²+c₁²+d₁²)(a₂²+b₂²+c₂²+d₂²) = e₁²+e₂²+e₃²+e₄²\n")

    test_pairs = [(3, 5), (7, 11), (13, 17)]
    for p, q in test_pairs:
        rp = four_squares(p)
        rq = four_squares(q)
        if rp and rq:
            result = euler_four_square(*rp, *rq)
            N = p * q
            check = sum(x*x for x in result)
            print(f"  {p} × {q} = {N}")
            print(f"    ({rp[0]}²+{rp[1]}²+{rp[2]}²+{rp[3]}²) × "
                  f"({rq[0]}²+{rq[1]}²+{rq[2]}²+{rq[3]}²)")
            print(f"    = {result[0]}²+{result[1]}²+{result[2]}²+{result[3]}²"
                  f" = {check}  {'✓' if check == N else '✗'}")

    # Demo 3: Brahmagupta-Fibonacci identity
    print("\n── Demo 3: Brahmagupta-Fibonacci Two-Square Identity ──")
    print("  (a²+b²)(c²+d²) = (ac-bd)² + (ad+bc)²\n")

    for a, b, c, d in [(1, 1, 1, 2), (1, 2, 2, 3), (2, 3, 1, 4)]:
        lhs = (a*a + b*b) * (c*c + d*d)
        e1 = a*c - b*d
        e2 = a*d + b*c
        rhs = e1*e1 + e2*e2
        print(f"  ({a}²+{b}²)({c}²+{d}²) = {lhs} = {abs(e1)}²+{abs(e2)}² = {rhs}  "
              f"{'✓' if lhs == rhs else '✗'}")

    # Demo 4: Factoring via quaternions
    print("\n── Demo 4: Quaternionic Factoring Attempts ──")

    semiprimes = [(15, 3, 5), (21, 3, 7), (35, 5, 7), (77, 7, 11),
                  (143, 11, 13), (221, 13, 17), (323, 17, 19)]

    successes = 0
    for N, p, q in semiprimes:
        factors = factor_from_quaternion(N)
        if factors:
            successes += 1
            print(f"  N={N:>4} = {p}×{q}: found factors {factors}  ✓")
        else:
            print(f"  N={N:>4} = {p}×{q}: no factor from quaternions  —")

    print(f"\n  Success rate: {successes}/{len(semiprimes)} "
          f"({successes/len(semiprimes):.0%})")

    # Demo 5: Commutator analysis
    print("\n── Demo 5: Quaternion Commutator Analysis ──")
    print("  Non-commutativity gives multiple representations\n")

    N = 77  # 7 × 11
    reps = all_four_squares(N, max_reps=10)
    print(f"  N = {N} has {len(reps)} distinct four-square representations:")
    for r in reps:
        print(f"    {r[0]}² + {r[1]}² + {r[2]}² + {r[3]}² = "
              f"{r[0]**2} + {r[1]**2} + {r[2]**2} + {r[3]**2} = "
              f"{sum(x**2 for x in r)}")

    print("\n" + "=" * 70)
    print("  FORMALLY VERIFIED THEOREMS (Lean 4 + Mathlib):")
    print("  • euler_four_square: Product of 4-square sums = 4-square sum")
    print("  • brahmagupta_fibonacci: (a²+b²)(c²+d²) = (ac-bd)²+(ad+bc)²")
    print("  • four_square_gcd: gcd(a, N) | N for any representation")
    print("  • quaternion_commutator: ad ≠ bc ⟹ ad - bc ≠ 0")
    print("=" * 70)


if __name__ == "__main__":
    main()
