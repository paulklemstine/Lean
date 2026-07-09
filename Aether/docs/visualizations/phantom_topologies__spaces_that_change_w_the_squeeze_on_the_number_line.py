"""Visualization: the squeeze (a, x] U [x, b) = (a, b) on a number line."""
import matplotlib.pyplot as plt


def plot_squeeze(a: float = -2.0, x: float = 0.5, b: float = 3.0) -> None:
    eps = min(x - a, b - x)
    fig, ax = plt.subplots(figsize=(9, 2.6))
    ax.hlines(2, a, x, color="crimson", lw=6, label="upper observer (a, x]")
    ax.hlines(1, x, b, color="royalblue", lw=6, label="lower observer [x, b)")
    ax.hlines(0, x - eps, x + eps, color="black", lw=6,
              label="Euclidean ball (x-e, x+e)")
    ax.scatter([x], [2], color="crimson")       # closed at x
    ax.scatter([x], [1], color="royalblue")     # closed at x
    ax.scatter([a], [2], facecolors="white", edgecolors="crimson")  # open at a
    ax.scatter([b], [1], facecolors="white", edgecolors="royalblue")  # open at b
    ax.set_yticks([0, 1, 2])
    ax.set_yticklabels(["consensus", "lower", "upper"])
    ax.set_title("Two one-sided intervals glue into a two-sided neighborhood")
    ax.legend(loc="upper right", fontsize=8)
    plt.tight_layout()
    plt.savefig("squeeze.png", dpi=150)
    print("wrote squeeze.png")


if __name__ == "__main__":
    plot_squeeze()
