"""
Algorithms for Hyperbolic Number Theory

Implements the core algorithms from the research paper:
1. Möbius automorphism computation
2. Hyperbolic distance calculation
3. Hyperbolic lattice point enumeration
4. Growth function computation
5. Hyperbolic zeta function partial sums
"""

import numpy as np
from typing import List, Tuple, Optional
from enum import Enum


class HypGenerator(Enum):
    """Generators of the modular group PSL(2,Z)."""
    S = "S"  # Order 2 generator
    T = "T"  # Order 3 generator


# Type aliases
HypWord = List[HypGenerator]
DiskPoint = complex  # Complex number with |z| < 1


def is_disk_point(z: complex, tol: float = 1e-10) -> bool:
    """Check if z is in the open unit disk.

    Args:
        z: Complex number to check
        tol: Tolerance for boundary

    Returns:
        True if |z|² < 1 - tol

    >>> is_disk_point(0.3 + 0.4j)
    True
    >>> is_disk_point(1.0 + 0.0j)
    False
    """
    return abs(z)**2 < 1 - tol


def moebius_map(a: DiskPoint, z: DiskPoint) -> DiskPoint:
    """Compute the Möbius automorphism φ_a(z) = (z - a) / (1 - conj(a)*z).

    This is an automorphism of the unit disk that sends a to 0.
    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        a: Center point in the disk
        z: Point to transform

    Returns:
        The image φ_a(z), guaranteed to be in the disk if both inputs are.

    >>> abs(moebius_map(0.3+0.4j, 0.3+0.4j)) < 1e-10
    True
    >>> abs(moebius_map(0.3+0.4j, 0) - (-0.3-0.4j)) < 1e-10
    True
    """
    denom = 1 - a.conjugate() * z
    return (z - a) / denom


def pseudo_hyp_dist_sq(z: DiskPoint, w: DiskPoint) -> float:
    """Compute the squared pseudo-hyperbolic distance.

    d²(z,w) = |z - w|² / |1 - conj(w)*z|²

    This equals |φ_w(z)|² and satisfies 0 ≤ d² < 1 for disk points.
    Time complexity: O(1)

    Args:
        z, w: Points in the unit disk

    Returns:
        The squared pseudo-hyperbolic distance, in [0, 1).

    >>> pseudo_hyp_dist_sq(0.3+0.4j, 0.3+0.4j) < 1e-10
    True
    """
    return abs(moebius_map(w, z))**2


def hyperbolic_distance(z: DiskPoint, w: DiskPoint) -> float:
    """Compute the true hyperbolic distance using the Poincaré metric.

    d(z,w) = 2 * arctanh(|φ_w(z)|) = log((1+r)/(1-r)) where r = |φ_w(z)|.
    Time complexity: O(1)

    Args:
        z, w: Points in the unit disk

    Returns:
        The hyperbolic distance, in [0, ∞).

    >>> hyperbolic_distance(0+0j, 0+0j) < 1e-10
    True
    """
    r = abs(moebius_map(w, z))
    if r >= 1:
        return float('inf')
    return 2 * np.arctanh(r)


def hyp_growth(n: int) -> int:
    """Compute the growth function for the hyperbolic lattice.

    hypGrowth(0) = 1
    hypGrowth(n+1) = hypGrowth(n) + 2 * 3^n

    Closed form: hypGrowth(n) = 3^n for n ≥ 1.
    Time complexity: O(1) using closed form

    Args:
        n: Non-negative integer (radius in Cayley graph)

    Returns:
        Number of lattice points in ball of radius n.

    >>> hyp_growth(0)
    1
    >>> hyp_growth(5) == 3**5
    True
    """
    if n == 0:
        return 1
    return 3**n


def hyp_growth_recursive(n: int) -> int:
    """Recursive computation of growth function (for verification).

    Time complexity: O(n)

    >>> all(hyp_growth(k) == hyp_growth_recursive(k) for k in range(20))
    True
    """
    if n == 0:
        return 1
    return hyp_growth_recursive(n - 1) + 2 * 3**(n - 1)


def prim_word_count(n: int) -> int:
    """Count primitive (cyclically reduced) words of length n.

    These are the "hyperbolic primes" — the analog of prime numbers
    in hyperbolic arithmetic.

    Time complexity: O(1)

    Args:
        n: Word length

    Returns:
        Number of primitive words of length n.

    >>> prim_word_count(0)
    0
    >>> prim_word_count(1)
    2
    >>> prim_word_count(5) == 2 * 3**4
    True
    """
    if n == 0:
        return 0
    if n == 1:
        return 2
    return 2 * 3**(n - 1)


def enumerate_words(max_length: int) -> List[HypWord]:
    """Enumerate all words in {S, T} up to given length.

    Time complexity: O(2^max_length)
    Space complexity: O(2^max_length)

    Args:
        max_length: Maximum word length

    Returns:
        List of all words up to max_length.
    """
    words: List[HypWord] = [[]]
    for length in range(1, max_length + 1):
        for word in [w for w in words if len(w) == length - 1]:
            words.append(word + [HypGenerator.S])
            words.append(word + [HypGenerator.T])
    return words


def kesten_bound(d: int) -> float:
    """Compute the Kesten spectral radius bound.

    For a Cayley graph with d generators, ρ ≤ √(2d-1)/d.
    Time complexity: O(1)

    Args:
        d: Number of generators (positive integer)

    Returns:
        The Kesten bound.

    >>> kesten_bound(2) - np.sqrt(3)/2 < 1e-10
    True
    """
    return np.sqrt(2 * d - 1) / d


def hyp_zeta_partial(s: float, N: int) -> float:
    """Compute partial sum of the hyperbolic zeta function.

    ζ_H(s, N) = Σ_{n=1}^{N} 3^n / n^(2s)

    Time complexity: O(N)

    Args:
        s: Real parameter (should be > 0 for convergence analysis)
        N: Number of terms

    Returns:
        The partial sum.
    """
    return sum(3**n / n**(2*s) for n in range(1, N + 1))


def verify_fundamental_identity(a: complex, z: complex) -> Tuple[float, float, float]:
    """Verify the fundamental algebraic identity.

    Returns (LHS, RHS, error).

    >>> lhs, rhs, err = verify_fundamental_identity(0.3+0.4j, 0.1-0.2j)
    >>> err < 1e-12
    True
    """
    denom = 1 - a.conjugate() * z
    lhs = abs(denom)**2 - abs(z - a)**2
    rhs = (1 - abs(z)**2) * (1 - abs(a)**2)
    return lhs, rhs, abs(lhs - rhs)


def find_geodesic_midpoint(z: DiskPoint, w: DiskPoint,
                            max_iter: int = 100) -> DiskPoint:
    """Find the geodesic midpoint between z and w in hyperbolic geometry.

    Uses bisection on the geodesic arc.
    Time complexity: O(max_iter)

    Args:
        z, w: Points in the unit disk
        max_iter: Maximum iterations for bisection

    Returns:
        Approximate geodesic midpoint m such that d(z,m) ≈ d(m,w).
    """
    # Map w to 0 via φ_w, find midpoint in normalized coords, map back
    z_norm = moebius_map(w, z)

    # Midpoint in normalized coords: scale z_norm by factor
    # such that d(0, m_norm) = d(0, z_norm) / 2
    r = abs(z_norm)
    if r < 1e-15:
        return w

    # d(0, z_norm) = 2 arctanh(r)
    # Want d(0, m) = arctanh(r), so |m| = tanh(arctanh(r)/1) is wrong
    # Actually: half-distance = arctanh(r), want tanh(arctanh(r)/1)
    half_d = np.arctanh(r)
    m_r = np.tanh(half_d / 2)

    # Scale z_norm to have modulus m_r
    m_norm = z_norm / r * m_r

    # Map back via φ_w inverse = φ_{-w} ... actually φ_w is an involution
    # φ_w(φ_w(z)) = z for Möbius maps
    # Actually not quite: need to map back via φ_{-w} or use φ_w again
    midpoint = moebius_map(-w / (1 - abs(w)**2 * 0), m_norm)

    # More correctly: φ_w is self-inverse: φ_w(φ_w(z)) = z
    midpoint = moebius_map(w, m_norm)  # This inverts: φ_w(φ_w(z)) should give z back... not quite

    # Actually φ_a is an involution: φ_a ∘ φ_a = id
    # So to invert, just apply φ_w again
    # But φ_w maps w->0, and φ_w(0) = -w ≠ w (unless w=0)
    # The correct inverse is: φ_{-a}(z) with different parametrization

    # Simpler: the inverse of z -> (z-a)/(1-āz) is z -> (z+a)/(1+āz)
    def moebius_inv(a, z):
        return (z + a) / (1 + a.conjugate() * z)

    midpoint = moebius_inv(w, m_norm)
    return midpoint


if __name__ == "__main__":
    # Quick self-test
    print("Running algorithm self-tests...")

    # Test fundamental identity
    for _ in range(100):
        a = (np.random.randn() + 1j * np.random.randn()) * 0.4
        z = (np.random.randn() + 1j * np.random.randn()) * 0.4
        _, _, err = verify_fundamental_identity(a, z)
        assert err < 1e-10, f"Identity failed: err={err}"

    # Test disk preservation
    for _ in range(100):
        a = (np.random.randn() + 1j * np.random.randn()) * 0.4
        z = (np.random.randn() + 1j * np.random.randn()) * 0.4
        w = moebius_map(a, z)
        assert abs(w)**2 < 1, f"Disk preservation failed: |w|²={abs(w)**2}"

    # Test growth closed form
    for n in range(1, 20):
        assert hyp_growth(n) == hyp_growth_recursive(n)

    # Test symmetry
    for _ in range(100):
        z = (np.random.randn() + 1j * np.random.randn()) * 0.4
        w = (np.random.randn() + 1j * np.random.randn()) * 0.4
        d1 = pseudo_hyp_dist_sq(z, w)
        d2 = pseudo_hyp_dist_sq(w, z)
        assert abs(d1 - d2) < 1e-10, f"Symmetry failed: {d1} vs {d2}"

    print("All self-tests passed!")
