"""Numerical demonstrations of harmonic-even balance and the opposite-semicube
Helly property of partial cubes.

Model
-----
A partial cube is represented in the *coordinate model*: a vertex is a tuple of
booleans (a sign vector) and a partial cube is a set of such tuples, all of the
same length ``d`` (the number of coordinates / Theta-classes).

For a coordinate ``i`` the two *opposite semicubes* are the vertices whose
``i``-th entry is ``True`` and those whose ``i``-th entry is ``False``.

This script demonstrates, on concrete examples, the four pillars of the theory:

  1. Matching-Balance Equivalence: the opposite-semicube Helly property holds
     iff every coordinate is balanced (harmonic-evenness).
  2. Canonical Mirror: antipodal closure implies harmonic-evenness, witnessed
     by the antipode (flip every bit); in particular the full hypercube.
  3. Parity Obstruction: a harmonic-even set over >=1 coordinate has even size.
  4. Product Balance Law: a Cartesian product of nonempty partial cubes is
     harmonic-even iff every factor is.
"""

from __future__ import annotations

from itertools import product as iproduct
from typing import Dict, List, Sequence, Tuple

Vertex = Tuple[bool, ...]
PartialCube = List[Vertex]


# --------------------------------------------------------------------------- #
# Core notions
# --------------------------------------------------------------------------- #
def semicube(V: Sequence[Vertex], i: int, b: bool) -> List[Vertex]:
    """The semicube of coordinate ``i`` with sign ``b``: vertices with v[i] == b."""
    return [v for v in V if v[i] == b]


def is_balanced(V: Sequence[Vertex], i: int) -> bool:
    """Coordinate ``i`` is balanced iff its two opposite semicubes are equinumerous."""
    return len(semicube(V, i, True)) == len(semicube(V, i, False))


def dimension(V: Sequence[Vertex]) -> int:
    """Number of coordinates; assumes all vertices share one length."""
    return len(V[0]) if V else 0


def is_harmonic_even(V: Sequence[Vertex]) -> bool:
    """Harmonic-even: every coordinate splits V into two equal-sized semicubes."""
    return all(is_balanced(V, i) for i in range(dimension(V)))


def has_matching(V: Sequence[Vertex], i: int) -> bool:
    """A bijection between the two opposite semicubes exists iff they are equinumerous."""
    return len(semicube(V, i, True)) == len(semicube(V, i, False))


def opposite_semicube_helly(V: Sequence[Vertex]) -> bool:
    """Opposite-semicube Helly property: every cut admits a matching."""
    return all(has_matching(V, i) for i in range(dimension(V)))


# --------------------------------------------------------------------------- #
# Antipodal symmetry
# --------------------------------------------------------------------------- #
def antipode(v: Vertex) -> Vertex:
    """Coordinatewise complement (flip every bit)."""
    return tuple(not x for x in v)


def is_antipodally_closed(V: Sequence[Vertex]) -> bool:
    """Closed under the antipodal involution v -> not v."""
    S = set(V)
    return all(antipode(v) in S for v in V)


def canonical_matching(V: Sequence[Vertex], i: int) -> Dict[Vertex, Vertex]:
    """If V is antipodally closed, the antipode matches the True side to the False
    side of coordinate ``i`` (fixed-point-free)."""
    return {v: antipode(v) for v in semicube(V, i, True)}


# --------------------------------------------------------------------------- #
# Cartesian product (finite family) on the disjoint-union coordinate set
# --------------------------------------------------------------------------- #
def cartesian_product(factors: Sequence[PartialCube]) -> PartialCube:
    """Merge a finite family of partial cubes into a single partial cube whose
    coordinate set is the disjoint union (concatenation) of the factor coordinates."""
    merged: PartialCube = []
    for combo in iproduct(*factors):
        merged.append(tuple(x for v in combo for x in v))
    return merged


# --------------------------------------------------------------------------- #
# Example partial cubes
# --------------------------------------------------------------------------- #
def hypercube(d: int) -> PartialCube:
    """The full d-dimensional hypercube: all 2^d sign vectors."""
    return [tuple(bits) for bits in iproduct([False, True], repeat=d)]


def even_cycle(m: int) -> PartialCube:
    """The 2m-cycle as a partial cube on m coordinates (a standard construction:
    vertex k is the sign vector with the first k coordinates True for k = 0..m,
    then decreasing back). Here we use the classic 'staircase' embedding that is
    antipodally closed for the full cycle."""
    verts: PartialCube = []
    # Ascending arc: k Trues followed by (m-k) Falses, k = 0..m-1
    for k in range(m):
        verts.append(tuple([True] * k + [False] * (m - k)))
    # Descending arc: complements of the ascending arc give the other half
    for k in range(m):
        verts.append(antipode(verts[k]))
    return verts


def path(n_vertices: int) -> PartialCube:
    """A path on n vertices as a partial cube on (n-1) coordinates:
    vertex k has its first k coordinates True."""
    d = n_vertices - 1
    return [tuple([True] * k + [False] * (d - k)) for k in range(n_vertices)]


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_equivalence() -> None:
    print("=" * 70)
    print("1. Matching-Balance Equivalence (Helly property == harmonic-even)")
    print("=" * 70)
    examples = {
        "Q_3 (hypercube dim 3)": hypercube(3),
        "6-cycle (even_cycle m=3)": even_cycle(3),
        "path on 3 vertices": path(3),
        "path on 4 vertices": path(4),
    }
    for name, V in examples.items():
        he = is_harmonic_even(V)
        helly = opposite_semicube_helly(V)
        print(f"  {name:28s} | vertices={len(V):3d} | "
              f"harmonic-even={he!s:5s} | Helly={helly!s:5s} | match={he == helly}")
    print()


def demo_canonical_mirror() -> None:
    print("=" * 70)
    print("2. Canonical Mirror (antipodal closure => harmonic-even)")
    print("=" * 70)
    V = hypercube(3)
    print(f"  Q_3 antipodally closed: {is_antipodally_closed(V)}")
    print(f"  Q_3 harmonic-even:      {is_harmonic_even(V)}")
    match0 = canonical_matching(V, 0)
    print("  Canonical matching of cut 0 (True side -> False side via antipode):")
    for src, dst in list(match0.items())[:4]:
        s = "".join("1" if b else "0" for b in src)
        t = "".join("1" if b else "0" for b in dst)
        print(f"    {s} -> {t}   (fixed-point-free: {src != dst})")
    print()


def demo_parity() -> None:
    print("=" * 70)
    print("3. Parity Obstruction (harmonic-even => even vertex count)")
    print("=" * 70)
    for name, V in {"Q_2": hypercube(2), "6-cycle": even_cycle(3),
                    "path on 3 vertices (odd)": path(3)}.items():
        he = is_harmonic_even(V)
        parity = "even" if len(V) % 2 == 0 else "odd"
        note = ""
        if len(V) % 2 == 1:
            note = "  <- odd size forces NOT harmonic-even"
        print(f"  {name:26s} | size={len(V):3d} ({parity}) | "
              f"harmonic-even={he}{note}")
    print()


def demo_product_law() -> None:
    print("=" * 70)
    print("4. Product Balance Law (product harmonic-even iff every factor is)")
    print("=" * 70)
    cases = [
        ("Q_1 x 6-cycle", [hypercube(1), even_cycle(3)]),
        ("Q_2 x Q_1", [hypercube(2), hypercube(1)]),
        ("6-cycle x path(3)", [even_cycle(3), path(3)]),
        ("path(3) x path(4)", [path(3), path(4)]),
    ]
    for name, factors in cases:
        prod = cartesian_product(factors)
        each = [is_harmonic_even(f) for f in factors]
        prod_he = is_harmonic_even(prod)
        print(f"  {name:22s} | factor HE={each} | "
              f"product size={len(prod):3d} | product HE={prod_he} | "
              f"law holds={prod_he == all(each)}")
    print()


def main() -> None:
    demo_equivalence()
    demo_canonical_mirror()
    demo_parity()
    demo_product_law()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
