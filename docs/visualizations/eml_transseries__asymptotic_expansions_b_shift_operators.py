"""
Visualization: Shift Operators on the Growth Level Lattice

Shows the self-similar structure of the growth hierarchy
under exponential and logarithmic shifts.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))

    levels = range(-3, 4)
    exponents = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0]

    level_labels = {
        -3: "log³(x)", -2: "log²(x)", -1: "log(x)",
        0: "x", 1: "exp(x)", 2: "exp²(x)", 3: "exp³(x)"
    }

    # Draw the lattice points
    for l in levels:
        for e in exponents:
            color = '#2196F3' if l < 0 else ('#4CAF50' if l == 0 else '#F44336')
            ax.scatter(l, e, c=color, s=80, zorder=5, edgecolors='black', linewidths=0.5)

    # Draw shift arrows
    for l in range(-3, 3):
        for e in [1.0, 2.0]:
            ax.annotate("",
                        xy=(l + 1, e), xytext=(l, e),
                        arrowprops=dict(arrowstyle="->", color="#E91E63",
                                        lw=1.5, alpha=0.6))

    for l in range(-2, 4):
        for e in [1.5, 2.5]:
            ax.annotate("",
                        xy=(l - 1, e), xytext=(l, e),
                        arrowprops=dict(arrowstyle="->", color="#9C27B0",
                                        lw=1.5, alpha=0.6))

    # Labels
    for l, label in level_labels.items():
        ax.text(l, -0.2, label, ha='center', va='top', fontsize=9,
                fontweight='bold', color='black')

    ax.set_xlabel("Integer Level ℓ", fontsize=13)
    ax.set_ylabel("Real Exponent α", fontsize=13)
    ax.set_title("Growth Level Lattice with Shift Operators", fontsize=14)

    # Legend
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], marker='o', color='w', markerfacecolor='#2196F3',
               markersize=10, label='Logarithmic (ℓ < 0)'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='#4CAF50',
               markersize=10, label='Polynomial (ℓ = 0)'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='#F44336',
               markersize=10, label='Exponential (ℓ > 0)'),
        Line2D([0], [0], color='#E91E63', lw=2, label='expShift →'),
        Line2D([0], [0], color='#9C27B0', lw=2, label='← logShift'),
    ]
    ax.legend(handles=legend_elements, fontsize=10, loc='upper left')

    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(-0.5, 3.5)
    ax.grid(True, alpha=0.2)
    ax.axvline(x=-0.5, color='gray', linestyle=':', alpha=0.3)
    ax.axvline(x=0.5, color='gray', linestyle=':', alpha=0.3)

    plt.tight_layout()
    plt.savefig("Applications/shift_operators.png", dpi=150, bbox_inches='tight')
    print("Saved: Applications/shift_operators.png")


if __name__ == "__main__":
    main()
