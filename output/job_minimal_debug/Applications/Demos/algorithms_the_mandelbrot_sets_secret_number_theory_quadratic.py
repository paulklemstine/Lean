#!/usr/bin/env python3
"""
Mandelbrot Arithmetic: Core Algorithms

Type-hinted implementations of the key algorithms from the
Mandelbrot arithmetic theory.
"""

from typing import Dict, List, Optional, Set, Tuple
from math import gcd


def qiter(c: complex, n: int) -> complex:
    """
    Compute the n-th iterate of z -> z^2 + c starting from z_0 = 0.
    
    This is the fundamental computation underlying the Mandelbrot set:
    z_0 = 0, z_{k+1} = z_k^2 + c.
    
    Complexity: O(n) multiplications.
    """
    z: complex = 0
    for _ in range(n):
        z = z * z + c
    return z


def qiter_modular(c: int, n: int, modulus: int) -> int:
    """
    Compute qiter(n, c) modulo a given modulus.
    
    Uses modular reduction at each step to prevent integer overflow.
    This is essential for studying the arithmetic Mandelbrot set
    over Z/mZ.
    
    Complexity: O(n) modular multiplications.
    """
    z: int = 0
    for _ in range(n):
        z = (z * z + c) % modulus
    return z


def find_exact_period(c: int, modulus: int) -> int:
    """
    Find the exact period of 0 under z -> z^2 + c in Z/modulus Z.
    
    Returns the smallest positive n such that qiter(n, c) ≡ 0 (mod modulus),
    or 0 if no such n exists within modulus^2 + 1 steps.
    
    Algorithm: Floyd's cycle detection adapted for the "return to zero" criterion.
    """
    z: int = 0
    for n in range(1, modulus * modulus + 2):
        z = (z * z + c) % modulus
        if z == 0:
            return n
    return 0


def arithmetic_mandelbrot_set(modulus: int) -> Dict[int, int]:
    """
    Compute the arithmetic Mandelbrot set over Z/modulus Z.
    
    Returns a dictionary mapping each c in the set to its exact period.
    A parameter c is in the arithmetic Mandelbrot set if and only if
    the orbit of 0 under z -> z^2 + c returns to 0.
    
    This is the finite-field analogue of the classical Mandelbrot set.
    """
    result: Dict[int, int] = {}
    for c in range(modulus):
        period = find_exact_period(c, modulus)
        if period > 0:
            result[c] = period
    return result


def period_spectrum(modulus: int) -> Dict[int, List[int]]:
    """
    Compute the period spectrum over Z/modulus Z.
    
    Groups parameters by their exact period, returning a dictionary
    mapping each period to the list of parameters achieving it.
    
    This is the dynatomic decomposition of the arithmetic Mandelbrot set.
    """
    spectrum: Dict[int, List[int]] = {}
    mandelbrot = arithmetic_mandelbrot_set(modulus)
    for c, period in mandelbrot.items():
        if period not in spectrum:
            spectrum[period] = []
        spectrum[period].append(c)
    return dict(sorted(spectrum.items()))


def mandelbrot_polynomial_coefficients(n: int) -> List[int]:
    """
    Compute the coefficients of the n-th Mandelbrot polynomial M_n(c).
    
    M_0 = 0, M_{n+1} = M_n^2 + c (as polynomials in c).
    Returns coefficients [a_0, a_1, ..., a_d] where M_n(c) = sum a_i c^i.
    
    The degree of M_n is 2^{n-1} for n >= 1.
    """
    if n == 0:
        return [0]
    
    # Start with M_1 = c = [0, 1]
    poly: List[int] = [0, 1]
    
    for _ in range(n - 1):
        # Square the polynomial
        deg = len(poly) - 1
        squared = [0] * (2 * deg + 1)
        for i in range(deg + 1):
            for j in range(deg + 1):
                squared[i + j] += poly[i] * poly[j]
        # Add c (add 1 to coefficient of c^1)
        while len(squared) < 2:
            squared.append(0)
        squared[1] += 1
        poly = squared
    
    return poly


def verify_orbit_shift(c: complex, d: int, max_m: int = 20) -> bool:
    """
    Verify the Orbit Shift Lemma: if qiter(d, c) = 0,
    then qiter(d + m, c) = qiter(m, c) for all m up to max_m.
    """
    if abs(qiter(c, d)) > 1e-10:
        return False
    
    for m in range(max_m):
        if abs(qiter(c, d + m) - qiter(c, m)) > 1e-10:
            return False
    return True


def verify_period_divisibility(c: complex, d: int, max_k: int = 10) -> bool:
    """
    Verify the Period Divisibility Theorem: if qiter(d, c) = 0,
    then qiter(d*k, c) = 0 for all k >= 1 up to max_k.
    """
    if abs(qiter(c, d)) > 1e-10:
        return False
    
    for k in range(1, max_k + 1):
        if abs(qiter(c, d * k)) > 1e-10:
            return False
    return True


def verify_orbit_congruence(c: int, n: int) -> Tuple[bool, int]:
    """
    Verify the Orbit Congruence Theorem: qiter(n, c) = c + c^2 * q
    for some integer q.
    
    Returns (True, q) if verified, (False, 0) otherwise.
    """
    if c == 0:
        return (True, 0)
    
    val = int(qiter(c, n).real)
    remainder = val - c
    if remainder % (c * c) != 0:
        return (False, 0)
    q = remainder // (c * c)
    return (True, q)


def dynatomic_polynomial_degree(n: int) -> int:
    """
    Compute the degree of the n-th dynatomic polynomial Φ_n(c).
    
    The degree satisfies: sum_{d|n} deg(Φ_d) = 2^{n-1} (for n >= 1).
    By Möbius inversion: deg(Φ_n) = sum_{d|n} μ(n/d) * 2^{d-1}.
    """
    if n == 0:
        return 0
    
    def mobius(m: int) -> int:
        """Compute the Möbius function μ(m)."""
        if m == 1:
            return 1
        factors = set()
        temp = m
        for p in range(2, m + 1):
            if p * p > temp:
                break
            if temp % p == 0:
                factors.add(p)
                temp //= p
                if temp % p == 0:
                    return 0
        if temp > 1:
            factors.add(temp)
        return (-1) ** len(factors)
    
    degree = 0
    for d in range(1, n + 1):
        if n % d == 0:
            degree += mobius(n // d) * (2 ** (d - 1))
    return degree


if __name__ == "__main__":
    # Quick validation
    print("Mandelbrot polynomial coefficients:")
    for n in range(6):
        coeffs = mandelbrot_polynomial_coefficients(n)
        print(f"  M_{n}: {coeffs} (degree {len(coeffs)-1})")
    
    print("\nDynatomic polynomial degrees:")
    for n in range(1, 11):
        print(f"  Φ_{n}: degree {dynatomic_polynomial_degree(n)}")
    
    print("\nArithmetic Mandelbrot sets:")
    for p in [2, 3, 5, 7, 11]:
        ms = arithmetic_mandelbrot_set(p)
        print(f"  Z/{p}Z: {ms}")
    
    print("\nPeriod spectra:")
    for p in [7, 11, 13]:
        spec = period_spectrum(p)
        print(f"  Z/{p}Z: {spec}")
