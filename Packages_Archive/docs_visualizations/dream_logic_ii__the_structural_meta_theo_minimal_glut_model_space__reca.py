"""Visualize how LPm recapture and non-monotonicity depend on minimal-glut models.

Draws, for the premise sets {p, ~p v q} (consistent) and {p, ~p v q, ~p} (forces a
glut), the model space colored by glut-set size, marking the minimal models and
whether the conclusion q holds on them. Requires matplotlib.
"""
from __future__ import annotations
from itertools import product
import matplotlib.pyplot as plt

FF, BB, TT = 0, 1, 2
LABELS = ["ff", "bb", "tt"]
desig = lambda a: a >= BB
neg = lambda a: BB if a == BB else (TT if a == FF else FF)


def ev(val, f):
    k = f[0]
    if k == "a": return val[f[1]]
    if k == "n": return neg(ev(val, f[1]))
    if k == "c": return min(ev(val, f[1]), ev(val, f[2]))
    if k == "d": return max(ev(val, f[1]), ev(val, f[2]))


def panel(ax, gamma, title):
    p, q = ("a", 0), ("a", 1)
    mods = []
    for pv, qv in product((FF, BB, TT), repeat=2):
        val = {0: pv, 1: qv}
        if all(desig(ev(val, b)) for b in gamma):
            mods.append((pv, qv))
    glut = lambda v: sum(1 for x in v if x == BB)
    minsz = min(glut(v) for v in mods)
    for pv in (FF, BB, TT):
        for qv in (FF, BB, TT):
            is_model = (pv, qv) in mods
            is_min = is_model and glut((pv, qv)) == minsz
            color = "#dddddd"
            if is_model:
                color = "#9ecae1"
            if is_min:
                color = "#fdae6b" if not desig(ev({0: pv, 1: qv}, q)) else "#a1d99b"
            ax.add_patch(plt.Rectangle((pv, qv), 0.9, 0.9, color=color))
            tag = "min" if is_min else ("mod" if is_model else "")
            ax.text(pv + 0.45, qv + 0.45, tag, ha="center", va="center", fontsize=9)
    ax.set_xlim(-0.2, 3.1); ax.set_ylim(-0.2, 3.1)
    ax.set_xticks([0.45, 1.45, 2.45]); ax.set_xticklabels(LABELS)
    ax.set_yticks([0.45, 1.45, 2.45]); ax.set_yticklabels(LABELS)
    ax.set_xlabel("p"); ax.set_ylabel("q"); ax.set_title(title)


def main() -> None:
    p, q = ("a", 0), ("a", 1)
    cons = [p, ("d", ("n", p), q)]
    forced = [p, ("d", ("n", p), q), ("n", p)]
    fig, axes = plt.subplots(1, 2, figsize=(11, 5))
    panel(axes[0], cons, "Gamma = {p, ~p v q}\nminimal model holds q (green) -> LPm |- q")
    panel(axes[1], forced, "Delta = Gamma + {~p}\nminimal model fails q (orange) -> retraction")
    fig.suptitle("LPm recapture vs. non-monotonicity (green=q holds, orange=q fails)")
    fig.tight_layout()
    fig.savefig("dream_logic_recapture.png", dpi=130)
    print("wrote dream_logic_recapture.png")


if __name__ == "__main__":
    main()
