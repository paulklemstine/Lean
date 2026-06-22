"""Visualize the strict truncation-level hierarchy as a ladder.
Requires matplotlib. Saves truncation.png."""
import matplotlib.pyplot as plt

levels = [("contractible (-2)", 0), ("proposition (-1)", 1),
          ("set (0)", 2), ("groupoid (1)", 3)]

if __name__ == "__main__":
    fig, ax = plt.subplots(figsize=(6, 5))
    for name, idx in levels:
        ax.plot([0, 1], [idx, idx], lw=3)
        ax.text(1.05, idx, f"{name}", va="center")
    ax.set_yticks([i for _, i in levels])
    ax.set_xlim(-0.1, 2.2); ax.set_xticks([])
    ax.set_ylabel("truncation index (n + 2)")
    ax.set_title("The strict truncation hierarchy")
    plt.tight_layout(); plt.savefig("truncation.png", dpi=140)
    print("saved truncation.png")
