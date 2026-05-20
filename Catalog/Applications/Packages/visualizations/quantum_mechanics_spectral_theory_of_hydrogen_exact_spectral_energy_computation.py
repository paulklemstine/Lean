#!/usr/bin/env python3
"""
Algorithms for Hydrogen Atom Spectral Theory

Implements computational algorithms for:
1. Energy level computation with arbitrary precision
2. Spectral series wavelength prediction
3. Degeneracy enumeration
4. Transition rate estimation
5. Basel problem partial sum computation
"""

import math
from typing import List, Tuple, Dict, Optional
from fractions import Fraction


def hydrogen_energy_exact(n: int) -> Fraction:
    """Compute E_n = -1/n² as an exact rational number.
    
    Time complexity: O(1)
    Space complexity: O(1)
    
    Args:
        n: Principal quantum number (≥ 1)
    
    Returns:
        Exact rational energy -1/n²
    
    >>> hydrogen_energy_exact(1)
    Fraction(-1, 1)
    >>> hydrogen_energy_exact(2)
    Fraction(-1, 4)
    """
    assert n >= 1
    return Fraction(-1, n * n)


def photon_energy_exact(n_lower: int, n_upper: int) -> Fraction:
    """Compute the Rydberg formula exactly as a rational number.
    
    ΔE = 1/n_lower² - 1/n_upper²
    
    Time complexity: O(1) 
    Space complexity: O(1)
    
    >>> photon_energy_exact(1, 2)
    Fraction(3, 4)
    >>> photon_energy_exact(2, 3)
    Fraction(5, 36)
    >>> photon_energy_exact(3, 4)
    Fraction(7, 144)
    """
    assert 1 <= n_lower < n_upper
    return Fraction(1, n_lower**2) - Fraction(1, n_upper**2)


def spectral_gap_exact(n: int) -> Fraction:
    """Compute the spectral gap between levels n and n+1 exactly.
    
    gap(n) = (2n+1) / (n²(n+1)²)
    
    Time complexity: O(1)
    Space complexity: O(1)
    
    >>> spectral_gap_exact(1)
    Fraction(3, 4)
    >>> spectral_gap_exact(2)
    Fraction(5, 36)
    """
    assert n >= 1
    return Fraction(2*n + 1, n**2 * (n+1)**2)


def spectral_gap_ratio_exact(n: int) -> Fraction:
    """Compute gap(n)/gap(n+1) exactly.
    
    >>> spectral_gap_ratio_exact(1)
    Fraction(27, 5)
    >>> spectral_gap_ratio_exact(2)
    Fraction(20, 7)
    """
    return spectral_gap_exact(n) / spectral_gap_exact(n + 1)


def enumerate_quantum_states(n: int) -> List[Tuple[int, int, int]]:
    """Enumerate all valid quantum states (n, l, m) for a given n.
    
    Time complexity: O(n²)
    Space complexity: O(n²)
    
    Args:
        n: Principal quantum number
    
    Returns:
        List of (n, l, m) triples
    
    >>> len(enumerate_quantum_states(1))
    1
    >>> len(enumerate_quantum_states(3))
    9
    """
    states = []
    for l in range(n):
        for m in range(-l, l + 1):
            states.append((n, l, m))
    return states


def degeneracy_sum(n: int) -> int:
    """Compute n² as sum of odd numbers: Σ_{l=0}^{n-1} (2l+1).
    
    This is the formally verified identity from hydrogen_degeneracy.
    
    Time complexity: O(n)
    Space complexity: O(1)
    
    >>> degeneracy_sum(1)
    1
    >>> degeneracy_sum(4)
    16
    """
    return sum(2*l + 1 for l in range(n))


def total_states_up_to(N: int) -> int:
    """Total states from level 1 to N: N(N+1)(2N+1)/6.
    
    Formally verified in hydrogen_total_states.
    
    >>> total_states_up_to(3)
    14
    >>> total_states_up_to(5)
    55
    """
    return N * (N + 1) * (2 * N + 1) // 6


def energy_partial_sum_exact(n: int) -> Fraction:
    """Compute Σ_{k=1}^{n} 1/k² as exact rational.
    
    This partial sum converges to π²/6 (Basel problem).
    Formally verified bound: Σ ≤ 2 - 1/n.
    
    Time complexity: O(n)
    Space complexity: O(1)
    
    >>> energy_partial_sum_exact(1)
    Fraction(1, 1)
    >>> energy_partial_sum_exact(3)
    Fraction(49, 36)
    """
    return sum(Fraction(1, k**2) for k in range(1, n + 1))


def verify_telescoping_bound(n: int) -> bool:
    """Verify the formally proved bound: Σ_{k=1}^{n} 1/k² ≤ 2 - 1/n.
    
    >>> all(verify_telescoping_bound(n) for n in range(1, 100))
    True
    """
    if n < 1:
        return False
    partial = energy_partial_sum_exact(n)
    bound = Fraction(2) - Fraction(1, n)
    return partial <= bound


def spectral_series_wavelengths(n_final: int, count: int = 10,
                                 R_inf: float = 1.097373e7) -> List[Dict]:
    """Compute wavelengths for a spectral series.
    
    Args:
        n_final: Lower level of the series
        count: Number of transitions to compute
        R_inf: Rydberg constant in m⁻¹
    
    Returns:
        List of dicts with transition info
    
    >>> ws = spectral_series_wavelengths(2, count=3)
    >>> abs(ws[0]['wavelength_nm'] - 656.3) < 1.0
    True
    """
    results = []
    for k in range(count):
        n_upper = n_final + k + 1
        energy = photon_energy_exact(n_final, n_upper)
        wavelength_m = 1.0 / (R_inf * float(energy))
        results.append({
            'n_lower': n_final,
            'n_upper': n_upper,
            'energy_exact': energy,
            'energy_float': float(energy),
            'wavelength_nm': wavelength_m * 1e9,
        })
    return results


def azimuthal_selection_check(m: int, m_prime: int) -> Dict:
    """Check dipole selection rules for given m, m'.
    
    Returns dict with allowed polarizations.
    
    >>> azimuthal_selection_check(0, 1)['allowed']
    True
    >>> azimuthal_selection_check(0, 3)['allowed']
    False
    """
    delta_m = m_prime - m
    allowed_q = []
    if delta_m == 0:
        allowed_q.append(('z-polarized', 0))
    if delta_m == 1:
        allowed_q.append(('σ⁺', 1))
    if delta_m == -1:
        allowed_q.append(('σ⁻', -1))
    
    return {
        'm': m,
        'm_prime': m_prime,
        'delta_m': delta_m,
        'allowed': len(allowed_q) > 0,
        'polarizations': allowed_q,
    }


if __name__ == "__main__":
    import doctest
    results = doctest.testmod(verbose=False)
    print(f"Doctest results: {results.attempted} tests, {results.failed} failures")
    
    # Demonstrate exact arithmetic
    print("\n--- Exact Spectral Energies ---")
    for n1, n2 in [(1,2), (1,3), (2,3), (2,4), (3,4)]:
        E = photon_energy_exact(n1, n2)
        print(f"  n={n1} → n={n2}: ΔE = {E} = {float(E):.10f}")
    
    # Demonstrate gap ratios
    print("\n--- Spectral Gap Ratios (exact) ---")
    for n in range(1, 6):
        r = spectral_gap_ratio_exact(n)
        print(f"  gap({n})/gap({n+1}) = {r} ≈ {float(r):.6f}")
    
    # Basel connection
    print("\n--- Basel Problem Connection ---")
    for n in [10, 50, 100, 1000]:
        s = energy_partial_sum_exact(n)
        bound = Fraction(2) - Fraction(1, n)
        gap = math.pi**2/6 - float(s)
        print(f"  Σ_{'{k=1}'}^{n:4d} 1/k² = {float(s):.10f}  "
              f"bound: {float(bound):.10f}  gap to π²/6: {gap:.2e}")
