#!/usr/bin/env python3
"""Numerical demonstrations of shifted-Hankel moment certificates.

Uses only the Python standard library.  It computes weighted spectral moments,
builds shifted Hankel matrices, checks the first nonlinear certificate, verifies
the exact quadratic identity, and illustrates its deterministic error budget.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import sqrt
from typing import Iterable, Sequence


@dataclass(frozen=True)
class Certificate:
    moments: tuple[float, float, float]
    gap: float
    detects_negative_node: bool


def spectral_moment(weights: Sequence[float], nodes: Sequence[float], k: int) -> float:
    """Return p_k = sum_j w_j x_j^k."""
    if len(weights) != len(nodes):
        raise ValueError("weights and nodes must have the same length")
    if k < 0:
        raise ValueError("moment order must be nonnegative")
    return sum(w * (x ** k) for w, x in zip(weights, nodes))


def moments(weights: Sequence[float], nodes: Sequence[float], max_order: int) -> list[float]:
    """Return [p_0, ..., p_max_order]."""
    return [spectral_moment(weights, nodes, k) for k in range(max_order + 1)]


def shifted_hankel(moment_values: Sequence[float], level: int) -> list[list[float]]:
    """Build H_level[a,b] = p_(a+b+1)."""
    if level < 1:
        raise ValueError("level must be positive")
    required = 2 * level
    if len(moment_values) < required:
        raise ValueError(f"need moments p_0 through p_{2 * level - 1}")
    return [[moment_values[a + b + 1] for b in range(level)] for a in range(level)]


def polynomial_value(coefficients: Sequence[float], x: float) -> float:
    """Evaluate a polynomial by Horner's rule."""
    value = 0.0
    for coefficient in reversed(coefficients):
        value = value * x + coefficient
    return value


def quadratic_form(matrix: Sequence[Sequence[float]], vector: Sequence[float]) -> float:
    """Compute v^T A v for a square matrix."""
    if len(matrix) != len(vector) or any(len(row) != len(vector) for row in matrix):
        raise ValueError("matrix and vector dimensions do not agree")
    return sum(vector[a] * matrix[a][b] * vector[b]
               for a in range(len(vector)) for b in range(len(vector)))


def spectral_square_sum(
    weights: Sequence[float], nodes: Sequence[float], coefficients: Sequence[float]
) -> float:
    """Compute sum_j w_j x_j f(x_j)^2."""
    return sum(w * x * polynomial_value(coefficients, x) ** 2
               for w, x in zip(weights, nodes))


def first_certificate(weights: Sequence[float], nodes: Sequence[float]) -> Certificate:
    """Evaluate D = p_2^2 - p_1 p_3; D > 0 certifies a negative node."""
    p1, p2, p3 = (spectral_moment(weights, nodes, k) for k in (1, 2, 3))
    gap = p2 * p2 - p1 * p3
    return Certificate((p1, p2, p3), gap, gap > 0.0)


def robust_violation(gap: float, bound: float, error: float) -> tuple[bool, float]:
    """Apply the sufficient condition gap > 2(2 B eps + eps^2)."""
    if bound < 0.0 or error < 0.0:
        raise ValueError("bound and error must be nonnegative")
    budget = 2.0 * (2.0 * bound * error + error * error)
    return gap > budget, budget


def format_matrix(matrix: Iterable[Iterable[float]]) -> str:
    return "\n".join("  [" + ", ".join(f"{x:10.5f}" for x in row) + "]" for row in matrix)


def run_demo() -> None:
    examples = [
        ("nonnegative spectrum", [1.0, 1.0, 1.0], [1.0, 2.0, 3.0]),
        ("detected negative node", [1.0, 1.0, 1.0], [-1.0, 2.0, 3.0]),
        ("negative node not detected at level two", [0.01, 1.0, 1.0], [-0.01, 1.0, 2.0]),
    ]
    print("FIRST NONLINEAR MOMENT CERTIFICATE")
    for name, weights, nodes in examples:
        result = first_certificate(weights, nodes)
        p1, p2, p3 = result.moments
        print(f"\n{name}: nodes={nodes}")
        print(f"  (p1, p2, p3) = ({p1:.6g}, {p2:.6g}, {p3:.6g})")
        print(f"  D = p2^2 - p1*p3 = {result.gap:.6g}")
        print(f"  certificate reports negative support: {result.detects_negative_node}")

    weights = [0.5, 1.0, 1.5]
    nodes = [0.25, 1.5, 2.0]
    level = 3
    coefficient_vector = [1.0, -0.7, 0.2]
    ps = moments(weights, nodes, 2 * level - 1)
    hankel = shifted_hankel(ps, level)
    lhs = quadratic_form(hankel, coefficient_vector)
    rhs = spectral_square_sum(weights, nodes, coefficient_vector)
    print("\nSHIFTED-HANKEL QUADRATIC IDENTITY")
    print(format_matrix(hankel))
    print(f"  c^T H c                    = {lhs:.12f}")
    print(f"  sum_j w_j x_j f(x_j)^2    = {rhs:.12f}")
    print(f"  absolute numerical error  = {abs(lhs - rhs):.3e}")

    detected = first_certificate([1.0, 1.0, 1.0], [-1.0, 2.0, 3.0])
    bound = max(abs(value) for value in detected.moments)
    error = 0.1
    stable, budget = robust_violation(detected.gap, bound, error)
    print("\nROBUSTNESS BUDGET")
    print(f"  exact margin delta = {detected.gap:.6g}")
    print(f"  moment bound B     = {bound:.6g}")
    print(f"  uniform error eps  = {error:.6g}")
    print(f"  worst-case budget  = {budget:.6g}")
    print(f"  violation guaranteed to survive: {stable}")

    # Equality example: all positive nodes coincide, so Cauchy--Schwarz is tight.
    equality = first_certificate([1.0, 2.0], [2.0, 2.0])
    print("\nBOUNDARY EXAMPLE")
    print(f"  repeated node gap = {equality.gap:.6g} (zero up to arithmetic precision)")
    print(f"  sqrt(p1*p3) = {sqrt(equality.moments[0] * equality.moments[2]):.6g}")


if __name__ == "__main__":
    run_demo()
