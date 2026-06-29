"""
demo.py — Numerical demonstrations of the integral chain complex of a clique complex.

This script mirrors the formal Lean development in
`Catalog/Shared/CliqueComplexChain.lean`. It implements, in plain Python:

  * the orientation sign        sgn(x, s) = (-1)^{# of y in s with y < x}      (Def 2.1)
  * the single-simplex boundary bdSingle(s) = sum_x sgn(x, s) * (s \\ {x})     (Def 2.2)
  * its linear extension        bd(chain)                                       (Def 2.3)
  * the clique complex of a graph and its faces                                 (Def 2.4)

and then *numerically verifies* the central theorems:

  * Theorem 3.1 / 3.2:  bd . bd = 0   (the chain-complex identity)
  * Lemma 4.3:          the sign-swap identity
  * Theorem 3.3:        faces are downward closed
  * Theorem 3.5:        the boundary of a clique-face is supported on clique-faces

Everything is self-contained: no third-party libraries are required.

A "face"/simplex is represented as a sorted tuple of comparable vertices.
A "chain" is represented as a dict { face : integer coefficient }, with zero
coefficients pruned (the analogue of a finitely supported function).
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Tuple, TypeVar

Vertex = TypeVar("Vertex")
Face = Tuple[Vertex, ...]          # always stored in increasing order
Chain = Dict[Face, int]            # face -> coefficient, zeros pruned


# --------------------------------------------------------------------------- #
# Core definitions (mirroring the Lean file)
# --------------------------------------------------------------------------- #

def make_face(vertices: Iterable[Vertex]) -> Face:
    """Canonical ordered representative of a finite vertex set."""
    return tuple(sorted(set(vertices)))


def sgn(x: Vertex, s: Face) -> int:
    """Orientation sign: (-1) ^ (number of elements of s strictly below x)."""
    rank = sum(1 for y in s if y < x)
    return (-1) ** rank


def erase(s: Face, x: Vertex) -> Face:
    """Remove vertex x from face s (the analogue of Finset.erase)."""
    return tuple(y for y in s if y != x)


def bd_single(s: Face) -> Chain:
    """Boundary of a single oriented simplex s = sum_{x in s} sgn(x,s) * (s \\ {x})."""
    chain: Chain = {}
    for x in s:
        face = erase(s, x)
        chain[face] = chain.get(face, 0) + sgn(x, s)
    return prune(chain)


def bd(chain: Chain) -> Chain:
    """Linear extension of bd_single to arbitrary chains."""
    out: Chain = {}
    for s, c in chain.items():
        for face, coeff in bd_single(s).items():
            out[face] = out.get(face, 0) + c * coeff
    return prune(out)


def prune(chain: Chain) -> Chain:
    """Drop zero coefficients (keep the support finite and canonical)."""
    return {f: c for f, c in chain.items() if c != 0}


# --------------------------------------------------------------------------- #
# Graphs and clique complexes
# --------------------------------------------------------------------------- #

class SimpleGraph:
    """A simple graph on a set of comparable vertices."""

    def __init__(self, vertices: Iterable[Vertex],
                 edges: Iterable[Tuple[Vertex, Vertex]]) -> None:
        self.vertices: List[Vertex] = sorted(set(vertices))
        self.adj: Dict[FrozenSet[Vertex], bool] = {}
        for (a, b) in edges:
            if a != b:
                self.adj[frozenset((a, b))] = True

    def adjacent(self, a: Vertex, b: Vertex) -> bool:
        return a != b and frozenset((a, b)) in self.adj

    def is_face(self, s: Iterable[Vertex]) -> bool:
        """IsFace G s  :  s is a clique of G (pairwise adjacent vertices)."""
        s = make_face(s)
        return all(self.adjacent(a, b) for a, b in combinations(s, 2))

    def cliques(self) -> List[Face]:
        """All faces of the clique complex Δ(G), including the empty face."""
        faces: List[Face] = [()]
        for k in range(1, len(self.vertices) + 1):
            for combo in combinations(self.vertices, k):
                if self.is_face(combo):
                    faces.append(combo)
        return faces

    def cliques_of_size(self, k: int) -> List[Face]:
        return [f for f in self.cliques() if len(f) == k]

    def euler_characteristic(self) -> int:
        """Reduced alternating clique count: sum_k (-1)^k |{(k+1)-cliques}|."""
        chi = 0
        max_dim = max((len(f) for f in self.cliques()), default=0)
        for dim in range(0, max_dim):           # dim = k, faces of size k+1
            chi += (-1) ** dim * len(self.cliques_of_size(dim + 1))
        return chi


# --------------------------------------------------------------------------- #
# Pretty printing
# --------------------------------------------------------------------------- #

def show_face(s: Face) -> str:
    return "{" + ",".join(str(v) for v in s) + "}"


def show_chain(chain: Chain) -> str:
    if not chain:
        return "0"
    parts = []
    for f in sorted(chain, key=lambda t: (len(t), t)):
        c = chain[f]
        sign = "+" if c > 0 else "-"
        mag = abs(c)
        coeff = "" if mag == 1 else str(mag)
        parts.append(f"{sign} {coeff}{show_face(f)}")
    return " ".join(parts).lstrip("+ ").strip()


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #

def demo_boundary_of_triangle() -> None:
    print("=" * 70)
    print("DEMO 1: Boundary of the triangle {1,2,3}")
    print("=" * 70)
    tri = make_face([1, 2, 3])
    b = bd_single(tri)
    print(f"  ∂{show_face(tri)} = {show_chain(b)}")
    print(f"  Expected:        {{2,3}} - {{1,3}} + {{1,2}}")
    bb = bd(b)
    print(f"  ∂∂{show_face(tri)} = {show_chain(bb)}   (must be 0)")
    assert bb == {}, "∂² should vanish!"
    print("  ✓ ∂² = 0 verified for the triangle\n")


def demo_boundary_of_tetrahedron() -> None:
    print("=" * 70)
    print("DEMO 2: Boundary of the tetrahedron {1,2,3,4}")
    print("=" * 70)
    tet = make_face([1, 2, 3, 4])
    b = bd_single(tet)
    print(f"  ∂{show_face(tet)} = {show_chain(b)}")
    bb = bd(b)
    print(f"  ∂∂{show_face(tet)} = {show_chain(bb)}   (must be 0)")
    assert bb == {}, "∂² should vanish!"
    print("  ✓ ∂² = 0 verified for the tetrahedron\n")


def demo_sgn_swap() -> None:
    print("=" * 70)
    print("DEMO 3: The sign-swap identity (Lemma 4.3)")
    print("  sgn(x,s)·sgn(y, s\\{x}) = - sgn(y,s)·sgn(x, s\\{y})")
    print("=" * 70)
    s = make_face([1, 2, 3, 4, 5])
    ok = True
    for x in s:
        for y in s:
            if x == y:
                continue
            lhs = sgn(x, s) * sgn(y, erase(s, x))
            rhs = -(sgn(y, s) * sgn(x, erase(s, y)))
            match = lhs == rhs
            ok = ok and match
            print(f"  x={x}, y={y}:  lhs={lhs:+d}  rhs={rhs:+d}  {'✓' if match else '✗'}")
    assert ok
    print("  ✓ sign-swap identity holds for all distinct pairs\n")


def demo_dd_zero_random() -> None:
    print("=" * 70)
    print("DEMO 4: ∂² = 0 over many random integer chains (Theorem 3.1)")
    print("=" * 70)
    import random
    random.seed(2024)
    universe = list(range(1, 7))
    all_faces: List[Face] = []
    for k in range(1, len(universe) + 1):
        all_faces.extend(make_face(c) for c in combinations(universe, k))
    trials = 500
    for _ in range(trials):
        chain: Chain = {}
        for f in random.sample(all_faces, k=random.randint(1, 8)):
            chain[f] = random.randint(-4, 4)
        chain = prune(chain)
        assert bd(bd(chain)) == {}, f"∂² failed on {chain}"
    print(f"  ✓ ∂² = 0 verified on {trials} random integer chains over 6 vertices\n")


def demo_clique_complex() -> None:
    print("=" * 70)
    print("DEMO 5: Clique complex of a graph + boundary preserves faces")
    print("=" * 70)
    # A graph: triangle {1,2,3} plus a pendant edge 3-4.
    G = SimpleGraph(
        vertices=[1, 2, 3, 4],
        edges=[(1, 2), (2, 3), (1, 3), (3, 4)],
    )
    faces = G.cliques()
    print("  Faces of Δ(G):")
    for f in sorted(faces, key=lambda t: (len(t), t)):
        print(f"    {show_face(f)}  (dim {len(f) - 1})")
    print(f"  Reduced Euler characteristic χ(Δ(G)) = {G.euler_characteristic()}")

    # Theorem 3.5: boundary of a clique-face is supported on clique-faces.
    print("\n  Checking boundary preserves faces (Theorem 3.5):")
    for f in faces:
        if len(f) >= 1:
            for sub in bd_single(f):
                assert G.is_face(sub), f"{show_face(sub)} not a face!"
            print(f"    ∂{show_face(f)} supported on faces ✓")

    # Theorem 3.3: downward closure.
    print("\n  Checking downward closure (Theorem 3.3):")
    big = make_face([1, 2, 3])
    assert G.is_face(big)
    for k in range(0, len(big) + 1):
        for sub in combinations(big, k):
            assert G.is_face(sub)
    print(f"    every subset of {show_face(big)} is a face ✓\n")


def demo_euler_characteristics() -> None:
    print("=" * 70)
    print("DEMO 6: Euler characteristics of some named graphs")
    print("=" * 70)

    # Complete graph K4 -> filled tetrahedron, contractible, χ_reduced should be 1.
    K4 = SimpleGraph([1, 2, 3, 4],
                     [(a, b) for a, b in combinations([1, 2, 3, 4], 2)])
    print(f"  K4 (filled tetrahedron):        χ = {K4.euler_characteristic()}")

    # 4-cycle (no chords): a hollow square = a circle. χ_reduced = 0.
    C4 = SimpleGraph([1, 2, 3, 4], [(1, 2), (2, 3), (3, 4), (1, 4)])
    print(f"  C4 (4-cycle, a circle):         χ = {C4.euler_characteristic()}")

    # Empty graph on 5 vertices: 5 disjoint points. χ_reduced = 5.
    E5 = SimpleGraph([1, 2, 3, 4, 5], [])
    print(f"  5 isolated vertices:            χ = {E5.euler_characteristic()}")

    # Two disjoint triangles. Each triangle filled solid (contractible);
    # two pieces -> χ_reduced = 2.
    T2 = SimpleGraph(
        [1, 2, 3, 4, 5, 6],
        [(1, 2), (2, 3), (1, 3), (4, 5), (5, 6), (4, 6)],
    )
    print(f"  two disjoint filled triangles:  χ = {T2.euler_characteristic()}")
    print()


def main() -> None:
    demo_boundary_of_triangle()
    demo_boundary_of_tetrahedron()
    demo_sgn_swap()
    demo_dd_zero_random()
    demo_clique_complex()
    demo_euler_characteristics()
    print("All demonstrations passed. ∂² = 0 holds in every test.")


if __name__ == "__main__":
    main()
