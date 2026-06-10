"""
Tropical Persistence Barcode — Core Algorithms

This module implements the core algorithms for computing tropical persistence
barcodes of graph filtrations relative to a basepoint q.

The tropical kernel dimension δ(S) = β₁(G[S]) + κ_q(S) decomposes into
the cycle rank (first Betti number) of the induced subgraph and the count
of q-visible connected components.

Time complexity:
  - Single stage evaluation: O(|V| + |E|) using union-find
  - Full filtration barcode: O(m · (|V| + |E|)) for m stages

Space complexity: O(|V| + |E|)
"""

from typing import List, Tuple, Dict, Set, Optional, NamedTuple
from collections import defaultdict
import itertools


class UnionFind:
    """Disjoint-set / union-find data structure for connected component tracking."""

    def __init__(self, elements):
        self.parent = {x: x for x in elements}
        self.rank = {x: 0 for x in elements}

    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x, y):
        """Union two sets. Returns True if they were in different sets."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True

    def components(self):
        """Return dict mapping root -> set of elements."""
        comp = defaultdict(set)
        for x in self.parent:
            comp[self.find(x)].add(x)
        return dict(comp)


class Graph:
    """Simple undirected graph."""

    def __init__(self, vertices: set, edges: set):
        self.vertices = set(vertices)
        self.edges = set()
        self.adj = defaultdict(set)
        for u, v in edges:
            if u != v and u in vertices and v in vertices:
                edge = (min(u, v), max(u, v))
                self.edges.add(edge)
                self.adj[u].add(v)
                self.adj[v].add(u)

    def neighbors(self, v) -> set:
        return self.adj[v]

    def induced_subgraph(self, S: set) -> 'Graph':
        """Return the subgraph induced on vertex set S."""
        sub_edges = {(u, v) for u, v in self.edges if u in S and v in S}
        return Graph(S, sub_edges)


class TropicalFiltrationEvent(NamedTuple):
    """Event data for a single filtration step."""
    cycle_birth: int
    q_visible_birth: int
    invisible_merge_death: int

    @property
    def delta(self) -> int:
        return self.cycle_birth + self.q_visible_birth - self.invisible_merge_death


def induced_edge_count(G: Graph, S: set) -> int:
    """Number of edges in G[S]."""
    return sum(1 for u, v in G.edges if u in S and v in S)


def induced_component_count(G: Graph, S: set) -> int:
    """Number of connected components of G[S]."""
    if not S:
        return 0
    uf = UnionFind(S)
    for u, v in G.edges:
        if u in S and v in S:
            uf.union(u, v)
    return len(uf.components())


def induced_cycle_rank(G: Graph, S: set) -> int:
    """Cycle rank β₁(G[S]) = |E(G[S])| + c(G[S]) - |S|."""
    if not S:
        return 0
    e = induced_edge_count(G, S)
    c = induced_component_count(G, S)
    return e + c - len(S)


def q_visible_component_count(G: Graph, q, S: set) -> int:
    """Number of connected components of G[S] that have a vertex adjacent to q."""
    if not S:
        return 0
    uf = UnionFind(S)
    for u, v in G.edges:
        if u in S and v in S:
            uf.union(u, v)
    comps = uf.components()
    count = 0
    for root, members in comps.items():
        # Check if any member is adjacent to q in the ambient graph
        for v in members:
            if q in G.neighbors(v):
                count += 1
                break
    return count


def tropical_kernel_dim(G: Graph, q, S: set) -> int:
    """The tropical kernel dimension δ(S) = β₁(G[S]) + κ_q(S).

    This is the central invariant combining topological and visibility information.
    """
    return induced_cycle_rank(G, S) + q_visible_component_count(G, q, S)


def compute_step_event(G: Graph, q, S: set, v) -> TropicalFiltrationEvent:
    """Compute the filtration event when inserting vertex v into set S.

    Decomposes the change in tropical kernel dimension into:
    - cycle births: new independent cycles created
    - q-visible births: new q-visible components appearing
    - invisible merge deaths: q-invisible components destroyed by merging

    Time complexity: O(|V| + |E|) per call.
    """
    S_new = S | {v}
    cr_old = induced_cycle_rank(G, S)
    cr_new = induced_cycle_rank(G, S_new)
    qv_old = q_visible_component_count(G, q, S)
    qv_new = q_visible_component_count(G, q, S_new)

    cycle_birth = max(cr_new - cr_old, 0)
    q_visible_birth = max(qv_new - qv_old, 0)

    # Deaths = negative changes
    cycle_death = max(cr_old - cr_new, 0)
    vis_death = max(qv_old - qv_new, 0)
    invisible_merge_death = cycle_death + vis_death

    return TropicalFiltrationEvent(cycle_birth, q_visible_birth, invisible_merge_death)


def compute_tropical_barcode(
    G: Graph, q, filtration: List[set]
) -> List[TropicalFiltrationEvent]:
    """Compute the tropical persistence barcode for a graph filtration.

    Args:
        G: The ambient graph
        q: The basepoint vertex
        filtration: Increasing sequence of vertex sets [S_0, S_1, ..., S_m]

    Returns:
        List of TropicalFiltrationEvent, one per consecutive pair.

    Time complexity: O(m · (|V| + |E|)) where m = len(filtration) - 1.
    """
    events = []
    for k in range(len(filtration) - 1):
        S_k = filtration[k]
        S_k1 = filtration[k + 1]
        # Compute the event between S_k and S_{k+1}
        new_vertices = S_k1 - S_k
        # For single-vertex insertions, use the step event directly
        if len(new_vertices) == 1:
            v = next(iter(new_vertices))
            events.append(compute_step_event(G, q, S_k, v))
        else:
            # For multi-vertex steps, compute the total change
            cr_old = induced_cycle_rank(G, S_k)
            cr_new = induced_cycle_rank(G, S_k1)
            qv_old = q_visible_component_count(G, q, S_k)
            qv_new = q_visible_component_count(G, q, S_k1)
            events.append(TropicalFiltrationEvent(
                cycle_birth=max(cr_new - cr_old, 0),
                q_visible_birth=max(qv_new - qv_old, 0),
                invisible_merge_death=max(cr_old - cr_new, 0) + max(qv_old - qv_new, 0)
            ))
    return events


def compute_dims(G: Graph, q, filtration: List[set]) -> List[int]:
    """Compute the dimension sequence δ(S_k) for each filtration stage.

    Time complexity: O(m · (|V| + |E|)).
    """
    return [tropical_kernel_dim(G, q, S) for S in filtration]


def reconstruct_dims(init: int, events: List[TropicalFiltrationEvent]) -> List[int]:
    """Reconstruct the dimension sequence from initial value and event deltas.

    This implements the barcode reconstruction theorem:
    δ(S_k) = δ(S_0) + Σ_{i<k} Δ_i

    Time complexity: O(m).
    """
    dims = [init]
    current = init
    for e in events:
        current += e.delta
        dims.append(current)
    return dims


def verify_barcode_correctness(
    G: Graph, q, filtration: List[set]
) -> Tuple[bool, List[int], List[int]]:
    """Verify that the barcode reconstruction matches direct computation.

    Returns (is_correct, direct_dims, reconstructed_dims).
    """
    direct = compute_dims(G, q, filtration)
    events = compute_tropical_barcode(G, q, filtration)
    reconstructed = reconstruct_dims(direct[0] if direct else 0, events)
    return direct == reconstructed, direct, reconstructed


def graph_h1_rank_delta(G: Graph, filtration: List[set], k: int) -> int:
    """Change in cycle rank (H₁) between filtration stages k and k+1."""
    return induced_cycle_rank(G, filtration[k+1]) - induced_cycle_rank(G, filtration[k])


# --- Graph generators ---

def complete_graph(n: int) -> Graph:
    """K_n: the complete graph on n vertices."""
    V = set(range(n))
    E = {(i, j) for i in range(n) for j in range(i+1, n)}
    return Graph(V, E)


def cycle_graph(n: int) -> Graph:
    """C_n: the cycle graph on n vertices."""
    V = set(range(n))
    E = {(i, (i+1) % n) for i in range(n)}
    return Graph(V, E)


def path_graph(n: int) -> Graph:
    """P_n: the path graph on n vertices."""
    V = set(range(n))
    E = {(i, i+1) for i in range(n-1)}
    return Graph(V, E)


def star_graph(n: int) -> Graph:
    """S_n: star graph with center 0 and n-1 leaves."""
    V = set(range(n))
    E = {(0, i) for i in range(1, n)}
    return Graph(V, E)


def petersen_graph() -> Graph:
    """The Petersen graph on 10 vertices."""
    V = set(range(10))
    # Outer cycle
    outer = {(i, (i+1) % 5) for i in range(5)}
    # Inner pentagram
    inner = {(5 + i, 5 + (i+2) % 5) for i in range(5)}
    # Spokes
    spokes = {(i, i+5) for i in range(5)}
    return Graph(V, outer | inner | spokes)


if __name__ == "__main__":
    # Quick test
    G = cycle_graph(5)
    q = 0
    filt = [set(), {1}, {1, 2}, {1, 2, 3}, {1, 2, 3, 4}]

    print("Graph: C_5, basepoint q=0")
    print(f"Filtration: {filt}")
    dims = compute_dims(G, q, filt)
    events = compute_tropical_barcode(G, q, filt)
    recon = reconstruct_dims(dims[0], events)

    print(f"Direct dims:        {dims}")
    print(f"Events:             {[(e.cycle_birth, e.q_visible_birth, e.invisible_merge_death) for e in events]}")
    print(f"Reconstructed dims: {recon}")
    print(f"Match: {dims == recon}")
