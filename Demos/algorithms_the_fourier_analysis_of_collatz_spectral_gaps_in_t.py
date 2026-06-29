#!/usr/bin/env python3
"""
Algorithms for Spectral Analysis of the Collatz Map

Type-hinted implementations of the core algorithms for computing
parity words, spectral sums, and contraction exponents.
"""
import math
from typing import Optional


def collatz_step(n: int) -> int:
    """Standard Collatz step T(n)."""
    if n % 2 == 0:
        return n // 2
    else:
        return 3 * n + 1


def collatz_orbit(n: int, max_steps: int = 100000) -> list[int]:
    """Compute the full Collatz orbit until reaching 1."""
    orbit: list[int] = [n]
    current = n
    steps = 0
    while current != 1 and steps < max_steps:
        current = collatz_step(current)
        orbit.append(current)
        steps += 1
    return orbit


def parity_word(orbit: list[int]) -> list[int]:
    """Extract binary parity word from orbit: 1 if odd, 0 if even."""
    return [x % 2 for x in orbit]


def odd_step_count(pw: list[int]) -> int:
    """Count number of 1s (odd steps) in a parity word."""
    return sum(pw)


def parity_density(pw: list[int]) -> float:
    """Compute the parity density j/k of a parity word."""
    if len(pw) == 0:
        return 0.0
    return sum(pw) / len(pw)


def contraction_exponent(j: int, k: int) -> float:
    """
    Compute the contraction exponent δ = k·log(2) - j·log(3).

    Positive values indicate net orbit contraction.
    The orbit contracts by a multiplicative factor of 2^k / 3^j.
    """
    return k * math.log(2) - j * math.log(3)


def contraction_factor(j: int, k: int) -> float:
    """
    Compute the contraction factor 2^k / 3^j.

    Values > 1 indicate net contraction.
    """
    return (2 ** k) / (3 ** j)


def spectral_cos_sum(pw: list[int], omega: float) -> float:
    """
    Cosine component of the discrete Fourier transform of the parity word.

    F_cos(ω) = Σ_{k=0}^{K-1} pw[k] · cos(2πωk)
    """
    return sum(
        pw[k] * math.cos(2 * math.pi * omega * k)
        for k in range(len(pw))
    )


def spectral_sin_sum(pw: list[int], omega: float) -> float:
    """
    Sine component of the discrete Fourier transform of the parity word.

    F_sin(ω) = Σ_{k=0}^{K-1} pw[k] · sin(2πωk)
    """
    return sum(
        pw[k] * math.sin(2 * math.pi * omega * k)
        for k in range(len(pw))
    )


def spectral_energy(pw: list[int], omega: float) -> float:
    """
    Spectral energy |F(ω)|² = F_cos² + F_sin² at frequency ω.

    At ω = 0, this equals j² where j = odd_step_count.
    """
    c = spectral_cos_sum(pw, omega)
    s = spectral_sin_sum(pw, omega)
    return c * c + s * s


def spectral_profile(
    pw: list[int],
    num_frequencies: int = 100
) -> list[tuple[float, float]]:
    """
    Compute the spectral energy profile over evenly spaced frequencies.

    Returns list of (frequency, energy) pairs.
    """
    result: list[tuple[float, float]] = []
    for i in range(num_frequencies + 1):
        omega = i / num_frequencies
        e = spectral_energy(pw, omega)
        result.append((omega, e))
    return result


def max_spectral_energy_ratio(
    pw: list[int],
    num_frequencies: int = 100,
    exclude_dc: bool = True
) -> float:
    """
    Compute the maximum spectral energy ratio E(ω) / E(0) over non-DC frequencies.

    A small ratio indicates a spectral gap (mixing behavior).
    """
    j = odd_step_count(pw)
    dc_energy = j * j
    if dc_energy == 0:
        return 0.0

    max_ratio = 0.0
    for i in range(1 if exclude_dc else 0, num_frequencies + 1):
        omega = i / num_frequencies
        e = spectral_energy(pw, omega)
        ratio = e / dc_energy
        if ratio > max_ratio:
            max_ratio = ratio
    return max_ratio


def verify_spectral_gap_conjecture(
    max_n: int = 10000,
    verbose: bool = False
) -> dict[str, object]:
    """
    Test the spectral gap conjecture for all n from 2 to max_n.

    The conjecture states that every Collatz orbit reaching 1 has
    parity density strictly below log(2)/log(3) ≈ 0.6309.

    Returns a dictionary with:
    - 'holds': bool — whether the conjecture holds for all tested n
    - 'max_density': float — maximum parity density observed
    - 'max_n': int — the n achieving maximum density
    - 'critical_threshold': float — log(2)/log(3)
    - 'gap': float — critical_threshold - max_density
    """
    critical = math.log(2) / math.log(3)
    max_density = 0.0
    max_n_val = 1

    for n in range(2, max_n + 1):
        orbit = collatz_orbit(n)
        if orbit[-1] != 1:
            continue
        pw = parity_word(orbit)
        d = parity_density(pw)
        if d > max_density:
            max_density = d
            max_n_val = n
        if verbose and d > 0.6:
            print(f"  n={n}: density={d:.6f}, steps={len(orbit)}")

    return {
        'holds': max_density < critical,
        'max_density': max_density,
        'max_n': max_n_val,
        'critical_threshold': critical,
        'gap': critical - max_density,
    }


def generalized_map_orbit(
    n: int,
    a: int = 3,
    b: int = 1,
    max_steps: int = 10000
) -> Optional[list[int]]:
    """
    Orbit under the generalized map: n/2 if even, a*n+b if odd.

    Returns None if the orbit exceeds 10^15 (divergence detected).
    """
    orbit: list[int] = [n]
    current = n
    for _ in range(max_steps):
        if current == 1:
            break
        if current % 2 == 0:
            current = current // 2
        else:
            current = a * current + b
        if current > 10**15:
            return None  # Divergence detected
        orbit.append(current)
    return orbit


if __name__ == "__main__":
    # Quick verification
    result = verify_spectral_gap_conjecture(1000, verbose=True)
    print(f"\nConjecture holds for n ≤ 1000: {result['holds']}")
    print(f"Max density: {result['max_density']:.6f}")
    print(f"Critical threshold: {result['critical_threshold']:.6f}")
    print(f"Gap: {result['gap']:.6f}")
