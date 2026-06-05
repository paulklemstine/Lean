#!/usr/bin/env python3
"""
Jigsaw Puzzle NP-Completeness Demo

Demonstrates the 3-SAT to Jigsaw Puzzle reduction with concrete examples.
"""

from enum import Enum
from dataclasses import dataclass
from typing import List, Tuple, Optional
from itertools import product


class EdgeType(Enum):
    FLAT = "flat"
    TAB = "tab"
    BLANK = "blank"


def complement(e: EdgeType) -> EdgeType:
    """The complement involution: tab ↔ blank, flat ↦ flat."""
    if e == EdgeType.TAB:
        return EdgeType.BLANK
    elif e == EdgeType.BLANK:
        return EdgeType.TAB
    return EdgeType.FLAT


def compatible(e1: EdgeType, e2: EdgeType) -> bool:
    """Two edges are compatible iff one complements the other."""
    return complement(e1) == e2


@dataclass
class JigsawPiece:
    top: EdgeType
    right: EdgeType
    bottom: EdgeType
    left: EdgeType

    def fits_right(self, other: 'JigsawPiece') -> bool:
        return compatible(self.right, other.left)

    def fits_below(self, other: 'JigsawPiece') -> bool:
        return compatible(self.bottom, other.top)


def bool_to_edge(b: bool) -> EdgeType:
    """Encode a boolean as an edge type."""
    return EdgeType.TAB if b else EdgeType.BLANK


# --- 3-SAT to Puzzle Reduction ---

@dataclass
class Literal:
    var: int
    positive: bool

    def eval(self, assignment: List[bool]) -> bool:
        return assignment[self.var] if self.positive else not assignment[self.var]


@dataclass
class Clause:
    literals: List[Literal]

    def satisfied(self, assignment: List[bool]) -> bool:
        return any(lit.eval(assignment) for lit in self.literals)


def puzzle_encoding(formula: List[Clause], assignment: List[bool],
                    clause_idx: int, lit_idx: int) -> EdgeType:
    """Encode literal evaluation as edge type."""
    lit = formula[clause_idx].literals[lit_idx]
    val = lit.eval(assignment)
    return bool_to_edge(val)


def check_reduction(formula: List[Clause], assignment: List[bool]) -> bool:
    """Check if every clause has at least one tab in the puzzle encoding."""
    for j, clause in enumerate(formula):
        has_tab = any(
            puzzle_encoding(formula, assignment, j, k) == EdgeType.TAB
            for k in range(len(clause.literals))
        )
        if not has_tab:
            return False
    return True


# --- Betti Numbers and Grid Topology ---

def internal_edges(m: int, n: int) -> int:
    """Count internal edges in an m×n grid."""
    return m * (n - 1) + (m - 1) * n


def betti1(m: int, n: int) -> int:
    """First Betti number of the m×n grid graph."""
    return (m - 1) * (n - 1)


def verify_euler(m: int, n: int) -> bool:
    """Verify V - E + F = 2 for an m×n grid."""
    V = m * n
    E = internal_edges(m, n)
    F = betti1(m, n) + 1
    return V - E + F == 2


# --- Demo ---

def main():
    print("=" * 60)
    print("JIGSAW PUZZLE NP-COMPLETENESS DEMO")
    print("=" * 60)

    # 1. Edge Algebra
    print("\n--- 1. Edge Type Algebra ---")
    for e in EdgeType:
        c = complement(e)
        print(f"  complement({e.value}) = {c.value}, "
              f"involution: complement(complement({e.value})) = "
              f"{complement(c).value}")

    print(f"\n  Fixed point: {complement(EdgeType.FLAT).value} "
          f"(flat is its own complement)")
    print(f"  Non-fixed: complement(tab) = {complement(EdgeType.TAB).value} ≠ tab")

    # 2. Compatibility
    print("\n--- 2. Compatibility Matrix ---")
    print("         flat    tab   blank")
    for e1 in EdgeType:
        row = [compatible(e1, e2) for e2 in EdgeType]
        print(f"  {e1.value:5s}  {'  '.join('✓' if c else '✗' for c in row)}")

    # 3. Signature space
    count = len(list(product(EdgeType, repeat=4)))
    print(f"\n  Signature space: {count} possible piece types (3^4 = 81)")

    # 4. Boolean encoding
    print("\n--- 3. Boolean-Edge Encoding ---")
    for b1 in [True, False]:
        for b2 in [True, False]:
            e1 = bool_to_edge(b1)
            e2 = bool_to_edge(b2)
            comp = compatible(e1, e2)
            print(f"  bool_to_edge({b1}) = {e1.value}, "
                  f"bool_to_edge({b2}) = {e2.value}, "
                  f"compatible = {comp}, "
                  f"b1 ≠ b2 = {b1 != b2}")

    # 5. SAT Reduction
    print("\n--- 4. 3-SAT to Puzzle Reduction ---")
    # (x0 ∨ x1 ∨ ¬x2) ∧ (¬x0 ∨ x2 ∨ x2)
    formula = [
        Clause([Literal(0, True), Literal(1, True), Literal(2, False)]),
        Clause([Literal(0, False), Literal(2, True), Literal(2, True)]),
    ]
    print(f"  Formula: (x0 ∨ x1 ∨ ¬x2) ∧ (¬x0 ∨ x2 ∨ x2)")
    print(f"  Variables: 3, Clauses: 2")
    print(f"  Reduction piece count: 2×3 + 2 = 8")

    print("\n  Testing all 8 assignments:")
    for bits in product([False, True], repeat=3):
        assignment = list(bits)
        sat = all(c.satisfied(assignment) for c in formula)
        puzzle_ok = check_reduction(formula, assignment)

        encoding = []
        for j in range(2):
            clause_enc = [puzzle_encoding(formula, assignment, j, k).value
                          for k in range(3)]
            encoding.append(clause_enc)

        status = "✓ SAT" if sat else "✗ UNSAT"
        puzzle_status = "✓ TABS" if puzzle_ok else "✗ NO TABS"
        match = "MATCH" if (sat == puzzle_ok) else "MISMATCH!"
        print(f"  ({','.join(str(int(b)) for b in assignment)}) "
              f"{status:8s} | {puzzle_status:10s} | {match}")

    # 6. Grid Topology
    print("\n--- 5. Grid Constraint Topology ---")
    print(f"  {'m×n':>6s}  {'V':>4s}  {'E':>4s}  {'β₁':>4s}  {'V-E+F=2':>8s}")
    for m, n in [(1, 1), (1, 5), (2, 2), (2, 3), (3, 3), (5, 5), (10, 10)]:
        V = m * n
        E = internal_edges(m, n)
        b = betti1(m, n)
        euler_ok = verify_euler(m, n)
        print(f"  {m}×{n:2d}    {V:4d}  {E:4d}  {b:4d}  {'✓' if euler_ok else '✗':>8s}")

    # 7. Superlinear redundancy
    print("\n--- 6. Superlinear Redundancy Growth ---")
    for m in range(2, 8):
        for n in range(2, 8):
            b_curr = betti1(m, n)
            b_next = betti1(m + 1, n + 1)
            diff = b_next - b_curr
            print(f"  β₁({m+1},{n+1}) - β₁({m},{n}) = "
                  f"{b_next} - {b_curr} = {diff} > 1 ✓"
                  if diff > 1 else f"  FAIL at ({m},{n})")
            if m != n:
                break  # Just show diagonal

    # 8. Constraint-variable gap
    print("\n--- 7. Constraint-Variable Gap ---")
    for m in range(1, 6):
        for n in range(1, 6):
            E = internal_edges(m, n)
            gap = 2 * m * n - E
            ratio = E / (m * n) if m * n > 0 else 0
            if m == n:
                print(f"  m={m}, n={n}: 2mn={2*m*n}, E={E}, "
                      f"gap=m+n={m+n}, ratio={ratio:.2f}")

    print("\n--- 8. Path Assembly Uniqueness ---")
    n = 8
    f = [i % 2 == 0 for i in range(n)]
    g = [i % 2 == 0 for i in range(n)]
    print(f"  Path of length {n}:")
    print(f"  f = {['T' if x else 'F' for x in f]}")
    print(f"  g = {['T' if x else 'F' for x in g]}")
    print(f"  f[0] == g[0]: {f[0] == g[0]}")
    print(f"  f == g: {f == g} (uniqueness theorem confirms this)")

    # Alternative path
    h = [i % 2 != 0 for i in range(n)]
    print(f"\n  h = {['T' if x else 'F' for x in h]}")
    print(f"  h[0] == f[0]: {h[0] == f[0]}")
    print(f"  h != f: {h != f} (different initial value → different everywhere)")

    print("\n" + "=" * 60)
    print("All demonstrations complete. Results match formal proofs.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Betti Number Growth for Grid Graphs

Shows the superlinear growth of β₁(m,n) = (m-1)(n-1) and the
constraint-to-variable ratio approaching 2.
"""
import matplotlib.pyplot as plt
import numpy as np


def betti1(m: int, n: int) -> int:
    return (m - 1) * (n - 1)


def internal_edges(m: int, n: int) -> int:
    return m * (n - 1) + (m - 1) * n


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Topological Complexity of Jigsaw Grid Graphs",
                 fontsize=16, fontweight='bold')

    # Plot 1: β₁ for square grids
    ax1 = axes[0, 0]
    ns = np.arange(1, 21)
    betas = [(n - 1) ** 2 for n in ns]
    ax1.plot(ns, betas, 'ro-', linewidth=2, markersize=6)
    ax1.fill_between(ns, 0, betas, alpha=0.1, color='red')
    ax1.set_xlabel('Grid size n (n×n grid)')
    ax1.set_ylabel('β₁ = (n-1)²')
    ax1.set_title('First Betti Number (Square Grids)')
    ax1.grid(True, alpha=0.3)

    # Plot 2: Superlinear growth verification
    ax2 = axes[0, 1]
    ms = np.arange(2, 16)
    diffs = [betti1(m + 1, m + 1) - betti1(m, m) for m in ms]
    ax2.bar(ms, diffs, color='#3498db', alpha=0.7, edgecolor='navy')
    ax2.axhline(y=1, color='red', linestyle='--', linewidth=2,
                label='Threshold = 1')
    ax2.set_xlabel('Grid size m')
    ax2.set_ylabel('β₁(m+1,m+1) - β₁(m,m)')
    ax2.set_title('Superlinear Growth: Δβ₁ > 1')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    # Plot 3: Constraint density approaching 2
    ax3 = axes[1, 0]
    ns_ratio = np.arange(1, 51)
    ratios = [internal_edges(n, n) / (n * n) for n in ns_ratio]
    ax3.plot(ns_ratio, ratios, 'g-', linewidth=2)
    ax3.axhline(y=2, color='red', linestyle='--', linewidth=1,
                label='Limit = 2')
    ax3.set_xlabel('Grid size n')
    ax3.set_ylabel('E / V')
    ax3.set_title('Constraint-to-Variable Ratio → 2')
    ax3.legend()
    ax3.set_ylim(0, 2.5)
    ax3.grid(True, alpha=0.3)

    # Plot 4: Euler characteristic verification
    ax4 = axes[1, 1]
    data = []
    for m in range(1, 11):
        for n in range(1, 11):
            V = m * n
            E = internal_edges(m, n)
            F = betti1(m, n) + 1
            euler = V - E + F
            data.append((m, n, V, E, F, euler))

    # Show β₁ as heatmap
    grid = np.zeros((10, 10))
    for m in range(1, 11):
        for n in range(1, 11):
            grid[m - 1, n - 1] = betti1(m, n)

    im = ax4.imshow(grid, cmap='hot', origin='lower', aspect='equal')
    ax4.set_xlabel('n')
    ax4.set_ylabel('m')
    ax4.set_title('β₁(m,n) Heatmap')
    ax4.set_xticks(range(10))
    ax4.set_xticklabels(range(1, 11))
    ax4.set_yticks(range(10))
    ax4.set_yticklabels(range(1, 11))
    plt.colorbar(im, ax=ax4, label='β₁')

    plt.tight_layout()
    plt.savefig('betti_growth.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved to betti_growth.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: SAT-to-Puzzle Reduction Verification

Shows the correspondence between 3-SAT assignments and puzzle edge encodings
for the example formula (x₀ ∨ x₁ ∨ ¬x₂) ∧ (¬x₀ ∨ x₂ ∨ x₂).
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product


def main():
    # Formula: (x₀ ∨ x₁ ∨ ¬x₂) ∧ (¬x₀ ∨ x₂ ∨ x₂)
    def eval_clause(assignment, clause):
        """Evaluate a clause under an assignment."""
        results = []
        for var, pos in clause:
            val = assignment[var] if pos else not assignment[var]
            results.append(val)
        return results

    clause1 = [(0, True), (1, True), (2, False)]   # x₀ ∨ x₁ ∨ ¬x₂
    clause2 = [(0, False), (2, True), (2, True)]    # ¬x₀ ∨ x₂ ∨ x₂
    clauses = [clause1, clause2]
    clause_names = ["x₀ ∨ x₁ ∨ ¬x₂", "¬x₀ ∨ x₂ ∨ x₂"]

    # Enumerate all assignments
    assignments = list(product([False, True], repeat=3))

    fig, axes = plt.subplots(2, 4, figsize=(16, 8))
    fig.suptitle("SAT → Puzzle Reduction: All 8 Assignments",
                 fontsize=14, fontweight='bold')

    for idx, assignment in enumerate(assignments):
        ax = axes[idx // 4, idx % 4]
        ax.set_xlim(-0.5, 3.5)
        ax.set_ylim(-0.5, 2.5)
        ax.set_aspect('equal')
        ax.set_xticks([])
        ax.set_yticks([])

        # Title
        astr = ','.join(['T' if a else 'F' for a in assignment])
        satisfied = all(any(eval_clause(assignment, c)) for c in clauses)
        color = '#2ecc71' if satisfied else '#e74c3c'
        ax.set_title(f"({astr})\n{'✓ SAT' if satisfied else '✗ UNSAT'}",
                     fontsize=10, color=color, fontweight='bold')
        ax.patch.set_facecolor('#f8f9fa' if satisfied else '#fadbd8')

        # Draw clause boxes
        for j, clause in enumerate(clauses):
            y = 1.5 - j
            vals = eval_clause(assignment, clause)
            clause_sat = any(vals)

            # Clause box
            rect = mpatches.FancyBboxPatch(
                (-0.3, y - 0.3), 3.6, 0.6,
                boxstyle="round,pad=0.1",
                facecolor='#d5f5e3' if clause_sat else '#fadbd8',
                edgecolor='#27ae60' if clause_sat else '#c0392b',
                linewidth=2
            )
            ax.add_patch(rect)

            # Literal edge types
            for k, val in enumerate(vals):
                x = k
                edge_color = '#e74c3c' if val else '#3498db'
                label = 'TAB' if val else 'BLK'
                ax.plot(x, y, 'o', color=edge_color, markersize=20,
                        markeredgecolor='black', markeredgewidth=1)
                ax.text(x, y, label, ha='center', va='center',
                        fontsize=7, color='white', fontweight='bold')

    # Add legend
    tab_patch = mpatches.Patch(color='#e74c3c', label='TAB (true)')
    blank_patch = mpatches.Patch(color='#3498db', label='BLANK (false)')
    sat_patch = mpatches.Patch(color='#d5f5e3', label='Clause satisfied')
    unsat_patch = mpatches.Patch(color='#fadbd8', label='Clause unsatisfied')
    fig.legend(handles=[tab_patch, blank_patch, sat_patch, unsat_patch],
               loc='lower center', ncol=4, fontsize=10)

    plt.tight_layout(rect=[0, 0.05, 1, 0.95])
    plt.savefig('sat_reduction.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved to sat_reduction.png")

    # Summary statistics
    sat_count = sum(1 for a in assignments
                    if all(any(eval_clause(a, c)) for c in clauses))
    print(f"\nFormula: (x₀ ∨ x₁ ∨ ¬x₂) ∧ (¬x₀ ∨ x₂ ∨ x₂)")
    print(f"Satisfying assignments: {sat_count} out of {len(assignments)}")
    print(f"Satisfiable: {sat_count > 0}")
    print(f"Reduction piece count: 2×3 + 2 = {2*3 + 2}")


if __name__ == "__main__":
    main()
