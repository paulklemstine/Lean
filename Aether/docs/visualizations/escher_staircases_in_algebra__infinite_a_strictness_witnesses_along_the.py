import matplotlib.pyplot as plt
import numpy as np

def plot_witnesses(depth: int = 7) -> None:
    grid = np.zeros((depth, depth + 1))
    for n in range(depth):
        grid[n, n] = 1.0   # spike e_n has its 1 at coordinate n
    fig, ax = plt.subplots(figsize=(8, 6))
    ax.imshow(grid, cmap="Blues", aspect="equal")
    for n in range(depth):
        ax.text(n, n, "1", ha="center", va="center", color="white")
    ax.set_xlabel("coordinate index k")
    ax.set_ylabel("witness e_n (separates rung n from n+1)")
    ax.set_title("Spike witnesses: e_n in S_{n+1} but not S_n")
    ax.set_xticks(range(depth + 1))
    ax.set_yticks(range(depth))
    plt.tight_layout()
    plt.savefig("escher_witnesses.png", dpi=150)

if __name__ == "__main__":
    plot_witnesses()
