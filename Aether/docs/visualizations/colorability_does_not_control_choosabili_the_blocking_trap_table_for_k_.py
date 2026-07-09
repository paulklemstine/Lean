"""Visualization: the 'trap table' - each small-side choice blocks one vertex."""
import matplotlib.pyplot as plt

def main() -> None:
    a0_colors = [0, 1]
    a1_colors = [2, 3]
    blocked = {(0, 2): "b0", (0, 3): "b1", (1, 2): "b2", (1, 3): "b3"}
    fig, ax = plt.subplots(figsize=(6, 5))
    for i, a in enumerate(a0_colors):
        for j, b in enumerate(a1_colors):
            ax.add_patch(plt.Rectangle((j, i), 1, 1, facecolor="#FADBD8",
                                       edgecolor="black"))
            ax.text(j + 0.5, i + 0.5, f"a0={a}, a1={b}\nblocks {blocked[(a, b)]}",
                    ha="center", va="center", fontsize=11)
    ax.set_xticks([0.5, 1.5]); ax.set_xticklabels([f"a1={c}" for c in a1_colors])
    ax.set_yticks([0.5, 1.5]); ax.set_yticklabels([f"a0={c}" for c in a0_colors])
    ax.set_xlim(0, 2); ax.set_ylim(0, 2)
    ax.set_title("Every small-side choice blocks exactly one large-side vertex")
    plt.tight_layout()
    plt.savefig("trap_table.png", dpi=150)
    print("wrote trap_table.png")

if __name__ == "__main__":
    main()
