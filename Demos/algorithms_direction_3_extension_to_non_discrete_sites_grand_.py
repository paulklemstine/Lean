#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Categorical Compression Number

Implements the core algorithms for computing κ(C), finding minimal
separating families, and testing Yoneda-separation.
"""

from itertools import combinations
from typing import Dict, List, Set, Tuple, Any


def is_thin(cat) -> bool:
    """Check if all hom-sets have at most one element."""
    return all(len(m) <= 1 for m in cat.hom.values())


def parallel_pairs(cat) -> List[Tuple]:
    """Return all non-trivial pairs of parallel morphisms (x, y, f, g) with f ≠ g."""
    pairs = []
    for (x, y), morphs in cat.hom.items():
        for i, f in enumerate(morphs):
            for g in morphs[i + 1:]:
                pairs.append((x, y, f, g))
    return pairs


def is_yoneda_separating(cat, probe_set: Set) -> bool:
    """
    Check if probe_set is Yoneda-separating for cat.

    Time complexity: O(|Par| · |P| · max|Hom|)
    where |Par| is the number of parallel pairs.
    """
    for x, y, f, g in parallel_pairs(cat):
        separated = False
        for q in probe_set:
            for h in cat.hom.get((y, q), []):
                if cat.compose.get((f, h)) != cat.compose.get((g, h)):
                    separated = True
                    break
            if separated:
                break
        if not separated:
            return False
    return True


def compression_number_bruteforce(cat) -> Tuple[int, Set]:
    """
    Compute κ(C) by brute-force enumeration.

    Algorithm:
      For k = 0, 1, 2, ..., |Ob(C)|:
        For each subset P ⊆ Ob(C) with |P| = k:
          If P is Yoneda-separating: return k, P.

    Time complexity: O(2^|Ob| · |Par| · |Ob| · max|Hom|)

    Returns (κ, witness) where witness is a minimal separating family.
    """
    if is_thin(cat):
        return 0, set()

    for size in range(len(cat.objects) + 1):
        for probe in combinations(cat.objects, size):
            if is_yoneda_separating(cat, set(probe)):
                return size, set(probe)
    return len(cat.objects), set(cat.objects)


def all_minimal_separating_families(cat) -> List[Set]:
    """Find all minimal Yoneda-separating families (those achieving κ(C))."""
    kappa, _ = compression_number_bruteforce(cat)
    result = []
    for probe in combinations(cat.objects, kappa):
        if is_yoneda_separating(cat, set(probe)):
            result.append(set(probe))
    return result


def separation_profile(cat) -> Dict[int, int]:
    """
    Compute the separation profile: for each k, count how many
    size-k subsets are Yoneda-separating.
    """
    profile = {}
    for size in range(len(cat.objects) + 1):
        count = 0
        for probe in combinations(cat.objects, size):
            if is_yoneda_separating(cat, set(probe)):
                count += 1
        profile[size] = count
    return profile


def monotonicity_check(cat) -> bool:
    """Verify monotonicity: P separating and P ⊆ Q implies Q separating."""
    sep_families = set()
    for size in range(len(cat.objects) + 1):
        for probe in combinations(cat.objects, size):
            if is_yoneda_separating(cat, set(probe)):
                sep_families.add(frozenset(probe))

    for family in sep_families:
        for obj in cat.objects:
            superset = family | {obj}
            if frozenset(superset) not in sep_families:
                return False
    return True


def greedy_separating_family(cat) -> Tuple[int, Set]:
    """
    Greedy approximation: iteratively add the object that separates
    the most remaining unseparated pairs.

    Time complexity: O(|Ob|^2 · |Par| · max|Hom|)
    """
    pairs = parallel_pairs(cat)
    if not pairs:
        return 0, set()

    probe = set()
    remaining = list(pairs)

    while remaining:
        best_obj = None
        best_count = -1
        for q in cat.objects:
            if q in probe:
                continue
            count = 0
            for x, y, f, g in remaining:
                for h in cat.hom.get((y, q), []):
                    if cat.compose.get((f, h)) != cat.compose.get((g, h)):
                        count += 1
                        break
            if count > best_count:
                best_count = count
                best_obj = q
        if best_obj is None or best_count == 0:
            break
        probe.add(best_obj)
        new_remaining = []
        for x, y, f, g in remaining:
            separated = False
            for h in cat.hom.get((y, best_obj), []):
                if cat.compose.get((f, h)) != cat.compose.get((g, h)):
                    separated = True
                    break
            if not separated:
                new_remaining.append((x, y, f, g))
        remaining = new_remaining

    return len(probe), probe


if __name__ == "__main__":
    from demo import (parallel_arrows_category, discrete_category,
                       total_order_category, z2_monoid, z3_monoid)

    print("Algorithms for Categorical Compression Number")
    print("=" * 55)

    cats = [
        discrete_category(3),
        parallel_arrows_category(2),
        parallel_arrows_category(4),
        total_order_category(4),
        z2_monoid(),
        z3_monoid(),
    ]

    for cat in cats:
        kappa, witness = compression_number_bruteforce(cat)
        greedy_k, greedy_w = greedy_separating_family(cat)
        profile = separation_profile(cat)
        mono_ok = monotonicity_check(cat)
        minimals = all_minimal_separating_families(cat)

        print(f"\n  {cat.name}")
        print(f"    κ(exact)  = {kappa}, witness = {witness}")
        print(f"    κ(greedy) = {greedy_k}, witness = {greedy_w}")
        print(f"    Monotonicity check: {'PASS' if mono_ok else 'FAIL'}")
        print(f"    Minimal families: {minimals}")
        print(f"    Separation profile: {profile}")
