import matplotlib.pyplot as plt

def visualize_Ktt(t: int = 5) -> None:
    """Draw the balanced complete bipartite witness K_{t,t}."""
    ax = plt.gca()
    ya = list(range(t)); yb = list(range(t))
    for i in ya:
        for j in yb:
            ax.plot([0, 1], [i, j], color="steelblue", alpha=0.35, lw=0.8)
    ax.scatter([0]*t, ya, s=120, color="crimson", zorder=3, label="side A")
    ax.scatter([1]*t, yb, s=120, color="darkgreen", zorder=3, label="side B")
    ax.set_title(f"K_{{{t},{t}}}: {t*t} edges, C_d-free for odd d")
    ax.axis("off"); ax.legend()
    plt.tight_layout(); plt.savefig("Ktt.png", dpi=150)

if __name__ == "__main__":
    visualize_Ktt(5)
