"""Numerical demonstrations for:

    "Regularity of Flag Graphs of Maniplexes and a Census-Based
     Classification of Regular 4-Maniplexes"

An *involution family* of size n+1 on a finite flag set is a list of maps
    sigma_0, ..., sigma_n : A -> A
such that each sigma_i is an involution (sigma_i o sigma_i = id), is
fixed-point-free (sigma_i(x) != x), non-adjacent maps commute
(|i - j| >= 2  =>  sigma_i o sigma_j = sigma_j o sigma_i), and images are
separated (i != j  =>  sigma_i(v) != sigma_j(v)).

Main theorem (verified numerically here): the associated *flag graph*,
in which v ~ w iff some sigma_i sends one to the other, is regular of degree
n+1.  For n = 3 (four connection involutions) the flag graph is tetravalent.

Every function is self-contained and type-hinted.  Run this file directly.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, Hashable, List, Set, Tuple

# A flag is any hashable object; a connection involution is a dict mapping
# flags to flags (a permutation of the flag set).
Flag = Hashable
Involution = Dict[Flag, Flag]


# --------------------------------------------------------------------------
# Verification of the four involution-family axioms (Algorithm A)
# --------------------------------------------------------------------------
def verify_involution_family(flags: List[Flag],
                             sigmas: List[Involution]) -> Dict[str, bool]:
    """Check the four axioms of an involution family. Returns a report dict."""
    involutive = all(s[s[x]] == x for s in sigmas for x in flags)
    fixed_point_free = all(s[x] != x for s in sigmas for x in flags)
    string = all(
        sigmas[i][sigmas[j][x]] == sigmas[j][sigmas[i][x]]
        for i in range(len(sigmas))
        for j in range(len(sigmas))
        if abs(i - j) >= 2
        for x in flags
    )
    separation = all(
        sigmas[i][v] != sigmas[j][v]
        for v in flags
        for i in range(len(sigmas))
        for j in range(len(sigmas))
        if i != j
    )
    return {
        "involutive": involutive,
        "fixed_point_free": fixed_point_free,
        "string (non-adjacent commute)": string,
        "separation": separation,
        "is_valid_family": involutive and fixed_point_free and string and separation,
    }


# --------------------------------------------------------------------------
# The flag graph and its vertex degrees (Algorithm B)
# --------------------------------------------------------------------------
def flag_graph_neighbors(flags: List[Flag],
                         sigmas: List[Involution]) -> Dict[Flag, Set[Flag]]:
    """Neighbor set of every flag: N(v) = { sigma_i(v) : i }."""
    neighbors: Dict[Flag, Set[Flag]] = {v: set() for v in flags}
    for v in flags:
        for s in sigmas:
            neighbors[v].add(s[v])          # w = sigma_i(v)
            neighbors[s[v]].add(v)           # symmetric closure
    return neighbors


def degree_sequence(flags: List[Flag],
                    sigmas: List[Involution]) -> Dict[Flag, int]:
    """Degree of each vertex in the flag graph."""
    nb = flag_graph_neighbors(flags, sigmas)
    return {v: len(nb[v]) for v in flags}


def is_regular_of_degree(flags: List[Flag],
                         sigmas: List[Involution], d: int) -> bool:
    """True iff every vertex of the flag graph has degree exactly d."""
    return all(deg == d for deg in degree_sequence(flags, sigmas).values())


# --------------------------------------------------------------------------
# Divisibility of the flag count (Algorithm C, Proposition 3.3)
# --------------------------------------------------------------------------
def two_element_orbits(flags: List[Flag], sigma: Involution) -> List[Tuple[Flag, Flag]]:
    """Partition the flag set into the 2-element orbits of a single sigma."""
    seen: Set[Flag] = set()
    orbits: List[Tuple[Flag, Flag]] = []
    for x in flags:
        if x not in seen:
            y = sigma[x]
            orbits.append((x, y))
            seen.add(x)
            seen.add(y)
    return orbits


# --------------------------------------------------------------------------
# Example 1: the hypercube Q_{n+1} as the flag graph of a rank-(n+1) family.
# sigma_i flips bit i of a vector in {0,1}^{n+1}.
# --------------------------------------------------------------------------
def hypercube_family(dim: int) -> Tuple[List[Flag], List[Involution]]:
    """Involution family of size `dim` on {0,1}^dim; flag graph is Q_dim."""
    flags: List[Flag] = list(product((0, 1), repeat=dim))

    def flip(i: int) -> Involution:
        s: Involution = {}
        for v in flags:
            w = list(v)
            w[i] ^= 1
            s[v] = tuple(w)
        return s

    sigmas = [flip(i) for i in range(dim)]
    return flags, sigmas


# --------------------------------------------------------------------------
# Example 2: the flag graph of a regular n-gon (rank 2, a 2-valent 2n-cycle).
# A flag is (vertex mod n, side in {0,1}); sigma_0 swaps the vertex within an
# edge, sigma_1 swaps the edge within a vertex.
# --------------------------------------------------------------------------
def polygon_family(n: int) -> Tuple[List[Flag], List[Involution]]:
    """Rank-2 involution family for the n-gon; flag graph is the 2n-cycle.

    The 2n flags are integers 0, 1, ..., 2n-1 arranged in a cycle.
    sigma_0 (edge-preserving) pairs (0,1), (2,3), ...;
    sigma_1 (vertex-preserving) pairs (1,2), (3,4), ..., (2n-1, 0).
    """
    m = 2 * n
    flags: List[Flag] = list(range(m))
    sigma0: Involution = {k: (k + 1 if k % 2 == 0 else k - 1) for k in flags}
    sigma1: Involution = {k: (k + 1) % m if k % 2 == 1 else (k - 1) % m
                          for k in flags}
    return flags, [sigma0, sigma1]


def _report(title: str, flags: List[Flag], sigmas: List[Involution],
            expected_degree: int) -> None:
    print(f"\n=== {title} ===")
    rank = len(sigmas)
    axioms = verify_involution_family(flags, sigmas)
    for k, v in axioms.items():
        print(f"  axiom {k:32s}: {v}")
    degs = degree_sequence(flags, sigmas)
    unique_degrees = sorted(set(degs.values()))
    print(f"  number of flags               : {len(flags)}")
    print(f"  connection involutions (rank) : {rank}")
    print(f"  degree set of flag graph      : {unique_degrees}")
    print(f"  regular of degree {expected_degree}?          : "
          f"{is_regular_of_degree(flags, sigmas, expected_degree)}")
    orbits = two_element_orbits(flags, sigmas[0])
    print(f"  #(2-element orbits of sigma_0) : {len(orbits)}  "
          f"=> flag count even: {len(flags) % 2 == 0}")


def main() -> None:
    print("Demonstration: flag graph of a rank-n maniplex is n-regular.")

    # Rank-4 (n=3): the 4-cube Q_4 is tetravalent — the headline case.
    flags4, sig4 = hypercube_family(4)
    _report("Rank-4 family on {0,1}^4  (flag graph = 4-cube Q_4)",
            flags4, sig4, expected_degree=4)

    # Rank-2: the n-gon's flag graph is a 2-valent cycle.
    flagsP, sigP = polygon_family(6)
    _report("Rank-2 family for the hexagon (flag graph = 12-cycle)",
            flagsP, sigP, expected_degree=2)

    # A sweep confirming the general rank-valence principle for several ranks.
    print("\n=== Rank-valence sweep (hypercube families) ===")
    for dim in range(1, 7):
        flags, sig = hypercube_family(dim)
        ok = is_regular_of_degree(flags, sig, dim)
        print(f"  rank {dim}: |flags| = {len(flags):3d}, "
              f"regular of degree {dim}? {ok}")


if __name__ == "__main__":
    main()
