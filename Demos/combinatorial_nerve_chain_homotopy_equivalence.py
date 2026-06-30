"""
demo.py — Numerical demonstrations for

    "The Euler Characteristic of a Covered Complex:
     Exact Inclusion-Exclusion and the Numerical Shadow of Nerve
     Reconstruction"

We work with finite *face collections*: a face is a finite set of vertex
labels (here, a frozenset of ints), and a face collection is a set of
faces.  The signed Euler characteristic of a collection X is

    echi(X) = sum over faces sigma in X of (-1) ** |sigma|

where |sigma| is the number of vertices in sigma.  This is the
"number-of-vertices" normalization; it equals -1 times the classical
dimension-graded Euler characteristic chi(X).

The central law verified here is the exact two-set inclusion-exclusion
identity

    echi(A | B) == echi(A) + echi(B) - echi(A & B)

together with its general k-set expansion

    echi(union_i A_i) == sum over nonempty S of
                         (-1)^(|S|-1) * echi(intersection_{i in S} A_i).

The script is fully self-contained and uses only the standard library.
Run with:  python demo.py
"""

from __future__ import annotations

import itertools
import random
from typing import FrozenSet, Iterable, List, Set, Tuple

# A face is a frozenset of integer vertex labels.
Face = FrozenSet[int]
# A face collection is a set of faces.
Collection = Set[Face]


# ---------------------------------------------------------------------------
# Core invariant
# ---------------------------------------------------------------------------
def echi(collection: Collection) -> int:
    """Signed Euler characteristic: sum of (-1)^|sigma| over faces sigma."""
    return sum((-1) ** len(sigma) for sigma in collection)


def classical_chi(collection: Collection) -> int:
    """Classical dimension-graded Euler characteristic, chi = -echi."""
    return -echi(collection)


# ---------------------------------------------------------------------------
# Inclusion-exclusion combinators
# ---------------------------------------------------------------------------
def echi_union_two(a: Collection, b: Collection) -> int:
    """echi(A | B) computed via two-set inclusion-exclusion."""
    return echi(a) + echi(b) - echi(a & b)


def echi_union_k(pieces: List[Collection]) -> int:
    """echi of the union of the pieces, via full k-set inclusion-exclusion.

    Sums (-1)^(|S|-1) * echi(intersection over S) over all nonempty
    subsets S of the index set.  Subsets whose intersection is empty
    contribute 0 (echi of the empty collection is 0), so this is exactly
    a sum over the nerve of the cover.
    """
    n = len(pieces)
    total = 0
    for r in range(1, n + 1):
        for combo in itertools.combinations(range(n), r):
            inter: Collection = set(pieces[combo[0]])
            for idx in combo[1:]:
                inter &= pieces[idx]
            total += ((-1) ** (r - 1)) * echi(inter)
    return total


# ---------------------------------------------------------------------------
# Helpers to build standard complexes (downward-closed face collections)
# ---------------------------------------------------------------------------
def closure(maximal_faces: Iterable[Iterable[int]]) -> Collection:
    """Downward closure: all nonempty subsets of the given maximal faces.

    Produces a genuine abstract simplicial complex from a list of its
    top-dimensional simplices.
    """
    result: Collection = set()
    for face in maximal_faces:
        verts = list(face)
        for r in range(1, len(verts) + 1):
            for sub in itertools.combinations(verts, r):
                result.add(frozenset(sub))
    return result


def tetrahedron_boundary() -> Collection:
    """Boundary of a tetrahedron: a triangulated 2-sphere.

    Maximal faces are the four triangles {0,1,2}, {0,1,3}, {0,2,3},
    {1,2,3}; we take their closure but DROP the solid 3-cell {0,1,2,3}
    (it is never a maximal face here), giving the hollow sphere.
    classical chi = 2, so echi = -2.
    """
    return closure([(0, 1, 2), (0, 1, 3), (0, 2, 3), (1, 2, 3)])


def torus_triangles() -> List[Tuple[int, int, int]]:
    """The 14 triangles of the 7-vertex Csaszar triangulation of the torus.

    Built over the cyclic group Z_7 as the orbits of {i, i+1, i+3} and
    {i, i+2, i+3}.  Their edges realize all 21 pairs of K_7, so the
    complex has 7 vertices, 21 edges and 14 triangles: classical chi = 0,
    hence echi = 0.
    """
    tris: List[Tuple[int, int, int]] = []
    for i in range(7):
        tris.append((i % 7, (i + 1) % 7, (i + 3) % 7))
        tris.append((i % 7, (i + 2) % 7, (i + 3) % 7))
    return tris


def torus_triangulation() -> Collection:
    """The 7-vertex Csaszar triangulation of the torus (closure of faces)."""
    return closure(torus_triangles())


# ---------------------------------------------------------------------------
# Random face collections (NOT necessarily complexes) for stress testing
# ---------------------------------------------------------------------------
def random_collection(n_vertices: int, n_faces: int,
                      max_dim: int, rng: random.Random) -> Collection:
    """A random finite face collection over vertices 0..n_vertices-1."""
    coll: Collection = set()
    for _ in range(n_faces):
        size = rng.randint(1, max_dim + 1)
        size = min(size, n_vertices)
        verts = rng.sample(range(n_vertices), size)
        coll.add(frozenset(verts))
    return coll


# ---------------------------------------------------------------------------
# Demonstration 1: sphere from a two-chart cover
# ---------------------------------------------------------------------------
def demo_sphere_two_cover() -> None:
    print("=" * 70)
    print("Demo 1: 2-sphere (tetrahedron boundary) from a two-chart cover")
    print("=" * 70)
    sphere = tetrahedron_boundary()
    print(f"  echi(sphere)        = {echi(sphere)}   "
          f"(classical chi = {classical_chi(sphere)})")

    # Split into two charts: a "northern" pair of triangles and a
    # "southern" pair, overlapping along their shared faces.
    north = closure([(0, 1, 2), (0, 1, 3)])
    south = closure([(0, 2, 3), (1, 2, 3)])
    union = north | south
    assert union == sphere, "north | south must reconstruct the sphere"

    lhs = echi(sphere)
    rhs = echi_union_two(north, south)
    print(f"  echi(north)         = {echi(north)}")
    print(f"  echi(south)         = {echi(south)}")
    print(f"  echi(north & south) = {echi(north & south)}")
    print(f"  inclusion-exclusion = {rhs}")
    print(f"  direct count        = {lhs}")
    assert lhs == rhs
    print("  OK: two-set law reproduces the global value.\n")


# ---------------------------------------------------------------------------
# Demonstration 2: torus
# ---------------------------------------------------------------------------
def demo_torus() -> None:
    print("=" * 70)
    print("Demo 2: triangulated torus has echi = 0 (classical chi = 0)")
    print("=" * 70)
    torus = torus_triangulation()
    print(f"  echi(torus)  = {echi(torus)}   "
          f"(classical chi = {classical_chi(torus)})")
    assert echi(torus) == 0, "torus Euler characteristic should be 0"

    # Cover the torus by two overlapping halves of its triangle list.
    tri = torus_triangles()
    a = closure(tri[:8])
    b = closure(tri[6:])
    assert (a | b) == torus
    lhs, rhs = echi(torus), echi_union_two(a, b)
    print(f"  inclusion-exclusion over two halves = {rhs}")
    print(f"  direct count                        = {lhs}")
    assert lhs == rhs
    print("  OK: two-set law holds on a space with nontrivial topology.\n")


# ---------------------------------------------------------------------------
# Demonstration 3: randomized stress test of the two-set law
# ---------------------------------------------------------------------------
def demo_random_two_set(trials: int = 5000) -> None:
    print("=" * 70)
    print(f"Demo 3: randomized two-set inclusion-exclusion ({trials} trials)")
    print("=" * 70)
    rng = random.Random(2024)
    failures = 0
    for _ in range(trials):
        a = random_collection(8, rng.randint(0, 20), 4, rng)
        b = random_collection(8, rng.randint(0, 20), 4, rng)
        if echi(a | b) != echi_union_two(a, b):
            failures += 1
    print(f"  failures = {failures} / {trials}")
    assert failures == 0
    print("  OK: identity held exactly on every random pair.\n")


# ---------------------------------------------------------------------------
# Demonstration 4: k-set expansion
# ---------------------------------------------------------------------------
def demo_k_set(trials: int = 2000) -> None:
    print("=" * 70)
    print(f"Demo 4: randomized k-set inclusion-exclusion ({trials} trials)")
    print("=" * 70)
    rng = random.Random(7)
    failures = 0
    for _ in range(trials):
        k = rng.randint(3, 5)
        pieces = [random_collection(7, rng.randint(0, 12), 3, rng)
                  for _ in range(k)]
        union: Collection = set()
        for p in pieces:
            union |= p
        if echi(union) != echi_union_k(pieces):
            failures += 1
    print(f"  failures = {failures} / {trials}")
    assert failures == 0
    print("  OK: full alternating expansion matched the direct count.\n")


def main() -> None:
    demo_sphere_two_cover()
    demo_torus()
    demo_random_two_set()
    demo_k_set()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
