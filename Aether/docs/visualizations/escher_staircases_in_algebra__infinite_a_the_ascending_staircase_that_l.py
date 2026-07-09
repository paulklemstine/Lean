import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch

def plot_staircase(depth: int = 7) -> None:
    fig, ax = plt.subplots(figsize=(8, 6))
    for n in range(depth):
        ax.add_patch(plt.Rectangle((n, n), 1.0, 1.0, facecolor="#cfe8ff",
                                    edgecolor="#1f6fb2"))
        ax.text(n + 0.5, n + 0.5, f"I_{n}", ha="center", va="center")
    # loop-back arrow from the top rung to the bottom rung (infimum = {0})
    ax.add_patch(FancyArrowPatch((depth - 0.5, depth), (0.5, 0.0),
                 connectionstyle="arc3,rad=-0.5", arrowstyle="->",
                 mutation_scale=18, color="#b22222"))
    ax.text(depth * 0.55, 0.2, "infimum = {0} = I_0", color="#b22222")
    ax.set_xlim(-0.5, depth + 0.5)
    ax.set_ylim(-0.5, depth + 0.5)
    ax.set_aspect("equal")
    ax.set_title("Escher staircase: I_0 < I_1 < ... , yet the meet is I_0")
    ax.axis("off")
    plt.tight_layout()
    plt.savefig("escher_staircase.png", dpi=150)

if __name__ == "__main__":
    plot_staircase()
