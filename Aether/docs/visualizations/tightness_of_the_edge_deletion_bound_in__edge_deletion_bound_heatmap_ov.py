import matplotlib.pyplot as plt

def cover_ceiling_heatmap(dmax: int = 9, cmax: int = 6) -> None:
    """Heatmap of the deletion bound c*d*n over (c, d) at the threshold."""
    import numpy as np
    C = range(1, cmax + 1); D = range(3, dmax + 1, 2)  # odd d
    Z = np.array([[c * d * (2 * (2 * (1 + 2 * c) * d)) for d in D] for c in C])
    plt.imshow(Z, origin="lower", aspect="auto", cmap="viridis",
               extent=[min(D), max(D), min(C), max(C)])
    plt.colorbar(label="deletion bound c*d*n at threshold")
    plt.xlabel("d (odd)"); plt.ylabel("c")
    plt.title("Edge-deletion bound across parameters")
    plt.tight_layout(); plt.savefig("bound_heatmap.png", dpi=150)

if __name__ == "__main__":
    cover_ceiling_heatmap()
