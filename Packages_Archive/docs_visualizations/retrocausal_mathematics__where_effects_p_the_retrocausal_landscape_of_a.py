"""
Visualization: the retrocausal landscape of a finite Heyting chain.
===================================================================

Generates a figure with two panels:

  (left)  the n-element Heyting chain bottom < ... < top, showing for each
          element a the values of  a v a^c (LEM) and (a v a^c)^cc (TEM),
          highlighting where the law of excluded middle fails while the
          temporal excluded middle persists;

  (right) the action of the retrocausal involution rev on the chain as an
          order-reversing permutation (a "time-reversal" arrow diagram).

Run:  python visualize.py   ->  writes retrocausal_landscape.png
Requires: matplotlib.
"""

from __future__ import annotations

from typing import List
import matplotlib.pyplot as plt


def chain_compl(i: int, n: int) -> int:
    """Pseudo-complement in the n-chain 0 < 1 < ... < n-1:
    a^c = top if a = bottom, else bottom."""
    return n - 1 if i == 0 else 0


def chain_lem(i: int, n: int) -> int:
    return max(i, chain_compl(i, n))


def chain_dneg(i: int, n: int) -> int:
    return chain_compl(chain_compl(i, n), n)


def chain_tem(i: int, n: int) -> int:
    return chain_dneg(chain_lem(i, n), n)


def main() -> None:
    n: int = 5
    elements: List[int] = list(range(n))

    fig, (axL, axR) = plt.subplots(1, 2, figsize=(13, 6))

    # ---- Left: LEM vs TEM per element -------------------------------------
    lem_vals = [chain_lem(i, n) for i in elements]
    tem_vals = [chain_tem(i, n) for i in elements]
    lem_fail = [i for i in elements if chain_lem(i, n) != n - 1]

    axL.plot(elements, lem_vals, "o-", color="#c0392b", label="a v a^c  (LEM)")
    axL.plot(elements, tem_vals, "s--", color="#2980b9", label="(a v a^c)^cc  (TEM)")
    axL.axhline(n - 1, color="gray", lw=0.8, ls=":")
    for i in lem_fail:
        axL.annotate("LEM fails", (i, chain_lem(i, n)),
                     textcoords="offset points", xytext=(0, -22),
                     ha="center", color="#c0392b", fontsize=9)
    axL.set_xticks(elements)
    axL.set_xlabel("element a  (0 = bottom, %d = top)" % (n - 1))
    axL.set_ylabel("value in the chain")
    axL.set_title("Excluded middle dies, temporal excluded middle survives")
    axL.legend(loc="lower right")
    axL.grid(alpha=0.3)

    # ---- Right: rev as order-reversing involution -------------------------
    rev = [n - 1 - i for i in elements]
    axR.set_xlim(-0.5, 1.5)
    axR.set_ylim(-0.5, n - 0.5)
    for i in elements:
        axR.scatter([0], [i], s=120, color="#27ae60")
        axR.scatter([1], [i], s=120, color="#8e44ad")
        axR.annotate("", xy=(1, rev[i]), xytext=(0, i),
                     arrowprops=dict(arrowstyle="->", color="#7f8c8d", lw=1.2))
        axR.text(-0.15, i, f"{i}", ha="right", va="center")
        axR.text(1.15, i, f"{i}", ha="left", va="center")
    axR.text(0, n - 0.3, "a", ha="center", fontsize=12, weight="bold")
    axR.text(1, n - 0.3, "rev a", ha="center", fontsize=12, weight="bold")
    axR.set_title("Time-reversal rev: order-reversing involution")
    axR.axis("off")

    fig.suptitle("The Retrocausal Landscape of a Heyting Chain", fontsize=14)
    fig.tight_layout()
    fig.savefig("retrocausal_landscape.png", dpi=150)
    print("wrote retrocausal_landscape.png")


if __name__ == "__main__":
    main()
