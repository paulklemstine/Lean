"""Visualization: the non-monotonic retraction of LPm.

Shows, for premise sets {p, p->q} and {p, p->q, ~p}, the glut-minimal models
and the truth value of q in each, making visible that q is forced (tt) in the
first case but free (can be ff) in the second.

Standalone: run `python _assets_viz_retraction.py` to produce
`lp_retraction.png`.
"""
from __future__ import annotations

from itertools import product
from typing import Dict, FrozenSet, List, Tuple

import matplotlib.pyplot as plt

NAMES = {0: "ff", 1: "bb", 2: "tt"}


def neg(x: int) -> int:
    return {0: 2, 1: 1, 2: 0}[x]


def desig(x: int) -> bool:
    return x != 0


def impl(p: int, q: int) -> int:
    return max(neg(p), q)  # disj(neg p, q)


def models(constraints) -> List[Tuple[int, int]]:
    out = []
    for p, q in product(range(3), repeat=2):
        if all(c(p, q) for c in constraints):
            out.append((p, q))
    return out


def gluts(p: int, q: int) -> FrozenSet[int]:
    return frozenset(i for i, v in ((0, p), (1, q)) if v == 1)


def minimal(ms: List[Tuple[int, int]]) -> List[Tuple[int, int]]:
    gs = [gluts(*m) for m in ms]
    return [m for m, g in zip(ms, gs) if not any(h < g for h in gs)]


def main() -> None:
    base = [lambda p, q: desig(p), lambda p, q: desig(impl(p, q))]
    expanded = base + [lambda p, q: desig(neg(p))]

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    for ax, cons, title in (
        (axes[0], base, "Premises {p, p->q}\nq is ENTAILED"),
        (axes[1], expanded, "Premises {p, p->q, ~p}\nq is RETRACTED"),
    ):
        mm = minimal(models(cons))
        xs = list(range(len(mm)))
        qvals = [m[1] for m in mm]
        colors = ["#2ca02c" if desig(q) else "#d62728" for q in qvals]
        ax.bar(xs, [v + 0.2 for v in qvals], color=colors)
        ax.set_xticks(xs)
        ax.set_xticklabels([f"p={NAMES[p]}\nq={NAMES[q]}" for p, q in mm])
        ax.set_yticks([0.2, 1.2, 2.2])
        ax.set_yticklabels(["ff", "bb", "tt"])
        ax.set_title(title)
        ax.set_ylabel("value of q")
        all_des = all(desig(q) for q in qvals)
        ax.text(0.5, 0.95, f"all minimal models designate q?  {all_des}",
                transform=ax.transAxes, ha="center", va="top",
                fontsize=11, color=("#2ca02c" if all_des else "#d62728"))

    fig.suptitle("LPm non-monotonicity: adding ~p retracts q", fontsize=15)
    fig.tight_layout()
    fig.savefig("lp_retraction.png", dpi=150)
    print("wrote lp_retraction.png")


if __name__ == "__main__":
    main()
