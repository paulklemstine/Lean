#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for M-convex shadow analysis.

Implements:
1. M-convex exchange verification (O(|S|^2 * n^2) time)
2. One-step and two-step shadow computation
3. Aggregate Hessian shadow with arbitrary weight matrices
4. Shadow compatibility checking
"""
import itertools
from typing import Set, Tuple, List, Optional, Dict

Vec = Tuple[int, ...]

def total_degree(v: Vec) -> int:
    """Total degree (sum of coordinates) of an exponent vector."""
    return sum(v)

def exchange(alpha: Vec, t: int, u: int) -> Vec:
    """Exchange operation: α - e_t + e_u.
    
    Args:
        alpha: exponent vector
        t: coordinate to decrement
        u: coordinate to increment
    Returns:
        New vector with alpha[t]-1 and alpha[u]+1
    """
    result = list(alpha)
    result[t] -= 1
    result[u] += 1
    return tuple(result)

def verify_mconvex(S: Set[Vec], verbose: bool = False) -> Tuple[bool, Optional[Dict]]:
    """Verify the M-convex symmetric exchange property.
    
    Time: O(|S|^2 * n^2) where n = dimension.
    Space: O(|S| * n) for the hash set.
    
    Args:
        S: finite set of exponent vectors (same dimension)
        verbose: if True, print progress
        
    Returns:
        (True, None) if M-convex, (False, counterexample) otherwise.
    """
    if len(S) <= 1:
        return True, None
    
    S_list = list(S)
    n = len(S_list[0])
    
    for idx_a, alpha in enumerate(S_list):
        for idx_b, beta in enumerate(S_list):
            if idx_a == idx_b:
                continue
            for t in range(n):
                if alpha[t] > beta[t]:
                    found = False
                    for u in range(n):
                        if alpha[u] < beta[u]:
                            gamma = exchange(alpha, t, u)
                            if gamma in S:
                                found = True
                                break
                    if not found:
                        return False, {
                            'alpha': alpha, 'beta': beta,
                            'coordinate': t,
                        }
    return True, None

def one_step_shadow(S: Set[Vec]) -> Set[Vec]:
    """Compute the one-step derivative shadow.
    
    ∂S = { α - e_i | α ∈ S, α_i > 0 }
    
    Time: O(|S| * n)
    """
    shadow = set()
    for alpha in S:
        for i in range(len(alpha)):
            if alpha[i] > 0:
                v = list(alpha)
                v[i] -= 1
                shadow.add(tuple(v))
    return shadow

def two_step_shadow(S: Set[Vec]) -> Set[Vec]:
    """Compute the two-step derivative shadow (iterated one-step).
    
    ∂²S = ∂(∂S)
    
    Time: O(|S| * n + |∂S| * n)
    """
    return one_step_shadow(one_step_shadow(S))

def aggregate_hessian_shadow(S: Set[Vec], A: Optional[List[List[float]]] = None) -> Set[Vec]:
    """Compute the aggregate Hessian shadow.
    
    AgSh(S,A) = { α - e_i - e_j | α ∈ S, α_i > 0, (α-e_i)_j > 0, A_ij ≠ 0 }
    
    When A is None (all-ones), this equals twoStepShadow(S).
    
    Args:
        S: support set
        A: weight matrix (n×n), None for all-ones
    """
    shadow = set()
    for alpha in S:
        n = len(alpha)
        for i in range(n):
            if alpha[i] <= 0:
                continue
            w = 1.0 if A is None else None
            for j in range(n):
                if A is not None:
                    w = A[i][j]
                if w == 0:
                    continue
                beta = list(alpha)
                beta[i] -= 1
                if beta[j] > 0:
                    beta[j] -= 1
                    shadow.add(tuple(beta))
    return shadow

def is_shadow_compatible(S: Set[Vec], A: List[List[float]]) -> bool:
    """Check if weight matrix A is shadow-compatible with S.
    
    WeightedShadowCompatible: ∀ α ∈ S, ∀ i,j, α_i > 0 → α_j > 0 → A_ij ≠ 0
    """
    for alpha in S:
        n = len(alpha)
        for i in range(n):
            if alpha[i] <= 0:
                continue
            for j in range(n):
                if alpha[j] > 0 and A[i][j] == 0:
                    return False
    return True

def uniform_matroid_bases(n: int, r: int) -> Set[Vec]:
    """Bases of uniform matroid U(r,n) as indicator vectors."""
    return {tuple(1 if i in s else 0 for i in range(n))
            for s in itertools.combinations(range(n), r)}

def steepest_descent_mconvex(S: Set[Vec], w: Vec) -> Vec:
    """Optimize a linear function over an M-convex set via steepest descent.
    
    Find argmax { w · x | x ∈ S } using the exchange property.
    This runs in O(n * D * |check time|) where D is the diameter.
    
    For M-convex sets, steepest descent always finds the global optimum.
    """
    if not S:
        raise ValueError("Empty set")
    
    n = len(w)
    current = next(iter(S))
    
    while True:
        improved = False
        best_gain = 0
        best_next = current
        
        for t in range(n):
            if current[t] <= 0:
                continue
            for u in range(n):
                if t == u:
                    continue
                candidate = exchange(current, t, u)
                if candidate in S:
                    gain = w[u] - w[t]
                    if gain > best_gain:
                        best_gain = gain
                        best_next = candidate
                        improved = True
        
        if not improved:
            break
        current = best_next
    
    return current


if __name__ == "__main__":
    # Example: optimize over U(3,6) shadow
    bases = uniform_matroid_bases(6, 3)
    shadow = two_step_shadow(bases)
    
    print("M-convex optimization over two-step shadow of U(3,6)")
    print(f"Shadow size: {len(shadow)}")
    
    w = (5, 3, 1, 0, -1, -3)
    opt = steepest_descent_mconvex(shadow, w)
    print(f"Weight vector: {w}")
    print(f"Optimal point: {opt}")
    print(f"Optimal value: {sum(a*b for a,b in zip(w, opt))}")
    
    # Verify by brute force
    best_val = max(sum(a*b for a,b in zip(w, x)) for x in shadow)
    print(f"Brute-force optimal: {best_val}")
    print(f"Match: {sum(a*b for a,b in zip(w, opt)) == best_val}")
