"""Numerical demonstrations of oddomorphisms between finite graphs over GF(2).

An *oddomorphism* from a finite graph F to a finite graph G is a vertex map
phi : V(F) -> V(G) whose 0/1 function matrix M_phi intertwines the adjacency
matrices over the two-element field GF(2):

        A_F @ M_phi == M_phi @ A_G      (all arithmetic modulo 2).

Equivalently (local parity condition): for every vertex u of F and every vertex
a of G, the number of neighbours of u that phi sends to a is odd if and only if
phi(u) is adjacent to a in G.

This module is fully self-contained (standard library only). Every routine is
inlined and type-hinted. Running it reproduces the paper's key facts:

  * the identity map is an oddomorphism (reflexivity);
  * oddomorphisms compose (transitivity);
  * every graph isomorphism is an oddomorphism;
  * the folding map 2K2 -> K2 is a non-injective, surjective oddomorphism, while
    the constant map is NOT an oddomorphism;
  * function matrices are contravariantly functorial: M_phi @ M_psi = M_{psi.phi}.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Sequence, Set, Tuple

Matrix = List[List[int]]
Edge = Tuple[int, int]


# --------------------------------------------------------------------------- #
# GF(2) linear algebra                                                        #
# --------------------------------------------------------------------------- #
def mat_mul_gf2(a: Matrix, b: Matrix) -> Matrix:
    """Multiply two matrices over GF(2) (entries reduced modulo 2)."""
    rows, inner, cols = len(a), len(b), len(b[0])
    out: Matrix = [[0] * cols for _ in range(rows)]
    for i in range(rows):
        for k in range(inner):
            if a[i][k] & 1:
                row_b = b[k]
                out_i = out[i]
                for j in range(cols):
                    out_i[j] ^= row_b[j] & 1
    return out


def mat_eq(a: Matrix, b: Matrix) -> bool:
    """Test equality of two GF(2) matrices."""
    return all((x & 1) == (y & 1) for ra, rb in zip(a, b) for x, y in zip(ra, rb))


# --------------------------------------------------------------------------- #
# Graphs, adjacency matrices, function matrices                               #
# --------------------------------------------------------------------------- #
def adjacency_matrix(n: int, edges: Sequence[Edge]) -> Matrix:
    """Symmetric 0/1 adjacency matrix of a simple graph on vertices 0..n-1."""
    a: Matrix = [[0] * n for _ in range(n)]
    for u, v in edges:
        a[u][v] = 1
        a[v][u] = 1
    return a


def function_matrix(phi: Sequence[int], m: int) -> Matrix:
    """0/1 function matrix M_phi with M_phi[u][a] = 1 iff phi(u) = a.

    ``phi`` lists images of vertices 0..len(phi)-1; ``m`` is |V(G)|.
    """
    n = len(phi)
    mat: Matrix = [[0] * m for _ in range(n)]
    for u in range(n):
        mat[u][phi[u]] = 1
    return mat


# --------------------------------------------------------------------------- #
# The oddomorphism test (two equivalent forms)                                #
# --------------------------------------------------------------------------- #
def is_oddomorphism_matrix(a_f: Matrix, a_g: Matrix, phi: Sequence[int]) -> bool:
    """Matrix form: check A_F @ M_phi == M_phi @ A_G over GF(2)."""
    m = len(a_g)
    m_phi = function_matrix(phi, m)
    return mat_eq(mat_mul_gf2(a_f, m_phi), mat_mul_gf2(m_phi, a_g))


def is_oddomorphism_parity(
    n: int, edges_f: Sequence[Edge], m: int, edges_g: Sequence[Edge],
    phi: Sequence[int],
) -> bool:
    """Local-parity form: for all u, a, #{v ~ u : phi(v)=a} is odd iff phi(u) ~ a."""
    adj_f: List[Set[int]] = [set() for _ in range(n)]
    for u, v in edges_f:
        adj_f[u].add(v)
        adj_f[v].add(u)
    adj_g: Set[Edge] = set()
    for u, v in edges_g:
        adj_g.add((u, v))
        adj_g.add((v, u))
    for u in range(n):
        for a in range(m):
            count_odd = sum(1 for v in adj_f[u] if phi[v] == a) % 2 == 1
            edge_in_g = (phi[u], a) in adj_g
            if count_odd != edge_in_g:
                return False
    return True


def compose(psi: Sequence[int], phi: Sequence[int]) -> List[int]:
    """(psi . phi)(u) = psi(phi(u))."""
    return [psi[phi[u]] for u in range(len(phi))]


# --------------------------------------------------------------------------- #
# Enumeration utilities                                                       #
# --------------------------------------------------------------------------- #
def all_oddomorphisms(
    n: int, edges_f: Sequence[Edge], m: int, edges_g: Sequence[Edge],
) -> List[Tuple[int, ...]]:
    """Brute-force enumerate every oddomorphism F -> G."""
    a_f = adjacency_matrix(n, edges_f)
    a_g = adjacency_matrix(m, edges_g)
    return [phi for phi in product(range(m), repeat=n)
            if is_oddomorphism_matrix(a_f, a_g, list(phi))]


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_folding_map() -> None:
    """The folding map 2K2 -> K2 is a non-injective, surjective oddomorphism."""
    print("=" * 68)
    print("Demo 1: the folding map 2K2 -> K2")
    print("=" * 68)
    edges_f: List[Edge] = [(0, 1), (2, 3)]     # 2K2 on {0,1,2,3}
    edges_g: List[Edge] = [(0, 1)]             # K2 on {0,1}
    phi = [0, 1, 0, 1]                          # 0,2 -> 0 ; 1,3 -> 1
    ok_mat = is_oddomorphism_matrix(
        adjacency_matrix(4, edges_f), adjacency_matrix(2, edges_g), phi)
    ok_par = is_oddomorphism_parity(4, edges_f, 2, edges_g, phi)
    surjective = set(phi) == {0, 1}
    injective = len(set(phi)) == len(phi)
    print(f"  phi = {phi}")
    print(f"  oddomorphism (matrix form)  : {ok_mat}")
    print(f"  oddomorphism (parity form)  : {ok_par}")
    print(f"  surjective                  : {surjective}")
    print(f"  injective                   : {injective}  (expected False)")

    const = [0, 0, 0, 0]
    ok_const = is_oddomorphism_matrix(
        adjacency_matrix(4, edges_f), adjacency_matrix(2, edges_g), const)
    print(f"  constant map {const} oddomorphism? {ok_const}  (expected False)")


def demo_reflexive_transitive() -> None:
    """Identity is an oddomorphism and oddomorphisms compose."""
    print("=" * 68)
    print("Demo 2: reflexivity and transitivity (preorder)")
    print("=" * 68)
    # Path on 4 vertices 0-1-2-3.
    edges: List[Edge] = [(0, 1), (1, 2), (2, 3)]
    a = adjacency_matrix(4, edges)
    identity = [0, 1, 2, 3]
    print(f"  identity is an oddomorphism : "
          f"{is_oddomorphism_matrix(a, a, identity)}")

    # Two self-oddomorphisms composed: use the automorphism reversing the path.
    reverse = [3, 2, 1, 0]
    is_auto = is_oddomorphism_matrix(a, a, reverse)
    comp = compose(reverse, reverse)
    is_comp = is_oddomorphism_matrix(a, a, comp)
    print(f"  path-reversal is oddomorphism: {is_auto}")
    print(f"  reverse . reverse = {comp} oddomorphism? {is_comp}")


def demo_isomorphisms_are_oddomorphisms() -> None:
    """Every isomorphism (here, an automorphism of C4) is an oddomorphism."""
    print("=" * 68)
    print("Demo 3: isomorphisms are oddomorphisms")
    print("=" * 68)
    # 4-cycle C4: 0-1-2-3-0.
    edges: List[Edge] = [(0, 1), (1, 2), (2, 3), (3, 0)]
    a = adjacency_matrix(4, edges)
    autos = [
        [0, 1, 2, 3],  # identity
        [1, 2, 3, 0],  # rotation
        [0, 3, 2, 1],  # reflection
    ]
    for g in autos:
        print(f"  automorphism {g} oddomorphism? "
              f"{is_oddomorphism_matrix(a, a, g)}")


def demo_functoriality() -> None:
    """Function matrices are contravariantly functorial: M_phi M_psi = M_{psi.phi}."""
    print("=" * 68)
    print("Demo 4: functoriality  M_phi @ M_psi = M_{psi . phi}")
    print("=" * 68)
    phi = [0, 2, 1]         # V(F)={0,1,2} -> V(G)={0,1,2}
    psi = [1, 0, 1]         # V(G)={0,1,2} -> V(H)={0,1}
    lhs = mat_mul_gf2(function_matrix(phi, 3), function_matrix(psi, 2))
    rhs = function_matrix(compose(psi, phi), 2)
    print(f"  phi = {phi}, psi = {psi}, psi.phi = {compose(psi, phi)}")
    print(f"  M_phi @ M_psi == M_(psi.phi) : {mat_eq(lhs, rhs)}")


def demo_enumeration() -> None:
    """Count all oddomorphisms 2K2 -> K2 and K3 -> K3."""
    print("=" * 68)
    print("Demo 5: enumerating oddomorphisms")
    print("=" * 68)
    odd_2k2 = all_oddomorphisms(4, [(0, 1), (2, 3)], 2, [(0, 1)])
    print(f"  #oddomorphisms 2K2 -> K2 : {len(odd_2k2)}")
    for phi in odd_2k2:
        print(f"      {list(phi)}")

    k3_edges: List[Edge] = [(0, 1), (1, 2), (0, 2)]
    odd_k3 = all_oddomorphisms(3, k3_edges, 3, k3_edges)
    print(f"  #self-oddomorphisms of K3: {len(odd_k3)}  "
          f"(|Aut(K3)| = 6)")


def main() -> None:
    demo_folding_map()
    print()
    demo_reflexive_transitive()
    print()
    demo_isomorphisms_are_oddomorphisms()
    print()
    demo_functoriality()
    print()
    demo_enumeration()


if __name__ == "__main__":
    main()
