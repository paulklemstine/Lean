"""Visualization: the Parity Paradox and the decaying parity defect.

Generates two panels:
  (left)  P(v, 1) vs v, highlighting the down-steps where adding a villager hurts.
  (right) the parity defect D(v, 1) decaying toward 1.

Saves 'werewolf_parity.png'. Requires matplotlib.
"""

from __future__ import annotations

from fractions import Fraction
from functools import lru_cache
from typing import List

import matplotlib.pyplot as plt


@lru_cache(maxsize=None)
def win_prob(v: int, w: int) -> Fraction:
    if w == 0:
        return Fraction(1, 1)
    if v <= w:
        return Fraction(0, 1)
    total = v + w
    after_wolf = Fraction(1, 1) if w == 1 else win_prob(v - 1, w - 1)
    after_villager = Fraction(0, 1) if v <= w + 2 else win_prob(v - 2, w)
    return Fraction(w, total) * after_wolf + Fraction(v, total) * after_villager


def main() -> None:
    vs: List[int] = list(range(2, 21))
    ps: List[float] = [float(win_prob(v, 1)) for v in vs]
    defects: List[float] = [float(win_prob(v, 1) / win_prob(v + 1, 1)) for v in vs]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(vs, ps, "o-", color="#2c6fbb", label="P(v, 1)")
    for v, p, pn in zip(vs, ps, ps[1:]):
        if pn < p:  # down-step: adding a villager hurt
            ax1.annotate("", xy=(v + 1, pn), xytext=(v, p),
                         arrowprops=dict(arrowstyle="->", color="crimson", lw=2))
    ax1.set_title("Parity Paradox: red arrows are where +1 villager HURTS")
    ax1.set_xlabel("villagers v (one werewolf)")
    ax1.set_ylabel("villager win probability")
    ax1.grid(True, alpha=0.3)
    ax1.legend()

    ax2.plot(vs, defects, "s-", color="#b8492c", label="D(v, 1) = P(v,1)/P(v+1,1)")
    ax2.axhline(1.0, color="gray", ls="--", label="D = 1 (no paradox)")
    ax2.set_title("Parity defect decays toward 1")
    ax2.set_xlabel("villagers v (one werewolf)")
    ax2.set_ylabel("parity defect D(v, 1)")
    ax2.grid(True, alpha=0.3)
    ax2.legend()

    fig.tight_layout()
    fig.savefig("werewolf_parity.png", dpi=140)
    print("wrote werewolf_parity.png")


if __name__ == "__main__":
    main()
