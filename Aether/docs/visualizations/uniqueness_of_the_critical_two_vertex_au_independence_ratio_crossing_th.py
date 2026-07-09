"""Standalone visualization: independence ratio crossing 1/4 as vertices are added.
Generates a PNG plotting 7/m against the critical line 1/4 for m = 27..40,
highlighting the base (27), boundary (28), and crossing (29)."""
from fractions import Fraction
import matplotlib.pyplot as plt


def main() -> None:
    ms = list(range(27, 41))
    ratios = [7.0 / m for m in ms]
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(ms, ratios, "o-", color="#2b6cb0", label="independence ratio 7/m")
    ax.axhline(0.25, color="#c53030", ls="--", label="critical value 1/4")
    for m, tag, col in [(27, "base G27", "#38a169"),
                        (28, "boundary", "#dd6b20"),
                        (29, "G29 crosses", "#805ad5")]:
        ax.scatter([m], [7.0 / m], s=140, zorder=5, color=col)
        ax.annotate(tag, (m, 7.0 / m), textcoords="offset points",
                    xytext=(6, 10), fontsize=9, color=col)
    ax.set_xlabel("number of vertices m")
    ax.set_ylabel("ratio")
    ax.set_title("Independence ratio 7/m crossing the 1/4 threshold")
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("independence_ratio_crossing.png", dpi=150)
    print("wrote independence_ratio_crossing.png")


if __name__ == "__main__":
    main()
