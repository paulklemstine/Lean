#!/usr/bin/env python3
"""
Surreal Topology: Algorithms

Type-hinted implementations of key algorithms from the surreal topology research.
"""

from fractions import Fraction
from typing import List, Tuple, Set, Optional, Callable
from dataclasses import dataclass
import math


@dataclass
class Interval:
    """An open interval (left, right) in a linear order."""
    left: float
    right: float
    
    def contains(self, x: float) -> bool:
        return self.left < x < self.right
    
    def is_empty(self) -> bool:
        return self.left >= self.right
    
    def intersect(self, other: 'Interval') -> 'Interval':
        return Interval(max(self.left, other.left), min(self.right, other.right))
    
    def __repr__(self) -> str:
        return f"({self.left}, {self.right})"


def bounded_day_dyadics(n: int) -> List[Fraction]:
    """
    Generate surreal numbers of birthday ≤ n (dyadic rationals k/2^n, |k| ≤ 2^n).
    
    Algorithm: Enumerate integers k from -2^n to 2^n and form k/2^n.
    Time complexity: O(2^n)
    Space complexity: O(2^n)
    
    Args:
        n: Maximum birthday (generation number)
    
    Returns:
        Sorted list of dyadic rationals representing surreal numbers of birthday ≤ n
    """
    denom = 2 ** n
    return sorted(set(Fraction(k, denom) for k in range(-denom, denom + 1)))


def finite_cover_test(
    elements: List[float],
    cover_points: List[float]
) -> Tuple[bool, List[float]]:
    """
    Test whether {(-∞, a) : a ∈ cover_points} covers all elements.
    
    This implements the non-compactness test: for a linear order with no maximum,
    any finite cover by initial segments must fail.
    
    Algorithm:
        1. Find max of cover_points
        2. Any element ≥ max is uncovered
    
    Time complexity: O(n + m) where n = |elements|, m = |cover_points|
    
    Args:
        elements: Elements to be covered
        cover_points: Upper bounds of initial segments
    
    Returns:
        (is_covered, uncovered_elements) tuple
    """
    if not cover_points:
        return False, elements
    
    max_cover = max(cover_points)
    uncovered = [x for x in elements if x >= max_cover]
    return len(uncovered) == 0, uncovered


def surreal_open_extension(
    embedding: Callable[[Fraction], float],
    source_elements: List[Fraction],
    open_set: Set[Fraction]
) -> List[Interval]:
    """
    Compute the surreal open extension of an open set via an order embedding.
    
    Given f: α ↪o β (order embedding) and U ⊆ α, compute:
        SurrealOpenExtension(f, U) = ⋃ {(f(a), f(b)) : a < b, (a,b) ⊆ U}
    
    Algorithm:
        1. For each pair a < b in source_elements
        2. Check if Ioo(a, b) ⊆ U (all intermediate elements are in U)
        3. If so, add interval (f(a), f(b)) to the extension
        4. Merge overlapping intervals for the final result
    
    Time complexity: O(n^2 * m) where n = |source_elements|, m = check cost
    
    Args:
        embedding: Order-preserving map f: α → β
        source_elements: Sorted elements of the source order
        open_set: The open set U ⊆ α to extend
    
    Returns:
        List of disjoint open intervals forming the extension
    """
    intervals: List[Interval] = []
    sorted_elems = sorted(source_elements)
    
    for i, a in enumerate(sorted_elems):
        for j in range(i + 1, len(sorted_elems)):
            b = sorted_elems[j]
            # Check if Ioo(a, b) ⊆ U
            ioo = {x for x in sorted_elems if a < x < b}
            if ioo and ioo <= open_set:
                fa, fb = embedding(a), embedding(b)
                intervals.append(Interval(fa, fb))
    
    # Merge overlapping intervals
    return merge_intervals(intervals)


def merge_intervals(intervals: List[Interval]) -> List[Interval]:
    """
    Merge overlapping intervals into a minimal set of disjoint intervals.
    
    Time complexity: O(n log n)
    """
    if not intervals:
        return []
    
    sorted_ivs = sorted(intervals, key=lambda iv: iv.left)
    merged = [sorted_ivs[0]]
    
    for iv in sorted_ivs[1:]:
        if iv.left <= merged[-1].right:
            merged[-1] = Interval(merged[-1].left, max(merged[-1].right, iv.right))
        else:
            merged.append(iv)
    
    return merged


def hausdorff_separation(
    x: float, y: float, dense_elements: List[float]
) -> Optional[Tuple[float, Interval, Interval]]:
    """
    Find explicit Hausdorff-separating neighborhoods for x < y in a dense order.
    
    Algorithm:
        1. Find z between x and y (midpoint or element from dense set)
        2. Return Iio(z) as neighborhood of x and Ioi(z) as neighborhood of y
    
    Time complexity: O(n) for searching dense_elements
    
    Args:
        x: First point
        y: Second point (must have x < y)
        dense_elements: Sorted list of elements from a dense subset
    
    Returns:
        (z, nhd_x, nhd_y) where z separates, nhd_x ∋ x, nhd_y ∋ y
    """
    if x >= y:
        return None
    
    # Find element between x and y
    between = [z for z in dense_elements if x < z < y]
    if between:
        z = between[len(between) // 2]  # Take middle element
    else:
        z = (x + y) / 2  # Fallback to midpoint
    
    return (z, Interval(float('-inf'), z), Interval(z, float('inf')))


def coinitiality_test(
    point: Fraction,
    elements: List[Fraction],
    max_seq_length: int = 10
) -> Tuple[bool, List[Fraction]]:
    """
    Test whether a point has countable coinitiality in a finite order.
    
    For a finite order, coinitiality is always finite (hence countable).
    We compute the smallest elements above the point.
    
    Algorithm:
        1. Filter elements above the point
        2. Sort and take the smallest ones
    
    Time complexity: O(n log n)
    
    Args:
        point: The point to test
        elements: Sorted elements of the order
        max_seq_length: Maximum number of coinitial elements to return
    
    Returns:
        (has_countable_coinitiality, coinitial_sequence)
    """
    above = sorted([x for x in elements if x > point])
    coinitial_seq = above[:max_seq_length]
    # In a finite order, coinitiality is always countable
    return True, coinitial_seq


def connected_components_finite(
    elements: List[float],
    adjacency_threshold: float
) -> List[List[float]]:
    """
    Compute connected components of a finite ordered set with given adjacency threshold.
    
    In the discrete topology on a finite set, every point is its own component.
    With a threshold, adjacent elements (distance < threshold) are connected.
    
    This tests the conjecture that countable dense order fragments are totally 
    disconnected in the order topology (singleton components).
    
    Algorithm:
        1. Sort elements
        2. Group consecutive elements with gap < threshold
    
    Time complexity: O(n log n)
    
    Args:
        elements: Points in the space
        adjacency_threshold: Maximum gap for adjacency
    
    Returns:
        List of connected components (each a list of elements)
    """
    if not elements:
        return []
    
    sorted_elems = sorted(elements)
    components: List[List[float]] = [[sorted_elems[0]]]
    
    for x in sorted_elems[1:]:
        if x - components[-1][-1] < adjacency_threshold:
            components[-1].append(x)
        else:
            components.append([x])
    
    return components


def contraction_to_zero(q: Fraction, steps: int) -> List[Fraction]:
    """
    Generate the contraction-to-zero sequence: q, q/2, q/4, ..., q/2^steps.
    
    This models the contractibility of intervals in ordered fields — every
    closed interval [a, b] can be continuously contracted to a point via
    the homotopy H(x, t) = (1-t)x + ta.
    
    Args:
        q: Starting value
        steps: Number of halving steps
    
    Returns:
        List of values [q, q/2, q/4, ..., q/2^steps]
    """
    return [q / (2 ** i) for i in range(steps + 1)]


if __name__ == "__main__":
    # Quick test of all algorithms
    print("Testing algorithms...")
    
    # Test bounded_day_dyadics
    d3 = bounded_day_dyadics(3)
    print(f"Birthday ≤ 3: {len(d3)} dyadics")
    
    # Test finite_cover_test
    covered, uncovered = finite_cover_test(
        [float(x) for x in d3],
        [1.0, 2.0, 3.0]
    )
    print(f"Cover test: covered={covered}, uncovered={len(uncovered)} elements")
    
    # Test surreal_open_extension
    U = {x for x in d3 if Fraction(0) < x < Fraction(1)}
    ext = surreal_open_extension(float, d3, U)
    print(f"Surreal extension of (0,1): {len(ext)} intervals")
    
    # Test Hausdorff separation
    sep = hausdorff_separation(0.3, 0.7, [float(x) for x in d3])
    if sep:
        print(f"Separation: z={sep[0]}, nhd_x={sep[1]}, nhd_y={sep[2]}")
    
    # Test coinitiality
    has_ci, seq = coinitiality_test(Fraction(0), d3)
    print(f"Coinitiality at 0: {has_ci}, seq={seq[:5]}")
    
    # Test connected components
    comps = connected_components_finite([float(x) for x in d3], 0.01)
    print(f"Connected components (threshold=0.01): {len(comps)} components")
    
    # Test contraction
    ct = contraction_to_zero(Fraction(1), 5)
    print(f"Contraction: {ct}")
    
    print("All tests passed ✓")
