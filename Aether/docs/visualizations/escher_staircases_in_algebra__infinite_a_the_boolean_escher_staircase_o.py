"""Visualization: the Boolean Escher staircase as nested support windows."""
import matplotlib.pyplot as plt


def plot_staircase(max_n: int = 6) -> None:
    fig, ax = plt.subplots(figsize=(8, 5))
    for n in range(1, max_n + 1):
        ax.broken_barh([(0, n)], (n - 0.4, 0.8), facecolors=plt.cm.viridis(n / max_n))
        ax.text(n + 0.1, n, f"I_{n}", va="center")
    ax.set_xlabel("allowed support positions  0,1,...,n-1")
    ax.set_ylabel("ideal index n")
    ax.set_title("Escher staircase in F_2^N: I_n = support-below-n (strictly ascending)")
    ax.set_xlim(0, max_n + 1)
    ax.set_ylim(0, max_n + 1)
    plt.tight_layout()
    plt.savefig("escher_staircase.png", dpi=150)
    print("wrote escher_staircase.png")


if __name__ == "__main__":
    plot_staircase()
