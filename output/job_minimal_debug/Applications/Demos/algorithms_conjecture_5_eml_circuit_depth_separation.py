#!/usr/bin/env python3
"""
EML Circuit Depth Separation — Algorithms

Implements the key algorithms from the research paper:
1. ExpRank calculator with certified correctness
2. Polynomial growth bound checker
3. Minimum-depth EML search
4. Growth level estimator
"""

import math
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass
from enum import Enum, auto


# ============================================================
# Expression Types
# ============================================================

class ExprType(Enum):
    VAR = auto()
    CONST = auto()
    ADD = auto()
    MUL = auto()
    NEG = auto()
    INV = auto()
    EML = auto()


@dataclass
class EMLNode:
    """A node in an EML expression tree."""
    kind: ExprType
    value: Optional[float] = None  # for CONST
    left: Optional['EMLNode'] = None
    right: Optional['EMLNode'] = None

    def eval(self, x: float) -> float:
        """Evaluate the expression at point x."""
        if self.kind == ExprType.VAR:
            return x
        elif self.kind == ExprType.CONST:
            return self.value
        elif self.kind == ExprType.ADD:
            return self.left.eval(x) + self.right.eval(x)
        elif self.kind == ExprType.MUL:
            return self.left.eval(x) * self.right.eval(x)
        elif self.kind == ExprType.NEG:
            return -self.left.eval(x)
        elif self.kind == ExprType.INV:
            v = self.left.eval(x)
            return 1.0 / v if v != 0 else 0.0
        elif self.kind == ExprType.EML:
            a = self.left.eval(x)
            b = self.right.eval(x)
            if b > 700:
                return float('inf') if a > 0 else float('-inf') if a < 0 else 0.0
            return a * math.exp(b)
        raise ValueError(f"Unknown kind: {self.kind}")


# ============================================================
# Algorithm 1: ExpRank Calculator
# ============================================================

def compute_exp_rank(node: EMLNode) -> int:
    """
    Compute the exponential rank of an EML expression.

    The exponential rank is the key syntactic invariant:
    - Field operations preserve the max rank of their arguments
    - eml(a, b) has rank max(rank(a), rank(b) + 1)

    Time complexity: O(|node|) where |node| is the tree size
    Space complexity: O(depth(node)) stack space

    Returns:
        The exponential rank (non-negative integer)

    Examples:
        >>> var = EMLNode(ExprType.VAR)
        >>> compute_exp_rank(var)
        0
        >>> eml1 = EMLNode(ExprType.EML, left=EMLNode(ExprType.CONST, value=1.0), right=var)
        >>> compute_exp_rank(eml1)
        1
    """
    if node.kind == ExprType.VAR:
        return 0
    elif node.kind == ExprType.CONST:
        return 0
    elif node.kind in (ExprType.ADD, ExprType.MUL):
        return max(compute_exp_rank(node.left), compute_exp_rank(node.right))
    elif node.kind in (ExprType.NEG, ExprType.INV):
        return compute_exp_rank(node.left)
    elif node.kind == ExprType.EML:
        return max(compute_exp_rank(node.left), compute_exp_rank(node.right) + 1)
    raise ValueError(f"Unknown kind: {node.kind}")


def compute_eml_depth(node: EMLNode) -> int:
    """
    Compute the EML depth of an expression.

    EML depth counts only the nesting of eml operations,
    ignoring field operations.

    Time complexity: O(|node|)
    """
    if node.kind in (ExprType.VAR, ExprType.CONST):
        return 0
    elif node.kind in (ExprType.ADD, ExprType.MUL):
        return max(compute_eml_depth(node.left), compute_eml_depth(node.right))
    elif node.kind in (ExprType.NEG, ExprType.INV):
        return compute_eml_depth(node.left)
    elif node.kind == ExprType.EML:
        return 1 + max(compute_eml_depth(node.left), compute_eml_depth(node.right))
    raise ValueError(f"Unknown kind: {node.kind}")


def compute_tree_size(node: EMLNode) -> int:
    """Compute the total tree size."""
    if node.kind in (ExprType.VAR, ExprType.CONST):
        return 1
    elif node.kind in (ExprType.NEG, ExprType.INV):
        return 1 + compute_tree_size(node.left)
    else:
        return 1 + compute_tree_size(node.left) + compute_tree_size(node.right)


# ============================================================
# Algorithm 2: Polynomial Growth Bound
# ============================================================

def compute_poly_bound(node: EMLNode) -> Tuple[float, int]:
    """
    Compute the polynomial growth bound (coefBound, polyBound) for
    an inv-free, eml-free expression.

    For x ≥ 1: |node.eval(x)| ≤ coefBound * x^polyBound

    Returns:
        (coefBound, polyBound) tuple

    Raises:
        ValueError if the expression contains inv or eml nodes
    """
    if node.kind == ExprType.VAR:
        return (1.0, 1)
    elif node.kind == ExprType.CONST:
        return (abs(node.value) + 1, 0)
    elif node.kind == ExprType.ADD:
        ca, na = compute_poly_bound(node.left)
        cb, nb = compute_poly_bound(node.right)
        return (ca + cb, max(na, nb))
    elif node.kind == ExprType.MUL:
        ca, na = compute_poly_bound(node.left)
        cb, nb = compute_poly_bound(node.right)
        return (ca * cb, na + nb)
    elif node.kind == ExprType.NEG:
        return compute_poly_bound(node.left)
    elif node.kind == ExprType.INV:
        raise ValueError("inv not supported for polynomial bound")
    elif node.kind == ExprType.EML:
        raise ValueError("eml not supported for polynomial bound")
    raise ValueError(f"Unknown kind: {node.kind}")


def verify_poly_bound(node: EMLNode, x_values: List[float]) -> bool:
    """
    Verify the polynomial growth bound at specific points.

    Returns True if |node.eval(x)| ≤ coefBound * x^polyBound
    for all given x values ≥ 1.
    """
    try:
        coef, deg = compute_poly_bound(node)
    except ValueError:
        return False

    for x in x_values:
        if x < 1:
            continue
        val = abs(node.eval(x))
        bound = coef * x ** deg
        if val > bound + 1e-10:  # small tolerance for floating point
            return False
    return True


# ============================================================
# Algorithm 3: Minimum-Depth EML Search
# ============================================================

def iter_exp(n: int, x: float) -> float:
    """Compute iterExp(n, x)."""
    result = x
    for _ in range(n):
        if result > 700:
            return float('inf')
        result = math.exp(result)
    return result


def generate_expressions(max_size: int,
                         constants: List[float] = None) -> List[EMLNode]:
    """
    Generate all EML expression trees up to a given size.

    Time complexity: O(C^max_size) where C is the branching factor
    Space complexity: O(max_size * output_size)
    """
    if constants is None:
        constants = [0.0, 1.0, -1.0, 2.0]

    leaves = [EMLNode(ExprType.VAR)]
    leaves += [EMLNode(ExprType.CONST, value=c) for c in constants]

    by_size: Dict[int, List[EMLNode]] = {1: list(leaves)}

    for s in range(2, max_size + 1):
        exprs = []
        # Unary: neg, inv
        if s - 1 in by_size:
            for a in by_size[s - 1]:
                exprs.append(EMLNode(ExprType.NEG, left=a))
                exprs.append(EMLNode(ExprType.INV, left=a))

        # Binary: add, mul, eml
        for s1 in range(1, s - 1):
            s2 = s - 1 - s1
            if s1 in by_size and s2 in by_size:
                for a in by_size[s1]:
                    for b in by_size[s2]:
                        exprs.append(EMLNode(ExprType.ADD, left=a, right=b))
                        exprs.append(EMLNode(ExprType.MUL, left=a, right=b))
                        exprs.append(EMLNode(ExprType.EML, left=a, right=b))
        by_size[s] = exprs

    result = []
    for s in range(1, max_size + 1):
        result.extend(by_size.get(s, []))
    return result


def find_min_depth_eml(n: int,
                       max_size: int = 5,
                       constants: List[float] = None,
                       test_points: List[float] = None,
                       tolerance: float = 1e-8) -> Optional[EMLNode]:
    """
    Search for the minimum EML-depth expression computing iterExp(n).

    Args:
        n: Target iterExp level
        max_size: Maximum expression tree size to search
        constants: Allowed constant values
        test_points: Points at which to compare
        tolerance: Matching tolerance

    Returns:
        The minimum-depth expression found, or None
    """
    if test_points is None:
        test_points = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0]

    exprs = generate_expressions(max_size, constants)
    # Sort by eml_depth
    exprs.sort(key=lambda e: compute_eml_depth(e))

    best = None
    best_depth = float('inf')

    for e in exprs:
        d = compute_eml_depth(e)
        if d >= best_depth:
            continue

        matches = True
        for x in test_points:
            try:
                v1 = e.eval(x)
                v2 = iter_exp(n, x)
                if v1 == float('inf') and v2 == float('inf'):
                    continue
                if abs(v1 - v2) > tolerance * max(1, abs(v2)):
                    matches = False
                    break
            except (OverflowError, ValueError, ZeroDivisionError):
                matches = False
                break

        if matches:
            best = e
            best_depth = d

    return best


# ============================================================
# Algorithm 4: Growth Level Estimator
# ============================================================

def estimate_growth_level(f, x_large: float = 100.0) -> int:
    """
    Estimate the 'exponential growth level' of a function f.

    Level 0: polynomial growth (bounded by x^N)
    Level k: grows like iterExp(k, x) for large x

    The estimate works by counting how many times we can take log
    before the function becomes polynomial-bounded.

    Args:
        f: A callable f(x) -> float
        x_large: A large value of x to evaluate at

    Returns:
        Estimated growth level (non-negative integer)
    """
    try:
        val = f(x_large)
    except (OverflowError, ValueError):
        return 10  # very high growth

    if val <= 0 or math.isinf(val) or math.isnan(val):
        if math.isinf(val):
            return 10
        return 0

    level = 0
    current = val
    # Keep taking log until the value is "small" (polynomial-scale)
    while current > x_large and level < 20:
        current = math.log(current)
        level += 1
        if current <= 0:
            break

    return level


# ============================================================
# Main: Algorithm demonstrations
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm 1: ExpRank Calculator")
    print("=" * 60)

    var = EMLNode(ExprType.VAR)
    c1 = EMLNode(ExprType.CONST, value=1.0)

    # Build eml(1, eml(1, eml(1, x))) = iterExp(3)
    e1 = EMLNode(ExprType.EML, left=c1, right=var)
    e2 = EMLNode(ExprType.EML, left=c1, right=e1)
    e3 = EMLNode(ExprType.EML, left=c1, right=e2)

    for i, e in enumerate([var, e1, e2, e3]):
        print(f"  iterExp({i}) canonical: "
              f"expRank={compute_exp_rank(e)}, "
              f"emlDepth={compute_eml_depth(e)}, "
              f"size={compute_tree_size(e)}")

    # Verify expRank ≤ emlDepth
    print("\n  Verifying expRank ≤ emlDepth for all generated expressions...")
    all_exprs = generate_expressions(5)
    violations = 0
    for e in all_exprs:
        if compute_exp_rank(e) > compute_eml_depth(e):
            violations += 1
    print(f"  Checked {len(all_exprs)} expressions, {violations} violations.")
    print()

    print("=" * 60)
    print("Algorithm 2: Polynomial Growth Bound Verification")
    print("=" * 60)

    # Build x + 2*x^2
    x_sq = EMLNode(ExprType.MUL, left=var, right=var)
    two_x_sq = EMLNode(ExprType.MUL,
                       left=EMLNode(ExprType.CONST, value=2.0),
                       right=x_sq)
    poly_expr = EMLNode(ExprType.ADD, left=var, right=two_x_sq)

    coef, deg = compute_poly_bound(poly_expr)
    print(f"  Expression: x + 2x²")
    print(f"  Bound: {coef} * x^{deg}")
    test_xs = [1.0, 2.0, 5.0, 10.0, 100.0]
    print(f"  Verification: {verify_poly_bound(poly_expr, test_xs)}")
    print()

    print("=" * 60)
    print("Algorithm 3: Minimum-Depth Search")
    print("=" * 60)

    for n in [1, 2]:
        print(f"\n  Searching for min-depth EMLExpr for iterExp({n})...")
        result = find_min_depth_eml(n, max_size=5)
        if result:
            print(f"  Found: emlDepth={compute_eml_depth(result)}, "
                  f"expRank={compute_exp_rank(result)}, "
                  f"size={compute_tree_size(result)}")
        else:
            print(f"  No match found in search space.")

    print()
    print("=" * 60)
    print("Algorithm 4: Growth Level Estimation")
    print("=" * 60)

    for n in range(5):
        level = estimate_growth_level(lambda x, n=n: iter_exp(n, x))
        print(f"  iterExp({n}): estimated growth level = {level}")

    # Test with a polynomial
    level = estimate_growth_level(lambda x: x**3 + 2*x)
    print(f"  x³ + 2x:     estimated growth level = {level}")
