#!/usr/bin/env python3
"""Numerical illustrations for finite EML expression complexity.

The program computes expression-tree size and depth exactly, evaluates several
expressions numerically, samples their errors against matching target functions,
and tabulates the bound m * ceil(1 / epsilon). Sampling illustrates agreement;
it is not used as a proof of a continuum supremum.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
import math
from typing import Callable, Iterable, Union


@dataclass(frozen=True)
class Var:
    """The input-variable leaf."""


@dataclass(frozen=True)
class Unary:
    """A unary exponential or logarithmic node."""

    op: str
    child: "Expr"


@dataclass(frozen=True)
class Binary:
    """A binary addition or multiplication node."""

    op: str
    left: "Expr"
    right: "Expr"


Expr = Union[Var, Unary, Binary]


def size(expr: Expr) -> int:
    """Return the exact number of nodes in an expression tree."""
    if isinstance(expr, Var):
        return 1
    if isinstance(expr, Unary):
        return 1 + size(expr.child)
    return 1 + size(expr.left) + size(expr.right)


def depth(expr: Expr) -> int:
    """Return tree depth, with a variable leaf at depth zero."""
    if isinstance(expr, Var):
        return 0
    if isinstance(expr, Unary):
        return 1 + depth(expr.child)
    return 1 + max(depth(expr.left), depth(expr.right))


def evaluate(expr: Expr, x: float) -> float:
    """Evaluate an EML tree at x using ordinary floating-point operations."""
    if isinstance(expr, Var):
        return x
    if isinstance(expr, Unary):
        value = evaluate(expr.child, x)
        if expr.op == "exp":
            return math.exp(value)
        if expr.op == "log":
            return math.log(value)
        raise ValueError(f"unknown unary operation: {expr.op}")
    left = evaluate(expr.left, x)
    right = evaluate(expr.right, x)
    if expr.op == "add":
        return left + right
    if expr.op == "mul":
        return left * right
    raise ValueError(f"unknown binary operation: {expr.op}")


def uniform_grid(a: float, b: float, intervals: int) -> Iterable[float]:
    """Generate both endpoints and equally spaced interior grid points."""
    if intervals <= 0:
        raise ValueError("intervals must be positive")
    return (a + (b - a) * i / intervals for i in range(intervals + 1))


def sampled_max_error(
    target: Callable[[float], float], expr: Expr, a: float, b: float, intervals: int
) -> float:
    """Return the largest absolute error observed on a uniform grid."""
    return max(abs(target(x) - evaluate(expr, x)) for x in uniform_grid(a, b, intervals))


def reciprocal_ceiling(epsilon: Fraction) -> int:
    """Compute ceil(1 / epsilon) exactly for 0 < epsilon <= 1."""
    if not (Fraction(0) < epsilon <= Fraction(1)):
        raise ValueError("epsilon must satisfy 0 < epsilon <= 1")
    reciprocal = 1 / epsilon
    return (reciprocal.numerator + reciprocal.denominator - 1) // reciprocal.denominator


def quantitative_bound(description_size: int, epsilon: Fraction) -> int:
    """Return description_size * ceil(1 / epsilon)."""
    if description_size < 0:
        raise ValueError("description_size must be nonnegative")
    return description_size * reciprocal_ceiling(epsilon)


def print_complexity_table(expr: Expr, tolerances: list[Fraction]) -> None:
    """Print direct tree data and reciprocal-tolerance upper bounds."""
    print(f"tree size: {size(expr)}")
    print(f"tree depth: {depth(expr)}")
    print("epsilon       ceil(1/epsilon)   size-based bound")
    for epsilon in tolerances:
        print(
            f"{str(epsilon):<13} "
            f"{reciprocal_ceiling(epsilon):<17} "
            f"{quantitative_bound(size(expr), epsilon)}"
        )


def main() -> None:
    """Run three reproducible numerical demonstrations."""
    x = Var()

    # Example 1: exp(x) + x^2 has size 6 and depth 2.
    exp_plus_square = Binary("add", Unary("exp", x), Binary("mul", x, x))
    error = sampled_max_error(
        lambda value: math.exp(value) + value * value,
        exp_plus_square,
        -1.0,
        1.0,
        2_000,
    )
    print("Example 1: exp(x) + x^2 on [-1, 1]")
    print_complexity_table(
        exp_plus_square,
        [Fraction(1), Fraction(1, 2), Fraction(1, 5), Fraction(1, 10)],
    )
    print(f"sampled maximum error: {error:.3e}\n")

    # Example 2: exp(log(x)) agrees with x on a positive interval.
    exp_log = Unary("exp", Unary("log", x))
    error = sampled_max_error(lambda value: value, exp_log, 0.25, 4.0, 2_000)
    print("Example 2: exp(log(x)) on [0.25, 4]")
    print_complexity_table(exp_log, [Fraction(1), Fraction(1, 4), Fraction(1, 20)])
    print(f"sampled maximum floating-point error: {error:.3e}\n")

    # Example 3: compare a broad balanced tree with a narrow nested tree.
    x_plus_x = Binary("add", x, x)
    balanced = Binary("mul", x_plus_x, x_plus_x)
    nested = Unary("exp", Unary("log", Unary("exp", x)))
    print("Example 3: tree shape comparison")
    print(f"(x+x)(x+x): size={size(balanced)}, depth={depth(balanced)}")
    print(f"exp(log(exp(x))): size={size(nested)}, depth={depth(nested)}")

    # The structural inequality is checked for every displayed tree.
    for expr in (exp_plus_square, exp_log, balanced, nested):
        assert depth(expr) < size(expr)


if __name__ == "__main__":
    main()
