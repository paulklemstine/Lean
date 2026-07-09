"""Heatmap of the energy-quadruple grid, highlighting the two kernels."""
import numpy as np
import matplotlib.pyplot as plt


def energy_grid(s):
    """For pairs p=(a,c), q=(b,d) indexed by s x s, mark a+b == c+d."""
    n = len(s)
    idx = [(a, c) for a in s for c in s]
    M = np.zeros((n * n, n * n))
    kind = np.zeros((n * n, n * n))  # 1 diagonal, 2 swap, 3 both, 4 nontrivial
    for i, (a, c) in enumerate(idx):
        for j, (b, d) in enumerate(idx):
            if a + b == c + d:
                M[i, j] = 1
                diag = (a == c and b == d)
                swap = (a == d and b == c)
                kind[i, j] = 3 if diag and swap else 1 if diag else 2 if swap else 4
    return kind


for name, s in [("Sidon {0,1,3,7}", [0, 1, 3, 7]),
                ("AP {0,1,2,3}", [0, 1, 2, 3])]:
    kind = energy_grid(s)
    plt.figure(figsize=(5, 5))
    plt.imshow(kind, cmap="viridis")
    plt.title(f"Energy quadruples of {name}\n(diagonal/swap kernels vs extra)")
    plt.colorbar(label="0 none | 1 diag | 2 swap | 3 both | 4 nontrivial")
    fname = "grid_" + ("sidon" if "Sidon" in name else "ap") + ".png"
    plt.tight_layout()
    plt.savefig(fname, dpi=150)
    print("wrote", fname)
