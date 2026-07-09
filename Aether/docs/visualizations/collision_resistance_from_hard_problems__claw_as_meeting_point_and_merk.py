"""Visualization: the collision-claw bipartite picture and MD chaining.

Generates two panels:
  (1) The two permutations g0, g1 as a bipartite map on Z/n, highlighting a
      claw  g0(x) = g1(y)  as a meeting point (the collision-claw identity).
  (2) The Merkle-Damgard chaining values for two equal-length messages that
      collide, showing the last-block extraction point.

Requires: matplotlib, numpy.  Run:  python pkg_viz.py
"""

from __future__ import annotations

from typing import Callable, List

import matplotlib.pyplot as plt


def affine(a: int, c: int, n: int) -> Callable[[int], int]:
    return lambda x: (a * x + c) % n


def main() -> None:
    n = 7
    g0 = affine(2, 1, n)
    g1 = affine(3, 5, n)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 6))

    # Panel 1: claw as a meeting point.
    for x in range(n):
        ax1.plot([0, 1], [x, g0(x)], color="tab:blue", alpha=0.5)
        ax1.plot([2, 1], [x, g1(x)], color="tab:red", alpha=0.5)
    # highlight the claw g0(x)=g1(y)
    claw = next((x, y) for x in range(n) for y in range(n) if g0(x) == g1(y))
    cx, cy = claw
    ax1.plot([0, 1], [cx, g0(cx)], color="black", lw=3, label="g0 branch (claw)")
    ax1.plot([2, 1], [cy, g1(cy)], color="green", lw=3, label="g1 branch (claw)")
    ax1.scatter([1], [g0(cx)], color="gold", s=200, zorder=5,
                edgecolor="black", label=f"meeting state = {g0(cx)}")
    ax1.set_xticks([0, 1, 2])
    ax1.set_xticklabels(["input x", "state", "input y"])
    ax1.set_title(f"Claw = collision: g0({cx})={g0(cx)}=g1({cy}) on Z/{n}")
    ax1.legend(loc="upper center")

    # Panel 2: MD chaining for two colliding equal-length messages.
    def claw_compress(s: int, b: int) -> int:
        return g1(s) if b else g0(s)

    def md_chain(msg: List[int], iv: int = 0) -> List[int]:
        out = [iv]
        for b in msg:
            out.append(claw_compress(out[-1], b))
        return out

    m1, m2 = [0, 0, 0], [0, 0, 1]
    c1, c2 = md_chain(m1), md_chain(m2)
    ax2.plot(range(len(c1)), c1, "o-", color="tab:blue", label=f"m1={m1}")
    ax2.plot(range(len(c2)), c2, "s--", color="tab:red", label=f"m2={m2}")
    ax2.axvline(len(c1) - 1, color="gray", ls=":", alpha=0.7)
    ax2.set_xlabel("block index")
    ax2.set_ylabel("chaining value")
    ax2.set_title("Merkle-Damgard collision: equal final hash")
    ax2.legend()

    fig.suptitle("Collision Resistance from Claw-Free Pairs", fontsize=14)
    fig.tight_layout()
    fig.savefig("clawfree_visualization.png", dpi=150)
    print("saved clawfree_visualization.png")


if __name__ == "__main__":
    main()
