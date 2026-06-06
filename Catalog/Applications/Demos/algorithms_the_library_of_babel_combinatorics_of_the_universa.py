#!/usr/bin/env python3
"""
Library of Babel: Algorithms

Type-hinted implementations of the key algorithms from the formalization:
- Hamming distance computation
- Hamming ball enumeration
- Catalog fiber analysis
- Pattern search in volumes
- Sphere-packing bound computation
- De Bruijn sequence construction for mini-libraries
"""

from typing import List, Tuple, Dict, Set, Optional, Iterator
from itertools import product
import math
from collections import Counter


def hamming_distance(v: List[int], w: List[int]) -> int:
    """Compute Hamming distance between two volumes (same length)."""
    assert len(v) == len(w), "Volumes must have the same length"
    return sum(1 for a, b in zip(v, w) if a != b)


def hamming_ball(center: List[int], radius: int, alphabet_size: int) -> List[List[int]]:
    """Enumerate all volumes within Hamming distance `radius` of `center`.
    Warning: exponential in radius — use only for small parameters."""
    L = len(center)
    result = []
    for vol in product(range(alphabet_size), repeat=L):
        vol_list = list(vol)
        if hamming_distance(center, vol_list) <= radius:
            result.append(vol_list)
    return result


def hamming_ball_size(alphabet_size: int, length: int, radius: int) -> int:
    """Compute exact Hamming ball volume: sum_{i=0}^{r} C(L,i)*(A-1)^i."""
    return sum(
        math.comb(length, i) * (alphabet_size - 1) ** i
        for i in range(min(radius, length) + 1)
    )


def hamming_sphere_size(alphabet_size: int, length: int, radius: int) -> int:
    """Compute exact Hamming sphere size: C(L,r)*(A-1)^r."""
    if radius > length:
        return 0
    return math.comb(length, radius) * (alphabet_size - 1) ** radius


def catalog_fiber_analysis(
    catalog: Dict[Tuple[int, ...], int],
    num_descriptions: int
) -> Dict[int, List[Tuple[int, ...]]]:
    """Analyze catalog fibers: group volumes by their description."""
    fibers: Dict[int, List[Tuple[int, ...]]] = {d: [] for d in range(num_descriptions)}
    for volume, desc in catalog.items():
        fibers[desc].append(volume)
    return fibers


def catalog_max_fiber(
    catalog: Dict[Tuple[int, ...], int],
    num_descriptions: int
) -> Tuple[int, int]:
    """Find the largest catalog fiber. Returns (description, fiber_size)."""
    fibers = catalog_fiber_analysis(catalog, num_descriptions)
    best_d = max(fibers, key=lambda d: len(fibers[d]))
    return best_d, len(fibers[best_d])


def sphere_packing_bound(alphabet_size: int, length: int, min_dist: int) -> int:
    """Hamming bound: max code size with given minimum distance.

    For min distance d = 2r+1, the bound is A^L / V(L,r) where
    V(L,r) = Hamming ball volume of radius r.
    """
    if min_dist % 2 == 0:
        # For even min distance, use r = (d-2)/2 (slightly weaker but valid)
        r = (min_dist - 2) // 2
    else:
        r = (min_dist - 1) // 2
    ball_vol = hamming_ball_size(alphabet_size, length, r)
    return alphabet_size ** length // ball_vol


def singleton_bound(alphabet_size: int, length: int, min_dist: int) -> int:
    """Singleton bound: max code size ≤ A^(L-d+1)."""
    return alphabet_size ** max(0, length - min_dist + 1)


def pattern_positions(
    volume: List[int], pattern: List[int]
) -> List[int]:
    """Find all starting positions where pattern occurs in volume."""
    positions = []
    for i in range(len(volume) - len(pattern) + 1):
        if volume[i:i+len(pattern)] == pattern:
            positions.append(i)
    return positions


def pattern_density(
    alphabet_size: int, length: int, pattern_length: int
) -> float:
    """Probability that a random volume contains a given pattern at a random position."""
    if pattern_length > length:
        return 0.0
    return 1.0 / alphabet_size ** pattern_length


def total_pattern_occurrences(
    alphabet_size: int, length: int, pattern_length: int
) -> int:
    """Total (volume, position) pairs containing a given pattern.
    Equals (L - m + 1) * A^(L - m)."""
    if pattern_length > length:
        return 0
    return (length - pattern_length + 1) * alphabet_size ** (length - pattern_length)


def de_bruijn_sequence(alphabet_size: int, order: int) -> List[int]:
    """Generate a de Bruijn sequence B(A, n) — a cyclic sequence in which every
    possible n-length string over alphabet {0,...,A-1} occurs exactly once as a
    contiguous substring.

    Uses Martin's algorithm (recursive construction via Lyndon words).
    The sequence has length A^n.
    """
    k = alphabet_size
    n = order
    if n == 0:
        return [0]

    a = [0] * (k * n)
    sequence: List[int] = []

    def db(t: int, p: int) -> None:
        if t > n:
            if n % p == 0:
                sequence.extend(a[1:p + 1])
        else:
            a[t] = a[t - p]
            db(t + 1, p)
            for j in range(a[t - p] + 1, k):
                a[t] = j
                db(t + 1, t)

    db(1, 1)
    return sequence


def de_bruijn_catalog(
    alphabet_size: int, book_length: int
) -> List[int]:
    """Construct a de Bruijn-based catalog for a mini-library.

    The de Bruijn sequence B(A, L) visits every L-length string
    as a contiguous substring. This provides a 'linear catalog'
    that encodes all volumes in a single sequence of length A^L + L - 1.
    """
    return de_bruijn_sequence(alphabet_size, book_length)


def verify_de_bruijn(sequence: List[int], alphabet_size: int, order: int) -> bool:
    """Verify that a sequence is a valid de Bruijn sequence."""
    expected_length = alphabet_size ** order
    if len(sequence) != expected_length:
        return False

    seen: Set[Tuple[int, ...]] = set()
    for i in range(expected_length):
        # Treat sequence as cyclic
        substring = tuple(sequence[(i + j) % expected_length] for j in range(order))
        seen.add(substring)

    return len(seen) == expected_length


# ============================
# Self-test
# ============================
if __name__ == "__main__":
    # Test Hamming distance
    v = [0, 1, 2, 3]
    w = [0, 1, 0, 3]
    assert hamming_distance(v, w) == 1

    # Test Hamming ball size formula
    for A in [2, 3, 4]:
        for L in [4, 8]:
            assert hamming_ball_size(A, L, 0) == 1
            assert hamming_ball_size(A, L, 1) == 1 + L * (A - 1)
            assert hamming_ball_size(A, L, L) == A ** L

    # Test de Bruijn sequence
    for A in [2, 3, 4]:
        for n in [2, 3, 4]:
            seq = de_bruijn_sequence(A, n)
            assert verify_de_bruijn(seq, A, n), f"Failed for B({A},{n})"

    # Test pattern density formula
    assert total_pattern_occurrences(4, 16, 4) == 13 * 4 ** 12

    # Test catalog pigeonhole
    A, L, D = 2, 4, 3
    lib_size = A ** L  # 16
    # Any catalog from 16 volumes to 3 labels has max fiber ≥ ceil(16/3) = 6
    min_fiber = (lib_size + D - 1) // D
    assert min_fiber == 6

    print("All self-tests passed!")
    print()

    # Demo: de Bruijn for mini-library
    print("De Bruijn sequence B(4, 3):")
    seq = de_bruijn_sequence(4, 3)
    print(f"  Length: {len(seq)} (expected {4**3} = 64)")
    print(f"  First 20 symbols: {seq[:20]}")
    print(f"  Valid: {verify_de_bruijn(seq, 4, 3)}")
