"""
Hyperbolic Number Theory: Core Algorithms

Implements Möbius transformations on the Poincaré disk, orbit computation,
hyperbolic distance, and the partial hyperbolic zeta function.
"""

import cmath
import math
from typing import List, Tuple, Set, Optional


def mobius_transform(z: complex, a: complex, theta: float) -> complex:
    """Apply a Möbius automorphism φ_{a,θ}(z) = e^{iθ} · (z - a) / (1 - conj(a) · z).

    Args:
        z: Point in the Poincaré disk
        a: Center of the transformation (|a| < 1)
        theta: Rotation angle

    Returns:
        Image point in the Poincaré disk
    """
    rotation = cmath.exp(1j * theta)
    numerator = z - a
    denominator = 1 - a.conjugate() * z
    return rotation * numerator / denominator


def hyp_dist(z: complex, w: complex) -> float:
    """Compute the hyperbolic distance between two points in the Poincaré disk.

    d(z,w) = 2 * artanh(|z-w| / |1 - conj(w)*z|)

    Args:
        z, w: Points in the Poincaré disk (|z|, |w| < 1)

    Returns:
        Hyperbolic distance (non-negative real)
    """
    rho = abs(z - w) / abs(1 - w.conjugate() * z)
    rho = min(rho, 0.9999999999)  # Numerical safety
    return 2 * math.atanh(rho)


def hyp_norm(z: complex) -> float:
    """Compute the hyperbolic norm (distance from origin).

    ||z||_H = 2 * artanh(|z|)

    Args:
        z: Point in the Poincaré disk

    Returns:
        Hyperbolic norm
    """
    r = abs(z)
    if r >= 1:
        return float('inf')
    if r < 1e-15:
        return 0.0
    return 2 * math.atanh(r)


class MobiusGenerator:
    """A Möbius transformation generator for a hyperbolic lattice."""

    def __init__(self, center: complex, angle: float):
        assert abs(center) < 1, f"Center must be in disk, got |a| = {abs(center)}"
        self.center = center
        self.angle = angle

    def apply(self, z: complex) -> complex:
        return mobius_transform(z, self.center, self.angle)

    def __repr__(self) -> str:
        return f"Möbius(a={self.center:.4f}, θ={self.angle:.4f})"


class HyperbolicLattice:
    """A hyperbolic lattice: orbit of the origin under Möbius generators."""

    def __init__(self, generators: List[MobiusGenerator]):
        assert len(generators) > 0, "Need at least one generator"
        self.generators = generators

    def compute_orbit(self, depth: int, tolerance: float = 1e-10) -> List[complex]:
        """Compute orbit points up to given depth.

        Args:
            depth: Maximum number of generator applications
            tolerance: Deduplication tolerance

        Returns:
            List of distinct orbit points
        """
        orbit: List[complex] = [0j]
        seen: Set[Tuple[float, float]] = {(0.0, 0.0)}

        for _ in range(depth):
            new_points: List[complex] = []
            for z in orbit:
                for gen in self.generators:
                    w = gen.apply(z)
                    # Deduplication
                    key = (round(w.real / tolerance) * tolerance,
                           round(w.imag / tolerance) * tolerance)
                    if key not in seen:
                        seen.add(key)
                        new_points.append(w)
            if not new_points:
                break
            orbit.extend(new_points)

        return orbit

    def count_primes(self) -> List[complex]:
        """Return hyperbolic primes: first-generation orbit points (excluding origin)."""
        primes = []
        for gen in self.generators:
            w = gen.apply(0j)
            if abs(w) > 1e-15:
                primes.append(w)
        return primes

    def hyp_zeta_partial(self, depth: int, s: float) -> float:
        """Compute the partial hyperbolic zeta function.

        ζ_H^{(n)}(s) = Σ_{z ∈ Orbit_n, z≠0} 1/||z||_H^{2s}

        Args:
            depth: Orbit depth
            s: Complex parameter (real part)

        Returns:
            Partial zeta value
        """
        orbit = self.compute_orbit(depth)
        total = 0.0
        for z in orbit:
            if abs(z) < 1e-15:
                continue
            hn = hyp_norm(z)
            if hn > 1e-15:
                total += 1.0 / (hn ** (2 * s))
        return total


def psl2z_generators_disk() -> List[MobiusGenerator]:
    """Standard generators for PSL(2,ℤ) mapped to the Poincaré disk.

    The modular group PSL(2,ℤ) acts on the upper half-plane via
    S: z ↦ -1/z and T: z ↦ z+1. We conjugate to the disk model
    using the Cayley transform w = (z-i)/(z+i).

    Returns approximate disk-model generators.
    """
    # S transformation (order 2): center at i maps to 0 in disk
    # Under Cayley transform, S becomes a rotation by π
    gen_s = MobiusGenerator(center=0j, angle=math.pi)

    # T transformation: z ↦ z+1 in half-plane
    # Under Cayley, this becomes a Möbius with specific center
    # The fixed point of T is at infinity, which maps to 1 in the disk
    # Approximate generator in disk coordinates
    a_t = 0.5 + 0.0j  # Approximate center for T in disk model
    gen_t = MobiusGenerator(center=a_t, angle=0.0)

    return [gen_s, gen_t]


def make_regular_generators(k: int, radius: float = 0.5) -> List[MobiusGenerator]:
    """Create k generators evenly spaced around the disk.

    Args:
        k: Number of generators
        radius: Distance of centers from origin (< 1)

    Returns:
        List of k Möbius generators
    """
    generators = []
    for i in range(k):
        angle = 2 * math.pi * i / k
        center = radius * cmath.exp(1j * angle)
        generators.append(MobiusGenerator(center=center, angle=angle))
    return generators


def verify_disk_preservation(gen: MobiusGenerator, n_tests: int = 1000) -> bool:
    """Verify that a Möbius generator maps the disk into itself.

    Tests n_tests random points in the disk.
    """
    import random
    for _ in range(n_tests):
        r = random.random() * 0.999
        theta = random.random() * 2 * math.pi
        z = r * cmath.exp(1j * theta)
        w = gen.apply(z)
        if abs(w) >= 1.0 - 1e-12:
            return False
    return True
