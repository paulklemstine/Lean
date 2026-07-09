"""
Visualization: residue-class coverage of the Erdos-Straus conjecture.

Colors each integer 2 <= n < 300 by which structural rule solves 4/n:
even, multiple of three, n = 3 mod 4 (Sierpinski), n = 5 mod 8 (Komornik),
or reduction to a prime p = 1 mod 8 (the open core). The plot makes the
"great collapse" visible: almost every residue is covered, and the open
cases form a sparse set.
"""

from __future__ import annotations

from typing import List
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def min_fac(n: int) -> int:
    if n % 2 == 0:
        return 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return d
        d += 2
    return n


def classify(n: int) -> str:
    """Return the rule that first applies to n."""
    if n % 2 == 0:
        return "even"
    if n % 3 == 0:
        return "mult_of_3"
    if n % 4 == 3:
        return "sierpinski"   # n = 3 mod 4
    if n % 8 == 5:
        return "komornik"     # n = 5 mod 8
    # n = 1 mod 8 and odd, not divisible by 3:
    p = min_fac(n)
    return "prime_core" if p == n else "lift_to_core"


COLORS = {
    "even": "#4C72B0",
    "mult_of_3": "#55A868",
    "sierpinski": "#C44E52",
    "komornik": "#8172B3",
    "lift_to_core": "#CCB974",
    "prime_core": "#000000",
}
LABELS = {
    "even": "Even (n = 2m)",
    "mult_of_3": "Multiple of 3",
    "sierpinski": "Sierpinski (n = 3 mod 4)",
    "komornik": "Komornik (n = 5 mod 8)",
    "lift_to_core": "Lift to core prime",
    "prime_core": "Open core: prime = 1 mod 8",
}


def main() -> None:
    N = 300
    cols = 30
    fig, ax = plt.subplots(figsize=(12, 5))
    for n in range(2, N):
        cls = classify(n)
        row, col = divmod(n, cols)
        ax.add_patch(plt.Rectangle((col, -row), 0.92, 0.92,
                                   color=COLORS[cls]))
        ax.text(col + 0.46, -row + 0.46, str(n), ha="center", va="center",
                fontsize=5, color="white" if cls == "prime_core" else "black")
    ax.set_xlim(0, cols)
    ax.set_ylim(-(N // cols) - 1, 1)
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_title("Erdos-Straus: which rule solves 4/n  (2 <= n < 300)")
    handles: List[mpatches.Patch] = [
        mpatches.Patch(color=COLORS[k], label=LABELS[k]) for k in LABELS
    ]
    ax.legend(handles=handles, loc="lower center", ncol=3,
              bbox_to_anchor=(0.5, -0.18), fontsize=8)
    plt.tight_layout()
    plt.savefig("erdos_straus_coverage.png", dpi=150, bbox_inches="tight")
    print("Saved erdos_straus_coverage.png")


if __name__ == "__main__":
    main()
