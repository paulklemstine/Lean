#!/usr/bin/env python3
"""
Algorithms for Persistent Homology of 1D Point Clouds.

Type-hinted implementations of the core algorithms for computing
H₀ persistent homology of finite point clouds on the real line.
"""

from typing import NamedTuple
from collections import Counter
import math


class Bar(NamedTuple):
    """A bar in the persistence barcode."""
    birth: float
    death: float
    length: float


class ArithPersistenceSig(NamedTuple):
    """Arithmetic Persistence Signature: bundles topological and arithmetic data."""
    num_points: int
    bars: list[int]
    total_persistence: int
    max_bar: int
    gap_spectrum: dict[int, int]


def sieve(n: int) -> list[int]:
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def compute_gap_sequence(points: list[int]) -> list[int]:
    """
    Compute the gap sequence of a sorted list of points.

    For a sorted list [a₁, a₂, ..., aₙ], returns [a₂-a₁, a₃-a₂, ..., aₙ-aₙ₋₁].
    This IS the H₀ barcode of the 1D Rips filtration.

    Time complexity: O(n)
    Space complexity: O(n)
    """
    return [points[i+1] - points[i] for i in range(len(points) - 1)]


def compute_components(gaps: list[int], epsilon: float) -> int:
    """
    Compute the number of connected components at filtration parameter epsilon.

    For a 1D sorted point cloud, two consecutive points are in the same
    component iff their gap ≤ epsilon.

    Time complexity: O(n)
    """
    if not gaps:
        return 1 if gaps is not None else 0
    return 1 + sum(1 for g in gaps if g > epsilon)


def compute_betti_curve(gaps: list[int]) -> list[tuple[int, int]]:
    """
    Compute the Betti curve β₀(ε) for all integer scales.

    Returns list of (epsilon, num_components) pairs.
    The curve is antitone (non-increasing) and stabilizes at 1.

    Time complexity: O(n * max_gap)
    """
    if not gaps:
        return [(0, 1)]
    max_gap = max(gaps)
    return [(eps, compute_components(gaps, eps)) for eps in range(max_gap + 1)]


def compute_persistence_landscape(gaps: list[int]) -> list[tuple[int, int]]:
    """
    Compute the persistence landscape λ₁(ε).

    λ₁(ε) = number of bars strictly greater than ε.
    Total persistence = ∑ λ₁(ε) (Betti integral formula).

    Time complexity: O(n * max_gap)
    """
    if not gaps:
        return []
    max_gap = max(gaps)
    return [(eps, sum(1 for g in gaps if g > eps)) for eps in range(max_gap)]


def compute_aps(points: list[int]) -> ArithPersistenceSig:
    """
    Construct the Arithmetic Persistence Signature of a sorted point cloud.

    The APS bundles:
    - Topological data (barcode, Betti curve)
    - Arithmetic data (gap parity, gap bounds)
    - Analytic data (total persistence, mean gap)

    Time complexity: O(n)
    """
    gaps = compute_gap_sequence(points)
    return ArithPersistenceSig(
        num_points=len(points),
        bars=gaps,
        total_persistence=sum(gaps),
        max_bar=max(gaps) if gaps else 0,
        gap_spectrum=dict(Counter(gaps))
    )


def verify_betti_integral(gaps: list[int]) -> bool:
    """
    Verify the Betti integral formula: ∑_{ε=0}^{M-1} λ₁(ε) = ∑ bars.

    This is a key theorem proved formally in Lean 4.

    Time complexity: O(n * max_gap)
    """
    if not gaps:
        return True
    max_gap = max(gaps)
    integral = sum(sum(1 for g in gaps if g > eps) for eps in range(max_gap))
    return integral == sum(gaps)


def verify_total_persistence(points: list[int]) -> bool:
    """
    Verify the total persistence identity: ∑ gaps = last - first.

    Telescoping sum identity proved formally in Lean 4.

    Time complexity: O(n)
    """
    if len(points) < 2:
        return True
    gaps = compute_gap_sequence(points)
    return sum(gaps) == points[-1] - points[0]


def verify_gap_parity(primes: list[int]) -> bool:
    """
    Verify that all prime gaps except the first (3-2=1) are even.

    For primes p, q > 2, both are odd, so q - p is even.
    Proved formally in Lean 4.

    Time complexity: O(n)
    """
    gaps = compute_gap_sequence(primes)
    if not gaps:
        return True
    # First gap (3-2=1) can be odd
    return all(g % 2 == 0 for g in gaps[1:])


def verify_downward_closure(points: list[int], epsilon: float) -> bool:
    """
    Verify the 1D Rips downward closure property:
    If points[i] and points[k] are connected (|p_i - p_k| ≤ ε),
    then all intermediate points are pairwise connected.

    This is the key property that makes H₁ = 0 for 1D point clouds.
    Proved formally in Lean 4.

    Time complexity: O(n²)
    """
    n = len(points)
    for i in range(n):
        for k in range(i + 2, n):
            if abs(points[k] - points[i]) <= epsilon:
                # Check all intermediate pairs
                for j in range(i + 1, k):
                    if abs(points[j] - points[i]) > epsilon:
                        return False
                    if abs(points[k] - points[j]) > epsilon:
                        return False
    return True


def prime_aps(n: int) -> ArithPersistenceSig:
    """
    Compute the Arithmetic Persistence Signature of primes up to n.

    Time complexity: O(n log log n) for sieve + O(π(n)) for APS
    """
    return compute_aps(sieve(n))


if __name__ == "__main__":
    # Verify all properties for primes up to 10000
    primes = sieve(10000)
    gaps = compute_gap_sequence(primes)

    print("Verification of formally proved properties:")
    print(f"  Total persistence identity: {verify_total_persistence(primes)}")
    print(f"  Betti integral formula: {verify_betti_integral(gaps)}")
    print(f"  Gap parity: {verify_gap_parity(primes)}")
    print(f"  Downward closure (ε=10): {verify_downward_closure(primes[:50], 10)}")

    aps = prime_aps(10000)
    print(f"\nAPS for primes up to 10000:")
    print(f"  Points: {aps.num_points}")
    print(f"  Total persistence: {aps.total_persistence}")
    print(f"  Max bar: {aps.max_bar}")
    print(f"  Top gap sizes: {sorted(aps.gap_spectrum.items(), key=lambda x: -x[1])[:5]}")
