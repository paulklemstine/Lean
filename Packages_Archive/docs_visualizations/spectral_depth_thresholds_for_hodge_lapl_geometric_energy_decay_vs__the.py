"""Visualization: energy decay vs. depth, measured against the rho^k bound.

Generates a semilog plot showing the measured residual energy ||T^k x||^2 of an
energy-carrying signal under Hodge message passing, overlaid with the
theoretical geometric bound rho^k * ||x||^2 and the tolerance line eps.
Requires matplotlib.
"""
from __future__ import annotations
import math
from typing import List

import matplotlib.pyplot as plt

Vector = List[float]
Matrix = List[List[float]]


def transpose(A: Matrix) -> Matrix:
    return [list(c) for c in zip(*A)]


def matvec(A: Matrix, x: Vector) -> Vector:
    return [sum(a * xi for a, xi in zip(r, x)) for r in A]


def matmul(A: Matrix, B: Matrix) -> Matrix:
    Bt = transpose(B)
    return [[sum(a * b for a, b in zip(r, c)) for c in Bt] for r in A]


def main() -> None:
    B = [[-1.0, 1.0, 0.0, 0.0], [0.0, -1.0, 1.0, 0.0], [0.0, 0.0, -1.0, 1.0]]
    L = matmul(transpose(B), B)
    mu, lam = 2 - math.sqrt(2), 2 + math.sqrt(2)
    alpha = 1.0 / lam
    rho = 1 - alpha * mu * (2 - alpha * lam)
    x = [1.0, -1.0, 1.0, -1.0]
    e0 = sum(xi * xi for xi in x)
    depths = list(range(0, 90))
    measured, bound = [], []
    xk = x[:]
    for k in depths:
        measured.append(sum(xi * xi for xi in xk))
        bound.append(rho ** k * e0)
        lx = matvec(L, xk)
        xk = [xi - alpha * li for xi, li in zip(xk, lx)]
    plt.figure(figsize=(8, 5))
    plt.semilogy(depths, measured, "o-", ms=3, label="measured energy")
    plt.semilogy(depths, bound, "--", label=f"bound rho^k, rho={rho:.3f}")
    plt.axhline(1e-6, color="r", ls=":", label="tolerance eps=1e-6")
    plt.xlabel("depth k (layers)")
    plt.ylabel("residual Dirichlet energy")
    plt.title("Geometric energy decay and the spectral depth threshold")
    plt.legend()
    plt.grid(True, which="both", alpha=0.3)
    plt.tight_layout()
    plt.savefig("energy_decay.png", dpi=150)
    print("wrote energy_decay.png")


if __name__ == "__main__":
    main()
