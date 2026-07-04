"""
Numerical demonstrations for the multi-kernel support law of Sidon sets.

A finite set of integers s is a Sidon set (B_2 set) if all pairwise sums are
distinct; equivalently, all differences of distinct elements are distinct.

Main results demonstrated here (k = |s|):
  * Maximal difference-set law:   |s - s| = k^2 - k + 1   (for Sidon s)
  * Characterization:             s is Sidon  <=>  |s - s| = k^2 - k + 1
  * Sum-difference conservation:  2|s + s| = |s - s| + 2k - 1  (for Sidon s)
  * Classical sum law:            2|s + s| = k(k + 1)          (for Sidon s)

All functions are self-contained and use only the standard library.
"""

from __future__ import annotations

from itertools import combinations
from typing import Iterable, List, Set, Tuple


# --------------------------------------------------------------------------- #
# Core kernels and predicates
# --------------------------------------------------------------------------- #

def is_sidon(s: Iterable[int]) -> bool:
    """Return True iff s is a Sidon set (all pairwise differences distinct)."""
    elems = sorted(set(s))
    seen: Set[int] = set()
    for a, b in combinations(elems, 2):
        d = a - b
        if d in seen:
            return False
        seen.add(d)
    return True


def difference_set(s: Iterable[int]) -> Set[int]:
    """The difference set s - s = { a - b : a, b in s }."""
    elems = list(set(s))
    return {a - b for a in elems for b in elems}


def sumset(s: Iterable[int]) -> Set[int]:
    """The sumset s + s = { a + b : a, b in s }."""
    elems = list(set(s))
    return {a + b for a in elems for b in elems}


def difference_kernel(s: Iterable[int]) -> dict[int, int]:
    """The difference kernel r^-_s(x) = #{ (a,b) : a - b = x }."""
    elems = list(set(s))
    kernel: dict[int, int] = {}
    for a in elems:
        for b in elems:
            kernel[a - b] = kernel.get(a - b, 0) + 1
    return kernel


def max_difference_card(k: int) -> int:
    """The maximal possible difference-set size for a k-element set."""
    return k * k - k + 1


def deficit(s: Iterable[int]) -> int:
    """Deficit D(s) = (k^2 - k + 1) - |s - s|; zero iff s is Sidon."""
    k = len(set(s))
    return max_difference_card(k) - len(difference_set(s))


# --------------------------------------------------------------------------- #
# Verification of the theorems on concrete sets
# --------------------------------------------------------------------------- #

def report(s: List[int]) -> None:
    """Print a full multi-kernel report for the set s and check the laws."""
    elems = sorted(set(s))
    k = len(elems)
    ds = difference_set(elems)
    ss = sumset(elems)
    sidon = is_sidon(elems)

    print(f"set s               = {elems}")
    print(f"k = |s|             = {k}")
    print(f"Sidon?              = {sidon}")
    print(f"|s - s|             = {len(ds)}")
    print(f"k^2 - k + 1  (max)  = {max_difference_card(k)}")
    print(f"deficit D(s)        = {deficit(elems)}")
    print(f"|s + s|             = {len(ss)}")
    if sidon:
        # Maximal difference-set law
        assert len(ds) == max_difference_card(k), "difference-set law failed"
        # Classical sum law
        assert 2 * len(ss) == k * (k + 1), "sum law failed"
        # Conservation law
        assert 2 * len(ss) == len(ds) + 2 * k - 1, "conservation law failed"
        print("laws verified       = difference-set, sum, conservation  [OK]")
    else:
        assert len(ds) < max_difference_card(k), "non-Sidon should be deficient"
        print("characterization    = |s-s| < max, correctly NOT Sidon   [OK]")
    print("-" * 56)


def brute_force_sidon(s: Iterable[int]) -> bool:
    """Independent O(k^4) Sidon check via the sum definition, for validation."""
    elems = sorted(set(s))
    for a in elems:
        for b in elems:
            for c in elems:
                for d in elems:
                    if a + b == c + d and not (a == c or a == d):
                        return False
    return True


def cross_validate(sets: List[List[int]]) -> None:
    """Confirm the O(k^2) difference test agrees with the O(k^4) definition."""
    print("Cross-validation: difference test vs. quadruple definition")
    for s in sets:
        fast = is_sidon(s)
        slow = brute_force_sidon(s)
        char = (len(difference_set(s)) == max_difference_card(len(set(s))))
        assert fast == slow == char, f"disagreement on {s}"
        print(f"  {str(sorted(set(s))):<24} sidon={fast}  (all methods agree)")
    print("-" * 56)


# --------------------------------------------------------------------------- #
# Main
# --------------------------------------------------------------------------- #

if __name__ == "__main__":
    print("=" * 56)
    print("Multi-kernel support law for Sidon sets — demonstrations")
    print("=" * 56)

    # A power-of-two Sidon set.
    report([1, 2, 4, 8])
    # A Mian-Chowla style Sidon set.
    report([1, 2, 5, 11, 22])
    # Perfect-difference-set flavored Sidon set {0,1,3} (k=3).
    report([0, 1, 3])
    # A non-Sidon consecutive set (many collisions).
    report([1, 2, 3, 4])
    # Another non-Sidon set.
    report([0, 1, 2, 4, 5])

    cross_validate(
        [[1, 2, 4, 8], [1, 2, 3, 4], [0, 1, 3], [1, 2, 5, 11, 22], [0, 1, 2, 4, 5]]
    )

    # Show the difference kernel (autocorrelation) of a Sidon set is flat.
    print("Difference kernel of the Sidon set {1,2,4,8} (value : count):")
    for x, c in sorted(difference_kernel([1, 2, 4, 8]).items()):
        tag = "  <- diagonal" if x == 0 else ""
        print(f"  {x:>3} : {c}{tag}")
    print("All nonzero counts equal 1  =>  maximally flat autocorrelation.")
