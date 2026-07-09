"""Visualization: the coarsening principle in the lattice of topologies."""
import matplotlib.pyplot as plt


def plot_lattice() -> None:
    fig, ax = plt.subplots(figsize=(6, 5))
    # positions: y = "fineness" (higher = finer / more open sets)
    nodes = {
        "Euclidean\n(consensus)": (0.5, 0.25),
        "lower-limit\n(Sorgenfrey)": (0.15, 0.7),
        "upper-limit": (0.85, 0.7),
        "discrete\n(finest)": (0.5, 1.0),
    }
    edges = [
        ("Euclidean\n(consensus)", "lower-limit\n(Sorgenfrey)"),
        ("Euclidean\n(consensus)", "upper-limit"),
        ("lower-limit\n(Sorgenfrey)", "discrete\n(finest)"),
        ("upper-limit", "discrete\n(finest)"),
    ]
    for u, v in edges:
        (x0, y0), (x1, y1) = nodes[u], nodes[v]
        ax.plot([x0, x1], [y0, y1], color="gray", zorder=1)
    for name, (x, y) in nodes.items():
        ax.scatter([x], [y], s=40, color="navy", zorder=2)
        ax.annotate(name, (x, y), textcoords="offset points", xytext=(6, 6),
                    fontsize=9)
    ax.set_ylabel("finer  -->")
    ax.set_title("Each observer is finer than the consensus (agreement coarsens)")
    ax.set_xticks([])
    plt.tight_layout()
    plt.savefig("lattice.png", dpi=150)
    print("wrote lattice.png")


if __name__ == "__main__":
    plot_lattice()
