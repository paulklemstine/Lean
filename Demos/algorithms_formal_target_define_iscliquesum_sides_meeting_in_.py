"""Colour-Permutation Gluing of Proper Colourings Across a Clique Weld.

Given proper n-colourings of the two sides of a clique sum, produces a proper
n-colouring of the glued graph, witnessing chi(G) = max(chi_1, chi_2).

The construction: both colourings are injective on the weld K (its vertices are
pairwise adjacent on each side), so c2(v) -> c1(v) is a bijection between two
k-element subsets of the palette; extend it to a permutation sigma of all n
colours and recolour the right-hand side by sigma o c2.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Optional, Set, Tuple

Vertex = int
Colouring = Dict[Vertex, int]
AdjacencyMap = Dict[Vertex, Set[Vertex]]


def build_adjacency(vertices: Iterable[Vertex],
                    edges: Iterable[Tuple[Vertex, Vertex]]) -> AdjacencyMap:
    adj: AdjacencyMap = {v: set() for v in vertices}
    for a, b in edges:
        adj[a].add(b)
        adj[b].add(a)
    return adj


def is_proper(adj: AdjacencyMap, colouring: Colouring) -> bool:
    return all(colouring[a] != colouring[b] for a in adj for b in adj[a])


def greedy_colouring(adj: AdjacencyMap, order: Optional[List[Vertex]] = None) -> Colouring:
    """A proper colouring by greedy first-fit in the given order."""
    order = order if order is not None else sorted(adj, key=lambda v: -len(adj[v]))
    colouring: Colouring = {}
    for v in order:
        used = {colouring[u] for u in adj[v] if u in colouring}
        colour = 0
        while colour in used:
            colour += 1
        colouring[v] = colour
    return colouring


def extend_to_permutation(partial: Dict[int, int], n: int) -> List[int]:
    """Extend an injective partial map on {0..n-1} to a full permutation."""
    if len(set(partial.values())) != len(partial):
        raise ValueError("the partial map is not injective")
    sigma: List[Optional[int]] = [None] * n
    for source, target in partial.items():
        sigma[source] = target
    free_sources = [i for i in range(n) if sigma[i] is None]
    free_targets = [j for j in range(n) if j not in set(partial.values())]
    for source, target in zip(free_sources, free_targets):
        sigma[source] = target
    return [x for x in sigma if x is not None]


def glue_colourings(adj1: AdjacencyMap, side_s: Iterable[Vertex], c1: Colouring,
                    adj2: AdjacencyMap, side_t: Iterable[Vertex], c2: Colouring,
                    n_colours: int) -> Colouring:
    """Glue two proper n-colourings of the sides into one of the clique sum."""
    s, t = frozenset(side_s), frozenset(side_t)
    weld: FrozenSet[Vertex] = s & t

    if len({c1[v] for v in weld}) != len(weld):
        raise ValueError("left colouring is not injective on the weld: not a clique sum")
    if len({c2[v] for v in weld}) != len(weld):
        raise ValueError("right colouring is not injective on the weld: not a clique sum")
    if len(weld) > n_colours:
        raise ValueError("k <= n is violated: not a clique sum")

    partial = {c2[v]: c1[v] for v in weld}
    sigma = extend_to_permutation(partial, n_colours)
    glued: Colouring = {}
    for v in s:
        glued[v] = c1[v]
    for v in t:
        if v not in s:
            glued[v] = sigma[c2[v]]
    return glued


def weld_size_bound(adj: AdjacencyMap, weld: Iterable[Vertex], n_colours: int) -> bool:
    """The automatic inequality k <= n for a genuine clique sum."""
    weld_set = frozenset(weld)
    is_clique = all(b in adj[a] for a, b in combinations(sorted(weld_set), 2))
    return (not is_clique) or len(weld_set) <= n_colours


if __name__ == "__main__":
    # Two triangles glued along an edge: chi = 3 on each side and on the sum.
    a1 = build_adjacency([0, 1, 2], [(0, 1), (1, 2), (0, 2)])
    a2 = build_adjacency([0, 1, 3], [(0, 1), (1, 3), (0, 3)])
    c1 = greedy_colouring(a1)
    c2 = greedy_colouring(a2, order=[3, 1, 0])
    glued = glue_colourings(a1, [0, 1, 2], c1, a2, [0, 1, 3], c2, n_colours=3)
    union = build_adjacency([0, 1, 2, 3],
                            [(0, 1), (1, 2), (0, 2), (1, 3), (0, 3)])
    print("left  colouring:", c1)
    print("right colouring:", c2, "(disagrees with the left one on the weld)")
    print("glued colouring:", glued)
    print("proper on the clique sum:", is_proper(union, glued))


"""Trace-Decomposed Independence Number of a Clique Sum.

Computes alpha(G) for a clique sum G = G1 ∪ G2 along a weld clique K by solving
at most 2(k+1) constrained subproblems on the two sides, using

    alpha(G) = max over T ⊆ K with |T| <= 1 of (alpha_1(T) + alpha_2(T) - |T|).

Self-contained; no third-party dependencies.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Optional, Set, Tuple

Vertex = int
AdjacencyMap = Dict[Vertex, Set[Vertex]]


def build_adjacency(vertices: Iterable[Vertex],
                    edges: Iterable[Tuple[Vertex, Vertex]]) -> AdjacencyMap:
    """Adjacency map of a simple undirected graph."""
    adj: AdjacencyMap = {v: set() for v in vertices}
    for a, b in edges:
        if a == b:
            raise ValueError("simple graphs have no loops")
        adj[a].add(b)
        adj[b].add(a)
    return adj


def max_independent_set(adj: AdjacencyMap, ground: Iterable[Vertex]) -> int:
    """Independence number restricted to `ground`, by branch and bound.

    Branching rule: pick a vertex v of maximum degree inside the remaining
    ground set; either v is used (delete its closed neighbourhood) or it is not
    (delete v). Isolated vertices are taken greedily.
    """
    remaining: FrozenSet[Vertex] = frozenset(ground)

    def solve(rest: FrozenSet[Vertex]) -> int:
        if not rest:
            return 0
        degrees = {v: len(adj[v] & rest) for v in rest}
        isolated = [v for v, d in degrees.items() if d == 0]
        if isolated:
            return len(isolated) + solve(rest - frozenset(isolated))
        pivot = max(degrees, key=lambda v: degrees[v])
        take = 1 + solve(rest - {pivot} - adj[pivot])
        drop = solve(rest - {pivot})
        return max(take, drop)

    return solve(remaining)


def traced_independence_number(adj: AdjacencyMap, side: Iterable[Vertex],
                               weld: Iterable[Vertex],
                               trace: Iterable[Vertex]) -> Optional[int]:
    """alpha_i(T): largest independent A ⊆ side with A ∩ weld == T.

    Returns None when no such independent set exists (which happens only if T
    itself is not independent, impossible for |T| <= 1).
    """
    side_set, weld_set, trace_set = frozenset(side), frozenset(weld), frozenset(trace)
    if not trace_set <= weld_set & side_set:
        return None
    if len(trace_set) > 1:
        return None  # inadmissible: a clique meets an independent set at most once
    free = side_set - weld_set
    if trace_set:
        (v,) = tuple(trace_set)
        free = free - adj[v]
        return 1 + max_independent_set(adj, free)
    return max_independent_set(adj, free)


def admissible_traces(weld: Iterable[Vertex]) -> List[FrozenSet[Vertex]]:
    """The k+1 traces a witness can carry across the weld."""
    return [frozenset()] + [frozenset({v}) for v in sorted(weld)]


def clique_sum_independence_number(
    adj1: AdjacencyMap, side_s: Iterable[Vertex],
    adj2: AdjacencyMap, side_t: Iterable[Vertex],
) -> Tuple[int, Dict[Tuple[Vertex, ...], int]]:
    """alpha(G) for the clique sum, together with the per-trace values.

    Complexity: 2(k+1) independent-set computations on graphs no larger than the
    two sides; O(k * (T(n1) + T(n2))) where T is the cost of one side's oracle.
    """
    s, t = frozenset(side_s), frozenset(side_t)
    weld = s & t
    per_trace: Dict[Tuple[Vertex, ...], int] = {}
    best = 0
    for trace in admissible_traces(weld):
        a1 = traced_independence_number(adj1, s, weld, trace)
        a2 = traced_independence_number(adj2, t, weld, trace)
        if a1 is None or a2 is None:
            continue
        value = a1 + a2 - len(trace)
        per_trace[tuple(sorted(trace))] = value
        best = max(best, value)
    return best, per_trace


def verify_strong_clique_sum(adj1: AdjacencyMap, side_s: Iterable[Vertex],
                             adj2: AdjacencyMap, side_t: Iterable[Vertex]) -> bool:
    """Check that the weld is a clique on EACH side (the strong hypothesis)."""
    s, t = frozenset(side_s), frozenset(side_t)
    weld = s & t
    return all(b in adj1[a] and b in adj2[a] for a, b in combinations(sorted(weld), 2))


if __name__ == "__main__":
    # Witness A: the path 2 - 1 - 0 - 3 as a clique sum along K = {0,1}.
    a1 = build_adjacency([0, 1, 2], [(0, 1), (1, 2)])
    a2 = build_adjacency([0, 1, 3], [(0, 1), (0, 3)])
    assert verify_strong_clique_sum(a1, [0, 1, 2], a2, [0, 1, 3])
    alpha, table = clique_sum_independence_number(a1, [0, 1, 2], a2, [0, 1, 3])
    print("per-trace values:", table)
    print("alpha(G) =", alpha)
    print("alpha_1 + alpha_2 =", max_independent_set(a1, [0, 1, 2])
          + max_independent_set(a2, [0, 1, 3]))


"""Trace-State Dynamic Programming for Iterated Clique Sums Along a Tree.

A graph assembled from bags H_1, ..., H_m by clique sums along a tree, where the
separator between a bag and its parent is a clique K_e, has independence number
computable by a fold whose state is the trace a partial solution leaves on K_e:
either the empty set, or a single vertex of K_e. The table therefore has size
|K_e| + 1 rather than 2^|K_e|.

For a bag B with parent separator K, and children c_1..c_r with separators
K_1..K_r, the fold is

    table_B(T) = max over independent A ⊆ B with A ∩ K = T of
                 |A| + sum_i ( best_child_i(A ∩ K_i) - |A ∩ K_i| ),

    best_child_i(T') = table_{c_i}(T'),

and the answer is max over T of table_root(T), the root separator being empty.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Optional, Sequence, Set, Tuple

Vertex = int
Trace = FrozenSet[Vertex]
AdjacencyMap = Dict[Vertex, Set[Vertex]]


class Bag:
    """A node of the clique-sum tree: a vertex set with its own edges."""

    def __init__(self, vertices: Iterable[Vertex],
                 edges: Iterable[Tuple[Vertex, Vertex]],
                 children: Optional[Sequence["Bag"]] = None) -> None:
        self.vertices: FrozenSet[Vertex] = frozenset(vertices)
        self.edges: List[FrozenSet[Vertex]] = [frozenset(e) for e in edges]
        self.children: List[Bag] = list(children or [])

    def adjacency(self) -> AdjacencyMap:
        adj: AdjacencyMap = {v: set() for v in self.vertices}
        for e in self.edges:
            a, b = tuple(e)
            adj[a].add(b)
            adj[b].add(a)
        return adj

    def is_independent(self, subset: Iterable[Vertex]) -> bool:
        items = list(subset)
        edge_set = set(self.edges)
        return all(frozenset((a, b)) not in edge_set for a, b in combinations(items, 2))


def all_subsets(ground: Iterable[Vertex]) -> List[FrozenSet[Vertex]]:
    items = sorted(ground)
    out: List[FrozenSet[Vertex]] = []
    for mask in range(1 << len(items)):
        out.append(frozenset(items[i] for i in range(len(items)) if mask >> i & 1))
    return out


def admissible_traces(separator: Iterable[Vertex]) -> List[Trace]:
    return [frozenset()] + [frozenset({v}) for v in sorted(separator)]


def fold(bag: Bag, separator: Trace) -> Dict[Trace, int]:
    """Traced independence numbers of the subtree rooted at `bag`.

    `separator` is the clique shared with the parent (empty at the root).
    Returns a table T -> best size of an independent set of the subtree whose
    intersection with the separator is exactly T.
    """
    child_tables: List[Tuple[FrozenSet[Vertex], Dict[Trace, int]]] = []
    for child in bag.children:
        shared = bag.vertices & child.vertices
        child_tables.append((shared, fold(child, shared)))

    table: Dict[Trace, int] = {}
    for trace in admissible_traces(separator):
        best = None
        for subset in all_subsets(bag.vertices):
            if subset & frozenset(separator) != trace:
                continue
            if not bag.is_independent(subset):
                continue
            total = len(subset)
            feasible = True
            for shared, child_table in child_tables:
                local = subset & shared
                if len(local) > 1:
                    feasible = False  # a clique separator carries at most one vertex
                    break
                if local not in child_table:
                    feasible = False
                    break
                total += child_table[local] - len(local)
            if feasible and (best is None or total > best):
                best = total
        if best is not None:
            table[trace] = best
    return table


def independence_number_of_assembly(root: Bag) -> int:
    """alpha of the whole assembly: the fold at the root with an empty separator."""
    table = fold(root, frozenset())
    return max(table.values(), default=0)


if __name__ == "__main__":
    # A "path of triangles": three triangles glued in a chain along shared edges.
    #   bag0 = {0,1,2}, bag1 = {1,2,3} (shares the edge {1,2}),
    #   bag2 = {2,3,4} (shares the edge {2,3} with bag1)
    def triangle(a: Vertex, b: Vertex, c: Vertex,
                 children: Optional[Sequence[Bag]] = None) -> Bag:
        return Bag([a, b, c], [(a, b), (b, c), (a, c)], children)

    bag2 = triangle(2, 3, 4)
    bag1 = triangle(1, 2, 3, [bag2])
    bag0 = triangle(0, 1, 2, [bag1])
    print("alpha of the chain of three triangles =", independence_number_of_assembly(bag0))
    # The chain of triangles on {0..4} has independence number 2 ({0,3} or {0,4}).
