"""
CSS Codes as Cohomology — Numerical Demonstrations
==================================================

Self-contained Python demonstrations of the results in
"CSS Codes as Cohomology: Quantum Error Correction from Homological Algebra".

We work over the binary field F2 (the relevant field for qubits). All linear
algebra is implemented from scratch with integer matrices reduced mod 2.

Key results demonstrated:
  * Theorem 4.1  Homological Dimension Theorem:  k = dim(C_X/C_Z) = beta_1
  * Theorem 4.2  Quantum rank-nullity:           beta_1 + dim B_1 = dim Z_1
  * Theorem 4.3  Chain-level rank-nullity:        dim Z_1 + rank(d1) = n
  * Theorem 4.4  Logical-qubit additivity (third isomorphism)
  * Theorem 4.5  Self-dual codes encode 0 qubits
  * Theorems 5.2/5.3  Hamming weight: positive-definiteness and triangle ineq.
  * Theorems 7.2/7.3  Hypercube Betti numbers: beta_1(Q_2)=1, beta_1(Q_n)>1 (n>=3)

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations, product
from typing import List, Tuple

Matrix = List[List[int]]  # entries in {0,1}, interpreted mod 2
Vector = List[int]


# ---------------------------------------------------------------------------
# F2 linear algebra
# ---------------------------------------------------------------------------

def mat_mul_mod2(a: Matrix, b: Matrix) -> Matrix:
    """Multiply two matrices over F2 (entries reduced mod 2)."""
    rows, inner, cols = len(a), len(b), len(b[0]) if b else 0
    out: Matrix = [[0] * cols for _ in range(rows)]
    for i in range(rows):
        for k in range(inner):
            if a[i][k] % 2:
                for j in range(cols):
                    out[i][j] ^= b[k][j] % 2
    return out


def rank_mod2(matrix: Matrix) -> int:
    """Rank of a matrix over F2 via Gaussian elimination."""
    if not matrix or not matrix[0]:
        return 0
    m = [row[:] for row in matrix]
    rows, cols = len(m), len(m[0])
    rank, pivot_row = 0, 0
    for col in range(cols):
        sel = -1
        for r in range(pivot_row, rows):
            if m[r][col] % 2:
                sel = r
                break
        if sel == -1:
            continue
        m[pivot_row], m[sel] = m[sel], m[pivot_row]
        for r in range(rows):
            if r != pivot_row and m[r][col] % 2:
                m[r] = [(x ^ y) for x, y in zip(m[r], m[pivot_row])]
        rank += 1
        pivot_row += 1
        if pivot_row == rows:
            break
    return rank


def nullity_mod2(matrix: Matrix, num_cols: int) -> int:
    """Dimension of the kernel of a matrix acting on F2^num_cols (columns)."""
    return num_cols - rank_mod2(matrix)


# ---------------------------------------------------------------------------
# Chain complexes and CSS codes
# ---------------------------------------------------------------------------

class ChainComplex3:
    """A 3-term chain complex F^m --d2--> F^n --d1--> F^p over F2.

    d2 is an (n x m) matrix (maps F^m -> F^n).
    d1 is a (p x n) matrix (maps F^n -> F^p).
    The chain condition d1 . d2 = 0 must hold (checked on construction).
    """

    def __init__(self, n: int, m: int, p: int, d2: Matrix, d1: Matrix) -> None:
        self.n, self.m, self.p = n, m, p
        self.d2, self.d1 = d2, d1
        if not self.chain_condition_holds():
            raise ValueError("chain condition d1 . d2 = 0 violated")

    def chain_condition_holds(self) -> bool:
        prod = mat_mul_mod2(self.d1, self.d2)  # p x m
        return all(entry % 2 == 0 for row in prod for entry in row)

    def dim_cycles(self) -> int:
        """dim Z_1 = dim ker(d1) = nullity of d1 on F^n."""
        return nullity_mod2(self.d1, self.n)

    def dim_boundaries(self) -> int:
        """dim B_1 = dim im(d2) = rank of d2."""
        return rank_mod2(self.d2)

    def betti1(self) -> int:
        """beta_1 = dim H_1 = dim Z_1 - dim B_1  (Theorem 4.2)."""
        return self.dim_cycles() - self.dim_boundaries()

    def logical_qubits(self) -> int:
        """k = dim(C_X / C_Z) = beta_1  (Theorem 4.1)."""
        return self.betti1()


# ---------------------------------------------------------------------------
# Hamming weight  (Definition 5.1, Theorems 5.2, 5.3)
# ---------------------------------------------------------------------------

def hamming_weight(v: Vector) -> int:
    """Number of nonzero coordinates of v."""
    return sum(1 for x in v if x % 2 != 0)


def vec_add_mod2(v: Vector, w: Vector) -> Vector:
    return [(a ^ b) for a, b in zip(v, w)]


# ---------------------------------------------------------------------------
# Hypercube Betti number  (Definition 7.1, Theorems 7.2, 7.3)
# ---------------------------------------------------------------------------

def hypercube_betti1(n: int) -> int:
    """beta_1(Q_n) = n * 2^(n-1) - 2^n + 1  for n >= 1."""
    return n * 2 ** (n - 1) - 2 ** n + 1


def hypercube_edges(n: int) -> int:
    return n * 2 ** (n - 1)


def hypercube_vertices(n: int) -> int:
    return 2 ** n


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_repetition_code() -> None:
    """The 3-bit repetition complex: a simple one-qubit CSS code.

    Take the path graph on 3 vertices with d1 the incidence (boundary) map
    and d2 = 0. Then Z_1 = ker(d1), B_1 = 0, and beta_1 counts independent
    cycles. With a triangle (cycle graph C_3) we get exactly one loop.
    """
    print("=" * 70)
    print("DEMO 1: Cycle graph C_3 as a one-qubit topological code")
    print("=" * 70)
    # C_3: 3 vertices, 3 edges. d1 : F^3(edges) -> F^3(vertices).
    # edges: e0=(0,1), e1=(1,2), e2=(2,0). Boundary map (vertices x edges):
    d1 = [
        [1, 0, 1],  # vertex 0 touches e0, e2
        [1, 1, 0],  # vertex 1 touches e0, e1
        [0, 1, 1],  # vertex 2 touches e1, e2
    ]
    d2 = [[0], [0], [0]]  # no 2-cells: F^1 -> F^3 zero map (m=1)
    K = ChainComplex3(n=3, m=1, p=3, d2=d2, d1=d1)
    print(f"  vertices |V| = 3, edges |E| = 3")
    print(f"  chain condition d1.d2 = 0 : {K.chain_condition_holds()}")
    print(f"  dim Z_1 (cycles)     = {K.dim_cycles()}")
    print(f"  dim B_1 (boundaries) = {K.dim_boundaries()}")
    print(f"  beta_1 = logical qubits k = {K.logical_qubits()}")
    print(f"  Euler check  |E|-|V|+1 = {3 - 3 + 1}")
    print()


def demo_rank_nullity() -> None:
    """Verify Theorems 4.2 and 4.3 on a random-ish complex."""
    print("=" * 70)
    print("DEMO 2: Rank-nullity conservation laws (Theorems 4.2, 4.3)")
    print("=" * 70)
    # A small but nontrivial complex: n=4, m=2, p=2.
    d2 = [  # 4 x 2  (F^2 -> F^4)
        [1, 0],
        [1, 0],
        [0, 1],
        [0, 1],
    ]
    d1 = [  # 2 x 4  (F^4 -> F^2)
        [1, 1, 0, 0],
        [0, 0, 1, 1],
    ]
    K = ChainComplex3(n=4, m=2, p=2, d2=d2, d1=d1)
    z, b, beta = K.dim_cycles(), K.dim_boundaries(), K.betti1()
    rank_d1 = rank_mod2(d1)
    print(f"  chain condition d1.d2 = 0 : {K.chain_condition_holds()}")
    print(f"  dim Z_1 = {z}, dim B_1 = {b}, beta_1 = {beta}")
    print(f"  Theorem 4.2:  beta_1 + dim B_1 = dim Z_1 ?  "
          f"{beta} + {b} = {z}  ->  {beta + b == z}")
    print(f"  Theorem 4.3:  dim Z_1 + rank(d1) = n ?       "
          f"{z} + {rank_d1} = {K.n}  ->  {z + rank_d1 == K.n}")
    print()


def demo_self_dual() -> None:
    """Theorem 4.5: when C_X = C_Z the code encodes zero qubits."""
    print("=" * 70)
    print("DEMO 3: Self-dual code encodes 0 qubits (Theorem 4.5)")
    print("=" * 70)
    # Force B_1 = Z_1 by choosing d2 whose image is exactly ker(d1).
    d1 = [[1, 1]]            # F^2 -> F^1, kernel spanned by (1,1)
    d2 = [[1], [1]]          # F^1 -> F^2, image spanned by (1,1) = ker(d1)
    K = ChainComplex3(n=2, m=1, p=1, d2=d2, d1=d1)
    print(f"  dim Z_1 = {K.dim_cycles()}, dim B_1 = {K.dim_boundaries()}")
    print(f"  C_X = C_Z  (cycles == boundaries) : "
          f"{K.dim_cycles() == K.dim_boundaries()}")
    print(f"  logical qubits k = {K.logical_qubits()}  (expected 0)")
    print()


def demo_additivity() -> None:
    """Theorem 4.4: logical-qubit additivity for a tower C_Z <= C_mid <= C_X.

    We model dimensions directly: for nested subspaces the identity is
    dim(C_X/C_Z) = dim(C_X/C_mid) + dim(C_mid/C_Z).
    """
    print("=" * 70)
    print("DEMO 4: Logical-qubit additivity / third isomorphism (Theorem 4.4)")
    print("=" * 70)
    dim_CX, dim_Cmid, dim_CZ = 7, 5, 2  # any chain of dimensions
    lhs = dim_CX - dim_CZ
    rhs = (dim_CX - dim_Cmid) + (dim_Cmid - dim_CZ)
    print(f"  dim C_X = {dim_CX}, dim C_mid = {dim_Cmid}, dim C_Z = {dim_CZ}")
    print(f"  dim(C_X/C_Z)   = {lhs}")
    print(f"  dim(C_X/C_mid) + dim(C_mid/C_Z) = {rhs}")
    print(f"  additivity holds : {lhs == rhs}")
    print()


def demo_hamming_metric() -> None:
    """Theorems 5.2 and 5.3: Hamming weight is a genuine metric."""
    print("=" * 70)
    print("DEMO 5: Hamming weight metric axioms (Theorems 5.2, 5.3)")
    print("=" * 70)
    n = 5
    print(f"  Positive-definiteness: weight(v)=0 iff v=0  (all v in F2^{n})")
    pd_ok = True
    for v in product([0, 1], repeat=n):
        v = list(v)
        if (hamming_weight(v) == 0) != (all(x == 0 for x in v)):
            pd_ok = False
    print(f"    verified over all {2**n} vectors : {pd_ok}")
    print(f"  Triangle inequality: weight(v+w) <= weight(v)+weight(w)")
    tri_ok = True
    worst = (None, None, 0)
    for v in product([0, 1], repeat=n):
        for w in product([0, 1], repeat=n):
            v, w = list(v), list(w)
            lhs = hamming_weight(vec_add_mod2(v, w))
            rhs = hamming_weight(v) + hamming_weight(w)
            if lhs > rhs:
                tri_ok = False
            if rhs - lhs > worst[2]:
                worst = (v, w, rhs - lhs)
    print(f"    verified over all {2**n}x{2**n} pairs : {tri_ok}")
    print(f"    example slack: v={worst[0]}, w={worst[1]}, "
          f"rhs-lhs={worst[2]}")
    print()


def demo_hypercubes() -> None:
    """Theorems 7.2 and 7.3: hypercube Betti numbers."""
    print("=" * 70)
    print("DEMO 6: Hypercube codes Q_n are multi-qubit (Theorems 7.2, 7.3)")
    print("=" * 70)
    print(f"  {'n':>2} | {'|V|':>6} | {'|E|':>6} | {'beta_1 (k qubits)':>18}")
    print("  " + "-" * 44)
    for n in range(1, 9):
        V, E, beta = hypercube_vertices(n), hypercube_edges(n), hypercube_betti1(n)
        # cross-check via Euler relation
        assert beta == E - V + 1
        print(f"  {n:>2} | {V:>6} | {E:>6} | {beta:>18}")
    print()
    print(f"  Theorem 7.2:  beta_1(Q_2) = {hypercube_betti1(2)}  (expected 1)")
    print(f"  Theorem 7.3:  beta_1(Q_n) > 1 for all n>=3 : "
          f"{all(hypercube_betti1(n) > 1 for n in range(3, 30))}")
    print()


def demo_brute_force_betti() -> None:
    """Cross-check the closed-form hypercube Betti number against an
    explicit incidence-matrix rank computation for small n."""
    print("=" * 70)
    print("DEMO 7: Brute-force verification of beta_1(Q_n) via matrix rank")
    print("=" * 70)
    for n in range(1, 5):
        verts = list(product([0, 1], repeat=n))
        index = {v: i for i, v in enumerate(verts)}
        edges: List[Tuple[int, int]] = []
        for v in verts:
            for bit in range(n):
                w = list(v)
                w[bit] ^= 1
                w = tuple(w)
                a, b = index[v], index[w]
                if a < b:
                    edges.append((a, b))
        # incidence (boundary) matrix d1 : edges -> vertices, |V| x |E|
        d1 = [[0] * len(edges) for _ in range(len(verts))]
        for j, (a, b) in enumerate(edges):
            d1[a][j] = 1
            d1[b][j] = 1
        # beta_1 = |E| - rank(d1)  (connected: rank = |V|-1)
        beta_bruteforce = len(edges) - rank_mod2(d1)
        beta_formula = hypercube_betti1(n)
        print(f"  Q_{n}: |V|={len(verts):>3}, |E|={len(edges):>3}, "
              f"brute-force beta_1={beta_bruteforce}, "
              f"formula={beta_formula}, match={beta_bruteforce == beta_formula}")
    print()


def main() -> None:
    print()
    print("#" * 70)
    print("#  CSS CODES AS COHOMOLOGY — NUMERICAL DEMONSTRATIONS")
    print("#" * 70)
    print()
    demo_repetition_code()
    demo_rank_nullity()
    demo_self_dual()
    demo_additivity()
    demo_hamming_metric()
    demo_hypercubes()
    demo_brute_force_betti()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
