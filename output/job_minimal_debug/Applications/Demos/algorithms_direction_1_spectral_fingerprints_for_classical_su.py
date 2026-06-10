#!/usr/bin/env python3
"""
Spectral Fingerprint Algorithms

Implementation of the spectral fingerprint computation and group recognition
algorithms described in the research paper.

Algorithms:
1. spectral_fingerprint: Compute the spectral profile of a matrix group
2. recognize_group: Identify classical group family from spectral data
3. count_irreducible_polys: Count irreducible polynomials over finite fields
"""

from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass
from itertools import product
import math


@dataclass
class SpectralProfile:
    """Spectral profile recording characteristic polynomial statistics."""
    irreducible_rate: float
    split_rate: float
    self_reciprocal_rate: float
    sample_size: int

    def distance(self, other: 'SpectralProfile') -> float:
        """L2 distance between spectral profiles."""
        return math.sqrt(
            (self.irreducible_rate - other.irreducible_rate) ** 2 +
            (self.split_rate - other.split_rate) ** 2 +
            (self.self_reciprocal_rate - other.self_reciprocal_rate) ** 2
        )


@dataclass
class SpectralFingerprint:
    """Full spectral fingerprint for group recognition."""
    dim: int
    field_size: int
    group_type: str  # "GL", "SL", "Sp", "O"
    profile: SpectralProfile


class GF:
    """Simple finite field GF(p) for prime p."""

    def __init__(self, p: int):
        if not self._is_prime(p):
            raise ValueError(f"{p} is not prime")
        self.p = p
        self.elements = list(range(p))
        self.nonzero = list(range(1, p))

    @staticmethod
    def _is_prime(n: int) -> bool:
        if n < 2:
            return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0:
                return False
        return True

    def add(self, a: int, b: int) -> int:
        return (a + b) % self.p

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.p

    def neg(self, a: int) -> int:
        return (-a) % self.p

    def inv(self, a: int) -> int:
        if a % self.p == 0:
            raise ValueError("Cannot invert zero")
        return pow(a, self.p - 2, self.p)

    def sub(self, a: int, b: int) -> int:
        return (a - b) % self.p


class Matrix2x2:
    """2x2 matrix over GF(p)."""

    def __init__(self, entries: List[List[int]], gf: GF):
        self.a, self.b = entries[0]
        self.c, self.d = entries[1]
        self.gf = gf

    def det(self) -> int:
        return self.gf.sub(self.gf.mul(self.a, self.d),
                           self.gf.mul(self.b, self.c))

    def trace(self) -> int:
        return self.gf.add(self.a, self.d)

    def charpoly(self) -> Tuple[int, int]:
        """Returns (constant_term, linear_coeff) of x^2 - trace*x + det."""
        return (self.det(), self.gf.neg(self.trace()))

    def is_invertible(self) -> bool:
        return self.det() != 0


def is_irreducible_degree2(const_term: int, linear_coeff: int, p: int) -> bool:
    """
    Check if x^2 + linear_coeff * x + const_term is irreducible over GF(p).

    Algorithm: A degree-2 polynomial is irreducible iff its discriminant
    is not a quadratic residue.

    Time complexity: O(log p) for the Legendre symbol computation.
    Space complexity: O(1).
    """
    disc = (linear_coeff * linear_coeff - 4 * const_term) % p
    if disc == 0:
        return False
    # Euler's criterion: disc^((p-1)/2) mod p
    return pow(disc, (p - 1) // 2, p) != 1


def is_palindromic_degree2(const_term: int, p: int) -> bool:
    """
    Check if a monic degree-2 polynomial is palindromic (self-reciprocal).

    For monic degree-2 polynomial x^2 + a1*x + a0, the coefficient
    sequence is (a0, a1, 1). Palindromic requires a0 = 1.

    Time complexity: O(1).
    """
    return const_term % p == 1


def count_irreducible_monic_degree2(p: int) -> int:
    """
    Count the number of irreducible monic polynomials of degree 2 over GF(p).

    Formula: (p^2 - p) / 2 = p(p-1)/2

    This is a classical result from finite field theory: the number of
    irreducible monic polynomials of degree n over GF(q) is given by
    the necklace polynomial (1/n) * sum_{d|n} mu(n/d) * q^d.
    For n=2: (1/2)(q^2 - q) = q(q-1)/2.

    Time complexity: O(1).
    """
    return p * (p - 1) // 2


def spectral_fingerprint(matrices: List[Matrix2x2], p: int) -> SpectralProfile:
    """
    Compute the spectral profile of a collection of 2x2 matrices over GF(p).

    For each matrix, computes its characteristic polynomial and classifies it as:
    - Irreducible (no roots in GF(p))
    - Split (all roots in GF(p))
    - Self-reciprocal/palindromic (constant term equals leading coefficient)

    Args:
        matrices: List of 2x2 matrices over GF(p)
        p: Prime field size

    Returns:
        SpectralProfile with computed rates

    Time complexity: O(n * log p) where n = len(matrices).
    Space complexity: O(1) beyond input.
    """
    n = len(matrices)
    if n == 0:
        return SpectralProfile(0.0, 0.0, 0.0, 0)

    n_irred = 0
    n_split = 0
    n_selfrecip = 0

    for m in matrices:
        const_term, linear_coeff = m.charpoly()
        if is_irreducible_degree2(const_term, linear_coeff, p):
            n_irred += 1
        else:
            n_split += 1
        if is_palindromic_degree2(const_term, p):
            n_selfrecip += 1

    return SpectralProfile(
        irreducible_rate=n_irred / n,
        split_rate=n_split / n,
        self_reciprocal_rate=n_selfrecip / n,
        sample_size=n
    )


def theoretical_profile(group_type: str, n: int, q: int) -> SpectralProfile:
    """
    Compute the theoretical spectral profile for a classical group family.

    Currently implemented for n=2 (2x2 matrices).

    Args:
        group_type: One of "GL", "SL", "Sp", "O"
        n: Matrix dimension
        q: Field size (prime)

    Returns:
        Theoretical SpectralProfile
    """
    if n != 2:
        raise NotImplementedError("Only n=2 is currently supported")

    if group_type == "GL":
        irred = q / (2 * (q + 1))
        split = 1 - irred  # approximate
        selfrecip = 1 / (q - 1)  # fraction with det=1 (palindromic)
        size = q * (q**2 - 1) * (q - 1)
    elif group_type == "SL":
        irred = (q - 1) / (2 * q)
        split = 1 - irred
        selfrecip = 1.0  # all SL_2 elements have det=1, so palindromic
        size = q * (q**2 - 1)
    elif group_type == "Sp":
        # Sp_2 ≅ SL_2 for 2x2
        irred = (q - 1) / (2 * q)
        split = 1 - irred
        selfrecip = 1.0
        size = q * (q**2 - 1)
    else:
        raise ValueError(f"Unknown group type: {group_type}")

    return SpectralProfile(
        irreducible_rate=irred,
        split_rate=split,
        self_reciprocal_rate=selfrecip,
        sample_size=size
    )


def recognize_group(profile: SpectralProfile, n: int, q: int,
                    candidates: List[str] = None) -> Tuple[str, float]:
    """
    Identify the classical group family from an observed spectral profile.

    Algorithm:
    1. Compute theoretical profiles for each candidate group family.
    2. Return the family whose theoretical profile is closest to the observed one.

    Args:
        profile: Observed spectral profile
        n: Matrix dimension
        q: Field size
        candidates: List of group types to consider (default: ["GL", "SL", "Sp"])

    Returns:
        (best_group_type, confidence_score) where confidence is the ratio
        of second-best to best distance (higher = more confident)

    Time complexity: O(|candidates|).
    """
    if candidates is None:
        candidates = ["GL", "SL"]  # Sp ≅ SL for n=2

    distances = {}
    for gtype in candidates:
        try:
            theory = theoretical_profile(gtype, n, q)
            distances[gtype] = profile.distance(theory)
        except (NotImplementedError, ValueError):
            continue

    if not distances:
        return ("UNKNOWN", 0.0)

    sorted_types = sorted(distances.items(), key=lambda x: x[1])
    best = sorted_types[0]

    if len(sorted_types) > 1:
        second = sorted_types[1]
        confidence = second[1] / (best[1] + 1e-10)
    else:
        confidence = float('inf')

    return (best[0], confidence)


def enumerate_gl2(p: int) -> List[Matrix2x2]:
    """Enumerate all elements of GL_2(GF(p))."""
    gf = GF(p)
    matrices = []
    for a, b, c, d in product(range(p), repeat=4):
        m = Matrix2x2([[a, b], [c, d]], gf)
        if m.is_invertible():
            matrices.append(m)
    return matrices


def enumerate_sl2(p: int) -> List[Matrix2x2]:
    """Enumerate all elements of SL_2(GF(p))."""
    gf = GF(p)
    matrices = []
    for a, b, c, d in product(range(p), repeat=4):
        m = Matrix2x2([[a, b], [c, d]], gf)
        if m.det() == 1:
            matrices.append(m)
    return matrices


# Example usage
if __name__ == "__main__":
    print("Spectral Fingerprint Algorithm Demo")
    print("=" * 50)

    for p in [3, 5, 7]:
        print(f"\nField: GF({p})")

        gl2 = enumerate_gl2(p)
        sl2 = enumerate_sl2(p)

        gl2_fp = spectral_fingerprint(gl2, p)
        sl2_fp = spectral_fingerprint(sl2, p)

        print(f"  GL_2: irred={gl2_fp.irreducible_rate:.4f}, "
              f"selfrecip={gl2_fp.self_reciprocal_rate:.4f}")
        print(f"  SL_2: irred={sl2_fp.irreducible_rate:.4f}, "
              f"selfrecip={sl2_fp.self_reciprocal_rate:.4f}")

        # Test recognition
        recognized, conf = recognize_group(gl2_fp, 2, p)
        print(f"  GL_2 recognized as: {recognized} (confidence: {conf:.2f})")

        recognized, conf = recognize_group(sl2_fp, 2, p)
        print(f"  SL_2 recognized as: {recognized} (confidence: {conf:.2f})")
