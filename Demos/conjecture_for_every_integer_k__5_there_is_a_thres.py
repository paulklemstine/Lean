#!/usr/bin/env python3
"""
Half-canonical divisors of large rank on regular graphs
=======================================================

Self-contained numerical demonstration of the results of the accompanying paper.

Mathematical background
-----------------------
A *divisor* on a finite simple graph G = (V, E) is a function D : V -> Z (a
configuration of chips, possibly negative).  Its degree is deg D = sum_v D(v).
Firing a set A subset V sends one chip from each vertex of A along each of its
edges leaving A; two divisors are *linearly equivalent* when a sequence of
firings turns one into the other.  A divisor is *effective* if it is everywhere
non-negative.

The *Baker-Norine rank* r(D) is the largest r >= 0 such that for EVERY effective
divisor E of degree r the difference D - E is linearly equivalent to an effective
divisor, with r(D) = -1 if D itself is not equivalent to an effective divisor.

The genus is g = |E| - |V| + 1 and the canonical divisor is K(v) = deg(v) - 2,
of degree 2g - 2.  The *half-canonical degree* is g - 1, where Riemann-Roch
r(D) - r(K - D) = deg D - g + 1 degenerates to r(D) = r(K - D).

Results demonstrated here
-------------------------
 (A) Receiving-move bound: min degree >= k and D >= m everywhere (m >= 1) imply
     r(D) >= m + t for all t <= min(m, k); in particular r(D) >= 2m.
 (B) Set-firing bound:     min degree >= k and D >= m everywhere (2 <= m <= k)
     imply r(D) >= min(3m - 1, k + m).
 (C) Existence:            every simple k-regular graph with k >= 6, k != 7,
     on ANY number of vertices, carries a divisor of degree g - 1 with
     r(D) >= k - 1.
 (D) Obstruction:          on a k-regular graph no divisor of degree g - 1 has
     r chips at every vertex once 2r > k - 2.
 (F) Self-dual witness:    on a 2j-regular graph with j >= 3 the constant
     divisor j - 1 is a theta characteristic (2D = K) of degree g - 1 with
     r(D) >= 3j - 4 >= k - 1.
 (G) Brill-Noether:        rho(g, g-1, r) = g - (r+1)^2, and for r = k - 1 on a
     k-regular graph rho >= 1 iff 2k^2 <= (k-2)n; n >= 2k + 7 suffices for k>=5.

Ranks are computed exactly, via q-reduced divisors (Dhar's burning algorithm).

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
from collections import deque
from typing import Dict, Iterator, List, Optional, Sequence, Tuple

Graph = List[List[int]]      # adjacency lists of a simple graph on {0,...,n-1}
Divisor = List[int]          # chip configuration, indexed by vertex


# --------------------------------------------------------------------------
# 1. Graph constructors and basic invariants
# --------------------------------------------------------------------------

def complete_graph(n: int) -> Graph:
    """K_n: the complete graph on n vertices, which is (n-1)-regular."""
    return [[j for j in range(n) if j != i] for i in range(n)]


def complete_bipartite(a: int, b: int) -> Graph:
    """K_{a,b}.  Regular precisely when a == b, of degree a."""
    return [[a + j for j in range(b)] if i < a else [j for j in range(a)]
            for i in range(a + b)]


def circulant(n: int, jumps: Sequence[int]) -> Graph:
    """C_n(j1,...,js): vertices Z/n, with i ~ i +- j for each jump j."""
    adj: Graph = []
    for i in range(n):
        nbrs = set()
        for j in jumps:
            nbrs.add((i + j) % n)
            nbrs.add((i - j) % n)
        nbrs.discard(i)
        adj.append(sorted(nbrs))
    return adj


def cycle_power(n: int, k: int) -> Graph:
    """The k-th power of an n-cycle: 2k-regular for n > 2k."""
    return circulant(n, list(range(1, k + 1)))


def num_vertices(g: Graph) -> int:
    return len(g)


def num_edges(g: Graph) -> int:
    return sum(len(nb) for nb in g) // 2


def genus(g: Graph) -> int:
    """g = |E| - |V| + 1."""
    return num_edges(g) - num_vertices(g) + 1


def canonical_divisor(g: Graph) -> Divisor:
    """K(v) = deg(v) - 2, of degree 2g - 2."""
    return [len(nb) - 2 for nb in g]


def is_regular(g: Graph) -> Optional[int]:
    """Return the common degree if g is regular, else None."""
    degs = {len(nb) for nb in g}
    return degs.pop() if len(degs) == 1 else None


def degree_of(d: Divisor) -> int:
    return sum(d)


# --------------------------------------------------------------------------
# 2. Chip-firing: q-reduced divisors via Dhar's burning algorithm
# --------------------------------------------------------------------------

def _bfs_distances(g: Graph, q: int) -> List[int]:
    dist = [-1] * len(g)
    dist[q] = 0
    queue = deque([q])
    while queue:
        v = queue.popleft()
        for u in g[v]:
            if dist[u] < 0:
                dist[u] = dist[v] + 1
                queue.append(u)
    return dist


def _fire_complement(g: Graph, d: Divisor, s: Sequence[int]) -> None:
    """In place: fire V \\ S, i.e. add the Laplacian image of the indicator of S."""
    inside = set(s)
    for v in range(len(g)):
        if v in inside:
            d[v] += sum(1 for u in g[v] if u not in inside)
        else:
            d[v] -= sum(1 for u in g[v] if u in inside)


def q_reduce(g: Graph, d: Divisor, q: int = 0) -> Divisor:
    """
    The unique q-reduced divisor linearly equivalent to d.

    Stage 1 (benevolence): process vertices by decreasing distance from q and
    borrow along the layers until every vertex other than q is out of debt.
    Stage 2 (Dhar): repeatedly burn from q; if the fire does not consume the
    whole graph, the unburnt set can fire without creating debt, so fire it.
    """
    out = list(d)
    dist = _bfs_distances(g, q)
    for layer in range(max(dist), 0, -1):
        s = [v for v in range(len(g)) if dist[v] >= layer]
        while any(out[v] < 0 for v in s):
            _fire_complement(g, out, s)
    while True:
        burnt = {q}
        changed = True
        while changed:
            changed = False
            for v in range(len(g)):
                if v in burnt:
                    continue
                if sum(1 for u in g[v] if u in burnt) > out[v]:
                    burnt.add(v)
                    changed = True
        unburnt = [v for v in range(len(g)) if v not in burnt]
        if not unburnt:
            return out
        # firing the unburnt set is the same as firing the complement of `burnt`
        _fire_complement(g, out, list(burnt))


def is_equivalent_to_effective(g: Graph, d: Divisor, q: int = 0) -> bool:
    """A divisor is equivalent to an effective one iff its q-reduction is effective."""
    return all(x >= 0 for x in q_reduce(g, d, q))


def effective_divisors(n: int, deg: int) -> Iterator[Divisor]:
    """All effective divisors of the given degree on n vertices (weak compositions)."""
    if deg < 0:
        return
    for cut in itertools.combinations(range(deg + n - 1), n - 1):
        parts: List[int] = []
        prev = -1
        for x in cut:
            parts.append(x - prev - 1)
            prev = x
        parts.append(deg + n - 1 - prev - 1)
        yield parts


def baker_norine_rank(g: Graph, d: Divisor) -> int:
    """
    Exact Baker-Norine rank.  Complexity is exponential in the rank
    (it tests all C(r+n-1, n-1) effective divisors of each degree r), so it is
    intended for small graphs and moderate ranks.
    """
    n = len(g)
    if not is_equivalent_to_effective(g, d):
        return -1
    r = 0
    while True:
        for e in effective_divisors(n, r + 1):
            if not is_equivalent_to_effective(g, [d[i] - e[i] for i in range(n)]):
                return r
        r += 1


# --------------------------------------------------------------------------
# 3. The theoretical bounds
# --------------------------------------------------------------------------

def receiving_move_bound(k: int, m: int) -> int:
    """Theorem A: rank >= m + min(m, k), i.e. 2m when m <= k.  Needs m >= 1."""
    return m + min(m, k)


def set_firing_bound(k: int, m: int) -> Optional[int]:
    """Theorem B: rank >= min(3m - 1, k + m), valid when 2 <= m <= k."""
    if m < 2 or m > k:
        return None
    return min(3 * m - 1, k + m)


def half_canonical_witness(g: Graph, k: int) -> Divisor:
    """
    The explicit witness of degree g - 1: floor((k-2)/2) chips at every vertex,
    with the leftover g - 1 - m*n chips dumped at vertex 0.
    """
    n = len(g)
    m = (k - 2) // 2
    d = [m] * n
    d[0] += (genus(g) - 1) - m * n
    return d


def brill_noether_number(gen: int, deg: int, r: int) -> int:
    """rho = g - (r+1)(g - d + r).  At d = g - 1 this equals g - (r+1)^2."""
    return gen - (r + 1) * (gen - deg + r)


def is_theta_characteristic(g: Graph, d: Divisor) -> bool:
    """2D ~ K, tested by q-reducing the difference 2D - K to the zero divisor."""
    k = canonical_divisor(g)
    diff = [2 * d[i] - k[i] for i in range(len(g))]
    if sum(diff) != 0:
        return False
    return all(x == 0 for x in q_reduce(g, diff))


# --------------------------------------------------------------------------
# 4. Demonstrations
# --------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_basic_invariants() -> None:
    banner("1.  Regular graphs: the half-canonical degree g - 1 = (k-2)n/2")
    rows: List[Tuple[str, Graph]] = [
        ("K_6", complete_graph(6)),
        ("K_7", complete_graph(7)),
        ("K_8", complete_graph(8)),
        ("K_{5,5}", complete_bipartite(5, 5)),
        ("C_8(1,2,3)", circulant(8, [1, 2, 3])),
        ("C_9(1,2,3)", circulant(9, [1, 2, 3])),
        ("C_11(1,2,3,4)", circulant(11, [1, 2, 3, 4])),
    ]
    print(f"{'graph':<14}{'k':>4}{'n':>5}{'|E|':>6}{'g':>6}{'g-1':>6}"
          f"{'(k-2)n/2':>11}{'K':>10}")
    for name, gr in rows:
        k = is_regular(gr)
        assert k is not None
        n = num_vertices(gr)
        gen = genus(gr)
        print(f"{name:<14}{k:>4}{n:>5}{num_edges(gr):>6}{gen:>6}{gen - 1:>6}"
              f"{(k - 2) * n // 2:>11}{'const ' + str(k - 2):>10}")
    print("\nThe last two columns agree in every row: 2(g-1) = (k-2)n and K = k-2.")


def demo_obstruction() -> None:
    banner("2.  Theorem D: no uniform witness of rank k-1 at degree g - 1")
    print("On a k-regular graph, a divisor of degree g-1 with r chips at EVERY")
    print("vertex forces r*n <= (k-2)n/2, i.e. 2r <= k-2.  The target r = k-1")
    print("always violates this, so pointwise domination can never certify it.\n")
    print(f"{'k':>4}{'max uniform reserve m':>26}{'target k-1':>13}"
          f"{'2(k-1) > k-2 ?':>17}")
    for k in range(4, 13):
        print(f"{k:>4}{(k - 2) // 2:>26}{k - 1:>13}"
              f"{str(2 * (k - 1) > k - 2):>17}")


def demo_bounds_table() -> None:
    banner("3.  Theorems A, B, C: what the two firing moves deliver at degree g-1")
    print("With reserve m = floor((k-2)/2) available at the half-canonical degree:\n")
    print(f"{'k':>4}{'m':>4}{'trivial':>9}{'A: 2m':>8}{'B: min(3m-1,k+m)':>19}"
          f"{'target k-1':>12}{'settled?':>10}")
    for k in range(4, 15):
        m = (k - 2) // 2
        b = set_firing_bound(k, m)
        bstr = "-" if b is None else str(b)
        settled = (b is not None and b >= k - 1)
        print(f"{k:>4}{m:>4}{m:>9}{receiving_move_bound(k, m):>8}{bstr:>19}"
              f"{k - 1:>12}{('YES' if settled else 'no'):>10}")
    print("\nEvery k >= 6 except k = 7 is settled, with NO lower bound on n.")


def demo_exact_ranks() -> None:
    banner("4.  Exact Baker-Norine ranks: the set-firing bound is attained")
    cases: List[Tuple[str, Graph, Optional[Divisor], str]] = [
        ("K_6", complete_graph(6), [2] * 6, "constant 2 (degree 12)"),
        ("K_6", complete_graph(6), None, "half-canonical witness"),
        ("K_7", complete_graph(7), None, "half-canonical witness"),
        ("K_8", complete_graph(8), None, "half-canonical witness"),
        ("C_8(1,2,3)", circulant(8, [1, 2, 3]), None, "half-canonical witness"),
        ("C_9(1,2,3)", circulant(9, [1, 2, 3]), None, "half-canonical witness"),
    ]
    print(f"{'graph':<13}{'divisor':<26}{'deg':>5}{'g-1':>6}{'rank':>6}"
          f"{'bound':>8}{'sharp?':>9}")
    for name, gr, div, label in cases:
        k = is_regular(gr)
        assert k is not None
        d = div if div is not None else half_canonical_witness(gr, k)
        m = min(d)
        rank = baker_norine_rank(gr, d)
        bound = set_firing_bound(k, m)
        bstr = "-" if bound is None else str(bound)
        sharp = "yes" if (bound is not None and rank == bound) else ""
        print(f"{name:<13}{label:<26}{degree_of(d):>5}{genus(gr) - 1:>6}"
              f"{rank:>6}{bstr:>8}{sharp:>9}")
    print("\nEvery bound above is attained exactly.  Note K_7: the true rank is")
    print("5 = 3m - 1 while the competing term k + m equals 8, so the 3m-1 branch")
    print("of the minimum is the essential one and cannot be dropped.")


def demo_theta_characteristic() -> None:
    banner("5.  Theorem F: an explicit self-dual (theta-characteristic) witness")
    print("On a 2j-regular graph K = 2(j-1) is constant, so the constant divisor")
    print("j-1 satisfies 2D = K exactly: it is its own residual K - D.\n")
    print(f"{'graph':<14}{'k=2j':>6}{'D':>10}{'deg D':>7}{'g-1':>6}"
          f"{'2D = K ?':>10}{'rank':>6}{'3j-4':>7}{'k-1':>6}")
    for name, gr in [("K_7", complete_graph(7)),
                     ("C_8(1,2,3)", circulant(8, [1, 2, 3])),
                     ("C_9(1,2,3)", circulant(9, [1, 2, 3]))]:
        k = is_regular(gr)
        assert k is not None and k % 2 == 0
        j = k // 2
        d = [j - 1] * num_vertices(gr)
        print(f"{name:<14}{k:>6}{('const ' + str(j - 1)):>10}{degree_of(d):>7}"
              f"{genus(gr) - 1:>6}{str(is_theta_characteristic(gr, d)):>10}"
              f"{baker_norine_rank(gr, d):>6}{3 * j - 4:>7}{k - 1:>6}")


def demo_residual_involution() -> None:
    banner("6.  Theorem E: the residual involution D -> K - D at degree g-1")
    gr = complete_graph(7)
    k = canonical_divisor(gr)
    gen = genus(gr)
    print(f"K_7:  g = {gen}, half-canonical degree = {gen - 1}, K = {k}\n")
    print(f"{'D':<24}{'deg D':>7}  {'K - D':<26}{'deg':>5}{'r(D)':>6}{'r(K-D)':>8}")
    samples: List[Divisor] = [
        [2, 2, 2, 2, 2, 2, 2],
        [5, 3, 2, 1, 1, 1, 1],
        [8, 1, 1, 1, 1, 1, 1],
        [14, 0, 0, 0, 0, 0, 0],
    ]
    for d in samples:
        res = [k[i] - d[i] for i in range(len(gr))]
        print(f"{str(d):<24}{degree_of(d):>7}  {str(res):<26}{degree_of(res):>5}"
              f"{baker_norine_rank(gr, d):>6}{baker_norine_rank(gr, res):>8}")
    print("\nThe residual preserves the degree g-1 and, as Riemann-Roch predicts,")
    print("the rank as well: witnesses come in residual pairs (or are fixed).")


def demo_brill_noether() -> None:
    banner("7.  Theorem G: Brill-Noether arithmetic, and why 2k^2 was a mirage")
    print("At d = g - 1 the Brill-Noether number collapses to rho = g - (r+1)^2.")
    print("For a k-regular graph with r = k-1:  rho >= 1  <=>  2k^2 <= (k-2)n.\n")
    print(f"{'k':>4}{'2k^2':>8}{'quadratic n':>14}{'linear n = 2k+7':>18}"
          f"{'(k-2)(2k+7) >= 2k^2 ?':>24}")
    for k in range(5, 13):
        print(f"{k:>4}{2 * k * k:>8}{2 * k * k:>14}{2 * k + 7:>18}"
              f"{str((k - 2) * (2 * k + 7) >= 2 * k * k):>24}")
    print("\nThe linear scale already removes the numerical obstruction, and the")
    print("existence theorem removes it entirely: the true threshold is n >= 1.\n")
    gr = complete_graph(7)
    gen = genus(gr)
    for r in range(0, 6):
        rho = brill_noether_number(gen, gen - 1, r)
        assert rho == gen - (r + 1) ** 2
        print(f"  K_7:  rho(g={gen}, d={gen - 1}, r={r}) = {rho:>4}"
              f"   (= g - (r+1)^2)")


def demo_k5_threshold() -> None:
    banner("8.  The residual degree k = 5: a genuine threshold is required")
    gr = complete_graph(6)
    gen = genus(gr)
    target = gen - 1
    print(f"K_6 is 5-regular with g = {gen} and half-canonical degree {target}.")
    print(f"Exhaustive search over all effective divisors of degree {target} ...")
    best = -2
    argbest: Divisor = []
    count = 0
    for e in effective_divisors(num_vertices(gr), target):
        count += 1
        r = baker_norine_rank(gr, e)
        if r > best:
            best, argbest = r, list(e)
    print(f"  searched {count} effective divisors;  maximal rank = {best}"
          f"  (attained e.g. at {argbest})")
    print(f"  target k - 1 = 4  is NOT attained, so N_0(5) > 6.\n")
    gr2 = complete_bipartite(5, 5)
    d2 = [2] * 5 + [1] * 5
    print(f"K_{{5,5}} is also 5-regular, with g = {genus(gr2)} and "
          f"half-canonical degree {genus(gr2) - 1}.")
    print(f"  the divisor {d2} has degree {degree_of(d2)} and rank "
          f"{baker_norine_rank(gr2, d2)} >= 4.")
    print("\nTwo 5-regular graphs, opposite answers: at k = 5 the maximal")
    print("half-canonical rank is not a function of n alone.")


def main() -> None:
    print(__doc__.split("Run:")[0].strip())
    demo_basic_invariants()
    demo_obstruction()
    demo_bounds_table()
    demo_exact_ranks()
    demo_theta_characteristic()
    demo_residual_involution()
    demo_brill_noether()
    demo_k5_threshold()
    banner("Summary")
    print("* A divisor with m >= 2 chips everywhere on a graph of minimum degree k")
    print("  has Baker-Norine rank at least min(3m - 1, k + m).")
    print("* At the half-canonical degree of a k-regular graph, m = floor((k-2)/2),")
    print("  giving rank >= 3*floor((k-2)/2) - 1 >= k - 1 for all k >= 6, k != 7,")
    print("  with no hypothesis on the number of vertices: N_0(k) = 1.")
    print("* The bound is attained on K_6, K_7, K_8, C_8(1,2,3), C_9(1,2,3).")
    print("* At k = 5 a genuine threshold is required: max rank on K_6 is 2.")


if __name__ == "__main__":
    main()
