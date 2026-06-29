"""Visualization: ground-state degeneracy GSD(A,g)=d^g vs genus, log scale.

Plots d^g against genus g for several quantum dimensions d, illustrating the
geometric growth of topological memory with the number of handles.
Requires matplotlib.
"""
from __future__ import annotations

import matplotlib.pyplot as plt
from typing import List


def gsd_curve(d: int, gmax: int) -> List[int]:
    return [d ** g for g in range(gmax + 1)]


def main() -> None:
    gmax = 6
    gs = list(range(gmax + 1))
    plt.figure(figsize=(6, 4))
    for d in (2, 3, 4, 5):
        plt.semilogy(gs, gsd_curve(d, gmax), marker="o", label=f"d={d}")
    plt.xlabel("genus g")
    plt.ylabel("GSD(A, g) = d^g  (log scale)")
    plt.title("Topological memory grows geometrically with genus")
    plt.legend(); plt.grid(True, which="both", alpha=0.3)
    plt.tight_layout()
    plt.savefig("gsd_growth.png", dpi=150)
    print("wrote gsd_growth.png")


if __name__ == "__main__":
    main()
