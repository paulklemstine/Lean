"""
Numerical demonstrations of the Generalized Multinomial Convolution Identity.

For all integers m >= 1, a >= 0, d >= 0:

    sum over ordered m-tuples (i_1,...,i_m) of non-negative integers with
    i_1 + ... + i_m = d  of  prod_{j=1}^m C(a + i_j, a)   ==   C(m*a + d + m - 1, d)

where C(n, k) is the binomial coefficient.

This script:
  1. Directly enumerates the left-hand side by brute force.
  2. Computes the right-hand side as a single binomial coefficient.
  3. Verifies equality across a wide grid of parameters.
  4. Demonstrates the two-factor negative binomial convolution base case,
     the stars-and-bars specialization (a = 0), and the m = 3 Bogart-Longyear case.

Self-contained: standard library only.
"""

from __future__ import annotations

from itertools import product
from math import comb
from typing import Iterator, Tuple


def ordered_compositions(m: int, d: int) -> Iterator[Tuple[int, ...]]:
    """Yield all ordered m-tuples of non-negative integers summing to d.

    These are the weak compositions of d into m parts. There are C(d+m-1, d)
    of them. Implemented by placing m-1 dividers among d units (stars and bars).
    """
    if m == 0:
        if d == 0:
            yield ()
        return
    if m == 1:
        yield (d,)
        return
    # choose positions of m-1 dividers in a row of d + m - 1 slots
    for divs in _divider_positions(d + m - 1, m - 1):
        parts = []
        prev = -1
        for pos in divs:
            parts.append(pos - prev - 1)
            prev = pos
        parts.append((d + m - 1) - prev - 1)
        yield tuple(parts)


def _divider_positions(n: int, k: int) -> Iterator[Tuple[int, ...]]:
    """All strictly increasing k-subsets of {0,...,n-1}."""
    from itertools import combinations

    yield from combinations(range(n), k)


def lhs_bruteforce(m: int, a: int, d: int) -> int:
    """Left-hand side: sum of products of binomial weights over compositions."""
    total = 0
    for tup in ordered_compositions(m, d):
        prod = 1
        for x in tup:
            prod *= comb(a + x, a)
        total += prod
    return total


def rhs_closed_form(m: int, a: int, d: int) -> int:
    """Right-hand side: the single binomial coefficient C(m*a + d + m - 1, d)."""
    return comb(m * a + d + m - 1, d)


def negbinom_conv_lhs(p: int, q: int, d: int) -> int:
    """Two-factor negative binomial convolution: sum_{i+j=d} C(p+i,p) C(q+j,q)."""
    return sum(comb(p + i, p) * comb(q + (d - i), q) for i in range(d + 1))


def negbinom_conv_rhs(p: int, q: int, d: int) -> int:
    """Closed form C(p+q+1+d, d) of the two-factor convolution."""
    return comb(p + q + 1 + d, d)


def demo_main_identity() -> None:
    print("=" * 70)
    print("Generalized Multinomial Convolution Identity")
    print("  sum prod C(a+i_j, a)  ==  C(m*a + d + m - 1, d)")
    print("=" * 70)
    ok = True
    for m in range(1, 6):
        for a in range(0, 4):
            for d in range(0, 7):
                lhs = lhs_bruteforce(m, a, d)
                rhs = rhs_closed_form(m, a, d)
                if lhs != rhs:
                    ok = False
                    print(f"  MISMATCH m={m} a={a} d={d}: {lhs} != {rhs}")
    print(f"All (m in 1..5, a in 0..3, d in 0..6) checks passed: {ok}")


def demo_two_factor() -> None:
    print("\n" + "=" * 70)
    print("Base engine: two-factor negative binomial convolution")
    print("  sum_{i+j=d} C(p+i,p) C(q+j,q)  ==  C(p+q+1+d, d)")
    print("=" * 70)
    for (p, q, d) in [(1, 1, 2), (2, 3, 4), (0, 5, 3), (4, 4, 5)]:
        l = negbinom_conv_lhs(p, q, d)
        r = negbinom_conv_rhs(p, q, d)
        print(f"  p={p} q={q} d={d}:  LHS={l:6d}  RHS={r:6d}  {'OK' if l == r else 'FAIL'}")


def demo_stars_and_bars() -> None:
    print("\n" + "=" * 70)
    print("Specialization a = 0: stars and bars")
    print("  |{ m-tuples summing to d }|  ==  C(d + m - 1, d)")
    print("=" * 70)
    for m in range(1, 5):
        for d in range(0, 6):
            count = sum(1 for _ in ordered_compositions(m, d))
            closed = comb(d + m - 1, d)
            assert count == closed == lhs_bruteforce(m, 0, d)
            print(f"  m={m} d={d}: {count:4d} tuples  =  C({d+m-1},{d}) = {closed}")


def demo_three_row() -> None:
    print("\n" + "=" * 70)
    print("Bogart-Longyear m = 3 case (used for 3-row Latin rectangles)")
    print("  sum_{i+j+k=d} C(a+i,a)C(a+j,a)C(a+k,a)  ==  C(3a+d+2, d)")
    print("=" * 70)
    for a in range(0, 4):
        for d in range(0, 6):
            lhs = lhs_bruteforce(3, a, d)
            rhs = comb(3 * a + d + 2, d)
            assert lhs == rhs
            print(f"  a={a} d={d}: LHS={lhs:6d}  =  C({3*a+d+2},{d}) = {rhs}")


if __name__ == "__main__":
    demo_main_identity()
    demo_two_factor()
    demo_stars_and_bars()
    demo_three_row()
    print("\nAll demonstrations completed successfully.")
