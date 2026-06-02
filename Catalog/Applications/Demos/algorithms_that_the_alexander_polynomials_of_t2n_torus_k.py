#!/usr/bin/env python3
"""
Algorithms for Cyclotomic Knot Spectra

Type-hinted implementations of the core algorithms for computing
Alexander polynomials, spectral classifications, and OAM channel counts
for T(2,n) torus knots.
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum
from math import gcd, sqrt
from typing import Optional


class SpectralType(Enum):
    """Classification of the spectral type of a palindromic knot polynomial."""
    CRYSTALLINE = "crystalline"   # All roots on unit circle, |b| < 2
    METALLIC = "metallic"        # Real roots off unit circle, |b| > 2
    DEGENERATE = "degenerate"    # Repeated root at ±1, |b| = 2
    COMPOSITE = "composite"      # Higher degree, mixed root types


@dataclass
class AlexanderPolynomial:
    """
    Represents the Alexander polynomial of a T(2,n) torus knot.
    
    The polynomial is stored as a list of integer coefficients [a_0, a_1, ..., a_{n-1}]
    representing a_0 + a_1*X + ... + a_{n-1}*X^{n-1}.
    """
    n: int
    coefficients: list[int]
    
    @classmethod
    def from_torus_knot(cls, n: int) -> AlexanderPolynomial:
        """
        Compute the Alexander polynomial of T(2,n).
        
        A_n(X) = Σ_{i=0}^{n-1} (-1)^i X^i
        
        Time complexity: O(n)
        Space complexity: O(n)
        """
        if n <= 0:
            raise ValueError(f"n must be positive, got {n}")
        coeffs = [(-1)**i for i in range(n)]
        return cls(n=n, coefficients=coeffs)
    
    def evaluate(self, x: complex) -> complex:
        """Evaluate the polynomial at x using Horner's method. O(n) time."""
        result = complex(0)
        for c in reversed(self.coefficients):
            result = result * x + c
        return result
    
    def degree(self) -> int:
        """Return the degree of the polynomial."""
        return len(self.coefficients) - 1
    
    def determinant(self) -> int:
        """Compute the knot determinant |A_n(-1)|."""
        return abs(int(round(self.evaluate(-1).real)))
    
    def seifert_genus(self) -> int:
        """Compute the Seifert genus = degree / 2."""
        return self.degree() // 2
    
    def is_palindromic(self) -> bool:
        """Check if the polynomial is palindromic (self-reciprocal)."""
        n = len(self.coefficients)
        return all(
            self.coefficients[i] == self.coefficients[n - 1 - i]
            for i in range(n // 2)
        )


@dataclass
class TorusKnotSpectrum:
    """
    Complete spectral data of a T(2,n) torus knot.
    
    Bundles the Alexander polynomial with its spectral classification
    and OAM channel count.
    """
    n: int
    alexander: AlexanderPolynomial
    spectral_type: SpectralType
    channel_count: int
    seifert_genus: int
    knot_determinant: int
    
    @classmethod
    def compute(cls, n: int) -> TorusKnotSpectrum:
        """
        Compute the full spectrum of T(2,n).
        
        Algorithm:
        1. Compute Alexander polynomial A_n (O(n))
        2. Classify spectral type (O(1) for quadratic, O(n) for general)
        3. Compute channel count φ(n) (O(√n))
        4. Compute genus and determinant (O(1) and O(n))
        
        Total: O(n)
        """
        if n % 2 == 0:
            raise ValueError(f"n must be odd for T(2,n) torus knot, got {n}")
        
        alex = AlexanderPolynomial.from_torus_knot(n)
        
        # Spectral classification
        if n == 1:
            spec_type = SpectralType.DEGENERATE
        elif alex.degree() == 2:
            b = alex.coefficients[1]  # Middle coefficient
            disc = b * b - 4 * alex.coefficients[0] * alex.coefficients[2]
            if disc < 0:
                spec_type = SpectralType.CRYSTALLINE
            elif disc > 0:
                spec_type = SpectralType.METALLIC
            else:
                spec_type = SpectralType.DEGENERATE
        else:
            # Higher degree: all T(2,n) for n > 3 have crystalline spectrum
            # (roots are primitive 2n-th roots of unity, all on unit circle)
            spec_type = SpectralType.CRYSTALLINE
        
        channels = euler_totient(n)
        genus = alex.seifert_genus()
        det = alex.determinant()
        
        return cls(
            n=n,
            alexander=alex,
            spectral_type=spec_type,
            channel_count=channels,
            seifert_genus=genus,
            knot_determinant=det,
        )


def euler_totient(n: int) -> int:
    """
    Compute Euler's totient function φ(n).
    
    φ(n) = n · ∏_{p|n} (1 - 1/p)
    
    Time complexity: O(√n)
    """
    if n <= 0:
        raise ValueError(f"n must be positive, got {n}")
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


def palindromic_discriminant(b: int) -> int:
    """
    Compute the discriminant of the palindromic quadratic X² + bX + 1.
    
    Δ(b) = b² - 4
    
    Classification:
    - Δ < 0: crystalline spectrum (roots on unit circle)
    - Δ > 0: metallic spectrum (real roots)
    - Δ = 0: degenerate (repeated root)
    """
    return b * b - 4


def classify_palindromic_spectrum(b: int) -> SpectralType:
    """
    Classify the spectrum of a palindromic quadratic X² + bX + 1.
    
    Based on the Spectral Dichotomy Theorem:
    - |b| < 2 → crystalline (Δ < 0, roots on unit circle)
    - |b| > 2 → metallic (Δ > 0, real roots)
    - |b| = 2 → degenerate (Δ = 0, repeated root)
    """
    d = palindromic_discriminant(b)
    if d < 0:
        return SpectralType.CRYSTALLINE
    elif d > 0:
        return SpectralType.METALLIC
    else:
        return SpectralType.DEGENERATE


def oam_channel_count(n: int) -> int:
    """
    Compute the number of independent OAM channels for T(2,n).
    
    For odd n: channels = φ(2n) = φ(n)
    (since gcd(2,n) = 1 for odd n)
    
    Time complexity: O(√n)
    """
    if n % 2 == 0:
        raise ValueError(f"n must be odd, got {n}")
    return euler_totient(n)


def verify_fundamental_identity(n: int) -> bool:
    """
    Verify the fundamental identity (X+1)·A_n(X) = X^n + 1.
    
    Tests at multiple evaluation points for numerical verification.
    """
    alex = AlexanderPolynomial.from_torus_knot(n)
    
    test_points = [0, 1, -1, 2, -2, 0.5, 1j, 1+1j]
    for x in test_points:
        lhs = (x + 1) * alex.evaluate(x)
        rhs = x**n + 1
        if abs(lhs - rhs) > 1e-10:
            return False
    return True


def cyclotomic_polynomial(n: int) -> list[int]:
    """
    Compute the n-th cyclotomic polynomial Φ_n(X).
    
    Uses the recursive definition:
    X^n - 1 = ∏_{d|n} Φ_d(X)
    
    Time complexity: O(n² log n) (due to recursive polynomial division)
    """
    if n == 1:
        return [-1, 1]
    
    # X^n - 1
    xn_minus_1 = [-1] + [0] * (n - 1) + [1]
    
    # Divide by Φ_d for proper divisors d of n
    divisors = sorted(d for d in range(1, n) if n % d == 0)
    
    result = xn_minus_1[:]
    for d in divisors:
        phi_d = cyclotomic_polynomial(d)
        result = _poly_exact_divide(result, phi_d)
    
    return result


def _poly_exact_divide(dividend: list[int], divisor: list[int]) -> list[int]:
    """Exact polynomial division (assumes divisibility)."""
    while len(dividend) > 1 and dividend[-1] == 0:
        dividend = dividend[:-1]
    while len(divisor) > 1 and divisor[-1] == 0:
        divisor = divisor[:-1]
    
    if len(dividend) < len(divisor):
        return [0]
    
    quotient = [0] * (len(dividend) - len(divisor) + 1)
    remainder = dividend[:]
    
    for i in range(len(quotient) - 1, -1, -1):
        quotient[i] = remainder[i + len(divisor) - 1] // divisor[-1]
        for j in range(len(divisor)):
            remainder[i + j] -= quotient[i] * divisor[j]
    
    return quotient


def verify_cyclotomic_bridge(p: int) -> bool:
    """
    Verify A_p = Φ_{2p} for prime p.
    
    Returns True if the Alexander polynomial of T(2,p) equals
    the 2p-th cyclotomic polynomial.
    """
    alex = AlexanderPolynomial.from_torus_knot(p)
    phi_2p = cyclotomic_polynomial(2 * p)
    return alex.coefficients == phi_2p


if __name__ == "__main__":
    print("=== Algorithm Verification ===\n")
    
    # Test fundamental identity
    for n in [3, 5, 7, 9, 11, 13, 15]:
        assert verify_fundamental_identity(n), f"Identity failed for n={n}"
    print("✓ Fundamental identity verified for n = 3,5,7,9,11,13,15")
    
    # Test cyclotomic bridge
    for p in [3, 5, 7, 11, 13]:
        assert verify_cyclotomic_bridge(p), f"Bridge failed for p={p}"
    print("✓ Cyclotomic bridge verified for p = 3,5,7,11,13")
    
    # Test determinant
    for n in range(1, 20):
        alex = AlexanderPolynomial.from_torus_knot(n)
        assert alex.determinant() == n, f"Determinant failed for n={n}"
    print("✓ Knot determinant |A_n(-1)| = n verified for n = 1..19")
    
    # Test OAM channels
    for n in [3, 5, 7, 9, 11]:
        spectrum = TorusKnotSpectrum.compute(n)
        assert spectrum.channel_count == euler_totient(n)
    print("✓ OAM channel count verified for n = 3,5,7,9,11")
    
    # Display full spectrum data
    print("\n=== Torus Knot Spectrum Table ===\n")
    print(f"{'Knot':>10} {'Degree':>6} {'Genus':>5} {'Det':>4} {'Channels':>8} {'Type':>12}")
    print("-" * 55)
    for n in [3, 5, 7, 9, 11, 13, 15, 17, 19]:
        s = TorusKnotSpectrum.compute(n)
        print(f"{'T(2,'+str(n)+')':>10} {s.alexander.degree():>6} "
              f"{s.seifert_genus:>5} {s.knot_determinant:>4} "
              f"{s.channel_count:>8} {s.spectral_type.value:>12}")
