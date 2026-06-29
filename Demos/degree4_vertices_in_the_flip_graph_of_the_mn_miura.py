"""
Numerical demonstrations for:

    Mountain-Valley Configurations and the Hypercube Flip Graph of the Miura-ori

This self-contained script reproduces, by direct computation, every theorem in
the accompanying paper:

  Local degree-4 vertex
    * mountains_of_genericValid : every generic-valid MV assignment has 1 or 3
      mountains (Maekawa's theorem, combinatorial form).
    * card_genericValid         : there are exactly 4 generic-valid MV
      assignments (Hull's count).

  Flip graph Q_d (Boolean hypercube)
    * flipGraph_adj_iff      : adjacency == single-coordinate flip.
    * flipGraph_degree       : Q_d is d-regular.
    * flipGraph_degree_four  : Q_4 is 4-regular.
    * flipGraph_card_verts   : Q_d has 2^d vertices.
    * flipGraph_card_edges   : Q_d has d * 2^(d-1) edges.
    * flipGraph_connected    : Q_d is connected.
    * flipGraph_adj_parity   : adjacent configs differ in mountain-count parity
                               (bipartiteness).

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Tuple

# A configuration of d binary degrees of freedom is a tuple of bools.
# True == mountain, False == valley.
Config = Tuple[bool, ...]


# --------------------------------------------------------------------------- #
# Local degree-4 vertex
# --------------------------------------------------------------------------- #

def all_assignments(d: int) -> List[Config]:
    """All 2^d Boolean assignments on d creases/coordinates."""
    return [tuple(bits) for bits in product([False, True], repeat=d)]


def mountains(a: Config) -> int:
    """Number of mountain creases (True coordinates)."""
    return sum(1 for x in a if x)


def generic_valid(a: Config) -> bool:
    """Hull's generic flat-foldable characterization for a degree-4 vertex:
    the two creases bounding the unique smallest sector (0,1) fold oppositely,
    and the opposite pair (2,3) folds the same way."""
    return (a[0] != a[1]) and (a[2] == a[3])


def demo_local_vertex() -> None:
    print("=" * 64)
    print("LOCAL DEGREE-4 VERTEX")
    print("=" * 64)
    assigns = all_assignments(4)
    valid = [a for a in assigns if generic_valid(a)]

    print(f"Total MV assignments (2^4)         : {len(assigns)}")
    print(f"Generic-valid assignments          : {len(valid)}  "
          f"(card_genericValid expects 4)")
    assert len(valid) == 4

    print("\nThe four generic-valid assignments (M=mountain, V=valley):")
    for a in valid:
        glyph = "".join("M" if x else "V" for x in a)
        print(f"   {glyph}   mountains = {mountains(a)}")

    # Maekawa: every generic-valid assignment has 1 or 3 mountains.
    assert all(mountains(a) in (1, 3) for a in valid)
    print("\nMaekawa check: every generic-valid vertex has 1 or 3 mountains  [OK]")

    # Per-crease flips break validity (3-1 -> 2-2): the per-crease graph on
    # valid states is edgeless.
    def crease_flip(a: Config, i: int) -> Config:
        return a[:i] + (not a[i],) + a[i + 1:]

    edges = 0
    for a in valid:
        for i in range(4):
            if generic_valid(crease_flip(a, i)):
                edges += 1
    print(f"Per-crease flip edges among valid states : {edges}  "
          f"(expected 0 -> edgeless)")
    assert edges == 0


# --------------------------------------------------------------------------- #
# Flip graph Q_d (Boolean hypercube)
# --------------------------------------------------------------------------- #

def flip(a: Config, i: int) -> Config:
    """Toggle coordinate i:  a^(i) = update(a, i, not a[i])."""
    return a[:i] + (not a[i],) + a[i + 1:]


def hamming(a: Config, b: Config) -> int:
    """Number of coordinates in which a and b disagree."""
    return sum(1 for x, y in zip(a, b) if x != y)


def adjacent(a: Config, b: Config) -> bool:
    """Q_d adjacency: unit Hamming distance."""
    return hamming(a, b) == 1


def neighbors(a: Config) -> List[Config]:
    """The d single-flip neighbors of a (flipGraph_adj_iff)."""
    return [flip(a, i) for i in range(len(a))]


def degree(a: Config) -> int:
    return len(neighbors(a))


def edge_count(d: int) -> int:
    """Number of edges of Q_d via the handshake lemma."""
    verts = all_assignments(d)
    total_degree = sum(degree(a) for a in verts)
    assert total_degree % 2 == 0
    return total_degree // 2


def is_connected(d: int) -> bool:
    """BFS from the all-mountain configuration."""
    verts = all_assignments(d)
    start: Config = tuple([True] * d)
    seen = {start}
    frontier = [start]
    while frontier:
        nxt: List[Config] = []
        for a in frontier:
            for b in neighbors(a):
                if b not in seen:
                    seen.add(b)
                    nxt.append(b)
        frontier = nxt
    return len(seen) == len(verts)


def reconfiguration_path(a: Config, b: Config) -> List[Config]:
    """Geodesic: flip the disagreeing coordinates one at a time."""
    path = [a]
    cur = a
    for i in range(len(a)):
        if cur[i] != b[i]:
            cur = flip(cur, i)
            path.append(cur)
    assert cur == b
    return path


def demo_flip_graph(max_d: int = 6) -> None:
    print("\n" + "=" * 64)
    print("FLIP GRAPH  Q_d  (BOOLEAN HYPERCUBE)")
    print("=" * 64)
    print(f"{'d':>3} | {'vertices':>9} | {'all deg = d?':>12} | "
          f"{'edges':>7} | {'d*2^(d-1)':>10} | {'connected':>9}")
    print("-" * 64)
    for d in range(1, max_d + 1):
        verts = all_assignments(d)
        regular = all(degree(a) == d for a in verts)      # flipGraph_degree
        E = edge_count(d)                                 # flipGraph_card_edges
        E_formula = d * 2 ** (d - 1)
        conn = is_connected(d)                            # flipGraph_connected
        assert len(verts) == 2 ** d                       # flipGraph_card_verts
        assert regular
        assert E == E_formula
        assert conn
        print(f"{d:>3} | {len(verts):>9} | {str(regular):>12} | "
              f"{E:>7} | {E_formula:>10} | {str(conn):>9}")

    # flipGraph_degree_four spotlight
    print("\nQ_4 spotlight (flipGraph_degree_four): every vertex has degree 4.")
    assert all(degree(a) == 4 for a in all_assignments(4))

    # Bipartiteness / parity invariant (flipGraph_adj_parity)
    d = 4
    ok = all(
        (mountains(a) % 2) != (mountains(b) % 2)
        for a in all_assignments(d)
        for b in neighbors(a)
    )
    print(f"Parity invariant on Q_{d}: adjacent configs differ in "
          f"mountain-count parity -> bipartite  [{'OK' if ok else 'FAIL'}]")
    assert ok

    # Connectivity, constructively: a geodesic of length = Hamming distance.
    a: Config = (True, True, True, True)
    b: Config = (False, True, False, False)
    path = reconfiguration_path(a, b)
    print(f"\nGeodesic from {''.join('M' if x else 'V' for x in a)} "
          f"to {''.join('M' if x else 'V' for x in b)}:")
    for step in path:
        print("   " + "".join("M" if x else "V" for x in step))
    print(f"Path length = {len(path) - 1} = Hamming distance "
          f"{hamming(a, b)}  [OK]")
    assert len(path) - 1 == hamming(a, b)


def main() -> None:
    demo_local_vertex()
    demo_flip_graph(max_d=6)
    print("\nAll theorem checks passed.")


if __name__ == "__main__":
    main()
