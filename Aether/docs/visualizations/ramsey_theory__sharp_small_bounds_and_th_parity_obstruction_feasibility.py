"""Heat map of the parity obstruction: which (n,d) pairs admit a d-regular red graph."""
import matplotlib.pyplot as plt
import numpy as np


def main() -> None:
    N, D = 16, 16
    grid = np.zeros((D, N))
    for n in range(1, N + 1):
        for d in range(1, D + 1):
            # 1 = permitted (n*d even), 0 = forbidden by parity (n*d odd)
            grid[d - 1, n - 1] = 0 if (n * d) % 2 == 1 else 1
    plt.figure(figsize=(7, 6))
    plt.imshow(grid, origin="lower", extent=(0.5, N + 0.5, 0.5, D + 0.5), cmap="RdYlGn", aspect="auto")
    plt.colorbar(label="0 = forbidden (n*d odd)   1 = permitted (n*d even)")
    plt.scatter([9], [3], c="black", s=80, marker="x", label="R(3,4): (n,d)=(9,3) forbidden")
    plt.xlabel("number of vertices n"); plt.ylabel("regular red-degree d")
    plt.title("Parity obstruction: d-regular red colourings on n vertices")
    plt.legend(); plt.tight_layout(); plt.savefig("parity_obstruction.png", dpi=150)
    print("saved parity_obstruction.png")


if __name__ == "__main__":
    main()
