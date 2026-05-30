#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Core Algorithms

Implements the algorithms described in the research paper for:
- Möbius addition and gyration on the Poincaré disk
- SL(2,R) group operations
- Hyperbolic lattice generation via PSL(2,Z)
- Hyperbolic prime detection
- Hyperbolic counting function
- Critical line to disk mapping
"""

import numpy as np
from typing import List, Tuple, Set, Optional
from dataclasses import dataclass


# ============================================================
# Poincaré Disk Arithmetic
# ============================================================

def moebius_add(z: complex, w: complex) -> complex:
    """
    Möbius addition on the Poincaré disk.
    
    z ⊕ w = (z + w) / (1 + conj(z) * w)
    
    This is the Einstein velocity addition formula and forms a
    gyrogroup (non-commutative group with gyration automorphisms).
    
    Args:
        z: First operand (complex, |z| < 1)
        w: Second operand (complex, |w| < 1)
    
    Returns:
        Möbius sum z ⊕ w
    """
    denom = 1 + z.conjugate() * w
    if abs(denom) < 1e-15:
        return complex(0, 0)
    return (z + w) / denom


def gyration_factor(z: complex, w: complex) -> complex:
    """
    Gyration factor gyr(z, w) = (1 + conj(z)*w) / (1 + z*conj(w)).
    
    This is always a unit complex number (|gyr| = 1) when the
    denominator is nonzero, meaning gyration is a pure rotation.
    
    The gyration accounts for the non-commutativity of Möbius addition:
    z ⊕ w = gyr(z, w) * (w ⊕ z)
    
    Args:
        z, w: Complex numbers
    
    Returns:
        Gyration factor (unit complex number)
    """
    denom = 1 + z * w.conjugate()
    if abs(denom) < 1e-15:
        return complex(1, 0)
    return (1 + z.conjugate() * w) / denom


def poincare_conformal(z: complex) -> float:
    """
    Poincaré conformal factor λ(z) = 2/(1 - |z|²).
    
    This factor converts between Euclidean and hyperbolic infinitesimal
    distances: ds_hyp = λ(z) * ds_euc.
    
    Properties (proved in Lean):
    - λ(z) > 0 for all z in D
    - λ(0) = 2
    - λ(z) ≥ 2 for all z in D
    
    Args:
        z: Point in Poincaré disk (|z| < 1)
    
    Returns:
        Conformal factor λ(z)
    """
    norm_sq = abs(z) ** 2
    return 2.0 / (1.0 - norm_sq)


def hyp_distance(z: complex, w: complex) -> float:
    """
    Hyperbolic distance between two points in the Poincaré disk.
    
    d(z, w) = 2 * arctanh(|z ⊖ w|) where z ⊖ w = (-z) ⊕ w.
    
    Equivalently: d(z, w) = 2 * arctanh(|z - w| / |1 - conj(w)*z|)
    
    Args:
        z, w: Points in the Poincaré disk
    
    Returns:
        Hyperbolic distance d(z, w)
    """
    diff = moebius_add(-z, w)
    r = min(abs(diff), 1 - 1e-15)  # clamp for numerical stability
    return 2.0 * np.arctanh(r)


# ============================================================
# SL(2,R) Operations
# ============================================================

@dataclass
class SL2RElement:
    """Element of SL(2,R): 2x2 real matrix with determinant 1."""
    a: float
    b: float
    c: float
    d: float
    
    def det(self) -> float:
        return self.a * self.d - self.b * self.c
    
    def __post_init__(self):
        assert abs(self.det() - 1.0) < 1e-8, f"det = {self.det()} ≠ 1"
    
    def __mul__(self, other: 'SL2RElement') -> 'SL2RElement':
        """Group multiplication (matrix product)."""
        return SL2RElement(
            self.a * other.a + self.b * other.c,
            self.a * other.b + self.b * other.d,
            self.c * other.a + self.d * other.c,
            self.c * other.b + self.d * other.d
        )
    
    def inv(self) -> 'SL2RElement':
        """Group inverse: [[d, -b], [-c, a]]."""
        return SL2RElement(self.d, -self.b, -self.c, self.a)
    
    def act_upper_half(self, z: complex) -> Optional[complex]:
        """Möbius action on upper half-plane: (az+b)/(cz+d)."""
        denom = self.c * z + self.d
        if abs(denom) < 1e-15:
            return None
        return (self.a * z + self.b) / denom


# ============================================================
# Hyperbolic Lattice Generation
# ============================================================

def cayley_transform(z: complex) -> complex:
    """Map upper half-plane to Poincaré disk: w = (z - i)/(z + i)."""
    return (z - 1j) / (z + 1j)


def inv_cayley_transform(w: complex) -> complex:
    """Map Poincaré disk to upper half-plane: z = i(1 + w)/(1 - w)."""
    return 1j * (1 + w) / (1 - w)


def generate_psl2z_orbit(max_depth: int = 5) -> List[complex]:
    """
    Generate orbit of i under PSL(2,Z) in the Poincaré disk.
    
    Uses BFS over words in the generators S and T of PSL(2,Z):
    - S: z ↦ -1/z (corresponding to [[0,-1],[1,0]])
    - T: z ↦ z+1 (corresponding to [[1,1],[0,1]])
    
    Args:
        max_depth: Maximum word length in generators
    
    Returns:
        Sorted list of orbit points in the Poincaré disk
    
    Complexity: O(4^depth) orbit points, O(4^depth) time
    """
    S = SL2RElement(0, -1, 1, 0)
    T = SL2RElement(1, 1, 0, 1)
    generators = [S, T, S.inv(), T.inv()]
    
    base_point = 1j  # i in upper half-plane
    
    orbit_disk: Set[Tuple[float, float]] = set()
    visited: Set[Tuple[float, float, float, float]] = set()
    
    def matrix_key(M: SL2RElement) -> Tuple:
        return (round(M.a, 8), round(M.b, 8), round(M.c, 8), round(M.d, 8))
    
    identity = SL2RElement(1, 0, 0, 1)
    current_level = [identity]
    visited.add(matrix_key(identity))
    
    # Add base point
    w0 = cayley_transform(base_point)
    orbit_disk.add((round(w0.real, 10), round(w0.imag, 10)))
    
    for depth in range(max_depth):
        next_level = []
        for M in current_level:
            for g in generators:
                M2 = M * g
                key = matrix_key(M2)
                neg_key = matrix_key(SL2RElement(-M2.a, -M2.b, -M2.c, -M2.d)
                                     if abs(M2.det() - 1) < 0.01 else M2)
                if key not in visited and neg_key not in visited:
                    visited.add(key)
                    z = M2.act_upper_half(base_point)
                    if z is not None and z.imag > 1e-10:
                        w = cayley_transform(z)
                        if abs(w) < 1 - 1e-10:
                            orbit_disk.add((round(w.real, 10), round(w.imag, 10)))
                    next_level.append(M2)
        current_level = next_level
    
    points = [complex(re, im) for re, im in orbit_disk]
    return sorted(points, key=abs)


# ============================================================
# Hyperbolic Prime Detection
# ============================================================

def is_hyperbolic_prime(orbit: List[complex], n: int, tol: float = 1e-6) -> bool:
    """
    Test if orbit[n] is a hyperbolic prime.
    
    A lattice point is hyperbolic prime if it cannot be expressed as
    orbit[i] ⊕ orbit[j] for any 0 < i, j < n.
    
    Args:
        orbit: List of orbit points sorted by norm
        n: Index to test
        tol: Tolerance for equality check
    
    Returns:
        True if orbit[n] is hyperbolic prime
    
    Complexity: O(n²)
    """
    if n <= 0 or n >= len(orbit):
        return False
    
    target = orbit[n]
    for i in range(1, n):
        for j in range(1, n):
            w = moebius_add(orbit[i], orbit[j])
            if abs(w - target) < tol:
                return False
    return True


def hyperbolic_prime_count(orbit: List[complex], N: int) -> int:
    """
    Count hyperbolic primes among the first N orbit points.
    
    Args:
        orbit: List of orbit points
        N: Upper bound on index
    
    Returns:
        Number of hyperbolic primes with index < N
    
    Complexity: O(N³)
    """
    return sum(1 for n in range(1, min(N, len(orbit)))
               if is_hyperbolic_prime(orbit, n))


# ============================================================
# Counting Function
# ============================================================

def hyp_counting(orbit: List[complex], R: float, N: int) -> int:
    """
    Count orbit points among the first N with Euclidean norm ≤ R.
    
    Properties (proved in Lean):
    - Monotone in R: R ≤ S ⟹ count(R) ≤ count(S)
    - Monotone in N: M ≤ N ⟹ count(M) ≤ count(N)
    - Lower bound: count ≥ 1 when R ≥ 0, N > 0
    - Upper bound: count ≤ N
    
    Args:
        orbit: List of orbit points
        R: Radius threshold
        N: Number of points to consider
    
    Returns:
        Count of points with |orbit[n]| ≤ R for n < N
    """
    return sum(1 for n in range(min(N, len(orbit))) if abs(orbit[n]) <= R)


# ============================================================
# Critical Line Mapping
# ============================================================

def critical_line_to_disk(t: float) -> complex:
    """
    Map a point on the critical line Re(s) = 1/2 to the Poincaré disk.
    
    The Cayley-type transform s ↦ (s-1)/(s+1) maps the critical line
    into the closed unit disk (proved in Lean as critical_line_to_disk).
    
    Args:
        t: Imaginary part (ρ = 1/2 + it)
    
    Returns:
        Transformed point in the Poincaré disk
    """
    rho = complex(0.5, t)
    return (rho - 1) / (rho + 1)


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Generating PSL(2,Z) orbit...")
    orbit = generate_psl2z_orbit(4)
    print(f"  {len(orbit)} orbit points generated")
    
    print("\nCounting function values:")
    for R in [0.3, 0.5, 0.7, 0.9]:
        count = hyp_counting(orbit, R, len(orbit))
        print(f"  N({R}) = {count}")
    
    print("\nHyperbolic primes (first 20 points):")
    for n in range(1, min(21, len(orbit))):
        if is_hyperbolic_prime(orbit, n):
            print(f"  Λ({n}) = {orbit[n]:.6f}, |Λ({n})| = {abs(orbit[n]):.6f}")
    
    print("\nCritical line mapping:")
    for t in [14.13, 21.02, 25.01]:
        w = critical_line_to_disk(t)
        print(f"  ρ = 1/2 + {t}i → |w| = {abs(w):.8f}")
