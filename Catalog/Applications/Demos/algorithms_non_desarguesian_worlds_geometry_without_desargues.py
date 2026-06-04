#!/usr/bin/env python3
"""
Algorithms for Non-Desarguesian Plane Analysis

Type-hinted implementations of the core algorithms from the research.
"""

from __future__ import annotations
import math
from dataclasses import dataclass
from typing import Optional


def is_prime(n: int) -> bool:
    """Primality test."""
    if n < 2:
        return False
    for i in range(2, int(math.isqrt(n)) + 1):
        if n % i == 0:
            return False
    return True


def divisors_of(n: int) -> list[int]:
    """Return all positive divisors of n."""
    return sorted(d for d in range(1, n + 1) if n % d == 0)


@dataclass
class DefectSpectrum:
    """
    Desarguesian Defect Spectrum (DDS).

    For a projective plane of order q = p^k coordinated by a nearfield
    with kernel of order p^d, the DDS encodes:
    - defect_dim = k/d - 1 (0 iff Desarguesian)
    - kernel_index = p^(k-d) (1 iff Desarguesian)
    - non_distributive_count = p^k - p^d (algebraic defect)
    """
    p: int
    k: int
    d: int

    def __post_init__(self) -> None:
        assert is_prime(self.p), f"p={self.p} is not prime"
        assert self.k >= 1, "k must be >= 1"
        assert self.d >= 1, "d must be >= 1"
        assert self.d <= self.k, "d must be <= k"
        assert self.k % self.d == 0, f"d={self.d} must divide k={self.k}"

    @property
    def order(self) -> int:
        return self.p ** self.k

    @property
    def kernel_order(self) -> int:
        return self.p ** self.d

    @property
    def defect_dim(self) -> int:
        return self.k // self.d - 1

    @property
    def is_desarguesian(self) -> bool:
        return self.d == self.k

    @property
    def non_distributive_count(self) -> int:
        return self.p ** self.k - self.p ** self.d

    @property
    def kernel_index(self) -> int:
        return self.p ** (self.k - self.d)


def enumerate_defect_spectra(p: int, k: int) -> list[DefectSpectrum]:
    """
    Enumerate all possible defect spectra for a given prime p and exponent k.

    Algorithm: Find all d | k with 1 <= d <= k, construct DDS(p, k, d).

    Returns spectra sorted by defect dimension (ascending).
    """
    assert is_prime(p) and k >= 1
    return sorted(
        [DefectSpectrum(p, k, d) for d in divisors_of(k)],
        key=lambda s: s.defect_dim
    )


def collineation_bound_ratio(q: int) -> float:
    """
    Compute PGL(3, q) order / Hall collineation bound.

    For q >= 3, this ratio is always > 1 (our main theorem).
    """
    hall = 4 * q**2 * (q - 1)
    pgl = (q**3 - 1) * (q**3 - q) * (q**3 - q**2)
    return pgl / hall if hall > 0 else float('inf')


@dataclass
class MoultonPoint:
    x: float
    y: float


def moulton_incidence(point: MoultonPoint, slope: float, intercept: float) -> bool:
    """
    Check incidence in the Moulton plane.

    In the Moulton plane, lines with negative slope get their slope
    doubled in the right half-plane (x > 0).
    """
    eps = 1e-10
    if slope >= 0:
        return abs(point.y - (slope * point.x + intercept)) < eps
    elif point.x <= 0:
        return abs(point.y - (slope * point.x + intercept)) < eps
    else:
        return abs(point.y - (2 * slope * point.x + intercept)) < eps


def moulton_slope_at(slope: float, x: float) -> float:
    """
    The effective slope of a Moulton line at position x.

    This is the 'bending function': negative slopes get doubled
    for x > 0, creating the non-Desarguesian structure.
    """
    if slope >= 0:
        return slope
    elif x <= 0:
        return slope
    else:
        return 2 * slope


def find_moulton_line(P: MoultonPoint, Q: MoultonPoint) -> Optional[tuple[float, float]]:
    """
    Find a Moulton line through two distinct points.

    Returns (slope, intercept) or None if vertical.

    Algorithm:
    1. If x-coords equal: vertical line (return None)
    2. If both in left half-plane or both right, or non-negative slope: standard
    3. If one left, one right with negative slope: solve bent system
    """
    if abs(P.x - Q.x) < 1e-10:
        return None  # vertical line

    # Try standard slope
    m = (Q.y - P.y) / (Q.x - P.x)
    b = P.y - m * P.x

    if m >= 0:
        return (m, b)

    # Negative slope: check if bending affects this line
    if P.x <= 0 and Q.x <= 0:
        return (m, b)  # both in left half, standard

    if P.x > 0 and Q.x > 0:
        # Both in right half: effective slope is 2m
        m_eff = (Q.y - P.y) / (Q.x - P.x)
        m_real = m_eff / 2
        b_real = P.y - 2 * m_real * P.x
        return (m_real, b_real)

    # Mixed: one left, one right
    if P.x <= 0:
        left, right = P, Q
    else:
        left, right = Q, P

    # Solve: left.y = m * left.x + b and right.y = 2m * right.x + b
    # Subtracting: left.y - right.y = m * left.x - 2m * right.x
    #            = m * (left.x - 2 * right.x)
    denom = left.x - 2 * right.x
    if abs(denom) < 1e-10:
        return None
    m = (left.y - right.y) / denom
    b = left.y - m * left.x
    return (m, b)


def classify_plane(p: int, k: int, d: int) -> dict[str, any]:
    """
    Classify a projective plane by its defect spectrum.

    Returns a dictionary with classification info.
    """
    spec = DefectSpectrum(p, k, d)
    classification = {
        "order": spec.order,
        "prime": p,
        "total_dim": k,
        "kernel_dim": d,
        "defect_dim": spec.defect_dim,
        "type": "Desarguesian (PG)" if spec.is_desarguesian else "Non-Desarguesian",
        "kernel_order": spec.kernel_order,
        "non_distributive_elements": spec.non_distributive_count,
        "kernel_index": spec.kernel_index,
    }

    if not spec.is_desarguesian:
        q = spec.kernel_order
        if q >= 3:
            classification["collineation_ratio"] = collineation_bound_ratio(q)
            classification["symmetry_reduction"] = f"{collineation_bound_ratio(q):.1f}x fewer symmetries"

    return classification


if __name__ == "__main__":
    # Demo: classify all planes of order 2^6 = 64
    print("Classification of planes of order 64 = 2^6:")
    print("-" * 60)
    for d in divisors_of(6):
        info = classify_plane(2, 6, d)
        print(f"\n  d = {d}: {info['type']}")
        for key, val in info.items():
            if key != 'type':
                print(f"    {key}: {val}")
