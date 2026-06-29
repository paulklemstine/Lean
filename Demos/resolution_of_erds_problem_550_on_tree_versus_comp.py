"""
Numerical demonstrations for the foundational cases of Erdos Problem 550
(tree versus complete multipartite Ramsey numbers), all-ones specialization.

Results demonstrated:
  * ramsey_tree_edge        :  R(T, K_2) = n  for every n-vertex tree T.
  * chvatal_lower_bound     :  R(T, K_k) > (k-1)(n-1), witnessed by the
                               disjoint-clique "block coloring".
  * allones identification  :  K_{1,...,1} = K_k.
  * Chvatal value           :  R(T_n, K_k) = (k-1)(n-1) + 1.

Everything is self-contained: graphs are adjacency-relation closures on
range(N), colorings are functions on unordered pairs, and "containment"
is brute-force injective embedding search (exponential, used only on tiny
instances for verification).

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations, permutations
from typing import Callable, Dict, FrozenSet, List, Set, Tuple

Vertex = int
Edge = FrozenSet[Vertex]
AdjPred = Callable[[Vertex, Vertex], bool]


# ---------------------------------------------------------------------------
# Basic graph utilities
# ---------------------------------------------------------------------------

def complete_graph_edges(n: int) -> Set[Edge]:
    """Edge set of the complete graph K_n on vertices 0..n-1."""
    return {frozenset((u, v)) for u, v in combinations(range(n), 2)}


def path_tree_edges(n: int) -> Set[Edge]:
    """The path P_n: 0-1-2-...-(n-1). A tree on n vertices."""
    return {frozenset((i, i + 1)) for i in range(n - 1)}


def star_tree_edges(n: int) -> Set[Edge]:
    """The star K_{1,n-1}: center 0 joined to 1..n-1. A tree on n vertices."""
    return {frozenset((0, i)) for i in range(1, n)}


def is_connected(vertices: List[Vertex], edges: Set[Edge]) -> bool:
    """Standard BFS connectivity check."""
    if not vertices:
        return True
    adj: Dict[Vertex, Set[Vertex]] = {v: set() for v in vertices}
    for e in edges:
        a, b = tuple(e)
        adj[a].add(b)
        adj[b].add(a)
    seen = {vertices[0]}
    stack = [vertices[0]]
    while stack:
        x = stack.pop()
        for y in adj[x]:
            if y not in seen:
                seen.add(y)
                stack.append(y)
    return len(seen) == len(vertices)


def is_tree(n: int, edges: Set[Edge]) -> bool:
    """A tree on n vertices: connected with exactly n-1 edges."""
    return is_connected(list(range(n)), edges) and len(edges) == n - 1


# ---------------------------------------------------------------------------
# Containment (graph embedding) search
# ---------------------------------------------------------------------------

def contains_copy(
    n_small: int,
    edges_small: Set[Edge],
    n_big: int,
    adj_big: AdjPred,
) -> bool:
    """
    True iff the graph (n_small, edges_small) embeds into the graph on
    range(n_big) with adjacency `adj_big`, i.e. there is an injective map
    f with edge (x,y) => adj_big(f x, f y). Brute force; tiny instances only.
    """
    targets = range(n_big)
    for f in permutations(targets, n_small):
        ok = True
        for e in edges_small:
            x, y = tuple(e)
            if not adj_big(f[x], f[y]):
                ok = False
                break
        if ok:
            return True
    return False


# ---------------------------------------------------------------------------
# Colorings as red-adjacency predicates; blue = complement on distinct pairs
# ---------------------------------------------------------------------------

def block_coloring_red(k: int, n: int) -> Tuple[int, AdjPred]:
    """
    The extremal disjoint-clique coloring witnessing R(T,K_k) > (k-1)(n-1).
    Red iff same block; blocks have size s=n-1, there are b=k-1 blocks.
    Returns (N, red_adj) where N = (k-1)(n-1).
    """
    s = n - 1
    b = k - 1
    N = b * s

    def red_adj(x: Vertex, y: Vertex) -> bool:
        return x != y and (x // s) == (y // s)

    return N, red_adj


def blue_of(red_adj: AdjPred) -> AdjPred:
    """Blue adjacency = complement of red on distinct pairs."""
    return lambda x, y: x != y and not red_adj(x, y)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_base_case() -> None:
    """R(T, K_2) = n: K_n arrows to (T,K_2), K_{n-1} does not."""
    print("=" * 70)
    print("DEMO 1: Exact base case  R(T, K_2) = n   (ramsey_tree_edge)")
    print("=" * 70)
    for n, name, edges in [
        (4, "path P_4", path_tree_edges(4)),
        (5, "star K_{1,4}", star_tree_edges(5)),
    ]:
        assert is_tree(n, edges), "must be a tree"
        # Upper bound: every red graph on n vertices yields red T or a blue edge.
        # The hardest red graph to beat is K_n itself (no blue edge), which
        # contains T because T <= K_n. Verify T embeds in K_n.
        kn_adj: AdjPred = lambda x, y: x != y
        has_red_T = contains_copy(n, edges, n, kn_adj)
        # Lower bound: all-red K_{n-1} has no blue edge and cannot host
        # the connected n-vertex tree on n-1 vertices.
        red_T_in_n_minus_1 = contains_copy(n, edges, n - 1, kn_adj)
        print(f"  {name} (n={n}):")
        print(f"    T embeds in red K_n            : {has_red_T}  (=> R <= {n})")
        print(f"    T embeds in red K_(n-1)        : {red_T_in_n_minus_1}"
              f"  (no blue edge there => R > {n-1})")
        print(f"    Conclusion  R(T, K_2) = {n}")
    print()


def demo_lower_bound() -> None:
    """Block coloring on (k-1)(n-1) vertices: no red T, no blue K_k."""
    print("=" * 70)
    print("DEMO 2: Tightness lower bound  R(T,K_k) > (k-1)(n-1)"
          "  (chvatal_lower_bound)")
    print("=" * 70)
    for k, n in [(3, 3), (3, 4), (4, 3)]:
        N, red = block_coloring_red(k, n)
        blue = blue_of(red)
        tree_edges = path_tree_edges(n)
        assert is_tree(n, tree_edges)
        # No red copy of the n-vertex tree:
        red_T = contains_copy(n, tree_edges, N, red)
        # No blue copy of K_k:
        kk_edges = complete_graph_edges(k)
        blue_Kk = contains_copy(k, kk_edges, N, blue)
        print(f"  k={k}, n={n}:  N=(k-1)(n-1)={N}")
        print(f"    red copy of P_{n}  present : {red_T}")
        print(f"    blue copy of K_{k} present : {blue_Kk}")
        print(f"    => coloring avoids both  => R(P_{n}, K_{k}) > {N}")
    print()


def demo_allones_identification() -> None:
    """K_{1,...,1} (k singleton parts) is isomorphic to K_k."""
    print("=" * 70)
    print("DEMO 3: All-ones identification  K_{1,...,1} = K_k")
    print("        (completeGraph_isContained_allOnes / allOnes_..._completeGraph)")
    print("=" * 70)
    for k in range(2, 6):
        # Singleton-part multipartite graph on k vertices: vertex i in part i.
        # Adjacent iff different parts iff i != j -> exactly K_k.
        mp_adj: AdjPred = lambda x, y: x != y          # parts are singletons
        kk_adj: AdjPred = lambda x, y: x != y
        kk_edges = complete_graph_edges(k)
        fwd = contains_copy(k, kk_edges, k, mp_adj)    # K_k -> K_{1..1}
        # K_{1..1} edges equal K_k edges here; check reverse embedding too.
        bwd = contains_copy(k, kk_edges, k, kk_adj)
        print(f"  k={k}:  K_k -> K_(1,..,1): {fwd}   K_(1,..,1) -> K_k: {bwd}"
              f"   => isomorphic")
    print()


def demo_chvatal_values() -> None:
    """Tabulate R(T_n, K_k) = (k-1)(n-1)+1."""
    print("=" * 70)
    print("DEMO 4: Chvatal values  R(T_n, K_k) = (k-1)(n-1)+1")
    print("=" * 70)
    print("        (lower bound proven here; upper bound is Chvatal's theorem)")
    ks = [2, 3, 4, 5]
    ns = [2, 3, 4, 5, 6]
    header = "  n \\ k | " + " ".join(f"{k:4d}" for k in ks)
    print(header)
    print("  " + "-" * (len(header) - 2))
    for n in ns:
        row = " ".join(f"{(k - 1) * (n - 1) + 1:4d}" for k in ks)
        print(f"  {n:5d} | {row}")
    print()
    print("  Spot checks:")
    print(f"    R(P_5, K_3) = 2*4 + 1 = {2*4+1}")
    print(f"    R(K_(1,4), K_4) = 3*4 + 1 = {3*4+1}")
    print()


def main() -> None:
    demo_base_case()
    demo_lower_bound()
    demo_allones_identification()
    demo_chvatal_values()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
