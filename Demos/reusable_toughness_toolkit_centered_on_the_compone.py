"""
Numerical demonstrations for the component-count toughness toolkit.

This self-contained module illustrates, on concrete finite graphs, the four
central results:

  1. Component-count monotonicity: adding edges never increases the number of
     components left after deleting a vertex set.
  2. Toughness monotonicity: 1-toughness is preserved under adding edges
     (Chvatal's necessary condition for Hamiltonicity).
  3. The sharp bound comp(G, S) <= max(1, |S|) for 1-tough graphs, and its
     corollary that 1-tough graphs are 2-connected (no cut vertex).
  4. The complete-graph dichotomy: a complete graph excludes a pattern H as an
     induced subgraph exactly when H has a non-edge (equivalently, when H is not
     itself complete).

Graphs are represented as (vertex set, edge set) with undirected edges stored as
frozensets. Everything is implemented from scratch with type hints; no external
libraries are required.
"""

from __future__ import annotations

from itertools import combinations, permutations
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

Vertex = int
Edge = FrozenSet[Vertex]
Graph = Tuple[Set[Vertex], Set[Edge]]


# ---------------------------------------------------------------------------
# Core graph utilities
# ---------------------------------------------------------------------------

def make_graph(vertices: Iterable[Vertex], edges: Iterable[Tuple[Vertex, Vertex]]) -> Graph:
    """Build a simple graph from a vertex list and a list of unordered pairs."""
    V: Set[Vertex] = set(vertices)
    E: Set[Edge] = set()
    for a, b in edges:
        if a == b:
            raise ValueError("loops are not allowed in a simple graph")
        E.add(frozenset((a, b)))
    return (V, E)


def complete_graph(n: int) -> Graph:
    """The complete graph K_n on vertices 0..n-1."""
    V = set(range(n))
    E = {frozenset((a, b)) for a, b in combinations(range(n), 2)}
    return (V, E)


def path_graph(vertices: List[Vertex]) -> Graph:
    """A path through the given vertices in order."""
    V = set(vertices)
    E = {frozenset((vertices[i], vertices[i + 1])) for i in range(len(vertices) - 1)}
    return (V, E)


def is_adjacent(G: Graph, a: Vertex, b: Vertex) -> bool:
    return frozenset((a, b)) in G[1]


def induced_subgraph(G: Graph, keep: Set[Vertex]) -> Graph:
    """The subgraph induced on the vertex set `keep`."""
    V, E = G
    kept = V & keep
    kept_edges = {e for e in E if e <= kept}
    return (kept, kept_edges)


def connected_components(G: Graph) -> List[Set[Vertex]]:
    """Return the connected components of G as a list of vertex sets."""
    V, E = G
    adj: Dict[Vertex, Set[Vertex]] = {v: set() for v in V}
    for e in E:
        a, b = tuple(e)
        adj[a].add(b)
        adj[b].add(a)
    seen: Set[Vertex] = set()
    comps: List[Set[Vertex]] = []
    for start in V:
        if start in seen:
            continue
        stack = [start]
        comp: Set[Vertex] = set()
        while stack:
            u = stack.pop()
            if u in seen:
                continue
            seen.add(u)
            comp.add(u)
            stack.extend(adj[u] - seen)
        comps.append(comp)
    return comps


def num_comp(G: Graph, S: Set[Vertex]) -> int:
    """comp(G, S): number of components remaining after deleting the set S."""
    return len(connected_components(induced_subgraph(G, G[0] - S)))


def is_connected(G: Graph) -> bool:
    return num_comp(G, set()) <= 1 and len(G[0]) >= 1


# ---------------------------------------------------------------------------
# Toughness
# ---------------------------------------------------------------------------

def is_one_tough(G: Graph) -> bool:
    """Check 1-toughness directly from the definition (exponential; for demos)."""
    if not is_connected(G):
        return False
    V = list(G[0])
    for r in range(1, len(V) + 1):
        for S in combinations(V, r):
            Sset = set(S)
            c = num_comp(G, Sset)
            if c >= 2 and c > len(Sset):
                return False
    return True


def max_component_bound_holds(G: Graph) -> bool:
    """Verify comp(G, S) <= max(1, |S|) for every vertex set S."""
    V = list(G[0])
    for r in range(0, len(V) + 1):
        for S in combinations(V, r):
            if num_comp(G, set(S)) > max(1, len(S)):
                return False
    return True


def is_two_connected(G: Graph) -> bool:
    """True if |V| >= 2 and deleting any single vertex keeps the graph connected."""
    V = G[0]
    if len(V) < 2:
        return False
    return all(num_comp(G, {v}) <= 1 for v in V)


# ---------------------------------------------------------------------------
# Induced-subgraph containment (the forbidden-pattern dichotomy)
# ---------------------------------------------------------------------------

def has_non_edge(H: Graph) -> bool:
    """True if H has two distinct non-adjacent vertices."""
    return any(not is_adjacent(H, a, b) for a, b in combinations(H[0], 2))


def contains_induced(H: Graph, G: Graph) -> bool:
    """Brute-force test whether G contains H as an induced subgraph."""
    HV = list(H[0])
    GV = list(G[0])
    if len(HV) > len(GV):
        return False
    for image in permutations(GV, len(HV)):
        f = dict(zip(HV, image))
        ok = True
        for a, b in combinations(HV, 2):
            if is_adjacent(H, a, b) != is_adjacent(G, f[a], f[b]):
                ok = False
                break
        if ok:
            return True
    return False


def k1_union_p4() -> Graph:
    """K1 + P4: isolated vertex 0, path 1-2-3-4."""
    V = {0, 1, 2, 3, 4}
    E = {frozenset((1, 2)), frozenset((2, 3)), frozenset((3, 4))}
    return (V, E)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_component_monotonicity() -> None:
    print("=" * 68)
    print("1. Component-count monotonicity: adding edges never adds components")
    print("=" * 68)
    # G: a path 0-1-2-3 ; H: G plus the edge 0-3 (a 4-cycle).
    G = path_graph([0, 1, 2, 3])
    H = make_graph({0, 1, 2, 3}, [(0, 1), (1, 2), (2, 3), (0, 3)])
    for S in [set(), {1}, {1, 2}, {0, 2}]:
        cg, ch = num_comp(G, S), num_comp(H, S)
        print(f"  S={sorted(S)!s:12} comp(G,S)={cg}  comp(H,S)={ch}  "
              f"[H<=G? {ch <= cg}]")
    print()


def demo_toughness_monotonicity() -> None:
    print("=" * 68)
    print("2. Toughness monotonicity and Chvatal's condition")
    print("=" * 68)
    C5 = make_graph(set(range(5)),
                    [(i, (i + 1) % 5) for i in range(5)])  # 5-cycle (Hamiltonian)
    print(f"  5-cycle C5 is 1-tough? {is_one_tough(C5)}")
    # Add a chord: still 1-tough, as the theorem predicts.
    H = make_graph(set(range(5)),
                   [(i, (i + 1) % 5) for i in range(5)] + [(0, 2)])
    print(f"  C5 + chord(0,2) is 1-tough? {is_one_tough(H)}  "
          f"(guaranteed by monotonicity)")
    print(f"  K5 (contains C5) is 1-tough? {is_one_tough(complete_graph(5))}")
    print()


def demo_two_connectivity() -> None:
    print("=" * 68)
    print("3. Sharp bound comp(G,S)<=max(1,|S|)  =>  1-tough graphs are 2-connected")
    print("=" * 68)
    for name, G in [("K4", complete_graph(4)),
                    ("C5", make_graph(set(range(5)),
                                      [(i, (i + 1) % 5) for i in range(5)]))]:
        tough = is_one_tough(G)
        bound = max_component_bound_holds(G)
        twoc = is_two_connected(G)
        print(f"  {name}: 1-tough={tough}  bound holds={bound}  2-connected={twoc}")
    # A graph with a cut vertex cannot be 1-tough:
    bowtie = make_graph({0, 1, 2, 3, 4},
                        [(0, 1), (1, 2), (2, 0), (2, 3), (3, 4), (4, 2)])
    print(f"  Bow-tie (cut vertex 2): 1-tough={is_one_tough(bowtie)}  "
          f"comp(G,{{2}})={num_comp(bowtie, {2})}")
    print()


def demo_complete_dichotomy() -> None:
    print("=" * 68)
    print("4. Complete-graph dichotomy: forbids exactly the patterns with a non-edge")
    print("=" * 68)
    K5 = complete_graph(5)
    patterns = {
        "K3 (complete)": complete_graph(3),
        "P3 (has non-edge)": path_graph([0, 1, 2]),
        "K1+P4 (has non-edge)": k1_union_p4(),
        "K5 (complete)": complete_graph(5),
    }
    for name, H in patterns.items():
        ne = has_non_edge(H)
        contained = contains_induced(H, K5)
        # Theorem: contained  <=>  not ne (i.e. H complete), given |H| <= |K5|.
        print(f"  H={name:22} non-edge={ne!s:5}  K5 contains H (induced)={contained!s:5}"
              f"  [dichotomy ok? {contained == (not ne)}]")
    print()


def main() -> None:
    demo_component_monotonicity()
    demo_toughness_monotonicity()
    demo_two_connectivity()
    demo_complete_dichotomy()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
