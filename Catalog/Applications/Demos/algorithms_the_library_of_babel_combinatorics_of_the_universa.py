#!/usr/bin/env python3
"""
Library of Babel: Algorithms

Type-hinted implementations of the key algorithms from the Library of Babel theory.
"""

import math
from typing import List, Tuple, Optional, Set, FrozenSet
from itertools import product


# --- Core Types ---

Volume = Tuple[int, ...]  # A volume is a tuple of alphabet symbols


# --- Hamming Distance ---

def hamming_distance(v: Volume, w: Volume) -> int:
    """Compute Hamming distance between two volumes."""
    assert len(v) == len(w), "Volumes must have the same length"
    return sum(1 for a, b in zip(v, w) if a != b)


# --- Redundancy Profile ---

def redundancy_number(A: int, L: int, r: int) -> int:
    """
    Compute the redundancy number: |{w : hammingDist(v, w) ≤ r}|.

    This equals ∑_{i=0}^{min(r,L)} C(L,i) * (A-1)^i.
    Proved independent of center v (redundancy_profile_uniform).
    """
    return sum(math.comb(L, i) * (A - 1) ** i for i in range(min(r, L) + 1))


# --- Collision Number ---

def collision_lower_bound(total: int, colors: int) -> int:
    """
    Compute ⌈total/colors⌉ = (total + colors - 1) // colors.

    This is the proven lower bound on the collision number of any coloring.
    """
    assert colors > 0, "Number of colors must be positive"
    return (total + colors - 1) // colors


# --- Greedy Code Construction ---

def greedy_code(A: int, L: int, d: int) -> List[Volume]:
    """
    Construct a code with minimum Hamming distance d using greedy algorithm.

    Returns a list of codewords (volumes) that are pairwise at distance ≥ d.
    This gives a lower bound on information_capacity(A, L, d).
    """
    code: List[Volume] = []
    for v in product(range(A), repeat=L):
        vol = tuple(v)
        if all(hamming_distance(vol, c) >= d for c in code):
            code.append(vol)
    return code


# --- Hamming Bound ---

def hamming_bound(A: int, L: int, d: int) -> int:
    """
    Compute the Hamming (sphere-packing) bound on code size.

    The maximum number of codewords in a code with minimum distance d
    is at most A^L / V(L, ⌊(d-1)/2⌋) where V is the Hamming ball volume.

    Proved as singleton_bound in our formalization.
    """
    ball_size = redundancy_number(A, L, (d - 1) // 2)
    return A ** L // ball_size


# --- Sublibrary Collision Detection ---

def find_close_pair(
    volumes: List[Volume], max_dist: int = 1
) -> Optional[Tuple[Volume, Volume]]:
    """
    Find a pair of volumes with Hamming distance ≤ max_dist.

    By sublibrary_collision, any set of > A^(L-1) volumes over alphabet A
    must contain such a pair (for max_dist=1).
    """
    for i, v in enumerate(volumes):
        for j in range(i + 1, len(volumes)):
            w = volumes[j]
            if hamming_distance(v, w) <= max_dist:
                return (v, w)
    return None


# --- De Bruijn Sequence Construction ---

def de_bruijn_sequence(A: int, n: int) -> List[int]:
    """
    Generate a de Bruijn sequence B(A, n): a cyclic sequence of length A^n
    in which every possible n-tuple over alphabet {0,...,A-1} appears exactly
    once as a consecutive substring.

    Uses the standard algorithm based on Lyndon words.
    """
    if n == 0:
        return [0]

    sequence: List[int] = []
    a = [0] * (A * n)

    def db(t: int, p: int) -> None:
        if t > n:
            if n % p == 0:
                sequence.extend(a[1:p + 1])
        else:
            a[t] = a[t - p]
            db(t + 1, p)
            for j in range(a[t - p] + 1, A):
                a[t] = j
                db(t + 1, t)

    db(1, 1)
    return sequence


# --- Catalog Impossibility Verification ---

def verify_catalog_impossibility(A: int, L: int, D: int) -> dict:
    """
    Verify the catalog impossibility theorem numerically.

    Returns a dict with the volumes count, catalog schemes count,
    and whether the impossibility holds (schemes > volumes for D ≥ 2).
    """
    volumes = A ** L
    schemes = D ** volumes
    return {
        "alphabet_size": A,
        "volume_length": L,
        "description_values": D,
        "num_volumes": volumes,
        "num_catalog_schemes": schemes,
        "impossibility_holds": schemes > volumes if D >= 2 else False,
        "ratio": schemes / volumes if volumes > 0 else float('inf'),
    }


# --- Translation Symmetry ---

def translate_volume(
    v: Volume, source: Volume, target: Volume, A: int
) -> Volume:
    """
    Translate volume v from center 'source' to center 'target' in Fin(A) arithmetic.

    This is the bijection used in redundancy_profile_uniform:
    w ↦ (w - source + target) mod A, componentwise.
    """
    return tuple((vi - si + ti) % A for vi, si, ti in zip(v, source, target))


if __name__ == "__main__":
    # Quick demonstration
    print("De Bruijn sequence B(2, 3):", de_bruijn_sequence(2, 3))
    print("De Bruijn sequence B(3, 2):", de_bruijn_sequence(3, 2))

    print("\nGreedy code (A=2, L=7, d=3):")
    code = greedy_code(2, 7, 3)
    print(f"  Found {len(code)} codewords (Hamming bound: {hamming_bound(2, 7, 3)})")

    print("\nCatalog impossibility (A=2, L=3, D=2):")
    result = verify_catalog_impossibility(2, 3, 2)
    for k, v in result.items():
        print(f"  {k}: {v}")
