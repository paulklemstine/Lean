"""
Visualization: the genus-zero Riemann-Roch balance and the genus-one obstruction.

Left panel: for a tree, plots r(D), r(K-D), and deg(D)+1 against deg(D), showing
that r(D) - r(K-D) = deg(D) + 1 (the Riemann-Roch line) holds exactly.

Right panel: the chip-firing lattice of the 2-edge banana, showing that all
principal divisors land on even first-coordinates, so (1,-1) is unreachable from
(0,0) -- the genus-one obstruction.
"""

from __future__ import annotations

import matplotlib.pyplot as plt


def tree_rank(deg_D: int) -> int:
    """On a tree, r(D) = deg D if deg D >= 0 else -1."""
    return deg_D if deg_D >= 0 else -1


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # Genus 0: K has degree -2, so r(K-D) = tree_rank(-2 - deg_D).
    degs = list(range(-4, 7))
    rD = [tree_rank(d) for d in degs]
    rKD = [tree_rank(-2 - d) for d in degs]
    lhs = [a - b for a, b in zip(rD, rKD)]
    rhs = [d + 1 for d in degs]

    ax1.plot(degs, rD, "o-", label="r(D)")
    ax1.plot(degs, rKD, "s-", label="r(K-D)")
    ax1.plot(degs, lhs, "^--", label="r(D) - r(K-D)")
    ax1.plot(degs, rhs, "k:", lw=2, label="deg D + 1")
    ax1.axhline(0, color="gray", lw=0.5)
    ax1.set_xlabel("deg D")
    ax1.set_ylabel("rank")
    ax1.set_title("Genus-0 Riemann-Roch:  r(D) - r(K-D) = deg D + 1")
    ax1.legend()
    ax1.grid(alpha=0.3)

    # Genus 1 banana: principal divisors (2(t-s), 2(s-t)).
    xs, ys = [], []
    for s in range(-3, 4):
        for t in range(-3, 4):
            xs.append(2 * (t - s))
            ys.append(2 * (s - t))
    ax2.scatter(xs, ys, c="tab:blue", label="prin(s,t) (reachable from 0)")
    ax2.scatter([0], [0], c="green", s=120, marker="*", label="(0,0)")
    ax2.scatter([1], [-1], c="red", s=120, marker="X",
                label="(1,-1): UNREACHABLE")
    ax2.set_xlabel("chips at a")
    ax2.set_ylabel("chips at b")
    ax2.set_title("Genus-1 obstruction: principal divisors on the banana")
    ax2.legend()
    ax2.grid(alpha=0.3)
    ax2.set_aspect("equal", adjustable="box")

    plt.tight_layout()
    plt.savefig("riemann_roch_graph.png", dpi=150)
    print("saved riemann_roch_graph.png")


if __name__ == "__main__":
    main()
