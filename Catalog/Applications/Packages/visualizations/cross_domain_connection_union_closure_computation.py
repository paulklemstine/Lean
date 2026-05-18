#!/usr/bin/env python3
"""
Algorithms for Union-Closed Family Analysis

Implements the computational core for analyzing union-closed set families
as monotone configuration spaces, computing correlation observables,
and performing union closure operations.
"""

from itertools import combinations, chain
from collections import Counter, defaultdict
from fractions import Fraction
from typing import FrozenSet, Set, List, Tuple, Dict, Optional
import math


# Type aliases
Element = int
Subset = FrozenSet[Element]
Family = List[Subset]


def powerset_list(ground: Set[Element]) -> Family:
    """Generate the full powerset of a ground set as a list of frozensets.

    Time: O(2^n), Space: O(2^n) where n = |ground|.

    >>> powerset_list({1, 2})
    [frozenset(), frozenset({1}), frozenset({2}), frozenset({1, 2})]
    """
    s = sorted(ground)
    return [frozenset(c) for r in range(len(s) + 1)
            for c in combinations(s, r)]


def is_union_closed(family: Family) -> bool:
    """Check if a family is closed under pairwise unions.

    Time: O(|F|^2 · n), Space: O(|F| · n).

    Args:
        family: List of frozensets.

    Returns:
        True if for all A, B in family, A ∪ B is also in family.

    >>> is_union_closed([frozenset({1}), frozenset({2}), frozenset({1,2})])
    True
    >>> is_union_closed([frozenset({1}), frozenset({2})])
    False
    """
    family_set = set(family)
    return all(A | B in family_set for A in family for B in family)


def union_closure(family: Family) -> Family:
    """Compute the smallest union-closed family containing the input.

    Uses iterative fixpoint: repeatedly add pairwise unions until stable.

    Time: O(|cl(F)|^2 · n) per iteration, at most O(2^n) iterations.
    Space: O(2^n · n).

    Args:
        family: Input family of frozensets.

    Returns:
        Sorted list of frozensets forming the union closure.

    >>> union_closure([frozenset({1}), frozenset({2})])
    [frozenset({1}), frozenset({2}), frozenset({1, 2})]
    """
    current = set(family)
    changed = True
    while changed:
        changed = False
        to_add = set()
        current_list = list(current)
        for i, A in enumerate(current_list):
            for B in current_list[i:]:
                C = A | B
                if C not in current:
                    to_add.add(C)
                    changed = True
        current |= to_add
    return sorted(current, key=lambda s: (len(s), sorted(s)))


def member_count(a: Element, family: Family) -> int:
    """Count sets in family containing element a.

    Equals |F| · P(a ∈ s) under uniform measure on F.

    Time: O(|F|), Space: O(1).

    >>> member_count(1, [frozenset({1,2}), frozenset({2,3}), frozenset({1,3})])
    2
    """
    return sum(1 for s in family if a in s)


def joint_count(a: Element, b: Element, family: Family) -> int:
    """Count sets containing both a and b.

    Equals |F| · P(a ∈ s ∧ b ∈ s) under uniform measure.

    Time: O(|F|), Space: O(1).
    """
    return sum(1 for s in family if a in s and b in s)


def marginal_density(a: Element, family: Family) -> Fraction:
    """Marginal occupancy probability of site a under uniform measure.

    Time: O(|F|), Space: O(1).
    """
    if not family:
        return Fraction(0)
    return Fraction(member_count(a, family), len(family))


def two_point_correlation(a: Element, b: Element,
                          family: Family) -> Fraction:
    """Two-point correlation function E[X_a · X_b].

    Time: O(|F|), Space: O(1).
    """
    if not family:
        return Fraction(0)
    return Fraction(joint_count(a, b, family), len(family))


def covariance(a: Element, b: Element, family: Family) -> Fraction:
    """Connected correlation Cov(X_a, X_b) = E[X_a X_b] - E[X_a]E[X_b].

    Time: O(|F|), Space: O(1).
    """
    return two_point_correlation(a, b, family) - \
           marginal_density(a, family) * marginal_density(b, family)


def correlation_matrix(ground: Set[Element],
                       family: Family) -> Dict[Tuple[int,int], Fraction]:
    """Compute the full covariance matrix of site occupancy variables.

    Time: O(|α|^2 · |F|), Space: O(|α|^2).

    Returns:
        Dictionary mapping (a, b) -> Cov(X_a, X_b).
    """
    result = {}
    for a in sorted(ground):
        for b in sorted(ground):
            if b >= a:
                result[(a, b)] = covariance(a, b, family)
                if a != b:
                    result[(b, a)] = result[(a, b)]
    return result


def total_occupancy(family: Family) -> int:
    """Total particle number across all configurations: Σ_{s∈F} |s|.

    Time: O(|F|), Space: O(1).
    """
    return sum(len(s) for s in family)


def average_card(family: Family) -> Fraction:
    """Average set size in the family.

    Time: O(|F|), Space: O(1).
    """
    if not family:
        return Fraction(0)
    return Fraction(total_occupancy(family), len(family))


def find_popular_elements(ground: Set[Element], family: Family,
                          threshold: Fraction = Fraction(1, 2)) -> List[Element]:
    """Find elements with marginal density ≥ threshold.

    Time: O(|α| · |F|), Space: O(|α|).
    """
    return [a for a in sorted(ground)
            if marginal_density(a, family) >= threshold]


def verify_theorem_a(ground: Set[Element], family: Family) -> bool:
    """Verify Σ_a memberCount(a, F) = Σ_{s∈F} |s|.

    Time: O(|α| · |F|), Space: O(1).
    """
    lhs = sum(member_count(a, family) for a in ground)
    rhs = total_occupancy(family)
    return lhs == rhs


def verify_theorem_b(ground: Set[Element], family: Family) -> bool:
    """Verify the majority-from-average principle.

    Time: O(|α| · |F|), Space: O(1).
    """
    if not family or not ground:
        return True  # vacuous
    n = len(ground)
    F_card = len(family)
    if 2 * total_occupancy(family) < F_card * n:
        return True  # hypothesis not met
    return any(2 * member_count(a, family) >= F_card for a in ground)


def verify_theorem_c(family: Family) -> Tuple[bool, int, int]:
    """Verify Σ|s| over F ≤ Σ|s| over cl(F).

    Returns (result, total_F, total_cl).
    Time: O(|cl(F)|^2 · n), Space: O(2^n · n).
    """
    cl = union_closure(family)
    t_f = total_occupancy(family)
    t_cl = total_occupancy(cl)
    return t_f <= t_cl, t_f, t_cl


def verify_powerset_correlation(ground: Set[Element]) -> bool:
    """Verify nonneg correlation on full powerset for all pairs.

    Time: O(|α|^2 · 2^n), Space: O(2^n · n).
    """
    ps = powerset_list(ground)
    P = len(ps)
    for a in ground:
        for b in ground:
            mc_a = member_count(a, ps)
            mc_b = member_count(b, ps)
            jc = joint_count(a, b, ps)
            if P * jc < mc_a * mc_b:
                return False
    return True


def enumerate_union_closed_families(ground: Set[Element]) -> List[Family]:
    """Enumerate all union-closed subfamilies of 2^ground.

    Warning: exponential in 2^|ground|. Only practical for |ground| ≤ 4.

    Time: O(2^(2^n) · 2^n · n), Space: O(2^(2^n)).
    """
    ps = powerset_list(ground)
    result = []
    for r in range(len(ps) + 1):
        for subfamily in combinations(ps, r):
            fam = list(subfamily)
            if is_union_closed(fam):
                result.append(fam)
    return result


def frankl_conjecture_check(ground: Set[Element],
                            family: Family) -> Dict[str, object]:
    """Check Frankl's union-closed conjecture for a specific family.

    Frankl's conjecture: every union-closed family with ≥ 2 members
    has an element in at least half the sets.

    Time: O(|α| · |F|), Space: O(|α|).
    """
    F_card = len(family)
    if F_card <= 1:
        return {"applicable": False, "reason": "family too small"}
    if not is_union_closed(family):
        return {"applicable": False, "reason": "not union-closed"}

    max_mc = 0
    best_elem = None
    for a in ground:
        mc = member_count(a, family)
        if mc > max_mc:
            max_mc = mc
            best_elem = a

    holds = 2 * max_mc >= F_card
    return {
        "applicable": True,
        "holds": holds,
        "best_element": best_elem,
        "best_count": max_mc,
        "family_size": F_card,
        "ratio": Fraction(max_mc, F_card),
    }


if __name__ == "__main__":
    print("=== Algorithm Verification Suite ===\n")

    for n in range(1, 5):
        ground = set(range(1, n + 1))
        print(f"Ground set size {n}:")

        # Theorem A
        ps = powerset_list(ground)
        assert verify_theorem_a(ground, ps), f"Theorem A failed for n={n}"
        print(f"  Theorem A (double counting): ✓")

        # Theorem B
        assert verify_theorem_b(ground, ps), f"Theorem B failed for n={n}"
        print(f"  Theorem B (majority-from-avg): ✓")

        # Powerset correlation
        assert verify_powerset_correlation(ground), f"Powerset corr failed for n={n}"
        print(f"  Powerset nonneg correlation: ✓")

    # Frankl check on small families
    print("\nFrankl's conjecture verification on all union-closed families of {1,2,3}:")
    ground3 = {1, 2, 3}
    families = enumerate_union_closed_families(ground3)
    print(f"  Total union-closed families: {len(families)}")
    all_hold = True
    for fam in families:
        result = frankl_conjecture_check(ground3, fam)
        if result["applicable"] and not result["holds"]:
            all_hold = False
            print(f"  COUNTEREXAMPLE: {[sorted(s) for s in fam]}")
    if all_hold:
        print(f"  Frankl's conjecture holds for all {len(families)} families ✓")

    print("\nAll algorithm checks passed!")
