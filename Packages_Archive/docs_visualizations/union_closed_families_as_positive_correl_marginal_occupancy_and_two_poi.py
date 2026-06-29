"""Visualize marginal occupancies and the two-point correlation matrix of a
union-closed family, illustrating Theorems A, D, and inclusion-exclusion."""
from itertools import combinations
from typing import FrozenSet, List
import numpy as np
import matplotlib.pyplot as plt


def upper_set(ground, seeds) -> List[FrozenSet[int]]:
    universe = [frozenset(c) for r in range(len(ground) + 1)
                for c in combinations(ground, r)]
    return [t for t in universe if any(set(s) <= t for s in seeds)]


def main() -> None:
    ground = list(range(6))
    F = upper_set(ground, [frozenset({0, 1}), frozenset({2, 3}), frozenset({4})])
    n, m = len(ground), len(F)

    marg = np.array([sum(1 for s in F if a in s) / m for a in ground])
    corr = np.zeros((n, n))
    for i in ground:
        for j in ground:
            corr[i, j] = sum(1 for s in F if i in s and j in s) / m

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.5))
    ax1.bar(ground, marg, color="#3b6fb6")
    ax1.axhline(0.5, color="crimson", ls="--", label="density threshold 1/2")
    ax1.set_title("Marginal occupancy  P(a)  (Theorems A & B)")
    ax1.set_xlabel("site a"); ax1.set_ylabel("P(a in s)"); ax1.legend()

    im = ax2.imshow(corr, cmap="viridis", vmin=0, vmax=1)
    ax2.set_title("Two-point correlation  P(a,b)  (Thm D / incl-excl)")
    ax2.set_xlabel("site b"); ax2.set_ylabel("site a")
    fig.colorbar(im, ax=ax2)
    fig.tight_layout()
    fig.savefig("union_closed_correlations.png", dpi=150)
    print("saved union_closed_correlations.png")


if __name__ == "__main__":
    main()
