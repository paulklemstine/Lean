"""
Algorithms for Prime Frequency Spectrum Analysis

Implements the algorithms described in the research paper for computing
prime frequencies, finite prime signals, and spectral analysis.
"""

import numpy as np
from typing import List, Tuple, Optional


def sieve_of_eratosthenes(n: int) -> List[int]:
    """
    Compute all primes up to n using the Sieve of Eratosthenes.
    
    Time complexity: O(n log log n)
    Space complexity: O(n)
    
    Args:
        n: Upper bound for prime search
    Returns:
        Sorted list of all primes p with 2 ≤ p ≤ n
    
    Example:
        >>> sieve_of_eratosthenes(20)
        [2, 3, 5, 7, 11, 13, 17, 19]
    """
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def compute_prime_frequencies(primes: List[int]) -> List[Tuple[int, float]]:
    """
    Compute the prime frequency spectrum: (p, log(p)/(2π)) for each prime.
    
    Time complexity: O(K) where K = len(primes)
    
    Args:
        primes: List of prime numbers
    Returns:
        List of (prime, frequency) pairs
    
    Example:
        >>> compute_prime_frequencies([2, 3, 5])
        [(2, 0.1103...), (3, 0.1749...), (5, 0.2562...)]
    """
    return [(p, np.log(p) / (2 * np.pi)) for p in primes]


def compute_spectral_gaps(primes: List[int]) -> List[Tuple[int, int, float]]:
    """
    Compute spectral gaps between consecutive primes.
    
    Args:
        primes: Sorted list of primes
    Returns:
        List of (p, q, gap) triples where gap = (log(q) - log(p))/(2π)
    
    Example:
        >>> compute_spectral_gaps([2, 3, 5, 7])
        [(2, 3, 0.0645...), (3, 5, 0.0813...), (5, 7, 0.0535...)]
    """
    gaps = []
    for i in range(len(primes) - 1):
        p, q = primes[i], primes[i + 1]
        gap = (np.log(q) - np.log(p)) / (2 * np.pi)
        gaps.append((p, q, gap))
    return gaps


def evaluate_prime_signal(primes: List[int], t_values: np.ndarray) -> np.ndarray:
    """
    Evaluate the finite prime signal D_N(t) = Σ_p (1/√p) cos(t·log(p)).
    
    Time complexity: O(K × M) where K = len(primes), M = len(t_values)
    
    Args:
        primes: List of primes to include
        t_values: Array of time points at which to evaluate
    Returns:
        Array of signal values D_N(t)
    
    Example:
        >>> primes = [2, 3, 5]
        >>> t = np.array([0.0])
        >>> evaluate_prime_signal(primes, t)  # Sum of 1/√p for p in primes
        array([1.485...])
    """
    signal = np.zeros_like(t_values, dtype=float)
    for p in primes:
        amplitude = 1.0 / np.sqrt(p)
        log_p = np.log(p)
        signal += amplitude * np.cos(t_values * log_p)
    return signal


def spectral_analysis_fft(
    primes: List[int],
    T: float = 500.0,
    M: int = 2**16
) -> Tuple[np.ndarray, np.ndarray, List[Tuple[float, float]]]:
    """
    Compute the spectral analysis of the prime signal via FFT.
    
    Samples D_N(t) at M uniformly spaced points in [-T, T],
    computes the FFT, and identifies peaks.
    
    Time complexity: O(K·M + M log M)
    
    Args:
        primes: List of primes
        T: Time range [-T, T]
        M: Number of sample points (should be power of 2)
    Returns:
        (freq_axis, magnitude, peaks) where peaks = [(freq, height), ...]
    
    Example:
        >>> primes = sieve_of_eratosthenes(50)
        >>> freqs, mag, peaks = spectral_analysis_fft(primes)
    """
    t = np.linspace(-T, T, M)
    signal = evaluate_prime_signal(primes, t)
    
    spectrum = np.fft.fft(signal)
    freqs = np.fft.fftfreq(M, d=(2 * T) / M)
    
    # Take positive frequencies only
    pos_mask = freqs > 0
    freq_axis = freqs[pos_mask]
    magnitude = np.abs(spectrum[pos_mask])
    
    # Peak detection
    threshold = 0.05 * np.max(magnitude)
    peaks = []
    for i in range(2, len(magnitude) - 2):
        if (magnitude[i] > magnitude[i-1] and magnitude[i] > magnitude[i+1]
                and magnitude[i] > threshold):
            peaks.append((freq_axis[i], magnitude[i]))
    
    # Sort by height
    peaks.sort(key=lambda x: -x[1])
    
    return freq_axis, magnitude, peaks


def match_peaks_to_primes(
    peaks: List[Tuple[float, float]],
    primes: List[int],
    tolerance: float = 0.01
) -> List[Tuple[float, float, Optional[int], float]]:
    """
    Match detected spectral peaks to predicted prime frequencies.
    
    Args:
        peaks: List of (frequency, height) pairs from FFT
        primes: List of primes to match against
        tolerance: Maximum frequency difference for a match
    Returns:
        List of (peak_freq, peak_height, matched_prime, error) tuples
    """
    prime_freqs = {p: np.log(p) / (2 * np.pi) for p in primes}
    results = []
    
    for peak_f, peak_h in peaks:
        best_prime = None
        best_error = float('inf')
        
        for p, pf in prime_freqs.items():
            error = abs(peak_f - pf)
            if error < best_error:
                best_error = error
                best_prime = p
        
        if best_error < tolerance:
            results.append((peak_f, peak_h, best_prime, best_error))
        else:
            results.append((peak_f, peak_h, None, best_error))
    
    return results


def tropical_decomposition(n: int, primes: List[int]) -> List[Tuple[int, int, float]]:
    """
    Tropical decomposition of n: express primeFreq(n) as a sum of prime frequencies.
    
    Uses the factorization n = p1^a1 * p2^a2 * ... to compute
    primeFreq(n) = a1*primeFreq(p1) + a2*primeFreq(p2) + ...
    
    Args:
        n: Positive integer to decompose
        primes: List of primes to use for factorization
    Returns:
        List of (prime, exponent, contribution) triples
    
    Example:
        >>> tropical_decomposition(12, [2, 3, 5])
        [(2, 2, 0.2207...), (3, 1, 0.1749...)]
    """
    if n <= 0:
        raise ValueError("n must be positive")
    
    factors = []
    remaining = n
    for p in primes:
        if p * p > remaining:
            break
        exp = 0
        while remaining % p == 0:
            exp += 1
            remaining //= p
        if exp > 0:
            freq = np.log(p) / (2 * np.pi)
            factors.append((p, exp, exp * freq))
    
    if remaining > 1:
        freq = np.log(remaining) / (2 * np.pi)
        factors.append((remaining, 1, freq))
    
    return factors


def verify_tropical_homomorphism(a: int, b: int) -> Tuple[float, float, float]:
    """
    Verify the tropical homomorphism: primeFreq(a*b) = primeFreq(a) + primeFreq(b).
    
    Args:
        a, b: Positive integers
    Returns:
        (lhs, rhs, error) where lhs = primeFreq(a*b), rhs = primeFreq(a) + primeFreq(b)
    """
    lhs = np.log(a * b) / (2 * np.pi)
    rhs = np.log(a) / (2 * np.pi) + np.log(b) / (2 * np.pi)
    return lhs, rhs, abs(lhs - rhs)


if __name__ == "__main__":
    # Example usage
    primes = sieve_of_eratosthenes(100)
    print("Prime frequencies:")
    for p, f in compute_prime_frequencies(primes[:10]):
        print(f"  p={p}, freq={f:.8f}")
    
    print("\nSpectral gaps:")
    for p, q, gap in compute_spectral_gaps(primes[:10]):
        print(f"  ({p}, {q}): gap = {gap:.8f}")
    
    print("\nTropical decomposition of 360 = 2^3 * 3^2 * 5:")
    for p, exp, contrib in tropical_decomposition(360, primes):
        print(f"  {p}^{exp}: contribution = {contrib:.8f}")
    
    total = sum(c for _, _, c in tropical_decomposition(360, primes))
    direct = np.log(360) / (2 * np.pi)
    print(f"  Total = {total:.8f}, direct = {direct:.8f}, error = {abs(total-direct):.2e}")
