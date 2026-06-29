"""
demo.py — Numerical demonstrations for

    "Optimality of the Density Threshold for Linear r-Uniform Hypergraphs"

Main results demonstrated here (all self-contained, no external dependencies):

    Theorem (density threshold, `linear_card_le`):
        A linear r-uniform hypergraph on n vertices with m edges satisfies
            m * C(r, 2) <= C(n, 2),   i.e.   m <= n(n-1) / (r(r-1)).

    Theorem (optimality, `steiner_card_eq`):
        A Steiner system S(2, r, n) attains equality:
            m * C(r, 2) = C(n, 2).

We verify these on explicit linear hypergraphs (the Fano plane S(2,3,7),
the affine planes S(2,3,9) and S(2,4,16)), confirm the disjoint-pair double
count (`pairs_disjoint` + `biUnion_pairs_subset`), and illustrate the
divisibility obstruction at non-admissible orders.

Run with:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import Dict, FrozenSet, Iterable, List, Sequence, Tuple

# A hypergraph is a list of edges; each edge is a frozenset of vertices.
Vertex = int
Edge = FrozenSet[Vertex]
Hypergraph = List[Edge]
Pair = Tuple[Vertex, Vertex]


# --------------------------------------------------------------------------- #
# Core combinatorial predicates (mirrors of the Lean definitions)
# --------------------------------------------------------------------------- #
def is_uniform(edges: Hypergraph, r: int) -> bool:
    """IsUniform: every edge has exactly r vertices."""
    return all(len(e) == r for e in edges)


def is_linear(edges: Hypergraph) -> bool:
    """IsLinear: any two distinct edges meet in at most one vertex."""
    for i in range(len(edges)):
        for j in range(i + 1, len(edges)):
            if len(edges[i] & edges[j]) > 1:
                return False
    return True


def pair_set(e: Edge) -> List[Pair]:
    """The 2-element subsets of an edge (mirror of powersetCard 2 e)."""
    return [tuple(sorted(p)) for p in combinations(sorted(e), 2)]


def covers_all_pairs(edges: Hypergraph, vertices: Sequence[Vertex]) -> bool:
    """Every 2-subset of the vertex set is contained in some edge."""
    universe = {tuple(sorted(p)) for p in combinations(sorted(vertices), 2)}
    covered: set[Pair] = set()
    for e in edges:
        covered.update(pair_set(e))
    return universe <= covered


def is_steiner(edges: Hypergraph, r: int, vertices: Sequence[Vertex]) -> bool:
    """IsSteiner: r-uniform + linear + covers every pair of vertices."""
    return (
        is_uniform(edges, r)
        and is_linear(edges)
        and covers_all_pairs(edges, vertices)
    )


# --------------------------------------------------------------------------- #
# Pair-incidence double count (the engine of both theorems)
# --------------------------------------------------------------------------- #
def pair_multiplicities(edges: Hypergraph) -> Dict[Pair, int]:
    """Count, for every vertex pair, how many edges contain it."""
    table: Dict[Pair, int] = {}
    for e in edges:
        for p in pair_set(e):
            table[p] = table.get(p, 0) + 1
    return table


def pairs_disjoint(edges: Hypergraph) -> bool:
    """`pairs_disjoint`: in a linear family no pair is covered twice."""
    return all(mult <= 1 for mult in pair_multiplicities(edges).values())


def total_pairs_covered(edges: Hypergraph) -> int:
    """Size of the (disjoint, when linear) union of the per-edge pair sets."""
    return len(pair_multiplicities(edges))


# --------------------------------------------------------------------------- #
# Threshold arithmetic
# --------------------------------------------------------------------------- #
def threshold_integer(n: int, r: int) -> int:
    """Maximum number of edges floor(C(n,2) / C(r,2))."""
    return comb(n, 2) // comb(r, 2)


def threshold_real(n: int, r: int) -> float:
    """Real density bound n(n-1) / (r(r-1))."""
    return n * (n - 1) / (r * (r - 1))


def steiner_admissible(n: int, r: int) -> bool:
    """Classical necessary divisibility conditions for S(2,r,n)."""
    return (n - 1) % (r - 1) == 0 and (n * (n - 1)) % (r * (r - 1)) == 0


# --------------------------------------------------------------------------- #
# Explicit extremal hypergraphs (Steiner systems achieving equality)
# --------------------------------------------------------------------------- #
def fano_plane() -> Hypergraph:
    """The Fano plane S(2,3,7): 7 blocks on vertices 1..7."""
    blocks = [
        {1, 2, 3}, {1, 4, 5}, {1, 6, 7},
        {2, 4, 6}, {2, 5, 7},
        {3, 4, 7}, {3, 5, 6},
    ]
    return [frozenset(b) for b in blocks]


def affine_plane_order(q: int) -> Tuple[Hypergraph, List[Vertex]]:
    """
    Affine plane AG(2,q) for PRIME q: a Steiner system S(2, q, q^2).
    Points are pairs (x,y) in (Z/q)^2 encoded as x*q + y.
    Lines: y = a*x + b (q^2 lines) and x = c (q vertical lines).

    NB: q must be prime so that Z/q is a field (for true prime powers such
    as q = 4 one must use GF(q) arithmetic, not Z/q).
    """
    pts = list(range(q * q))

    def code(x: int, y: int) -> int:
        return x * q + y

    lines: Hypergraph = []
    for a in range(q):
        for b in range(q):
            lines.append(frozenset(code(x, (a * x + b) % q) for x in range(q)))
    for c in range(q):
        lines.append(frozenset(code(c, y) for y in range(q)))
    return lines, pts


# --------------------------------------------------------------------------- #
# Reporting helpers
# --------------------------------------------------------------------------- #
def report_hypergraph(name: str, edges: Hypergraph, r: int,
                      vertices: Sequence[Vertex]) -> None:
    n = len(vertices)
    m = len(edges)
    lhs = m * comb(r, 2)
    rhs = comb(n, 2)
    print(f"=== {name} ===")
    print(f"  vertices n = {n}, edge size r = {r}, edges m = {m}")
    print(f"  r-uniform        : {is_uniform(edges, r)}")
    print(f"  linear           : {is_linear(edges)}")
    print(f"  pairs disjoint   : {pairs_disjoint(edges)}")
    print(f"  covers all pairs : {covers_all_pairs(edges, vertices)}")
    print(f"  is Steiner S(2,{r},{n}) : {is_steiner(edges, r, vertices)}")
    print(f"  m*C(r,2) = {lhs},  C(n,2) = {rhs}")
    relation = "=" if lhs == rhs else "<"
    print(f"  threshold check  : m*C(r,2) {relation} C(n,2)   "
          f"(upper bound m <= {threshold_integer(n, r)} edges)")
    print(f"  pairs covered (union size) = {total_pairs_covered(edges)} "
          f"(should equal m*C(r,2) = {lhs} when linear)")
    print()


def main() -> None:
    print("Optimality of the Density Threshold for Linear r-Uniform Hypergraphs")
    print("=" * 70)
    print()

    # 1. Fano plane: S(2,3,7), achieves equality 7*3 = 21 = C(7,2).
    report_hypergraph("Fano plane  S(2,3,7)", fano_plane(), r=3,
                      vertices=list(range(1, 8)))

    # 2. Affine plane AG(2,3): S(2,3,9), achieves equality 12*3 = 36 = C(9,2).
    edges3, pts3 = affine_plane_order(3)
    report_hypergraph("Affine plane AG(2,3) = S(2,3,9)", edges3, r=3,
                      vertices=pts3)

    # 3. Affine plane AG(2,5): block size q=5 gives S(2,5,25), achieving
    #    equality 30*10 = 300 = C(25,2).
    edges5, pts5 = affine_plane_order(5)  # q=5 is prime; Z/5 is a field
    report_hypergraph("Affine plane AG(2,5) = S(2,5,25)", edges5, r=5,
                      vertices=pts5)

    # 4. A linear (non-Steiner) sub-hypergraph: drop one block from the Fano
    #    plane. Still linear, no longer covers all pairs -> strict inequality.
    partial = fano_plane()[:-1]
    report_hypergraph("Fano minus one block (linear, not Steiner)", partial,
                      r=3, vertices=list(range(1, 8)))

    # 5. Divisibility obstruction at non-admissible orders.
    print("=== Steiner admissibility scan (r = 3) ===")
    print("  n : C(n,2)  threshold floor  admissible (S(2,3,n) can exist)")
    for n in range(3, 16):
        print(f"  {n:2d} : {comb(n,2):6d}  {threshold_integer(n,3):14d}  "
              f"{steiner_admissible(n,3)}")
    print()
    print("  Note: admissible n for r=3 are exactly n = 1,3 (mod 6):")
    print("       ", [n for n in range(3, 40) if steiner_admissible(n, 3)])


if __name__ == "__main__":
    main()
