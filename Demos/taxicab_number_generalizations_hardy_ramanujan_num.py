"""
Numerical demonstrations for the elementary theory of taxicab representations.

A *taxicab representation* of a natural number N is a pair (a, b) of positive
integers with a <= b and a**3 + b**3 == N. The n-th taxicab number Taxicab(n)
is the least N admitting at least n distinct such representations.

This self-contained script demonstrates:
  1. Enumeration of representations (rigidity: the smaller summand is unique).
  2. Verification of the classical witnesses 1729, 87539319, 6963472309248.
  3. The cubic lower bound  Taxicab(n) > n**3.
  4. The cube-scaling principle (counts never decrease under * t**3).

All functions are inlined with type hints; no third-party dependencies.
"""

from __future__ import annotations

from typing import Dict, List, Tuple


# ---------------------------------------------------------------------------
# 1. Core: integer cube root and representation enumeration  (Algorithm A)
# ---------------------------------------------------------------------------

def integer_cube_root(n: int) -> int:
    """Return floor(n ** (1/3)) exactly for n >= 0 using integer arithmetic."""
    if n < 0:
        raise ValueError("integer_cube_root expects n >= 0")
    if n == 0:
        return 0
    lo, hi = 0, 1
    while hi ** 3 <= n:
        hi *= 2
    while lo < hi:
        mid = (lo + hi + 1) // 2
        if mid ** 3 <= n:
            lo = mid
        else:
            hi = mid - 1
    return lo


def is_perfect_cube(n: int) -> bool:
    """True iff n is the cube of a non-negative integer."""
    if n < 0:
        return False
    r = integer_cube_root(n)
    return r ** 3 == n


def representations(N: int) -> List[Tuple[int, int]]:
    """All (a, b) with 0 < a <= b and a**3 + b**3 == N, sorted by a.

    Complexity: O(N**(1/3)) loop iterations, each an O(1) cube test.
    """
    reps: List[Tuple[int, int]] = []
    a = 1
    while 2 * a ** 3 <= N:          # a <= b forces 2*a**3 <= N
        remainder = N - a ** 3
        if remainder > 0 and is_perfect_cube(remainder):
            b = integer_cube_root(remainder)
            if b >= a:
                reps.append((a, b))
        a += 1
    return reps


# ---------------------------------------------------------------------------
# 2. Classical witnesses
# ---------------------------------------------------------------------------

CLASSICAL: Dict[int, int] = {
    2: 1729,
    3: 87539319,
    4: 6963472309248,
}


def verify_witnesses() -> None:
    """Confirm each classical taxicab number has exactly the expected count."""
    print("=== Classical taxicab witnesses ===")
    for n, N in CLASSICAL.items():
        reps = representations(N)
        print(f"Taxicab({n}) = {N}")
        for (a, b) in reps:
            assert a ** 3 + b ** 3 == N
            print(f"    {a}^3 + {b}^3 = {N}")
        assert len(reps) == n, f"expected {n} reps, found {len(reps)}"
        print(f"    -> exactly {len(reps)} distinct representations. OK\n")


# ---------------------------------------------------------------------------
# 3. Rigidity check: distinct representations use distinct smaller summands
# ---------------------------------------------------------------------------

def check_rigidity(N: int) -> None:
    """Verify the smaller summand determines the representation."""
    reps = representations(N)
    smaller = [a for (a, _) in reps]
    assert len(smaller) == len(set(smaller)), "smaller summands must be distinct"
    print(f"Rigidity for N={N}: {len(smaller)} representations, "
          f"{len(set(smaller))} distinct smaller summands. OK")


# ---------------------------------------------------------------------------
# 4. Cubic lower bound:  n distinct representations  =>  N > n**3
# ---------------------------------------------------------------------------

def check_cubic_floor() -> None:
    """Confirm Taxicab(n) > n**3 for the known values, with the margin."""
    print("\n=== Cubic lower bound  Taxicab(n) > n^3 ===")
    for n, N in CLASSICAL.items():
        floor = n ** 3
        assert N > floor
        ratio = N / floor
        print(f"n={n}: floor n^3 = {floor:>3}, "
              f"Taxicab(n) = {N:>16}, ratio = {ratio:.3e}")


# ---------------------------------------------------------------------------
# 5. Cube-scaling principle:  count(N) <= count(N * t**3)   (Algorithm C)
# ---------------------------------------------------------------------------

def scale_representations(reps: List[Tuple[int, int]], t: int) -> List[Tuple[int, int]]:
    """Transport representations of N to representations of N * t**3."""
    if t <= 0:
        raise ValueError("t must be positive")
    return [(a * t, b * t) for (a, b) in reps]


def check_scaling(N: int, t: int) -> None:
    """Verify scaling by t preserves the representation count (injectively)."""
    base = representations(N)
    scaled = scale_representations(base, t)
    target = N * t ** 3
    for (a, b) in scaled:
        assert a ** 3 + b ** 3 == target
    # scaled reps are among the reps of the target (count non-decreasing)
    all_target = set(representations(target))
    assert set(scaled).issubset(all_target)
    print(f"Scaling N={N} by t={t}: {len(base)} -> {len(scaled)} transported "
          f"representations of {target} (target has {len(all_target)} total).")


# ---------------------------------------------------------------------------
# 6. Small taxicab search by sieving  (Algorithm B, illustrative)
# ---------------------------------------------------------------------------

def taxicab_search(min_count: int, cube_limit: int) -> Tuple[int, int]:
    """Least N with >= min_count representations, searching a, b <= cube_limit.

    Returns (N, count). Caveat: correctness of minimality requires cube_limit
    large enough that all summands of the true answer fall within range.
    """
    counts: Dict[int, int] = {}
    for a in range(1, cube_limit + 1):
        a3 = a ** 3
        for b in range(a, cube_limit + 1):
            s = a3 + b ** 3
            counts[s] = counts.get(s, 0) + 1
    best = min((s for s, c in counts.items() if c >= min_count), default=-1)
    return best, counts.get(best, 0)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    verify_witnesses()

    print("=== Rigidity (smaller summand determines representation) ===")
    for N in CLASSICAL.values():
        check_rigidity(N)

    check_cubic_floor()

    print("\n=== Cube-scaling principle ===")
    check_scaling(1729, 2)   # 1729 * 8 = 13832 inherits >= 2 representations
    check_scaling(1729, 3)

    print("\n=== Small taxicab search (sieving up to 20) ===")
    N2, c2 = taxicab_search(2, 20)
    print(f"Least N <= grid with >= 2 representations: {N2} ({c2} ways) -> 1729")


if __name__ == "__main__":
    main()
