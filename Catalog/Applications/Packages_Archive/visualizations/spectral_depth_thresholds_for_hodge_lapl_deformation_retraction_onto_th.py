"""Visualization: harmonic vs. energy-carrying split across depth.

Decomposes a generic signal into its harmonic (constant) component and its
energy-carrying complement on the path graph, then plots both component norms
as functions of message-passing depth: the harmonic part stays flat (immortal)
while the complement decays geometrically. Requires matplotlib.
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
    lam = 2 + math.sqrt(2)
    alpha = 1.0 / lam
    n = 4
    x = [3.0, 1.0, -2.0, 4.0]
    mean = sum(x) / n
    harm = [mean] * n                       # projection onto constants (ker L)
    depths = list(range(0, 60))
    harm_norm, comp_norm = [], []
    xk = x[:]
    for _ in depths:
        h = [mean] * n
        c = [a - b for a, b in zip(xk, h)]
        harm_norm.append(sum(v * v for v in h) ** 0.5)
        comp_norm.append(sum(v * v for v in c) ** 0.5)
        lx = matvec(L, xk)
        xk = [xi - alpha * li for xi, li in zip(xk, lx)]
    plt.figure(figsize=(8, 5))
    plt.plot(depths, harm_norm, "o-", ms=3, label="harmonic part (topology)")
    plt.semilogy(depths, comp_norm, "s-", ms=3, label="energy-carrying part")
    plt.xlabel("depth k (layers)")
    plt.ylabel("component norm (log scale)")
    plt.title("Deformation retraction onto the harmonic subspace")
    plt.legend()
    plt.grid(True, which="both", alpha=0.3)
    plt.tight_layout()
    plt.savefig("harmonic_split.png", dpi=150)
    print("wrote harmonic_split.png")


if __name__ == "__main__":
    main()
