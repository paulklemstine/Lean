"""Heatmap of product-frame ranks showing rank(a,b) = min(rank a, rank b)."""
import matplotlib.pyplot as plt
import numpy as np

if __name__ == "__main__":
    # chains of ranks 0..3 and 0..4
    rF = list(range(4))
    rG = list(range(5))
    M = np.array([[min(a, b) for b in rG] for a in rF])
    fig, ax = plt.subplots(figsize=(6, 5))
    im = ax.imshow(M, origin="lower", cmap="viridis")
    for i in range(M.shape[0]):
        for j in range(M.shape[1]):
            ax.text(j, i, str(M[i, j]), ha="center", va="center", color="w")
    ax.set_xlabel("rank of coordinate b")
    ax.set_ylabel("rank of coordinate a")
    ax.set_title("Synchronized product: rank(a,b) = min(rank a, rank b)")
    fig.colorbar(im, label="rank(a,b)")
    plt.tight_layout()
    plt.savefig("product_rank_min.png", dpi=140)
    print("wrote product_rank_min.png")
