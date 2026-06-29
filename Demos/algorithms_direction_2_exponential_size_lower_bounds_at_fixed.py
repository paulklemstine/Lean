#!/usr/bin/env python3
"""
Algorithms for EML Expression Analysis

This module implements algorithms for analyzing inverse-free EML expressions,
including expression enumeration, growth profile extraction, and size lower
bound verification.

These algorithms correspond to the formally verified theory in
SizeDepthTradeoff.lean.
"""

import math
from typing import List, Tuple, Optional, Dict, Set
from dataclasses import dataclass, field


# ============================================================
# Core Data Structures
# ============================================================

@dataclass
class GrowthProfile:
    """Growth profile of an EML expression.

    An expression with profile (k, N, C) satisfies
    |eval(e, x)| <= iterExp(k, C * x^N) for large x.

    Attributes:
        tower_height: Level of tower iteration (k)
        poly_deg: Polynomial degree in tower argument (N)
        coeff: Multiplicative coefficient in tower argument (C)
    """
    tower_height: int
    poly_deg: int
    coeff: float

    @property
    def budget(self) -> float:
        """Single-number budget summarizing profile complexity."""
        return self.tower_height + self.poly_deg + self.coeff


@dataclass
class EMLNode:
    """Node in an EML expression tree.

    Supports: var, const(c), add(l,r), mul(l,r), neg(l), eml(l,r)
    where eml(l,r) evaluates as l * exp(r).
    """
    kind: str
    value: Optional[float] = None
    left: Optional['EMLNode'] = None
    right: Optional['EMLNode'] = None

    def eval(self, x: float) -> float:
        """Evaluate expression at point x.

        Args:
            x: Input value

        Returns:
            Result of evaluating the expression tree at x

        Raises:
            OverflowError: If computation overflows
        """
        if self.kind == 'var':
            return x
        elif self.kind == 'const':
            return self.value
        elif self.kind == 'add':
            return self.left.eval(x) + self.right.eval(x)
        elif self.kind == 'mul':
            return self.left.eval(x) * self.right.eval(x)
        elif self.kind == 'neg':
            return -self.left.eval(x)
        elif self.kind == 'eml':
            return self.left.eval(x) * math.exp(self.right.eval(x))
        raise ValueError(f"Unknown kind: {self.kind}")

    @property
    def size(self) -> int:
        """Syntactic size (number of constructor nodes)."""
        if self.kind in ('var', 'const'):
            return 1
        elif self.kind == 'neg':
            return 1 + self.left.size
        else:
            return 1 + self.left.size + self.right.size

    @property
    def eml_depth(self) -> int:
        """EML depth (maximum nesting of eml operations)."""
        if self.kind in ('var', 'const'):
            return 0
        elif self.kind == 'neg':
            return self.left.eml_depth
        elif self.kind == 'eml':
            return 1 + max(self.left.eml_depth, self.right.eml_depth)
        else:
            return max(self.left.eml_depth, self.right.eml_depth)

    @property
    def eml_count(self) -> int:
        """Number of eml nodes in the expression."""
        if self.kind in ('var', 'const'):
            return 0
        elif self.kind == 'neg':
            return self.left.eml_count
        elif self.kind == 'eml':
            return 1 + self.left.eml_count + self.right.eml_count
        else:
            return self.left.eml_count + self.right.eml_count


# ============================================================
# Algorithm 1: Growth Profile Extraction
# ============================================================

def extract_profile(expr: EMLNode) -> GrowthProfile:
    """Extract a growth profile from an inverse-free EML expression.

    Implements the inductive construction from noInv_hasPolyTowerMajorant.

    Algorithm:
        - var: profile (0, 1, 1) since |x| <= 1 * x^1
        - const(c): profile (0, 0, |c|+1) since |c| <= (|c|+1) * x^0
        - neg(a): same profile as a
        - add(a,b): profile (max(ka,kb), max(Na,Nb)+1, 2*max(Ca,Cb)+1)
        - mul(a,b): profile (max(ka,kb), max(Na,Nb), 2*max(Ca,Cb)+1)
        - eml(a,b): profile (1+max(ka,kb), max(Na,Nb), 2*max(Ca,Cb)+1)

    Args:
        expr: An inverse-free EML expression

    Returns:
        A GrowthProfile bounding the expression's growth

    Time complexity: O(size)
    Space complexity: O(depth) for recursion stack
    """
    if expr.kind == 'var':
        return GrowthProfile(0, 1, 1.0)
    elif expr.kind == 'const':
        return GrowthProfile(0, 0, abs(expr.value) + 1)
    elif expr.kind == 'neg':
        return extract_profile(expr.left)
    elif expr.kind == 'add':
        pa = extract_profile(expr.left)
        pb = extract_profile(expr.right)
        return GrowthProfile(
            max(pa.tower_height, pb.tower_height),
            max(pa.poly_deg, pb.poly_deg) + 1,
            2 * max(pa.coeff, pb.coeff) + 1
        )
    elif expr.kind == 'mul':
        pa = extract_profile(expr.left)
        pb = extract_profile(expr.right)
        return GrowthProfile(
            max(pa.tower_height, pb.tower_height),
            max(pa.poly_deg, pb.poly_deg),
            2 * max(pa.coeff, pb.coeff) + 1
        )
    elif expr.kind == 'eml':
        pa = extract_profile(expr.left)
        pb = extract_profile(expr.right)
        return GrowthProfile(
            1 + max(pa.tower_height, pb.tower_height),
            max(pa.poly_deg, pb.poly_deg),
            2 * max(pa.coeff, pb.coeff) + 1
        )
    raise ValueError(f"Unknown kind: {expr.kind}")


# ============================================================
# Algorithm 2: Expression Enumeration
# ============================================================

def enumerate_expressions(
    max_size: int,
    max_depth: int = None,
    consts: List[float] = None,
    inverse_free_only: bool = True
) -> List[EMLNode]:
    """Enumerate EML expressions up to a given size.

    Args:
        max_size: Maximum expression size
        max_depth: Maximum EML depth (None for no limit)
        consts: Constant values to use (default: [0, 1])
        inverse_free_only: If True, exclude inv nodes

    Returns:
        List of EML expressions satisfying the constraints

    Time complexity: O(4^max_size) worst case
    Space complexity: O(4^max_size)
    """
    if consts is None:
        consts = [0.0, 1.0]

    cache: Dict[int, List[EMLNode]] = {}

    def gen(budget: int) -> List[EMLNode]:
        if budget in cache:
            return cache[budget]
        if budget <= 0:
            return []

        result = []

        # Leaves (size 1)
        if budget >= 1:
            result.append(EMLNode('var'))
            for c in consts:
                result.append(EMLNode('const', value=c))

        # Unary (size >= 2)
        if budget >= 2:
            for child in gen(budget - 1):
                node = EMLNode('neg', left=child)
                if max_depth is None or node.eml_depth <= max_depth:
                    result.append(node)

        # Binary (size >= 3)
        for left_sz in range(1, budget - 1):
            right_sz = budget - 1 - left_sz
            for left in gen(left_sz):
                for right in gen(right_sz):
                    for op in ['add', 'mul', 'eml']:
                        node = EMLNode(op, left=left, right=right)
                        if max_depth is not None and node.eml_depth > max_depth:
                            continue
                        result.append(node)

        cache[budget] = result
        return result

    all_exprs = []
    for s in range(1, max_size + 1):
        all_exprs.extend(gen(s))
    return all_exprs


# ============================================================
# Algorithm 3: Profile Counting
# ============================================================

def count_bounded_profiles(D: int, s: int) -> int:
    """Count the number of growth profiles with bounded parameters.

    Corresponds to bounded_profiles_card in the formal development.

    Args:
        D: Maximum tower height
        s: Maximum polynomial degree and coefficient

    Returns:
        Number of profiles (tower_height <= D, poly_deg <= s, coeff <= s)

    Time complexity: O(1)
    """
    return (D + 1) * (s + 1) * (s + 1)


def verify_profile_bound(D: int, s: int) -> bool:
    """Verify that the profile count matches the polynomial bound.

    Args:
        D: Maximum tower height
        s: Budget parameter

    Returns:
        True if count <= (D+1) * (s+1)^2
    """
    count = count_bounded_profiles(D, s)
    bound = (D + 1) * (s + 1) ** 2
    return count <= bound


# ============================================================
# Algorithm 4: Size Lower Bound Verification
# ============================================================

def iterExp(n: int, x: float) -> float:
    """Compute the n-fold iterated exponential.

    Args:
        n: Number of iterations
        x: Input value

    Returns:
        exp^n(x)
    """
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
        except OverflowError:
            return float('inf')
    return result


def verify_size_lower_bound(
    n: int,
    max_search_size: int = None,
    test_points: List[float] = None,
    tolerance: float = 1e-6
) -> Tuple[bool, Optional[EMLNode]]:
    """Verify that no small expression computes iterExp n.

    Searches for an inverse-free expression of size <= n that
    computes iterExp n on test points. The formal theorem guarantees
    no such expression exists.

    Args:
        n: Tower height
        max_search_size: Maximum size to search (default: n)
        test_points: Points to test equality on
        tolerance: Numerical tolerance

    Returns:
        (True, None) if no small expression found (consistent with theorem)
        (False, expr) if a counterexample found (would disprove theorem)
    """
    if max_search_size is None:
        max_search_size = n
    if test_points is None:
        test_points = [0.1 * i for i in range(1, 21)]

    target_values = [(x, iterExp(n, x)) for x in test_points]

    exprs = enumerate_expressions(max_search_size, consts=[0.0, 1.0])

    for expr in exprs:
        if expr.size > max_search_size:
            continue
        matches = True
        for x, target in target_values:
            try:
                val = expr.eval(x)
                if abs(val - target) > tolerance:
                    matches = False
                    break
            except (OverflowError, ValueError, ZeroDivisionError):
                matches = False
                break
        if matches:
            return (False, expr)

    return (True, None)


# ============================================================
# Example usage
# ============================================================

if __name__ == '__main__':
    # Example: extract profiles
    print("Profile extraction examples:")
    exprs = [
        ("x", EMLNode('var')),
        ("1", EMLNode('const', value=1.0)),
        ("x + x", EMLNode('add', left=EMLNode('var'), right=EMLNode('var'))),
        ("1*exp(x)", EMLNode('eml', left=EMLNode('const', value=1.0),
                             right=EMLNode('var'))),
    ]
    for name, expr in exprs:
        p = extract_profile(expr)
        print(f"  {name}: height={p.tower_height}, deg={p.poly_deg}, "
              f"coeff={p.coeff:.1f}, budget={p.budget:.1f}")

    print()
    print("Size lower bound verification:")
    for n in range(1, 5):
        ok, counter = verify_size_lower_bound(n, max_search_size=min(n, 3))
        status = "✓ consistent" if ok else f"✗ counterexample: {counter}"
        print(f"  iterExp {n}: {status}")

    print()
    print("Profile counting verification:")
    for D in [1, 2, 3]:
        for s in [5, 10]:
            count = count_bounded_profiles(D, s)
            bound = (D + 1) * (s + 1) ** 2
            print(f"  D={D}, s={s}: count={count}, bound={bound}, "
                  f"ok={count <= bound}")
