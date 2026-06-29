"""Visualization: the contractible total space and the encode/decode dictionary.

Renders, for a finite base type A with basepoint a0, the total space
Sigma a, R(a) of the path identity system, showing how every fibre point
collapses onto the center (a0, rflR), and the bijection (a0=a) <-> R(a) per fibre.

Requires matplotlib.  Run:  python viz.py
"""
from __future__ import annotations

from typing import List, Tuple

import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch


def path_fibre(a0: str, a: str) -> Tuple[bool, ...]:
    return (True,) if a == a0 else tuple()


def main() -> None:
    points: List[str] = ["a0", "a1", "a2", "a3"]
    a0 = "a0"

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.5))

    # ---- Left: total space collapsing onto the center -------------------
    ax1.set_title("Total space  Σ a, R(a)  collapses onto center (a0, rflR)")
    xs = list(range(len(points)))
    center = (0, 1)  # (a0, rflR)
    for i, a in enumerate(points):
        fib = path_fibre(a0, a)
        if fib:
            ax1.scatter([i], [1], s=420, c="#d62728", zorder=3,
                        edgecolors="black")
            ax1.annotate("(a0, rflR)\nCENTER", (i, 1),
                         textcoords="offset points", xytext=(0, 18),
                         ha="center", fontsize=9, color="#d62728")
        else:
            ax1.scatter([i], [0.15], s=120, c="#bbbbbb", zorder=2)
            ax1.annotate(f"R({a}) = ∅", (i, 0.15),
                         textcoords="offset points", xytext=(0, -22),
                         ha="center", fontsize=8, color="#777777")
        ax1.annotate(a, (i, -0.35), ha="center", fontsize=10)
    ax1.set_xlim(-0.7, len(points) - 0.3)
    ax1.set_ylim(-0.6, 1.6)
    ax1.axis("off")

    # ---- Right: per-fibre bijection (a0=a) <-> R(a) ---------------------
    ax2.set_title("Encode/Decode dictionary:  (a0 = a)  ≃  R(a)")
    for i, a in enumerate(points):
        y = len(points) - i
        has = bool(path_fibre(a0, a))
        left_label = "{ rfl }" if has else "∅"
        right_label = "{ rflR }" if has else "∅"
        ax2.text(0.05, y, f"(a0={a}) = {left_label}", fontsize=10,
                 ha="left", va="center")
        ax2.text(0.95, y, f"R({a}) = {right_label}", fontsize=10,
                 ha="right", va="center")
        color = "#2ca02c" if has else "#cccccc"
        arr = FancyArrowPatch((0.40, y), (0.60, y),
                              arrowstyle="<|-|>", mutation_scale=14,
                              color=color, lw=2)
        ax2.add_patch(arr)
        if has:
            ax2.text(0.5, y + 0.18, "encode/decode", fontsize=7,
                     ha="center", color="#2ca02c")
    ax2.set_xlim(0, 1)
    ax2.set_ylim(0, len(points) + 1)
    ax2.axis("off")

    fig.suptitle("Fundamental Theorem of Identity Systems — path family over a finite type",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("identity_systems_viz.png", dpi=140)
    print("Wrote identity_systems_viz.png")


if __name__ == "__main__":
    main()
