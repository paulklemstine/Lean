#!/usr/bin/env python3
"""
Algorithms for Causal Loops in Category Theory

Type-hinted implementations of:
1. Cocycle verification
2. Pentagon identity checking
3. Coboundary decomposition
4. H³ computation for finite abelian groups
5. Associator defect analysis
"""

from typing import Callable, Optional, Tuple, List, Set, Dict
import itertools


# --- Core Types ---

CochainFn = Callable[[int, int, int], int]
Cochain2Fn = Callable[[int, int], int]


# --- Algorithm 1: Cocycle Verification ---

def verify_cocycle(alpha: CochainFn, n: int) -> Tuple[bool, Optional[Tuple[int, int, int, int]]]:
    """
    Verify the 3-cocycle condition over ℤ/nℤ.
    
    Returns (True, None) if α is a cocycle, or (False, counterexample) otherwise.
    
    The 3-cocycle condition is:
    α(g₂,g₃,g₄) - α(g₁+g₂,g₃,g₄) + α(g₁,g₂+g₃,g₄) - α(g₁,g₂,g₃+g₄) + α(g₁,g₂,g₃) ≡ 0 (mod n)
    
    Time: O(n⁴), Space: O(1)
    """
    for g1, g2, g3, g4 in itertools.product(range(n), repeat=4):
        val = (alpha(g2, g3, g4)
               - alpha((g1 + g2) % n, g3, g4)
               + alpha(g1, (g2 + g3) % n, g4)
               - alpha(g1, g2, (g3 + g4) % n)
               + alpha(g1, g2, g3)) % n
        if val != 0:
            return False, (g1, g2, g3, g4)
    return True, None


# --- Algorithm 2: Pentagon Identity Check ---

def verify_pentagon(alpha: CochainFn, n: int) -> Tuple[bool, Optional[Tuple[int, int, int, int]]]:
    """
    Verify the pentagon identity over ℤ/nℤ.
    
    α(f+g, h, k) + α(f, g, h+k) = α(g, h, k) + α(f, g+h, k) + α(f, g, h)  (mod n)
    
    By our bridge theorem, this is equivalent to the cocycle condition.
    
    Time: O(n⁴), Space: O(1)
    """
    for f, g, h, k in itertools.product(range(n), repeat=4):
        lhs = (alpha((f + g) % n, h, k) + alpha(f, g, (h + k) % n)) % n
        rhs = (alpha(g, h, k) + alpha(f, (g + h) % n, k) + alpha(f, g, h)) % n
        if lhs != rhs:
            return False, (f, g, h, k)
    return True, None


# --- Algorithm 3: Coboundary Decomposition ---

def find_coboundary_decomposition(
    alpha: CochainFn, n: int
) -> Optional[List[List[int]]]:
    """
    Find a 2-cochain β such that α = δβ, or return None if α is not a coboundary.
    
    Searches exhaustively over all n^(n²) possible 2-cochains.
    
    Time: O(n^(n²+3)), Space: O(n²)
    """
    for beta_vals in itertools.product(range(n), repeat=n * n):
        beta = lambda g1, g2, bv=beta_vals: bv[g1 * n + g2]
        is_match = True
        for g1, g2, g3 in itertools.product(range(n), repeat=3):
            coboundary = (beta(g2, g3)
                         - beta((g1 + g2) % n, g3)
                         + beta(g1, (g2 + g3) % n)
                         - beta(g1, g2)) % n
            if coboundary != alpha(g1, g2, g3):
                is_match = False
                break
        if is_match:
            return [[beta_vals[i * n + j] for j in range(n)] for i in range(n)]
    return None


# --- Algorithm 4: H³ Computation ---

def compute_h3_order(n: int) -> Dict[str, int]:
    """
    Compute |H³(ℤ/nℤ, ℤ/nℤ)| by counting cocycles and coboundaries.
    
    WARNING: Exponential in n. Only practical for n ≤ 3.
    
    Returns dict with cocycle_count, coboundary_count, h3_order.
    """
    # Count cocycles
    cocycle_count = 0
    for alpha_vals in itertools.product(range(n), repeat=n**3):
        alpha = lambda g1, g2, g3, av=alpha_vals: av[g1 * n**2 + g2 * n + g3]
        ok, _ = verify_cocycle(alpha, n)
        if ok:
            cocycle_count += 1
    
    # Count distinct coboundaries
    coboundary_set: Set[Tuple[int, ...]] = set()
    for beta_vals in itertools.product(range(n), repeat=n**2):
        beta = lambda g1, g2, bv=beta_vals: bv[g1 * n + g2]
        cb_key = tuple(
            (beta(g2, g3) - beta((g1 + g2) % n, g3) + beta(g1, (g2 + g3) % n) - beta(g1, g2)) % n
            for g1, g2, g3 in itertools.product(range(n), repeat=3)
        )
        coboundary_set.add(cb_key)
    
    coboundary_count = len(coboundary_set)
    h3_order = cocycle_count // coboundary_count if coboundary_count > 0 else 0
    
    return {
        "cocycle_count": cocycle_count,
        "coboundary_count": coboundary_count,
        "h3_order": h3_order
    }


# --- Algorithm 5: Associator Defect Analysis ---

def associator_defect(
    op: Callable[[float, float], float], 
    a: float, b: float, c: float
) -> float:
    """
    Compute the associator defect: op(op(a,b), c) - op(a, op(b,c)).
    """
    return op(op(a, b), c) - op(a, op(b, c))


def defect_accumulation(
    values: List[float], 
    op: Callable[[float, float], float]
) -> Tuple[float, float, float]:
    """
    Compute left-fold, right-fold, and their difference for a binary operation.
    
    Returns (left_result, right_result, difference).
    """
    if not values:
        return (0.0, 0.0, 0.0)
    
    # Left fold
    left = values[0]
    for v in values[1:]:
        left = op(left, v)
    
    # Right fold
    right = values[-1]
    for v in reversed(values[:-1]):
        right = op(v, right)
    
    return (left, right, left - right)


# --- Main ---

if __name__ == "__main__":
    print("Algorithm demonstrations:")
    
    # Product cocycle on ℤ/2ℤ
    alpha = lambda a, b, c: (a * b * c) % 2
    
    print(f"\n1. Cocycle verification: {verify_cocycle(alpha, 2)}")
    print(f"2. Pentagon verification: {verify_pentagon(alpha, 2)}")
    print(f"3. Coboundary decomposition: {find_coboundary_decomposition(alpha, 2)}")
    
    print(f"\n4. H³(ℤ/2ℤ, ℤ/2ℤ):")
    h3 = compute_h3_order(2)
    for k, v in h3.items():
        print(f"   {k}: {v}")
    
    print(f"\n5. Defect accumulation for subtraction:")
    sub = lambda a, b: a - b
    for n in range(3, 8):
        vals = [5.0] * n
        left, right, diff = defect_accumulation(vals, sub)
        print(f"   n={n}: left={left:.0f}, right={right:.0f}, diff={diff:.0f}")
