#!/usr/bin/env python3
"""
Cyclotomic Knot Spectra — Core Algorithms

Type-hinted implementations of the key computational procedures:
1. Alexander polynomial computation
2. Cyclotomic polynomial computation
3. Spectral classification
4. OAM channel counting
5. Cyclotomic knot spectrum construction
"""

from dataclasses import dataclass
from enum import Enum
from math import gcd
from typing import Optional


class SpectralClass(Enum):
    """Classification of palindromic polynomial root geometry."""
    CRYSTALLINE = "crystalline"  # All roots on unit circle
    METALLIC = "metallic"       # Real roots present


@dataclass
class Polynomial:
    """Integer polynomial represented as coefficient list (index = degree)."""
    coeffs: list[int]

    def __post_init__(self) -> None:
        # Strip trailing zeros
        while len(self.coeffs) > 1 and self.coeffs[-1] == 0:
            self.coeffs.pop()

    @property
    def degree(self) -> int:
        return len(self.coeffs) - 1

    def eval_at(self, x: complex) -> complex:
        """Evaluate polynomial at point x using Horner's method."""
        result: complex = 0
        for c in reversed(self.coeffs):
            result = result * x + c
        return result

    def __mul__(self, other: "Polynomial") -> "Polynomial":
        """Polynomial multiplication."""
        n = len(self.coeffs) + len(other.coeffs) - 1
        result = [0] * n
        for i, a in enumerate(self.coeffs):
            for j, b in enumerate(other.coeffs):
                result[i + j] += a * b
        return Polynomial(result)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Polynomial):
            return NotImplemented
        return self.coeffs == other.coeffs

    def __repr__(self) -> str:
        terms: list[str] = []
        for i, c in enumerate(self.coeffs):
            if c == 0:
                continue
            if i == 0:
                terms.append(str(c))
            elif i == 1:
                terms.append(f"{c}X" if abs(c) != 1 else ("X" if c == 1 else "-X"))
            else:
                terms.append(f"{c}X^{i}" if abs(c) != 1 else (f"X^{i}" if c == 1 else f"-X^{i}"))
        return " + ".join(terms).replace("+ -", "- ") if terms else "0"

    def is_palindromic(self) -> bool:
        """Check if coefficients are palindromic."""
        n = len(self.coeffs)
        return all(self.coeffs[i] == self.coeffs[n - 1 - i] for i in range(n // 2))


def poly_exact_div(dividend: Polynomial, divisor: Polynomial) -> Polynomial:
    """Exact polynomial division over ℤ (assumes divisibility)."""
    out = list(dividend.coeffs)
    norm = divisor.coeffs[-1]
    dlen = len(divisor.coeffs)
    for i in range(len(out) - 1, dlen - 2, -1):
        coeff = out[i] // norm
        if coeff != 0:
            for j in range(dlen - 1):
                out[i - (dlen - 1 - j)] -= divisor.coeffs[j] * coeff
        out[i] = coeff
    return Polynomial(out[dlen - 1:])


def alexander_polynomial(n: int) -> Polynomial:
    """
    Compute Alexander polynomial of torus knot T(2,n).

    Algorithm: Direct computation of Σ_{i=0}^{n-1} (-1)^i X^i.
    Complexity: O(n) time and space.

    Args:
        n: Winding number of the torus knot (should be odd for standard form)

    Returns:
        Alexander polynomial as integer polynomial
    """
    return Polynomial([(-1)**i for i in range(n)])


def cyclotomic_polynomial(n: int) -> Polynomial:
    """
    Compute n-th cyclotomic polynomial Φ_n(X) over ℤ.

    Algorithm: Recursive division using Φ_n = (X^n - 1) / ∏_{d|n, d<n} Φ_d.
    Complexity: O(n² log n) time.

    Args:
        n: Index of cyclotomic polynomial (positive integer)

    Returns:
        Cyclotomic polynomial Φ_n(X)
    """
    if n == 1:
        return Polynomial([-1, 1])  # X - 1

    # Start with X^n - 1
    xn_minus_1 = Polynomial([-1] + [0] * (n - 1) + [1])

    # Divide by Φ_d for each proper divisor d
    for d in range(1, n):
        if n % d == 0:
            phi_d = cyclotomic_polynomial(d)
            xn_minus_1 = poly_exact_div(xn_minus_1, phi_d)

    return xn_minus_1


def euler_totient(n: int) -> int:
    """
    Compute Euler's totient function φ(n).

    Algorithm: Trial division with Euler's product formula.
    Complexity: O(√n) time.

    Args:
        n: Positive integer

    Returns:
        φ(n) = |{k : 1 ≤ k ≤ n, gcd(k,n) = 1}|
    """
    if n <= 0:
        return 0
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


def spectral_classify(b: int) -> SpectralClass:
    """
    Classify quadratic palindrome X² - bX + 1 by root geometry.

    Algorithm: Compare b² to 4 (discriminant test).
    Complexity: O(1).

    The discriminant b² - 4 determines:
    - b² < 4: complex conjugate roots on the unit circle (crystalline)
    - b² ≥ 4: real roots (metallic, includes golden ratio for b=3)

    Args:
        b: Middle coefficient of X² - bX + 1

    Returns:
        SpectralClass.CRYSTALLINE or SpectralClass.METALLIC
    """
    return SpectralClass.CRYSTALLINE if b * b < 4 else SpectralClass.METALLIC


def is_prime(n: int) -> bool:
    """Simple primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


@dataclass
class CyclotomicKnotSpectrum:
    """
    Spectral data of a T(2,n) torus knot.

    Encodes the Alexander polynomial, cyclotomic factorization structure,
    and spectral classification into a single algebraic invariant.
    """
    knot_param: int
    alexander_poly: Polynomial
    num_divisors: int
    spectral_class: SpectralClass
    is_cyclotomic: bool
    channel_count: int  # φ(knot_param)

    def __repr__(self) -> str:
        return (f"CyclotomicKnotSpectrum(T(2,{self.knot_param}), "
                f"class={self.spectral_class.value}, "
                f"channels={self.channel_count}, "
                f"cyclotomic={self.is_cyclotomic})")


def make_knot_spectrum(n: int) -> CyclotomicKnotSpectrum:
    """
    Construct the cyclotomic knot spectrum of T(2,n).

    Algorithm:
    1. Compute Alexander polynomial A_n(X)
    2. Count divisors of n
    3. Check if A_n equals Φ_{2n} (cyclotomic bridge)
    4. Classify spectral type
    5. Count OAM channels via φ(n)

    Args:
        n: Odd positive integer (winding number)

    Returns:
        CyclotomicKnotSpectrum for T(2,n)
    """
    alex = alexander_polynomial(n)

    # Count divisors
    num_div = sum(1 for d in range(1, n + 1) if n % d == 0)

    # Check cyclotomic bridge
    cyclo = cyclotomic_polynomial(2 * n)
    is_cyclo = alex == cyclo

    # Spectral classification
    spec = SpectralClass.CRYSTALLINE if n <= 5 else SpectralClass.METALLIC

    # Channel count
    channels = euler_totient(n)

    return CyclotomicKnotSpectrum(
        knot_param=n,
        alexander_poly=alex,
        num_divisors=num_div,
        spectral_class=spec,
        is_cyclotomic=is_cyclo,
        channel_count=channels,
    )


def verify_fundamental_identity(n: int) -> bool:
    """
    Verify (X+1) · A_n(X) = X^n + 1 for given n.

    Args:
        n: Odd positive integer

    Returns:
        True if identity holds
    """
    alex = alexander_polynomial(n)
    x_plus_1 = Polynomial([1, 1])
    product = alex * x_plus_1
    expected = Polynomial([1] + [0] * (n - 1) + [1])
    return product == expected


if __name__ == "__main__":
    print("Cyclotomic Knot Spectra — Algorithm Verification")
    print("=" * 50)

    # Verify fundamental identity for odd n
    for n in [3, 5, 7, 9, 11, 13, 15]:
        assert verify_fundamental_identity(n), f"Identity failed for n={n}"
    print("✓ Fundamental identity verified for n = 3,5,7,9,11,13,15")

    # Verify cyclotomic bridge for odd primes
    for p in [3, 5, 7, 11, 13]:
        alex = alexander_polynomial(p)
        cyclo = cyclotomic_polynomial(2 * p)
        assert alex == cyclo, f"Bridge failed for p={p}"
    print("✓ Cyclotomic bridge verified for p = 3,5,7,11,13")

    # Verify totient identity
    for n in range(1, 50, 2):
        assert euler_totient(2 * n) == euler_totient(n), f"Totient failed for n={n}"
    print("✓ Totient identity φ(2n)=φ(n) verified for odd n ∈ [1,49]")

    # Print knot spectra
    print("\nKnot Spectra:")
    for n in [3, 5, 7, 9, 11, 13]:
        spec = make_knot_spectrum(n)
        print(f"  {spec}")
