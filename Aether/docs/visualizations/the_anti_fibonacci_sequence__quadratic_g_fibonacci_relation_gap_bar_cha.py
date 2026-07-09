"""Visualization 3: Fibonacci-relation gap  (A(n+1)+A(n)) - A(n+2),  highlighting {0,3}."""
from __future__ import annotations
import matplotlib.pyplot as plt


def closed(n: int) -> int:
    return 1 + n * (n - 1) // 2


def main() -> None:
    ns = list(range(0, 21))
    gap = [(closed(n + 1) + closed(n)) - closed(n + 2) for n in ns]
    colors = ["seagreen" if g == 0 else "slategray" for g in gap]

    fig, ax = plt.subplots(figsize=(9, 5.5))
    ax.bar(ns, gap, color=colors)
    ax.axhline(0, color="black", lw=1)
    for n in (0, 3):
        ax.annotate("coincidence", xy=(n, 0), xytext=(n, 3),
                    ha="center", color="seagreen",
                    arrowprops=dict(arrowstyle="->", color="seagreen"))
    ax.set_title("Fibonacci-relation gap  (A(n+1)+A(n)) - A(n+2)\n"
                 "zero exactly at n = 0 and n = 3, positive (undershoot) for n >= 4")
    ax.set_xlabel("n"); ax.set_ylabel("gap"); ax.set_xticks(ns)

    fig.tight_layout()
    fig.savefig("antifib_gap.png", dpi=150)
    print("saved antifib_gap.png")


if __name__ == "__main__":
    main()
