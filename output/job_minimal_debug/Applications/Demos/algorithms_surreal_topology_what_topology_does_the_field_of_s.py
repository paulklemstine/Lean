#!/usr/bin/env python3
"""
Algorithms for Surreal Topology

Type-hinted implementations of the core algorithms used in the
surreal topology research, including gap detection, connected
component computation, and Dedekind cut classification.
"""

from fractions import Fraction
from typing import Optional
from dataclasses import dataclass


@dataclass
class DedekindGap:
    """A Dedekind gap in a finite ordered set: a point where
    the gap between consecutive elements is maximal."""
    left_endpoint: float
    right_endpoint: float
    gap_size: float
    position: float  # midpoint of the gap


@dataclass
class ConnectedComponent:
    """An approximate connected component of a finite point set."""
    points: list[float]
    left: float
    right: float
    size: int


def detect_gaps(
    points: list[float],
    threshold: Optional[float] = None
) -> list[DedekindGap]:
    """Detect Dedekind gaps in a finite ordered set.
    
    A gap is a pair of consecutive points (a, b) where b - a exceeds
    the threshold. If no threshold is given, uses the mean gap size.
    
    Args:
        points: A sorted list of distinct real numbers.
        threshold: Minimum gap size to report. Defaults to mean gap.
        
    Returns:
        List of DedekindGap objects, sorted by gap size (largest first).
        
    Complexity: O(n log n) for sorting, O(n) for gap detection.
    """
    if len(points) < 2:
        return []
    
    sorted_pts = sorted(set(points))
    
    if threshold is None:
        total_span = sorted_pts[-1] - sorted_pts[0]
        threshold = total_span / (2 * len(sorted_pts))
    
    gaps: list[DedekindGap] = []
    for i in range(len(sorted_pts) - 1):
        gap_size = sorted_pts[i + 1] - sorted_pts[i]
        if gap_size > threshold:
            gaps.append(DedekindGap(
                left_endpoint=sorted_pts[i],
                right_endpoint=sorted_pts[i + 1],
                gap_size=gap_size,
                position=(sorted_pts[i] + sorted_pts[i + 1]) / 2
            ))
    
    return sorted(gaps, key=lambda g: -g.gap_size)


def connected_components(
    points: list[float],
    epsilon: float
) -> list[ConnectedComponent]:
    """Compute ε-connected components of a finite point set.
    
    Two points are ε-connected if there is a chain of points
    between them where consecutive points are within ε of each other.
    
    Args:
        points: A list of real numbers.
        epsilon: The connectivity threshold.
        
    Returns:
        List of ConnectedComponent objects.
        
    Complexity: O(n log n) for sorting, O(n) for component detection.
    """
    if not points:
        return []
    
    sorted_pts = sorted(set(points))
    components: list[ConnectedComponent] = []
    current: list[float] = [sorted_pts[0]]
    
    for p in sorted_pts[1:]:
        if p - current[-1] <= epsilon:
            current.append(p)
        else:
            components.append(ConnectedComponent(
                points=current,
                left=current[0],
                right=current[-1],
                size=len(current)
            ))
            current = [p]
    
    components.append(ConnectedComponent(
        points=current,
        left=current[0],
        right=current[-1],
        size=len(current)
    ))
    
    return components


def contraction_path(
    x: float,
    steps: int = 100
) -> list[tuple[float, float]]:
    """Compute the contraction path from x to 0.
    
    Uses the homotopy H(x, t) = (1-t)·x for t ∈ [0, 1].
    
    Args:
        x: Starting point.
        steps: Number of interpolation steps.
        
    Returns:
        List of (t, H(x,t)) pairs.
    """
    return [(t / steps, (1 - t / steps) * x) for t in range(steps + 1)]


def dyadic_approximation(
    n: int,
    interval: tuple[float, float] = (-1.0, 1.0)
) -> list[Fraction]:
    """Generate day-n dyadic rational approximation to an interval.
    
    Produces all numbers of the form k/2^n that lie in the interval.
    These are the surreal numbers "born on day n" (approximately).
    
    Args:
        n: The day number (precision level).
        interval: The interval to approximate.
        
    Returns:
        Sorted list of Fraction objects.
    """
    denom = 2**n
    lo = int(interval[0] * denom)
    hi = int(interval[1] * denom)
    return sorted(Fraction(k, denom) for k in range(lo, hi + 1))


def gap_density_profile(
    points: list[float],
    bins: int = 50
) -> list[tuple[float, float]]:
    """Compute the gap density profile of a finite ordered set.
    
    Returns (position, gap_size) pairs showing how gaps are distributed.
    Higher values indicate potential Dedekind gaps in the limit.
    
    Args:
        points: Sorted list of distinct real numbers.
        bins: Number of bins for the profile.
        
    Returns:
        List of (position, gap_density) pairs.
    """
    if len(points) < 2:
        return []
    
    sorted_pts = sorted(set(points))
    lo, hi = sorted_pts[0], sorted_pts[-1]
    bin_width = (hi - lo) / bins
    
    profile: list[tuple[float, float]] = []
    for b in range(bins):
        bin_lo = lo + b * bin_width
        bin_hi = lo + (b + 1) * bin_width
        bin_center = (bin_lo + bin_hi) / 2
        
        # Find max gap in this bin
        max_gap = 0.0
        for i in range(len(sorted_pts) - 1):
            if sorted_pts[i] >= bin_lo and sorted_pts[i + 1] <= bin_hi:
                max_gap = max(max_gap, sorted_pts[i + 1] - sorted_pts[i])
        
        profile.append((bin_center, max_gap))
    
    return profile


def classify_order_type(
    points: list[float],
    epsilon: float = 1e-6
) -> str:
    """Classify the topology type of a finite ordered set.
    
    Returns one of:
    - "singleton": single point
    - "discrete": all gaps exceed threshold
    - "cluster": some clusters with gaps between them
    - "quasi-connected": appears connected at given resolution
    
    Args:
        points: A list of real numbers.
        epsilon: Resolution threshold.
        
    Returns:
        Classification string.
    """
    if len(points) <= 1:
        return "singleton"
    
    sorted_pts = sorted(set(points))
    gaps = [sorted_pts[i + 1] - sorted_pts[i] for i in range(len(sorted_pts) - 1)]
    
    min_gap = min(gaps)
    max_gap = max(gaps)
    mean_gap = sum(gaps) / len(gaps)
    
    if min_gap > epsilon:
        if max_gap / min_gap < 2:
            return "discrete"
        else:
            return "cluster"
    else:
        return "quasi-connected"


if __name__ == "__main__":
    # Demo
    import math
    
    # Detect gaps in rationals near √2
    rats = sorted(set(p / q for q in range(1, 50) for p in range(1, 2 * q)))
    rats_near_sqrt2 = [r for r in rats if 1.3 < r < 1.5]
    gaps = detect_gaps(rats_near_sqrt2)
    print("Gaps in rationals near √2:")
    for g in gaps[:3]:
        print(f"  ({g.left_endpoint:.4f}, {g.right_endpoint:.4f}), "
              f"size={g.gap_size:.6f}, position={g.position:.4f}")
    print(f"  √2 ≈ {math.sqrt(2):.4f}")
    
    # Connected components
    print("\nConnected components at various ε:")
    test_points = [float(Fraction(p, q)) for q in range(1, 20) 
                   for p in range(1, q) if math.gcd(p, q) == 1]
    test_points = [p for p in test_points if 0 < p < 1]
    for eps in [0.001, 0.01, 0.05, 0.1]:
        comps = connected_components(test_points, eps)
        print(f"  ε={eps}: {len(comps)} components")
    
    # Classification
    print(f"\nOrder type classification: {classify_order_type(test_points)}")
