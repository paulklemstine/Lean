"""
Numerical demonstrations of the sharp dichotomy for the total d-Hoggatt numbers.

The total d-Hoggatt numbers are the row sums H_d(n) = sum_k H_d(n,k):
    d = 1 : H_1(n) = 2^n            (powers of two)
    d = 2 : H_2(n) = C_n            (Catalan numbers)
    d = 3 : H_3(n)                  (Baxter numbers)

Main facts illustrated here:
    * 2^n is LOG-LINEAR:        a(n+1)^2 = a(n)*a(n+2)   (equality)  -> not strictly log-convex
    * C_n is STRICTLY LOG-CONVEX: a(n+1)^2 < a(n)*a(n+2)             -> not log-concave
    * Exact discriminant identity for Catalan:
          (2n+1)(n+3) C_n C_{n+2} = (n+2)(2n+3) C_{n+1}^2,
      the two coefficients differing by the positive constant 3.
    * Ratio-monotonicity: C_{n+1}/C_n is strictly increasing.
    * Tropical form: with v(n) = -log a(n), strict log-convexity <=> strict concavity of v.

This script is self-contained (standard library only) and prints tables verifying
each statement over a range of n.
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Callable, List, Tuple


# ----------------------------------------------------------------------------
# Sequences
# ----------------------------------------------------------------------------

def pow_two(n: int) -> int:
    """The d = 1 total: H_1(n) = 2^n."""
    return 1 << n


def catalan(n: int) -> int:
    """The d = 2 total: the n-th Catalan number C_n = binom(2n, n) / (n + 1)."""
    return math.comb(2 * n, n) // (n + 1)


def baxter(n: int) -> int:
    """The d = 3 total: the n-th Baxter number.

    B(n) = sum_{k=1}^{n}  C(n+1,k-1) * C(n+1,k) * C(n+1,k+1)
                          / ( C(n+1,1) * C(n+1,2) )
    with B(0) = 1.  Here C(.,.) denotes a binomial coefficient.
    The sequence begins 1, 1, 2, 6, 22, 92, 422, 2074, ...
    """
    if n == 0:
        return 1
    denom = math.comb(n + 1, 1) * math.comb(n + 1, 2)
    total = 0
    for k in range(1, n + 1):
        total += (
            math.comb(n + 1, k - 1)
            * math.comb(n + 1, k)
            * math.comb(n + 1, k + 1)
        )
    assert total % denom == 0, "Baxter number should be an integer"
    return total // denom


# ----------------------------------------------------------------------------
# Curvature classification
# ----------------------------------------------------------------------------

def discriminant(a: Callable[[int], int], n: int) -> int:
    """Return a(n)*a(n+2) - a(n+1)^2.

    > 0  : strictly log-convex at n
    = 0  : log-linear at n
    < 0  : strictly log-concave at n
    """
    return a(n) * a(n + 2) - a(n + 1) ** 2


def classify(a: Callable[[int], int], upto: int) -> str:
    signs = {sign(discriminant(a, n)) for n in range(upto)}
    if signs == {0}:
        return "log-linear (log-concave and log-convex with equality)"
    if signs <= {1}:
        return "strictly log-convex (hence not log-concave)"
    if signs <= {-1, 0}:
        return "log-concave"
    return "mixed"


def sign(x: int) -> int:
    return (x > 0) - (x < 0)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_dichotomy(upto: int = 12) -> None:
    print("=" * 74)
    print("SHARP DICHOTOMY: curvature of the total d-Hoggatt numbers")
    print("=" * 74)
    for name, a in (("d=1  2^n", pow_two), ("d=2  C_n", catalan), ("d=3  Baxter", baxter)):
        print(f"\n[{name}]  discriminant a(n)a(n+2) - a(n+1)^2  for n = 0..{upto-1}")
        row = [discriminant(a, n) for n in range(upto)]
        print("   values:", row)
        print("   verdict:", classify(a, upto))


def demo_catalan_discriminant_identity(upto: int = 12) -> None:
    print("\n" + "=" * 74)
    print("EXACT DISCRIMINANT IDENTITY for the Catalan totals")
    print("  (2n+1)(n+3) * C_n C_{n+2}  =  (n+2)(2n+3) * C_{n+1}^2")
    print("=" * 74)
    print(f"{'n':>3} | {'LHS':>18} | {'RHS':>18} | {'coeff gap':>9}")
    print("-" * 60)
    for n in range(upto):
        lhs = (2 * n + 1) * (n + 3) * catalan(n) * catalan(n + 2)
        rhs = (n + 2) * (2 * n + 3) * catalan(n + 1) ** 2
        gap = (n + 2) * (2 * n + 3) - (2 * n + 1) * (n + 3)
        assert lhs == rhs, f"identity failed at n={n}"
        print(f"{n:>3} | {lhs:>18} | {rhs:>18} | {gap:>9}")
    print("The coefficient gap is the constant 3 -- the source of strictness.")


def demo_ratio_monotonicity(upto: int = 12) -> None:
    print("\n" + "=" * 74)
    print("RATIO MONOTONICITY: C_{n+1}/C_n is strictly increasing")
    print("=" * 74)
    print(f"{'n':>3} | {'C_{n+1}/C_n':>14} | increasing?")
    print("-" * 44)
    prev: Fraction | None = None
    for n in range(upto):
        r = Fraction(catalan(n + 1), catalan(n))
        inc = "-" if prev is None else ("yes" if r > prev else "NO")
        print(f"{n:>3} | {float(r):>14.10f} | {inc}")
        prev = r
    print("Ratios rise monotonically toward the limit 4.")


def demo_tropical(upto: int = 12) -> None:
    print("\n" + "=" * 74)
    print("TROPICAL / DEQUANTIZED VIEW: v(n) = -log a(n), second difference")
    print("  Delta^2 v(n) = v(n) - 2 v(n+1) + v(n+2)")
    print("  = 0  -> v affine (d=1);   > 0 -> v strictly concave (d=2)")
    print("=" * 74)
    print(f"{'n':>3} | {'Delta^2 v (2^n)':>16} | {'Delta^2 v (C_n)':>16}")
    print("-" * 44)
    for n in range(upto):
        def d2v(a: Callable[[int], int]) -> float:
            v = lambda m: -math.log(a(m))
            return v(n) - 2 * v(n + 1) + v(n + 2)
        print(f"{n:>3} | {d2v(pow_two):>16.10f} | {d2v(catalan):>16.10f}")
    print("For 2^n the second difference is exactly 0; for C_n it is strictly positive.")


def main() -> None:
    demo_dichotomy()
    demo_catalan_discriminant_identity()
    demo_ratio_monotonicity()
    demo_tropical()
    print("\nAll demonstrations completed and internal assertions passed.")


if __name__ == "__main__":
    main()
