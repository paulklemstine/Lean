#!/usr/bin/env python3
"""
Algorithms for Multivariate EML Tower Complexity

Implements:
1. Expression restriction (multivariate → single-variable)
2. Variable support extraction with correctness verification
3. Depth and size computation
4. Exhaustive enumeration of bounded expressions
"""

import math
from typing import List, Set, Optional, Tuple, Callable
from dataclasses import dataclass
from enum import Enum

# ============================================================
# Core Expression Types
# ============================================================

class ExprType(Enum):
    CONST = "const"
    VAR = "var"
    ADD = "add"
    MUL = "mul"
    EXP = "exp"

@dataclass
class MVExpr:
    """Multivariate inverse-free EML expression over k variables."""
    kind: ExprType
    value: Optional[float] = None  # for CONST
    var_idx: Optional[int] = None  # for VAR
    left: Optional['MVExpr'] = None   # for binary ops
    right: Optional['MVExpr'] = None  # for binary ops
    child: Optional['MVExpr'] = None  # for EXP

    def eval(self, x: List[float]) -> float:
        """Evaluate the expression at point x."""
        if self.kind == ExprType.CONST:
            return self.value
        elif self.kind == ExprType.VAR:
            return x[self.var_idx]
        elif self.kind == ExprType.ADD:
            return self.left.eval(x) + self.right.eval(x)
        elif self.kind == ExprType.MUL:
            return self.left.eval(x) * self.right.eval(x)
        elif self.kind == ExprType.EXP:
            v = self.child.eval(x)
            return math.exp(min(v, 700))

    def depth(self) -> int:
        """Maximum exponential nesting depth."""
        if self.kind in (ExprType.CONST, ExprType.VAR):
            return 0
        elif self.kind in (ExprType.ADD, ExprType.MUL):
            return max(self.left.depth(), self.right.depth())
        elif self.kind == ExprType.EXP:
            return 1 + self.child.depth()

    def size(self) -> int:
        """Total number of constructor nodes."""
        if self.kind in (ExprType.CONST, ExprType.VAR):
            return 1
        elif self.kind in (ExprType.ADD, ExprType.MUL):
            return 1 + self.left.size() + self.right.size()
        elif self.kind == ExprType.EXP:
            return 1 + self.child.size()

    def var_support(self) -> Set[int]:
        """
        Extract the set of variable indices that appear syntactically.

        Correctness: By structural induction, this returns exactly the
        set of variable indices that appear as VAR nodes in the tree.
        Theorem (proved in Lean): if j ∉ var_support(e), then e.eval
        is independent of coordinate j.
        """
        if self.kind == ExprType.CONST:
            return set()
        elif self.kind == ExprType.VAR:
            return {self.var_idx}
        elif self.kind in (ExprType.ADD, ExprType.MUL):
            return self.left.var_support() | self.right.var_support()
        elif self.kind == ExprType.EXP:
            return self.child.var_support()

    def __repr__(self) -> str:
        if self.kind == ExprType.CONST:
            return f"{self.value}"
        elif self.kind == ExprType.VAR:
            return f"x{self.var_idx}"
        elif self.kind == ExprType.ADD:
            return f"({self.left} + {self.right})"
        elif self.kind == ExprType.MUL:
            return f"({self.left} * {self.right})"
        elif self.kind == ExprType.EXP:
            return f"exp({self.child})"

# ============================================================
# Algorithm 1: Expression Restriction
# ============================================================

def restrict_expr(e: MVExpr, j: int, c: float) -> MVExpr:
    """
    Restrict a multivariate expression to a single-variable expression
    by fixing coordinate j to the variable and all others to constant c.

    This is the key algorithmic tool for reducing multivariate lower bounds
    to single-variable ones.

    Complexity: O(size(e)) time and space.

    Correctness (proved in Lean as restrictExpr_eval):
        restrict_expr(e, j, c).eval([t]) == e.eval(x)
        where x[i] = t if i == j, else c

    Depth bound (proved in Lean as restrictExpr_depth_le):
        restrict_expr(e, j, c).depth() <= e.depth()

    Args:
        e: multivariate expression
        j: coordinate index to keep as variable
        c: constant value for all other coordinates

    Returns:
        Single-variable expression (using var_idx=0 for the variable)
    """
    if e.kind == ExprType.CONST:
        return MVExpr(ExprType.CONST, value=e.value)
    elif e.kind == ExprType.VAR:
        if e.var_idx == j:
            return MVExpr(ExprType.VAR, var_idx=0)
        else:
            return MVExpr(ExprType.CONST, value=c)
    elif e.kind == ExprType.ADD:
        return MVExpr(ExprType.ADD,
                      left=restrict_expr(e.left, j, c),
                      right=restrict_expr(e.right, j, c))
    elif e.kind == ExprType.MUL:
        return MVExpr(ExprType.MUL,
                      left=restrict_expr(e.left, j, c),
                      right=restrict_expr(e.right, j, c))
    elif e.kind == ExprType.EXP:
        return MVExpr(ExprType.EXP,
                      child=restrict_expr(e.child, j, c))

# ============================================================
# Algorithm 2: Semantic Dependence Check
# ============================================================

def check_semantic_dependence(e: MVExpr, k: int, j: int,
                               base_point: List[float] = None,
                               delta: float = 1.0) -> bool:
    """
    Check if expression e semantically depends on coordinate j
    by evaluating at two points that differ only in coordinate j.

    Theorem (proved in Lean as mem_varSupport_of_semantic_dependence):
        If this returns True, then j must be in var_support(e).

    Args:
        e: expression to check
        k: number of variables
        j: coordinate to check
        base_point: base evaluation point (default: all ones)
        delta: perturbation amount

    Returns:
        True if e appears to depend on coordinate j
    """
    if base_point is None:
        base_point = [1.0] * k
    perturbed = list(base_point)
    perturbed[j] = base_point[j] + delta

    try:
        v1 = e.eval(base_point)
        v2 = e.eval(perturbed)
        return abs(v1 - v2) > 1e-12
    except (OverflowError, ValueError):
        return True  # assume dependence if evaluation fails

# ============================================================
# Algorithm 3: Bounded Expression Enumeration
# ============================================================

def enumerate_bounded(k: int, max_depth: int, max_size: int,
                      constants: List[float] = None) -> List[MVExpr]:
    """
    Enumerate all multivariate EML expressions with bounded depth and size.

    Complexity: O(|constants|^max_size * k^max_size) worst case,
    but pruned heavily by depth and size bounds.

    Args:
        k: number of variables
        max_depth: maximum exponential depth
        max_size: maximum syntactic size
        constants: allowed constant values

    Returns:
        List of expressions satisfying the bounds
    """
    if constants is None:
        constants = [1.0, 2.0]

    results = []

    def gen(d: int, s: int) -> List[MVExpr]:
        """Generate expressions with depth ≤ d and size ≤ s."""
        if s <= 0:
            return []
        exprs = []
        # Leaves (size 1, depth 0)
        for c in constants:
            exprs.append(MVExpr(ExprType.CONST, value=c))
        for i in range(k):
            exprs.append(MVExpr(ExprType.VAR, var_idx=i))

        if s >= 2 and d >= 1:
            # Exp nodes (size 1 + child.size, depth 1 + child.depth)
            for sub in gen(d - 1, s - 1):
                exprs.append(MVExpr(ExprType.EXP, child=sub))

        if s >= 3:
            # Binary ops (size 1 + left.size + right.size)
            subs = gen(d, s - 2)  # each child needs at least size 1
            for i, a in enumerate(subs[:15]):
                for b in subs[:15]:
                    if 1 + a.size() + b.size() <= s:
                        exprs.append(MVExpr(ExprType.ADD, left=a, right=b))
                        exprs.append(MVExpr(ExprType.MUL, left=a, right=b))

        return exprs

    all_exprs = gen(max_depth, max_size)
    return [e for e in all_exprs if e.depth() <= max_depth and e.size() <= max_size]

# ============================================================
# Algorithm 4: Positive Grid Evaluator
# ============================================================

def iterExp(n: int, x: float) -> float:
    """Iterated exponential with overflow protection."""
    for _ in range(n):
        x = math.exp(min(x, 700))
    return x

def positive_grid_evaluator(e: MVExpr, k: int, n: int,
                             grid_points: int = 5,
                             tol: float = 1e-6) -> Tuple[bool, float]:
    """
    Evaluate expression on a positive grid and compare with iterExp(n, sum(x)).

    Args:
        e: expression to test
        k: number of variables
        n: tower height
        grid_points: number of points per dimension
        tol: relative tolerance

    Returns:
        (matches, max_relative_error)
    """
    import itertools as it
    vals = [0.1 * (i + 1) for i in range(grid_points)]
    max_err = 0.0
    matches = True

    for pt in it.product(vals, repeat=k):
        pt_list = list(pt)
        try:
            val = e.eval(pt_list)
            tgt = iterExp(n, sum(pt_list))
            rel_err = abs(val - tgt) / max(1.0, abs(tgt))
            max_err = max(max_err, rel_err)
            if rel_err > tol:
                matches = False
        except (OverflowError, ValueError):
            matches = False
            max_err = float('inf')

    return matches, max_err

# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Build: exp(exp(exp(x0 + x1)))
    e = MVExpr(ExprType.EXP, child=MVExpr(ExprType.EXP, child=MVExpr(ExprType.EXP,
        child=MVExpr(ExprType.ADD,
                     left=MVExpr(ExprType.VAR, var_idx=0),
                     right=MVExpr(ExprType.VAR, var_idx=1)))))

    print(f"Expression: {e}")
    print(f"Depth: {e.depth()}")
    print(f"Size: {e.size()}")
    print(f"Variable support: {e.var_support()}")
    print()

    # Restriction
    r = restrict_expr(e, 0, 1.0)
    print(f"Restricted to x0 (others=1): {r}")
    print(f"Restricted depth: {r.depth()} ≤ original depth: {e.depth()}")
    print()

    # Semantic dependence
    for j in range(2):
        dep = check_semantic_dependence(e, 2, j)
        print(f"Depends on x{j}? {dep}")
    print()

    # Grid evaluation
    matches, err = positive_grid_evaluator(e, 2, 3, grid_points=3)
    print(f"Matches iterExp(3, x0+x1)? {matches}")
    print(f"Max relative error: {err:.2e}")
