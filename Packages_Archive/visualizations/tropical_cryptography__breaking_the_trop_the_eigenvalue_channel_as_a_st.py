"""
Visualization: Eigenvalue additivity lambda(A^{⊗m}) = m * lambda(A) as a
perfect straight line, exposing the homomorphism that breaks the TDLP.

Run:  python3 _viz_eigenvalue_additivity.py   (produces tropical_additivity.png)
"""
from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt

INF = math.inf
Matrix = List[List[float]]
Vector = List[float]


def trop_matmul(A: Matrix, B: Matrix) -> Matrix:
    n, p, m = len(A), len(B[0]), len(B)
    return [[min(A[i][k] + B[k][j] for k in range(m)) for j in range(p)]
            for i in range(n)]


def trop_identity(n: int) -> Matrix:
    return [[0.0 if i == j else INF for j in range(n)] for i in range(n)]


def trop_matpow(A: Matrix, m: int) -> Matrix:
    n = len(A)
    result, base, e = trop_identity(n), [r[:] for r in A], m
    while e > 0:
        if e & 1:
            result = trop_matmul(result, base)
        base = trop_matmul(base, base)
        e >>= 1
    return result


def trop_matvec(A: Matrix, v: Vector) -> Vector:
    return [min(A[i][k] + v[k] for k in range(len(v))) for i in range(len(A))]


def main() -> None:
    matrices = {
        "diag 1 / off 100 (lambda=1)": [[1.0, 100.0], [100.0, 1.0]],
        "diag 3 / off 50 (lambda=3)": [[3.0, 50.0, 60.0],
                                       [60.0, 3.0, 50.0],
                                       [50.0, 60.0, 3.0]],
        "boundary digraph (lambda=0)": [[0.0, 4.0, 7.0],
                                        [5.0, 0.0, 3.0],
                                        [6.0, 2.0, 0.0]],
    }
    ms = list(range(1, 13))
    plt.figure(figsize=(8, 5))
    for label, A in matrices.items():
        v = [0.0] * len(A)
        ys = [trop_matvec(trop_matpow(A, m), v)[0] - v[0] for m in ms]
        plt.plot(ms, ys, marker="o", label=label)
    plt.title("Tropical eigenvalue additivity: lambda(A^m) = m * lambda(A)")
    plt.xlabel("exponent m")
    plt.ylabel("eigenvalue of A^{(x)m}  (residual on v)")
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.tight_layout()
    plt.savefig("tropical_additivity.png", dpi=150)
    print("wrote tropical_additivity.png")


if __name__ == "__main__":
    main()
