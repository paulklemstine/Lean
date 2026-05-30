#!/usr/bin/env python3
"""
Algorithms for Hyperbolic Number Theory
========================================

Implements core algorithms for arithmetic on the Poincaré disk:
1. Möbius transformation algebra
2. Hyperbolic lattice generation
3. Hyperbolic distance computation
4. Lattice point counting
5. Hyperbolic zeta function partial sums
"""

import numpy as np
from typing import List, Tuple, Set, Optional


class MoebiusMat:
    """A Möbius transformation z ↦ (az+b)/(cz+d) with ad-bc ≠ 0.
    
    Complexity: O(1) for apply, compose, inverse.
    """
    
    def __init__(self, a: complex, b: complex, c: complex, d: complex):
        det = a * d - b * c
        if abs(det) < 1e-15:
            raise ValueError(f"Degenerate Möbius transformation: det = {det}")
        self.a, self.b, self.c, self.d = a, b, c, d
        self._det = det
    
    def apply(self, z: complex) -> complex:
        """Apply transformation: (az+b)/(cz+d). O(1)."""
        denom = self.c * z + self.d
        if abs(denom) < 1e-15:
            return complex('inf')
        return (self.a * z + self.b) / denom
    
    def compose(self, other: 'MoebiusMat') -> 'MoebiusMat':
        """Compose self ∘ other via matrix multiplication. O(1)."""
        return MoebiusMat(
            self.a * other.a + self.b * other.c,
            self.a * other.b + self.b * other.d,
            self.c * other.a + self.d * other.c,
            self.c * other.b + self.d * other.d
        )
    
    def inverse(self) -> 'MoebiusMat':
        """Compute inverse transformation. O(1)."""
        return MoebiusMat(self.d, -self.b, -self.c, self.a)
    
    @property
    def det(self) -> complex:
        return self._det
    
    @staticmethod
    def identity() -> 'MoebiusMat':
        return MoebiusMat(1, 0, 0, 1)
    
    def __repr__(self):
        return f"MoebiusMat({self.a}, {self.b}, {self.c}, {self.d})"


def moebius_add(z: complex, w: complex) -> complex:
    """Möbius addition (Einstein velocity addition).
    
    (z + w) / (1 + conj(w) * z)
    
    Properties (verified formally):
    - Identity: 0 ⊕ z = z ⊕ 0 = z
    - Commutative for real inputs
    - Non-commutative in general (Thomas precession)
    
    Complexity: O(1).
    """
    denom = 1 + np.conj(w) * z
    if abs(denom) < 1e-15:
        return complex('inf')
    return (z + w) / denom


def pseudo_hyp_dist(z: complex, w: complex) -> float:
    """Pseudo-hyperbolic distance ρ(z,w) = |z-w| / |1 - w̄z|.
    
    Properties (verified formally):
    - ρ(z,z) = 0
    - ρ(z,w) = ρ(w,z) (symmetry)
    - ρ(z,w) ≥ 0
    - ρ(z,w) < 1 when z,w in unit disk
    
    Complexity: O(1).
    """
    denom = abs(1 - np.conj(w) * z)
    if denom < 1e-15:
        return float('inf')
    return abs(z - w) / denom


def hyp_dist(z: complex, w: complex) -> float:
    """Hyperbolic distance d(z,w) = log((1+ρ)/(1-ρ)) = 2·artanh(ρ).
    
    Complexity: O(1).
    """
    rho = pseudo_hyp_dist(z, w)
    if rho >= 1.0:
        return float('inf')
    return np.log((1 + rho) / (1 - rho))


def hyp_area(R: float) -> float:
    """Area of hyperbolic disk of radius R.
    
    A(R) = 2π(cosh(R) - 1) = 4π sinh²(R/2)
    
    Properties (verified formally):
    - A(0) = 0
    - A(R) ≥ 0 for R ≥ 0
    - Strictly monotone on [0,∞)
    - A(R) ≥ π(eᴿ - 2)  (exponential growth)
    
    Complexity: O(1).
    """
    return 2 * np.pi * (np.cosh(R) - 1)


def generate_lattice(generators: List[complex], depth: int = 5,
                     max_points: int = 10000) -> List[complex]:
    """Generate hyperbolic lattice points by iterating Möbius additions.
    
    Starting from the origin, repeatedly applies Möbius addition with
    each generator to create an orbit.
    
    Args:
        generators: List of generating points in the unit disk
        depth: Number of iteration rounds
        max_points: Maximum number of points to generate
    
    Returns:
        List of lattice points in the unit disk
    
    Complexity: O(|generators|^depth) in the worst case, bounded by max_points.
    """
    points: Set[Tuple[float, float]] = {(0.0, 0.0)}
    current = [0.0 + 0.0j]
    
    for _ in range(depth):
        if len(points) >= max_points:
            break
        new_pts = []
        for p in current:
            for g in generators:
                q = moebius_add(p, g)
                key = (round(q.real, 8), round(q.imag, 8))
                if abs(q) < 0.9999 and key not in points:
                    points.add(key)
                    new_pts.append(q)
                    if len(points) >= max_points:
                        break
            if len(points) >= max_points:
                break
        current = new_pts
    
    return [complex(x, y) for x, y in points]


def lattice_count(points: List[complex], center: complex, R: float) -> int:
    """Count lattice points within hyperbolic distance R of center.
    
    Properties (verified formally):
    - Monotone: R ≤ S ⟹ N(R) ≤ N(S)
    - Bounded: N(R) ≤ |points|
    
    Complexity: O(n) where n = len(points).
    """
    return sum(1 for p in points if hyp_dist(p, center) <= R)


def hyp_zeta_partial(points: List[complex], s: float) -> float:
    """Partial sum of hyperbolic zeta function.
    
    ζ_H(s) = Σ_{n: ‖n‖_H > 0} 1/‖n‖_H^{2s}
    
    Args:
        points: Lattice points (complex numbers in disk)
        s: Complex exponent (real part)
    
    Returns:
        Partial sum of the zeta function
    
    Complexity: O(n) where n = len(points).
    """
    total = 0.0
    for p in points:
        norm = hyp_dist(p, 0)
        if norm > 1e-10:
            total += norm ** (-2 * s)
    return total


def cross_ratio(z1: complex, z2: complex, z3: complex, z4: complex) -> complex:
    """Cross-ratio of four complex numbers.
    
    [z₁, z₂; z₃, z₄] = (z₁-z₃)(z₂-z₄) / ((z₁-z₄)(z₂-z₃))
    
    The cross-ratio is a Möbius invariant: preserved under all Möbius transforms.
    
    Complexity: O(1).
    """
    num = (z1 - z3) * (z2 - z4)
    den = (z1 - z4) * (z2 - z3)
    if abs(den) < 1e-15:
        return complex('inf')
    return num / den


# =============================================================================
# Example usage
# =============================================================================

if __name__ == "__main__":
    # Generate a hyperbolic lattice
    gens = [0.3, -0.3, 0.3j, -0.3j, 0.2+0.2j, -0.2-0.2j,
            0.15+0.25j, -0.15-0.25j]
    lattice = generate_lattice(gens, depth=6, max_points=5000)
    print(f"Generated {len(lattice)} lattice points")
    
    # Count lattice points at various radii
    print("\nLattice counting function N(R):")
    print(f"{'R':>6s}  {'N(R)':>6s}  {'A(R)':>10s}  {'Density':>10s}")
    for R in np.arange(0.5, 5.1, 0.5):
        N = lattice_count(lattice, 0, R)
        A = hyp_area(R)
        density = N / A if A > 0 else 0
        print(f"{R:6.1f}  {N:6d}  {A:10.2f}  {density:10.4f}")
    
    # Hyperbolic zeta function
    print("\nHyperbolic zeta partial sums:")
    for s in [0.5, 1.0, 1.5, 2.0, 3.0]:
        zeta = hyp_zeta_partial(lattice, s)
        print(f"  ζ_H({s:.1f}) ≈ {zeta:.6f}")
    
    # Cross-ratio invariance test
    M = MoebiusMat(1+1j, 0.5, 0.2j, 1-0.3j)
    pts = [0.1+0.2j, -0.3+0.1j, 0.4-0.2j, -0.1-0.3j]
    cr_before = cross_ratio(*pts)
    cr_after = cross_ratio(*[M.apply(p) for p in pts])
    print(f"\nCross-ratio invariance:")
    print(f"  Before Möbius: {cr_before:.6f}")
    print(f"  After Möbius:  {cr_after:.6f}")
    print(f"  Difference:    {abs(cr_before - cr_after):.2e}")
