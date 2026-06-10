#!/usr/bin/env python3
"""
Hecke Eigenvalue Recursion: Core Algorithms

Type-hinted implementations of the Hecke eigenvalue recursion and
related computations for GL₂ local Hecke algebras.
"""

from typing import List, Tuple
import numpy as np


def hecke_seq(a: int, q: int, length: int) -> List[int]:
    """
    Compute the Hecke eigenvalue sequence h(0), h(1), ..., h(length-1).

    The sequence satisfies:
        h(0) = 1, h(1) = a, h(n+2) = a*h(n+1) - q*h(n)

    Args:
        a: Hecke eigenvalue (trace of Frobenius)
        q: Determinant (norm of prime)
        length: Number of terms to compute

    Returns:
        List of the first `length` values of the Hecke sequence

    Algorithm: O(n) iterative computation using the linear recurrence.
    """
    if length <= 0:
        return []
    if length == 1:
        return [1]

    h = [0] * length
    h[0] = 1
    h[1] = a
    for n in range(2, length):
        h[n] = a * h[n - 1] - q * h[n - 2]
    return h


def hecke_companion_matrix(a: int, q: int) -> np.ndarray:
    """
    Return the 2x2 Hecke companion matrix [[a, -q], [1, 0]].

    This matrix has:
        - trace = a (the Hecke eigenvalue)
        - determinant = q (the prime norm)
        - C^(n+1)[0,0] = h(n+1)

    Args:
        a: Hecke eigenvalue
        q: Determinant

    Returns:
        2x2 numpy array (object dtype for exact integer arithmetic)
    """
    return np.array([[a, -q], [1, 0]], dtype=object)


def hecke_companion_power(a: int, q: int, n: int) -> np.ndarray:
    """
    Compute C^n where C is the Hecke companion matrix, using
    binary exponentiation for O(log n) matrix multiplications.

    Args:
        a: Hecke eigenvalue
        q: Determinant
        n: Power to raise to

    Returns:
        C^n as a 2x2 numpy array (object dtype)
    """
    C = hecke_companion_matrix(a, q)
    if n == 0:
        return np.eye(2, dtype=object)
    if n == 1:
        return C.copy()

    result = np.eye(2, dtype=object)
    base = C.copy()
    while n > 0:
        if n % 2 == 1:
            result = result @ base
        base = base @ base
        n //= 2
    return result


def verify_cassini(a: int, q: int, n: int) -> Tuple[int, int, bool]:
    """
    Verify the Cassini-Hecke identity h(n+1)^2 - h(n+2)*h(n) = q^(n+1).

    Returns: (lhs, rhs, whether they match)
    """
    h = hecke_seq(a, q, n + 3)
    lhs = h[n + 1] ** 2 - h[n + 2] * h[n]
    rhs = q ** (n + 1)
    return lhs, rhs, lhs == rhs


def hecke_characteristic_poly(a: int, q: int) -> Tuple[int, int, int]:
    """
    Return coefficients of the characteristic polynomial of the
    Hecke companion matrix: X^2 - a*X + q.

    The roots α, β satisfy α + β = a, α*β = q, and
    h(n) = (α^(n+1) - β^(n+1)) / (α - β) when α ≠ β.

    Returns: (1, -a, q) representing X^2 - a*X + q
    """
    return (1, -a, q)


def hecke_discriminant(a: int, q: int) -> int:
    """
    Compute the discriminant a^2 - 4q of the Hecke characteristic polynomial.

    The Ramanujan bound |a| ≤ 2√q is equivalent to discriminant ≤ 0,
    meaning the roots are complex conjugate and lie on the circle |z| = √q.
    """
    return a * a - 4 * q


def is_ramanujan(a: float, q: float) -> bool:
    """
    Check whether the Hecke eigenvalue a satisfies the Ramanujan bound
    |a| ≤ 2√q, equivalently whether the discriminant a² - 4q ≤ 0.
    """
    return a * a <= 4 * q


def tropical_hecke_seq(a: float, q: float, length: int) -> List[float]:
    """
    Compute the tropical (min-plus) Hecke sequence:
        t(0) = 0, t(1) = a, t(n+2) = min(a + t(n+1), q + t(n))

    This is the tropicalization of the algebraic Hecke recursion,
    obtained by replacing (*, +, -) with (+, min, ∞).

    In the Ramanujan regime 2a ≤ q, t(n) = n*a (affine/linear growth).
    Outside the Ramanujan regime, growth is super-linear.
    """
    if length <= 0:
        return []
    if length == 1:
        return [0.0]
    t = [0.0] * length
    t[0] = 0.0
    t[1] = a
    for n in range(2, length):
        t[n] = min(a + t[n - 1], q + t[n - 2])
    return t


def tropical_cassini_defect(a: float, q: float, n: int) -> float:
    """
    Compute the tropical Cassini defect:
        δ(n) = 2*t(n+1) - t(n+2) - t(n) - (n+1)*q_trop

    where q_trop is the tropical determinant. In the Ramanujan regime,
    this defect vanishes identically.
    """
    t = tropical_hecke_seq(a, q, n + 3)
    return 2 * t[n + 1] - t[n + 2] - t[n]
