#!/usr/bin/env python3
"""
Algorithms for computing support-Tutte polynomials.

Implements:
  1. Recursive deletion-contraction evaluation (exact)
  2. Memoized version with canonical hashing
  3. Activity-based expansion
  4. Symbolic polynomial computation using sympy
"""

from typing import Set, Tuple, FrozenSet, Dict, Optional, List
from functools import lru_cache
from collections import defaultdict


# ──────────────────────────────────────────────────────────────────
# Core Data Structures
# ──────────────────────────────────────────────────────────────────

class GroundSupport:
    """
    A ground support: (supp, ground) where supp ⊆ ℕ^n is a finite set of
    nonneg integer vectors and ground ⊆ {0,...,n-1} is the active coordinate set.

    Invariant: for all m in supp, m[i] ≠ 0 ⟹ i ∈ ground.

    Time complexity of operations:
      - delete(e): O(|supp|)
      - contract(e): O(|supp|)
      - is_loop(e): O(|supp|)
      - is_coloop(e): O(|supp|)
    """

    def __init__(self, supp: FrozenSet[Tuple[int, ...]], ground: FrozenSet[int]):
        self.supp = supp
        self.ground = ground
        self._hash = hash((self.supp, self.ground))

    @classmethod
    def from_sets(cls, supp: Set[Tuple[int, ...]], ground: Set[int]) -> 'GroundSupport':
        return cls(frozenset(supp), frozenset(ground))

    def __hash__(self):
        return self._hash

    def __eq__(self, other):
        return self.supp == other.supp and self.ground == other.ground

    def __repr__(self):
        return f"GS(|supp|={len(self.supp)}, |ground|={len(self.ground)})"

    def delete(self, e: int) -> 'GroundSupport':
        """Deletion: keep m with m[e] = 0, remove e from ground. O(|supp|)."""
        new_supp = frozenset(m for m in self.supp if m[e] == 0)
        return GroundSupport(new_supp, self.ground - {e})

    def min_coord(self, e: int) -> int:
        """Min value at coordinate e. O(|supp|)."""
        return min((m[e] for m in self.supp), default=0)

    def contract(self, e: int) -> 'GroundSupport':
        """Contraction: filter to min at e, shift, remove e. O(|supp|)."""
        mc = self.min_coord(e)
        filtered = [m for m in self.supp if m[e] == mc]
        shifted = frozenset(
            tuple(v - mc if j == e else v for j, v in enumerate(m))
            for m in filtered
        )
        return GroundSupport(shifted, self.ground - {e})

    def is_loop(self, e: int) -> bool:
        """All elements have m[e] > 0. O(|supp|)."""
        return bool(self.supp) and all(m[e] > 0 for m in self.supp)

    def is_coloop(self, e: int) -> bool:
        """All elements share the same m[e] value. O(|supp|)."""
        if not self.supp:
            return False
        vals = {m[e] for m in self.supp}
        return len(vals) == 1


# ──────────────────────────────────────────────────────────────────
# Algorithm 1: Basic Recursive Evaluation
# ──────────────────────────────────────────────────────────────────

def tutte_eval_recursive(S: GroundSupport, a: int = 1, b: int = 1) -> int:
    """
    Compute T(S; a, b) via the uniform deletion-contraction recurrence.

    T(S) = 1                                    if ground = ∅
    T(S) = a · T(S\\e) + b · T(S/e)            otherwise

    Time: O(2^|ground|) worst case (exponential in ground set size).
    Space: O(|ground|) stack depth.

    Result: always equals (a + b)^|ground| (Power Law theorem).
    """
    if not S.ground:
        return 1
    e = min(S.ground)
    return a * tutte_eval_recursive(S.delete(e), a, b) + \
           b * tutte_eval_recursive(S.contract(e), a, b)


# ──────────────────────────────────────────────────────────────────
# Algorithm 2: Memoized Evaluation
# ──────────────────────────────────────────────────────────────────

def tutte_eval_memoized(S: GroundSupport, a: int = 1, b: int = 1,
                         memo: Optional[Dict] = None) -> int:
    """
    Memoized version: caches results by canonical support representation.

    Time: O(|distinct sub-supports| · |supp|) with memoization.
    Space: O(|distinct sub-supports|).
    """
    if memo is None:
        memo = {}
    key = (S.supp, S.ground, a, b)
    if key in memo:
        return memo[key]
    if not S.ground:
        result = 1
    else:
        e = min(S.ground)
        result = a * tutte_eval_memoized(S.delete(e), a, b, memo) + \
                 b * tutte_eval_memoized(S.contract(e), a, b, memo)
    memo[key] = result
    return result


# ──────────────────────────────────────────────────────────────────
# Algorithm 3: 4-Parameter Case-Dependent Evaluation
# ──────────────────────────────────────────────────────────────────

def tutte_eval_4param(S: GroundSupport, x: int = 1, y: int = 1,
                       u: int = 1, v: int = 1) -> int:
    """
    Case-dependent 4-parameter evaluation.

    T(S) = 1                                    if ground = ∅
    T(S) = y · T(S\\e)                          if e is a loop
    T(S) = x · T(S/e)                           if e is a coloop
    T(S) = u · T(S\\e) + v · T(S/e)            if e is ordinary

    The loop/coloop classification makes this non-trivial: different
    supports with the same ground set may get different T₄ values.

    Time: O(|ground|) per path (no branching since ordinary del = con).
    """
    if not S.ground:
        return 1
    e = min(S.ground)
    if S.is_loop(e):
        return y * tutte_eval_4param(S.delete(e), x, y, u, v)
    elif S.is_coloop(e):
        return x * tutte_eval_4param(S.contract(e), x, y, u, v)
    else:
        return u * tutte_eval_4param(S.delete(e), x, y, u, v) + \
               v * tutte_eval_4param(S.contract(e), x, y, u, v)


# ──────────────────────────────────────────────────────────────────
# Algorithm 4: Activity Expansion
# ──────────────────────────────────────────────────────────────────

def compute_activity_data(S: GroundSupport) -> Dict[str, int]:
    """
    Compute the activity data for a ground support under canonical ordering.

    Returns dict with keys: 'loops', 'coloops', 'ordinary', 'total'.
    Each counts how many coordinates fall into each category during
    the canonical (min-first) recursion.

    Time: O(|ground| · |supp|).
    """
    loops = 0
    coloops = 0
    ordinary = 0
    current = S
    while current.ground:
        e = min(current.ground)
        if current.is_loop(e):
            loops += 1
            current = current.delete(e)
        elif current.is_coloop(e):
            coloops += 1
            current = current.contract(e)
        else:
            ordinary += 1
            # For ordinary elements, delete = contract (since min = 0)
            current = current.delete(e)
    return {'loops': loops, 'coloops': coloops, 'ordinary': ordinary,
            'total': loops + coloops + ordinary}


def tutte_from_activity(activity: Dict[str, int], x=1, y=1, u=1, v=1) -> int:
    """
    Compute T₄ from activity data. Since the recursion never branches,
    T₄ = x^coloops · y^loops · (u+v)^ordinary.

    Time: O(1) given activity data.
    """
    return (x ** activity['coloops'] *
            y ** activity['loops'] *
            (u + v) ** activity['ordinary'])


# ──────────────────────────────────────────────────────────────────
# Support Constructors
# ──────────────────────────────────────────────────────────────────

def simplex_support(n: int, d: int) -> GroundSupport:
    """Degree-d simplex on n variables: {x ∈ ℕ^n : Σx_i = d}."""
    def gen(rv, rs):
        if rv == 1: yield (rs,); return
        for val in range(rs + 1):
            for rest in gen(rv - 1, rs - val): yield (val,) + rest
    return GroundSupport.from_sets(set(gen(n, d)), set(range(n)))


def uniform_matroid_support(n: int, k: int) -> GroundSupport:
    """U(k,n) uniform matroid indicator vectors."""
    from itertools import combinations
    supp = {tuple(1 if i in B else 0 for i in range(n))
            for B in combinations(range(n), k)}
    return GroundSupport.from_sets(supp, set(range(n)))


# ──────────────────────────────────────────────────────────────────
# Example Usage
# ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Algorithm 1: Basic recursive
    S = simplex_support(4, 3)
    print(f"Simplex Δ(4,3): |supp|={len(S.supp)}, |ground|={len(S.ground)}")
    print(f"  Recursive T(1,1) = {tutte_eval_recursive(S, 1, 1)}")
    print(f"  Memoized  T(1,1) = {tutte_eval_memoized(S, 1, 1)}")
    print(f"  Expected  (1+1)^4 = {2**4}")

    # Algorithm 3: 4-parameter
    print(f"\n  T₄(x=2,y=3,u=1,v=1) = {tutte_eval_4param(S, 2, 3, 1, 1)}")

    # Algorithm 4: Activity expansion
    act = compute_activity_data(S)
    print(f"\n  Activity data: {act}")
    print(f"  T₄ from activity: {tutte_from_activity(act, 2, 3, 1, 1)}")
    print(f"  Matches direct: {tutte_eval_4param(S, 2, 3, 1, 1) == tutte_from_activity(act, 2, 3, 1, 1)}")

    # Comparison table
    print(f"\n{'Support':<20} {'Loops':>5} {'Colps':>5} {'Ord':>5} {'T₄(5,3,2,7)':>12}")
    print(f"{'─'*20} {'─'*5} {'─'*5} {'─'*5} {'─'*12}")
    for n in range(2, 6):
        for k in range(1, n):
            S = uniform_matroid_support(n, k)
            act = compute_activity_data(S)
            val = tutte_from_activity(act, 5, 3, 2, 7)
            print(f"U({k},{n}){'':<14} {act['loops']:>5} {act['coloops']:>5} {act['ordinary']:>5} {val:>12}")
