#!/usr/bin/env python3
"""
Algorithms for Finite Hilbert-Pólya Blueprint.

Implements the core computational procedures described in the research paper:

1. Symmetrized Dirichlet truncation with functional equation verification
2. Self-inversive polynomial detection and root pairing
3. Möbius transport: critical line ↔ unit circle
4. Cayley transform for spectral models
5. Rank analysis of arithmetic kernel matrices
"""

import numpy as np
from typing import List, Tuple, Optional, Callable


# ═══════════════════════════════════════════════
# Algorithm 1: Symmetrized Dirichlet Truncation
# ═══════════════════════════════════════════════

def symmetrized_truncation(
    N: int,
    chi: Callable[[complex], complex],
    s: complex
) -> complex:
    """
    Compute the symmetrized Dirichlet truncation Z_N(s).

    Z_N(s) = Σ_{n=1}^N n^{-s} + χ(s) · Σ_{n=1}^N n^{s-1}

    Args:
        N: truncation parameter
        chi: functional equation factor satisfying χ(s)·χ(1-s) = 1
        s: complex argument

    Returns:
        Z_N(s) as a complex number

    Time complexity: O(N)
    Space complexity: O(1)
    """
    d_sum = sum(n ** (-s) for n in range(1, N + 1))
    d_dual = sum(n ** (s - 1) for n in range(1, N + 1))
    return d_sum + chi(s) * d_dual


def verify_functional_equation(
    N: int,
    chi: Callable[[complex], complex],
    test_points: List[complex],
    tol: float = 1e-10
) -> List[Tuple[complex, float]]:
    """
    Verify Z_N(1-s) = χ(1-s)·Z_N(s) at given test points.

    Args:
        N: truncation parameter
        chi: functional equation factor
        test_points: points at which to verify
        tol: tolerance for error

    Returns:
        List of (s, error) pairs

    Time complexity: O(N · |test_points|)
    """
    results = []
    for s in test_points:
        lhs = symmetrized_truncation(N, chi, 1 - s)
        rhs = chi(1 - s) * symmetrized_truncation(N, chi, s)
        error = abs(lhs - rhs)
        results.append((s, error))
    return results


# ═══════════════════════════════════════════════
# Algorithm 2: Self-Inversive Polynomial Analysis
# ═══════════════════════════════════════════════

def is_self_inversive(
    coeffs: np.ndarray,
    tol: float = 1e-10
) -> Tuple[bool, Optional[complex]]:
    """
    Check if a polynomial is self-inversive (palindromic up to rotation).

    A polynomial P(z) = Σ a_k z^k of degree d is self-inversive if
    a_k = ω · conj(a_{d-k}) for some |ω| = 1.

    Args:
        coeffs: polynomial coefficients [a_0, a_1, ..., a_d] (low to high)
        tol: numerical tolerance

    Returns:
        (is_self_inversive, omega) where omega is the rotation factor

    Time complexity: O(d)
    Space complexity: O(d)
    """
    d = len(coeffs) - 1
    if d < 0:
        return False, None

    # Find omega from a_d / conj(a_0)
    if abs(coeffs[0]) < tol or abs(coeffs[d]) < tol:
        # Degenerate case
        return False, None

    omega = coeffs[d] / np.conj(coeffs[0])
    if abs(abs(omega) - 1) > tol:
        return False, None

    # Verify a_k = omega * conj(a_{d-k}) for all k
    for k in range(d + 1):
        expected = omega * np.conj(coeffs[d - k])
        if abs(coeffs[k] - expected) > tol:
            return False, None

    return True, omega


def find_conjugate_reciprocal_pairs(
    roots: np.ndarray,
    tol: float = 1e-8
) -> List[Tuple[complex, complex, float]]:
    """
    Find conjugate-reciprocal pairs among roots.

    For each root z, find 1/conj(z) among the other roots.

    Args:
        roots: array of polynomial roots
        tol: tolerance for matching

    Returns:
        List of (z, 1/conj(z), match_error) triples

    Time complexity: O(n²)
    """
    pairs = []
    used = set()

    for i, z in enumerate(roots):
        if i in used or abs(z) < tol:
            continue
        target = 1.0 / np.conj(z)
        best_j = None
        best_err = float('inf')

        for j, w in enumerate(roots):
            if j == i or j in used:
                continue
            err = abs(w - target)
            if err < best_err:
                best_err = err
                best_j = j

        if best_j is not None and best_err < tol:
            pairs.append((z, roots[best_j], best_err))
            used.add(i)
            used.add(best_j)

    return pairs


# ═══════════════════════════════════════════════
# Algorithm 3: Möbius Transport
# ═══════════════════════════════════════════════

def mobius_critical_to_circle(s: complex) -> complex:
    """
    Möbius transform sending Re(s) = 1/2 to the unit circle.

    φ(s) = (s - 3/2) / (s + 1/2)

    This is the composition of:
    1. Centering: w = s - 1/2 (maps critical line to imaginary axis)
    2. Cayley map: z = (w - 1)/(w + 1) (maps imaginary axis to unit circle)

    Args:
        s: complex number (s ≠ -1/2)

    Returns:
        φ(s) on the unit circle iff Re(s) = 1/2

    Time complexity: O(1)
    """
    return (s - 1.5) / (s + 0.5)


def mobius_circle_to_critical(z: complex) -> complex:
    """
    Inverse Möbius transform: unit circle → critical line.

    φ⁻¹(z) = (3/2 + z/2) / (1 - z)  =  (z + 3) / (2(1 - z))

    Inverts φ(s) = (s - 3/2)/(s + 1/2).

    Args:
        z: complex number (z ≠ 1)

    Returns:
        s with Re(s) = 1/2 iff |z| = 1

    Time complexity: O(1)
    """
    return (1.5 + 0.5 * z) / (1 - z)


def transport_polynomial_to_circle(
    coeffs: np.ndarray,
    N_sample: int = 1000
) -> np.ndarray:
    """
    Given a polynomial P(s), compute the transported polynomial Q(z) = P(φ⁻¹(z))
    by sampling on the unit circle and using FFT.

    Args:
        coeffs: coefficients of P(s) (low to high degree)
        N_sample: number of sample points on unit circle

    Returns:
        Approximate coefficients of Q(z)

    Time complexity: O(N_sample · log(N_sample))
    """
    theta = np.linspace(0, 2 * np.pi, N_sample, endpoint=False)
    z_vals = np.exp(1j * theta)

    # Evaluate P at φ⁻¹(z) for each z on the unit circle
    q_vals = np.array([
        np.polyval(coeffs[::-1], mobius_circle_to_critical(z))
        for z in z_vals
    ])

    # FFT to get coefficients
    q_coeffs = np.fft.fft(q_vals) / N_sample
    return q_coeffs[:len(coeffs)]


# ═══════════════════════════════════════════════
# Algorithm 4: Cayley Transform for Spectral Models
# ═══════════════════════════════════════════════

def cayley_transform(w: complex) -> complex:
    """
    Cayley transform: z = (w - i) / (w + i).

    Maps real line to unit circle, upper half-plane to unit disk.

    Args:
        w: complex number (w ≠ -i)

    Returns:
        z with |z| = 1 iff w is real

    Time complexity: O(1)
    """
    return (w - 1j) / (w + 1j)


def inverse_cayley(z: complex) -> complex:
    """
    Inverse Cayley transform: w = i(1 + z) / (1 - z).

    Args:
        z: complex number (z ≠ 1)

    Returns:
        w with w real iff |z| = 1

    Time complexity: O(1)
    """
    return 1j * (1 + z) / (1 - z)


def hermitian_to_unit_circle(H: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """
    Given a Hermitian matrix H, compute its eigenvalues (real),
    then map them to the unit circle via the Cayley transform.

    This implements the spectral bridge:
    Hermitian → real eigenvalues → unit-circle points

    Args:
        H: Hermitian matrix (n × n)

    Returns:
        (eigenvalues, cayley_images) where eigenvalues are real
        and cayley_images lie on the unit circle

    Time complexity: O(n³) for eigenvalue computation
    """
    eigenvalues = np.linalg.eigvalsh(H)
    cayley_images = np.array([cayley_transform(lam) for lam in eigenvalues])
    return eigenvalues, cayley_images


# ═══════════════════════════════════════════════
# Algorithm 5: Arithmetic Kernel Rank Analysis
# ═══════════════════════════════════════════════

def prime_log_kernel(primes: List[int]) -> np.ndarray:
    """
    Construct the prime-log kernel matrix K(p,q) = log(pq)/sqrt(pq).

    Args:
        primes: list of prime numbers

    Returns:
        n × n kernel matrix

    Time complexity: O(n²)
    """
    n = len(primes)
    K = np.zeros((n, n))
    for i, p in enumerate(primes):
        for j, q in enumerate(primes):
            K[i, j] = np.log(p * q) / np.sqrt(p * q)
    return K


def analyze_kernel_rank(K: np.ndarray, tol: float = 1e-10) -> dict:
    """
    Analyze the rank structure of a kernel matrix via SVD.

    Args:
        K: kernel matrix
        tol: threshold for considering singular values as zero

    Returns:
        Dictionary with rank info: numerical_rank, singular_values, etc.

    Time complexity: O(n³)
    """
    U, S, Vt = np.linalg.svd(K)
    numerical_rank = int(np.sum(S > tol))
    return {
        'numerical_rank': numerical_rank,
        'singular_values': S,
        'top_singular_values': S[:min(5, len(S))],
        'condition_number': S[0] / S[-1] if S[-1] > 0 else float('inf'),
        'frobenius_norm': np.linalg.norm(K, 'fro'),
    }


def outer_product_decomposition(
    primes: List[int]
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Decompose the prime-log kernel as K = u·v^T + v·u^T.

    The vectors are:
        u_p = log(p) / sqrt(p)
        v_p = 1 / sqrt(p)

    Args:
        primes: list of prime numbers

    Returns:
        (K, u, v) where K = outer(u,v) + outer(v,u)

    Time complexity: O(n²)
    """
    u = np.array([np.log(p) / np.sqrt(p) for p in primes])
    v = np.array([1.0 / np.sqrt(p) for p in primes])
    K = np.outer(u, v) + np.outer(v, u)
    return K, u, v


if __name__ == "__main__":
    # Quick self-test
    print("Self-inversive check on z^4 + 2z^3 + 3z^2 + 2z + 1:")
    result, omega = is_self_inversive(np.array([1, 2, 3, 2, 1]))
    print(f"  Is self-inversive: {result}, ω = {omega}")

    print("\nPrime-log kernel rank analysis (primes up to 30):")
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    info = analyze_kernel_rank(prime_log_kernel(primes))
    print(f"  Numerical rank: {info['numerical_rank']}")
    print(f"  Top singular values: {info['top_singular_values']}")

    print("\nCayley transform of Hermitian matrix spectrum:")
    H = np.array([[1, 0.5], [0.5, 2]])
    eigs, cayley = hermitian_to_unit_circle(H)
    print(f"  Eigenvalues: {eigs}")
    print(f"  |Cayley images|: {[abs(z) for z in cayley]}")
