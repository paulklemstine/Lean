#!/usr/bin/env python3
"""
Algorithms for Multi-Step Filtration Obstruction Calculus

Provides implementations of:
1. Obstruction exponent computation for cyclic p-primary filtrations
2. Composition law verification
3. Gap invariant computation
4. General n-step recursive decomposition
5. Obstruction profile classification

All algorithms are O(1) for fixed-step filtrations and O(n) for
n-step recursive decomposition.
"""

from dataclasses import dataclass
from typing import List, Tuple, Optional


@dataclass
class ObstructionProfile:
    """Complete obstruction profile for a three-step filtration.

    Attributes:
        a, b, c: Exponents defining Z/p^a ⊆ Z/p^b ⊆ Z/p^c
        left_exp: Left step obstruction exponent min(a, b-a)
        right_exp: Right step obstruction exponent min(b, c-b)
        total_exp: Total obstruction exponent min(a, c-a)
        correction_exp: Triple correction min(max(a-(b-a), 0), c-b)
        gap1: First gap b - a
        gap2: Second gap c - b
    """
    a: int
    b: int
    c: int
    left_exp: int
    right_exp: int
    total_exp: int
    correction_exp: int
    gap1: int
    gap2: int

    @property
    def is_thin_base(self) -> bool:
        """Whether the base is thin (2a ≤ b), meaning correction vanishes."""
        return 2 * self.a <= self.b

    @property
    def is_split_left(self) -> bool:
        """Whether the left step splits (gap1 = 0)."""
        return self.gap1 == 0

    @property
    def is_maximal_anomaly(self) -> bool:
        """Whether the correction achieves its maximum (= a)."""
        return self.correction_exp == self.a


def compute_obstruction_profile(a: int, b: int, c: int) -> ObstructionProfile:
    """Compute the full obstruction profile for a three-step filtration.

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        a: Base exponent (a ≥ 0)
        b: Middle exponent (b ≥ a)
        c: Top exponent (c ≥ b)

    Returns:
        ObstructionProfile with all computed invariants.

    Raises:
        ValueError: If a > b or b > c.

    Example:
        >>> p = compute_obstruction_profile(2, 3, 5)
        >>> p.correction_exp
        1
        >>> p.is_thin_base
        False
    """
    if a > b or b > c:
        raise ValueError(f"Need a ≤ b ≤ c, got ({a}, {b}, {c})")

    gap1 = b - a
    gap2 = c - b
    left_exp = min(a, gap1)
    right_exp = min(b, gap2)
    total_exp = min(a, c - a)
    correction_exp = min(max(a - gap1, 0), gap2)

    return ObstructionProfile(
        a=a, b=b, c=c,
        left_exp=left_exp, right_exp=right_exp,
        total_exp=total_exp, correction_exp=correction_exp,
        gap1=gap1, gap2=gap2
    )


def nstep_recursive_decomposition(exponents: List[int]) -> List[int]:
    """Compute the recursive obstruction decomposition for an n-step filtration.

    For a filtration 0 ⊆ Z/p^{e_0} ⊆ Z/p^{e_1} ⊆ ... ⊆ Z/p^{e_n},
    decomposes the total obstruction min(e_0, e_n - e_0) as:
        left_obs + correction_1 + correction_2 + ... + correction_{n-1}

    where each correction_k measures the k-th interaction term.

    Time complexity: O(n) where n is the number of steps
    Space complexity: O(n)

    Args:
        exponents: List [e_0, e_1, ..., e_n] with e_0 ≤ e_1 ≤ ... ≤ e_n

    Returns:
        List of terms [left_obs, corr_1, corr_2, ..., corr_{n-1}]
        whose sum equals min(e_0, e_n - e_0).

    Example:
        >>> nstep_recursive_decomposition([2, 3, 5, 9])
        [1, 1, 0]
    """
    if len(exponents) < 2:
        return [0]

    a = exponents[0]
    terms = [min(a, exponents[1] - a)]  # left obstruction

    for k in range(2, len(exponents)):
        prev_total = exponents[k - 1] - a
        curr_gap = exponents[k] - exponents[k - 1]
        correction = min(max(a - prev_total, 0), curr_gap)
        terms.append(correction)

    return terms


def classify_filtration(a: int, b: int, c: int) -> str:
    """Classify a three-step filtration by its obstruction behavior.

    Returns a human-readable classification string.

    Categories:
    - "trivial": a = 0 or c = a (no obstruction at all)
    - "thin-base": 2a ≤ b (correction vanishes, pairwise data suffices)
    - "split-left": b = a (left step trivial, all obstruction from right)
    - "maximal-anomaly": correction = a (maximum interaction)
    - "partial-anomaly": 0 < correction < a (intermediate interaction)
    """
    profile = compute_obstruction_profile(a, b, c)

    if profile.total_exp == 0:
        return "trivial"
    elif profile.is_split_left:
        return "split-left"
    elif profile.is_thin_base:
        return "thin-base"
    elif profile.is_maximal_anomaly:
        return "maximal-anomaly"
    elif profile.correction_exp > 0:
        return "partial-anomaly"
    else:
        return "thin-base"


def find_critical_threshold(a: int, gap2: int) -> int:
    """Find the critical gap1 threshold where correction transitions to zero.

    The correction vanishes when gap1 ≥ a. This function returns a,
    the exact threshold.

    Args:
        a: Base exponent
        gap2: Second gap (unused, but included for interface completeness)

    Returns:
        The critical value of gap1 at which correction becomes zero.
    """
    return a


def enumerate_anomaly_spectrum(max_exp: int) -> List[Tuple[int, int, int, int]]:
    """Enumerate all distinct (a, gap1, gap2, correction) patterns up to max_exp.

    Returns sorted list of tuples showing the full landscape of
    obstruction behavior.

    Time complexity: O(max_exp^3)
    """
    results = []
    seen = set()
    for a in range(max_exp + 1):
        for d1 in range(max_exp + 1):
            for d2 in range(1, max_exp + 1):
                corr = min(max(a - d1, 0), d2)
                key = (a, d1, d2, corr)
                if key not in seen:
                    seen.add(key)
                    results.append(key)
    return sorted(results)


if __name__ == "__main__":
    # Demo usage
    print("=== Obstruction Profile Examples ===\n")
    examples = [(1, 2, 3), (2, 3, 5), (3, 4, 7), (2, 2, 5), (5, 6, 10)]
    for a, b, c in examples:
        p = compute_obstruction_profile(a, b, c)
        cls = classify_filtration(a, b, c)
        print(f"({a},{b},{c}): left={p.left_exp}, right={p.right_exp}, "
              f"total={p.total_exp}, correction={p.correction_exp}, "
              f"class={cls}")

    print("\n=== N-Step Recursive Decomposition ===\n")
    for exps in [[1, 2, 3], [2, 3, 5, 9], [1, 3, 5, 7, 10], [3, 3, 5, 8]]:
        terms = nstep_recursive_decomposition(exps)
        total = min(exps[0], exps[-1] - exps[0])
        print(f"Exponents {exps}: terms={terms}, sum={sum(terms)}, total={total}, "
              f"{'✓' if sum(terms) == total else '✗'}")
