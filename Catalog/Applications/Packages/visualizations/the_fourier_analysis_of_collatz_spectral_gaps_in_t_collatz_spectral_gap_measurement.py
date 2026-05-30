#!/usr/bin/env python3
"""
Algorithms for Collatz Spectral Analysis
=========================================

Implements the core algorithms from the research paper:
1. Fast Collatz exponential sum computation
2. Spectral gap measurement
3. Parity ratio estimation
4. Drift function analysis and critical threshold computation

Time complexity: O(N) per frequency evaluation, O(N·M) for M frequencies.
Space complexity: O(1) for streaming computation, O(N) for orbit storage.
"""

import numpy as np
from typing import Tuple, List, Optional
from dataclasses import dataclass


@dataclass
class SpectralGapResult:
    """Result of a spectral gap measurement."""
    N: int
    max_energy: float
    sqrt_N: float
    gap_ratio: float  # max_energy / sqrt(N)
    argmax_omega: float
    frequencies_tested: int


@dataclass
class ParityAnalysis:
    """Parity analysis of a Collatz orbit."""
    n: int
    total_steps: int
    odd_count: int
    even_count: int
    odd_ratio: float
    descent_exponent: float
    spectral_weight: float
    is_contracting: bool


def collatz_step(n: int) -> int:
    """Standard Collatz step: n/2 if even, 3n+1 if odd.

    Complexity: O(1)
    """
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_orbit(n: int, max_steps: int = 100000) -> List[int]:
    """Compute full Collatz orbit from n to 1 (or max_steps).

    Complexity: O(stopping_time(n))
    """
    orbit = [n]
    current = n
    for _ in range(max_steps):
        if current <= 1:
            break
        current = collatz_step(current)
        orbit.append(current)
    return orbit


def compute_exponential_sum(N: int, omega: float) -> complex:
    """
    Compute the Collatz exponential sum:
        F_T(ω) = Σ_{n=1}^{N} exp(2πiω·T(n)/n)

    Args:
        N: Upper limit of summation
        omega: Frequency parameter

    Returns:
        Complex value of the exponential sum

    Complexity: O(N)
    """
    total = 0.0 + 0.0j
    for n in range(1, N + 1):
        Tn = collatz_step(n)
        phase = 2.0 * np.pi * omega * Tn / n
        total += np.exp(1j * phase)
    return total


def compute_spectral_energy(N: int, omega: float) -> float:
    """
    Compute spectral energy |F_T(ω)|.

    Complexity: O(N)
    """
    return abs(compute_exponential_sum(N, omega))


def measure_spectral_gap(
    N: int,
    num_frequencies: int = 200,
    omega_range: Tuple[float, float] = (0.01, 10.0)
) -> SpectralGapResult:
    """
    Measure the spectral gap by scanning frequencies.

    The spectral gap is measured as max_ω |F_T(ω)| / √N.
    If this ratio is bounded as N → ∞, the spectral gap conjecture holds.

    Args:
        N: Number of terms in the sum
        num_frequencies: Number of frequencies to test
        omega_range: Range of frequencies to scan

    Returns:
        SpectralGapResult with gap measurement

    Complexity: O(N · num_frequencies)
    """
    omegas = np.linspace(omega_range[0], omega_range[1], num_frequencies)
    max_energy = 0.0
    argmax = 0.0

    for omega in omegas:
        energy = compute_spectral_energy(N, omega)
        if energy > max_energy:
            max_energy = energy
            argmax = omega

    sqrt_N = np.sqrt(N)
    return SpectralGapResult(
        N=N,
        max_energy=max_energy,
        sqrt_N=sqrt_N,
        gap_ratio=max_energy / sqrt_N,
        argmax_omega=argmax,
        frequencies_tested=num_frequencies
    )


def analyze_parity(n: int) -> ParityAnalysis:
    """
    Full parity analysis of a Collatz orbit.

    Computes the odd/even step counts, descent exponent, spectral weight,
    and determines whether the orbit is contracting.

    Args:
        n: Starting value (must be > 1)

    Returns:
        ParityAnalysis dataclass

    Complexity: O(stopping_time(n))
    """
    orbit = collatz_orbit(n)
    total = len(orbit) - 1
    if total == 0:
        return ParityAnalysis(n, 0, 0, 0, 0.0, 0.0, 1.0, True)

    odd_count = sum(1 for x in orbit[:-1] if x % 2 == 1)
    even_count = total - odd_count
    odd_ratio = odd_count / total

    # Descent exponent: j*log(3) - (k-j)*log(2)
    de = odd_count * np.log(3) - even_count * np.log(2)

    # Spectral weight: 3^j / 2^(k-j)
    sw = 3**odd_count / 2**even_count if even_count < 1000 else np.exp(de)

    return ParityAnalysis(
        n=n,
        total_steps=total,
        odd_count=odd_count,
        even_count=even_count,
        odd_ratio=odd_ratio,
        descent_exponent=de,
        spectral_weight=sw,
        is_contracting=(de < 0)
    )


def drift_function(p: float) -> float:
    """
    Random walk drift: μ(p) = p·log(3) - (1-p)·log(2).

    The drift is negative for p < p* ≈ 0.3869, where p* is the
    critical parity threshold.

    Complexity: O(1)
    """
    return p * np.log(3) - (1 - p) * np.log(2)


def critical_threshold() -> float:
    """
    The critical parity threshold p* = log(2)/(log(2)+log(3)).

    Below this threshold, orbits contract on average.

    Complexity: O(1)
    """
    return np.log(2) / (np.log(2) + np.log(3))


def find_drift_zero(tol: float = 1e-15) -> float:
    """
    Find the unique zero of the drift function in (0,1) by bisection.

    This implements the constructive version of our cross-domain theorem
    (drift_unique_zero_in_unit).

    Complexity: O(log(1/tol))
    """
    lo, hi = 0.0, 1.0
    while hi - lo > tol:
        mid = (lo + hi) / 2
        if drift_function(mid) < 0:
            lo = mid
        else:
            hi = mid
    return (lo + hi) / 2


def spectral_weight(j: int, k: int) -> float:
    """Compute spectral weight 3^j / 2^(k-j)."""
    return 3**j / 2**(k - j)


def descent_exponent(j: int, k: int) -> float:
    """Compute descent exponent j·log(3) - (k-j)·log(2)."""
    return j * np.log(3) - (k - j) * np.log(2)


def batch_spectral_gap_test(
    N_values: List[int],
    num_frequencies: int = 100
) -> List[SpectralGapResult]:
    """
    Run spectral gap test across multiple N values.

    If the gap_ratio stays bounded, the spectral gap conjecture holds.

    Complexity: O(sum(N_i) · num_frequencies)
    """
    results = []
    for N in N_values:
        result = measure_spectral_gap(N, num_frequencies)
        results.append(result)
    return results


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Collatz Spectral Analysis Algorithms")
    print("=" * 50)

    # Critical threshold
    p_star = critical_threshold()
    p_star_bisect = find_drift_zero()
    print(f"\nCritical threshold (analytical): {p_star:.10f}")
    print(f"Critical threshold (bisection):  {p_star_bisect:.10f}")

    # Parity analysis
    print("\nParity Analysis:")
    for n in [27, 871, 6171, 77031]:
        analysis = analyze_parity(n)
        print(f"  n={n}: steps={analysis.total_steps}, "
              f"odd_ratio={analysis.odd_ratio:.4f}, "
              f"contracting={analysis.is_contracting}")

    # Spectral gap test
    print("\nSpectral Gap Test:")
    N_values = [50, 100, 200, 500]
    results = batch_spectral_gap_test(N_values, num_frequencies=50)
    for r in results:
        print(f"  N={r.N:>5}: max|F_T|={r.max_energy:.2f}, "
              f"√N={r.sqrt_N:.2f}, ratio={r.gap_ratio:.4f}")
