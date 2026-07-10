"""
Quantum Error Correction from Homological Algebra: CSS Codes as Cohomology
==========================================================================

Numerical demonstrations of the correspondence between CSS quantum
error-correcting codes and the homology of chain complexes.

Central dictionary
------------------
A CSS code is a length-two chain complex  A --d2--> B --d1--> C  with
d1 . d2 = 0.  The physical qubits are a basis of B; the logical qubits are the
middle homology  H = ker(d1) / im(d2).  The two structural identities are:

    (Dimension formula)  k + rank(d1) + rank(d2) = dim(B)
    (Euler identity)     beta0 + dim(B) = dim(ker d1) + dim(C)

For a graph complex (d2 = 0) the logical count is the first Betti number
(circuit rank):  k = E - V + beta0.  For the connected hypercube Q_n this
gives the closed form  beta1(Q_n) = 2^(n-1) * (n - 2) + 1.

This file is self-contained: every routine is inlined and uses only the
standard library.  Arithmetic over F_2 is done with 0/1 integers modulo 2.
"""

from __future__ import annotations

from itertools import product
from typing import List, Tuple

Matrix = List[List[int]]  # a matrix over F_2, entries in {0, 1}


# ---------------------------------------------------------------------------
# Linear algebra over F_2
# ---------------------------------------------------------------------------
def rank_f2(matrix: Matrix) -> int:
    """Rank of a 0/1 matrix over the field F_2 via Gaussian elimination."""
    if not matrix or not matrix[0]:
        return 0
    rows = [row[:] for row in matrix]
    n_rows, n_cols = len(rows), len(rows[0])
    rank = 0
    pivot_col = 0
    for pivot_col in range(n_cols):
        pivot_row = None
        for r in range(rank, n_rows):
            if rows[r][pivot_col] == 1:
                pivot_row = r
                break
        if pivot_row is None:
            continue
        rows[rank], rows[pivot_row] = rows[pivot_row], rows[rank]
        for r in range(n_rows):
            if r != rank and rows[r][pivot_col] == 1:
                rows[r] = [(a ^ b) for a, b in zip(rows[r], rows[rank])]
        rank += 1
        if rank == n_rows:
            break
    return rank


def nullity_f2(matrix: Matrix, n_cols: int) -> int:
    """Dimension of the kernel of an F_2 matrix with `n_cols` columns."""
    return n_cols - rank_f2(matrix)


# ---------------------------------------------------------------------------
# CSS logical-qubit count from parity-check data (Theorem: dimension formula)
# ---------------------------------------------------------------------------
def num_logical_qubits(d1: Matrix, d2: Matrix, dim_B: int) -> int:
    """
    Number of logical qubits k = dim(B) - rank(d1) - rank(d2), where
    d1 : B -> C is the X-type check and d2 : A -> B has image = boundaries.
    Requires the chain condition d1 . d2 = 0 (checked by the caller).
    """
    return dim_B - rank_f2(d1) - rank_f2(d2)


def chain_condition_holds(d1: Matrix, d2: Matrix) -> bool:
    """Check d1 . d2 = 0 over F_2 (d1 is C-by-B, d2 is B-by-A)."""
    if not d2 or not d2[0]:
        return True  # d2 = 0
    n_c, n_b = len(d1), len(d1[0])
    n_b2, n_a = len(d2), len(d2[0])
    if n_b != n_b2:
        raise ValueError("d1 columns must match d2 rows")
    for i in range(n_c):
        for j in range(n_a):
            s = 0
            for m in range(n_b):
                s ^= (d1[i][m] & d2[m][j])
            if s != 0:
                return False
    return True


# ---------------------------------------------------------------------------
# Graph -> incidence matrix -> homological code (HQECC)
# ---------------------------------------------------------------------------
def incidence_matrix_f2(n_vertices: int, edges: List[Tuple[int, int]]) -> Matrix:
    """
    F_2 incidence matrix d1 of a graph: rows = vertices, columns = edges.
    Column e = (u, v) has 1 in rows u and v.
    """
    d1 = [[0] * len(edges) for _ in range(n_vertices)]
    for j, (u, v) in enumerate(edges):
        d1[u][j] ^= 1
        d1[v][j] ^= 1
    return d1


def connected_components(n_vertices: int, edges: List[Tuple[int, int]]) -> int:
    """Number of connected components (beta0) via union-find."""
    parent = list(range(n_vertices))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    for u, v in edges:
        ru, rv = find(u), find(v)
        if ru != rv:
            parent[ru] = rv
    return len({find(x) for x in range(n_vertices)})


def graph_code_logical(n_vertices: int, edges: List[Tuple[int, int]]) -> int:
    """
    Logical qubits of the homological code of a graph (d2 = 0):
    k = E - V + beta0 = first Betti number (circuit rank).
    """
    beta0 = connected_components(n_vertices, edges)
    return len(edges) - n_vertices + beta0


# ---------------------------------------------------------------------------
# Hypercube Q_n
# ---------------------------------------------------------------------------
def hypercube_edges(n: int) -> Tuple[int, List[Tuple[int, int]]]:
    """Vertices 0..2^n-1 (binary strings); edges join Hamming-distance-1 pairs."""
    n_vertices = 1 << n
    edges: List[Tuple[int, int]] = []
    for v in range(n_vertices):
        for bit in range(n):
            w = v ^ (1 << bit)
            if v < w:
                edges.append((v, w))
    return n_vertices, edges


def betti1_hypercube_closed(n: int) -> int:
    """Closed form beta1(Q_n) = 2^(n-1) * (n - 2) + 1 for n >= 1."""
    return (1 << (n - 1)) * (n - 2) + 1


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_dimension_formula() -> None:
    """Verify k = dim(B) - rank(d1) - rank(d2) on the repetition-type check."""
    print("=" * 68)
    print("DEMO 1  CSS dimension formula on a small explicit complex")
    print("=" * 68)
    # B = F_2^2, C = F_2 with d1(x, y) = x + y, and d2 = 0.
    d1 = [[1, 1]]          # C-by-B : maps (x,y) -> x+y
    d2 = [[0], [0]]        # B-by-A : the zero map (no 2-cells)
    dim_B = 2
    assert chain_condition_holds(d1, d2)
    k = num_logical_qubits(d1, d2, dim_B)
    print(f"  d1 = {d1}, d2 = 0, dim B = {dim_B}")
    print(f"  rank(d1) = {rank_f2(d1)}, rank(d2) = {rank_f2(d2)}")
    print(f"  logical qubits k = dim B - rank(d1) - rank(d2) = {k}")
    print(f"  (cycle space ker(d1) has dimension {nullity_f2(d1, dim_B)})")
    assert k == 1
    print("  OK: encodes 1 logical qubit, matching ker(d1).\n")


def demo_euler_identity() -> None:
    """Check beta0 + E = beta1 + V on several small graphs."""
    print("=" * 68)
    print("DEMO 2  Euler identity  V - E = beta0 - beta1  for graph codes")
    print("=" * 68)
    graphs = {
        "triangle (3-cycle)": (3, [(0, 1), (1, 2), (2, 0)]),
        "square (4-cycle)": (4, [(0, 1), (1, 2), (2, 3), (3, 0)]),
        "path P4 (tree)": (4, [(0, 1), (1, 2), (2, 3)]),
        "theta graph": (2, [(0, 1), (0, 1), (0, 1)]),  # 3 parallel edges
    }
    for name, (V, edges) in graphs.items():
        E = len(edges)
        beta0 = connected_components(V, edges)
        beta1 = graph_code_logical(V, edges)
        lhs, rhs = V - E, beta0 - beta1
        print(f"  {name:20s}: V={V}, E={E}, beta0={beta0}, "
              f"beta1(=k)={beta1}, V-E={lhs}, beta0-beta1={rhs}")
        assert lhs == rhs
    print("  OK: Euler identity holds in every case.\n")


def demo_hypercube_counts() -> None:
    """Compute HQECC(Q_n) logical qubits directly and via the closed form."""
    print("=" * 68)
    print("DEMO 3  Hypercube homological code HQECC(Q_n): the '1 qubit' myth")
    print("=" * 68)
    print(f"  {'n':>3} | {'V=2^n':>7} | {'E=n2^{n-1}':>10} | "
          f"{'direct k':>9} | {'closed form':>11}")
    print("  " + "-" * 52)
    for n in range(1, 9):
        V, edges = hypercube_edges(n)
        E = len(edges)
        k_direct = graph_code_logical(V, edges)
        k_closed = betti1_hypercube_closed(n)
        assert k_direct == k_closed
        print(f"  {n:>3} | {V:>7} | {E:>10} | {k_direct:>9} | {k_closed:>11}")
    print()
    print("  The '1 logical qubit' law holds ONLY at n = 2 (the 4-cycle).")
    for n, expected in ((4, 17), (6, 129), (8, 769)):
        assert betti1_hypercube_closed(n) == expected
    print("  Test cases: beta1(Q4)=17, beta1(Q6)=129, beta1(Q8)=769.  OK\n")


def demo_rate_formula() -> None:
    """Illustrate the combinatorial rate k/n = 1 - (V - beta0)/E."""
    print("=" * 68)
    print("DEMO 4  Code rate k/E = 1 - (V - beta0)/E for graph codes")
    print("=" * 68)
    for n in range(2, 9):
        V, edges = hypercube_edges(n)
        E = len(edges)
        beta0 = connected_components(V, edges)
        k = graph_code_logical(V, edges)
        rate = k / E
        pred = 1 - (V - beta0) / E
        assert abs(rate - pred) < 1e-12
        print(f"  Q_{n}: k={k:>4}, E={E:>5}, rate=k/E={rate:.4f} "
              f"= 1-(V-beta0)/E={pred:.4f}")
    print("  OK: rate matches the Euler-characteristic formula.\n")


if __name__ == "__main__":
    demo_dimension_formula()
    demo_euler_identity()
    demo_hypercube_counts()
    demo_rate_formula()
    print("All demonstrations completed successfully.")
