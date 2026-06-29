"""
CSS Codes as Cohomology — Numerical Demonstrations
==================================================

Self-contained Python demonstrations of the homological theory of CSS quantum
error-correcting codes. All linear algebra is done over the field GF(2) = {0, 1}
(arithmetic modulo 2), the field relevant for ordinary qubits.

Key facts illustrated (each a theorem from the formal development):

  * A three-term chain complex  V2 --d2--> V1 --d1--> V0  with d1 . d2 = 0
    yields a CSS code with  C_X = ker(d1),  C_Z = range(d2),  C_Z <= C_X.
  * logical qubits = dim(C_X / C_Z) = dim H1 = first Betti number beta_1.
  * Quantum rank-nullity:  beta_1 + dim(boundaries) = dim(cycles).
  * Linear rank-nullity:   dim(cycles) + rank(d1) = n.
  * Hamming weight is definite (0 iff zero) and subadditive (triangle ineq).
  * Hypercube Q_n:  beta_1(Q_n) = n*2^(n-1) - 2^n + 1; =1 for n=2, >1 for n>=3.

No third-party dependencies; matrices are lists of rows over GF(2).
"""

from __future__ import annotations

from itertools import combinations
from typing import List, Tuple

# A vector / matrix over GF(2): entries are 0 or 1 (ints), matrices are row lists.
Vec = List[int]
Mat = List[List[int]]


# ---------------------------------------------------------------------------
# Core GF(2) linear algebra
# ---------------------------------------------------------------------------
def gf2_rank(matrix: Mat) -> int:
    """Rank of a 0/1 matrix over GF(2) via Gaussian elimination.

    Complexity O(rows * cols * min(rows, cols)).
    """
    # Work on a copy so the caller's matrix is untouched.
    rows: Mat = [row[:] for row in matrix]
    if not rows:
        return 0
    n_cols: int = len(rows[0])
    rank: int = 0
    pivot_row: int = 0
    for col in range(n_cols):
        # Find a row at or below pivot_row with a 1 in this column.
        sel: int = -1
        for r in range(pivot_row, len(rows)):
            if rows[r][col] == 1:
                sel = r
                break
        if sel == -1:
            continue
        rows[pivot_row], rows[sel] = rows[sel], rows[pivot_row]
        # Eliminate this column from all other rows (mod 2).
        for r in range(len(rows)):
            if r != pivot_row and rows[r][col] == 1:
                rows[r] = [(a ^ b) for a, b in zip(rows[r], rows[pivot_row])]
        rank += 1
        pivot_row += 1
        if pivot_row == len(rows):
            break
    return rank


def matmul_gf2(a: Mat, b: Mat) -> Mat:
    """Matrix product over GF(2):  (a @ b) mod 2."""
    inner: int = len(b)
    cols: int = len(b[0]) if b else 0
    result: Mat = []
    for row in a:
        new_row: Vec = []
        for j in range(cols):
            acc: int = 0
            for k in range(inner):
                acc ^= row[k] & b[k][j]
            new_row.append(acc)
        result.append(new_row)
    return result


def kernel_dim(d1: Mat, n: int) -> int:
    """dim ker(d1) for d1 : GF(2)^n -> GF(2)^p, given as a (p x n) matrix.

    By rank-nullity:  dim ker = n - rank(d1).
    """
    return n - gf2_rank(d1)


# ---------------------------------------------------------------------------
# Chain complex / CSS code invariants
# ---------------------------------------------------------------------------
def check_chain_condition(d1: Mat, d2: Mat) -> bool:
    """Verify d1 . d2 = 0 over GF(2), where d1 is (p x n) and d2 is (n x m)."""
    product: Mat = matmul_gf2(d1, d2)
    return all(entry == 0 for row in product for entry in row)


def betti1(d1: Mat, d2: Mat, n: int) -> int:
    """First Betti number beta_1 = dim(ker d1) - dim(range d2).

    This equals the number of logical qubits of the associated CSS code
    (Homological Dimension Theorem).
    """
    dim_cycles: int = kernel_dim(d1, n)          # dim ker(d1)
    dim_boundaries: int = gf2_rank(d2)           # dim range(d2) = rank(d2)
    return dim_cycles - dim_boundaries


def css_invariants(d1: Mat, d2: Mat, n: int) -> Tuple[int, int, int]:
    """Return (dim cycles, dim boundaries, beta_1) and check the conservation laws.

    Asserts the quantum rank-nullity identity and the linear rank-nullity theorem.
    """
    assert check_chain_condition(d1, d2), "chain condition d1.d2 = 0 violated"
    dim_cycles: int = kernel_dim(d1, n)
    dim_boundaries: int = gf2_rank(d2)
    beta: int = dim_cycles - dim_boundaries
    # Theorem 4.1 (quantum rank-nullity): beta_1 + dim B = dim Z.
    assert beta + dim_boundaries == dim_cycles
    # Theorem 4.2 (linear rank-nullity): dim Z + rank(d1) = n.
    assert dim_cycles + gf2_rank(d1) == n
    return dim_cycles, dim_boundaries, beta


# ---------------------------------------------------------------------------
# Hamming weight
# ---------------------------------------------------------------------------
def hamming_weight(v: Vec) -> int:
    """Number of nonzero coordinates of v."""
    return sum(1 for x in v if x != 0)


def gf2_add(v: Vec, w: Vec) -> Vec:
    """Coordinatewise XOR of two GF(2) vectors of equal length."""
    return [a ^ b for a, b in zip(v, w)]


# ---------------------------------------------------------------------------
# Hypercube graph Q_n as a 1-complex
# ---------------------------------------------------------------------------
def hypercube_edges(n: int) -> List[Tuple[int, int]]:
    """Edges of Q_n: pairs of vertices (as integers 0..2^n-1) differing in one bit."""
    edges: List[Tuple[int, int]] = []
    num_vertices: int = 1 << n
    for v in range(num_vertices):
        for bit in range(n):
            w: int = v ^ (1 << bit)
            if v < w:
                edges.append((v, w))
    return edges


def hypercube_boundary_map(n: int) -> Mat:
    """The graph boundary map d1 : edges -> vertices of Q_n, as a (|V| x |E|) matrix.

    Column e (edge {u, v}) has 1s in rows u and v (over GF(2)).
    """
    edges: List[Tuple[int, int]] = hypercube_edges(n)
    num_vertices: int = 1 << n
    # Rows indexed by vertices, columns by edges.
    matrix: Mat = [[0] * len(edges) for _ in range(num_vertices)]
    for col, (u, v) in enumerate(edges):
        matrix[u][col] = 1
        matrix[v][col] = 1
    return matrix


def hypercube_betti1_formula(n: int) -> int:
    """Closed form: beta_1(Q_n) = n*2^(n-1) - 2^n + 1."""
    return n * (1 << (n - 1)) - (1 << n) + 1


def hypercube_betti1_computed(n: int) -> int:
    """beta_1(Q_n) computed from the boundary map: |E| - rank(d1).

    For a connected graph, dim H_1 = |E| - (|V| - 1) = |E| - rank(d1),
    since rank of the incidence matrix of a connected graph on V vertices is V - 1.
    """
    d1: Mat = hypercube_boundary_map(n)
    num_edges: int = len(d1[0]) if d1 else 0
    return num_edges - gf2_rank(d1)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_repetition_code() -> None:
    """The 3-qubit complex: d1 detects parity, no 2-cells -> 1 logical qubit.

    d1 : GF(2)^3 -> GF(2)^2 sends (a,b,c) to (a+b, b+c) (the two parity checks
    of the repetition code). There are no 2-cells, so d2 = 0 (a 3 x 0 matrix).
    """
    print("=" * 64)
    print("Demo 1: Repetition-style complex (3 qubits, 2 checks)")
    print("=" * 64)
    n: int = 3
    d1: Mat = [[1, 1, 0],
               [0, 1, 1]]
    d2: Mat = [[], [], []]  # no 2-cells: range(d2) = {0}
    dim_cycles, dim_boundaries, beta = (
        kernel_dim(d1, n), 0, betti1(d1, d2, n))
    print(f"  dim cycles (ker d1)     = {dim_cycles}")
    print(f"  dim boundaries (rng d2) = {dim_boundaries}")
    print(f"  beta_1 = logical qubits = {beta}")
    assert beta == 1
    print("  => encodes 1 logical qubit (as expected).")
    print()


def demo_toric_like() -> None:
    """A small closed complex with two independent holes -> beta_1 = 2.

    We hand-build a tiny complex modelling a torus-like situation: 4 edges
    forming two independent cycles, with one 2-cell filling one of them, so
    beta_1 = (dim cycles) - (dim boundaries).
    """
    print("=" * 64)
    print("Demo 2: Two-hole complex (toric flavour)")
    print("=" * 64)
    n: int = 4
    # d1 with a 2-dimensional kernel (two independent cycles).
    d1: Mat = [[1, 1, 0, 0],
               [0, 0, 1, 1]]
    # one 2-cell filling the first cycle (1,1,0,0) is in ker(d1):
    d2: Mat = [[1], [1], [0], [0]]
    print(f"  chain condition d1.d2 = 0 ? {check_chain_condition(d1, d2)}")
    dim_cycles, dim_boundaries, beta = css_invariants(d1, d2, n)
    print(f"  dim cycles (ker d1)     = {dim_cycles}")
    print(f"  dim boundaries (rng d2) = {dim_boundaries}")
    print(f"  beta_1 = logical qubits = {beta}")
    assert beta == 1
    print("  => one cycle is filled in, leaving 1 genuine hole = 1 logical qubit.")
    print()


def demo_self_dual() -> None:
    """Self-dual situation: cycles = boundaries -> 0 logical qubits."""
    print("=" * 64)
    print("Demo 3: Self-dual code encodes zero logical qubits")
    print("=" * 64)
    n: int = 2
    d1: Mat = [[1, 1]]            # ker = span{(1,1)}, dim 1
    d2: Mat = [[1], [1]]          # range = span{(1,1)}, dim 1  -> equals cycles
    dim_cycles, dim_boundaries, beta = css_invariants(d1, d2, n)
    print(f"  dim cycles = {dim_cycles}, dim boundaries = {dim_boundaries}")
    print(f"  beta_1 = {beta}")
    assert beta == 0
    print("  => C_X = C_Z, so logical qubits = 0 (Theorem: self-dual is trivial).")
    print()


def demo_hamming_weight() -> None:
    """Hamming weight definiteness and the triangle inequality."""
    print("=" * 64)
    print("Demo 4: Hamming weight is a norm on GF(2)^n")
    print("=" * 64)
    v: Vec = [1, 0, 1, 1, 0]
    w: Vec = [0, 1, 1, 0, 0]
    print(f"  v = {v}, weight = {hamming_weight(v)}")
    print(f"  w = {w}, weight = {hamming_weight(w)}")
    s: Vec = gf2_add(v, w)
    print(f"  v + w = {s}, weight = {hamming_weight(s)}")
    # Definiteness:
    assert hamming_weight([0, 0, 0]) == 0
    # Triangle inequality:
    assert hamming_weight(s) <= hamming_weight(v) + hamming_weight(w)
    print("  weight(v+w) <= weight(v) + weight(w) ?",
          hamming_weight(s) <= hamming_weight(v) + hamming_weight(w))
    print("  weight(x) = 0 iff x = 0 ? verified for zero vector.")
    print()


def demo_hypercube() -> None:
    """Betti numbers of the hypercube codes Q_n, formula vs. computation."""
    print("=" * 64)
    print("Demo 5: Hypercube codes Q_n  (beta_1 = n*2^(n-1) - 2^n + 1)")
    print("=" * 64)
    print(f"  {'n':>2} | {'|V|':>5} | {'|E|':>6} | {'formula':>8} | {'computed':>9}")
    print("  " + "-" * 44)
    for n in range(1, 7):
        num_v: int = 1 << n
        num_e: int = n * (1 << (n - 1))
        f: int = hypercube_betti1_formula(n)
        c: int = hypercube_betti1_computed(n)
        assert f == c, f"mismatch at n={n}: {f} vs {c}"
        print(f"  {n:>2} | {num_v:>5} | {num_e:>6} | {f:>8} | {c:>9}")
    print()
    print(f"  beta_1(Q_2) = {hypercube_betti1_formula(2)}  (== 1)")
    assert hypercube_betti1_formula(2) == 1
    for n in range(3, 7):
        assert hypercube_betti1_formula(n) > 1
    print("  beta_1(Q_n) > 1 for all n >= 3  =>  multi-qubit codes.")
    print()


def main() -> None:
    demo_repetition_code()
    demo_toric_like()
    demo_self_dual()
    demo_hamming_weight()
    demo_hypercube()
    print("All demonstrations completed and assertions verified.")


if __name__ == "__main__":
    main()
