"""
Visualization: the tropical spectrum and the residual leakage map.

Produces two panels for a weighted digraph (non-negative weights, zero
self-loops):

  (left)  the residual max over a grid of probe vectors, illustrating
          digraph_residual_nonpos (residual <= 0 everywhere) and the boundary
          eigenvalue lambda = 0 attained by constant vectors.
  (right) the eigenvalue-attack signal lambda(A^{(x)k}) = k * lambda(A) as a
          function of the secret exponent k, for an off-boundary matrix
          (slope != 0, leaky) versus a boundary matrix (flat zero, no leak).

Requires matplotlib; standard-library-only fallbacks are avoided to keep the
plot faithful.
"""

from __future__ import annotations

from typing import List

import numpy as np
import matplotlib.pyplot as plt

Matrix = List[List[float]]
Vector = List[float]
INF = float("inf")


def trop_matvec(A: Matrix, v: Vector) -> Vector:
    n = len(v)
    return [min(A[i][k] + v[k] for k in range(n)) for i in range(n)]


def trop_matmul(A: Matrix, B: Matrix) -> Matrix:
    n = len(A)
    return [[min(A[i][k] + B[k][j] for k in range(n)) for j in range(n)]
            for i in range(n)]


def trop_identity(n: int) -> Matrix:
    return [[0.0 if i == j else INF for j in range(n)] for i in range(n)]


def trop_power(A: Matrix, k: int) -> Matrix:
    n = len(A)
    res = trop_identity(n)
    base = [row[:] for row in A]
    while k > 0:
        if k & 1:
            res = trop_matmul(res, base)
        base = trop_matmul(base, base)
        k >>= 1
    return res


def residual(A: Matrix, v: Vector) -> Vector:
    Av = trop_matvec(A, v)
    return [Av[i] - v[i] for i in range(len(v))]


def main() -> None:
    W: Matrix = [[0.0, 2.0, 5.0],
                 [3.0, 0.0, 4.0],
                 [6.0, 1.0, 0.0]]

    # Panel 1: max residual over a 2D slice (v0, v1) with v2 = 0.
    xs = np.linspace(-6, 6, 120)
    ys = np.linspace(-6, 6, 120)
    Z = np.zeros((len(ys), len(xs)))
    for a, x in enumerate(xs):
        for b, y in enumerate(ys):
            Z[b, a] = max(residual(W, [float(x), float(y), 0.0]))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))
    im = ax1.contourf(xs, ys, Z, levels=30, cmap="viridis")
    ax1.contour(xs, ys, Z, levels=[0.0], colors="white", linewidths=2)
    ax1.scatter([0], [0], color="red", zorder=5,
                label="constant slice (lambda = 0)")
    ax1.set_title("max residual  (always <= 0;  boundary lambda = 0 in white)")
    ax1.set_xlabel("v[0]")
    ax1.set_ylabel("v[1]")
    ax1.legend(loc="upper right")
    fig.colorbar(im, ax=ax1, shrink=0.85)

    # Panel 2: eigenvalue-attack signal vs exponent k.
    d = -3.0
    A_off: Matrix = [[d, 12.0, 12.0], [12.0, d, 12.0], [12.0, 12.0, d]]
    v0: Vector = [0.0, 0.0, 0.0]
    ks = list(range(1, 13))
    leaky = [residual(trop_power(A_off, k), v0)[0] for k in ks]
    flat = [residual(trop_power(W, k), v0)[0] for k in ks]
    ax2.plot(ks, leaky, "o-", label="off-boundary: lambda(A^k)=k*lambda(A) (leaky)")
    ax2.plot(ks, flat, "s--", label="boundary: lambda = 0 (no leak)")
    ax2.set_title("Eigenvalue-attack signal vs secret exponent k")
    ax2.set_xlabel("secret exponent k")
    ax2.set_ylabel("measured eigenvalue lambda(A^k)")
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig("tropical_boundary.png", dpi=150)
    print("Saved tropical_boundary.png")


if __name__ == "__main__":
    main()
