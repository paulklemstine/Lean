"""
Visualization: the multiplicative telescope of relative indices collapsing to |G|.

Renders, for the composition series of S_4 (1 < Z2 < V4 < A4 < S4), the running
partial products of the relative indices [H_{i+1}:H_i] climbing to |G| = 24,
alongside the constant target line |G|. Saves 'telescope_S4.png'.
"""

from __future__ import annotations

from math import prod
from typing import List

import matplotlib.pyplot as plt


def telescope_partial_products(rel_indices: List[int]) -> List[int]:
    """Running products [r0, r0*r1, r0*r1*r2, ...]."""
    out: List[int] = []
    acc = 1
    for r in rel_indices:
        acc *= r
        out.append(acc)
    return out


def main() -> None:
    labels = ["[Z2:1]", "[V4:Z2]", "[A4:V4]", "[S4:A4]"]
    rel = [2, 2, 3, 2]                       # factor orders of S_4
    partial = telescope_partial_products(rel)
    order = prod(rel)                        # 24

    fig, ax = plt.subplots(figsize=(8, 5))
    xs = range(len(rel))
    ax.bar(xs, partial, color="#4C72B0", alpha=0.85, label="running product")
    for x, (r, p) in enumerate(zip(rel, partial)):
        ax.text(x, p + 0.4, f"x{r}\n={p}", ha="center", va="bottom", fontsize=10)
    ax.axhline(order, color="#C44E52", linestyle="--", linewidth=2,
               label=f"|S_4| = {order}")
    ax.set_xticks(list(xs))
    ax.set_xticklabels(labels)
    ax.set_ylabel("product of relative indices so far")
    ax.set_title("Subgroup-index telescope:  product of step sizes climbs to |G|")
    ax.legend()
    fig.tight_layout()
    fig.savefig("telescope_S4.png", dpi=150)
    print("wrote telescope_S4.png")


if __name__ == "__main__":
    main()
