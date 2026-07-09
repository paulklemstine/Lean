"""Visualization: boundary witnesses [0,1) and (0,1] seen by one observer only."""
import matplotlib.pyplot as plt


def plot_boundary() -> None:
    fig, ax = plt.subplots(figsize=(8, 3))
    # [0, 1): lower observer sees open at 0; euclidean does not.
    ax.hlines(1, 0, 1, color="royalblue", lw=6)
    ax.scatter([0], [1], color="royalblue")                      # closed
    ax.scatter([1], [1], facecolors="white", edgecolors="royalblue")  # open
    ax.annotate("[0, 1): lower-open at 0, not Euclidean-open", (0.0, 1.15),
                fontsize=9)
    # (0, 1]: upper observer sees open at 1; euclidean does not.
    ax.hlines(0, 0, 1, color="crimson", lw=6)
    ax.scatter([0], [0], facecolors="white", edgecolors="crimson")   # open
    ax.scatter([1], [0], color="crimson")                        # closed
    ax.annotate("(0, 1]: upper-open at 1, not Euclidean-open", (0.0, 0.15),
                fontsize=9)
    ax.set_yticks([])
    ax.set_xlim(-0.3, 1.6)
    ax.set_ylim(-0.4, 1.6)
    ax.set_title("Single-observer boundary witnesses")
    plt.tight_layout()
    plt.savefig("boundary.png", dpi=150)
    print("wrote boundary.png")


if __name__ == "__main__":
    plot_boundary()
