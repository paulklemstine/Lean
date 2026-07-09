"""Draw a simple braid diagram for a braid word on n strands."""
import matplotlib.pyplot as plt


def draw_braid(word, n=3, filename="braid_diagram.png"):
    fig, ax = plt.subplots(figsize=(4, 6))
    positions = list(range(n))
    for level, (i, sign) in enumerate(word):
        y0, y1 = level, level + 1
        for s in range(n):
            if s == i:
                ax.plot([s, s + 1], [y0, y1], color="#c44e52" if sign else "#4c72b0", lw=2)
            elif s == i + 1:
                ax.plot([s, s - 1], [y0, y1], color="#c44e52" if sign else "#4c72b0", lw=2)
            else:
                ax.plot([s, s], [y0, y1], color="gray", lw=1)
    ax.set_title("Cognitive braid diagram")
    ax.axis("off")
    plt.tight_layout()
    plt.savefig(filename, dpi=150)
    print("saved", filename)


if __name__ == "__main__":
    draw_braid([(0, True), (1, True), (0, True)])  # trefoil braid
