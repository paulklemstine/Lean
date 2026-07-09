"""Visualization: the ascending kernel-dimension staircase and its plateau.

Generates a step plot of n |-> dim ker(g^n) for several endomorphisms, marking
the stabilization deadline n = dim V. Requires matplotlib.
"""
from __future__ import annotations
from fractions import Fraction
from typing import List
import matplotlib.pyplot as plt

Matrix = List[List[Fraction]]


def matmul(a, b):
    n, m, p = len(a), len(b), len(b[0])
    out = [[Fraction(0)] * p for _ in range(n)]
    for i in range(n):
        for k in range(m):
            if a[i][k]:
                for j in range(p):
                    out[i][j] += a[i][k] * b[k][j]
    return out


def rank(a):
    m = [r[:] for r in a]; rows = len(m); cols = len(m[0]) if rows else 0
    rk = c = 0
    for r in range(rows):
        if c >= cols: break
        piv = None
        while c < cols:
            piv = next((i for i in range(r, rows) if m[i][c] != 0), None)
            if piv is not None: break
            c += 1
        if c >= cols: break
        m[r], m[piv] = m[piv], m[r]
        inv = m[r][c]; m[r] = [x / inv for x in m[r]]
        for i in range(rows):
            if i != r and m[i][c]:
                f = m[i][c]; m[i] = [x - f * y for x, y in zip(m[i], m[r])]
        rk += 1; c += 1
    return rk


def kernel_dims(a, upto):
    d = len(a); I = [[Fraction(i == j) for j in range(d)] for i in range(d)]
    out, P = [], I
    for _ in range(upto + 1):
        out.append(d - rank(P)); P = matmul(P, a)
    return out


def shift(d):
    m = [[Fraction(0)] * d for _ in range(d)]
    for i in range(d - 1): m[i][i + 1] = Fraction(1)
    return m


def main():
    examples = {
        "nilpotent shift (d=6)": shift(6),
        "Jordan(3)+diag(2,5) (d=5)": [
            [Fraction(0), Fraction(1), Fraction(0), Fraction(0), Fraction(0)],
            [Fraction(0), Fraction(0), Fraction(1), Fraction(0), Fraction(0)],
            [Fraction(0), Fraction(0), Fraction(0), Fraction(0), Fraction(0)],
            [Fraction(0), Fraction(0), Fraction(0), Fraction(2), Fraction(0)],
            [Fraction(0), Fraction(0), Fraction(0), Fraction(0), Fraction(5)],
        ],
    }
    plt.figure(figsize=(8, 5))
    for name, mat in examples.items():
        d = len(mat); ys = kernel_dims(mat, d + 3)
        plt.step(range(len(ys)), ys, where="post", marker="o", label=name)
        plt.axvline(d, ls="--", alpha=0.4)
    plt.xlabel("n  (iterate exponent)")
    plt.ylabel("dim ker(g^n)")
    plt.title("Kernel-dimension staircase: stabilizes by n = dim V")
    plt.legend(); plt.grid(alpha=0.3); plt.tight_layout()
    plt.savefig("kernel_staircase.png", dpi=150)
    print("saved kernel_staircase.png")


if __name__ == "__main__":
    main()
