#!/usr/bin/env python3
"""
EML Interpolation Theory: Algorithms

Type-hinted implementations of the key algorithms from the EML
Stone-Weierstrass framework.
"""

import math
from typing import List, Tuple, Callable, Optional
from dataclasses import dataclass


# ============================================================
# Core Data Structures
# ============================================================

@dataclass
class EMLComplexity:
    """Complexity pair for an EML term."""
    width: int
    depth: int
    
    @property
    def total_cost(self) -> int:
        """Total cost = width * 2^depth."""
        return self.width * (2 ** self.depth)
    
    def __le__(self, other: 'EMLComplexity') -> bool:
        """Product partial order."""
        return self.width <= other.width and self.depth <= other.depth
    
    def __repr__(self) -> str:
        return f"EMLComplexity(w={self.width}, d={self.depth}, cost={self.total_cost})"


# ============================================================
# Algorithm 1: EML Term Construction
# ============================================================

def construct_eml_power(n: int) -> Callable[[float], float]:
    """
    Construct x^n as an EML computation.
    
    Algorithm: Repeated multiplication (Horner-like).
    Complexity: width = max(1, 2n), depth = n.
    
    Args:
        n: Non-negative integer exponent.
    
    Returns:
        Function x ↦ x^n.
    """
    def power_fn(x: float) -> float:
        return x ** n
    return power_fn


def construct_eml_polynomial(coefficients: List[float]) -> Tuple[Callable[[float], float], EMLComplexity]:
    """
    Construct a polynomial in Horner form as an EML computation.
    
    Algorithm: Horner's method: a₀ + x(a₁ + x(a₂ + ...))
    
    Args:
        coefficients: [a₀, a₁, ..., aₙ] where polynomial is Σ aᵢxⁱ.
    
    Returns:
        Tuple of (evaluation function, complexity).
    """
    n = len(coefficients)
    if n == 0:
        return (lambda x: 0.0, EMLComplexity(width=1, depth=0))
    
    def horner_eval(x: float) -> float:
        result = coefficients[-1]
        for i in range(n - 2, -1, -1):
            result = coefficients[i] + x * result
        return result
    
    # Width: 2n - 1 (n constants + (n-1) var references), Depth: 2(n-1) + 1
    width = max(1, 2 * n - 1)
    depth = max(0, 2 * (n - 1))
    
    return (horner_eval, EMLComplexity(width=width, depth=depth))


# ============================================================
# Algorithm 2: Iterated Exponential
# ============================================================

def iterated_exponential(k: int, x: float, overflow_cap: float = 1e300) -> float:
    """
    Compute the k-fold iterated exponential exp^(k)(x).
    
    Algorithm: Sequential application of exp, with overflow protection.
    Complexity: width = 1, depth = k.
    
    Args:
        k: Number of exp applications.
        x: Input value.
        overflow_cap: Maximum value before returning inf.
    
    Returns:
        exp^(k)(x), or inf if overflow occurs.
    """
    result = x
    for _ in range(k):
        if result > 700:  # exp(700) ≈ 1e304
            return float('inf')
        result = math.exp(result)
        if result > overflow_cap:
            return float('inf')
    return result


# ============================================================
# Algorithm 3: Exponential Separation Bound
# ============================================================

def exp_separation_bound(x: float, y: float) -> Tuple[float, float]:
    """
    Compute the exponential separation and its lower bound.
    
    Theorem: |exp(x) - exp(y)| ≥ |x - y| * exp(min(x, y))
    
    Args:
        x, y: Two distinct real numbers.
    
    Returns:
        Tuple of (actual separation |exp(x)-exp(y)|, lower bound |x-y|*exp(min(x,y))).
    """
    actual = abs(math.exp(x) - math.exp(y))
    bound = abs(x - y) * math.exp(min(x, y))
    return (actual, bound)


# ============================================================
# Algorithm 4: EML Approximation Search
# ============================================================

def find_best_eml_approx(
    target: Callable[[float], float],
    max_width: int,
    max_depth: int,
    domain: Tuple[float, float] = (0.0, 1.0),
    num_samples: int = 100
) -> Tuple[Optional[List[float]], float, EMLComplexity]:
    """
    Search for the best EML polynomial approximation to a target function.
    
    Algorithm: 
    1. Sample the target function on a grid.
    2. For each degree d from 1 to max_width:
       - Fit a degree-d polynomial using least squares.
       - Compute the sup-norm error on the grid.
    3. Return the best polynomial with complexity within bounds.
    
    Args:
        target: Target function to approximate.
        max_width: Maximum allowed width.
        max_depth: Maximum allowed depth.
        domain: Interval [a, b] to approximate on.
        num_samples: Number of sample points.
    
    Returns:
        Tuple of (best coefficients or None, error, complexity).
    """
    a, b = domain
    xs = [a + (b - a) * i / (num_samples - 1) for i in range(num_samples)]
    ys = [target(x) for x in xs]
    
    best_coeffs: Optional[List[float]] = None
    best_error = float('inf')
    best_complexity = EMLComplexity(width=1, depth=0)
    
    # Try polynomials of increasing degree
    for degree in range(1, min(max_width, 20)):
        # Simple polynomial fitting using Vandermonde matrix
        # (In production, use numpy.polyfit)
        coeffs = _fit_polynomial(xs, ys, degree)
        if coeffs is None:
            continue
        
        # Evaluate error
        max_err = 0.0
        for i, x in enumerate(xs):
            val = _eval_polynomial(coeffs, x)
            max_err = max(max_err, abs(val - ys[i]))
        
        complexity = EMLComplexity(width=max(1, 2 * len(coeffs) - 1),
                                    depth=max(0, 2 * (len(coeffs) - 1)))
        
        if max_err < best_error and complexity.width <= max_width:
            best_error = max_err
            best_coeffs = coeffs
            best_complexity = complexity
    
    return (best_coeffs, best_error, best_complexity)


def _fit_polynomial(xs: List[float], ys: List[float], degree: int) -> Optional[List[float]]:
    """Simple polynomial fitting via normal equations (no numpy dependency)."""
    n = len(xs)
    d = degree + 1
    
    # Build Vandermonde matrix A and compute A^T A and A^T y
    ATA = [[0.0] * d for _ in range(d)]
    ATy = [0.0] * d
    
    for i in range(n):
        powers = [xs[i] ** j for j in range(d)]
        for j in range(d):
            for k in range(d):
                ATA[j][k] += powers[j] * powers[k]
            ATy[j] += powers[j] * ys[i]
    
    # Solve via Gaussian elimination
    try:
        coeffs = _solve_linear(ATA, ATy)
        return coeffs
    except (ZeroDivisionError, ValueError):
        return None


def _solve_linear(A: List[List[float]], b: List[float]) -> List[float]:
    """Solve Ax = b via Gaussian elimination with partial pivoting."""
    n = len(b)
    # Augmented matrix
    M = [row[:] + [bi] for row, bi in zip(A, b)]
    
    for col in range(n):
        # Partial pivoting
        max_row = col
        for row in range(col + 1, n):
            if abs(M[row][col]) > abs(M[max_row][col]):
                max_row = row
        M[col], M[max_row] = M[max_row], M[col]
        
        if abs(M[col][col]) < 1e-12:
            raise ValueError("Singular matrix")
        
        for row in range(col + 1, n):
            factor = M[row][col] / M[col][col]
            for j in range(col, n + 1):
                M[row][j] -= factor * M[col][j]
    
    # Back substitution
    x = [0.0] * n
    for i in range(n - 1, -1, -1):
        x[i] = M[i][n]
        for j in range(i + 1, n):
            x[i] -= M[i][j] * x[j]
        x[i] /= M[i][i]
    
    return x


def _eval_polynomial(coeffs: List[float], x: float) -> float:
    """Evaluate polynomial in Horner form."""
    result = coeffs[-1]
    for i in range(len(coeffs) - 2, -1, -1):
        result = coeffs[i] + x * result
    return result


# ============================================================
# Algorithm 5: Depth-Width Tradeoff Analysis
# ============================================================

def analyze_depth_width_tradeoff(
    k_max: int = 5,
    x_values: List[float] = [0.5, 1.0, 1.5, 2.0]
) -> List[dict]:
    """
    Analyze the depth-width tradeoff for iterated exponentials.
    
    For each depth k from 0 to k_max, compute:
    - The value of exp^(k)(x) at sample points
    - The growth ratio exp^(k+1)(x) / exp^(k)(x)
    - The EML complexity (width=1, depth=k)
    
    Returns:
        List of analysis results per depth level.
    """
    results = []
    
    for k in range(k_max + 1):
        values = {}
        ratios = {}
        
        for x in x_values:
            val_k = iterated_exponential(k, x)
            values[x] = val_k
            
            if k > 0:
                val_prev = iterated_exponential(k - 1, x)
                if val_prev > 0 and not math.isinf(val_k):
                    ratios[x] = val_k / val_prev
                else:
                    ratios[x] = float('inf')
        
        results.append({
            'depth': k,
            'width': 1,
            'total_cost': 2 ** k,
            'values': values,
            'growth_ratios': ratios
        })
    
    return results


if __name__ == "__main__":
    # Example usage
    print("EML Polynomial Approximation of sin(x) on [0, π]:")
    coeffs, error, complexity = find_best_eml_approx(
        math.sin, max_width=20, max_depth=20,
        domain=(0.0, math.pi)
    )
    if coeffs:
        print(f"  Best polynomial degree: {len(coeffs) - 1}")
        print(f"  Max error: {error:.2e}")
        print(f"  Complexity: {complexity}")
    
    print("\nDepth-Width Tradeoff Analysis:")
    results = analyze_depth_width_tradeoff(k_max=4)
    for r in results:
        print(f"  Depth {r['depth']}: cost={r['total_cost']}, "
              f"values at x=1: {r['values'].get(1.0, 'N/A'):.6f}"
              if not math.isinf(r['values'].get(1.0, float('inf')))
              else f"  Depth {r['depth']}: cost={r['total_cost']}, values at x=1: overflow")
