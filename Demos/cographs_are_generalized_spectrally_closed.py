"""
Numerical demonstrations for:

    "Cographs Are a Self-Complementary Hereditary Class:
     The Structural Foundation for Generalized Spectral Closure"

This self-contained script (standard library only) illustrates the paper's
main results on small graphs:

  1. P4 is self-complementary, via the explicit permutation 0 1 2 3 -> 1 3 0 2.
  2. The complement functor: an induced embedding transports to complements.
  3. Cographs are closed under complementation (Forb(P4) is self-complementary).
  4. The complement adjacency identity  A(G^c) = J - I - A(G).
  5. Generalized cospectrality and its closure under complementation.

Graphs are represented as (n, edges) where edges is a set of frozenset pairs.
"""

from __future__ import annotations

from itertools import combinations, permutations
from typing import Iterable

Edge = frozenset          # a frozenset of two distinct vertices
Graph = tuple[int, set[Edge]]  # (number_of_vertices, edge_set)


# --------------------------------------------------------------------------- #
# Basic graph utilities
# --------------------------------------------------------------------------- #
def make_graph(n: int, edge_list: Iterable[tuple[int, int]]) -> Graph:
    """Build a graph on vertices 0..n-1 from a list of edges."""
    edges = {frozenset((u, v)) for (u, v) in edge_list}
    return (n, edges)


def adjacent(g: Graph, u: int, v: int) -> bool:
    """True iff u and v are adjacent in g (u != v)."""
    return frozenset((u, v)) in g[1]


def complement(g: Graph) -> Graph:
    """Return the complement graph G^c on the same vertex set."""
    n, edges = g
    comp_edges = {
        frozenset((u, v))
        for u, v in combinations(range(n), 2)
        if frozenset((u, v)) not in edges
    }
    return (n, comp_edges)


def adjacency_matrix(g: Graph) -> list[list[int]]:
    """Return the n x n 0/1 adjacency matrix of g as a list of lists."""
    n, _ = g
    return [[1 if adjacent(g, i, j) else 0 for j in range(n)] for i in range(n)]


def path_graph(n: int) -> Graph:
    """The path P_n on vertices 0..n-1 with edges {i, i+1}."""
    return make_graph(n, [(i, i + 1) for i in range(n - 1)])


# --------------------------------------------------------------------------- #
# 1. Self-complementarity of P4
# --------------------------------------------------------------------------- #
def is_isomorphism(g: Graph, h: Graph, perm: list[int]) -> bool:
    """True iff `perm` (a list mapping vertex i -> perm[i]) is a graph
    isomorphism from g to h; requires same vertex count."""
    if g[0] != h[0] or sorted(perm) != list(range(g[0])):
        return False
    n = g[0]
    for u, v in combinations(range(n), 2):
        if adjacent(g, u, v) != adjacent(h, perm[u], perm[v]):
            return False
    return True


def demo_p4_self_complementary() -> None:
    print("=" * 70)
    print("1. P4 is self-complementary")
    print("=" * 70)
    p4 = path_graph(4)
    p4c = complement(p4)
    sigma = [1, 3, 0, 2]  # the explicit permutation from the paper
    print("  P4  edges:", sorted(tuple(sorted(e)) for e in p4[1]))
    print("  P4^c edges:", sorted(tuple(sorted(e)) for e in p4c[1]))
    ok = is_isomorphism(p4, p4c, sigma)
    print(f"  sigma = {sigma} is an isomorphism P4 -> P4^c : {ok}")
    assert ok


# --------------------------------------------------------------------------- #
# 2. Complement functor on induced embeddings
# --------------------------------------------------------------------------- #
def is_induced_embedding(f_graph: Graph, g: Graph, mapping: list[int]) -> bool:
    """True iff `mapping` is an induced embedding of f_graph into g:
    injective and preserving adjacency AND non-adjacency."""
    if len(set(mapping)) != len(mapping):
        return False  # not injective
    m = f_graph[0]
    for u, v in combinations(range(m), 2):
        if adjacent(f_graph, u, v) != adjacent(g, mapping[u], mapping[v]):
            return False
    return True


def find_induced_embedding(f_graph: Graph, g: Graph) -> list[int] | None:
    """Brute-force search for an induced embedding f_graph -> g."""
    m, n = f_graph[0], g[0]
    for mapping in permutations(range(n), m):
        if is_induced_embedding(f_graph, g, list(mapping)):
            return list(mapping)
    return None


def demo_complement_functor() -> None:
    print("=" * 70)
    print("2. Complement functor: same map embeds the complements")
    print("=" * 70)
    p4 = path_graph(4)
    # A graph on 5 vertices that contains an induced P4.
    g = make_graph(5, [(0, 1), (1, 2), (2, 3), (0, 4)])
    emb = find_induced_embedding(p4, g)
    print("  induced P4 in G via map:", emb)
    assert emb is not None
    # The SAME map is an induced embedding of the complements (Theorem 3.1).
    same_in_complements = is_induced_embedding(complement(p4), complement(g), emb)
    print("  same map embeds P4^c -> G^c :", same_in_complements)
    assert same_in_complements


# --------------------------------------------------------------------------- #
# 3. Cographs are closed under complementation
# --------------------------------------------------------------------------- #
def is_cograph(g: Graph) -> bool:
    """True iff g has no induced P4 (brute force over all 4-subsets)."""
    p4 = path_graph(4)
    n = g[0]
    for quad in combinations(range(n), 4):
        sub = induced_subgraph(g, quad)
        if find_induced_embedding(p4, sub) is not None:
            return False
    return True


def induced_subgraph(g: Graph, vertices: tuple[int, ...]) -> Graph:
    """Return the subgraph induced on the given vertex tuple, relabeled 0..k-1."""
    index = {v: i for i, v in enumerate(vertices)}
    edges = [
        (index[u], index[v])
        for u, v in combinations(vertices, 2)
        if adjacent(g, u, v)
    ]
    return make_graph(len(vertices), edges)


def demo_cograph_self_complementary() -> None:
    print("=" * 70)
    print("3. Forb(P4) is closed under complementation")
    print("=" * 70)
    examples: list[tuple[str, Graph]] = [
        ("K4 (complete)", make_graph(4, list(combinations(range(4), 2)))),
        ("P4 (a path, NOT a cograph)", path_graph(4)),
        ("C4 (4-cycle)", make_graph(4, [(0, 1), (1, 2), (2, 3), (3, 0)])),
        ("P5 (NOT a cograph)", path_graph(5)),
        ("star K_{1,4}", make_graph(5, [(0, 1), (0, 2), (0, 3), (0, 4)])),
    ]
    for name, g in examples:
        cg, cgc = is_cograph(g), is_cograph(complement(g))
        print(f"  {name:32s} cograph={cg!s:5s}  complement cograph={cgc!s:5s}")
        assert cg == cgc  # Theorem 5.2


# --------------------------------------------------------------------------- #
# 4. Complement adjacency identity  A(G^c) = J - I - A(G)
# --------------------------------------------------------------------------- #
def demo_complement_identity() -> None:
    print("=" * 70)
    print("4. Complement adjacency identity  A(G^c) = J - I - A(G)")
    print("=" * 70)
    g = make_graph(5, [(0, 1), (1, 2), (2, 3), (0, 4)])
    n = g[0]
    A = adjacency_matrix(g)
    Ac = adjacency_matrix(complement(g))
    JminusIminusA = [
        [(1 - (1 if i == j else 0) - A[i][j]) for j in range(n)] for i in range(n)
    ]
    print("  A(G^c)      =", Ac)
    print("  J - I - A(G) =", JminusIminusA)
    assert Ac == JminusIminusA  # Theorem 6.1


# --------------------------------------------------------------------------- #
# 5. Generalized cospectrality and its closure under complementation
# --------------------------------------------------------------------------- #
def char_poly_coeffs(mat: list[list[int]]) -> list[float]:
    """Coefficients of the characteristic polynomial via the Faddeev-LeVerrier
    algorithm (no external libraries). Returns [1, c1, c2, ..., cn]."""
    n = len(mat)
    M = [[0.0] * n for _ in range(n)]  # M_0 = 0
    coeffs = [1.0]
    A = [[float(x) for x in row] for row in mat]
    for k in range(1, n + 1):
        # M = A * M_prev + c_{k-1} * I
        AM = matmul(A, M)
        for i in range(n):
            AM[i][i] += coeffs[-1]
        M = AM
        trace_AM = sum(matmul(A, M)[i][i] for i in range(n))
        coeffs.append(-trace_AM / k)
    return coeffs


def matmul(X: list[list[float]], Y: list[list[float]]) -> list[list[float]]:
    n, m, p = len(X), len(Y), len(Y[0])
    return [[sum(X[i][k] * Y[k][j] for k in range(m)) for j in range(p)]
            for i in range(n)]


def spectrum_signature(g: Graph) -> tuple[float, ...]:
    """A rounded characteristic-polynomial signature (spectrum proxy)."""
    return tuple(round(c, 6) for c in char_poly_coeffs(adjacency_matrix(g)))


def generalized_cospectral(g: Graph, h: Graph) -> bool:
    """True iff g,h share adjacency AND complement characteristic polynomials."""
    return (
        spectrum_signature(g) == spectrum_signature(h)
        and spectrum_signature(complement(g)) == spectrum_signature(complement(h))
    )


def demo_generalized_cospectral() -> None:
    print("=" * 70)
    print("5. Generalized cospectrality and closure under complementation")
    print("=" * 70)
    g = make_graph(5, [(0, 1), (1, 2), (2, 3), (0, 4)])
    print("  A-spectrum signature   :", spectrum_signature(g))
    print("  A^c-spectrum signature :", spectrum_signature(complement(g)))
    print("  G generalized-cospectral with itself:", generalized_cospectral(g, g))
    # Closure (Theorem 6.4): if G ~ H then G^c ~ H^c. Here H = G, illustrating
    # that swapping the two spectra preserves the relation.
    print("  G^c generalized-cospectral with G^c:",
          generalized_cospectral(complement(g), complement(g)))
    assert generalized_cospectral(g, g)


# --------------------------------------------------------------------------- #
def main() -> None:
    demo_p4_self_complementary()
    print()
    demo_complement_functor()
    print()
    demo_cograph_self_complementary()
    print()
    demo_complement_identity()
    print()
    demo_generalized_cospectral()
    print()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
