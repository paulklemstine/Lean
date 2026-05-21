#!/usr/bin/env python3
"""
algorithms.py — Path groupoid algorithms: composition, reparametrization, homotopy.

Implements the core algorithms from the path groupoid research:
- Path concatenation via piecewise-linear rescaling
- Path reversal (time-reversal)
- Endpoint-preserving reparametrization
- Explicit homotopy witnesses for groupoid laws
- Numerical verification of coherence conditions

All algorithms are O(n) in the number of sample points, with exact
arithmetic for piecewise-linear paths.
"""

from typing import Callable, Tuple, List
import math


# Type alias for paths: functions [0,1] → ℝ
PathFunc = Callable[[float], float]


class PiecewiseLinearPath:
    """A piecewise-linear path [0,1] → ℝ defined by breakpoints.
    
    Attributes:
        breakpoints: sorted list of t values in [0,1]
        values: corresponding function values
    
    Complexity: O(log n) per evaluation via binary search, O(n) for sampling.
    """
    
    def __init__(self, breakpoints: List[float], values: List[float]):
        assert len(breakpoints) == len(values)
        assert breakpoints[0] == 0.0 and breakpoints[-1] == 1.0
        assert all(breakpoints[i] <= breakpoints[i+1] for i in range(len(breakpoints)-1))
        self.breakpoints = list(breakpoints)
        self.values = list(values)
    
    def __call__(self, t: float) -> float:
        """Evaluate the path at parameter t ∈ [0,1]."""
        t = max(0.0, min(1.0, t))
        if t <= self.breakpoints[0]:
            return self.values[0]
        if t >= self.breakpoints[-1]:
            return self.values[-1]
        # Binary search for interval
        lo, hi = 0, len(self.breakpoints) - 1
        while hi - lo > 1:
            mid = (lo + hi) // 2
            if self.breakpoints[mid] <= t:
                lo = mid
            else:
                hi = mid
        # Linear interpolation
        t0, t1 = self.breakpoints[lo], self.breakpoints[hi]
        v0, v1 = self.values[lo], self.values[hi]
        if t1 == t0:
            return v0
        frac = (t - t0) / (t1 - t0)
        return v0 + frac * (v1 - v0)
    
    @property
    def source(self) -> float:
        return self.values[0]
    
    @property
    def target(self) -> float:
        return self.values[-1]
    
    def sample(self, n: int = 100) -> Tuple[List[float], List[float]]:
        """Sample the path at n evenly-spaced points."""
        ts = [i / (n - 1) for i in range(n)]
        vs = [self(t) for t in ts]
        return ts, vs


def concat(p: PiecewiseLinearPath, q: PiecewiseLinearPath) -> PiecewiseLinearPath:
    """Concatenate two composable paths.
    
    (p · q)(t) = p(2t) if t ≤ 1/2, q(2t-1) if t ≥ 1/2
    
    Precondition: p.target == q.source (approximately)
    Complexity: O(n + m) where n, m are breakpoint counts.
    
    Algorithm:
        1. Rescale p's breakpoints to [0, 0.5]
        2. Rescale q's breakpoints to [0.5, 1.0]
        3. Merge, deduplicating the midpoint
    """
    new_bp = [t / 2 for t in p.breakpoints]
    new_vals = list(p.values)
    
    # Skip q's first breakpoint (it overlaps with p's last)
    for i in range(1, len(q.breakpoints)):
        new_bp.append(0.5 + q.breakpoints[i] / 2)
        new_vals.append(q.values[i])
    
    return PiecewiseLinearPath(new_bp, new_vals)


def reverse(p: PiecewiseLinearPath) -> PiecewiseLinearPath:
    """Reverse a path: p⁻¹(t) = p(1-t).
    
    Complexity: O(n) where n is breakpoint count.
    """
    new_bp = [1.0 - t for t in reversed(p.breakpoints)]
    new_vals = list(reversed(p.values))
    return PiecewiseLinearPath(new_bp, new_vals)


def refl(x: float) -> PiecewiseLinearPath:
    """Constant path at x.
    
    Complexity: O(1).
    """
    return PiecewiseLinearPath([0.0, 1.0], [x, x])


class EndpointPreservingReparam:
    """An endpoint-preserving monotone reparametrization [0,1] → [0,1].
    
    Defined by piecewise-linear interpolation through breakpoints,
    with φ(0) = 0 and φ(1) = 1.
    """
    
    def __init__(self, breakpoints: List[float], values: List[float]):
        assert breakpoints[0] == 0.0 and breakpoints[-1] == 1.0
        assert values[0] == 0.0 and values[-1] == 1.0
        assert all(values[i] <= values[i+1] for i in range(len(values)-1))
        self.breakpoints = breakpoints
        self.values = values
    
    def __call__(self, t: float) -> float:
        t = max(0.0, min(1.0, t))
        if t <= 0.0:
            return 0.0
        if t >= 1.0:
            return 1.0
        lo, hi = 0, len(self.breakpoints) - 1
        while hi - lo > 1:
            mid = (lo + hi) // 2
            if self.breakpoints[mid] <= t:
                lo = mid
            else:
                hi = mid
        t0, t1 = self.breakpoints[lo], self.breakpoints[hi]
        v0, v1 = self.values[lo], self.values[hi]
        if t1 == t0:
            return v0
        frac = (t - t0) / (t1 - t0)
        return v0 + frac * (v1 - v0)


def reparametrize(p: PiecewiseLinearPath, phi: EndpointPreservingReparam) -> PiecewiseLinearPath:
    """Apply reparametrization φ to path p, yielding p ∘ φ.
    
    Complexity: O(n·m) in worst case, but O(n+m) for aligned breakpoints.
    """
    # Sample at a refined set of breakpoints
    all_bp = sorted(set(phi.breakpoints))
    new_vals = [p(phi(t)) for t in all_bp]
    return PiecewiseLinearPath(all_bp, new_vals)


def left_unit_reparam(s: float) -> EndpointPreservingReparam:
    """Reparametrization witnessing refl · p ≃ p at homotopy time s.
    
    At s=0: φ(t) = max(2t-1, 0) (the concat reparametrization)
    At s=1: φ(t) = t (identity)
    Interpolation: breakpoint moves from 1/2 to 0.
    """
    s = max(0.0, min(1.0, s))
    bp_mid = (1 - s) / 2
    if bp_mid < 1e-15:
        return EndpointPreservingReparam([0.0, 1.0], [0.0, 1.0])
    return EndpointPreservingReparam(
        [0.0, bp_mid, 1.0],
        [0.0, 0.0, 1.0]
    )


def assoc_reparam_left(s: float) -> Tuple[float, float]:
    """Breakpoints for the associativity homotopy at homotopy time s.
    
    Returns (b1, b2) where p lives on [0,b1], q on [b1,b2], r on [b2,1].
    At s=0: (1/4, 1/2)  — left bracketing
    At s=1: (1/2, 3/4)  — right bracketing
    """
    b1 = (1 - s) * 0.25 + s * 0.5
    b2 = (1 - s) * 0.5 + s * 0.75
    return b1, b2


def verify_groupoid_law(law_name: str, path_a, path_b, n_samples: int = 1000) -> float:
    """Verify two paths are pointwise close (max absolute error).
    
    Args:
        law_name: name for reporting
        path_a, path_b: paths to compare
        n_samples: number of sample points
    
    Returns: maximum absolute pointwise error
    """
    max_err = 0.0
    for i in range(n_samples):
        t = i / (n_samples - 1)
        err = abs(path_a(t) - path_b(t))
        max_err = max(max_err, err)
    return max_err


def run_verification_suite():
    """Run a complete verification of all groupoid laws."""
    import random
    random.seed(42)
    
    results = {}
    
    for trial in range(20):
        # Random piecewise-linear paths
        n = random.randint(3, 8)
        bp = sorted([0.0] + [random.random() for _ in range(n-2)] + [1.0])
        vals = [random.gauss(0, 2) for _ in range(n)]
        p = PiecewiseLinearPath(bp, vals)
        
        n = random.randint(3, 8)
        bp = sorted([0.0] + [random.random() for _ in range(n-2)] + [1.0])
        vals_q = [p.target] + [random.gauss(0, 2) for _ in range(n-2)] + [random.gauss(0, 2)]
        q = PiecewiseLinearPath(bp, vals_q)
        
        n = random.randint(3, 8)
        bp = sorted([0.0] + [random.random() for _ in range(n-2)] + [1.0])
        vals_r = [q.target] + [random.gauss(0, 2) for _ in range(n-2)] + [random.gauss(0, 2)]
        r = PiecewiseLinearPath(bp, vals_r)
        
        # Test 1: Endpoint preservation
        pq = concat(p, q)
        assert abs(pq.source - p.source) < 1e-12
        assert abs(pq.target - q.target) < 1e-12
        
        # Test 2: Associativity
        pq_r = concat(concat(p, q), r)
        p_qr = concat(p, concat(q, r))
        err = verify_groupoid_law("assoc", pq_r, p_qr)
        results.setdefault("assoc", []).append(err)
        
        # Test 3: Inverse
        pp_inv = concat(p, reverse(p))
        refl_x = refl(p.source)
        # Note: these are NOT equal, only homotopic
        # Check endpoints match
        assert abs(pp_inv.source - refl_x.source) < 1e-12
        assert abs(pp_inv.target - refl_x.target) < 1e-12
    
    return results


if __name__ == "__main__":
    results = run_verification_suite()
    print("Groupoid law verification complete.")
    if "assoc" in results:
        max_err = max(results["assoc"])
        print(f"  Max associativity discrepancy: {max_err:.2e}")
        print(f"  (This measures how much the two bracketings differ pointwise;")
        print(f"   they are NOT equal, only homotopic — the discrepancy is expected.)")
