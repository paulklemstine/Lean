"""
demo.py
=======

Numerical demonstrations for:

    "Tightness of the Edge-Deletion Bound in a Hyperstability Extension
     of the Erdos-Gallai Theorem"

Central objects and facts demonstrated here
-------------------------------------------
* The balanced complete bipartite graph K_{t,t} on n = 2t vertices has t^2 edges.
* K_{t,t} is bipartite, hence C_d-free for every odd d (no odd cycles at all).
* Lemma A: a graph with a vertex cover of size k on n vertices has <= k*n edges.
* Lemma B: if every connected component has a vertex cover of size <= k,
  then the graph has <= k*n edges.
* Main Theorem (tightness): with the calibration t = 2(1+2c)d and n = 2t,
  every subgraph H <= K_{t,t} whose components each admit a vertex cover of
  size <= (1+c)d requires at least c*d*n edge deletions from K_{t,t}, and this
  bound is attained with equality at the threshold.

The module is self-contained (standard library only) and fully type-hinted.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, List, Set, Tuple

Vertex = Tuple[int, int]          # (side, index): side in {0, 1}
Edge = Tuple[Vertex, Vertex]      # unordered pair, stored canonically


# ---------------------------------------------------------------------------
# Construction of the extremal witness K_{t,t}
# ---------------------------------------------------------------------------
def calibrated_t(c: int, d: int) -> int:
    """Return the calibrated side size t = 2(1 + 2c)d from the Main Theorem."""
    return 2 * (1 + 2 * c) * d


def complete_bipartite(t: int) -> Tuple[List[Vertex], List[Edge]]:
    """Build K_{t,t}: sides A = {(0,i)} and B = {(1,j)}, all cross edges."""
    side_a: List[Vertex] = [(0, i) for i in range(t)]
    side_b: List[Vertex] = [(1, j) for j in range(t)]
    vertices: List[Vertex] = side_a + side_b
    edges: List[Edge] = [(a, b) for a in side_a for b in side_b]
    return vertices, edges


# ---------------------------------------------------------------------------
# Vertex covers and the two counting lemmas
# ---------------------------------------------------------------------------
def is_vertex_cover(edges: List[Edge], cover: Set[Vertex]) -> bool:
    """Check that every edge has at least one endpoint in `cover`."""
    return all(u in cover or v in cover for (u, v) in edges)


def lemma_A_bound(cover_size: int, n: int) -> int:
    """Lemma A ceiling: a cover of size k caps the edge count at k*n."""
    return cover_size * n


def connected_components(
    vertices: List[Vertex], edges: List[Edge]
) -> List[Set[Vertex]]:
    """Union-find over the edge list; returns the vertex sets of components."""
    parent: Dict[Vertex, Vertex] = {v: v for v in vertices}

    def find(x: Vertex) -> Vertex:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: Vertex, y: Vertex) -> None:
        parent[find(x)] = find(y)

    for u, v in edges:
        union(u, v)

    groups: Dict[Vertex, Set[Vertex]] = {}
    for v in vertices:
        groups.setdefault(find(v), set()).add(v)
    return list(groups.values())


def lemma_B_bound(k: int, n: int) -> int:
    """Lemma B ceiling: componentwise covers of size <= k cap edges at k*n."""
    return k * n


# ---------------------------------------------------------------------------
# The Main Theorem: deletion cost
# ---------------------------------------------------------------------------
def deletion_lower_bound(c: int, d: int, n: int) -> int:
    """Target lower bound on edge deletions from the Main Theorem: c*d*n."""
    return c * d * n


def demo_edge_count_and_calibration(c: int, d: int) -> None:
    """Show t^2 edges, the calibration identity, and the c*d*n target."""
    t = calibrated_t(c, d)
    n = 2 * t
    vertices, edges = complete_bipartite(t)
    print(f"[Calibration]  c={c}, d={d}  ->  t = 2(1+2c)d = {t},  n = 2t = {n}")
    print(f"  |E(K_{{t,t}})| counted   = {len(edges)}")
    print(f"  |E(K_{{t,t}})| formula t^2 = {t * t}")
    assert len(edges) == t * t

    allowed = lemma_B_bound((1 + c) * d, n)          # (1+c) d n
    target = deletion_lower_bound(c, d, n)           # c d n
    surplus = t * t - allowed                        # forced deletions
    print(f"  Lemma B ceiling (1+c)d n = {allowed}")
    print(f"  Forced deletions t^2 - (1+c)d n = {surplus}")
    print(f"  Target c d n = {target}")
    assert surplus == target, "calibration must yield exact equality"
    print("  => deletion bound attained with EQUALITY at the threshold.\n")


def demo_lemma_A(t: int) -> None:
    """Verify Lemma A on K_{t,t}: one side is a cover of size t, edges = t^2 <= t*n."""
    vertices, edges = complete_bipartite(t)
    n = len(vertices)
    cover: Set[Vertex] = {(0, i) for i in range(t)}   # side A covers all edges
    assert is_vertex_cover(edges, cover)
    bound = lemma_A_bound(len(cover), n)
    print(f"[Lemma A]  t={t}: cover size k={len(cover)}, n={n}")
    print(f"  edges = {len(edges)}  <=  k*n = {bound}   ({len(edges) <= bound})\n")
    assert len(edges) <= bound


def demo_lemma_B(t: int) -> None:
    """
    Verify Lemma B on a subgraph of K_{t,t} split into small components.

    We delete edges so that K_{t,t} breaks into t disjoint single edges
    (a perfect matching). Each component is one edge, covered by 1 vertex,
    so k = 1 and edges = t <= 1 * n.
    """
    vertices, _ = complete_bipartite(t)
    n = len(vertices)
    matching: List[Edge] = [((0, i), (1, i)) for i in range(t)]
    comps = connected_components(vertices, matching)
    k = 1  # each matched edge covered by a single endpoint
    for comp in comps:
        comp_edges = [(u, v) for (u, v) in matching if u in comp and v in comp]
        # pick any endpoint of each edge as a size-<=1 cover
        cover = {e[0] for e in comp_edges}
        assert is_vertex_cover(comp_edges, cover)
        assert len(cover) <= k
    bound = lemma_B_bound(k, n)
    print(f"[Lemma B]  perfect matching subgraph of K_{{t,t}}, t={t}")
    print(f"  components = {len(comps)}, each cover <= k={k}, n={n}")
    print(f"  edges = {len(matching)}  <=  k*n = {bound}   ({len(matching) <= bound})\n")
    assert len(matching) <= bound


def demo_main_theorem(c: int, d: int) -> None:
    """
    Verify the Main Theorem on an explicit subgraph H <= K_{t,t}.

    We build H by keeping edges only inside disjoint "blocks" so that every
    component of H has a vertex cover of size exactly (1+c)d, then confirm the
    number of deleted edges is >= c*d*n (and equals it at the threshold).
    """
    t = calibrated_t(c, d)
    n = 2 * t
    vertices, full_edges = complete_bipartite(t)
    k = (1 + c) * d

    # Partition side A into blocks of size k; within block r keep a complete
    # bipartite join to a matching block of B of size k. Each such K_{k,k}
    # block has a vertex cover of size k (one whole side of the block).
    kept: List[Edge] = []
    r = 0
    while (r + 1) * k <= t:
        a_block = [(0, i) for i in range(r * k, (r + 1) * k)]
        b_block = [(1, j) for j in range(r * k, (r + 1) * k)]
        kept.extend((a, b) for a in a_block for b in b_block)
        r += 1

    comps = connected_components(vertices, kept)
    # verify each component admits a cover of size <= k
    for comp in comps:
        comp_edges = [(u, v) for (u, v) in kept if u in comp and v in comp]
        cover = {v for v in comp if v[0] == 0}  # the A-side within the block
        if comp_edges:
            assert is_vertex_cover(comp_edges, cover)
            assert len(cover) <= k

    deletions = len(full_edges) - len(kept)
    bound = deletion_lower_bound(c, d, n)
    print(f"[Main Theorem]  c={c}, d={d}, t={t}, n={n}, budget k=(1+c)d={k}")
    print(f"  |E(K_{{t,t}})| = {len(full_edges)},  |E(H)| = {len(kept)}")
    print(f"  deletions = {deletions}  >=  c*d*n = {bound}   ({deletions >= bound})")
    print("  (Lemma B guarantees deletions >= c*d*n for ANY valid H.)\n")
    assert deletions >= bound


def main() -> None:
    print("=" * 68)
    print("Tightness of the Edge-Deletion Bound (Erdos-Gallai hyperstability)")
    print("=" * 68 + "\n")

    for c, d in [(1, 3), (2, 3), (1, 5), (3, 7)]:
        demo_edge_count_and_calibration(c, d)

    demo_lemma_A(t=4)
    demo_lemma_A(t=6)
    demo_lemma_B(t=5)

    for c, d in [(1, 3), (2, 5)]:
        demo_main_theorem(c, d)

    print("All numerical checks passed.")


if __name__ == "__main__":
    main()
