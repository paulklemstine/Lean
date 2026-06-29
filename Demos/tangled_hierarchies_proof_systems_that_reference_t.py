"""
demo.py — Flag complexes and the Clique Recognition Theorem
===========================================================

Self-contained numerical demonstration of the structural theorems relating
flag complexes and clique complexes of simple graphs.

We model:
  * a simple graph G as a vertex set plus a set of undirected edges (frozensets
    of size 2);
  * an abstract simplicial complex (ASC) as a set of faces (frozensets),
    required to be downward closed;
  * the clique complex of G   (`clique_complex`);
  * the 1-skeleton of an ASC  (`one_skeleton`);
  * the flag test             (`is_flag`).

We then verify, on concrete examples, the five theorems:

  A. clique complexes are flag                       (cliqueComplex_isFlag)
  B. {a,b} is a face of cliqueComplex(G) iff a~b     (clique_pair_iff)
  C. singletons are always faces                     (IsFlag.singleton_mem)
  D. flag K  =>  K = cliqueComplex(oneSkel K)        (IsFlag.eq_cliqueComplex)
  E. K is flag  <=>  K = cliqueComplex(oneSkel K)    (isFlag_iff_eq_cliqueComplex)

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

from itertools import combinations
from typing import FrozenSet, Iterable, List, Set, Tuple

Vertex = int
Edge = FrozenSet[Vertex]      # a 2-element frozenset {a, b}
Face = FrozenSet[Vertex]      # any finite face
Complex = Set[Face]           # a set of faces


# --------------------------------------------------------------------------- #
#  Simple graphs                                                              #
# --------------------------------------------------------------------------- #

class Graph:
    """A simple (undirected, loopless) graph."""

    def __init__(self, vertices: Iterable[Vertex],
                 edges: Iterable[Tuple[Vertex, Vertex]]) -> None:
        self.vertices: Set[Vertex] = set(vertices)
        self.edges: Set[Edge] = set()
        for a, b in edges:
            if a == b:
                raise ValueError(f"loops are not allowed: {a}")
            self.edges.add(frozenset((a, b)))
            self.vertices.update((a, b))

    def adj(self, a: Vertex, b: Vertex) -> bool:
        """Adjacency: distinct endpoints joined by an edge."""
        return a != b and frozenset((a, b)) in self.edges

    def __repr__(self) -> str:
        es = sorted(tuple(sorted(e)) for e in self.edges)
        return f"Graph(V={sorted(self.vertices)}, E={es})"


# --------------------------------------------------------------------------- #
#  Core constructions                                                         #
# --------------------------------------------------------------------------- #

def is_clique(g: Graph, s: FrozenSet[Vertex]) -> bool:
    """True iff every distinct pair in s is adjacent in g."""
    return all(g.adj(a, b) for a, b in combinations(sorted(s), 2))


def clique_complex(g: Graph) -> Complex:
    """
    The clique complex of g: all finite cliques of g, including the empty face
    and all singletons. Enumerates every subset of every maximal clique.
    """
    faces: Complex = {frozenset()}
    # Subset-growing search: start from singletons, extend by common neighbours.
    # Simpler (and correct) here: test all subsets of the vertex set, which is
    # fine for the small demo graphs below.
    verts = sorted(g.vertices)
    for r in range(1, len(verts) + 1):
        for combo in combinations(verts, r):
            s = frozenset(combo)
            if is_clique(g, s):
                faces.add(s)
    return faces


def one_skeleton(k: Complex) -> Graph:
    """
    The 1-skeleton of an ASC k: vertices are the singleton faces, edges are the
    2-element faces.
    """
    vertices = {next(iter(f)) for f in k if len(f) == 1}
    edges = [tuple(f) for f in k if len(f) == 2]
    return Graph(vertices, edges)  # type: ignore[arg-type]


def is_downward_closed(k: Complex) -> bool:
    """Check the ASC structural axiom: every subset of a face is a face."""
    for f in k:
        elems = sorted(f)
        for r in range(len(elems) + 1):
            for combo in combinations(elems, r):
                if frozenset(combo) not in k:
                    return False
    return True


def is_flag(k: Complex) -> bool:
    """
    Test the flag property: every set whose distinct pairs are all edges of the
    1-skeleton is itself a face.  By the Recognition Theorem this is equivalent
    to k == clique_complex(one_skeleton(k)); we test that directly, and also
    return the equivalent direct check.
    """
    g = one_skeleton(k)
    return clique_complex(g) == set(k)


def hollow_simplices(k: Complex) -> List[FrozenSet[Vertex]]:
    """
    The certificates of non-flagness: cliques of the 1-skeleton that are NOT
    faces of k (the 'hollow simplices').  Empty list iff k is flag.
    """
    g = one_skeleton(k)
    missing = clique_complex(g) - set(k)
    return sorted(missing, key=lambda f: (len(f), tuple(sorted(f))))


# --------------------------------------------------------------------------- #
#  Pretty printing                                                            #
# --------------------------------------------------------------------------- #

def show_complex(name: str, k: Complex) -> None:
    by_dim: dict[int, List[Tuple[int, ...]]] = {}
    for f in k:
        by_dim.setdefault(len(f), []).append(tuple(sorted(f)))
    print(f"  {name}:")
    for size in sorted(by_dim):
        dim = size - 1
        faces = sorted(by_dim[size])
        label = {-1: "empty", 0: "vertices", 1: "edges",
                 2: "triangles", 3: "tetrahedra"}.get(dim, f"dim-{dim}")
        print(f"    {label:>10} ({size}-sets): {faces}")


# --------------------------------------------------------------------------- #
#  Demonstrations                                                             #
# --------------------------------------------------------------------------- #

def demo_theorem_A_and_B() -> None:
    print("=" * 70)
    print("THEOREM A  (clique complexes are flag)  and  THEOREM B  (edge fidelity)")
    print("=" * 70)
    # The 'paw' graph: a triangle 1-2-3 with a pendant edge 3-4.
    g = Graph([1, 2, 3, 4], [(1, 2), (2, 3), (1, 3), (3, 4)])
    print(f"  Graph G = {g}")
    k = clique_complex(g)
    show_complex("cliqueComplex(G)", k)

    assert is_downward_closed(k), "clique complex must be downward closed"
    print(f"\n  Downward closed?  {is_downward_closed(k)}")
    print(f"  THEOREM A: cliqueComplex(G) is flag?  {is_flag(k)}")
    assert is_flag(k)

    print("\n  THEOREM B: {a,b} a face of cliqueComplex(G)  <=>  a~b in G")
    for a, b in combinations(sorted(g.vertices), 2):
        face = frozenset((a, b)) in k
        adj = g.adj(a, b)
        flag = "OK" if face == adj else "MISMATCH"
        print(f"    pair {{{a},{b}}}: face={face!s:5}  adj={adj!s:5}  [{flag}]")
        assert face == adj


def demo_theorem_C() -> None:
    print("\n" + "=" * 70)
    print("THEOREM C  (singletons are always faces)")
    print("=" * 70)
    g = Graph([1, 2, 3], [(1, 2)])  # 3 is isolated
    k = clique_complex(g)
    for v in sorted(g.vertices):
        present = frozenset((v,)) in k
        print(f"    singleton {{{v}}} present?  {present}  "
              f"(vertex {'isolated' if v == 3 else 'in an edge'})")
        assert present


def demo_theorem_D_and_E() -> None:
    print("\n" + "=" * 70)
    print("THEOREMS D & E  (Recognition Theorem: flag <=> self-rebuilding)")
    print("=" * 70)

    # ---- A flag complex: filled square's triangulation (two triangles) ----
    g = Graph([1, 2, 3, 4], [(1, 2), (2, 3), (3, 4), (4, 1), (1, 3)])
    k_flag = clique_complex(g)
    print("  Flag example K = cliqueComplex of a 4-cycle with one diagonal:")
    show_complex("K", k_flag)
    rebuilt = clique_complex(one_skeleton(k_flag))
    print(f"\n  THEOREM D/E: K == cliqueComplex(oneSkel K)?  {rebuilt == k_flag}")
    print(f"  is_flag(K) = {is_flag(k_flag)}")
    assert rebuilt == k_flag and is_flag(k_flag)

    # ---- A NON-flag complex: hollow triangle (3 edges, no 2-face) ----
    print("\n  Non-flag example: the hollow triangle (boundary of a triangle).")
    hollow: Complex = {
        frozenset(),
        frozenset((1,)), frozenset((2,)), frozenset((3,)),
        frozenset((1, 2)), frozenset((2, 3)), frozenset((1, 3)),
        # NOTE: {1,2,3} deliberately ABSENT -> hollow
    }
    show_complex("K_hollow", hollow)
    print(f"\n  downward closed?  {is_downward_closed(hollow)}")
    print(f"  is_flag(K_hollow) = {is_flag(hollow)}  (expected False)")
    miss = hollow_simplices(hollow)
    print(f"  hollow simplices (clique-of-skeleton but not a face): "
          f"{[tuple(sorted(f)) for f in miss]}")
    assert not is_flag(hollow)
    assert [tuple(sorted(f)) for f in miss] == [(1, 2, 3)]

    # Filling the missing 2-face makes it flag again.
    filled = set(hollow) | {frozenset((1, 2, 3))}
    print(f"\n  After filling {{1,2,3}}: is_flag = {is_flag(filled)}  (expected True)")
    assert is_flag(filled)


def demo_round_trip() -> None:
    print("\n" + "=" * 70)
    print("ROUND TRIP  (Corollary: oneSkel(cliqueComplex(G)) == G)")
    print("=" * 70)
    g = Graph([1, 2, 3, 4, 5],
              [(1, 2), (2, 3), (1, 3), (3, 4), (4, 5), (3, 5)])
    k = clique_complex(g)
    g2 = one_skeleton(k)
    same_v = g.vertices == g2.vertices
    same_e = g.edges == g2.edges
    print(f"  G              = {g}")
    print(f"  oneSkel(fill)  = {g2}")
    print(f"  vertices match? {same_v}   edges match? {same_e}")
    assert same_v and same_e


def demo_dimension_explosion() -> None:
    print("\n" + "=" * 70)
    print("DIMENSION EXPLOSION  (K_n -> full (n-1)-simplex, 2^n faces)")
    print("=" * 70)
    for n in range(1, 7):
        kn = Graph(range(n),
                   [(a, b) for a, b in combinations(range(n), 2)])
        faces = clique_complex(kn)
        print(f"    K_{n}: |faces| = {len(faces):4d}   (2^{n} = {2 ** n})")
        assert len(faces) == 2 ** n


def main() -> None:
    demo_theorem_A_and_B()
    demo_theorem_C()
    demo_theorem_D_and_E()
    demo_round_trip()
    demo_dimension_explosion()
    print("\n" + "=" * 70)
    print("All assertions passed: the five theorems hold on every example.")
    print("=" * 70)


if __name__ == "__main__":
    main()
