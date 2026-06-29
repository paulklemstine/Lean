"""
Numerical demonstrations for:

    "Verified Binary Search as Threshold Finding,
     with a Bridge to the Factorial Number System"

This script mirrors the verified mathematics:

  * bsearch / bsearch_steps  -> threshold binary search and its step counter
  * bsearch_spec             -> the loop-invariant correctness contract
  * bsearch_steps_le         -> tight ceiling-logarithm complexity bound
  * value / Valid / value_lt -> the factoradic value and the < k! estimate
  * digit / value_digit      -> explicit digit extraction and reconstruction
  * value_unique             -> uniqueness of valid factoradic codes
  * factoradic_search        -> the bridge: searching [0, k!) in clog2(k!) steps

Everything is self-contained: pure Python standard library, type hints, and all
helper functions inlined. Run `python demo.py`.
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple


# ----------------------------------------------------------------------------
# 1. Ceiling base-2 logarithm: clog2(g) = least m with g <= 2**m.
#    Recurrence (matching the algorithm): clog2(g) = clog2(ceil(g/2)) + 1 for g>1.
# ----------------------------------------------------------------------------
def clog2(g: int) -> int:
    """Ceiling base-2 logarithm, with clog2(g) = 0 for g <= 1."""
    if g <= 1:
        return 0
    return clog2((g + 1) // 2) + 1


# ----------------------------------------------------------------------------
# 2. Threshold binary search and its step counter (mirror of `bsearch`).
# ----------------------------------------------------------------------------
def bsearch(p: Callable[[int], bool], lo: int, hi: int) -> int:
    """Locate the boundary index r where p flips from False to True.

    Intended invariant: p(lo) == False and p(hi) == True. Returns r with
    p(r-1) == False and p(r) == True.
    """
    while lo + 1 < hi:
        mid = (lo + hi) // 2
        if p(mid):
            hi = mid
        else:
            lo = mid
    return hi


def bsearch_steps(p: Callable[[int], bool], lo: int, hi: int) -> int:
    """Count the number of bisection iterations (mirror of `bsearchSteps`)."""
    steps = 0
    while lo + 1 < hi:
        mid = (lo + hi) // 2
        steps += 1
        if p(mid):
            hi = mid
        else:
            lo = mid
    return steps


# ----------------------------------------------------------------------------
# 3. Factorial number system (factoradic).
# ----------------------------------------------------------------------------
def value(c: Callable[[int], int], k: int) -> int:
    """Length-k factoradic value: sum_{i<k} c(i) * i!."""
    return sum(c(i) * math.factorial(i) for i in range(k))


def is_valid(c: Callable[[int], int], k: int) -> bool:
    """Validity: c(i) <= i for all i < k."""
    return all(c(i) <= i for i in range(k))


def digit(n: int, i: int) -> int:
    """Explicit factoradic digit extractor: floor(n / i!) mod (i+1)."""
    return (n // math.factorial(i)) % (i + 1)


def factoradic_digits(n: int, k: int) -> List[int]:
    """The length-k factoradic code (c(0), ..., c(k-1)) of n."""
    return [digit(n, i) for i in range(k)]


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------
def demo_correctness() -> None:
    """bsearch_spec: returned index is the exact false->true boundary."""
    print("=" * 70)
    print("DEMO 1  Functional correctness (bsearch_spec)")
    print("=" * 70)
    # A monotone predicate flipping at threshold = 42.
    threshold = 42
    p = lambda i: i >= threshold
    lo, hi = 0, 100
    r = bsearch(p, lo, hi)
    print(f"predicate flips at {threshold};  search over ({lo}, {hi}) returns r = {r}")
    print(f"  lo < r <= hi      : {lo < r <= hi}")
    print(f"  p(r)   == True    : {p(r)}")
    print(f"  p(r-1) == False   : {not p(r - 1)}")
    assert lo < r <= hi and p(r) and not p(r - 1)
    assert r == threshold
    print("  -> r is exactly the boundary, with NO monotonicity used in the proof.")
    print()


def demo_complexity() -> None:
    """bsearch_steps_le: steps <= clog2(hi-lo), TIGHT at gap 3."""
    print("=" * 70)
    print("DEMO 2  Tight ceiling-logarithm complexity (bsearch_steps_le)")
    print("=" * 70)
    print(f"{'gap':>5} {'worst steps':>12} {'clog2(gap)':>11} "
          f"{'floor log2':>11} {'tight?':>7}")
    for gap in [1, 2, 3, 4, 5, 8, 9, 16, 17, 100, 1000]:
        # Worst case over all predicates: maximize by trying every flip point.
        worst = 0
        for t in range(gap + 1):
            p = lambda i, t=t: i >= t
            # anchors must satisfy p(0)=False, p(gap)=True; pick t in (0, gap].
            if 0 < t <= gap:
                worst = max(worst, bsearch_steps(p, 0, gap))
        cl = clog2(gap)
        fl = math.floor(math.log2(gap)) if gap >= 1 else 0
        tight = "yes" if worst == cl else ""
        ok = worst <= cl
        assert ok, f"bound violated at gap={gap}"
        print(f"{gap:>5} {worst:>12} {cl:>11} {fl:>11} {tight:>7}")
    print("  -> steps <= clog2(gap) always; equality (tight) e.g. at gap = 3.")
    print("  -> floor-log2 UNDERCOUNTS (e.g. gap=3: floor=1 but 2 steps needed).")
    print()


def demo_factoradic() -> None:
    """value_digit / value_unique: digit map is a bijection onto [0, k!)."""
    print("=" * 70)
    print("DEMO 3  Factoradic bijection (value_digit, value_unique, value_lt)")
    print("=" * 70)
    k = 5
    fact_k = math.factorial(k)
    print(f"k = {k},  k! = {fact_k}.  Checking all n in [0, {fact_k}):")
    seen: dict[Tuple[int, ...], int] = {}
    for n in range(fact_k):
        digits = factoradic_digits(n, k)
        c = lambda i, d=digits: d[i]
        # value_lt: valid code stays below k!
        assert is_valid(c, k) and value(c, k) < fact_k
        # value_digit: reconstruction recovers n
        assert value(c, k) == n
        # value_unique: codes are distinct (injectivity)
        key = tuple(digits)
        assert key not in seen, "collision -> uniqueness violated"
        seen[key] = n
    print(f"  value_lt    : every code's value < {fact_k}            OK")
    print(f"  value_digit : value(digit(n)) == n for all n           OK")
    print(f"  value_unique: all {fact_k} codes distinct (bijection)  OK")
    # Show a few example codes.
    print("  examples (n -> factoradic digits, least-significant first):")
    for n in [0, 1, 7, 42, 119]:
        print(f"    {n:>3} -> {factoradic_digits(n, k)}")
    print()


def demo_bridge() -> None:
    """factoradic_search: search [0, k!) in <= clog2(k!) comparisons."""
    print("=" * 70)
    print("DEMO 4  The bridge (factoradic_search)")
    print("=" * 70)
    for k in range(1, 9):
        fact_k = math.factorial(k)
        bound = clog2(fact_k)
        # search for a target inside the factoradic index space [0, k!)
        target = max(1, fact_k - 1)
        p = lambda i, t=target: i >= t
        steps = bsearch_steps(p, 0, fact_k)
        assert steps <= bound
        print(f"  k={k:>2}  k!={fact_k:>7}  search steps={steps:>2} "
              f"<= clog2(k!)={bound:>2}   OK")
    print("  -> searching the size-k! factoradic index space costs <= clog2(k!).")
    print()


def main() -> None:
    demo_correctness()
    demo_complexity()
    demo_factoradic()
    demo_bridge()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
