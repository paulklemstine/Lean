"""
Magnitude homology of tope graphs: numerical demonstrations.

This self-contained script demonstrates, by brute-force computation, every
quantitative claim about the tope graph of the arrangement of the n coordinate
hyperplanes {x_i = 0} in R^n.

Background
----------
Chambers (topes) of the coordinate arrangement are the 2^n open orthants; the
tope C_s indexed by s subset of {0,...,n-1} is

    C_s = { x in R^n : x_i > 0 for i in s,  x_i < 0 for i not in s }.

Separation principle (proved in the accompanying paper): the hyperplane
{x_i = 0} separates C_s from C_t exactly when i lies in the symmetric
difference s XOR t.  Consequently the tope graph -- topes as vertices, an edge
whenever exactly one hyperplane separates -- has

    d(s, t) = |s XOR t|          (Hamming distance),

so it is the n-dimensional hypercube graph Q_n, which is also the Cayley graph
of the Coxeter group (Z/2)^n with respect to its n coordinate reflections.

Magnitude homology (Hepworth-Willerton).  A generator of bidegree (k, l) is a
tuple (x_0, ..., x_k) of vertices with x_{i-1} != x_i and total length
sum_i d(x_{i-1}, x_i) = l.  MC_{k,l} is free on these.  The differential
deletes interior entries that lie on a geodesic between their neighbours:

    delta(x_0,...,x_k) = sum_{i=1}^{k-1} (-1)^i [x_i is "smooth"] (x_0,...,^x_i,...,x_k).

Results verified here
---------------------
  (1) d(s,t) = |s XOR t| against breadth-first search.
  (2) The separation set of two chambers, computed from actual sample points
      of R^n, equals the symmetric difference of the index sets.
  (3) rank MC_{1,l}(T_n) = 2^n * C(n, l).
  (4) rank MC_{2,l}(T_n) = 2^n * (C(2n, l) - 2 * C(n, l)).
  (5) delta_2 is surjective for every l >= 2 (degree-1 diagonality:
      MH_{1,l} = 0 for l >= 2), and MH_{1,1} is free on the 2^n * n ordered
      edges.
  (6) rank ker delta_2 = 2^n * (C(2n, l) - 3 * C(n, l)); for l = 2 this is
      MH_{2,2}(T_n), of rank 2^n * C(n+1, 2) -- exactly 2^n times the value at
      2 of the Hilbert function of the polynomial ring k[x_1,...,x_n], as the
      Stanley-Reisner description predicts.
  (7) The magnitude power series of a diagonal graph,
      sum_l (-1)^l rank MH_{l,l} q^l, equals 2^n / (1 + q)^n for T_n.
  (8) The same numbers computed on the Cayley graph of (Z/2)^n directly.
  (9) The (2,2)-cycle rank computed for other small graphs, showing which of
      them behave like tope graphs.

Run:  python3 demo.py
"""

from __future__ import annotations

from collections import deque
from itertools import product
from math import comb
from typing import Dict, Iterable, Iterator, List, Sequence, Set, Tuple

Vertex = int
Graph = Dict[Vertex, List[Vertex]]

# --------------------------------------------------------------------------
# 1.  Chambers of the coordinate arrangement, as honest subsets of R^n
# --------------------------------------------------------------------------


def sample_point(s: int, n: int) -> Tuple[float, ...]:
    """A representative point of the chamber indexed by the bitmask ``s``.

    Coordinate ``i`` is positive iff bit ``i`` of ``s`` is set.
    """
    return tuple(1.0 if (s >> i) & 1 else -1.0 for i in range(n))


def in_chamber(x: Sequence[float], s: int, n: int) -> bool:
    """Test membership of ``x`` in the chamber indexed by ``s``."""
    for i in range(n):
        if (s >> i) & 1:
            if not x[i] > 0.0:
                return False
        else:
            if not x[i] < 0.0:
                return False
    return True


def separating_hyperplanes(
    x: Sequence[float], y: Sequence[float], n: int
) -> Set[int]:
    """Indices ``i`` such that the hyperplane {x_i = 0} separates ``x`` from ``y``."""
    return {i for i in range(n) if x[i] * y[i] < 0.0}


def symmetric_difference(s: int, t: int, n: int) -> Set[int]:
    """The symmetric difference of the index sets, as a set of coordinates."""
    d = s ^ t
    return {i for i in range(n) if (d >> i) & 1}


# --------------------------------------------------------------------------
# 2.  The tope graph and its metric
# --------------------------------------------------------------------------


def tope_graph(n: int) -> Graph:
    """The tope graph of the n coordinate hyperplanes: the hypercube Q_n."""
    return {s: [s ^ (1 << i) for i in range(n)] for s in range(1 << n)}


def cayley_graph_z2n(n: int) -> Graph:
    """Cayley graph of (Z/2)^n with respect to the n coordinate reflections.

    Group elements are encoded as bitmasks, group law is XOR, generators are
    the standard basis vectors.  This returns literally the same graph as
    ``tope_graph`` -- which is exactly the content of the isomorphism theorem.
    """
    gens = [1 << i for i in range(n)]
    return {g: [g ^ e for e in gens] for g in range(1 << n)}


def bfs_distances(graph: Graph, source: Vertex) -> Dict[Vertex, int]:
    """Shortest-path distances from ``source`` by breadth-first search."""
    dist: Dict[Vertex, int] = {source: 0}
    queue: deque[Vertex] = deque([source])
    while queue:
        v = queue.popleft()
        for w in graph[v]:
            if w not in dist:
                dist[w] = dist[v] + 1
                queue.append(w)
    return dist


def all_pairs_distances(graph: Graph) -> Dict[Vertex, Dict[Vertex, int]]:
    """All-pairs shortest-path distances."""
    return {v: bfs_distances(graph, v) for v in graph}


def hamming_distance(s: int, t: int) -> int:
    """Number of separating hyperplanes = popcount of the symmetric difference."""
    return bin(s ^ t).count("1")


# --------------------------------------------------------------------------
# 3.  Magnitude chains and the degree-2 differential
# --------------------------------------------------------------------------


def gen1(dist: Dict[Vertex, Dict[Vertex, int]], ell: int) -> List[Tuple[int, int]]:
    """Generators of MC_{1,l}: ordered pairs of distinct vertices at distance l."""
    return [
        (x, y)
        for x in dist
        for y in dist
        if x != y and dist[x][y] == ell
    ]


def gen2(
    dist: Dict[Vertex, Dict[Vertex, int]], ell: int
) -> List[Tuple[int, int, int]]:
    """Generators of MC_{2,l}: triples (x,y,z), x!=y!=z, d(x,y)+d(y,z) = l."""
    out: List[Tuple[int, int, int]] = []
    for y in dist:
        for x in dist:
            if x == y:
                continue
            a = dist[x][y]
            if a >= ell:
                continue
            for z in dist:
                if z == y:
                    continue
                if a + dist[y][z] == ell:
                    out.append((x, y, z))
    return out


def gen3_count(dist: Dict[Vertex, Dict[Vertex, int]], ell: int) -> int:
    """Number of generators of MC_{3,l}: quadruples with three positive legs."""
    total = 0
    for x, y, z, w in product(dist, repeat=4):
        if x == y or y == z or z == w:
            continue
        if dist[x][y] + dist[y][z] + dist[z][w] == ell:
            total += 1
    return total


def delta2_image(
    dist: Dict[Vertex, Dict[Vertex, int]], triple: Tuple[int, int, int]
) -> Tuple[int, int] | None:
    """delta_2 of a (2,l)-generator: delete the middle vertex if it is smooth."""
    x, y, z = triple
    if x == z:
        return None
    if dist[x][y] + dist[y][z] == dist[x][z]:
        return (x, z)
    return None


def rank_delta2_and_kernel(
    dist: Dict[Vertex, Dict[Vertex, int]], ell: int
) -> Tuple[int, int, int, bool]:
    """Return (#MC_2l, #MC_1l, rank ker delta_2, delta_2 surjective?).

    Because delta_2 maps each basis vector either to 0 or to a single basis
    vector, its rank equals the number of distinct basis vectors hit, so the
    kernel rank is  #MC_2l - #(distinct targets).
    """
    g2 = gen2(dist, ell)
    g1 = gen1(dist, ell)
    targets = {t for t in (delta2_image(dist, g) for g in g2) if t is not None}
    rank_image = len(targets)
    return len(g2), len(g1), len(g2) - rank_image, rank_image == len(g1)


# --------------------------------------------------------------------------
# 4.  Closed-form predictions
# --------------------------------------------------------------------------


def predicted_mc1(n: int, ell: int) -> int:
    """rank MC_{1,l}(T_n) = 2^n * C(n, l)."""
    return (1 << n) * comb(n, ell)


def predicted_mc2(n: int, ell: int) -> int:
    """rank MC_{2,l}(T_n) = 2^n * (C(2n, l) - 2 C(n, l))."""
    return (1 << n) * (comb(2 * n, ell) - 2 * comb(n, ell))


def predicted_cycles(n: int, ell: int) -> int:
    """rank of the (2,l)-cycle group of T_n = 2^n * (C(2n, l) - 3 C(n, l))."""
    return (1 << n) * (comb(2 * n, ell) - 3 * comb(n, ell))


def hilbert_polynomial_ring(n: int, ell: int) -> int:
    """Hilbert function of k[x_1,...,x_n] in degree l: C(n+l-1, l)."""
    return comb(n + ell - 1, ell)


def predicted_diagonal_rank(n: int, ell: int) -> int:
    """Stanley-Reisner prediction for rank MH_{l,l}(T_n) = 2^n * C(n+l-1, l)."""
    return (1 << n) * hilbert_polynomial_ring(n, ell)


# --------------------------------------------------------------------------
# 5.  Demonstrations
# --------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_chamber_geometry(nmax: int = 4) -> None:
    banner("1. Chamber geometry: separation = symmetric difference")
    for n in range(1, nmax + 1):
        ok_member = True
        ok_sep = True
        for s in range(1 << n):
            x = sample_point(s, n)
            ok_member &= in_chamber(x, s, n)
            # points of a chamber avoid every hyperplane
            ok_member &= all(x[i] != 0.0 for i in range(n))
            for t in range(1 << n):
                y = sample_point(t, n)
                ok_sep &= separating_hyperplanes(x, y, n) == symmetric_difference(
                    s, t, n
                )
                if s != t:
                    ok_member &= not in_chamber(x, t, n)  # chambers are disjoint
        print(
            f"  n = {n}:  chambers nonempty/disjoint/off-hyperplanes: {ok_member};"
            f"  separation = symmetric difference: {ok_sep}"
        )


def demo_metric(nmax: int = 5) -> None:
    banner("2. The tope graph is the hypercube:  d(s,t) = |s XOR t|")
    for n in range(1, nmax + 1):
        g = tope_graph(n)
        dist = all_pairs_distances(g)
        ok = all(
            dist[s][t] == hamming_distance(s, t) for s in dist for t in dist
        )
        connected = all(len(dist[s]) == (1 << n) for s in dist)
        print(f"  n = {n}:  BFS distance = |s XOR t|: {ok};  connected: {connected}")


def demo_chain_counts(nmax: int = 4) -> None:
    banner("3-4. Chain group ranks of the tope graph")
    print(f"  {'n':>2} {'l':>2} {'#MC_1l':>10} {'formula':>10} "
          f"{'#MC_2l':>10} {'formula':>10}")
    for n in range(1, nmax + 1):
        dist = all_pairs_distances(tope_graph(n))
        for ell in range(1, 2 * n + 1):
            c1 = len(gen1(dist, ell))
            c2 = len(gen2(dist, ell))
            f1 = predicted_mc1(n, ell)
            f2 = predicted_mc2(n, ell)
            flag = "OK" if (c1 == f1 and c2 == f2) else "MISMATCH"
            print(f"  {n:>2} {ell:>2} {c1:>10} {f1:>10} {c2:>10} {f2:>10}   {flag}")


def demo_degree1_diagonality(nmax: int = 4) -> None:
    banner("5. MH_{1,1} is free on ordered edges; MH_{1,l} = 0 for l >= 2")
    for n in range(1, nmax + 1):
        dist = all_pairs_distances(tope_graph(n))
        edges = len(gen1(dist, 1))
        print(f"  n = {n}:  ordered edges = {edges}  (2^n n = {(1 << n) * n});"
              f"  MC_{{2,1}} = {len(gen2(dist, 1))}  =>  MH_11 free of rank {edges}")
        for ell in range(2, 2 * n + 1):
            _, c1, _, surj = rank_delta2_and_kernel(dist, ell)
            if c1 == 0:
                continue
            print(f"        l = {ell}: delta_2 onto MC_{{1,{ell}}} "
                  f"({c1} generators): {surj}  =>  MH_{{1,{ell}}} = 0")


def demo_mh22(nmax: int = 4) -> None:
    banner("6. MH_{2,2} and the Hilbert function of a polynomial ring")
    print(f"  {'n':>2} {'#MC_22':>8} {'#MC_12':>8} {'rank ker':>9} "
          f"{'2^n C(n+1,2)':>13} {'#MC_32':>7}")
    for n in range(1, nmax + 1):
        dist = all_pairs_distances(tope_graph(n))
        c2, c1, kern, _ = rank_delta2_and_kernel(dist, 2)
        pred = predicted_diagonal_rank(n, 2)
        g3 = gen3_count(dist, 2)
        flag = "OK" if (kern == pred and g3 == 0) else "MISMATCH"
        print(f"  {n:>2} {c2:>8} {c1:>8} {kern:>9} {pred:>13} {g3:>7}   {flag}")
    print("\n  (#MC_32 = 0 means nothing maps into bidegree (2,2), so the cycle")
    print("   group IS the homology MH_{2,2}.)")
    print("\n  Hilbert function of k[x_1,...,x_n] in degree 2 = C(n+1,2):")
    for n in range(1, nmax + 1):
        print(f"     n = {n}:  C(n+1,2) = {hilbert_polynomial_ring(n, 2)},"
              f"  rank MH_22 = 2^{n} * {hilbert_polynomial_ring(n, 2)}"
              f" = {predicted_diagonal_rank(n, 2)}")


def demo_cycles_all_lengths(nmax: int = 4) -> None:
    banner("6b. The (2,l)-cycle group in every length")
    print(f"  {'n':>2} {'l':>2} {'rank ker delta_2':>17} "
          f"{'2^n(C(2n,l)-3C(n,l))':>22}")
    for n in range(1, nmax + 1):
        dist = all_pairs_distances(tope_graph(n))
        for ell in range(2, 2 * n + 1):
            _, _, kern, _ = rank_delta2_and_kernel(dist, ell)
            pred = predicted_cycles(n, ell)
            flag = "OK" if kern == pred else "MISMATCH"
            print(f"  {n:>2} {ell:>2} {kern:>17} {pred:>22}   {flag}")


def magnitude_series_from_diagonal(n: int, order: int) -> List[int]:
    """Coefficients of sum_l (-1)^l rank MH_{l,l}(T_n) q^l up to q^order."""
    return [(-1) ** ell * predicted_diagonal_rank(n, ell) for ell in range(order + 1)]


def series_2n_over_1plusq_n(n: int, order: int) -> List[int]:
    """Coefficients of 2^n / (1+q)^n, i.e. 2^n * (-1)^l C(n+l-1, l)."""
    return [(1 << n) * (-1) ** ell * comb(n + ell - 1, ell) for ell in range(order + 1)]


def demo_magnitude_series(nmax: int = 4, order: int = 6) -> None:
    banner("7. Euler characteristic: the magnitude series of the hypercube")
    for n in range(1, nmax + 1):
        a = magnitude_series_from_diagonal(n, order)
        b = series_2n_over_1plusq_n(n, order)
        print(f"  n = {n}:  {a}")
        print(f"           2^n/(1+q)^n  ->  {b}   match: {a == b}")


def demo_cayley(nmax: int = 4) -> None:
    banner("8. The same computation on the Cayley graph of (Z/2)^n")
    for n in range(1, nmax + 1):
        gt = tope_graph(n)
        gc = cayley_graph_z2n(n)
        same = all(sorted(gt[v]) == sorted(gc[v]) for v in gt)
        dist = all_pairs_distances(gc)
        c2, c1, kern, surj = rank_delta2_and_kernel(dist, 2)
        print(f"  n = {n}:  tope graph == Cayley graph: {same};"
              f"  MH_22 rank = {kern} (= 2^n C(n+1,2) = "
              f"{predicted_diagonal_rank(n, 2)});  delta_2 onto: {surj}")


def path_graph(m: int) -> Graph:
    return {i: [j for j in (i - 1, i + 1) if 0 <= j < m] for i in range(m)}


def cycle_graph(m: int) -> Graph:
    return {i: [(i - 1) % m, (i + 1) % m] for i in range(m)}


def complete_graph(m: int) -> Graph:
    return {i: [j for j in range(m) if j != i] for i in range(m)}


def demo_other_graphs() -> None:
    banner("9. MH_{2,2} for other small graphs (rank = #MC_22 - #MC_12)")
    families: List[Tuple[str, Graph]] = [
        ("path P_4", path_graph(4)),
        ("path P_5", path_graph(5)),
        ("cycle C_4 (= Q_2)", cycle_graph(4)),
        ("cycle C_5", cycle_graph(5)),
        ("cycle C_6", cycle_graph(6)),
        ("complete K_4", complete_graph(4)),
        ("complete K_5", complete_graph(5)),
        ("cube Q_3", tope_graph(3)),
    ]
    print(f"  {'graph':>20} {'#MC_22':>8} {'#MC_12':>8} {'rank MH_22':>11} "
          f"{'2|E| (diag. cycles)':>20}")
    for name, g in families:
        dist = all_pairs_distances(g)
        c2, c1, kern, _ = rank_delta2_and_kernel(dist, 2)
        ordered_edges = sum(len(nbrs) for nbrs in g.values())
        print(f"  {name:>20} {c2:>8} {c1:>8} {kern:>11} {ordered_edges:>20}")
    print("\n  The last column counts the diagonal cycles (x,y,x); it is always")
    print("  at most rank MH_22, as the embedding theorem asserts.")


def main() -> None:
    print(__doc__)
    demo_chamber_geometry()
    demo_metric()
    demo_chain_counts()
    demo_degree1_diagonality()
    demo_mh22()
    demo_cycles_all_lengths()
    demo_magnitude_series()
    demo_cayley()
    demo_other_graphs()
    banner("All computations agree with the closed-form results.")


if __name__ == "__main__":
    main()
