#!/usr/bin/env python3
"""
Verified Symbolic Differentiation Algorithm for EML Expressions

This module implements the symbolic differentiation algorithm that has been
formally verified in Lean 4 to satisfy:
  1. Semantic correctness: the symbolic derivative matches the analytic derivative
  2. Depth control: differentiation raises Hardy depth by at most 1

The algorithm operates on PosEMLExpr, a fragment of the EML expression language
consisting of constants, variables, addition, multiplication, and exponentiation.

Complexity Analysis:
  - Time:  O(n) per differentiation, where n = number of nodes in the expression tree
  - Space: O(n) for the output expression tree (product rule doubles mul nodes)
  - Depth: output depth ≤ input depth + 1 (formally verified)
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum, auto
from typing import Optional
import math


# ═══════════════════════════════════════════════════════════════════════
# Core Data Structure: PosEMLExpr
# ═══════════════════════════════════════════════════════════════════════

class Tag(Enum):
    """Expression constructor tags."""
    CONST = auto()
    VAR = auto()
    ADD = auto()
    MUL = auto()
    EXP = auto()


@dataclass(frozen=True)
class Expr:
    """A PosEMLExpr node.

    This mirrors the Lean 4 inductive type:
        inductive PosEMLExpr where
          | const : ℝ → PosEMLExpr
          | var   : PosEMLExpr
          | add   : PosEMLExpr → PosEMLExpr → PosEMLExpr
          | mul   : PosEMLExpr → PosEMLExpr → PosEMLExpr
          | exp   : PosEMLExpr → PosEMLExpr
    """
    tag: Tag
    value: float = 0.0
    left: Optional[Expr] = None
    right: Optional[Expr] = None

    # Smart constructors
    @staticmethod
    def const(c: float) -> Expr:
        return Expr(Tag.CONST, value=c)

    @staticmethod
    def var() -> Expr:
        return Expr(Tag.VAR)

    @staticmethod
    def add(a: Expr, b: Expr) -> Expr:
        return Expr(Tag.ADD, left=a, right=b)

    @staticmethod
    def mul(a: Expr, b: Expr) -> Expr:
        return Expr(Tag.MUL, left=a, right=b)

    @staticmethod
    def exp(a: Expr) -> Expr:
        return Expr(Tag.EXP, left=a)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Evaluation
# ═══════════════════════════════════════════════════════════════════════

def evaluate(e: Expr, x: float) -> float:
    """Evaluate expression e at point x.

    Mirrors PosEMLExpr.eval in Lean.
    Time complexity: O(n) where n = number of nodes.

    Args:
        e: Expression to evaluate
        x: Point at which to evaluate

    Returns:
        The real value e(x)

    Example:
        >>> evaluate(Expr.exp(Expr.var()), 1.0)
        2.718281828459045
    """
    if e.tag == Tag.CONST:
        return e.value
    elif e.tag == Tag.VAR:
        return x
    elif e.tag == Tag.ADD:
        return evaluate(e.left, x) + evaluate(e.right, x)
    elif e.tag == Tag.MUL:
        return evaluate(e.left, x) * evaluate(e.right, x)
    elif e.tag == Tag.EXP:
        val = evaluate(e.left, x)
        try:
            return math.exp(val)
        except OverflowError:
            return float('inf')
    raise ValueError(f"Unknown tag: {e.tag}")


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Depth Computation
# ═══════════════════════════════════════════════════════════════════════

def depth(e: Expr) -> int:
    """Compute the Hardy hierarchy depth of an expression.

    Mirrors PosEMLExpr.depth in Lean. Counts maximum nesting of exp.
    Time complexity: O(n).

    The depth corresponds to the Hardy level: an expression of depth d
    evaluates to a function in Hardy level d.

    Args:
        e: Expression

    Returns:
        Non-negative integer depth

    Example:
        >>> depth(Expr.exp(Expr.exp(Expr.var())))
        2
    """
    if e.tag == Tag.CONST:
        return 0
    elif e.tag == Tag.VAR:
        return 0
    elif e.tag == Tag.ADD:
        return max(depth(e.left), depth(e.right))
    elif e.tag == Tag.MUL:
        return max(depth(e.left), depth(e.right))
    elif e.tag == Tag.EXP:
        return depth(e.left) + 1
    raise ValueError(f"Unknown tag: {e.tag}")


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Verified Symbolic Differentiation
# ═══════════════════════════════════════════════════════════════════════

def symbolic_deriv(e: Expr) -> Expr:
    """Symbolically differentiate an expression.

    This is the VERIFIED algorithm: the Lean proof `eval_deriv_eq` certifies
    that for all e and x:
        HasDerivAt (fun y => e.eval y) ((symbolic_deriv e).eval x) x

    And `depth_deriv_le` certifies:
        depth(symbolic_deriv(e)) ≤ depth(e) + 1

    Time complexity: O(n) where n = number of nodes.
    Space complexity: O(n) for output (product rule can double subtrees).

    Pseudocode:
        DIFFERENTIATE(e):
          match e with
          | const(c) → const(0)
          | var      → const(1)
          | add(a,b) → add(DIFFERENTIATE(a), DIFFERENTIATE(b))
          | mul(a,b) → add(mul(DIFFERENTIATE(a), b), mul(a, DIFFERENTIATE(b)))
          | exp(a)   → mul(DIFFERENTIATE(a), exp(a))

    Args:
        e: Expression to differentiate

    Returns:
        The symbolic derivative as an Expr

    Example:
        >>> pretty(symbolic_deriv(Expr.exp(Expr.var())))
        '(1 * exp(x))'
    """
    if e.tag == Tag.CONST:
        return Expr.const(0)
    elif e.tag == Tag.VAR:
        return Expr.const(1)
    elif e.tag == Tag.ADD:
        return Expr.add(symbolic_deriv(e.left), symbolic_deriv(e.right))
    elif e.tag == Tag.MUL:
        # Product rule: (a*b)' = a'*b + a*b'
        return Expr.add(
            Expr.mul(symbolic_deriv(e.left), e.right),
            Expr.mul(e.left, symbolic_deriv(e.right))
        )
    elif e.tag == Tag.EXP:
        # Chain rule: (exp(a))' = a' * exp(a)
        return Expr.mul(symbolic_deriv(e.left), Expr.exp(e.left))
    raise ValueError(f"Unknown tag: {e.tag}")


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Numerical Derivative (for validation)
# ═══════════════════════════════════════════════════════════════════════

def numerical_deriv(e: Expr, x: float, h: float = 1e-8) -> float:
    """Compute numerical derivative using central differences.

    Used to validate the symbolic derivative against finite differences.

    Args:
        e: Expression
        x: Point at which to differentiate
        h: Step size for finite differences

    Returns:
        Approximate derivative value
    """
    try:
        return (evaluate(e, x + h) - evaluate(e, x - h)) / (2 * h)
    except (OverflowError, ValueError):
        return float('nan')


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 5: Hardy Level Classification
# ═══════════════════════════════════════════════════════════════════════

def classify_hardy_level(e: Expr) -> dict:
    """Classify an expression's Hardy level and derivative properties.

    Returns a dictionary with:
      - depth: Hardy depth of e
      - deriv_depth: Hardy depth of e'
      - gap: deriv_depth - depth
      - hardy_bound: guaranteed Hardy level of e' (= depth + 1)
      - is_tight: whether gap equals +1

    Example:
        >>> classify_hardy_level(Expr.exp(Expr.var()))
        {'depth': 1, 'deriv_depth': 1, 'gap': 0, 'hardy_bound': 2, 'is_tight': False}
    """
    de = symbolic_deriv(e)
    d = depth(e)
    dd = depth(de)
    return {
        'depth': d,
        'deriv_depth': dd,
        'gap': dd - d,
        'hardy_bound': d + 1,
        'is_tight': dd == d + 1,
    }


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 6: Logarithmic Derivative
# ═══════════════════════════════════════════════════════════════════════

def log_deriv(e: Expr, x: float) -> float:
    """Compute the logarithmic derivative e'(x)/e(x).

    The logarithmic derivative is the native language of:
    - WKB approximation
    - Saddle-point asymptotics
    - Renormalization-group beta functions
    - Riccati transforms

    Args:
        e: Expression
        x: Point at which to evaluate

    Returns:
        The logarithmic derivative value
    """
    de = symbolic_deriv(e)
    f_val = evaluate(e, x)
    df_val = evaluate(de, x)
    if abs(f_val) < 1e-15:
        return float('nan')
    return df_val / f_val


# ═══════════════════════════════════════════════════════════════════════
# Pretty Printing
# ═══════════════════════════════════════════════════════════════════════

def pretty(e: Expr) -> str:
    """Pretty-print an expression."""
    if e.tag == Tag.CONST:
        v = e.value
        if v == int(v):
            return str(int(v))
        return str(v)
    elif e.tag == Tag.VAR:
        return "x"
    elif e.tag == Tag.ADD:
        return f"({pretty(e.left)} + {pretty(e.right)})"
    elif e.tag == Tag.MUL:
        return f"({pretty(e.left)} * {pretty(e.right)})"
    elif e.tag == Tag.EXP:
        return f"exp({pretty(e.left)})"
    return "?"


def node_count(e: Expr) -> int:
    """Count nodes in the expression tree."""
    if e.tag in (Tag.CONST, Tag.VAR):
        return 1
    elif e.tag in (Tag.ADD, Tag.MUL):
        return 1 + node_count(e.left) + node_count(e.right)
    elif e.tag == Tag.EXP:
        return 1 + node_count(e.left)
    return 1


# ═══════════════════════════════════════════════════════════════════════
# Validation
# ═══════════════════════════════════════════════════════════════════════

def validate_derivative(e: Expr, test_points: list[float] = None, tol: float = 1e-5) -> bool:
    """Validate symbolic derivative against numerical derivative.

    Args:
        e: Expression to validate
        test_points: Points at which to check (default: [0.5, 1.0, 2.0])
        tol: Tolerance for comparison

    Returns:
        True if symbolic and numerical derivatives agree within tolerance
    """
    if test_points is None:
        test_points = [0.5, 1.0, 2.0]

    de = symbolic_deriv(e)
    for x in test_points:
        sym = evaluate(de, x)
        num = numerical_deriv(e, x)
        if math.isnan(sym) or math.isnan(num):
            continue
        if math.isinf(sym) or math.isinf(num):
            continue
        if abs(sym - num) > tol * max(1, abs(sym)):
            return False
    return True


# ═══════════════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 60)
    print("  Verified Symbolic Differentiation Algorithm")
    print("=" * 60)

    x = Expr.var()
    examples = [
        ("x", x),
        ("exp(x)", Expr.exp(x)),
        ("x * exp(x)", Expr.mul(x, Expr.exp(x))),
        ("exp(exp(x))", Expr.exp(Expr.exp(x))),
    ]

    for name, e in examples:
        de = symbolic_deriv(e)
        info = classify_hardy_level(e)
        valid = validate_derivative(e)

        print(f"\n  f(x) = {name}")
        print(f"  f'(x) = {pretty(de)}")
        print(f"  Depth: {info['depth']} → {info['deriv_depth']} (gap: {info['gap']:+d})")
        print(f"  Hardy bound: ≤ {info['hardy_bound']}")
        print(f"  Numerical validation: {'✓' if valid else '✗'}")

    print("\n" + "=" * 60)
