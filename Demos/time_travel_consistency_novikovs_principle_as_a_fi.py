#!/usr/bin/env python3
"""Numerical demonstrations of contractive causal consistency.

The examples illustrate affine convergence, a posteriori error certificates,
a nonlinear polynomial contraction on an invariant interval, and two
fixed-point-free paradox maps. Only the Python standard library is required.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import isclose
from typing import Callable, Generic, Hashable, Iterable, TypeVar

State = TypeVar("State")
FiniteState = TypeVar("FiniteState", bound=Hashable)


@dataclass(frozen=True)
class IterationRecord:
    """One scalar fixed-point iteration and its certified error bound."""

    step: int
    value: float
    residual: float
    certified_error: float


def iterate_contraction(
    return_map: Callable[[float], float],
    contraction_factor: float,
    initial_state: float,
    tolerance: float = 1e-10,
    max_steps: int = 100,
) -> list[IterationRecord]:
    """Iterate a scalar contraction until its residual certificate is small.

    If ``K`` is the contraction factor, the returned certificate is
    ``abs(x - F(x)) / (1 - K)``, an upper bound on distance to the fixed point.
    """
    if not 0.0 <= contraction_factor < 1.0:
        raise ValueError("contraction_factor must lie in [0, 1)")
    if tolerance <= 0.0:
        raise ValueError("tolerance must be positive")
    if max_steps < 0:
        raise ValueError("max_steps must be nonnegative")

    records: list[IterationRecord] = []
    x = float(initial_state)
    for step in range(max_steps + 1):
        residual = abs(x - return_map(x))
        certificate = residual / (1.0 - contraction_factor)
        records.append(IterationRecord(step, x, residual, certificate))
        if certificate <= tolerance:
            break
        x = return_map(x)
    return records


def affine_return_map(a: float, b: float) -> Callable[[float], float]:
    """Return the affine causal law F(x) = a*x + b."""
    return lambda x: a * x + b


def affine_fixed_point(a: float, b: float) -> float:
    """Compute the unique affine fixed point when abs(a) < 1."""
    if abs(a) >= 1.0:
        raise ValueError("the affine consistency theorem requires abs(a) < 1")
    return b / (1.0 - a)


def polynomial_value(coefficients: list[float], x: float) -> float:
    """Evaluate coefficients in ascending order by Horner's method."""
    value = 0.0
    for coefficient in reversed(coefficients):
        value = value * x + coefficient
    return value


def sample_interval_conditions(
    coefficients: list[float],
    lower: float,
    upper: float,
    samples: int = 1001,
) -> tuple[bool, float]:
    """Sample invariance and a derivative bound on an interval.

    This is a numerical illustration, not a proof of global interval bounds.
    The derivative is evaluated analytically at an evenly spaced grid.
    """
    if lower > upper:
        raise ValueError("lower must not exceed upper")
    if samples < 2:
        raise ValueError("samples must be at least two")
    derivative = [i * coefficients[i] for i in range(1, len(coefficients))]
    invariant = True
    max_derivative = 0.0
    for i in range(samples):
        x = lower + (upper - lower) * i / (samples - 1)
        y = polynomial_value(coefficients, x)
        invariant = invariant and lower <= y <= upper
        max_derivative = max(
            max_derivative, abs(polynomial_value(derivative, x))
        )
    return invariant, max_derivative


def find_finite_fixed_points(
    states: Iterable[FiniteState],
    return_map: Callable[[FiniteState], FiniteState],
) -> list[FiniteState]:
    """Enumerate all fixed points of a finite table-defined return map."""
    return [state for state in states if return_map(state) == state]


def trace_finite_orbit(
    return_map: Callable[[FiniteState], FiniteState],
    initial_state: FiniteState,
) -> tuple[list[FiniteState], list[FiniteState]]:
    """Trace a finite orbit and return its transient prefix and eventual cycle."""
    first_seen: dict[FiniteState, int] = {}
    orbit: list[FiniteState] = []
    state = initial_state
    while state not in first_seen:
        first_seen[state] = len(orbit)
        orbit.append(state)
        state = return_map(state)
    cycle_start = first_seen[state]
    return orbit[:cycle_start], orbit[cycle_start:]


def print_records(title: str, records: list[IterationRecord], exact: float) -> None:
    """Print selected rows from an iteration table."""
    print(f"\n{title}")
    print("step        value         residual       certificate     actual error")
    selected = records[:8]
    if len(records) > 9:
        selected += [records[-1]]
    for record in selected:
        print(
            f"{record.step:4d}  {record.value:13.9f}  "
            f"{record.residual:13.6e}  {record.certified_error:13.6e}  "
            f"{abs(record.value - exact):13.6e}"
        )


def demonstrate_affine_consistency() -> None:
    """Show global convergence to the fixed point of x -> x/2 + 3."""
    a, b = 0.5, 3.0
    return_map = affine_return_map(a, b)
    exact = affine_fixed_point(a, b)
    for initial in (0.0, 20.0):
        records = iterate_contraction(return_map, abs(a), initial, 1e-9, 100)
        print_records(f"Affine loop from x0={initial:g}; fixed point={exact:g}", records, exact)
        assert all(
            abs(record.value - exact) <= record.certified_error + 1e-12
            for record in records
        )


def demonstrate_polynomial_domain() -> None:
    """Show a nonlinear polynomial contraction on the invariant interval [-1, 1]."""
    # p(x) = 0.2*x^2 + 0.3*x + 0.1. On [-1,1],
    # p([-1,1]) is contained in [-1,1] and |p'(x)| = |0.4*x+0.3| <= 0.7.
    coefficients = [0.1, 0.3, 0.2]
    return_map = lambda x: polynomial_value(coefficients, x)
    invariant, sampled_derivative_bound = sample_interval_conditions(
        coefficients, -1.0, 1.0
    )
    contraction_factor = 0.7
    records = iterate_contraction(return_map, contraction_factor, -1.0, 1e-10, 100)
    approximate_fixed_point = records[-1].value
    print("\nNonlinear polynomial loop on [-1, 1]")
    print(f"sampled interval invariance: {invariant}")
    print(f"sampled max |p'(x)|: {sampled_derivative_bound:.6f}")
    print(f"fixed-point approximation: {approximate_fixed_point:.12f}")
    print(f"certified error bound: {records[-1].certified_error:.3e}")
    assert invariant
    assert sampled_derivative_bound <= contraction_factor + 1e-12
    assert abs(return_map(approximate_fixed_point) - approximate_fixed_point) <= 1e-10


def demonstrate_paradoxes() -> None:
    """Display algebraic and finite failures outside the contraction hypotheses."""
    # x^2 + 1 = x has discriminant -3, hence no real fixed point.
    discriminant = (-1.0) ** 2 - 4.0
    print("\nQuadratic map F(x)=x^2+1")
    print(f"fixed-point discriminant: {discriminant:g} (negative: no real solution)")
    assert discriminant < 0.0

    negate = lambda value: not value
    fixed_points = find_finite_fixed_points([False, True], negate)
    transient, cycle = trace_finite_orbit(negate, False)
    print("\nBoolean negation")
    print(f"fixed points: {fixed_points}")
    print(f"transient prefix: {transient}; eventual cycle: {cycle}")
    assert fixed_points == []
    assert cycle == [False, True]


def main() -> None:
    """Run all demonstrations and internal numerical checks."""
    demonstrate_affine_consistency()
    demonstrate_polynomial_domain()
    demonstrate_paradoxes()
    assert isclose(affine_fixed_point(0.5, 3.0), 6.0)
    print("\nAll demonstrations completed successfully.")


if __name__ == "__main__":
    main()
