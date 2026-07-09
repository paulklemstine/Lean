"""Visualization: the rank-four discriminant landscape and the modular window.

Generates a figure showing, for diagonal Hessians diag(a,b,c,e) with small
positive entries, the distribution of discriminants det = a·b·c·e, highlighting
the conjectured modular window {8, 12, 16} and the divisibility-by-4 structure.
Requires matplotlib.
"""

from __future__ import annotations

from collections import Counter
from itertools import product
from typing import Dict, List

import matplotlib.pyplot as plt

TARGETS = {8, 12, 16}


def discriminant_histogram(max_entry: int = 4) -> Dict[int, int]:
    """Count how many diagonal forms diag(a,b,c,e), 1<=entries<=max_entry,
    yield each discriminant value det = a*b*c*e."""
    counts: Counter[int] = Counter()
    for a, b, c, e in product(range(1, max_entry + 1), repeat=4):
        counts[a * b * c * e] += 1
    return dict(sorted(counts.items()))


def main() -> None:
    hist = discriminant_histogram(4)
    discs: List[int] = list(hist.keys())
    freqs: List[int] = list(hist.values())
    colors = ["#d62728" if d in TARGETS else
              ("#2ca02c" if d % 4 == 0 and 8 <= d <= 16 else "#7f7f7f")
              for d in discs]

    fig, ax = plt.subplots(figsize=(12, 5))
    ax.bar(range(len(discs)), freqs, color=colors)
    ax.set_xticks(range(len(discs)))
    ax.set_xticklabels(discs, rotation=90, fontsize=7)
    ax.set_xlabel("discriminant  det H = product of diagonal entries")
    ax.set_ylabel("number of diagonal forms diag(a,b,c,e), 1<=entries<=4")
    ax.set_title("Rank-four discriminant landscape — conjectured modular window {8, 12, 16} in red")
    for d in TARGETS:
        if d in discs:
            idx = discs.index(d)
            ax.annotate(str(d), (idx, hist[d]), textcoords="offset points",
                        xytext=(0, 4), ha="center", color="#d62728", fontsize=9, weight="bold")
    fig.tight_layout()
    fig.savefig("discriminant_landscape.png", dpi=150)
    print("Saved discriminant_landscape.png")


if __name__ == "__main__":
    main()
