"""
Algorithms for Hyperbolic Number Theory
========================================

Implements core algorithms for arithmetic on the Poincaré disk:
1. Möbius transformation composition
2. Hyperbolic distance computation
3. Orbit generation for hyperbolic lattices
4. Primitive word (hyperbolic prime) counting
5. Hyperbolic lattice point counting

Time/Space complexity annotations included.
"""

import math
from typing import List, Tuple, Set, Optional
from itertools import product


class DiskPoint:
    """A point in the Poincaré disk {(x,y) : x² + y² < 1}."""

    def __init__(self, x: float, y: float):
        self.x = x
        self.y = y

    @property
    def norm_sq(self) -> float:
        return self.x**2 + self.y**2

    @property
    def norm(self) -> float:
        return math.sqrt(self.norm_sq)

    def hyp_norm(self) -> float:
        """Hyperbolic distance from origin: 2·artanh(|z|)."""
        r = self.norm
        if r >= 1.0:
            return float('inf')
        return math.log((1 + r) / (1 - r))

    def __repr__(self):
        return f"({self.x:.4f}, {self.y:.4f})"


def moebius_translate(a: DiskPoint, z: DiskPoint) -> DiskPoint:
    """
    Apply Möbius translation T_a(z) = (z - a) / (1 - ā·z).

    Time: O(1)
    Space: O(1)

    Args:
        a: Center point (must be in disk)
        z: Point to transform (must be in disk)

    Returns:
        T_a(z), guaranteed to be in the disk.
    """
    denom = (1 - a.x*z.x - a.y*z.y)**2 + (a.x*z.y - a.y*z.x)**2
    if denom < 1e-15:
        raise ValueError("Degenerate Möbius transformation")

    rx = ((z.x - a.x)*(1 - a.x*z.x - a.y*z.y)
          + (z.y - a.y)*(a.x*z.y - a.y*z.x)) / denom
    ry = ((z.y - a.y)*(1 - a.x*z.x - a.y*z.y)
          - (z.x - a.x)*(a.x*z.y - a.y*z.x)) / denom
    return DiskPoint(rx, ry)


def hyp_distance(p: DiskPoint, q: DiskPoint) -> float:
    """
    Compute hyperbolic distance between two disk points.

    Uses: d_H(p,q) = 2·artanh(|T_p(q)|) where T_p is translation by p.

    Time: O(1)
    Space: O(1)
    """
    w = moebius_translate(p, q)
    return w.hyp_norm()


def generate_orbit(generators: List[DiskPoint], max_depth: int) -> List[DiskPoint]:
    """
    Generate the orbit of the origin under iterated Möbius translations.

    Time: O(k^d) where k = #generators, d = max_depth
    Space: O(k^d)

    Args:
        generators: List of disk points defining translations
        max_depth: Maximum word length

    Returns:
        List of orbit points (with possible duplicates near boundary).
    """
    origin = DiskPoint(0.0, 0.0)
    orbit = [origin]
    current_layer = [origin]

    for depth in range(max_depth):
        next_layer = []
        for point in current_layer:
            for gen in generators:
                new_point = moebius_translate(gen, point)
                if new_point.norm < 0.9999:  # Stay safely in disk
                    next_layer.append(new_point)
        orbit.extend(next_layer)
        current_layer = next_layer

    return orbit


def count_primitive_words(k: int, n: int) -> int:
    """
    Count primitive (Lyndon) words of length n over k-letter alphabet.

    Uses Witt's formula: L(k, n) = (1/n) Σ_{d|n} μ(n/d) · k^d

    Time: O(n · √n) for divisor enumeration
    Space: O(n)

    Args:
        k: Alphabet size (≥ 2)
        n: Word length (≥ 1)

    Returns:
        Number of primitive words (Lyndon words) of length n.
    """
    def mobius(m: int) -> int:
        """Möbius function μ(m)."""
        if m == 1:
            return 1
        factors = set()
        temp = m
        for p in range(2, int(math.sqrt(m)) + 1):
            if temp % p == 0:
                factors.add(p)
                temp //= p
                if temp % p == 0:
                    return 0  # p² divides m
        if temp > 1:
            factors.add(temp)
        return (-1) ** len(factors)

    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += mobius(n // d) * k**d

    return total // n


def lattice_points_in_ball(R: int) -> List[Tuple[int, int]]:
    """
    Enumerate all integer lattice points (a, b) with a² + b² ≤ R².

    Time: O(R²)
    Space: O(R²)

    Args:
        R: Radius of the ball

    Returns:
        List of (a, b) pairs.
    """
    points = []
    for a in range(-R, R + 1):
        for b in range(-R, R + 1):
            if a**2 + b**2 <= R**2:
                points.append((a, b))
    return points


def project_to_disk(a: int, b: int) -> DiskPoint:
    """
    Project integer lattice point to Poincaré disk via (a,b)/(√(a²+b²)+1).

    Time: O(1)
    Space: O(1)
    """
    r = math.sqrt(a**2 + b**2)
    if r == 0:
        return DiskPoint(0, 0)
    scale = r / (r + 1)
    return DiskPoint(a * scale / r, b * scale / r)


def poincare_conformal_factor(r: float) -> float:
    """
    Compute the conformal factor λ(r) = 2/(1 - r²) of the Poincaré metric.

    Time: O(1)
    """
    assert 0 <= r < 1
    return 2.0 / (1 - r**2)


def triangle_defect(alpha: float, beta: float, gamma: float) -> float:
    """
    Compute the angular defect (= hyperbolic area) of a triangle.

    Time: O(1)
    """
    return math.pi - (alpha + beta + gamma)


# --- Demonstration ---

if __name__ == "__main__":
    print("Primitive word counts (k=2):")
    print(f"{'n':>4} {'Lyndon(2,n)':>12} {'2^n/n':>10} {'Ratio':>8}")
    for n in range(1, 21):
        count = count_primitive_words(2, n)
        expected = 2**n / n
        ratio = count / expected if expected > 0 else 0
        print(f"{n:4d} {count:12d} {expected:10.1f} {ratio:8.4f}")

    print("\nLattice point counts vs π·R²:")
    for R in [5, 10, 20, 50, 100]:
        points = lattice_points_in_ball(R)
        density = len(points) / R**2
        print(f"  R={R:3d}: {len(points):6d} points, "
              f"count/R² = {density:.6f} (π ≈ {math.pi:.6f})")
