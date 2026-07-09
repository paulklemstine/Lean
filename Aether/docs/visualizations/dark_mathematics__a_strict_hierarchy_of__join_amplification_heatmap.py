"""Heatmap of join amplification: level(B_a join B_b) = max(a, b)."""
import numpy as np
import matplotlib.pyplot as plt


def join_level(a: int, b: int) -> int:
    """Darkness level of the join of B_a and B_b."""
    return max(a, b)


def main() -> None:
    n = 8
    grid = np.array([[join_level(a, b) for b in range(n)] for a in range(n)])
    fig, ax = plt.subplots(figsize=(6.5, 5.5))
    im = ax.imshow(grid, origin="lower", cmap="magma")
    for a in range(n):
        for b in range(n):
            ax.text(b, a, str(grid[a, b]), ha="center", va="center",
                    color="white" if grid[a, b] < n - 1 else "black", fontsize=8)
    ax.set_xlabel("b  (right component B_b)")
    ax.set_ylabel("a  (left component B_a)")
    ax.set_title("Join amplification: darkness level of B_a join B_b = max(a, b)")
    fig.colorbar(im, ax=ax, label="darkness level of the join")
    fig.tight_layout()
    fig.savefig("join_amplification.png", dpi=150)
    print("wrote join_amplification.png")


if __name__ == "__main__":
    main()
