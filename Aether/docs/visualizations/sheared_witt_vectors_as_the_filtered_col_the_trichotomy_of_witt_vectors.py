"""Visualization: the trichotomy pointwise / stage-bounded / finite-support."""
import matplotlib.pyplot as plt

def main() -> None:
    classes = ["pointwise\nin colimit", "stage-bounded", "finite support"]
    sizes = [3, 2, 1]  # strictly nested (schematic)
    colors = ["#f4cccc", "#9fc5e8", "#b6d7a8"]
    fig, ax = plt.subplots(figsize=(7, 5))
    for s, c, name in zip(sizes, colors, classes):
        ax.barh(0, s, color=c, edgecolor="black", height=0.6, left=0)
        ax.text(s - 0.5, 0, name, va="center", ha="right", fontsize=9)
    ax.set_title("Nested classes of Witt vectors over a colimit ring")
    ax.set_yticks([]); ax.set_xlabel("increasing generality ->")
    fig.tight_layout()
    fig.savefig("trichotomy.png", dpi=150)
    print("wrote trichotomy.png")

if __name__ == "__main__":
    main()
