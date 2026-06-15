"""Visualization: the staircase of d(A)=ceil(log2 |A|) vs the continuous log2,
plus the k-ary cost curves. Saves observation_complexity.png."""
from __future__ import annotations
import math
from typing import List
import matplotlib.pyplot as plt


def clog(base: int, n: int) -> int:
    if base <= 1 or n <= 1:
        return 0
    k, power = 0, 1
    while power < n:
        power *= base
        k += 1
    return k


def main() -> None:
    cards: List[int] = list(range(1, 130))
    binary: List[int] = [clog(2, c) for c in cards]
    cont: List[float] = [math.log2(c) if c >= 1 else 0.0 for c in cards]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    ax1.step(cards, binary, where="post", label=r"$d(A)=\lceil\log_2|A|\rceil$", color="crimson")
    ax1.plot(cards, cont, "--", color="gray", label=r"$\log_2|A|$ (continuous)")
    ax1.axvline(100, color="navy", ls=":", alpha=0.7)
    ax1.scatter([100], [clog(2, 100)], color="navy", zorder=5)
    ax1.annotate("Fin 100 -> 7", (100, 7), textcoords="offset points", xytext=(-70, 8), color="navy")
    ax1.set_xlabel("|A| (number of elements)")
    ax1.set_ylabel("minimum observations")
    ax1.set_title("Exact Boolean query complexity")
    ax1.legend()
    ax1.grid(alpha=0.3)

    for k, color in [(2, "crimson"), (3, "darkorange"), (10, "seagreen")]:
        ax2.step(cards, [clog(k, c) for c in cards], where="post",
                 label=fr"$\lceil\log_{{{k}}}|A|\rceil$", color=color)
    ax2.set_xlabel("|A|")
    ax2.set_ylabel("minimum k-ary observations")
    ax2.set_title("Richer alphabets need fewer observations")
    ax2.legend()
    ax2.grid(alpha=0.3)

    fig.suptitle("The Observation Complexity Theorem", fontsize=14, fontweight="bold")
    fig.tight_layout()
    fig.savefig("observation_complexity.png", dpi=150)
    print("saved observation_complexity.png")


if __name__ == "__main__":
    main()
