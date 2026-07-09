import matplotlib.pyplot as plt
import numpy as np

def visualize_fermat_heatmap() -> None:
    primes = [2, 3, 5, 7, 11, 13]
    a_range = range(0, 20)
    grid = np.array([[(a ** p - a) % p for a in a_range] for p in primes])
    fig, ax = plt.subplots(figsize=(9, 4))
    im = ax.imshow(grid, aspect="auto", cmap="viridis")
    ax.set_yticks(range(len(primes))); ax.set_yticklabels(primes)
    ax.set_xticks(range(len(a_range))); ax.set_xticklabels(list(a_range))
    ax.set_xlabel("a"); ax.set_ylabel("prime p")
    ax.set_title("(a^p - a) mod p  (all zero = Fermat's Little Theorem)")
    fig.colorbar(im, ax=ax, label="residue")
    plt.tight_layout(); plt.savefig("fermat_heatmap.png", dpi=150)

if __name__ == "__main__":
    visualize_fermat_heatmap()
