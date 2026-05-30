#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Core Algorithms

Implements the mathematical algorithms for arithmetic on the Poincaré disk:
1. Möbius transformation and its inverse
2. Hyperbolic addition (Einstein velocity addition)
3. Hyperbolic lattice generation
4. Hyperbolic prime sieve
5. Hyperbolic zeta function computation
6. Gauss circle embedding

All functions include type hints, docstrings, and complexity analysis.
"""

import numpy as np
from typing import List, Tuple, Optional, Set
from collections import defaultdict


# ─── Core Poincaré Disk Operations ───────────────────────────────────────

class PoincareDisk:
    """Represents arithmetic on the Poincaré disk model of hyperbolic geometry.

    The Poincaré disk D = {z ∈ ℂ : |z| < 1} with hyperbolic metric
    ds² = 4|dz|²/(1-|z|²)² models the hyperbolic plane H².

    Time complexity for basic operations: O(1)
    Space complexity: O(1)
    """

    @staticmethod
    def is_in_disk(z: complex, tol: float = 1e-10) -> bool:
        """Check if z is in the open unit disk."""
        return abs(z) < 1 - tol

    @staticmethod
    def mobius_map(a: complex, z: complex) -> complex:
        """Möbius automorphism φ_a(z) = (a - z) / (1 - conj(a) * z).

        Properties (proved in Lean):
        - φ_a(0) = a
        - φ_a(a) = 0
        - φ_a(φ_a(z)) = z (involution)
        - |z| < 1, |a| < 1 ⟹ |φ_a(z)| < 1 (disk preservation)

        Time: O(1), Space: O(1)
        """
        denom = 1 - a.conjugate() * z
        if abs(denom) < 1e-15:
            raise ValueError(f"Degenerate: 1 - conj(a)*z = 0 for a={a}, z={z}")
        return (a - z) / denom

    @staticmethod
    def hyp_add(a: complex, b: complex) -> complex:
        """Hyperbolic addition: a ⊕ b = (a + b) / (1 + conj(a) * b).

        This is equivalent to the Einstein velocity addition formula
        from special relativity (proved in Lean: einstein_velocity_is_hypAdd).

        Properties (proved in Lean):
        - 0 ⊕ b = b (left identity)
        - a ⊕ 0 = a (right identity)
        - a ⊕ (-a) = 0 (inverse)
        - NOT commutative for complex arguments (gyrogroup structure)

        Time: O(1), Space: O(1)
        """
        denom = 1 + a.conjugate() * b
        if abs(denom) < 1e-15:
            raise ValueError(f"Degenerate denominator for a={a}, b={b}")
        return (a + b) / denom

    @staticmethod
    def hyp_dist(z: complex, w: complex) -> float:
        """Hyperbolic distance d(z, w) = arctanh(|φ_w(z)|).

        Properties (proved in Lean):
        - d(z,z) = 0
        - d(z,w) = d(w,z) (symmetry)
        - d(z,w) ≥ 0

        Time: O(1), Space: O(1)
        """
        m = PoincareDisk.mobius_map(w, z)
        r = abs(m)
        if r >= 1:
            return float('inf')
        return np.arctanh(r)

    @staticmethod
    def hyp_dist_sq(z: complex, w: complex) -> float:
        """Squared Möbius pseudo-distance |φ_w(z)|².

        Time: O(1), Space: O(1)
        """
        m = PoincareDisk.mobius_map(w, z)
        return abs(m) ** 2


# ─── Hyperbolic Lattice Generation ───────────────────────────────────────

class HyperbolicLattice:
    """Generates and manages a hyperbolic lattice as the orbit of a basepoint
    under a discrete group of isometries.

    Algorithm: Breadth-first orbit generation
    Time: O(N * D) where N = number of generators, D = depth
    Space: O(|orbit|)
    """

    def __init__(self, generators: List[complex], basepoint: complex = 0.0,
                 min_separation: float = 0.01):
        """Initialize with a set of Möbius translation vectors.

        Args:
            generators: List of disk points defining Möbius translations
            basepoint: Starting point for orbit generation
            min_separation: Minimum distance between distinct lattice points
        """
        self.generators = generators
        self.basepoint = basepoint
        self.min_separation = min_separation
        self.points: List[complex] = []
        self.disk = PoincareDisk()

    def generate(self, depth: int = 6) -> List[complex]:
        """Generate lattice points via breadth-first orbit expansion.

        Algorithm:
        1. Start with {basepoint}
        2. For each frontier point, apply all generators via hyperbolic addition
        3. Add new points that are sufficiently separated from existing ones
        4. Repeat for `depth` iterations

        Time: O(|G|^depth) worst case, typically much less due to deduplication
        Space: O(|orbit|)
        """
        orbit_set: Set[int] = set()  # Hash-based dedup
        orbit: List[complex] = [self.basepoint]
        frontier: List[complex] = [self.basepoint]

        def _hash(z: complex) -> int:
            return hash((round(z.real, 4), round(z.imag, 4)))

        orbit_set.add(_hash(self.basepoint))

        for _ in range(depth):
            new_frontier: List[complex] = []
            for z in frontier:
                for g in self.generators:
                    for sign in [1, -1]:
                        try:
                            w = self.disk.hyp_add(complex(sign) * g, z)
                            if abs(w) < 0.999:
                                h = _hash(w)
                                if h not in orbit_set:
                                    orbit_set.add(h)
                                    orbit.append(w)
                                    new_frontier.append(w)
                        except ValueError:
                            pass
            frontier = new_frontier

        # Sort by hyperbolic distance from origin
        orbit.sort(key=lambda z: abs(z))
        self.points = orbit
        return orbit

    def counting_function(self, R: float) -> int:
        """Count lattice points within hyperbolic radius R from origin.

        Time: O(|orbit|), Space: O(1)
        """
        return sum(1 for p in self.points
                   if self.disk.hyp_dist(p, 0) <= R)


# ─── Hyperbolic Prime Sieve ─────────────────────────────────────────────

class HyperbolicPrimeSieve:
    """Identifies hyperbolic primes in a lattice.

    A lattice point p is hyperbolic prime if it cannot be written as
    p = a ⊕ b for any two non-zero lattice points a, b with smaller
    hyperbolic distance from the origin.

    Algorithm: Exhaustive sieve (analogous to trial division)
    Time: O(N³) where N = number of lattice points
    Space: O(N)
    """

    def __init__(self, lattice: HyperbolicLattice):
        self.lattice = lattice
        self.disk = PoincareDisk()

    def sieve(self, max_points: int = 50) -> Tuple[List[int], List[int]]:
        """Run the hyperbolic prime sieve.

        Returns: (prime_indices, composite_indices)
        Time: O(N³), Space: O(N)
        """
        points = self.lattice.points[:max_points]
        primes = []
        composites = []

        for n in range(len(points)):
            if abs(points[n]) < 1e-10:
                continue  # skip zero

            is_prime = True
            for i in range(n):
                if abs(points[i]) < 1e-10:
                    continue
                for j in range(n):
                    if abs(points[j]) < 1e-10:
                        continue
                    try:
                        s = self.disk.hyp_add(points[i], points[j])
                        if abs(s - points[n]) < 0.005:
                            is_prime = False
                            break
                    except ValueError:
                        pass
                if not is_prime:
                    break

            if is_prime:
                primes.append(n)
            else:
                composites.append(n)

        return primes, composites

    def prime_counting_function(self, R_values: List[float]) -> List[Tuple[float, int]]:
        """Compute π_H(R) for a list of radii.

        Time: O(len(R_values) * N³), Space: O(N)
        """
        primes, _ = self.sieve(len(self.lattice.points))
        prime_set = set(primes)
        result = []
        for R in R_values:
            count = 0
            for i in prime_set:
                if i < len(self.lattice.points):
                    d = self.disk.hyp_dist(self.lattice.points[i], 0)
                    if d <= R:
                        count += 1
            result.append((R, count))
        return result


# ─── Hyperbolic Zeta Function ────────────────────────────────────────────

class HyperbolicZeta:
    """Computes the partial hyperbolic zeta function.

    ζ_H(s, N) = Σ_{n=1}^{N} 1/d(p_n, 0)^{2s}

    where d is the hyperbolic distance.

    Time: O(N) per evaluation
    Space: O(1)
    """

    def __init__(self, lattice: HyperbolicLattice):
        self.lattice = lattice
        self.disk = PoincareDisk()
        # Precompute distances
        self.distances = []
        for p in lattice.points:
            d = self.disk.hyp_dist(p, 0)
            if d > 1e-10:
                self.distances.append(d)

    def evaluate(self, s: float, N: Optional[int] = None) -> float:
        """Evaluate ζ_H(s, N).

        Args:
            s: Complex exponent (real part)
            N: Number of terms (default: all)

        Time: O(N), Space: O(1)
        """
        if N is None:
            N = len(self.distances)
        total = 0.0
        for d in self.distances[:N]:
            total += d ** (-2 * s)
        return total

    def partial_sums(self, s: float, steps: int = 20) -> List[Tuple[int, float]]:
        """Compute partial sums for convergence analysis.

        Time: O(N), Space: O(steps)
        """
        result = []
        N_max = len(self.distances)
        for k in range(1, steps + 1):
            n = min(k * N_max // steps, N_max)
            if n > 0:
                result.append((n, self.evaluate(s, n)))
        return result


# ─── Gauss Circle Embedding ─────────────────────────────────────────────

def gauss_circle_count(R: int) -> int:
    """Count integer points (a,b) with a² + b² ≤ R².

    This is the classical Gauss circle problem.
    The answer is approximately πR².

    Time: O(R²), Space: O(1)
    """
    count = 0
    for a in range(-R, R + 1):
        for b in range(-R, R + 1):
            if a**2 + b**2 <= R**2:
                count += 1
    return count


def gauss_to_disk_embedding(R: int) -> List[complex]:
    """Embed Gauss circle lattice points into the Poincaré disk.

    Maps (a, b) ↦ (a + bi)/(R+1), which sends Z² ∩ B(0,R) into D.

    Proved in Lean: gauss_to_hyp_embedding shows |z|² < 1 for all embedded points.

    Time: O(R²), Space: O(R²)
    """
    points = []
    for a in range(-R, R + 1):
        for b in range(-R, R + 1):
            if a**2 + b**2 <= R**2:
                z = complex(a / (R + 1), b / (R + 1))
                points.append(z)
    return points


# ─── Example Usage ──────────────────────────────────────────────────────

if __name__ == "__main__":
    # Create a hyperbolic lattice
    generators = [
        0.1 + 0.0j,
        0.0 + 0.1j,
        0.15 * np.exp(1j * np.pi / 3),
        0.15 * np.exp(1j * 2 * np.pi / 3),
    ]
    lattice = HyperbolicLattice(generators)
    points = lattice.generate(depth=5)
    print(f"Generated {len(points)} lattice points")

    # Run prime sieve
    sieve = HyperbolicPrimeSieve(lattice)
    primes, composites = sieve.sieve(min(40, len(points)))
    print(f"Found {len(primes)} primes and {len(composites)} composites")

    # Compute zeta function
    zeta = HyperbolicZeta(lattice)
    for s in [1.0, 1.5, 2.0, 3.0]:
        val = zeta.evaluate(s, min(50, len(zeta.distances)))
        print(f"ζ_H({s}) ≈ {val:.6f}")

    # Gauss circle embedding
    for R in [5, 10, 20]:
        gc = gauss_circle_count(R)
        embedded = gauss_to_disk_embedding(R)
        max_norm = max(abs(z) for z in embedded)
        print(f"R={R}: {gc} points, max |z| in disk = {max_norm:.4f} < 1")
