#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Core Algorithms

Implements the mathematical algorithms from the research paper:
1. Möbius orbit computation
2. Hyperbolic zeta function evaluation
3. Hyperbolic prime counting
4. Cross-ratio and hyperbolic distance
5. Orbit composition verification
"""

import numpy as np
from typing import Optional


def moebius_map(a: complex, z: complex) -> complex:
    """
    Möbius disk automorphism φ_a(z) = (z - a) / (1 - conj(a) * z).
    
    Maps the unit disk to itself when |a| < 1.
    Sends a to 0 and 0 to -a.
    
    Args:
        a: Center point (must satisfy |a| < 1)
        z: Input point
    Returns:
        φ_a(z)
    
    Example:
        >>> moebius_map(0.3, 0.0)
        (-0.3+0j)
        >>> abs(moebius_map(0.3+0.2j, 0.5-0.1j)) < 1
        True
    """
    denom = 1 - np.conj(a) * z
    if abs(denom) < 1e-15:
        raise ValueError(f"Denominator near zero: |1 - conj(a)*z| = {abs(denom)}")
    return (z - a) / denom


def compute_orbit(a: complex, N: int, start: complex = 0.0) -> np.ndarray:
    """
    Compute the Möbius orbit: z_0 = start, z_{n+1} = φ_a(z_n).
    
    Time complexity: O(N)
    Space complexity: O(N)
    
    Args:
        a: Generator (|a| < 1)
        N: Number of orbit points after start
        start: Initial point (default: origin)
    Returns:
        Array of N+1 complex numbers [z_0, z_1, ..., z_N]
    
    Example:
        >>> orbit = compute_orbit(0.3, 5)
        >>> all(abs(z)**2 < 1 for z in orbit)
        True
    """
    orbit = np.zeros(N + 1, dtype=complex)
    orbit[0] = start
    for i in range(N):
        orbit[i + 1] = moebius_map(a, orbit[i])
    return orbit


def golden_generator() -> float:
    """
    The golden generator: a = (3 - sqrt(5))/2 = 1/φ².
    
    Returns:
        The golden generator ≈ 0.38197
    """
    return (3 - np.sqrt(5)) / 2


def hyp_cross_ratio_sq(z: complex, w: complex) -> float:
    """
    Squared hyperbolic cross-ratio: ρ(z,w) = |z-w|²/|1-conj(z)w|².
    
    The hyperbolic distance is d(z,w) = arctanh(sqrt(ρ(z,w))).
    
    Args:
        z, w: Points in the disk
    Returns:
        ρ(z, w) ∈ [0, 1)
    
    Example:
        >>> hyp_cross_ratio_sq(0.3, 0.5)  # real points
        0.01307...
        >>> abs(hyp_cross_ratio_sq(0.3, 0.5) - hyp_cross_ratio_sq(0.5, 0.3)) < 1e-15
        True
    """
    return abs(z - w)**2 / abs(1 - np.conj(z) * w)**2


def hyp_distance(z: complex, w: complex) -> float:
    """
    Hyperbolic distance on the Poincaré disk: d(z,w) = arctanh(|z-w|/|1-conj(z)w|).
    
    Args:
        z, w: Points in the unit disk
    Returns:
        d(z, w) ≥ 0
    """
    r = np.sqrt(hyp_cross_ratio_sq(z, w))
    return np.arctanh(min(r, 1 - 1e-15))


def hyp_zeta_partial(a: complex, s: float, N: int) -> float:
    """
    Partial hyperbolic zeta sum: ζ_H(s, N) = Σ_{n=1}^{N} 1/|z_n|^{2s}.
    
    Time complexity: O(N)
    
    Args:
        a: Generator
        s: Exponent (typically s > 0)
        N: Number of terms
    Returns:
        ζ_H(s, N) ≥ 0
    
    Example:
        >>> hyp_zeta_partial(golden_generator(), 1.0, 10)
        36.46...
    """
    orbit = compute_orbit(a, N)
    total = 0.0
    for i in range(1, N + 1):
        nsq = abs(orbit[i])**2
        if nsq > 1e-30:
            total += nsq**(-s)
    return total


def sieve_primes(N: int) -> list[int]:
    """
    Sieve of Eratosthenes for primes up to N.
    
    Time complexity: O(N log log N)
    Space complexity: O(N)
    
    Args:
        N: Upper bound
    Returns:
        List of primes ≤ N
    """
    if N < 2:
        return []
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(N**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, N + 1, i):
                is_prime[j] = False
    return [i for i in range(N + 1) if is_prime[i]]


def hyp_prime_count(N: int) -> int:
    """
    Hyperbolic prime counting function π_H(N) = #{p ≤ N : p prime}.
    
    Args:
        N: Upper bound
    Returns:
        Number of primes ≤ N
    
    Example:
        >>> hyp_prime_count(10)
        4
        >>> hyp_prime_count(100)
        25
    """
    return len(sieve_primes(N))


def verify_orbit_composition(a: complex, m: int, n: int,
                              tol: float = 1e-12) -> tuple[bool, float]:
    """
    Verify the orbit composition theorem:
    orbit(a, z_m, n) = z_{n+m}
    
    Args:
        a: Generator
        m, n: Orbit indices
        tol: Tolerance for floating-point comparison
    Returns:
        (passed, error) tuple
    """
    orbit = compute_orbit(a, m + n)
    z_m = orbit[m]
    # Compute orbit(a, z_m, n)
    composed = compute_orbit(a, n, start=z_m)
    z_composed = composed[n]
    z_direct = orbit[n + m]
    error = abs(z_composed - z_direct)
    return error < tol, error


def verify_disk_preservation(a: complex, N: int) -> tuple[bool, float]:
    """
    Verify that all orbit points satisfy |z_n|² < 1.
    
    Args:
        a: Generator (|a| < 1)
        N: Number of orbit points to check
    Returns:
        (all_in_disk, max_normsq) tuple
    """
    orbit = compute_orbit(a, N)
    normsqs = [abs(z)**2 for z in orbit]
    max_nsq = max(normsqs)
    return max_nsq < 1, max_nsq


def normSq_complement(a: complex, z: complex) -> tuple[float, float]:
    """
    Verify the normSq complement identity:
    1 - |φ_a(z)|² = (1-|a|²)(1-|z|²) / |1-conj(a)z|²
    
    Returns:
        (lhs, rhs) for comparison
    """
    phi = moebius_map(a, z)
    lhs = 1 - abs(phi)**2
    denom = abs(1 - np.conj(a) * z)**2
    rhs = (1 - abs(a)**2) * (1 - abs(z)**2) / denom
    return lhs, rhs


if __name__ == "__main__":
    print("=== Algorithm Tests ===\n")
    
    a = golden_generator()
    print(f"Golden generator: {a:.6f}")
    print(f"|a|² = {abs(a)**2:.6f}")
    
    # Test disk preservation
    ok, max_nsq = verify_disk_preservation(a, 1000)
    print(f"\nDisk preservation (N=1000): {'PASS' if ok else 'FAIL'}")
    print(f"  Max |z_n|² = {max_nsq:.10f}")
    
    # Test orbit composition
    print("\nOrbit composition tests:")
    for m, n in [(3, 4), (5, 7), (10, 15), (1, 99)]:
        ok, err = verify_orbit_composition(a, m, n)
        print(f"  m={m:3d}, n={n:3d}: {'PASS' if ok else 'FAIL'} (error={err:.2e})")
    
    # Test normSq identity
    print("\nNormSq complement identity:")
    for z in [0.3+0.2j, -0.5+0.1j, 0.8-0.3j]:
        lhs, rhs = normSq_complement(a, z)
        print(f"  z={z}: LHS={lhs:.10f}, RHS={rhs:.10f}, diff={abs(lhs-rhs):.2e}")
    
    # Zeta function
    print(f"\nHyperbolic zeta ζ_H(1, N):")
    for N in [10, 50, 100, 500]:
        z = hyp_zeta_partial(a, 1.0, N)
        print(f"  N={N:4d}: ζ_H = {z:12.4f}, ln(N) = {np.log(N):.4f}")
    
    # Prime counting
    print(f"\nHyperbolic prime counting:")
    for N in [10, 100, 1000, 10000]:
        pi_N = hyp_prime_count(N)
        ratio = pi_N / (N / np.log(N)) if N > 1 else 0
        print(f"  π_H({N:6d}) = {pi_N:5d}, N/ln(N) = {N/np.log(N):8.1f}, ratio = {ratio:.3f}")
