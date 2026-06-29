"""
Numerical demonstrations for: Chromatic Counting, Deletion-Contraction,
and the Sharpness of the Greedy Bound.

Every function is self-contained with type hints. The module verifies, on
concrete graphs, the main theorems from the formal development:

  * chromCount_bot   : edgeless graph has k**n proper colorings
  * chromCount_top   : complete graph has falling-factorial proper colorings
  * chromCount_deletion_contraction :
        P(G_del, k) = P(G, k) + contractCount(G_del, u, v, k)
  * chromCount_eq_zero_iff : P(G,k) = 0  <=>  G is not k-colorable
  * colorable_maxDegree_add_one / chromaticNumber_le_maxDegree_add_one :
        chi(G) <= maxDegree(G) + 1   (greedy bound)
  * completeGraph_chromatic_eq_maxDegree_add_one : chi(K_{n+1}) = n+1 = Delta+1
  * oddCycle_chromatic_eq_maxDegree_add_one      : chi(C_{2m+3}) = 3 = Delta+1

A graph is represented as (n_vertices, frozenset of edges), where each edge is
a frozenset {u, v} of distinct vertices in range(n_vertices).
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Dict, FrozenSet, List, Set, Tuple

Edge = FrozenSet[int]
Graph = Tuple[int, FrozenSet[Edge]]


# --------------------------------------------------------------------------- #
# Graph constructors
# --------------------------------------------------------------------------- #
def edgeless_graph(n: int) -> Graph:
    """The edgeless graph (bottom) on n vertices: no edges, no constraints."""
    return (n, frozenset())


def complete_graph(n: int) -> Graph:
    """The complete graph K_n (top): every pair of vertices is adjacent."""
    edges: Set[Edge] = {frozenset({u, v}) for u in range(n) for v in range(u + 1, n)}
    return (n, frozenset(edges))


def cycle_graph(n: int) -> Graph:
    """The cycle C_n on vertices 0..n-1 (requires n >= 3)."""
    if n < 3:
        raise ValueError("cycle_graph requires n >= 3")
    edges: Set[Edge] = {frozenset({i, (i + 1) % n}) for i in range(n)}
    return (n, frozenset(edges))


def path_graph(n: int) -> Graph:
    """The path P_n on vertices 0..n-1."""
    edges: Set[Edge] = {frozenset({i, i + 1}) for i in range(n - 1)}
    return (n, frozenset(edges))


def random_graph(n: int, p: float, seed: int) -> Graph:
    """An Erdos-Renyi style random graph G(n, p)."""
    rng = random.Random(seed)
    edges: Set[Edge] = set()
    for u in range(n):
        for v in range(u + 1, n):
            if rng.random() < p:
                edges.add(frozenset({u, v}))
    return (n, frozenset(edges))


# --------------------------------------------------------------------------- #
# Core combinatorics
# --------------------------------------------------------------------------- #
def adjacency(graph: Graph) -> Dict[int, Set[int]]:
    """Adjacency lists of the graph."""
    n, edges = graph
    adj: Dict[int, Set[int]] = {v: set() for v in range(n)}
    for e in edges:
        a, b = tuple(e)
        adj[a].add(b)
        adj[b].add(a)
    return adj


def max_degree(graph: Graph) -> int:
    """Maximum degree Delta(G); 0 for the empty vertex set."""
    adj = adjacency(graph)
    return max((len(nbrs) for nbrs in adj.values()), default=0)


def is_proper(graph: Graph, coloring: Tuple[int, ...]) -> bool:
    """True iff `coloring` assigns different colors to adjacent vertices."""
    _, edges = graph
    return all(coloring[a] != coloring[b] for e in edges for a, b in [tuple(e)])


def chrom_count_bruteforce(graph: Graph, k: int) -> int:
    """P(G, k): number of proper k-colorings, by exhaustive enumeration."""
    n, _ = graph
    if k <= 0:
        return 1 if n == 0 else 0
    return sum(1 for c in itertools.product(range(k), repeat=n) if is_proper(graph, c))


def contract_count_bruteforce(graph: Graph, u: int, v: int, k: int) -> int:
    """contractCount: proper k-colorings of `graph` with color(u) == color(v)."""
    n, _ = graph
    if k <= 0:
        return 0
    return sum(
        1
        for c in itertools.product(range(k), repeat=n)
        if c[u] == c[v] and is_proper(graph, c)
    )


def add_edge(graph: Graph, u: int, v: int) -> Graph:
    """Return graph + edge uv."""
    n, edges = graph
    return (n, edges | {frozenset({u, v})})


def remove_edge(graph: Graph, u: int, v: int) -> Graph:
    """Return graph - edge uv."""
    n, edges = graph
    return (n, edges - {frozenset({u, v})})


def chromatic_number(graph: Graph) -> int:
    """chi(G) = least k with P(G,k) > 0  (Proposition: chromCount_eq_zero_iff)."""
    n, _ = graph
    for k in range(n + 1):
        if chrom_count_bruteforce(graph, k) > 0:
            return k
    return n  # unreachable for simple graphs


def falling_factorial(k: int, n: int) -> int:
    """k^{underline n} = k (k-1) ... (k-n+1) = k.descFactorial n."""
    result = 1
    for i in range(n):
        result *= k - i
    return result


# --------------------------------------------------------------------------- #
# Exact chromatic polynomial via deletion-contraction (the DC recursion)
# --------------------------------------------------------------------------- #
def chromatic_polynomial_coeffs(graph: Graph) -> List[int]:
    """
    Coefficients of the chromatic polynomial P(G, x) as a list [c0, c1, ...]
    (so P(G, x) = sum c_i x^i), computed purely by deletion-contraction:

        P(G, x) = P(G - uv, x) - P(G / uv, x)      (subtractive form)

    Base case: the edgeless graph on n vertices has P = x^n (chromCount_bot).
    """
    n, edges = graph
    if not edges:
        coeffs = [0] * (n + 1)
        coeffs[n] = 1
        return coeffs  # x^n
    e = next(iter(edges))
    u, v = tuple(e)
    deleted = remove_edge(graph, u, v)
    # Contraction G / uv: merge v into u, relabel vertices to 0..n-2.
    contracted = _contract(graph, u, v)
    p_del = chromatic_polynomial_coeffs(deleted)
    p_con = chromatic_polynomial_coeffs(contracted)
    length = max(len(p_del), len(p_con))
    p_del += [0] * (length - len(p_del))
    p_con += [0] * (length - len(p_con))
    return [p_del[i] - p_con[i] for i in range(length)]


def _contract(graph: Graph, u: int, v: int) -> Graph:
    """Contract edge uv: identify v with u, remove loops, relabel to 0..n-2."""
    n, edges = graph
    new_edges: Set[Edge] = set()
    for e in edges:
        a, b = tuple(e)
        a = u if a == v else a
        b = u if b == v else b
        if a != b:
            new_edges.add(frozenset({a, b}))
    remaining = sorted(set(range(n)) - {v})
    relabel = {old: i for i, old in enumerate(remaining)}
    relabeled: Set[Edge] = {
        frozenset({relabel[a], relabel[b]}) for e in new_edges for a, b in [tuple(e)]
    }
    return (n - 1, frozenset(relabeled))


def eval_poly(coeffs: List[int], k: int) -> int:
    """Evaluate a polynomial given as coefficient list at integer k."""
    return sum(c * k**i for i, c in enumerate(coeffs))


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_edgeless_and_complete() -> None:
    print("=" * 70)
    print("chromCount_bot and chromCount_top: closed forms at the extremes")
    print("=" * 70)
    for n in range(1, 5):
        for k in range(1, 5):
            bot = chrom_count_bruteforce(edgeless_graph(n), k)
            assert bot == k**n, (n, k, bot)
            top = chrom_count_bruteforce(complete_graph(n), k)
            assert top == falling_factorial(k, n), (n, k, top)
        print(f"  n={n}: edgeless P(bot,k)=k^{n}, complete P(top,k)=k^_underline_{n}  OK")
    print()


def demo_deletion_contraction() -> None:
    print("=" * 70)
    print("chromCount_deletion_contraction:")
    print("  P(G_del,k) = P(G,k) + contractCount(G_del,u,v,k)")
    print("=" * 70)
    test_graphs = [
        ("path P4", path_graph(4)),
        ("cycle C5", cycle_graph(5)),
        ("K4", complete_graph(4)),
        ("random(5,0.5)", random_graph(5, 0.5, seed=7)),
    ]
    for name, g_del in test_graphs:
        n, edges = g_del
        # pick a non-edge (u, v) so adding it is meaningful; else any pair.
        pair = None
        for u in range(n):
            for v in range(u + 1, n):
                if frozenset({u, v}) not in edges:
                    pair = (u, v)
                    break
            if pair:
                break
        if pair is None:
            pair = (0, 1)
        u, v = pair
        g = add_edge(g_del, u, v)
        for k in range(1, 5):
            lhs = chrom_count_bruteforce(g_del, k)
            rhs = chrom_count_bruteforce(g, k) + contract_count_bruteforce(g_del, u, v, k)
            assert lhs == rhs, (name, k, lhs, rhs)
        print(f"  {name:15s} edge ({u},{v}): identity holds for k=1..4  OK")
    print()


def demo_dc_polynomial() -> None:
    print("=" * 70)
    print("Deletion-contraction computes the chromatic polynomial exactly")
    print("=" * 70)
    test_graphs = [
        ("path P4", path_graph(4)),
        ("cycle C5", cycle_graph(5)),
        ("K4", complete_graph(4)),
        ("random(6,0.4)", random_graph(6, 0.4, seed=3)),
    ]
    for name, g in test_graphs:
        coeffs = chromatic_polynomial_coeffs(g)
        for k in range(0, 6):
            assert eval_poly(coeffs, k) == chrom_count_bruteforce(g, k), (name, k)
        terms = " + ".join(f"{c}x^{i}" for i, c in enumerate(coeffs) if c)
        print(f"  {name:15s} P(x) = {terms}")
        print(f"  {'':15s} matches brute force for k=0..5  OK")
    print()


def demo_greedy_bound_and_brooks() -> None:
    print("=" * 70)
    print("Greedy bound chi <= Delta+1, and the two Brooks exceptions")
    print("=" * 70)
    families = [
        ("edgeless n=4", edgeless_graph(4)),
        ("path P5", path_graph(5)),
        ("even cycle C6", cycle_graph(6)),
        ("odd cycle C5", cycle_graph(5)),
        ("odd cycle C7", cycle_graph(7)),
        ("K3", complete_graph(3)),
        ("K5", complete_graph(5)),
        ("random(6,0.5)", random_graph(6, 0.5, seed=11)),
    ]
    for name, g in families:
        chi = chromatic_number(g)
        delta = max_degree(g)
        tight = "  <-- TIGHT (chi = Delta+1)" if chi == delta + 1 else ""
        assert chi <= delta + 1, (name, chi, delta)
        print(f"  {name:15s} chi={chi}, Delta={delta}, Delta+1={delta+1}{tight}")
    print()
    print("  Verifying completeGraph_chromatic_eq_maxDegree_add_one:")
    for n in range(1, 6):  # K_{n+1}
        g = complete_graph(n + 1)
        assert chromatic_number(g) == max_degree(g) + 1 == n + 1
        print(f"    K_{n+1}: chi = {n+1} = Delta+1  OK")
    print("  Verifying oddCycle_chromatic_eq_maxDegree_add_one:")
    for m in range(0, 3):  # C_{2m+3}
        g = cycle_graph(2 * m + 3)
        assert chromatic_number(g) == max_degree(g) + 1 == 3
        print(f"    C_{2*m+3}: chi = 3 = Delta+1  OK")
    print()


def demo_tropical_sandwich() -> None:
    print("=" * 70)
    print("Tropical (max-plus) deletion-contraction sandwich on log-counts:")
    print("  max(logP(G), logC) <= logP(G_del) <= max(logP(G), logC) + log2")
    print("=" * 70)
    g_del = cycle_graph(5)
    u, v = 0, 2  # a non-edge of C5
    g = add_edge(g_del, u, v)
    print(f"  {'k':>3} {'logP(G_del)':>12} {'max+0':>10} {'max+log2':>10}")
    for k in range(2, 7):
        p_del = chrom_count_bruteforce(g_del, k)
        p_g = chrom_count_bruteforce(g, k)
        c = contract_count_bruteforce(g_del, u, v, k)
        if min(p_del, p_g, c) == 0:
            continue
        lo = max(math.log(p_g), math.log(c))
        hi = lo + math.log(2)
        val = math.log(p_del)
        assert lo - 1e-9 <= val <= hi + 1e-9, (k, lo, val, hi)
        print(f"  {k:>3} {val:>12.4f} {lo:>10.4f} {hi:>10.4f}")
    print("  Sandwich verified for k=2..6 on C5  OK")
    print()


def main() -> None:
    demo_edgeless_and_complete()
    demo_deletion_contraction()
    demo_dc_polynomial()
    demo_greedy_bound_and_brooks()
    demo_tropical_sandwich()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()


"""
Visualization: chromatic polynomials and the tropical (log) envelope.

Generates two panels:
  (left)  the chromatic polynomial P(G, k) for several graph families, showing
          how the edgeless graph gives k^n and the complete graph gives the
          falling factorial, with paths/cycles in between;
  (right) the tropicalization log P(G, k) vs log k, exhibiting the convex,
          piecewise-linear envelope with integer slopes 0,1,...,|V|.

Self-contained; requires only numpy and matplotlib.
"""

from __future__ import annotations

import itertools
import math
from typing import FrozenSet, List, Set, Tuple

import matplotlib.pyplot as plt
import numpy as np

Edge = FrozenSet[int]
Graph = Tuple[int, FrozenSet[Edge]]


def complete_graph(n: int) -> Graph:
    return (n, frozenset(frozenset({u, v}) for u in range(n) for v in range(u + 1, n)))


def cycle_graph(n: int) -> Graph:
    return (n, frozenset(frozenset({i, (i + 1) % n}) for i in range(n)))


def path_graph(n: int) -> Graph:
    return (n, frozenset(frozenset({i, i + 1}) for i in range(n - 1)))


def edgeless_graph(n: int) -> Graph:
    return (n, frozenset())


def is_proper(graph: Graph, coloring: Tuple[int, ...]) -> bool:
    _, edges = graph
    return all(coloring[a] != coloring[b] for e in edges for a, b in [tuple(e)])


def chrom_count(graph: Graph, k: int) -> int:
    n, _ = graph
    if k <= 0:
        return 1 if n == 0 else 0
    return sum(1 for c in itertools.product(range(k), repeat=n) if is_proper(graph, c))


def main() -> None:
    families = [
        ("edgeless (k^4)", edgeless_graph(4)),
        ("path P4", path_graph(4)),
        ("cycle C4", cycle_graph(4)),
        ("cycle C5 (odd)", cycle_graph(5)),
        ("complete K4", complete_graph(4)),
    ]
    ks = list(range(1, 9))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    for name, g in families:
        ys = [chrom_count(g, k) for k in ks]
        ax1.plot(ks, ys, "o-", label=name)
    ax1.set_title("Chromatic polynomial P(G, k)")
    ax1.set_xlabel("number of colors k")
    ax1.set_ylabel("proper colorings P(G, k)")
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    for name, g in families:
        xs, ys = [], []
        for k in ks:
            c = chrom_count(g, k)
            if c > 0:
                xs.append(math.log(k))
                ys.append(math.log(c))
        ax2.plot(xs, ys, "s-", label=name)
    ax2.set_title("Tropicalization: log P(G, k) vs log k\n(piecewise-linear, integer slopes)")
    ax2.set_xlabel("log k")
    ax2.set_ylabel("log P(G, k)")
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig("chromatic_visualization.png", dpi=140)
    print("saved chromatic_visualization.png")


if __name__ == "__main__":
    main()
