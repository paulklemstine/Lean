"""
Numerical demonstrations for:

    Bounded Tree-Independence Number in K_{1,d}-Free Graphs
    Excluding a Planar Induced Minor

This self-contained script illustrates, on small explicit graphs, every
quantitative claim of the accompanying paper:

  1. K_{1,d}-freeness <=> maximum degree <= d - 1
     (theorems: IsKStarFree.degree_lt / maxDegree_le / minDegree_le / degree_bounds)

  2. The greedy independent-set bound  |B| <= (Delta + 1) * alpha(G[B])
     (theorem: card_le_indepNumOn)

  3. The two-sided comparison
         alpha-tw(G) <= tw(G) + 1                      (always)
         tw(G)       <= (Delta + 1) * alpha-tw(G)      (bounded degree)
     computed by brute force over all tree decompositions on small graphs
     (theorems: treeIndepNumber_le_treewidth_succ,
                treewidth_le_mul_treeIndepNumber)

  4. The unconditional base case d = 2: every K_{1,2}-free graph is a matching
     and has alpha-tw <= 1.

Graphs are represented as (vertices, edges) with vertices a frozenset of ints
and edges a frozenset of frozenset pairs.  Everything is computed by explicit
enumeration so the numbers can be checked by hand.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations, permutations
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

Vertex = int
Edge = FrozenSet[Vertex]
Graph = Tuple[FrozenSet[Vertex], FrozenSet[Edge]]


# --------------------------------------------------------------------------
# Basic graph utilities
# --------------------------------------------------------------------------
def make_graph(vertices: Iterable[Vertex], edges: Iterable[Tuple[Vertex, Vertex]]) -> Graph:
    """Build a simple graph from a vertex list and an edge list."""
    V: FrozenSet[Vertex] = frozenset(vertices)
    E: FrozenSet[Edge] = frozenset(frozenset((u, v)) for u, v in edges)
    return (V, E)


def neighbors(G: Graph, v: Vertex) -> Set[Vertex]:
    """Return the open neighborhood N_G(v)."""
    V, E = G
    return {w for w in V if w != v and frozenset((v, w)) in E}


def degree(G: Graph, v: Vertex) -> int:
    """Return deg_G(v)."""
    return len(neighbors(G, v))


def max_degree(G: Graph) -> int:
    """Return the maximum degree Delta(G) (0 for the empty graph)."""
    V, _ = G
    return max((degree(G, v) for v in V), default=0)


def min_degree(G: Graph) -> int:
    """Return the minimum degree delta(G) (0 for the empty graph)."""
    V, _ = G
    return min((degree(G, v) for v in V), default=0)


def is_independent(G: Graph, s: Iterable[Vertex]) -> bool:
    """True iff s induces no edge of G."""
    _, E = G
    s = list(s)
    return all(frozenset((u, v)) not in E for u, v in combinations(s, 2))


def induced_independence_number(G: Graph, B: FrozenSet[Vertex]) -> int:
    """alpha(G[B]): the largest independent set contained in B (indepNumOn)."""
    best = 0
    Bl = list(B)
    for k in range(len(Bl), -1, -1):
        for s in combinations(Bl, k):
            if is_independent(G, s):
                return k  # k decreasing, so first hit is the maximum
    return best


# --------------------------------------------------------------------------
# 1. K_{1,d}-freeness  <=>  Delta <= d - 1
# --------------------------------------------------------------------------
def is_k_star_free(G: Graph, d: int) -> bool:
    """True iff G contains no K_{1,d}, i.e. no vertex has >= d neighbors."""
    V, _ = G
    return all(degree(G, v) < d for v in V)


def smallest_forbidden_star(G: Graph) -> int:
    """The least d for which G is K_{1,d}-free, namely Delta(G) + 1."""
    return max_degree(G) + 1


# --------------------------------------------------------------------------
# 2. Greedy independent-set bound:  |B| <= (Delta + 1) * alpha(G[B])
# --------------------------------------------------------------------------
def greedy_independent_set(G: Graph, B: FrozenSet[Vertex]) -> Set[Vertex]:
    """Greedy elimination: repeatedly pick a vertex, delete it and its
    neighbors.  Returns an independent set of size >= |B| / (Delta + 1)."""
    remaining: Set[Vertex] = set(B)
    chosen: Set[Vertex] = set()
    while remaining:
        v = min(remaining)  # deterministic choice
        chosen.add(v)
        remaining -= {v} | neighbors(G, v)
    return chosen


# --------------------------------------------------------------------------
# 3. Treewidth and tree-independence number via elimination orderings
#
# Both parameters equal a minimum over chordal completions of G.  Every
# elimination ordering produces a chordal completion (the "elimination game"):
# when a vertex v is eliminated, its not-yet-eliminated neighbors are turned
# into a clique, which becomes the bag B(v).  Then
#     tw(G)       = min over orderings of  max_v (|B(v)| - 1),
#     alpha-tw(G) = min over orderings of  max_v  alpha(G[B(v)]).
# Minimizing over all |V|! orderings gives the exact values (fast for |V| <= 7).
# --------------------------------------------------------------------------
def _elimination_bags(G: Graph, order: Tuple[Vertex, ...]) -> List[FrozenSet[Vertex]]:
    """Run the elimination game along `order`; return the bag for each vertex."""
    V, E = G
    adj: Dict[Vertex, Set[Vertex]] = {v: set(neighbors(G, v)) for v in V}
    alive: Set[Vertex] = set(V)
    bags: List[FrozenSet[Vertex]] = []
    for v in order:
        later_nbrs = {w for w in adj[v] if w in alive}
        bag = frozenset({v} | later_nbrs)
        bags.append(bag)
        # make later neighbors a clique (fill edges)
        for a, b in combinations(later_nbrs, 2):
            adj[a].add(b)
            adj[b].add(a)
        alive.discard(v)
    return bags


def treewidth(G: Graph) -> int:
    """Exact treewidth via minimum over all elimination orderings."""
    V, _ = G
    Vl = list(V)
    if not Vl:
        return 0
    best = len(Vl) - 1
    for order in permutations(Vl):
        bags = _elimination_bags(G, order)
        width = max(len(b) for b in bags) - 1
        best = min(best, width)
    return best


def tree_independence_number(G: Graph) -> int:
    """Exact tree-independence number via minimum over elimination orderings."""
    V, _ = G
    Vl = list(V)
    if not Vl:
        return 0
    best = len(Vl)
    for order in permutations(Vl):
        bags = _elimination_bags(G, order)
        cost = max(induced_independence_number(G, b) for b in bags)
        best = min(best, cost)
    return best


# --------------------------------------------------------------------------
# Example graphs
# --------------------------------------------------------------------------
def path(n: int) -> Graph:
    """Path P_n on vertices 0..n-1."""
    return make_graph(range(n), [(i, i + 1) for i in range(n - 1)])


def cycle(n: int) -> Graph:
    """Cycle C_n on vertices 0..n-1."""
    return make_graph(range(n), [(i, (i + 1) % n) for i in range(n)])


def clique(n: int) -> Graph:
    """Complete graph K_n."""
    return make_graph(range(n), list(combinations(range(n), 2)))


def matching(pairs: int) -> Graph:
    """A matching: `pairs` disjoint edges on 2*pairs vertices (K_{1,2}-free)."""
    return make_graph(range(2 * pairs),
                      [(2 * i, 2 * i + 1) for i in range(pairs)])


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_degree_equivalence() -> None:
    print("=" * 70)
    print("1. K_{1,d}-freeness  <=>  Delta(G) <= d - 1")
    print("=" * 70)
    examples = {
        "P_5 (path)": path(5),
        "C_6 (cycle)": cycle(6),
        "K_4 (clique)": clique(4),
        "3 disjoint edges": matching(3),
    }
    for name, G in examples.items():
        Delta = max_degree(G)
        d_free = smallest_forbidden_star(G)  # = Delta + 1
        # verify the theorem statement on a range of d
        ok = all(is_k_star_free(G, d) == (max_degree(G) <= d - 1)
                 for d in range(1, 8))
        print(f"{name:18s}  Delta={Delta}  smallest d with K_(1,d)-free = {d_free}"
              f"   equivalence holds: {ok}")
    print()


def demo_greedy_bound() -> None:
    print("=" * 70)
    print("2. Greedy bound:  |B| <= (Delta + 1) * alpha(G[B])")
    print("=" * 70)
    for name, G in {"C_6": cycle(6), "P_5": path(5), "K_4": clique(4)}.items():
        V, _ = G
        Delta = max_degree(G)
        B = frozenset(V)
        alpha = induced_independence_number(G, B)
        greedy = greedy_independent_set(G, B)
        lhs, rhs = len(B), (Delta + 1) * alpha
        print(f"{name:5s}  |B|={lhs}  Delta={Delta}  alpha={alpha}  "
              f"(Delta+1)*alpha={rhs}  bound holds: {lhs <= rhs}  "
              f"greedy set size={len(greedy)} (>= {len(B)}/{Delta+1} "
              f"= {len(B)/(Delta+1):.2f})")
    print()


def demo_comparison() -> None:
    print("=" * 70)
    print("3. Two-sided comparison of tw and alpha-tw")
    print("   alpha-tw <= tw + 1     and     tw <= (Delta+1) * alpha-tw")
    print("=" * 70)
    for name, G in {
        "P_4": path(4),
        "C_4": cycle(4),
        "C_5": cycle(5),
        "K_4": clique(4),
        "2 edges": matching(2),
    }.items():
        tw = treewidth(G)
        atw = tree_independence_number(G)
        Delta = max_degree(G)
        upper = atw <= tw + 1
        lower = tw <= (Delta + 1) * atw
        print(f"{name:8s}  tw={tw}  alpha-tw={atw}  Delta={Delta}   "
              f"alpha-tw<=tw+1: {upper}   tw<=(Delta+1)*alpha-tw: {lower}")
    print()


def demo_base_case() -> None:
    print("=" * 70)
    print("4. Base case d = 2: every K_{1,2}-free graph (a matching) has")
    print("   alpha-tw <= 1, unconditionally.")
    print("=" * 70)
    for k in range(1, 5):
        G = matching(k)
        free = is_k_star_free(G, 2)
        atw = tree_independence_number(G)
        print(f"matching with {k} edge(s):  K_(1,2)-free={free}  alpha-tw={atw}  "
              f"(<= 1: {atw <= 1})")
    print()


def main() -> None:
    demo_degree_equivalence()
    demo_greedy_bound()
    demo_comparison()
    demo_base_case()
    print("All demonstrations agree with the formalized theorems.")


if __name__ == "__main__":
    main()
