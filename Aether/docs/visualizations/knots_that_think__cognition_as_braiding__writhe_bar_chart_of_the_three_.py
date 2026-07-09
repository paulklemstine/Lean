"""Visualization: writhe of the three cognitive braids as a bar chart."""
import matplotlib.pyplot as plt


def main() -> None:
    names = ["trivial", "creative", "confused"]
    writhes = [0, 3, 0]
    colors = ["#8899aa", "#2ca02c", "#d62728"]
    fig, ax = plt.subplots(figsize=(6, 4))
    ax.bar(names, writhes, color=colors)
    ax.set_ylabel("writhe (signed crossing count)")
    ax.set_title("Writhe detects creativity, is blind to confusion")
    for i, w in enumerate(writhes):
        ax.text(i, w + 0.05, str(w), ha="center")
    ax.axhline(0, color="black", linewidth=0.8)
    fig.tight_layout()
    fig.savefig("writhe_bars.png", dpi=150)
    print("saved writhe_bars.png")


if __name__ == "__main__":
    main()
