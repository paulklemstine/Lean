"""Visualization: the exact local star threshold and complete-graph forcing.

Generates a two-panel figure:
  (left)  per-color class sizes for a sample coloring vs. their targets,
          with the conservation identity sum(cc)=#M annotated;
  (right) the forcing region N >= sum_j (t_j-1)+2 for K_N as t varies.

Requires matplotlib. Run: python visualization.py
"""
from typing import List, Sequence
import matplotlib.pyplot as plt


def class_counts(colors: Sequence[int], q: int) -> List[int]:
    out = [0] * q
    for c in colors:
        out[c] += 1
    return out


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Panel 1: color classes vs targets
    targets = [2, 3, 2]
    colors = [0, 1, 1, 2, 0, 1, 2, 0]
    q = len(targets)
    counts = class_counts(colors, q)
    x = list(range(q))
    ax1.bar([i - 0.2 for i in x], counts, width=0.4, label="cc_j (class size)")
    ax1.bar([i + 0.2 for i in x], targets, width=0.4, label="t_j (target)")
    ax1.axhline(0, color="black", linewidth=0.5)
    ax1.set_xticks(x)
    ax1.set_xticklabels([f"color {i}" for i in x])
    ax1.set_title(f"Color classes vs targets  (sum cc = {sum(counts)} = #M)")
    ax1.set_ylabel("count")
    ax1.legend()

    # Panel 2: complete-graph forcing region
    sum_targets = list(range(0, 9))
    threshold = [s + 2 for s in sum_targets]
    ax2.plot(sum_targets, threshold, marker="o")
    ax2.fill_between(sum_targets, threshold, [t + 5 for t in threshold],
                     alpha=0.2, label="forced region")
    ax2.set_xlabel("sum_j (t_j - 1)")
    ax2.set_ylabel("N (vertices of K_N)")
    ax2.set_title("Complete-graph forcing bound  N >= sum(t_j-1)+2")
    ax2.legend()

    fig.tight_layout()
    fig.savefig("star_threshold.png", dpi=150)
    print("Wrote star_threshold.png")


if __name__ == "__main__":
    main()
