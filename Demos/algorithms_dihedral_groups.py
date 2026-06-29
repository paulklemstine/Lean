#!/usr/bin/env python3
"""
Algorithms for Dihedral-Cyclotomic Computations

Implements core algorithms from the research on real cyclotomic subfields
and dihedral symmetry in number fields.
"""

import numpy as np
from typing import List, Tuple
from math import gcd


def euler_totient(n: int) -> int:
    """Compute Euler's totient function φ(n).

    Args:
        n: A positive integer.

    Returns:
        The number of integers in [1, n] coprime to n.

    Time complexity: O(n)
    Space complexity: O(1)

    >>> euler_totient(7)
    6
    >>> euler_totient(12)
    4
    """
    return sum(1 for k in range(1, n + 1) if gcd(k, n) == 1)


def real_cyclotomic_generator(n: int) -> complex:
    """Compute α_n = ζ_n + ζ_n⁻¹ = 2·cos(2π/n).

    This is the generator of the maximal real subfield ℚ(α_n) ⊂ ℚ(ζ_n).

    Args:
        n: The order of the root of unity (n ≥ 1).

    Returns:
        The complex number 2·cos(2π/n) (real-valued).

    >>> abs(real_cyclotomic_generator(4)) < 1e-10
    True
    >>> abs(real_cyclotomic_generator(3) - (-1.0)) < 1e-10
    True
    >>> abs(real_cyclotomic_generator(6) - 1.0) < 1e-10
    True
    """
    return 2 * np.cos(2 * np.pi / n)


def chebyshev_power_sum(alpha: float, k: int) -> float:
    """Compute ζ^k + ζ^{-k} as a polynomial in α = ζ + ζ⁻¹.

    Uses the Chebyshev recurrence:
        T_0(α) = 2
        T_1(α) = α
        T_k(α) = α · T_{k-1}(α) - T_{k-2}(α)

    This is the "power-sum Chebyshev" relation, not the standard
    Chebyshev polynomial (which uses cos).

    Args:
        alpha: The value ζ + ζ⁻¹.
        k: The power (non-negative integer).

    Returns:
        The value ζ^k + ζ^{-k}.

    Time complexity: O(k)
    Space complexity: O(1)

    >>> chebyshev_power_sum(2 * np.cos(2 * np.pi / 7), 0)
    2.0
    >>> abs(chebyshev_power_sum(2 * np.cos(2 * np.pi / 7), 7) - 2.0) < 1e-10
    True
    """
    if k == 0:
        return 2.0
    if k == 1:
        return alpha
    t_prev2 = 2.0
    t_prev1 = alpha
    for _ in range(2, k + 1):
        t_curr = alpha * t_prev1 - t_prev2
        t_prev2 = t_prev1
        t_prev1 = t_curr
    return t_prev1


def minimal_polynomial_real_generator(n: int) -> List[float]:
    """Compute the minimal polynomial of 2·cos(2π/n) over ℚ (approximately).

    The roots of this polynomial are {2·cos(2πk/n) : gcd(k,n) = 1, 1 ≤ k ≤ n/2}.

    Args:
        n: A positive integer ≥ 3.

    Returns:
        Coefficients [a_0, a_1, ..., a_d] of the minimal polynomial
        a_0 + a_1·x + ... + a_d·x^d (approximately, as floats).

    Time complexity: O(φ(n)²)
    Space complexity: O(φ(n))
    """
    # Find roots: 2·cos(2πk/n) for k coprime to n, 1 ≤ k ≤ n//2
    roots = []
    for k in range(1, n):
        if gcd(k, n) == 1:
            root = 2 * np.cos(2 * np.pi * k / n)
            # Only take k ≤ n/2 (since cos is symmetric, we'd get duplicates)
            # Actually for the minimal polynomial we want all conjugates
            # which are 2cos(2πk/n) for k coprime to n, k in [1, n//2]
            pass
    roots = []
    seen = set()
    for k in range(1, n):
        if gcd(k, n) == 1:
            val = round(2 * np.cos(2 * np.pi * k / n), 12)
            if val not in seen:
                roots.append(2 * np.cos(2 * np.pi * k / n))
                seen.add(val)

    # Build polynomial from roots
    poly = np.array([1.0])
    for r in roots:
        # Multiply by (x - r)
        new_poly = np.zeros(len(poly) + 1)
        for i, c in enumerate(poly):
            new_poly[i + 1] += c
            new_poly[i] -= c * r
        poly = new_poly

    # Round to nearest integers (these polynomials have integer coefficients)
    int_coeffs = [round(c) for c in poly]
    return int_coeffs


def galois_automorphisms(n: int) -> List[int]:
    """Return the Galois group (ℤ/nℤ)× as a list of exponents.

    These correspond to the automorphisms σ_k: ζ ↦ ζ^k of ℚ(ζ_n).

    Args:
        n: A positive integer.

    Returns:
        Sorted list of integers k with 1 ≤ k < n and gcd(k, n) = 1.

    >>> galois_automorphisms(7)
    [1, 2, 3, 4, 5, 6]
    >>> galois_automorphisms(8)
    [1, 3, 5, 7]
    """
    return sorted(k for k in range(1, n) if gcd(k, n) == 1)


def inversion_orbits(n: int) -> List[Tuple[int, int]]:
    """Compute the orbits of the inversion map k ↦ -k (mod n) on (ℤ/nℤ)×.

    Each orbit {k, n-k} corresponds to a pair of roots ζ^k, ζ^{-k} that
    get swapped by complex conjugation. The orbit representative gives
    the real generator ζ^k + ζ^{-k}.

    Args:
        n: A positive integer ≥ 3.

    Returns:
        List of (k, n-k) pairs with k < n-k, representing inversion orbits.

    >>> inversion_orbits(7)
    [(1, 6), (2, 5), (3, 4)]
    """
    G = galois_automorphisms(n)
    orbits = []
    used = set()
    for k in G:
        if k not in used:
            partner = n - k
            if partner != k:
                orbits.append((min(k, partner), max(k, partner)))
                used.add(k)
                used.add(partner)
            else:
                # k = n/2, self-paired (only when n is even)
                orbits.append((k, k))
                used.add(k)
    return orbits


def verify_quadratic_relation(n: int) -> float:
    """Verify the quadratic relation ζ² - (ζ+ζ⁻¹)·ζ + 1 = 0.

    Args:
        n: Order of the root of unity.

    Returns:
        The absolute value of the residual (should be ~0).

    >>> verify_quadratic_relation(7) < 1e-14
    True
    """
    z = np.exp(2j * np.pi / n)
    alpha = z + 1/z
    residual = z**2 - alpha * z + 1
    return abs(residual)


def field_tower_degrees(n: int) -> dict:
    """Compute the degrees in the tower ℚ ⊂ ℚ(ζ+ζ⁻¹) ⊂ ℚ(ζ).

    Args:
        n: A positive integer ≥ 3.

    Returns:
        Dictionary with keys:
        - 'phi_n': Euler's totient φ(n) = [ℚ(ζ):ℚ]
        - 'real_degree': φ(n)/2 = [ℚ(ζ+ζ⁻¹):ℚ]
        - 'quadratic_index': 2 = [ℚ(ζ):ℚ(ζ+ζ⁻¹)]

    >>> field_tower_degrees(7)
    {'phi_n': 6, 'real_degree': 3, 'quadratic_index': 2}
    """
    phi = euler_totient(n)
    return {
        'phi_n': phi,
        'real_degree': phi // 2,
        'quadratic_index': 2,
    }


if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)

    print("\n--- Chebyshev Power Sums ---")
    n = 7
    alpha = real_cyclotomic_generator(n)
    print(f"n={n}, α = 2cos(2π/{n}) = {alpha:.8f}")
    for k in range(8):
        ps = chebyshev_power_sum(alpha, k)
        print(f"  ζ^{k} + ζ^{{-{k}}} = T_{k}(α) = {ps:+.8f}")

    print("\n--- Minimal Polynomials of 2cos(2π/n) ---")
    for n in [3, 4, 5, 7, 8, 11, 12, 13]:
        coeffs = minimal_polynomial_real_generator(n)
        terms = []
        for i, c in enumerate(coeffs):
            if c != 0:
                if i == 0:
                    terms.append(f"{c}")
                elif i == 1:
                    terms.append(f"{c}x")
                else:
                    terms.append(f"{c}x^{i}")
        poly_str = " + ".join(terms).replace("+ -", "- ")
        deg = euler_totient(n) // 2
        print(f"  n={n:2d}: degree {deg}, p(x) = {poly_str}")

    print("\n--- Inversion Orbits ---")
    for n in [5, 7, 8, 12]:
        orbits = inversion_orbits(n)
        print(f"  n={n:2d}: orbits = {orbits}")

    print("\n--- Quadratic Relation Verification ---")
    for n in range(3, 20):
        res = verify_quadratic_relation(n)
        print(f"  n={n:2d}: |ζ² - αζ + 1| = {res:.2e}")

    print("\n--- Field Tower Degrees ---")
    for n in [3, 4, 5, 7, 8, 11, 12, 13, 15, 20, 24]:
        d = field_tower_degrees(n)
        print(f"  n={n:2d}: [ℚ(ζ):ℚ] = {d['phi_n']}, "
              f"[ℚ(α):ℚ] = {d['real_degree']}, "
              f"[ℚ(ζ):ℚ(α)] = {d['quadratic_index']}")
