"""Visualize how superimposing more right/left cuts progressively isolates a point,
shrinking the pooled neighborhood of x down to {x}."""
import matplotlib.pyplot as plt


def plot_pinning(x: float = 0.0) -> None:
    fig, ax = plt.subplots(figsize=(9, 4))
    widths = [1.0, 0.5, 0.25, 0.1]
    for row, w in enumerate(widths):
        y = len(widths) - row
        ax.hlines(y, x, x + w, color="crimson", lw=5, alpha=0.6)
        ax.hlines(y, x - w, x, color="royalblue", lw=5, alpha=0.6)
        ax.plot(x, y, "ko", ms=7)
        ax.text(x + w + 0.03, y,
                rf"$[x,x+{w})\cap(x-{w},x]=\{{x\}}$", va="center", fontsize=9)
    ax.plot(x, 0.3, "k*", ms=22)
    ax.text(x + 0.03, 0.3, r"limit: $\{x\}$ isolated (discrete)", va="center")
    ax.axvline(x, color="gray", ls=":", lw=0.8)
    ax.text(x, len(widths) + 0.6, "$x$", ha="center")
    ax.set_xlim(x - 1.4, x + 1.4)
    ax.set_ylim(0, len(widths) + 1)
    ax.axis("off")
    ax.set_title("Pooling half-open cuts pins x from both sides")
    plt.tight_layout()
    plt.savefig("point_pinning.png", dpi=150)
    print("wrote point_pinning.png")


if __name__ == "__main__":
    plot_pinning()
