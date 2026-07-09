"""Visualize GLMC cut values across all proper cuts of a small labeled graph.

Generates a bar chart of cut values for every proper cut, highlighting the
global label min-cut optimum. Requires matplotlib.
"""
from __future__ import annotations
from itertools import combinations
from typing import List, Set, Tuple
import matplotlib.pyplot as plt

Edge = Tuple[str, str, str]


def cut_value(edges: List[Edge], A: Set[str]) -> int:
    return len({lab for (u, v, lab) in edges if (u in A) != (v in A)})


def main() -> None:
    V = ["a1", "a2", "a3", "b1", "b2", "b3"]
    E: List[Edge] = [
        ("a1", "a2", "r"), ("a2", "a3", "r"), ("a1", "a3", "r"),
        ("b1", "b2", "r"), ("b2", "b3", "r"), ("b1", "b3", "r"),
        ("a1", "b1", "b"), ("a2", "b2", "g"),
    ]
    cuts: List[Set[str]] = []
    for r in range(1, len(V)):
        for combo in combinations(V, r):
            cuts.append(set(combo))
    values = [cut_value(E, A) for A in cuts]
    opt = min(values)

    colors = ["crimson" if v == opt else "steelblue" for v in values]
    plt.figure(figsize=(12, 4))
    plt.bar(range(len(values)), values, color=colors)
    plt.axhline(opt, color="crimson", linestyle="--", label=f"glmc_opt = {opt}")
    plt.xlabel("proper cut index")
    plt.ylabel("distinct crossing labels (cut value)")
    plt.title("GLMC cut values over all proper cuts (optimum in red)")
    plt.legend()
    plt.tight_layout()
    plt.savefig("glmc_cut_values.png", dpi=150)
    print("wrote glmc_cut_values.png")


if __name__ == "__main__":
    main()
