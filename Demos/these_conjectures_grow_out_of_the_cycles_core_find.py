"""
The Thermodynamic Horizon of Discovery -- numerical demonstrations.

This self-contained script illustrates the main results:

  1. Statements over a finite alphabet are countably infinite: they can be
     enumerated by the naturals, but the enumeration never terminates.
  2. The discoverable fraction of a finite budget decays to 0 at the exact
     order 1/N (upper bound |S|/N, lower bound 1/N once N exceeds max(S)).
  3. Robustness: with a scalar budget s, the fraction s/N -> 0 iff s is finite.
  4. Area-law (quadratic) capacity c*m^2 vs a linear budget L*m: crossover at
     m* = L/c, with the linear budget a vanishing fraction above it.
  5. Countability transfer: comparison between two enumerated systems factors
     through the naturals via "encode in A, decode in B".

Run with:  python demo.py
"""

from __future__ import annotations

from math import inf, isqrt
from typing import Callable, Iterator, List, Optional, Set, Tuple


# ---------------------------------------------------------------------------
# 1. Countably infinite statements over a finite alphabet
# ---------------------------------------------------------------------------

def enumerate_statements(num_symbols: int, count: int) -> List[Tuple[int, ...]]:
    """Enumerate the first `count` statements (strings) over an alphabet with
    `num_symbols` symbols, ordered by length then lexicographically.

    Demonstrates countability: this is an explicit injection index -> string.
    """
    if num_symbols < 1:
        raise ValueError("alphabet must have at least one symbol")
    out: List[Tuple[int, ...]] = []
    length = 0
    while len(out) < count:
        # all strings of the current length, in lexicographic order
        total = num_symbols ** length
        for code in range(total):
            if len(out) >= count:
                break
            digits: List[int] = []
            x = code
            for _ in range(length):
                digits.append(x % num_symbols)
                x //= num_symbols
            out.append(tuple(reversed(digits)))
        length += 1
    return out


def replicate_witness(n: int) -> Tuple[int, ...]:
    """The injective witness n -> (0, 0, ..., 0) of length n proving infinitude:
    distinct n give strings of distinct length."""
    return tuple(0 for _ in range(n))


# ---------------------------------------------------------------------------
# 2. Discoverable fraction of a finite budget
# ---------------------------------------------------------------------------

def discoverable_fraction(budget: Set[int], n: int) -> float:
    """rho_S(N) = |{x in S : x < N}| / N."""
    if n <= 0:
        raise ValueError("N must be positive")
    discovered = sum(1 for x in budget if x < n)
    return discovered / n


def upper_bound(budget: Set[int], n: int) -> float:
    """|S| / N, the Theorem 4.1 upper bound on the discoverable fraction."""
    return len(budget) / n


def reciprocal_lower_bound(n: int) -> float:
    """1 / N, the Theorem 4.3 lower bound (valid once N exceeds max(S))."""
    return 1.0 / n


# ---------------------------------------------------------------------------
# 3. Robustness: finite-versus-infinite dichotomy
# ---------------------------------------------------------------------------

def scalar_fraction(s: float, n: int) -> float:
    """s / N in the extended nonnegative reals (s may be math.inf)."""
    if s == inf:
        return inf
    return s / n


def fraction_tends_to_zero(s: float, horizon: int = 10 ** 18) -> bool:
    """Empirical check of Theorem 5.1: s/N -> 0 iff s is finite.  A finite s
    always eventually drops below any threshold; s = inf never does."""
    return scalar_fraction(s, horizon) < 1e-3


# ---------------------------------------------------------------------------
# 4. Area-law capacity versus a linear budget
# ---------------------------------------------------------------------------

def crossover_mass(c: float, ell: float) -> float:
    """The crossover mass m* = L / c (requires c > 0)."""
    if c <= 0:
        raise ValueError("c must be positive")
    return ell / c


def area_law_dominates(c: float, ell: float, m: float) -> bool:
    """Whether L*m <= c*m^2 at mass m >= 0.  By Theorem 6.1 this holds iff
    m == 0 or m >= L/c."""
    if m < 0:
        raise ValueError("mass must be nonnegative")
    return ell * m <= c * m * m


def linear_over_quadratic(c: float, ell: float, m: float) -> float:
    """(L*m)/(c*m^2) = (L/c)/m, the vanishing ratio of Theorem 6.2."""
    if m <= 0:
        raise ValueError("mass must be positive")
    return (ell * m) / (c * m * m)


# ---------------------------------------------------------------------------
# 5. Countability transfer across systems
# ---------------------------------------------------------------------------

def transfer(
    encode_a: Callable[[int], int],
    decode_b: Callable[[int], int],
) -> Callable[[int], int]:
    """The comparison bijection f = decode_b o encode_a : A -> B, factoring
    through the shared enumeration of the naturals (Theorem 7.1)."""
    return lambda a: decode_b(encode_a(a))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("1. COUNTABLE INFINITUDE OF STATEMENTS (alphabet {0,1})")
    print("=" * 70)
    for i, s in enumerate(enumerate_statements(num_symbols=2, count=10)):
        print(f"  index {i:>2}  ->  string {s}")
    print(f"  infinitude witness: n=5 -> {replicate_witness(5)} "
          f"(length {len(replicate_witness(5))})")

    print()
    print("=" * 70)
    print("2. DISCOVERABLE FRACTION DECAYS AT ORDER 1/N")
    print("=" * 70)
    budget: Set[int] = {2, 3, 5, 7, 11, 13}
    print(f"  finite budget S = {sorted(budget)},  |S| = {len(budget)}")
    print(f"  {'N':>8} {'rho_S(N)':>12} {'|S|/N (upper)':>14} {'1/N (lower)':>12}")
    for n in (10, 100, 1_000, 10_000, 100_000):
        rho = discoverable_fraction(budget, n)
        ub = upper_bound(budget, n)
        lb = reciprocal_lower_bound(n) if n > max(budget) else float("nan")
        print(f"  {n:>8} {rho:>12.3e} {ub:>14.3e} {lb:>12.3e}")

    print()
    print("=" * 70)
    print("3. ROBUSTNESS: s/N -> 0  IFF  s finite")
    print("=" * 70)
    for s in (1.0, 1e6, 1e12, inf):
        label = "inf" if s == inf else f"{s:g}"
        print(f"  s = {label:>8}:  tends to zero? {fraction_tends_to_zero(s)}")

    print()
    print("=" * 70)
    print("4. AREA-LAW vs LINEAR: crossover mass m* = L/c")
    print("=" * 70)
    c, ell = 2.0, 10.0
    mstar = crossover_mass(c, ell)
    print(f"  c = {c}, L = {ell}  =>  crossover mass m* = {mstar}")
    for m in (1.0, 3.0, 5.0, 5.0000001, 10.0, 100.0):
        print(f"    m = {m:>10}: area-law dominates? "
              f"{area_law_dominates(c, ell, m)!s:>5}  "
              f"(L*m)/(c*m^2) = {linear_over_quadratic(c, ell, m):.4f}")

    print()
    print("=" * 70)
    print("5. COUNTABILITY TRANSFER (encode in A, decode in B)")
    print("=" * 70)
    # System A: even numbers <-> naturals ; System B: odd numbers <-> naturals
    encode_a = lambda a: a // 2          # A = {0,2,4,...} -> N
    decode_b = lambda k: 2 * k + 1       # N -> B = {1,3,5,...}
    f = transfer(encode_a, decode_b)
    for a in (0, 2, 4, 6, 8):
        print(f"  A-element {a:>2}  --encode-->  {encode_a(a)}  "
              f"--decode-->  B-element {f(a)}")


if __name__ == "__main__":
    main()
