#!/usr/bin/env python3
"""
Algorithms for Matroid Minor Theory

Type-hinted implementations of the key algorithms from the formalized theory.
"""

from typing import Dict, List, Set, Tuple, Optional, Callable
from dataclasses import dataclass


@dataclass
class MatroidMinorSystem:
    """An abstract matroid minor system."""
    elements: List[str]
    is_minor: Callable[[str, str], bool]
    size: Callable[[str], int]


@dataclass
class ObstructionSpectrum:
    """The obstruction spectrum for a minor-closed class."""
    spectrum: Dict[int, int]  # rank -> count of excluded minors
    total: int
    max_rank: int
    width: int


def compute_obstruction_spectrum(
    excluded_minors: List[str],
    rank_fn: Callable[[str], int]
) -> ObstructionSpectrum:
    """Compute the obstruction spectrum from a list of excluded minors.
    
    Algorithm:
    1. For each excluded minor, compute its rank
    2. Group by rank and count
    3. Compute total, max_rank, width
    
    Time complexity: O(n) where n = |excluded_minors|
    Space complexity: O(max_rank)
    """
    spectrum: Dict[int, int] = {}
    for m in excluded_minors:
        r = rank_fn(m)
        spectrum[r] = spectrum.get(r, 0) + 1
    
    total = len(excluded_minors)
    max_rank = max(spectrum.keys(), default=0)
    width = sum(1 for c in spectrum.values() if c > 0)
    
    return ObstructionSpectrum(spectrum, total, max_rank, width)


def verify_antichain(
    candidates: List[str],
    is_minor: Callable[[str, str], bool]
) -> bool:
    """Verify that a set of matroids forms an antichain under the minor relation.
    
    Algorithm:
    For all pairs (M_i, M_j) with i ≠ j, check that neither is a minor of the other.
    
    Time complexity: O(n² · T_minor) where T_minor is the cost of the minor test
    """
    n = len(candidates)
    for i in range(n):
        for j in range(n):
            if i != j and is_minor(candidates[i], candidates[j]):
                return False
    return True


def find_excluded_minors(
    system: MatroidMinorSystem,
    property_fn: Callable[[str], bool],
    is_minor_closed: bool = True
) -> List[str]:
    """Find excluded minors for a minor-closed property.
    
    Algorithm (exhaustive search on finite systems):
    1. Sort elements by size (ascending)
    2. For each element M not satisfying P:
       a. Check if all proper minors of M satisfy P
       b. If so, M is an excluded minor
    
    This implements the constructive version of `contains_excluded_minor`.
    
    Time complexity: O(n² · T_minor · T_property)
    """
    # Sort by size for efficiency (smaller elements first)
    sorted_elements = sorted(system.elements, key=system.size)
    
    excluded: List[str] = []
    
    for m in sorted_elements:
        if not property_fn(m):
            # Check if all proper minors satisfy the property
            all_proper_minors_satisfy = True
            for m_prime in sorted_elements:
                if m_prime != m and system.is_minor(m_prime, m):
                    if not property_fn(m_prime):
                        all_proper_minors_satisfy = False
                        break
            
            if all_proper_minors_satisfy:
                excluded.append(m)
    
    return excluded


def spectral_duality_check(
    primal_spectrum: Dict[int, int],
    dual_spectrum: Dict[int, int],
    max_ground_rank: int
) -> Tuple[bool, List[int]]:
    """Check if primal and dual spectra form a valid duality pair.
    
    Returns (is_valid, mismatched_ranks).
    
    A valid duality pair satisfies:
    primal[r] = dual[max_ground_rank - r] for all r ≤ max_ground_rank
    """
    mismatched: List[int] = []
    
    for r in range(max_ground_rank + 1):
        p = primal_spectrum.get(r, 0)
        d = dual_spectrum.get(max_ground_rank - r, 0)
        if p != d:
            mismatched.append(r)
    
    return (len(mismatched) == 0, mismatched)


def growth_rate_classifier(
    max_elements_by_rank: Dict[int, int]
) -> str:
    """Classify the growth rate of a matroid class.
    
    Returns: 'linear', 'quadratic', 'exponential', or 'unknown'
    
    The Growth Rate Theorem (Geelen-Kung-Whittle) states that
    for any minor-closed class, the growth rate function is either:
    - Linear (like graphic matroids on surfaces)
    - Quadratic (like GF(q)-representable for some q)
    - Exponential (base q for some prime power q)
    """
    if not max_elements_by_rank:
        return 'unknown'
    
    ranks = sorted(max_elements_by_rank.keys())
    if len(ranks) < 3:
        return 'unknown'
    
    # Check ratios
    ratios_quad = []
    ratios_exp = []
    
    for i in range(1, len(ranks)):
        r = ranks[i]
        r_prev = ranks[i-1]
        n = max_elements_by_rank[r]
        n_prev = max_elements_by_rank[r_prev]
        
        if r > 0 and r_prev > 0:
            # Quadratic growth: n ≈ c·r²
            if n_prev > 0:
                ratios_quad.append(n / (r * r) if r > 0 else 0)
                ratios_exp.append(n / n_prev if n_prev > 0 else 0)
    
    # Check if quadratic ratios are roughly constant
    if ratios_quad and max(ratios_quad) / max(min(ratios_quad), 0.01) < 2:
        return 'quadratic'
    
    # Check if exponential ratios are roughly constant
    if ratios_exp and max(ratios_exp) / max(min(ratios_exp), 0.01) < 1.5:
        return 'exponential'
    
    # Check linearity
    ratios_lin = [max_elements_by_rank[r] / r for r in ranks if r > 0]
    if ratios_lin and max(ratios_lin) / max(min(ratios_lin), 0.01) < 2:
        return 'linear'
    
    return 'unknown'


def wqo_test_sequence(
    sequence: List[str],
    is_minor: Callable[[str, str], bool],
    max_check: int = 1000
) -> Optional[Tuple[int, int]]:
    """Test if a finite sequence witnesses WQO by finding i < j with M_i ≤ M_j.
    
    Returns the first (i, j) pair found, or None if no such pair exists
    within the search limit.
    
    This is a computational test for the WQO property on finite sequences.
    """
    n = min(len(sequence), max_check)
    for i in range(n):
        for j in range(i + 1, n):
            if is_minor(sequence[i], sequence[j]):
                return (i, j)
    return None


if __name__ == "__main__":
    # Example: classify growth rates
    print("Growth Rate Classification:")
    
    # GF(2)-representable (graphs): quadratic growth
    gf2 = {r: r * (r - 1) // 2 + r for r in range(1, 10)}
    print(f"  GF(2): {growth_rate_classifier(gf2)}")
    
    # GF(3)-representable: quadratic growth with factor ~3/2
    gf3 = {r: 3 * r * (r - 1) // 2 + r for r in range(1, 10)}
    print(f"  GF(3): {growth_rate_classifier(gf3)}")
    
    # Example: compute spectrum
    print("\nObstruction Spectrum for planar graphs:")
    spec = compute_obstruction_spectrum(
        ["K_5", "K_{3,3}"],
        lambda m: 4  # both have matroid rank 4
    )
    print(f"  {spec}")
    
    # Example: duality check
    print("\nDuality Check for ternary matroids:")
    valid, mismatches = spectral_duality_check(
        {2: 1, 3: 2, 4: 1},
        {2: 1, 3: 2, 4: 1},
        max_ground_rank=5
    )
    print(f"  Valid duality pair: {valid}")
    if not valid:
        print(f"  Mismatched ranks: {mismatches}")
