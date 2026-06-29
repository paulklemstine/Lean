"""
Numerical demonstration of the stack-sorting depth results and Defant's constant.

This script is fully self-contained (standard library only) and mirrors the
machine-verified development:

  * stack_sort         -- West's stack-sorting map s (one pass).
  * depth              -- least number of passes to reach the sorted list.
  * depth_distribution -- the depth histogram over all permutations of [1..n].
  * stack_sortable_cnt -- number of permutations of depth <= 1 (one-pass).
  * catalan            -- Catalan numbers, compared against the above.
  * defant_const       -- lambda = (3/5)(7 - 8 ln 2), the conjectured limiting
                          average-depth density, with its certified bounds.

It reproduces:
  * stack_sort([2,3,1]) -> [2,1,3] -> [1,2,3]   (a depth-2 permutation),
  * the Catalan law  stack_sortable_cnt(n) == catalan(n)  for n = 1..7,
  * the depth histograms matching the Lean #eval output,
  * the enclosure  0.8728 < lambda < 0.8729  and  G < lambda.
"""

from __future__ import annotations

from itertools import permutations
from math import comb, log
from typing import Dict, List, Tuple


# --------------------------------------------------------------------------
# West's stack-sorting map
# --------------------------------------------------------------------------

def pop_less(x: int, stack: List[int]) -> Tuple[List[int], List[int]]:
    """Pop every top entry strictly smaller than x (head = top).

    Returns (popped, remaining) where `popped` is in pop order.
    """
    popped: List[int] = []
    i = 0
    while i < len(stack) and stack[i] < x:
        popped.append(stack[i])
        i += 1
    return popped, stack[i:]


def stack_sort(seq: List[int]) -> List[int]:
    """One full pass of West's stack-sorting map s, starting from an empty stack."""
    stack: List[int] = []
    output: List[int] = []
    for x in seq:
        popped, rest = pop_less(x, stack)
        output.extend(popped)
        stack = [x] + rest          # push x on top of what remains
    output.extend(stack)            # flush
    return output


def depth(seq: List[int]) -> int:
    """Least number of stack_sort passes needed to reach the ascending sort."""
    target = sorted(seq)
    cur = list(seq)
    count = 0
    # West's bound guarantees depth <= len(seq) - 1; len(seq) passes always suffice.
    for _ in range(len(seq) + 1):
        if cur == target:
            return count
        cur = stack_sort(cur)
        count += 1
    return count


# --------------------------------------------------------------------------
# Enumeration, histogram, Catalan law
# --------------------------------------------------------------------------

def perms_n(n: int) -> List[List[int]]:
    """All permutations of [1, 2, ..., n]."""
    return [list(p) for p in permutations(range(1, n + 1))]


def depth_distribution(n: int) -> List[Tuple[int, int]]:
    """Histogram [(t, #permutations of depth t)] over S_n."""
    counts: Dict[int, int] = {}
    for p in perms_n(n):
        d = depth(p)
        counts[d] = counts.get(d, 0) + 1
    m = max(counts) if counts else 0
    return [(t, counts.get(t, 0)) for t in range(m + 1)]


def stack_sortable_count(n: int) -> int:
    """Number of permutations of [1..n] with stack-sorting depth <= 1."""
    return sum(1 for p in perms_n(n) if depth(p) <= 1)


def catalan(n: int) -> int:
    """The n-th Catalan number C_n = binom(2n, n) / (n + 1)."""
    return comb(2 * n, n) // (n + 1)


def average_depth(n: int) -> float:
    """Average stack-sorting depth D_n over S_n."""
    dist = depth_distribution(n)
    total = sum(t * c for t, c in dist)
    npts = sum(c for _, c in dist)
    return total / npts


# --------------------------------------------------------------------------
# Defant's constant
# --------------------------------------------------------------------------

def defant_const() -> float:
    """Defant's constant lambda = (3/5)(7 - 8 ln 2) ~ 0.872892."""
    return (3.0 / 5.0) * (7.0 - 8.0 * log(2.0))


GOLOMB_DICKMAN: float = 0.6243299885  # asymptotic expected longest cycle density


# --------------------------------------------------------------------------
# Demonstration driver
# --------------------------------------------------------------------------

def main() -> None:
    print("=" * 68)
    print("Worked example: the minimal depth-2 permutation [2, 3, 1]")
    print("=" * 68)
    seq = [2, 3, 1]
    once = stack_sort(seq)
    twice = stack_sort(once)
    print(f"  s({seq}) = {once}")
    print(f"  s({once}) = {twice}")
    print(f"  depth({seq}) = {depth(seq)}   (expected 2)")
    print()

    print("=" * 68)
    print("The Catalan law:  #{depth <= 1} == C_n")
    print("=" * 68)
    print(f"  {'n':>2} | {'one-pass sortable':>18} | {'C_n':>6} | match")
    print("  " + "-" * 44)
    for n in range(1, 8):
        cnt = stack_sortable_count(n)
        cat = catalan(n)
        print(f"  {n:>2} | {cnt:>18} | {cat:>6} | {cnt == cat}")
    print()

    print("=" * 68)
    print("Depth histograms (compare with the Lean #eval output)")
    print("=" * 68)
    for n in range(1, 7):
        print(f"  n={n}: {depth_distribution(n)}")
    print()

    print("=" * 68)
    print("Average depth D_n and the normalized ratio D_n / n")
    print("=" * 68)
    print(f"  {'n':>2} | {'D_n':>10} | {'D_n / n':>10}")
    print("  " + "-" * 30)
    for n in range(1, 8):
        d = average_depth(n)
        print(f"  {n:>2} | {d:>10.5f} | {d / n:>10.5f}")
    print("  (ratios rise slowly toward the conjectured limit lambda ~ 0.8729)")
    print()

    print("=" * 68)
    print("Defant's constant and the Golomb-Dickman comparison")
    print("=" * 68)
    lam = defant_const()
    print(f"  lambda = (3/5)(7 - 8 ln 2)   = {lam:.10f}")
    print(f"  linear form 21/5 - 24/5 ln 2 = {21/5 - 24/5*log(2):.10f}")
    print(f"  enclosure 0.8728 < lambda < 0.8729 : {0.8728 < lam < 0.8729}")
    print(f"  lambda < 1        : {lam < 1}")
    print(f"  lambda < 7/8      : {lam < 7/8}  (7/8 = {7/8})")
    print(f"  0.6244 < lambda   : {0.6244 < lam}")
    print(f"  Golomb-Dickman G  = {GOLOMB_DICKMAN}")
    print(f"  G < 0.6244 < lambda, hence G < lambda : {GOLOMB_DICKMAN < lam}")


if __name__ == "__main__":
    main()
