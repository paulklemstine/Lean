"""Visualize the syndrome defect (discrete curvature) heatmap over region pairs."""
from itertools import combinations
from typing import FrozenSet, List
import matplotlib.pyplot as plt
import numpy as np

Region = FrozenSet[int]


def S(X: Region) -> float:
    return 0.0 if len(X) == 0 else 1.0 - 2.0 ** (-len(X))


def main() -> None:
    sites = [0, 1, 2]
    regions: List[Region] = []
    for k in range(len(sites) + 1):
        for combo in combinations(sites, k):
            regions.append(frozenset(combo))
    n = len(regions)
    M = np.zeros((n, n))
    for i, X in enumerate(regions):
        for j, Y in enumerate(regions):
            M[i, j] = S(X) + S(Y) - S(X & Y) - S(X | Y)
    labels = ["{" + ",".join(map(str, sorted(R))) + "}" if R else "{}" for R in regions]
    fig, ax = plt.subplots(figsize=(7, 6))
    im = ax.imshow(M, cmap="viridis")
    ax.set_xticks(range(n)); ax.set_xticklabels(labels, rotation=90)
    ax.set_yticks(range(n)); ax.set_yticklabels(labels)
    ax.set_title("Syndrome defect (discrete curvature): always >= 0")
    fig.colorbar(im, ax=ax, label="defect(X,Y)")
    fig.tight_layout()
    fig.savefig("syndrome_defect_heatmap.png", dpi=150)
    print("saved syndrome_defect_heatmap.png")


if __name__ == "__main__":
    main()
