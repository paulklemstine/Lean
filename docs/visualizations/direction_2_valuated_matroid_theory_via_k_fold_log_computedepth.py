"""
algorithms.py — Core algorithms for computing directional depth of multivariate functions.

This module implements the mathematical theory of iterated directional log-concavity
for functions on multi-indices f : (α → ℕ) → ℝ≥0.

Key algorithms:
1. check_directional_log_concave — verify the mixed log-concavity condition
2. ratio_transform — compute the directional ratio transform Rᵢf
3. compute_depth — compute the directional depth of a function on a finite domain
4. check_supermodular — verify supermodularity of -log f
5. check_exchange_closed — verify exchange-closure of support

Complexity:
- check_directional_log_concave: O(|α|² · |domain|) per function evaluation
- compute_depth up to level k: O(|α|^k · |domain| · |α|²) total
"""

import numpy as np
from typing import Dict, Tuple, List, Optional, Callable
from itertools import product as iter_product
import math


# Type alias: multi-index is a tuple of nonneg ints
MultiIndex = Tuple[int, ...]


def basis_vector(n: int, i: int) -> Tuple[int, ...]:
    """Unit basis vector eᵢ in ℤⁿ."""
    v = [0] * n
    v[i] = 1
    return tuple(v)


def add_mi(a: MultiIndex, b: MultiIndex) -> MultiIndex:
    """Add two multi-indices componentwise."""
    return tuple(x + y for x, y in zip(a, b))


def degree(m: MultiIndex) -> int:
    """Total degree of a multi-index."""
    return sum(m)


def degree_slice(n: int, d: int) -> List[MultiIndex]:
    """
    Generate all multi-indices in ℕⁿ of total degree d.
    
    Uses stars-and-bars enumeration.
    
    Args:
        n: number of variables
        d: total degree
    
    Returns:
        List of all multi-indices (tuples) summing to d.
    
    Complexity: O(C(n+d-1, d)) — the number of such multi-indices.
    """
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in degree_slice(n - 1, d - k):
            result.append((k,) + rest)
    return result


def check_directional_log_concave(
    f: Dict[MultiIndex, float],
    n: int,
    domain: Optional[List[MultiIndex]] = None,
    tol: float = -1e-12
) -> Tuple[bool, Optional[Tuple[int, int, MultiIndex]]]:
    """
    Check directional log-concavity of f on a given domain.
    
    The condition: for all i, j ∈ {0,...,n-1} and all m in domain,
        f(m + eᵢ) · f(m + eⱼ) ≥ f(m) · f(m + eᵢ + eⱼ)
    
    Args:
        f: function values as dict from multi-index to ℝ
        n: dimension (number of indices)
        domain: list of multi-indices to check (default: all keys of f)
        tol: tolerance for inequality (negative = strict)
    
    Returns:
        (True, None) if log-concave, or (False, (i, j, m)) witnessing failure.
    
    Complexity: O(n² · |domain|)
    """
    if domain is None:
        domain = list(f.keys())
    
    for m in domain:
        for i in range(n):
            ei = basis_vector(n, i)
            mi = add_mi(m, ei)
            for j in range(i, n):
                ej = basis_vector(n, j)
                mj = add_mi(m, ej)
                mij = add_mi(mi, ej)
                
                fm = f.get(m, 0.0)
                fmi = f.get(mi, 0.0)
                fmj = f.get(mj, 0.0)
                fmij = f.get(mij, 0.0)
                
                # Check: fmi * fmj >= fm * fmij
                lhs = fmi * fmj
                rhs = fm * fmij
                if lhs - rhs < tol:
                    return False, (i, j, m)
    
    return True, None


def ratio_transform(
    f: Dict[MultiIndex, float],
    i: int,
    n: int
) -> Dict[MultiIndex, float]:
    """
    Compute the ratio transform Rᵢf(m) = f(m + eᵢ) / f(m).
    
    Uses the convention that division by zero yields 0.
    
    Args:
        f: function values
        i: direction index
        n: dimension
    
    Returns:
        Dict mapping m to Rᵢf(m) for all m where f(m) ≠ 0.
    
    Complexity: O(|domain|)
    """
    ei = basis_vector(n, i)
    result = {}
    for m, fm in f.items():
        if abs(fm) > 1e-15:
            mi = add_mi(m, ei)
            fmi = f.get(mi, 0.0)
            result[m] = fmi / fm
        else:
            result[m] = 0.0
    return result


def compute_depth(
    f: Dict[MultiIndex, float],
    n: int,
    max_depth: int = 10,
    domain: Optional[List[MultiIndex]] = None,
    tol: float = -1e-10
) -> int:
    """
    Compute the directional depth of f by iterating ratio transforms.
    
    Algorithm:
    1. Check directional log-concavity of f.
    2. If it passes, compute all n ratio transforms.
    3. Recursively check depth of each ratio transform.
    4. The depth is 1 + min(depth of Rᵢf for all i).
    
    Args:
        f: function values
        n: dimension
        max_depth: maximum depth to check (prevents infinite recursion)
        domain: domain to check on
        tol: tolerance for inequality checks
    
    Returns:
        The computed depth (capped at max_depth).
    
    Complexity: O(n^k · |domain| · n²) where k is the computed depth.
    """
    if max_depth == 0:
        return 0
    
    is_lc, failure = check_directional_log_concave(f, n, domain, tol)
    if not is_lc:
        return 0
    
    min_sub_depth = max_depth - 1
    for i in range(n):
        ri_f = ratio_transform(f, i, n)
        # Filter out near-zero entries for cleaner recursion
        ri_f_clean = {m: v for m, v in ri_f.items() if abs(v) > 1e-15}
        if len(ri_f_clean) == 0:
            min_sub_depth = 0
            break
        sub_depth = compute_depth(ri_f_clean, n, max_depth - 1, None, tol)
        min_sub_depth = min(min_sub_depth, sub_depth)
        if min_sub_depth == 0:
            break
    
    return 1 + min_sub_depth


def check_supermodular(
    g: Dict[MultiIndex, float],
    n: int,
    domain: Optional[List[MultiIndex]] = None,
    tol: float = -1e-12
) -> Tuple[bool, Optional[Tuple[int, int, MultiIndex]]]:
    """
    Check supermodularity of g on multi-indices.
    
    Condition: for i ≠ j, g(m + eᵢ + eⱼ) + g(m) ≥ g(m + eᵢ) + g(m + eⱼ).
    
    Args:
        g: function values
        n: dimension
        domain: domain to check
        tol: tolerance
    
    Returns:
        (True, None) if supermodular, or (False, (i, j, m)) witnessing failure.
    """
    if domain is None:
        domain = list(g.keys())
    
    for m in domain:
        for i in range(n):
            ei = basis_vector(n, i)
            for j in range(i + 1, n):
                ej = basis_vector(n, j)
                gm = g.get(m, 0.0)
                gmi = g.get(add_mi(m, ei), 0.0)
                gmj = g.get(add_mi(m, ej), 0.0)
                gmij = g.get(add_mi(m, add_mi(ei, ej)), 0.0)
                
                if (gmij + gm) - (gmi + gmj) < tol:
                    return False, (i, j, m)
    
    return True, None


def neg_log_function(
    f: Dict[MultiIndex, float]
) -> Dict[MultiIndex, float]:
    """Compute -log(f) pointwise, skipping non-positive values."""
    return {m: -math.log(v) for m, v in f.items() if v > 0}


def check_exchange_closed(
    f: Dict[MultiIndex, float],
    n: int,
    d: int,
    tol: float = 1e-15
) -> Tuple[bool, Optional[Tuple[MultiIndex, MultiIndex, int]]]:
    """
    Check exchange-closure of the support of f on degree slice d.
    
    For all m, n with degree d and f(m) > 0, f(n) > 0:
    if m_i < n_i, then ∃ j with n_j < m_j and f(exchange(m, i, j)) > 0.
    
    Returns:
        (True, None) if exchange-closed, or (False, (m, n, i)) as witness.
    """
    points = [m for m in degree_slice(n, d) if f.get(m, 0.0) > tol]
    
    for m in points:
        for nn in points:
            for i in range(n):
                if m[i] < nn[i]:
                    found = False
                    for j in range(n):
                        if nn[j] < m[j]:
                            # exchange move: increment i, decrement j
                            moved = list(m)
                            moved[i] += 1
                            moved[j] -= 1
                            if moved[j] >= 0 and f.get(tuple(moved), 0.0) > tol:
                                found = True
                                break
                    if not found:
                        return False, (m, nn, i)
    
    return True, None


# ──────────────────────────────────────────────────────────────────────
# Model families for testing
# ──────────────────────────────────────────────────────────────────────

def uniform_matroid_valuation(n: int, r: int, max_degree: int = None) -> Dict[MultiIndex, float]:
    """
    Construct the indicator function of the uniform matroid U(r, n).
    f(m) = 1 if |m| = r and all m_i ∈ {0, 1}, else 0.
    (Bases of the uniform matroid on n elements of rank r.)
    """
    if max_degree is None:
        max_degree = r
    result = {}
    for m in degree_slice(n, r):
        if all(mi <= 1 for mi in m):
            result[m] = 1.0
    return result


def weighted_product_valuation(weights: List[float], d: int) -> Dict[MultiIndex, float]:
    """
    Product valuation: f(m) = ∏ wᵢ^{mᵢ} on degree slice d.
    This is always infinitely log-concave (like geometric sequences).
    """
    n = len(weights)
    result = {}
    for m in degree_slice(n, d):
        val = 1.0
        for i in range(n):
            val *= weights[i] ** m[i]
        result[m] = val
    return result


def multinomial_valuation(n: int, d: int) -> Dict[MultiIndex, float]:
    """
    Multinomial coefficients: f(m) = d! / (m₁! · m₂! · ... · mₙ!).
    These arise from (x₁ + ... + xₙ)^d and should have high depth.
    """
    result = {}
    for m in degree_slice(n, d):
        val = math.factorial(d)
        for mi in m:
            val /= math.factorial(mi)
        result[m] = float(val)
    return result


def perturbed_multinomial(n: int, d: int, epsilon: float = 0.1) -> Dict[MultiIndex, float]:
    """
    Multinomial coefficients with asymmetric perturbation.
    f(m) = multinomial(m) * (1 + ε * m₁) to break symmetry.
    """
    base = multinomial_valuation(n, d)
    result = {}
    for m, v in base.items():
        result[m] = v * (1.0 + epsilon * m[0])
    return result


if __name__ == "__main__":
    print("=== Directional Depth Algorithm Demo ===\n")
    
    # Test 1: Multinomial coefficients (should have high depth)
    n, d = 3, 4
    f = multinomial_valuation(n, d)
    depth = compute_depth(f, n, max_depth=6)
    print(f"Multinomial(n={n}, d={d}): depth = {depth}")
    
    # Test 2: Uniform matroid
    f = uniform_matroid_valuation(4, 2)
    depth = compute_depth(f, 4, max_depth=6)
    print(f"Uniform matroid U(2,4): depth = {depth}")
    
    # Test 3: Product valuation (should be infinite depth)
    f = weighted_product_valuation([1.0, 2.0, 3.0], 5)
    depth = compute_depth(f, 3, max_depth=8)
    print(f"Product valuation [1,2,3], d=5: depth ≥ {depth}")
    
    # Test 4: Supermodularity of -log f
    f = multinomial_valuation(3, 3)
    g = neg_log_function(f)
    is_sm, _ = check_supermodular(g, 3)
    print(f"\n-log(multinomial) supermodular: {is_sm}")
    
    print("\nDone.")
