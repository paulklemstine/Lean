#!/usr/bin/env python3
"""
EML Differential Algebra: Core Algorithms

Type-hinted implementations of symbolic EML differentiation,
logarithmic derivative computation, and depth analysis.
"""
from __future__ import annotations
from dataclasses import dataclass
from typing import Callable, Optional
import math


# ─── EML Expression Tree ──────────────────────────────────────────────────

@dataclass
class EMLExpr:
    """Base class for EML differential expressions."""
    pass


@dataclass
class Var(EMLExpr):
    """The identity function x ↦ x."""
    pass


@dataclass
class Const(EMLExpr):
    """A real constant."""
    value: float


@dataclass
class Add(EMLExpr):
    """Sum of two expressions."""
    left: EMLExpr
    right: EMLExpr


@dataclass
class Mul(EMLExpr):
    """Product of two expressions."""
    left: EMLExpr
    right: EMLExpr


@dataclass
class Exp(EMLExpr):
    """Exponential composition exp(e)."""
    inner: EMLExpr


@dataclass
class Log(EMLExpr):
    """Logarithmic composition log(e)."""
    inner: EMLExpr


@dataclass
class Div(EMLExpr):
    """Division e₁/e₂."""
    numer: EMLExpr
    denom: EMLExpr


# ─── Evaluation ───────────────────────────────────────────────────────────

def evaluate(expr: EMLExpr, x: float) -> float:
    """Evaluate an EML expression at a real number x."""
    if isinstance(expr, Var):
        return x
    elif isinstance(expr, Const):
        return expr.value
    elif isinstance(expr, Add):
        return evaluate(expr.left, x) + evaluate(expr.right, x)
    elif isinstance(expr, Mul):
        return evaluate(expr.left, x) * evaluate(expr.right, x)
    elif isinstance(expr, Exp):
        return math.exp(evaluate(expr.inner, x))
    elif isinstance(expr, Log):
        return math.log(evaluate(expr.inner, x))
    elif isinstance(expr, Div):
        return evaluate(expr.numer, x) / evaluate(expr.denom, x)
    raise TypeError(f"Unknown expression type: {type(expr)}")


# ─── Symbolic Differentiation ─────────────────────────────────────────────

def sym_diff(expr: EMLExpr) -> EMLExpr:
    """
    Symbolic differentiation of an EML expression.

    Preserves EML structure: the derivative of an EML expression
    is always another EML expression.

    Algorithm:
      var       → const(1)
      const(c)  → const(0)
      add(a, b) → add(a', b')
      mul(a, b) → add(mul(a', b), mul(a, b'))        [product rule]
      exp(e)    → mul(exp(e), e')                     [exp chain rule]
      log(e)    → div(e', e)                          [log chain rule]
      div(a, b) → div(add(mul(a', b), mul(const(-1), mul(a, b'))), mul(b, b))
    """
    if isinstance(expr, Var):
        return Const(1.0)
    elif isinstance(expr, Const):
        return Const(0.0)
    elif isinstance(expr, Add):
        return Add(sym_diff(expr.left), sym_diff(expr.right))
    elif isinstance(expr, Mul):
        return Add(
            Mul(sym_diff(expr.left), expr.right),
            Mul(expr.left, sym_diff(expr.right))
        )
    elif isinstance(expr, Exp):
        return Mul(Exp(expr.inner), sym_diff(expr.inner))
    elif isinstance(expr, Log):
        return Div(sym_diff(expr.inner), expr.inner)
    elif isinstance(expr, Div):
        return Div(
            Add(
                Mul(sym_diff(expr.numer), expr.denom),
                Mul(Const(-1.0), Mul(expr.numer, sym_diff(expr.denom)))
            ),
            Mul(expr.denom, expr.denom)
        )
    raise TypeError(f"Unknown expression type: {type(expr)}")


# ─── Depth Analysis ───────────────────────────────────────────────────────

def depth(expr: EMLExpr) -> int:
    """
    Composition depth: maximum nesting of exp/log operations.
    Measures the 'transcendental complexity' of an EML expression.
    """
    if isinstance(expr, (Var, Const)):
        return 0
    elif isinstance(expr, (Add, Mul)):
        return max(depth(expr.left), depth(expr.right))
    elif isinstance(expr, (Exp, Log)):
        return depth(expr.inner) + 1
    elif isinstance(expr, Div):
        return max(depth(expr.numer), depth(expr.denom))
    raise TypeError(f"Unknown expression type: {type(expr)}")


def node_count(expr: EMLExpr) -> int:
    """Count all nodes in the expression tree."""
    if isinstance(expr, (Var, Const)):
        return 1
    elif isinstance(expr, (Add, Mul)):
        return 1 + node_count(expr.left) + node_count(expr.right)
    elif isinstance(expr, (Exp, Log)):
        return 1 + node_count(expr.inner)
    elif isinstance(expr, Div):
        return 1 + node_count(expr.numer) + node_count(expr.denom)
    raise TypeError(f"Unknown expression type: {type(expr)}")


# ─── Logarithmic Derivative ──────────────────────────────────────────────

def log_deriv_symbolic(expr: EMLExpr) -> EMLExpr:
    """
    Compute the symbolic logarithmic derivative LD(f) = f'/f.

    For exp(e), this simplifies to e' (stripping the exp layer).
    For products, LD(f·g) = LD(f) + LD(g).
    """
    if isinstance(expr, Exp):
        # LD(exp(e)) = e'  — the key simplification
        return sym_diff(expr.inner)
    elif isinstance(expr, Mul):
        # LD(f·g) = LD(f) + LD(g)
        return Add(log_deriv_symbolic(expr.left), log_deriv_symbolic(expr.right))
    else:
        # General case: f'/f
        return Div(sym_diff(expr), expr)


# ─── Pretty Printing ─────────────────────────────────────────────────────

def pretty(expr: EMLExpr) -> str:
    """Pretty-print an EML expression."""
    if isinstance(expr, Var):
        return "x"
    elif isinstance(expr, Const):
        v = expr.value
        if v == int(v):
            return str(int(v))
        return f"{v:.4g}"
    elif isinstance(expr, Add):
        return f"({pretty(expr.left)} + {pretty(expr.right)})"
    elif isinstance(expr, Mul):
        return f"({pretty(expr.left)} · {pretty(expr.right)})"
    elif isinstance(expr, Exp):
        return f"exp({pretty(expr.inner)})"
    elif isinstance(expr, Log):
        return f"log({pretty(expr.inner)})"
    elif isinstance(expr, Div):
        return f"({pretty(expr.numer)} / {pretty(expr.denom)})"
    return "?"


# ─── Demonstrations ──────────────────────────────────────────────────────

def main() -> None:
    print("EML Differential Algebra — Algorithm Demonstrations")
    print("=" * 60)

    # Example: f(x) = exp(x²) · log(x+1)
    x_sq = Mul(Var(), Var())  # x²
    x_plus_1 = Add(Var(), Const(1.0))  # x+1
    f = Mul(Exp(x_sq), Log(x_plus_1))  # exp(x²)·log(x+1)

    print(f"\nf(x) = {pretty(f)}")
    print(f"depth(f) = {depth(f)}")
    print(f"nodes(f) = {node_count(f)}")

    # Symbolic derivative
    f_prime = sym_diff(f)
    print(f"\nf'(x) = {pretty(f_prime)}")
    print(f"depth(f') = {depth(f_prime)}")
    print(f"nodes(f') = {node_count(f_prime)}")

    # Verify depth bound
    print(f"\nDepth bound: depth(f') = {depth(f_prime)} ≤ depth(f) + 1 = {depth(f) + 1}: "
          f"{'✓' if depth(f_prime) <= depth(f) + 1 else '✗'}")

    # Node count bound
    n = node_count(f)
    bound = 3 * n ** 2
    print(f"Node bound: nodes(f') = {node_count(f_prime)} ≤ 3·{n}² = {bound}: "
          f"{'✓' if node_count(f_prime) <= bound else '✗'}")

    # Numerical verification
    x0 = 0.5
    print(f"\nNumerical verification at x = {x0}:")
    print(f"  f({x0}) = {evaluate(f, x0):.10f}")
    print(f"  f'({x0}) [symbolic] = {evaluate(f_prime, x0):.10f}")
    fd = (evaluate(f, x0 + 1e-8) - evaluate(f, x0 - 1e-8)) / 2e-8
    print(f"  f'({x0}) [numerical] = {fd:.10f}")

    # Logarithmic derivative
    print(f"\n--- Logarithmic Derivative ---")
    g = Exp(x_sq)  # exp(x²)
    ld = log_deriv_symbolic(g)
    print(f"LD(exp(x²)) = {pretty(ld)}")
    print(f"  This should equal 2x = {pretty(sym_diff(x_sq))}")
    print(f"  At x={x0}: LD = {evaluate(ld, x0):.6f}, 2x = {2*x0:.6f}")

    # Iterated differentiation
    print(f"\n--- Iterated Differentiation ---")
    expr = f
    for i in range(4):
        d = depth(expr)
        n = node_count(expr)
        print(f"  f^({i}): depth={d}, nodes={n}")
        expr = sym_diff(expr)


if __name__ == "__main__":
    main()
