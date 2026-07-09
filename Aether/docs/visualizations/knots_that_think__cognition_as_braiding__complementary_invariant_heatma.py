"""Visualization: invariant table heatmap for the three cognitive braids."""
import matplotlib.pyplot as plt
import numpy as np


def main() -> None:
    braids = ["trivial", "creative", "confused"]
    # rows: writhe, permutation-nontrivial (0/1), min crossing count
    data = np.array([
        [0, 3, 0],       # writhe
        [0, 1, 1],       # permutation nontrivial?
    ], dtype=float)
    rows = ["writhe", "perm != id"]
    fig, ax = plt.subplots(figsize=(6, 3))
    im = ax.imshow(data, cmap="viridis", aspect="auto")
    ax.set_xticks(range(len(braids)))
    ax.set_xticklabels(braids)
    ax.set_yticks(range(len(rows)))
    ax.set_yticklabels(rows)
    for r in range(data.shape[0]):
        for c in range(data.shape[1]):
            ax.text(c, r, f"{data[r, c]:.0f}", ha="center", va="center", color="white")
    ax.set_title("Complementary invariants of the cognitive braids")
    fig.colorbar(im, ax=ax)
    fig.tight_layout()
    fig.savefig("invariant_table.png", dpi=150)
    print("saved invariant_table.png")


if __name__ == "__main__":
    main()
