#!/usr/bin/env python3
"""Numerical demonstrations for rational exponential--logarithmic expressions.

The calculations illustrate expression evaluation and bounded searches. They do
not prove algebraicity, transcendence, or conjectural multiplication elimination.
"""
from __future__ import annotations

from dataclasses import dataclass
from decimal import Decimal, getcontext
from itertools import product
from math import comb
from typing import Dict, Iterable, List, Mapping, Sequence, Tuple, Union

getcontext().prec = 60


@dataclass(frozen=True)
class Const:
    value: Decimal


@dataclass(frozen=True)
class Var:
    pass


@dataclass(frozen=True)
class Exp:
    child: "Expr"


@dataclass(frozen=True)
class Log:
    child: "Expr"


@dataclass(frozen=True)
class Add:
    left: "Expr"
    right: "Expr"


@dataclass(frozen=True)
class Mul:
    left: "Expr"
    right: "Expr"


Expr = Union[Const, Var, Exp, Log, Add, Mul]
BivariatePolynomial = Dict[Tuple[int, int], int]


def evaluate(expr: Expr, x: Decimal = Decimal(0)) -> Decimal:
    """Recursively evaluate an expression tree at x using Decimal arithmetic."""
    if isinstance(expr, Const):
        return expr.value
    if isinstance(expr, Var):
        return x
    if isinstance(expr, Exp):
        return evaluate(expr.child, x).exp()
    if isinstance(expr, Log):
        value = evaluate(expr.child, x)
        if value <= 0:
            raise ValueError("This numerical demo evaluates log only on positive inputs")
        return value.ln()
    if isinstance(expr, Add):
        return evaluate(expr.left, x) + evaluate(expr.right, x)
    if isinstance(expr, Mul):
        return evaluate(expr.left, x) * evaluate(expr.right, x)
    raise TypeError(f"Unknown expression node: {expr!r}")


def node_count(expr: Expr) -> int:
    """Return the number of nodes in an expression tree."""
    if isinstance(expr, (Const, Var)):
        return 1
    if isinstance(expr, (Exp, Log)):
        return 1 + node_count(expr.child)
    if isinstance(expr, (Add, Mul)):
        return 1 + node_count(expr.left) + node_count(expr.right)
    raise TypeError(f"Unknown expression node: {expr!r}")


def horner(coefficients: Sequence[int], x: Decimal) -> Decimal:
    """Evaluate c_0 + c_1*x + ... by Horner's rule."""
    result = Decimal(0)
    for coefficient in reversed(coefficients):
        result = result * x + Decimal(coefficient)
    return result


def bounded_relation_search(
    value: Decimal, degree: int, coefficient_bound: int, keep: int = 5
) -> List[Tuple[Decimal, Tuple[int, ...]]]:
    """Return the smallest residuals among bounded nonzero integer polynomials."""
    if degree < 0 or coefficient_bound < 1 or keep < 1:
        raise ValueError("Require degree >= 0, coefficient_bound >= 1, and keep >= 1")
    candidates: List[Tuple[Decimal, Tuple[int, ...]]] = []
    choices = range(-coefficient_bound, coefficient_bound + 1)
    for coefficients in product(choices, repeat=degree + 1):
        if all(c == 0 for c in coefficients) or coefficients[-1] == 0:
            continue
        residual = abs(horner(coefficients, value))
        candidates.append((residual, coefficients))
    candidates.sort(key=lambda item: (item[0], item[1]))
    return candidates[:keep]


def substitute_sum(coefficients: Sequence[int]) -> BivariatePolynomial:
    """Expand p(X+Y) as a map (power of X, power of Y) -> coefficient."""
    result: BivariatePolynomial = {}
    for total_degree, coefficient in enumerate(coefficients):
        for x_degree in range(total_degree + 1):
            y_degree = total_degree - x_degree
            term = coefficient * comb(total_degree, x_degree)
            if term:
                key = (x_degree, y_degree)
                result[key] = result.get(key, 0) + term
    return {key: value for key, value in result.items() if value != 0}


def specialize_y_zero(polynomial: Mapping[Tuple[int, int], int]) -> Tuple[int, ...]:
    """Recover the coefficients of Q(X,0)."""
    max_degree = max((i for (i, j) in polynomial if j == 0), default=0)
    return tuple(polynomial.get((i, 0), 0) for i in range(max_degree + 1))


def format_polynomial(coefficients: Sequence[int]) -> str:
    terms = [f"{c:+d}*T^{i}" for i, c in enumerate(coefficients) if c]
    return " ".join(terms).lstrip("+") or "0"


def featured_expression() -> Expr:
    return Add(Exp(Exp(Const(Decimal(1)))), Log(Const(Decimal(2))))


def demonstrate_evaluation() -> None:
    expr = featured_expression()
    exp_exp_one = evaluate(Exp(Exp(Const(Decimal(1)))))
    log_two = evaluate(Log(Const(Decimal(2))))
    value = evaluate(expr)
    print("Featured expression: exp(exp(1)) + log(2)")
    print(f"Tree nodes: {node_count(expr)}")
    print(f"exp(exp(1)) = {exp_exp_one}")
    print(f"log(2)       = {log_two}")
    print(f"sum          = {value}\n")


def demonstrate_relation_search() -> None:
    value = evaluate(featured_expression())
    print("Small bounded polynomial-relation search")
    print("degree <= 3, coefficients in [-3, 3]")
    for residual, coefficients in bounded_relation_search(value, 3, 3, keep=5):
        print(f"residual={residual:.8E}  p(T)={format_polynomial(coefficients)}")
    print("This finite search is illustrative and is not a transcendence test.\n")


def demonstrate_substitution() -> None:
    coefficients = (2, -3, 1)  # p(T) = T^2 - 3T + 2
    expanded = substitute_sum(coefficients)
    recovered = specialize_y_zero(expanded)
    print("Substitution witness for injectivity")
    print(f"p coefficients, low to high: {coefficients}")
    print(f"nonzero coefficients of p(X+Y): {dict(sorted(expanded.items()))}")
    print(f"coefficients after setting Y=0: {recovered}")
    assert recovered == coefficients
    print("Specialization recovers p exactly.\n")


def main() -> None:
    demonstrate_evaluation()
    demonstrate_relation_search()
    demonstrate_substitution()


if __name__ == "__main__":
    main()
