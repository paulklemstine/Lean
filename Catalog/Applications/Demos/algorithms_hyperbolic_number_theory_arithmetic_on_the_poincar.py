"""
Hyperbolic Number Theory: Core Algorithms
==========================================

Implementation of Möbius transformations, pseudohyperbolic distance,
hyperbolic lattice enumeration, and the hyperbolic zeta function
on the Poincaré disk model.

All functions are type-hinted and documented.
"""

import cmath
import math
from typing import List, Tuple, Set, Optional


def mobius_map(a: complex, z: complex) -> complex:
    """Apply the Möbius transformation φ_a(z) = (z - a) / (1 - conj(a)*z).
    
    This maps the unit disk to itself when |a| < 1 and |z| < 1.
    It sends a ↦ 0 and is an isometry of the hyperbolic metric.
    
    Args:
        a: Center point in the unit disk (|a| < 1)
        z: Point to transform (|z| < 1)
    
    Returns:
        The image φ_a(z) in the unit disk
    """
    return (z - a) / (1 - a.conjugate() * z)


def mobius_inverse(a: complex, w: complex) -> complex:
    """Apply the inverse Möbius transformation φ_{-a}(w) = (w + a) / (1 + conj(a)*w).
    
    This is the functional inverse of mobius_map(a, ·).
    
    Args:
        a: Original center point
        w: Point to invert
    
    Returns:
        The pre-image z such that φ_a(z) = w
    """
    return (w + a) / (1 + a.conjugate() * w)


def pseudo_hyp_dist(z: complex, w: complex) -> float:
    """Compute the pseudohyperbolic distance ρ(z, w) = |φ_w(z)|.
    
    This is related to the hyperbolic distance by d_H(z,w) = 2·arctanh(ρ(z,w)).
    
    Args:
        z, w: Points in the unit disk
    
    Returns:
        The pseudohyperbolic distance in [0, 1)
    """
    return abs(mobius_map(w, z))


def hyperbolic_distance(z: complex, w: complex) -> float:
    """Compute the hyperbolic distance d_H(z, w) = 2·arctanh(ρ(z, w)).
    
    Args:
        z, w: Points in the unit disk
    
    Returns:
        The hyperbolic distance (non-negative real)
    """
    rho = pseudo_hyp_dist(z, w)
    return 2 * math.atanh(min(rho, 0.9999999))  # clamp for numerical stability


def conformal_weight(z: complex) -> float:
    """Compute the conformal weight 1/(1 - |z|²)² at point z.
    
    This appears in the hyperbolic area element dA_hyp = dA_eucl / (1 - |z|²)².
    
    Args:
        z: Point in the unit disk
    
    Returns:
        The conformal weight (≥ 1 inside the disk)
    """
    r2 = abs(z) ** 2
    return 1.0 / (1.0 - r2) ** 2


def generate_lattice_orbit(
    generators: List[complex],
    max_depth: int = 8,
    max_points: int = 5000
) -> Set[complex]:
    """Generate the orbit of the origin under iterated Möbius maps.
    
    Starting from z = 0, we apply all generators and their inverses
    repeatedly up to max_depth iterations, collecting all distinct points.
    
    Args:
        generators: List of generator points in the unit disk
        max_depth: Maximum iteration depth
        max_points: Maximum number of points to generate
    
    Returns:
        Set of orbit points (approximately, due to floating point)
    """
    # Use a grid-based deduplication
    seen: Set[Tuple[int, int]] = set()
    points: List[complex] = []
    GRID = 1_000_000  # discretization for dedup
    
    def grid_key(z: complex) -> Tuple[int, int]:
        return (round(z.real * GRID), round(z.imag * GRID))
    
    # Start with the origin
    current_layer = [complex(0, 0)]
    key = grid_key(complex(0, 0))
    seen.add(key)
    points.append(complex(0, 0))
    
    # All maps: generators and their inverses
    all_maps = []
    for g in generators:
        all_maps.append(('fwd', g))
        all_maps.append(('inv', g))
    
    for depth in range(max_depth):
        next_layer = []
        for z in current_layer:
            for direction, g in all_maps:
                if direction == 'fwd':
                    w = mobius_map(g, z)
                else:
                    w = mobius_inverse(g, z)
                
                if abs(w) >= 0.99999:
                    continue
                
                key = grid_key(w)
                if key not in seen:
                    seen.add(key)
                    points.append(w)
                    next_layer.append(w)
                    
                    if len(points) >= max_points:
                        return set(points)
        
        current_layer = next_layer
        if not current_layer:
            break
    
    return set(points)


def counting_function(points: List[complex], R: float) -> int:
    """Count lattice points with |z| ≤ R.
    
    Args:
        points: List of lattice points
        R: Euclidean radius threshold
    
    Returns:
        Number of points within radius R
    """
    return sum(1 for z in points if abs(z) <= R)


def hyperbolic_zeta_partial(points: List[complex], s: float) -> float:
    """Compute the partial hyperbolic zeta function.
    
    ζ_H(s) = Σ_{z ∈ points, z ≠ 0} 1/|z|^(2s)
    
    Args:
        points: List of lattice points
        s: Complex parameter (real part)
    
    Returns:
        The partial zeta sum
    """
    total = 0.0
    for z in points:
        r = abs(z)
        if r > 1e-10:
            total += r ** (-2 * s)
    return total


def verify_mobius_identity(a: complex, z: complex) -> Tuple[float, float]:
    """Verify the fundamental Möbius identity:
    |1 - conj(a)*z|² - |z - a|² = (1 - |a|²)(1 - |z|²)
    
    Returns (LHS, RHS) which should be equal up to floating point.
    """
    denom = 1 - a.conjugate() * z
    lhs = abs(denom) ** 2 - abs(z - a) ** 2
    rhs = (1 - abs(a) ** 2) * (1 - abs(z) ** 2)
    return lhs, rhs


def verify_mobius_inverse(a: complex, z: complex) -> float:
    """Verify that φ_{-a}(φ_a(z)) = z.
    
    Returns |φ_{-a}(φ_a(z)) - z| which should be ~0.
    """
    w = mobius_map(a, z)
    z_recovered = mobius_map(-a, w)
    return abs(z_recovered - z)


def verify_conformal_transform(a: complex, z: complex) -> Tuple[float, float]:
    """Verify the conformal factor transformation law:
    1 - |φ_a(z)|² = (1 - |a|²)(1 - |z|²) / |1 - conj(a)*z|²
    
    Returns (LHS, RHS).
    """
    w = mobius_map(a, z)
    denom = 1 - a.conjugate() * z
    lhs = 1 - abs(w) ** 2
    rhs = (1 - abs(a) ** 2) * (1 - abs(z) ** 2) / abs(denom) ** 2
    return lhs, rhs


if __name__ == "__main__":
    # Quick verification
    a = complex(0.3, 0.4)
    z = complex(-0.2, 0.5)
    
    print("=== Möbius Identity Verification ===")
    lhs, rhs = verify_mobius_identity(a, z)
    print(f"  LHS = {lhs:.15f}")
    print(f"  RHS = {rhs:.15f}")
    print(f"  Diff = {abs(lhs - rhs):.2e}")
    
    print("\n=== Möbius Inverse Verification ===")
    err = verify_mobius_inverse(a, z)
    print(f"  |φ_{{-a}}(φ_a(z)) - z| = {err:.2e}")
    
    print("\n=== Conformal Transform Verification ===")
    lhs, rhs = verify_conformal_transform(a, z)
    print(f"  LHS = {lhs:.15f}")
    print(f"  RHS = {rhs:.15f}")
    print(f"  Diff = {abs(lhs - rhs):.2e}")
