"""Standalone visualization: the independence-ratio threshold at n=29.

Plots the inverse independence ratio n/alpha as vertex count n grows with the
independence number fixed at alpha=7, highlighting the crossing of the value 4
at n=29. Requires matplotlib."""
import matplotlib.pyplot as plt


def main() -> None:
    alpha = 7
    ns = list(range(20, 40))
    ratios = [n / alpha for n in ns]

    fig, ax = plt.subplots(figsize=(9, 5))
    ax.plot(ns, ratios, "o-", color="#2b6cb0", label=r"$n/\alpha$ with $\alpha=7$")
    ax.axhline(4.0, color="#c53030", linestyle="--", label=r"threshold $4$")
    ax.axvline(29, color="#2f855a", linestyle=":", label=r"$n=29$")
    ax.scatter([29], [29 / 7], color="#2f855a", zorder=5, s=80)
    ax.annotate(r"$29/7 = 4.142\ldots > 4$", xy=(29, 29 / 7),
                xytext=(30.5, 4.4),
                arrowprops=dict(arrowstyle="->", color="#2f855a"))
    ax.set_xlabel("vertex count $n$")
    ax.set_ylabel(r"inverse independence ratio $n/\alpha$")
    ax.set_title("The 29-vertex threshold for independence number 7")
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("threshold.png", dpi=150)
    print("Saved threshold.png")


if __name__ == "__main__":
    main()
