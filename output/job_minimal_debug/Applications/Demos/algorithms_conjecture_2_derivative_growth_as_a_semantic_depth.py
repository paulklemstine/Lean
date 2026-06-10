"""
Algorithms for Derivative Growth as a Semantic Depth Invariant.

Implements certified derivative bound computation and depth majorant towers
for expressions in the exp-composition fragment.
"""

import math
from dataclasses import dataclass
from typing import Union, Callable, List, Tuple
from enum import Enum, auto


# ─────────────────────────────────────────────────────────────────────
# Expression Language
# ─────────────────────────────────────────────────────────────────────

class ExprKind(Enum):
    VAR = auto()
    CONST = auto()
    ADD = auto()
    MUL = auto()
    EXP = auto()


@dataclass
class Expr:
    """A smooth expression over ℝ supporting var, const, add, mul, exp."""
    kind: ExprKind
    value: float = 0.0  # used for CONST
    left: 'Expr | None' = None
    right: 'Expr | None' = None

    @staticmethod
    def var() -> 'Expr':
        return Expr(kind=ExprKind.VAR)

    @staticmethod
    def const(c: float) -> 'Expr':
        return Expr(kind=ExprKind.CONST, value=c)

    @staticmethod
    def add(a: 'Expr', b: 'Expr') -> 'Expr':
        return Expr(kind=ExprKind.ADD, left=a, right=b)

    @staticmethod
    def mul(a: 'Expr', b: 'Expr') -> 'Expr':
        return Expr(kind=ExprKind.MUL, left=a, right=b)

    @staticmethod
    def exp(e: 'Expr') -> 'Expr':
        return Expr(kind=ExprKind.EXP, left=e)


def tower_expr(k: int) -> Expr:
    """Canonical depth-k tower expression: exp(exp(...exp(var)...))."""
    if k == 0:
        return Expr.var()
    return Expr.exp(tower_expr(k - 1))


# ─────────────────────────────────────────────────────────────────────
# Evaluation
# ─────────────────────────────────────────────────────────────────────

def eval_expr(e: Expr, x: float) -> float:
    """Evaluate expression at x.

    Args:
        e: Expression tree
        x: Point of evaluation

    Returns:
        Value of the expression at x

    Time complexity: O(|e|) where |e| is the size of the expression tree
    Space complexity: O(depth(e)) for recursion stack
    """
    if e.kind == ExprKind.VAR:
        return x
    elif e.kind == ExprKind.CONST:
        return e.value
    elif e.kind == ExprKind.ADD:
        return eval_expr(e.left, x) + eval_expr(e.right, x)
    elif e.kind == ExprKind.MUL:
        return eval_expr(e.left, x) * eval_expr(e.right, x)
    elif e.kind == ExprKind.EXP:
        val = eval_expr(e.left, x)
        if val > 700:  # overflow guard
            return float('inf')
        return math.exp(val)
    raise ValueError(f"Unknown expression kind: {e.kind}")


def eval_deriv(e: Expr, x: float) -> float:
    """Evaluate the symbolic derivative of the expression at x.

    Uses the structural derivative formula (chain rule, product rule, etc.).

    Args:
        e: Expression tree
        x: Point of evaluation

    Returns:
        Value of the derivative at x

    Time complexity: O(|e|)
    Space complexity: O(depth(e))
    """
    if e.kind == ExprKind.VAR:
        return 1.0
    elif e.kind == ExprKind.CONST:
        return 0.0
    elif e.kind == ExprKind.ADD:
        return eval_deriv(e.left, x) + eval_deriv(e.right, x)
    elif e.kind == ExprKind.MUL:
        v1 = eval_expr(e.left, x)
        v2 = eval_expr(e.right, x)
        d1 = eval_deriv(e.left, x)
        d2 = eval_deriv(e.right, x)
        return d1 * v2 + v1 * d2
    elif e.kind == ExprKind.EXP:
        v = eval_expr(e.left, x)
        d = eval_deriv(e.left, x)
        if v > 700:
            return float('inf')
        return math.exp(v) * d
    raise ValueError(f"Unknown expression kind: {e.kind}")


# ─────────────────────────────────────────────────────────────────────
# Depth and Size
# ─────────────────────────────────────────────────────────────────────

def depth(e: Expr) -> int:
    """Syntactic depth of an expression tree.

    Time complexity: O(|e|)
    """
    if e.kind in (ExprKind.VAR, ExprKind.CONST):
        return 0
    elif e.kind in (ExprKind.ADD, ExprKind.MUL):
        return 1 + max(depth(e.left), depth(e.right))
    elif e.kind == ExprKind.EXP:
        return 1 + depth(e.left)
    return 0


def size(e: Expr) -> int:
    """Size (number of nodes) of an expression tree.

    Time complexity: O(|e|)
    """
    if e.kind in (ExprKind.VAR, ExprKind.CONST):
        return 1
    elif e.kind in (ExprKind.ADD, ExprKind.MUL):
        return 1 + size(e.left) + size(e.right)
    elif e.kind == ExprKind.EXP:
        return 1 + size(e.left)
    return 1


# ─────────────────────────────────────────────────────────────────────
# Iterated Exponential and Depth Majorant
# ─────────────────────────────────────────────────────────────────────

def iter_exp(k: int, x: float) -> float:
    """Iterated exponential: iter_exp(0, x) = x, iter_exp(k+1, x) = exp(iter_exp(k, x)).

    Args:
        k: Number of exp iterations
        x: Base value

    Returns:
        The k-fold iterated exponential of x

    Time complexity: O(k)
    Space complexity: O(1)
    """
    result = x
    for _ in range(k):
        if result > 700:
            return float('inf')
        result = math.exp(result)
    return result


def depth_majorant(d: int, M: float) -> float:
    """The tower bound for derivative growth at depth d with subexpression bound M.

    This equals iter_exp(d, M).

    Args:
        d: Expression depth
        M: Subexpression bound

    Returns:
        The tower majorant value

    Time complexity: O(d)
    """
    return iter_exp(d, M)


# ─────────────────────────────────────────────────────────────────────
# Certified Derivative Bound Algorithm
# ─────────────────────────────────────────────────────────────────────

def certify_deriv_bound(e: Expr, M: float) -> float:
    """Compute a certified upper bound on |d/dx E(x)| for x in [0,1],
    assuming all subexpression values are bounded by M.

    This implements the recursive bound:
      - var: 1
      - const c: 0
      - add(e1, e2): bound(e1) + bound(e2)
      - mul(e1, e2): M * bound(e2) + bound(e1) * M
      - exp(e): M * bound(e)

    The soundness theorem (proved in Lean) guarantees:
      |E'(x)| ≤ certify_deriv_bound(E, M) for all x ∈ [0,1]
    whenever all subexpressions of E evaluate to values in [-M, M] on [0,1].

    Args:
        e: Expression tree
        M: Subexpression bound (must be ≥ 0)

    Returns:
        Certified upper bound on derivative magnitude

    Time complexity: O(|e|)
    Space complexity: O(depth(e))

    Example:
        >>> e = tower_expr(3)  # exp(exp(exp(x)))
        >>> certify_deriv_bound(e, 10.0)
        1000.0  # = M^3 = 10^3
    """
    if e.kind == ExprKind.VAR:
        return 1.0
    elif e.kind == ExprKind.CONST:
        return 0.0
    elif e.kind == ExprKind.ADD:
        return certify_deriv_bound(e.left, M) + certify_deriv_bound(e.right, M)
    elif e.kind == ExprKind.MUL:
        d1 = certify_deriv_bound(e.left, M)
        d2 = certify_deriv_bound(e.right, M)
        return M * d2 + d1 * M
    elif e.kind == ExprKind.EXP:
        return M * certify_deriv_bound(e.left, M)
    raise ValueError(f"Unknown expression kind: {e.kind}")


# ─────────────────────────────────────────────────────────────────────
# Derivative Product Formula for Iterated Exponentials
# ─────────────────────────────────────────────────────────────────────

def iter_exp_deriv_prod(k: int, x: float) -> float:
    """Closed-form derivative of iter_exp(k, ·) at x.

    Equals ∏_{i=0}^{k-1} iter_exp(i+1, x).

    This is proved in Lean as iterExp_hasDerivAt.

    Args:
        k: Tower height
        x: Evaluation point

    Returns:
        Product formula for the derivative

    Time complexity: O(k)
    """
    prod = 1.0
    for i in range(k):
        factor = iter_exp(i + 1, x)
        if factor == float('inf') or prod == float('inf'):
            return float('inf')
        prod *= factor
    return prod


# ─────────────────────────────────────────────────────────────────────
# Subexpression Boundedness Check
# ─────────────────────────────────────────────────────────────────────

def check_subexpr_bounded(e: Expr, M: float, x_points: List[float]) -> bool:
    """Check numerically whether all subexpressions are bounded by M
    at the given sample points.

    Args:
        e: Expression tree
        M: Bound to check
        x_points: Sample points in [0, 1]

    Returns:
        True if all subexpressions are bounded at all sample points
    """
    for x in x_points:
        val = eval_expr(e, x)
        if abs(val) > M:
            return False
    if e.kind in (ExprKind.ADD, ExprKind.MUL):
        return (check_subexpr_bounded(e.left, M, x_points) and
                check_subexpr_bounded(e.right, M, x_points))
    elif e.kind == ExprKind.EXP:
        return check_subexpr_bounded(e.left, M, x_points)
    return True


# ─────────────────────────────────────────────────────────────────────
# Depth Lower Bound Certificate
# ─────────────────────────────────────────────────────────────────────

def depth_lower_bound_certificate(f_deriv_max: float, M: float) -> int:
    """Compute the minimum depth d such that depth_majorant(d, M) ≥ f_deriv_max.

    By the depth separation theorem, if |f'(x)| > depth_majorant(d, M)
    somewhere on [0,1], then f cannot be represented by a depth-d expression.

    Args:
        f_deriv_max: Observed maximum derivative magnitude on [0,1]
        M: Subexpression bound

    Returns:
        Minimum depth d needed to represent f

    Time complexity: O(d) where d is the returned depth
    """
    d = 0
    bound = M  # depth_majorant(0, M) = M
    while bound < f_deriv_max and bound < float('inf'):
        d += 1
        if bound > 700:
            break
        bound = math.exp(bound)
    return d


# ─────────────────────────────────────────────────────────────────────
# Random Expression Generation
# ─────────────────────────────────────────────────────────────────────

import random

def random_exp_fragment(max_depth: int, const_bound: float = 1.0) -> Expr:
    """Generate a random expression in the exp-composition fragment.

    Args:
        max_depth: Maximum depth of the generated expression
        const_bound: Maximum absolute value of constants

    Returns:
        Random exp-fragment expression
    """
    if max_depth == 0:
        if random.random() < 0.7:
            return Expr.var()
        else:
            return Expr.const(random.uniform(-const_bound, const_bound))
    else:
        return Expr.exp(random_exp_fragment(max_depth - 1, const_bound))


def random_full_expr(max_depth: int, const_bound: float = 1.0) -> Expr:
    """Generate a random expression using all constructors.

    Args:
        max_depth: Maximum depth
        const_bound: Maximum absolute value of constants

    Returns:
        Random expression
    """
    if max_depth == 0:
        if random.random() < 0.6:
            return Expr.var()
        else:
            return Expr.const(random.uniform(-const_bound, const_bound))
    else:
        choice = random.random()
        child_depth = max_depth - 1
        if choice < 0.3:
            return Expr.exp(random_full_expr(child_depth, const_bound))
        elif choice < 0.55:
            return Expr.add(random_full_expr(child_depth, const_bound),
                          random_full_expr(child_depth, const_bound))
        elif choice < 0.8:
            return Expr.mul(random_full_expr(child_depth, const_bound),
                          random_full_expr(child_depth, const_bound))
        else:
            return Expr.exp(random_full_expr(child_depth, const_bound))


# ─────────────────────────────────────────────────────────────────────
# Numerical Derivative Estimation
# ─────────────────────────────────────────────────────────────────────

def estimate_max_deriv(e: Expr, n_points: int = 1000) -> Tuple[float, float]:
    """Estimate the maximum absolute derivative on [0, 1].

    Args:
        e: Expression
        n_points: Number of sample points

    Returns:
        (max_deriv, argmax_x) tuple
    """
    max_deriv = 0.0
    argmax_x = 0.0
    for i in range(n_points + 1):
        x = i / n_points
        try:
            d = abs(eval_deriv(e, x))
            if d > max_deriv and math.isfinite(d):
                max_deriv = d
                argmax_x = x
        except (OverflowError, ValueError):
            pass
    return max_deriv, argmax_x


if __name__ == "__main__":
    print("=" * 60)
    print("Certified Derivative Bound Algorithm — Examples")
    print("=" * 60)

    for k in range(6):
        e = tower_expr(k)
        M = max(1.0, max(abs(eval_expr(e, x/100)) for x in range(101)))
        cert_bound = certify_deriv_bound(e, M)
        dm = depth_majorant(k, M)
        max_d, _ = estimate_max_deriv(e)

        print(f"\ntowerExpr({k}): depth={depth(e)}, size={size(e)}")
        print(f"  Subexpr bound M = {M:.4f}")
        print(f"  Observed max|f'| = {max_d:.6g}")
        print(f"  Certified bound  = {cert_bound:.6g}")
        print(f"  Tower majorant   = {dm:.6g}")
        print(f"  cert ≤ majorant? {cert_bound <= dm or dm == float('inf')}")

    print("\n" + "=" * 60)
    print("Depth Lower Bound Certificates")
    print("=" * 60)
    for k in range(1, 6):
        e = tower_expr(k)
        max_d, _ = estimate_max_deriv(e)
        M_val = max(1.0, iter_exp(k, 1.0))
        min_depth = depth_lower_bound_certificate(max_d, M_val)
        print(f"  towerExpr({k}): max|f'|={max_d:.4g}, min depth cert = {min_depth}")
