"""
Algorithms for Hyperbolic Number Theory
========================================

Implements core algorithms for computing with hyperbolic integers,
Möbius transformations, and lattice point counting on the Poincaré disk.

All algorithms are self-contained with type hints and docstrings.
"""

import math
from typing import List, Tuple, Optional


def normSq(z: complex) -> float:
    """Compute |z|² = re(z)² + im(z)²
    
    Time: O(1), Space: O(1)
    """
    return z.real**2 + z.imag**2


def mobius_transform(a: complex, z: complex) -> complex:
    """Compute the Möbius automorphism T_a(z) = (z - a)/(1 - conj(a)*z)
    
    Maps the unit disk to itself when |a| < 1 and |z| < 1.
    
    Args:
        a: Center point with |a| < 1
        z: Input point with |z| < 1
    
    Returns:
        T_a(z) in the unit disk
    
    Time: O(1), Space: O(1)
    """
    return (z - a) / (1 - a.conjugate() * z)


def mobius_involution(a: complex, z: complex) -> complex:
    """Compute the involutory Möbius automorphism φ_a(z) = (a - z)/(1 - conj(a)*z)
    
    Satisfies φ_a(φ_a(z)) = z (self-inverse).
    
    Time: O(1), Space: O(1)
    """
    return (a - z) / (1 - a.conjugate() * z)


def cayley_transform(z: complex) -> complex:
    """Cayley transform: maps upper half-plane to Poincaré disk.
    C(z) = (z - i)/(z + i)
    
    Time: O(1), Space: O(1)
    """
    return (z - 1j) / (z + 1j)


def inverse_cayley(w: complex) -> complex:
    """Inverse Cayley transform: maps Poincaré disk to upper half-plane.
    C⁻¹(w) = i(1 + w)/(1 - w)
    
    Time: O(1), Space: O(1)
    """
    return 1j * (1 + w) / (1 - w)


def pseudo_hyp_dist(z: complex, w: complex) -> float:
    """Compute the pseudo-hyperbolic distance between z and w.
    ρ(z,w) = |z - w| / |1 - conj(w)·z|
    
    Takes values in [0, 1) for points in the open unit disk.
    
    Time: O(1), Space: O(1)
    """
    num = abs(z - w)
    den = abs(1 - w.conjugate() * z)
    if den == 0:
        return float('inf')
    return num / den


def hyperbolic_distance(z: complex, w: complex) -> float:
    """Compute the hyperbolic distance in the Poincaré disk model.
    d(z,w) = 2 · arctanh(ρ(z,w))
    
    where ρ is the pseudo-hyperbolic distance.
    
    Time: O(1), Space: O(1)
    """
    rho = pseudo_hyp_dist(z, w)
    if rho >= 1:
        return float('inf')
    return 2 * math.atanh(rho)


def generate_psl2z_orbit(max_depth: int = 5) -> List[complex]:
    """Generate orbit points of i under PSL(2,Z) on the Poincaré disk.
    
    Uses the Cayley transform to map the PSL(2,Z) orbit of i in the
    upper half-plane to the disk model. Generates points by applying
    the generators S: z → -1/z and T: z → z+1 of PSL(2,Z).
    
    Args:
        max_depth: Maximum word length in generators
    
    Returns:
        List of complex numbers in the Poincaré disk
    
    Time: O(2^max_depth), Space: O(2^max_depth)
    """
    visited = set()
    orbit = []
    
    def add_point(z_uhp: complex):
        """Add a UHP point to the orbit via Cayley transform"""
        if z_uhp.imag <= 0:
            return
        w = cayley_transform(z_uhp)
        # Round for deduplication
        key = (round(w.real, 10), round(w.imag, 10))
        if key not in visited:
            visited.add(key)
            orbit.append(w)
    
    # BFS over words in the generators
    current = {1j}  # Start with i
    add_point(1j)
    
    for _ in range(max_depth):
        next_level = set()
        for z in current:
            # Apply generator S: z → -1/z
            if abs(z) > 1e-15:
                s_z = -1.0 / z
                if s_z.imag > 1e-10:
                    add_point(s_z)
                    next_level.add(s_z)
            # Apply generator T: z → z + 1
            t_z = z + 1
            if t_z.imag > 1e-10:
                add_point(t_z)
                next_level.add(t_z)
            # Apply T⁻¹: z → z - 1
            ti_z = z - 1
            if ti_z.imag > 1e-10:
                add_point(ti_z)
                next_level.add(ti_z)
        current = next_level
    
    return orbit


def count_lattice_points_in_ball(
    points: List[complex], center: complex, radius: float
) -> int:
    """Count lattice points within a hyperbolic ball.
    
    Args:
        points: List of lattice points in the disk
        center: Center of the hyperbolic ball
        radius: Hyperbolic radius
    
    Returns:
        Number of points within hyperbolic distance `radius` of `center`
    
    Time: O(n) where n = len(points), Space: O(1)
    """
    count = 0
    for p in points:
        if hyperbolic_distance(center, p) <= radius:
            count += 1
    return count


def verify_key_identity(a: complex, z: complex) -> Tuple[float, float, float]:
    """Verify the Möbius key identity for given inputs.
    
    Returns (LHS, RHS, error) where:
    LHS = |1 - conj(a)·z|² - |z - a|²
    RHS = (1 - |a|²)(1 - |z|²)
    
    Time: O(1), Space: O(1)
    """
    lhs = normSq(1 - a.conjugate() * z) - normSq(z - a)
    rhs = (1 - normSq(a)) * (1 - normSq(z))
    return lhs, rhs, abs(lhs - rhs)


def find_hyperbolic_primes(
    orbit: List[complex], num_primes: int = 10
) -> List[complex]:
    """Find hyperbolic primes: the orbit points closest to the origin.
    
    These are the irreducible elements of the hyperbolic lattice,
    analogous to prime numbers in ℤ.
    
    Args:
        orbit: List of orbit points in the disk
        num_primes: Number of primes to return
    
    Returns:
        List of the closest non-origin orbit points
    
    Time: O(n log n), Space: O(n)
    """
    # Filter out the origin and sort by normSq
    nonzero = [(normSq(p), p) for p in orbit if abs(p) > 1e-12]
    nonzero.sort()
    return [p for _, p in nonzero[:num_primes]]


def hyperbolic_lattice_growth_test(max_R: float = 10.0, steps: int = 20) -> List[Tuple[float, int]]:
    """Test the hyperbolic prime counting conjecture.
    
    Computes N(R) = #{lattice points with normSq ≤ 1 - 1/R²}
    and checks whether N(R) ∝ R² as predicted.
    
    Returns:
        List of (R, count) pairs
    
    Time: O(steps × n), Space: O(n)
    """
    orbit = generate_psl2z_orbit(max_depth=8)
    results = []
    
    for i in range(1, steps + 1):
        R = 1.0 + (max_R - 1.0) * i / steps
        threshold = 1 - 1 / R**2
        count = sum(1 for p in orbit if normSq(p) <= threshold)
        results.append((R, count))
    
    return results


# Example usage
if __name__ == "__main__":
    print("Generating PSL(2,Z) orbit on the Poincaré disk...")
    orbit = generate_psl2z_orbit(max_depth=6)
    print(f"Generated {len(orbit)} orbit points")
    
    print("\nFirst 5 hyperbolic primes (closest to origin):")
    primes = find_hyperbolic_primes(orbit, 5)
    for i, p in enumerate(primes):
        print(f"  p_{i+1} = {p:.6f}, |p|² = {normSq(p):.6f}")
    
    print("\nKey identity verification:")
    for a, z in [(0.3+0.4j, 0.1+0.2j), (0.7+0.1j, -0.5+0.3j)]:
        lhs, rhs, err = verify_key_identity(a, z)
        print(f"  a={a}, z={z}: error = {err:.2e}")
    
    print("\nLattice point growth test (Hyperbolic PNT conjecture):")
    growth = hyperbolic_lattice_growth_test(max_R=8.0, steps=8)
    print(f"  {'R':>6} | {'N(R)':>6} | {'N(R)/R²':>8}")
    print(f"  {'---':>6} | {'---':>6} | {'---':>8}")
    for R, count in growth:
        ratio = count / R**2 if R > 0 else 0
        print(f"  {R:6.2f} | {count:6d} | {ratio:8.4f}")
