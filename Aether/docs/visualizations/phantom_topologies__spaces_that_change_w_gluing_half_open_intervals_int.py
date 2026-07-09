"""Visualize the two-observer decomposition of the real line: how a left
half-open and a right half-open interval glue into a two-sided neighborhood.

Requires: matplotlib.
"""
from __future__ import annotations
import matplotlib.pyplot as plt


def main():
    x, eps = 0.0, 1.0
    fig, ax = plt.subplots(figsize=(8, 2))
    ax.hlines(2, x - eps, x, color="#3498db", lw=6, label="upper-limit (a,x]")
    ax.hlines(1, x, x + eps, color="#e67e22", lw=6, label="lower-limit [x,b)")
    ax.hlines(0, x - eps, x + eps, color="#2ecc71", lw=6,
              label="Euclidean (a,b)")
    ax.plot([x], [2], "o", color="#3498db")   # closed at x
    ax.plot([x], [1], "o", color="#e67e22")   # closed at x
    ax.set_yticks([0, 1, 2])
    ax.set_yticklabels(["consensus", "lower", "upper"])
    ax.set_title("(a,x] U [x,b) = (a,b): reality = agreement of two observers")
    ax.legend(loc="upper right")
    plt.savefig("line_split.png", dpi=150, bbox_inches="tight")
    print("saved line_split.png")


if __name__ == "__main__":
    main()
