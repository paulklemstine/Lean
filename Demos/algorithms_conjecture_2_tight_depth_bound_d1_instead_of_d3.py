#!/usr/bin/env python3
"""
Algorithms for EML Depth Hierarchy Analysis.

Implements the key algorithms from the research paper:
1. Growth rank computation for EML expressions
2. Polynomial-argument tower majorant estimation
3. Depth separation verification
"""

import math
from dataclasses import dataclass
from typing import Callable, Optional, Tuple, List
from enum import Enum, auto


class ExprType(Enum):
    VAR = auto()
    CONST = auto()
    ADD = auto()
    MUL = auto()
    NEG = auto()
    EML = auto()


@dataclass
class EMLExpr:
    """Representation of an EML expression tree."""
    kind: ExprType
    value: Optional[float] = None  # for CONST
    left: Optional['EMLExpr'] = None  # for binary ops
    right: Optional['EMLExpr'] = None  # for binary ops
    child: Optional['EMLExpr'] = None  # for unary ops

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
            return -self.child.eval(x)
        elif self.kind == ExprType.EML:
            a = self.left.eval(x)
            b = self.right.eval(x)
            if b > 500:
                return float('inf')
            return a * math.exp(b)
        raise ValueError(f"Unknown expression type: {self.kind}")

    def eml_depth(self) -> int:
        """Compute the EML depth of the expression.

        Returns:
            The maximum nesting depth of eml operations.
        """
        if self.kind in (ExprType.VAR, ExprType.CONST):
            return 0
        elif self.kind in (ExprType.ADD, ExprType.MUL):
            return max(self.left.eml_depth(), self.right.eml_depth())
        elif self.kind == ExprType.NEG:
            return self.child.eml_depth()
        elif self.kind == ExprType.EML:
            return 1 + max(self.left.eml_depth(), self.right.eml_depth())
        return 0

    def growth_rank(self) -> int:
        """Compute the growth rank of the expression.

        The growth rank is a structural measure that upper-bounds the
        tower majorant level. It equals the number of nested eml operations
        on any root-to-leaf path.

        Returns:
            The growth rank (always ≤ eml_depth).
        """
        if self.kind in (ExprType.VAR, ExprType.CONST):
            return 0
        elif self.kind in (ExprType.ADD, ExprType.MUL):
            return max(self.left.growth_rank(), self.right.growth_rank())
        elif self.kind == ExprType.NEG:
            return self.child.growth_rank()
        elif self.kind == ExprType.EML:
            return 1 + max(self.left.growth_rank(), self.right.growth_rank())
        return 0

    def is_inv_free(self) -> bool:
        """Check if the expression is inverse-free."""
        if self.kind in (ExprType.VAR, ExprType.CONST):
            return True
        elif self.kind in (ExprType.ADD, ExprType.MUL, ExprType.EML):
            return self.left.is_inv_free() and self.right.is_inv_free()
        elif self.kind == ExprType.NEG:
            return self.child.is_inv_free()
        return False

    def size(self) -> int:
        """Compute the size (number of nodes) of the expression."""
        if self.kind in (ExprType.VAR, ExprType.CONST):
            return 1
        elif self.kind in (ExprType.ADD, ExprType.MUL, ExprType.EML):
            return 1 + self.left.size() + self.right.size()
        elif self.kind == ExprType.NEG:
            return 1 + self.child.size()
        return 1


# Convenience constructors
def Var() -> EMLExpr:
    return EMLExpr(ExprType.VAR)

def Const(c: float) -> EMLExpr:
    return EMLExpr(ExprType.CONST, value=c)

def Add(a: EMLExpr, b: EMLExpr) -> EMLExpr:
    return EMLExpr(ExprType.ADD, left=a, right=b)

def Mul(a: EMLExpr, b: EMLExpr) -> EMLExpr:
    return EMLExpr(ExprType.MUL, left=a, right=b)

def Neg(a: EMLExpr) -> EMLExpr:
    return EMLExpr(ExprType.NEG, child=a)

def Eml(a: EMLExpr, b: EMLExpr) -> EMLExpr:
    return EMLExpr(ExprType.EML, left=a, right=b)


def eml_expr_iterexp(n: int) -> EMLExpr:
    """Construct the canonical EML expression for iterExp(n).

    This is the depth-optimal construction:
    eml(1, eml(1, ... eml(1, var)...)) with n nested eml layers.

    Args:
        n: The tower height.

    Returns:
        An EMLExpr of depth n computing iterExp(n).
    """
    if n == 0:
        return Var()
    return Eml(Const(1.0), eml_expr_iterexp(n - 1))


def iterExp(n: int, x: float) -> float:
    """Compute the iterated exponential iterExp(n, x)."""
    result = x
    for _ in range(n):
        if result > 500:
            return float('inf')
        result = math.exp(result)
    return result


def estimate_tower_majorant_level(
    f: Callable[[float], float],
    test_points: List[float] = None,
    max_level: int = 5
) -> Tuple[int, float, int]:
    """Estimate the tower majorant level of a function.

    Finds the minimum k such that f(x) ≤ iterExp(k, C * x^N) for
    appropriate C, N on the test points.

    Args:
        f: The function to analyze.
        test_points: Points at which to test (default: [2, 5, 10, 20]).
        max_level: Maximum level to search.

    Returns:
        (k, C, N) where k is the estimated level, C the coefficient, N the degree.
    """
    if test_points is None:
        test_points = [2.0, 5.0, 10.0, 20.0]

    for k in range(max_level + 1):
        for N in range(6):
            for C_mult in [1, 2, 5, 10, 50, 100]:
                C = float(C_mult)
                all_bounded = True
                for x in test_points:
                    try:
                        fx = f(x)
                        bound = iterExp(k, C * x**N)
                        if fx > bound or bound == float('inf'):
                            all_bounded = False
                            break
                    except (OverflowError, ValueError):
                        all_bounded = False
                        break
                if all_bounded:
                    return (k, C, N)

    return (max_level + 1, float('inf'), 0)


def verify_depth_separation(
    expr: EMLExpr,
    target_n: int,
    test_points: List[float] = None
) -> Tuple[bool, Optional[float]]:
    """Verify that an expression does NOT represent iterExp(n).

    Checks whether expr.eval(x) ≠ iterExp(n, x) at test points.

    Args:
        expr: The candidate expression.
        target_n: The target tower height.
        test_points: Points at which to test.

    Returns:
        (separated, witness_x) where separated is True if a separating
        point was found, and witness_x is the separating point.
    """
    if test_points is None:
        test_points = [1.5, 2.0, 2.5, 3.0, 4.0, 5.0]

    for x in test_points:
        try:
            expr_val = expr.eval(x)
            target_val = iterExp(target_n, x)

            if target_val == float('inf') and expr_val == float('inf'):
                continue

            if abs(expr_val - target_val) > 1e-10 * max(abs(target_val), 1):
                return (True, x)
        except (OverflowError, ValueError):
            continue

    return (False, None)


if __name__ == "__main__":
    print("=== EML Expression Analysis ===\n")

    # Build canonical expressions
    for n in range(5):
        e = eml_expr_iterexp(n)
        print(f"emlExprIterExp({n}): depth={e.eml_depth()}, "
              f"growthRank={e.growth_rank()}, size={e.size()}, "
              f"invFree={e.is_inv_free()}")

    print()

    # Verify depth separation
    print("=== Depth Separation Verification ===\n")
    for D in range(4):
        for n in range(D + 1, D + 3):
            # Try various depth-D candidates
            if D == 0:
                candidates = [Var(), Mul(Var(), Var()), Mul(Mul(Var(), Var()), Var())]
            elif D == 1:
                candidates = [
                    Eml(Const(1.0), Var()),  # exp(x)
                    Eml(Var(), Var()),  # x*exp(x)
                    Eml(Const(1.0), Mul(Const(2.0), Var())),  # exp(2x)
                ]
            else:
                candidates = [eml_expr_iterexp(D)]

            for cand in candidates:
                sep, witness = verify_depth_separation(cand, n)
                status = f"SEPARATED at x={witness}" if sep else "NOT SEPARATED (!!)"
                print(f"  D={D}, n={n}: depth={cand.eml_depth()} expr vs iterExp({n}): {status}")

    print()

    # Estimate tower majorant levels
    print("=== Tower Majorant Level Estimation ===\n")
    test_fns = [
        ("x", lambda x: x),
        ("x^2", lambda x: x**2),
        ("exp(x)", lambda x: math.exp(x)),
        ("x*exp(x)", lambda x: x * math.exp(x)),
        ("exp(exp(x))", lambda x: iterExp(2, x)),
    ]
    for name, f in test_fns:
        k, C, N = estimate_tower_majorant_level(f)
        print(f"  {name:>15}: level={k}, C={C}, N={N}")
