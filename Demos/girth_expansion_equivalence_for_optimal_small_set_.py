"""
Girth-Expansion Bridge for Optimal Small-Set Expanders -- numerical demonstrations.

This self-contained script demonstrates, on concrete left-d-regular bipartite
graphs, the results of the accompanying paper:

  * optimal_imp_girth     : optimal small-set expansion  =>  girth >= 2s+2
  * converse_false        : girth >= 6 does NOT imply 2-optimal expansion
  * optimal_iff_disjoint  : for s >= 2, optimal  <=>  pairwise-disjoint nbhds
  * no_four_cycle_iff     : no 4-cycle  <=>  every pair shares <= 1 neighbor

Model.  A left-d-regular bipartite graph is a neighbor function
    N : L -> set(R)
with |N(u)| = d for every left vertex u.  We represent it as a dict mapping
each left vertex (an int) to a frozenset of right vertices (ints).

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

# A left-d-regular bipartite graph: left vertex -> set of right neighbors.
Graph = Dict[int, FrozenSet[int]]


# --------------------------------------------------------------------------- #
# Core combinatorial quantities                                               #
# --------------------------------------------------------------------------- #
def neighborhood(graph: Graph, left_set: Iterable[int]) -> Set[int]:
    """Return N(X) = union of N(u) over u in left_set (Definition 'nbhd')."""
    out: Set[int] = set()
    for u in left_set:
        out |= set(graph[u])
    return out


def is_left_regular(graph: Graph, d: int) -> bool:
    """Check |N(u)| = d for every left vertex (Definition 'LeftRegular')."""
    return all(len(graph[u]) == d for u in graph)


def degree(graph: Graph) -> int:
    """Common left-degree d (assumes the graph is left-regular)."""
    return len(next(iter(graph.values()))) if graph else 0


def is_optimal_expander(graph: Graph, d: int, s: int) -> bool:
    """
    Definition 'OptimalExpander': every left set X with |X| <= s satisfies
    |N(X)| = d * |X| (maximal possible neighborhood size).
    """
    lefts = list(graph)
    for size in range(0, s + 1):
        for X in combinations(lefts, size):
            if len(neighborhood(graph, X)) != d * len(X):
                return False
    return True


def all_pairs_disjoint(graph: Graph) -> bool:
    """Definition 'AllPairsDisjoint': N(u) and N(v) disjoint for all u != v."""
    lefts = list(graph)
    for u, v in combinations(lefts, 2):
        if graph[u] & graph[v]:
            return False
    return True


def max_pairwise_intersection(graph: Graph) -> int:
    """Largest |N(u) cap N(v)| over distinct left vertices u, v."""
    lefts = list(graph)
    best = 0
    for u, v in combinations(lefts, 2):
        best = max(best, len(graph[u] & graph[v]))
    return best


def has_four_cycle(graph: Graph) -> bool:
    """
    'HasCycle N 2': a 4-cycle is two distinct left vertices sharing two
    distinct right neighbors (Remark 2.7).  Equivalent to
    max_pairwise_intersection >= 2.
    """
    return max_pairwise_intersection(graph) >= 2


def has_short_cycle(graph: Graph, s: int) -> bool:
    """
    'HasShortCycle N s': there is a 2k-cycle with 2 <= k <= s.  We detect a
    2k-cycle directly: k distinct left vertices u_0..u_{k-1} and k distinct
    right vertices w_0..w_{k-1} with w_i in N(u_i) cap N(u_{i+1 mod k}).
    """
    lefts = list(graph)
    for k in range(2, s + 1):
        if _has_cycle_of_length(graph, k, lefts):
            return True
    return False


def _has_cycle_of_length(graph: Graph, k: int, lefts: List[int]) -> bool:
    """Brute-force search for a combinatorial 2k-cycle ('HasCycle N k')."""
    from itertools import permutations

    for left_tuple in permutations(lefts, k):
        # Need distinct right vertices w_i in N(u_i) cap N(u_{i+1 mod k}).
        choices: List[List[int]] = []
        ok = True
        for i in range(k):
            shared = graph[left_tuple[i]] & graph[left_tuple[(i + 1) % k]]
            if not shared:
                ok = False
                break
            choices.append(sorted(shared))
        if ok and _can_pick_distinct(choices):
            return True
    return False


def _can_pick_distinct(choices: List[List[int]]) -> bool:
    """Can we pick one element from each list, all distinct? (small backtrack)"""
    def bt(i: int, used: Set[int]) -> bool:
        if i == len(choices):
            return True
        for x in choices[i]:
            if x not in used:
                used.add(x)
                if bt(i + 1, used):
                    return True
                used.discard(x)
        return False

    return bt(0, set())


def girth_ge(graph: Graph, s: int) -> bool:
    """Definition 'GirthGe': girth >= 2s+2, i.e. no short cycle up to 2s."""
    return not has_short_cycle(graph, s)


# --------------------------------------------------------------------------- #
# Example graphs                                                              #
# --------------------------------------------------------------------------- #
def disjoint_stars(num_left: int, d: int) -> Graph:
    """Vertex-disjoint union of stars: N(u) = {u*d, ..., u*d + d - 1}."""
    return {u: frozenset(range(u * d, u * d + d)) for u in range(num_left)}


def counterexample_graph() -> Graph:
    """
    The witness of 'converse_false':
        L = {0, 1}, R = {0, 1, 2}, d = 2,
        N(0) = {0, 1},  N(1) = {1, 2}.
    Girth >= 6 (shares only one neighbor) but NOT 2-optimal (|N({0,1})| = 3).
    """
    return {0: frozenset({0, 1}), 1: frozenset({1, 2})}


def four_cycle_graph() -> Graph:
    """Two left vertices sharing two neighbors: a 4-cycle (girth = 4)."""
    return {0: frozenset({0, 1}), 1: frozenset({0, 1})}


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_forward_bridge() -> None:
    """optimal_imp_girth: an optimal expander always has girth >= 2s+2."""
    print("=" * 70)
    print("DEMO 1  --  Forward bridge (optimal_imp_girth)")
    print("=" * 70)
    g = disjoint_stars(num_left=4, d=3)
    d = degree(g)
    for s in (2, 3, 4):
        opt = is_optimal_expander(g, d, s)
        girth = girth_ge(g, s)
        print(f"  disjoint stars (n=4, d={d}):  s={s}  optimal={opt}  "
              f"girth>=2s+2={girth}   optimal=>girth: {(not opt) or girth}")
    print("  => optimality implies the girth bound in every case.\n")


def demo_converse_fails() -> None:
    """converse_false: girth >= 6 but not 2-optimal."""
    print("=" * 70)
    print("DEMO 2  --  Converse fails (converse_false)")
    print("=" * 70)
    g = counterexample_graph()
    d = degree(g)
    X = [0, 1]
    print(f"  N(0)={set(g[0])}  N(1)={set(g[1])}  d={d}")
    print(f"  girth>=6 (GirthGe N 2): {girth_ge(g, 2)}")
    print(f"  |N({{0,1}})| = {len(neighborhood(g, X))}  vs  d*|X| = {d*len(X)}")
    print(f"  2-optimal expander: {is_optimal_expander(g, d, 2)}")
    print("  => high girth does NOT imply optimal expansion.\n")


def demo_optimal_iff_disjoint() -> None:
    """optimal_iff_disjoint: for s>=2, optimal <=> pairwise-disjoint."""
    print("=" * 70)
    print("DEMO 3  --  Optimal <=> Disjoint (optimal_iff_disjoint)")
    print("=" * 70)
    graphs = {
        "disjoint stars (n=3,d=2)": disjoint_stars(3, 2),
        "counterexample N0={0,1},N1={1,2}": counterexample_graph(),
        "4-cycle N0=N1={0,1}": four_cycle_graph(),
    }
    for name, g in graphs.items():
        d = degree(g)
        for s in (2, 3):
            opt = is_optimal_expander(g, d, s)
            disj = all_pairs_disjoint(g)
            print(f"  {name:34s} s={s}  optimal={opt}  disjoint={disj}  "
                  f"match={opt == disj}")
    print("  => optimal and pairwise-disjoint coincide; s carries no info.\n")


def demo_no_four_cycle_iff() -> None:
    """no_four_cycle_iff: no 4-cycle <=> every pair shares <= 1 neighbor."""
    print("=" * 70)
    print("DEMO 4  --  Girth-6 characterization (no_four_cycle_iff)")
    print("=" * 70)
    graphs = {
        "disjoint stars (n=3,d=2)": disjoint_stars(3, 2),
        "counterexample N0={0,1},N1={1,2}": counterexample_graph(),
        "4-cycle N0=N1={0,1}": four_cycle_graph(),
    }
    for name, g in graphs.items():
        no4 = not has_four_cycle(g)
        share_le1 = max_pairwise_intersection(g) <= 1
        print(f"  {name:34s} no-4-cycle={no4}  max-share<=1={share_le1}  "
              f"match={no4 == share_le1}")
    print("  => no 4-cycle is exactly 'every pair shares at most one neighbor'.\n")


def main() -> None:
    print("\nGIRTH-EXPANSION BRIDGE FOR OPTIMAL SMALL-SET EXPANDERS")
    print("Numerical demonstrations of the four main results.\n")
    demo_forward_bridge()
    demo_converse_fails()
    demo_optimal_iff_disjoint()
    demo_no_four_cycle_iff()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
