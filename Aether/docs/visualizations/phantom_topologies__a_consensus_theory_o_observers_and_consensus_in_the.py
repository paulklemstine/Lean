"""Visualize where observers and consensus sit in the refinement lattice."""
import matplotlib.pyplot as plt

def main() -> None:
    fig, ax = plt.subplots(figsize=(6, 6))
    nodes = {
        "discrete (bottom, finest)": (0.5, 1.0),
        "lower-limit observer": (0.25, 0.66),
        "upper-limit observer": (0.75, 0.66),
        "Euclidean = consensus": (0.5, 0.33),
        "indiscrete (top, coarsest)": (0.5, 0.0),
    }
    edges = [
        ("discrete (bottom, finest)", "lower-limit observer"),
        ("discrete (bottom, finest)", "upper-limit observer"),
        ("lower-limit observer", "Euclidean = consensus"),
        ("upper-limit observer", "Euclidean = consensus"),
        ("Euclidean = consensus", "indiscrete (top, coarsest)"),
    ]
    for u, v in edges:
        (x1, y1), (x2, y2) = nodes[u], nodes[v]
        ax.plot([x1, x2], [y1, y2], color="gray", zorder=1)
    for name, (x, y) in nodes.items():
        ax.scatter([x], [y], s=120, zorder=2)
        ax.annotate(name, (x, y), textcoords="offset points", xytext=(8, 6))
    ax.set_title("Observers are finer (lower) than their consensus")
    ax.axis("off"); plt.tight_layout(); plt.savefig("lattice.png", dpi=150)

if __name__ == "__main__":
    main()
