"""Heatmap of the shifted Legendre matrices C and C+J for a chosen prime."""
import numpy as np
import matplotlib.pyplot as plt


def legendre(a: int, p: int) -> int:
    a %= p
    return 0 if a == 0 else (1 if pow(a, (p - 1) // 2, p) == 1 else -1)


def main(p: int = 19) -> None:
    m = (p - 5) // 2
    C = np.array([[legendre(j - k, p) for k in range(m)] for j in range(m)])
    CJ = C + 1
    fig, axes = plt.subplots(1, 2, figsize=(11, 5))
    for ax, M, title, cmap in (
        (axes[0], C, f"C  (antisymmetric, det C = 0),  p = {p}", "coolwarm"),
        (axes[1], CJ, f"C + J  (det = floor((p-2)/3)^2 = {((p-2)//3)**2})", "viridis"),
    ):
        im = ax.imshow(M, cmap=cmap)
        ax.set_title(title)
        ax.set_xlabel("k"); ax.set_ylabel("j")
        fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    fig.suptitle("Truncated Legendre-symbol matrices")
    fig.tight_layout()
    fig.savefig("legendre_matrices.png", dpi=150)
    print("wrote legendre_matrices.png")


if __name__ == "__main__":
    main()
