"""
demo.py — Numerical demonstrations for:

  "The Opposite-Semicube Helly Property of Product Partial Cubes
   and Its Characterization by Harmonic-Evenness"

A partial cube is represented by a Hamming labeling: a set of binary
vertex-codes (tuples of 0/1) that is closed enough to be isometric in the
hypercube.  A *semicube* is the set of vertices whose code has a fixed value in
a fixed coordinate.  A partial cube is *harmonic-even* iff every three
pairwise-intersecting compatible semicubes share a common vertex (the triple
"Helly number two" condition), which we prove is equivalent to the full
opposite-semicube Helly property.

Main theorem demonstrated here:

    G □ H has the opposite-semicube Helly property
        <=>  both G and H are harmonic-even.

All functions are self-contained and type-hinted. Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Dict, FrozenSet, List, Sequence, Tuple

Vertex = Tuple[int, ...]          # a binary Hamming code
PartialCube = List[Vertex]        # list of vertex codes (all same length)
Semicube = Tuple[int, int]        # (coordinate index, bit value in {0,1})


# ---------------------------------------------------------------------------
# Basic geometry
# ---------------------------------------------------------------------------
def hamming(u: Vertex, v: Vertex) -> int:
    """Hamming distance between two equal-length binary codes."""
    return sum(1 for a, b in zip(u, v) if a != b)


def coordinates(pc: PartialCube) -> List[int]:
    """Indices of coordinates that are *used* (not constant across all vertices)."""
    n = len(pc[0])
    used: List[int] = []
    for i in range(n):
        vals = {v[i] for v in pc}
        if len(vals) == 2:
            used.append(i)
    return used


def semicubes(pc: PartialCube) -> List[Semicube]:
    """All semicubes: two per used coordinate."""
    return [(i, b) for i in coordinates(pc) for b in (0, 1)]


def semicube_vertices(pc: PartialCube, s: Semicube) -> FrozenSet[Vertex]:
    """Vertices lying in semicube s = (coordinate, bit)."""
    i, b = s
    return frozenset(v for v in pc if v[i] == b)


def is_compatible(family: Sequence[Semicube]) -> bool:
    """A family is compatible if it never contains both opposite semicubes
    (same coordinate, different bit)."""
    seen: Dict[int, int] = {}
    for i, b in family:
        if i in seen and seen[i] != b:
            return False
        seen[i] = b
    return True


# ---------------------------------------------------------------------------
# The Helly test and the harmonic-even (triple) test
# ---------------------------------------------------------------------------
def has_opposite_semicube_helly(pc: PartialCube) -> bool:
    """Brute-force full property: every compatible pairwise-intersecting family
    of semicubes has a common vertex.  Exponential; used to validate the
    polynomial triple test below."""
    scs = semicubes(pc)
    sets = {s: semicube_vertices(pc, s) for s in scs}
    n = len(scs)
    for r in range(1, n + 1):
        for fam in combinations(scs, r):
            if not is_compatible(fam):
                continue
            if any(not (sets[a] & sets[b]) for a, b in combinations(fam, 2)):
                continue  # not pairwise-intersecting
            common = frozenset(pc)
            for s in fam:
                common &= sets[s]
            if not common:
                return False
    return True


def is_harmonic_even(pc: PartialCube) -> bool:
    """Polynomial triple test: every compatible pairwise-intersecting triple of
    semicubes has a common vertex.  By the Reduction Theorem this equals the
    full opposite-semicube Helly property."""
    scs = semicubes(pc)
    sets = {s: semicube_vertices(pc, s) for s in scs}
    for fam in combinations(scs, 3):
        if not is_compatible(fam):
            continue
        if any(not (sets[a] & sets[b]) for a, b in combinations(fam, 2)):
            continue
        if not (sets[fam[0]] & sets[fam[1]] & sets[fam[2]]):
            return False
    return True


# ---------------------------------------------------------------------------
# Constructions
# ---------------------------------------------------------------------------
def hypercube(n: int) -> PartialCube:
    """Q_n: all 2^n binary codes of length n."""
    return [tuple(bits) for bits in product((0, 1), repeat=n)]


def path(m: int) -> PartialCube:
    """Path P_m on m vertices, embedded as prefixes of 1's: 0..0, 10..0, 110..0, ..."""
    return [tuple([1] * k + [0] * (m - 1 - k)) for k in range(m)]


def even_cycle(twok: int) -> PartialCube:
    """Even cycle C_{2k} on 2k vertices, standard partial-cube (Fibonacci-free)
    Hamming labeling with k coordinates.  Vertex j (0..2k-1) is labeled so that
    consecutive vertices differ in exactly one coordinate and antipodal edges
    share a theta-class."""
    assert twok % 2 == 0 and twok >= 4
    k = twok // 2
    verts: List[Vertex] = []
    for j in range(twok):
        # coordinate i is 1 for exactly the k consecutive "positions" ending at j
        code = [0] * k
        for i in range(k):
            # edge between vertex i and i+1 flips coordinate i (going forward),
            # and edge between k+i and k+i+1 flips it back.
            if i < j <= k + i:
                code[i] = 1
        verts.append(tuple(code))
    return verts


def cartesian_product(g: PartialCube, h: PartialCube) -> PartialCube:
    """G □ H: concatenate codes."""
    return [gv + hv for gv in g for hv in h]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def report(name: str, pc: PartialCube) -> bool:
    he = is_harmonic_even(pc)
    full = has_opposite_semicube_helly(pc)
    tag = "harmonic-even" if he else "NOT harmonic-even"
    match = "OK" if he == full else "MISMATCH!"
    print(f"  {name:26s} |V|={len(pc):3d}  coords={len(coordinates(pc)):2d}  "
          f"-> {tag:18s}  (triple==full: {match})")
    assert he == full, "Reduction Theorem violated on an example!"
    return he


def main() -> None:
    print("=" * 74)
    print("1. Single partial cubes: triple test == full Helly (Reduction Theorem)")
    print("=" * 74)
    report("tree/path P4", path(4))
    report("hypercube Q3", hypercube(3))
    report("square C4 = Q2", hypercube(2))
    report("hexagon C6", even_cycle(6))
    report("octagon C8", even_cycle(8))

    print()
    print("=" * 74)
    print("2. Main Theorem:  G □ H is Helly  <=>  both factors harmonic-even")
    print("=" * 74)
    factors = {
        "P4 (tree)": path(4),
        "Q2 (square)": hypercube(2),
        "C6 (hexagon)": even_cycle(6),
    }
    for (ng, g), (nh, h) in product(factors.items(), repeat=2):
        prod = cartesian_product(g, h)
        prod_helly = is_harmonic_even(prod)
        predicted = is_harmonic_even(g) and is_harmonic_even(h)
        status = "OK" if prod_helly == predicted else "MISMATCH!"
        print(f"  {ng:14s} □ {nh:14s} -> product Helly={str(prod_helly):5s}  "
              f"predicted={str(predicted):5s}  [{status}]")
        assert prod_helly == predicted, "Main Theorem violated!"

    print()
    print("=" * 74)
    print("3. Witness that C6 fails: three pairwise-meeting arcs, empty triple")
    print("=" * 74)
    c6 = even_cycle(6)
    scs = semicubes(c6)
    sets = {s: semicube_vertices(c6, s) for s in scs}
    for fam in combinations(scs, 3):
        if not is_compatible(fam):
            continue
        if all(sets[a] & sets[b] for a, b in combinations(fam, 2)) and not (
            sets[fam[0]] & sets[fam[1]] & sets[fam[2]]
        ):
            print(f"  bad triple of semicubes: {fam}")
            for s in fam:
                print(f"     semicube {s}: {sorted(sets[s])}")
            break

    print()
    print("All assertions passed: Reduction Theorem and Main Theorem hold on"
          " every example above.")


if __name__ == "__main__":
    main()
