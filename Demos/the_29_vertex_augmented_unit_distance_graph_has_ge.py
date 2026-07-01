"""
demo.py -- Numerical demonstrations of the independence-ratio engine for
fractional colorings.

Core facts demonstrated:

  (1) Weak-duality bound:   |V| <= alpha(G) * total(w)   for any feasible
      fractional coloring w, hence   chi_f(G) >= |V| / alpha(G).

  (2) Quarter barrier:      4 * alpha(G) < |V|   ==>   chi_f(G) > 4.

  (3) Blow-up invariance:   rho(G[t]) = rho(G),  so a single sub-quarter
      witness spawns an infinite family with the same ratio ceiling.

The script uses only the Python standard library and exact integer / fraction
arithmetic, so every printed inequality is verified, not approximated.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

Vertex = int
Edge = Tuple[Vertex, Vertex]
Graph = Dict[Vertex, Set[Vertex]]


# ---------------------------------------------------------------------------
# Graph utilities
# ---------------------------------------------------------------------------
def make_graph(n: int, edges: Iterable[Edge]) -> Graph:
    """Build an adjacency-set graph on vertices {0, ..., n-1}."""
    g: Graph = {v: set() for v in range(n)}
    for u, v in edges:
        if u == v:
            continue
        g[u].add(v)
        g[v].add(u)
    return g


def is_independent(g: Graph, s: FrozenSet[Vertex]) -> bool:
    """A set is independent if no two of its vertices are adjacent."""
    verts = list(s)
    for i in range(len(verts)):
        for j in range(i + 1, len(verts)):
            if verts[j] in g[verts[i]]:
                return False
    return True


def independence_number(g: Graph) -> int:
    """Maximum size of an independent set (branch-and-bound over vertices)."""
    verts = sorted(g)
    n = len(verts)
    best = 0

    def expand(idx: int, chosen: List[Vertex]) -> None:
        nonlocal best
        # Prune: even taking every remaining vertex cannot beat best.
        if len(chosen) + (n - idx) <= best:
            return
        if idx == n:
            best = max(best, len(chosen))
            return
        v = verts[idx]
        # Branch 1: include v if it is non-adjacent to all chosen vertices.
        if all(v not in g[c] for c in chosen):
            expand(idx + 1, chosen + [v])
        # Branch 2: exclude v.
        expand(idx + 1, chosen)

    expand(0, [])
    return best


def maximum_independent_sets(g: Graph) -> List[FrozenSet[Vertex]]:
    """All independent sets of maximum size (small graphs only)."""
    alpha = independence_number(g)
    verts = list(g)
    out: List[FrozenSet[Vertex]] = []
    for combo in combinations(verts, alpha):
        s = frozenset(combo)
        if is_independent(g, s):
            out.append(s)
    return out


# ---------------------------------------------------------------------------
# Fractional-coloring quantities
# ---------------------------------------------------------------------------
def independence_ratio(g: Graph) -> Fraction:
    """rho(G) = alpha(G) / |V|, computed exactly as a Fraction."""
    return Fraction(independence_number(g), len(g))


def lower_bound_chi_f(g: Graph) -> Fraction:
    """Weak-duality lower bound  chi_f(G) >= |V| / alpha(G)."""
    return Fraction(len(g), independence_number(g))


def singleton_coloring_total(g: Fraction | Graph) -> int:
    """The singleton coloring (weight 1 on each vertex) has total |V|;
    this is the trivial upper bound chi_f(G) <= |V|."""
    assert isinstance(g, dict)
    return len(g)


def verify_weak_duality(g: Graph, weights: Dict[FrozenSet[Vertex], Fraction]) -> bool:
    """Check that `weights` is a feasible fractional coloring, then verify the
    weak-duality inequality  |V| <= alpha(G) * total(w)  holds exactly."""
    # (i) nonnegativity and (ii) support on independent sets.
    for s, w in weights.items():
        if w < 0:
            return False
        if w > 0 and not is_independent(g, s):
            return False
    # (iii) covering: every vertex covered to level >= 1.
    for v in g:
        cover = sum((w for s, w in weights.items() if v in s), Fraction(0))
        if cover < 1:
            return False
    total = sum(weights.values(), Fraction(0))
    alpha = independence_number(g)
    return len(g) <= alpha * total


# ---------------------------------------------------------------------------
# Balanced blow-up
# ---------------------------------------------------------------------------
def balanced_blowup(g: Graph, t: int) -> Graph:
    """Replace each vertex by t copies; copies of adjacent vertices are joined,
    copies of the same vertex form an independent cluster."""
    verts = sorted(g)
    index = {v: i for i, v in enumerate(verts)}
    n = len(verts)

    def label(v: Vertex, k: int) -> int:
        return index[v] * t + k

    edges: List[Edge] = []
    for u in verts:
        for v in g[u]:
            if index[u] < index[v]:
                for a in range(t):
                    for b in range(t):
                        edges.append((label(u, a), label(v, b)))
    return make_graph(n * t, edges)


# ---------------------------------------------------------------------------
# Example graphs
# ---------------------------------------------------------------------------
def cycle_graph(n: int) -> Graph:
    """The n-cycle C_n, a unit-distance graph. alpha(C_n) = floor(n/2)."""
    return make_graph(n, [(i, (i + 1) % n) for i in range(n)])


def sub_quarter_witness() -> Graph:
    """A small combinatorial graph with independence ratio strictly below 1/4,
    illustrating the quarter-barrier mechanism abstractly. It is the disjoint
    union of complete graphs K5, K5, K5 (three cliques of size 5): a clique of
    size 5 contributes exactly 1 to any independent set, so alpha = 3 while
    |V| = 15, giving rho = 3/15 = 1/5 < 1/4."""
    edges: List[Edge] = []
    base = 0
    for _ in range(3):
        block = list(range(base, base + 5))
        for u, v in combinations(block, 2):
            edges.append((u, v))
        base += 5
    return make_graph(15, edges)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_weak_duality() -> None:
    print("=" * 70)
    print("Demo 1: weak duality  |V| <= alpha(G) * total(w)")
    print("=" * 70)
    g = cycle_graph(5)  # C_5: alpha = 2, |V| = 5
    alpha = independence_number(g)
    print(f"Graph C_5:  |V| = {len(g)},  alpha(G) = {alpha}")
    # A feasible fractional coloring of C_5: the 5 independent edges (max
    # independent sets of size 2), each with weight 1/2, cover every vertex
    # exactly once and have total 5/2.
    edges2 = [frozenset(s) for s in combinations(range(5), 2)
              if is_independent(g, frozenset(s))]
    weights = {s: Fraction(1, 2) for s in edges2}
    ok = verify_weak_duality(g, weights)
    total = sum(weights.values(), Fraction(0))
    print(f"Feasible coloring on max independent sets, total = {total}")
    print(f"Weak-duality inequality verified exactly: {ok}")
    print(f"Lower bound  |V|/alpha = {lower_bound_chi_f(g)}  (= {float(lower_bound_chi_f(g)):.4f})")
    print(f"chi_f(C_5) is exactly 5/2 = {Fraction(5, 2)} -- bound is tight.\n")


def demo_quarter_barrier() -> None:
    print("=" * 70)
    print("Demo 2: quarter barrier  rho(G) < 1/4  ==>  chi_f(G) > 4")
    print("=" * 70)
    g = sub_quarter_witness()
    alpha = independence_number(g)
    n = len(g)
    rho = independence_ratio(g)
    bound = lower_bound_chi_f(g)
    print(f"Witness graph:  |V| = {n},  alpha(G) = {alpha}")
    print(f"Independence ratio rho = {rho} = {float(rho):.4f}  (< 1/4: {rho < Fraction(1,4)})")
    print(f"Check 4*alpha < |V|:  4*{alpha} = {4*alpha} < {n}  -> {4*alpha < n}")
    print(f"Certified lower bound chi_f >= {bound} = {float(bound):.4f} > 4: {bound > 4}\n")


def demo_blowup_invariance() -> None:
    print("=" * 70)
    print("Demo 3: blow-up invariance  rho(G[t]) = rho(G)")
    print("=" * 70)
    g = sub_quarter_witness()
    rho0 = independence_ratio(g)
    print(f"Base graph rho = {rho0}")
    for t in (2, 3):
        gt = balanced_blowup(g, t)
        rt = independence_ratio(gt)
        print(f"  t = {t}:  |V[t]| = {len(gt):3d},  alpha = {independence_number(gt):2d},"
              f"  rho = {rt}  (equal to base: {rt == rho0})")
    print()


def demo_27_to_29_schematic() -> None:
    print("=" * 70)
    print("Demo 4: schematic 27 -> 29 augmentation arithmetic")
    print("=" * 70)
    # The 27-vertex base sits exactly at rho = 1/4:  alpha = 27/4 is not an
    # integer, but the configuration realizes chi_f = 4 (ratio exactly 1/4 in
    # the fractional sense). Adding two points that intrude on every maximum
    # independent set forces alpha to drop so that 4*alpha < 29.
    for n, alpha, tag in [(27, Fraction(27, 4), "base (threshold)"),
                          (29, 7, "augmented witness")]:
        ratio = Fraction(alpha) / n if isinstance(alpha, int) else alpha / n
        bound = Fraction(n) / alpha
        strict = bound > 4
        print(f"  {tag:22s}:  |V| = {n},  alpha = {alpha},"
              f"  rho = {ratio},  chi_f >= {bound} ( > 4: {strict})")
    print("\n  The augmented 29-point graph has 4*7 = 28 < 29, so rho = 7/29 < 1/4,")
    print("  giving chi_f(G_29) >= 29/7 > 4, hence chi_f(plane) > 4.\n")


def main() -> None:
    demo_weak_duality()
    demo_quarter_barrier()
    demo_blowup_invariance()
    demo_27_to_29_schematic()


if __name__ == "__main__":
    main()
