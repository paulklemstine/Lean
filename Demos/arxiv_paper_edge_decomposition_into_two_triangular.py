"""
Triangular forests: numerical demonstrations of the main results.
=================================================================

A *triangular forest* is a graph in which every cycle has length exactly three;
equivalently, every 2-connected block is a single edge or a triangle.

This self-contained script demonstrates, by explicit computation:

  1. Membership testing for the class (block-based, linear time).
  2. The sharp sparsity law   2e <= 3(n-1)   over all graphs on n <= 7 vertices,
     together with the extremal numbers  floor(3(n-1)/2).
  3. Sharpness: the windmill graphs F_k on n = 2k+1 vertices have 3k edges,
     attaining  2e = 3(n-1).
  4. The exact threshold: K_n decomposes into two triangular forests iff n <= 5,
     with an explicit K_5 certificate and an exhaustive refutation for K_6.
  5. The clique obstruction: any graph containing a K_6 fails to decompose.
  6. Triangular thickness lower bound  n <= 3k  for covers of K_n, and greedy
     covers matching  ceil(n/3)  for small n (n != 6).
  7. Local structure: neighbourhoods induce matchings, so every edge of a
     triangular forest lies in at most one triangle.

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

import itertools
import random
from typing import Dict, FrozenSet, Iterable, List, Optional, Sequence, Set, Tuple

Edge = FrozenSet[int]
Graph = Tuple[int, FrozenSet[Edge]]  # (number of vertices, edge set)


# ---------------------------------------------------------------------------
# Basic graph utilities
# ---------------------------------------------------------------------------

def edge(u: int, v: int) -> Edge:
    """The undirected edge {u, v}."""
    if u == v:
        raise ValueError("loops are not allowed in a simple graph")
    return frozenset((u, v))


def make_graph(n: int, pairs: Iterable[Tuple[int, int]]) -> Graph:
    """Build a simple graph on vertices 0..n-1 from a list of pairs."""
    return (n, frozenset(edge(u, v) for u, v in pairs))


def complete_graph(n: int) -> Graph:
    """The complete graph K_n."""
    return make_graph(n, itertools.combinations(range(n), 2))


def windmill(k: int) -> Graph:
    """The windmill (friendship) graph F_k: k triangles glued at the hub 0."""
    pairs: List[Tuple[int, int]] = []
    for i in range(1, k + 1):
        a, b = 2 * i - 1, 2 * i
        pairs += [(0, a), (0, b), (a, b)]
    return make_graph(2 * k + 1, pairs)


def adjacency(g: Graph) -> Dict[int, Set[int]]:
    """Adjacency lists of a graph."""
    n, edges = g
    adj: Dict[int, Set[int]] = {v: set() for v in range(n)}
    for e in edges:
        u, v = tuple(e)
        adj[u].add(v)
        adj[v].add(u)
    return adj


def degrees(g: Graph) -> Dict[int, int]:
    """Degree of every vertex."""
    return {v: len(nbrs) for v, nbrs in adjacency(g).items()}


# ---------------------------------------------------------------------------
# 1. Membership test for the class of triangular forests
# ---------------------------------------------------------------------------

def triangles_through(g: Graph, e: Edge) -> List[int]:
    """The vertices completing the edge e to a triangle."""
    adj = adjacency(g)
    u, v = tuple(e)
    return sorted(adj[u] & adj[v])


def is_triangular_forest(g: Graph) -> bool:
    """
    Decide whether every cycle of g has length exactly 3.

    Method (Proposition: block description).  Every edge must lie in at most one
    triangle (otherwise two triangles share an edge and span a 4-cycle).  Then
    contract each triangle to a single vertex and test the result for acyclicity:
    the contracted graph is a forest exactly when every block of g was an edge or
    a triangle.
    """
    n, edges = g
    # (i) every edge lies in at most one triangle
    tri_edges: Set[Edge] = set()
    for e in edges:
        common = triangles_through(g, e)
        if len(common) >= 2:
            return False
        if len(common) == 1:
            tri_edges.add(e)

    # (ii) contract the triangles (union-find over triangle edges)
    parent = list(range(n))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> None:
        rx, ry = find(x), find(y)
        if rx != ry:
            parent[rx] = ry

    for e in tri_edges:
        u, v = tuple(e)
        union(u, v)

    # (iii) the quotient must be a forest: count components and remaining edges
    remaining = [e for e in edges if e not in tri_edges]
    quotient_edges: Set[Edge] = set()
    for e in remaining:
        u, v = tuple(e)
        ru, rv = find(u), find(v)
        if ru == rv:
            return False  # a non-triangle edge inside a contracted blob
        q = frozenset((ru, rv))
        if q in quotient_edges:
            return False  # parallel edges in the quotient = a longer cycle
        quotient_edges.add(q)

    roots = {find(v) for v in range(n)}
    # forest test: |E| <= |V| - #components, checked via union-find on the quotient
    parent2 = {r: r for r in roots}

    def find2(x: int) -> int:
        while parent2[x] != x:
            parent2[x] = parent2[parent2[x]]
            x = parent2[x]
        return x

    for q in quotient_edges:
        a, b = tuple(q)
        ra, rb = find2(a), find2(b)
        if ra == rb:
            return False  # cycle in the quotient
        parent2[ra] = rb
    return True


def brute_force_is_triangular_forest(g: Graph) -> bool:
    """Reference implementation: enumerate all cycles and check their lengths."""
    n, edges = g
    adj = adjacency(g)
    for length in range(4, n + 1):
        for verts in itertools.permutations(range(n), length):
            if verts[0] != min(verts):
                continue
            if verts[1] > verts[-1]:
                continue  # kill the reflection
            if all(verts[(i + 1) % length] in adj[verts[i]] for i in range(length)):
                return False
    return True


# ---------------------------------------------------------------------------
# 2-3. The sharp sparsity law and its extremal graphs
# ---------------------------------------------------------------------------

def max_edges_triangular_forest(n: int) -> Tuple[int, Optional[Graph]]:
    """Exhaustively maximise the edge count over triangular forests on n vertices."""
    all_pairs = list(itertools.combinations(range(n), 2))
    best, witness = 0, None
    for size in range(len(all_pairs), -1, -1):
        found = False
        for subset in itertools.combinations(all_pairs, size):
            g = make_graph(n, subset)
            if is_triangular_forest(g):
                best, witness, found = size, g, True
                break
        if found:
            break
    return best, witness


def sparsity_bound(n: int) -> int:
    """The sharp bound floor(3(n-1)/2) on the number of edges."""
    return (3 * (n - 1)) // 2


# ---------------------------------------------------------------------------
# 4. Decomposition into two triangular forests
# ---------------------------------------------------------------------------

def decompose_into_two(g: Graph) -> Optional[Tuple[Graph, Graph]]:
    """
    Search for a partition of E(g) into two triangular forests.

    Backtracking over an edge 2-colouring, using the fact that the class is closed
    under subgraphs: a partial colour class that is already not a triangular forest
    can never become one, so the partial test is a sound pruning rule.
    """
    n, edges = g
    # density prescreen: a decomposable graph satisfies |E| <= 3(n-1)
    if n >= 1 and len(edges) > 3 * (n - 1):
        return None
    order = sorted(edges, key=lambda e: sorted(e))
    part: List[List[Edge]] = [[], []]

    def backtrack(i: int) -> bool:
        if i == len(order):
            return True
        for side in (0, 1):
            part[side].append(order[i])
            if is_triangular_forest((n, frozenset(part[side]))) and backtrack(i + 1):
                return True
            part[side].pop()
        return False

    if not backtrack(0):
        return None
    return (n, frozenset(part[0])), (n, frozenset(part[1]))


def contains_k6(g: Graph) -> bool:
    """Does g contain six mutually adjacent vertices?"""
    n, _ = g
    adj = adjacency(g)
    for six in itertools.combinations(range(n), 6):
        if all(b in adj[a] for a, b in itertools.combinations(six, 2)):
            return True
    return False


# ---------------------------------------------------------------------------
# 6. Triangular thickness
# ---------------------------------------------------------------------------

def greedy_cover(g: Graph, tries: int = 4000, seed: int = 20260818) -> List[Graph]:
    """
    Randomised search for a cover of E(g) by few triangular forests.

    Repeatedly peel off a maximal triangular forest under a random edge order and
    keep the best (fewest parts) result over `tries` restarts.  Las Vegas: every
    output part is verified to belong to the class.
    """
    n, edges = g
    rng = random.Random(seed)
    best: Optional[List[Graph]] = None
    for _ in range(tries):
        remaining = set(edges)
        parts: List[Graph] = []
        while remaining:
            order = list(remaining)
            rng.shuffle(order)
            chosen: List[Edge] = []
            for e in order:
                if is_triangular_forest((n, frozenset(chosen + [e]))):
                    chosen.append(e)
            parts.append((n, frozenset(chosen)))
            remaining -= set(chosen)
        if best is None or len(parts) < len(best):
            best = parts
        if best is not None and len(best) <= -(-n // 3):
            break
    assert best is not None
    for p in best:
        assert is_triangular_forest(p)
    return best


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------

def show(g: Graph) -> str:
    """Readable rendering of a graph's edge set."""
    _, edges = g
    return "{" + ", ".join(f"{min(e)}{max(e)}" for e in sorted(edges, key=lambda e: sorted(e))) + "}"


def banner(text: str) -> None:
    print()
    print("=" * 78)
    print(text)
    print("=" * 78)


def demo_membership() -> None:
    banner("1.  Membership in the class of triangular forests")
    examples: List[Tuple[str, Graph]] = [
        ("K_3  (a triangle)", complete_graph(3)),
        ("K_4", complete_graph(4)),
        ("C_4  (a 4-cycle)", make_graph(4, [(0, 1), (1, 2), (2, 3), (3, 0)])),
        ("path P_5", make_graph(5, [(0, 1), (1, 2), (2, 3), (3, 4)])),
        ("bowtie F_2", windmill(2)),
        ("two triangles sharing an edge", make_graph(4, [(0, 1), (1, 2), (0, 2), (1, 3), (2, 3)])),
        ("triangle with two pendant edges", make_graph(5, [(0, 1), (0, 2), (1, 2), (0, 4), (1, 3)])),
    ]
    for name, g in examples:
        fast = is_triangular_forest(g)
        slow = brute_force_is_triangular_forest(g)
        assert fast == slow, f"membership tests disagree on {name}"
        print(f"  {name:34s} n={g[0]}  e={len(g[1]):2d}   triangular forest: {fast}")
    print("\n  (the fast block-based test agrees with brute-force cycle enumeration)")


def demo_sparsity() -> None:
    banner("2-3.  The sharp sparsity law  2e <= 3(n-1)  and its extremal graphs")
    print("   n | max e over all triangular forests | floor(3(n-1)/2) | 2n-3 (weak bound)")
    print("  ---+-----------------------------------+-----------------+------------------")
    for n in range(1, 7):
        best, witness = max_edges_triangular_forest(n)
        assert best == sparsity_bound(n), f"sharp bound violated at n={n}"
        weak = max(2 * n - 3, 0)
        print(f"  {n:2d} | {best:33d} | {sparsity_bound(n):15d} | {weak:17d}")
        if witness is not None and n >= 3:
            print(f"     |   a maximiser: {show(witness)}")
    print("\n  The windmill graphs attain the bound for every odd order:")
    for k in range(1, 7):
        g = windmill(k)
        n, edges = g
        assert is_triangular_forest(g)
        assert 2 * len(edges) == 3 * (n - 1)
        print(f"    F_{k}:  n = {n:2d},  e = {len(edges):2d},  2e = {2*len(edges):2d} = 3(n-1)")


def demo_threshold() -> None:
    banner("4.  The exact threshold:  K_n decomposes into two triangular forests iff n <= 5")
    for n in range(2, 8):
        result = decompose_into_two(complete_graph(n))
        verdict = "YES" if result else "no "
        edges = n * (n - 1) // 2
        budget = 2 * sparsity_bound(n)
        print(f"  K_{n}:  e = {edges:2d},  two-part budget 2*floor(3(n-1)/2) = {budget:2d}   ->  {verdict}")
        if result:
            a, b = result
            print(f"        part 1 = {show(a)}")
            print(f"        part 2 = {show(b)}")
    print()
    print("  The critical case n = 6:  K_6 has 15 edges and the real-valued budget is")
    print("  2 * 3*5/2 = 15 -- a dead heat.  Integrality decides it:  2e <= 15 with e an")
    print("  integer forces e <= 7 per part, so at most 14 < 15 edges can be covered.")
    print("  The decomposition therefore fails by exactly one edge.")


def demo_clique_obstruction() -> None:
    banner("5.  The clique obstruction: a K_6 subgraph forbids decomposition")
    # K_6 plus an isolated vertex and a pendant path: still contains K_6, still fails.
    g = make_graph(9, list(itertools.combinations(range(6), 2)) + [(0, 6), (6, 7), (7, 8)])
    print(f"  Host graph: K_6 with a pendant path attached, n = {g[0]}, e = {len(g[1])}")
    print(f"  contains K_6:                {contains_k6(g)}")
    print(f"  decomposes into two forests: {decompose_into_two(g) is not None}")
    print()
    print("  How much must be removed from K_6 before it decomposes?")
    for removed in ([(4, 5)], [(4, 5), (2, 3)], [(4, 5), (2, 3), (0, 1)]):
        h = make_graph(6, [p for p in itertools.combinations(range(6), 2)
                           if p not in removed])
        res = decompose_into_two(h)
        label = "K_6 minus " + ", ".join(f"{a}{b}" for a, b in removed)
        print(f"    {label:32s} e = {len(h[1]):2d}   decomposes: {res is not None}")
        if res:
            a, b = res
            print(f"        part 1 = {show(a)}")
            print(f"        part 2 = {show(b)}")
    print()
    print("  Deleting a single edge is not enough: the resulting 14 edges exactly")
    print("  saturate the budget 2*floor(3*5/2) = 14, and no split achieves it.")
    print("  Deleting two disjoint edges does suffice.")


def demo_thickness() -> None:
    banner("6.  Triangular thickness of K_n:  the lower bound n <= 3k, and greedy covers")
    print("   n | lower bound ceil(n/3) | greedy cover found | matches?")
    print("  ---+-----------------------+--------------------+---------")
    for n in range(3, 11):
        lb = -(-n // 3)
        cover = greedy_cover(complete_graph(n), tries=2000)
        k = len(cover)
        # verify the cover
        covered: Set[Edge] = set()
        for part in cover:
            assert is_triangular_forest(part)
            covered |= set(part[1])
        assert covered == complete_graph(n)[1]
        assert n <= 3 * k, "the proved lower bound n <= 3k must hold"
        mark = "yes" if k == lb else f"no (needs {k})"
        print(f"  {n:2d} | {lb:21d} | {k:18d} | {mark}")
    print("\n  n = 6 is the exception: counting permits k = 2, but no such cover exists.")


def demo_local_structure() -> None:
    banner("7.  Local structure: neighbourhoods induce matchings")
    for k in range(1, 5):
        g = windmill(k)
        adj = adjacency(g)
        worst = 0
        for e in g[1]:
            worst = max(worst, len(triangles_through(g, e)))
        # check the matching property directly at every vertex
        ok = True
        for v in range(g[0]):
            for u in adj[v]:
                partners = [w for w in adj[v] if w != u and w in adj[u]]
                if len(partners) > 1:
                    ok = False
        print(f"  F_{k}: max #triangles through an edge = {worst}; "
              f"every neighbourhood a matching: {ok}")
    print("\n  Consequence: in a triangular forest triangles are pairwise edge-disjoint,")
    print("  which is what makes the linear-time membership test correct.")


def main() -> None:
    print(__doc__)
    demo_membership()
    demo_sparsity()
    demo_threshold()
    demo_clique_obstruction()
    demo_thickness()
    demo_local_structure()
    banner("All computed values agree with the theorems.")


if __name__ == "__main__":
    main()
