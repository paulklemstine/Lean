"""
visualization.py -- Plot chromatic polynomials and illustrate the
deletion-contraction recurrence P(G,k) = P(G+uv,k) + P(G/uv,k).

Standalone: requires only numpy and matplotlib. Saves two figures:
  * chromatic_polynomials.png  -- P(G,k) curves for several small graphs.
  * deletion_contraction.png   -- the recurrence checked term-by-term on a path.
"""

from __future__ import annotations

from itertools import product, combinations

import numpy as np
import matplotlib.pyplot as plt


def is_proper(coloring: tuple[int, ...], edges: list[tuple[int, int]]) -> bool:
    return all(coloring[a] != coloring[b] for a, b in edges)


def chromatic_count(n: int, edges: list[tuple[int, int]], k: int) -> int:
    if k <= 0:
        return 0 if n > 0 else 1
    return sum(
        1 for c in product(range(k), repeat=n) if is_proper(c, edges)
    )


def main() -> None:
    graphs: dict[str, tuple[int, list[tuple[int, int]]]] = {
        "Triangle $K_3$": (3, [(0, 1), (1, 2), (0, 2)]),
        "Path $P_3$": (3, [(0, 1), (1, 2)]),
        "Cycle $C_4$": (4, [(0, 1), (1, 2), (2, 3), (3, 0)]),
        "Complete $K_4$": (4, [(a, b) for a, b in combinations(range(4), 2)]),
    }
    ks = np.arange(0, 7)

    # Figure 1: chromatic polynomial curves.
    plt.figure(figsize=(8, 5))
    for name, (n, edges) in graphs.items():
        ys = [chromatic_count(n, edges, int(k)) for k in ks]
        plt.plot(ks, ys, marker="o", label=name)
    plt.title("Chromatic polynomials $P(G,k)$ (number of proper $k$-colorings)")
    plt.xlabel("number of colors $k$")
    plt.ylabel("$P(G,k)$")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("chromatic_polynomials.png", dpi=150)

    # Figure 2: deletion-contraction on the path a-b-c (contract ends 0,2).
    n, edges = 3, [(0, 1), (1, 2)]
    plus = edges + [(0, 2)]            # triangle
    contr = [(0, 1)]                    # single edge (2 vertices)
    P_G = [chromatic_count(n, edges, int(k)) for k in ks]
    P_add = [chromatic_count(n, plus, int(k)) for k in ks]
    P_con = [chromatic_count(2, contr, int(k)) for k in ks]

    plt.figure(figsize=(8, 5))
    width = 0.35
    plt.bar(ks - width / 2, P_G, width, label="$P(G,k)$ (path)")
    plt.bar(ks + width / 2, np.array(P_add) + np.array(P_con), width,
            label="$P(G{+}uv,k)+P(G/uv,k)$", alpha=0.6)
    plt.title("Deletion-contraction: $P(G,k)=P(G{+}uv,k)+P(G/uv,k)$")
    plt.xlabel("number of colors $k$")
    plt.ylabel("count")
    plt.legend()
    plt.grid(True, axis="y", alpha=0.3)
    plt.tight_layout()
    plt.savefig("deletion_contraction.png", dpi=150)
    print("Saved chromatic_polynomials.png and deletion_contraction.png")


if __name__ == "__main__":
    main()
