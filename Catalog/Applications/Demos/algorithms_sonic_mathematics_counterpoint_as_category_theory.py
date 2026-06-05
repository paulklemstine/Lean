#!/usr/bin/env python3
"""
Algorithms for Voice Leading System Analysis

Type-hinted implementations of the core algorithms from the
Counterpoint Category Theory research.
"""

from typing import Set, FrozenSet, List, Tuple, Dict, Optional
from itertools import combinations


def neg_mod(x: int, n: int = 12) -> int:
    """Negation in Z/nZ."""
    return (-x) % n


def compute_stabilizer(S: Set[int], n: int = 12) -> Set[int]:
    """
    Compute the translational stabilizer of S in Z/nZ.

    The stabilizer is the subgroup {d ∈ Z/nZ : S + d = S}.
    Time complexity: O(n · |S|)

    Args:
        S: Subset of Z/nZ (represented as integers mod n)
        n: Size of the cyclic group

    Returns:
        The stabilizer subgroup as a set of integers
    """
    return {d for d in range(n) if all((s + d) % n in S for s in S)}


def compute_inversion_orphans(S: Set[int], n: int = 12) -> Set[int]:
    """
    Find inversion orphans: elements c ∈ S with −c ∉ S.

    Args:
        S: Consonance set in Z/nZ
        n: Size of cyclic group

    Returns:
        Set of orphan elements
    """
    return {c for c in S if neg_mod(c, n) not in S}


def inversion_pair_count(S: Set[int], n: int = 12) -> int:
    """
    Count elements of S whose negation is also in S.

    Args:
        S: Subset of Z/nZ
        n: Modulus

    Returns:
        |{c ∈ S : −c ∈ S}|
    """
    return sum(1 for c in S if neg_mod(c, n) in S)


def optimal_voice_leading(
    source: int, target: int, n: int = 12, bound: int = 6
) -> Tuple[int, int, int]:
    """
    Find minimum-cost voice leading between two interval classes.

    A voice leading (δ_bass, δ_treble) transitions from interval `source`
    to interval `target` if (δ_treble − δ_bass) ≡ (target − source) (mod n).
    Cost = |δ_bass| + |δ_treble|.

    Args:
        source: Source interval class in Z/nZ
        target: Target interval class in Z/nZ
        n: Chromatic universe size
        bound: Maximum absolute step size

    Returns:
        (δ_bass, δ_treble, cost) of optimal voice leading
    """
    best: Optional[Tuple[int, int, int]] = None
    diff = (target - source) % n
    for db in range(-bound, bound + 1):
        for dt in range(-bound, bound + 1):
            if (dt - db) % n == diff:
                c = abs(db) + abs(dt)
                if best is None or c < best[2]:
                    best = (db, dt, c)
    assert best is not None
    return best


def distance_matrix(consonances: Set[int], n: int = 12, bound: int = 6) -> Dict[Tuple[int, int], int]:
    """
    Compute the voice leading distance matrix between consonant intervals.

    Args:
        consonances: Set of consonant interval classes
        n: Chromatic universe size
        bound: Maximum step size for voice leadings

    Returns:
        Dictionary mapping (source, target) pairs to minimum costs
    """
    result: Dict[Tuple[int, int], int] = {}
    for src in consonances:
        for tgt in consonances:
            _, _, cost = optimal_voice_leading(src, tgt, n, bound)
            result[(src, tgt)] = cost
    return result


def enumerate_fux_optimal(n: int, target_size: int, required: Set[int]) -> List[Set[int]]:
    """
    Find all "Fux-optimal" consonance sets: subsets of Z/nZ with
    specified size, trivial stabilizer, and maximum inversion pair count.

    Args:
        n: Size of cyclic group
        target_size: Desired cardinality of consonance set
        required: Elements that must be in the set

    Returns:
        List of sets achieving the maximum inversion pair count
    """
    remaining = [x for x in range(n) if x not in required]
    choose = target_size - len(required)

    if choose < 0 or choose > len(remaining):
        return []

    max_inv = 0
    maximizers: List[Set[int]] = []

    for combo in combinations(remaining, choose):
        S = required | set(combo)
        stab = compute_stabilizer(S, n)
        if stab == {0}:
            inv = inversion_pair_count(S, n)
            if inv > max_inv:
                max_inv = inv
                maximizers = [S]
            elif inv == max_inv:
                maximizers.append(S)

    return maximizers


def third_orbit_decomposition(n: int = 12, step: int = 3) -> List[Set[int]]:
    """
    Decompose Z/nZ into orbits under repeated addition of `step`.

    Args:
        n: Size of cyclic group
        step: Generator of the cyclic subgroup

    Returns:
        List of orbits (each a set of integers mod n)
    """
    seen: Set[int] = set()
    orbits: List[Set[int]] = []
    for start in range(n):
        if start not in seen:
            orbit: Set[int] = set()
            x = start
            while x not in orbit:
                orbit.add(x)
                x = (x + step) % n
            seen |= orbit
            orbits.append(orbit)
    return orbits


def is_consonance_preserving(
    delta: Tuple[int, int], consonances: Set[int], n: int = 12
) -> bool:
    """
    Check if a voice leading preserves consonance for ALL consonant intervals.

    Args:
        delta: (δ_bass, δ_treble) voice leading
        consonances: Set of consonant intervals
        n: Chromatic universe size

    Returns:
        True iff every consonant interval maps to a consonant interval
    """
    transition = (delta[1] - delta[0]) % n
    return all((c + transition) % n in consonances for c in consonances)


def circle_of_fifths(n: int = 12, generator: int = 7) -> List[int]:
    """
    Generate the circle of fifths (or any generator cycle).

    Args:
        n: Chromatic universe size
        generator: Interval that generates the cycle

    Returns:
        List of pitch classes in cycle order
    """
    return [(generator * k) % n for k in range(n)]


if __name__ == '__main__':
    C = {0, 3, 4, 7, 8, 9}

    print("=== Voice Leading System Analysis ===\n")

    print(f"Consonances: {sorted(C)}")
    print(f"Stabilizer: {compute_stabilizer(C)}")
    print(f"Inversion orphans: {compute_inversion_orphans(C)}")
    print(f"Inversion pair count: {inversion_pair_count(C)}")

    print("\nDistance matrix:")
    dm = distance_matrix(C)
    cons = sorted(C)
    print("     " + "  ".join(f"{c:2d}" for c in cons))
    for src in cons:
        row = [f"{dm[(src, tgt)]:2d}" for tgt in cons]
        print(f"  {src:2d}: {'  '.join(row)}")

    print("\nThird-orbit decomposition:")
    for orb in third_orbit_decomposition():
        density = len(orb & C)
        print(f"  {sorted(orb)} → {density} consonances")

    print("\nFux-optimal sets (6-element, {0,7} required, trivial stabilizer):")
    maximizers = enumerate_fux_optimal(12, 6, {0, 7})
    for S in maximizers:
        print(f"  {sorted(S)} (inv pairs: {inversion_pair_count(S)})")
