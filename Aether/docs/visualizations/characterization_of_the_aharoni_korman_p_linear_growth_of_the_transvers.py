"""Visualize the Width Threshold: transversal antichain size grows linearly
with the number of disjoint summands, diverging to an infinite antichain."""
import matplotlib.pyplot as plt


def main() -> None:
    blocks = list(range(1, 21))
    sizes = blocks[:]  # transversal size == number of blocks
    fig, ax = plt.subplots(figsize=(7, 4))
    ax.plot(blocks, sizes, "o-", color="darkorange")
    ax.set_title("Disjoint sum: transversal antichain size vs #blocks")
    ax.set_xlabel("number of nonempty summands")
    ax.set_ylabel("largest guaranteed antichain")
    ax.grid(alpha=0.3)
    ax.annotate("-> infinity => not FAC", (blocks[-1], sizes[-1]),
                textcoords="offset points", xytext=(-120, -20), color="red")
    plt.tight_layout(); plt.savefig("viz_width.png", dpi=150)
    print("wrote viz_width.png")


if __name__ == "__main__":
    main()
