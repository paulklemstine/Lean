"""
Hyperbolic Number Theory: Core Algorithms

Implements the mathematical constructions from the Poincaré disk formalization:
- Möbius transformations and their algebra
- Pseudo-hyperbolic distance computation
- Hyperbolic lattice generation and counting
- Hyperbolic prime enumeration
- Hyperbolic zeta function evaluation
"""

import numpy as np
from typing import List, Tuple, Optional, Set
from dataclasses import dataclass


# ============================================================
# Algorithm 1: Möbius Transformation Algebra
# ============================================================

def moebius_map(a: complex, z: complex) -> complex:
    """
    Compute the Möbius automorphism of the unit disk:
        φ_a(z) = (z - a) / (1 - conj(a) * z)

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        a: Center of the transformation, |a| < 1
        z: Input point, |z| < 1

    Returns:
        The transformed point φ_a(z), guaranteed |φ_a(z)| < 1

    >>> abs(moebius_map(0.5, 0.5))  # φ_a(a) = 0
    0.0
    """
    denom = 1 - np.conj(a) * z
    if abs(denom) < 1e-15:
        raise ValueError("Denominator too close to zero")
    return (z - a) / denom


def moebius_inverse(a: complex, w: complex) -> complex:
    """
    Compute the inverse Möbius transformation φ_{-a}(w).

    By our theorem moebius_inverse: φ_{-a}(φ_a(z)) = z.

    Time complexity: O(1)
    Space complexity: O(1)
    """
    return moebius_map(-a, w)


def moebius_compose(a: complex, b: complex, z: complex) -> complex:
    """
    Compose two Möbius transformations: φ_a(φ_b(z)).

    By theorem moebius_comp_maps_disk, the result is in the disk
    when a, b, z are all in the disk.

    Time complexity: O(1)
    Space complexity: O(1)
    """
    return moebius_map(a, moebius_map(b, z))


# ============================================================
# Algorithm 2: Pseudo-Hyperbolic Distance
# ============================================================

def pseudo_hyperbolic_distance(z: complex, w: complex) -> float:
    """
    Compute the pseudo-hyperbolic distance ρ(z, w) = |φ_w(z)|.

    Properties (proved in Lean):
    - ρ(z, z) = 0  (pseudoHypDist_self)
    - 0 ≤ ρ(z, w) < 1  (pseudoHypDist_nonneg, pseudoHypDist_lt_one)

    The pseudo-hyperbolic distance is related to the true hyperbolic
    distance d_H by: d_H(z,w) = arctanh(ρ(z,w))

    Time complexity: O(1)
    Space complexity: O(1)
    """
    return abs(moebius_map(w, z))


def hyperbolic_distance(z: complex, w: complex) -> float:
    """
    Compute the true hyperbolic distance d_H(z, w) = arctanh(ρ(z,w)).

    Time complexity: O(1)
    Space complexity: O(1)
    """
    rho = pseudo_hyperbolic_distance(z, w)
    if rho >= 1.0:
        return float('inf')
    return np.arctanh(rho)


# ============================================================
# Algorithm 3: Hyperbolic Lattice Generation
# ============================================================

@dataclass
class HyperbolicLattice:
    """
    A hyperbolic lattice: finite orbit of a point under Möbius generators.

    Corresponds to the HyperbolicLattice structure in Lean.
    """
    points: List[complex]
    size: int
    generators: List[complex]
    max_depth: int

    def count_in_ball(self, r: float) -> int:
        """
        Count points with |z| < r.
        Corresponds to countPointsInBall in Lean.

        Properties (proved):
        - count_in_ball(r) = 0 when r ≤ 0
        - count_in_ball(r) = size when r ≥ 1
        - monotone in r
        """
        return sum(1 for p in self.points if abs(p) < r)


def generate_hyperbolic_lattice(
    generators: List[complex],
    max_depth: int = 5,
    boundary_epsilon: float = 0.001
) -> HyperbolicLattice:
    """
    Generate a hyperbolic lattice by iteratively applying Möbius generators.

    Algorithm:
    1. Start with the origin {0}
    2. At each depth d, apply each generator g to each frontier point p:
       new_point = φ_g(p)
    3. Add new_point if it's in the disk and hasn't been seen
    4. Repeat up to max_depth

    Time complexity: O(|G|^d) where |G| = number of generators, d = depth
    Space complexity: O(|G|^d)

    Args:
        generators: Möbius parameters, each with |g| < 1
        max_depth: Maximum number of iterations
        boundary_epsilon: How close to ∂D to allow points

    Returns:
        HyperbolicLattice containing all generated orbit points
    """
    threshold = 1.0 - boundary_epsilon
    precision = 10  # decimal places for rounding

    seen: Set[Tuple[float, float]] = set()
    points: List[complex] = []

    def round_point(z: complex) -> Tuple[float, float]:
        return (round(z.real, precision), round(z.imag, precision))

    # Seed with origin
    origin = 0 + 0j
    key = round_point(origin)
    seen.add(key)
    points.append(origin)

    frontier = [origin]

    for depth in range(max_depth):
        new_frontier = []
        for p in frontier:
            for g in generators:
                # Apply generator
                q = moebius_map(g, p)
                if abs(q) < threshold:
                    key = round_point(q)
                    if key not in seen:
                        seen.add(key)
                        points.append(q)
                        new_frontier.append(q)
                # Also apply inverse generator
                q_inv = moebius_inverse(g, p)
                if abs(q_inv) < threshold:
                    key = round_point(q_inv)
                    if key not in seen:
                        seen.add(key)
                        points.append(q_inv)
                        new_frontier.append(q_inv)
        frontier = new_frontier
        if not frontier:
            break

    return HyperbolicLattice(
        points=points,
        size=len(points),
        generators=generators,
        max_depth=max_depth
    )


# ============================================================
# Algorithm 4: Hyperbolic Prime Enumeration
# ============================================================

def sieve_of_eratosthenes(n: int) -> List[bool]:
    """
    Standard prime sieve up to n.

    Time complexity: O(n log log n)
    Space complexity: O(n)
    """
    if n < 2:
        return [False] * (n + 1)
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return is_prime


def count_hyperbolic_primes(n: int) -> int:
    """
    Count hyperbolic primes up to depth n.

    A lattice point at depth k is a "hyperbolic prime" if k is prime.
    This is countHypPrimes in Lean.

    Time complexity: O(n log log n)
    Space complexity: O(n)
    """
    if n < 2:
        return 0
    sieve = sieve_of_eratosthenes(n - 1)
    return sum(sieve)


def hyperbolic_prime_ratio(n: int) -> float:
    """
    Compute π_H(n) · ln(n) / n — should converge to 1 by the PNT.

    This is the computational test for the hyperbolicPNT_conjecture.
    """
    if n < 3:
        return float('nan')
    pi_n = count_hyperbolic_primes(n)
    return pi_n * np.log(n) / n


# ============================================================
# Algorithm 5: Hyperbolic Zeta Function
# ============================================================

def hyperbolic_zeta(lattice: HyperbolicLattice, s: float) -> float:
    """
    Evaluate the hyperbolic zeta function:
        ζ_H(s) = Σ_{p ∈ L, |p| > 0} |p|^{-2s}

    Corresponds to hypZeta in Lean.

    Time complexity: O(|L|)
    Space complexity: O(1)

    Args:
        lattice: The hyperbolic lattice
        s: Real parameter (should be > 1/2 for convergence)

    Returns:
        The value of the zeta function
    """
    total = 0.0
    for p in lattice.points:
        r = abs(p)
        if r > 1e-10:
            total += r ** (-2 * s)
    return total


# ============================================================
# Main: Run all algorithms with example data
# ============================================================

if __name__ == "__main__":
    print("Hyperbolic Number Theory — Algorithm Demonstrations")
    print("=" * 60)

    # Generate a sample lattice
    gens = [0.3 + 0.1j, -0.2 + 0.4j, 0.15 - 0.35j]
    lattice = generate_hyperbolic_lattice(gens, max_depth=5)
    print(f"\nGenerated lattice with {lattice.size} points")

    # Counting function
    print("\nLattice point counting (radius → count):")
    for r in np.arange(0.1, 1.0, 0.1):
        c = lattice.count_in_ball(r)
        print(f"  r = {r:.1f}: {c} points")

    # Zeta function
    print("\nHyperbolic zeta function values:")
    for s in [0.6, 0.8, 1.0, 1.5, 2.0]:
        z = hyperbolic_zeta(lattice, s)
        print(f"  ζ_H({s}) = {z:.6f}")

    # PNT verification
    print("\nHyperbolic PNT verification (π(N)·ln(N)/N → 1):")
    for N in [100, 1000, 10000, 100000, 1000000]:
        ratio = hyperbolic_prime_ratio(N)
        print(f"  N = {N:>8}: ratio = {ratio:.6f}")
