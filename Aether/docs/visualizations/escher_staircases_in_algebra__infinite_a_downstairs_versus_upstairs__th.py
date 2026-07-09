"""Visualize the collapse: proper rungs downstairs vs. the single unit ideal upstairs."""
import matplotlib.pyplot as plt

def plot_collapse(depth: int = 7) -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 5), sharey=False)
    # downstairs: strictly ascending proper ideals
    for n in range(1, depth):
        ax1.add_patch(plt.Rectangle((0, n), n, 0.7, color=plt.cm.plasma(n / depth)))
    ax1.set_title("Downstairs  Q[x_0,x_1,...]\n(strict tower of proper ideals)")
    ax1.set_xlim(0, depth); ax1.set_ylim(0, depth); ax1.set_xlabel("ideal size")
    ax1.set_ylabel("rung n")
    # upstairs: every rung is the whole field -> one flat level
    ax2.add_patch(plt.Rectangle((0, 1), depth - 1, depth - 2, color="crimson", alpha=0.5))
    ax2.text((depth - 1) / 2, depth / 2, "all rungs = (1)\n= whole field",
             ha="center", va="center", fontsize=12)
    ax2.set_title("Upstairs  Q(x_0,x_1,...)\n(the staircase has collapsed)")
    ax2.set_xlim(0, depth); ax2.set_ylim(0, depth); ax2.set_xlabel("ideal size")
    plt.tight_layout()
    plt.savefig("escher_collapse.png", dpi=150)
    print("wrote escher_collapse.png")

if __name__ == "__main__":
    plot_collapse()
