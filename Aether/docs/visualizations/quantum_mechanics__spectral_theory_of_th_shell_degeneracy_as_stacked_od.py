import matplotlib.pyplot as plt
import matplotlib.patches as patches


def main() -> None:
    n = 5
    fig, ax = plt.subplots(figsize=(6, 6))
    cmap = plt.get_cmap("viridis")
    for l in range(n):
        color = cmap(l / n)
        # gnomon for subshell l: cells (l, 0..l) and (0..l, l)
        for j in range(l + 1):
            ax.add_patch(patches.Rectangle((l, j), 1, 1, facecolor=color,
                                           edgecolor="white"))
        for i in range(l):
            ax.add_patch(patches.Rectangle((i, l), 1, 1, facecolor=color,
                                           edgecolor="white"))
    ax.set_xlim(0, n)
    ax.set_ylim(0, n)
    ax.set_aspect("equal")
    ax.set_title(f"sum_(l<{n}) (2l+1) = {n}^2 = {n*n}")
    plt.tight_layout()
    plt.savefig("degeneracy_squares.png", dpi=150)
    print("wrote degeneracy_squares.png")


if __name__ == "__main__":
    main()
