#!/usr/bin/env python3
"""
Visualization: GL Frame Structure and Tangling Hierarchy

Generates a visual representation of GL frames, reflective towers,
and soundness spectra using matplotlib.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import Dict, Set, Tuple, List


def draw_gl_frame(worlds: List[int], edges: List[Tuple[int, int]],
                  tangling_degrees: Dict[int, int],
                  soundness_status: Dict[int, str],
                  title: str = "GL Frame Structure"):
    """Draw a GL frame as a directed graph with annotations."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    n = len(worlds)
    # Position worlds in a vertical layout (higher = more powerful)
    positions = {}
    for i, w in enumerate(sorted(worlds)):
        x = 0.5 + 0.3 * np.sin(i * 0.5)
        y = i / max(n - 1, 1)
        positions[w] = (x, y)

    # Draw edges
    for u, v in edges:
        x1, y1 = positions[u]
        x2, y2 = positions[v]
        dx, dy = x2 - x1, y2 - y1
        ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle="->", color="steelblue",
                                   alpha=0.4, lw=1.5,
                                   connectionstyle="arc3,rad=0.1"))

    # Draw worlds
    colors = {"sound": "#4CAF50", "unsound": "#FF5722", "terminal": "#9E9E9E"}
    for w in worlds:
        x, y = positions[w]
        status = soundness_status.get(w, "unsound")
        color = colors.get(status, "#9E9E9E")
        deg = tangling_degrees.get(w, 0)

        circle = plt.Circle((x, y), 0.035, facecolor=color,
                            edgecolor="black", linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, str(w), ha="center", va="center",
                fontsize=14, fontweight="bold", zorder=6, color="white")
        ax.text(x + 0.06, y + 0.02, f"deg={deg}", fontsize=9,
                ha="left", va="bottom", color="dimgray")

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor=colors["sound"], edgecolor="black",
                       label="Sound for ⊥ (consistent)"),
        mpatches.Patch(facecolor=colors["unsound"], edgecolor="black",
                       label="Unsound for ⊥"),
        mpatches.Patch(facecolor=colors["terminal"], edgecolor="black",
                       label="Terminal (no successors)"),
    ]
    ax.legend(handles=legend_elements, loc="upper left", fontsize=10)

    ax.set_xlim(0, 1)
    ax.set_ylim(-0.1, 1.1)
    ax.set_aspect("equal")
    ax.set_title(title, fontsize=16, fontweight="bold")
    ax.axis("off")

    plt.tight_layout()
    plt.savefig("gl_frame_structure.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved: gl_frame_structure.png")


def draw_soundness_spectrum_heatmap(n_worlds: int = 6):
    """Draw a heatmap of soundness spectrum across worlds and formulas."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Build reflective tower
    worlds = list(range(n_worlds))
    formula_names = ["⊥", "⊤", "p", "□⊥", "□p", "□(□⊥→⊥)", "Con"]

    # Compute spectrum manually for the chain frame
    # In a chain 0 ← 1 ← 2 ← ... ← n-1:
    # World 0 is terminal: □φ vacuously true, so soundness = forces φ
    # Higher worlds: more complex

    spectrum_data = np.zeros((n_worlds, len(formula_names)))

    for w in worlds:
        # ⊥: never sound (□⊥ is true at terminals but ⊥ is false)
        spectrum_data[w, 0] = 0

        # ⊤: always sound (⊤ is always true)
        spectrum_data[w, 1] = 1

        # p: depends on valuation; say p true at even worlds
        if w == 0:  # terminal, p true at 0
            spectrum_data[w, 2] = 1
        else:
            spectrum_data[w, 2] = 0.5  # depends on valuation

        # □⊥: sound iff world has no successors or □⊥ is false
        if w == 0:
            spectrum_data[w, 3] = 0  # □⊥ true, ⊥ false → unsound
        else:
            spectrum_data[w, 3] = 1  # □⊥ false → implication true

        # □p: similar analysis
        if w == 0:
            spectrum_data[w, 4] = 0  # □p true (vacuous), p true → sound
        else:
            spectrum_data[w, 4] = 0.5  # depends

        # □(□⊥→⊥): the consistency proof formula
        if w == 0:
            spectrum_data[w, 5] = 0  # vacuously □, but forces ⊥ fails
        elif w == 1:
            spectrum_data[w, 5] = 0  # has successor 0 where □⊥→⊥ fails
        else:
            spectrum_data[w, 5] = 0  # chain continues

        # Con = ¬□⊥
        if w == 0:
            spectrum_data[w, 6] = 0  # □(¬□⊥) true, ¬□⊥ false → unsound
        else:
            spectrum_data[w, 6] = 1  # □Con false → imp true

    cmap = plt.cm.RdYlGn
    im = ax.imshow(spectrum_data, cmap=cmap, aspect="auto",
                   vmin=0, vmax=1, interpolation="nearest")

    ax.set_xticks(range(len(formula_names)))
    ax.set_xticklabels(formula_names, fontsize=12)
    ax.set_yticks(range(n_worlds))
    ax.set_yticklabels([f"Level {w}" for w in worlds], fontsize=11)

    ax.set_xlabel("Formula", fontsize=13)
    ax.set_ylabel("Tower Level", fontsize=13)
    ax.set_title("Soundness Spectrum across Reflective Tower Levels",
                 fontsize=14, fontweight="bold")

    # Add text annotations
    for i in range(n_worlds):
        for j in range(len(formula_names)):
            val = spectrum_data[i, j]
            text = "✓" if val >= 0.9 else ("?" if val > 0.1 else "✗")
            color = "white" if val < 0.3 or val > 0.7 else "black"
            ax.text(j, i, text, ha="center", va="center",
                    fontsize=14, color=color, fontweight="bold")

    plt.colorbar(im, ax=ax, label="Soundness (1=sound, 0=unsound)")
    plt.tight_layout()
    plt.savefig("soundness_spectrum.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved: soundness_spectrum.png")


def draw_tangling_degree_growth():
    """Plot tangling degree as a function of tower height."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: tangling degree vs tower level
    heights = list(range(1, 20))
    for h in [5, 10, 15, 20]:
        degrees = list(range(h))  # In a chain, deg(w_i) = i
        ax1.plot(range(h), degrees, "o-", label=f"Tower height {h}",
                 markersize=5, alpha=0.8)

    ax1.set_xlabel("Tower Level", fontsize=12)
    ax1.set_ylabel("Tangling Degree", fontsize=12)
    ax1.set_title("Tangling Degree Growth in Reflective Towers",
                  fontsize=13, fontweight="bold")
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: consistency gap visualization
    levels = list(range(8))
    can_prove_own_con = [False] * 8
    can_prove_lower_con = [False] + [True] * 7

    x = np.arange(len(levels))
    width = 0.35

    bars1 = ax2.bar(x - width/2, [int(b) for b in can_prove_own_con],
                    width, label="Proves own Con", color="#FF5722", alpha=0.8)
    bars2 = ax2.bar(x + width/2, [int(b) for b in can_prove_lower_con],
                    width, label="Proves lower Con", color="#4CAF50", alpha=0.8)

    ax2.set_xlabel("Tower Level", fontsize=12)
    ax2.set_ylabel("Can Prove", fontsize=12)
    ax2.set_title("The Consistency Gap (2nd Incompleteness)",
                  fontsize=13, fontweight="bold")
    ax2.set_xticks(x)
    ax2.set_xticklabels([f"L{i}" for i in levels])
    ax2.set_yticks([0, 1])
    ax2.set_yticklabels(["No", "Yes"])
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3, axis="y")

    plt.tight_layout()
    plt.savefig("tangling_growth.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved: tangling_growth.png")


if __name__ == "__main__":
    # Example: 6-world reflective tower
    n = 6
    worlds = list(range(n))
    edges = [(i, j) for i in range(n) for j in range(i)]
    degrees = {w: w for w in worlds}  # deg(w_i) = i in a chain

    # Soundness status: world 0 is terminal (unsound for ⊥ since □⊥
    # is vacuously true but ⊥ is false). Others are sound for ⊥
    # (□⊥ is false since they have successors, so □⊥→⊥ is vacuously true).
    status = {0: "terminal"}
    for w in range(1, n):
        status[w] = "sound"

    draw_gl_frame(worlds, edges, degrees, status,
                  title="6-Level Reflective Tower (GL Frame)")
    draw_soundness_spectrum_heatmap(n)
    draw_tangling_degree_growth()
