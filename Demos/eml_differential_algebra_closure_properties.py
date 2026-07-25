#!/usr/bin/env python3
"""Numerical demonstrations for rational exponential--logarithmic expressions.

The module implements a compact immutable expression tree, evaluation, symbolic
substitution, symbolic differentiation, regularity diagnostics, and finite-
difference comparisons. It uses only the Python standard library.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import exp, isfinite, log
from typing import Callable, Iterable, Sequence


@dataclass(frozen=True)
class Expr:
    """An immutable node in a univariate EML expression tree."""

    op: str
    args: tuple["Expr", ...] = ()
    value: float | None = None

    @staticmethod
    def const(value: float) -> "Expr":
        return Expr("const", value=float(value))

    @staticmethod
    def var() -> "Expr":
        return Expr("var")

    def __add__(self, other: "Expr | float") -> "Expr":
        return Expr("add", (self, as_expr(other)))

    def __radd__(self, other: "Expr | float") -> "Expr":
        return as_expr(other) + self

    def __mul__(self, other: "Expr | float") -> "Expr":
        return Expr("mul", (self, as_expr(other)))

    def __rmul__(self, other: "Expr | float") -> "Expr":
        return as_expr(other) * self

    def __neg__(self) -> "Expr":
        return Expr.const(-1.0) * self

    def __sub__(self, other: "Expr | float") -> "Expr":
        return self + (-as_expr(other))

    def inv(self) -> "Expr":
        return Expr("inv", (self,))

    def __truediv__(self, other: "Expr | float") -> "Expr":
        return self * as_expr(other).inv()

    def exponential(self) -> "Expr":
        return Expr("exp", (self,))

    def logarithm(self) -> "Expr":
        return Expr("log", (self,))


def as_expr(value: Expr | float) -> Expr:
    """Convert a number to a constant expression, leaving expressions unchanged."""
    return value if isinstance(value, Expr) else Expr.const(value)


def evaluate(expr: Expr, x: float) -> float:
    """Evaluate an expression at x using ordinary real-domain operations."""
    if expr.op == "const":
        assert expr.value is not None
        return expr.value
    if expr.op == "var":
        return x
    if expr.op == "add":
        return evaluate(expr.args[0], x) + evaluate(expr.args[1], x)
    if expr.op == "mul":
        return evaluate(expr.args[0], x) * evaluate(expr.args[1], x)
    child = evaluate(expr.args[0], x)
    if expr.op == "inv":
        if child == 0.0:
            raise ValueError("reciprocal singularity")
        return 1.0 / child
    if expr.op == "exp":
        return exp(child)
    if expr.op == "log":
        if child <= 0.0:
            raise ValueError("logarithm is outside its conventional real domain")
        return log(child)
    raise ValueError(f"unknown expression operation: {expr.op}")


def substitute(outer: Expr, inner: Expr) -> Expr:
    """Replace every variable in outer by inner, representing composition."""
    if outer.op == "const":
        return outer
    if outer.op == "var":
        return inner
    return Expr(outer.op, tuple(substitute(arg, inner) for arg in outer.args), outer.value)


def differentiate(expr: Expr) -> Expr:
    """Construct the symbolic derivative according to the recursive rules."""
    if expr.op == "const":
        return Expr.const(0.0)
    if expr.op == "var":
        return Expr.const(1.0)
    if expr.op == "add":
        return differentiate(expr.args[0]) + differentiate(expr.args[1])
    if expr.op == "mul":
        left, right = expr.args
        return differentiate(left) * right + left * differentiate(right)
    child = expr.args[0]
    if expr.op == "inv":
        return -differentiate(child) * (child * child).inv()
    if expr.op == "exp":
        return differentiate(child) * child.exponential()
    if expr.op == "log":
        return differentiate(child) * child.inv()
    raise ValueError(f"unknown expression operation: {expr.op}")


def regular_at(expr: Expr, x: float) -> bool:
    """Check the domain-sensitive regularity conditions at a numerical point."""
    try:
        value = evaluate(expr, x)
        return isfinite(value)
    except (ValueError, OverflowError, ZeroDivisionError):
        return False


def finite_difference(function: Callable[[float], float], x: float, h: float = 1e-6) -> float:
    """Approximate a derivative by a centered finite difference."""
    return (function(x + h) - function(x - h)) / (2.0 * h)


def derivative_comparison(expr: Expr, points: Iterable[float]) -> list[tuple[float, float, float, float]]:
    """Compare symbolic and centered finite-difference derivatives."""
    derivative = differentiate(expr)
    rows: list[tuple[float, float, float, float]] = []
    for x in points:
        symbolic = evaluate(derivative, x)
        numeric = finite_difference(lambda t: evaluate(expr, t), x)
        rows.append((x, symbolic, numeric, abs(symbolic - numeric)))
    return rows


def print_table(title: str, headers: Sequence[str], rows: Iterable[Sequence[object]]) -> None:
    """Print a simple aligned table."""
    materialized = [[str(item) for item in row] for row in rows]
    widths = [len(header) for header in headers]
    for row in materialized:
        widths = [max(width, len(cell)) for width, cell in zip(widths, row)]
    print(f"\n{title}")
    print("  ".join(header.ljust(width) for header, width in zip(headers, widths)))
    print("  ".join("-" * width for width in widths))
    for row in materialized:
        print("  ".join(cell.ljust(width) for cell, width in zip(row, widths)))


def demo_differentiation() -> None:
    """Demonstrate symbolic differentiation on a globally regular expression."""
    x = Expr.var()
    expr = (x * x).exponential() * (Expr.const(1.0) + x * x).logarithm()
    rows = [
        (f"{point:.2f}", f"{symbolic:.10f}", f"{numeric:.10f}", f"{error:.2e}")
        for point, symbolic, numeric, error in derivative_comparison(expr, [-1.0, -0.4, 0.2, 0.7])
    ]
    print_table(
        "Demo 1: symbolic derivative versus finite differences",
        ("x", "symbolic", "finite difference", "absolute error"),
        rows,
    )


def demo_composition() -> None:
    """Demonstrate that substitution evaluates exactly as composition."""
    x = Expr.var()
    outer = x.exponential() + x.inv()
    inner = Expr.const(1.0) + x * x
    composed = substitute(outer, inner)
    rows = []
    for point in [-1.5, -0.5, 0.0, 0.8]:
        by_substitution = evaluate(composed, point)
        by_composition = evaluate(outer, evaluate(inner, point))
        rows.append((f"{point:.2f}", f"{by_substitution:.10f}", f"{by_composition:.10f}",
                     f"{abs(by_substitution - by_composition):.2e}"))
    print_table(
        "Demo 2: substitution identity for composition",
        ("x", "substituted tree", "direct composition", "difference"),
        rows,
    )


def demo_inverse_and_antiderivative() -> None:
    """Check the exponential/logarithm inverse derivative and exp antiderivative."""
    rows = []
    for point in [0.25, 0.75, 1.5, 3.0]:
        inverse_derivative = 1.0 / point
        reciprocal_formula = 1.0 / exp(log(point))
        exp_antiderivative_error = abs(finite_difference(exp, point) - exp(point))
        rows.append((f"{point:.2f}", f"{inverse_derivative:.10f}",
                     f"{reciprocal_formula:.10f}", f"{exp_antiderivative_error:.2e}"))
    print_table(
        "Demo 3: inverse-branch derivative and exponential antiderivative",
        ("x", "(log)'(x)", "1/exp(log x)", "|(exp)' - exp|"),
        rows,
    )


def demo_regularity() -> None:
    """Expose regular and singular sample points for reciprocal and logarithm."""
    x = Expr.var()
    reciprocal = x.inv()
    logarithm = x.logarithm()
    rows = [(f"{point:.1f}", str(regular_at(reciprocal, point)), str(regular_at(logarithm, point)))
            for point in [-1.0, 0.0, 1.0, 2.0]]
    print_table(
        "Demo 4: numerical regularity diagnostics",
        ("x", "1/x regular", "log(x) in conventional real domain"),
        rows,
    )


def main() -> None:
    """Run all numerical demonstrations."""
    demo_differentiation()
    demo_composition()
    demo_inverse_and_antiderivative()
    demo_regularity()


if __name__ == "__main__":
    main()
