"""Visualization: the orthogonal Hodge decomposition on a small graph.

Generates a figure showing, for a weighted path/cycle graph, an arbitrary
edge cochain decomposed into its flowing (gradient) part d u and its harmonic
remainder h, illustrating that the two are orthogonal in the weighted inner
product and that diffusion melts the flowing part while h is preserved.

Requires matplotlib. Run:  python3 _assets_visualization.py
"""

from __future__ import annotations

from typing import List
import matplotlib.pyplot as plt

Matrix = List[List[float]]
Vector = List[float]


def transpose(a: Matrix) -> Matrix:
    return [list(c) for c in zip(*a)] if a else []


def matmul(a: Matrix, b: Matrix) -> Matrix:
    bt = transpose(b)
    return [[sum(x * y for x, y in zip(r, c)) for c in bt] for r in a]


def matvec(a: Matrix, v: Vector) -> Vector:
    return [sum(aij * vj for aij, vj in zip(row, v)) for row in a]


def codiff(d: Matrix, src: Vector, tgt: Vector) -> Matrix:
    inv = [1.0 / w for w in src]
    dt = transpose(d)
    return [[inv[j] * dt[j][i] * tgt[i] for i in range(len(d))]
            for j in range(len(dt))]


def solve(a: Matrix, b: Vector, ridge: float = 1e-9) -> Vector:
    k = len(a)
    m = [[a[i][j] + (ridge if i == j else 0.0) for j in range(k)] + [b[i]]
         for i in range(k)]
    for col in range(k):
        piv = max(range(col, k), key=lambda r: abs(m[r][col]))
        m[col], m[piv] = m[piv], m[col]
        p = m[col][col]
        if abs(p) < 1e-15:
            continue
        for r in range(k):
            if r != col and abs(m[r][col]) > 1e-15:
                f = m[r][col] / p
                m[r] = [m[r][c] - f * m[col][c] for c in range(k + 1)]
    return [m[i][k] / m[i][i] if abs(m[i][i]) > 1e-15 else 0.0 for i in range(k)]


def main() -> None:
    # 4-cycle: vertices 0-1-2-3-0, so ker(delta) is nontrivial (one harmonic loop).
    d: Matrix = [[-1, 1, 0, 0],
                 [0, -1, 1, 0],
                 [0, 0, -1, 1],
                 [1, 0, 0, -1]]
    d = [[float(x) for x in row] for row in d]
    src: Vector = [1.0, 1.0, 1.0, 1.0]
    tgt: Vector = [1.0, 1.0, 1.0, 1.0]

    delta = codiff(d, src, tgt)
    lap_up = matmul(delta, d)

    x: Vector = [1.5, -0.5, 2.0, 0.3]  # arbitrary edge cochain
    b = matvec(delta, x)
    u = solve(lap_up, b)
    flow = matvec(d, u)
    harm = [xi - fi for xi, fi in zip(x, flow)]

    edges = ["e01", "e12", "e23", "e30"]
    idx = range(len(edges))

    fig, axes = plt.subplots(1, 3, figsize=(13, 4), sharey=True)
    axes[0].bar(idx, x, color="#4C72B0")
    axes[0].set_title("Original cochain x")
    axes[1].bar(idx, flow, color="#DD8452")
    axes[1].set_title("Flowing part  d u  (gradient)")
    axes[2].bar(idx, harm, color="#55A868")
    axes[2].set_title("Harmonic part  h  (delta h = 0)")
    for ax in axes:
        ax.set_xticks(list(idx))
        ax.set_xticklabels(edges)
        ax.axhline(0, color="k", lw=0.6)
    dot = sum(t * f * h for t, f, h in zip(tgt, flow, harm))
    fig.suptitle(f"Hodge decomposition on a 4-cycle   "
                 f"<d u, h>_tgt = {dot:.2e}  (orthogonal)")
    fig.tight_layout()
    fig.savefig("hodge_decomposition.png", dpi=150)
    print("wrote hodge_decomposition.png ; orthogonality dot =", dot)


if __name__ == "__main__":
    main()
