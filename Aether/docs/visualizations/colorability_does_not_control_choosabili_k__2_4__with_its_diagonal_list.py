"""Visualization: K_{2,4} drawn with its diagonal list assignment."""
import matplotlib.pyplot as plt

def main() -> None:
    small = {"a0": (0.0, 3.0), "a1": (0.0, -3.0)}
    big = {f"b{j}": (3.0, 1.5 - j) for j in range(4)}
    lists = {"a0": "{0,1}", "a1": "{2,3}",
             "b0": "{0,2}", "b1": "{0,3}", "b2": "{1,2}", "b3": "{1,3}"}
    fig, ax = plt.subplots(figsize=(7, 6))
    for a in small.values():
        for b in big.values():
            ax.plot([a[0], b[0]], [a[1], b[1]], color="0.7", lw=1, zorder=1)
    for name, (x, y) in {**small, **big}.items():
        ax.scatter([x], [y], s=900, color="#4C72B0", zorder=2)
        ax.text(x, y, name, ha="center", va="center", color="white", fontweight="bold")
        ax.text(x + (0.5 if x > 0 else -0.5), y, lists[name],
                ha="left" if x > 0 else "right", va="center", fontsize=11)
    ax.set_title("K_{2,4} with the diagonal 2-list assignment (not 2-choosable)")
    ax.set_axis_off()
    ax.set_xlim(-2.5, 5.5)
    plt.tight_layout()
    plt.savefig("k24_diagonal.png", dpi=150)
    print("wrote k24_diagonal.png")

if __name__ == "__main__":
    main()
