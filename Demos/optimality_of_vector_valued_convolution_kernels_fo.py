"""Numerical demonstrations for the difference-set method for Sidon sets.

A finite set S of integers is a *Sidon set* (B_2 set) if all pairwise sums
a + b are distinct, equivalently all pairwise differences a - b (a != b) are
distinct. Writing F(N) for the maximum size of a Sidon set inside {1, ..., N},
this module demonstrates:

  * verification of the Sidon property,
  * the difference-set counting bound  |S|(|S|-1) <= 2(N-1),
  * the square-root ceiling            F(N) <= sqrt(2N) + 1,
  * the powers-of-two Sidon family (unbounded lower bound),
  * the greedy (Mian-Chowla) Sidon sequence,
  * the quadratic construction Q_p realizing the sqrt(N) frontier.

All functions are self-contained and use only the standard library.
"""
from __future__ import annotations

import math
from itertools import combinations
from typing import List, Set, Tuple


# --------------------------------------------------------------------------
# Core predicates and bounds
# --------------------------------------------------------------------------
def is_sidon(s: List[int]) -> bool:
    """Return True iff `s` is a Sidon set (all pairwise differences distinct)."""
    diffs: Set[int] = set()
    elems = list(s)
    for a, b in combinations(elems, 2):
        d = a - b
        if d in diffs or -d in diffs:
            return False
        diffs.add(d)
        diffs.add(-d)
    return True


def distinct_difference_count(s: List[int]) -> Tuple[int, int]:
    """Return (ordered pair count |S|(|S|-1), number of distinct nonzero diffs)."""
    m = len(s)
    ordered_pairs = m * (m - 1)
    diffs = {a - b for a in s for b in s if a != b}
    return ordered_pairs, len(diffs)


def counting_bound_holds(s: List[int], n: int) -> bool:
    """Check the quantitative bound |S|(|S|-1) <= 2(N-1) for S in {1,...,N}."""
    m = len(s)
    return m * (m - 1) <= 2 * (n - 1)


def sqrt_ceiling(n: int) -> float:
    """The leading-order upper bound F(N) <= sqrt(2N) + 1."""
    return math.sqrt(2 * n) + 1.0


# --------------------------------------------------------------------------
# Constructions
# --------------------------------------------------------------------------
def powers_of_two(k: int) -> List[int]:
    """The first k powers of two {2^0, ..., 2^(k-1)} -- a Sidon set of size k."""
    return [2 ** i for i in range(k)]


def greedy_sidon(n: int) -> List[int]:
    """Greedy (Mian-Chowla-type) Sidon set inside {1, ..., N}."""
    chosen: List[int] = []
    realized: Set[int] = set()
    for x in range(1, n + 1):
        new_diffs = {x - s for s in chosen}
        if new_diffs.isdisjoint(realized):
            chosen.append(x)
            realized |= new_diffs
            realized |= {-d for d in new_diffs}
    return chosen


def quadratic_sidon(p: int) -> List[int]:
    """Quadratic family Q_p = {2p*i + (i^2 mod p) : 0 <= i < p} in {1,...,2p^2}."""
    return [2 * p * i + (i * i) % p for i in range(p)]


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_verify_small_sets() -> None:
    print("=" * 66)
    print("Sidon verification on small sets")
    print("=" * 66)
    examples = {
        "{1,2}": [1, 2],
        "{1,2,4}": [1, 2, 4],
        "{1,2,4,8}": [1, 2, 4, 8],
        "{1,2,3} (NOT Sidon: 2-1 = 3-2)": [1, 2, 3],
        "{1,2,5,11,13} (perfect ruler)": [1, 2, 5, 11, 13],
    }
    for name, s in examples.items():
        print(f"  {name:38s} -> Sidon = {is_sidon(s)}")


def demo_powers_of_two() -> None:
    print("=" * 66)
    print("Powers of two form a Sidon set of every size (unboundedness)")
    print("=" * 66)
    for k in range(1, 9):
        s = powers_of_two(k)
        ordered, distinct = distinct_difference_count(s)
        print(f"  k={k}: P_k={str(s):26s} Sidon={is_sidon(s)} "
              f"pairs={ordered:3d} distinct_diffs={distinct:3d}")


def demo_counting_bound() -> None:
    print("=" * 66)
    print("Difference-set counting bound  |S|(|S|-1) <= 2(N-1)")
    print("=" * 66)
    for n in [10, 50, 100, 500, 1000]:
        s = greedy_sidon(n)
        m = len(s)
        ceiling = sqrt_ceiling(n)
        ok = counting_bound_holds(s, n)
        print(f"  N={n:5d}: greedy |S|={m:3d}  m(m-1)={m*(m-1):5d} "
              f"<= 2(N-1)={2*(n-1):5d} [{ok}]  ceiling sqrt(2N)+1={ceiling:7.2f}")


def demo_quadratic_frontier() -> None:
    print("=" * 66)
    print("Quadratic construction Q_p realizes the sqrt(N) frontier")
    print("=" * 66)
    for p in [3, 5, 7, 11, 13, 17]:
        s = quadratic_sidon(p)
        n = 2 * p * p
        m = len(s)
        ratio = m / math.sqrt(n)
        print(f"  p={p:3d}: |Q_p|={m:3d}  window N=2p^2={n:5d}  "
              f"Sidon={is_sidon(s)}  |Q_p|/sqrt(N)={ratio:5.3f}")


def demo_bound_comparison() -> None:
    print("=" * 66)
    print("Lower (log2 vs sqrt) and upper (sqrt2) bracketing of F(N)")
    print("=" * 66)
    for n in [16, 64, 256, 1024, 4096]:
        log_lb = math.log2(n) + 1
        greedy_lb = len(greedy_sidon(n))
        upper = sqrt_ceiling(n)
        print(f"  N={n:5d}: powers-of-two LB~{log_lb:6.2f} | "
              f"greedy LB={greedy_lb:4d} | upper bound={upper:7.2f}")


if __name__ == "__main__":
    demo_verify_small_sets()
    print()
    demo_powers_of_two()
    print()
    demo_counting_bound()
    print()
    demo_quadratic_frontier()
    print()
    demo_bound_comparison()
