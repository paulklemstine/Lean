"""Visualization: q-game probability sequences and convergence.

Generates two panels:
  (left)  formalized normalization P(q,0)=1, sequences for q=1..5;
  (right) game-theoretic normalization P(0,q)=0 with the 1-1/e asymptote.
Saves to qgame_sequences.png.
"""
from fractions import Fraction
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def q_game_prefix(q: int, N: int, base: Fraction) -> List[Fraction]:
    vals: List[Fraction] = [base]
    running, covered = Fraction(0), 0
    for m in range(1, N + 1):
        top = max(m - q, 0)
        while covered < top:
            running += vals[covered]
            covered += 1
        vals.append((Fraction(1) + running) / m)
    return vals


def main() -> None:
    N = 60
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    for q in range(1, 6):
        ys = [float(v) for v in q_game_prefix(q, N, Fraction(1))]
        ax1.plot(range(N + 1), ys, marker=".", label=f"q={q}")
    ax1.set_title("Formalized normalization  P(q,0)=1")
    ax1.set_xlabel("n"); ax1.set_ylabel("P(q,n)")
    ax1.set_ylim(0, 1.05); ax1.grid(alpha=0.3); ax1.legend()

    for q in range(1, 6):
        ys = [float(v) for v in q_game_prefix(q, N, Fraction(0))]
        ax2.plot(range(N + 1), ys, marker=".", label=f"q={q}")
    asymptote = 1 - np.exp(-1)
    ax2.axhline(asymptote, color="k", ls="--", lw=1, label="1 - 1/e")
    ax2.set_title("Game normalization  P(0,q)=0")
    ax2.set_xlabel("n"); ax2.set_ylabel("P(n,q)")
    ax2.set_ylim(0, 1.05); ax2.grid(alpha=0.3); ax2.legend()

    fig.suptitle("Generalized q-game winning probability")
    fig.tight_layout()
    fig.savefig("qgame_sequences.png", dpi=150)
    print("saved qgame_sequences.png")


if __name__ == "__main__":
    main()
