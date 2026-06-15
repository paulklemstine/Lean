import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

def visualize_chain_vs_branching():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 7))

    # Left: Chain (realizable)
    chain_sets = [
        (set(), "emptyset", 0),
        ({0}, "{0}", 1),
        ({0, 2}, "{0,2}", 2),
        ({0, 1, 2}, "{0,1,2}", 3),
        ({0, 1, 2, 4}, "{0,1,2,4}", 4),
        ({0, 1, 2, 3, 4}, "{0,1,2,3,4}", 5),
    ]
    for i, (s, label, threshold) in enumerate(chain_sets):
        y = i * 1.2
        width = len(s) * 0.8 + 0.5
        rect = mpatches.FancyBboxPatch((2.5 - width/2, y - 0.3), width, 0.6,
                                        boxstyle="round,pad=0.1",
                                        facecolor=plt.cm.Blues(0.2 + 0.12*i),
                                        edgecolor="black", linewidth=1.5)
        ax1.add_patch(rect)
        ax1.text(2.5, y, label, ha="center", va="center", fontsize=9, fontweight="bold")
        ax1.text(5.2, y, f"threshold={threshold}", ha="left", va="center", fontsize=8, color="gray")
        if i > 0:
            ax1.annotate("", xy=(2.5, y - 0.35), xytext=(2.5, y - 0.85),
                        arrowprops=dict(arrowstyle="->", color="darkblue", lw=1.5))
    ax1.set_xlim(-0.5, 7)
    ax1.set_ylim(-1, 7)
    ax1.set_title("Realizable: Closed Sets Form a Chain", fontsize=13, fontweight="bold")
    ax1.axis("off")

    # Right: Branching (not realizable)
    branch_positions = {"emptyset": (2.5, 0), "{0,2}": (1, 2), "{1,3}": (4, 2), "{0,1,2,3}": (2.5, 4)}
    colors = {"emptyset": "#ffcccc", "{0,2}": "#ccffcc", "{1,3}": "#ccccff", "{0,1,2,3}": "#ffffcc"}
    for label, (x, y) in branch_positions.items():
        width = len(label) * 0.12 + 0.5
        rect = mpatches.FancyBboxPatch((x - width/2, y - 0.3), width, 0.6,
                                        boxstyle="round,pad=0.1",
                                        facecolor=colors[label],
                                        edgecolor="black", linewidth=1.5)
        ax2.add_patch(rect)
        ax2.text(x, y, label, ha="center", va="center", fontsize=9, fontweight="bold")
    edges = [("emptyset", "{0,2}"), ("emptyset", "{1,3}"), ("{0,2}", "{0,1,2,3}"), ("{1,3}", "{0,1,2,3}")]
    for src, dst in edges:
        x1, y1 = branch_positions[src]
        x2, y2 = branch_positions[dst]
        ax2.annotate("", xy=(x2, y2 - 0.35), xytext=(x1, y1 + 0.35),
                    arrowprops=dict(arrowstyle="->", color="darkred", lw=1.5))
    ax2.annotate("incomparable!", xy=(2.5, 2), fontsize=10, color="red",
                ha="center", va="center", fontweight="bold",
                bbox=dict(boxstyle="round,pad=0.2", facecolor="white", edgecolor="red", alpha=0.8))
    ax2.set_xlim(-0.5, 6)
    ax2.set_ylim(-1, 5.5)
    ax2.set_title("NOT Realizable: Closed Sets Branch", fontsize=13, fontweight="bold")
    ax2.axis("off")
    plt.tight_layout()
    plt.savefig("chain_vs_branching.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved chain_vs_branching.png")

visualize_chain_vs_branching()
