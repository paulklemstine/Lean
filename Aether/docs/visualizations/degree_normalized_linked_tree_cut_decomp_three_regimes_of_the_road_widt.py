"""Visualization of degree-normalized adhesion-size rays.

Plots the adhesion-size sequence |F_{e_n}| along a root-to-end ray for the three
regimes of the dichotomy (Theorem 4): finite (antitone, stabilizing exactly at
the displayed edge-degree), infinite (monotone, diverging), and the forbidden
oscillating ray that violates normalization. Saves 'degree_normalization.png'.
"""

from __future__ import annotations

import matplotlib.pyplot as plt


def displayed_edge_degree(sizes: list[int]) -> int:
    return min(sizes)


def main() -> None:
    n_steps = 16
    finite = [max(3, 11 - n) for n in range(n_steps)]           # antitone -> 3
    infinite = [n // 2 + 1 for n in range(n_steps)]             # monotone -> infinity
    oscillating = [1 if n % 2 == 0 else 2 for n in range(n_steps)]
    xs = list(range(n_steps))

    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5), sharey=False)

    d = displayed_edge_degree(finite)
    axes[0].step(xs, finite, where="post", color="#1f77b4", linewidth=2)
    axes[0].axhline(d, color="#1f77b4", ls="--", alpha=0.6,
                    label=f"displayedEdgeDegree = {d}")
    axes[0].set_title("Finite end (Theorem 1)\nstabilizes EXACTLY at the degree")
    axes[0].legend()

    axes[1].step(xs, infinite, where="post", color="#2ca02c", linewidth=2)
    for k in (3, 5, 7):
        axes[1].axhline(k, color="gray", ls=":", alpha=0.4)
    axes[1].set_title("Infinite end (Theorem 3)\ndiverges past every k")

    axes[2].step(xs, oscillating, where="post", color="#d62728", linewidth=2)
    axes[2].set_title("Oscillating ray (FORBIDDEN)\nbreaks the dichotomy")

    for ax in axes:
        ax.set_xlabel("step n along the ray")
        ax.set_ylabel(r"$|F_{e_n}|$")
        ax.grid(alpha=0.3)

    fig.suptitle("Degree normalization: width of the road toward an end",
                 fontsize=14)
    fig.tight_layout()
    fig.savefig("degree_normalization.png", dpi=140)
    print("saved degree_normalization.png")


if __name__ == "__main__":
    main()
