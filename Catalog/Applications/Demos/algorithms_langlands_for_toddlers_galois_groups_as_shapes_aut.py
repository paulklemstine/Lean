#!/usr/bin/env python3
"""
Algorithms for the GL₁ Langlands Shape-Color Dictionary.

Type-hinted implementations of the core algorithms used in the
Langlands for Toddlers formalization.
"""

from typing import List, Tuple, Dict, Optional
import math


def jacobi_symbol(a: int, n: int) -> int:
    """
    Compute the Jacobi symbol (a/n).

    Uses the law of quadratic reciprocity and reduction rules:
    1. (a/n) is multiplicative in both arguments
    2. (2/n) = (-1)^((n²-1)/8)
    3. (-1/n) = (-1)^((n-1)/2)
    4. (a/n)(n/a) = (-1)^((a-1)/2 · (n-1)/2) for odd a,n

    Args:
        a: Numerator (any integer)
        n: Denominator (positive odd integer)

    Returns:
        -1, 0, or 1

    Raises:
        ValueError: if n is not positive and odd
    """
    if n <= 0 or n % 2 == 0:
        raise ValueError(f"n must be positive and odd, got {n}")

    a = a % n
    result = 1

    while a != 0:
        # Factor out powers of 2
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result

        # Quadratic reciprocity flip
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n

    return result if n == 1 else 0


def kronecker_symbol(d: int, n: int) -> int:
    """
    Compute the Kronecker symbol (d/n), extending the Jacobi symbol
    to all integer denominators.

    This is the "color function" of the shape-color dictionary:
    for fundamental discriminant D, χ_D(n) = (D/n).

    Args:
        d: Discriminant (numerator)
        n: Evaluation point (denominator, any integer)

    Returns:
        -1, 0, or 1
    """
    if n == 0:
        return 1 if abs(d) == 1 else 0
    if n < 0:
        n = -n
        if d < 0:
            return -kronecker_symbol(d, n)
        return kronecker_symbol(d, n)
    if n == 1:
        return 1

    result = 1

    # Handle factor of 2
    while n % 2 == 0:
        n //= 2
        if d % 2 == 0:
            return 0
        if d % 8 in (3, 5):
            result = -result

    if n == 1:
        return result

    return result * jacobi_symbol(d, n)


def is_fundamental_discriminant(d: int) -> bool:
    """
    Check if d is a fundamental discriminant.

    A fundamental discriminant is either:
    - d ≡ 1 (mod 4) and d is squarefree
    - d = 4m where m is squarefree and m ≢ 1 (mod 4) and m ≠ 0

    Args:
        d: Integer to check

    Returns:
        True if d is a fundamental discriminant
    """
    if d == 0:
        return False

    def is_squarefree(n: int) -> bool:
        n = abs(n)
        if n == 0:
            return False
        p = 2
        while p * p <= n:
            if n % (p * p) == 0:
                return False
            p += 1
        return True

    if d % 4 == 1:
        return is_squarefree(d)
    if d % 4 == 0:
        m = d // 4
        return is_squarefree(m) and m % 4 != 1 and m != 0
    return False


def compute_field_discriminant(d: int) -> int:
    """
    Compute the fundamental discriminant of Q(√d) for squarefree d.

    If d ≡ 1 (mod 4), the discriminant is d.
    Otherwise, the discriminant is 4d.

    Args:
        d: Squarefree nonzero integer

    Returns:
        The fundamental discriminant D
    """
    if d % 4 == 1:
        return d
    return 4 * d


def character_sum(d: int, n: int) -> int:
    """
    Compute Σ_{a=0}^{n-1} (d/a) using the Kronecker symbol.

    For fundamental discriminant d with |d| = n, this sum is 0
    (color orthogonality).

    Args:
        d: Discriminant
        n: Modulus (sum range)

    Returns:
        The character sum
    """
    return sum(kronecker_symbol(d, a) for a in range(n))


def gauss_sum(d: int, p: int) -> complex:
    """
    Compute the Gauss sum g(χ_d) = Σ_{a=1}^{p-1} (d/a)·e^{2πia/p}.

    This is the "bridge" between multiplicative (color) and additive (shape)
    structures. Satisfies g(χ)² = χ(-1)·p.

    Args:
        d: Discriminant
        p: Odd prime

    Returns:
        The Gauss sum as a complex number
    """
    result = 0j
    for a in range(1, p):
        chi_val = jacobi_symbol(d, p) if d != 0 else jacobi_symbol(a, p)
        # For the character (·/p), use a as input
        chi_a = jacobi_symbol(a, p)
        omega = math.e ** (2j * math.pi * a / p)
        result += chi_a * omega
    return result


def find_splitting_prime(d1: int, d2: int, limit: int = 1000) -> Optional[int]:
    """
    Find a prime p where the characters χ_{d1} and χ_{d2} differ.

    By the Chebotarev density theorem, such a prime always exists
    for distinct fundamental discriminants.

    Args:
        d1: First fundamental discriminant
        d2: Second fundamental discriminant
        limit: Search limit

    Returns:
        A prime p where kronecker_symbol(d1, p) ≠ kronecker_symbol(d2, p),
        or None if not found within limit
    """
    for n in range(2, limit):
        if all(n % d != 0 for d in range(2, int(n**0.5) + 1)):  # is prime
            if n % 2 == 1:  # odd prime
                if kronecker_symbol(d1, n) != kronecker_symbol(d2, n):
                    return n
    return None


def enumerate_fundamental_discriminants(limit: int) -> List[int]:
    """
    Enumerate all fundamental discriminants D with |D| ≤ limit.

    Args:
        limit: Maximum absolute value

    Returns:
        Sorted list of fundamental discriminants
    """
    return sorted(d for d in range(-limit, limit + 1)
                  if is_fundamental_discriminant(d))


def verify_bilinear_expansion(
    a1: int, a2: int, b1: int, b2: int
) -> Tuple[int, int, bool]:
    """
    Verify the bilinear expansion:
    J(a1·a2, b1·b2) = J(a1,b1)·J(a1,b2)·J(a2,b1)·J(a2,b2)

    Args:
        a1, a2: First argument factors
        b1, b2: Second argument factors (must be odd and positive)

    Returns:
        Tuple of (LHS, RHS, match)
    """
    if b1 * b2 <= 0 or (b1 * b2) % 2 == 0:
        raise ValueError("b1 * b2 must be positive and odd")

    lhs = jacobi_symbol(a1 * a2, b1 * b2)
    rhs = (jacobi_symbol(a1, b1) * jacobi_symbol(a1, b2) *
           jacobi_symbol(a2, b1) * jacobi_symbol(a2, b2))
    return lhs, rhs, lhs == rhs


def verify_reciprocity(p: int, q: int) -> Tuple[int, int, bool]:
    """
    Verify quadratic reciprocity for odd primes p, q:
    (p/q)·(q/p) = (-1)^((p-1)/2 · (q-1)/2)

    Args:
        p, q: Distinct odd primes

    Returns:
        Tuple of (LHS, RHS, match)
    """
    lhs = jacobi_symbol(p, q) * jacobi_symbol(q, p)
    rhs = (-1) ** ((p - 1) // 2 * (q - 1) // 2)
    return lhs, rhs, lhs == rhs


if __name__ == "__main__":
    # Quick test
    print("Fundamental discriminants |D| ≤ 20:")
    print(enumerate_fundamental_discriminants(20))

    print("\nSplitting primes between D=-4 and D=8:")
    p = find_splitting_prime(-4, 8)
    print(f"  First splitting prime: {p}")
    print(f"  χ_{{-4}}({p}) = {kronecker_symbol(-4, p)}")
    print(f"  χ_8({p}) = {kronecker_symbol(8, p)}")

    print("\nBilinear expansion test:")
    for a1, a2, b1, b2 in [(3, 7, 5, 11), (-2, 5, 3, 7), (13, -4, 9, 25)]:
        lhs, rhs, ok = verify_bilinear_expansion(a1, a2, b1, b2)
        print(f"  J({a1}·{a2}, {b1}·{b2}): LHS={lhs}, RHS={rhs}, {'✓' if ok else '✗'}")
