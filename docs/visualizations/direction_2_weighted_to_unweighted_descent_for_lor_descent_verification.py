#!/usr/bin/env python3
"""
algorithms.py — Verified Algorithms for Shadow Computation

Implements the descent pipeline algorithms with correctness guarantees:
1. Weighted shadow computation W_k
2. Unweighted shadow computation Sh_k  
3. Weight ratio computation r_k
4. Descent inequality verification

All algorithms are proven to terminate (they iterate over finite sets)
and their outputs match the formal definitions in the Lean proofs.

Complexity Analysis:
- W_k computation: O(C(n,k) * |bases| * k) time, O(|bases|) space
- Sh_k computation: O(C(n,k) * |bases| * k) time, O(|bases|) space
- Full profile: O(sum_{k=0}^r C(n,k) * |bases| * k) time
"""

from itertools import combinations
from typing import List, Set, Tuple, Dict, Optional
from math import comb, factorial


def descending_factorial(x: int, k: int) -> int:
    """
    Compute the descending factorial x^{\\underline{k}} = x(x-1)...(x-k+1).
    
    Correctness: Matches Nat.descFactorial in Lean/Mathlib.
    Termination: Loop runs exactly k iterations.
    Complexity: O(k) time, O(1) space.
    
    >>> descending_factorial(5, 3)
    60
    >>> descending_factorial(10, 0)
    1
    """
    if k < 0 or k > x:
        return 0
    result = 1
    for i in range(k):
        result *= (x - i)
    return result


def verify_descFactorial_log_concavity(x: int, k: int) -> bool:
    """
    Verify the descending factorial log-concavity inequality:
    (x^{\\underline{k}})^2 >= x^{\\underline{k-1}} * x^{\\underline{k+1}}
    
    This is Theorem descFactorial_sq_ge in the Lean formalization.
    
    >>> verify_descFactorial_log_concavity(5, 2)
    True
    """
    if k < 1 or x < k + 1:
        return True  # vacuously true outside valid range
    lhs = descending_factorial(x, k) ** 2
    rhs = descending_factorial(x, k - 1) * descending_factorial(x, k + 1)
    return lhs >= rhs


class ShadowComputer:
    """
    Computes weighted and unweighted shadow cardinalities for
    multivariate polynomials represented by their support.
    
    The polynomial is specified by its support: a set of exponent vectors
    (tuples of non-negative integers). For matroid basis polynomials,
    each exponent vector is the indicator of a basis.
    
    Algorithm:
        For each k-element multi-index γ:
            1. Compute the iterated partial derivative D^γ f
            2. Count |supp(D^γ f)| for W_k
            3. Check if supp(D^γ f) ≠ ∅ for Sh_k
    
    Termination: The outer loop iterates over C(n,k) multi-indices.
                 The inner loop iterates over |support| monomials.
                 Both are finite.
    
    Correctness: The iterated derivative D^γ f of a polynomial with
                 support S removes elements of γ from each monomial in S.
                 This matches the formal definition in IteratedShadowGeometry.
    """
    
    def __init__(self, support: Set[Tuple[int, ...]], n: int):
        """
        Initialize with the support of the polynomial.
        
        Args:
            support: Set of tuples, each representing a monomial
                     (sorted tuple of variable indices with repetition)
            n: Number of variables
        """
        self.support = support
        self.n = n
    
    def derivative_support(self, gamma: Tuple[int, ...]) -> Set[Tuple[int, ...]]:
        """
        Compute the support of D^gamma f.
        
        For each monomial α in support, if γ ≤ α (componentwise),
        then α - γ is in the support of D^γ f.
        
        Complexity: O(|support| * |gamma|) per call.
        """
        result = set()
        for monomial in self.support:
            remaining = list(monomial)
            valid = True
            for v in gamma:
                if v in remaining:
                    remaining.remove(v)
                else:
                    valid = False
                    break
            if valid:
                result.add(tuple(sorted(remaining)))
        return result
    
    def weighted_shadow(self, k: int) -> int:
        """
        Compute W_k = Σ_{|γ|=k} |supp(D^γ f)|.
        
        Complexity: O(C(n,k) * |support| * k).
        """
        total = 0
        for gamma in combinations(range(self.n), k):
            total += len(self.derivative_support(gamma))
        return total
    
    def unweighted_shadow(self, k: int) -> int:
        """
        Compute Sh_k = |{γ : |γ|=k, D^γ f ≠ 0}|.
        
        Complexity: O(C(n,k) * |support| * k).
        """
        total = 0
        for gamma in combinations(range(self.n), k):
            if len(self.derivative_support(gamma)) > 0:
                total += 1
        return total
    
    def weight_ratio(self, k: int) -> float:
        """
        Compute r_k = W_k / Sh_k.
        
        Returns 0 if Sh_k = 0.
        """
        w = self.weighted_shadow(k)
        s = self.unweighted_shadow(k)
        return w / s if s > 0 else 0.0
    
    def full_profile(self, max_k: int) -> Dict[str, List]:
        """
        Compute the full shadow profile up to order max_k.
        
        Returns a dictionary with keys 'W', 'Sh', 'r' containing
        the weighted, unweighted, and ratio sequences.
        
        Complexity: O(Σ_{k=0}^{max_k} C(n,k) * |support| * k).
        """
        W = []
        Sh = []
        r = []
        for k in range(max_k + 1):
            w = self.weighted_shadow(k)
            s = self.unweighted_shadow(k)
            W.append(w)
            Sh.append(s)
            r.append(w / s if s > 0 else 0.0)
        return {'W': W, 'Sh': Sh, 'r': r}


def verify_descent_inequality(W: float, Wm: float, Wp: float,
                                r: float, rm: float, rp: float) -> Dict:
    """
    Verify the abstract descent inequality.
    
    Given W, W_-, W_+ (weighted) and r, r_-, r_+ (ratios),
    computes S = W/r etc. and checks S^2 >= S_- * S_+.
    
    This implements the core check of Theorem descent_inequality.
    
    Returns a dict with the computed values and verification results.
    """
    S = W / r
    Sm = Wm / rm
    Sp = Wp / rp
    
    w_lc = W**2 >= Wm * Wp
    r_lcv = r**2 <= rm * rp
    s_lc = S**2 >= Sm * Sp - 1e-10
    
    return {
        'S': (Sm, S, Sp),
        'W_log_concave': w_lc,
        'r_log_convex': r_lcv,
        'S_log_concave': s_lc,
        'descent_applicable': w_lc and r_lcv,
        'descent_verified': w_lc and r_lcv and s_lc,
    }


def matroid_bases_uniform(k: int, n: int) -> Set[Tuple[int, ...]]:
    """Bases of the uniform matroid U_{k,n}."""
    return set(combinations(range(n), k))


if __name__ == "__main__":
    # Example usage
    print("=== Descending Factorial Log-Concavity ===")
    for x in [5, 10, 20]:
        for k in range(1, x):
            assert verify_descFactorial_log_concavity(x, k), f"Failed for x={x}, k={k}"
    print("All descending factorial tests passed!")
    
    print("\n=== Shadow Computation for U_{3,6} ===")
    bases = matroid_bases_uniform(3, 6)
    sc = ShadowComputer(bases, 6)
    profile = sc.full_profile(3)
    print(f"W_k:  {profile['W']}")
    print(f"Sh_k: {profile['Sh']}")
    print(f"r_k:  {[f'{x:.2f}' for x in profile['r']]}")
    
    print("\n=== Descent Inequality Verification ===")
    result = verify_descent_inequality(
        W=8.0, Wm=10.0, Wp=5.0,
        r=1.5, rm=2.0, rp=1.2
    )
    print(f"Descent applicable: {result['descent_applicable']}")
    print(f"Descent verified: {result['descent_verified']}")
    print(f"Computed S: {result['S']}")
