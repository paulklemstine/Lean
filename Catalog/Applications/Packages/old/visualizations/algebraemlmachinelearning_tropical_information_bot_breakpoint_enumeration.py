"""
Tropical Information Bottleneck — Algorithms

Complete implementations of the algorithms from the research paper with
docstrings, type hints, and example usage.
"""

from typing import List, Tuple, Optional
import math


class Observer:
    """A canonical observer factor with capacity and distortion.

    Attributes:
        name: Human-readable identifier.
        capacity: Closure capacity c_i (lower = better compression).
        distortion: Tropical distortion d_i (lower = better fidelity).
    """
    def __init__(self, name: str, capacity: float, distortion: float):
        self.name = name
        self.capacity = capacity
        self.distortion = distortion

    def objective(self, beta: float) -> float:
        """Compute the scalarized objective c_i + β * d_i."""
        return self.capacity + beta * self.distortion

    def __repr__(self) -> str:
        return f"Observer({self.name}, c={self.capacity}, d={self.distortion})"


def bottleneck_value(observers: List[Observer], beta: float) -> Tuple[float, Observer]:
    """Algorithm 1: Compute B(β) = min_i (c_i + β * d_i).

    Args:
        observers: Nonempty list of canonical observer factors.
        beta: Non-negative trade-off parameter.

    Returns:
        Tuple of (B(β), optimal observer).

    Time complexity: O(n) where n = |observers|.
    Space complexity: O(1) beyond input.

    >>> obs = [Observer("A", 1.0, 3.0), Observer("B", 2.0, 1.0)]
    >>> val, opt = bottleneck_value(obs, 1.0)
    >>> val
    3.0
    >>> opt.name
    'B'
    """
    assert len(observers) > 0, "Observer set must be nonempty"
    assert beta >= 0, "β must be non-negative"

    best_obs = observers[0]
    best_val = best_obs.objective(beta)

    for obs in observers[1:]:
        val = obs.objective(beta)
        if val < best_val:
            best_val = val
            best_obs = obs

    return best_val, best_obs


def find_breakpoint(obs_i: Observer, obs_j: Observer) -> Optional[float]:
    """Compute the breakpoint where two observers exchange optimality.

    Solves c_i + β * d_i = c_j + β * d_j for β.
    Returns None if d_i = d_j (parallel lines).

    >>> find_breakpoint(Observer("A", 1.0, 3.0), Observer("B", 3.0, 1.0))
    1.0
    """
    dd = obs_i.distortion - obs_j.distortion
    if abs(dd) < 1e-15:
        return None
    return (obs_j.capacity - obs_i.capacity) / dd


def enumerate_breakpoints(observers: List[Observer]) -> List[Tuple[float, Observer, Observer]]:
    """Algorithm 2: Enumerate all breakpoints of B(β).

    A breakpoint is a β* ≥ 0 where two observers have equal objective value
    and both are on the lower envelope.

    Args:
        observers: List of canonical observer factors.

    Returns:
        Sorted list of (β*, obs_i, obs_j) triples for active breakpoints.

    Time complexity: O(n² log n) for n observers.
    Space complexity: O(n²).

    >>> obs = [Observer("A", 1.0, 3.0), Observer("B", 2.0, 1.0)]
    >>> bps = enumerate_breakpoints(obs)
    >>> len(bps)
    1
    >>> abs(bps[0][0] - 0.5) < 1e-10
    True
    """
    candidates = []
    n = len(observers)

    for i in range(n):
        for j in range(i + 1, n):
            bp = find_breakpoint(observers[i], observers[j])
            if bp is not None and bp >= 0:
                candidates.append((bp, observers[i], observers[j]))

    candidates.sort(key=lambda x: x[0])

    # Filter: keep only breakpoints where both observers are on the lower envelope
    active = []
    for bp, oi, oj in candidates:
        val_i = oi.objective(bp)
        val_j = oj.objective(bp)
        min_val = min(obs.objective(bp) for obs in observers)
        if abs(val_i - min_val) < 1e-10 and abs(val_j - min_val) < 1e-10:
            active.append((bp, oi, oj))

    return active


class AffineSegment:
    """A segment of the piecewise-affine bottleneck function.

    B(β) = intercept + β * slope for β ∈ [beta_start, beta_end].
    """
    def __init__(self, beta_start: float, beta_end: float,
                 slope: float, intercept: float, observer: Observer):
        self.beta_start = beta_start
        self.beta_end = beta_end
        self.slope = slope
        self.intercept = intercept
        self.observer = observer

    def __repr__(self) -> str:
        return (f"[{self.beta_start:.4f}, {self.beta_end:.4f}]: "
                f"B(β) = {self.intercept:.2f} + β * {self.slope:.2f} "
                f"({self.observer.name})")


def compute_tradeoff_curve(observers: List[Observer]) -> List[AffineSegment]:
    """Algorithm 3: Compute the full piecewise-affine trade-off curve.

    Returns a list of AffineSegment objects covering [0, ∞).

    Time complexity: O(n² log n).
    Space complexity: O(n²).

    >>> obs = [Observer("A", 1.0, 3.0), Observer("B", 3.0, 1.0)]
    >>> segs = compute_tradeoff_curve(obs)
    >>> len(segs)
    2
    """
    breakpoints = enumerate_breakpoints(observers)
    bp_values = [0.0] + [bp for bp, _, _ in breakpoints] + [float('inf')]

    segments = []
    for k in range(len(bp_values) - 1):
        start = bp_values[k]
        end = bp_values[k + 1]

        # Find optimal observer at midpoint
        if end == float('inf'):
            mid = start + 1.0
        else:
            mid = (start + end) / 2.0

        _, opt = bottleneck_value(observers, mid)
        segments.append(AffineSegment(
            beta_start=start,
            beta_end=end,
            slope=opt.distortion,
            intercept=opt.capacity,
            observer=opt
        ))

    return segments


def certified_rate_region_test(observers: List[Observer],
                                c: float, d: float) -> Tuple[bool, Optional[Observer]]:
    """Test whether (c, d) lies in the certified rate region.

    A pair (c, d) is achievable iff ∃ i: cap(i) ≤ c and dist(i) ≤ d.

    Args:
        observers: List of canonical observer factors.
        c: Candidate capacity.
        d: Candidate distortion.

    Returns:
        (True, dominating observer) or (False, None).

    >>> obs = [Observer("A", 1.0, 3.0), Observer("B", 3.0, 1.0)]
    >>> certified_rate_region_test(obs, 2.0, 4.0)
    (True, Observer(A, c=1.0, d=3.0))
    >>> certified_rate_region_test(obs, 0.5, 0.5)[0]
    False
    """
    for obs in observers:
        if obs.capacity <= c and obs.distortion <= d:
            return True, obs
    return False, None


# ─── Example Usage ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    observers = [
        Observer("Deep-Narrow", 1.0, 5.0),
        Observer("Medium", 2.5, 2.0),
        Observer("Wide-Shallow", 4.0, 1.0),
        Observer("Balanced", 2.0, 3.0),
        Observer("Ultra-Compressed", 0.5, 8.0),
    ]

    print("=== Trade-off Curve ===")
    segments = compute_tradeoff_curve(observers)
    for seg in segments:
        print(f"  {seg}")

    print("\n=== Rate Region Tests ===")
    test_pairs = [(3.0, 3.0), (0.3, 0.5), (1.0, 5.0), (5.0, 2.0)]
    for c, d in test_pairs:
        ok, dom = certified_rate_region_test(observers, c, d)
        status = f"✓ dominated by {dom.name}" if ok else "✗ not achievable"
        print(f"  ({c}, {d}): {status}")
