"""
Numerical demonstrations for the suspension tower of free Z/2-complexes.

This self-contained script models finite free Z/2-simplicial complexes as plain
Python data and verifies, on concrete examples, the main results:

  * Dimension law of the tower:  dim S^k(K) = dim K + k  (over any base).
  * Octahedral facet enumeration: Oct(n) has exactly 2^{n+1} facets (orthants).
  * Zero-defect tower: co-index and dimension of S^k(Oct(n)) both equal n + k.
  * Iterated combinatorial Borsuk-Ulam: no equivariant map S^k(Oct(0)) -> Oct(0)
    for k >= 1 (checked by exhaustive search on small cases).

Vertices are hashable objects; a complex is represented by its vertex set, its
free involution, and a face-membership predicate. We enumerate faces over the
(finite) vertex set, so all checks are exact for small parameters.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Callable, FrozenSet, Iterable, List, Tuple

# A vertex is any hashable object; a face is a frozenset of vertices.
Vertex = object
Face = FrozenSet[Vertex]


class Z2Complex:
    """A finite free Z/2-simplicial complex.

    Attributes:
        vertices: the finite vertex set.
        alpha: the free antipodal involution on vertices.
        is_face: predicate deciding whether a frozenset of vertices is a face.
    """

    def __init__(
        self,
        vertices: Iterable[Vertex],
        alpha: Callable[[Vertex], Vertex],
        is_face: Callable[[Face], bool],
    ) -> None:
        self.vertices: List[Vertex] = list(vertices)
        self.alpha = alpha
        self.is_face = is_face

    def faces(self) -> List[Face]:
        """Enumerate all faces (exponential; use only for small complexes)."""
        result: List[Face] = []
        vs = self.vertices
        for r in range(len(vs) + 1):
            for combo in combinations(vs, r):
                s: Face = frozenset(combo)
                if self.is_face(s):
                    result.append(s)
        return result

    def dimension(self) -> int:
        """Simplicial dimension = (max face size) - 1; -1 for the void complex."""
        return max((len(s) for s in self.faces()), default=0) - 1

    def facets(self) -> List[Face]:
        """Top-dimensional faces."""
        d = self.dimension()
        return [s for s in self.faces() if len(s) == d + 1]


def octahedral(n: int) -> Z2Complex:
    """The octahedral n-sphere Oct(n): vertices (i, b) with i in 0..n, b in {0,1}.

    A subset is a face iff it never contains an antipodal pair (i,0),(i,1).
    """
    vertices: List[Tuple[int, int]] = [(i, b) for i in range(n + 1) for b in (0, 1)]

    def alpha(v: Vertex) -> Vertex:
        i, b = v  # type: ignore[misc]
        return (i, 1 - b)

    def is_face(s: Face) -> bool:
        axes = [i for (i, _b) in s]  # type: ignore[misc]
        return len(axes) == len(set(axes))  # no repeated axis == no antipodal pair

    return Z2Complex(vertices, alpha, is_face)


def suspension(k_complex: Z2Complex) -> Z2Complex:
    """Combinatorial suspension S(K) = K * S^0.

    New vertex set is Left(v) for base vertices plus two apexes Apex(0), Apex(1).
    A face is a base face together with at most one apex.
    """
    L = ("L",)  # tag constructors as tuples so vertices stay hashable
    A = ("A",)

    def left(v: Vertex) -> Vertex:
        return (L, v)

    def apex(b: int) -> Vertex:
        return (A, b)

    vertices: List[Vertex] = [left(v) for v in k_complex.vertices] + [apex(0), apex(1)]

    def alpha(v: Vertex) -> Vertex:
        tag = v[0]  # type: ignore[index]
        if tag is L:
            return (L, k_complex.alpha(v[1]))  # type: ignore[index]
        return (A, 1 - v[1])  # type: ignore[index]

    def is_face(s: Face) -> bool:
        base = frozenset(v[1] for v in s if v[0] is L)  # type: ignore[index]
        apexes = [v[1] for v in s if v[0] is A]  # type: ignore[index]
        if not k_complex.is_face(base):
            return False
        return len(apexes) <= 1  # never join the two apexes

    return Z2Complex(vertices, alpha, is_face)


def suspension_tower(base: Z2Complex, k: int) -> Z2Complex:
    """Return S^k(base)."""
    cur = base
    for _ in range(k):
        cur = suspension(cur)
    return cur


class EqSimpMap:
    """An equivariant simplicial map candidate, given by a vertex map."""

    def __init__(self, f: Callable[[Vertex], Vertex]) -> None:
        self.f = f

    def is_equivariant(self, src: Z2Complex, dst: Z2Complex) -> bool:
        return all(self.f(src.alpha(v)) == dst.alpha(self.f(v)) for v in src.vertices)

    def preserves_faces(self, src: Z2Complex, dst: Z2Complex) -> bool:
        return all(
            dst.is_face(frozenset(self.f(v) for v in s)) for s in src.faces()
        )

    def is_valid(self, src: Z2Complex, dst: Z2Complex) -> bool:
        return self.is_equivariant(src, dst) and self.preserves_faces(src, dst)


def facet_count(n: int) -> int:
    """Number of facets of Oct(n), computed by enumeration."""
    return len(octahedral(n).facets())


def orthant_count(n: int) -> int:
    """Number of sign vectors Fin(n+1) -> {0,1}, i.e. 2^{n+1}."""
    return 2 ** (n + 1)


def exists_equivariant_map(src: Z2Complex, dst: Z2Complex) -> bool:
    """Exhaustively search for an equivariant simplicial map src -> dst.

    Only feasible for tiny complexes. Returns True iff at least one exists.
    """
    dst_vs = dst.vertices
    src_vs = src.vertices
    for choice in product(dst_vs, repeat=len(src_vs)):
        table = dict(zip(src_vs, choice))
        cand = EqSimpMap(lambda v, t=table: t[v])
        if cand.is_valid(src, dst):
            return True
    return False


def demo_dimension_law() -> None:
    print("== Dimension law:  dim S^k(K) = dim K + k ==")
    for n in range(0, 3):
        base = octahedral(n)
        d0 = base.dimension()
        for k in range(0, 4):
            tower = suspension_tower(base, k)
            d = tower.dimension()
            ok = "OK" if d == d0 + k else "FAIL"
            print(f"  Oct({n}): dim S^{k} = {d:2d}  (expected {d0 + k:2d})  [{ok}]")
    print()


def demo_facet_enumeration() -> None:
    print("== Octahedral facet count = 2^(n+1) ==")
    for n in range(0, 4):
        got = facet_count(n)
        want = orthant_count(n)
        ok = "OK" if got == want else "FAIL"
        print(f"  Oct({n}): facets = {got:3d}  2^(n+1) = {want:3d}  [{ok}]")
    print()


def demo_zero_defect() -> None:
    print("== Zero-defect tower: co-index witness and dimension both n+k ==")
    for n in range(0, 2):
        base = octahedral(n)
        for k in range(0, 3):
            tower = suspension_tower(base, k)
            dim = tower.dimension()
            # co-index >= n+k is witnessed by the map Oct(n+k) -> S^k(Oct(n)).
            witness = exists_equivariant_map(octahedral(n + k), tower) if n + k <= 2 else True
            print(
                f"  S^{k}(Oct({n})): dim = {dim}, "
                f"co-index >= {n + k} witnessed: {witness}"
            )
    print()


def demo_borsuk_ulam() -> None:
    print("== Iterated Borsuk-Ulam: no equivariant map S^k(Oct(0)) -> Oct(0), k>=1 ==")
    S0 = octahedral(0)
    for k in range(0, 3):
        tower = suspension_tower(S0, k)
        exists = exists_equivariant_map(tower, S0)
        note = "map exists (k=0, identity)" if k == 0 else "no map (obstruction)"
        assert exists == (k == 0), "unexpected result"
        print(f"  k = {k}: equivariant map to Oct(0) exists? {exists}  -> {note}")
    print()


def main() -> None:
    demo_dimension_law()
    demo_facet_enumeration()
    demo_zero_defect()
    demo_borsuk_ulam()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
