#!/usr/bin/env python3
"""Numerical demonstrations of finite-sample neural tangent kernel dynamics.

The script uses only the Python standard library.  It constructs Gram kernels,
checks the energy identity, runs fixed-kernel residual descent, and evaluates the
entrywise Jacobian-drift certificate.
"""

from __future__ import annotations

from math import sqrt
from typing import Iterable, List, Sequence, Tuple

Vector = List[float]
Matrix = List[List[float]]


def transpose(a: Sequence[Sequence[float]]) -> Matrix:
    """Return the transpose of a rectangular matrix."""
    if not a:
        return []
    return [list(column) for column in zip(*a)]


def matvec(a: Sequence[Sequence[float]], x: Sequence[float]) -> Vector:
    """Multiply a dense matrix by a vector."""
    if any(len(row) != len(x) for row in a):
        raise ValueError("matrix and vector dimensions do not match")
    return [sum(value * coordinate for value, coordinate in zip(row, x)) for row in a]


def matmul(a: Sequence[Sequence[float]], b: Sequence[Sequence[float]]) -> Matrix:
    """Multiply two dense matrices."""
    bt = transpose(b)
    if a and b and len(a[0]) != len(b):
        raise ValueError("matrix dimensions do not match")
    return [[sum(x * y for x, y in zip(row, column)) for column in bt] for row in a]


def dot(x: Sequence[float], y: Sequence[float]) -> float:
    """Compute the Euclidean inner product."""
    if len(x) != len(y):
        raise ValueError("vector dimensions do not match")
    return sum(a * b for a, b in zip(x, y))


def squared_norm(x: Sequence[float]) -> float:
    """Compute the squared Euclidean norm."""
    return dot(x, x)


def neural_tangent_kernel(jacobian: Sequence[Sequence[float]]) -> Matrix:
    """Construct K = J J^T from sample-by-parameter Jacobian rows."""
    return matmul(jacobian, transpose(jacobian))


def parameter_gradient(jacobian: Sequence[Sequence[float]], residual: Sequence[float]) -> Vector:
    """Compute J^T r."""
    return matvec(transpose(jacobian), residual)


def residual_descent(
    kernel: Sequence[Sequence[float]],
    learning_rate: float,
    initial_residual: Sequence[float],
    steps: int,
) -> List[Vector]:
    """Return r_0,...,r_steps for r_(t+1) = r_t - eta K r_t."""
    if steps < 0:
        raise ValueError("steps must be nonnegative")
    history = [list(initial_residual)]
    for _ in range(steps):
        kr = matvec(kernel, history[-1])
        history.append([r - learning_rate * update for r, update in zip(history[-1], kr)])
    return history


def entrywise_drift_certificate(
    jacobian_0: Sequence[Sequence[float]], jacobian_1: Sequence[Sequence[float]]
) -> Tuple[float, float, float, float]:
    """Return (B, delta, observed kernel drift, theorem bound 2 p B delta)."""
    if len(jacobian_0) != len(jacobian_1) or any(
        len(row_0) != len(row_1) for row_0, row_1 in zip(jacobian_0, jacobian_1)
    ):
        raise ValueError("Jacobians must have equal shapes")
    p = len(jacobian_0[0]) if jacobian_0 else 0
    entries_0 = [abs(x) for row in jacobian_0 for x in row]
    entries_1 = [abs(x) for row in jacobian_1 for x in row]
    differences = [
        abs(x_1 - x_0)
        for row_0, row_1 in zip(jacobian_0, jacobian_1)
        for x_0, x_1 in zip(row_0, row_1)
    ]
    b = max(entries_0 + entries_1, default=0.0)
    delta = max(differences, default=0.0)
    k0 = neural_tangent_kernel(jacobian_0)
    k1 = neural_tangent_kernel(jacobian_1)
    observed = max(
        (abs(y - x) for row_0, row_1 in zip(k0, k1) for x, y in zip(row_0, row_1)),
        default=0.0,
    )
    return b, delta, observed, 2.0 * p * b * delta


def print_matrix(name: str, matrix: Sequence[Sequence[float]]) -> None:
    """Pretty-print a small dense matrix."""
    print(f"{name} =")
    for row in matrix:
        print("  [" + ", ".join(f"{value:9.5f}" for value in row) + "]")


def demonstrate_energy_identity() -> None:
    """Show r^T K r = ||J^T r||^2 and Gram positivity numerically."""
    jacobian = [[1.0, -0.5, 0.2], [0.3, 1.1, -0.4], [-0.7, 0.2, 0.9]]
    residual = [1.2, -0.8, 0.5]
    kernel = neural_tangent_kernel(jacobian)
    gradient = parameter_gradient(jacobian, residual)
    left = dot(residual, matvec(kernel, residual))
    right = squared_norm(gradient)
    print("\n1. Gram energy identity")
    print_matrix("K", kernel)
    print(f"r^T K r       = {left:.12f}")
    print(f"||J^T r||^2   = {right:.12f}")
    print(f"absolute gap  = {abs(left - right):.3e}")


def demonstrate_geometric_convergence() -> None:
    """Show the q^t bound for a diagonal NTK with a stable learning rate."""
    jacobian = [[1.0, 0.0, 0.0], [0.0, sqrt(2.0), 0.0], [0.0, 0.0, sqrt(3.0)]]
    kernel = neural_tangent_kernel(jacobian)
    eta = 0.5
    eigenvalues = [1.0, 2.0, 3.0]
    q = max((1.0 - eta * value) ** 2 for value in eigenvalues)
    initial = [2.0, -1.0, 3.0]
    history = residual_descent(kernel, eta, initial, 8)
    print("\n2. Fixed-kernel geometric convergence")
    print(f"learning rate eta = {eta:.3f}; contraction factor q = {q:.3f}")
    print(" t       ||r_t||^2        q^t ||r_0||^2")
    initial_energy = squared_norm(initial)
    for t, residual in enumerate(history):
        print(f"{t:2d}   {squared_norm(residual):14.8f}   {(q ** t) * initial_energy:14.8f}")


def demonstrate_kernel_stability() -> None:
    """Compare observed kernel drift with the uniform 2 p B delta bound."""
    j0 = [[0.8, -0.4, 0.3, 0.1], [0.2, 0.7, -0.5, 0.6], [-0.3, 0.1, 0.9, -0.2]]
    perturbation = [[0.01, -0.02, 0.00, 0.01], [-0.01, 0.01, 0.02, -0.01], [0.02, 0.00, -0.01, 0.01]]
    j1 = [[x + dx for x, dx in zip(row, change)] for row, change in zip(j0, perturbation)]
    b, delta, observed, bound = entrywise_drift_certificate(j0, j1)
    print("\n3. Entrywise NTK stability")
    print(f"parameter count p          = {len(j0[0])}")
    print(f"Jacobian magnitude B       = {b:.6f}")
    print(f"maximum Jacobian drift     = {delta:.6f}")
    print(f"observed max kernel drift  = {observed:.6f}")
    print(f"certified bound 2 p B d    = {bound:.6f}")
    print(f"certificate satisfied      = {observed <= bound + 1e-12}")


def main() -> None:
    """Run all demonstrations."""
    print("Neural Tangent Kernel: finite-sample numerical demonstrations")
    demonstrate_energy_identity()
    demonstrate_geometric_convergence()
    demonstrate_kernel_stability()


if __name__ == "__main__":
    main()
