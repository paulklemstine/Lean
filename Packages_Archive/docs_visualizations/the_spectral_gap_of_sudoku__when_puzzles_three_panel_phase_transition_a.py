"""
sudoku_visualization.py -- Visualize the Sudoku phase transition.

Produces a figure with three panels:
  (1) Branching factor n^2(1-d) vs clue density d, with the critical line at 1.
  (2) Interaction strength sigma(n) and degree ratio vs order n, with bounds.
  (3) Transition window width 1/n^2 (density) and constant absolute width n^2.

Self-contained; requires only matplotlib and numpy.
Run:  python3 sudoku_visualization.py   (saves sudoku_phase_transition.png)
"""

from __future__ import annotations

from typing import List

import numpy as np
import matplotlib.pyplot as plt


def branching_factor(n: int, d: np.ndarray) -> np.ndarray:
    return (n ** 2) * (1.0 - d)


def critical_density(n: int) -> float:
    return 1.0 - 1.0 / n ** 2


def interaction_strength(n: int) -> float:
    return 2.0 * (n + 1) / (3.0 * n + 1)


def degree_ratio(n: int) -> float:
    return (3.0 * n + 1) / (2.0 * (n + 1))


def main() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

    # Panel 1: branching factor and the critical point.
    d = np.linspace(0, 1, 400)
    for n in (2, 3, 4):
        ax = axes[0]
        ax.plot(d, branching_factor(n, d), label=f"n={n}")
        dc = critical_density(n)
        ax.axvline(dc, ls="--", alpha=0.4)
        ax.plot([dc], [1.0], "o", color="black")
    axes[0].axhline(1.0, color="red", lw=1.2, label="critical branching = 1")
    axes[0].set_xlabel("clue density  d")
    axes[0].set_ylabel("average branching  n^2(1-d)")
    axes[0].set_title("Branching factor and the critical density")
    axes[0].set_ylim(0, 6)
    axes[0].legend()

    # Panel 2: interaction strength and degree ratio.
    ns: List[int] = list(range(2, 13))
    axes[1].plot(ns, [interaction_strength(n) for n in ns], "o-", label="sigma(n)=2(n+1)/(3n+1)")
    axes[1].axhline(2 / 3, color="gray", ls=":", label="lower bound 2/3")
    axes[1].axhline(1.0, color="gray", ls="--", label="upper bound 1")
    axes[1].plot(ns, [degree_ratio(n) for n in ns], "s-", label="degree ratio (3n+1)/(2(n+1))")
    axes[1].axhline(1.5, color="purple", ls="-.", label="asymptote 3/2")
    axes[1].set_xlabel("order  n")
    axes[1].set_title("Interaction strength and degree ratio")
    axes[1].legend()

    # Panel 3: transition window width (density vs absolute).
    axes[2].plot(ns, [1.0 / n ** 2 for n in ns], "o-", label="density width 1/n^2")
    axes[2].plot(ns, [(n ** 4) * (1.0 / n ** 2) / n ** 2 for n in ns], "s-",
                 label="absolute width / n^2 (= 1)")
    axes[2].set_xlabel("order  n")
    axes[2].set_title("Transition window: sharper but constant absolute slack")
    axes[2].legend()

    fig.suptitle("The Spectral Gap of Sudoku: a constraint-counting phase transition",
                 fontsize=14)
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("sudoku_phase_transition.png", dpi=130)
    print("saved sudoku_phase_transition.png")


if __name__ == "__main__":
    main()
