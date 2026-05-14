"""
Tropical CTC Algorithms: Fixed-Point Computation, Contraction Analysis, Cycle Detection

Implements the core algorithms from the tropical CTC framework with full type hints,
docstrings, complexity analysis, and example usage.
"""

import numpy as np
from typing import Tuple, Optional, List
from dataclasses import dataclass


@dataclass
class FixedPointResult:
    """Result of a fixed-point computation."""
    point: np.ndarray
    iterations: int
    residual: float
    converged: bool
    trajectory: List[np.ndarray]


# ============================================================
# Algorithm 1: Tropical Fixed-Point Iteration
# ============================================================

def tropical_fixed_point(
    A: np.ndarray,
    b: np.ndarray,
    x0: np.ndarray,
    lam: float = 1.0,
    max_iter: int = 10000,
    tol: float = 1e-12,
    record_trajectory: bool = False,
) -> FixedPointResult:
    """
    Find a fixed point of the (discounted) tropical affine map via iteration.
    
    Computes x_{k+1} = F_λ(x_k) where:
        F_λ(x)_i = min(min_j(A[i,j] + λ·x[j]), b[i])
    
    Args:
        A: n×n causal weight matrix
        b: n-vector of boundary constraints
        x0: Initial state vector
        lam: Discount factor (0 ≤ λ ≤ 1). λ < 1 guarantees contraction.
        max_iter: Maximum iterations
        tol: Convergence tolerance (sup-norm)
        record_trajectory: If True, store all intermediate states
    
    Returns:
        FixedPointResult with the fixed point, iteration count, and convergence info
    
    Complexity:
        Time: O(max_iter · n²) in general; O(n² · log(1/tol) / log(1/λ)) for contractive maps
        Space: O(n) without trajectory, O(max_iter · n) with trajectory
    
    Example:
        >>> A = np.array([[2., 1.], [1., 2.]])
        >>> b = np.array([5., 5.])
        >>> result = tropical_fixed_point(A, b, np.zeros(2), lam=0.5)
        >>> print(f"Fixed point: {result.point}, converged in {result.iterations} steps")
    """
    n = A.shape[0]
    x = x0.copy()
    trajectory = [x.copy()] if record_trajectory else []
    
    for k in range(max_iter):
        # Compute F_λ(x)
        x_new = np.zeros(n)
        for i in range(n):
            x_new[i] = min(np.min(A[i, :] + lam * x), b[i])
        
        residual = np.max(np.abs(x_new - x))
        if record_trajectory:
            trajectory.append(x_new.copy())
        
        if residual < tol:
            return FixedPointResult(
                point=x_new, iterations=k + 1, residual=residual,
                converged=True, trajectory=trajectory
            )
        x = x_new
    
    return FixedPointResult(
        point=x, iterations=max_iter, residual=np.max(np.abs(x_new - x)),
        converged=False, trajectory=trajectory
    )


# ============================================================
# Algorithm 2: Contraction Rate Estimation
# ============================================================

def estimate_contraction_rate(
    A: np.ndarray,
    b: np.ndarray,
    lam: float = 1.0,
    n_samples: int = 100,
    scale: float = 10.0,
) -> Tuple[float, float]:
    """
    Empirically estimate the contraction rate of a tropical affine map.
    
    Samples random pairs (x, y) and computes:
        rate = max over pairs of dist(F(x), F(y)) / dist(x, y)
    
    For discounted maps with factor λ, the theoretical bound is λ.
    
    Args:
        A: n×n causal weight matrix
        b: n-vector of boundary constraints
        lam: Discount factor
        n_samples: Number of random pairs to test
        scale: Scale of random vectors
    
    Returns:
        (empirical_rate, theoretical_bound)
    
    Complexity:
        Time: O(n_samples · n²)
        Space: O(n)
    """
    n = A.shape[0]
    max_rate = 0.0
    
    def F(x):
        result = np.zeros(n)
        for i in range(n):
            result[i] = min(np.min(A[i, :] + lam * x), b[i])
        return result
    
    for _ in range(n_samples):
        x = np.random.randn(n) * scale
        y = np.random.randn(n) * scale
        
        d_in = np.max(np.abs(x - y))
        if d_in < 1e-15:
            continue
        
        d_out = np.max(np.abs(F(x) - F(y)))
        rate = d_out / d_in
        max_rate = max(max_rate, rate)
    
    return max_rate, lam


# ============================================================
# Algorithm 3: Minimum Cycle Mean Computation
# ============================================================

def minimum_cycle_mean(A: np.ndarray) -> Tuple[float, Optional[List[int]]]:
    """
    Compute the minimum cycle mean of a weighted directed graph.
    
    Uses Karp's algorithm: for a graph with weight matrix A,
        μ* = min_v min_{k<n} (d_n(v) - d_k(v)) / (n - k)
    where d_k(v) is the minimum weight of a walk of length k ending at v.
    
    The minimum cycle mean is the tropical analogue of spectral radius.
    Positive minimum cycle mean ⟹ chronology protection.
    
    Args:
        A: n×n weight matrix (A[i,j] = weight of edge j → i)
    
    Returns:
        (min_cycle_mean, cycle) where cycle is a list of vertex indices
        forming the minimum-mean cycle, or None if no cycle exists
    
    Complexity:
        Time: O(n³)
        Space: O(n²)
    """
    n = A.shape[0]
    INF = float('inf')
    
    # d[k][v] = minimum weight of a walk of length k ending at v
    d = np.full((n + 1, n), INF)
    
    # Start from a supersource (weight 0 to all vertices)
    d[0, :] = 0.0
    
    # Dynamic programming: shortest walks of length k
    for k in range(1, n + 1):
        for v in range(n):
            for u in range(n):
                if d[k-1, u] < INF:
                    d[k, v] = min(d[k, v], d[k-1, u] + A[v, u])
    
    # Karp's formula: μ* = min_v max_k (d[n,v] - d[k,v]) / (n - k)
    # For minimum CYCLE mean (not maximum)
    min_mean = INF
    for v in range(n):
        max_val = -INF
        for k in range(n):
            if d[k, v] < INF and d[n, v] < INF:
                val = (d[n, v] - d[k, v]) / (n - k)
                max_val = max(max_val, val)
        if max_val < min_mean:
            min_mean = max_val
    
    if min_mean == INF:
        return INF, None
    
    return min_mean, None  # Cycle extraction omitted for brevity


# ============================================================
# Algorithm 4: Paradox-Freedom Certificate
# ============================================================

@dataclass
class ParadoxCertificate:
    """Certificate that a tropical CTC system is paradox-free."""
    is_paradox_free: bool
    method: str
    contraction_rate: Optional[float]
    min_cycle_mean: Optional[float]
    fixed_point: Optional[np.ndarray]
    message: str


def certify_paradox_freedom(
    A: np.ndarray,
    b: np.ndarray,
    lo: Optional[np.ndarray] = None,
    hi: Optional[np.ndarray] = None,
    lam: float = 1.0,
) -> ParadoxCertificate:
    """
    Certify that a tropical CTC system admits a consistent timeline.
    
    Uses a hierarchy of methods:
    1. If λ < 1: contraction ⟹ unique fixed point (strongest guarantee)
    2. If box [lo, hi] preserved: monotone fixed point exists (Knaster-Tarski)
    3. Positive minimum cycle mean: spectral chronology protection
    
    Args:
        A: n×n causal weight matrix
        b: n-vector of boundary constraints
        lo, hi: Optional box bounds
        lam: Discount factor (default 1.0 = no discounting)
    
    Returns:
        ParadoxCertificate with the verdict and supporting evidence
    
    Complexity:
        Time: O(n³) for cycle mean, O(n² · log(1/tol)) for fixed-point iteration
        Space: O(n²)
    """
    n = A.shape[0]
    
    # Method 1: Contraction (strongest)
    if 0 <= lam < 1:
        result = tropical_fixed_point(A, b, np.zeros(n), lam=lam)
        return ParadoxCertificate(
            is_paradox_free=result.converged,
            method="contraction (λ < 1)",
            contraction_rate=lam,
            min_cycle_mean=None,
            fixed_point=result.point if result.converged else None,
            message=f"Unique fixed point found via contraction (λ={lam}, "
                    f"{result.iterations} iterations, residual={result.residual:.2e})"
        )
    
    # Method 2: Box preservation (monotone fixed point)
    if lo is not None and hi is not None:
        # Check if F maps [lo, hi] into itself
        x_test = hi.copy()
        Fx = np.zeros(n)
        for i in range(n):
            Fx[i] = min(np.min(A[i, :] + lam * x_test), b[i])
        
        maps_hi_down = np.all(Fx <= hi)
        
        x_test = lo.copy()
        for i in range(n):
            Fx[i] = min(np.min(A[i, :] + lam * x_test), b[i])
        maps_lo_up = np.all(Fx >= lo)
        
        if maps_hi_down and maps_lo_up:
            result = tropical_fixed_point(A, b, hi, lam=lam)
            if result.converged and np.all(result.point >= lo) and np.all(result.point <= hi):
                return ParadoxCertificate(
                    is_paradox_free=True,
                    method="box preservation (Knaster-Tarski)",
                    contraction_rate=None,
                    min_cycle_mean=None,
                    fixed_point=result.point,
                    message=f"Fixed point found in [{lo}, {hi}] via monotone iteration"
                )
    
    # Method 3: Cycle mean analysis
    mcm, cycle = minimum_cycle_mean(A)
    if mcm > 0:
        return ParadoxCertificate(
            is_paradox_free=True,
            method="positive cycle mean",
            contraction_rate=None,
            min_cycle_mean=mcm,
            fixed_point=None,
            message=f"Minimum cycle mean = {mcm:.4f} > 0: spectral chronology protection"
        )
    
    return ParadoxCertificate(
        is_paradox_free=False,
        method="inconclusive",
        contraction_rate=None,
        min_cycle_mean=mcm if mcm != float('inf') else None,
        fixed_point=None,
        message="Could not certify paradox-freedom with available methods"
    )


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Tropical CTC Algorithms — Example Usage")
    print("=" * 50)
    
    # Example 1: Fixed-point iteration
    A = np.array([[2., 1., 3.], [1., 2., 1.], [3., 1., 2.]])
    b = np.array([8., 7., 9.])
    
    result = tropical_fixed_point(A, b, np.ones(3) * 5, lam=0.7, record_trajectory=True)
    print(f"\nFixed point: {result.point}")
    print(f"Converged: {result.converged} in {result.iterations} iterations")
    
    # Example 2: Contraction rate
    emp_rate, theory = estimate_contraction_rate(A, b, lam=0.7)
    print(f"\nEmpirical contraction rate: {emp_rate:.6f}")
    print(f"Theoretical bound (λ):     {theory:.6f}")
    
    # Example 3: Minimum cycle mean
    mcm, _ = minimum_cycle_mean(A)
    print(f"\nMinimum cycle mean: {mcm:.4f}")
    
    # Example 4: Paradox-freedom certificate
    cert = certify_paradox_freedom(A, b, lam=0.7)
    print(f"\nParadox-freedom certificate:")
    print(f"  Verdict: {'PARADOX-FREE' if cert.is_paradox_free else 'INCONCLUSIVE'}")
    print(f"  Method: {cert.method}")
    print(f"  Message: {cert.message}")
