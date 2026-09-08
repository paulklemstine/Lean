"""
The Fork Channel: numerical demonstration of the complete crossing spectrum.

Model
-----
For a branching node of arity n (n > 0):

    delta(n) = 1 / n^2                     entropy deficit  (= collision
                                           probability of [n] x [n])
    A(n)     = log2(n) - 1 - delta(n)      address channel  (additive penalty)
    X(n)     = 2 * (1 - delta(n))          exchange channel (multiplicative)
    R(n)     = log2(n) + delta(n)          resonance functional

Central identity:   A(n) - X(n) = R(n) - 3.

This script verifies, numerically and with exact integer arithmetic:

  1. the collapse identity A - X = R - 3;
  2. the combinatorial grounding delta(n) = collision probability;
  3. the integer criterion  X(m) < A(m)  <=>  2^(3m^2-1) < m^(m^2), including
     the two decisive certificates 7^49 < 2^146 and 2^191 < 8^64;
  4. the sign dichotomy: A < X on (2, 7], A > X on [8, oo);
  5. uniqueness of the crossing r in (7, 8), and its certified dyadic bracket
     253/32 < r < 507/64;
  6. the exact sub-critical crossing A(1/2) = X(1/2) = -6;
  7. strict monotonicity and divergence of the ratio A/X.

Pure standard library; no third-party dependencies.
"""

from __future__ import annotations

from fractions import Fraction
from math import log, log2, sqrt
from typing import Callable, Iterable, List, Tuple

# --------------------------------------------------------------------------
# 1. The model
# --------------------------------------------------------------------------


def deficit(n: float) -> float:
    """Entropy deficit delta(n) = 1 / n^2."""
    return 1.0 / (n * n)


def address_channel(n: float) -> float:
    """Address channel A(n) = log2(n) - 1 - delta(n)."""
    return log2(n) - 1.0 - deficit(n)


def exchange_channel(n: float) -> float:
    """Exchange channel X(n) = 2 (1 - delta(n))."""
    return 2.0 * (1.0 - deficit(n))


def resonance(n: float) -> float:
    """Resonance functional R(n) = log2(n) + delta(n)."""
    return log2(n) + deficit(n)


def ratio(n: float) -> float:
    """Channel ratio A(n) / X(n)."""
    return address_channel(n) / exchange_channel(n)


def resonance_derivative(n: float) -> float:
    """R'(n) = 1/(n ln 2) - 2/n^3."""
    return 1.0 / (n * log(2.0)) - 2.0 / n**3


# --------------------------------------------------------------------------
# 2. Combinatorial grounding of the deficit
# --------------------------------------------------------------------------


def fork_collision_probability(n: int) -> Fraction:
    """Exact probability that two independent uniform probes of the ordered
    branch-pair set [n] x [n] return the same pair.

    Favourable outcomes: the diagonal of S x S with S = [n] x [n], of size n^2.
    Total outcomes: |S|^2 = (n^2)^2.
    """
    s = n * n
    return Fraction(s, s * s)


# --------------------------------------------------------------------------
# 3. The exact integer criterion
# --------------------------------------------------------------------------


def integer_criterion_winner(m: int) -> str:
    """Decide the channel comparison at integer arity m >= 2 by exact integers.

    X(m) < A(m)  <=>  2^(3 m^2 - 1) < m^(m^2)
    A(m) < X(m)  <=>  m^(m^2) < 2^(3 m^2 - 1)
    """
    if m < 2:
        raise ValueError("integer criterion requires m >= 2")
    left = m ** (m * m)
    right = 2 ** (3 * m * m - 1)
    if left < right:
        return "exchange"
    if right < left:
        return "address"
    return "tie"


def dyadic_resonance_below_three(a: int, k: int) -> bool:
    """Exact test of R(a / 2^k) < 3 by a single integer power comparison.

        R(a/2^k) = log2(a) - k + 4^k / a^2 < 3
                <=> a^(a^2) < 2^((3+k) a^2 - 4^k).
    """
    sq = a * a
    exponent = (3 + k) * sq - 4**k
    if exponent < 0:
        return False
    return a**sq < 2**exponent


# --------------------------------------------------------------------------
# 4. Root finding
# --------------------------------------------------------------------------


def bisect(f: Callable[[float], float], lo: float, hi: float,
           iterations: int = 200) -> float:
    """Bisection for an increasing f with f(lo) < 0 < f(hi)."""
    for _ in range(iterations):
        mid = 0.5 * (lo + hi)
        if f(mid) < 0.0:
            lo = mid
        else:
            hi = mid
    return 0.5 * (lo + hi)


def newton_crossing(start: float = 7.9, steps: int = 6) -> float:
    """Newton refinement of the root of R(n) = 3."""
    x = start
    for _ in range(steps):
        x -= (resonance(x) - 3.0) / resonance_derivative(x)
    return x


def certified_dyadic_bracket(k: int) -> Tuple[Fraction, Fraction]:
    """Bracket the crossing r inside a dyadic grid of mesh 2^-k, deciding each
    grid point by an exact integer power comparison (no floating point)."""
    lo, hi = 2**k * 7, 2**k * 8  # integers a with a/2^k in [7, 8]
    while hi - lo > 1:
        mid = (lo + hi) // 2
        if dyadic_resonance_below_three(mid, k):
            lo = mid
        else:
            hi = mid
    return Fraction(lo, 2**k), Fraction(hi, 2**k)


# --------------------------------------------------------------------------
# 5. Demonstrations
# --------------------------------------------------------------------------


def demo_collapse_identity(samples: Iterable[float]) -> None:
    print("1. COLLAPSE IDENTITY   A(n) - X(n) = R(n) - 3")
    print(f"   {'n':>8} {'A(n)':>12} {'X(n)':>12} {'A-X':>12} {'R-3':>12}")
    for n in samples:
        a, x, r = address_channel(n), exchange_channel(n), resonance(n)
        print(f"   {n:8.4f} {a:12.6f} {x:12.6f} {a - x:12.6f} {r - 3.0:12.6f}")
        assert abs((a - x) - (r - 3.0)) < 1e-12
    print("   identity verified to machine precision at every sample\n")


def demo_collision_probability(arities: Iterable[int]) -> None:
    print("2. DEFICIT = FORK COLLISION PROBABILITY")
    for n in arities:
        p = fork_collision_probability(n)
        print(f"   n = {n:3d}:  collision probability = {p}"
              f"   vs   1/n^2 = {Fraction(1, n * n)}")
        assert p == Fraction(1, n * n)
    print("   exact match for every arity tested\n")


def demo_integer_criterion(arities: Iterable[int]) -> None:
    print("3. INTEGER CRITERION   (exact integer arithmetic, no floats)")
    print(f"   {'m':>4} {'winner':>10} {'digits m^(m^2)':>16}"
          f" {'digits 2^(3m^2-1)':>19}")
    for m in arities:
        w = integer_criterion_winner(m)
        d1 = len(str(m ** (m * m)))
        d2 = len(str(2 ** (3 * m * m - 1)))
        print(f"   {m:4d} {w:>10} {d1:16d} {d2:19d}")
    print()
    print("   decisive certificates:")
    print(f"     7^49  < 2^146 : {7**49 < 2**146}"
          f"   ({7**49} < {2**146})")
    print(f"     2^191 < 8^64  : {2**191 < 8**64}"
          f"   (8^64 = 2^192, so this is one doubling)")
    assert integer_criterion_winner(7) == "exchange"
    assert integer_criterion_winner(8) == "address"
    print("   => last defeat at m = 7, first victory at m = 8\n")


def demo_sign_dichotomy() -> None:
    print("4. SIGN DICHOTOMY")
    grid_low: List[float] = [2.0001 + 0.05 * i for i in range(100)]
    grid_low = [n for n in grid_low if 2.0 < n <= 7.0]
    assert all(address_channel(n) < exchange_channel(n) for n in grid_low)
    print(f"   A(n) < X(n) confirmed at {len(grid_low)} points of (2, 7]")
    grid_high = [8.0 * (1.0 + 0.37 * i) for i in range(60)]
    assert all(exchange_channel(n) < address_channel(n) for n in grid_high)
    print(f"   X(n) < A(n) confirmed at {len(grid_high)} points of [8, oo)")
    print(f"   R(7) = {resonance(7.0):.9f} < 3 < {resonance(8.0):.9f} = R(8)")
    print("   (R(8) = 3 + 1/64 exactly)\n")


def demo_crossing() -> None:
    print("5. THE TRANSCENDENTAL CROSSING")
    r_bisect = bisect(lambda n: resonance(n) - 3.0, 7.0, 8.0)
    r_newton = newton_crossing()
    print(f"   bisection : r = {r_bisect:.12f}")
    print(f"   Newton    : r = {r_newton:.12f}")
    assert abs(r_bisect - r_newton) < 1e-10
    print(f"   A(r) = {address_channel(r_newton):.12f}"
          f"   X(r) = {exchange_channel(r_newton):.12f}")
    lo, hi = Fraction(253, 32), Fraction(507, 64)
    print(f"   certified bracket 253/32 = {float(lo)} < r < {float(hi)}"
          f" = 507/64 : {float(lo) < r_newton < float(hi)}")
    print("   certificate exponents: 253^2 = 64009, 8*64009 - 4^5 = 511048;"
          " 507^2 = 257049, 9*257049 - 4^6 = 2309345")
    assert dyadic_resonance_below_three(253, 5)
    assert not dyadic_resonance_below_three(507, 6)
    print("   both integer certificates verified exactly")
    a, b = certified_dyadic_bracket(6)
    print(f"   integer-certified bisection at mesh 2^-6: "
          f"{a} = {float(a)} < r < {b} = {float(b)}\n")


def demo_second_crossing() -> None:
    print("6. THE EXACT SUB-CRITICAL CROSSING AT n = 1/2")
    n = 0.5
    print(f"   log2(1/2) = {log2(n):.1f}, delta(1/2) = {deficit(n):.1f},"
          f" R(1/2) = {resonance(n):.1f}   (-1 + 4 = 3)")
    print(f"   A(1/2) = {address_channel(n):.1f},"
          f" X(1/2) = {exchange_channel(n):.1f}")
    assert abs(address_channel(n) + 6.0) < 1e-12
    assert abs(exchange_channel(n) + 6.0) < 1e-12
    print("   dyadic resonance table  R(2^-k) = 4^k - k:")
    for k in range(5):
        print(f"     k = {k}:  n = 2^-{k},  R = {4**k - k}")
    print("   the critical level 3 is hit exactly once, at k = 1\n")


def demo_unimodality_and_ratio() -> None:
    print("7. UNIMODALITY, RATIO MONOTONICITY, DIVERGENCE")
    n_star = sqrt(2.0 * log(2.0))
    print(f"   R'(n) = 0 at n* = sqrt(2 ln 2) = {n_star:.9f},"
          f" R(n*) = {resonance(n_star):.9f}")
    assert abs(resonance_derivative(n_star)) < 1e-12
    print("   R decreases on (0, n*), increases on (n*, oo): one valley,")
    print("   so the level 3 (above the valley floor) is met exactly twice.")
    grid = [2.0 * 1.15**i for i in range(60)]
    values = [ratio(n) for n in grid]
    assert all(v < w for v, w in zip(values, values[1:]))
    print(f"   A/X strictly increasing across {len(grid)} points of [2, oo)")
    print(f"   {'n':>12} {'A/X':>12} {'(log2 n - 2)/2':>16}")
    for n in [8.0, 64.0, 1024.0, 2.0**30, 2.0**100]:
        print(f"   {n:12.3g} {ratio(n):12.6f} {(log2(n) - 2.0) / 2.0:16.6f}")
    print("   A/X -> infinity, gaining one unit per two doublings\n")


def main() -> None:
    print("=" * 74)
    print(" THE FORK CHANNEL: COMPLETE CROSSING SPECTRUM")
    print("=" * 74 + "\n")
    demo_collapse_identity([0.5, 2.0, 3.0, 4.0, 7.0, 7.9119050377, 8.0, 64.0])
    demo_collision_probability([1, 2, 3, 7, 8, 12])
    demo_integer_criterion([2, 3, 4, 5, 6, 7, 8, 9, 10])
    demo_sign_dichotomy()
    demo_crossing()
    demo_second_crossing()
    demo_unimodality_and_ratio()
    print("=" * 74)
    print(" All demonstrations completed successfully.")
    print(" Crossing spectrum on (0, oo):  { 1/2,  r }  with 7 < r < 8.")
    print("=" * 74)


if __name__ == "__main__":
    main()
