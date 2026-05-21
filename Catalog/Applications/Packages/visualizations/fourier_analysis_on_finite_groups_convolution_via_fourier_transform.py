#!/usr/bin/env python3
"""
Certified Algorithms for Fourier Analysis on Finite Groups

This module implements the DFT, inverse DFT, and convolution algorithms
on cyclic groups Z/nZ, matching the formally verified definitions in the
Lean 4 development.

Each algorithm includes:
- Complete implementation with type hints
- Complexity analysis
- Correctness invariants matching the formal proofs
"""

import numpy as np
from typing import Optional


# ─────────────────────────────────────────────────────────────────────
# Character System on Z/nZ
# ─────────────────────────────────────────────────────────────────────

def character(n: int, k: int, j: int) -> complex:
    """Character χ_k(j) on Z/nZ.

    χ_k(j) = ω^{jk} where ω = e^{2πi/n}.

    This is the j-th value of the k-th character of Z/nZ.
    Each χ_k is a group homomorphism: χ_k(a + b) = χ_k(a) * χ_k(b).

    Args:
        n: Group order (positive integer)
        k: Character index (0 ≤ k < n)
        j: Group element (0 ≤ j < n)

    Returns:
        Complex number on the unit circle.

    Complexity: O(1)
    """
    return np.exp(2j * np.pi * j * k / n)


def character_matrix(n: int) -> np.ndarray:
    """Complete character matrix for Z/nZ.

    Returns the n×n matrix M where M[k, j] = χ_k(j) = ω^{jk}.
    This matrix satisfies:
    - M * conj(M)^T = n * I  (orthogonality)
    - conj(M)^T * M = n * I  (dual orthogonality)

    Args:
        n: Group order

    Returns:
        n×n complex matrix.

    Complexity: O(n²)
    """
    omega = np.exp(2j * np.pi / n)
    k = np.arange(n)
    j = np.arange(n)
    return omega ** np.outer(k, j)


# ─────────────────────────────────────────────────────────────────────
# Discrete Fourier Transform
# ─────────────────────────────────────────────────────────────────────

def dft(f: np.ndarray) -> np.ndarray:
    """Discrete Fourier Transform on Z/nZ.

    Computes f̂(k) = Σ_{j=0}^{n-1} f(j) * conj(χ_k(j))
                   = Σ_{j=0}^{n-1} f(j) * ω^{-jk}

    This matches the formal definition `fourierTransform` in Lean:
        fun i => Σ g : G, f g * starRingEnd ℂ (B.χ i g)

    Correctness properties (formally verified):
    1. Parseval: Σ_k |f̂(k)|² = n * Σ_j |f(j)|²
    2. Convolution: DFT(f * h) = DFT(f) · DFT(h)
    3. Inversion: IDFT(DFT(f)) = f

    Args:
        f: Input signal, array of n complex numbers.

    Returns:
        Fourier coefficients, array of n complex numbers.

    Complexity: O(n²) — quadratic DFT
    Note: Can be accelerated to O(n log n) via FFT when n is composite.
    """
    n = len(f)
    if n == 0:
        return np.array([], dtype=complex)

    M = character_matrix(n)
    return np.conj(M) @ f


def idft(fhat: np.ndarray) -> np.ndarray:
    """Inverse Discrete Fourier Transform on Z/nZ.

    Recovers f(j) = (1/n) * Σ_{k=0}^{n-1} f̂(k) * χ_k(j)

    This matches the formal definition `fourierInverse` in Lean:
        fun g => (1 / |G|) * Σ i : B.ι, F i * B.χ i g

    Args:
        fhat: Fourier coefficients, array of n complex numbers.

    Returns:
        Recovered signal, array of n complex numbers.

    Complexity: O(n²)
    """
    n = len(fhat)
    if n == 0:
        return np.array([], dtype=complex)

    M = character_matrix(n)
    return (1.0 / n) * M.T @ fhat


# ─────────────────────────────────────────────────────────────────────
# Convolution
# ─────────────────────────────────────────────────────────────────────

def convolution_direct(f: np.ndarray, h: np.ndarray) -> np.ndarray:
    """Direct convolution on Z/nZ.

    Computes (f * h)(x) = Σ_{y=0}^{n-1} f(y) * h(x - y mod n)

    This matches the formal definition `convolution` in Lean.

    Args:
        f, h: Input signals, arrays of n complex numbers.

    Returns:
        Convolution, array of n complex numbers.

    Complexity: O(n²)
    """
    n = len(f)
    assert len(h) == n, "Input arrays must have the same length"

    result = np.zeros(n, dtype=complex)
    for x in range(n):
        for y in range(n):
            result[x] += f[y] * h[(x - y) % n]
    return result


def convolution_fourier(f: np.ndarray, h: np.ndarray) -> np.ndarray:
    """Convolution via Fourier transform.

    Uses the convolution theorem (formally verified):
        f * h = IDFT(DFT(f) · DFT(h))

    This is the spectral method: convolution in time domain becomes
    pointwise multiplication in frequency domain.

    Args:
        f, h: Input signals, arrays of n complex numbers.

    Returns:
        Convolution, array of n complex numbers.

    Complexity: O(n²) with quadratic DFT, O(n log n) with FFT.
    """
    fhat = dft(f)
    hhat = dft(h)
    return idft(fhat * hhat)


# ─────────────────────────────────────────────────────────────────────
# Support and Uncertainty
# ─────────────────────────────────────────────────────────────────────

def support_size(f: np.ndarray, tol: float = 1e-10) -> int:
    """Size of the support of f: number of indices where |f(j)| > tol.

    Matches the formal definition `finSupportCard` in Lean.

    Args:
        f: Input signal.
        tol: Tolerance for zero detection.

    Returns:
        |{j : f(j) ≠ 0}|
    """
    return int(np.sum(np.abs(f) > tol))


def uncertainty_product(f: np.ndarray, tol: float = 1e-10) -> int:
    """Compute |supp(f)| * |supp(f̂)|.

    The uncertainty principle guarantees this is ≥ n for nonzero f.
    """
    fhat = dft(f)
    return support_size(f, tol) * support_size(fhat, tol)


def verify_uncertainty(f: np.ndarray, tol: float = 1e-10) -> bool:
    """Verify the uncertainty principle for a specific function.

    Returns True if |supp(f)| * |supp(f̂)| ≥ n.
    """
    n = len(f)
    return uncertainty_product(f, tol) >= n


# ─────────────────────────────────────────────────────────────────────
# Additive Energy
# ─────────────────────────────────────────────────────────────────────

def additive_energy_direct(A: list, n: int) -> int:
    """Direct computation of additive energy E(A) in Z/nZ.

    E(A) = |{(a₁,a₂,a₃,a₄) ∈ A⁴ : a₁-a₂ ≡ a₃-a₄ (mod n)}|

    Complexity: O(|A|⁴)
    """
    count = 0
    for a1 in A:
        for a2 in A:
            for a3 in A:
                for a4 in A:
                    if (a1 - a2) % n == (a3 - a4) % n:
                        count += 1
    return count


def additive_energy_fourier(A: list, n: int) -> float:
    """Fourier computation of additive energy.

    E(A) = (1/n) * Σ_k |1̂_A(k)|⁴

    This identity is formally verified in the Lean development.

    Complexity: O(n²) via DFT, O(n log n) with FFT.
    """
    indicator = np.zeros(n, dtype=complex)
    for a in A:
        indicator[a % n] = 1.0
    fhat = dft(indicator)
    return np.real(np.sum(np.abs(fhat) ** 4)) / n


# ─────────────────────────────────────────────────────────────────────
# Pseudocode Documentation
# ─────────────────────────────────────────────────────────────────────

DFT_PSEUDOCODE = """
Algorithm: Discrete Fourier Transform on Z/nZ
Input: f[0..n-1] ∈ ℂⁿ
Output: f̂[0..n-1] ∈ ℂⁿ

1. ω ← e^{2πi/n}
2. for k = 0 to n-1:
3.     f̂[k] ← 0
4.     for j = 0 to n-1:
5.         f̂[k] ← f̂[k] + f[j] · ω^{-jk}
6. return f̂

Time: O(n²)
Space: O(n)
Correctness: Parseval, Convolution Theorem, Inversion (formally verified)
"""

CONVOLUTION_PSEUDOCODE = """
Algorithm: Convolution via Fourier Transform on Z/nZ
Input: f[0..n-1], h[0..n-1] ∈ ℂⁿ
Output: (f*h)[0..n-1] ∈ ℂⁿ

1. f̂ ← DFT(f)
2. ĥ ← DFT(h)
3. for k = 0 to n-1:
4.     ĝ[k] ← f̂[k] · ĥ[k]
5. g ← IDFT(ĝ)
6. return g

Time: O(n²) [O(n log n) with FFT]
Space: O(n)
Correctness: g[x] = Σ_y f[y] · h[(x-y) mod n] (formally verified)
"""


if __name__ == "__main__":
    # Quick self-test
    print("Self-test of algorithms module...")

    n = 8
    np.random.seed(42)
    f = np.random.randn(n) + 1j * np.random.randn(n)
    h = np.random.randn(n) + 1j * np.random.randn(n)

    # Test inversion
    assert np.allclose(idft(dft(f)), f), "Inversion failed"

    # Test Parseval
    fhat = dft(f)
    assert np.isclose(np.sum(np.abs(fhat)**2), n * np.sum(np.abs(f)**2)), "Parseval failed"

    # Test convolution theorem
    conv_direct = convolution_direct(f, h)
    conv_fourier = convolution_fourier(f, h)
    assert np.allclose(conv_direct, conv_fourier), "Convolution theorem failed"

    # Test uncertainty
    for _ in range(100):
        g = np.zeros(n, dtype=complex)
        k = np.random.randint(1, n + 1)
        idx = np.random.choice(n, k, replace=False)
        g[idx] = np.random.randn(k) + 1j * np.random.randn(k)
        assert verify_uncertainty(g), "Uncertainty principle failed"

    print("All self-tests passed ✓")
