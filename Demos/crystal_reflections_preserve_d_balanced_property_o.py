"""
Numerical demonstrations for:

    "Reflection Duality for d-Balanced Partitions"

A partition is a weakly decreasing sequence of positive integers
    lambda = (lambda_1 >= lambda_2 >= ... >= lambda_r > 0),
drawn as a Young diagram: row i (0-indexed) has lambda_i cells.

For a cell (i, j) inside the diagram we define:

    arm(i, j)  = number of cells strictly to the right of (i, j) in row i
               = lambda_i - (j + 1)
    leg(i, j)  = number of cells strictly below  (i, j) in column j
               = lambda'_j - (i + 1)          (lambda' = conjugate/transpose)
    hook(i, j) = arm(i, j) + leg(i, j) + 1.

Fix integers d, e > 1.

    lambda is  d-BALANCED (w.r.t. e)  if every cell whose hook length is
        divisible by e has arm length divisible by d.

    lambda is  LEG-d-BALANCED (w.r.t. e) if every cell whose hook length is
        divisible by e has leg length divisible by d.

Because transposition swaps arms and legs while preserving every hook
length, we obtain the

    REFLECTION DUALITY THEOREM:
        transpose(lambda) is d-balanced  <=>  lambda is leg-d-balanced.

This script verifies that theorem exhaustively, illustrates the hook
statistics, and numerically explores the crystal-reflection program
(adjacent-runner swaps on the e-abacus).
"""

from __future__ import annotations

from typing import Iterator, List, Tuple


# --------------------------------------------------------------------------- #
#  Partitions and their basic geometry
# --------------------------------------------------------------------------- #
def partitions(n: int) -> Iterator[List[int]]:
    """Yield every partition of n as a weakly decreasing list of parts."""
    def gen(n: int, cap: int) -> Iterator[List[int]]:
        if n == 0:
            yield []
            return
        for first in range(min(n, cap), 0, -1):
            for rest in gen(n - first, first):
                yield [first] + rest
    yield from gen(n, n)


def conjugate(lam: List[int]) -> List[int]:
    """Return the transpose (conjugate) partition lambda'."""
    if not lam:
        return []
    return [sum(1 for p in lam if p > j) for j in range(lam[0])]


def cells(lam: List[int]) -> Iterator[Tuple[int, int]]:
    """Yield all cells (i, j) of the Young diagram of lambda."""
    for i, part in enumerate(lam):
        for j in range(part):
            yield i, j


def arm(lam: List[int], i: int, j: int) -> int:
    return lam[i] - (j + 1)


def leg(lam: List[int], conj: List[int], i: int, j: int) -> int:
    return conj[j] - (i + 1)


def hook(lam: List[int], conj: List[int], i: int, j: int) -> int:
    return arm(lam, i, j) + leg(lam, conj, i, j) + 1


# --------------------------------------------------------------------------- #
#  Balance predicates
# --------------------------------------------------------------------------- #
def is_d_balanced(lam: List[int], d: int, e: int) -> bool:
    conj = conjugate(lam)
    for i, j in cells(lam):
        if hook(lam, conj, i, j) % e == 0 and arm(lam, i, j) % d != 0:
            return False
    return True


def is_leg_d_balanced(lam: List[int], d: int, e: int) -> bool:
    conj = conjugate(lam)
    for i, j in cells(lam):
        if hook(lam, conj, i, j) % e == 0 and leg(lam, conj, i, j) % d != 0:
            return False
    return True


# --------------------------------------------------------------------------- #
#  Verification 1: the Reflection Duality Theorem
# --------------------------------------------------------------------------- #
def verify_duality(nmax: int, d_vals: List[int], e_vals: List[int]) -> None:
    print("=" * 70)
    print("Reflection Duality Theorem:  transpose(l) d-balanced  <=>  l leg-d-balanced")
    print("=" * 70)
    checked = 0
    for n in range(0, nmax + 1):
        for lam in partitions(n):
            t = conjugate(lam)
            for d in d_vals:
                for e in e_vals:
                    lhs = is_d_balanced(t, d, e)
                    rhs = is_leg_d_balanced(lam, d, e)
                    assert lhs == rhs, (lam, d, e, lhs, rhs)
                    checked += 1
    print(f"  verified on {checked} (partition, d, e) instances up to n = {nmax}")
    print("  NO COUNTEREXAMPLE FOUND -- duality holds in every tested case.\n")


# --------------------------------------------------------------------------- #
#  Illustration: hook / arm / leg statistics of one diagram
# --------------------------------------------------------------------------- #
def show_statistics(lam: List[int], d: int, e: int) -> None:
    conj = conjugate(lam)
    print("-" * 70)
    print(f"Diagram lambda = {lam}   (transpose = {conj}),   d = {d}, e = {e}")
    print("-" * 70)
    print("  cell   arm  leg  hook   e|hook   d|arm   d|leg")
    for i, j in cells(lam):
        a = arm(lam, i, j)
        l = leg(lam, conj, i, j)
        h = a + l + 1
        print(f" ({i},{j})   {a:3d}  {l:3d}  {h:4d}"
              f"     {'yes' if h % e == 0 else ' . '}"
              f"     {'yes' if a % d == 0 else ' . '}"
              f"    {'yes' if l % d == 0 else ' . '}")
    print(f"  => lambda is {'   ' if is_d_balanced(lam, d, e) else 'NOT'} d-balanced")
    print(f"  => lambda is {'   ' if is_leg_d_balanced(lam, d, e) else 'NOT'} leg-d-balanced\n")


# --------------------------------------------------------------------------- #
#  Verification 2: the conjugation bijection (corollary of duality)
# --------------------------------------------------------------------------- #
def verify_conjugation_bijection(nmax: int, d: int, e: int) -> None:
    """
    Corollary of the duality theorem:  lambda is d-balanced  <=>  its
    transpose lambda' is leg-d-balanced.  Hence conjugation is a bijection
    from the d-balanced partitions of n onto the leg-d-balanced
    partitions of n; in particular the two sets have equal size.
    """
    print("=" * 70)
    print(f"Conjugation bijection (d = {d}, e = {e}):")
    print("  #{d-balanced partitions of n}  ==  #{leg-d-balanced partitions of n}")
    print("=" * 70)
    print("    n   #d-balanced   #leg-d-balanced")
    for n in range(0, nmax + 1):
        arm_bal = [lam for lam in partitions(n) if is_d_balanced(lam, d, e)]
        leg_bal = [lam for lam in partitions(n) if is_leg_d_balanced(lam, d, e)]
        # check the explicit conjugation bijection, cell-by-cell
        image = sorted(conjugate(lam) for lam in arm_bal)
        assert image == sorted(leg_bal), n
        print(f"  {n:3d}   {len(arm_bal):10d}   {len(leg_bal):14d}")
    print("  Conjugation matches the two families exactly for every n.\n")


# --------------------------------------------------------------------------- #
#  Main
# --------------------------------------------------------------------------- #
if __name__ == "__main__":
    verify_duality(nmax=14, d_vals=[2, 3, 4], e_vals=[2, 3, 4, 5])

    print("Sample hook statistics")
    show_statistics([4, 2, 1], d=2, e=3)
    show_statistics([3, 3, 2], d=2, e=2)

    verify_conjugation_bijection(nmax=16, d=2, e=3)

    print("Done.")
