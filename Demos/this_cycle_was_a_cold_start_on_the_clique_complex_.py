"""
demo.py — Numerical demonstrations of the clique-complex / flag-complex theory.

This self-contained script illustrates, with concrete examples, the main results:

  * Pivot lemma        : a 2-element set is a clique iff its endpoints are adjacent.
  * One-skeleton       : skel(Delta(G)) == G  (clique complex is injective).
  * Flag characterization:
        - every clique complex is flag;
        - a flag complex containing all singletons equals Delta(skel(K));
        - the singleton hypothesis is necessary (Bool counterexample).
  * Vietoris-Rips      : monotonicity of the complex in the scale epsilon.
  * f-vector           : Turan-style bound  f_k <= C(n, k+1), tight for K_n.

Everything is pure Python (standard library only); run `python demo.py`.
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import Callable, Dict, FrozenSet, Hashable, List, Sequence, Set, Tuple

# A graph is a set of vertices together with a symmetric adjacency predicate.
Vertex = Hashable
Face = FrozenSet[Vertex]
Graph = Tuple[List[Vertex], Set[FrozenSet[Vertex]]]  # (vertices, edge set as 2-sets)


# --------------------------------------------------------------------------- #
# Core constructions                                                          #
# --------------------------------------------------------------------------- #
def make_graph(vertices: Sequence[Vertex],
               edges: Sequence[Tuple[Vertex, Vertex]]) -> Graph:
    """Build a simple graph from a vertex list and an edge list."""
    eset: Set[FrozenSet[Vertex]] = set()
    for u, v in edges:
        if u == v:
            raise ValueError("simple graphs have no loops")
        eset.add(frozenset((u, v)))
    return (list(vertices), eset)


def adjacent(g: Graph, u: Vertex, v: Vertex) -> bool:
    """True iff u and v are adjacent (distinct + edge present)."""
    return u != v and frozenset((u, v)) in g[1]


def is_clique(g: Graph, s: Sequence[Vertex]) -> bool:
    """True iff every pair of distinct elements of s is adjacent in g."""
    return all(adjacent(g, u, v) for u, v in combinations(set(s), 2))


def clique_complex(g: Graph) -> Set[Face]:
    """Delta(G): the set of all cliques (as frozensets), including the empty face."""
    verts = g[0]
    faces: Set[Face] = {frozenset()}
    for k in range(1, len(verts) + 1):
        for combo in combinations(verts, k):
            if is_clique(g, combo):
                faces.add(frozenset(combo))
    return faces


def one_skeleton(vertices: Sequence[Vertex], faces: Set[Face]) -> Graph:
    """skel(K): keep only vertices and the 2-element faces as edges."""
    edges = {f for f in faces if len(f) == 2}
    return (list(vertices), edges)


def is_flag(vertices: Sequence[Vertex], faces: Set[Face]) -> bool:
    """
    Test the flag property: every candidate set whose singletons and pairs are
    all faces must itself be a face. Equivalently, every clique of skel(K) whose
    singletons are all faces must be a face. We check all subsets directly.
    """
    fset = set(faces)
    for k in range(0, len(vertices) + 1):
        for combo in combinations(vertices, k):
            s = frozenset(combo)
            singles_ok = all(frozenset((v,)) in fset for v in s)
            pairs_ok = all(frozenset((u, v)) in fset
                           for u, v in combinations(s, 2))
            if singles_ok and pairs_ok and s not in fset:
                return False
    return True


def f_vector(vertices: Sequence[Vertex], faces: Set[Face]) -> List[int]:
    """f_k = number of faces of cardinality k+1, for k = 0 .. n-1."""
    n = len(vertices)
    fv = [0] * n
    for f in faces:
        if 1 <= len(f) <= n:
            fv[len(f) - 1] += 1
    return fv


def vietoris_rips_graph(vertices: Sequence[Vertex],
                        d: Callable[[Vertex, Vertex], float],
                        eps: float) -> Graph:
    """VRG(d, eps): join distinct u,v when d(u,v) <= eps and d(v,u) <= eps."""
    edges: Set[FrozenSet[Vertex]] = set()
    for u, v in combinations(vertices, 2):
        if d(u, v) <= eps and d(v, u) <= eps:
            edges.add(frozenset((u, v)))
    return (list(vertices), edges)


def vietoris_rips(vertices: Sequence[Vertex],
                  d: Callable[[Vertex, Vertex], float],
                  eps: float) -> Set[Face]:
    """VR(d, eps) = clique complex of the Vietoris-Rips graph at scale eps."""
    return clique_complex(vietoris_rips_graph(vertices, d, eps))


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_pivot_lemma() -> None:
    print("=" * 70)
    print("DEMO 1 — Pivot lemma: a 2-clique is exactly an edge")
    print("=" * 70)
    g = make_graph([0, 1, 2], [(0, 1), (1, 2)])
    for u, v in [(0, 1), (1, 2), (0, 2)]:
        print(f"  IsClique({{{u},{v}}}) = {is_clique(g, (u, v))!s:5}  "
              f"Adj({u},{v}) = {adjacent(g, u, v)}")
    print("  -> the two columns agree for every pair (Theorem 3.1).\n")


def demo_one_skeleton() -> None:
    print("=" * 70)
    print("DEMO 2 — skel(Delta(G)) == G  (one-skeleton recovers the graph)")
    print("=" * 70)
    g = make_graph([0, 1, 2, 3], [(0, 1), (1, 2), (2, 0), (2, 3)])
    delta = clique_complex(g)
    skel = one_skeleton(g[0], delta)
    print(f"  G edges        : {sorted(map(sorted, g[1]))}")
    print(f"  skel(Delta G)  : {sorted(map(sorted, skel[1]))}")
    print(f"  equal? {skel[1] == g[1]}   (Theorem 3.2 / Corollary 3.3)\n")


def demo_flag_characterization() -> None:
    print("=" * 70)
    print("DEMO 3 — Flag characterization (Theorems 4.1, 4.2)")
    print("=" * 70)
    g = make_graph([0, 1, 2, 3], [(0, 1), (1, 2), (2, 0), (2, 3)])
    delta = clique_complex(g)
    print(f"  Delta(G) is flag?  {is_flag(g[0], delta)}  (every clique complex is flag)")
    skel = one_skeleton(g[0], delta)
    rebuilt = clique_complex(skel)
    print(f"  Delta(skel(Delta G)) == Delta(G)?  {rebuilt == delta}")
    print("  (flag + all singletons => K = Delta(skel K))\n")


def demo_counterexample() -> None:
    print("=" * 70)
    print("DEMO 4 — Counterexample: singleton hypothesis is necessary (Thm 4.4)")
    print("=" * 70)
    verts = [False, True]                # Bool
    K = {frozenset()}                    # trivial complex {emptyset}
    print(f"  K.faces            : {[set(f) for f in K]}")
    print(f"  K is flag?         : {is_flag(verts, K)}  (vacuously)")
    skel = one_skeleton(verts, K)
    rebuilt = clique_complex(skel)
    print(f"  skel(K) edges      : {sorted(map(sorted, skel[1]))}  (empty graph)")
    print(f"  Delta(skel K).faces: {sorted([sorted(f) for f in rebuilt])}")
    print(f"  K == Delta(skel K)? {K == rebuilt}  -> FALSE: singletons reappear!\n")


def demo_vietoris_rips() -> None:
    print("=" * 70)
    print("DEMO 5 — Vietoris-Rips monotonicity (Theorem 5.1)")
    print("=" * 70)
    # Four points on a line at positions 0, 1, 2, 4.
    pos: Dict[int, float] = {0: 0.0, 1: 1.0, 2: 2.0, 3: 4.0}
    verts = list(pos)
    d = lambda u, v: abs(pos[u] - pos[v])
    prev: Set[Face] = set()
    for eps in [0.5, 1.0, 2.0, 4.0]:
        vr = vietoris_rips(verts, d, eps)
        nested = prev.issubset(vr)
        print(f"  eps={eps:<4}  #faces={len(vr):<3}  f-vector={f_vector(verts, vr)}  "
              f"prev subset? {nested if prev else 'n/a'}")
        prev = vr
    print("  -> face sets are nested as eps grows (a filtration).\n")


def demo_f_vector_bound() -> None:
    print("=" * 70)
    print("DEMO 6 — Turan-style f-vector bound  f_k <= C(n, k+1) (Theorem 6.1)")
    print("=" * 70)
    n = 5
    verts = list(range(n))
    complete = make_graph(verts, list(combinations(verts, 2)))
    delta_kn = clique_complex(complete)
    fv = f_vector(verts, delta_kn)
    print(f"  Complete graph K_{n}:")
    print(f"  {'k':>2} | {'f_k':>5} | {'C(n,k+1)':>9} | tight?")
    for k in range(n):
        print(f"  {k:>2} | {fv[k]:>5} | {comb(n, k + 1):>9} | {fv[k] == comb(n, k + 1)}")
    # A sparser graph stays strictly under the ceiling at higher dimensions.
    path = make_graph(verts, [(i, i + 1) for i in range(n - 1)])
    fv_path = f_vector(verts, clique_complex(path))
    print(f"\n  Path graph P_{n} f-vector: {fv_path}")
    print(f"  bounds C(n,k+1)         : {[comb(n, k + 1) for k in range(n)]}")
    print("  -> every entry respects the ceiling; equality only for K_n.\n")


def main() -> None:
    demo_pivot_lemma()
    demo_one_skeleton()
    demo_flag_characterization()
    demo_counterexample()
    demo_vietoris_rips()
    demo_f_vector_bound()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()


"""
viz_filtration.py — Visualize the Vietoris-Rips filtration on a 2D point cloud.

Generates a row of panels, one per scale epsilon, showing how edges and filled
triangles (2-faces) of the clique complex appear and accumulate as epsilon grows
(Theorem 5.1: the complexes are nested). Requires matplotlib + numpy.

Run:  python viz_filtration.py   ->  writes  vr_filtration.png
"""

from __future__ import annotations

from itertools import combinations
from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import Polygon


def vr_faces(points: np.ndarray, eps: float) -> Tuple[List[Tuple[int, int]],
                                                      List[Tuple[int, int, int]]]:
    """Return (edges, triangles) of the Vietoris-Rips complex at scale eps."""
    n = len(points)
    dist = np.linalg.norm(points[:, None, :] - points[None, :, :], axis=-1)
    edges = [(i, j) for i, j in combinations(range(n), 2) if dist[i, j] <= eps]
    eset = set(edges)
    triangles = [
        (i, j, k)
        for i, j, k in combinations(range(n), 3)
        if (i, j) in eset and (j, k) in eset and (i, k) in eset
    ]
    return edges, triangles


def main() -> None:
    rng = np.random.default_rng(7)
    # Points roughly on a circle (so a loop is born then filled in).
    theta = np.linspace(0, 2 * np.pi, 9, endpoint=False)
    pts = np.c_[np.cos(theta), np.sin(theta)] + 0.05 * rng.standard_normal((9, 2))

    scales = [0.5, 0.8, 1.2, 2.0]
    fig, axes = plt.subplots(1, len(scales), figsize=(4 * len(scales), 4))
    for ax, eps in zip(axes, scales):
        edges, tris = vr_faces(pts, eps)
        for (i, j, k) in tris:
            ax.add_patch(Polygon(pts[[i, j, k]], closed=True,
                                 facecolor="#4c72b0", alpha=0.25, edgecolor="none"))
        for (i, j) in edges:
            ax.plot(pts[[i, j], 0], pts[[i, j], 1], color="#dd8452", lw=1.3, zorder=2)
        ax.scatter(pts[:, 0], pts[:, 1], color="#2a2a2a", zorder=3, s=30)
        ax.set_title(f"eps = {eps}\n{len(edges)} edges, {len(tris)} triangles")
        ax.set_aspect("equal")
        ax.axis("off")
    fig.suptitle("Vietoris-Rips filtration: complexes grow monotonically with eps",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("vr_filtration.png", dpi=150)
    print("wrote vr_filtration.png")


if __name__ == "__main__":
    main()
