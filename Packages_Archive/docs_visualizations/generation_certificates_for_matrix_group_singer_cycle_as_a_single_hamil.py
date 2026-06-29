"""
Visualization: Singer-cycle orbit over F_2^n as a single Hamiltonian-like cycle.

A companion matrix of a primitive polynomial over F_2 permutes all 2^n - 1
nonzero vectors in one orbit (Theorem 2 / Singer specialization). We lay the
orbit out on a circle and draw the successor edges, visually confirming the
single full cycle.
"""
from __future__ import annotations
from typing import List, Tuple
import math
import matplotlib.pyplot as plt


def mat_vec(M, v, p):
    n = len(M)
    return tuple(sum(M[i][j] * v[j] for j in range(n)) % p for i in range(n))


def main() -> None:
    p, n = 2, 4
    poly = (1, 1, 0, 0, 1)  # X^4 + X + 1, primitive over F_2
    M = tuple(
        tuple((1 if i == j + 1 else 0) if j < n - 1 else (-poly[i]) % p
              for j in range(n))
        for i in range(n)
    )
    v0 = tuple(1 if i == 0 else 0 for i in range(n))
    orbit: List[Tuple[int, ...]] = []
    cur = v0
    while True:
        orbit.append(cur)
        cur = mat_vec(M, cur, p)
        if cur == v0:
            break
    N = len(orbit)
    angles = [2 * math.pi * k / N for k in range(N)]
    xs = [math.cos(a) for a in angles]
    ys = [math.sin(a) for a in angles]
    plt.figure(figsize=(7, 7))
    for k in range(N):
        x1, y1 = xs[k], ys[k]
        x2, y2 = xs[(k + 1) % N], ys[(k + 1) % N]
        plt.annotate("", xy=(x2, y2), xytext=(x1, y1),
                     arrowprops=dict(arrowstyle="->", color="steelblue", alpha=0.7))
    plt.scatter(xs, ys, c="crimson", zorder=3)
    for k, vec in enumerate(orbit):
        plt.text(xs[k] * 1.12, ys[k] * 1.12, "".join(map(str, vec)),
                 ha="center", va="center", fontsize=8)
    plt.title(f"Singer cycle on F_2^{n}: {N} nonzero states in one orbit")
    plt.axis("equal"); plt.axis("off")
    plt.tight_layout()
    plt.savefig("singer_orbit.png", dpi=130)
    print(f"orbit length {N} (max {2**n - 1}); saved singer_orbit.png")


if __name__ == "__main__":
    main()
