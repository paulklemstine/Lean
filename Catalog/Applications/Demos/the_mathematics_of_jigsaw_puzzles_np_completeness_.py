#!/usr/bin/env python3
"""
demo.py — Jigsaw Puzzle NP-Completeness: Numerical Examples

Demonstrates the key results:
1. Edge complementarity and the involution structure
2. SAT-to-puzzle reduction on a concrete example
3. Betti number computation for grid constraint graphs
4. Constraint density analysis
"""

from typing import List, Tuple, Dict, Optional
from enum import Enum


class EdgeType(Enum):
    TAB = "tab"
    BLANK = "blank"
    FLAT = "flat"


def complement(e: EdgeType) -> EdgeType:
    """Complement involution: tab ↔ blank, flat ↔ flat."""
    if e == EdgeType.TAB:
        return EdgeType.BLANK
    elif e == EdgeType.BLANK:
        return EdgeType.TAB
    else:
        return EdgeType.FLAT


def complement_iterate(e: EdgeType, n: int) -> EdgeType:
    """Apply complement n times."""
    result = e
    for _ in range(n):
        result = complement(result)
    return result


# ============================================================
# Demo 1: Complement Involution
# ============================================================
print("=" * 60)
print("Demo 1: Complement Involution")
print("=" * 60)

for e in EdgeType:
    c = complement(e)
    cc = complement(c)
    print(f"  compl({e.value}) = {c.value}, compl(compl({e.value})) = {cc.value}")
    assert cc == e, "Involution property failed!"

print("\nVerifying compl^4 = id (grid cycle consistency):")
for e in EdgeType:
    result = complement_iterate(e, 4)
    print(f"  compl^4({e.value}) = {result.value}")
    assert result == e

print("\nFixed points: ", [e.value for e in EdgeType if complement(e) == e])
print("Free orbits: ", [(e.value, complement(e).value) for e in EdgeType if complement(e) != e and e.value < complement(e).value])


# ============================================================
# Demo 2: Boolean-Edge Encoding
# ============================================================
print("\n" + "=" * 60)
print("Demo 2: Boolean-Edge Encoding")
print("=" * 60)

def bool_to_edge(b: bool) -> EdgeType:
    return EdgeType.TAB if b else EdgeType.BLANK

print("Encoding: True → tab, False → blank")
print(f"  bool_to_edge(True) = {bool_to_edge(True).value}")
print(f"  bool_to_edge(False) = {bool_to_edge(False).value}")

print("\nHomomorphism: compl(encode(b)) = encode(¬b)")
for b in [True, False]:
    lhs = complement(bool_to_edge(b))
    rhs = bool_to_edge(not b)
    print(f"  compl(encode({b})) = {lhs.value} = encode({not b}) = {rhs.value} ✓")
    assert lhs == rhs

print("\nComplementarity ↔ Inequality:")
for b1 in [True, False]:
    for b2 in [True, False]:
        e1, e2 = bool_to_edge(b1), bool_to_edge(b2)
        compl_match = complement(e1) == e2
        different = b1 != b2
        status = "✓" if compl_match == different else "✗"
        print(f"  b1={b1}, b2={b2}: compl(e1)=e2? {compl_match}, b1≠b2? {different} {status}")


# ============================================================
# Demo 3: SAT-to-Puzzle Reduction
# ============================================================
print("\n" + "=" * 60)
print("Demo 3: SAT-to-Puzzle Reduction")
print("=" * 60)

# Formula: (x₀ ∨ x₁ ∨ ¬x₂) ∧ (¬x₀ ∨ x₂ ∨ x₂)
clauses = [
    [(0, True), (1, True), (2, False)],   # x₀ ∨ x₁ ∨ ¬x₂
    [(0, False), (2, True), (2, True)],   # ¬x₀ ∨ x₂ ∨ x₂
]

def evaluate_literal(assignment: List[bool], var: int, polarity: bool) -> bool:
    return assignment[var] if polarity else not assignment[var]

def is_satisfied(assignment: List[bool], clauses: List[List[Tuple[int, bool]]]) -> bool:
    return all(
        any(evaluate_literal(assignment, var, pol) for var, pol in clause)
        for clause in clauses
    )

def literal_edge(assignment: List[bool], var: int, polarity: bool) -> EdgeType:
    return bool_to_edge(evaluate_literal(assignment, var, polarity))

print("Formula: (x₀ ∨ x₁ ∨ ¬x₂) ∧ (¬x₀ ∨ x₂ ∨ x₂)")
print("\nAll assignments (3 variables = 8 possibilities):")

sat_count = 0
for bits in range(8):
    assignment = [(bits >> i) & 1 == 1 for i in range(3)]
    sat = is_satisfied(assignment, clauses)
    if sat:
        sat_count += 1

    edges = []
    for clause in clauses:
        clause_edges = [literal_edge(assignment, v, p).value for v, p in clause]
        has_tab = any(e == "tab" for e in clause_edges)
        edges.append((clause_edges, has_tab))

    status = "SAT ✓" if sat else "UNSAT ✗"
    print(f"  x₀={assignment[0]}, x₁={assignment[1]}, x₂={assignment[2]}: {status}")
    for i, (ce, ht) in enumerate(edges):
        tab_mark = "✓ (has tab)" if ht else "✗ (no tab)"
        print(f"    Clause {i}: edges = {ce} → {tab_mark}")

print(f"\nTotal satisfying assignments: {sat_count}/8")


# ============================================================
# Demo 4: Betti Numbers and Constraint Density
# ============================================================
print("\n" + "=" * 60)
print("Demo 4: Betti Numbers and Constraint Density")
print("=" * 60)

def grid_internal_edges(m: int, n: int) -> int:
    return m * (n - 1) + (m - 1) * n

def grid_betti1(m: int, n: int) -> int:
    return (m - 1) * (n - 1)

print("Grid (m×n) | Cells | Edges | β₁   | Density")
print("-" * 50)
for m, n in [(1, 5), (2, 3), (3, 3), (5, 5), (10, 10), (20, 20)]:
    cells = m * n
    edges = grid_internal_edges(m, n)
    betti = grid_betti1(m, n)
    density = edges / cells if cells > 0 else 0
    print(f"  {m:2d}×{n:2d}    | {cells:4d}  | {edges:4d}  | {betti:4d} | {density:.3f}")
    # Verify Euler-Poincaré
    assert edges + 1 == cells + betti, "Euler-Poincaré failed!"

print("\nEuler-Poincaré verified: E + 1 = V + β₁ for all grids ✓")

print("\nConstraint density 2 - 2/n for n×n grids:")
for n in [2, 5, 10, 20, 50, 100]:
    density = grid_internal_edges(n, n) / (n * n)
    theoretical = 2 - 2/n
    print(f"  n={n:3d}: actual={density:.4f}, 2-2/n={theoretical:.4f}, gap={2*n}")


# ============================================================
# Demo 5: Orbit-Stabilizer Verification
# ============================================================
print("\n" + "=" * 60)
print("Demo 5: Involution Orbit-Stabilizer")
print("=" * 60)

fixed = [e for e in EdgeType if complement(e) == e]
free = [e for e in EdgeType if complement(e) != e]
print(f"  |EdgeType| = {len(EdgeType.__members__)}")
print(f"  Fixed points: {[e.value for e in fixed]} (count = {len(fixed)})")
print(f"  Free elements: {[e.value for e in free]} (count = {len(free)})")
print(f"  Parity check: {len(EdgeType.__members__)} mod 2 = {len(EdgeType.__members__) % 2}")
print(f"  |Fix| mod 2 = {len(fixed) % 2}")
assert len(EdgeType.__members__) % 2 == len(fixed) % 2, "Parity theorem failed!"
print("  Involution parity theorem verified ✓")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
visualize_betti.py — Visualize Betti numbers and constraint density for grid puzzles.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def grid_betti1(m: int, n: int) -> int:
    return (m - 1) * (n - 1)


def grid_internal_edges(m: int, n: int) -> int:
    return m * (n - 1) + (m - 1) * n


def constraint_density(m: int, n: int) -> float:
    v = m * n
    return grid_internal_edges(m, n) / v if v > 0 else 0.0


# Figure 1: Betti number heatmap
fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Heatmap
sizes = range(1, 21)
betti_matrix = np.array([[grid_betti1(m, n) for n in sizes] for m in sizes])
im = axes[0].imshow(betti_matrix, cmap='YlOrRd', origin='lower', extent=[0.5, 20.5, 0.5, 20.5])
axes[0].set_xlabel('n (columns)')
axes[0].set_ylabel('m (rows)')
axes[0].set_title('β₁ = (m-1)(n-1): Obstruction Dimension')
plt.colorbar(im, ax=axes[0], label='β₁')

# Square grid growth
ns = np.arange(1, 51)
bettis = [(n-1)**2 for n in ns]
axes[1].plot(ns, bettis, 'b-', linewidth=2)
axes[1].fill_between(ns, 0, bettis, alpha=0.2)
axes[1].set_xlabel('Grid size n')
axes[1].set_ylabel('β₁ = (n-1)²')
axes[1].set_title('Quadratic Growth of β₁ for n×n Grids')
axes[1].grid(True, alpha=0.3)

# Constraint density approaching 2
ns_density = np.arange(2, 101)
densities = [constraint_density(n, n) for n in ns_density]
axes[2].plot(ns_density, densities, 'r-', linewidth=2, label='E(n,n) / n²')
axes[2].axhline(y=2, color='gray', linestyle='--', alpha=0.5, label='Limit = 2')
axes[2].set_xlabel('Grid size n')
axes[2].set_ylabel('Constraint density')
axes[2].set_title('Constraint Density → 2 as n → ∞')
axes[2].legend()
axes[2].grid(True, alpha=0.3)
axes[2].set_ylim(0.8, 2.1)

plt.tight_layout()
plt.savefig('betti_analysis.png', dpi=150, bbox_inches='tight')
print("Saved betti_analysis.png")


#!/usr/bin/env python3
"""
visualize_reduction.py — Visualize the SAT-to-puzzle reduction.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def bool_to_edge(b: bool) -> str:
    return "tab" if b else "blank"


def evaluate_literal(assignment: list, var: int, pol: bool) -> bool:
    return assignment[var] if pol else not assignment[var]


# Formula: (x₀ ∨ x₁ ∨ ¬x₂) ∧ (¬x₀ ∨ x₂ ∨ x₂)
clauses = [
    [(0, True), (1, True), (2, False)],
    [(0, False), (2, True), (2, True)],
]

clause_labels = ["x₀ ∨ x₁ ∨ ¬x₂", "¬x₀ ∨ x₂ ∨ x₂"]

fig, axes = plt.subplots(2, 4, figsize=(20, 10))

assignments = [
    [True, True, True],
    [False, True, True],
    [True, False, True],
    [False, False, True],
    [True, True, False],
    [False, True, False],
    [True, False, False],
    [False, False, False],
]

for idx, assignment in enumerate(assignments):
    row = idx // 4
    col = idx % 4
    ax = axes[row][col]

    # Check satisfaction
    sat = all(
        any(evaluate_literal(assignment, v, p) for v, p in clause)
        for clause in clauses
    )

    # Draw assignment
    ax.set_xlim(-0.5, 3.5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')

    # Variable values
    for i, val in enumerate(assignment):
        color = '#2ecc71' if val else '#e74c3c'
        edge = bool_to_edge(val)
        ax.add_patch(plt.Rectangle((i, 2.5), 0.8, 0.6, facecolor=color, edgecolor='black', linewidth=1.5))
        ax.text(i + 0.4, 2.8, f'x{i}={val}', ha='center', va='center', fontsize=7, fontweight='bold')
        ax.text(i + 0.4, 2.55, edge, ha='center', va='center', fontsize=6, style='italic')

    # Clause evaluation
    for ci, clause in enumerate(clauses):
        y_pos = 1.2 - ci * 1.2
        clause_sat = any(evaluate_literal(assignment, v, p) for v, p in clause)
        bg_color = '#d5f5e3' if clause_sat else '#fadbd8'
        ax.add_patch(plt.Rectangle((-0.3, y_pos - 0.1), 3.6, 0.9, facecolor=bg_color,
                                   edgecolor='black', linewidth=1, linestyle='--'))
        ax.text(1.5, y_pos + 0.65, clause_labels[ci], ha='center', va='center', fontsize=7)

        for li, (v, p) in enumerate(clause):
            lit_val = evaluate_literal(assignment, v, p)
            edge = bool_to_edge(lit_val)
            color = '#27ae60' if edge == 'tab' else '#c0392b'
            ax.add_patch(plt.Rectangle((li * 1.1, y_pos), 0.8, 0.5, facecolor=color,
                                       edgecolor='black', linewidth=1, alpha=0.7))
            ax.text(li * 1.1 + 0.4, y_pos + 0.25, edge, ha='center', va='center',
                    fontsize=6, color='white', fontweight='bold')

    title_color = 'green' if sat else 'red'
    title_text = 'SAT ✓' if sat else 'UNSAT ✗'
    ax.set_title(f'{title_text}', color=title_color, fontsize=10, fontweight='bold')
    ax.axis('off')

fig.suptitle('SAT-to-Puzzle Reduction: All 8 Assignments\n'
             'Formula: (x₀ ∨ x₁ ∨ ¬x₂) ∧ (¬x₀ ∨ x₂ ∨ x₂)\n'
             'Green = tab (satisfied), Red = blank (unsatisfied)',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('sat_reduction.png', dpi=150, bbox_inches='tight')
print("Saved sat_reduction.png")
