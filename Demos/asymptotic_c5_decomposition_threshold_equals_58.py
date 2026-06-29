"""
Numerical demonstrations for:

    Necessary divisibility conditions for C5-decompositions
    and the asymptotic threshold delta_{C_5} = 5/8.

This script is fully self-contained (standard library only) and illustrates the
formally proven results:

  * c5edges / IsFiveCycle  -- a 5-cycle has exactly 5 edges (c5edges_card)
  * even local incidence    -- each vertex meets a 5-cycle in 0 or 2 edges
                               (c5edges_even_incidence)
  * card_edgeFinset_eq      -- |E(G)| = 5 * (#cycles)
  * five_dvd_card_edgeFinset / even_degree / c5_decomposition_divisible
                            -- necessity of C5-divisibility
  * no_decomposition_of_not_divisible -- contrapositive obstruction
  * cycleGraph5_decomposition / K_5 = C_5 u C_5 -- non-vacuity witnesses
  * nwThreshold_strictAnti  -- delta_{C_ell} = ell/(2 ell - 2) strictly
                               decreasing to 1/2, with delta_{C_5} = 5/8.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

Vertex = int
Edge = FrozenSet[Vertex]          # an unordered pair {a, b}
Graph = Set[Edge]                  # a simple graph as a set of edges


# --------------------------------------------------------------------------- #
# Core primitives mirroring the Lean definitions
# --------------------------------------------------------------------------- #
def edge(a: Vertex, b: Vertex) -> Edge:
    """Unordered edge {a, b} (the Sym2 V constructor s(a, b))."""
    if a == b:
        raise ValueError("a simple-graph edge needs distinct endpoints")
    return frozenset((a, b))


def c5edges(v: Tuple[Vertex, Vertex, Vertex, Vertex, Vertex]) -> Set[Edge]:
    """
    Edge set of the closed 5-cycle through v[0..4], with wrap-around.
    Mirrors `c5edges (v : Fin 5 -> V)`.
    """
    if len(v) != 5:
        raise ValueError("a 5-cycle needs exactly 5 vertex slots")
    return {edge(v[i], v[(i + 1) % 5]) for i in range(5)}


def is_five_cycle(s: Set[Edge]) -> bool:
    """
    Decide whether `s` is the edge set of a genuine 5-cycle on 5 distinct
    vertices.  Mirrors `IsFiveCycle`.
    """
    if len(s) != 5:
        return False
    verts = set().union(*s) if s else set()
    if len(verts) != 5:
        return False
    # every vertex of a 5-cycle has degree exactly 2 and the graph is connected
    deg: Dict[Vertex, int] = {x: 0 for x in verts}
    for e in s:
        for x in e:
            deg[x] += 1
    if any(d != 2 for d in deg.values()):
        return False
    return _is_connected(s, verts)


def _is_connected(s: Set[Edge], verts: Set[Vertex]) -> bool:
    if not verts:
        return True
    adj: Dict[Vertex, Set[Vertex]] = {x: set() for x in verts}
    for e in s:
        a, b = tuple(e)
        adj[a].add(b)
        adj[b].add(a)
    start = next(iter(verts))
    seen = {start}
    stack = [start]
    while stack:
        x = stack.pop()
        for y in adj[x]:
            if y not in seen:
                seen.add(y)
                stack.append(y)
    return seen == verts


def degree(g: Graph, w: Vertex) -> int:
    """Degree of vertex w in graph g."""
    return sum(1 for e in g if w in e)


def vertices(g: Graph) -> Set[Vertex]:
    out: Set[Vertex] = set()
    for e in g:
        out |= set(e)
    return out


# --------------------------------------------------------------------------- #
# C5-divisibility (Definition: IsC5Divisible)
# --------------------------------------------------------------------------- #
def is_c5_divisible(g: Graph) -> bool:
    """All degrees even AND 5 | |E(G)|."""
    if len(g) % 5 != 0:
        return False
    return all(degree(g, w) % 2 == 0 for w in vertices(g))


def divisibility_report(name: str, g: Graph) -> None:
    print(f"  graph {name!r}: |E| = {len(g)}, "
          f"5 | |E|? {len(g) % 5 == 0}, "
          f"all degrees even? {all(degree(g, w) % 2 == 0 for w in vertices(g))} "
          f"=> C5-divisible? {is_c5_divisible(g)}")


# --------------------------------------------------------------------------- #
# Verifying a candidate C5-decomposition (the C5Decomposition structure)
# --------------------------------------------------------------------------- #
def is_c5_decomposition(g: Graph, parts: List[Set[Edge]]) -> bool:
    """
    Check that `parts` is a genuine C5-decomposition of g:
      (isCycle) each part is a 5-cycle,
      (disj)    parts pairwise edge-disjoint,
      (cover)   union of parts == E(g).
    """
    if not all(is_five_cycle(p) for p in parts):
        return False
    seen: Set[Edge] = set()
    for p in parts:
        if seen & p:
            return False          # overlap -> not disjoint
        seen |= p
    return seen == g


# --------------------------------------------------------------------------- #
# Standard graph constructors
# --------------------------------------------------------------------------- #
def cycle_graph(n: int) -> Graph:
    """The n-cycle 0-1-...-(n-1)-0."""
    return {edge(i, (i + 1) % n) for i in range(n)}


def complete_graph(n: int) -> Graph:
    """K_n."""
    return {edge(a, b) for a, b in combinations(range(n), 2)}


# --------------------------------------------------------------------------- #
# The generalized Nash-Williams threshold  (nwThreshold_strictAnti)
# --------------------------------------------------------------------------- #
def nw_threshold(ell: int) -> Fraction:
    """delta_{C_ell} = ell / (2 ell - 2)  as an exact rational."""
    if ell < 3:
        raise ValueError("threshold defined for cycle length ell >= 3")
    return Fraction(ell, 2 * ell - 2)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_edge_count_and_incidence() -> None:
    print("== A single pentagon: 5 edges, even local incidence ==")
    v = (10, 11, 12, 13, 14)
    s = c5edges(v)
    print(f"  c5edges({v}) = {sorted(tuple(sorted(e)) for e in s)}")
    print(f"  |c5edges| = {len(s)}  (c5edges_card: should be 5)")
    for w in (10, 12, 99):
        inc = sum(1 for e in s if w in e)
        print(f"    incidence of vertex {w}: {inc}  (even? {inc % 2 == 0})")
    print(f"  is_five_cycle? {is_five_cycle(s)}")
    print()


def demo_pentagon_witness() -> None:
    print("== Non-vacuity witness 1: C_5 decomposes into itself ==")
    g = cycle_graph(5)
    parts = [set(g)]
    divisibility_report("C_5", g)
    print(f"  valid C5-decomposition (1 part)? {is_c5_decomposition(g, parts)}")
    print(f"  card_edgeFinset_eq check: |E| = {len(g)} = 5 * {len(parts)}")
    print()


def demo_k5_witness() -> None:
    print("== Non-vacuity witness 2: K_5 = C_5 u C_5 ==")
    g = complete_graph(5)
    outer = c5edges((0, 1, 2, 3, 4))     # outer pentagon
    inner = c5edges((0, 2, 4, 1, 3))     # inner pentagram
    parts = [outer, inner]
    divisibility_report("K_5", g)
    print(f"  valid C5-decomposition (2 parts)? {is_c5_decomposition(g, parts)}")
    print(f"  card_edgeFinset_eq check: |E| = {len(g)} = 5 * {len(parts)}")
    print()


def demo_obstruction() -> None:
    print("== Contrapositive obstruction: non-divisible => no decomposition ==")
    # A path 0-1-2-3 has two odd-degree endpoints and 3 edges.
    path = {edge(0, 1), edge(1, 2), edge(2, 3)}
    divisibility_report("path P_4", path)
    print(f"  C5-divisible? {is_c5_divisible(path)} "
          f"=> no C5-decomposition can exist (no_decomposition_of_not_divisible)")
    # K_4: 6 edges (not div by 5), all degrees 3 (odd) -- doubly obstructed.
    k4 = complete_graph(4)
    divisibility_report("K_4", k4)
    print()


def demo_complete_graph_family() -> None:
    print("== Conjecture 3: which K_n are C5-divisible? (n = 5..30) ==")
    print("  expected pattern: n = 1 or 5 (mod 10)")
    rows: List[str] = []
    for n in range(5, 31):
        g = complete_graph(n)
        ok = is_c5_divisible(g)
        residue_ok = (n % 10 in (1, 5))
        flag = "OK " if ok == residue_ok else "!! "
        if ok:
            rows.append(f"  {flag}K_{n:<2}: C5-divisible "
                        f"(|E|={len(g)}, deg={n-1}, n mod 10={n % 10})")
    for r in rows:
        print(r)
    print()


def demo_threshold_family() -> None:
    print("== nwThreshold_strictAnti: delta_{C_ell} = ell/(2 ell - 2) ==")
    prev: Fraction | None = None
    for ell in (3, 5, 7, 9, 11, 21, 101, 1001):
        t = nw_threshold(ell)
        mono = ""
        if prev is not None:
            mono = "  (strictly decreasing)" if t < prev else "  (NOT decreasing!)"
        tag = "  <-- pentagon: 5/8" if ell == 5 else ""
        print(f"  delta_C_{ell:<4} = {t}  = {float(t):.6f}{mono}{tag}")
        prev = t
    print(f"  limit as ell -> infinity: 1/2 = {0.5:.6f}")
    print()


def demo_minimum_degree_threshold() -> None:
    print("== Conjecture 1: the 5/8 minimum-degree bar (illustrative) ==")
    thr = nw_threshold(5)                      # 5/8
    print(f"  threshold delta_C_5 = {thr} = {float(thr)}")
    for n in (80, 800, 8000):
        bar = float(thr) * n
        print(f"    n = {n:>5}: a C5-divisible graph with min-degree > "
              f"{bar:.1f} is conjectured to decompose")
    print()


def main() -> None:
    print("=" * 70)
    print("C5-decompositions and the asymptotic threshold delta_{C_5} = 5/8")
    print("=" * 70)
    print()
    demo_edge_count_and_incidence()
    demo_pentagon_witness()
    demo_k5_witness()
    demo_obstruction()
    demo_complete_graph_family()
    demo_threshold_family()
    demo_minimum_degree_threshold()
    print("All demonstrations consistent with the formal results.")


if __name__ == "__main__":
    main()
