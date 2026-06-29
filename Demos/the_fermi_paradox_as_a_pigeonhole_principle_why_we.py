"""
The Fermi Paradox as a Pigeonhole Principle: Numerical Demonstrations
=====================================================================

Self-contained Python demonstrations of the core results:

  * First-moment existence theorem
        E[X] < 1  =>  some region is empty (X_i = 0).

  * First-moment tail bound
        w(Z) >= 1 - E[X]   (Z = empty regions).

  * Conservative Drake inequality
        each p_j <= 1/10, N <= 1e10, n >= 11  =>  N * prod p_j < 1.

  * Fusion theorem ("we are alone")
        conservative Drake  =>  P(empty region) >= 0.9.

  * Fibonacci strong divisibility (resonant listening window)
        gcd(F_m, F_n) = F_{gcd(m, n)}.

All arithmetic that must be exact is done with fractions.Fraction.
Run:  python demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import gcd, prod
from typing import List, Sequence, Tuple


# ---------------------------------------------------------------------------
# First moment method over finite weighted spaces
# ---------------------------------------------------------------------------

def expectation(weights: Sequence[Fraction], values: Sequence[int]) -> Fraction:
    """E[X] = sum_i w_i * X_i over a finite weighted space."""
    assert len(weights) == len(values), "weights and values must align"
    assert sum(weights) == 1, "weights must sum to exactly 1"
    assert all(w >= 0 for w in weights), "weights must be non-negative"
    assert all(v >= 0 for v in values), "values must be non-negative integers"
    return sum((w * v for w, v in zip(weights, values)), Fraction(0))


def empty_set_weight(weights: Sequence[Fraction], values: Sequence[int]) -> Fraction:
    """w(Z) = total weight of regions with X_i = 0."""
    return sum((w for w, v in zip(weights, values) if v == 0), Fraction(0))


def first_moment_certify(
    weights: Sequence[Fraction], values: Sequence[int]
) -> Tuple[bool, Fraction, Fraction]:
    """
    Returns (guaranteed_empty, expectation, emptiness_lower_bound).

    Theorem 3.1: if E[X] < 1 then some region is empty.
    Theorem 3.2: w(Z) >= 1 - E[X] always.
    """
    exp = expectation(weights, values)
    lower = max(Fraction(0), Fraction(1) - exp)
    return (exp < 1, exp, lower)


# ---------------------------------------------------------------------------
# Conservative Drake inequality
# ---------------------------------------------------------------------------

def drake_expectation(n_worlds: Fraction, hurdles: Sequence[Fraction]) -> Fraction:
    """E_Drake = N * prod_j p_j."""
    p = prod(hurdles, start=Fraction(1))
    return n_worlds * p


def drake_certified_below_one(
    n_worlds: Fraction,
    hurdles: Sequence[Fraction],
    cap: Fraction = Fraction(1, 10),
    n_max: Fraction = Fraction(10) ** 10,
    min_hurdles: int = 11,
) -> Tuple[Fraction, bool]:
    """
    Theorem 4.3: if every p_j <= cap, N <= n_max, and #hurdles >= min_hurdles,
    then E_Drake < 1.  Returns (E_Drake, certified).
    """
    exp = drake_expectation(n_worlds, hurdles)
    cap_ok = all(p <= cap for p in hurdles)
    count_ok = len(hurdles) >= min_hurdles
    world_ok = n_worlds <= n_max
    certified = cap_ok and count_ok and world_ok
    return exp, certified


# ---------------------------------------------------------------------------
# Fibonacci strong divisibility (resonant listening window)
# ---------------------------------------------------------------------------

def fib(k: int) -> int:
    """k-th Fibonacci number, F_0 = 0, F_1 = 1."""
    a, b = 0, 1
    for _ in range(k):
        a, b = b, a + b
    return a


def fib_strong_divisibility(m: int, n: int) -> Tuple[int, int, bool]:
    """
    Lemma 6.2:  gcd(F_m, F_n) = F_{gcd(m, n)}.
    Returns (lhs, rhs, equal).
    """
    lhs = gcd(fib(m), fib(n))
    rhs = fib(gcd(m, n))
    return lhs, rhs, lhs == rhs


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_first_moment() -> None:
    print("=" * 70)
    print("DEMO 1  First moment method: E[X] < 1  =>  an empty region exists")
    print("=" * 70)
    # Three cosmic regions, uniform weight, civilization counts (0, 0, 1).
    weights: List[Fraction] = [Fraction(1, 3)] * 3
    values: List[int] = [0, 0, 1]
    empty, exp, lower = first_moment_certify(weights, values)
    actual = empty_set_weight(weights, values)
    print(f"  weights            = {[str(w) for w in weights]}")
    print(f"  civilization counts = {values}")
    print(f"  E[X]               = {exp}  ({float(exp):.4f})")
    print(f"  guaranteed empty?  = {empty}")
    print(f"  bound  w(Z) >= 1 - E[X] = {lower}  ({float(lower):.4f})")
    print(f"  actual w(Z)            = {actual}  ({float(actual):.4f})")
    assert actual >= lower, "tail bound must hold"
    print("  OK: actual emptiness mass respects the lower bound.\n")


def demo_drake() -> None:
    print("=" * 70)
    print("DEMO 2  Conservative Drake inequality:  N * prod p_j < 1")
    print("=" * 70)
    n_worlds = Fraction(10) ** 10           # 1e10 habitable worlds
    hurdles = [Fraction(1, 10)] * 11        # 11 hurdles, each p = 1/10
    exp, certified = drake_certified_below_one(n_worlds, hurdles)
    print(f"  N (habitable worlds) = 1e10")
    print(f"  hurdles              = 11 x (1/10)")
    print(f"  E_Drake              = {exp}  ({float(exp):.6f})")
    print(f"  certified < 1?       = {certified}")
    assert exp < 1 and certified
    print("  OK: expected civilizations = 0.1 < 1.\n")


def demo_fusion() -> None:
    print("=" * 70)
    print("DEMO 3  Fusion theorem:  conservative Drake => P(empty) >= 0.9")
    print("=" * 70)
    n_worlds = Fraction(10) ** 10
    hurdles = [Fraction(1, 10)] * 11
    exp, certified = drake_certified_below_one(n_worlds, hurdles)
    emptiness_bound = Fraction(1) - exp
    print(f"  E[X]                       = {exp}  ({float(exp):.4f})")
    print(f"  P(empty region) >= 1 - E[X] = {emptiness_bound}  "
          f"({float(emptiness_bound):.4f})")
    assert certified and emptiness_bound >= Fraction(9, 10)
    print("  OK: probability our region is empty is at least 0.9.\n")


def demo_scenarios() -> None:
    print("=" * 70)
    print("DEMO 4  Scenario sweep: how the dichotomy flips around E = 1")
    print("=" * 70)
    n_worlds = Fraction(10) ** 10
    scenarios = [
        ("Conservative",        Fraction(1, 10), 11),
        ("Very conservative",   Fraction(1, 10), 13),
        ("Mildly optimistic",   Fraction(1, 5),  11),
        ("Optimistic",          Fraction(1, 2),   7),
    ]
    print(f"  {'scenario':<20}{'p':>8}{'n':>4}{'E[X]':>16}{'w(Z)>=':>12}")
    for name, p, n in scenarios:
        hurdles = [p] * n
        exp = drake_expectation(n_worlds, hurdles)
        if exp < 1:
            wz = f"{float(1 - exp):.3f}"
        else:
            wz = "n/a"
        print(f"  {name:<20}{str(p):>8}{n:>4}{float(exp):>16.4g}{wz:>12}")
    print()


def demo_fibonacci() -> None:
    print("=" * 70)
    print("DEMO 5  Resonant listening: gcd(F_m, F_n) = F_{gcd(m, n)}")
    print("=" * 70)
    pairs = [(12, 8), (10, 15), (21, 14), (9, 6), (13, 7)]
    for m, n in pairs:
        lhs, rhs, ok = fib_strong_divisibility(m, n)
        g = gcd(m, n)
        print(f"  m={m:>3}, n={n:>3}:  gcd(F_{m},F_{n}) = {lhs:<8}"
              f"F_gcd({m},{n})=F_{g} = {rhs:<8} match={ok}")
        assert ok
    print("  OK: Fibonacci strong divisibility verified.\n")


def main() -> None:
    demo_first_moment()
    demo_drake()
    demo_fusion()
    demo_scenarios()
    demo_fibonacci()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
