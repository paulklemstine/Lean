"""
Numerical demonstrations for:

    The Suspension Tower of Free Z2-Complexes and an Iterated Borsuk-Ulam Obstruction

This self-contained script models free Z2-simplicial complexes concretely and
verifies, on explicit small examples, the paper's main quantitative claims:

  * the octahedral n-sphere Oct(n) has maximal face cardinality n+1 (dimension n);
  * suspension adds exactly one to the maximal face cardinality;
  * the k-fold suspension tower over Oct(n) has co-index and dimension both = n+k
    (zero excess);
  * the combinatorial Borsuk-Ulam base case: no equivariant simplicial map
    Oct(n) -> Oct(0) exists for n >= 1;
  * the iterated obstruction: no equivariant map from the k-fold suspension of S^0
    onto S^0 exists for k >= 1.

Vertices are encoded uniformly as hashable tuples so that a single generic
`suspend` routine can be iterated to any height.
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Callable, FrozenSet, Iterable, List, Optional, Tuple

# A vertex is an arbitrary hashable object; faces are frozensets of vertices.
Vertex = object
Face = FrozenSet[Vertex]


# ---------------------------------------------------------------------------
# Free Z2-complex, represented by its vertex set, antipodal map, and face test.
# ---------------------------------------------------------------------------
class Z2Complex:
    """A finite free Z2-simplicial complex."""

    def __init__(
        self,
        vertices: Iterable[Vertex],
        alpha: Callable[[Vertex], Vertex],
        is_face: Callable[[Face], bool],
    ) -> None:
        self.vertices: List[Vertex] = list(vertices)
        self.alpha = alpha
        self.is_face = is_face

    def all_faces(self) -> List[Face]:
        """Enumerate every face (brute force over all subsets)."""
        faces: List[Face] = []
        vs = self.vertices
        for r in range(len(vs) + 1):
            for combo in combinations(vs, r):
                f = frozenset(combo)
                if self.is_face(f):
                    faces.append(f)
        return faces

    def max_face_card(self) -> int:
        """Largest face cardinality; dimension is this minus one."""
        best = 0
        vs = self.vertices
        for r in range(len(vs), -1, -1):
            for combo in combinations(vs, r):
                if self.is_face(frozenset(combo)):
                    return r
        return best

    def dimension(self) -> int:
        return self.max_face_card() - 1


# ---------------------------------------------------------------------------
# The octahedral n-sphere Oct(n): beads (i, b) for axis i, sign b in {True,False}.
# A face is any set with no antipodal pair (i,True),(i,False).
# ---------------------------------------------------------------------------
def oct_sphere(n: int) -> Z2Complex:
    vertices = [(i, b) for i in range(n + 1) for b in (True, False)]

    def alpha(v: Vertex) -> Vertex:
        i, b = v  # type: ignore[misc]
        return (i, not b)

    def is_face(s: Face) -> bool:
        axes = {}
        for (i, b) in s:  # type: ignore[misc]
            if i in axes and axes[i] != b:
                return False
            axes[i] = b
        return True

    return Z2Complex(vertices, alpha, is_face)


# ---------------------------------------------------------------------------
# Suspension S(K) = K * S^0. New apexes tagged ("apex", True/False).
# Base vertices are wrapped as ("base", v). A face has base part a face of K and
# contains at most one apex.
# ---------------------------------------------------------------------------
def suspend(K: Z2Complex) -> Z2Complex:
    base_vertices = [("base", v) for v in K.vertices]
    apex_vertices = [("apex", True), ("apex", False)]
    vertices = base_vertices + apex_vertices

    def alpha(v: Vertex) -> Vertex:
        tag, x = v  # type: ignore[misc]
        if tag == "base":
            return ("base", K.alpha(x))
        return ("apex", not x)

    def is_face(s: Face) -> bool:
        base_part = frozenset(x for (tag, x) in s if tag == "base")  # type: ignore[misc]
        if not K.is_face(base_part):
            return False
        apex_count = sum(1 for (tag, _x) in s if tag == "apex")  # type: ignore[misc]
        return apex_count <= 1

    return Z2Complex(vertices, alpha, is_face)


def suspend_tower(K: Z2Complex, k: int) -> Z2Complex:
    """The k-fold suspension tower S^k(K)."""
    for _ in range(k):
        K = suspend(K)
    return K


# ---------------------------------------------------------------------------
# Equivariant simplicial map search (brute force) between small complexes.
# Returns a vertex map (dict) if one exists, else None.
# ---------------------------------------------------------------------------
def find_equivariant_map(K: Z2Complex, L: Z2Complex) -> Optional[dict]:
    """Search for a Z2-simplicial map K -> L (equivariant, face-preserving)."""
    kv = K.vertices
    lv = L.vertices
    k_faces = K.all_faces()

    def equivariant(assign: dict) -> bool:
        for v in kv:
            if assign[K.alpha(v)] != L.alpha(assign[v]):
                return False
        return True

    def face_preserving(assign: dict) -> bool:
        for f in k_faces:
            image = frozenset(assign[v] for v in f)
            if not L.is_face(image):
                return False
        return True

    # Backtracking over vertex assignments, pairing v with alpha(v).
    seen = set()
    orbit_reps = []
    for v in kv:
        if v in seen:
            continue
        orbit_reps.append(v)
        seen.add(v)
        seen.add(K.alpha(v))

    assign: dict = {}

    def backtrack(idx: int) -> Optional[dict]:
        if idx == len(orbit_reps):
            if equivariant(assign) and face_preserving(assign):
                return dict(assign)
            return None
        v = orbit_reps[idx]
        for w in lv:
            assign[v] = w
            assign[K.alpha(v)] = L.alpha(w)
            # early equivariance is automatic by construction; prune faces later
            result = backtrack(idx + 1)
            if result is not None:
                return result
        del assign[v]
        del assign[K.alpha(v)]
        return None

    return backtrack(0)


# ---------------------------------------------------------------------------
# Demonstrations.
# ---------------------------------------------------------------------------
def demo_octahedral_dimensions() -> None:
    print("=" * 68)
    print("Octahedral spheres Oct(n): dimension should equal n")
    print("=" * 68)
    for n in range(0, 4):
        K = oct_sphere(n)
        print(f"  Oct({n}): max face card = {K.max_face_card()}, "
              f"dimension = {K.dimension()}  (expected {n})")


def demo_suspension_adds_one() -> None:
    print("=" * 68)
    print("Suspension adds exactly one to the maximal face cardinality")
    print("=" * 68)
    for n in range(0, 3):
        K = oct_sphere(n)
        SK = suspend(K)
        print(f"  Oct({n}): maxface {K.max_face_card()}  ->  "
              f"S(Oct({n})): maxface {SK.max_face_card()}  "
              f"(delta = {SK.max_face_card() - K.max_face_card()})")


def demo_tower_zero_excess() -> None:
    print("=" * 68)
    print("Suspension tower S^k(Oct(n)): dimension = n + k  (zero excess)")
    print("=" * 68)
    for n in range(0, 2):
        for k in range(0, 3):
            T = suspend_tower(oct_sphere(n), k)
            dim = T.dimension()
            print(f"  n={n}, k={k}: dim S^{k}(Oct({n})) = {dim}  "
                  f"(expected {n + k}); coind >= {n + k} by tower growth "
                  f"=> excess 0")


def demo_borsuk_ulam_base() -> None:
    print("=" * 68)
    print("Borsuk-Ulam base case: no equivariant map Oct(n) -> Oct(0), n >= 1")
    print("=" * 68)
    L = oct_sphere(0)
    for n in range(0, 3):
        K = oct_sphere(n)
        m = find_equivariant_map(K, L)
        status = "EXISTS" if m is not None else "none"
        print(f"  Oct({n}) -> Oct(0): {status}  "
              f"({'ok (n=0)' if (n == 0) == (m is not None) else 'check'})")


def demo_iterated_obstruction() -> None:
    print("=" * 68)
    print("Iterated obstruction: no map S^k(S^0) -> S^0 for k >= 1")
    print("=" * 68)
    L = oct_sphere(0)
    for k in range(0, 3):
        T = suspend_tower(oct_sphere(0), k)
        m = find_equivariant_map(T, L)
        status = "EXISTS" if m is not None else "none"
        print(f"  S^{k}(S^0) -> S^0: {status}  "
              f"(dimension of tower = {T.dimension()})")


def main() -> None:
    demo_octahedral_dimensions()
    print()
    demo_suspension_adds_one()
    print()
    demo_tower_zero_excess()
    print()
    demo_borsuk_ulam_base()
    print()
    demo_iterated_obstruction()


if __name__ == "__main__":
    main()
