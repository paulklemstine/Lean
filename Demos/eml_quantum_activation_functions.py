#!/usr/bin/env python3
"""Numerical demonstrations for quantum exponential--logarithm activations.

Only NumPy is required. Hermitian spectral calculus is used instead of a
black-box matrix logarithm, making every computed quantity transparent.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import atan, log
from typing import Tuple

import numpy as np
from numpy.typing import NDArray

ComplexMatrix = NDArray[np.complex128]


@dataclass(frozen=True)
class ActivationResult:
    """Factors, output, and Frobenius-norm unitary residuals."""

    exponential: ComplexMatrix
    logarithm: ComplexMatrix
    output: ComplexMatrix
    log_residual: float
    output_residual: float


def _require_hermitian(matrix: ComplexMatrix, *, atol: float = 1e-10) -> None:
    """Raise ValueError unless ``matrix`` is square and Hermitian."""
    if matrix.ndim != 2 or matrix.shape[0] != matrix.shape[1]:
        raise ValueError("matrix must be square")
    if not np.allclose(matrix, matrix.conj().T, atol=atol):
        raise ValueError("matrix must be Hermitian")


def hermitian_function(
    matrix: ComplexMatrix, values: NDArray[np.complex128]
) -> ComplexMatrix:
    """Reassemble a matrix function from eigenvectors and supplied eigenvalues."""
    _, eigenvectors = np.linalg.eigh(matrix)
    return (eigenvectors * values) @ eigenvectors.conj().T


def unitary_exponential(hamiltonian: ComplexMatrix) -> ComplexMatrix:
    """Compute exp(iH) for a Hermitian matrix H by spectral calculus."""
    _require_hermitian(hamiltonian)
    eigenvalues, eigenvectors = np.linalg.eigh(hamiltonian)
    return (eigenvectors * np.exp(1j * eigenvalues)) @ eigenvectors.conj().T


def principal_log_identity_plus_i(
    hamiltonian: ComplexMatrix,
) -> ComplexMatrix:
    """Compute the principal logarithm Log(I+iH) for Hermitian H."""
    _require_hermitian(hamiltonian)
    eigenvalues, eigenvectors = np.linalg.eigh(hamiltonian)
    log_eigenvalues = np.log(1.0 + 1j * eigenvalues)
    return (eigenvectors * log_eigenvalues) @ eigenvectors.conj().T


def unitary_residual(matrix: ComplexMatrix) -> float:
    """Return ||M* M - I||_F, which vanishes exactly for unitary M."""
    identity = np.eye(matrix.shape[0], dtype=np.complex128)
    defect = matrix.conj().T @ matrix - identity
    return float(np.linalg.norm(defect, ord="fro"))


def quantum_eml_activation(
    first_hamiltonian: ComplexMatrix, second_hamiltonian: ComplexMatrix
) -> ActivationResult:
    """Evaluate exp(iH1) Log(I+iH2) and its unitary diagnostics."""
    if first_hamiltonian.shape != second_hamiltonian.shape:
        raise ValueError("Hamiltonians must have the same shape")
    exponential = unitary_exponential(first_hamiltonian)
    logarithm = principal_log_identity_plus_i(second_hamiltonian)
    output = exponential @ logarithm
    return ActivationResult(
        exponential=exponential,
        logarithm=logarithm,
        output=output,
        log_residual=unitary_residual(logarithm),
        output_residual=unitary_residual(output),
    )


def scalar_log_modulus_squared(t: float) -> float:
    """Return |Log(1+it)|^2 on the principal branch for real t."""
    return 0.25 * log(1.0 + t * t) ** 2 + atan(t) ** 2


def bisect_scalar_unitarity(
    lower: float, upper: float, *, tolerance: float = 1e-12
) -> Tuple[float, float]:
    """Bracket a root of |Log(1+it)|^2-1 by bisection."""
    if tolerance <= 0.0:
        raise ValueError("tolerance must be positive")

    def objective(t: float) -> float:
        return scalar_log_modulus_squared(t) - 1.0

    f_lower = objective(lower)
    f_upper = objective(upper)
    if f_lower * f_upper > 0.0:
        raise ValueError("interval endpoints must bracket a root")
    while upper - lower > tolerance:
        midpoint = 0.5 * (lower + upper)
        f_midpoint = objective(midpoint)
        if f_lower * f_midpoint <= 0.0:
            upper = midpoint
            f_upper = f_midpoint
        else:
            lower = midpoint
            f_lower = f_midpoint
    return lower, upper


def format_matrix(matrix: ComplexMatrix) -> str:
    """Format a small complex matrix for readable terminal output."""
    return np.array2string(matrix, precision=6, suppress_small=True)


def run_demo() -> None:
    """Run the zero obstruction, factor identity, and scalar-root examples."""
    np.set_printoptions(precision=6, suppress=True)
    first = np.array([[0.3, 0.2 - 0.1j], [0.2 + 0.1j, -0.7]], dtype=np.complex128)
    zero = np.zeros((2, 2), dtype=np.complex128)

    zero_case = quantum_eml_activation(first, zero)
    print("=== Zero-second-Hamiltonian obstruction ===")
    print("Activation output:\n", format_matrix(zero_case.output))
    print(f"Output unitary residual: {zero_case.output_residual:.12f}")
    print(f"Expected ||I||_F = sqrt(2): {np.sqrt(2.0):.12f}\n")

    second = np.array(
        [[0.8, 0.2 - 0.1j], [0.2 + 0.1j, -0.4]], dtype=np.complex128
    )
    generic = quantum_eml_activation(first, second)
    gram_difference = (
        generic.output.conj().T @ generic.output
        - generic.logarithm.conj().T @ generic.logarithm
    )
    print("=== Unitary factor cannot repair the logarithmic factor ===")
    print(f"Log-factor residual: {generic.log_residual:.12e}")
    print(f"Output residual:     {generic.output_residual:.12e}")
    print(f"Gram-identity error: {np.linalg.norm(gram_difference):.12e}\n")

    lower, upper = bisect_scalar_unitarity(0.0, 2.0)
    root = 0.5 * (lower + upper)
    scalar_second = root * np.eye(2, dtype=np.complex128)
    scalar_case = quantum_eml_activation(first, scalar_second)
    print("=== Exploratory scalar unitary logarithmic factor ===")
    print(f"Root bracket: [{lower:.13f}, {upper:.13f}]")
    print(f"Midpoint t: {root:.13f}")
    print(f"|Log(1+it)|^2: {scalar_log_modulus_squared(root):.13f}")
    print(f"Log-factor residual: {scalar_case.log_residual:.12e}")
    print(f"Output residual:     {scalar_case.output_residual:.12e}")
    print("Note: this last root is a floating-point illustration, not an interval proof.")


if __name__ == "__main__":
    run_demo()
