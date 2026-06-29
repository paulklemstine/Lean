#!/usr/bin/env python3
"""
Algorithms for Multivariate k-Fold Log-Concavity and M-Convexity

Implements certified procedures for:
1. Mixed directional log-concavity testing
2. Rectangle closure verification
3. Support exchange testing
4. Tropical supermodularity checking
5. k-fold directional log-concavity depth estimation

All algorithms operate on finite lattice functions represented as
dictionaries from tuples to floats.
"""

from itertools import combinations
from math import factorial, log, exp
from typing import Dict, Tuple, Set, List, Optional
from collections import defaultdict


# Type aliases
ExponentVector = Tuple[int, ...]
LatticeFunc = Dict[ExponentVector, float]


def standard_basis(n: int, i: int) -> ExponentVector:
    """Return the i-th standard basis vector e_i in Z^n."""
    return tuple(1 if j == i else 0 for j in range(n))


def add_vecs(a: ExponentVector, b: ExponentVector) -> ExponentVector:
    """Componentwise addition of exponent vectors."""
    return tuple(x + y for x, y in zip(a, b))


def sub_vecs(a: ExponentVector, b: ExponentVector) -> ExponentVector:
    """Componentwise subtraction of exponent vectors."""
    return tuple(x - y for x, y in zip(a, b))


def eval_f(f: LatticeFunc, m: ExponentVector) -> float:
    """Evaluate lattice function at m, defaulting to 0."""
    return f.get(m, 0.0)


# ─────────────────────────────────────────────────────────
# Algorithm 1: Mixed Directional Log-Concavity Test
# ─────────────────────────────────────────────────────────

def test_mixed_logconcave(
    f: LatticeFunc,
    n: int,
    tol: float = 1e-10
) -> Tuple[bool, List[Tuple[int, int, ExponentVector, float, float]]]:
    """
    Test mixed directional log-concavity of a lattice function.

    For all i ≠ j and all m in the support neighborhood:
        f(m + e_i + e_j) · f(m) ≤ f(m + e_i) · f(m + e_j)

    Args:
        f: Dictionary mapping exponent vectors to real values
        n: Dimension of the lattice
        tol: Numerical tolerance for inequality checking

    Returns:
        (is_valid, violations): Boolean result and list of violations.
        Each violation is (i, j, m, lhs, rhs).

    Complexity: O(n² · |supp_neighborhood|)
    """
    support = {k for k, v in f.items() if abs(v) > tol}
    
    # Build support neighborhood
    neighborhood: Set[ExponentVector] = set()
    for m in support:
        neighborhood.add(m)
        for i in range(n):
            ei = standard_basis(n, i)
            neighborhood.add(sub_vecs(m, ei))
    
    violations = []
    for m in neighborhood:
        for i in range(n):
            for j in range(n):
                if i == j:
                    continue
                ei = standard_basis(n, i)
                ej = standard_basis(n, j)
                
                lhs = eval_f(f, add_vecs(add_vecs(m, ei), ej)) * eval_f(f, m)
                rhs = eval_f(f, add_vecs(m, ei)) * eval_f(f, add_vecs(m, ej))
                
                if lhs > rhs + tol:
                    violations.append((i, j, m, lhs, rhs))
    
    return len(violations) == 0, violations


def test_axis_logconcave(
    f: LatticeFunc,
    n: int,
    tol: float = 1e-10
) -> Tuple[bool, List]:
    """
    Test axis directional log-concavity: f(m+2ei)·f(m) ≤ f(m+ei)².

    Complexity: O(n · |supp_neighborhood|)
    """
    support = {k for k, v in f.items() if abs(v) > tol}
    violations = []
    
    for m in support:
        for i in range(n):
            ei = standard_basis(n, i)
            lhs = eval_f(f, add_vecs(m, add_vecs(ei, ei))) * eval_f(f, m)
            rhs = eval_f(f, add_vecs(m, ei)) ** 2
            if lhs > rhs + tol:
                violations.append((i, m, lhs, rhs))
    
    return len(violations) == 0, violations


# ─────────────────────────────────────────────────────────
# Algorithm 2: Rectangle Closure Test
# ─────────────────────────────────────────────────────────

def test_rectangle_closed(
    support: Set[ExponentVector],
    n: int
) -> Tuple[bool, List[Tuple[int, int, ExponentVector]]]:
    """
    Test whether a support set is rectangle-closed.

    For all i < j and m in support:
        m ∈ S and m+e_i+e_j ∈ S  ⟹  m+e_i ∈ S and m+e_j ∈ S

    Args:
        support: Set of exponent vectors
        n: Dimension

    Returns:
        (is_closed, violations): Boolean and list of (i, j, m) violations.

    Complexity: O(n² · |support|)
    """
    violations = []
    for m in support:
        for i in range(n):
            for j in range(i + 1, n):
                ei = standard_basis(n, i)
                ej = standard_basis(n, j)
                m_ij = add_vecs(add_vecs(m, ei), ej)
                if m_ij in support:
                    m_i = add_vecs(m, ei)
                    m_j = add_vecs(m, ej)
                    if m_i not in support or m_j not in support:
                        violations.append((i, j, m))
    return len(violations) == 0, violations


# ─────────────────────────────────────────────────────────
# Algorithm 3: Support Exchange Test
# ─────────────────────────────────────────────────────────

def test_support_exchange(
    support: Set[ExponentVector],
    n: int
) -> Tuple[bool, List[Tuple[ExponentVector, ExponentVector, int]]]:
    """
    Test the matroid exchange property on support.

    For all α, β ∈ S and i with α_i > β_i:
        ∃ j with β_j > α_j and α - e_i + e_j ∈ S

    Complexity: O(n · |support|²)
    """
    support_list = list(support)
    violations = []
    
    for alpha in support_list:
        for beta in support_list:
            for i in range(n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(n):
                        if beta[j] > alpha[j]:
                            exchanged = list(alpha)
                            exchanged[i] -= 1
                            exchanged[j] += 1
                            if tuple(exchanged) in support:
                                found = True
                                break
                    if not found:
                        violations.append((alpha, beta, i))
    
    return len(violations) == 0, violations


# ─────────────────────────────────────────────────────────
# Algorithm 4: Tropical Supermodularity Test
# ─────────────────────────────────────────────────────────

def test_neglog_supermodular(
    f: LatticeFunc,
    n: int,
    tol: float = 1e-10
) -> Tuple[bool, List]:
    """
    Test that -log f is supermodular on the positive support.

    Equivalent to: log f(m) + log f(m+ei+ej) ≤ log f(m+ei) + log f(m+ej)

    Complexity: O(n² · |support|)
    """
    violations = []
    support = {k for k, v in f.items() if v > tol}
    
    for m in support:
        for i in range(n):
            for j in range(i + 1, n):
                ei = standard_basis(n, i)
                ej = standard_basis(n, j)
                
                vals = [eval_f(f, m),
                        eval_f(f, add_vecs(m, ei)),
                        eval_f(f, add_vecs(m, ej)),
                        eval_f(f, add_vecs(add_vecs(m, ei), ej))]
                
                if all(v > tol for v in vals):
                    lv = [log(v) for v in vals]
                    if lv[0] + lv[3] > lv[1] + lv[2] + tol:
                        violations.append((i, j, m, lv[0] + lv[3], lv[1] + lv[2]))
    
    return len(violations) == 0, violations


# ─────────────────────────────────────────────────────────
# Algorithm 5: Comprehensive Directional Log-Concavity Suite
# ─────────────────────────────────────────────────────────

def full_directional_analysis(
    f: LatticeFunc,
    n: int,
    tol: float = 1e-10
) -> Dict[str, any]:
    """
    Run the complete directional log-concavity analysis suite.

    Returns a dictionary with results for each test:
    - mixed_logconcave: bool
    - axis_logconcave: bool
    - rectangle_closed: bool
    - support_exchange: bool
    - neglog_supermodular: bool
    - support_size: int
    - violations: dict of violation lists

    Complexity: O(n² · (|support| + |support|²))
    """
    support = {k for k, v in f.items() if abs(v) > tol}
    
    is_mixed, mixed_v = test_mixed_logconcave(f, n, tol)
    is_axis, axis_v = test_axis_logconcave(f, n, tol)
    is_rect, rect_v = test_rectangle_closed(support, n)
    is_exch, exch_v = test_support_exchange(support, n)
    is_trop, trop_v = test_neglog_supermodular(f, n, tol)
    
    return {
        'mixed_logconcave': is_mixed,
        'axis_logconcave': is_axis,
        'rectangle_closed': is_rect,
        'support_exchange': is_exch,
        'neglog_supermodular': is_trop,
        'support_size': len(support),
        'violations': {
            'mixed': mixed_v,
            'axis': axis_v,
            'rectangle': rect_v,
            'exchange': exch_v,
            'tropical': trop_v
        }
    }


# ─────────────────────────────────────────────────────────
# Utility: Homogeneous Support Generation
# ─────────────────────────────────────────────────────────

def homogeneous_support(n: int, d: int) -> List[ExponentVector]:
    """Generate all exponent vectors of total degree d in n variables."""
    if n == 1:
        return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in homogeneous_support(n - 1, d - k):
            result.append((k,) + rest)
    return result


def multinomial(m: ExponentVector) -> int:
    """Compute multinomial coefficient (|m|)! / ∏ m_i!"""
    total = sum(m)
    result = factorial(total)
    for mi in m:
        result //= factorial(mi)
    return result


# ─────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Complete homogeneous polynomial h_3 in 3 variables
    n, d = 3, 3
    f: LatticeFunc = {}
    for m in homogeneous_support(n, d):
        f[m] = float(multinomial(m))
    
    print("Complete homogeneous polynomial h_3 in 3 variables")
    print(f"Support size: {len(f)}")
    
    results = full_directional_analysis(f, n)
    for key in ['mixed_logconcave', 'axis_logconcave', 'rectangle_closed',
                'support_exchange', 'neglog_supermodular']:
        print(f"  {key}: {results[key]}")
