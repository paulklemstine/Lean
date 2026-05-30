"""
Algorithms for Primewise Persistent Homology of Rational Dynamics.

Implements the core algorithms for computing mod-p dynamical graphs,
persistence profiles, orbit entropy, and conjugacy testing.
"""

from __future__ import annotations
import math
from collections import Counter
from dataclasses import dataclass, field
from typing import Callable, Optional


@dataclass
class ModPDynamics:
    """A mod-p dynamical system: a self-map of {0, 1, ..., p}."""
    p: int
    map_fn: Callable[[int], int]

    @property
    def n(self) -> int:
        """Number of points in P^1(F_p)."""
        return self.p + 1

    def iterate(self, k: int, x: int) -> int:
        """Compute the k-th iterate of map_fn at x."""
        result = x
        for _ in range(k):
            result = self.map_fn(result)
        return result

    def fixed_points(self) -> list[int]:
        """Return all fixed points."""
        return [x for x in range(self.n) if self.map_fn(x) == x]

    def periodic_points(self, k: int) -> list[int]:
        """Return all periodic points of period dividing k."""
        return [x for x in range(self.n) if self.iterate(k, x) == x]

    def preimage(self, y: int) -> list[int]:
        """Return the preimage of y under map_fn."""
        return [x for x in range(self.n) if self.map_fn(x) == y]

    def preimage_size(self, y: int) -> int:
        """Return |preimage(y)|."""
        return len(self.preimage(y))

    def preimage_sizes(self) -> list[int]:
        """Return the list of preimage sizes for all points."""
        return [self.preimage_size(y) for y in range(self.n)]

    def degree_sequence(self) -> list[int]:
        """Return the sorted degree sequence (sorted preimage sizes)."""
        return sorted(self.preimage_sizes())

    def image_set(self) -> set[int]:
        """Return the image of map_fn."""
        return {self.map_fn(x) for x in range(self.n)}

    def tail_count(self, k: int) -> int:
        """Return |{y : preimage_size(y) > k}|."""
        return sum(1 for y in range(self.n) if self.preimage_size(y) > k)

    def orbit_entropy(self) -> float:
        """Compute the orbit entropy."""
        sizes = self.preimage_sizes()
        n = self.n
        if n == 0:
            return 0.0
        log_sum = sum(math.log(s + 1) for s in sizes)
        return math.log(n) - log_sum / n


@dataclass
class PersistenceProfile:
    """A persistence profile recording orbit statistics at multiple levels."""
    depth: int
    periodic_counts: list[int]
    tail_counts: list[int]

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, PersistenceProfile):
            return NotImplemented
        return (self.depth == other.depth and
                self.periodic_counts == other.periodic_counts and
                self.tail_counts == other.tail_counts)


def compute_persistence_profile(dyn: ModPDynamics, depth: int) -> PersistenceProfile:
    """
    Extract a persistence profile from a mod-p dynamical system.

    Args:
        dyn: The dynamical system
        depth: Number of filtration levels

    Returns:
        PersistenceProfile with periodic counts and tail counts

    Complexity: O(depth * p + p^2)
    """
    periodic_counts = [len(dyn.periodic_points(k + 1)) for k in range(depth)]
    tail_counts = [dyn.tail_count(k) for k in range(depth)]
    return PersistenceProfile(depth, periodic_counts, tail_counts)


def conjugacy_test(
    f_map: Callable[[int], int],
    g_map: Callable[[int], int],
    primes: list[int],
    depth: int = 5
) -> tuple[bool, list[int]]:
    """
    Test whether two rational maps are likely conjugate by comparing
    persistence profiles across multiple primes.

    Args:
        f_map: Function (p, x) -> f(x) mod p for the first map
        g_map: Function (p, x) -> g(x) mod p for the second map
        primes: List of primes to test
        depth: Persistence profile depth

    Returns:
        (likely_conjugate, separating_primes) where separating_primes
        lists primes where profiles differ
    """
    separating = []
    for p in primes:
        dyn_f = ModPDynamics(p, lambda x, p=p: f_map(p, x))
        dyn_g = ModPDynamics(p, lambda x, p=p: g_map(p, x))
        prof_f = compute_persistence_profile(dyn_f, depth)
        prof_g = compute_persistence_profile(dyn_g, depth)
        if prof_f != prof_g:
            separating.append(p)
    return len(separating) == 0, separating


def make_polynomial_mod_p(coeffs: list[int], p: int) -> Callable[[int], int]:
    """
    Create a mod-p polynomial map from coefficients.

    Args:
        coeffs: Coefficients [a0, a1, ..., an] for a0 + a1*x + ... + an*x^n
        p: Prime modulus

    Returns:
        Function Fin(p+1) -> Fin(p+1) (maps p to p as the point at infinity)
    """
    n = len(coeffs) - 1  # degree

    def f(x: int) -> int:
        if x == p:
            # Point at infinity: for a degree-n polynomial,
            # infinity maps to infinity
            return p
        val = sum(c * pow(x, i, p) for i, c in enumerate(coeffs)) % p
        return val

    return f


def verify_preimage_sum_identity(dyn: ModPDynamics) -> bool:
    """
    Verify the preimage sum identity: sum of preimage sizes = p + 1.

    This is Theorem 3.1 in the paper.
    """
    total = sum(dyn.preimage_size(y) for y in range(dyn.n))
    return total == dyn.n


def compute_all_invariants(dyn: ModPDynamics, depth: int = 5) -> dict:
    """
    Compute all invariants of a mod-p dynamical system.

    Returns a dictionary with:
    - degree_sequence: sorted list of preimage sizes
    - fixed_point_count: number of fixed points
    - periodic_counts: periodic point counts at each level
    - tail_counts: tail counts at each level
    - orbit_entropy: information-theoretic entropy
    - image_size: size of the image
    - preimage_sum_check: verification of the sum identity
    """
    return {
        'degree_sequence': dyn.degree_sequence(),
        'fixed_point_count': len(dyn.fixed_points()),
        'periodic_counts': [len(dyn.periodic_points(k+1)) for k in range(depth)],
        'tail_counts': [dyn.tail_count(k) for k in range(depth)],
        'orbit_entropy': dyn.orbit_entropy(),
        'image_size': len(dyn.image_set()),
        'preimage_sum_check': verify_preimage_sum_identity(dyn),
    }


if __name__ == '__main__':
    # Example: x^2 + 1 mod 7
    p = 7
    f = make_polynomial_mod_p([1, 0, 1], p)  # 1 + 0*x + 1*x^2
    dyn = ModPDynamics(p, f)

    print(f"Dynamical system: x^2 + 1 mod {p}")
    print(f"Points: {{0, 1, ..., {p}}}")
    print(f"Map: {[f(x) for x in range(p+1)]}")
    print()

    invariants = compute_all_invariants(dyn)
    for key, val in invariants.items():
        print(f"  {key}: {val}")
