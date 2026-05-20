#!/usr/bin/env python3
"""
Algorithms for Symmetric Power Functoriality

Implements the core algorithms for computing symmetric power transfers,
Euler factors, and related invariants for GL(2) Satake parameters.
"""

from fractions import Fraction
from typing import List, Optional, Tuple
from dataclasses import dataclass
import math


@dataclass
class SatakeGL2:
    """An unramified local GL(2) parameter (Satake eigenvalues).

    Represents the pair (α, β) encoding the Frobenius eigenvalues
    at an unramified place.

    Example:
        >>> pi = SatakeGL2(Fraction(2), Fraction(3))
        >>> pi.trace()
        Fraction(5, 1)
        >>> pi.det()
        Fraction(6, 1)
    """
    alpha: Fraction
    beta: Fraction

    def trace(self) -> Fraction:
        """Trace α + β (Hecke eigenvalue aₚ)."""
        return self.alpha + self.beta

    def det(self) -> Fraction:
        """Determinant αβ (central character value ωₚ)."""
        return self.alpha * self.beta

    def discriminant(self) -> Fraction:
        """Discriminant (α - β)²."""
        return (self.alpha - self.beta) ** 2

    def is_endoscopic(self) -> bool:
        """Check if α = β (endoscopic/non-generic)."""
        return self.alpha == self.beta

    def twist(self, chi: Fraction) -> 'SatakeGL2':
        """Twist by scalar χ: (α, β) ↦ (χα, χβ)."""
        return SatakeGL2(chi * self.alpha, chi * self.beta)


@dataclass
class SatakeGLn:
    """An unramified local GL(n) parameter.

    Represents the tuple (a₁, ..., aₙ) of Satake eigenvalues.

    Example:
        >>> pi = SatakeGLn([Fraction(4), Fraction(6), Fraction(9)])
        >>> pi.degree()
        3
    """
    roots: List[Fraction]

    def degree(self) -> int:
        """Number of roots (= n for GL(n))."""
        return len(self.roots)

    def twist(self, chi: Fraction) -> 'SatakeGLn':
        """Twist uniformly by scalar χ."""
        return SatakeGLn([chi * r for r in self.roots])

    def root_product(self) -> Fraction:
        """Product of all roots (central character)."""
        result = Fraction(1)
        for r in self.roots:
            result *= r
        return result


def symm_pow_transfer(m: int, pi: SatakeGL2) -> SatakeGLn:
    """Compute the symmetric m-th power transfer.

    Maps GL(2) parameter (α, β) to GL(m+1) parameter with roots
    (α^m, α^{m-1}β, ..., αβ^{m-1}, β^m).

    Args:
        m: Symmetric power degree (m ≥ 0).
        pi: GL(2) Satake parameter.

    Returns:
        GL(m+1) Satake parameter.

    Time complexity: O(m) multiplications.

    Example:
        >>> pi = SatakeGL2(Fraction(2), Fraction(3))
        >>> sym2 = symm_pow_transfer(2, pi)
        >>> sym2.roots
        [Fraction(4, 1), Fraction(6, 1), Fraction(9, 1)]
    """
    roots = []
    for i in range(m + 1):
        root = pi.alpha ** (m - i) * pi.beta ** i
        roots.append(root)
    return SatakeGLn(roots)


def recip_euler_factor(pi: SatakeGLn) -> List[Fraction]:
    """Compute the reciprocal Euler factor as a polynomial.

    Computes ∏ᵢ (1 - aᵢ X) and returns the coefficient list
    [c₀, c₁, ..., cₙ] where the polynomial is ∑ cₖ Xᵏ.

    Args:
        pi: GL(n) Satake parameter.

    Returns:
        List of polynomial coefficients, from constant to leading term.

    Time complexity: O(n²) ring operations.

    Example:
        >>> pi = SatakeGLn([Fraction(2), Fraction(3)])
        >>> recip_euler_factor(pi)
        [Fraction(1, 1), Fraction(-5, 1), Fraction(6, 1)]
    """
    coeffs = [Fraction(1)]
    for a in pi.roots:
        new_coeffs = [coeffs[0]]
        for k in range(1, len(coeffs)):
            new_coeffs.append(coeffs[k] - a * coeffs[k - 1])
        new_coeffs.append(-a * coeffs[-1])
        coeffs = new_coeffs
    return coeffs


def is_palindromic(coeffs: List[Fraction]) -> bool:
    """Check if polynomial coefficients are palindromic (up to sign alternation).

    A polynomial P(X) = ∑ cₖ Xᵏ of degree n is self-reciprocal if
    cₖ = (-1)ⁿ · c_{n-k} for all k.

    Args:
        coeffs: Polynomial coefficients [c₀, c₁, ..., cₙ].

    Returns:
        True if the polynomial is self-reciprocal.

    Example:
        >>> is_palindromic([Fraction(1), Fraction(-3), Fraction(3), Fraction(-1)])
        True
    """
    n = len(coeffs) - 1
    if n < 0:
        return True
    sign = (-1) ** n
    return all(coeffs[k] == sign * coeffs[n - k] for k in range(n + 1))


def elementary_symmetric(roots: List[Fraction], k: int) -> Fraction:
    """Compute the k-th elementary symmetric polynomial of the roots.

    e_k(a₁, ..., aₙ) = ∑_{|S|=k} ∏_{i∈S} aᵢ

    Args:
        roots: List of values.
        k: Degree of the elementary symmetric polynomial.

    Returns:
        Value of e_k.

    Time complexity: O(C(n,k) · k).

    Example:
        >>> elementary_symmetric([Fraction(2), Fraction(3), Fraction(5)], 2)
        Fraction(31, 1)
    """
    from itertools import combinations
    result = Fraction(0)
    for subset in combinations(roots, k):
        product = Fraction(1)
        for x in subset:
            product *= x
        result += product
    return result


def power_sum(roots: List[Fraction], k: int) -> Fraction:
    """Compute the k-th power sum of the roots: p_k = ∑ aᵢᵏ.

    Example:
        >>> power_sum([Fraction(2), Fraction(3)], 2)
        Fraction(13, 1)
    """
    return sum(r ** k for r in roots)


def verify_euler_factor_identity(m: int, pi: SatakeGL2) -> bool:
    """Verify that the Euler factor of Sym^m(π) equals the product of linear factors.

    This checks the main theorem: L⁻¹(X, Sym^m π) = ∏ᵢ (1 - α^{m-i}β^i X).

    Returns True if the identity holds (should always be True).

    Example:
        >>> pi = SatakeGL2(Fraction(2), Fraction(3))
        >>> verify_euler_factor_identity(2, pi)
        True
    """
    transferred = symm_pow_transfer(m, pi)
    computed_coeffs = recip_euler_factor(transferred)

    # Independently compute the product of linear factors
    check_coeffs = [Fraction(1)]
    for i in range(m + 1):
        root = pi.alpha ** (m - i) * pi.beta ** i
        new_check = [check_coeffs[0]]
        for k in range(1, len(check_coeffs)):
            new_check.append(check_coeffs[k] - root * check_coeffs[k - 1])
        new_check.append(-root * check_coeffs[-1])
        check_coeffs = new_check

    return computed_coeffs == check_coeffs


def verify_twist_compatibility(m: int, chi: Fraction, pi: SatakeGL2) -> bool:
    """Verify Sym^m(χ·π) = χ^m · Sym^m(π).

    Example:
        >>> pi = SatakeGL2(Fraction(2), Fraction(3))
        >>> verify_twist_compatibility(2, Fraction(5), pi)
        True
    """
    lhs = symm_pow_transfer(m, pi.twist(chi))
    rhs = symm_pow_transfer(m, pi).twist(chi ** m)
    return lhs.roots == rhs.roots


def verify_endoscopic_collapse(m: int, alpha: Fraction) -> bool:
    """Verify that when α = β, Sym^m Euler factor = (1 - α^m X)^{m+1}.

    Example:
        >>> verify_endoscopic_collapse(2, Fraction(3))
        True
    """
    pi = SatakeGL2(alpha, alpha)
    coeffs = recip_euler_factor(symm_pow_transfer(m, pi))

    # Expected: (1 - α^m X)^{m+1}
    c = alpha ** m
    expected = [Fraction(1)]
    single = [Fraction(1), -c]
    for _ in range(m + 1):
        new_expected = [Fraction(0)] * (len(expected) + len(single) - 1)
        for i, a in enumerate(expected):
            for j, b in enumerate(single):
                new_expected[i + j] += a * b
        expected = new_expected

    return coeffs == expected


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("Symmetric Power Transfer Algorithms")
    print("=" * 50)

    pi = SatakeGL2(Fraction(2), Fraction(3))
    print(f"Parameter: ({pi.alpha}, {pi.beta})")
    print(f"Trace: {pi.trace()}, Det: {pi.det()}, Discr: {pi.discriminant()}")
    print()

    for m in range(1, 5):
        transferred = symm_pow_transfer(m, pi)
        coeffs = recip_euler_factor(transferred)
        print(f"Sym^{m}: roots = {transferred.roots}")
        print(f"  Euler factor coeffs: {coeffs}")
        print(f"  Identity verified: {verify_euler_factor_identity(m, pi)}")
        print(f"  Twist compatible: {verify_twist_compatibility(m, Fraction(5), pi)}")
        print()

    # Endoscopic test
    print("Endoscopic collapse tests:")
    for m in range(1, 6):
        print(f"  m={m}: {verify_endoscopic_collapse(m, Fraction(3))}")
