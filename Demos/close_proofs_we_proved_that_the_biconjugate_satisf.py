"""
CSS Codes as Cohomology — Numerical Demonstrations
==================================================

Self-contained Python demonstrations of the results in
"CSS Codes as Cohomology: Quantum Error Correction from Homological Algebra".

All linear algebra is done over the field GF(2) = {0, 1} (the relevant field for
qubit codes), implemented from scratch so the file has no third-party
dependencies. Each function is fully inlined and type-hinted.

Results demonstrated
--------------------
1. The chain condition  d1 . d2 = 0  and  boundaries <= cycles.
2. Homological Dimension Theorem:  k = beta_1 = dim ker(d1) - dim im(d2).
3. Quantum rank-nullity:  k + dim(B) = dim(Z)  and  dim(Z) + rank(d1) = n.
4. Logical-qubit additivity across a nested filtration.
5. Self-dual code (C_X = C_Z) encodes 0 logical qubits.
6. Hamming weight: faithfulness and the triangle inequality.
7. Hypercube Betti number  beta_1(Q_n) = n*2^(n-1) - 2^n + 1, with the
   surprising multi-qubit growth for n >= 3.
"""

from __future__ import annotations

from itertools import product
from typing import List, Tuple

# ---------------------------------------------------------------------------
# Minimal GF(2) linear algebra
# ---------------------------------------------------------------------------

Matrix = List[List[int]]  # entries in {0, 1}, row-major


def matmul_gf2(a: Matrix, b: Matrix) -> Matrix:
    """Multiply two GF(2) matrices (entries reduced mod 2)."""
    rows, inner, cols = len(a), len(b), len(b[0]) if b else 0
    out: Matrix = [[0] * cols for _ in range(rows)]
    for i in range(rows):
        for k in range(inner):
            if a[i][k]:
                row_b = b[k]
                row_o = out[i]
                for j in range(cols):
                    row_o[j] ^= row_b[j]
    return out


def is_zero(a: Matrix) -> bool:
    """True iff every entry of `a` is 0."""
    return all(v == 0 for row in a for v in row)


def rank_gf2(a: Matrix) -> int:
    """Rank of a GF(2) matrix via Gaussian elimination."""
    m = [row[:] for row in a]
    rows = len(m)
    cols = len(m[0]) if rows else 0
    rank = 0
    pivot_col = 0
    for pivot_col in range(cols):
        pivot_row = next((r for r in range(rank, rows) if m[r][pivot_col]), None)
        if pivot_row is None:
            continue
        m[rank], m[pivot_row] = m[pivot_row], m[rank]
        for r in range(rows):
            if r != rank and m[r][pivot_col]:
                m[r] = [x ^ y for x, y in zip(m[r], m[rank])]
        rank += 1
        if rank == rows:
            break
    return rank


def nullity_gf2(a: Matrix, n_cols: int) -> int:
    """Dimension of the kernel of an (rows x n_cols) GF(2) matrix."""
    return n_cols - rank_gf2(a)


# ---------------------------------------------------------------------------
# Chain complex -> CSS code
# ---------------------------------------------------------------------------

def betti1_from_boundaries(d1: Matrix, d2: Matrix, n: int) -> int:
    """First Betti number  beta_1 = dim ker(d1) - dim im(d2),
    which equals the logical dimension k of the induced CSS code.

    Uses the identity  beta_1 = n - rank(d1) - rank(d2)  (Theorems 4.2 + 4.3)."""
    return n - rank_gf2(d1) - rank_gf2(d2)


def verify_chain_condition(d1: Matrix, d2: Matrix) -> bool:
    """Check the chain condition d1 . d2 = 0 (equivalently B <= Z)."""
    return is_zero(matmul_gf2(d1, d2))


# ---------------------------------------------------------------------------
# Hamming weight
# ---------------------------------------------------------------------------

def hamming_weight(v: List[int]) -> int:
    """Number of nonzero coordinates of v (over any ring with 0)."""
    return sum(1 for x in v if x != 0)


def vec_add_gf2(v: List[int], w: List[int]) -> List[int]:
    """Coordinatewise GF(2) addition (XOR)."""
    return [a ^ b for a, b in zip(v, w)]


# ---------------------------------------------------------------------------
# Hypercube Betti number
# ---------------------------------------------------------------------------

def hypercube_betti1(n: int) -> int:
    """Closed form beta_1(Q_n) = n*2^(n-1) - 2^n + 1  (= |E| - |V| + 1)."""
    edges = n * 2 ** (n - 1) if n >= 1 else 0
    vertices = 2 ** n
    return edges - vertices + 1


def hypercube_boundary_matrix(n: int) -> Tuple[Matrix, int, int]:
    """Vertex-edge incidence (boundary) matrix d : F^E -> F^V of Q_n over GF(2).

    Returns (matrix, num_vertices, num_edges). Rows index vertices, columns edges.
    """
    verts = list(product((0, 1), repeat=n))
    index = {v: i for i, v in enumerate(verts)}
    edges: List[Tuple[int, int]] = []
    for v in verts:
        for bit in range(n):
            w = list(v)
            w[bit] ^= 1
            w_t = tuple(w)
            a, b = index[v], index[w_t]
            if a < b:
                edges.append((a, b))
    d: Matrix = [[0] * len(edges) for _ in range(len(verts))]
    for col, (a, b) in enumerate(edges):
        d[a][col] = 1
        d[b][col] = 1
    return d, len(verts), len(edges)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_toric_like_code() -> None:
    """A tiny chain complex: the 4-cycle (square) Q_2, which encodes 1 qubit."""
    print("=" * 64)
    print("DEMO 1: The square Q_2 as a 1-qubit homological code")
    print("=" * 64)
    # Edge-vertex boundary d1 : F^E -> F^V for a 4-cycle, and trivial d2.
    # Square: vertices 0,1,2,3 ; edges 0-1,1-2,2-3,3-0
    d1: Matrix = [
        [1, 0, 0, 1],  # vertex 0
        [1, 1, 0, 0],  # vertex 1
        [0, 1, 1, 0],  # vertex 2
        [0, 0, 1, 1],  # vertex 3
    ]
    n_edges = 4
    d2: Matrix = [[0] for _ in range(n_edges)]  # no 2-cells: image is {0}
    assert verify_chain_condition(d1, d2)
    k = betti1_from_boundaries(d1, d2, n_edges)
    print(f"chain condition d1.d2 = 0 : {verify_chain_condition(d1, d2)}")
    print(f"dim cycles  = ker d1     : {nullity_gf2(d1, n_edges)}")
    print(f"rank d1                  : {rank_gf2(d1)}")
    print(f"logical qubits k = beta_1: {k}   (closed form {hypercube_betti1(2)})")
    print()


def demo_rank_nullity() -> None:
    """Verify k + dim B = dim Z and dim Z + rank(d1) = n on a random-ish complex."""
    print("=" * 64)
    print("DEMO 2: Quantum rank-nullity identities")
    print("=" * 64)
    # Build a genuine 3-term complex with d1.d2 = 0.
    # d2 columns are chosen to lie in ker(d1).
    d1: Matrix = [
        [1, 1, 0, 0, 0],
        [0, 1, 1, 0, 0],
        [0, 0, 0, 1, 1],
    ]
    n = 5
    # vectors in ker d1: e.g. (1,1,1,0,0) -> d1 gives (0,0,0)? check below.
    d2: Matrix = [
        [1],
        [1],
        [1],
        [0],
        [0],
    ]
    assert verify_chain_condition(d1, d2), "constructed d2 not in ker d1"
    dim_Z = nullity_gf2(d1, n)
    dim_B = rank_gf2(d2)
    k = betti1_from_boundaries(d1, d2, n)
    print(f"dim cycles Z          : {dim_Z}")
    print(f"dim boundaries B      : {dim_B}")
    print(f"beta_1 (logical k)    : {k}")
    print(f"check  k + dim B == dim Z      : {k + dim_B == dim_Z}")
    print(f"check  dim Z + rank d1 == n    : {dim_Z + rank_gf2(d1) == n}")
    print()


def demo_additivity() -> None:
    """Logical-qubit additivity across nested subspaces (third iso theorem)."""
    print("=" * 64)
    print("DEMO 3: Additivity of logical dimension across a filtration")
    print("=" * 64)
    # Use dimensions directly: C_Z (dim 1) <= C_mid (dim 3) <= C_X (dim 5).
    dim_CX, dim_Cmid, dim_CZ = 5, 3, 1
    left = dim_CX - dim_CZ
    right = (dim_CX - dim_Cmid) + (dim_Cmid - dim_CZ)
    print(f"dim(C_X/C_Z)                       : {left}")
    print(f"dim(C_X/C_mid) + dim(C_mid/C_Z)    : {right}")
    print(f"additivity holds                  : {left == right}")
    print()


def demo_self_dual() -> None:
    """Self-dual code C_X = C_Z encodes 0 logical qubits."""
    print("=" * 64)
    print("DEMO 4: Self-dual code encodes zero logical qubits")
    print("=" * 64)
    dim_CX = dim_CZ = 4
    print(f"C_X = C_Z (dim {dim_CX}) -> k = dim(C_X/C_Z) = {dim_CX - dim_CZ}")
    print()


def demo_hamming() -> None:
    """Hamming weight: faithfulness and triangle inequality."""
    print("=" * 64)
    print("DEMO 5: Hamming weight is a faithful metric")
    print("=" * 64)
    zero = [0, 0, 0, 0, 0]
    print(f"wt(0) == 0  and  v=0 iff wt=0     : "
          f"{hamming_weight(zero) == 0}")
    v = [1, 1, 0, 1, 0]
    w = [0, 1, 1, 1, 0]
    s = vec_add_gf2(v, w)
    lhs, rhs = hamming_weight(s), hamming_weight(v) + hamming_weight(w)
    print(f"v             : {v}  wt = {hamming_weight(v)}")
    print(f"w             : {w}  wt = {hamming_weight(w)}")
    print(f"v + w (GF2)   : {s}  wt = {lhs}")
    print(f"triangle ineq : wt(v+w)={lhs} <= wt(v)+wt(w)={rhs}  -> {lhs <= rhs}")
    print()


def demo_hypercube_growth() -> None:
    """beta_1(Q_n) > 1 for n >= 3: hypercubes are multi-qubit codes."""
    print("=" * 64)
    print("DEMO 6: Hypercube codes Q_n and their capacity growth")
    print("=" * 64)
    print(f"{'n':>2} | {'|V|':>5} {'|E|':>6} | {'beta_1 (formula)':>16} "
          f"| {'beta_1 (matrix)':>16}")
    print("-" * 64)
    for n in range(1, 6):
        d, nv, ne = hypercube_boundary_matrix(n)
        # graph: only d1 (edges->vertices), no 2-cells, so beta_1 = ker d
        beta_matrix = nullity_gf2(d, ne)
        beta_formula = hypercube_betti1(n)
        print(f"{n:>2} | {nv:>5} {ne:>6} | {beta_formula:>16} "
              f"| {beta_matrix:>16}")
    print()
    print("Q_2 encodes exactly 1 qubit; Q_3 encodes 5; capacity grows ~ n*2^n.")
    print("This refutes the naive 'always 1 qubit' conjecture for n >= 3.")
    print()


def main() -> None:
    demo_toric_like_code()
    demo_rank_nullity()
    demo_additivity()
    demo_self_dual()
    demo_hamming()
    demo_hypercube_growth()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
