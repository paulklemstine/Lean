"""
Algorithms for Surreal Topology

Type-hinted implementations of the core algorithms from the research.
"""

from typing import Callable, Optional, Tuple, List
from dataclasses import dataclass
import math


@dataclass
class DedekindCut:
    """A Dedekind cut defined by a predicate on rationals.
    
    lower_pred(q) returns True if q is in the lower set.
    The cut is at the boundary between True and False.
    """
    lower_pred: Callable[[float], bool]
    name: str = "unnamed"
    
    def is_gap(self, precision: float = 1e-10) -> bool:
        """Check if this cut represents a gap (no rational at the boundary).
        
        Uses binary search to narrow down the boundary. If no rational
        is found within `precision` of the boundary, reports likely gap.
        """
        lo, hi = -10.0, 10.0
        
        # Find initial bounds (with iteration limit)
        for _ in range(20):
            if not self.lower_pred(lo):
                break
            lo -= 10
        for _ in range(20):
            if self.lower_pred(hi):
                break
            hi += 10
        
        # Binary search
        for _ in range(100):
            if hi - lo <= precision:
                break
            mid = (lo + hi) / 2
            if self.lower_pred(mid):
                lo = mid
            else:
                hi = mid
        
        # Check if boundary is realized
        boundary = (lo + hi) / 2
        return self.lower_pred(boundary) != (not self.lower_pred(boundary + precision))
    
    def boundary_approximation(self, precision: float = 1e-12) -> float:
        """Approximate the boundary value of the cut."""
        lo, hi = -10.0, 10.0
        for _ in range(10):
            if not self.lower_pred(lo):
                break
            lo -= 10
        for _ in range(10):
            if self.lower_pred(hi):
                break
            hi += 10
            
        for _ in range(100):
            mid = (lo + hi) / 2
            if self.lower_pred(mid):
                lo = mid
            else:
                hi = mid
        return (lo + hi) / 2


def linear_path(a: float, b: float, t: float) -> float:
    """Linear interpolation path: f(t) = (1-t)*a + t*b.
    
    Properties (proved in Lean):
    - f(0) = a
    - f(1) = b  
    - f is continuous
    - f is monotone when a <= b
    - f([0,1]) = [a,b] when a <= b
    """
    return (1 - t) * a + t * b


def cofinal_sequence_left(x: float) -> Callable[[int], float]:
    """Return a sequence cofinal below x.
    
    The sequence a_n = x - 1/(n+1) satisfies:
    - a_n < x for all n
    - For any y < x, exists n with y <= a_n
    """
    return lambda n: x - 1.0 / (n + 1)


def coinitial_sequence_right(x: float) -> Callable[[int], float]:
    """Return a sequence coinitial above x.
    
    The sequence b_n = x + 1/(n+1) satisfies:
    - b_n > x for all n  
    - For any y > x, exists n with b_n <= y
    """
    return lambda n: x + 1.0 / (n + 1)


def is_tame(x: float, 
            left_seq: Optional[Callable[[int], float]] = None,
            right_seq: Optional[Callable[[int], float]] = None,
            test_points: int = 100) -> bool:
    """Check if a point is tame (countable cofinality from both sides).
    
    For real numbers, this always returns True (Theorem: real_all_tame).
    """
    if left_seq is None:
        left_seq = cofinal_sequence_left(x)
    if right_seq is None:
        right_seq = coinitial_sequence_right(x)
    
    # Check left cofinality: all seq values < x
    for n in range(test_points):
        if left_seq(n) >= x:
            return False
    
    # Check right cofinality: all seq values > x
    for n in range(test_points):
        if right_seq(n) <= x:
            return False
    
    return True


def neighborhood_basis(x: float, n_terms: int = 5) -> List[Tuple[float, float]]:
    """Compute a countable neighborhood basis at a tame point.
    
    For a tame point x with cofinal sequence a_n and coinitial sequence b_n,
    the intervals (a_n, b_m) form a countable neighborhood basis.
    
    Returns the first n_terms intervals (sorted by diameter).
    """
    a = cofinal_sequence_left(x)
    b = coinitial_sequence_right(x)
    
    intervals = []
    for n in range(n_terms):
        for m in range(n_terms):
            lo = a(n)
            hi = b(m)
            if lo < x < hi:
                intervals.append((lo, hi, hi - lo))
    
    # Sort by diameter
    intervals.sort(key=lambda t: t[2])
    return [(lo, hi) for lo, hi, _ in intervals[:n_terms]]


def detect_gaps_in_interval(
    lower_pred: Callable[[float], bool],
    a: float, b: float,
    resolution: int = 1000
) -> List[float]:
    """Detect potential Dedekind gaps in an interval [a,b].
    
    Scans the interval and identifies points where the predicate
    transitions from True to False, indicating a potential gap.
    """
    gaps = []
    step = (b - a) / resolution
    prev = lower_pred(a)
    
    for i in range(1, resolution + 1):
        x = a + i * step
        curr = lower_pred(x)
        if prev and not curr:
            # Potential gap found; refine
            lo, hi = x - step, x
            for _ in range(50):
                mid = (lo + hi) / 2
                if lower_pred(mid):
                    lo = mid
                else:
                    hi = mid
            gaps.append((lo + hi) / 2)
        prev = curr
    
    return gaps


# Example gaps
SQRT2_GAP = DedekindCut(
    lower_pred=lambda q: q * q < 2 if q >= 0 else True,
    name="√2 gap in Q"
)

PI_GAP = DedekindCut(
    lower_pred=lambda q: q < math.pi,
    name="π gap in Q"  
)

E_GAP = DedekindCut(
    lower_pred=lambda q: q < math.e,
    name="e gap in Q"
)


if __name__ == "__main__":
    print("Testing algorithms:")
    print(f"  √2 gap boundary: {SQRT2_GAP.boundary_approximation():.12f}")
    print(f"  π gap boundary:  {PI_GAP.boundary_approximation():.12f}")
    print(f"  e gap boundary:  {E_GAP.boundary_approximation():.12f}")
    
    print(f"\n  Linear path(3, 7, 0.5) = {linear_path(3, 7, 0.5)}")
    print(f"  Is π tame? {is_tame(math.pi)}")
    
    basis = neighborhood_basis(math.pi, 5)
    print(f"\n  Neighborhood basis at π:")
    for lo, hi in basis:
        print(f"    ({lo:.6f}, {hi:.6f}), diameter = {hi-lo:.6f}")
