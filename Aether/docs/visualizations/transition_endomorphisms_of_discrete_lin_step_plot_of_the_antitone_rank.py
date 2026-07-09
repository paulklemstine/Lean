"""Visualize the antitone rank filtration of a discrete linear cocycle."""
from fractions import Fraction
from typing import Callable, List

import matplotlib.pyplot as plt

Matrix = List[List[Fraction]]


def identity(d: int) -> Matrix:
    return [[Fraction(1) if r == c else Fraction(0) for c in range(d)]
            for r in range(d)]


def matmul(a: Matrix, b: Matrix) -> Matrix:
    n, k, m = len(a), len(b), len(b[0])
    out = [[Fraction(0) for _ in range(m)] for _ in range(n)]
    for i in range(n):
        for t in range(k):
            if a[i][t] == 0:
                continue
            for j in range(m):
                out[i][j] += a[i][t] * b[t][j]
    return out


def rank(a: Matrix) -> int:
    m = [row[:] for row in a]
    rows, cols = len(m), len(m[0]) if m else 0
    r = 0
    for c in range(cols):
        piv = next((i for i in range(r, rows) if m[i][c] != 0), None)
        if piv is None:
            continue
        m[r], m[piv] = m[piv], m[r]
        inv = Fraction(1) / m[r][c]
        m[r] = [x * inv for x in m[r]]
        for i in range(rows):
            if i != r and m[i][c] != 0:
                fac = m[i][c]
                m[i] = [x - fac * y for x, y in zip(m[i], m[r])]
        r += 1
    return r


def trans_endo(f: Callable[[int], Matrix], n: int, d: int) -> Matrix:
    m = identity(d)
    for t in range(n):
        m = matmul(f(t), m)
    return m


def main() -> None:
    d = 4
    mats = [
        [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]],
        [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 0]],
        [[1, 1, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]],
        [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
        [[1, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
    ]
    frac_mats = [[[Fraction(x) for x in row] for row in M] for M in mats]
    f = lambda k: frac_mats[k] if k < len(frac_mats) else frac_mats[-1]
    n_max = 8
    ranks = [rank(trans_endo(f, n, d)) for n in range(n_max + 1)]
    plt.figure(figsize=(8, 5))
    plt.step(range(n_max + 1), ranks, where="post", linewidth=2, color="#2a6f97")
    plt.scatter(range(n_max + 1), ranks, color="#014f86", zorder=3)
    plt.xlabel("window length n")
    plt.ylabel("rank of transition endomorphism  Phi(0, n)")
    plt.title("Antitone rank filtration of a discrete linear cocycle")
    plt.ylim(-0.5, d + 0.5)
    plt.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig("rank_filtration.png", dpi=150)
    print("Saved rank_filtration.png; ranks =", ranks)


if __name__ == "__main__":
    main()
