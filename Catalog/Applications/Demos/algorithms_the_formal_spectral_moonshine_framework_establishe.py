#!/usr/bin/env python3
"""
Spectral Moonshine Algorithms

Implements the core algorithms from the spectral moonshine framework:
1. Spectral decoding (Fourier coefficient extraction)
2. Packet projection (spectral reconstruction)
3. Spectral energy computation
4. Orthonormality verification
5. Spectral faithfulness test

All algorithms operate on class functions represented as numpy arrays.
"""

import numpy as np
from typing import List, Tuple, Optional


def cf_inner(f: np.ndarray, g: np.ndarray, group_order: int) -> complex:
    """
    Compute the class function inner product.

    ⟨f, g⟩ = (1/|G|) ∑_{x∈G} f(x) · conj(g(x))

    Args:
        f: Class function values as array of length |G|.
        g: Class function values as array of length |G|.
        group_order: The order |G| of the group.

    Returns:
        Complex inner product value.

    Time complexity: O(|G|)
    Space complexity: O(1)
    """
    return np.sum(f * np.conj(g)) / group_order


def decode_spectral_coefficients(
    f: np.ndarray,
    basis: List[np.ndarray],
    group_order: int
) -> np.ndarray:
    """
    Algorithm 1: Spectral Decoding

    Extract the Fourier coefficients of a class function with respect to
    an orthonormal basis.

    Given f and basis {χ₁, ..., χₖ}, computes cᵢ = ⟨f, χᵢ⟩ for each i.

    Args:
        f: Class function to decode.
        basis: List of orthonormal basis class functions.
        group_order: Order of the group.

    Returns:
        Array of complex Fourier coefficients.

    Time complexity: O(k · |G|) where k = len(basis)
    Space complexity: O(k)
    """
    return np.array([cf_inner(f, chi, group_order) for chi in basis])


def packet_projector(
    f: np.ndarray,
    basis: List[np.ndarray],
    group_order: int
) -> np.ndarray:
    """
    Algorithm 2: Packet Projection (Spectral Reconstruction)

    Reconstruct a class function from its spectral components:
    P(f) = ∑ᵢ ⟨f, χᵢ⟩ · χᵢ

    Under completeness, P(f) = f (Theorem 1).
    Always satisfies P(P(f)) = P(f) (Theorem 4: idempotence).

    Args:
        f: Class function to project.
        basis: List of orthonormal basis class functions.
        group_order: Order of the group.

    Returns:
        Projected class function.

    Time complexity: O(k · |G|)
    Space complexity: O(|G|)
    """
    coeffs = decode_spectral_coefficients(f, basis, group_order)
    result = np.zeros_like(f)
    for i, chi in enumerate(basis):
        result += coeffs[i] * chi
    return result


def spectral_energy(
    f: np.ndarray,
    basis: List[np.ndarray],
    group_order: int
) -> float:
    """
    Algorithm 3: Spectral Energy Computation

    Compute E(f) = ∑ᵢ |⟨f, χᵢ⟩|²

    Under completeness, E(f) = ⟨f, f⟩ (Parseval, Theorem 2).
    E(f) = 0 iff f = 0 under completeness (Theorem 5).

    Args:
        f: Class function.
        basis: Orthonormal basis.
        group_order: Order of the group.

    Returns:
        Real spectral energy value.

    Time complexity: O(k · |G|)
    Space complexity: O(k)
    """
    coeffs = decode_spectral_coefficients(f, basis, group_order)
    return float(np.sum(np.abs(coeffs) ** 2))


def verify_orthonormality(
    basis: List[np.ndarray],
    group_order: int,
    tol: float = 1e-10
) -> Tuple[bool, np.ndarray]:
    """
    Algorithm 4: Orthonormality Verification

    Compute the Gram matrix G_{ij} = ⟨χᵢ, χⱼ⟩ and check if G ≈ I.

    Args:
        basis: List of class functions to test.
        group_order: Order of the group.
        tol: Tolerance for deviation from identity.

    Returns:
        Tuple of (is_orthonormal, gram_matrix).

    Time complexity: O(k² · |G|)
    Space complexity: O(k²)
    """
    k = len(basis)
    gram = np.zeros((k, k), dtype=complex)
    for i in range(k):
        for j in range(k):
            gram[i, j] = cf_inner(basis[i], basis[j], group_order)

    is_orth = np.allclose(gram, np.eye(k), atol=tol)
    return is_orth, gram


def verify_parseval(
    f: np.ndarray,
    basis: List[np.ndarray],
    group_order: int,
    tol: float = 1e-10
) -> Tuple[bool, complex, float]:
    """
    Algorithm 5: Parseval Identity Verification

    Check whether ⟨f, f⟩ = ∑ᵢ |⟨f, χᵢ⟩|² (Theorem 2).

    Args:
        f: Class function.
        basis: Complete orthonormal basis.
        group_order: Order of the group.
        tol: Tolerance.

    Returns:
        Tuple of (holds, inner_product, spectral_energy).

    Time complexity: O(k · |G|)
    """
    ip = cf_inner(f, f, group_order)
    energy = spectral_energy(f, basis, group_order)
    holds = abs(ip - energy) < tol
    return holds, ip, energy


def verify_reconstruction(
    f: np.ndarray,
    basis: List[np.ndarray],
    group_order: int,
    tol: float = 1e-10
) -> Tuple[bool, float]:
    """
    Algorithm 6: Reconstruction Verification

    Check whether P(f) = f (Theorem 1).

    Args:
        f: Class function.
        basis: Complete orthonormal basis.
        group_order: Order of the group.
        tol: Tolerance.

    Returns:
        Tuple of (exact_reconstruction, max_error).

    Time complexity: O(k · |G|)
    """
    pf = packet_projector(f, basis, group_order)
    err = np.max(np.abs(f - pf))
    return err < tol, float(err)


def spectral_decomposition_table(
    f: np.ndarray,
    basis: List[np.ndarray],
    basis_names: List[str],
    group_order: int
) -> str:
    """
    Algorithm 7: Pretty-print spectral decomposition

    Produces a formatted table of the spectral decomposition of f.

    Args:
        f: Class function to decompose.
        basis: Orthonormal basis.
        basis_names: Names for basis elements.
        group_order: Order of the group.

    Returns:
        Formatted string table.
    """
    coeffs = decode_spectral_coefficients(f, basis, group_order)
    energy = spectral_energy(f, basis, group_order)
    total_ip = cf_inner(f, f, group_order)

    lines = ["Spectral Decomposition Table"]
    lines.append("-" * 50)
    lines.append(f"{'Basis Element':<15} {'Coefficient':<25} {'|c|²':<15}")
    lines.append("-" * 50)

    for name, c in zip(basis_names, coeffs):
        lines.append(f"{name:<15} {c:<25.6f} {abs(c)**2:<15.6f}")

    lines.append("-" * 50)
    lines.append(f"{'Total energy':<15} {'':25} {energy:<15.6f}")
    lines.append(f"{'<f,f>':<15} {'':25} {total_ip.real:<15.6f}")
    lines.append(f"{'Parseval gap':<15} {'':25} {abs(total_ip - energy):<15.2e}")

    return "\n".join(lines)


# =============================================================================
# Example usage
# =============================================================================

if __name__ == "__main__":
    print("Spectral Moonshine Algorithms — Example Usage\n")

    # Z/4Z example
    n = 4
    omega = np.exp(2j * np.pi / n)
    chars = [np.array([omega**(j * k) for j in range(n)]) for k in range(n)]
    names = [f"χ_{k}" for k in range(n)]

    f = np.array([3, 1, -1, 2], dtype=complex)

    print(spectral_decomposition_table(f, chars, names, n))

    print(f"\nOrthonormality check: {verify_orthonormality(chars, n)[0]}")
    print(f"Reconstruction check: {verify_reconstruction(f, chars, n)}")
    print(f"Parseval check: {verify_parseval(f, chars, n)}")

    # Idempotence check
    Pf = packet_projector(f, chars, n)
    PPf = packet_projector(Pf, chars, n)
    print(f"Idempotence |P²f - Pf|: {np.max(np.abs(PPf - Pf)):.2e}")
