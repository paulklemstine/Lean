"""Visualize the counterexample D = sum_{k in N} N^op as a Hasse-style
diagram of the linear order: blocks laid left-to-right, each an inverted N^op
ladder, with the covering relations of the single spanning chain drawn in."""
import matplotlib.pyplot as plt


def main() -> None:
    blocks, height = 4, 4
    pts = {(k, n): (k, height - 1 - n) for k in range(blocks) for n in range(height)}
    order = [(k, n) for k in range(blocks) for n in range(height - 1, -1, -1)]
    fig, ax = plt.subplots(figsize=(8, 5))
    for i in range(len(order) - 1):
        (x0, y0) = pts[order[i]]
        (x1, y1) = pts[order[i + 1]]
        ax.plot([x0, x1], [y0, y1], color="steelblue", lw=1.5, zorder=1)
    for (k, n), (x, y) in pts.items():
        ax.scatter([x], [y], s=140, color="crimson", zorder=2)
        ax.annotate(f"({k},{n})", (x, y), textcoords="offset points",
                    xytext=(6, 6), fontsize=8)
    ax.set_title("D = sum over N of N^op : one saturated spanning chain")
    ax.set_xlabel("block index k"); ax.set_ylabel("height in N^op block")
    ax.grid(alpha=0.3)
    plt.tight_layout(); plt.savefig("viz_chain.png", dpi=150)
    print("wrote viz_chain.png")


if __name__ == "__main__":
    main()
