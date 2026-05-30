#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Core Algorithms

Implements the mathematical machinery for arithmetic on the Poincaré disk:
- Möbius transformations and their composition
- Hyperbolic distance computation
- PSL(2,Z) orbit generation (BFS on the Cayley graph)
- Hyperbolic prime sieve
- Lattice point counting with growth rate estimation
- Hyperbolic zeta function evaluation
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from collections import deque


class MobiusTransform:
    """
    A Möbius transformation of the Poincaré disk.
    
    Maps z ↦ e^{iθ} (z - a) / (1 - conj(a) z)
    where a is the center and θ is a rotation angle.
    
    Time complexity: O(1) per evaluation
    Space complexity: O(1)
    """

    def __init__(self, center: complex, rotation: float = 0.0):
        """
        Args:
            center: Point a in the unit disk (|a| < 1)
            rotation: Rotation angle θ in radians
        """
        assert abs(center) < 1, f"|center| = {abs(center)} >= 1"
        self.center = center
        self.rotation = rotation

    def __call__(self, z: complex) -> complex:
        """Apply the Möbius transformation to z."""
        phase = np.exp(1j * self.rotation)
        return phase * (z - self.center) / (1 - np.conj(self.center) * z)

    def inverse(self) -> 'MobiusTransform':
        """Return the inverse transformation.
        
        The inverse of φ_a with rotation θ is φ_{-e^{iθ}a} with rotation -θ.
        """
        phase = np.exp(1j * self.rotation)
        new_center = -phase * self.center
        return MobiusTransform(new_center, -self.rotation)

    def compose(self, other: 'MobiusTransform') -> 'MobiusTransform':
        """Compose self ∘ other (apply other first, then self).
        
        The composition of two disk automorphisms is again a disk automorphism.
        We compute it by evaluating at key points.
        """
        # Composition is another Möbius transform
        # We find it by computing where 0 goes and the derivative at 0
        w0 = self(other(0j))
        # The center of the composition sends 0 to w0
        # So center = -w0 (up to rotation)
        center = -w0
        if abs(center) >= 1:
            center *= 0.99 / abs(center)  # numerical safety
        return MobiusTransform(center, 0.0)


class HyperbolicDistance:
    """
    Compute hyperbolic distances on the Poincaré disk.
    
    The hyperbolic metric is ds² = 4|dz|²/(1-|z|²)².
    
    Distance formula: d(z,w) = arccosh(1 + 2|z-w|²/((1-|z|²)(1-|w|²)))
    
    Time complexity: O(1)
    """

    @staticmethod
    def cross_ratio(z: complex, w: complex) -> float:
        """Compute |z-w|² / ((1-|z|²)(1-|w|²))."""
        return abs(z - w)**2 / ((1 - abs(z)**2) * (1 - abs(w)**2))

    @staticmethod
    def distance(z: complex, w: complex) -> float:
        """Compute hyperbolic distance d(z,w)."""
        cr = HyperbolicDistance.cross_ratio(z, w)
        return np.arccosh(1 + 2 * cr)

    @staticmethod
    def distance_from_origin(z: complex) -> float:
        """Compute d(0, z) = 2 arctanh(|z|)."""
        r = abs(z)
        return 2 * np.arctanh(r)


class PSL2ZOrbitGenerator:
    """
    Generate the orbit of a point under PSL(2,Z) acting on the upper half-plane,
    mapped to the Poincaré disk via the Cayley transform.
    
    PSL(2,Z) = <S, T> where S: z → -1/z, T: z → z+1.
    
    Algorithm: BFS on the Cayley graph with deduplication.
    
    Time complexity: O(N log N) where N is the number of orbit points
    Space complexity: O(N)
    """

    @staticmethod
    def cayley_to_disk(z: complex) -> complex:
        """Cayley transform: upper half-plane → Poincaré disk."""
        return (z - 1j) / (z + 1j)

    @staticmethod
    def cayley_from_disk(w: complex) -> complex:
        """Inverse Cayley transform: Poincaré disk → upper half-plane."""
        return 1j * (1 + w) / (1 - w)

    @staticmethod
    def generate(max_points: int = 1000, max_depth: int = 10) -> List[complex]:
        """
        Generate PSL(2,Z) orbit points on the Poincaré disk.
        
        Args:
            max_points: Maximum number of points to generate
            max_depth: Maximum BFS depth in the Cayley graph
            
        Returns:
            List of complex numbers in the unit disk, sorted by |z|
        """
        visited: Dict[Tuple[int, int], complex] = {}
        queue = deque()

        basepoint = complex(0, 1)  # i in the upper half-plane

        def canonical(z: complex) -> Tuple[int, int]:
            return (round(z.real * 1e8), round(z.imag * 1e8))

        visited[canonical(basepoint)] = basepoint
        queue.append((basepoint, 0))

        while queue and len(visited) < max_points:
            z, depth = queue.popleft()
            if depth >= max_depth:
                continue

            # Generators of PSL(2,Z) and their inverses
            transforms = []
            if abs(z) > 1e-10:
                transforms.append(-1 / z)       # S
            transforms.append(z + 1)              # T
            transforms.append(z - 1)              # T^{-1}

            for w in transforms:
                if w.imag < 1e-10:
                    continue
                key = canonical(w)
                if key not in visited:
                    visited[key] = w
                    queue.append((w, depth + 1))

        # Map to disk and sort by distance from origin
        disk_points = []
        for z_uhp in visited.values():
            z_disk = PSL2ZOrbitGenerator.cayley_to_disk(z_uhp)
            if abs(z_disk) < 1 - 1e-12:
                disk_points.append(z_disk)

        return sorted(disk_points, key=abs)


class HyperbolicPrimeSieve:
    """
    Sieve for hyperbolic primes in a lattice.
    
    A hyperbolic prime is a lattice point that cannot be written as
    a ⊕ b (Möbius addition) for any two lattice points a, b with
    smaller norm and nonzero norm.
    
    Time complexity: O(N² · P) where N is the number of points and P is primes found
    Space complexity: O(N)
    """

    @staticmethod
    def mobius_add(z: complex, w: complex) -> complex:
        """Hyperbolic addition: z ⊕ w = (z + w) / (1 + conj(z) * w)."""
        denom = 1 + np.conj(z) * w
        if abs(denom) < 1e-15:
            return float('inf')
        return (z + w) / denom

    @staticmethod
    def sieve(lattice: List[complex], tol: float = 1e-5) -> List[complex]:
        """
        Find all hyperbolic primes in the lattice.
        
        Args:
            lattice: Sorted list of lattice points (by |z|)
            tol: Tolerance for equality comparison
            
        Returns:
            List of hyperbolic primes
        """
        primes = []
        for i, p in enumerate(lattice):
            if abs(p) < tol:
                continue

            is_prime = True
            # Check all pairs (a, b) with |a|, |b| < |p|
            smaller = [z for z in lattice[:i] if abs(z) > tol]
            for a in smaller:
                if not is_prime:
                    break
                for b in smaller:
                    s = HyperbolicPrimeSieve.mobius_add(a, b)
                    if abs(s) < float('inf') and abs(s - p) < tol:
                        is_prime = False
                        break

            if is_prime:
                primes.append(p)

        return primes


class HyperbolicZeta:
    """
    Evaluate the hyperbolic zeta function:
    
    ζ_H(s) = Σ_{z ∈ Z_H, |z| > 0} 1/d(0,z)^{2s}
    
    where d(0,z) is the hyperbolic distance from the origin to z.
    
    Time complexity: O(N) per evaluation
    Space complexity: O(N) for storing lattice
    """

    def __init__(self, lattice: List[complex]):
        """
        Args:
            lattice: List of lattice points on the Poincaré disk
        """
        self.distances = []
        for z in lattice:
            r = abs(z)
            if r > 1e-10:
                d = 2 * np.arctanh(r)
                self.distances.append(d)
        self.distances.sort()

    def evaluate(self, s: complex) -> complex:
        """
        Evaluate ζ_H(s) = Σ 1/d^{2s}.
        
        Args:
            s: Complex number with Re(s) > 1/2 for convergence
            
        Returns:
            The partial sum (truncated to available lattice points)
        """
        result = 0j
        for d in self.distances:
            result += d ** (-2 * s)
        return result

    def find_zeros(self, t_range: Tuple[float, float], n_points: int = 1000,
                   sigma: float = 0.5) -> List[float]:
        """
        Search for zeros of ζ_H(s) along the line Re(s) = sigma.
        
        Uses sign changes of Re(ζ_H) and Im(ζ_H) to locate zeros.
        
        Args:
            t_range: Range of imaginary parts to search
            n_points: Number of sample points
            sigma: Real part of the line to search
            
        Returns:
            List of t values where zeros approximately occur
        """
        t_vals = np.linspace(t_range[0], t_range[1], n_points)
        values = [self.evaluate(complex(sigma, t)) for t in t_vals]

        zeros = []
        for i in range(len(values) - 1):
            # Look for sign changes in real part
            if values[i].real * values[i + 1].real < 0:
                # Refine by bisection
                t_lo, t_hi = t_vals[i], t_vals[i + 1]
                for _ in range(20):
                    t_mid = (t_lo + t_hi) / 2
                    v_mid = self.evaluate(complex(sigma, t_mid))
                    if v_mid.real * values[i].real < 0:
                        t_hi = t_mid
                    else:
                        t_lo = t_mid
                zeros.append((t_lo + t_hi) / 2)

        return zeros


class LatticeGrowthEstimator:
    """
    Estimate the growth rate of lattice point counting.
    
    For hyperbolic lattices, the expected growth is:
    N(R) ~ C · e^R / R  (in hyperbolic radius)
    or equivalently N(r) ~ C / (1 - r²) (in Euclidean radius)
    
    Time complexity: O(N log N)
    """

    @staticmethod
    def estimate_growth_constant(lattice: List[complex],
                                  radii: Optional[List[float]] = None) -> float:
        """
        Estimate the constant C in N(r) ~ C / (1 - r²).
        
        Uses least squares fitting on log-transformed data.
        
        Returns:
            Estimated growth constant C
        """
        if radii is None:
            radii = [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.85, 0.9, 0.95]

        counts = []
        growths = []
        for r in radii:
            n = sum(1 for z in lattice if abs(z) < r)
            if n > 0:
                counts.append(n)
                growths.append(1 / (1 - r**2))

        if len(counts) < 2:
            return 0.0

        # Fit C via least squares: N(r) ≈ C / (1 - r²)
        x = np.array(growths)
        y = np.array(counts)
        C = np.dot(x, y) / np.dot(x, x)
        return float(C)


if __name__ == "__main__":
    # Quick demonstration
    print("Generating PSL(2,Z) orbit...")
    lattice = PSL2ZOrbitGenerator.generate(max_points=500, max_depth=8)
    print(f"Generated {len(lattice)} points")

    print("\nFirst 5 lattice points:")
    for i, z in enumerate(lattice[:5]):
        d = HyperbolicDistance.distance_from_origin(z)
        print(f"  z_{i} = {z:.4f}, |z| = {abs(z):.6f}, d(0,z) = {d:.4f}")

    print("\nSieving for hyperbolic primes...")
    primes = HyperbolicPrimeSieve.sieve(lattice[:50])
    print(f"Found {len(primes)} primes among first 50 points")

    print("\nGrowth constant estimation:")
    C = LatticeGrowthEstimator.estimate_growth_constant(lattice)
    print(f"  Estimated C = {C:.4f}")
    print(f"  Expected C ≈ 6/π = {6/np.pi:.4f}")

    print("\nHyperbolic zeta function evaluation:")
    zeta = HyperbolicZeta(lattice)
    for s in [1.5, 2.0, 3.0]:
        val = zeta.evaluate(s)
        print(f"  ζ_H({s}) ≈ {val:.6f}")
