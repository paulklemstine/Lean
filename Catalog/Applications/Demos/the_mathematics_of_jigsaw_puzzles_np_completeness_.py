"""
Jigsaw Puzzle NP-Completeness: Interactive Demo

Demonstrates the 3-SAT to Jigsaw Puzzle reduction with concrete examples.
"""

from enum import Enum
from typing import List, Tuple, Optional
from dataclasses import dataclass
import random


class EdgeType(Enum):
    TAB = "tab"
    BLANK = "blank"
    FLAT = "flat"

    def complement(self):
        if self == EdgeType.TAB:
            return EdgeType.BLANK
        elif self == EdgeType.BLANK:
            return EdgeType.TAB
        return EdgeType.FLAT

    def is_complementary(self, other):
        return (self == EdgeType.TAB and other == EdgeType.BLANK) or \
               (self == EdgeType.BLANK and other == EdgeType.TAB)


@dataclass
class JigsawPiece:
    top: EdgeType
    right: EdgeType
    bottom: EdgeType
    left: EdgeType
    label: str = ""

    def fits_horizontal(self, other):
        return self.right.is_complementary(other.left)

    def fits_vertical(self, other):
        return self.bottom.is_complementary(other.top)

    def dual(self):
        return JigsawPiece(
            self.top.complement(),
            self.right.complement(),
            self.bottom.complement(),
            self.left.complement(),
            f"dual({self.label})"
        )


@dataclass
class Literal:
    var: int
    polarity: bool

    def eval(self, assignment: List[bool]) -> bool:
        v = assignment[self.var]
        return v if self.polarity else not v

    def __repr__(self):
        return f"x{self.var+1}" if self.polarity else f"¬x{self.var+1}"


@dataclass
class Clause:
    literals: List[Literal]

    def sat(self, assignment: List[bool]) -> bool:
        return any(l.eval(assignment) for l in self.literals)

    def __repr__(self):
        return f"({' ∨ '.join(str(l) for l in self.literals)})"


def bool_to_edge(b: bool) -> EdgeType:
    return EdgeType.TAB if b else EdgeType.BLANK


def clause_output(clause: Clause, assignment: List[bool]) -> EdgeType:
    return EdgeType.TAB if clause.sat(assignment) else EdgeType.BLANK


def demonstrate_reduction():
    """Demonstrate the 3-SAT to Jigsaw Puzzle reduction."""

    print("=" * 60)
    print("3-SAT TO JIGSAW PUZZLE REDUCTION")
    print("=" * 60)

    # Example formula: (x₁ ∨ x₂ ∨ ¬x₃) ∧ (¬x₁ ∨ x₃ ∨ x₃)
    clauses = [
        Clause([Literal(0, True), Literal(1, True), Literal(2, False)]),
        Clause([Literal(0, False), Literal(2, True), Literal(2, True)]),
    ]
    num_vars = 3
    formula_str = " ∧ ".join(str(c) for c in clauses)
    print(f"\nFormula φ = {formula_str}")
    print(f"Variables: {num_vars}, Clauses: {len(clauses)}")

    # Test all assignments
    print(f"\n{'Assignment':<20} {'Clause 1':<15} {'Clause 2':<15} {'Satisfies?':<10}")
    print("-" * 60)

    satisfying_assignments = []
    for bits in range(2**num_vars):
        assignment = [(bits >> i) & 1 == 1 for i in range(num_vars)]
        vals = [f"x{i+1}={'T' if a else 'F'}" for i, a in enumerate(assignment)]
        c1_sat = clauses[0].sat(assignment)
        c2_sat = clauses[1].sat(assignment)
        all_sat = c1_sat and c2_sat

        if all_sat:
            satisfying_assignments.append(assignment)

        print(f"  {', '.join(vals):<18} {'✓' if c1_sat else '✗':<15} "
              f"{'✓' if c2_sat else '✗':<15} {'YES' if all_sat else 'no':<10}")

    print(f"\nSatisfying assignments: {len(satisfying_assignments)}")

    # Demonstrate the reduction for one satisfying assignment
    if satisfying_assignments:
        a = satisfying_assignments[0]
        print(f"\n{'=' * 60}")
        print(f"PUZZLE CONSTRUCTION for assignment "
              f"x₁={'T' if a[0] else 'F'}, x₂={'T' if a[1] else 'F'}, x₃={'T' if a[2] else 'F'}")
        print(f"{'=' * 60}")

        # Variable gadgets
        print("\nVariable Gadgets:")
        for i in range(num_vars):
            edge = bool_to_edge(a[i])
            comp = bool_to_edge(not a[i])
            print(f"  x{i+1}: TRUE piece  → assignment edge = {edge.value}")
            print(f"  x{i+1}: FALSE piece → assignment edge = {comp.value}")
            print(f"       Complementary? {edge.is_complementary(comp)} ✓")

        # Clause gadgets
        print("\nClause Gadgets:")
        for j, clause in enumerate(clauses):
            output = clause_output(clause, a)
            lit_vals = [l.eval(a) for l in clause.literals]
            print(f"  C{j+1} = {clause}")
            print(f"    Literal values: {[bool_to_edge(v).value for v in lit_vals]}")
            print(f"    Output edge: {output.value} ({'satisfied' if output == EdgeType.TAB else 'unsatisfied'})")

    # Complement duality demonstration
    print(f"\n{'=' * 60}")
    print("COMPLEMENT DUALITY THEOREM")
    print("=" * 60)
    p = JigsawPiece(EdgeType.FLAT, EdgeType.TAB, EdgeType.BLANK, EdgeType.FLAT, "P")
    q = JigsawPiece(EdgeType.FLAT, EdgeType.FLAT, EdgeType.FLAT, EdgeType.BLANK, "Q")

    print(f"\nPiece P: top={p.top.value}, right={p.right.value}, "
          f"bottom={p.bottom.value}, left={p.left.value}")
    print(f"Piece Q: top={q.top.value}, right={q.right.value}, "
          f"bottom={q.bottom.value}, left={q.left.value}")
    print(f"P fits horizontally to Q? {p.fits_horizontal(q)}")

    pd, qd = p.dual(), q.dual()
    print(f"\nDual P: top={pd.top.value}, right={pd.right.value}, "
          f"bottom={pd.bottom.value}, left={pd.left.value}")
    print(f"Dual Q: top={qd.top.value}, right={qd.right.value}, "
          f"bottom={qd.bottom.value}, left={qd.left.value}")
    print(f"Dual P fits horizontally to Dual Q? {pd.fits_horizontal(qd)}")
    print(f"Duality preserved: {p.fits_horizontal(q) == pd.fits_horizontal(qd)} ✓")

    # Counting
    print(f"\n{'=' * 60}")
    print("COMPATIBLE PAIR COUNTING")
    print("=" * 60)
    count = 0
    total = 0
    edge_types = [EdgeType.TAB, EdgeType.BLANK, EdgeType.FLAT]
    for t1 in edge_types:
        for r1 in edge_types:
            for b1 in edge_types:
                for l1 in edge_types:
                    for t2 in edge_types:
                        for r2 in edge_types:
                            for b2 in edge_types:
                                for l2 in edge_types:
                                    total += 1
                                    p = JigsawPiece(t1, r1, b1, l1)
                                    q = JigsawPiece(t2, r2, b2, l2)
                                    if p.fits_horizontal(q):
                                        count += 1
    print(f"Total ordered pairs: {total} (= 81²)")
    print(f"Horizontally compatible pairs: {count}")
    print(f"Fraction: {count}/{total} = {count/total:.4f}")
    print(f"Expected: 2 × 3⁶ / 3⁸ = 1458/6561 = {1458/6561:.4f}")


if __name__ == "__main__":
    demonstrate_reduction()


"""
Visualization: Jigsaw Puzzle Compatibility Structure

Generates a heatmap showing which piece pairs are horizontally compatible,
revealing the block structure of the compatibility relation.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def edge_types():
    return ['tab', 'blank', 'flat']


def is_complementary(e1, e2):
    return (e1 == 'tab' and e2 == 'blank') or (e1 == 'blank' and e2 == 'tab')


def all_pieces():
    pieces = []
    for t in edge_types():
        for r in edge_types():
            for b in edge_types():
                for l in edge_types():
                    pieces.append((t, r, b, l))
    return pieces


def build_compatibility_matrix():
    pieces = all_pieces()
    n = len(pieces)
    matrix = np.zeros((n, n), dtype=int)
    for i, p in enumerate(pieces):
        for j, q in enumerate(pieces):
            if is_complementary(p[1], q[3]):  # p.right vs q.left
                matrix[i][j] = 1
    return matrix, pieces


def main():
    matrix, pieces = build_compatibility_matrix()
    n = len(pieces)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Heatmap of compatibility
    ax1 = axes[0]
    im = ax1.imshow(matrix, cmap='YlOrRd', aspect='auto', interpolation='nearest')
    ax1.set_title(f'Horizontal Compatibility Matrix\n({n}×{n} = {n*n} pairs, '
                  f'{matrix.sum()} compatible)', fontsize=12)
    ax1.set_xlabel('Piece Q index')
    ax1.set_ylabel('Piece P index')
    plt.colorbar(im, ax=ax1, label='Compatible')

    # Distribution of compatibility degree
    ax2 = axes[1]
    out_degrees = matrix.sum(axis=1)
    in_degrees = matrix.sum(axis=0)
    ax2.hist(out_degrees, bins=range(0, max(out_degrees)+2), alpha=0.7,
             label='Out-degree (# pieces P fits left of)', color='steelblue')
    ax2.hist(in_degrees, bins=range(0, max(in_degrees)+2), alpha=0.7,
             label='In-degree (# pieces that fit left of P)', color='coral')
    ax2.set_xlabel('Compatibility degree')
    ax2.set_ylabel('Number of pieces')
    ax2.set_title('Distribution of Compatibility Degrees')
    ax2.legend()

    plt.tight_layout()
    plt.savefig('puzzle_compatibility.png', dpi=150, bbox_inches='tight')
    print(f"Saved puzzle_compatibility.png")
    print(f"Total pieces: {n}")
    print(f"Compatible pairs: {matrix.sum()}")
    print(f"Compatibility fraction: {matrix.sum()}/{n*n} = {matrix.sum()/(n*n):.4f}")

    # Edge type statistics
    print(f"\nDegree statistics:")
    print(f"  Mean out-degree: {out_degrees.mean():.1f}")
    print(f"  Min out-degree: {out_degrees.min()}")
    print(f"  Max out-degree: {out_degrees.max()}")


if __name__ == "__main__":
    main()


"""
Visualization: 3-SAT to Jigsaw Puzzle Reduction

Shows the reduction from a specific 3-SAT formula to puzzle pieces,
illustrating how variable gadgets enforce mutual exclusion and
clause gadgets enforce OR semantics.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def draw_piece(ax, x, y, edges, label="", color='lightblue', size=1.0):
    """Draw a jigsaw piece at position (x,y) with given edge types."""
    edge_colors = {'tab': 'green', 'blank': 'red', 'flat': 'gray'}

    rect = patches.FancyBboxPatch((x, y), size, size,
                                   boxstyle="round,pad=0.05",
                                   facecolor=color, edgecolor='black', linewidth=1.5)
    ax.add_patch(rect)

    # Draw edge indicators
    positions = {
        'top': (x + size/2, y + size + 0.1),
        'right': (x + size + 0.1, y + size/2),
        'bottom': (x + size/2, y - 0.1),
        'left': (x - 0.1, y + size/2)
    }
    edge_names = ['top', 'right', 'bottom', 'left']
    for name, edge in zip(edge_names, edges):
        px, py = positions[name]
        if edge == 'tab':
            marker = '▲' if name == 'top' else ('►' if name == 'right' else
                     ('▼' if name == 'bottom' else '◄'))
            ax.text(px, py, marker, ha='center', va='center', fontsize=10,
                    color='green', fontweight='bold')
        elif edge == 'blank':
            ax.text(px, py, '○', ha='center', va='center', fontsize=12,
                    color='red')

    if label:
        ax.text(x + size/2, y + size/2, label, ha='center', va='center',
                fontsize=8, fontweight='bold')


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    # ── Panel 1: Variable Gadgets ──
    ax1 = axes[0]
    ax1.set_xlim(-1, 7)
    ax1.set_ylim(-1, 10)
    ax1.set_aspect('equal')
    ax1.set_title('Variable Gadgets\n(Complementary edges enforce mutual exclusion)',
                   fontsize=12, fontweight='bold')
    ax1.axis('off')

    variables = ['x₁', 'x₂', 'x₃']
    for i, var in enumerate(variables):
        y_base = 7 - 3 * i

        # TRUE piece
        draw_piece(ax1, 1, y_base, ['flat', 'tab', 'flat', 'flat'],
                   f'{var}=T', color='#90EE90')
        # FALSE piece
        draw_piece(ax1, 4, y_base, ['flat', 'blank', 'flat', 'flat'],
                   f'{var}=F', color='#FFB6C1')

        # Arrow showing complementarity
        ax1.annotate('', xy=(3.8, y_base + 0.5), xytext=(2.2, y_base + 0.5),
                     arrowprops=dict(arrowstyle='<->', color='purple', lw=2))
        ax1.text(3, y_base + 0.8, 'complementary', ha='center', fontsize=7,
                 color='purple')

    # ── Panel 2: Clause Gadgets ──
    ax2 = axes[1]
    ax2.set_xlim(-1, 9)
    ax2.set_ylim(-1, 10)
    ax2.set_aspect('equal')
    ax2.set_title('Clause Gadgets\n(Output = TAB iff at least one input is TAB)',
                   fontsize=12, fontweight='bold')
    ax2.axis('off')

    # Clause 1: (x₁ ∨ x₂ ∨ ¬x₃) with assignment x₁=T, x₂=T, x₃=T
    y = 6
    ax2.text(4, y + 2.5, 'C₁ = (x₁ ∨ x₂ ∨ ¬x₃)', ha='center', fontsize=11,
             fontweight='bold')

    # Input edges
    inputs = [('x₁=T', 'tab', '#90EE90'), ('x₂=T', 'tab', '#90EE90'),
              ('¬x₃=F', 'blank', '#FFB6C1')]
    for j, (lbl, edge, clr) in enumerate(inputs):
        draw_piece(ax2, 1 + 2.5*j, y, ['flat', edge, 'flat', 'flat'],
                   lbl, color=clr, size=0.8)

    # Output
    ax2.text(4, y - 0.5, '→ Output: TAB (satisfied ✓)', ha='center',
             fontsize=10, color='green', fontweight='bold')

    # Clause 2: (¬x₁ ∨ x₃ ∨ x₃)
    y = 2
    ax2.text(4, y + 2.5, 'C₂ = (¬x₁ ∨ x₃ ∨ x₃)', ha='center', fontsize=11,
             fontweight='bold')

    inputs2 = [('¬x₁=F', 'blank', '#FFB6C1'), ('x₃=T', 'tab', '#90EE90'),
               ('x₃=T', 'tab', '#90EE90')]
    for j, (lbl, edge, clr) in enumerate(inputs2):
        draw_piece(ax2, 1 + 2.5*j, y, ['flat', edge, 'flat', 'flat'],
                   lbl, color=clr, size=0.8)

    ax2.text(4, y - 0.5, '→ Output: TAB (satisfied ✓)', ha='center',
             fontsize=10, color='green', fontweight='bold')

    plt.suptitle('3-SAT → Jigsaw Puzzle Reduction\n'
                 'Assignment: x₁=T, x₂=T, x₃=T',
                 fontsize=14, fontweight='bold', y=0.98)
    plt.tight_layout()
    plt.savefig('sat_reduction.png', dpi=150, bbox_inches='tight')
    print("Saved sat_reduction.png")


if __name__ == "__main__":
    main()
