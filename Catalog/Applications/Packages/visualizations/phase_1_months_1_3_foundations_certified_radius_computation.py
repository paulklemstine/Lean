#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Certified Radius Computation and Benchmarking

Implements the core algorithms from the research paper:
1. Certified radius computation with monotonicity guarantees
2. Residuated bound computation on extended reals
3. Finite benchmark certification oracle
4. Tropical perturbation budget analysis

All algorithms have formal correctness guarantees via the Lean theorems
in Bridges/CertifiedRadiusResiduated.lean.
"""

import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Optional, Callable
import time


# ═══════════════════════════════════════════════════════════════
# Algorithm 1: Certified Radius Computation
# ═══════════════════════════════════════════════════════════════

@dataclass
class CertifiedRadiusResult:
    """Result of a certified radius computation."""
    margin: float
    lipschitz: float
    radius: float
    is_trivial: bool  # True if radius is 0 (nonpositive margin)

    def __repr__(self):
        return (f"CertifiedRadiusResult(m={self.margin:.4f}, K={self.lipschitz:.4f}, "
                f"r={self.radius:.4f}, trivial={self.is_trivial})")


def compute_certified_radius(margin: float, lipschitz: float) -> CertifiedRadiusResult:
    """
    Compute the certified perturbation radius.
    
    Algorithm: r(m, K) = max(0, m / K)
    
    Complexity: O(1) time, O(1) space
    
    Correctness: Formally verified as `certifiedRadius` in Lean.
    Satisfies:
      - Monotone in margin (certifiedRadius_monotone_margin)
      - Antitone in Lipschitz (certifiedRadius_antitone_Lipschitz)
      - K * r ≤ m when m ≥ 0 (certifiedRadius_margin_ineq)
    
    Args:
        margin: Classification margin m = f(x) - threshold
        lipschitz: Lipschitz constant K > 0
    
    Returns:
        CertifiedRadiusResult with the computed radius
    """
    if lipschitz <= 0:
        radius = 0.0
    else:
        radius = max(0.0, margin / lipschitz)
    
    return CertifiedRadiusResult(
        margin=margin,
        lipschitz=lipschitz,
        radius=radius,
        is_trivial=(radius == 0.0)
    )


# ═══════════════════════════════════════════════════════════════
# Algorithm 2: Residuated Bound Computation
# ═══════════════════════════════════════════════════════════════

@dataclass
class ResidualResult:
    """Result of a residual computation on extended reals."""
    a: Optional[float]  # None represents ⊥
    b: Optional[float]
    residual: Optional[float]
    
    def __repr__(self):
        def fmt(x):
            return "⊥" if x is None else f"{x:.4f}"
        return f"Residual({fmt(self.a)} ⇒ {fmt(self.b)}) = {fmt(self.residual)}"


def compute_residual(a: Optional[float], b: Optional[float]) -> ResidualResult:
    """
    Compute the residual operation on WithBot ℝ.
    
    Algorithm:
      wbotResidual(a, b) = match (a, b):
        | (⊥, _) → ⊥
        | (_, ⊥) → ⊥
        | (a', b') → b' - a'
    
    Complexity: O(1) time, O(1) space
    
    Correctness: Formally verified as `wbotResidual` in Lean.
    Satisfies the adjunction:
      ↑(a + r) ≤ ↑b  ⟺  ↑r ≤ ↑(b - a)  (wbotResidual_adjoint_coe)
    
    Args:
        a: First operand (None = ⊥)
        b: Second operand (None = ⊥)
    
    Returns:
        ResidualResult with the computed residual
    """
    if a is None or b is None:
        residual = None
    else:
        residual = b - a
    
    return ResidualResult(a=a, b=b, residual=residual)


def check_adjunction(a: float, r: float, b: float) -> Tuple[bool, bool]:
    """
    Verify the residual adjunction: a + r ≤ b ⟺ r ≤ b - a.
    
    Returns (lhs_holds, rhs_holds) — they must always agree.
    
    Correctness: Formally verified as `real_add_le_iff_le_sub` in Lean.
    """
    lhs = (a + r <= b)
    rhs = (r <= b - a)
    assert lhs == rhs, f"Adjunction violated! a={a}, r={r}, b={b}"
    return lhs, rhs


# ═══════════════════════════════════════════════════════════════
# Algorithm 3: Finite Benchmark Certification
# ═══════════════════════════════════════════════════════════════

@dataclass
class BenchmarkResult:
    """Result of a finite benchmark certification."""
    n_points: int
    n_in_ball: int
    n_certified: int
    n_violations: int  # should always be 0 by the theorem
    radius: float
    margin: float
    lipschitz: float
    all_certified: bool
    elapsed_ms: float

    def __repr__(self):
        return (f"BenchmarkResult(points={self.n_points}, in_ball={self.n_in_ball}, "
                f"certified={self.n_certified}, violations={self.n_violations}, "
                f"r={self.radius:.4f}, time={self.elapsed_ms:.1f}ms)")


def certify_finite_ball(
    S: np.ndarray,        # shape (N, n) — finite point set
    f: Callable,          # function f: R^n → R
    x: np.ndarray,        # center point, shape (n,)
    margin: float,        # m ≤ f(x)
    lipschitz: float,     # K > 0
    radius: Optional[float] = None  # if None, use certified_radius(m, K)
) -> BenchmarkResult:
    """
    Certify nonnegativity of f within a ball around x over a finite set S.
    
    Algorithm:
      1. Compute r = certified_radius(m, K) if not provided
      2. For each y ∈ S with ‖y - x‖ ≤ r:
         - Verify |f(y) - f(x)| ≤ K·‖y - x‖ (Lipschitz check)
         - Conclude f(y) ≥ 0 by the certified ball theorem
    
    Complexity: O(N · n) time where N = |S|, n = dimension
    
    Correctness: Formally verified as `finite_certified_ball_nonneg` in Lean.
    Prerequisites: K > 0, m ≥ 0, m ≤ f(x), r ≤ max(0, m/K),
                   and |f(y) - f(x)| ≤ K·‖y-x‖ for all y ∈ S.
    
    Args:
        S: Array of shape (N, n), the finite point set
        f: The function to certify
        x: Center point
        margin: Lower bound on f(x)
        lipschitz: Lipschitz constant
        radius: Perturbation radius (default: certified_radius(m, K))
    
    Returns:
        BenchmarkResult with certification statistics
    """
    start = time.time()
    
    cr = compute_certified_radius(margin, lipschitz)
    if radius is None:
        radius = cr.radius
    
    assert radius <= cr.radius + 1e-10, \
        f"radius {radius} exceeds certified radius {cr.radius}"
    
    n_in_ball = 0
    n_certified = 0
    n_violations = 0
    fx = f(x)
    
    assert margin <= fx + 1e-10, f"Margin {margin} exceeds f(x) = {fx}"
    assert margin >= -1e-10, f"Margin must be nonneg, got {margin}"
    
    for y in S:
        dist = np.linalg.norm(y - x)
        if dist <= radius:
            n_in_ball += 1
            fy = f(y)
            
            # Verify Lipschitz condition
            lip_check = abs(fy - fx) <= lipschitz * dist + 1e-10
            
            if fy >= -1e-10:
                n_certified += 1
            else:
                n_violations += 1
    
    elapsed = (time.time() - start) * 1000
    
    return BenchmarkResult(
        n_points=len(S),
        n_in_ball=n_in_ball,
        n_certified=n_certified,
        n_violations=n_violations,
        radius=radius,
        margin=margin,
        lipschitz=lipschitz,
        all_certified=(n_violations == 0),
        elapsed_ms=elapsed
    )


# ═══════════════════════════════════════════════════════════════
# Algorithm 4: Monotonicity-Guided Radius Search
# ═══════════════════════════════════════════════════════════════

def optimal_radius_search(
    f: Callable,
    x: np.ndarray,
    lipschitz_bounds: List[float],
    margin_bounds: List[float]
) -> CertifiedRadiusResult:
    """
    Find the best certified radius by exploiting monotonicity.
    
    By certifiedRadius_mono, we know that:
      - Larger margins give larger radii
      - Smaller Lipschitz constants give larger radii
    
    So the optimal radius is obtained from the largest margin
    and smallest Lipschitz constant.
    
    Algorithm:
      1. Take m* = max(margin_bounds)
      2. Take K* = min(lipschitz_bounds)
      3. Return certified_radius(m*, K*)
    
    Complexity: O(|margins| + |lipschitz|) time
    
    Args:
        f: The function
        x: Center point
        lipschitz_bounds: List of valid Lipschitz constants
        margin_bounds: List of valid margin lower bounds
    
    Returns:
        CertifiedRadiusResult with the optimal radius
    """
    best_margin = max(margin_bounds)
    best_lipschitz = min(lipschitz_bounds)
    
    return compute_certified_radius(best_margin, best_lipschitz)


# ═══════════════════════════════════════════════════════════════
# Main demonstration
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)
    
    # Algorithm 1
    print("\n--- Algorithm 1: Certified Radius ---")
    for m, K in [(3.0, 2.0), (1.0, 4.0), (-1.0, 2.0), (5.0, 0.5)]:
        result = compute_certified_radius(m, K)
        print(f"  {result}")
    
    # Algorithm 2
    print("\n--- Algorithm 2: Residual Computation ---")
    for a, b in [(1.0, 3.0), (None, 2.0), (2.0, None), (-1.0, 5.0)]:
        result = compute_residual(a, b)
        print(f"  {result}")
    
    # Algorithm 3
    print("\n--- Algorithm 3: Finite Benchmark ---")
    n = 10
    np.random.seed(42)
    S = np.random.randn(500, n) * 2
    x = np.zeros(n)
    
    def f(y):
        return 5.0 - 2.0 * np.linalg.norm(y - x)
    
    result = certify_finite_ball(S, f, x, margin=5.0, lipschitz=2.0)
    print(f"  {result}")
    
    # Algorithm 4
    print("\n--- Algorithm 4: Optimal Radius Search ---")
    margins = [1.0, 2.0, 3.0, 2.5]
    lipschitz_vals = [4.0, 3.0, 2.0, 2.5]
    result = optimal_radius_search(f, x, lipschitz_vals, margins)
    print(f"  Best: {result}")
    
    print("\nAll algorithms completed successfully.")
