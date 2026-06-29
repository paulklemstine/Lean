"""
Numerical demonstration of the theorem:

    Girth bounds the minimum distance of a bipartite graph code.

Setup. A simple left-d-regular bipartite graph G on left vertices L and right
vertices R is given by an incidence relation inc(l, r). The code B(G) consists of
the sets S of left vertices such that EVERY right vertex has an even number of
neighbours in S. The minimum distance d_min is the size of the smallest non-empty
codeword.

Main theorem. If G is left-d-regular with d >= 2 and girth >= 2k+2, then
d_min >= k+1, i.e.  d_min >= ceil(girth / 2).

This file:
  * builds bipartite incidence graphs (Fano plane, complete bipartite, a tree),
  * computes girth by BFS,
  * computes minimum distance by exact codeword search,
  * extracts a cycle from a codeword (the constructive heart of the proof),
  * checks the inequality chain  2k+2 <= girth <= length <= 2|S|  on real data.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations
from collections import deque
from typing import Dict, List, Optional, Set, Tuple, Iterable
import math


# ---------------------------------------------------------------------------
# Bipartite incidence model
# ---------------------------------------------------------------------------

Incidence = Dict[int, Set[int]]  # left vertex -> set of right neighbours


def left_degree(inc: Incidence, l: int) -> int:
    """Number of right neighbours of left vertex l."""
    return len(inc[l])


def is_left_d_regular(inc: Incidence) -> Optional[int]:
    """Return d if G is left-d-regular, else None."""
    degs = {left_degree(inc, l) for l in inc}
    return next(iter(degs)) if len(degs) == 1 else None


def right_vertices(inc: Incidence) -> Set[int]:
    """All right vertices appearing in the incidence relation."""
    rs: Set[int] = set()
    for nbrs in inc.values():
        rs |= nbrs
    return rs


# ---------------------------------------------------------------------------
# The code B(G):  S is a codeword iff every right vertex has even S-degree
# ---------------------------------------------------------------------------

def right_degree_in(inc: Incidence, S: Iterable[int]) -> Dict[int, int]:
    """For each right vertex, how many of its neighbours lie in S."""
    Sset = set(S)
    counts: Dict[int, int] = {r: 0 for r in right_vertices(inc)}
    for l in Sset:
        for r in inc[l]:
            counts[r] += 1
    return counts


def is_codeword(inc: Incidence, S: Iterable[int]) -> bool:
    """Every right vertex must have an even number of neighbours in S."""
    return all(c % 2 == 0 for c in right_degree_in(inc, S).values())


def minimum_distance(inc: Incidence) -> Tuple[int, List[int]]:
    """Exact minimum distance: smallest non-empty codeword, by increasing size."""
    left = sorted(inc.keys())
    for size in range(1, len(left) + 1):
        for S in combinations(left, size):
            if is_codeword(inc, S):
                return size, list(S)
    return 0, []  # only the empty codeword exists


# ---------------------------------------------------------------------------
# Graph realisation on L (+) R  and girth via BFS
# ---------------------------------------------------------------------------

def adjacency(inc: Incidence) -> Dict[Tuple[str, int], Set[Tuple[str, int]]]:
    """Realise biGraph(inc) on tagged vertices ('L', l) and ('R', r)."""
    adj: Dict[Tuple[str, int], Set[Tuple[str, int]]] = {}
    for l, nbrs in inc.items():
        adj.setdefault(("L", l), set())
        for r in nbrs:
            adj.setdefault(("R", r), set())
            adj[("L", l)].add(("R", r))
            adj[("R", r)].add(("L", l))
    return adj


def girth(inc: Incidence) -> float:
    """Shortest cycle length via BFS from each vertex; inf if acyclic."""
    adj = adjacency(inc)
    best = math.inf
    for src in adj:
        dist = {src: 0}
        parent = {src: None}
        q = deque([src])
        while q:
            u = q.popleft()
            for w in adj[u]:
                if w not in dist:
                    dist[w] = dist[u] + 1
                    parent[w] = u
                    q.append(w)
                elif parent[u] != w:
                    best = min(best, dist[u] + dist[w] + 1)
    return best


# ---------------------------------------------------------------------------
# Constructive cycle extraction (the proof's heart)
# ---------------------------------------------------------------------------

def restricted_adjacency(inc: Incidence, S: Iterable[int]):
    """Edges of biGraph(inc) incident to a left vertex in S."""
    Sset = set(S)
    adj: Dict[Tuple[str, int], Set[Tuple[str, int]]] = {}
    for l in Sset:
        adj.setdefault(("L", l), set())
        for r in inc[l]:
            adj.setdefault(("R", r), set())
            adj[("L", l)].add(("R", r))
            adj[("R", r)].add(("L", l))
    return adj


def find_cycle_in_codeword(inc: Incidence, S: Iterable[int]) -> Optional[List]:
    """Given a non-empty codeword S, find a cycle in the restricted graph (DFS).

    By the theorem, the restricted graph has no degree-one vertex, so a cycle
    must exist; by bipartite alternation its length equals
    2 * (number of distinct left vertices it visits). The returned list is the
    cyclic sequence of vertices [v_0, v_1, ..., v_{L-1}] (edges v_i -> v_{i+1}
    and v_{L-1} -> v_0), so its length L equals the number of edges.
    """
    adj = restricted_adjacency(inc, S)
    visited: Set = set()
    parent: Dict = {}

    def dfs(u, p) -> Optional[List]:
        visited.add(u)
        parent[u] = p
        for w in adj[u]:
            if w == p:
                continue
            if w in visited:
                # back edge u -> w: reconstruct the path w ... u (the cycle)
                cycle = [u]
                cur = u
                while cur != w:
                    cur = parent[cur]
                    cycle.append(cur)
                return cycle  # vertices u, parent(u), ..., w ; closes w -> u
            res = dfs(w, u)
            if res is not None:
                return res
        return None

    for start in adj:
        if start not in visited:
            c = dfs(start, None)
            if c is not None:
                return c
    return None


# ---------------------------------------------------------------------------
# Example graphs
# ---------------------------------------------------------------------------

def fano_incidence() -> Incidence:
    """Fano plane: left = 7 lines, right = 7 points; left-3-regular, girth 6."""
    lines = [
        {0, 1, 2}, {0, 3, 4}, {0, 5, 6}, {1, 3, 5},
        {1, 4, 6}, {2, 3, 6}, {2, 4, 5},
    ]
    return {i: set(line) for i, line in enumerate(lines)}


def complete_bipartite(m: int, n: int) -> Incidence:
    """K_{m,n}: each of m left vertices joined to all n right vertices."""
    return {l: set(range(n)) for l in range(m)}


def star_tree(n: int) -> Incidence:
    """A tree (acyclic): one left vertex joined to n right vertices."""
    return {0: set(range(n))}


# ---------------------------------------------------------------------------
# Reporting: verify the theorem on each example
# ---------------------------------------------------------------------------

def report(name: str, inc: Incidence) -> None:
    d = is_left_d_regular(inc)
    g = girth(inc)
    dmin, S = minimum_distance(inc)
    print(f"=== {name} ===")
    print(f"  left vertices : {sorted(inc.keys())}")
    print(f"  left-regular  : {'yes, d=' + str(d) if d is not None else 'no'}")
    print(f"  girth         : {'inf (acyclic)' if g == math.inf else int(g)}")

    if g == math.inf:
        k_bound = "any k (acyclic): theorem gives d_min >= k+1 for all k"
        predicted = "infinite"
    else:
        k = int(g) // 2 - 1            # largest k with 2k+2 <= girth
        predicted = k + 1
        k_bound = f"k = {k}  (since 2k+2 = {2*k+2} <= girth = {int(g)})"
    print(f"  theorem param : {k_bound}")

    if dmin == 0:
        print("  min distance  : no non-empty codeword (only the zero codeword)")
        print("  theorem holds : vacuously (predicted lower bound never violated)\n")
        return

    print(f"  min distance  : d_min = {dmin}, witnessed by codeword S = {S}")
    if d is not None and d >= 2 and g != math.inf:
        ok = dmin >= predicted
        print(f"  prediction    : d_min >= {predicted}  -> {'TIGHT' if dmin == predicted else 'satisfied'} ({ok})")
        # constructive: cycle hidden in the minimum codeword
        cyc = find_cycle_in_codeword(inc, S)
        if cyc is not None:
            left_on_cycle = {v for v in cyc if v[0] == "L"}
            length = len(cyc)  # cyclic vertex list: #vertices == #edges
            m = len(left_on_cycle)
            print(f"  hidden cycle  : length {length} = 2 * {m} distinct left vertices")
            print(f"  chain check   : {2*k+2} <= {int(g)} <= {length} <= {2*dmin}"
                  f"  ->  {2*k+2 <= int(g) <= length <= 2*dmin}")
    print()


def main() -> None:
    print("Girth bounds the minimum distance of a bipartite graph code\n")
    report("Fano plane incidence graph (d=3, girth 6): bound 3, actual 4 (not tight)",
           fano_incidence())
    report("Complete bipartite K_{2,3} (d=3, girth 4): TIGHT witness, d_min = 2",
           complete_bipartite(2, 3))
    report("Complete bipartite K_{3,3} (d=3, girth 4): TIGHT witness, d_min = 2",
           complete_bipartite(3, 3))
    report("Star tree S_4 (acyclic, girth infinite)", star_tree(4))


if __name__ == "__main__":
    main()
