"""
Algorithms for Hyperbolic Number Theory
========================================
Implements core algorithms for arithmetic on the Poincaré disk,
orbit computation, and lattice point counting.
"""

import cmath
import math
from typing import Optional


class MobiusAutomorphism:
    """A Möbius automorphism of the Poincaré disk.

    Represents the map z ↦ e^{iθ} · (z - a) / (1 - conj(a) · z)
    where |a| < 1.

    Time complexity: O(1) per evaluation.
    Space complexity: O(1).
    """

    def __init__(self, center: complex, phase: float):
        """
        Args:
            center: Point a in the disk (|a| < 1)
            phase: Rotation angle θ

        Raises:
            ValueError: If |center| >= 1
        """
        if abs(center) >= 1.0:
            raise ValueError(f"|center| = {abs(center):.6f} >= 1, must be in open disk")
        self.center = center
        self.phase = phase
        self._exp_phase = cmath.exp(1j * phase)

    def __call__(self, z: complex) -> complex:
        """Apply the Möbius transformation.

        Args:
            z: Point in the disk

        Returns:
            Image of z under the transformation

        Complexity: O(1) arithmetic operations
        """
        denom = 1 - self.center.conjugate() * z
        return self._exp_phase * (z - self.center) / denom

    def inverse(self) -> 'MobiusAutomorphism':
        """Compute the inverse transformation.

        The inverse of z ↦ e^{iθ}(z-a)/(1-ā·z) is
        z ↦ (e^{-iθ}·z + a) / (1 + ā·e^{-iθ}·z),
        which equals z ↦ e^{-iθ}·(z - (-e^{iθ}·a)) / (1 - conj(-e^{iθ}·a)·z).

        Returns:
            The inverse MobiusAutomorphism

        Complexity: O(1)
        """
        new_center = -self._exp_phase * self.center
        new_phase = -self.phase
        return MobiusAutomorphism(new_center, new_phase)

    def compose(self, other: 'MobiusAutomorphism') -> 'MobiusAutomorphism':
        """Approximate composition by sampling.

        Note: The composition of two Möbius disk automorphisms is another
        Möbius disk automorphism, but extracting the parameters requires
        solving a system. Here we use a numerical approach.

        Returns:
            Approximate MobiusAutomorphism representing self ∘ other
        """
        # Evaluate at origin to find the new center
        new_center_neg = self(other(0j))
        # The center is the preimage of 0
        inv_self = self.inverse()
        inv_other = other.inverse()
        center = inv_other(inv_self(0j))
        # Phase from evaluating at a test point
        if abs(center) < 1 - 1e-10:
            test = center + 0.01 * (1 - abs(center))
            actual = self(other(test))
            expected_no_phase = (test - center) / (1 - center.conjugate() * test)
            if abs(expected_no_phase) > 1e-12:
                phase_complex = actual / expected_no_phase
                phase = cmath.phase(phase_complex)
            else:
                phase = 0.0
            return MobiusAutomorphism(center, phase)
        else:
            return MobiusAutomorphism(0j, 0.0)


class HyperbolicAddition:
    """Einstein/hyperbolic addition on the Poincaré disk.

    The operation z ⊕ w = (z + w) / (1 + conj(z)·w) gives the disk
    the structure of a gyrogroup (non-associative, non-commutative
    group-like structure).

    This is mathematically identical to the relativistic velocity
    addition formula in special relativity.
    """

    @staticmethod
    def add(z: complex, w: complex) -> complex:
        """Hyperbolic addition.

        Args:
            z, w: Points in the disk (|z|, |w| < 1)

        Returns:
            z ⊕ w in the disk

        Complexity: O(1)
        """
        return (z + w) / (1 + z.conjugate() * w)

    @staticmethod
    def neg(z: complex) -> complex:
        """Hyperbolic negation (inverse).

        The hyperbolic inverse of z is -z.

        Complexity: O(1)
        """
        return -z

    @staticmethod
    def is_in_disk(z: complex, tol: float = 1e-12) -> bool:
        """Check if a point is in the open unit disk."""
        return abs(z) < 1.0 - tol

    @classmethod
    def verify_closure(cls, z: complex, w: complex) -> tuple[complex, bool]:
        """Verify that z ⊕ w is in the disk.

        Returns:
            Tuple of (result, is_in_disk)
        """
        result = cls.add(z, w)
        return result, cls.is_in_disk(result)

    @classmethod
    def gyration(cls, z: complex, w: complex, x: complex) -> complex:
        """The gyration operator gyr[z,w](x).

        The gyration measures the failure of associativity:
        z ⊕ (w ⊕ x) = (z ⊕ w) ⊕ gyr[z,w](x)

        Complexity: O(1)
        """
        zw = cls.add(z, w)
        zwx = cls.add(zw, x)
        wx = cls.add(w, x)
        z_wx = cls.add(z, wx)
        # gyr[z,w](x) satisfies (z⊕w)⊕gyr[z,w](x) = z⊕(w⊕x)
        # So gyr[z,w](x) = ⊖(z⊕w) ⊕ (z⊕(w⊕x))
        return cls.add(cls.neg(zw), z_wx)


class HyperbolicLattice:
    """Generate and analyze hyperbolic lattice points.

    Given a Möbius automorphism as generator, produces the orbit of
    the origin and computes counting statistics.

    Algorithm: Iterative Möbius application
    Time complexity: O(N) to generate N orbit points
    Space complexity: O(N) to store all points
    """

    def __init__(self, generator: MobiusAutomorphism):
        self.generator = generator
        self._orbit: list[complex] = [0j]

    def generate(self, n: int) -> list[complex]:
        """Generate n orbit points starting from origin.

        Args:
            n: Number of orbit points to generate

        Returns:
            List of n complex points in the disk

        Complexity: O(n) time, O(n) space
        """
        while len(self._orbit) < n:
            self._orbit.append(self.generator(self._orbit[-1]))
        return self._orbit[:n]

    def counting_function(self, r: float, n: Optional[int] = None) -> int:
        """Count orbit points within Euclidean radius r.

        Args:
            r: Euclidean radius
            n: Number of orbit points to consider (default: all generated)

        Returns:
            Count of points with |p| ≤ r

        Complexity: O(n)
        """
        pts = self._orbit if n is None else self._orbit[:n]
        return sum(1 for p in pts if abs(p) <= r)

    def hyperbolic_distance_distribution(self, n: int) -> list[float]:
        """Compute the hyperbolic distance proxy from origin for each orbit point.

        Returns:
            List of distance proxies |p|²/(1-|p|²) for each point

        Complexity: O(n)
        """
        pts = self.generate(n)
        dists = []
        for p in pts:
            r2 = abs(p) ** 2
            if r2 < 1:
                dists.append(r2 / (1 - r2))
            else:
                dists.append(float('inf'))
        return dists


class HyperbolicZeta:
    """Numerical computation of the hyperbolic zeta function.

    ζ_H(s) = Σ_{n ∈ Z_H, |n|_H > 0} 1/|n|_H^{2s}

    where |n|_H is the hyperbolic distance proxy from the origin.

    Algorithm: Direct summation with convergence monitoring
    Time complexity: O(N) per evaluation for N terms
    Convergence: For Re(s) > 1, convergence is geometric
    """

    def __init__(self, lattice: HyperbolicLattice):
        self.lattice = lattice

    def evaluate(self, s: complex, n_terms: int = 100) -> complex:
        """Evaluate ζ_H(s) using the first n_terms lattice points.

        Args:
            s: Complex argument
            n_terms: Number of terms in partial sum

        Returns:
            Partial sum approximation to ζ_H(s)

        Complexity: O(n_terms)
        """
        pts = self.lattice.generate(n_terms)
        total = 0j
        for p in pts:
            r = abs(p)
            if r > 1e-12:
                hyp_norm = r ** 2 / (1 - r ** 2) if r < 1 else 1e10
                if hyp_norm > 1e-12:
                    total += hyp_norm ** (-s)
        return total

    def partial_sums(self, s: complex, n_max: int = 100) -> list[complex]:
        """Track partial sums for convergence analysis.

        Returns:
            List of cumulative partial sums

        Complexity: O(n_max)
        """
        pts = self.lattice.generate(n_max)
        sums = []
        total = 0j
        for p in pts:
            r = abs(p)
            if r > 1e-12 and r < 1:
                hyp_norm = r ** 2 / (1 - r ** 2)
                if hyp_norm > 1e-12:
                    total += hyp_norm ** (-s)
            sums.append(total)
        return sums


def demo_algorithms():
    """Demonstrate all algorithms with examples."""
    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)

    # 1. Möbius automorphism
    print("\n1. Möbius Automorphism")
    phi = MobiusAutomorphism(0.3 + 0.2j, math.pi / 4)
    z = 0.1 + 0.5j
    w = phi(z)
    print(f"   φ(z) = {w:.6f}, |φ(z)| = {abs(w):.6f}")

    # Inverse
    phi_inv = phi.inverse()
    z_back = phi_inv(w)
    print(f"   φ⁻¹(φ(z)) = {z_back:.6f} ≈ {z}")

    # 2. Hyperbolic addition
    print("\n2. Hyperbolic Addition (Gyrogroup)")
    ha = HyperbolicAddition()
    z, w = 0.3 + 0.1j, 0.2 - 0.3j
    print(f"   z ⊕ w = {ha.add(z, w):.6f}")
    print(f"   w ⊕ z = {ha.add(w, z):.6f}")
    print(f"   (non-commutative: diff = {abs(ha.add(z, w) - ha.add(w, z)):.6f})")

    gyr = ha.gyration(z, w, 0.1 + 0.1j)
    print(f"   gyr[z,w](0.1+0.1i) = {gyr:.6f}")

    # 3. Lattice generation
    print("\n3. Hyperbolic Lattice")
    gen = MobiusAutomorphism(0.5, math.pi / 3)
    lattice = HyperbolicLattice(gen)
    pts = lattice.generate(100)
    print(f"   Generated 100 orbit points")
    print(f"   N(0.5) = {lattice.counting_function(0.5)}")
    print(f"   N(0.9) = {lattice.counting_function(0.9)}")
    print(f"   N(0.99) = {lattice.counting_function(0.99)}")

    # 4. Hyperbolic zeta
    print("\n4. Hyperbolic Zeta Function")
    zeta = HyperbolicZeta(lattice)
    for s_real in [2.0, 3.0, 5.0]:
        val = zeta.evaluate(complex(s_real, 0), 200)
        print(f"   ζ_H({s_real}) ≈ {val:.6f}")

    print("\n" + "=" * 60)


if __name__ == "__main__":
    demo_algorithms()
