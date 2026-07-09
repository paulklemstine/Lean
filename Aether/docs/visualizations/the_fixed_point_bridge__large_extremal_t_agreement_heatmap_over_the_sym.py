import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations

def agreement_matrix(n: int) -> np.ndarray:
    perms = list(permutations(range(n)))
    N = len(perms)
    M = np.zeros((N, N), dtype=int)
    for a, s in enumerate(perms):
        for b, u in enumerate(perms):
            M[a, b] = sum(1 for i in range(n) if s[i] == u[i])
    return M

if __name__ == "__main__":
    n = 4
    M = agreement_matrix(n)
    plt.figure(figsize=(7, 6))
    plt.imshow(M, cmap="viridis")
    plt.colorbar(label="number of agreements")
    plt.title(f"Agreement counts over Sym({n})")
    plt.xlabel("permutation index")
    plt.ylabel("permutation index")
    plt.tight_layout()
    plt.savefig("agreement_heatmap.png", dpi=150)
    print("Saved agreement_heatmap.png")
