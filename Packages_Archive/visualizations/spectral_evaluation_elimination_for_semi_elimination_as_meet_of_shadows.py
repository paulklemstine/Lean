"""Visualization: elimination as the meet of evaluation-contraction shadows.

Standalone script (matplotlib only). Produces a two-panel figure:

  (left)  the congruence lattice picture: the true elimination Elim(C) sits
          *below* every evaluation contraction Contr_phi(C), and equals their
          meet ElimEval(C) under the separation property (Theorem 6.3).

  (right) the geometric shadow picture over the reals: the parabola y = x^2 and
          several "guessed sections" phi(y) = c; the projection onto the x-axis
          is recovered as the agreement of the section-induced shadows.

Run:  python3 _assets_viz.py   ->   writes spectral_elimination.png
"""

from __future__ import annotations

import matplotlib.pyplot as plt
import numpy as np


def make_figure(path: str = "spectral_elimination.png") -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.5))

    # ---- Left panel: lattice / meet diagram ------------------------------- #
    ax1.set_title("Elimination = meet of evaluation contractions", fontsize=12)
    contractions = [(1.0, 3.2, r"$Contr_{\phi_1}(C)$"),
                    (3.0, 3.2, r"$Contr_{\phi_2}(C)$"),
                    (5.0, 3.2, r"$Contr_{\phi_3}(C)$")]
    meet = (3.0, 1.0, r"$Elim(C)=\bigwedge_\phi Contr_\phi(C)$")
    top = (3.0, 5.0, r"$\top$ (total congruence)")
    for x, y, label in contractions:
        ax1.scatter([x], [y], s=120, color="#2b8cbe", zorder=3)
        ax1.annotate(label, (x, y), textcoords="offset points",
                     xytext=(0, 12), ha="center", fontsize=10)
        ax1.plot([x, meet[0]], [y, meet[1]], color="#7f7f7f", lw=1.3, zorder=1)
        ax1.plot([x, top[0]], [y, top[1]], color="#cccccc", lw=1.0, zorder=0)
    ax1.scatter([meet[0]], [meet[1]], s=180, color="#e34a33", zorder=4)
    ax1.annotate(meet[2], (meet[0], meet[1]), textcoords="offset points",
                 xytext=(0, -22), ha="center", fontsize=10, color="#e34a33")
    ax1.scatter([top[0]], [top[1]], s=120, color="#636363", zorder=3)
    ax1.annotate(top[2], (top[0], top[1]), textcoords="offset points",
                 xytext=(0, 12), ha="center", fontsize=10)
    ax1.set_xlim(-0.5, 6.5)
    ax1.set_ylim(0, 6)
    ax1.axis("off")
    ax1.text(3.0, 0.2, "finer  $\\leq$  coarser   (downward = finer)",
             ha="center", fontsize=9, color="#555555")

    # ---- Right panel: geometric projection / sections --------------------- #
    ax2.set_title("Guessed sections and the projected shadow", fontsize=12)
    x = np.linspace(-2.2, 2.2, 400)
    ax2.plot(x, x**2, color="#252525", lw=2, label=r"variety $y=x^2$")
    for c, col in zip([0.5, 1.5, 3.0], ["#2b8cbe", "#31a354", "#e6550d"]):
        ax2.axhline(c, color=col, lw=1.0, ls="--", alpha=0.7)
        xs = np.sqrt(c)
        for s in (-xs, xs):
            ax2.scatter([s], [c], color=col, s=40, zorder=3)
            ax2.plot([s, s], [0, c], color=col, lw=0.8, ls=":", alpha=0.7)
            ax2.scatter([s], [0], color=col, s=40, zorder=3)
        ax2.text(2.05, c, rf"$\phi:\,y={c}$", color=col, fontsize=9, va="center")
    ax2.axhline(0, color="#999999", lw=1.0)
    ax2.set_xlabel("retained variable  x")
    ax2.set_ylabel("eliminated variable  y")
    ax2.set_xlim(-2.4, 2.7)
    ax2.set_ylim(-0.4, 4.2)
    ax2.legend(loc="upper left", fontsize=9)

    fig.suptitle("Spectral Evaluation Elimination", fontsize=14, y=0.99)
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig(path, dpi=150)
    print(f"wrote {path}")


if __name__ == "__main__":
    make_figure()
