#!/usr/bin/env python3
"""
Demo: 3-SAT to Jigsaw Puzzle Reduction

Demonstrates the reduction from 3-SAT to jigsaw puzzle solving,
showing how boolean satisfiability maps to puzzle piece assembly.
"""

from enum import Enum
from dataclasses import dataclass
from typing import List, Tuple, Optional


class EdgeType(Enum):
    FLAT = "flat"
    TAB = "tab"
    BLANK = "blank"

    def complement(self) -> 'EdgeType':
        if self == EdgeType.TAB:
            return EdgeType.BLANK
        elif self == EdgeType.BLANK:
            return EdgeType.TAB
        return EdgeType.FLAT

    def compatible(self, other: 'EdgeType') -> bool:
        return other == self.complement()


@dataclass
class JigsawPiece:
    top: EdgeType
    right: EdgeType
    bottom: EdgeType
    left: EdgeType

    def __repr__(self):
        return f"[T:{self.top.value} R:{self.right.value} B:{self.bottom.value} L:{self.left.value}]"


@dataclass
class Literal:
    var: int
    polarity: bool  # True = positive, False = negated

    def eval(self, assignment: List[bool]) -> bool:
        val = assignment[self.var]
        return val if self.polarity else not val

    def __repr__(self):
        return f"x{self.var}" if self.polarity else f"¬x{self.var}"


@dataclass
class Clause:
    literals: List[Literal]

    def satisfied(self, assignment: List[bool]) -> bool:
        return any(lit.eval(assignment) for lit in self.literals)

    def __repr__(self):
        return f"({' ∨ '.join(str(l) for l in self.literals)})"


def bool_to_edge(b: bool) -> EdgeType:
    return EdgeType.TAB if b else EdgeType.BLANK


def variable_piece(val: bool) -> JigsawPiece:
    return JigsawPiece(
        top=EdgeType.FLAT,
        right=bool_to_edge(val),
        bottom=EdgeType.FLAT,
        left=EdgeType.FLAT,
    )


def clause_piece(vals: List[bool]) -> JigsawPiece:
    return JigsawPiece(
        top=bool_to_edge(vals[0]),
        right=bool_to_edge(any(vals)),
        bottom=bool_to_edge(vals[2]),
        left=bool_to_edge(vals[1]),
    )


def reduce_formula(clauses: List[Clause], num_vars: int, assignment: List[bool]):
    """Perform the reduction and check the puzzle encoding."""
    print("=" * 60)
    print("3-SAT to Jigsaw Puzzle Reduction")
    print("=" * 60)

    # Display formula
    formula_str = " ∧ ".join(str(c) for c in clauses)
    print(f"\nFormula: {formula_str}")
    print(f"Variables: {num_vars}, Clauses: {len(clauses)}")
    print(f"Total pieces: 2×{num_vars} + {len(clauses)} = {2*num_vars + len(clauses)}")

    # Display assignment
    assign_str = ", ".join(f"x{i}={'T' if v else 'F'}" for i, v in enumerate(assignment))
    print(f"\nAssignment: {assign_str}")

    # Variable pieces
    print("\n--- Variable Pieces ---")
    for i in range(num_vars):
        true_piece = variable_piece(True)
        false_piece = variable_piece(False)
        selected = variable_piece(assignment[i])
        print(f"  x{i}: TRUE piece {true_piece}, FALSE piece {false_piece}")
        print(f"       Selected: {'TRUE' if assignment[i] else 'FALSE'} → {selected}")
        print(f"       Complementary edges: {true_piece.right} ↔ {false_piece.right} "
              f"(compatible: {true_piece.right.compatible(false_piece.right)})")

    # Clause pieces
    print("\n--- Clause Pieces ---")
    all_satisfied = True
    for j, c in enumerate(clauses):
        lit_vals = [lit.eval(assignment) for lit in c.literals]
        piece = clause_piece(lit_vals)
        sat = c.satisfied(assignment)
        all_satisfied = all_satisfied and sat

        print(f"  Clause {j}: {c}")
        print(f"    Literal values: {['T' if v else 'F' for v in lit_vals]}")
        print(f"    Piece: {piece}")
        print(f"    Output (right edge): {piece.right.value} "
              f"→ {'SATISFIED ✓' if sat else 'UNSATISFIED ✗'}")

    print(f"\n{'='*60}")
    print(f"Formula satisfied: {'YES ✓' if all_satisfied else 'NO ✗'}")
    print(f"All clause pieces output TAB: {'YES ✓' if all_satisfied else 'NO ✗'}")
    print(f"{'='*60}")

    return all_satisfied


def main():
    # Example 1: (x₁ ∨ x₂ ∨ ¬x₃) ∧ (¬x₁ ∨ x₃ ∨ x₃)
    print("\n" + "█" * 60)
    print("  EXAMPLE 1: Satisfiable Formula")
    print("█" * 60)

    clauses1 = [
        Clause([Literal(0, True), Literal(1, True), Literal(2, False)]),
        Clause([Literal(0, False), Literal(2, True), Literal(2, True)]),
    ]
    assignment1 = [True, True, True]
    reduce_formula(clauses1, 3, assignment1)

    # Example 2: Unsatisfiable instance
    print("\n\n" + "█" * 60)
    print("  EXAMPLE 2: Checking Unsatisfying Assignment")
    print("█" * 60)

    clauses2 = [
        Clause([Literal(0, True), Literal(1, True), Literal(2, True)]),
        Clause([Literal(0, False), Literal(1, False), Literal(2, False)]),
    ]
    assignment2 = [True, True, True]
    reduce_formula(clauses2, 3, assignment2)

    # Example 3: Complement duality
    print("\n\n" + "█" * 60)
    print("  EXAMPLE 3: Complement Duality")
    print("█" * 60)

    piece = JigsawPiece(EdgeType.TAB, EdgeType.BLANK, EdgeType.TAB, EdgeType.FLAT)
    comp = JigsawPiece(
        piece.top.complement(),
        piece.right.complement(),
        piece.bottom.complement(),
        piece.left.complement(),
    )
    double_comp = JigsawPiece(
        comp.top.complement(),
        comp.right.complement(),
        comp.bottom.complement(),
        comp.left.complement(),
    )

    print(f"\nOriginal piece:  {piece}")
    print(f"Complement:      {comp}")
    print(f"Double complement: {double_comp}")
    print(f"Double complement == original: {piece == double_comp}")

    # Configuration space counting
    print("\n\n" + "█" * 60)
    print("  EXAMPLE 4: Configuration Space Size")
    print("█" * 60)

    for n in range(1, 5):
        for m in range(1, 5):
            configs = 81 ** (n * m)
            adj = (n - 1) * m + n * (m - 1) if n > 0 and m > 0 else 0
            print(f"  {n}×{m} grid: {configs:>15,} configurations, {adj} adjacency constraints")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: 3-SAT to Jigsaw Puzzle Reduction

Creates a visual representation of how a 3-SAT formula maps to jigsaw puzzle pieces,
showing the variable pieces, clause pieces, and their edge compatibility.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def draw_piece(ax, x, y, top, right, bottom, left, label="", color="white", size=1.0):
    """Draw a jigsaw piece at position (x, y) with given edge types."""
    edge_colors = {"flat": "#888888", "tab": "#2ecc71", "blank": "#e74c3c"}
    edge_symbols = {"flat": "—", "tab": "▶", "blank": "◀"}

    # Draw the piece body
    rect = patches.FancyBboxPatch(
        (x - size / 2, y - size / 2), size, size,
        boxstyle="round,pad=0.05", facecolor=color, edgecolor="black", linewidth=2
    )
    ax.add_patch(rect)

    # Draw edge indicators
    offset = size * 0.45
    font_size = 10

    # Top edge
    ax.plot([x - size * 0.3, x + size * 0.3], [y + offset, y + offset],
            color=edge_colors[top], linewidth=4)

    # Right edge
    ax.plot([x + offset, x + offset], [y - size * 0.3, y + size * 0.3],
            color=edge_colors[right], linewidth=4)

    # Bottom edge
    ax.plot([x - size * 0.3, x + size * 0.3], [y - offset, y - offset],
            color=edge_colors[bottom], linewidth=4)

    # Left edge
    ax.plot([x - offset, x - offset], [y - size * 0.3, y + size * 0.3],
            color=edge_colors[left], linewidth=4)

    # Label
    if label:
        ax.text(x, y, label, ha="center", va="center", fontsize=9, fontweight="bold")


def draw_legend(ax):
    """Draw a legend for edge types."""
    legend_items = [
        ("flat (boundary)", "#888888"),
        ("tab (protruding)", "#2ecc71"),
        ("blank (receiving)", "#e74c3c"),
    ]
    for i, (name, color) in enumerate(legend_items):
        ax.plot([0.05], [0.9 - i * 0.08], "s", color=color, markersize=12,
                transform=ax.transAxes)
        ax.text(0.1, 0.9 - i * 0.08, name, transform=ax.transAxes,
                fontsize=10, va="center")


def main():
    fig, axes = plt.subplots(2, 2, figsize=(16, 14))

    # Panel 1: Variable Pieces
    ax1 = axes[0, 0]
    ax1.set_title("Variable Pieces: Mutual Exclusion", fontsize=14, fontweight="bold")
    ax1.set_xlim(-1, 7)
    ax1.set_ylim(-1, 3)
    ax1.set_aspect("equal")
    ax1.axis("off")

    for i in range(3):
        # TRUE piece
        draw_piece(ax1, i * 2.5, 2, "flat", "tab", "flat", "flat",
                   f"x{i}=T", "#d5f5e3", 0.9)
        # FALSE piece
        draw_piece(ax1, i * 2.5, 0.5, "flat", "blank", "flat", "flat",
                   f"x{i}=F", "#fadbd8", 0.9)
        # Complementary arrow
        ax1.annotate("", xy=(i * 2.5 + 0.5, 0.9), xytext=(i * 2.5 + 0.5, 1.6),
                     arrowprops=dict(arrowstyle="<->", color="purple", lw=2))
        ax1.text(i * 2.5 + 0.75, 1.25, "complement", fontsize=7, color="purple",
                 rotation=90, va="center")

    # Panel 2: Clause Pieces (OR gate)
    ax2 = axes[0, 1]
    ax2.set_title("Clause Piece: OR Gate", fontsize=14, fontweight="bold")
    ax2.set_xlim(-1, 6)
    ax2.set_ylim(-1, 4)
    ax2.set_aspect("equal")
    ax2.axis("off")

    # Show clause piece for different input combinations
    combos = [
        ([True, True, False], "T∨T∨F", "#d5f5e3"),
        ([False, False, False], "F∨F∨F", "#fadbd8"),
        ([False, True, False], "F∨T∨F", "#d5f5e3"),
        ([True, False, True], "T∨F∨T", "#d5f5e3"),
    ]
    for idx, (vals, label, color) in enumerate(combos):
        x = (idx % 2) * 3
        y = 2.5 - (idx // 2) * 2
        edges = {
            "top": "tab" if vals[0] else "blank",
            "right": "tab" if any(vals) else "blank",
            "bottom": "tab" if vals[2] else "blank",
            "left": "tab" if vals[1] else "blank",
        }
        draw_piece(ax2, x, y, **edges, label=label, color=color, size=1.2)
        output = "TAB ✓" if any(vals) else "BLANK ✗"
        ax2.text(x + 0.8, y, f"→ {output}", fontsize=8, va="center",
                 color="#2ecc71" if any(vals) else "#e74c3c", fontweight="bold")

    # Panel 3: Full Reduction Example
    ax3 = axes[1, 0]
    ax3.set_title("Reduction: (x₀∨x₁∨¬x₂) ∧ (¬x₀∨x₂∨x₂)", fontsize=12, fontweight="bold")
    ax3.set_xlim(-1, 10)
    ax3.set_ylim(-1, 4)
    ax3.set_aspect("equal")
    ax3.axis("off")

    # Assignment: x0=T, x1=T, x2=T
    ax3.text(0, 3.5, "Assignment: x₀=T, x₁=T, x₂=T", fontsize=11, fontweight="bold")

    # Variable pieces (selected)
    for i in range(3):
        draw_piece(ax3, i * 1.8, 2, "flat", "tab", "flat", "flat",
                   f"x{i}=T", "#d5f5e3", 0.8)

    # Clause 1: (x0=T ∨ x1=T ∨ ¬x2=F) → at least one T → TAB
    draw_piece(ax3, 6, 2, "tab", "tab", "blank", "tab",
               "C₁\nT∨T∨F", "#d5f5e3", 1.0)
    ax3.text(7, 2, "→ TAB ✓", fontsize=10, color="#2ecc71", fontweight="bold")

    # Clause 2: (¬x0=F ∨ x2=T ∨ x2=T) → at least one T → TAB
    draw_piece(ax3, 6, 0.3, "blank", "tab", "tab", "tab",
               "C₂\nF∨T∨T", "#d5f5e3", 1.0)
    ax3.text(7, 0.3, "→ TAB ✓", fontsize=10, color="#2ecc71", fontweight="bold")

    ax3.text(8.5, 1.15, "SAT ✓", fontsize=16, fontweight="bold", color="#2ecc71",
             bbox=dict(boxstyle="round", facecolor="#d5f5e3", edgecolor="#2ecc71"))

    # Panel 4: Configuration Space
    ax4 = axes[1, 1]
    ax4.set_title("Configuration Space Size (log₁₀)", fontsize=14, fontweight="bold")

    grid_sizes = [(n, m) for n in range(1, 8) for m in range(1, 8)]
    ns = [s[0] for s in grid_sizes]
    ms = [s[1] for s in grid_sizes]
    log_configs = [4 * n * m * np.log10(3) for n, m in grid_sizes]

    scatter = ax4.scatter(ns, ms, c=log_configs, cmap="YlOrRd", s=200,
                          edgecolors="black", linewidth=0.5)
    plt.colorbar(scatter, ax=ax4, label="log₁₀(configurations)")
    ax4.set_xlabel("Rows")
    ax4.set_ylabel("Columns")

    for n, m, lc in zip(ns, ms, log_configs):
        ax4.text(n, m, f"{lc:.0f}", ha="center", va="center", fontsize=7)

    plt.tight_layout()
    plt.savefig("puzzle_reduction_visualization.png", dpi=150, bbox_inches="tight")
    print("Saved puzzle_reduction_visualization.png")


if __name__ == "__main__":
    main()
