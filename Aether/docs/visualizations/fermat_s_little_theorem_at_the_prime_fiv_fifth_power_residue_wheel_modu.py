import matplotlib.pyplot as plt
import numpy as np

def visualize_residue_wheel(p: int = 5) -> None:
    angles = np.linspace(0, 2 * np.pi, p, endpoint=False)
    xs, ys = np.cos(angles), np.sin(angles)
    fig, ax = plt.subplots(figsize=(6, 6))
    ax.scatter(xs, ys, s=600, zorder=3)
    for i in range(p):
        ax.annotate(str(i), (xs[i], ys[i]), ha="center", va="center",
                    fontsize=14, zorder=4)
        j = pow(i, p, p)
        ax.annotate("", xy=(xs[j], ys[j]), xytext=(xs[i], ys[i]),
                    arrowprops=dict(arrowstyle="->", color="crimson", lw=2))
    ax.set_title(f"x -> x^{p} on Z/{p}Z (all self-loops = identity)")
    ax.set_aspect("equal"); ax.axis("off")
    plt.tight_layout(); plt.savefig("residue_wheel.png", dpi=150)

if __name__ == "__main__":
    visualize_residue_wheel()
