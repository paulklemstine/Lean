#!/usr/bin/env python3
"""Dependency-free numerical demonstrations of generalized-join Laplacian splitting."""

from __future__ import annotations

from dataclasses import dataclass
from math import isclose
from typing import Sequence

Vector = list[float]
Matrix = list[list[float]]


def matvec(matrix: Matrix, vector: Sequence[float]) -> Vector:
    """Multiply a rectangular matrix by a vector."""
    return [sum(a * b for a, b in zip(row, vector)) for row in matrix]


def add_vectors(left: Sequence[float], right: Sequence[float]) -> Vector:
    return [a + b for a, b in zip(left, right)]


def scale(scalar: float, vector: Sequence[float]) -> Vector:
    return [scalar * value for value in vector]


def max_error(left: Sequence[float], right: Sequence[float]) -> float:
    return max((abs(a - b) for a, b in zip(left, right)), default=0.0)


def assert_close(left: Sequence[float], right: Sequence[float], tolerance: float = 1e-9) -> None:
    error = max_error(left, right)
    if error > tolerance:
        raise AssertionError(f"maximum error {error} exceeds tolerance {tolerance}")


def complete_graph_laplacian(size: int) -> Matrix:
    """Unit-weight Laplacian of the complete graph on ``size`` vertices."""
    if size <= 0:
        raise ValueError("size must be positive")
    return [[float(size - 1 if i == j else -1) for j in range(size)] for i in range(size)]


@dataclass(frozen=True)
class JoinSystem:
    """Internal Laplacians and weighted base adjacency for a generalized join."""

    internal: tuple[Matrix, ...]
    base_weights: Matrix

    @property
    def sizes(self) -> list[int]:
        return [len(block) for block in self.internal]

    def external_degrees(self) -> Vector:
        return matvec(self.base_weights, self.sizes)

    def quotient(self) -> Matrix:
        degrees = self.external_degrees()
        return [
            [
                (degrees[i] if i == j else 0.0) - self.base_weights[i][j] * self.sizes[j]
                for j in range(len(self.sizes))
            ]
            for i in range(len(self.sizes))
        ]

    def apply(self, fibers: Sequence[Sequence[float]]) -> list[Vector]:
        """Apply the generalized-join operator without constructing a dense matrix."""
        masses = [sum(fiber) for fiber in fibers]
        degrees = self.external_degrees()
        couplings = matvec(self.base_weights, masses)
        return [
            [internal_value + degrees[i] * value - couplings[i]
             for internal_value, value in zip(matvec(self.internal[i], fibers[i]), fibers[i])]
            for i in range(len(fibers))
        ]

    def lift(self, base_vector: Sequence[float]) -> list[Vector]:
        return [[float(base_vector[i])] * size for i, size in enumerate(self.sizes)]

    def split(self, fibers: Sequence[Sequence[float]]) -> tuple[list[Vector], Vector]:
        averages = [sum(fiber) / len(fiber) for fiber in fibers]
        centered = [[value - averages[i] for value in fiber] for i, fiber in enumerate(fibers)]
        return centered, averages


def flatten(fibers: Sequence[Sequence[float]]) -> Vector:
    return [value for fiber in fibers for value in fiber]


def two_fiber_spectral_demo() -> None:
    """Verify five explicit eigenvectors realizing the predicted full spectrum."""
    system = JoinSystem(
        internal=(complete_graph_laplacian(2), complete_graph_laplacian(3)),
        base_weights=[[0.0, 1.0], [1.0, 0.0]],
    )
    # One quotient zero mode, one quotient 5-mode, and three shifted local 5-modes.
    eigenpairs = [
        (0.0, [[1.0, 1.0], [1.0, 1.0, 1.0]]),
        (5.0, [[3.0, 3.0], [-2.0, -2.0, -2.0]]),
        (5.0, [[1.0, -1.0], [0.0, 0.0, 0.0]]),
        (5.0, [[0.0, 0.0], [1.0, -1.0, 0.0]]),
        (5.0, [[0.0, 0.0], [1.0, 0.0, -1.0]]),
    ]
    residuals = []
    for eigenvalue, fibers in eigenpairs:
        residuals.append(max_error(flatten(system.apply(fibers)), scale(eigenvalue, flatten(fibers))))
    print("\nDEMO 1 — shifted local and quotient eigenmodes")
    print("external degrees:", system.external_degrees())
    print("quotient matrix:", system.quotient())
    print("predicted eigenvalues: [0, 5, 5, 5, 5]")
    print("eigenvector residuals:", residuals)
    assert max(residuals) < 1e-9


def intertwining_demo() -> None:
    """Verify full action on a lift equals lifted quotient action."""
    system = JoinSystem(
        internal=(complete_graph_laplacian(2), [[0.0]], complete_graph_laplacian(3)),
        base_weights=[[0.0, 2.0, 0.0], [1.0, 0.0, 1.0], [3.0, 0.0, 0.0]],
    )
    base_signal = [1.5, -2.0, 0.25]
    left = flatten(system.apply(system.lift(base_signal)))
    right = flatten(system.lift(matvec(system.quotient(), base_signal)))
    print("\nDEMO 2 — weighted quotient intertwining")
    print("fiber sizes:", system.sizes)
    print("quotient matrix:", system.quotient())
    print("intertwining residual:", max_error(left, right))
    assert_close(left, right)


def invariant_decomposition_demo() -> None:
    """Verify reconstruction and zero-mass invariance for a concrete signal."""
    system = JoinSystem(
        internal=(complete_graph_laplacian(2), complete_graph_laplacian(3)),
        base_weights=[[0.0, 1.0], [1.0, 0.0]],
    )
    fibers = [[4.0, -2.0], [3.0, 0.0, 6.0]]
    centered, averages = system.split(fibers)
    reconstructed = [add_vectors(centered[i], [averages[i]] * system.sizes[i]) for i in range(2)]
    evolved_centered = system.apply(centered)
    output_masses = [sum(fiber) for fiber in evolved_centered]
    print("\nDEMO 3 — invariant direct-sum decomposition")
    print("fiber averages:", averages)
    print("centered fibers:", centered)
    print("masses after acting on centered signal:", output_masses)
    assert_close(flatten(reconstructed), flatten(fibers))
    assert_close([sum(fiber) for fiber in centered], [0.0, 0.0])
    assert_close(output_masses, [0.0, 0.0])


def main() -> None:
    two_fiber_spectral_demo()
    intertwining_demo()
    invariant_decomposition_demo()
    print("\nAll generalized-join identities passed their numerical checks.")


if __name__ == "__main__":
    main()
