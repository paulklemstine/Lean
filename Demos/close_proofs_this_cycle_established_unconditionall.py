"""
Numerical demonstrations for:

    The Z2-Coindex Under Suspension: A Constructive Lower-Bound Theory
    for Free Z2-Complexes.

This self-contained script builds the octahedral combinatorial spheres S^n
(boundary complexes of cross-polytopes), the antipodal Z2-action, and the
category of Z2-maps between them, and then reproduces the paper's main results
numerically:

  1. The antipodal map is a free involution.
  2. The suspension functor turns a Z2-map S^m -> S^n into one S^(m+1) -> S^(n+1).
  3. The constructive lower bound: an explicit Z2-map S^m -> S^n whenever m <= n.
  4. The decidable existence criterion (search over positive-vertex images).
  5. The base-case Borsuk-Ulam obstructions: no Z2-map S^1 -> S^0, none S^2 -> S^1.
  6. Sharpness of the suspension increment at the base of the tower.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Iterator, List, Optional, Tuple

# A vertex of S^n is (index, sign_bit): (i, True) = +e_i, (i, False) = -e_i.
Vertex = Tuple[int, bool]
VertexMap = Callable[[Vertex], Vertex]


# ---------------------------------------------------------------------------
# The combinatorial sphere and its antipodal action
# ---------------------------------------------------------------------------

def vertices(n: int) -> List[Vertex]:
    """All 2*(n+1) vertices of the n-dimensional combinatorial sphere S^n."""
    return [(i, b) for i in range(n + 1) for b in (True, False)]


def anti(p: Vertex) -> Vertex:
    """The antipodal map: flip the sign bit."""
    i, b = p
    return (i, not b)


def is_free_involution(n: int) -> bool:
    """anti is a fixed-point-free involution on V(S^n)."""
    return all(anti(anti(p)) == p and anti(p) != p for p in vertices(n))


def is_face(sigma: Tuple[Vertex, ...]) -> bool:
    """A face of the cross-polytope: no antipodal pair (>=1 sign per axis)."""
    seen: set[int] = set()
    for (i, _b) in sigma:
        if i in seen:
            return False
        seen.add(i)
    return True


# ---------------------------------------------------------------------------
# Z2-maps: equivariant + simplicial (local vertex-pair form)
# ---------------------------------------------------------------------------

def is_equivariant(f: VertexMap, m: int) -> bool:
    """f(anti p) == anti(f p) for all p in V(S^m)."""
    return all(f(anti(p)) == anti(f(p)) for p in vertices(m))


def is_simplicial(f: VertexMap, m: int) -> bool:
    """f(p) == anti(f(q))  =>  p == anti(q)   (faces map to faces)."""
    verts = vertices(m)
    for p in verts:
        for q in verts:
            if f(p) == anti(f(q)) and p != anti(q):
                return False
    return True


def is_z2_map(f: VertexMap, m: int) -> bool:
    return is_equivariant(f, m) and is_simplicial(f, m)


# ---------------------------------------------------------------------------
# Building blocks: identity, composition, equatorial inclusion, suspension
# ---------------------------------------------------------------------------

def z2_id() -> VertexMap:
    return lambda p: p


def z2_comp(g: VertexMap, f: VertexMap) -> VertexMap:
    return lambda p: g(f(p))


def z2_incl() -> VertexMap:
    """Equatorial inclusion S^n -> S^(n+1): reuse the index, keep the sign."""
    return lambda p: (p[0], p[1])  # index unchanged; lives in the larger sphere


def susp_vertex(p: Vertex) -> Vertex:
    """suspV: reuse the index in the enlarged sphere (never the top pole index)."""
    return (p[0], p[1])


def z2_susp(f: VertexMap, m: int, n: int) -> VertexMap:
    """Suspension functor with explicit source/target dimensions (poles known)."""
    def g(p: Vertex) -> Vertex:
        i, b = p
        if i == m + 1:               # pole of S^(m+1)
            return (n + 1, b)        # pole of S^(n+1)
        return susp_vertex(f((i, b)))
    return g


def explicit_lower_bound_map(m: int, n: int) -> VertexMap:
    """Constructive witness for m <= n: identity of S^m, then (n-m) inclusions.

    Since the equatorial inclusion keeps (index, sign) unchanged, the composite
    is simply the identity-on-coordinates embedding S^m -> S^n.
    """
    assert m <= n
    f = z2_id()
    for _ in range(n - m):
        f = z2_comp(z2_incl(), f)
    return f


# ---------------------------------------------------------------------------
# Decidable existence criterion via positive-vertex data
# ---------------------------------------------------------------------------

def induced(g: List[Vertex]) -> VertexMap:
    """Reconstruct a full equivariant map from images of the positive vertices."""
    def f(p: Vertex) -> Vertex:
        i, b = p
        return g[i] if b else anti(g[i])
    return f


def all_positive_data(m: int, n: int) -> Iterator[List[Vertex]]:
    """All assignments g : {0,...,m} -> V(S^n) of positive-vertex images."""
    for combo in product(vertices(n), repeat=m + 1):
        yield list(combo)


def exists_z2_map(m: int, n: int) -> Optional[List[Vertex]]:
    """Return positive-vertex data of a Z2-map S^m -> S^n, or None if none exists."""
    for g in all_positive_data(m, n):
        f = induced(g)
        if is_simplicial(f, m):      # induced maps are automatically equivariant
            return g
    return None


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_free_involution() -> None:
    print("=" * 70)
    print("1. Antipodal map is a free involution on S^n")
    print("=" * 70)
    for n in range(4):
        print(f"   S^{n}: {2*(n+1)} vertices, free involution = {is_free_involution(n)}")
    print()


def demo_suspension_functor() -> None:
    print("=" * 70)
    print("2. Suspension functor sends Z2-maps S^m->S^n to S^(m+1)->S^(n+1)")
    print("=" * 70)
    for m, n in [(0, 0), (0, 1), (1, 1), (1, 2), (2, 2)]:
        f = explicit_lower_bound_map(m, n)
        assert is_z2_map(f, m), "base map must be a Z2-map"
        sf = z2_susp(f, m, n)
        ok = is_z2_map(sf, m + 1)
        print(f"   susp: (S^{m}->S^{n})  |->  (S^{m+1}->S^{n+1})   valid Z2-map = {ok}")
    print()


def demo_lower_bound() -> None:
    print("=" * 70)
    print("3. Constructive lower bound: explicit Z2-map S^m -> S^n for m <= n")
    print("=" * 70)
    for n in range(4):
        for m in range(n + 1):
            f = explicit_lower_bound_map(m, n)
            print(f"   S^{m} -> S^{n}: Z2-map = {is_z2_map(f, m)}  "
                  f"(coind(S^{n}) >= {n})")
    print()


def demo_decidable_criterion() -> None:
    print("=" * 70)
    print("4. Decidable existence criterion (search over positive-vertex images)")
    print("=" * 70)
    for m, n in [(0, 0), (1, 1), (1, 2), (2, 2)]:
        g = exists_z2_map(m, n)
        print(f"   Z2-map S^{m} -> S^{n} exists = {g is not None}  "
              f"witness images = {g}")
    print()


def demo_borsuk_ulam() -> None:
    print("=" * 70)
    print("5. Base-case Borsuk-Ulam obstructions (exhaustive finite search)")
    print("=" * 70)
    g10 = exists_z2_map(1, 0)
    g21 = exists_z2_map(2, 1)
    print(f"   Z2-map S^1 -> S^0 exists = {g10 is not None}   (expected: False)")
    print(f"   Z2-map S^2 -> S^1 exists = {g21 is not None}   (expected: False)")
    assert g10 is None and g21 is None
    print("   -> No such maps: the classical Borsuk-Ulam obstruction, verified.")
    print()


def demo_sharp_increment() -> None:
    print("=" * 70)
    print("6. Sharp suspension increment at the base of the tower")
    print("=" * 70)
    coind0_ge0 = exists_z2_map(0, 0) is not None
    coind0_lt1 = exists_z2_map(1, 0) is None
    coind1_ge1 = exists_z2_map(1, 1) is not None
    coind1_lt2 = exists_z2_map(2, 1) is None
    print(f"   coind(S^0) >= 0 : {coind0_ge0}     coind(S^0) < 1 : {coind0_lt1}")
    print(f"   coind(S^1) >= 1 : {coind1_ge1}     coind(S^1) < 2 : {coind1_lt2}")
    if coind0_ge0 and coind0_lt1 and coind1_ge1 and coind1_lt2:
        print("   => coind(S^0) = 0, coind(S^1) = 1: increment is exactly one.")
    print()


def main() -> None:
    demo_free_involution()
    demo_suspension_functor()
    demo_lower_bound()
    demo_decidable_criterion()
    demo_borsuk_ulam()
    demo_sharp_increment()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
