"""Visualize the strictly ascending ideal chain that loops back to {0}."""
import matplotlib.pyplot as plt

def plot_staircase(depth: int = 7) -> None:
    fig, ax = plt.subplots(figsize=(8, 5))
    for n in range(depth):
        # each rung drawn as a step of increasing width (more generators)
        ax.add_patch(plt.Rectangle((0, n), n + 1, 0.8, color=plt.cm.viridis(n / depth)))
        ax.text(n + 1.1, n + 0.4, f"V_{n} = <x_0..x_{n-1}>", va="center", fontsize=9)
    ax.plot([0, 0], [0, depth], "k--", lw=1)
    ax.annotate("meet of all rungs = V_0 = {0}", xy=(0, 0), xytext=(2.5, -1.2),
                arrowprops=dict(arrowstyle="->"))
    ax.set_xlim(-0.5, depth + 4)
    ax.set_ylim(-2, depth + 0.5)
    ax.set_title("Escher staircase: strictly ascending ideals, looping back to {0}")
    ax.set_xlabel("number of generators (ideal 'size')")
    ax.set_ylabel("rung index n")
    plt.tight_layout()
    plt.savefig("escher_staircase.png", dpi=150)
    print("wrote escher_staircase.png")

if __name__ == "__main__":
    plot_staircase()
