"""
Numerical demonstrations for
"Tensor Amplification and Spectral Transfer for Sidorenko-Type Inequalities".

A *weighted graph* is a symmetric real matrix A (the vertex space carries the
uniform/counting measure).  We work with two homomorphism densities:

    edge density   t(K2, A) = (1/N^2) * sum_{i,j} A[i,j]
    cycle density  t(Ck, A) = (1/N^k) * trace(A^k)

The Sidorenko property for the k-cycle is  t(Ck, A) >= t(K2, A)^k, equivalently
the Sidorenko ratio  R_k(A) = t(Ck, A) / t(K2, A)^k  satisfies R_k(A) >= 1.

This script demonstrates, with no external dependencies:
  * the sign-free even-cycle base cases (C2 and C4),
  * spectral transfer: densities and the ratio are multiplicative under the
    Kronecker (tensor) product,
  * amplification: self-tensoring squares the ratio (orbit R, R^2, R^4, ...).
"""

from __future__ import annotations

from typing import List


Matrix = List[List[float]]


def n_vertices(A: Matrix) -> int:
    """Number of vertices (rows) of a square weighted graph."""
    return len(A)


def is_symmetric(A: Matrix, tol: float = 1e-9) -> bool:
    """Check A[i][j] == A[j][i] within tolerance."""
    n = n_vertices(A)
    return all(abs(A[i][j] - A[j][i]) <= tol for i in range(n) for j in range(n))


def mat_mul(A: Matrix, B: Matrix) -> Matrix:
    """Naive matrix product of two square matrices of equal size."""
    n = n_vertices(A)
    return [[sum(A[i][k] * B[k][j] for k in range(n)) for j in range(n)]
            for i in range(n)]


def mat_pow(A: Matrix, k: int) -> Matrix:
    """k-th matrix power by repeated squaring (k >= 0)."""
    n = n_vertices(A)
    result: Matrix = [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]
    base = [row[:] for row in A]
    while k > 0:
        if k & 1:
            result = mat_mul(result, base)
        base = mat_mul(base, base)
        k >>= 1
    return result


def trace(A: Matrix) -> float:
    """Sum of the diagonal entries."""
    return sum(A[i][i] for i in range(n_vertices(A)))


def total_weight(A: Matrix) -> float:
    """Sum of all entries = hom(K2, A)."""
    return sum(sum(row) for row in A)


def t_edge(A: Matrix) -> float:
    """Edge density t(K2, A)."""
    n = n_vertices(A)
    return total_weight(A) / (n ** 2)


def t_cycle(k: int, A: Matrix) -> float:
    """Cycle density t(Ck, A) = trace(A^k) / N^k."""
    n = n_vertices(A)
    return trace(mat_pow(A, k)) / (n ** k)


def sid_ratio(k: int, A: Matrix) -> float:
    """Sidorenko ratio R_k(A) = t(Ck, A) / t(K2, A)^k."""
    return t_cycle(k, A) / (t_edge(A) ** k)


def kron(A: Matrix, B: Matrix) -> Matrix:
    """Kronecker (tensor) product: vertices are pairs, weights multiply."""
    na, nb = n_vertices(A), n_vertices(B)
    n = na * nb
    C: Matrix = [[0.0] * n for _ in range(n)]
    for i in range(na):
        for j in range(na):
            for ip in range(nb):
                for jp in range(nb):
                    C[i * nb + ip][j * nb + jp] = A[i][j] * B[ip][jp]
    return C


def demo_base_cases() -> None:
    """C2 and C4 Sidorenko hold for symmetric graphs, including signed ones."""
    print("=" * 68)
    print("Base cases: sign-free even-cycle Sidorenko (C2 and C4)")
    print("=" * 68)
    examples = {
        "random-like positive": [[0.3, 0.7, 0.2],
                                 [0.7, 0.5, 0.9],
                                 [0.2, 0.9, 0.4]],
        "SIGNED (has negatives)": [[1.0, -2.0, 0.5],
                                   [-2.0, 3.0, -1.0],
                                   [0.5, -1.0, 2.0]],
        "constant (extremal)": [[0.6, 0.6], [0.6, 0.6]],
    }
    for name, A in examples.items():
        assert is_symmetric(A)
        r2, r4 = sid_ratio(2, A), sid_ratio(4, A)
        print(f"\n{name}:")
        print(f"  t(K2)={t_edge(A):+.4f}  t(C2)={t_cycle(2, A):+.4f}  "
              f"t(C4)={t_cycle(4, A):+.4f}")
        print(f"  R2 = {r2:.6f}  (>= 1 ? {r2 >= 1 - 1e-9})")
        print(f"  R4 = {r4:.6f}  (>= 1 ? {r4 >= 1 - 1e-9})")


def demo_spectral_transfer() -> None:
    """Densities and the ratio are multiplicative under the tensor product."""
    print("\n" + "=" * 68)
    print("Spectral transfer: multiplicativity under tensor product")
    print("=" * 68)
    A = [[0.4, 0.5], [0.5, 0.8]]
    B = [[0.2, 0.9, 0.1], [0.9, 0.3, 0.6], [0.1, 0.6, 0.7]]
    AB = kron(A, B)
    for k in (2, 4):
        lhs = t_cycle(k, AB)
        rhs = t_cycle(k, A) * t_cycle(k, B)
        print(f"\nk = {k}:")
        print(f"  t(C{k}, A(x)B)         = {lhs:.8f}")
        print(f"  t(C{k}, A) * t(C{k}, B) = {rhs:.8f}   match: {abs(lhs-rhs) < 1e-9}")
        rl, rr = sid_ratio(k, AB), sid_ratio(k, A) * sid_ratio(k, B)
        print(f"  R(A(x)B) = {rl:.8f}   R(A)*R(B) = {rr:.8f}   "
              f"match: {abs(rl-rr) < 1e-9}")


def demo_amplification() -> None:
    """Self-tensoring squares the ratio: orbit R, R^2, R^4, ... toward {0,1,inf}."""
    print("\n" + "=" * 68)
    print("Amplification: self-tensoring squares the Sidorenko ratio")
    print("=" * 68)
    surplus = [[0.5, 0.1], [0.1, 0.5]]          # R > 1 for C4
    deficit = [[0.5, 1.0], [1.0, 0.5]]          # R < 1 for the triangle C3
    for name, A, k in [("surplus C4", surplus, 4),
                       ("deficit C3", deficit, 3)]:
        r = sid_ratio(k, A)
        print(f"\n{name}: base ratio R = {r:.6f}")
        cur = [row[:] for row in A]
        orbit = [r]
        for _ in range(3):
            cur = kron(cur, cur)
            orbit.append(sid_ratio(k, cur))
        pred = [r ** (2 ** i) for i in range(len(orbit))]
        for i, (o, p) in enumerate(zip(orbit, pred)):
            print(f"  step {i}: measured {o:.6f}   predicted R^(2^{i}) {p:.6f}")


if __name__ == "__main__":
    demo_base_cases()
    demo_spectral_transfer()
    demo_amplification()
