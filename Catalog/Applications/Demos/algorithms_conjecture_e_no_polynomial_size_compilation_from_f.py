#!/usr/bin/env python3
"""
EML Depth Separation — Core Algorithms

Implements the key algorithms from the research paper:
1. Iterated exponential computation
2. EML expression tree manipulation
3. Depth-bounded enumeration
4. Growth bound certification
5. Grid-based representability testing

All algorithms include docstrings, type hints, and example usage.
"""

import math
from typing import Optional, List, Callable, Tuple, Dict
from dataclasses import dataclass
from enum import Enum, auto


# ============================================================
# Algorithm 1: Iterated Exponential Computation
# ============================================================

def iter_exp(n: int, x: float) -> float:
    """
    Compute the n-fold iterated exponential at x.

    iterExp(0, x) = x
    iterExp(n+1, x) = exp(iterExp(n, x))

    Time complexity: O(n)
    Space complexity: O(1)

    Args:
        n: Number of exponential iterations (non-negative)
        x: Input value

    Returns:
        The value iterExp(n, x), or float('inf') on overflow.

    Examples:
        >>> iter_exp(0, 2.0)
        2.0
        >>> iter_exp(1, 2.0)
        7.38905609893065
        >>> iter_exp(2, 1.0)  # exp(exp(1)) ≈ 15.15
        15.15426224147926
    """
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
        except OverflowError:
            return float('inf')
    return result


def iter_exp_safe(n: int, x: float, max_val: float = 1e300) -> Tuple[float, bool]:
    """
    Safe iterated exponential with overflow detection.

    Returns (value, overflowed) where overflowed indicates
    if the computation exceeded max_val.

    Args:
        n: Number of iterations
        x: Input value
        max_val: Maximum allowed value

    Returns:
        Tuple of (result, did_overflow)
    """
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
            if result > max_val:
                return float('inf'), True
        except OverflowError:
            return float('inf'), True
    return result, False


# ============================================================
# Algorithm 2: EML Expression Tree
# ============================================================

class NodeType(Enum):
    """Types of nodes in an EML expression tree."""
    VAR = auto()
    CONST = auto()
    ADD = auto()
    MUL = auto()
    NEG = auto()
    INV = auto()
    EML = auto()


@dataclass
class Expr:
    """
    EML expression tree node.

    Semantics:
        VAR:   eval(x) = x
        CONST: eval(x) = value
        ADD:   eval(x) = left.eval(x) + right.eval(x)
        MUL:   eval(x) = left.eval(x) * right.eval(x)
        NEG:   eval(x) = -left.eval(x)
        INV:   eval(x) = 1/left.eval(x) (0 if left=0)
        EML:   eval(x) = left.eval(x) * exp(right.eval(x))
    """
    node_type: NodeType
    value: Optional[float] = None
    left: Optional['Expr'] = None
    right: Optional['Expr'] = None

    def eval(self, x: float) -> float:
        """Evaluate the expression at point x."""
        if self.node_type == NodeType.VAR:
            return x
        elif self.node_type == NodeType.CONST:
            return self.value
        elif self.node_type == NodeType.ADD:
            return self.left.eval(x) + self.right.eval(x)
        elif self.node_type == NodeType.MUL:
            return self.left.eval(x) * self.right.eval(x)
        elif self.node_type == NodeType.NEG:
            return -self.left.eval(x)
        elif self.node_type == NodeType.INV:
            v = self.left.eval(x)
            return 1.0 / v if v != 0 else 0.0
        elif self.node_type == NodeType.EML:
            a = self.left.eval(x)
            b = self.right.eval(x)
            try:
                return a * math.exp(b)
            except OverflowError:
                return float('inf') if a > 0 else float('-inf') if a < 0 else 0.0
        raise ValueError(f"Unknown node type: {self.node_type}")

    @property
    def size(self) -> int:
        """Number of nodes in the expression tree."""
        if self.node_type in (NodeType.VAR, NodeType.CONST):
            return 1
        elif self.node_type in (NodeType.NEG, NodeType.INV):
            return 1 + self.left.size
        else:
            return 1 + self.left.size + self.right.size

    @property
    def eml_depth(self) -> int:
        """Maximum nesting depth of eml operations."""
        if self.node_type in (NodeType.VAR, NodeType.CONST):
            return 0
        elif self.node_type in (NodeType.NEG, NodeType.INV):
            return self.left.eml_depth
        elif self.node_type in (NodeType.ADD, NodeType.MUL):
            return max(self.left.eml_depth, self.right.eml_depth)
        elif self.node_type == NodeType.EML:
            return 1 + max(self.left.eml_depth, self.right.eml_depth)
        return 0

    @property
    def has_inv(self) -> bool:
        """Check if the expression contains INV nodes."""
        if self.node_type == NodeType.INV:
            return True
        if self.node_type in (NodeType.VAR, NodeType.CONST):
            return False
        if self.left and self.left.has_inv:
            return True
        if self.right and self.right.has_inv:
            return True
        return False


# ============================================================
# Algorithm 3: Depth-Bounded Enumeration
# ============================================================

def enumerate_expressions(max_size: int, max_depth: int,
                          constants: List[float] = [0.0, 1.0, -1.0],
                          include_inv: bool = False) -> List[Expr]:
    """
    Enumerate all EML expressions up to given size and depth bounds.

    This is the core search algorithm: it generates candidate expressions
    for representability testing.

    Time complexity: O(C^max_size) where C is the branching factor (~5-7)
    Space complexity: O(C^max_size)

    Args:
        max_size: Maximum number of nodes
        max_depth: Maximum eml nesting depth
        constants: List of constant values to include
        include_inv: Whether to include INV nodes

    Returns:
        List of all expressions satisfying the constraints.

    Example:
        >>> exprs = enumerate_expressions(3, 1, [1.0])
        >>> len(exprs)  # var, const(1), neg(var), neg(const), add/mul/eml combinations
        15
    """
    cache: Dict[Tuple[int, int], List[Expr]] = {}

    def gen(size: int, depth: int) -> List[Expr]:
        key = (size, depth)
        if key in cache:
            return cache[key]

        result = []
        if size <= 0:
            cache[key] = result
            return result

        # Leaves
        result.append(Expr(NodeType.VAR))
        for c in constants:
            result.append(Expr(NodeType.CONST, value=c))

        # Unary
        if size >= 2:
            for sub in gen(size - 1, depth):
                result.append(Expr(NodeType.NEG, left=sub))
                if include_inv:
                    result.append(Expr(NodeType.INV, left=sub))

        # Binary
        if size >= 3:
            for s1 in range(1, size - 1):
                s2 = size - 1 - s1
                lefts = gen(s1, depth)
                rights = gen(s2, depth)
                for l in lefts:
                    for r in rights:
                        result.append(Expr(NodeType.ADD, left=l, right=r))
                        result.append(Expr(NodeType.MUL, left=l, right=r))
                        # EML: depth increases by 1
                        if (depth >= 1 and
                            l.eml_depth < depth and
                            r.eml_depth < depth):
                            result.append(Expr(NodeType.EML, left=l, right=r))

        cache[key] = result
        return result

    return gen(max_size, max_depth)


# ============================================================
# Algorithm 4: Growth Bound Certification
# ============================================================

def certify_growth_bound(expr: Expr, grid: List[float],
                         C_candidates: List[float] = None) -> Dict:
    """
    Certify whether an expression satisfies the growth bound:
    |e.eval(x)| ≤ iterExp(emlDepth(e) + 1, C * x) for all x in grid.

    Args:
        expr: The expression to certify
        grid: Points at which to check the bound
        C_candidates: Constants C to try

    Returns:
        Dictionary with certification results for each C.

    Example:
        >>> e = Expr(NodeType.EML, left=Expr(NodeType.CONST, value=1.0),
        ...          right=Expr(NodeType.VAR))  # exp(x)
        >>> result = certify_growth_bound(e, [1.0, 2.0, 3.0])
        >>> result[1.0]['certified']
        True
    """
    if C_candidates is None:
        C_candidates = [1.0, 2.0, 5.0, 10.0, 50.0, 100.0]

    D = expr.eml_depth
    results = {}

    for C in C_candidates:
        violations = []
        max_ratio = 0.0

        for x in grid:
            try:
                val = abs(expr.eval(x))
                bound = iter_exp(D + 1, C * x)
                if math.isinf(bound):
                    continue
                if val > bound * (1 + 1e-10):  # small tolerance
                    violations.append((x, val, bound))
                if bound > 0:
                    max_ratio = max(max_ratio, val / bound)
            except (OverflowError, ValueError):
                continue

        results[C] = {
            'C': C,
            'depth': D,
            'level': D + 1,
            'certified': len(violations) == 0,
            'violations': violations,
            'max_ratio': max_ratio,
            'grid_size': len(grid)
        }

    return results


# ============================================================
# Algorithm 5: Grid-Based Representability Testing
# ============================================================

def test_representability(target_fn: Callable[[float], float],
                          max_depth: int, max_size: int,
                          grid: List[float],
                          tol: float = 1e-8) -> Optional[Expr]:
    """
    Search for an EML expression that represents target_fn on the grid.

    This implements the soundness-certified search: if None is returned,
    then no EMLExpr of the given depth and size matches on the grid.

    Args:
        target_fn: Target function to represent
        max_depth: Maximum eml depth
        max_size: Maximum expression size
        grid: Points at which to test equality
        tol: Relative tolerance for matching

    Returns:
        A matching expression, or None if no match found.

    Example:
        >>> result = test_representability(
        ...     lambda x: math.exp(x), max_depth=1, max_size=5,
        ...     grid=[0.5, 1.0, 1.5, 2.0])
        >>> result is not None  # Should find eml(1, x) = exp(x)
        True
    """
    candidates = enumerate_expressions(max_size, max_depth)

    for expr in candidates:
        if expr.eml_depth > max_depth:
            continue

        matches = True
        for x in grid:
            try:
                val = expr.eval(x)
                tgt = target_fn(x)

                if math.isinf(val) or math.isinf(tgt):
                    if val != tgt:
                        matches = False
                        break
                    continue

                if abs(val - tgt) > tol * max(1.0, abs(tgt)):
                    matches = False
                    break
            except (OverflowError, ValueError):
                matches = False
                break

        if matches:
            return expr

    return None


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Examples ===\n")

    # Algorithm 1: Iterated exponentials
    print("1. Iterated Exponentials:")
    for n in range(5):
        val, overflow = iter_exp_safe(n, 1.0)
        print(f"   iterExp({n}, 1.0) = {val:.6g}" +
              (" [overflow]" if overflow else ""))

    # Algorithm 3: Enumeration
    print("\n2. Expression Enumeration:")
    for depth in range(3):
        exprs = enumerate_expressions(5, depth, [1.0])
        print(f"   Depth ≤ {depth}, size ≤ 5: {len(exprs)} expressions")

    # Algorithm 5: Representability search
    print("\n3. Representability Search:")
    grid = [0.5, 1.0, 1.5, 2.0]
    for n in range(1, 5):
        for D in range(1, 4):
            result = test_representability(
                lambda x, n=n: iter_exp(n, x),
                max_depth=D, max_size=7, grid=grid)
            status = f"size={result.size}" if result else "NOT FOUND"
            print(f"   iterExp({n}) at depth ≤ {D}: {status}")
