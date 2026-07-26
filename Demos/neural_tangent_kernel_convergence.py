#!/usr/bin/env python3
"""Numerical demonstrations of frozen neural tangent kernel dynamics.

The script uses only the Python standard library.  It demonstrates geometric
convergence, exact spectral decay (including sign oscillation and a nullspace
obstruction), equal-kernel universality, and the weaker pathwise-action form of
universality.
"""

from __future__ import annotations

from math import sqrt
from typing import Callable, List, Sequence, Tuple

Vector = List[float]
Matrix = List[List[float]]


def add(a: Sequence[float], b: Sequence[float]) -> Vector:
    """Return the componentwise sum of two vectors."""
    if len(a) != len(b):
        raise ValueError("vector dimensions must agree")
    return [x + y for x, y in zip(a, b)]


def subtract(a: Sequence[float], b: Sequence[float]) -> Vector:
    """Return the componentwise difference of two vectors."""
    if len(a) != len(b):
        raise ValueError("vector dimensions must agree")
    return [x - y for x, y in zip(a, b)]


def scale(c: float, v: Sequence[float]) -> Vector:
    """Multiply a vector by a scalar."""
    return [c * x for x in v]


def matvec(matrix: Sequence[Sequence[float]], vector: Sequence[float]) -> Vector:
    """Multiply a dense matrix by a vector."""
    if any(len(row) != len(vector) for row in matrix):
        raise ValueError("matrix and vector dimensions must agree")
    return [sum(a * x for a, x in zip(row, vector)) for row in matrix]


def norm(vector: Sequence[float]) -> float:
    """Return the Euclidean norm."""
    return sqrt(sum(x * x for x in vector))


def frozen_step(kernel: Sequence[Sequence[float]], eta: float,
                residual: Sequence[float]) -> Vector:
    """Apply r -> r - eta K r."""
    return subtract(residual, scale(eta, matvec(kernel, residual)))


def frozen_trajectory(kernel: Matrix, eta: float, target: Vector,
                      initial: Vector, steps: int) -> List[Vector]:
    """Return prediction vectors from step zero through ``steps``."""
    if steps < 0:
        raise ValueError("steps must be nonnegative")
    residual = subtract(initial, target)
    predictions = [list(initial)]
    for _ in range(steps):
        residual = frozen_step(kernel, eta, residual)
        predictions.append(add(target, residual))
    return predictions


def diagonal_spectral_factors(diagonal: Sequence[float], eta: float) -> Vector:
    """Return 1 - eta*lambda for a diagonal kernel's eigenvalues."""
    return [1.0 - eta * eigenvalue for eigenvalue in diagonal]


def max_distance(path_a: Sequence[Sequence[float]],
                 path_b: Sequence[Sequence[float]]) -> float:
    """Return the maximum Euclidean separation of two equal-length paths."""
    if len(path_a) != len(path_b):
        raise ValueError("paths must have equal lengths")
    return max((norm(subtract(a, b)) for a, b in zip(path_a, path_b)), default=0.0)


def pathwise_action_trajectory(
    action: Callable[[Sequence[float]], Vector], eta: float,
    initial_residual: Vector, steps: int
) -> List[Vector]:
    """Iterate a residual path using an arbitrary kernel-action function."""
    residual = list(initial_residual)
    path = [list(residual)]
    for _ in range(steps):
        residual = subtract(residual, scale(eta, action(residual)))
        path.append(residual)
    return path


def convergence_demo() -> None:
    """Display geometric convergence and its theoretical envelope."""
    kernel = [[1.0, 0.0], [0.0, 3.0]]
    eta = 0.5
    target = [1.0, -2.0]
    initial = [3.0, -3.0]
    q = 0.5
    path = frozen_trajectory(kernel, eta, target, initial, 8)
    initial_error = norm(subtract(initial, target))
    print("\nGeometric convergence (q = 0.5)")
    print("step | residual norm | q^n ||r_0||")
    for step, prediction in enumerate(path):
        residual_norm = norm(subtract(prediction, target))
        envelope = (q ** step) * initial_error
        print(f"{step:4d} | {residual_norm:13.8f} | {envelope:13.8f}")
        assert residual_norm <= envelope + 1e-12


def spectral_demo() -> None:
    """Compare exact eigendirection factors and exhibit a nullspace mode."""
    diagonal = [1.0, 3.0]
    eta = 0.5
    factors = diagonal_spectral_factors(diagonal, eta)
    residual = [2.0, -1.0]
    print("\nExact spectral decay")
    print(f"factors: {factors} (the second component alternates sign)")
    for step in range(6):
        exact = [2.0 * factors[0] ** step, -1.0 * factors[1] ** step]
        print(f"step {step}: computed={residual}, exact={exact}")
        assert max(abs(a - b) for a, b in zip(residual, exact)) < 1e-12
        residual = frozen_step([[1.0, 0.0], [0.0, 3.0]], eta, residual)

    null_residual = [2.0, -1.0]
    for _ in range(5):
        null_residual = frozen_step([[1.0, 0.0], [0.0, 0.0]], eta, null_residual)
    print(f"nullspace example after 5 steps: {null_residual}")
    assert abs(null_residual[1] + 1.0) < 1e-12


def universality_demo() -> None:
    """Demonstrate global equal-kernel and pathwise-action universality."""
    kernel = [[2.0, 0.25], [0.25, 1.0]]
    path_a = frozen_trajectory(kernel, 0.3, [0.0, 1.0], [2.0, -1.0], 10)
    path_b = frozen_trajectory([row[:] for row in kernel], 0.3,
                               [0.0, 1.0], [2.0, -1.0], 10)
    discrepancy = max_distance(path_a, path_b)
    print("\nEqual-kernel architecture universality")
    print(f"maximum trajectory discrepancy: {discrepancy:.3e}")
    assert discrepancy == 0.0

    # These operators differ globally: K1(x,y)=(x,y), K2(x,y)=(x,2y).
    # Starting on the x-axis keeps both paths there, where their actions agree.
    action_1 = lambda r: [r[0], r[1]]
    action_2 = lambda r: [r[0], 2.0 * r[1]]
    path_1 = pathwise_action_trajectory(action_1, 0.25, [4.0, 0.0], 8)
    path_2 = pathwise_action_trajectory(action_2, 0.25, [4.0, 0.0], 8)
    pathwise_discrepancy = max_distance(path_1, path_2)
    print("Pathwise universality for globally different kernels")
    print(f"maximum trajectory discrepancy: {pathwise_discrepancy:.3e}")
    assert pathwise_discrepancy == 0.0


def main() -> None:
    """Run all demonstrations."""
    convergence_demo()
    spectral_demo()
    universality_demo()


if __name__ == "__main__":
    main()
