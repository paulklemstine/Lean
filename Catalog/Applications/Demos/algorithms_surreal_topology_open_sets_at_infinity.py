#!/usr/bin/env python3
"""
Algorithms for Surreal Topology Computations

Type-hinted implementations of key algorithms from the surreal topology research.
"""

from fractions import Fraction
from typing import List, Tuple, Set, Optional, Callable
import math


def bounded_day_dyadics(n: int) -> List[Fraction]:
    """
    Compute all surreal numbers born on or before day n (restricted to dyadics).
    
    Day n surreals include rationals k/2^n for |k| ≤ 2^n.
    
    Args:
        n: The day number (non-negative integer)
    
    Returns:
        Sorted list of dyadic rationals born by day n
    """
    result: Set[Fraction] = set()
    bound = 2 ** n
    denom = 2 ** n
    for k in range(-bound, bound + 1):
        result.add(Fraction(k, denom))
    return sorted(result)


def open_set_extension(
    embedding: Callable[[Fraction], float],
    open_set: Callable[[Fraction], bool],
    test_point: float,
    search_depth: int = 10
) -> bool:
    """
    Check if a point lies in the open set extension through an order embedding.
    
    Given ι: ℚ ↪ ℝ (the standard embedding) and an open set U ⊆ ℚ,
    the extension is ⋃ {(ι(a), ι(b)) | Ioo(a,b) ⊆ U, a < b}.
    
    Args:
        embedding: Order embedding function ι: ℚ → ℝ
        open_set: Characteristic function of the open set U ⊆ ℚ
        test_point: Point to test membership in the extension
        search_depth: Denominator bound for rational search
    
    Returns:
        True if we found a covering interval (may return False even if covered,
        due to finite search)
    """
    # Search for rational interval (a, b) with Ioo(a,b) ⊆ U and ι(a) < test_point < ι(b)
    denom = 2 ** search_depth
    for k_a in range(-denom, denom):
        a = Fraction(k_a, denom)
        if embedding(a) >= test_point:
            continue
        for k_b in range(k_a + 1, denom + 1):
            b = Fraction(k_b, denom)
            if embedding(b) <= test_point:
                continue
            # Check if Ioo(a, b) ⊆ U (sample check)
            all_in = True
            for k_mid in range(k_a + 1, k_b):
                mid = Fraction(k_mid, denom)
                if not open_set(mid):
                    all_in = False
                    break
            if all_in:
                return True
    return False


def cofinality_gap_witness(
    sequence: List[float],
    lower_bound: float
) -> Optional[float]:
    """
    Find a gap witness between a lower bound and a sequence.
    
    Given x (lower_bound) and sequence f with x < f(n),
    find y with x < y < f(n) for all n.
    
    Args:
        sequence: List of values all above lower_bound
        lower_bound: The point x
    
    Returns:
        A gap witness y, or None if sequence is empty
    """
    if not sequence:
        return None
    
    min_val = min(sequence)
    if min_val <= lower_bound:
        return None
    
    # Midpoint between lower_bound and minimum
    return (lower_bound + min_val) / 2


def detect_disconnection(
    points: List[float],
    gap_test: Callable[[float], bool]
) -> Tuple[List[float], List[float]]:
    """
    Detect a disconnection in an ordered set via a gap.
    
    Given an ordered set of points and a gap predicate (True = above gap),
    partition the points into lower and upper components.
    
    Args:
        points: Sorted list of points in the ordered set
        gap_test: Returns True if a point is above the gap
    
    Returns:
        Tuple of (lower_component, upper_component)
    """
    lower = [p for p in points if not gap_test(p)]
    upper = [p for p in points if gap_test(p)]
    return lower, upper


def long_line_cover_refinement(
    n_ordinals: int,
    interval_count: int = 10,
    overlap: float = 0.1
) -> Tuple[int, int]:
    """
    Compute cover refinement statistics for finite approximation to long line.
    
    Approximates n × [0,1) with lexicographic order and computes:
    - Number of open sets in a standard cover
    - Estimate of minimum locally finite refinement size
    
    Args:
        n_ordinals: Number of ordinal copies (approximating ω₁)
        interval_count: Number of intervals per [0,1) copy
        overlap: Fractional overlap between adjacent intervals
    
    Returns:
        Tuple of (cover_size, estimated_refinement_size)
    """
    # Standard cover: overlapping intervals in each copy of [0,1)
    # plus "transition" intervals at ordinal boundaries
    cover_size = n_ordinals * interval_count + (n_ordinals - 1)
    
    # At limit ordinals (simulated), the cofinality creates refinement issues
    # Each predecessor ordinal's intervals need to be coordinated
    # Estimated refinement grows as n * log(n) for finite approximations
    if n_ordinals > 1:
        refinement_size = int(n_ordinals * math.log2(n_ordinals) * interval_count)
    else:
        refinement_size = interval_count
    
    return cover_size, refinement_size


def dyadic_density_at_scale(n: int, interval: Tuple[float, float]) -> int:
    """
    Count day-n dyadic surreal numbers in a given interval.
    
    Args:
        n: Day number
        interval: (lower, upper) bounds
    
    Returns:
        Count of day-n dyadics in the interval
    """
    a, b = interval
    count = 0
    denom = 2 ** n
    bound = 2 ** n
    for k in range(-bound, bound + 1):
        val = k / denom
        if a < val < b:
            count += 1
    return count


if __name__ == "__main__":
    # Example: bounded day dyadics
    print("Day 3 dyadics:", [float(x) for x in bounded_day_dyadics(3)])
    print()
    
    # Example: cofinality gap
    seq = [2.0 + 1/n for n in range(1, 6)]
    witness = cofinality_gap_witness(seq, 2.0)
    print(f"Gap witness for sequence approaching 2 from above: {witness}")
    print()
    
    # Example: disconnection detection
    rationals = [i/10 for i in range(-20, 21)]
    sqrt2 = math.sqrt(2)
    lower, upper = detect_disconnection(rationals, lambda x: x > sqrt2)
    print(f"ℚ disconnection at √2: |lower| = {len(lower)}, |upper| = {len(upper)}")
    print()
    
    # Example: long line cover
    for n in [5, 10, 50, 100]:
        cover, refine = long_line_cover_refinement(n)
        print(f"Long line approx n={n}: cover={cover}, refinement≈{refine}")
