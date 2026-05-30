#!/usr/bin/env python3
"""
Algorithms for Hyperbolic Number Theory
========================================

Implements the core algorithms from the research paper:
1. Möbius transformation algebra on the Poincaré disk
2. Hyperbolic lattice point generation via BFS
3. Hyperbolic prime identification
4. Counting function computation
5. Schläfli tessellation classification
"""

import numpy as np
from typing import List, Tuple, Set, Optional
from dataclasses import dataclass


@dataclass
class HyperbolicPoint:
    """A point in the Poincaré disk with metadata."""
    z: complex
    index: int
    hyp_dist_from_origin: float
    is_prime: Optional[bool] = None
    generation: int = 0  # BFS depth at which this point was discovered


class MoebiusTransform:
    """A Möbius automorphism of the Poincaré disk.
    
    Represents φ_a(z) = (z - a) / (1 - conj(a) * z)
    
    Time complexity: O(1) per evaluation
    Space complexity: O(1)
    """
    
    def __init__(self, a: complex):
        """Initialize with center point a (must have |a| < 1)."""
        if abs(a) >= 1:
            raise ValueError(f"|a| = {abs(a)} >= 1, point not in disk")
        self.a = a
        self.a_conj = np.conj(a)
    
    def __call__(self, z: complex) -> complex:
        """Apply the Möbius map: φ_a(z) = (z - a) / (1 - ā·z)."""
        denom = 1 - self.a_conj * z
        if abs(denom) < 1e-15:
            raise ValueError("Denominator too close to zero")
        return (z - self.a) / denom
    
    def inverse(self) -> 'MoebiusTransform':
        """Return the inverse map φ_{-a}.
        
        Note: φ_a composed with φ_{-a} is NOT the identity (it's -id).
        The true inverse of (z-a)/(1-āz) is (-z-a)/(1+āz), or equivalently
        the involution ψ_a(z) = (a-z)/(1-āz) which satisfies ψ_a∘ψ_a = id.
        """
        return MoebiusTransform(-self.a)


class MoebiusInvolution:
    """The standard Möbius involution ψ_a(z) = (a - z)/(1 - conj(a)·z).
    
    Satisfies ψ_a(ψ_a(z)) = z (formally proved as moebius_involution in Lean).
    """
    
    def __init__(self, a: complex):
        if abs(a) >= 1:
            raise ValueError(f"|a| = {abs(a)} >= 1, point not in disk")
        self.a = a
    
    def __call__(self, z: complex) -> complex:
        return (self.a - z) / (1 - np.conj(self.a) * z)


def hyp_dist(z: complex, w: complex) -> float:
    """Compute hyperbolic distance on the Poincaré disk.
    
    d(z, w) = log((1 + t) / (1 - t)) where t = |z - w| / |1 - conj(w)·z|
    
    Properties (proved in Lean):
    - d(z, z) = 0 (hypDist_self)
    - d(z, w) ≥ 0 (hypDist_nonneg)
    - d(z, w) = d(w, z) (hypDist_comm)
    - d(0, z) = log((1+|z|)/(1-|z|)) (hypDist_origin)
    
    Time: O(1), Space: O(1)
    """
    t = abs(z - w) / abs(1 - np.conj(w) * z)
    t = min(t, 1 - 1e-15)  # Numerical safety
    return np.log((1 + t) / (1 - t))


def poincare_conformal_factor(z: complex) -> float:
    """Conformal factor λ(z) = 2/(1 - |z|²).
    
    Properties (proved in Lean):
    - λ(z) > 0 for |z| < 1 (poincareConformalFactor_pos)
    - λ(0) = 2 (poincareConformalFactor_origin)
    - λ(z) ≥ 1/ε when |z| ≥ 1-ε (poincareConformalFactor_large)
    """
    return 2.0 / (1 - abs(z)**2)


def hyp_area(R: float) -> float:
    """Hyperbolic area of a disk of radius R: 4π sinh²(R/2).
    
    Properties (proved in Lean):
    - hypArea(R) ≥ 0 (hypArea_nonneg)
    - hypArea(0) = 0 (hypArea_zero)
    """
    return 4 * np.pi * np.sinh(R / 2)**2


class HyperbolicLattice:
    """A discrete set of points in the Poincaré disk forming a lattice
    under Möbius composition.
    
    Corresponds to the HyperbolicLattice structure in Lean:
    - points : ℕ → ℂ
    - in_disk : ∀ n, ‖points n‖ < 1
    - monotone_dist : ordered by distance from origin
    - origin_first : points 0 = 0
    
    Algorithm: BFS-based orbit generation.
    Time: O(N · G · N) where N = #points, G = #generators (dominated by dedup)
    Space: O(N)
    """
    
    def __init__(self, p: int = 7, q: int = 3):
        """Initialize with a {p,q} tessellation.
        
        Args:
            p: number of sides per polygon
            q: number of polygons meeting at each vertex
        
        The tessellation is hyperbolic iff (p-2)(q-2) > 4
        (proved as schlafli_hyperbolic_condition in Lean).
        """
        self.p = p
        self.q = q
        
        # Verify hyperbolicity
        if (p - 2) * (q - 2) <= 4:
            raise ValueError(f"{{{p},{q}}} is not hyperbolic: (p-2)(q-2) = {(p-2)*(q-2)} ≤ 4")
        
        # Compute edge length: cosh(d) = cos(π/q) / sin(π/p)
        self.edge_length = np.arccosh(np.cos(np.pi/q) / np.sin(np.pi/p))
        self.edge_radius = np.tanh(self.edge_length / 2)
        
        # Generate initial generators
        self.generators = []
        for k in range(p):
            angle = 2 * np.pi * k / p
            z = self.edge_radius * np.exp(1j * angle)
            self.generators.append(z)
        
        self.points: List[HyperbolicPoint] = []
        self._point_set: Set[Tuple[float, float]] = set()
    
    def _quantize(self, z: complex) -> Tuple[float, float]:
        """Quantize a complex number for deduplication."""
        return (round(z.real, 8), round(z.imag, 8))
    
    def _add_point(self, z: complex, gen: int) -> bool:
        """Add a point if not already present. Returns True if new."""
        key = self._quantize(z)
        if key in self._point_set:
            return False
        if abs(z) >= 0.9999:
            return False
        self._point_set.add(key)
        pt = HyperbolicPoint(
            z=z,
            index=len(self.points),
            hyp_dist_from_origin=hyp_dist(0, z),
            generation=gen
        )
        self.points.append(pt)
        return True
    
    def generate(self, depth: int = 5) -> List[HyperbolicPoint]:
        """Generate lattice points via BFS up to given depth.
        
        Complexity:
        - Time: O(p^depth) in worst case (exponential growth, as expected)
        - Space: O(p^depth)
        """
        self.points = []
        self._point_set = set()
        self._add_point(0 + 0j, 0)
        
        queue = [0 + 0j]
        for gen in range(1, depth + 1):
            new_queue = []
            for center in queue:
                for g in self.generators:
                    try:
                        new_pt = MoebiusTransform(-center)(g)
                        if self._add_point(new_pt, gen):
                            new_queue.append(new_pt)
                    except ValueError:
                        continue
            queue = new_queue
        
        # Sort by hyperbolic distance (matching Lean's monotone_dist)
        self.points.sort(key=lambda p: p.hyp_dist_from_origin)
        for i, pt in enumerate(self.points):
            pt.index = i
        
        return self.points
    
    def identify_primes(self) -> List[HyperbolicPoint]:
        """Identify hyperbolic primes: points not expressible as Möbius
        compositions of earlier points.
        
        Matches the IsHyperbolicPrime definition in Lean:
        n > 0 ∧ ∀ i j, i > 0 → j > 0 → i < n → j < n →
            moebiusMap (points i) (points j) ≠ points n
        
        Complexity: O(N³) where N = #points
        """
        if not self.points:
            return []
        
        for pt in self.points:
            if pt.index == 0:
                pt.is_prime = False
                continue
            
            pt.is_prime = True
            for i in range(1, pt.index):
                for j in range(1, pt.index):
                    try:
                        composed = MoebiusTransform(self.points[i].z)(self.points[j].z)
                        if abs(composed - pt.z) < 1e-6:
                            pt.is_prime = False
                            break
                    except ValueError:
                        continue
                if not pt.is_prime:
                    break
        
        return [pt for pt in self.points if pt.is_prime]
    
    def counting_function(self, R: float) -> int:
        """Count lattice points within hyperbolic radius R.
        
        Corresponds to normCountingFn in Lean (using Euclidean proxy).
        Monotone in R (proved as normCountingFn_mono in Lean).
        """
        return sum(1 for pt in self.points if pt.hyp_dist_from_origin <= R)


def schlafli_classify(p: int, q: int) -> str:
    """Classify a {p,q} tessellation as hyperbolic, Euclidean, or spherical.
    
    By the Schläfli condition (schlafli_hyperbolic_condition in Lean):
    (p-2)(q-2) > 4 ⟺ 1/p + 1/q < 1/2 ⟺ hyperbolic
    """
    val = 1.0/p + 1.0/q
    if abs(val - 0.5) < 1e-10:
        return "Euclidean"
    elif val < 0.5:
        return "Hyperbolic"
    else:
        return "Spherical"


def gauss_bonnet_area(n_sides: int, angles: List[float]) -> float:
    """Compute hyperbolic polygon area via Gauss-Bonnet.
    
    Area = (n-2)π - Σ(angles)
    Positive when Σ(angles) < (n-2)π (proved as gauss_bonnet_polygon in Lean).
    """
    if len(angles) != n_sides:
        raise ValueError("Number of angles must match number of sides")
    return (n_sides - 2) * np.pi - sum(angles)


if __name__ == "__main__":
    # Quick demo
    print("Generating {7,3} hyperbolic lattice...")
    lattice = HyperbolicLattice(7, 3)
    points = lattice.generate(depth=4)
    print(f"Generated {len(points)} points")
    
    primes = lattice.identify_primes()
    print(f"Found {len(primes)} hyperbolic primes")
    
    print("\nCounting function N(R):")
    for R in range(1, 8):
        count = lattice.counting_function(R)
        area = hyp_area(R)
        print(f"  N({R}) = {count:>5}, area = {area:>10.2f}")
    
    print(f"\nSchläfli classification examples:")
    for p, q in [(3,6), (4,4), (6,3), (3,7), (5,4), (7,3), (4,5)]:
        print(f"  {{{p},{q}}}: {schlafli_classify(p, q)}")
