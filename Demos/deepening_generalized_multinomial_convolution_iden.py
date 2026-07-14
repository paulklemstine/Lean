"""Numerical demonstrations of the generalized multinomial convolution identity.

Core identity (uniform parameter):

    sum over (i_1, ..., i_m) with i_1 + ... + i_m = d of
        prod_{j=1}^m  C(a + i_j, a)
    =  C(m*a + d + m - 1, d).

Heterogeneous refinement (each factor its own parameter a_j):

    sum over (i_1, ..., i_m) with i_1 + ... + i_m = d of
        prod_{j=1}^m  C(a_j + i_j, a_j)
    =  C((a_1 + ... + a_m) + d + m - 1, d).

Everything is exact integer arithmetic; the demos cross-check three independent
evaluation strategies:
  (1) brute-force enumeration of tuples,
  (2) the closed-form right-hand side,
  (3) a truncated polynomial (generating-function) convolution ladder.
"""

from __future__ import annotations

from itertools import product
from math import comb
from typing import Iterator, List, Sequence, Tuple


# --------------------------------------------------------------------------- #
# Combinatorial primitives                                                     #
# --------------------------------------------------------------------------- #

def multichoose(r: int, k: int) -> int:
    """Multichoose number ((r choose k)) = C(r + k - 1, k).

    Counts multisets of size ``k`` drawn from ``r`` types. Uses the boundary
    convention ((0 choose k)) = [k == 0].
    """
    if r == 0:
        return 1 if k == 0 else 0
    return comb(r + k - 1, k)


def weak_compositions(m: int, d: int) -> Iterator[Tuple[int, ...]]:
    """Yield all ordered m-tuples of non-negative integers summing to d."""
    if m == 0:
        if d == 0:
            yield ()
        return
    if m == 1:
        yield (d,)
        return
    for first in range(d + 1):
        for rest in weak_compositions(m - 1, d - first):
            yield (first,) + rest


# --------------------------------------------------------------------------- #
# The three evaluation strategies                                             #
# --------------------------------------------------------------------------- #

def lhs_bruteforce(m: int, a: int, d: int) -> int:
    """Left-hand side by direct enumeration (uniform parameter a)."""
    total = 0
    for tup in weak_compositions(m, d):
        prod = 1
        for i in tup:
            prod *= comb(a + i, a)
        total += prod
    return total


def rhs_closed_form(m: int, a: int, d: int) -> int:
    """Right-hand side closed form: C(m*a + d + m - 1, d).

    The top argument uses truncated (natural-number) subtraction, so it is
    clamped at zero; this only matters for the degenerate case m = d = 0, where
    both sides equal 1.
    """
    return comb(max(0, m * a + d + m - 1), d)


def lhs_convolution_ladder(m: int, a: int, d: int) -> int:
    """Left-hand side via m-fold truncated polynomial convolution.

    The coefficient vector v[i] = C(a + i, a) is the truncation to degree d of
    the series (1 - x)^{-(a+1)}. Convolving it with itself m times and reading
    off degree d reproduces the left-hand side in O(m * d^2) integer ops.
    """
    if m == 0:
        return 1 if d == 0 else 0
    base: List[int] = [comb(a + i, a) for i in range(d + 1)]
    acc: List[int] = base[:]
    for _ in range(m - 1):
        acc = _truncated_convolve(acc, base, d)
    return acc[d]


def _truncated_convolve(p: Sequence[int], q: Sequence[int], d: int) -> List[int]:
    """Polynomial multiplication truncated at degree d."""
    out = [0] * (d + 1)
    for i, pi in enumerate(p):
        if pi == 0 or i > d:
            continue
        for j, qj in enumerate(q):
            if i + j > d:
                break
            out[i + j] += pi * qj
    return out


def lhs_bruteforce_hetero(a: Sequence[int], d: int) -> int:
    """Heterogeneous left-hand side by enumeration; a[j] is the j-th parameter."""
    m = len(a)
    total = 0
    for tup in weak_compositions(m, d):
        prod = 1
        for aj, ij in zip(a, tup):
            prod *= comb(aj + ij, aj)
        total += prod
    return total


def rhs_closed_form_hetero(a: Sequence[int], d: int) -> int:
    """Heterogeneous right-hand side: C(sum(a) + d + m - 1, d)."""
    m = len(a)
    return comb(max(0, sum(a) + d + m - 1), d)


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #

def demo_three_factor() -> None:
    """The classical m = 3 instance underlying Latin rectangle counting."""
    print("=" * 68)
    print("Demo 1:  Three-factor identity   sum = C(3a + d + 2, d)")
    print("=" * 68)
    for a in range(4):
        for d in range(6):
            lhs = lhs_bruteforce(3, a, d)
            rhs = rhs_closed_form(3, a, d)
            status = "OK" if lhs == rhs else "MISMATCH"
            print(f"  a={a} d={d}:  LHS={lhs:>7}  RHS={rhs:>7}  [{status}]")
            assert lhs == rhs


def demo_general_m() -> None:
    """Cross-check all three strategies for many (m, a, d)."""
    print("=" * 68)
    print("Demo 2:  General identity, three strategies agree")
    print("=" * 68)
    for m in range(0, 5):
        for a in range(0, 4):
            for d in range(0, 7):
                bf = lhs_bruteforce(m, a, d)
                cf = rhs_closed_form(m, a, d)
                cl = lhs_convolution_ladder(m, a, d)
                assert bf == cf == cl, (m, a, d, bf, cf, cl)
    print("  Verified brute force == closed form == convolution ladder")
    print("  for all m in 0..4, a in 0..3, d in 0..6.")


def demo_heterogeneous() -> None:
    """Heterogeneous identity: RHS sees parameters only through their sum."""
    print("=" * 68)
    print("Demo 3:  Heterogeneous identity, and invariance under sum-preserving")
    print("         permutations/redistributions of the parameters")
    print("=" * 68)
    parameter_sets = [(0, 1, 2), (2, 1, 0), (1, 1, 1), (3, 0, 0)]
    for d in [0, 2, 4]:
        vals = []
        for a in parameter_sets:
            lhs = lhs_bruteforce_hetero(a, d)
            rhs = rhs_closed_form_hetero(a, d)
            assert lhs == rhs
            vals.append(lhs)
            print(f"  a={a} d={d}:  value={lhs:>6}  (sum a = {sum(a)})")
        # All four parameter sets share sum = 3, hence identical values.
        assert len(set(vals)) == 1
        print(f"    -> all equal (sum of parameters fixed at 3): {vals[0]}")


def demo_multichoose_core() -> None:
    """The multichoose Vandermonde-Chu convolution at the heart of the proof."""
    print("=" * 68)
    print("Demo 4:  Multichoose Vandermonde-Chu convolution")
    print("         sum_k ((r,k)) * ((t,d-k)) = ((r+t,d))")
    print("=" * 68)
    for r in range(5):
        for t in range(5):
            for d in range(6):
                lhs = sum(multichoose(r, k) * multichoose(t, d - k)
                          for k in range(d + 1))
                rhs = multichoose(r + t, d)
                assert lhs == rhs, (r, t, d, lhs, rhs)
    print("  Verified for all r,t in 0..4, d in 0..5.")


if __name__ == "__main__":
    demo_three_factor()
    print()
    demo_general_m()
    print()
    demo_heterogeneous()
    print()
    demo_multichoose_core()
    print()
    print("All demonstrations passed.")
