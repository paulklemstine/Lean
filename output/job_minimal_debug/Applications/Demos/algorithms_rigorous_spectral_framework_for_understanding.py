#!/usr/bin/env python3
"""
Prime Spectral Framework — Core Algorithms
===========================================

Type-hinted implementations of the key algorithms in the spectral framework.
"""

import math
from dataclasses import dataclass
from typing import List, Tuple, Optional


@dataclass(frozen=True)
class PrimeSpectralLine:
    """A prime spectral line with frequency and amplitude."""
    prime: int
    frequency: float
    amplitude: float
    energy: float

    @staticmethod
    def from_prime(p: int) -> 'PrimeSpectralLine':
        """Construct a spectral line from a prime number."""
        assert p >= 2, f"Expected prime, got {p}"
        return PrimeSpectralLine(
            prime=p,
            frequency=math.log(p) / (2 * math.pi),
            amplitude=1.0 / math.sqrt(p),
            energy=1.0 / p
        )


@dataclass(frozen=True)
class SpectralChord:
    """A pair of prime spectral lines with harmonic analysis."""
    low: PrimeSpectralLine
    high: PrimeSpectralLine
    frequency_ratio: float
    amplitude_ratio: float

    @staticmethod
    def from_primes(p: int, q: int) -> 'SpectralChord':
        """Construct a spectral chord from two primes p < q."""
        assert p < q, f"Expected p < q, got {p} >= {q}"
        low = PrimeSpectralLine.from_prime(p)
        high = PrimeSpectralLine.from_prime(q)
        return SpectralChord(
            low=low,
            high=high,
            frequency_ratio=math.log(q) / math.log(p),
            amplitude_ratio=low.amplitude / high.amplitude
        )


def sieve_of_eratosthenes(n: int) -> List[int]:
    """Return all primes up to n."""
    if n < 2:
        return []
    sieve = bytearray(b'\x01') * (n + 1)
    sieve[0] = sieve[1] = 0
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            sieve[i*i::i] = bytearray(len(sieve[i*i::i]))
    return [i for i in range(2, n + 1) if sieve[i]]


def compute_prime_spectrum(n_primes: int) -> List[PrimeSpectralLine]:
    """Compute spectral lines for the first n_primes primes."""
    # Overestimate the sieve bound using PNT: p_n ~ n * ln(n)
    bound = max(100, int(n_primes * (math.log(n_primes) + math.log(math.log(n_primes + 2)) + 2)))
    primes = sieve_of_eratosthenes(bound)
    return [PrimeSpectralLine.from_prime(p) for p in primes[:n_primes]]


def spectral_resonance_defect(p: int, q: int, resolution: int) -> Tuple[float, int, int]:
    """
    Compute the spectral resonance defect D_N(p, q).

    Returns (defect, best_a, best_b) where defect = |log(p)/log(q) - best_a/best_b|.
    """
    r = math.log(p) / math.log(q)
    best_defect = float('inf')
    best_a, best_b = 0, 1
    for b in range(1, resolution + 1):
        a = round(r * b)
        defect = abs(r - a / b)
        if defect < best_defect:
            best_defect = defect
            best_a, best_b = a, b
    return (best_defect, best_a, best_b)


def continued_fraction_convergents(x: float, max_terms: int = 20) -> List[Tuple[int, int]]:
    """
    Compute the convergents (a/b) of the continued fraction expansion of x.
    Returns list of (numerator, denominator) pairs.
    """
    convergents: List[Tuple[int, int]] = []
    a_prev, b_prev = 1, 0  # p_{-1}/q_{-1}
    a_curr, b_curr = 0, 1  # p_0/q_0 (will be overwritten)

    remaining = x
    for _ in range(max_terms):
        floor_val = int(math.floor(remaining))
        a_next = floor_val * a_curr + a_prev if convergents else floor_val
        b_next = floor_val * b_curr + b_prev if convergents else 1
        if not convergents:
            a_curr, b_curr = a_next, b_next
        else:
            a_prev, b_prev = a_curr, b_curr
            a_curr, b_curr = a_next, b_next
        convergents.append((a_curr, b_curr))

        frac = remaining - floor_val
        if abs(frac) < 1e-15:
            break
        remaining = 1.0 / frac
    return convergents


def spectral_entropy(primes: List[int]) -> float:
    """
    Compute the spectral entropy H = -Σ w_i log(w_i)
    where w_i = (1/√p_i) / Σ(1/√p_j).
    """
    weights = [1.0 / math.sqrt(p) for p in primes]
    total = sum(weights)
    return -sum((w/total) * math.log(w/total) for w in weights)


def spectral_counting_function(f: float, primes: List[int]) -> int:
    """Count the number of primes with spectral frequency ≤ f."""
    return sum(1 for p in primes if math.log(p) / (2 * math.pi) <= f)


def verify_prime_power_independence(
    primes: List[int], max_exponent: int = 30
) -> Optional[Tuple[int, int, int, int]]:
    """
    Exhaustively verify p^m ≠ q^n for given primes and exponents up to max_exponent.
    Returns None if no violation found, or (p, m, q, n) of a violation.
    """
    # Compute all prime powers
    powers: dict[int, Tuple[int, int]] = {}
    for p in primes:
        val = p
        for m in range(1, max_exponent + 1):
            if val in powers:
                old_p, old_m = powers[val]
                if old_p != p:
                    return (old_p, old_m, p, m)
            powers[val] = (p, m)
            if val > 10**18:
                break
            val *= p
    return None


def spectral_gap_regularity_check(
    primes: List[int]
) -> Tuple[bool, int, float, float]:
    """
    Check the Spectral Gap Regularity Conjecture.
    Returns (holds, worst_n, worst_ratio, bound_at_worst).
    """
    worst_ratio = 0.0
    worst_n = 0
    for i in range(len(primes) - 1):
        p, q = primes[i], primes[i + 1]
        ratio = math.log(q) / math.log(p)
        n = i + 1
        bound = 1 + 1.0 / n
        if ratio > bound:
            return (False, n, ratio, bound)
        if ratio > worst_ratio:
            worst_ratio = ratio
            worst_n = n
    bound_at_worst = 1 + 1.0 / worst_n if worst_n > 0 else float('inf')
    return (True, worst_n, worst_ratio, bound_at_worst)


if __name__ == "__main__":
    # Quick self-test
    spectrum = compute_prime_spectrum(10)
    print("First 10 prime spectral lines:")
    for line in spectrum:
        print(f"  p={line.prime:>3}, freq={line.frequency:.6f}, "
              f"amp={line.amplitude:.6f}, energy={line.energy:.6f}")

    print("\nChord (2, 3):")
    chord = SpectralChord.from_primes(2, 3)
    print(f"  freq_ratio={chord.frequency_ratio:.6f}, "
          f"amp_ratio={chord.amplitude_ratio:.6f}")

    print("\nResonance defect D_100(2, 3):")
    d, a, b = spectral_resonance_defect(2, 3, 100)
    print(f"  D = {d:.10f}, best approx = {a}/{b}")

    print("\nContinued fraction of log(2)/log(3):")
    convs = continued_fraction_convergents(math.log(2) / math.log(3))
    for num, den in convs[:10]:
        print(f"  {num}/{den} = {num/den:.10f}")
