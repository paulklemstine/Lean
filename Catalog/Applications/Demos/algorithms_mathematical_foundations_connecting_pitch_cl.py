#!/usr/bin/env python3
"""
Algorithms for Chromatic Topology

Type-hinted implementations of the core algorithms for pitch class set theory,
Hamming distance computation, and orbit/stabilizer analysis on ℤ/12ℤ.
"""

from typing import FrozenSet, List, Tuple, Dict, Set, Counter as CounterType
from itertools import combinations
from collections import Counter


PitchClass = int  # Elements of ℤ/12ℤ, represented as 0..11
PCS = FrozenSet[int]  # Pitch class sets


def mod12(x: int) -> int:
    """Canonical representative in {0, ..., 11}."""
    return x % 12


def transpose(S: PCS, t: int) -> PCS:
    """
    Transposition T_t: shift every element by t (mod 12).

    Algorithm: O(|S|) — iterate and reduce mod 12.
    """
    return frozenset(mod12(x + t) for x in S)


def invert(S: PCS) -> PCS:
    """
    Inversion I: negate every element (mod 12).

    Algorithm: O(|S|)
    """
    return frozenset(mod12(-x) for x in S)


def complement(S: PCS, n: int = 12) -> PCS:
    """
    Complement: ℤ/nℤ \ S.

    Algorithm: O(n)
    """
    return frozenset(range(n)) - S


def hamming_distance(A: PCS, B: PCS) -> int:
    """
    Hamming distance: |A △ B| = |A \ B| + |B \ A|.

    Equivalently: |A| + |B| - 2|A ∩ B|.

    Algorithm: O(|A| + |B|) using set operations.
    """
    return len(A.symmetric_difference(B))


def interval_class(d: int) -> int:
    """
    Interval class: min(d mod 12, 12 - d mod 12).

    Maps directed intervals to unordered interval classes {0, ..., 6}.

    Algorithm: O(1)
    """
    d = d % 12
    return min(d, 12 - d)


def interval_vector(S: PCS) -> List[int]:
    """
    Interval-class vector: for each IC ∈ {1,...,6}, count unordered pairs.

    The interval vector is the fundamental invariant of pitch class set theory.
    It is preserved by transposition and inversion.

    Algorithm: O(|S|²) — iterate over all pairs.

    Returns: List of 6 integers [IC₁, IC₂, IC₃, IC₄, IC₅, IC₆]
    """
    vec = [0] * 6
    for a, b in combinations(sorted(S), 2):
        ic = interval_class(b - a)
        if 1 <= ic <= 6:
            vec[ic - 1] += 1
    return vec


def intervallic_fingerprint(S: PCS) -> Counter:
    """
    Intervallic fingerprint: multiset of directed intervals b - a
    for all ordered pairs (a, b) in S with a ≠ b.

    Novel invariant that refines the interval vector by retaining direction.
    Invariant under transposition but NOT under inversion.

    Algorithm: O(|S|²)

    Returns: Counter mapping directed intervals (0..11) to counts.
    """
    fp: Counter = Counter()
    for a in S:
        for b in S:
            if a != b:
                fp[mod12(b - a)] += 1
    return fp


def stabilizer(S: PCS) -> List[int]:
    """
    Stabilizer of S under transposition: {t ∈ ℤ/12ℤ | T_t(S) = S}.

    Algorithm: O(12 · |S|) — check all 12 transpositions.

    Returns: Sorted list of stabilizing intervals.
    """
    return sorted(t for t in range(12) if transpose(S, t) == S)


def orbit(S: PCS) -> Set[PCS]:
    """
    Orbit of S under transposition: {T_t(S) | t ∈ ℤ/12ℤ}.

    Algorithm: O(12 · |S|)

    Returns: Set of distinct PCS in the orbit.
    """
    return {transpose(S, t) for t in range(12)}


def orbit_stabilizer_check(S: PCS) -> Tuple[int, int, bool]:
    """
    Verify orbit-stabilizer theorem: |Orbit(S)| × |Stab(S)| = 12.

    Returns: (orbit_size, stabilizer_size, theorem_holds)
    """
    orb = len(orbit(S))
    stab = len(stabilizer(S))
    return orb, stab, orb * stab == 12


def hexachordal_check(S: PCS) -> bool:
    """
    Check hexachordal complementation: IV(S) = IV(complement(S))
    for |S| = 6.

    Algorithm: O(|S|²) — compute both interval vectors and compare.

    Returns: True iff the hexachordal theorem holds for S.
    """
    if len(S) != 6:
        raise ValueError(f"Expected hexachord (size 6), got size {len(S)}")
    return interval_vector(S) == interval_vector(complement(S))


def vietoris_rips_edges(cloud: List[PCS], epsilon: int) -> List[Tuple[int, int]]:
    """
    Compute edges of the Vietoris-Rips graph at scale ε.

    Two chords are connected iff their Hamming distance ≤ ε.

    Algorithm: O(|cloud|² · max_set_size)

    Returns: List of (i, j) edge pairs.
    """
    edges = []
    for i in range(len(cloud)):
        for j in range(i + 1, len(cloud)):
            if hamming_distance(cloud[i], cloud[j]) <= epsilon:
                edges.append((i, j))
    return edges


def filtration_sequence(cloud: List[PCS]) -> Dict[int, List[Tuple[int, int]]]:
    """
    Compute the full Rips filtration: edges at each threshold ε.

    Algorithm: O(|cloud|² · max_set_size + max_dist · |cloud|²)

    Returns: Dict mapping ε to list of edges born at that ε.
    """
    # Compute all pairwise distances
    n = len(cloud)
    distances: Dict[Tuple[int, int], int] = {}
    max_dist = 0
    for i in range(n):
        for j in range(i + 1, n):
            d = hamming_distance(cloud[i], cloud[j])
            distances[(i, j)] = d
            max_dist = max(max_dist, d)

    # Group edges by birth time
    filtration: Dict[int, List[Tuple[int, int]]] = {}
    for eps in range(max_dist + 1):
        new_edges = [(i, j) for (i, j), d in distances.items() if d == eps]
        if new_edges:
            filtration[eps] = new_edges

    return filtration


def classify_all_trichords() -> Dict[str, List[PCS]]:
    """
    Classify all 3-element PCS up to transposition/inversion equivalence.

    Uses the interval vector as the primary invariant.

    Algorithm: O(C(12,3) · 24) = O(5280)

    Returns: Dict mapping IV string to list of representative PCS.
    """
    classes: Dict[str, List[PCS]] = {}
    seen: Set[PCS] = set()

    for combo in combinations(range(12), 3):
        S = frozenset(combo)
        if S in seen:
            continue

        # Mark all T/I equivalents as seen
        for t in range(12):
            seen.add(transpose(S, t))
            seen.add(transpose(invert(S), t))

        iv = str(interval_vector(S))
        classes.setdefault(iv, []).append(S)

    return classes


if __name__ == "__main__":
    # Quick test of all algorithms
    C = frozenset({0, 4, 7})
    G = frozenset({7, 11, 2})

    print(f"C major: {sorted(C)}")
    print(f"Transpose by 5: {sorted(transpose(C, 5))}")
    print(f"Invert: {sorted(invert(C))}")
    print(f"Complement: {sorted(complement(C))}")
    print(f"Hamming(C, G) = {hamming_distance(C, G)}")
    print(f"IV(C) = {interval_vector(C)}")
    print(f"Fingerprint(C) = {dict(intervallic_fingerprint(C))}")
    print(f"Stabilizer(C) = {stabilizer(C)}")
    print(f"Orbit size = {len(orbit(C))}")
    print(f"Orbit-stabilizer: {orbit_stabilizer_check(C)}")
    print()

    # Classify trichords
    classes = classify_all_trichords()
    print(f"Trichord classes (up to T/I): {len(classes)}")
    for iv, reps in sorted(classes.items()):
        print(f"  IV = {iv}: {sorted(reps[0])}")
    print()

    # Hexachordal check
    for S in [frozenset(s) for s in combinations(range(12), 6)][:5]:
        print(f"  Hexachord {sorted(S)}: complementation holds = {hexachordal_check(S)}")
