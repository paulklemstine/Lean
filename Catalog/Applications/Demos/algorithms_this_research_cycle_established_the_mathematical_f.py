"""
Adelic Synchronization for Arithmetic Dynamics — Core Algorithms

Type-hinted implementations of the key algorithms for computing orbit signatures
and the adelic synchronization index (ASI) for quadratic maps over Z/pZ.
"""

from typing import Dict, List, Tuple, Set
from collections import Counter
import math


def quad_map(c: int, x: int, p: int) -> int:
    """Quadratic map x ↦ x² + c mod p."""
    return (x * x + c) % p


def iterate_map(c: int, x: int, p: int, n: int) -> int:
    """Compute the n-th iterate of x ↦ x² + c mod p."""
    result = x % p
    for _ in range(n):
        result = quad_map(c, result, p)
    return result


def find_rho_shape(c: int, x: int, p: int) -> Tuple[int, int]:
    """Find the rho shape (tail_length, cycle_length) for x under x ↦ x² + c mod p.

    Uses Floyd's cycle detection algorithm.
    Returns (tail, cycle) where tail + cycle ≤ p.
    """
    # Phase 1: Find meeting point
    tortoise = quad_map(c, x, p)
    hare = quad_map(c, quad_map(c, x, p), p)
    while tortoise != hare:
        tortoise = quad_map(c, tortoise, p)
        hare = quad_map(c, quad_map(c, hare, p), p)

    # Phase 2: Find tail length
    tail = 0
    tortoise = x % p
    while tortoise != hare:
        tortoise = quad_map(c, tortoise, p)
        hare = quad_map(c, hare, p)
        tail += 1

    # Phase 3: Find cycle length
    cycle = 1
    hare = quad_map(c, tortoise, p)
    while tortoise != hare:
        hare = quad_map(c, hare, p)
        cycle += 1

    return (tail, cycle)


def minimal_period(c: int, x: int, p: int) -> int:
    """Compute the minimal period of x under x ↦ x² + c mod p.

    Returns 0 if x is not periodic (i.e., it has a nontrivial tail).
    """
    tail, cycle = find_rho_shape(c, x, p)
    if tail == 0:
        return cycle
    # x is not periodic; its eventual period is cycle
    # but minimal period of x itself is 0 by convention
    return 0


def orbit_signature(c: int, p: int) -> Counter:
    """Compute the orbit signature: multiset of minimal periods for all x in Z/pZ.

    Only includes periodic points (those with tail length 0).
    """
    periods: Counter = Counter()
    for x in range(p):
        mp = minimal_period(c, x, p)
        if mp > 0:
            periods[mp] += 1
    return periods


def cycle_type(c: int, p: int) -> Set[int]:
    """Compute the cycle type: set of distinct cycle lengths."""
    return set(orbit_signature(c, p).keys())


def normalized_orbit_count(c: int, p: int, k: int) -> float:
    """Fraction of elements in Z/pZ with minimal period exactly k."""
    sig = orbit_signature(c, p)
    return sig.get(k, 0) / p


def orbit_length_distribution(c: int, p: int) -> Dict[int, float]:
    """Full normalized distribution of cycle lengths."""
    sig = orbit_signature(c, p)
    return {k: v / p for k, v in sig.items()}


def l2_overlap(dist1: Dict[int, float], dist2: Dict[int, float]) -> float:
    """L² overlap between two orbit length distributions."""
    all_keys = set(dist1.keys()) | set(dist2.keys())
    return sum(dist1.get(k, 0.0) * dist2.get(k, 0.0) for k in all_keys)


def adelic_sync_index(c: int, primes: List[int]) -> float:
    """Compute the Adelic Synchronization Index (ASI) for parameter c
    over a list of primes.

    The ASI measures cross-prime correlation of orbit length distributions.
    Higher values indicate algebraically special parameters.
    """
    if len(primes) < 2:
        return 0.0

    distributions = {p: orbit_length_distribution(c, p) for p in primes}

    total_overlap = 0.0
    pair_count = 0

    for i, p in enumerate(primes):
        for j, q in enumerate(primes):
            if i < j:
                total_overlap += l2_overlap(distributions[p], distributions[q])
                pair_count += 1

    return total_overlap / pair_count if pair_count > 0 else 0.0


def is_critically_preperiodic(c: int, bound: int = 1000) -> bool:
    """Check if 0 is preperiodic under x ↦ x² + c over Z.

    Uses a simple bound check: if |f^n(0)| > 2 for some n, then 0 escapes.
    Otherwise checks for periodicity within the bound.
    """
    x = 0
    seen: Dict[int, int] = {}
    for n in range(bound):
        if x in seen:
            return True
        seen[x] = n
        x = x * x + c
        if abs(x) > 4:  # escape radius
            return False
    return False


def iter_image_sizes(c: int, p: int, max_iter: int = 50) -> List[int]:
    """Compute the sequence of iterate image sizes for x ↦ x² + c mod p.

    Returns [|Im(f⁰)|, |Im(f¹)|, ..., |Im(f^max_iter)|].
    This sequence is nonincreasing (proved in our Lean formalization).
    """
    sizes = []
    for n in range(max_iter + 1):
        image = set()
        for x in range(p):
            image.add(iterate_map(c, x, p, n))
        sizes.append(len(image))
    return sizes


def stabilization_index(c: int, p: int) -> int:
    """Find the smallest N such that |Im(f^N)| = |Im(f^(N+1))|."""
    prev_size = p  # |Im(f⁰)| = p
    for n in range(1, p + 1):
        image = set()
        for x in range(p):
            image.add(iterate_map(c, x, p, n))
        curr_size = len(image)
        if curr_size == prev_size:
            return n - 1
        prev_size = curr_size
    return p


def compute_asi_landscape(c_range: range, primes: List[int]) -> Dict[int, float]:
    """Compute ASI for a range of c values."""
    return {c: adelic_sync_index(c, primes) for c in c_range}


if __name__ == "__main__":
    # Quick test
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    for c in [-2, -1, 0, 1, 2, 7]:
        asi = adelic_sync_index(c, primes)
        preperiodic = is_critically_preperiodic(c)
        print(f"c={c:3d}: ASI={asi:.6f}, preperiodic={preperiodic}")
