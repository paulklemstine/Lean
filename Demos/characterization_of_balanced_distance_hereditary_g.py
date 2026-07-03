"""
Numerical demonstrations for:

    Characterization of Balanced Distance-Hereditary Graphs
    by the Complement of 3-Matching (the octahedron 3K2-bar)

This self-contained script verifies, on explicit graphs, the structural facts
that make the octahedron  co(3K2) = complement of a perfect matching on six
vertices  the single forbidden induced subgraph separating balanced from
unbalanced distance-hereditary graphs:

  * exact adjacency of co(3K2): distinct vertices adjacent iff in different pairs
  * co(3K2) is isomorphic to the complete tripartite graph K_{2,2,2} (octahedron)
  * degrees: co(3K2) is 4-regular, 3K2 is 1-regular
  * unique-non-neighbor rigidity: every vertex misses exactly one other vertex
  * independence number of co(3K2) is 2
  * co(3K2) is P4-free (a cograph), hence distance-hereditary
  * P4-freeness is hereditary (passes to induced subgraphs)
  * co(3K2) is a proper cograph: it contains an induced 4-cycle
  * a metric distance-signature detector for the octahedron

No third-party libraries are required.
"""

from __future__ import annotations

from itertools import combinations, permutations
from typing import Dict, FrozenSet, Iterable, List, Sequence, Set, Tuple

Vertex = int
Edge = FrozenSet[Vertex]


# --------------------------------------------------------------------------- #
# A minimal simple-graph type                                                 #
# --------------------------------------------------------------------------- #
class Graph:
    """A finite simple graph given by a vertex list and an adjacency set."""

    def __init__(self, vertices: Iterable[Vertex], edges: Iterable[Tuple[Vertex, Vertex]]):
        self.vertices: List[Vertex] = list(vertices)
        self.adj: Set[Edge] = set()
        for u, v in edges:
            if u != v:
                self.adj.add(frozenset((u, v)))

    def is_adj(self, u: Vertex, v: Vertex) -> bool:
        return frozenset((u, v)) in self.adj

    def degree(self, v: Vertex) -> int:
        return sum(1 for u in self.vertices if u != v and self.is_adj(u, v))

    def neighbors(self, v: Vertex) -> Set[Vertex]:
        return {u for u in self.vertices if u != v and self.is_adj(u, v)}

    def non_neighbors(self, v: Vertex) -> Set[Vertex]:
        return {u for u in self.vertices if u != v and not self.is_adj(u, v)}

    def complement(self) -> "Graph":
        edges = [
            (u, v)
            for u, v in combinations(self.vertices, 2)
            if not self.is_adj(u, v)
        ]
        return Graph(self.vertices, edges)

    def induced(self, sub: Sequence[Vertex]) -> "Graph":
        s = set(sub)
        edges = [
            (u, v)
            for u, v in combinations(self.vertices, 2)
            if u in s and v in s and self.is_adj(u, v)
        ]
        return Graph(list(sub), edges)


# --------------------------------------------------------------------------- #
# The two central graphs                                                       #
# --------------------------------------------------------------------------- #
def matching3() -> Graph:
    """3K2: perfect matching on {0..5}, pairs {0,1},{2,3},{4,5}."""
    edges = [(i, j) for i, j in combinations(range(6), 2) if i // 2 == j // 2]
    return Graph(range(6), edges)


def co_matching3() -> Graph:
    """co(3K2): complement of 3K2 = octahedron = K_{2,2,2}."""
    return matching3().complement()


def complete_multipartite(part_sizes: Sequence[int]) -> Graph:
    """K_{n_1,...,n_k}: vertices grouped into parts, adjacent iff different parts."""
    labels: List[Tuple[int, int]] = []
    for p, size in enumerate(part_sizes):
        labels.extend((p, q) for q in range(size))
    index = {lab: i for i, lab in enumerate(labels)}
    edges = [
        (index[a], index[b])
        for a, b in combinations(labels, 2)
        if a[0] != b[0]
    ]
    return Graph(range(len(labels)), edges)


# --------------------------------------------------------------------------- #
# Structural checks                                                            #
# --------------------------------------------------------------------------- #
def adjacency_matches_pairs(g: Graph) -> bool:
    """co(3K2) adjacency: i~j iff i!=j and floor(i/2)!=floor(j/2)."""
    for i, j in combinations(g.vertices, 2):
        expected = (i // 2) != (j // 2)
        if g.is_adj(i, j) != expected:
            return False
    return True


def is_isomorphic(g: Graph, h: Graph) -> bool:
    """Brute-force isomorphism test (only for tiny graphs)."""
    if len(g.vertices) != len(h.vertices):
        return False
    hv = list(h.vertices)
    for perm in permutations(hv):
        mapping = dict(zip(g.vertices, perm))
        if all(
            g.is_adj(u, v) == h.is_adj(mapping[u], mapping[v])
            for u, v in combinations(g.vertices, 2)
        ):
            return True
    return False


def unique_non_neighbor(g: Graph) -> bool:
    """Every vertex has exactly one non-neighbor."""
    return all(len(g.non_neighbors(v)) == 1 for v in g.vertices)


def independence_number(g: Graph) -> int:
    best = 0
    n = len(g.vertices)
    for r in range(n, 0, -1):
        for combo in combinations(g.vertices, r):
            if all(not g.is_adj(u, v) for u, v in combinations(combo, 2)):
                return r
    return best


# --------------------------------------------------------------------------- #
# Induced-subgraph detection (P4 / C4 / octahedron)                           #
# --------------------------------------------------------------------------- #
def _induces(g: Graph, verts: Sequence[Vertex], pattern_adj) -> bool:
    """Check whether the ordered tuple `verts` induces the given pattern."""
    k = len(verts)
    return all(
        g.is_adj(verts[a], verts[b]) == pattern_adj(a, b)
        for a, b in combinations(range(k), 2)
    )


def _path_adj(a: int, b: int) -> bool:
    return abs(a - b) == 1


def _cycle_adj(n: int):
    def adj(a: int, b: int) -> bool:
        return abs(a - b) == 1 or abs(a - b) == n - 1
    return adj


def contains_induced_path(g: Graph, k: int) -> bool:
    """Does g contain an induced P_k?"""
    for combo in combinations(g.vertices, k):
        for perm in permutations(combo):
            if _induces(g, perm, _path_adj):
                return True
    return False


def contains_induced_cycle(g: Graph, k: int) -> bool:
    adj = _cycle_adj(k)
    for combo in combinations(g.vertices, k):
        for perm in permutations(combo):
            if _induces(g, perm, adj):
                return True
    return False


def is_cograph(g: Graph) -> bool:
    """A graph is a cograph iff it has no induced P4."""
    return not contains_induced_path(g, 4)


def contains_induced_octahedron(g: Graph) -> bool:
    """Search for six vertices inducing co(3K2) via the distance/adjacency pattern."""
    target = co_matching3()
    for combo in combinations(g.vertices, 6):
        if is_isomorphic(g.induced(combo), target):
            return True
    return False


# --------------------------------------------------------------------------- #
# Metric (distance-matrix) reformulation                                      #
# --------------------------------------------------------------------------- #
def all_pairs_distance(g: Graph) -> Dict[Tuple[Vertex, Vertex], int]:
    """BFS shortest-path distances; unreachable pairs get a large sentinel."""
    INF = 10 ** 9
    dist: Dict[Tuple[Vertex, Vertex], int] = {}
    for src in g.vertices:
        seen = {src: 0}
        frontier = [src]
        while frontier:
            nxt = []
            for u in frontier:
                for w in g.neighbors(u):
                    if w not in seen:
                        seen[w] = seen[u] + 1
                        nxt.append(w)
            frontier = nxt
        for v in g.vertices:
            dist[(src, v)] = seen.get(v, INF)
    return dist


def octahedron_distance_signature(g: Graph, six: Sequence[Vertex]) -> bool:
    """Prop 6.1: six vertices in three pairs with same-pair dist 2, diff-pair dist 1."""
    if len(six) != 6:
        return False
    dist = all_pairs_distance(g)
    pairs = [(six[0], six[1]), (six[2], six[3]), (six[4], six[5])]
    part = {}
    for k, (a, b) in enumerate(pairs):
        part[a] = k
        part[b] = k
    for x, y in combinations(six, 2):
        d = dist[(x, y)]
        if part[x] == part[y]:
            if d != 2:
                return False
        else:
            if d != 1:
                return False
    return True


# --------------------------------------------------------------------------- #
# Demonstration driver                                                         #
# --------------------------------------------------------------------------- #
def main() -> None:
    m3 = matching3()
    co = co_matching3()

    print("=" * 70)
    print("The octahedron  co(3K2) = complement of a perfect matching on 6 vertices")
    print("=" * 70)

    print("\n[1] Adjacency of co(3K2): i~j iff distinct and in different pairs")
    print("    holds:", adjacency_matches_pairs(co))

    print("\n[2] co(3K2) is isomorphic to the complete tripartite graph K_{2,2,2}")
    k222 = complete_multipartite([2, 2, 2])
    print("    isomorphic:", is_isomorphic(co, k222))

    print("\n[3] Degrees")
    print("    co(3K2) degrees:", [co.degree(v) for v in co.vertices],
          "-> 4-regular:", all(co.degree(v) == 4 for v in co.vertices))
    print("    3K2   degrees:", [m3.degree(v) for v in m3.vertices],
          "-> 1-regular:", all(m3.degree(v) == 1 for v in m3.vertices))

    print("\n[4] Unique non-neighbor rigidity in co(3K2)")
    for v in co.vertices:
        print(f"    vertex {v}: non-neighbor(s) = {sorted(co.non_neighbors(v))}")
    print("    unique for every vertex:", unique_non_neighbor(co))

    print("\n[5] Independence number of co(3K2)")
    print("    alpha(co(3K2)) =", independence_number(co), "(expected 2)")

    print("\n[6] co(3K2) is a cograph (no induced P4)")
    print("    is_cograph:", is_cograph(co))

    print("\n[7] P4-freeness is hereditary (every induced subgraph is also a cograph)")
    all_hered = True
    for r in range(1, 7):
        for combo in combinations(co.vertices, r):
            if not is_cograph(co.induced(combo)):
                all_hered = False
    print("    all induced subgraphs are cographs:", all_hered)

    print("\n[8] co(3K2) is a PROPER cograph: it contains an induced C4")
    print("    contains induced C4:", contains_induced_cycle(co, 4))
    print("    explicit induced C4 on order (0,2,1,3):",
          _induces(co, (0, 2, 1, 3), _cycle_adj(4)))

    print("\n[9] Metric distance signature of the octahedron")
    print("    six=(0,1,2,3,4,5) with pairs {0,1},{2,3},{4,5}:",
          octahedron_distance_signature(co, [0, 1, 2, 3, 4, 5]))

    print("\n[10] Detecting the obstruction inside larger graphs")
    # A graph containing an induced octahedron: co(3K2) plus an isolated vertex.
    big = Graph(list(range(7)), [(u, v) for u, v in co.adj_pairs()])
    print("    co(3K2) + isolated vertex contains induced octahedron:",
          contains_induced_octahedron(big))
    # A cograph with NO octahedron: a path-free complete graph K5 (balanced witness).
    k5 = complete_multipartite([1, 1, 1, 1, 1])
    print("    K5 contains induced octahedron:",
          contains_induced_octahedron(k5),
          "(none: K5 has no two non-adjacent vertices)")

    print("\nAll structural facts verified on explicit graphs.")


# Convenience method used above; attached here to keep Graph minimal.
def _adj_pairs(self: Graph) -> List[Tuple[Vertex, Vertex]]:
    return [tuple(sorted(e)) for e in self.adj]


Graph.adj_pairs = _adj_pairs  # type: ignore[attr-defined]


if __name__ == "__main__":
    main()
