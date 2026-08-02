#!/usr/bin/env python3
"""Numerical demonstrations for the finite entanglement-to-geometry model.

Only the Python standard library is used. Running this file prints diagnostics
for a product state, the Bell state, and an interpolation between them.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import cos, isclose, log2, pi, sin, sqrt
from typing import Iterable, Tuple

Matrix2 = Tuple[Tuple[float, float], Tuple[float, float]]


@dataclass(frozen=True)
class QuantumDiagnostics:
    determinant: float
    concurrence: float
    left_reduced: Matrix2
    right_reduced: Matrix2


def transpose(a: Matrix2) -> Matrix2:
    """Return the transpose of a real 2-by-2 matrix."""
    return ((a[0][0], a[1][0]), (a[0][1], a[1][1]))


def multiply(a: Matrix2, b: Matrix2) -> Matrix2:
    """Multiply two real 2-by-2 matrices."""
    return tuple(
        tuple(sum(a[i][k] * b[k][j] for k in range(2)) for j in range(2))
        for i in range(2)
    )  # type: ignore[return-value]


def determinant(a: Matrix2) -> float:
    """Compute the determinant of a real 2-by-2 matrix."""
    return a[0][0] * a[1][1] - a[0][1] * a[1][0]


def diagnose_state(psi: Matrix2) -> QuantumDiagnostics:
    """Compute determinant, concurrence, and both reduced density matrices."""
    det = determinant(psi)
    psi_t = transpose(psi)
    return QuantumDiagnostics(
        determinant=det,
        concurrence=2.0 * abs(det),
        left_reduced=multiply(psi, psi_t),
        right_reduced=multiply(psi_t, psi),
    )


def binary_entropy(probability: float) -> float:
    """Return binary entropy in bits, with continuous endpoint values."""
    if probability < 0.0 or probability > 1.0:
        raise ValueError("probability must lie in [0, 1]")
    if probability in (0.0, 1.0):
        return 0.0
    return -probability * log2(probability) - (1.0 - probability) * log2(1.0 - probability)


def reconstruct_throat(left: float, right: float, total: float) -> float:
    """Reconstruct a nonnegative one-throat weight from boundary entropies."""
    mutual_information = left + right - total
    if mutual_information < -1e-12:
        raise ValueError("data would require a negative throat weight")
    return max(0.0, mutual_information / 2.0)


def schmidt_state(theta: float) -> Matrix2:
    """Return the matrix for cos(theta)|00> + sin(theta)|11>."""
    return ((cos(theta), 0.0), (0.0, sin(theta)))


def matrix_string(a: Matrix2) -> str:
    """Format a 2-by-2 matrix for readable terminal output."""
    return f"[[{a[0][0]:.6f}, {a[0][1]:.6f}], [{a[1][0]:.6f}, {a[1][1]:.6f}]]"


def interpolation_rows(samples: int = 5) -> Iterable[Tuple[float, float, float]]:
    """Yield theta, concurrence, and entropy-derived throat weight."""
    if samples < 2:
        raise ValueError("samples must be at least 2")
    for index in range(samples):
        theta = (pi / 4.0) * index / (samples - 1)
        diagnostics = diagnose_state(schmidt_state(theta))
        entropy = binary_entropy(cos(theta) ** 2)
        yield theta, diagnostics.concurrence, reconstruct_throat(entropy, entropy, 0.0)


def main() -> None:
    bell: Matrix2 = ((1.0 / sqrt(2.0), 0.0), (0.0, 1.0 / sqrt(2.0)))
    product: Matrix2 = ((1.0, 0.0), (0.0, 0.0))
    mixed: Matrix2 = ((0.5, 0.0), (0.0, 0.5))

    product_data = diagnose_state(product)
    bell_data = diagnose_state(bell)

    print("Finite ER=EPR numerical demonstration")
    print("\nProduct state |00>:")
    print(f"  determinant={product_data.determinant:.6f}, concurrence={product_data.concurrence:.6f}")
    print(f"  left marginal={matrix_string(product_data.left_reduced)}")
    print(f"  throat from (0,0,0)={reconstruct_throat(0.0, 0.0, 0.0):.6f}")

    print("\nBell state (|00>+|11>)/sqrt(2):")
    print(f"  determinant={bell_data.determinant:.6f}, concurrence={bell_data.concurrence:.6f}")
    print(f"  left marginal={matrix_string(bell_data.left_reduced)}")
    print(f"  right marginal={matrix_string(bell_data.right_reduced)}")
    print(f"  throat from (1,1,0)={reconstruct_throat(1.0, 1.0, 0.0):.6f}")

    assert isclose(bell_data.concurrence, 1.0)
    assert all(isclose(bell_data.left_reduced[i][j], mixed[i][j]) for i in range(2) for j in range(2))
    assert isclose(reconstruct_throat(1.0, 1.0, 0.0), 1.0)

    print("\nInterpolation cos(theta)|00> + sin(theta)|11>:")
    print("  theta       concurrence   entropy-derived throat")
    for theta, concurrence, throat in interpolation_rows(7):
        print(f"  {theta:8.5f}    {concurrence:10.6f}        {throat:10.6f}")


if __name__ == "__main__":
    main()
