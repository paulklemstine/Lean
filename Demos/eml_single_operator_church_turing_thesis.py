#!/usr/bin/env python3
"""Numerical demonstrations of exact single-operator compilation.

The script builds finite expression trees, compiles them to either
D(a,b) = exp(a) - log(b) or P(a,b) = exp(a) * log(b), and compares source
and target evaluations on deterministic sample grids. Python floating-point
arithmetic is used only to illustrate the exact real identities.
"""

from __future__ import annotations

from dataclasses import dataclass
import math
from typing import Callable, Mapping, Sequence, Union


@dataclass(frozen=True)
class Const:
    value: float


@dataclass(frozen=True)
class Var:
    name: str


@dataclass(frozen=True)
class Unary:
    op: str
    child: "Expr"


@dataclass(frozen=True)
class Binary:
    op: str
    left: "Expr"
    right: "Expr"


Expr = Union[Const, Var, Unary, Binary]
Environment = Mapping[str, float]


def total_log(x: float) -> float:
    """Total real logarithm: log(0)=0 and log(x)=log(abs(x)) otherwise."""
    return 0.0 if x == 0.0 else math.log(abs(x))


def total_inv(x: float) -> float:
    """Total reciprocal with 0 inverse defined as 0."""
    return 0.0 if x == 0.0 else 1.0 / x


def evaluate(expr: Expr, env: Environment) -> float:
    """Evaluate a source or compiled expression tree."""
    if isinstance(expr, Const):
        return expr.value
    if isinstance(expr, Var):
        return env[expr.name]
    if isinstance(expr, Unary):
        value = evaluate(expr.child, env)
        operations: dict[str, Callable[[float], float]] = {
            "neg": lambda z: -z,
            "inv": total_inv,
            "exp": math.exp,
            "log": total_log,
        }
        return operations[expr.op](value)
    left = evaluate(expr.left, env)
    right = evaluate(expr.right, env)
    if expr.op == "add":
        return left + right
    if expr.op == "mul":
        return left * right
    if expr.op == "D":
        return math.exp(left) - total_log(right)
    if expr.op == "P":
        return math.exp(left) * total_log(right)
    raise ValueError(f"unknown binary operation: {expr.op}")


def add(left: Expr, right: Expr) -> Expr:
    return Binary("add", left, right)


def mul(left: Expr, right: Expr) -> Expr:
    return Binary("mul", left, right)


def neg(child: Expr) -> Expr:
    return Unary("neg", child)


def inv(child: Expr) -> Expr:
    return Unary("inv", child)


def exp(child: Expr) -> Expr:
    return Unary("exp", child)


def log(child: Expr) -> Expr:
    return Unary("log", child)


def compile_difference(expr: Expr) -> Expr:
    """Compile exp/log nodes to D(a,b)=exp(a)-log(b)."""
    if isinstance(expr, (Const, Var)):
        return expr
    if isinstance(expr, Binary):
        if expr.op not in {"add", "mul"}:
            raise ValueError("source tree must use only source operations")
        return Binary(
            expr.op,
            compile_difference(expr.left),
            compile_difference(expr.right),
        )
    child = compile_difference(expr.child)
    if expr.op in {"neg", "inv"}:
        return Unary(expr.op, child)
    if expr.op == "exp":
        return Binary("D", child, Const(1.0))
    if expr.op == "log":
        # 1 - D(0, child), represented using addition and negation.
        return add(Const(1.0), neg(Binary("D", Const(0.0), child)))
    raise ValueError(f"unknown source operation: {expr.op}")


def compile_product(expr: Expr) -> Expr:
    """Compile exp/log nodes to P(a,b)=exp(a)*log(b)."""
    if isinstance(expr, (Const, Var)):
        return expr
    if isinstance(expr, Binary):
        if expr.op not in {"add", "mul"}:
            raise ValueError("source tree must use only source operations")
        return Binary(expr.op, compile_product(expr.left), compile_product(expr.right))
    child = compile_product(expr.child)
    if expr.op in {"neg", "inv"}:
        return Unary(expr.op, child)
    if expr.op == "exp":
        return Binary("P", child, Const(math.e))
    if expr.op == "log":
        return Binary("P", Const(0.0), child)
    raise ValueError(f"unknown source operation: {expr.op}")


def expand_difference(expr: Expr) -> Expr:
    """Expand every D node back to exp(left)-log(right)."""
    if isinstance(expr, (Const, Var)):
        return expr
    if isinstance(expr, Unary):
        return Unary(expr.op, expand_difference(expr.child))
    left = expand_difference(expr.left)
    right = expand_difference(expr.right)
    if expr.op == "D":
        return add(exp(left), neg(log(right)))
    return Binary(expr.op, left, right)


def horner(coefficients: Sequence[float], x: float) -> float:
    """Evaluate ascending-order coefficients by Horner's method."""
    accumulator = 0.0
    for coefficient in reversed(coefficients):
        accumulator = coefficient + x * accumulator
    return accumulator


def polynomial_expr(coefficients: Sequence[float], variable: str = "x") -> Expr:
    """Build the Horner expression for ascending-order coefficients."""
    result: Expr = Const(0.0)
    x = Var(variable)
    for coefficient in reversed(coefficients):
        result = add(Const(coefficient), mul(x, result))
    return result


def node_count(expr: Expr) -> int:
    """Count syntax-tree nodes."""
    if isinstance(expr, (Const, Var)):
        return 1
    if isinstance(expr, Unary):
        return 1 + node_count(expr.child)
    return 1 + node_count(expr.left) + node_count(expr.right)


def close(left: float, right: float) -> bool:
    return math.isclose(left, right, rel_tol=1e-12, abs_tol=1e-12)


def demonstrate_compilers() -> None:
    """Compare source, difference-target, product-target, and expansion."""
    x, y = Var("x"), Var("y")
    source = add(exp(add(x, y)), inv(add(Const(3.0), neg(log(y)))))
    difference = compile_difference(source)
    product = compile_product(source)
    expanded = expand_difference(difference)

    print("Nested exp-log expression")
    print(f"  source nodes: {node_count(source)}")
    print(f"  difference-target nodes: {node_count(difference)}")
    print(f"  product-target nodes: {node_count(product)}")
    print("  x       y        source              D target            P target")
    for xv in (-1.25, -0.2, 0.75, 1.4):
        for yv in (0.0, 0.4, 1.0, 2.5):
            env = {"x": xv, "y": yv}
            values = [
                evaluate(source, env),
                evaluate(difference, env),
                evaluate(product, env),
                evaluate(expanded, env),
            ]
            assert all(close(values[0], value) for value in values[1:])
            print(f"  {xv:5.2f}  {yv:5.2f}  {values[0]:18.12g}  "
                  f"{values[1]:18.12g}  {values[2]:18.12g}")


def demonstrate_polynomial() -> None:
    """Show exact Horner representation of 2-3x+5x^3."""
    coefficients = [2.0, -3.0, 0.0, 5.0]
    expression = polynomial_expr(coefficients)
    difference = compile_difference(expression)
    product = compile_product(expression)
    print("\nHorner polynomial 2 - 3x + 5x^3")
    print("  x       direct              Horner/tree         D target            P target")
    for x in (-2.0, -0.5, 0.0, 0.75, 1.5):
        direct = 2.0 - 3.0 * x + 5.0 * x**3
        values = (
            horner(coefficients, x),
            evaluate(expression, {"x": x}),
            evaluate(difference, {"x": x}),
            evaluate(product, {"x": x}),
        )
        assert all(close(direct, value) for value in values)
        print(f"  {x:5.2f}  {direct:18.12g}  {values[1]:18.12g}  "
              f"{values[2]:18.12g}  {values[3]:18.12g}")


def main() -> None:
    demonstrate_compilers()
    demonstrate_polynomial()
    print("\nAll numerical comparisons agree within floating-point tolerance.")


if __name__ == "__main__":
    main()
