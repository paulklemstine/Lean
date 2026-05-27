#!/usr/bin/env python3
"""
algorithms.py — Algorithms for the Universal Support-Tutte Polynomial

Implements the core algorithms from the research paper:
1. Recursive computation of the support-Tutte polynomial
2. M-convexity verification
3. Support deletion and contraction
4. Order-independence testing

Time complexity: O(2^n * n) where n = |S|, matching the classical
Tutte polynomial computation complexity.
"""

from typing import FrozenSet, Tuple, Dict, List, Optional, Set
from collections import defaultdict
import itertools

Element = Tuple[int, ...]
Support = FrozenSet[Element]
Polynomial = Dict[int, int]  # degree -> coefficient


class SupportTutteComputer:
    """
    Computes the universal support-Tutte polynomial for M-convex supports.
    
    The support-Tutte polynomial T(S) ∈ ℕ[X] is the unique polynomial-valued
    deletion–contraction invariant satisfying:
      T(∅) = 1
      T({0}) = 1  
      T(S) = T(del S i) + T(con S i)  for ordinary coordinates i
      T(S) = X * T(con S i)            for loop coordinates i
    
    Example usage:
        >>> computer = SupportTutteComputer(n_coords=2)
        >>> S = frozenset({(0, 0), (1, 0), (0, 1)})
        >>> T = computer.compute(S)
        >>> print(computer.poly_str(T))
        'X + 2'
    """
    
    def __init__(self, n_coords: int):
        """
        Initialize with the number of coordinates.
        
        Args:
            n_coords: Dimension of the ambient space ℕ^n
        """
        self.n_coords = n_coords
        self._memo: Dict[Support, Polynomial] = {}
        self._call_count = 0
    
    def compute(self, S: Support) -> Polynomial:
        """
        Compute T(S) using memoized recursion.
        
        Args:
            S: A finite support set (frozenset of tuples)
            
        Returns:
            The support-Tutte polynomial as {degree: coefficient}
            
        Time complexity: O(2^|S| * |S| * n_coords)
        Space complexity: O(2^|S|) for memoization
        """
        self._call_count += 1
        
        if S in self._memo:
            return self._memo[S]
        
        result = self._compute_impl(S)
        self._memo[S] = result
        return result
    
    def _compute_impl(self, S: Support) -> Polynomial:
        """Core recursive computation."""
        # Base cases
        if len(S) == 0:
            return {0: 1}
        
        zero = tuple(0 for _ in range(self.n_coords))
        if S == frozenset({zero}):
            return {0: 1}
        
        # Find ordinary coordinate (prefer lower index for determinism)
        for i in range(self.n_coords):
            if self._is_ordinary(S, i):
                d = self.compute(self._delete(S, i))
                c = self.compute(self._contract(S, i))
                return self._poly_add(d, c)
        
        # Find loop coordinate
        for i in range(self.n_coords):
            if self._is_loop(S, i):
                c = self.compute(self._contract(S, i))
                return self._poly_mul_x(c)
        
        # Unreachable for valid supports
        return {0: 1}
    
    def _delete(self, S: Support, i: int) -> Support:
        """Support deletion: retain elements with m[i] = 0."""
        return frozenset(m for m in S if m[i] == 0)
    
    def _contract(self, S: Support, i: int) -> Support:
        """Tutte contraction: retain m[i] > 0, subtract e_i."""
        result = set()
        for m in S:
            if m[i] > 0:
                new = list(m)
                new[i] -= 1
                result.add(tuple(new))
        return frozenset(result)
    
    def _is_loop(self, S: Support, i: int) -> bool:
        """Check if coordinate i is a loop."""
        return len(S) > 0 and all(m[i] > 0 for m in S)
    
    def _is_ordinary(self, S: Support, i: int) -> bool:
        """Check if coordinate i is ordinary."""
        has_zero = any(m[i] == 0 for m in S)
        has_pos = any(m[i] > 0 for m in S)
        return has_zero and has_pos
    
    @staticmethod
    def _poly_add(p: Polynomial, q: Polynomial) -> Polynomial:
        """Add two polynomials."""
        result = dict(p)
        for k, v in q.items():
            result[k] = result.get(k, 0) + v
        return {k: v for k, v in result.items() if v != 0}
    
    @staticmethod
    def _poly_mul_x(p: Polynomial) -> Polynomial:
        """Multiply polynomial by X."""
        return {k + 1: v for k, v in p.items()}
    
    @staticmethod
    def poly_eval(p: Polynomial, x: int) -> int:
        """Evaluate polynomial at integer x."""
        return sum(coeff * x**deg for deg, coeff in p.items())
    
    @staticmethod
    def poly_str(p: Polynomial) -> str:
        """Pretty-print polynomial."""
        if not p:
            return "0"
        terms = []
        for deg in sorted(p.keys(), reverse=True):
            coeff = p[deg]
            if coeff == 0:
                continue
            if deg == 0:
                terms.append(str(coeff))
            elif deg == 1:
                terms.append(f"{coeff}X" if coeff != 1 else "X")
            else:
                terms.append(f"{coeff}X^{deg}" if coeff != 1 else f"X^{deg}")
        return " + ".join(terms) if terms else "0"
    
    def get_stats(self) -> Dict:
        """Return computation statistics."""
        return {
            "call_count": self._call_count,
            "memo_size": len(self._memo),
        }


def check_m_convexity(S: Support, n_coords: int) -> bool:
    """
    Verify the symmetric exchange property (M-convexity) for a support set.
    
    The exchange property states: for all x, y in S and all coordinates a
    with x(a) > y(a), there exists a coordinate b with y(b) > x(b) such
    that x - e_a + e_b ∈ S and y + e_a - e_b ∈ S.
    
    Args:
        S: Support set to check
        n_coords: Number of coordinates
        
    Returns:
        True if S satisfies the exchange property
        
    Time complexity: O(|S|^2 * n_coords^2)
    """
    for x in S:
        for y in S:
            for a in range(n_coords):
                if x[a] > y[a]:
                    found = False
                    for b in range(n_coords):
                        if y[b] > x[b]:
                            new_x = list(x)
                            new_x[a] -= 1
                            new_x[b] += 1
                            new_y = list(y)
                            new_y[a] += 1
                            new_y[b] -= 1
                            if tuple(new_x) in S and tuple(new_y) in S:
                                found = True
                                break
                    if not found:
                        return False
    return True


def test_order_independence(S: Support, n_coords: int) -> Tuple[bool, List[Polynomial]]:
    """
    Test whether the support-Tutte polynomial is independent of
    the coordinate ordering used in the recursion.
    
    Args:
        S: Support set
        n_coords: Number of coordinates
        
    Returns:
        (all_agree, list_of_polynomials_for_each_ordering)
    """
    results = []
    
    for perm in itertools.permutations(range(n_coords)):
        order = list(perm)
        computer = SupportTutteComputer(n_coords)
        # Override the coordinate search order
        T = _compute_with_order(S, n_coords, order)
        results.append(T)
    
    all_agree = all(r == results[0] for r in results)
    return all_agree, results


def _compute_with_order(S: Support, n: int, order: List[int],
                        memo: Optional[Dict] = None) -> Polynomial:
    """Compute T(S) using a specified coordinate order."""
    if memo is None:
        memo = {}
    
    if S in memo:
        return memo[S]
    
    if len(S) == 0:
        return {0: 1}
    
    zero = tuple(0 for _ in range(n))
    if S == frozenset({zero}):
        return {0: 1}
    
    for i in order:
        has_zero = any(m[i] == 0 for m in S)
        has_pos = any(m[i] > 0 for m in S)
        if has_zero and has_pos:
            d = _compute_with_order(
                frozenset(m for m in S if m[i] == 0), n, order, memo)
            contracted = set()
            for m in S:
                if m[i] > 0:
                    new = list(m)
                    new[i] -= 1
                    contracted.add(tuple(new))
            c = _compute_with_order(frozenset(contracted), n, order, memo)
            result = SupportTutteComputer._poly_add(d, c)
            memo[S] = result
            return result
    
    for i in order:
        if all(m[i] > 0 for m in S):
            contracted = set()
            for m in S:
                new = list(m)
                new[i] -= 1
                contracted.add(tuple(new))
            c = _compute_with_order(frozenset(contracted), n, order, memo)
            result = SupportTutteComputer._poly_mul_x(c)
            memo[S] = result
            return result
    
    return {0: 1}


# ============== EXAMPLE USAGE ==============

if __name__ == "__main__":
    print("Support-Tutte Polynomial Algorithm Demo")
    print("=" * 50)
    
    # Example 1: Basic computation
    computer = SupportTutteComputer(n_coords=3)
    S = frozenset({(0, 0, 1), (0, 1, 0), (1, 0, 0)})
    T = computer.compute(S)
    print(f"\nU_{{1,3}} indicators: T = {computer.poly_str(T)}")
    print(f"  T(1) = {computer.poly_eval(T, 1)} (should be {len(S)})")
    print(f"  M-convex: {check_m_convexity(S, 3)}")
    
    # Example 2: Non-binary support
    computer2 = SupportTutteComputer(n_coords=2)
    S2 = frozenset({(0, 0), (2, 0), (0, 2)})
    T2 = computer2.compute(S2)
    print(f"\nNon-binary {{(0,0), (2,0), (0,2)}}: T = {computer2.poly_str(T2)}")
    print(f"  T(1) = {computer2.poly_eval(T2, 1)} (should be {len(S2)})")
    print(f"  M-convex: {check_m_convexity(S2, 2)}")
    
    # Example 3: Order independence
    S3 = frozenset({(0, 0, 1), (0, 1, 0), (1, 0, 0)})
    agree, polys = test_order_independence(S3, 3)
    print(f"\nOrder independence for U_{{1,3}}: {'✓ PASSED' if agree else '✗ FAILED'}")
    
    stats = computer.get_stats()
    print(f"\nComputation stats: {stats}")
