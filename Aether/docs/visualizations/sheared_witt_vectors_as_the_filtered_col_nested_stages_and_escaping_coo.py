"""Visualization: nested stages S_0 subset S_1 subset ... and where coords land."""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def main() -> None:
    fig, ax = plt.subplots(figsize=(8, 6))
    # draw nested boxes for stages S_0 .. S_5
    for i in range(6):
        r = mpatches.Rectangle((-0.5 - i, -0.5 - i), 2 * (i + 1), 2 * (i + 1),
                               fill=False, edgecolor="gray")
        ax.add_patch(r)
        ax.text(0, i + 0.6, f"S_{i}", ha="center", color="gray")
    # place variable-vector coordinates X_k at radius k (escaping outward)
    for k in range(6):
        ax.plot(0, -k, "o", color="crimson")
        ax.text(0.2, -k, f"X_{k}", color="crimson")
    ax.set_xlim(-7, 7); ax.set_ylim(-7, 7)
    ax.set_aspect("equal")
    ax.set_title("Coordinates of the variable vector escape every finite stage")
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("stages.png", dpi=150)
    print("wrote stages.png")

if __name__ == "__main__":
    main()
