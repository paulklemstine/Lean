#!/usr/bin/env python3
"""
Algorithms for Prime Spectral Analysis of the Riemann Zeta Function.

Type-hinted implementations of:
1. Prime spectrum computation
2. Spectral consonance analysis
3. Fourier transform of zeta on the critical line
4. Spectral density estimation
5. Dissonance measure computation
"""

from math import log, sqrt, pi, floor, ceil
from typing import List, Tuple, Optional
import numpy as np


# ============================================================
# Algorithm 1: Prime Sieve and Spectrum Construction
# ============================================================

def sieve_of_eratosthenes(n: int) -> List[int]:
    """
    Standard sieve of Eratosthenes.

    Args:
        n: Upper bound for prime search

    Returns:
        Sorted list of primes ≤ n

    Complexity: O(n log log n) time, O(n) space
    """
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, n + 1, i):
                sieve[j] = False
    return [i for i in range(n + 1) if sieve[i]]


def compute_prime_spectrum(n: int) -> List[Tuple[int, float, float]]:
    """
    Compute the prime spectrum up to n.

    Each prime p contributes a spectral line at:
      - Frequency: f(p) = log(p) / (2π)
      - Amplitude: w(p) = 1 / √p

    Args:
        n: Upper bound for prime search

    Returns:
        List of (prime, frequency, weight) tuples, sorted by frequency
    """
    primes = sieve_of_eratosthenes(n)
    return [(p, log(p) / (2 * pi), 1.0 / sqrt(p)) for p in primes]


# ============================================================
# Algorithm 2: Spectral Consonance Analysis
# ============================================================

def frequency_ratio(p: int, q: int) -> float:
    """
    Compute the spectral frequency ratio log(q)/log(p).

    This ratio determines the "musical interval" between primes p and q.
    By Gelfond-Schneider, this is always irrational for distinct primes.

    Args:
        p: First prime (must be ≥ 2)
        q: Second prime (must be ≥ 2)

    Returns:
        log(q) / log(p)
    """
    return log(q) / log(p)


def best_rational_approximation(x: float, max_denom: int) -> Tuple[int, int, float]:
    """
    Find the best rational approximation a/b to x with b ≤ max_denom.

    Uses the Stern-Brocot tree / mediants for efficiency.

    Args:
        x: Real number to approximate
        max_denom: Maximum denominator allowed

    Returns:
        (a, b, distance) where |x - a/b| = distance is minimized
    """
    best_a, best_b = round(x), 1
    best_dist = abs(x - best_a)

    for b in range(1, max_denom + 1):
        a = round(x * b)
        dist = abs(x - a / b)
        if dist < best_dist:
            best_dist = dist
            best_a, best_b = a, b

    return best_a, best_b, best_dist


def spectral_consonance_matrix(primes: List[int], max_denom: int = 50) -> np.ndarray:
    """
    Compute the consonance matrix for a set of primes.

    Entry (i,j) = min distance of log(p_j)/log(p_i) from rationals with
    denominator ≤ max_denom. Small values indicate "near-consonance."

    Args:
        primes: List of primes
        max_denom: Maximum denominator for rational approximation

    Returns:
        n×n matrix of consonance values
    """
    n = len(primes)
    matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i == j:
                matrix[i, j] = 0.0
            else:
                ratio = frequency_ratio(primes[i], primes[j])
                _, _, dist = best_rational_approximation(ratio, max_denom)
                matrix[i, j] = dist
    return matrix


# ============================================================
# Algorithm 3: Zeta on Critical Line via Dirichlet Sum
# ============================================================

def zeta_critical_line(t: float, N: int = 1000) -> complex:
    """
    Approximate ζ(1/2 + it) using partial Dirichlet sum.

    Z(t) ≈ Σ_{n=1}^{N} n^{-1/2 - it}

    Args:
        t: Real parameter (imaginary part on critical line)
        N: Number of terms in partial sum

    Returns:
        Complex value ζ(1/2 + it)
    """
    result = 0j
    for n in range(1, N + 1):
        result += n ** (-0.5 - 1j * t)
    return result


def zeta_critical_line_vectorized(t_array: np.ndarray, N: int = 1000) -> np.ndarray:
    """
    Vectorized computation of ζ(1/2 + it) for an array of t values.

    Args:
        t_array: Array of real parameters
        N: Number of terms in Dirichlet sum

    Returns:
        Array of complex values
    """
    result = np.zeros(len(t_array), dtype=complex)
    for n in range(1, N + 1):
        result += n ** (-0.5 - 1j * t_array)
    return result


# ============================================================
# Algorithm 4: Windowed Fourier Transform of Zeta
# ============================================================

def fourier_transform_zeta(
    omega_values: np.ndarray,
    T: float = 100.0,
    dt: float = 0.1,
    N_dirichlet: int = 200,
    window_type: str = "gaussian"
) -> np.ndarray:
    """
    Compute the windowed Fourier transform of Z(t) = ζ(1/2+it).

    F[Z](ω) = ∫ Z(t) · w(t) · e^{-2πiωt} dt

    where w(t) is a window function ensuring convergence.

    Args:
        omega_values: Frequencies at which to evaluate the FT
        T: Half-width of the integration window
        dt: Time step for numerical integration
        N_dirichlet: Terms in Dirichlet sum for Z(t)
        window_type: "gaussian" or "hann"

    Returns:
        Complex array of Fourier transform values
    """
    t_values = np.arange(-T, T, dt)

    # Window function
    if window_type == "gaussian":
        sigma = T / 3
        window = np.exp(-t_values**2 / (2 * sigma**2))
    elif window_type == "hann":
        window = 0.5 * (1 + np.cos(pi * t_values / T))
    else:
        window = np.ones_like(t_values)

    # Compute Z(t)
    Z_values = zeta_critical_line_vectorized(t_values, N_dirichlet)
    Z_windowed = Z_values * window

    # Fourier transform
    result = np.zeros(len(omega_values), dtype=complex)
    for i, omega in enumerate(omega_values):
        integrand = Z_windowed * np.exp(-2j * pi * omega * t_values)
        result[i] = np.sum(integrand) * dt

    return result


# ============================================================
# Algorithm 5: Spectral Density Estimation
# ============================================================

def spectral_density(f: float, n_primes: int = 10000) -> Tuple[int, float]:
    """
    Count prime spectral lines below frequency f and compare with
    the PNT prediction e^{2πf} / (2πf).

    Args:
        f: Frequency threshold
        n_primes: Number of primes to consider

    Returns:
        (actual_count, predicted_count)
    """
    x = np.exp(2 * pi * f)
    primes = sieve_of_eratosthenes(int(min(x + 100, 10**7)))
    actual = sum(1 for p in primes if log(p) / (2 * pi) <= f)
    predicted = x / (2 * pi * f) if f > 0 else 0
    return actual, predicted


# ============================================================
# Algorithm 6: Spectral Weight Partial Sums
# ============================================================

def spectral_weight_sum(n: int) -> Tuple[float, float]:
    """
    Compute Σ_{p prime, p ≤ n} 1/√p and compare with bound n/√2.

    Args:
        n: Upper bound

    Returns:
        (actual_sum, upper_bound)
    """
    primes = sieve_of_eratosthenes(n)
    actual = sum(1.0 / sqrt(p) for p in primes)
    bound = n / sqrt(2)
    return actual, bound


# ============================================================
# Algorithm 7: Frequency Gap Analysis
# ============================================================

def frequency_gaps(n: int) -> List[Tuple[int, int, float, float]]:
    """
    Compute frequency gaps between consecutive primes and lower bounds.

    Args:
        n: Upper bound for primes

    Returns:
        List of (p, q, gap, lower_bound) for consecutive primes p < q
    """
    primes = sieve_of_eratosthenes(n)
    gaps = []
    for i in range(len(primes) - 1):
        p, q = primes[i], primes[i + 1]
        gap = log(q) / (2 * pi) - log(p) / (2 * pi)
        lower = log(1 + 1.0 / p) / (2 * pi)
        gaps.append((p, q, gap, lower))
    return gaps


if __name__ == "__main__":
    # Quick self-test
    spectrum = compute_prime_spectrum(30)
    print("Prime Spectrum (p ≤ 30):")
    for p, f, w in spectrum:
        print(f"  p={p:>2}, freq={f:.6f}, weight={w:.6f}")

    print("\nConsonance matrix (first 5 primes):")
    small = [2, 3, 5, 7, 11]
    mat = spectral_consonance_matrix(small, max_denom=50)
    for i, p in enumerate(small):
        row = " ".join(f"{mat[i,j]:.4f}" for j in range(len(small)))
        print(f"  p={p:>2}: {row}")

    print("\nSpectral density test:")
    for f in [0.5, 1.0, 1.5, 2.0]:
        actual, predicted = spectral_density(f)
        print(f"  f={f:.1f}: actual={actual}, predicted={predicted:.1f}")
