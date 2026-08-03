#!/usr/bin/env python3
"""Numerical demonstrations for normalized finite-term integration.

The program constructs exact symbolic records for polynomial, simple-pole,
higher-pole, and constant-rate exponential terms.  It evaluates the represented
integrand and its generated primitive, checks centered finite differences away
from poles, and reports the linear step bound for rational normal forms.
Only Python's standard library is required.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from fractions import Fraction
from math import exp, log
from typing import Iterable, Sequence


@dataclass(frozen=True)
class AlgebraicPiece:
    coefficient: Fraction
    degree: int

    def __post_init__(self) -> None:
        if self.degree < 0:
            raise ValueError("degree must be nonnegative")


@dataclass(frozen=True)
class LogarithmicPiece:
    residue: Fraction
    pole: Fraction


@dataclass(frozen=True)
class HigherPolePiece:
    coefficient: Fraction
    pole: Fraction
    order: int

    def __post_init__(self) -> None:
        if self.order < 2:
            raise ValueError("a higher pole must have order at least two")


@dataclass(frozen=True)
class ExponentialPiece:
    coefficient: Fraction
    rate: Fraction


@dataclass(frozen=True)
class NormalForm:
    algebraic: Sequence[AlgebraicPiece] = field(default_factory=tuple)
    logarithmic: Sequence[LogarithmicPiece] = field(default_factory=tuple)
    higher_poles: Sequence[HigherPolePiece] = field(default_factory=tuple)
    exponential: Sequence[ExponentialPiece] = field(default_factory=tuple)

    def poles(self) -> tuple[float, ...]:
        return tuple(float(p.pole) for p in (*self.logarithmic, *self.higher_poles))

    def regular_at(self, x: float, tolerance: float = 0.0) -> bool:
        return all(abs(x - pole) > tolerance for pole in self.poles())


def evaluate_integrand(form: NormalForm, x: float) -> float:
    """Evaluate the normalized input at a regular real point."""
    if not form.regular_at(x):
        raise ValueError(f"x={x} is a pole")
    algebraic = sum(float(p.coefficient) * x**p.degree for p in form.algebraic)
    logarithmic = sum(float(p.residue) / (x - float(p.pole)) for p in form.logarithmic)
    higher = sum(
        float(p.coefficient) / (x - float(p.pole)) ** p.order
        for p in form.higher_poles
    )
    exponential = sum(
        float(p.coefficient) * exp(float(p.rate) * x) for p in form.exponential
    )
    return algebraic + logarithmic + higher + exponential


def evaluate_primitive(form: NormalForm, x: float) -> float:
    """Evaluate the primitive constructed by the four-stage algorithm."""
    if not form.regular_at(x):
        raise ValueError(f"x={x} is a pole")
    algebraic = sum(
        float(p.coefficient / Fraction(p.degree + 1)) * x ** (p.degree + 1)
        for p in form.algebraic
    )
    logarithmic = sum(
        float(p.residue) * log(abs(x - float(p.pole))) for p in form.logarithmic
    )
    higher = sum(
        -float(p.coefficient / Fraction(p.order - 1))
        / (x - float(p.pole)) ** (p.order - 1)
        for p in form.higher_poles
    )
    exponential = 0.0
    for p in form.exponential:
        c, rate = float(p.coefficient), float(p.rate)
        exponential += c * x if p.rate == 0 else (c / rate) * exp(rate * x)
    return algebraic + logarithmic + higher + exponential


def centered_derivative(form: NormalForm, x: float, h: float = 1.0e-5) -> float:
    """Approximate the derivative of the generated primitive at x."""
    if h <= 0:
        raise ValueError("h must be positive")
    if not form.regular_at(x, h):
        raise ValueError("the finite-difference stencil meets or approaches a pole")
    return (evaluate_primitive(form, x + h) - evaluate_primitive(form, x - h)) / (2.0 * h)


def rational_complexity(polynomial_count: int, simple_count: int, higher_count: int) -> tuple[int, int]:
    """Return (steps, weighted input size) for rational normal-form data."""
    if min(polynomial_count, simple_count, higher_count) < 0:
        raise ValueError("piece counts must be nonnegative")
    steps = polynomial_count + simple_count + higher_count
    size = 1 + 2 * polynomial_count + 3 * simple_count + 4 * higher_count
    return steps, size


def demonstrate(form: NormalForm, sample_points: Iterable[float]) -> None:
    """Print a numerical derivative comparison and complexity certificate."""
    print("Normalized finite-term integration demo")
    print("x             integrand f(x)       centered F'(x)       absolute error")
    print("-" * 76)
    for x in sample_points:
        exact = evaluate_integrand(form, x)
        numerical = centered_derivative(form, x)
        print(f"{x:8.3f}  {exact:20.11e}  {numerical:20.11e}  {abs(exact-numerical):13.3e}")

    steps, size = rational_complexity(
        len(form.algebraic), len(form.logarithmic), len(form.higher_poles)
    )
    print("\nRational-stage complexity (exponential pieces excluded):")
    print(f"steps T = {steps}, weighted size N = {size}")
    print(f"T <= N: {steps <= size}; T <= N^2: {steps <= size**2}")


def main() -> None:
    # f(x) = 3x^2 - 2/(x-1) + 5/(x+2)^3 + 4e^(2x) + 7e^(0x)
    example = NormalForm(
        algebraic=(AlgebraicPiece(Fraction(3), 2),),
        logarithmic=(LogarithmicPiece(Fraction(-2), Fraction(1)),),
        higher_poles=(HigherPolePiece(Fraction(5), Fraction(-2), 3),),
        exponential=(
            ExponentialPiece(Fraction(4), Fraction(2)),
            ExponentialPiece(Fraction(7), Fraction(0)),
        ),
    )
    demonstrate(example, (-3.0, -1.0, 0.0, 0.5, 1.5, 2.0))


if __name__ == "__main__":
    main()
