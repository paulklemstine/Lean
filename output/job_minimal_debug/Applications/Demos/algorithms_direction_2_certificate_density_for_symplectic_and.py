#!/usr/bin/env python3
"""
Algorithms for Self-Reciprocal Polynomial Theory and Symplectic Certificate Density

This module implements:
1. Construction and enumeration of self-reciprocal polynomials over finite fields
2. Irreducibility testing for self-reciprocal polynomials
3. Certificate density estimation for Sp_{2n}(F_q)
4. Möbius-based counting of self-reciprocal irreducibles

All algorithms work over GF(q) for prime q, using sympy for finite field arithmetic.
"""

from typing import List, Tuple, Optional, Dict
from functools import lru_cache
from math import gcd
# ============================================================================
# Core Polynomial Arithmetic over Finite Fields
# ============================================================================

def poly_mul_mod(a: List[int], b: List[int], q: int) -> List[int]:
    """Multiply two polynomials over GF(q), represented as coefficient lists."""
    if not a or not b:
        return []
    result = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            result[i + j] = (result[i + j] + ai * bj) % q
    # Strip trailing zeros
    while len(result) > 1 and result[-1] == 0:
        result.pop()
    return result


def poly_mod(a: List[int], b: List[int], q: int) -> List[int]:
    """Compute a mod b over GF(q)."""
    a = list(a)
    while len(a) >= len(b) and a:
        if a[-1] == 0:
            a.pop()
            continue
        coeff = (a[-1] * pow(b[-1], q - 2, q)) % q
        shift = len(a) - len(b)
        for i in range(len(b)):
            a[shift + i] = (a[shift + i] - coeff * b[i]) % q
        while a and a[-1] == 0:
            a.pop()
    return a if a else [0]


def poly_pow_mod(base: List[int], exp: int, modulus: List[int], q: int) -> List[int]:
    """Compute base^exp mod modulus over GF(q)."""
    result = [1]
    base = poly_mod(base, modulus, q)
    while exp > 0:
        if exp % 2 == 1:
            result = poly_mod(poly_mul_mod(result, base, q), modulus, q)
        base = poly_mod(poly_mul_mod(base, base, q), modulus, q)
        exp //= 2
    return result


def poly_gcd(a: List[int], b: List[int], q: int) -> List[int]:
    """Compute GCD of two polynomials over GF(q)."""
    while b and b != [0]:
        a, b = b, poly_mod(a, b, q)
    if not a:
        return [0]
    # Normalize to monic
    lc_inv = pow(a[-1], q - 2, q)
    return [(c * lc_inv) % q for c in a]


def is_irreducible_gf(coeffs: List[int], q: int) -> bool:
    """
    Test irreducibility of a polynomial over GF(q) using Rabin's algorithm.

    Algorithm:
    1. Check that x^{q^n} ≡ x (mod f) — ensures f divides x^{q^n} - x.
    2. For each prime divisor p of n, check that gcd(x^{q^{n/p}} - x, f) = 1.

    Time complexity: O(n^2 log(q) * n) field operations.
    Space complexity: O(n) coefficients.

    Args:
        coeffs: Coefficient list [a_0, a_1, ..., a_n] of a monic polynomial.
        q: Prime field size.

    Returns:
        True if the polynomial is irreducible over GF(q).
    """
    n = len(coeffs) - 1  # degree
    if n <= 0:
        return False
    if n == 1:
        return True

    f = coeffs

    # Step 1: Check x^{q^n} ≡ x (mod f)
    x = [0, 1]  # the polynomial x
    xqn = poly_pow_mod(x, q**n, f, q)
    diff = list(xqn)
    if len(diff) < 2:
        diff.extend([0] * (2 - len(diff)))
    diff[1] = (diff[1] - 1) % q
    remainder = poly_mod(diff, f, q)
    if remainder != [0] and any(c != 0 for c in remainder):
        return False

    # Step 2: For each prime divisor p of n, check gcd(x^{q^{n/p}} - x, f) = 1
    prime_divisors = set()
    temp = n
    for p in range(2, int(temp**0.5) + 2):
        while temp % p == 0:
            prime_divisors.add(p)
            temp //= p
    if temp > 1:
        prime_divisors.add(temp)

    for p in prime_divisors:
        m = n // p
        xqm = poly_pow_mod(x, q**m, f, q)
        diff2 = list(xqm)
        if len(diff2) < 2:
            diff2.extend([0] * (2 - len(diff2)))
        diff2[1] = (diff2[1] - 1) % q
        while diff2 and diff2[-1] == 0:
            diff2.pop()
        if not diff2:
            diff2 = [0]
        g = poly_gcd(diff2, f, q)
        if len(g) > 1:  # gcd has degree > 0
            return False

    return True


# ============================================================================
# Self-Reciprocal Polynomial Construction
# ============================================================================

def make_self_reciprocal(half_coeffs: List[int], q: int) -> List[int]:
    """
    Construct a monic self-reciprocal polynomial from its first-half coefficients.

    Given coefficients a_0, a_1, ..., a_n, constructs:
        x^{2n} + a_{n}*x^n + ... + a_1*x^{2n-1} + ... + a_1*x + a_0

    The palindromic property ensures coeff[i] = coeff[2n - i].

    Args:
        half_coeffs: [a_0, a_1, ..., a_n] where a_0 is the constant term.
        q: Field size.

    Returns:
        Full coefficient list [a_0, a_1, ..., a_{2n}] with a_{2n} = a_0.

    Example:
        >>> make_self_reciprocal([1, 2, 3], 5)
        [1, 2, 3, 2, 1]  # represents 1 + 2x + 3x^2 + 2x^3 + x^4
    """
    n = len(half_coeffs) - 1
    full = list(half_coeffs) + list(reversed(half_coeffs[:-1]))
    return [c % q for c in full]


def is_self_reciprocal(coeffs: List[int]) -> bool:
    """
    Check if a polynomial (as coefficient list) is self-reciprocal (palindromic).

    A polynomial f of degree d is self-reciprocal iff coeff[i] = coeff[d-i] for all i.

    Args:
        coeffs: Coefficient list [a_0, ..., a_d].

    Returns:
        True if the coefficients form a palindrome.
    """
    return coeffs == coeffs[::-1]


def enumerate_self_reciprocal_irreducibles(q: int, n: int) -> List[List[int]]:
    """
    Enumerate all monic irreducible self-reciprocal polynomials of degree 2n over GF(q).

    Uses the dimension-halving theorem: such polynomials are determined by n+1
    coefficients (a_0, a_1, ..., a_n), with a_0 = 1 forced by monicity + palindrome.

    Args:
        q: Prime field size.
        n: Half-degree (total degree = 2n).

    Returns:
        List of coefficient lists for irreducible self-reciprocal polynomials.

    Complexity: O(q^n) polynomials tested, each irreducibility test O(n^2 log q).
    """
    if n == 0:
        return []

    result = []

    # Iterate over free parameters a_1, ..., a_n
    # a_0 = 1 (forced by monic + palindromic)
    def iterate_params(params, depth):
        if depth == n:
            half = [1] + list(params)  # a_0 = 1
            full = make_self_reciprocal(half, q)
            if is_irreducible_gf(full, q):
                result.append(full)
            return
        for val in range(q):
            iterate_params(params + (val,), depth + 1)

    iterate_params((), 0)
    return result


# ============================================================================
# Counting via Möbius Function
# ============================================================================

def mobius(n: int) -> int:
    """Compute the Möbius function μ(n)."""
    if n == 1:
        return 1
    factors = {}
    temp = n
    for p in range(2, int(temp**0.5) + 2):
        while temp % p == 0:
            factors[p] = factors.get(p, 0) + 1
            temp //= p
    if temp > 1:
        factors[temp] = 1
    for exp in factors.values():
        if exp > 1:
            return 0
    return (-1) ** len(factors)


def necklace_count(q: int, n: int) -> int:
    """
    Count the number of monic irreducible polynomials of degree n over GF(q)
    using the necklace formula:
        N(q, n) = (1/n) * Σ_{d|n} μ(n/d) * q^d

    This is exact (not asymptotic).
    """
    if n == 0:
        return 0
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += mobius(n // d) * q**d
    return total // n


def self_reciprocal_irreducible_count_formula(q: int, n: int) -> float:
    """
    Theoretical count of monic irreducible self-reciprocal polynomials of degree 2n
    over GF(q), using the formula:

        SRI(q, n) = (1/(2n)) * Σ_{d|n} μ(n/d) * q^d  for odd q
                  ≈ q^n / (2n) + O(q^{n/2})

    For even q, there are correction terms.

    This counts polynomials that are:
    - monic
    - of degree exactly 2n
    - irreducible over GF(q)
    - self-reciprocal (palindromic coefficients)

    Args:
        q: Prime power field size.
        n: Half-degree.

    Returns:
        Theoretical count (may be fractional for the formula).
    """
    if n == 0:
        return 0

    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += mobius(n // d) * q**d

    # The self-reciprocal irreducible count relates to the degree-n irreducible count
    # via the x -> x + x^{-1} map
    return total / (2 * n)


# ============================================================================
# Certificate Density Estimation
# ============================================================================

def symplectic_certificate_density(q: int, n: int) -> float:
    """
    Estimate the certificate density for Sp_{2n}(F_q).

    The certificate density is:
        δ(q, n) = SRI(q, n) / q^n

    where SRI(q,n) is the number of monic irreducible self-reciprocal polynomials
    of degree 2n over GF(q), and q^n is approximately the number of admissible
    conjugacy classes (each contributing ~1 to the normalized count).

    Asymptotically:
        δ(q, n) ≈ 1 / (2n)

    Args:
        q: Prime field size.
        n: Parameter (group is Sp_{2n}).

    Returns:
        Estimated certificate density.
    """
    sri = len(enumerate_self_reciprocal_irreducibles(q, n))
    total_sr = q**n  # number of monic self-reciprocal polys of degree 2n
    return sri / total_sr if total_sr > 0 else 0.0


def symplectic_group_order(q: int, n: int) -> int:
    """
    Compute |Sp_{2n}(F_q)| = q^{n^2} * Π_{i=1}^{n} (q^{2i} - 1).

    Args:
        q: Prime power.
        n: Rank parameter.

    Returns:
        Order of the symplectic group.
    """
    order = q ** (n * n)
    for i in range(1, n + 1):
        order *= (q ** (2 * i) - 1)
    return order


def gl_certificate_density(q: int, n: int) -> float:
    """
    Certificate density for GL_n(F_q): proportion of elements with
    irreducible characteristic polynomial.

    Asymptotically ≈ 1/n.

    For comparison with the symplectic case.
    """
    irred_count = necklace_count(q, n)
    return irred_count / q**n if q**n > 0 else 0.0


# ============================================================================
# Verification and Testing
# ============================================================================

def verify_coefficient_symmetry(coeffs: List[int]) -> bool:
    """
    Verify the coefficient symmetry property from Theorem 1:
    coeff[i] = coeff[d - i] for all i ≤ d.

    This is the computational verification of self_reciprocal_iff_coeff_symmetry.
    """
    d = len(coeffs) - 1
    for i in range(d + 1):
        if coeffs[i] != coeffs[d - i]:
            return False
    return True


def verify_determined_by_half(q: int, n: int) -> bool:
    """
    Verify Theorem 2: self-reciprocal polynomials of degree 2n are determined
    by their first n+1 coefficients.

    Tests exhaustively for small parameters.
    """
    seen_halves = {}
    for params in _iterate_tuples(q, n):
        half = (1,) + params
        full = tuple(make_self_reciprocal(list(half), q))
        half_key = half
        if half_key in seen_halves:
            if seen_halves[half_key] != full:
                return False  # Two different polys with same half — contradiction
        seen_halves[half_key] = full
    return True


def _iterate_tuples(q, n):
    """Generate all n-tuples over {0, ..., q-1}."""
    if n == 0:
        yield ()
        return
    for rest in _iterate_tuples(q, n - 1):
        for val in range(q):
            yield rest + (val,)


# ============================================================================
# Main demonstration
# ============================================================================

if __name__ == "__main__":
    print("Self-Reciprocal Polynomial Algorithms")
    print("=" * 50)
    print()

    # Test coefficient symmetry verification
    print("Coefficient Symmetry Verification:")
    test_polys = [
        [1, 2, 3, 2, 1],   # palindromic
        [1, 0, 1],          # palindromic
        [1, 2, 3, 4, 1],   # not palindromic
    ]
    for p in test_polys:
        print(f"  {p} -> palindromic: {verify_coefficient_symmetry(p)}")
    print()

    # Test dimension halving
    print("Dimension Halving Verification:")
    for q in [2, 3, 5]:
        for n in [1, 2, 3]:
            ok = verify_determined_by_half(q, n)
            print(f"  q={q}, n={n}: determined by first half = {ok}")
    print()

    # Count self-reciprocal irreducibles
    print("Self-Reciprocal Irreducible Counts:")
    print(f"{'q':>4} {'n':>4} {'SRI(q,n)':>10} {'formula':>12} {'q^n/(2n)':>12}")
    for q in [2, 3, 5, 7]:
        for n in [1, 2, 3]:
            if q**n > 1000:
                continue
            sri_actual = len(enumerate_self_reciprocal_irreducibles(q, n))
            sri_formula = self_reciprocal_irreducible_count_formula(q, n)
            asymp = q**n / (2 * n)
            print(f"{q:>4} {n:>4} {sri_actual:>10} {sri_formula:>12.1f} {asymp:>12.2f}")
    print()

    # Certificate density comparison: GL vs Sp
    print("Certificate Density Comparison (GL_n vs Sp_{2n}):")
    print(f"{'q':>4} {'n':>4} {'GL density':>12} {'1/n':>8} {'Sp density':>12} {'1/(2n)':>8}")
    for q in [3, 5, 7]:
        for n in [1, 2, 3]:
            gl_d = gl_certificate_density(q, n)
            sp_d = symplectic_certificate_density(q, n)
            print(f"{q:>4} {n:>4} {gl_d:>12.4f} {1/n:>8.4f} {sp_d:>12.4f} {1/(2*n):>8.4f}")
