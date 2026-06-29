"""Numerical demonstrations of the linear one-set wall--Menger bound.

This script exercises the four machine-checked theorems of the package:

  * exists_maximal_packing          -- a maximum pairwise-disjoint subfamily exists
  * packing_cover_duality           -- no s-packing  =>  hitting set of size <= c*(s-1)
  * wall_menger_separator_bound     -- the c = 4 specialisation: |X| <= 4s - 4
  * kConnected_neighbor_packing     -- a k-connected graph has >= k neighbour singletons

All functions are self-contained, type-hinted, and use only the standard library.

Constants from the concept / Lean output:
    T(s, r) = (8*s + 4) * r        wall-height threshold (linear in r)
    F(s)    = 4*s - 4              separator bound (depends only on s)
    c       = 4                    nail wall-degree (per-member cost)
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

Vertex = int
Member = FrozenSet[Vertex]
Family = List[Member]


# ----------------------------------------------------------------------------
# Concept constants
# ----------------------------------------------------------------------------

def T(s: int, r: int) -> int:
    """Wall-height threshold T(s, r) = (8s + 4) r (linear in r)."""
    return (8 * s + 4) * r


def F(s: int) -> int:
    """Separator bound F(s) = 4s - 4 (the c = 4 specialisation)."""
    return 4 * s - 4


# ----------------------------------------------------------------------------
# Theorem 1: exists_maximal_packing  (here computed as a *maximum* packing)
# ----------------------------------------------------------------------------

def is_pairwise_disjoint(subfamily: Iterable[Member]) -> bool:
    """True iff the given members are pairwise disjoint."""
    members = list(subfamily)
    for a, b in combinations(members, 2):
        if a & b:
            return False
    return True


def maximum_packing(family: Family) -> List[Member]:
    """A pairwise-disjoint subfamily of MAXIMUM cardinality (exists_maximal_packing).

    Brute-force search over subfamilies; intended for small instances.
    Returns one maximiser.
    """
    best: List[Member] = []
    n = len(family)
    for size in range(n, -1, -1):
        for combo in combinations(family, size):
            if is_pairwise_disjoint(combo):
                return list(combo)
    return best


def greedy_maximal_packing(family: Family) -> List[Member]:
    """Algorithm A: a *maximal* (not necessarily maximum) packing, greedily.

    Repeatedly add any member disjoint from those already chosen.
    """
    chosen: List[Member] = []
    union: Set[Vertex] = set()
    for member in family:
        if not (member & union):
            chosen.append(member)
            union |= member
    return chosen


def packing_number(family: Family) -> int:
    """nu(F): the maximum size of a pairwise-disjoint subfamily."""
    return len(maximum_packing(family))


# ----------------------------------------------------------------------------
# Theorem 2: packing_cover_duality
# ----------------------------------------------------------------------------

def union_of(members: Iterable[Member]) -> Set[Vertex]:
    out: Set[Vertex] = set()
    for m in members:
        out |= m
    return out


def is_hitting_set(family: Family, x: Set[Vertex]) -> bool:
    """True iff x meets every member of the family."""
    return all(bool(member & x) for member in family)


def packing_cover_duality(family: Family, s: int, c: int) -> Dict[str, object]:
    """Demonstrate: if F is c-bounded, nonempty-membered, and has no s-packing,
    then the union X of a maximum packing hits every member and |X| <= c(s-1).

    Returns a dictionary with the witness and the verified inequalities.
    """
    assert all(len(m) >= 1 for m in family), "members must be nonempty"
    assert all(len(m) <= c for m in family), "family must be c-bounded"
    nu = packing_number(family)
    assert nu <= s - 1, f"family has an s-packing (nu = {nu} >= s = {s})"

    packing = maximum_packing(family)
    x = union_of(packing)
    bound = c * (s - 1)
    return {
        "packing": [sorted(m) for m in packing],
        "packing_number": nu,
        "hitting_set": sorted(x),
        "hitting_set_size": len(x),
        "bound_c_times_s_minus_1": bound,
        "is_hitting_set": is_hitting_set(family, x),
        "size_bound_holds": len(x) <= bound,
    }


# ----------------------------------------------------------------------------
# Theorem 3: wall_menger_separator_bound  (c = 4)
# ----------------------------------------------------------------------------

def wall_menger_separator_bound(path_traces: Family, s: int) -> Dict[str, object]:
    """The c = 4 specialisation. path_traces are A--nail traces, each of size <= 4.
    If there is no s-packing, the hitting set X has |X| <= 4s - 4 = F(s).
    """
    result = packing_cover_duality(path_traces, s, c=4)
    result["F_of_s"] = F(s)
    result["meets_F_bound"] = result["hitting_set_size"] <= F(s)
    return result


# ----------------------------------------------------------------------------
# Theorem 4: kConnected_neighbor_packing
# ----------------------------------------------------------------------------

class SimpleGraph:
    """A minimal finite simple graph by adjacency sets."""

    def __init__(self, vertices: Iterable[Vertex], edges: Iterable[Tuple[Vertex, Vertex]]):
        self.vertices: Set[Vertex] = set(vertices)
        self.adj: Dict[Vertex, Set[Vertex]] = {v: set() for v in self.vertices}
        for u, v in edges:
            if u != v:
                self.adj[u].add(v)
                self.adj[v].add(u)

    def neighbors(self, w: Vertex) -> Set[Vertex]:
        return self.adj[w]

    def min_degree(self) -> int:
        return min((len(self.adj[v]) for v in self.vertices), default=0)

    def is_connected_after_deleting(self, removed: Set[Vertex]) -> bool:
        remaining = self.vertices - removed
        if not remaining:
            return True
        start = next(iter(remaining))
        seen = {start}
        stack = [start]
        while stack:
            u = stack.pop()
            for v in self.adj[u]:
                if v in remaining and v not in seen:
                    seen.add(v)
                    stack.append(v)
        return seen == remaining

    def is_k_connected(self, k: int) -> bool:
        """|V| > k and deleting any < k vertices keeps the graph connected."""
        if len(self.vertices) <= k:
            return False
        vs = list(self.vertices)
        for size in range(0, k):
            for s_combo in combinations(vs, size):
                if not self.is_connected_after_deleting(set(s_combo)):
                    return False
        return True


def kconnected_neighbor_packing(graph: SimpleGraph, w: Vertex) -> Dict[str, object]:
    """Build the neighbour-singleton family P = { {n} : n in N(w) } and verify it is
    a pairwise-disjoint family of nonempty sets of size >= deg(w) >= k (Whitney).
    """
    singletons: Family = [frozenset({n}) for n in sorted(graph.neighbors(w))]
    return {
        "vertex": w,
        "neighbor_singletons": [sorted(m) for m in singletons],
        "packing_size": len(singletons),
        "all_nonempty": all(len(m) >= 1 for m in singletons),
        "pairwise_disjoint": is_pairwise_disjoint(singletons),
        "degree": len(graph.neighbors(w)),
    }


# ----------------------------------------------------------------------------
# Driver
# ----------------------------------------------------------------------------

def main() -> None:
    print("=" * 72)
    print("Linear one-set wall--Menger bound: numerical demonstrations")
    print("=" * 72)

    # --- Theorem 1 & 2: greedy packing-cover duality (toy cycle, c = 2) -----
    print("\n[1/4] packing_cover_duality on a 5-cycle of overlapping pairs (c=2, s=3)")
    cyc: Family = [
        frozenset({1, 2}), frozenset({2, 3}), frozenset({3, 4}),
        frozenset({4, 5}), frozenset({5, 1}),
    ]
    out = packing_cover_duality(cyc, s=3, c=2)
    for key, val in out.items():
        print(f"    {key}: {val}")
    assert out["is_hitting_set"] and out["size_bound_holds"]

    # --- Theorem 3: wall separator bound at c = 4 --------------------------
    print("\n[2/4] wall_menger_separator_bound: nail traces of size <= 4 (s = 3)")
    # Six nail traces (each <= 4 wall-vertices) whose packing number is 2 < s = 3.
    traces: Family = [
        frozenset({10, 11, 12, 13}),
        frozenset({13, 14, 15, 16}),
        frozenset({16, 17, 18, 10}),
        frozenset({11, 14, 17, 12}),
        frozenset({15, 18, 13, 16}),
        frozenset({12, 15, 18, 11}),
    ]
    res = wall_menger_separator_bound(traces, s=3)
    for key, val in res.items():
        print(f"    {key}: {val}")
    assert res["is_hitting_set"] and res["meets_F_bound"]
    print(f"    => |X| = {res['hitting_set_size']} <= F(3) = {F(3)}")

    # --- Threshold table T(s,r) is linear in r ----------------------------
    print("\n[3/4] threshold T(s,r) = (8s+4)r is linear in r, F(s) = 4s-4")
    print("    s  r   T(s,r)   F(s)")
    for s in (1, 2, 3):
        for r in (1, 2, 4):
            print(f"    {s}  {r}   {T(s, r):>5}    {F(s):>3}")
        # verify linearity in r
        assert T(s, 2) - T(s, 1) == T(s, 3) - T(s, 2) == (8 * s + 4)

    # --- Theorem 4: connectivity bridge -----------------------------------
    print("\n[4/4] kConnected_neighbor_packing on K_5 (k = 4-connected)")
    k5 = SimpleGraph(range(5), [(i, j) for i in range(5) for j in range(i + 1, 5)])
    k = 4
    print(f"    is_{k}_connected(K5) = {k5.is_k_connected(k)}")
    print(f"    min_degree(K5)      = {k5.min_degree()}  (>= k = {k}, Whitney)")
    pack = kconnected_neighbor_packing(k5, w=0)
    for key, val in pack.items():
        print(f"    {key}: {val}")
    assert pack["pairwise_disjoint"] and pack["all_nonempty"]
    assert pack["packing_size"] >= k, "packing horn must have size >= k"
    print(f"    => packing horn realised with {pack['packing_size']} >= k = {k} members")

    print("\nAll demonstrations passed.")


if __name__ == "__main__":
    main()
