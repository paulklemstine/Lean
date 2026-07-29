#!/usr/bin/env python3
"""Numerical demonstrations of exact tropical-rational compilation for ReLU networks."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Iterable, Sequence, TypeAlias, Union

Vector: TypeAlias = tuple[float, ...]


@dataclass(frozen=True)
class AffinePoly:
    weights: Vector
    bias: float


@dataclass(frozen=True)
class AddPoly:
    left: "TropicalPoly"
    right: "TropicalPoly"


@dataclass(frozen=True)
class MaxPoly:
    left: "TropicalPoly"
    right: "TropicalPoly"


@dataclass(frozen=True)
class ScalePoly:
    coefficient: float
    poly: "TropicalPoly"

    def __post_init__(self) -> None:
        if self.coefficient < 0.0:
            raise ValueError("Tropical-polynomial scaling must be nonnegative")


TropicalPoly: TypeAlias = Union[AffinePoly, AddPoly, MaxPoly, ScalePoly]


@dataclass(frozen=True)
class TropicalRational:
    numerator: TropicalPoly
    denominator: TropicalPoly


@dataclass(frozen=True)
class AffineNode:
    weights: Vector
    bias: float


@dataclass(frozen=True)
class LinearCombination:
    weights: Vector
    nodes: tuple["Network", ...]
    bias: float

    def __post_init__(self) -> None:
        if len(self.weights) != len(self.nodes):
            raise ValueError("Each child must have exactly one weight")


@dataclass(frozen=True)
class ReLUNode:
    input: "Network"


Network: TypeAlias = Union[AffineNode, LinearCombination, ReLUNode]


def relu(value: float) -> float:
    """Return max(value, 0)."""
    return max(value, 0.0)


def dot(weights: Sequence[float], x: Sequence[float]) -> float:
    """Compute a dimension-checked dot product."""
    if len(weights) != len(x):
        raise ValueError("Weight and input dimensions differ")
    return sum(weight * coordinate for weight, coordinate in zip(weights, x))


def zero_poly(dimension: int) -> TropicalPoly:
    return AffinePoly((0.0,) * dimension, 0.0)


def constant_poly(dimension: int, value: float) -> TropicalPoly:
    return AffinePoly((0.0,) * dimension, value)


def eval_poly(poly: TropicalPoly, x: Vector) -> float:
    """Evaluate a generalized max-plus tropical polynomial."""
    if isinstance(poly, AffinePoly):
        return dot(poly.weights, x) + poly.bias
    if isinstance(poly, AddPoly):
        return eval_poly(poly.left, x) + eval_poly(poly.right, x)
    if isinstance(poly, MaxPoly):
        return max(eval_poly(poly.left, x), eval_poly(poly.right, x))
    return poly.coefficient * eval_poly(poly.poly, x)


def eval_rational(expression: TropicalRational, x: Vector) -> float:
    return eval_poly(expression.numerator, x) - eval_poly(expression.denominator, x)


def eval_network(network: Network, x: Vector) -> float:
    """Evaluate a finite scalar feedforward ReLU network."""
    if isinstance(network, AffineNode):
        return dot(network.weights, x) + network.bias
    if isinstance(network, LinearCombination):
        return sum(
            weight * eval_network(node, x)
            for weight, node in zip(network.weights, network.nodes)
        ) + network.bias
    return relu(eval_network(network.input, x))


def add_rational(left: TropicalRational, right: TropicalRational) -> TropicalRational:
    return TropicalRational(
        AddPoly(left.numerator, right.numerator),
        AddPoly(left.denominator, right.denominator),
    )


def add_constant(
    expression: TropicalRational, value: float, dimension: int
) -> TropicalRational:
    return add_rational(
        expression,
        TropicalRational(constant_poly(dimension, value), zero_poly(dimension)),
    )


def scale_rational(coefficient: float, expression: TropicalRational) -> TropicalRational:
    """Scale a pair, swapping its components when the coefficient is negative."""
    magnitude = abs(coefficient)
    if coefficient >= 0.0:
        return TropicalRational(
            ScalePoly(magnitude, expression.numerator),
            ScalePoly(magnitude, expression.denominator),
        )
    return TropicalRational(
        ScalePoly(magnitude, expression.denominator),
        ScalePoly(magnitude, expression.numerator),
    )


def relu_rational(expression: TropicalRational) -> TropicalRational:
    """Use max(P-Q, 0) = max(P, Q) - Q."""
    return TropicalRational(
        MaxPoly(expression.numerator, expression.denominator),
        expression.denominator,
    )


def sum_rationals(
    expressions: Iterable[TropicalRational], dimension: int
) -> TropicalRational:
    total = TropicalRational(zero_poly(dimension), zero_poly(dimension))
    for expression in expressions:
        total = add_rational(total, expression)
    return total


def compile_network(network: Network, dimension: int) -> TropicalRational:
    """Compile a network recursively into an exact tropical-rational pair."""
    if isinstance(network, AffineNode):
        if len(network.weights) != dimension:
            raise ValueError("Affine-node dimension differs from compiler dimension")
        return TropicalRational(
            AffinePoly(network.weights, network.bias), zero_poly(dimension)
        )
    if isinstance(network, LinearCombination):
        weighted_children = (
            scale_rational(weight, compile_network(node, dimension))
            for weight, node in zip(network.weights, network.nodes)
        )
        return add_constant(
            sum_rationals(weighted_children, dimension), network.bias, dimension
        )
    return relu_rational(compile_network(network.input, dimension))


def maximum_error(
    network: Network, expression: TropicalRational, points: Iterable[Vector]
) -> float:
    return max(
        (abs(eval_network(network, x) - eval_rational(expression, x)) for x in points),
        default=0.0,
    )


def linspace(start: float, stop: float, count: int) -> list[float]:
    if count < 2:
        raise ValueError("count must be at least two")
    step = (stop - start) / (count - 1)
    return [start + i * step for i in range(count)]


def two_unit_example() -> Network:
    first = ReLUNode(AffineNode((1.0,), -1.0))
    second = ReLUNode(AffineNode((-1.0,), -2.0))
    return LinearCombination((2.0, -3.0), (first, second), 0.5)


def nested_example() -> Network:
    inner = ReLUNode(AffineNode((1.0,), 0.0))
    affine_combination = LinearCombination((-2.0,), (inner,), 1.0)
    return ReLUNode(affine_combination)


def planar_example() -> Network:
    first = ReLUNode(AffineNode((1.0, -1.0), 0.25))
    second = ReLUNode(AffineNode((-0.5, 2.0), -1.0))
    return LinearCombination((1.5, -0.75), (first, second), -0.2)


def show_example(name: str, network: Network, dimension: int, points: list[Vector]) -> None:
    compiled = compile_network(network, dimension)
    print(f"\n{name}")
    print("input                 network       tropical pair      difference")
    for x in points:
        neural_value = eval_network(network, x)
        tropical_value = eval_rational(compiled, x)
        print(
            f"{str(x):20s} {neural_value:12.6f} {tropical_value:16.6f} "
            f"{neural_value - tropical_value:14.3e}"
        )
    print(f"maximum absolute error: {maximum_error(network, compiled, points):.3e}")


def main() -> None:
    line_points = [(x,) for x in linspace(-4.0, 4.0, 9)]
    dense_line = [(x,) for x in linspace(-5.0, 5.0, 1001)]
    grid = [
        (x, y)
        for x in linspace(-2.0, 2.0, 21)
        for y in linspace(-2.0, 2.0, 21)
    ]

    first = two_unit_example()
    show_example("Two-unit network with a negative output weight", first, 1, line_points)
    print(
        "dense-grid error:",
        f"{maximum_error(first, compile_network(first, 1), dense_line):.3e}",
    )

    second = nested_example()
    show_example("Nested ReLU and denominator preservation", second, 1, line_points)

    third = planar_example()
    selected_grid = [grid[index] for index in (0, 110, 220, 330, 440)]
    show_example("Two-dimensional polyhedral example", third, 2, selected_grid)
    print(
        "full 21-by-21 grid error:",
        f"{maximum_error(third, compile_network(third, 2), grid):.3e}",
    )


if __name__ == "__main__":
    main()
