#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for support-Tutte polynomial computation.

Implements the recursive deletion-contraction algorithm with memoization,
M-convexity verification, and activity counting.
"""

from typing import Set, Tuple, Dict, List, Optional, FrozenSet
from itertools import combinations, permutations
from collections import defaultdict

ExponentVector = Tuple[int, ...]
Poly = Dict[int, int]


# ============================================================
# Polynomial arithmetic
# ============================================================

def poly_zero() -> Poly:
    """The zero polynomial."""
    return {}

def poly_one() -> Poly:
    """The constant polynomial 1."""
    return {0: 1}

def poly_var() -> Poly:
    """The variable X."""
    return {1: 1}

def poly_add(p: Poly, q: Poly) -> Poly:
    """Add two polynomials."""
    result = dict(p)
    for deg, coeff in q.items():
        result[deg] = result.get(deg, 0) + coeff
    return {k: v for k, v in result.items() if v != 0}

def poly_mul(p: Poly, q: Poly) -> Poly:
    """Multiply two polynomials."""
    result: Poly = {}
    for d1, c1 in p.items():
        for d2, c2 in q.items():
            d = d1 + d2
            result[d] = result.get(d, 0) + c1 * c2
    return {k: v for k, v in result.items() if v != 0}

def poly_eval(p: Poly, x: int) -> int:
    """Evaluate polynomial at integer x."""
    return sum(c * x**d for d, c in p.items())

def poly_str(p: Poly) -> str:
    """Pretty-print a polynomial."""
    if not p:
        return "0"
    terms = []
    for d in sorted(p.keys(), reverse=True):
        c = p[d]
        if d == 0:
            terms.append(str(c))
        elif d == 1:
            terms.append(f"{c}*X" if abs(c) != 1 else ("X" if c > 0 else "-X"))
        else:
            terms.append(f"{c}*X^{d}" if abs(c) != 1 else (f"X^{d}" if c > 0 else f"-X^{d}"))
    return " + ".join(terms).replace("+ -", "- ")


# ============================================================
# Support operations
# ============================================================

def support_delete(S: Set[ExponentVector], i: int) -> Set[ExponentVector]:
    """Delete coordinate i: retain elements with v[i] = 0."""
    return {v for v in S if v[i] == 0}

def support_contract(S: Set[ExponentVector], i: int) -> Set[ExponentVector]:
    """Tutte-style contraction at coordinate i: retain elements with
    v[i] > 0, subtract 1 from coordinate i."""
    result = set()
    for v in S:
        if v[i] > 0:
            w = list(v)
            w[i] -= 1
            result.add(tuple(w))
    return result

def is_loop(S: Set[ExponentVector], i: int) -> bool:
    """Check if coordinate i is a loop (all elements positive)."""
    return len(S) > 0 and all(v[i] > 0 for v in S)

def is_ordinary(S: Set[ExponentVector], i: int) -> bool:
    """Check if coordinate i is ordinary (both zero and positive values exist)."""
    has_zero = any(v[i] == 0 for v in S)
    has_pos = any(v[i] > 0 for v in S)
    return has_zero and has_pos

def is_trivial_coord(S: Set[ExponentVector], i: int) -> bool:
    """Check if coordinate i is trivial (all elements zero)."""
    return all(v[i] == 0 for v in S)


# ============================================================
# M-convexity verification
# ============================================================

def check_mconvexity(S: Set[ExponentVector]) -> bool:
    """Verify the symmetric exchange property (M-convexity).
    
    For every x, y in S and coordinate a with x[a] > y[a],
    there exists b with y[b] > x[b] such that both
    x - e_a + e_b and y + e_a - e_b are in S.
    
    Time complexity: O(|S|^2 * n^2) where n is the dimension.
    """
    if len(S) <= 1:
        return True
    
    n = len(next(iter(S)))
    for x in S:
        for y in S:
            for a in range(n):
                if x[a] > y[a]:
                    found = False
                    for b in range(n):
                        if y[b] > x[b]:
                            x_new = list(x)
                            x_new[a] -= 1
                            x_new[b] += 1
                            y_new = list(y)
                            y_new[a] += 1
                            y_new[b] -= 1
                            if tuple(x_new) in S and tuple(y_new) in S:
                                found = True
                                break
                    if not found:
                        return False
    return True


# ============================================================
# Support-Tutte polynomial computation
# ============================================================

class SupportTutteComputer:
    """Memoized computation of the support-Tutte polynomial.
    
    Algorithm:
        Recursive deletion-contraction with memoization.
        At each step, choose the first ordinary or loop coordinate.
    
    Correctness:
        Formally verified in Lean 4 (see SupportTutteUniversality.lean).
        The universality theorem proves this recursion produces the
        unique invariant satisfying the deletion-contraction rules.
    
    Complexity:
        Time: O(2^k) where k = number of ordinary coordinates
        Space: O(2^k) for memoization table
    """
    
    def __init__(self):
        self.memo: Dict[FrozenSet[ExponentVector], Poly] = {}
        self.call_count = 0
    
    def compute(self, S: Set[ExponentVector]) -> Poly:
        """Compute T(S) with memoization."""
        self.call_count += 1
        key = frozenset(S)
        
        if key in self.memo:
            return self.memo[key]
        
        result = self._compute_impl(S)
        self.memo[key] = result
        return result
    
    def _compute_impl(self, S: Set[ExponentVector]) -> Poly:
        if not S:
            return poly_one()
        
        n = len(next(iter(S)))
        zero = tuple([0] * n)
        if S == {zero}:
            return poly_one()
        
        # Try ordinary coordinates first
        for i in range(n):
            if is_ordinary(S, i):
                d = support_delete(S, i)
                c = support_contract(S, i)
                return poly_add(self.compute(d), self.compute(c))
        
        # Then loop coordinates
        for i in range(n):
            if is_loop(S, i):
                c = support_contract(S, i)
                return poly_mul(poly_var(), self.compute(c))
        
        return poly_one()
    
    def activity_data(self, S: Set[ExponentVector]) -> Dict[str, int]:
        """Count loops, ordinary, and trivial coordinates."""
        if not S:
            return {"loops": 0, "ordinary": 0, "trivial": 0}
        
        n = len(next(iter(S)))
        loops = sum(1 for i in range(n) if is_loop(S, i))
        ordinary = sum(1 for i in range(n) if is_ordinary(S, i))
        trivial = sum(1 for i in range(n) if is_trivial_coord(S, i))
        return {"loops": loops, "ordinary": ordinary, "trivial": trivial}


def compute_support_tutte(S: Set[ExponentVector]) -> Poly:
    """Convenience function to compute T(S)."""
    computer = SupportTutteComputer()
    return computer.compute(S)


# ============================================================
# Order-independence verification
# ============================================================

def verify_order_independence(S: Set[ExponentVector],
                              verbose: bool = False) -> bool:
    """Verify that the support-Tutte polynomial is independent of
    the coordinate processing order.
    
    Tests all n! permutations of coordinates.
    """
    if not S:
        return True
    
    n = len(next(iter(S)))
    results = set()
    
    for perm in permutations(range(n)):
        memo: Dict[FrozenSet, Poly] = {}
        T = _compute_with_order(S, list(perm), memo)
        results.add(frozenset(T.items()))
        if verbose:
            print(f"  Order {list(perm)}: {poly_str(T)}")
    
    return len(results) == 1


def _compute_with_order(S: Set[ExponentVector],
                         order: List[int],
                         memo: Dict) -> Poly:
    """Compute T(S) with a specified coordinate processing order."""
    key = frozenset(S)
    if key in memo:
        return memo[key]
    
    if not S:
        return poly_one()
    
    n = len(next(iter(S)))
    zero = tuple([0] * n)
    if S == {zero}:
        return poly_one()
    
    for i in order:
        if is_ordinary(S, i):
            d = support_delete(S, i)
            c = support_contract(S, i)
            new_order = [j for j in order if j != i]
            result = poly_add(
                _compute_with_order(d, new_order, memo),
                _compute_with_order(c, new_order, memo)
            )
            memo[key] = result
            return result
    
    for i in order:
        if is_loop(S, i):
            c = support_contract(S, i)
            new_order = [j for j in order if j != i]
            result = poly_mul(poly_var(), _compute_with_order(c, new_order, memo))
            memo[key] = result
            return result
    
    return poly_one()


# ============================================================
# Enumeration tools
# ============================================================

def simplex_support(n: int, d: int) -> Set[ExponentVector]:
    """Generate all vectors in N^n summing to d."""
    if n == 1:
        return {(d,)}
    result = set()
    for k in range(d + 1):
        for rest in simplex_support(n - 1, d - k):
            result.add((k,) + rest)
    return result

def enumerate_mconvex_subsets(S: Set[ExponentVector],
                               min_size: int = 2) -> List[Set[ExponentVector]]:
    """Find all M-convex subsets of S with at least min_size elements."""
    results = []
    for r in range(min_size, len(S) + 1):
        for subset in combinations(S, r):
            sub = set(subset)
            if check_mconvexity(sub):
                results.append(sub)
    return results


if __name__ == "__main__":
    # Quick self-test
    print("Self-test of algorithms.py")
    
    S = simplex_support(3, 2)
    computer = SupportTutteComputer()
    T = computer.compute(S)
    print(f"Simplex(3,2): T = {poly_str(T)}, T(1) = {poly_eval(T, 1)}, |S| = {len(S)}")
    assert poly_eval(T, 1) == len(S), "Cardinality check failed!"
    
    assert verify_order_independence(S), "Order independence failed!"
    
    print("All self-tests passed!")
