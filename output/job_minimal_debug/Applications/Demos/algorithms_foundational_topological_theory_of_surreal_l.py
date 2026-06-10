#!/usr/bin/env python3
"""
Algorithms for Cofinality Spectrum Analysis

Type-hinted implementations of the core algorithms from the
surreal topology research.
"""

from typing import List, Tuple, Optional, Callable, Set, Dict
from enum import Enum
from dataclasses import dataclass
import math


class CofinalityClass(Enum):
    """Classification of a point by its cofinality type."""
    TAME = "tame"
    WILD_LEFT = "wild_left"
    WILD_RIGHT = "wild_right"
    WILD_BOTH = "wild_both"


@dataclass
class OrderGap:
    """
    Represents an order gap: a partition into lower and upper sets
    where lower has no max and upper has no min.
    """
    lower_bound: float  # supremum of lower set (not achieved)
    lower_witness: float  # an element in the lower set
    upper_witness: float  # an element in the upper set
    
    def contains_in_lower(self, x: float) -> bool:
        return x < self.lower_bound
    
    def contains_in_upper(self, x: float) -> bool:
        return x > self.lower_bound


@dataclass
class CofinalSequence:
    """A sequence cofinal in a set, with bound information."""
    terms: List[float]
    target: float
    is_cofinal: bool
    gap: float  # distance from sup(terms) to target


def classify_cofinality(
    x: float,
    left_oracle: Callable[[float], Optional[List[float]]],
    right_oracle: Callable[[float], Optional[List[float]]]
) -> CofinalityClass:
    """
    Classify the cofinality type of a point x.
    
    Args:
        x: the point to classify
        left_oracle: given x, returns a countable cofinal sequence below x,
                     or None if no such sequence exists
        right_oracle: given x, returns a countable coinitial sequence above x,
                      or None if no such sequence exists
    
    Returns:
        The cofinality class of x
    """
    left_cofinal = left_oracle(x)
    right_cofinal = right_oracle(x)
    
    has_left = left_cofinal is not None
    has_right = right_cofinal is not None
    
    if has_left and has_right:
        return CofinalityClass.TAME
    elif has_left and not has_right:
        return CofinalityClass.WILD_RIGHT
    elif not has_left and has_right:
        return CofinalityClass.WILD_LEFT
    else:
        return CofinalityClass.WILD_BOTH


def construct_cofinal_sequence(
    x: float,
    elements_below: List[float],
    max_terms: int = 100
) -> CofinalSequence:
    """
    Attempt to construct a cofinal sequence below x from a given set of elements.
    
    The sequence is constructed greedily: at each step, pick the element
    closest to x that hasn't been used yet.
    
    Args:
        x: target point
        elements_below: available elements strictly below x
        max_terms: maximum number of terms to use
    
    Returns:
        CofinalSequence with the constructed sequence and metadata
    """
    below = sorted([e for e in elements_below if e < x])
    if not below:
        return CofinalSequence(terms=[], target=x, is_cofinal=False, gap=float('inf'))
    
    # Take the top max_terms elements (closest to x)
    terms = below[-max_terms:]
    sup = max(terms)
    gap = x - sup
    
    # Check cofinality: is every element below x bounded by some term?
    is_cofinal = all(any(e <= t for t in terms) for e in below)
    
    return CofinalSequence(
        terms=terms,
        target=x,
        is_cofinal=is_cofinal,
        gap=gap
    )


def detect_order_gaps(
    elements: List[float],
    min_gap_ratio: float = 2.0
) -> List[OrderGap]:
    """
    Detect order gaps in a discrete sample of a linear order.
    
    A gap is detected where the distance between consecutive elements
    is significantly larger than the local average spacing.
    
    Args:
        elements: sorted list of elements from the order
        min_gap_ratio: minimum ratio of gap size to average spacing
                       to qualify as a gap
    
    Returns:
        List of detected OrderGap structures
    """
    if len(elements) < 3:
        return []
    
    sorted_elts = sorted(elements)
    spacings = [sorted_elts[i+1] - sorted_elts[i] for i in range(len(sorted_elts) - 1)]
    avg_spacing = sum(spacings) / len(spacings)
    
    gaps = []
    for i, spacing in enumerate(spacings):
        if avg_spacing > 0 and spacing / avg_spacing >= min_gap_ratio:
            gap_point = (sorted_elts[i] + sorted_elts[i+1]) / 2
            gaps.append(OrderGap(
                lower_bound=gap_point,
                lower_witness=sorted_elts[i],
                upper_witness=sorted_elts[i+1]
            ))
    
    return gaps


def p_filter_intersection(
    x: float,
    neighborhoods: List[Tuple[float, float]],
    is_wild_left: bool = False
) -> Optional[Tuple[float, float]]:
    """
    Compute the intersection behavior of a countable family of neighborhoods.
    
    For tame points: the intersection may collapse to {x}.
    For wild points: the intersection remains a neighborhood (P-filter property).
    
    The P-filter property states: if x has uncountable left cofinality,
    then for any countable family (U_n) of neighborhoods of x, there exists
    b < x such that (b, x) ⊆ ∩_n U_n.
    
    Args:
        x: the point
        neighborhoods: list of (left, right) interval endpoints
        is_wild_left: whether x has uncountable left cofinality
    
    Returns:
        The intersection interval, or None if it collapses
    """
    if not neighborhoods:
        return None
    
    left_endpoints = [a for a, _ in neighborhoods]
    right_endpoints = [b for _, b in neighborhoods]
    
    # The intersection of intervals (a_n, b_n) is (sup a_n, inf b_n)
    sup_left = max(left_endpoints)
    inf_right = min(right_endpoints)
    
    if is_wild_left:
        # P-filter property: left endpoints are bounded away from x
        # In a wild point, no countable set of left endpoints can be cofinal
        # So sup(left_endpoints) < x strictly, with room to spare
        if sup_left < x < inf_right:
            return (sup_left, inf_right)
        else:
            return None
    else:
        # Tame: intersection might be very thin or empty
        if sup_left < x < inf_right:
            return (sup_left, inf_right)
        else:
            return None


def cofinality_spectrum(
    elements: List[float],
    left_oracle: Callable[[float], Optional[List[float]]],
    right_oracle: Callable[[float], Optional[List[float]]]
) -> Dict[CofinalityClass, List[float]]:
    """
    Compute the cofinality spectrum of a set of elements.
    
    Returns a dictionary mapping each cofinality class to the list
    of elements with that classification.
    """
    spectrum: Dict[CofinalityClass, List[float]] = {
        cls: [] for cls in CofinalityClass
    }
    
    for x in elements:
        cls = classify_cofinality(x, left_oracle, right_oracle)
        spectrum[cls].append(x)
    
    return spectrum


def neighborhood_basis_size(
    x: float,
    cofinal_below: Optional[List[float]],
    coinitial_above: Optional[List[float]]
) -> Optional[int]:
    """
    Compute the size of the minimal countable neighborhood basis at x.
    
    If x is tame (has cofinal sequence below and coinitial above),
    the basis consists of intervals Ioo(s_n, t_m) for n, m in N,
    giving basis size |S| × |T|.
    
    If x is wild, no countable basis exists (returns None).
    """
    if cofinal_below is None or coinitial_above is None:
        return None  # Wild point: no countable basis
    
    # Tame point: basis size is |cofinal| × |coinitial|
    return len(cofinal_below) * len(coinitial_above)


def verify_gap_disconnection(
    elements: List[float],
    gap: OrderGap
) -> Tuple[List[float], List[float], bool]:
    """
    Verify the Order Gap Disconnection Theorem computationally.
    
    Given an order gap, partition the elements into lower and upper sets
    and verify they are "clopen" (no element of one set is a limit of
    elements of the other).
    
    Returns:
        (lower_elements, upper_elements, is_disconnected)
    """
    lower = [x for x in elements if gap.contains_in_lower(x)]
    upper = [x for x in elements if gap.contains_in_upper(x)]
    
    # Check disconnection: no element of lower is arbitrarily close to upper
    if lower and upper:
        max_lower = max(lower)
        min_upper = min(upper)
        gap_size = min_upper - max_lower
        is_disconnected = gap_size > 0
    else:
        is_disconnected = bool(lower) != bool(upper)
    
    return lower, upper, is_disconnected


# --- Main demonstration ---

if __name__ == "__main__":
    # Real number oracle: always returns cofinal sequences
    def real_left_oracle(x: float) -> Optional[List[float]]:
        if x == float('-inf'):
            return None
        return [x - 1.0 / (n + 1) for n in range(100)]
    
    def real_right_oracle(x: float) -> Optional[List[float]]:
        if x == float('inf'):
            return None
        return [x + 1.0 / (n + 1) for n in range(100)]
    
    # Classify some real numbers
    print("Cofinality classification of real numbers:")
    for x in [0.0, 1.0, math.pi, math.e, -5.0]:
        cls = classify_cofinality(x, real_left_oracle, real_right_oracle)
        print(f"  x = {x:8.4f}: {cls.value}")
    
    # Detect gaps in rationals near sqrt(2)
    print("\nGap detection near √2:")
    rationals = [p/q for q in range(1, 20) for p in range(1, 40)
                 if abs(p/q - math.sqrt(2)) < 0.5]
    rationals = sorted(set(rationals))
    gaps = detect_order_gaps(rationals, min_gap_ratio=3.0)
    print(f"  {len(rationals)} rationals sampled, {len(gaps)} gaps detected")
    
    # P-filter demonstration
    print("\nP-filter property demonstration:")
    x = 5.0
    nbhds = [(x - 1.0/(n+1), x + 1.0/(n+1)) for n in range(20)]
    result = p_filter_intersection(x, nbhds, is_wild_left=False)
    print(f"  Tame point: intersection = {result}")
    if result:
        print(f"  Width = {result[1] - result[0]:.6f} (shrinks toward 0)")
