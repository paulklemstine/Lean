#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Gap Spectrum Analysis

Type-hinted implementations of the core algorithms used in the
Gap Spectrum theory of ordered continua.
"""

from fractions import Fraction
from typing import List, Tuple, Optional, Set, Dict
from dataclasses import dataclass
import math


@dataclass
class DedekindGap:
    """A Dedekind gap in a finite ordered set, specified by its position."""
    lower_bound: float  # sup of lower cut
    upper_bound: float  # inf of upper cut
    
    @property
    def width(self) -> float:
        return self.upper_bound - self.lower_bound
    
    def contains(self, x: float) -> bool:
        """Check if x falls in this gap."""
        return self.lower_bound < x < self.upper_bound


@dataclass
class GapSpectrum:
    """The gap spectrum of a finite ordered set."""
    gaps: List[DedekindGap]
    total_points: int
    
    @property
    def gap_count(self) -> int:
        return len(self.gaps)
    
    @property
    def gap_density(self) -> float:
        """Ratio of gaps to intervals between consecutive points."""
        if self.total_points <= 1:
            return 0.0
        return self.gap_count / (self.total_points - 1)
    
    def is_gap_free(self) -> bool:
        return self.gap_count == 0


def dyadic_approximation(n: int) -> List[Fraction]:
    """
    Generate the day-n dyadic approximation to surreal numbers.
    
    Returns sorted list of {k/2^n : |k| ≤ 2^n}.
    
    Complexity: O(2^n log 2^n) = O(n · 2^n)
    """
    denom: int = 2 ** n
    return sorted([Fraction(k, denom) for k in range(-denom, denom + 1)])


def compute_gap_spectrum(
    points: List[Fraction],
    test_irrationals: List[float]
) -> GapSpectrum:
    """
    Compute the gap spectrum of a finite ordered set.
    
    Algorithm:
    1. Sort points (assumed sorted)
    2. For each consecutive pair (a, b), check if any test irrational falls in (a, b)
    3. Each such interval with an irrational is a gap
    
    Complexity: O(n · m) where n = |points|, m = |test_irrationals|
    """
    gaps: List[DedekindGap] = []
    for i in range(len(points) - 1):
        a, b = float(points[i]), float(points[i + 1])
        for x in test_irrationals:
            if a < x < b:
                gaps.append(DedekindGap(lower_bound=a, upper_bound=b))
                break
    return GapSpectrum(gaps=gaps, total_points=len(points))


def connected_components_ordered(
    points: List[Fraction],
    gaps: GapSpectrum
) -> List[List[Fraction]]:
    """
    Compute connected components of an ordered set given its gap spectrum.
    
    Two points are in the same component iff no gap separates them.
    
    Complexity: O(n · g) where n = |points|, g = |gaps|
    """
    if not points:
        return []
    
    gap_positions: List[Tuple[float, float]] = [
        (g.lower_bound, g.upper_bound) for g in gaps.gaps
    ]
    
    components: List[List[Fraction]] = [[points[0]]]
    for i in range(1, len(points)):
        a, b = float(points[i - 1]), float(points[i])
        separated = any(a <= lb and ub <= b for lb, ub in gap_positions)
        if separated:
            components.append([points[i]])
        else:
            components[-1].append(points[i])
    return components


def contraction_homotopy(
    x: float,
    t: float
) -> float:
    """
    The contraction homotopy H(x, t) = x · (1 - t).
    
    At t=0: H(x, 0) = x (identity)
    At t=1: H(x, 1) = 0 (constant map to zero)
    
    This demonstrates contractibility of ℝ and surreal-like completions.
    """
    return x * (1.0 - t)


def halving_contraction(
    x: Fraction,
    steps: int
) -> List[Fraction]:
    """
    Discrete contraction via repeated halving: x, x/2, x/4, ..., x/2^steps.
    
    This is a discrete approximation to the continuous contraction homotopy.
    Converges to 0 as steps → ∞.
    """
    return [x / (2 ** k) for k in range(steps + 1)]


def gap_free_check(
    points: List[Fraction],
    epsilon: float = 1e-10
) -> bool:
    """
    Check if a finite ordered set is "approximately gap-free" 
    by verifying no consecutive pair has a gap larger than epsilon.
    
    For a truly gap-free (complete) order, gaps can only appear between
    points, never within them.
    """
    for i in range(len(points) - 1):
        if float(points[i + 1] - points[i]) > epsilon:
            return False
    return True


def order_isomorphism_map(
    points: List[Fraction],
    f: callable
) -> List[Fraction]:
    """
    Apply an order-preserving map to a finite ordered set.
    
    Theorem (proved in Lean): order isomorphisms preserve gap-freeness.
    """
    return sorted([f(x) for x in points])


def convex_open_basis_check(
    interval: Tuple[Fraction, Fraction],
    points: List[Fraction]
) -> bool:
    """
    Check if an open interval (a, b) is in the convex open basis.
    
    An interval is convex-open iff it is both open and order-convex.
    Open intervals are always convex-open (proved in Lean as Ioo_mem_convexOpenBasis).
    """
    a, b = interval
    return a < b  # Open intervals (a, b) with a < b are always in the basis


def archimedean_embedding_rational(q: Fraction) -> float:
    """
    The canonical embedding ℚ → ℝ.
    
    Theorem (proved in Lean): Every Archimedean ordered field embeds
    into ℝ via a strict order-preserving ring homomorphism.
    """
    return float(q)


if __name__ == "__main__":
    # Quick test
    day3 = dyadic_approximation(3)
    sqrt2 = math.sqrt(2)
    spectrum = compute_gap_spectrum(day3, [sqrt2, -sqrt2])
    print(f"Day 3: {spectrum.total_points} points, {spectrum.gap_count} gaps")
    print(f"Gap-free: {spectrum.is_gap_free()}")
    print(f"Gap density: {spectrum.gap_density:.3f}")
    
    comps = connected_components_ordered(day3, spectrum)
    print(f"Connected components: {len(comps)}")
    
    # Test contraction
    path = halving_contraction(Fraction(3, 1), 5)
    print(f"Contraction of 3: {[float(x) for x in path]}")
