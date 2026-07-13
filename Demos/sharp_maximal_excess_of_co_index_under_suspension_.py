"""
Numerical demonstration: the co-index of free Z2-complexes under suspension.

This self-contained script implements the crystalline combinatorial model behind
the paper:

  * free Z2-simplicial complexes (a free antipodal involution on vertices plus a
    downward-closed, antipode-invariant family of faces),
  * the octahedral n-spheres Oct(n) (triangulations of S^n),
  * the unreduced suspension S(K) = K * S^0,
  * equivariant ("Z2-") simplicial maps, and their composition/functoriality,
  * the explicit connecting map Oct(n+1) -> S(Oct n) realizing S^{n+1} ~= S(S^n).

It then verifies, on concrete finite examples, the main theorems:

  1. Oct(n) has dimension exactly n, and its top face is the positive orthant.
  2. Suspension raises dimension by exactly one.
  3. The connecting map phi_n is equivariant and simplicial (raises co-index +1).
  4. The Borsuk-Ulam base case: no equivariant simplicial map Oct(n) -> Oct(0)
     for n >= 1, exhibited by an exhaustive search over all vertex maps.

Vertices are encoded as follows.

  * Oct(n): pairs (i, s) with axis i in {0,...,n} and sign s in {+1, -1}.
  * Suspension S(K) over base vertex set V: base vertices are ("base", v) and the
    two apexes are ("apex", +1) [North] and ("apex", -1) [South].
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Callable, FrozenSet, Iterable, List, Tuple

# ---------------------------------------------------------------------------
# Vertex type aliases (kept simple and hashable).
# ---------------------------------------------------------------------------
OctVertex = Tuple[int, int]                 # (axis, sign)  with sign in {+1,-1}
Vertex = object                             # generic hashable vertex
Face = FrozenSet[Vertex]


# ---------------------------------------------------------------------------
# Free Z2-complex, presented finitely by its vertex set, involution and a
# face-membership predicate.
# ---------------------------------------------------------------------------
class Z2Complex:
    """A finite free Z2-simplicial complex."""

    def __init__(
        self,
        vertices: Iterable[Vertex],
        alpha: Callable[[Vertex], Vertex],
        is_face: Callable[[Face], bool],
        name: str = "K",
    ) -> None:
        self.vertices: List[Vertex] = list(vertices)
        self.alpha = alpha
        self._is_face = is_face
        self.name = name

    def is_face(self, s: Iterable[Vertex]) -> bool:
        return self._is_face(frozenset(s))

    def faces(self) -> List[Face]:
        """Enumerate all faces (feasible only for small complexes)."""
        result: List[Face] = []
        vs = self.vertices
        for k in range(len(vs) + 1):
            for combo in combinations(vs, k):
                if self.is_face(combo):
                    result.append(frozenset(combo))
        return result

    def dimension(self) -> int:
        return max((len(f) - 1 for f in self.faces()), default=-1)

    def is_free(self) -> bool:
        """Involutive and fixed-point free."""
        for v in self.vertices:
            if self.alpha(v) == v:
                return False
            if self.alpha(self.alpha(v)) != v:
                return False
        return True


# ---------------------------------------------------------------------------
# The octahedral n-sphere Oct(n): boundary of the (n+1)-cross-polytope.
# ---------------------------------------------------------------------------
def oct_sphere(n: int) -> Z2Complex:
    vertices: List[OctVertex] = [(i, s) for i in range(n + 1) for s in (+1, -1)]

    def alpha(v: OctVertex) -> OctVertex:
        i, s = v
        return (i, -s)

    def is_face(s: Face) -> bool:
        # No antipodal pair: each axis appears with at most one sign.
        axes = [i for (i, _) in s]
        return len(axes) == len(set(axes))

    return Z2Complex(vertices, alpha, is_face, name=f"Oct({n})")


# ---------------------------------------------------------------------------
# Unreduced suspension S(K) = K * S^0.
# ---------------------------------------------------------------------------
NORTH = ("apex", +1)
SOUTH = ("apex", -1)


def suspension(K: Z2Complex) -> Z2Complex:
    base = [("base", v) for v in K.vertices]
    vertices = base + [NORTH, SOUTH]

    def alpha(v: Vertex) -> Vertex:
        tag, x = v
        if tag == "base":
            return ("base", K.alpha(x))
        return ("apex", -x)

    def is_face(s: Face) -> bool:
        base_part = frozenset(x for (tag, x) in s if tag == "base")
        if not K.is_face(base_part):
            return False
        # The two apexes are never joined (they are the two points of S^0).
        if NORTH in s and SOUTH in s:
            return False
        return True

    return Z2Complex(vertices, alpha, is_face, name=f"S({K.name})")


# ---------------------------------------------------------------------------
# Equivariant ("Z2-") simplicial maps.
# ---------------------------------------------------------------------------
def is_equivariant(f: Callable[[Vertex], Vertex], K: Z2Complex, L: Z2Complex) -> bool:
    return all(f(K.alpha(v)) == L.alpha(f(v)) for v in K.vertices)


def is_simplicial(f: Callable[[Vertex], Vertex], K: Z2Complex, L: Z2Complex) -> bool:
    return all(L.is_face(frozenset(f(v) for v in face)) for face in K.faces())


def is_z2_simplicial_map(
    f: Callable[[Vertex], Vertex], K: Z2Complex, L: Z2Complex
) -> bool:
    return is_equivariant(f, K, L) and is_simplicial(f, K, L)


# ---------------------------------------------------------------------------
# The explicit connecting map phi_n : Oct(n+1) -> S(Oct(n)).
# The last axis n+1 becomes the two apexes; the others stay in the base.
# ---------------------------------------------------------------------------
def connecting_map(n: int) -> Callable[[OctVertex], Vertex]:
    def phi(v: OctVertex) -> Vertex:
        i, s = v
        if i <= n:
            return ("base", (i, s))
        return ("apex", s)  # i == n+1

    return phi


# ---------------------------------------------------------------------------
# Demonstrations.
# ---------------------------------------------------------------------------
def demo_dimensions(max_n: int = 4) -> None:
    print("=" * 68)
    print("1. Octahedral spheres Oct(n): dimension equals n")
    print("=" * 68)
    for n in range(max_n + 1):
        K = oct_sphere(n)
        top = frozenset((i, +1) for i in range(n + 1))
        print(
            f"  Oct({n}): #vertices={len(K.vertices):2d}, "
            f"dim={K.dimension()} (expected {n}), "
            f"free involution={K.is_free()}, "
            f"positive-orthant is a top face={K.is_face(top)} (|orthant|={len(top)})"
        )


def demo_suspension_dimension(max_n: int = 3) -> None:
    print("=" * 68)
    print("2. Suspension raises dimension by exactly one")
    print("=" * 68)
    for n in range(max_n + 1):
        K = oct_sphere(n)
        SK = suspension(K)
        print(
            f"  dim Oct({n})={K.dimension()},  dim S(Oct({n}))={SK.dimension()} "
            f"(expected {K.dimension() + 1}),  S(K) free={SK.is_free()}"
        )


def demo_connecting_map(max_n: int = 3) -> None:
    print("=" * 68)
    print("3. Connecting map phi_n : Oct(n+1) -> S(Oct n)  (co-index +1)")
    print("=" * 68)
    for n in range(max_n + 1):
        src = oct_sphere(n + 1)
        tgt = suspension(oct_sphere(n))
        phi = connecting_map(n)
        equi = is_equivariant(phi, src, tgt)
        simp = is_simplicial(phi, src, tgt)
        print(
            f"  phi_{n}: Oct({n + 1}) -> S(Oct({n})): "
            f"equivariant={equi}, simplicial={simp}  =>  "
            f"co-index rises from {n} to at least {n + 1}"
        )


def demo_composition() -> None:
    print("=" * 68)
    print("4. Functoriality: identity certificate climbs the tower")
    print("=" * 68)
    # Start with the identity Oct(1) -> Oct(1); suspend and precompose with phi.
    K = oct_sphere(1)
    identity = lambda v: v
    print(f"  id: Oct(1) -> Oct(1) is a Z2-map: {is_z2_simplicial_map(identity, K, K)}")

    # Suspend the identity: S(id): S(Oct 1) -> S(Oct 1) (identity on base + apex).
    SK = suspension(K)
    Sid = lambda v: v
    print(f"  S(id): S(Oct 1) -> S(Oct 1) is a Z2-map: {is_z2_simplicial_map(Sid, SK, SK)}")

    # Compose phi_1 then S(id): a Z2-map Oct(2) -> S(Oct 1).
    phi = connecting_map(1)
    composite = lambda v: Sid(phi(v))
    src = oct_sphere(2)
    print(
        f"  S(id) . phi_1: Oct(2) -> S(Oct 1) is a Z2-map: "
        f"{is_z2_simplicial_map(composite, src, SK)}  "
        f"(=> coind(S(Oct 1)) >= 2)"
    )


def demo_borsuk_ulam(max_n: int = 3) -> None:
    print("=" * 68)
    print("5. Borsuk-Ulam base case: no Z2-map Oct(n) -> Oct(0) for n >= 1")
    print("=" * 68)
    target = oct_sphere(0)
    target_vertices = target.vertices  # exactly two vertices
    for n in range(0, max_n + 1):
        src = oct_sphere(n)
        # Exhaustively search all vertex maps that are equivariant, then test
        # simpliciality. Equivariance halves the free choices (one per axis).
        found = False
        # A map is determined by the image of the '+' end of each axis;
        # the '-' end is forced by equivariance.
        for choice in product(target_vertices, repeat=n + 1):
            def f(v: OctVertex, choice=choice) -> OctVertex:
                i, s = v
                base_img = choice[i]  # image of (i, +1)
                return base_img if s == +1 else target.alpha(base_img)
            if is_z2_simplicial_map(f, src, target):
                found = True
                break
        verdict = "EXISTS" if found else "NONE"
        note = "" if n == 0 else "  (Borsuk-Ulam obstruction confirmed)"
        print(f"  Oct({n}) -> Oct(0): equivariant simplicial map {verdict}{note}")


def main() -> None:
    demo_dimensions()
    print()
    demo_suspension_dimension()
    print()
    demo_connecting_map()
    print()
    demo_composition()
    print()
    demo_borsuk_ulam()
    print()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
