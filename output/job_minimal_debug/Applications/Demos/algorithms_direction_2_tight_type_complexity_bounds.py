#!/usr/bin/env python3
"""
Algorithms for Type Complexity Bounds

Implements the core algorithms from the research paper:
1. Type state bound computation
2. Branch complexity computation
3. Iterated endomorphism tower analysis
4. Lambda term enumeration and quotient size computation
5. Growth rate analysis

All algorithms have documented time and space complexity.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Union, List, Set, Tuple, Optional, Iterator
from collections import deque
import math


# ============================================================
# Type System
# ============================================================

@dataclass(frozen=True)
class Base:
    """Base type 'o'."""
    def __repr__(self) -> str:
        return "o"

@dataclass(frozen=True)
class Arrow:
    """Arrow type A → B."""
    left: Ty
    right: Ty
    def __repr__(self) -> str:
        l = f"({self.left})" if isinstance(self.left, Arrow) else str(self.left)
        return f"{l} → {self.right}"

Ty = Union[Base, Arrow]


# ============================================================
# Algorithm 1: Type State Bound
# ============================================================

def type_state_bound(ty: Ty) -> int:
    """
    Compute the type state bound.

    typeStateBound(base) = 1
    typeStateBound(A → B) = (typeStateBound(A) + 1) * (typeStateBound(B) + 1)

    Time: O(|ty|) where |ty| is the number of nodes in the type tree.
    Space: O(depth(ty)) for the recursion stack.

    >>> type_state_bound(Base())
    1
    >>> type_state_bound(Arrow(Base(), Base()))
    4
    """
    if isinstance(ty, Base):
        return 1
    return (type_state_bound(ty.left) + 1) * (type_state_bound(ty.right) + 1)


# ============================================================
# Algorithm 2: Branch Complexity
# ============================================================

def branch_complexity(ty: Ty) -> int:
    """
    Compute the branch complexity (additive node count).

    branchComplexity(base) = 1
    branchComplexity(A → B) = branchComplexity(A) + branchComplexity(B)

    Time: O(|ty|).
    Space: O(depth(ty)).

    >>> branch_complexity(Base())
    1
    >>> branch_complexity(Arrow(Base(), Base()))
    2
    """
    if isinstance(ty, Base):
        return 1
    return branch_complexity(ty.left) + branch_complexity(ty.right)


# ============================================================
# Algorithm 3: All Standard Type Measures
# ============================================================

def type_measures(ty: Ty) -> dict:
    """
    Compute all type complexity measures at once.

    Returns dict with keys: state_bound, complexity, size, depth, branch_complexity.

    Time: O(|ty|).

    >>> m = type_measures(Arrow(Base(), Base()))
    >>> m['state_bound']
    4
    >>> m['complexity']
    4
    >>> m['state_bound'] == m['complexity']
    True
    """
    if isinstance(ty, Base):
        return {
            'state_bound': 1,
            'complexity': 1,
            'size': 1,
            'depth': 0,
            'branch_complexity': 1,
        }
    lm = type_measures(ty.left)
    rm = type_measures(ty.right)
    return {
        'state_bound': (lm['state_bound'] + 1) * (rm['state_bound'] + 1),
        'complexity': (lm['complexity'] + 1) * (rm['complexity'] + 1),
        'size': 1 + lm['size'] + rm['size'],
        'depth': 1 + max(lm['depth'], rm['depth']),
        'branch_complexity': lm['branch_complexity'] + rm['branch_complexity'],
    }


# ============================================================
# Algorithm 4: Iterated Endomorphism Tower
# ============================================================

def iter_end_ty(n: int) -> Ty:
    """
    Construct iterEndTy(n).

    iterEndTy(0) = base
    iterEndTy(n+1) = iterEndTy(n) → iterEndTy(n)

    Time: O(2^n) for constructing the tree (it has 2^n leaves).

    >>> iter_end_ty(0)
    o
    >>> iter_end_ty(1)
    o → o
    """
    if n == 0:
        return Base()
    prev = iter_end_ty(n - 1)
    return Arrow(prev, prev)


def iter_end_bounds(n_max: int) -> List[int]:
    """
    Compute typeStateBound for iterEndTy(0), ..., iterEndTy(n_max).

    Uses the recurrence a(0) = 1, a(k+1) = (a(k) + 1)^2.
    This avoids constructing the exponentially large type trees.

    Time: O(n_max) arithmetic operations (but numbers grow doubly exponentially).
    Space: O(n_max) to store results.

    >>> iter_end_bounds(4)
    [1, 4, 25, 676, 458329]
    """
    bounds = [1]
    for _ in range(n_max):
        bounds.append((bounds[-1] + 1) ** 2)
    return bounds


def iter_end_branch_complexity(n: int) -> int:
    """
    Compute branchComplexity(iterEndTy(n)) = 2^n.

    Time: O(1) (using exponentiation).

    >>> iter_end_branch_complexity(5)
    32
    """
    return 2 ** n


# ============================================================
# Algorithm 5: Type Enumeration
# ============================================================

def enumerate_types(max_size: int) -> List[Ty]:
    """
    Enumerate all simple types up to a given size.

    Size is defined as: size(base) = 1, size(A → B) = 1 + size(A) + size(B).

    Time: O(C(max_size)) where C(n) is the n-th Catalan number (exponential).
    Space: O(C(max_size)).

    >>> len(enumerate_types(1))
    1
    >>> len(enumerate_types(3))
    2
    >>> len(enumerate_types(5))
    4
    """
    cache: dict[int, List[Ty]] = {}

    def types_of_size(s: int) -> List[Ty]:
        if s in cache:
            return cache[s]
        result = []
        if s == 1:
            result.append(Base())
        elif s >= 3:
            # size(A → B) = 1 + size(A) + size(B), so size(A) + size(B) = s - 1
            for sa in range(1, s - 1):
                sb = s - 1 - sa
                for a in types_of_size(sa):
                    for b in types_of_size(sb):
                        result.append(Arrow(a, b))
        cache[s] = result
        return result

    all_types = []
    for s in range(1, max_size + 1):
        all_types.extend(types_of_size(s))
    return all_types


# ============================================================
# Algorithm 6: Domination Verification
# ============================================================

def verify_domination(max_size: int = 9) -> bool:
    """
    Verify all domination theorems for types up to given size.

    Checks:
    - typeStateBound = complexity (identity)
    - branchComplexity ≤ typeStateBound
    - size ≤ typeStateBound
    - depth + 1 ≤ typeStateBound

    Returns True if all checks pass.

    >>> verify_domination(7)
    True
    """
    types = enumerate_types(max_size)
    for ty in types:
        m = type_measures(ty)
        if m['state_bound'] != m['complexity']:
            return False
        if m['branch_complexity'] > m['state_bound']:
            return False
        if m['size'] > m['state_bound']:
            return False
        if m['depth'] + 1 > m['state_bound']:
            return False
    return True


# ============================================================
# Algorithm 7: Growth Rate Analysis
# ============================================================

def analyze_growth(n_max: int = 10) -> List[dict]:
    """
    Analyze the growth rate of the endomorphism tower.

    For each level n, computes:
    - typeStateBound
    - branchComplexity (= 2^n)
    - ratio (stateBound / branchComplexity)
    - log_ratio (log10 of the ratio)

    >>> data = analyze_growth(3)
    >>> data[0]['state_bound']
    1
    >>> data[2]['state_bound']
    25
    """
    bounds = iter_end_bounds(n_max)
    results = []
    for n in range(n_max + 1):
        bc = 2 ** n
        ratio = bounds[n] / bc
        results.append({
            'n': n,
            'state_bound': bounds[n],
            'branch_complexity': bc,
            'ratio': ratio,
            'log_ratio': math.log10(ratio) if ratio > 0 else 0,
            'log_state_bound': math.log10(bounds[n]) if bounds[n] > 0 else 0,
        })
    return results


# ============================================================
# Algorithm 8: Arrow Amplification Check
# ============================================================

def arrow_amplification_factor(ty_a: Ty, ty_b: Ty) -> Tuple[float, float]:
    """
    Compute the amplification factors when forming A → B.

    Returns (factor_a, factor_b) where:
    - factor_a = typeStateBound(A → B) / typeStateBound(A)
    - factor_b = typeStateBound(A → B) / typeStateBound(B)

    Both factors are always > 1 (Theorem 8).

    >>> a, b = arrow_amplification_factor(Base(), Base())
    >>> a > 1 and b > 1
    True
    """
    sb_a = type_state_bound(ty_a)
    sb_b = type_state_bound(ty_b)
    sb_ab = type_state_bound(Arrow(ty_a, ty_b))
    return sb_ab / sb_a, sb_ab / sb_b


# ============================================================
# Main: Example usage
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Algorithm 1-2
    ty = Arrow(Arrow(Base(), Base()), Arrow(Base(), Base()))
    print(f"Type: {ty}")
    print(f"  State bound: {type_state_bound(ty)}")
    print(f"  Branch complexity: {branch_complexity(ty)}")
    print(f"  All measures: {type_measures(ty)}")

    # Algorithm 4
    print(f"\nEndomorphism tower bounds (0..7):")
    bounds = iter_end_bounds(7)
    for i, b in enumerate(bounds):
        print(f"  iterEndTy({i}): stateBound = {b:>15,}, branchComplexity = {2**i}")

    # Algorithm 5
    print(f"\nType enumeration:")
    for s in range(1, 10, 2):
        types = enumerate_types(s)
        print(f"  Types of size ≤ {s}: {len(types)}")

    # Algorithm 6
    print(f"\nDomination verification (size ≤ 9): {'PASS' if verify_domination(9) else 'FAIL'}")

    # Algorithm 7
    print(f"\nGrowth analysis:")
    data = analyze_growth(6)
    for d in data:
        print(f"  n={d['n']}: ratio = {d['ratio']:.1f}, log10(stateBound) = {d['log_state_bound']:.1f}")

    # Algorithm 8
    print(f"\nArrow amplification factors:")
    pairs = [(Base(), Base()), (Arrow(Base(), Base()), Base()),
             (Base(), Arrow(Base(), Base()))]
    for a, b in pairs:
        fa, fb = arrow_amplification_factor(a, b)
        print(f"  {a} → {b}: factor_A = {fa:.1f}, factor_B = {fb:.1f}")
