"""Visualize Erdős–Rényi threshold phenomena with matplotlib.

Produces a 2x2 panel:
  (a) triangle mean C(n,3)(c/n)^3 vs n approaching the Poisson limit c^3/6;
  (b) subcritical / critical / supercritical triangle trajectories;
  (c) expected isolated vertices at p=c/n (diverges) vs p=ln n/n (-> O(1));
  (d) clique-hierarchy expectations C(n,r)p^(C(r,2)) over a sweep of p.
"""
from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt


def expected_triangles(n: int, p: float) -> float:
    return math.comb(n, 3) * p ** 3


def expected_isolated(n: int, p: float) -> float:
    return n * (1.0 - p) ** (n - 1)


def expected_cliques(n: int, r: int, p: float) -> float:
    return math.comb(n, r) * p ** math.comb(r, 2)


def main() -> None:
    fig, ax = plt.subplots(2, 2, figsize=(12, 9))

    # (a) Poisson convergence
    ns: List[int] = [n for n in range(10, 3000, 10)]
    for c in (1.0, 2.0, 3.0):
        ax[0, 0].plot(ns, [expected_triangles(n, c / n) for n in ns], label=f"c={c}")
        ax[0, 0].axhline(c ** 3 / 6, ls="--", color="grey", lw=0.8)
    ax[0, 0].set_title("Triangle mean -> c^3/6 at p=c/n")
    ax[0, 0].set_xlabel("n"); ax[0, 0].set_ylabel("E[#triangles]"); ax[0, 0].legend()

    # (b) regimes
    for c in (0.5, 1.0, 2.0):
        ax[0, 1].plot(ns, [expected_triangles(n, c / n) for n in ns], label=f"c={c}")
    ax[0, 1].set_title("Sub/critical/super at p=c/n")
    ax[0, 1].set_xlabel("n"); ax[0, 1].set_ylabel("E[#triangles]"); ax[0, 1].legend()

    # (c) two thresholds
    big = [n for n in range(50, 20000, 50)]
    ax[1, 0].plot(big, [expected_isolated(n, 1.0 / n) for n in big], label="p=1/n")
    ax[1, 0].plot(big, [expected_isolated(n, math.log(n) / n) for n in big],
                  label="p=ln n / n")
    ax[1, 0].set_yscale("log")
    ax[1, 0].set_title("Isolated vertices: giant vs connectivity scale")
    ax[1, 0].set_xlabel("n"); ax[1, 0].set_ylabel("E[#isolated] (log)"); ax[1, 0].legend()

    # (d) clique hierarchy sweep
    n = 5000
    ps = [10 ** (-k / 20) for k in range(20, 100)]
    for r in (3, 4, 5):
        ax[1, 1].plot(ps, [expected_cliques(n, r, p) for p in ps], label=f"K_{r}")
    ax[1, 1].set_xscale("log"); ax[1, 1].set_yscale("log")
    ax[1, 1].axhline(1.0, ls="--", color="grey", lw=0.8)
    ax[1, 1].set_title(f"Clique hierarchy E[#K_r] at n={n}")
    ax[1, 1].set_xlabel("p (log)"); ax[1, 1].set_ylabel("E[#K_r] (log)"); ax[1, 1].legend()

    fig.tight_layout()
    fig.savefig("erdos_renyi_thresholds.png", dpi=150)
    print("saved erdos_renyi_thresholds.png")


if __name__ == "__main__":
    main()
