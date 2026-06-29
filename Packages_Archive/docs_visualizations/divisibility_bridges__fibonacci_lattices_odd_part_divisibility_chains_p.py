"""
Visualization: odd-part divisibility chains on [1, 2n] and the pigeonhole.

Renders [1, 2n] partitioned into the n chains  q * 2^k  (q odd), the structure
that powers `divisibility_pigeonhole`. Each chain is a column; choosing n+1
numbers must repeat a column (a divisibility pair). Requires matplotlib.
"""

from __future__ import annotations

from typing import Dict, List

import matplotlib.pyplot as plt


def odd_part(x: int) -> int:
    while x % 2 == 0:
        x //= 2
    return x


def make_figure(n: int = 8, out_path: str = "divisibility_chains.png") -> None:
    chains: Dict[int, List[int]] = {}
    for x in range(1, 2 * n + 1):
        chains.setdefault(odd_part(x), []).append(x)

    odds = sorted(chains)  # exactly n of them: 1, 3, ..., 2n-1
    fig, ax = plt.subplots(figsize=(1.1 * len(odds) + 2, 6))

    for col, q in enumerate(odds):
        members = chains[q]
        for row, val in enumerate(members):
            ax.scatter(col, row, s=900, color="#3b6db5", zorder=2)
            ax.text(col, row, str(val), ha="center", va="center",
                    color="white", fontsize=11, fontweight="bold", zorder=3)
        ys = list(range(len(members)))
        ax.plot([col] * len(members), ys, color="#9bb8e0", lw=2, zorder=1)

    ax.set_xticks(range(len(odds)))
    ax.set_xticklabels([f"odd part {q}" for q in odds], rotation=30, ha="right")
    ax.set_yticks([])
    ax.set_title(f"[1, {2*n}] split into {len(odds)} divisibility chains\n"
                 f"(any {n+1} numbers must repeat a column => a divisibility pair)")
    ax.set_xlim(-0.7, len(odds) - 0.3)
    ax.margins(y=0.15)
    fig.tight_layout()
    fig.savefig(out_path, dpi=130)
    print(f"wrote {out_path}")


if __name__ == "__main__":
    make_figure()
