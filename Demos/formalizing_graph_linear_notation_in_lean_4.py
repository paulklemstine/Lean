"""
Graph Linear Notation (gln): a complete numeric invariant for finite simple graphs.

This self-contained script demonstrates the mathematics formalized in Lean:

    * adjCode(G)  -- read the adjacency matrix as a base-2 integer.
    * permuteGraph(sigma, G) -- relabel vertices by a permutation.
    * gln(G)      -- the MAXIMUM adjacency code over all relabelings.

Main verified facts demonstrated numerically:
    1. adjCode is injective on labeled graphs.
    2. gln is invariant under isomorphism:    G ~= H  =>  gln(G) == gln(H).
    3. gln is complete:                       gln(G) == gln(H)  =>  G ~= H.
    Together:  gln(G) == gln(H)  <=>  G is isomorphic to H   (gln_eq_iff_iso).
    4. The number of distinct gln values on n vertices equals A000088(n),
       the number of graphs up to isomorphism.

Everything is inlined; only the Python standard library is used.
"""

from __future__ import annotations

from itertools import combinations, permutations, product
from typing import Dict, List, Sequence, Set, Tuple

# A graph on {0,...,n-1} is represented as an n x n tuple-of-tuples of 0/1 bits,
# symmetric with zero diagonal (simple graph).
Matrix = Tuple[Tuple[int, ...], ...]
Perm = Tuple[int, ...]


def adj_bit(g: Matrix, i: int, j: int) -> int:
    """The adjacency bit a_{ij}: 1 if i~j, else 0  (Definition: adjBit)."""
    return 1 if g[i][j] else 0


def adj_code(g: Matrix) -> int:
    """
    Read the adjacency matrix row-major as a base-2 integer (Definition: adjCode):

        adjCode(G) = sum_{i,j} a_{ij} * 2^(i*n + j).

    The cell (i, j) occupies the distinct bit position i*n + j, so the map is
    injective (Theorem: adjCode_injective).
    """
    n = len(g)
    code = 0
    for i in range(n):
        for j in range(n):
            if g[i][j]:
                code += 1 << (i * n + j)
    return code


def permute_graph(sigma: Perm, g: Matrix) -> Matrix:
    """
    Relabel G by sigma (Definition: permuteGraph / comap):

        (permuteGraph sigma G).Adj i j  <=>  G.Adj (sigma i) (sigma j).
    """
    n = len(g)
    return tuple(tuple(g[sigma[i]][sigma[j]] for j in range(n)) for i in range(n))


def gln(g: Matrix) -> int:
    """
    Graph linear notation (Definition: gln): the MAXIMUM adjacency code over all
    n! relabelings. This brute-force computation is faithful to the definition.
    """
    n = len(g)
    return max(adj_code(permute_graph(sigma, g)) for sigma in permutations(range(n)))


def gln_argmax(g: Matrix) -> Tuple[int, Perm]:
    """Return (gln(G), a maximizing permutation)  (witness of gln_attained)."""
    n = len(g)
    best_code = -1
    best_perm: Perm = tuple(range(n))
    for sigma in permutations(range(n)):
        c = adj_code(permute_graph(sigma, g))
        if c > best_code:
            best_code, best_perm = c, sigma
    return best_code, best_perm


def is_graph_iso(g: Matrix, h: Matrix) -> bool:
    """Direct isomorphism test: exists sigma with G.Adj i j <=> H.Adj (s i)(s j)."""
    n = len(g)
    if len(h) != n:
        return False
    for sigma in permutations(range(n)):
        if all(g[i][j] == h[sigma[i]][sigma[j]] for i in range(n) for j in range(n)):
            return True
    return False


def all_graphs(n: int) -> List[Matrix]:
    """Enumerate all 2^(C(n,2)) labeled simple graphs on {0,...,n-1}."""
    pairs = list(combinations(range(n), 2))
    graphs: List[Matrix] = []
    for bits in product((0, 1), repeat=len(pairs)):
        m = [[0] * n for _ in range(n)]
        for (i, j), b in zip(pairs, bits):
            m[i][j] = m[j][i] = b
        graphs.append(tuple(tuple(row) for row in m))
    return graphs


def empty_and_edge_two_vertices() -> None:
    """The worked example on 2 vertices: empty -> gln 0, single edge -> gln 6."""
    empty: Matrix = ((0, 0), (0, 0))
    edge: Matrix = ((0, 1), (1, 0))
    print("=== Worked example: graphs on 2 vertices ===")
    print(f"  empty graph : adjCode = {adj_code(empty)}, gln = {gln(empty)}")
    print(f"  single edge : adjCode = {adj_code(edge)}, gln = {gln(edge)}")
    print(f"  distinct notations -> {len({gln(empty), gln(edge)})} graphs up to iso\n")


def demonstrate_injectivity(n: int) -> None:
    """adjCode_injective: distinct labeled graphs get distinct codes."""
    graphs = all_graphs(n)
    codes = [adj_code(g) for g in graphs]
    print(f"=== adjCode injectivity on n={n} ({len(graphs)} labeled graphs) ===")
    print(f"  distinct codes = {len(set(codes))} (expected {len(graphs)}): "
          f"{'INJECTIVE' if len(set(codes)) == len(graphs) else 'COLLISION!'}\n")


def demonstrate_complete_invariant(n: int) -> None:
    """
    gln_eq_iff_iso: for all pairs, (gln(G)==gln(H)) <=> isomorphic(G,H).
    We check this equivalence over ALL labeled pairs on n vertices.
    """
    graphs = all_graphs(n)
    ok = True
    for g in graphs:
        for h in graphs:
            if (gln(g) == gln(h)) != is_graph_iso(g, h):
                ok = False
    print(f"=== gln complete invariant on n={n} ===")
    print(f"  (gln G == gln H) <=> (G ~= H) for all pairs: "
          f"{'VERIFIED' if ok else 'FAILED'}\n")


def count_iso_classes(n: int) -> int:
    """Number of distinct gln values = number of graphs up to isomorphism."""
    return len({gln(g) for g in all_graphs(n)})


def demonstrate_enumeration(max_n: int) -> None:
    """The image-size of gln reproduces A000088: 1,1,2,4,11,34,...."""
    a000088 = {0: 1, 1: 1, 2: 2, 3: 4, 4: 11, 5: 34}
    print("=== Counting graphs up to isomorphism via |image(gln)| (A000088) ===")
    for n in range(max_n + 1):
        got = count_iso_classes(n)
        expected = a000088.get(n)
        tag = "OK" if expected is None or got == expected else "MISMATCH"
        print(f"  n={n}: distinct gln values = {got:>3}  "
              f"(A000088 = {expected})  [{tag}]")
    print()


def demonstrate_canonical_form(n: int) -> None:
    """Show the maximizing permutation (canonical labeling) for a sample graph."""
    print(f"=== Canonical labeling (gln_attained) on n={n} ===")
    # A path 0-1-2 (when n>=3): edges (0,1) and (1,2).
    m = [[0] * n for _ in range(n)]
    if n >= 3:
        for i, j in [(0, 1), (1, 2)]:
            m[i][j] = m[j][i] = 1
    g: Matrix = tuple(tuple(row) for row in m)
    value, sigma = gln_argmax(g)
    canon = permute_graph(sigma, g)
    print(f"  original adjCode = {adj_code(g)}")
    print(f"  gln              = {value}  via permutation {sigma}")
    print(f"  canonical matrix = {canon}\n")


def main() -> None:
    empty_and_edge_two_vertices()
    demonstrate_injectivity(3)
    demonstrate_canonical_form(3)
    demonstrate_complete_invariant(3)
    demonstrate_enumeration(5)


if __name__ == "__main__":
    main()
