"""Visualization: the central reflection a -> c - a on a Hodge-Tate weight set."""
import matplotlib.pyplot as plt

def plot_reflection(weights, c):
    fig, ax = plt.subplots(figsize=(8, 2.5))
    ax.axhline(0, color="black", lw=0.8)
    ax.axvline(c / 2, color="crimson", ls="--", lw=1.2, label=f"center c/2 = {c/2}")
    for a in weights:
        ax.plot([a], [0], "o", color="steelblue", ms=10)
        ax.annotate("", xy=(c - a, 0.4), xytext=(a, 0.4),
                    arrowprops=dict(arrowstyle="->", color="gray", alpha=0.6))
    ax.set_yticks([])
    ax.set_title(f"Reflection a -> {c} - a on weights {sorted(weights)}")
    ax.legend(loc="upper right")
    fig.tight_layout()
    fig.savefig("reflection.png", dpi=150)
    print("wrote reflection.png")

if __name__ == "__main__":
    plot_reflection([2, 5, 8], 10)
