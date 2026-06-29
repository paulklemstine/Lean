"""
Numerical demonstration: cover times of block families and the Fano plane.

This self-contained script reproduces the central results of the accompanying
paper:

  * The block coupon-collector cover time is given by the inclusion-exclusion
    formula  E[T] = sum_{S != {}} (-1)^{|S|+1} * |B| / c(S),  where c(S) is the
    number of blocks meeting S.
  * For the singleton family on n points this equals the classical n * H_n.
  * For the seven lines of the Fano plane (the unique 2-(7,3,1) design) it
    equals 163/30, which is STRICTLY LESS THAN 7 * H_7 = 363/20.

All arithmetic is exact (fractions.Fraction), so the printed equalities are
mathematically certain, not floating-point approximations.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from typing import FrozenSet, Iterable, List, Sequence, Set, Tuple


Block = FrozenSet[int]


def coverage_count(blocks: Sequence[Block], subset: Set[int]) -> int:
    """Number of blocks that meet `subset` (have nonempty intersection with it)."""
    return sum(1 for b in blocks if b & subset)


def expected_cover_time(blocks: Sequence[Block], points: Sequence[int]) -> Fraction:
    """Exact expected cover time via inclusion-exclusion over nonempty subsets."""
    num_blocks = len(blocks)
    total = Fraction(0)
    n = len(points)
    for k in range(1, n + 1):
        sign = 1 if k % 2 == 1 else -1
        for combo in combinations(points, k):
            s = set(combo)
            c = coverage_count(blocks, s)
            if c == 0:
                continue  # an uncoverable subset contributes nothing finite here
            total += Fraction(sign * num_blocks, c)
    return total


def harmonic(n: int) -> Fraction:
    """The n-th harmonic number H_n = 1 + 1/2 + ... + 1/n as an exact fraction."""
    return sum((Fraction(1, k) for k in range(1, n + 1)), Fraction(0))


def singleton_family(n: int) -> List[Block]:
    """The n singletons {0}, {1}, ..., {n-1}."""
    return [frozenset({a}) for a in range(n)]


def fano_lines() -> List[Block]:
    """The seven lines of the Fano plane on points {0, ..., 6}."""
    raw: List[Tuple[int, int, int]] = [
        (0, 1, 2), (0, 3, 4), (0, 5, 6),
        (1, 3, 5), (1, 4, 6), (2, 3, 6), (2, 4, 5),
    ]
    return [frozenset(line) for line in raw]


def coverage_profile_by_size(
    blocks: Sequence[Block], points: Sequence[int]
) -> dict[int, Set[int]]:
    """For each subset size, the set of distinct coverage-count values observed."""
    profile: dict[int, Set[int]] = {}
    n = len(points)
    for k in range(1, n + 1):
        vals: Set[int] = set()
        for combo in combinations(points, k):
            vals.add(coverage_count(blocks, set(combo)))
        profile[k] = vals
    return profile


def verify_design_parameters(blocks: Sequence[Block], points: Sequence[int]) -> None:
    """Check the 2-(7,3,1) design axioms for the Fano line family."""
    assert len(blocks) == 7, "Fano plane has 7 lines"
    assert all(len(b) == 3 for b in blocks), "every line has 3 points"
    for p in points:
        deg = sum(1 for b in blocks if p in b)
        assert deg == 3, f"point {p} should lie on 3 lines, got {deg}"
    for p, q in combinations(points, 2):
        common = sum(1 for b in blocks if p in b and q in b)
        assert common == 1, f"pair {{{p},{q}}} should share 1 line, got {common}"


def main() -> None:
    points: List[int] = list(range(7))

    print("=" * 64)
    print("Coupon-collector cover times: singletons vs. the Fano plane")
    print("=" * 64)

    # --- Classical singleton collector ---------------------------------------
    singles = singleton_family(7)
    e_singles = expected_cover_time(singles, points)
    seven_H7 = 7 * harmonic(7)
    print("\n[1] Singleton family on 7 points (classical coupon collector)")
    print(f"    E[cover time]      = {e_singles}  = {float(e_singles):.4f}")
    print(f"    7 * H_7            = {seven_H7}  = {float(seven_H7):.4f}")
    assert e_singles == seven_H7 == Fraction(363, 20)
    print("    check: E[T] == 7*H_7 == 363/20   -> OK")

    # --- Fano plane ----------------------------------------------------------
    fano = fano_lines()
    verify_design_parameters(fano, points)
    print("\n[2] Fano line family (the 2-(7,3,1) design)")
    print("    design axioms 2-(7,3,1) verified                -> OK")

    profile = coverage_profile_by_size(fano, points)
    print("    coverage counts c(S) by subset size |S|:")
    for k in sorted(profile):
        vals = sorted(profile[k])
        note = ""
        if k == 1:
            note = "  (each point on 3 lines)"
        elif k == 2:
            note = "  (3 + 3 - 1; the early '4' was wrong)"
        elif len(vals) > 1:
            note = "  (depends on configuration, not just size)"
        print(f"      |S|={k}: {vals}{note}")

    e_fano = expected_cover_time(fano, points)
    print(f"\n    E[cover time]      = {e_fano}  = {float(e_fano):.4f}")
    assert e_fano == Fraction(163, 30)
    print("    check: E[T] == 163/30            -> OK")

    # --- The comparison ------------------------------------------------------
    print("\n[3] Comparison")
    print(f"    Fano   : {e_fano}  ~ {float(e_fano):.4f}")
    print(f"    Singles: {e_singles}  ~ {float(e_singles):.4f}")
    assert e_fano < e_singles
    speedup = e_singles / e_fano
    print(f"    Fano is STRICTLY FASTER by a factor of {float(speedup):.3f}")
    print("    => the original 'design exceeds 7*H_7' claim is FALSE")
    print("    => a covering design MINIMIZES, not maximizes, cover time")

    print("\n" + "=" * 64)
    print("All exact-arithmetic checks passed.")
    print("=" * 64)


if __name__ == "__main__":
    main()
