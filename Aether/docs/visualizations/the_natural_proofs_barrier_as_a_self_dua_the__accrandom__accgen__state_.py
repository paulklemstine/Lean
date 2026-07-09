"""
Visualization of the natural proofs barrier as a self-dual counting law.

Left panel:  the (accRandom, accGen) state plane. Useful properties live on the
             accGen = 0 axis; the advantage is the horizontal distance to the
             diagonal accRandom = accGen. The delta-largeness and
             delta-pseudorandomness regions are shaded, and their intersection
             on the useful axis is EMPTY -- this emptiness is the barrier.

Right panel: maximal distinguishing advantage 1 - |image G| / 2**m of the
             membership test, as a function of the number of seeds, showing how
             a seed-bounded generator is always distinguishable in principle.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List

import numpy as np
import matplotlib.pyplot as plt


def max_advantage(num_seeds: int, m: int) -> float:
    """Maximal advantage 1 - |image|/2**m, with |image| <= min(num_seeds, 2**m)."""
    image_size = min(num_seeds, 2 ** m)
    return 1.0 - image_size / (2 ** m)


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.5))

    # ----- Left: the (accRandom, accGen) state plane -----
    ax1.plot([0, 1], [0, 1], "k--", lw=1, label="advantage = 0 (accR = accG)")
    # The useful axis: accGen = 0.
    ax1.plot([0, 1], [0, 0], color="tab:blue", lw=3, label="useful tests (accGen = 0)")

    delta = 0.5
    # delta-largeness region: accRandom >= delta.
    ax1.axvspan(delta, 1.0, color="tab:green", alpha=0.12,
                label=r"$\delta$-large ($accR \geq \delta$)")
    # delta-pseudorandom region: accRandom - accGen < delta.
    xs = np.linspace(0, 1, 200)
    ax1.fill_between(xs, np.maximum(xs - delta, 0.0), 1.0,
                     color="tab:orange", alpha=0.12,
                     label=r"$\delta$-pseudorandom ($accR-accG<\delta$)")

    # A natural property (large + useful) -> big advantage, breaks pseudorandomness.
    ax1.scatter([0.8], [0.0], color="tab:red", zorder=5, s=70)
    ax1.annotate("natural property\n(large + useful)\nadvantage = 0.8",
                 (0.8, 0.0), textcoords="offset points", xytext=(-30, 30),
                 fontsize=9, ha="center")
    ax1.axvline(delta, color="gray", lw=0.8)
    ax1.set_xlabel("accRandom (density)")
    ax1.set_ylabel("accGen (generator acceptance)")
    ax1.set_title("State plane: useful axis meets large region\noutside the pseudorandom zone")
    ax1.set_xlim(0, 1)
    ax1.set_ylim(-0.05, 1)
    ax1.legend(fontsize=7, loc="upper left")

    # ----- Right: maximal advantage vs. number of seeds -----
    m = 6  # 2**6 = 64 truth tables
    seed_counts: List[int] = list(range(1, 2 ** m + 1))
    advs = [max_advantage(k, m) for k in seed_counts]
    ax2.plot(seed_counts, advs, color="tab:purple", lw=2)
    ax2.fill_between(seed_counts, advs, color="tab:purple", alpha=0.15)
    ax2.set_xlabel(f"number of seeds |S|  (space size 2^{m} = {2**m})")
    ax2.set_ylabel("maximal advantage  1 - |image|/2^m")
    ax2.set_title("Seed-bounded generators are always\ndistinguishable (membership test)")
    ax2.grid(alpha=0.3)

    fig.suptitle("The Natural Proofs Barrier as a Self-Dual Counting Law",
                 fontsize=13, fontweight="bold")
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("natural_proofs_barrier.png", dpi=150)
    print("Saved natural_proofs_barrier.png")


if __name__ == "__main__":
    main()
