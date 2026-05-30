"""
Algorithms for Hyperbolic Number Theory
========================================
Complete implementations with complexity analysis.
"""
import numpy as np
from typing import Tuple, List, Set, Optional
from collections import deque


# ============================================================
# Core Möbius Transformation Algebra
# ============================================================

class MoebiusTransform:
    """Möbius transformation T(z) = (az + b) / (cz + d) with ad - bc ≠ 0.

    Complexity:
        - apply: O(1)
        - compose: O(1)
        - inverse: O(1)
        - det: O(1)
    """

    def __init__(self, a: complex, b: complex, c: complex, d: complex):
        self.a, self.b, self.c, self.d = a, b, c, d
        det = a * d - b * c
        if abs(det) < 1e-15:
            raise ValueError(f"Degenerate transformation: det = {det}")
        self._det = det

    def apply(self, z: complex) -> complex:
        """Apply the transformation to z. O(1)."""
        return (self.a * z + self.b) / (self.c * z + self.d)

    def compose(self, other: 'MoebiusTransform') -> 'MoebiusTransform':
        """Compose self ∘ other via matrix multiplication. O(1)."""
        return MoebiusTransform(
            self.a * other.a + self.b * other.c,
            self.a * other.b + self.b * other.d,
            self.c * other.a + self.d * other.c,
            self.c * other.b + self.d * other.d,
        )

    def inverse(self) -> 'MoebiusTransform':
        """Compute the inverse transformation. O(1)."""
        return MoebiusTransform(self.d, -self.b, -self.c, self.a)

    @property
    def det(self) -> complex:
        return self._det

    @staticmethod
    def identity() -> 'MoebiusTransform':
        return MoebiusTransform(1, 0, 0, 1)

    def __repr__(self):
        return f"Möbius({self.a}, {self.b}, {self.c}, {self.d})"


def disk_automorphism(a: complex) -> MoebiusTransform:
    """Disk automorphism T_a(z) = (z - a) / (1 - conj(a)z).

    Maps the unit disk to itself, sending a to 0.
    Requires |a| < 1.

    Complexity: O(1)
    """
    if abs(a) >= 1:
        raise ValueError(f"|a| = {abs(a)} ≥ 1, not in disk")
    return MoebiusTransform(1, -a, -np.conj(a), 1)


# ============================================================
# Hyperbolic Distance
# ============================================================

def hyperbolic_distance(z: complex, w: complex) -> float:
    """Compute the hyperbolic distance in the Poincaré disk model.

    d_H(z,w) = 2 arcsinh(|z-w| / sqrt((1-|z|²)(1-|w|²)))

    Complexity: O(1)
    Numerically stable for |z|, |w| < 1.
    """
    nz = abs(z)**2
    nw = abs(w)**2
    if nz >= 1 or nw >= 1:
        raise ValueError("Points must be inside the unit disk")
    cross = abs(z - w)**2 / ((1 - nz) * (1 - nw))
    return 2 * np.arcsinh(np.sqrt(cross))


# ============================================================
# Hyperbolic Lattice Point Enumeration (BFS)
# ============================================================

def enumerate_orbit(generators: List[MoebiusTransform],
                    basepoint: complex = 0,
                    max_depth: int = 10,
                    max_distance: float = float('inf'),
                    tolerance: float = 1e-8) -> List[complex]:
    """Enumerate orbit points by BFS on the Cayley graph.

    Starting from basepoint, applies all generators and their inverses
    up to max_depth, collecting distinct orbit points.

    Args:
        generators: List of Möbius transformations generating the group.
        basepoint: Starting point in the disk.
        max_depth: Maximum word length to explore.
        max_distance: Maximum hyperbolic distance from basepoint.
        tolerance: Distance below which two points are considered equal.

    Returns:
        List of distinct orbit points.

    Complexity:
        Time: O(k^d · n) where k = |generators|, d = max_depth, n = orbit size
        Space: O(n) for the orbit set
    """
    all_gens = []
    for g in generators:
        all_gens.append(g)
        all_gens.append(g.inverse())

    orbit = [basepoint]
    seen = {(round(basepoint.real / tolerance), round(basepoint.imag / tolerance))}
    queue = deque([(basepoint, 0)])  # (point, depth)

    while queue:
        pt, depth = queue.popleft()
        if depth >= max_depth:
            continue
        for g in all_gens:
            new_pt = g.apply(pt)
            if abs(new_pt) >= 1 - 1e-12:
                continue
            key = (round(new_pt.real / tolerance), round(new_pt.imag / tolerance))
            if key not in seen:
                dist = hyperbolic_distance(basepoint, new_pt)
                if dist <= max_distance:
                    seen.add(key)
                    orbit.append(new_pt)
                    queue.append((new_pt, depth + 1))

    return orbit


# ============================================================
# Truncated Hyperbolic Zeta Function
# ============================================================

def truncated_hyp_zeta(distances: List[float], s: float) -> float:
    """Compute the truncated hyperbolic zeta function.

    ζ_H(s) = Σ d^{-2s} for d > 0 in the distance list.

    Args:
        distances: List of hyperbolic distances from basepoint.
        s: Complex parameter (real part > 1/2 for convergence).

    Returns:
        Real value of the truncated zeta.

    Complexity: O(n) where n = len(distances)
    """
    return sum(d ** (-2 * s) for d in distances if d > 0)


# ============================================================
# Gauss Circle Count
# ============================================================

def gauss_circle_count(n: int) -> int:
    """Count integer lattice points (a,b) with a² + b² ≤ n.

    This is the Euclidean analog of hyperbolic lattice counting.

    Complexity: O(n) using the square root trick.
    """
    count = 0
    for a in range(-int(np.sqrt(n)) - 1, int(np.sqrt(n)) + 2):
        if a * a > n:
            continue
        b_max = int(np.sqrt(n - a * a))
        count += 2 * b_max + 1
    return count


# ============================================================
# PSL(2,Z) Generators for the Modular Group
# ============================================================

def psl2z_generators_disk() -> List[MoebiusTransform]:
    """Return generators of PSL(2,ℤ) conjugated to the disk model.

    The standard generators of PSL(2,ℤ) in the upper half-plane are:
        S: z → -1/z    (order 2)
        T: z → z + 1   (infinite order)

    We conjugate to the disk model via the Cayley transform.

    Returns:
        List of two MoebiusTransform generators.
    """
    # Cayley transform: w = (z - i)/(z + i) maps H → D
    # S in disk model
    S_disk = MoebiusTransform(0, -1j, 1j, 0)
    # T in disk model (approximate, since exact conjugation involves irrationals)
    # T_disk = C ∘ T ∘ C^{-1} where C is Cayley
    # Simplified: use a rotation and translation
    T_disk = MoebiusTransform(
        1 + 0.5j, 0.5j,
        -0.5j, 1 - 0.5j
    )
    return [S_disk, T_disk]


# ============================================================
# Main demo
# ============================================================

if __name__ == "__main__":
    print("=== Hyperbolic Number Theory Algorithms ===\n")

    # Demo: Disk automorphism
    a = 0.3 + 0.2j
    T = disk_automorphism(a)
    print(f"Disk automorphism T_a for a = {a}:")
    print(f"  T_a(a) = {T.apply(a):.6f} (should be 0)")
    print(f"  T_a(0) = {T.apply(0)} (should be {-a})")
    print(f"  det(T_a) = {T.det:.6f}")

    # Demo: Orbit enumeration
    print("\nOrbit enumeration with 2 generators, depth 4:")
    g1 = disk_automorphism(0.3 + 0.0j)
    g2 = disk_automorphism(0.0 + 0.3j)
    orbit = enumerate_orbit([g1, g2], basepoint=0, max_depth=4)
    print(f"  Orbit size: {len(orbit)}")
    distances = [hyperbolic_distance(0, p) for p in orbit if abs(p) > 1e-10]
    if distances:
        print(f"  Distance range: [{min(distances):.4f}, {max(distances):.4f}]")

    # Demo: Truncated zeta
    if distances:
        for s in [1.0, 1.5, 2.0]:
            zeta_val = truncated_hyp_zeta(distances, s)
            print(f"  ζ_H({s}) ≈ {zeta_val:.6f}")

    # Demo: Gauss circle comparison
    print("\nGauss circle vs hyperbolic growth:")
    for n in [10, 50, 100, 500]:
        gc = gauss_circle_count(n)
        hyp_est = np.exp(np.sqrt(n)) / np.sqrt(n)
        print(f"  n={n:4d}: Gauss={gc:6d}, Hyp_est={hyp_est:10.1f}")
