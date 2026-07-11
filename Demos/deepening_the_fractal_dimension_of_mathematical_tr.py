"""
Numerical demonstrations for:

    The Fractal Dimension of Mathematical Truth: Realizing the Rational Spectrum

Statements are finite binary strings.  A *theory* accepts, at each length n, a
finite set of length-n strings.  Its box-counting (fractal) dimension is

        dim(T) = limsup_{n -> inf}  log2(count(T, n)) / n,     count(T, n) = |T(n)|.

For the periodic density theory D_{m,R} -- coordinate i is free iff i mod m in R,
otherwise forced to False -- we have the exact counting law

        count(D_{m,R}, n) = 2 ^ free(m, R, n),
        free(m, R, n)     = |{ i < n : i mod m in R }|,

and the main theorem

        dim(D_{m,R}) = |R| / m,

so every rational in [0, 1] is realized as the dimension of some theory.

This script is fully self-contained (standard library only).
"""

from __future__ import annotations

from fractions import Fraction
from math import log2, floor
from typing import Iterable


# --------------------------------------------------------------------------- #
# Core quantities
# --------------------------------------------------------------------------- #
def free_count(m: int, R: frozenset[int], n: int) -> int:
    """Number of free (admissible) coordinates below n: |{ i < n : i % m in R }|."""
    return sum(1 for i in range(n) if i % m in R)


def free_count_closed_form(m: int, R: frozenset[int], n: int) -> int:
    """O(1) closed form: |R| * floor(n / m) + |{ r in R : r < n % m }|."""
    full_blocks = n // m
    tail = n % m
    tail_hits = sum(1 for r in R if r < tail)
    return len(R) * full_blocks + tail_hits


def count_density_theory(m: int, R: frozenset[int], n: int) -> int:
    """Exact number of length-n strings accepted by D_{m,R}: 2 ** free_count."""
    return 2 ** free_count(m, R, n)


def dim_estimate(m: int, R: frozenset[int], n: int) -> float:
    """Finite-scale dimension estimate log2(count) / n = free_count / n."""
    if n == 0:
        return 0.0
    return log2(count_density_theory(m, R, n)) / n


def dim_exact(m: int, R: frozenset[int]) -> Fraction:
    """The exact box-counting dimension |R| / m."""
    return Fraction(len(R), m)


def sandwich_bounds(m: int, R: frozenset[int], n: int) -> tuple[int, int]:
    """Lower and upper bounds on free_count from complete-block counting."""
    lo = len(R) * (n // m)
    hi = len(R) * (n // m) + len(R)
    return lo, hi


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_counting_law() -> None:
    """Verify count(D_{m,R}, n) = 2 ** free_count and the closed form."""
    print("=" * 70)
    print("Demo 1: exact counting law  count = 2 ** free_count")
    print("=" * 70)
    m, R = 5, frozenset({0, 2, 3})
    print(f"m = {m}, R = {sorted(R)}  (density |R|/m = {dim_exact(m, R)})")
    print(f"{'n':>4} | {'free':>5} | {'closed':>6} | {'count = 2^free':>16}")
    print("-" * 44)
    for n in [1, 2, 5, 7, 10, 13, 20]:
        f = free_count(m, R, n)
        c = free_count_closed_form(m, R, n)
        assert f == c, "closed form disagrees with direct count"
        assert count_density_theory(m, R, n) == 2 ** f
        print(f"{n:>4} | {f:>5} | {c:>6} | {2**f:>16}")
    print()


def demo_convergence() -> None:
    """Watch dim_estimate converge to |R|/m, inside the sandwich bounds."""
    print("=" * 70)
    print("Demo 2: convergence of the dimension estimate to |R|/m")
    print("=" * 70)
    m, R = 7, frozenset({0, 1, 4})  # target 3/7
    target = dim_exact(m, R)
    print(f"m = {m}, R = {sorted(R)}  ->  exact dim = {target} = {float(target):.6f}")
    print(f"{'n':>6} | {'estimate':>10} | {'|est - dim|':>12} | {'bound m/n':>10}")
    print("-" * 48)
    for n in [10, 50, 100, 500, 1000, 5000, 20000]:
        est = dim_estimate(m, R, n)
        err = abs(est - float(target))
        lo, hi = sandwich_bounds(m, R, n)
        assert lo <= free_count(m, R, n) <= hi
        print(f"{n:>6} | {est:>10.6f} | {err:>12.2e} | {m/n:>10.2e}")
    print()


def demo_rational_realizability() -> None:
    """Realize a list of target rationals as dimensions of explicit theories."""
    print("=" * 70)
    print("Demo 3: every rational in [0,1] is realized")
    print("=" * 70)
    targets = [Fraction(0, 1), Fraction(1, 3), Fraction(1, 2),
               Fraction(2, 5), Fraction(3, 4), Fraction(1, 1)]
    print(f"{'target q':>10} | {'m':>3} | {'R':>14} | {'dim(D_mR)':>10} | ok")
    print("-" * 56)
    for q in targets:
        m = q.denominator
        p = q.numerator
        R = frozenset(range(p))          # R = {0, ..., p-1}, |R| = p
        d = dim_exact(m, R)
        ok = (d == q)
        assert ok
        # numerical confirmation at large n
        est = dim_estimate(m, R, 20000)
        print(f"{str(q):>10} | {m:>3} | {str(sorted(R)):>14} | "
              f"{str(d):>10} | {ok} (num {est:.4f})")
    print()


def demo_monotonicity() -> None:
    """Enlarging R (more free coordinates) never decreases the dimension."""
    print("=" * 70)
    print("Demo 4: monotonicity under inclusion of theories")
    print("=" * 70)
    m = 6
    chain: list[frozenset[int]] = [
        frozenset(),
        frozenset({0}),
        frozenset({0, 3}),
        frozenset({0, 2, 4}),
        frozenset({0, 1, 2, 3, 4, 5}),
    ]
    prev = -1.0
    for R in chain:
        d = dim_exact(m, R)
        assert float(d) >= prev, "dimension decreased under inclusion!"
        prev = float(d)
        print(f"R = {str(sorted(R)):>20}  ->  dim = {str(d):>5} = {float(d):.4f}")
    print("Dimensions are non-decreasing along the inclusion chain.  OK")
    print()


def demo_half_is_not_special() -> None:
    """The value 1/2 is one point of a full spectrum; show several near it."""
    print("=" * 70)
    print("Demo 5: 1/2 is not special -- neighbours in the spectrum")
    print("=" * 70)
    specs = [(2, {0}), (5, {0, 1}), (5, {0, 1, 2}), (7, {0, 1, 2}), (9, {0, 1, 2, 3, 4})]
    for m, Rset in specs:
        R = frozenset(Rset)
        print(f"m = {m}, R = {sorted(R)}  ->  dim = {dim_exact(m, R)}")
    print()


def main() -> None:
    demo_counting_law()
    demo_convergence()
    demo_rational_realizability()
    demo_monotonicity()
    demo_half_is_not_special()
    print("All demonstrations completed and assertions passed.")


if __name__ == "__main__":
    main()
