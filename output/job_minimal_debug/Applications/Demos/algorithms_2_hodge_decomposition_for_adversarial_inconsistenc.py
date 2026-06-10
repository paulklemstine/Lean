#!/usr/bin/env python3
"""
Algorithms for Combinatorial Hodge Decomposition

Implements the core algorithms for computing the Hodge decomposition
of 1-cochains on finite graph complexes:

  ω = d₀f + d₁†η + h

where d₀ is the 0-coboundary, d₁† is the adjoint of the 1-coboundary,
and h is the harmonic component.

Algorithm 1: Coboundary Matrix Construction — O(n²) for d₀, O(n³) for d₁
Algorithm 2: Hodge Laplacian Assembly — O(n⁴) via matrix products
Algorithm 3: Hodge Decomposition via Orthogonal Projection — O(n⁶) via SVD
Algorithm 4: Harmonic Space Computation — O(n⁶) via eigendecomposition
"""

import numpy as np
from typing import Tuple


def build_d0(n: int) -> np.ndarray:
    """Build the 0-coboundary matrix d₀ : C⁰ → C¹.

    (d₀f)(i,j) = f(j) - f(i)

    Args:
        n: Number of vertices

    Returns:
        d0: Matrix of shape (n², n) representing d₀

    Time complexity: O(n²)
    Space complexity: O(n³)
    """
    d0 = np.zeros((n * n, n))
    for i in range(n):
        for j in range(n):
            row = i * n + j
            d0[row, j] = 1.0   # +f(j)
            d0[row, i] -= 1.0  # -f(i)
    return d0


def build_d1(n: int) -> np.ndarray:
    """Build the 1-coboundary matrix d₁ : C¹ → C².

    (d₁ω)(i,j,k) = ω(i,j) - ω(i,k) + ω(j,k)

    Args:
        n: Number of vertices

    Returns:
        d1: Matrix of shape (n³, n²) representing d₁

    Time complexity: O(n³)
    Space complexity: O(n⁵)
    """
    d1 = np.zeros((n * n * n, n * n))
    for i in range(n):
        for j in range(n):
            for k in range(n):
                row = i * n * n + j * n + k
                d1[row, i * n + j] += 1.0   # +ω(i,j)
                d1[row, i * n + k] -= 1.0   # -ω(i,k)
                d1[row, j * n + k] += 1.0   # +ω(j,k)
    return d1


def hodge_laplacian_1(n: int) -> np.ndarray:
    """Compute the 1-Hodge Laplacian Δ₁ = d₀ d₀† + d₁† d₁.

    Args:
        n: Number of vertices

    Returns:
        delta1: Matrix of shape (n², n²) representing Δ₁

    Time complexity: O(n⁴) for matrix multiplications
    Space complexity: O(n⁴)
    """
    d0 = build_d0(n)
    d1 = build_d1(n)
    # Δ₁ = d₀ @ d₀ᵀ + d₁ᵀ @ d₁
    delta1 = d0 @ d0.T + d1.T @ d1
    return delta1


def hodge_decompose(n: int, omega: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Compute the Hodge decomposition ω = d₀f + d₁†η + h.

    Algorithm:
      1. Compute d₀, d₁
      2. Project ω onto range(d₀) via least-squares: f = (d₀ᵀd₀)⁺ d₀ᵀω
      3. Project remainder onto range(d₁ᵀ): η = (d₁d₁ᵀ)⁺ d₁(ω - d₀f)
      4. Harmonic residual: h = ω - d₀f - d₁ᵀη

    Args:
        n: Number of vertices
        omega: 1-cochain as a vector of length n²

    Returns:
        exact: Gradient component d₀f
        coexact: Curl-adjoint component d₁†η
        harmonic: Harmonic component h

    Time complexity: O(n⁶) dominated by pseudoinverse
    Space complexity: O(n⁴)
    """
    d0 = build_d0(n)
    d1 = build_d1(n)

    # Step 1: Project onto range(d₀)
    # Solve min_f ‖ω - d₀f‖² → f = (d₀ᵀd₀)⁺ d₀ᵀω
    f, _, _, _ = np.linalg.lstsq(d0, omega, rcond=None)
    exact = d0 @ f

    # Step 2: Project remainder onto range(d₁ᵀ)
    remainder = omega - exact
    # Solve min_η ‖remainder - d₁ᵀη‖² → η = (d₁d₁ᵀ)⁺ d₁ remainder
    eta, _, _, _ = np.linalg.lstsq(d1.T, remainder, rcond=None)
    coexact = d1.T @ eta

    # Step 3: Harmonic residual
    harmonic = omega - exact - coexact

    return exact, coexact, harmonic


def compute_harmonic_space(n: int, tol: float = 1e-10) -> np.ndarray:
    """Compute a basis for the harmonic 1-cochain space ker(Δ₁).

    Args:
        n: Number of vertices
        tol: Tolerance for identifying zero eigenvalues

    Returns:
        basis: Matrix whose columns form an orthonormal basis for ker(Δ₁).
               Shape (n², dim ker Δ₁). Empty if ker Δ₁ = {0}.

    Time complexity: O(n⁶) for eigendecomposition
    Space complexity: O(n⁴)
    """
    delta1 = hodge_laplacian_1(n)
    eigenvalues, eigenvectors = np.linalg.eigh(delta1)
    zero_mask = np.abs(eigenvalues) < tol
    if not np.any(zero_mask):
        return np.empty((n * n, 0))
    return eigenvectors[:, zero_mask]


def harmonic_energy(n: int, omega: np.ndarray) -> float:
    """Compute the harmonic energy ‖h‖² of a 1-cochain.

    The harmonic energy measures the irreducible topological obstruction
    in the inconsistency field. Zero harmonic energy means the field is
    fully decomposable into gradient + curl-adjoint.

    Args:
        n: Number of vertices
        omega: 1-cochain vector of length n²

    Returns:
        energy: ‖h‖² where h is the harmonic component of ω

    Time complexity: O(n⁶) for the full decomposition
    """
    _, _, h = hodge_decompose(n, omega)
    return float(np.dot(h, h))


def spectral_gap(n: int) -> float:
    """Compute the spectral gap of the Hodge Laplacian.

    The spectral gap λ₁ is the smallest non-zero eigenvalue of Δ₁.
    A larger spectral gap means faster mixing / better conditioning
    of the decomposition.

    Args:
        n: Number of vertices

    Returns:
        gap: Smallest non-zero eigenvalue of Δ₁ (0 if Δ₁ = 0)

    Time complexity: O(n⁶) for eigendecomposition
    """
    delta1 = hodge_laplacian_1(n)
    eigenvalues = np.sort(np.linalg.eigvalsh(delta1))
    nonzero = eigenvalues[eigenvalues > 1e-10]
    return float(nonzero[0]) if len(nonzero) > 0 else 0.0


if __name__ == "__main__":
    # Quick self-test
    for n in range(2, 7):
        d0 = build_d0(n)
        d1 = build_d1(n)
        assert np.allclose(d1 @ d0, 0), f"Cochain complex condition failed for n={n}"

        omega = np.random.randn(n * n)
        exact, coexact, harmonic = hodge_decompose(n, omega)
        assert np.allclose(omega, exact + coexact + harmonic), f"Decomposition failed for n={n}"
        assert abs(np.dot(exact, coexact)) < 1e-8, f"Orthogonality failed for n={n}"
        assert abs(np.dot(exact, harmonic)) < 1e-8, f"Orthogonality failed for n={n}"
        assert abs(np.dot(coexact, harmonic)) < 1e-8, f"Orthogonality failed for n={n}"
        print(f"n={n}: ✓ All tests passed. dim(ker Δ₁) = {compute_harmonic_space(n).shape[1]}")

    # Verify simplex acyclicity for n ≥ 4
    for n in range(4, 8):
        dim_h = compute_harmonic_space(n).shape[1]
        assert dim_h == 0, f"Expected trivial harmonic space for complete simplex K_{n}"
        print(f"K_{n}: dim(ker Δ₁) = 0 ✓ (simplex acyclicity)")
