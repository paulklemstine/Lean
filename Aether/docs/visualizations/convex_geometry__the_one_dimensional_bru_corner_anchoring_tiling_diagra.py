"""Visualize the corner-anchoring construction for the 1-D Brunn-Minkowski proof.

Draws A, B, A+B, and the two anchored translates U = A+{inf B}, V = {sup A}+B,
highlighting that U and V tile (up to a single seam point) a subset of A+B whose
length is vol(A) + vol(B). Requires matplotlib.
"""
from fractions import Fraction
from typing import List, Tuple
import matplotlib.pyplot as plt
import matplotlib.patches as patches

Interval = Tuple[float, float]


def canon(s: List[Interval]) -> List[Interval]:
    s = sorted((a, b) for (a, b) in s if a <= b)
    if not s:
        return []
    out = [s[0]]
    for a, b in s[1:]:
        pa, pb = out[-1]
        if a <= pb:
            out[-1] = (pa, max(pb, b))
        else:
            out.append((a, b))
    return out


def mink(a: List[Interval], b: List[Interval]) -> List[Interval]:
    return canon([(x + u, y + v) for (x, y) in a for (u, v) in b])


def draw(ax, intervals: List[Interval], y: float, color: str, label: str) -> None:
    for (lo, hi) in canon(intervals):
        ax.add_patch(patches.Rectangle((lo, y - 0.15), max(hi - lo, 0.0), 0.3,
                                        color=color, alpha=0.7))
        if hi == lo:
            ax.plot([lo], [y], marker="o", color=color)
    ax.text(-0.5, y, label, ha="right", va="center", fontsize=10)


def main() -> None:
    A = [(0.0, 1.0), (3.0, 4.0)]
    B = [(0.0, 1.0)]
    S = mink(A, B)
    a_max = max(h for _, h in canon(A))
    b_min = min(l for l, _ in canon(B))
    U = canon([(l + b_min, h + b_min) for (l, h) in A])
    V = canon([(l + a_max, h + a_max) for (l, h) in B])

    fig, ax = plt.subplots(figsize=(9, 4))
    draw(ax, A, 4, "#1f77b4", "A")
    draw(ax, B, 3, "#ff7f0e", "B")
    draw(ax, S, 2, "#2ca02c", "A+B")
    draw(ax, U, 1, "#9467bd", "U=A+{inf B}")
    draw(ax, V, 0, "#d62728", "V={sup A}+B")
    ax.axvline(a_max + b_min, ls="--", color="gray")
    ax.text(a_max + b_min, 4.6, f"seam = {a_max + b_min:g}", ha="center")
    ax.set_xlim(-1, 6)
    ax.set_ylim(-0.6, 5)
    ax.set_yticks([])
    ax.set_title("Corner-anchoring: U and V tile a length-(vol A + vol B) subset of A+B")
    plt.tight_layout()
    plt.savefig("brunn_minkowski_anchoring.png", dpi=150)
    print("wrote brunn_minkowski_anchoring.png")


if __name__ == "__main__":
    main()
