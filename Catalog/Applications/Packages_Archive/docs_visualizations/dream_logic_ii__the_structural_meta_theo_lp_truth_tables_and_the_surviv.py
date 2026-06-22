"""Visualize the LP truth tables and the structural/connective dichotomy.

Produces a single figure with: the negation/conjunction/disjunction tables over the
chain ff<bb<tt (with the glut bb highlighted), and a ledger of which rules survive.
Requires matplotlib.
"""
from __future__ import annotations
import matplotlib.pyplot as plt
import numpy as np

FF, BB, TT = 0, 1, 2
LABELS = ["ff", "bb", "tt"]


def neg(a: int) -> int:
    return BB if a == BB else (TT if a == FF else FF)


def main() -> None:
    fig, axes = plt.subplots(1, 4, figsize=(18, 4.5))

    # Negation table (1-D).
    ax = axes[0]
    neg_row = np.array([[neg(a) for a in (FF, BB, TT)]])
    ax.imshow(neg_row, cmap="coolwarm", vmin=0, vmax=2, aspect="auto")
    for j, a in enumerate((FF, BB, TT)):
        ax.text(j, 0, LABELS[neg(a)], ha="center", va="center", fontsize=14)
    ax.set_xticks(range(3)); ax.set_xticklabels(LABELS)
    ax.set_yticks([0]); ax.set_yticklabels(["neg a"])
    ax.set_title("Negation (fixes the glut bb)")

    # Conjunction = min, Disjunction = max.
    for ax, op, name in ((axes[1], np.minimum, "Conjunction = min"),
                         (axes[2], np.maximum, "Disjunction = max")):
        grid = np.array([[op(a, b) for b in (FF, BB, TT)] for a in (FF, BB, TT)])
        ax.imshow(grid, cmap="coolwarm", vmin=0, vmax=2)
        for i in range(3):
            for j in range(3):
                ax.text(j, i, LABELS[grid[i, j]], ha="center", va="center", fontsize=13)
        ax.set_xticks(range(3)); ax.set_xticklabels(LABELS)
        ax.set_yticks(range(3)); ax.set_yticklabels(LABELS)
        ax.set_title(name)

    # Dichotomy ledger.
    ax = axes[3]; ax.axis("off")
    rows = [
        ("Reflexivity", True), ("Monotonicity", True), ("Cut", True),
        ("Adjunction (and-intro)", True), ("Addition (or-intro)", True),
        ("Disjunctive syllogism", False), ("Modus ponens", False),
    ]
    ax.set_title("Structural & introduction rules SURVIVE;\nelimination rules DIE", fontsize=12)
    for i, (label, ok) in enumerate(rows):
        color = "#2a7d2a" if ok else "#b22222"
        mark = "survives" if ok else "FAILS"
        ax.text(0.02, 0.9 - i * 0.12, f"{label}", fontsize=12, transform=ax.transAxes)
        ax.text(0.78, 0.9 - i * 0.12, mark, fontsize=12, color=color,
                weight="bold", transform=ax.transAxes)

    fig.suptitle("Dream Logic II: the Logic of Paradox at a glance", fontsize=15)
    fig.tight_layout()
    fig.savefig("dream_logic_tables.png", dpi=130)
    print("wrote dream_logic_tables.png")


if __name__ == "__main__":
    main()
