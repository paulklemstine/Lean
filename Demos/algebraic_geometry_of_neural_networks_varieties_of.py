#!/usr/bin/env python3
"""Numerical demonstrations for max-affine tropical dequantization.

The script uses only the Python standard library. It evaluates binary max-affine
expression trees, their log-sum-exp dequantizations, the depth error bound, the
classification certificate, the layerwise budget identity, and the two scalar
ReLU obstructions discussed in the accompanying paper.
"""
from __future__ import annotations

from dataclasses import dataclass
import math
from typing import Sequence, TypeAlias

Vector: TypeAlias = tuple[float, ...]


@dataclass(frozen=True)
class Affine:
    """An affine leaf x -> weights dot x + bias."""

    weights: Vector
    bias: float


@dataclass(frozen=True)
class Maximum:
    """A binary tropical maximum node."""

    left: "Expression"
    right: "Expression"


Expression: TypeAlias = Affine | Maximum


def affine_value(leaf: Affine, point: Sequence[float]) -> float:
    """Evaluate an affine leaf."""
    if len(leaf.weights) != len(point):
        raise ValueError("Point and weight vectors must have equal dimensions")
    return sum(w * x for w, x in zip(leaf.weights, point)) + leaf.bias


def depth(expression: Expression) -> int:
    """Return the greatest number of maximum nodes on a root-to-leaf path."""
    if isinstance(expression, Affine):
        return 0
    return 1 + max(depth(expression.left), depth(expression.right))


def tropical_eval(expression: Expression, point: Sequence[float]) -> float:
    """Evaluate the hard max-affine expression."""
    if isinstance(expression, Affine):
        return affine_value(expression, point)
    return max(
        tropical_eval(expression.left, point),
        tropical_eval(expression.right, point),
    )


def stable_lse(a: float, b: float, beta: float) -> float:
    """Compute binary log-sum-exp without avoidable overflow."""
    if beta <= 0.0:
        raise ValueError("beta must be positive")
    maximum = max(a, b)
    return maximum + math.log(
        math.exp(beta * (a - maximum)) + math.exp(beta * (b - maximum))
    ) / beta


def smooth_eval(expression: Expression, point: Sequence[float], beta: float) -> float:
    """Evaluate the recursively dequantized expression."""
    if isinstance(expression, Affine):
        return affine_value(expression, point)
    return stable_lse(
        smooth_eval(expression.left, point, beta),
        smooth_eval(expression.right, point, beta),
        beta,
    )


def error_bound(expression: Expression, beta: float) -> float:
    """Return depth * log(2) / beta."""
    if beta <= 0.0:
        raise ValueError("beta must be positive")
    return depth(expression) * math.log(2.0) / beta


def certified_label(
    expression: Expression, point: Sequence[float], beta: float
) -> tuple[bool, bool]:
    """Return (hard positive label, label certified stable under smoothing)."""
    hard = tropical_eval(expression, point)
    return hard > 0.0, abs(hard) > error_bound(expression, beta)


def region_budget(widths: Sequence[int]) -> int:
    """Compute the recursively proposed layerwise budget."""
    budget = 1
    for width in widths:
        if width < 0:
            raise ValueError("widths must be nonnegative")
        budget *= 2 * width
    return budget


def region_budget_closed_form(widths: Sequence[int]) -> int:
    """Compute 2^L times the product of widths."""
    product = math.prod(widths)
    return (2 ** len(widths)) * product


def relu(x: float) -> float:
    """Scalar rectified linear unit."""
    return max(0.0, x)


def sample_expression() -> Expression:
    """Construct a depth-two max-affine score on R^2."""
    return Maximum(
        Maximum(Affine((1.0, -0.5), -0.25), Affine((-0.75, 1.0), -0.10)),
        Affine((0.20, 0.30), -0.60),
    )


def demonstrate_dequantization() -> None:
    """Print pointwise values and check the depth-controlled error numerically."""
    expression = sample_expression()
    points: list[Vector] = [
        (-1.0, -1.0),
        (-0.25, 0.5),
        (0.0, 0.0),
        (0.75, -0.25),
        (1.0, 1.0),
    ]
    print("\nDepth-controlled dequantization")
    print(f"expression depth: {depth(expression)}")
    for beta in (1.0, 4.0, 16.0):
        bound = error_bound(expression, beta)
        print(f"\nbeta={beta:g}, theorem bound={bound:.8f}")
        for point in points:
            hard = tropical_eval(expression, point)
            soft = smooth_eval(expression, point, beta)
            error = soft - hard
            assert -1e-12 <= error <= bound + 1e-12
            label, certified = certified_label(expression, point, beta)
            smooth_label = soft > 0.0
            if certified:
                assert label == smooth_label
            print(
                f"  x={point!s:>14} hard={hard: .6f} soft={soft: .6f} "
                f"error={error: .6f} certified={certified}"
            )


def demonstrate_soft_relu() -> None:
    """Show the one-gate softplus error approaching its maximum at zero."""
    beta = 5.0
    bound = math.log(2.0) / beta
    print("\nSoft-ReLU uniform estimate")
    print(f"beta={beta:g}, uniform bound={bound:.8f}")
    for x in (-2.0, -0.5, 0.0, 0.5, 2.0):
        soft = stable_lse(0.0, x, beta)
        hard = relu(x)
        print(f"  x={x: .2f} ReLU={hard:.8f} softplus={soft:.8f} error={soft-hard:.8f}")
    assert math.isclose(stable_lse(0.0, 0.0, beta), bound)


def demonstrate_region_identity() -> None:
    """Compare the recurrence and its exact closed form."""
    widths = [3, 5, 2, 4]
    recursive = region_budget(widths)
    closed = region_budget_closed_form(widths)
    assert recursive == closed
    print("\nLayerwise budget identity")
    print(f"widths={widths}")
    print(f"recurrence={recursive}, 2^L * product(widths)={closed}")


def demonstrate_obstructions() -> None:
    """Display the zero plateau and width-one kink of scalar ReLU."""
    epsilon = 0.25
    pair_count = math.comb(1, 2)
    left = relu(-epsilon)
    right = relu(epsilon)
    assert left == 0.0 and right == epsilon and pair_count == 0
    print("\nScalar ReLU obstructions")
    print("negative samples all lie in the raw zero set:", [relu(x) for x in (-3.0, -1.0, -0.1)])
    print(
        f"choose(1,2)={pair_count}, yet ReLU(-epsilon)={left:g} and "
        f"ReLU(epsilon)={right:g} for epsilon={epsilon:g}"
    )


def main() -> None:
    demonstrate_dequantization()
    demonstrate_soft_relu()
    demonstrate_region_identity()
    demonstrate_obstructions()


if __name__ == "__main__":
    main()
