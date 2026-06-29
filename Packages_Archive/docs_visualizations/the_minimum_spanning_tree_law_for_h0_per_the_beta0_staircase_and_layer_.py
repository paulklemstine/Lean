"""
Visualization: the beta0 component-count staircase and the layer-cake equality.

Renders the descending step function beta0(D, t) for a death multiset D, shades
the area equal to total H0 persistence, and overlays the truncated-death-sum
decomposition (one horizontal slab per death). Requires matplotlib.

Run:  python3 _viz_staircase.py
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt


def alive_count(deaths: List[int], t: int) -> int:
    return sum(1 for d in deaths if t < d)


def beta0(deaths: List[int], t: int) -> int:
    return 1 + alive_count(deaths, t)


def plot_staircase(deaths: List[int], horizon: int) -> None:
    ts = list(range(horizon + 1))
    ys = [beta0(deaths, t) for t in ts]

    fig, ax = plt.subplots(figsize=(9, 5))
    # Step function for beta0
    ax.step(ts, ys, where="post", color="#1f3b73", linewidth=2.5,
            label=r"$\beta_0(t)$ (component count)")
    # Shade area under (beta0 - 1) = total persistence
    for t in range(horizon):
        h = beta0(deaths, t) - 1
        if h > 0:
            ax.add_patch(plt.Rectangle((t, 1), 1, h, color="#7aa6ff",
                                       alpha=0.35, ec="white"))
    ax.axhline(1, color="#b03030", linestyle="--", linewidth=1.2,
               label="essential floor (1 component)")

    P = sum(beta0(deaths, t) - 1 for t in range(horizon))
    tds = sum(min(d, horizon) for d in deaths)
    ax.set_title(f"H0 staircase for D = {sorted(deaths)}    "
                 f"area = {P} = sum min(d,T) = {tds} = MST weight")
    ax.set_xlabel("filtration threshold  t")
    ax.set_ylabel(r"$\beta_0(t)$")
    ax.set_xticks(ts)
    ax.set_yticks(range(0, max(ys) + 1))
    ax.set_xlim(0, horizon)
    ax.set_ylim(0, max(ys) + 0.5)
    ax.legend(loc="upper right")
    ax.grid(alpha=0.2)
    fig.tight_layout()
    fig.savefig("staircase.png", dpi=150)
    print("Wrote staircase.png")


if __name__ == "__main__":
    plot_staircase([1, 2, 4], 7)
