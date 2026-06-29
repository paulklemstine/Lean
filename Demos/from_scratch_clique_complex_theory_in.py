"""
demo.py — Numerical demonstrations of the clique-complex theory.

This self-contained script illustrates the main results of the package:

  * the clique complex  Delta(G)  of a simple graph,
  * the one-skeleton  sk(K)  of a complex, and the reconstruction sk(Delta(G)) = G,
  * the flag property and the flag reconstruction K = Delta(sk(K)),
  * monotonicity of Delta and sk,
  * the Galois adjunction  Delta(G) subset K  <=>  G <= sk(K),
  * the unit  K subset Delta(sk(K)),
  * the closure law  Delta(sk(Delta(G))) = Delta(G),
  * the Vietoris-Rips filtration with its two extremes (full / discrete),
  * the complement duality  independenceComplex(G) = Delta(G^c),
  * the Turan-style f-vector bound  f_k(Delta(G)) <= C(n, k+1).

No third-party dependencies are required.
"""

from __future__ import annotations

from itertools import combinations, chain
from math import comb
from typing import FrozenSet, Iterable, Set, Tuple, Dict, List


# ---------------------------------------------------------------------------
# Basic combinatorial helpers
# ---------------------------------------------------------------------------

Vertex = int
Edge = FrozenSet[Vertex]
Face = FrozenSet[Vertex]
Graph = Tuple[FrozenSet[Vertex], Set[Edge]]            # (vertices, edge set)
Complex = Set[Face]                                     # set of faces (incl. empty)


def make_graph(vertices: Iterable[Vertex],
               edges: Iterable[Tuple[Vertex, Vertex]]) -> Graph:
    """Build a simple graph from a vertex list and an edge list."""
    V = frozenset(vertices)
    E: Set[Edge] = {frozenset((u, v)) for (u, v) in edges if u != v}
    return (V, E)


def adjacent(G: Graph, u: Vertex, v: Vertex) -> bool:
    """Adjacency test in a simple graph."""
    return u != v and frozenset((u, v)) in G[1]


def is_clique(G: Graph, s: Iterable[Vertex]) -> bool:
    """A set is a clique iff every distinct pair is an edge (Theorem 3.1 pivot)."""
    s = list(s)
    return all(adjacent(G, u, v) for u, v in combinations(s, 2))


def powerset(vertices: Iterable[Vertex]) -> Iterable[Face]:
    """All finite subsets of a finite vertex set, as frozensets."""
    vs = list(vertices)
    return (frozenset(c)
            for r in range(len(vs) + 1)
            for c in combinations(vs, r))


# ---------------------------------------------------------------------------
# The two functors:  Delta (clique complex)  and  sk (one-skeleton)
# ---------------------------------------------------------------------------

def clique_complex(G: Graph) -> Complex:
    """Delta(G): the set of all finite cliques of G (faces of the complex)."""
    V, _ = G
    return {s for s in powerset(V) if is_clique(G, s)}


def one_skeleton(V: FrozenSet[Vertex], K: Complex) -> Graph:
    """sk(K): vertices V, with u~v iff u != v and {u,v} is a face of K."""
    edges = {frozenset((u, v))
             for u, v in combinations(sorted(V), 2)
             if frozenset((u, v)) in K}
    return (V, edges)


def is_down_closed(K: Complex) -> bool:
    """Verify K is closed under taking subsets."""
    for f in K:
        for sub in powerset(f):
            if sub not in K:
                return False
    return True


def is_flag(V: FrozenSet[Vertex], K: Complex) -> bool:
    """
    Flag test: every finite set whose singletons and pairs are all faces is a face.
    """
    for s in powerset(V):
        s_list = list(s)
        singles_ok = all(frozenset((u,)) in K for u in s_list)
        pairs_ok = all(frozenset((u, v)) in K for u, v in combinations(s_list, 2))
        if singles_ok and pairs_ok and s not in K:
            return False
    return True


def complement(G: Graph) -> Graph:
    """Complement graph G^c: u~v iff u != v and u !~ v in G."""
    V, E = G
    all_pairs = {frozenset((u, v)) for u, v in combinations(sorted(V), 2)}
    return (V, all_pairs - E)


def independence_complex(G: Graph) -> Complex:
    """Independence complex: faces are independent sets = cliques of G^c."""
    return clique_complex(complement(G))


# ---------------------------------------------------------------------------
# Vietoris-Rips
# ---------------------------------------------------------------------------

def vietoris_rips_graph(V: FrozenSet[Vertex],
                        d: Dict[Tuple[Vertex, Vertex], float],
                        eps: float) -> Graph:
    """VR graph: u~v iff u != v and d(u,v) <= eps and d(v,u) <= eps."""
    edges = {frozenset((u, v))
             for u, v in combinations(sorted(V), 2)
             if d[(u, v)] <= eps and d[(v, u)] <= eps}
    return (V, edges)


def vietoris_rips(V: FrozenSet[Vertex],
                  d: Dict[Tuple[Vertex, Vertex], float],
                  eps: float) -> Complex:
    """VR(d, eps) = Delta(VRgraph(d, eps))."""
    return clique_complex(vietoris_rips_graph(V, d, eps))


def f_vector(V: FrozenSet[Vertex], K: Complex) -> List[int]:
    """f-vector: f[k] = number of faces of cardinality k+1."""
    n = len(V)
    counts = [0] * (n + 1)
    for f in K:
        if len(f) >= 1:
            counts[len(f) - 1] += 1
    # trim trailing zeros for tidy output
    while len(counts) > 1 and counts[-1] == 0:
        counts.pop()
    return counts


# ---------------------------------------------------------------------------
# Pretty-printing
# ---------------------------------------------------------------------------

def fmt(faces: Complex) -> str:
    def key(f: Face) -> Tuple[int, Tuple[int, ...]]:
        return (len(f), tuple(sorted(f)))
    return "{ " + ", ".join("{" + ",".join(map(str, sorted(f))) + "}" if f else "∅"
                            for f in sorted(faces, key=key)) + " }"


def banner(title: str) -> None:
    print("\n" + "=" * 72)
    print(title)
    print("=" * 72)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_reconstruction() -> None:
    banner("1. Reconstruction:  sk(Delta(G)) = G")
    # A triangle 0-1-2 plus a pendant edge 2-3.
    G = make_graph([0, 1, 2, 3], [(0, 1), (1, 2), (0, 2), (2, 3)])
    K = clique_complex(G)
    print("G edges        :", sorted(tuple(sorted(e)) for e in G[1]))
    print("Delta(G) faces :", fmt(K))
    G2 = one_skeleton(G[0], K)
    print("sk(Delta(G))   :", sorted(tuple(sorted(e)) for e in G2[1]))
    print("Recovered G?   :", G[1] == G2[1])
    print("Delta(G) flag? :", is_flag(G[0], K), "(every clique complex is flag)")


def demo_unit_and_closure() -> None:
    banner("2. Unit  K subset Delta(sk(K))  and closure  Delta(sk(Delta(G)))=Delta(G)")
    # A NON-flag complex: empty triangle (three edges, no 2-face).
    V = frozenset({0, 1, 2})
    K = set(powerset([])) | {frozenset((x,)) for x in V} | \
        {frozenset((0, 1)), frozenset((1, 2)), frozenset((0, 2))}
    K.add(frozenset())
    print("K (empty triangle), down-closed?", is_down_closed(K), " flag?", is_flag(V, K))
    skK = one_skeleton(V, K)
    DskK = clique_complex(skK)
    print("K subset Delta(sk(K))?          :", K.issubset(DskK), "(unit always holds)")
    print("Delta(sk(K)) fills the triangle :", frozenset((0, 1, 2)) in DskK)
    print("  -> K != Delta(sk(K)) because K is not flag:", K != DskK)
    # Closure idempotence on an image of Delta:
    G = make_graph([0, 1, 2], [(0, 1), (1, 2), (0, 2)])
    DG = clique_complex(G)
    closure = clique_complex(one_skeleton(G[0], DG))
    print("Delta(sk(Delta(G))) = Delta(G)? :", closure == DG)


def demo_galois() -> None:
    banner("3. Galois adjunction  Delta(G) subset K  <=>  G <= sk(K)")
    V = frozenset({0, 1, 2, 3})
    # K = clique complex of a 4-cycle 0-1-2-3-0 (a flag complex with all singletons).
    H = make_graph(V, [(0, 1), (1, 2), (2, 3), (3, 0)])
    K = clique_complex(H)
    skK = one_skeleton(V, K)
    print("K = Delta(4-cycle), flag & all singletons present.")
    test_graphs = {
        "single edge 0-1": make_graph(V, [(0, 1)]),
        "path 0-1-2": make_graph(V, [(0, 1), (1, 2)]),
        "diagonal 0-2 (not in sk K)": make_graph(V, [(0, 2)]),
    }
    for name, G in test_graphs.items():
        lhs = clique_complex(G).issubset(K)            # Delta(G) subset K
        rhs = G[1].issubset(skK[1])                    # G <= sk(K)
        print(f"  {name:28s}: Delta(G)⊆K={lhs!s:5}  G≤sk(K)={rhs!s:5}  agree={lhs==rhs}")


def demo_monotonicity() -> None:
    banner("4. Monotonicity of Delta and sk")
    V = frozenset({0, 1, 2})
    G = make_graph(V, [(0, 1)])
    H = make_graph(V, [(0, 1), (1, 2), (0, 2)])
    print("G <= H:", G[1].issubset(H[1]))
    print("Delta(G) subset Delta(H):",
          clique_complex(G).issubset(clique_complex(H)))


def demo_vietoris_rips() -> None:
    banner("5. Vietoris-Rips filtration: monotone, with full/discrete extremes")
    V = frozenset({0, 1, 2})
    # symmetric distances on a triangle with sides 1, 2, 3
    base = {(0, 1): 1.0, (0, 2): 2.0, (1, 2): 3.0}
    d: Dict[Tuple[int, int], float] = {}
    for (a, b), w in base.items():
        d[(a, b)] = w
        d[(b, a)] = w
    sep = min(d.values())      # minimum separation
    diam = max(d.values())     # diameter
    print(f"min separation = {sep}, diameter = {diam}")
    for eps in [0.5, 1.0, 1.5, 2.0, 3.0, 4.0]:
        K = vietoris_rips(V, d, eps)
        print(f"  eps={eps:>3}: faces = {fmt(K)}")
    print("Below sep (eps=0.5): discrete (only ∅ and singletons).")
    print("Above diam (eps=4.0): full simplex (all subsets are faces).")
    # monotonicity check
    chain_ok = vietoris_rips(V, d, 1.0).issubset(vietoris_rips(V, d, 2.0))
    print("Monotone (eps=1.0 ⊆ eps=2.0):", chain_ok)


def demo_complement_duality() -> None:
    banner("6. Complement duality:  independenceComplex(G) = Delta(G^c)")
    V = frozenset({0, 1, 2, 3})
    G = make_graph(V, [(0, 1), (1, 2), (2, 3), (3, 0)])  # 4-cycle
    IC = independence_complex(G)
    Dc = clique_complex(complement(G))
    print("independenceComplex(G):", fmt(IC))
    print("Delta(G^c)            :", fmt(Dc))
    print("Equal?                :", IC == Dc)
    print("Independence complex flag?:", is_flag(V, IC))


def demo_turan_bound() -> None:
    banner("7. Turan-style f-vector bound  f_k(Delta(G)) <= C(n, k+1)")
    V = frozenset(range(5))
    # complete graph K5 attains equality
    K5 = make_graph(V, list(combinations(range(5), 2)))
    fv = f_vector(V, clique_complex(K5))
    n = len(V)
    print("Complete graph K5:")
    for k, fk in enumerate(fv):
        print(f"  f_{k} = {fk:3d}   C(5,{k+1}) = {comb(n, k+1):3d}   equality: {fk == comb(n, k+1)}")
    # a sparse graph stays strictly below
    G = make_graph(V, [(0, 1), (1, 2), (2, 3)])
    fv2 = f_vector(V, clique_complex(G))
    print("Path on 0-1-2-3 (sparse):")
    for k, fk in enumerate(fv2):
        print(f"  f_{k} = {fk:3d}   C(5,{k+1}) = {comb(n, k+1):3d}   within bound: {fk <= comb(n, k+1)}")


def main() -> None:
    demo_reconstruction()
    demo_unit_and_closure()
    demo_galois()
    demo_monotonicity()
    demo_vietoris_rips()
    demo_complement_duality()
    demo_turan_bound()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
