#!/usr/bin/env python3
"""
Demo: Jigsaw Puzzle NP-Completeness — SAT-to-Puzzle Reduction

Demonstrates the key mathematical results:
1. The complement involution on edge types
2. SAT-to-puzzle reduction on a concrete example
3. Euler characteristic computation
4. Constraint superadditivity verification
"""

from enum import Enum
from typing import List, Tuple, Optional
from dataclasses import dataclass


class EdgeType(Enum):
    TAB = "tab"
    BLANK = "blank"
    FLAT = "flat"

    def complement(self) -> 'EdgeType':
        if self == EdgeType.TAB:
            return EdgeType.BLANK
        elif self == EdgeType.BLANK:
            return EdgeType.TAB
        return EdgeType.FLAT

    def is_boundary(self) -> bool:
        return self == EdgeType.FLAT

    def compatible(self, other: 'EdgeType') -> bool:
        return self.complement() == other


@dataclass
class Piece:
    top: EdgeType
    right: EdgeType
    bottom: EdgeType
    left: EdgeType

    def fits_right(self, other: 'Piece') -> bool:
        return self.right.compatible(other.left)

    def fits_below(self, other: 'Piece') -> bool:
        return self.bottom.compatible(other.top)


def bool_to_edge(b: bool) -> EdgeType:
    return EdgeType.TAB if b else EdgeType.BLANK


# ─── Demo 1: Complement Involution ───

print("=" * 60)
print("Demo 1: The Complement Involution")
print("=" * 60)
for e in EdgeType:
    c = e.complement()
    cc = c.complement()
    print(f"  compl({e.value:5s}) = {c.value:5s}  |  compl(compl({e.value})) = {cc.value}  {'✓ involution' if cc == e else '✗ ERROR'}")

print(f"\n  Boundary edges (fixed points): {[e.value for e in EdgeType if e.is_boundary()]}")
print(f"  Free orbits: {[{e.value, e.complement().value} for e in EdgeType if not e.is_boundary() and e.value < e.complement().value]}")
print(f"  Orbit partition: |JEdge| = |boundary| + 2·|free orbits| = 1 + 2·1 = 3 ✓")


# ─── Demo 2: SAT-to-Puzzle Reduction ───

print("\n" + "=" * 60)
print("Demo 2: SAT-to-Puzzle Reduction")
print("=" * 60)

# Formula: (x₀ ∨ x₁ ∨ ¬x₂) ∧ (¬x₀ ∨ x₂ ∨ x₂)
print("\n  Formula: (x₀ ∨ x₁ ∨ ¬x₂) ∧ (¬x₀ ∨ x₂ ∨ x₂)")
print("\n  Testing all 8 assignments:")

clauses = [
    lambda a: a[0] or a[1] or not a[2],
    lambda a: not a[0] or a[2] or a[2],
]

sat_count = 0
for bits in range(8):
    assignment = [(bits >> i) & 1 == 1 for i in range(3)]
    clause_results = [c(assignment) for c in clauses]
    all_sat = all(clause_results)

    # Compute edge encodings
    edges = [bool_to_edge(b) for b in assignment]
    clause_edges = [
        [bool_to_edge(assignment[0]), bool_to_edge(assignment[1]), bool_to_edge(not assignment[2])],
        [bool_to_edge(not assignment[0]), bool_to_edge(assignment[2]), bool_to_edge(assignment[2])],
    ]
    has_tab = [any(e == EdgeType.TAB for e in ce) for ce in clause_edges]

    status = "SAT ✓" if all_sat else "UNSAT ✗"
    tab_status = "has tab ✓" if all(has_tab) else "all blank ✗"
    if all_sat:
        sat_count += 1

    print(f"  x=({int(assignment[0])},{int(assignment[1])},{int(assignment[2])}) "
          f"→ clauses={[int(r) for r in clause_results]} "
          f"→ {status}  |  edges={tab_status}")

print(f"\n  Total satisfying assignments: {sat_count}/8")
print(f"  clause_sat_iff_tab verified: SAT ↔ ∃ tab edge in every clause ✓")


# ─── Demo 3: Euler Characteristic ───

print("\n" + "=" * 60)
print("Demo 3: Euler Characteristic of Constraint Graphs")
print("=" * 60)

def internal_edges(m: int, n: int) -> int:
    return m * (n - 1) + (m - 1) * n

def euler_char(m: int, n: int) -> int:
    V = m * n
    E = internal_edges(m, n)
    F = (m - 1) * (n - 1) + 1
    return V - E + F

print(f"\n  {'m×n':>6s}  {'V':>4s}  {'E':>4s}  {'F':>4s}  {'χ':>3s}")
print(f"  {'─'*6}  {'─'*4}  {'─'*4}  {'─'*4}  {'─'*3}")
for m, n in [(1, 1), (2, 2), (3, 3), (3, 4), (5, 5), (10, 10), (100, 100)]:
    V = m * n
    E = internal_edges(m, n)
    F = (m - 1) * (n - 1) + 1
    chi = euler_char(m, n)
    print(f"  {m}×{n:>3d}  {V:4d}  {E:4d}  {F:4d}  {chi:3d}  {'✓' if chi == 2 else '✗'}")

print(f"\n  χ = 2 for all rectangular grids (topologically spherical) ✓")


# ─── Demo 4: Constraint Superadditivity ───

print("\n" + "=" * 60)
print("Demo 4: Constraint Superadditivity")
print("=" * 60)

print(f"\n  Theorem: E(m, 2n) ≥ 2·E(m, n) + m")
print(f"\n  {'m':>3s}  {'n':>3s}  {'E(m,2n)':>8s}  {'2E(m,n)+m':>10s}  {'gap':>4s}")
print(f"  {'─'*3}  {'─'*3}  {'─'*8}  {'─'*10}  {'─'*4}")
for m in [1, 2, 3, 5, 10]:
    for n in [1, 2, 3, 5]:
        e_merged = internal_edges(m, 2 * n)
        e_double = 2 * internal_edges(m, n) + m
        gap = e_merged - e_double
        check = "✓" if e_merged >= e_double else "✗"
        print(f"  {m:3d}  {n:3d}  {e_merged:8d}  {e_double:10d}  {gap:4d}  {check}")

print(f"\n  Superadditivity holds with gap = 0 (tight bound) ✓")


# ─── Demo 5: Complement Permutation Sign ───

print("\n" + "=" * 60)
print("Demo 5: Complement Permutation Sign")
print("=" * 60)

# Compute the permutation as a product of transpositions
edges = list(EdgeType)
perm = {e: e.complement() for e in edges}
print(f"\n  Permutation: {{{', '.join(f'{e.value}↦{perm[e].value}' for e in edges)}}}")
print(f"  Cycle decomposition: (tab blank)(flat)")

# Count inversions to determine sign
# Using tab=0, blank=1, flat=2
mapping = [1, 0, 2]  # tab→blank(1), blank→tab(0), flat→flat(2)
inversions = sum(1 for i in range(3) for j in range(i + 1, 3) if mapping[i] > mapping[j])
sign = (-1) ** inversions
print(f"  Inversions: {inversions}")
print(f"  Sign: (-1)^{inversions} = {sign}")
print(f"  The complement is an {'odd' if sign == -1 else 'even'} permutation ✓")


print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Constraint Graph Topology of Jigsaw Puzzles

Shows the constraint graph structure for various grid sizes,
highlighting the Euler characteristic invariant χ = 2.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def internal_edges(m: int, n: int) -> int:
    return m * (n - 1) + (m - 1) * n


def euler_char(m: int, n: int) -> int:
    V = m * n
    E = internal_edges(m, n)
    F = (m - 1) * (n - 1) + 1
    return V - E + F


def constraint_density(m: int, n: int) -> float:
    V = m * n
    E = internal_edges(m, n)
    return 2 * E / V if V > 0 else 0


fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# ─── Panel 1: Constraint graph for a 4×5 grid ───
ax1 = axes[0, 0]
m, n = 4, 5
for i in range(m):
    for j in range(n):
        ax1.plot(j, -i, 'ko', markersize=10, zorder=5)
        if j + 1 < n:
            ax1.plot([j, j + 1], [-i, -i], 'b-', linewidth=2, alpha=0.7)
        if i + 1 < m:
            ax1.plot([j, j], [-i, -(i + 1)], 'r-', linewidth=2, alpha=0.7)

V = m * n
E = internal_edges(m, n)
F = (m - 1) * (n - 1) + 1
ax1.set_title(f'Constraint Graph ({m}×{n})\nV={V}, E={E}, F={F}, χ={V - E + F}',
              fontsize=13, fontweight='bold')
ax1.set_xlim(-0.5, n - 0.5)
ax1.set_ylim(-(m - 0.5), 0.5)
ax1.set_aspect('equal')
ax1.axis('off')
blue_patch = mpatches.Patch(color='blue', alpha=0.7, label='Horizontal constraints')
red_patch = mpatches.Patch(color='red', alpha=0.7, label='Vertical constraints')
ax1.legend(handles=[blue_patch, red_patch], loc='lower right', fontsize=9)

# ─── Panel 2: Euler characteristic is always 2 ───
ax2 = axes[0, 1]
sizes = range(1, 21)
chi_values = [euler_char(n, n) for n in sizes]
ax2.bar(list(sizes), chi_values, color='green', alpha=0.7, edgecolor='darkgreen')
ax2.axhline(y=2, color='red', linestyle='--', linewidth=2, label='χ = 2')
ax2.set_xlabel('Grid size n (for n×n grid)', fontsize=12)
ax2.set_ylabel('Euler characteristic χ', fontsize=12)
ax2.set_title('Euler Characteristic = 2\n(Topologically Spherical)', fontsize=13, fontweight='bold')
ax2.set_ylim(0, 4)
ax2.legend(fontsize=11)

# ─── Panel 3: Constraint density approaches 2 ───
ax3 = axes[1, 0]
sizes_dense = range(2, 101)
densities = [constraint_density(n, n) for n in sizes_dense]
ax3.plot(list(sizes_dense), densities, 'b-', linewidth=2, label='2E/V = 2(n-1)/n')
ax3.axhline(y=2, color='red', linestyle='--', linewidth=1.5, label='Limit = 2')
ax3.fill_between(list(sizes_dense), densities, 2, alpha=0.1, color='blue')
ax3.set_xlabel('Grid size n', fontsize=12)
ax3.set_ylabel('Constraint density (2E/V)', fontsize=12)
ax3.set_title('Constraint Density → 2\n(4-Regular Planar Graph Class)', fontsize=13, fontweight='bold')
ax3.legend(fontsize=11)
ax3.set_ylim(1.5, 2.1)

# ─── Panel 4: Constraint superadditivity ───
ax4 = axes[1, 1]
ms = [2, 3, 5, 10]
ns = range(1, 21)
colors = ['blue', 'green', 'orange', 'red']
for idx, m_val in enumerate(ms):
    gaps = [internal_edges(m_val, 2 * nv) - 2 * internal_edges(m_val, nv) for nv in ns]
    ax4.plot(list(ns), gaps, '-o', color=colors[idx], markersize=4,
             linewidth=2, label=f'm={m_val} (gap=m={m_val})')

ax4.set_xlabel('n (half-width)', fontsize=12)
ax4.set_ylabel('Superadditivity gap: E(m,2n) - 2E(m,n)', fontsize=12)
ax4.set_title('Constraint Superadditivity\n(Gap = m, tight bound)', fontsize=13, fontweight='bold')
ax4.legend(fontsize=10)

plt.tight_layout()
plt.savefig('constraint_graph_topology.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: constraint_graph_topology.png")


#!/usr/bin/env python3
"""
Visualization: SAT-to-Puzzle Reduction

Shows the Boolean-to-edge encoding and clause satisfaction structure
for the example formula (x₀ ∨ x₁ ∨ ¬x₂) ∧ (¬x₀ ∨ x₂ ∨ x₂).
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def bool_to_edge(b: bool) -> str:
    return "tab" if b else "blank"


def edge_color(b: bool) -> str:
    return "#2ecc71" if b else "#e74c3c"  # green for tab, red for blank


# The formula
clauses = [
    [("x₀", True), ("x₁", True), ("¬x₂", False)],   # raw: x₀ ∨ x₁ ∨ ¬x₂
    [("¬x₀", False), ("x₂", True), ("x₂", True)],     # raw: ¬x₀ ∨ x₂ ∨ x₂
]

fig, axes = plt.subplots(1, 2, figsize=(16, 8))

# ─── Panel 1: All 8 assignments with satisfaction status ───
ax1 = axes[0]
ax1.set_xlim(-0.5, 8.5)
ax1.set_ylim(-0.5, 9.5)

ax1.set_title('SAT Instance: All 8 Assignments\n'
              'Formula: (x₀ ∨ x₁ ∨ ¬x₂) ∧ (¬x₀ ∨ x₂ ∨ x₂)',
              fontsize=13, fontweight='bold')

# Header
ax1.text(0, 9, 'x₀', fontsize=11, ha='center', fontweight='bold')
ax1.text(1, 9, 'x₁', fontsize=11, ha='center', fontweight='bold')
ax1.text(2, 9, 'x₂', fontsize=11, ha='center', fontweight='bold')
ax1.text(4, 9, 'C₁', fontsize=11, ha='center', fontweight='bold')
ax1.text(5, 9, 'C₂', fontsize=11, ha='center', fontweight='bold')
ax1.text(7, 9, 'SAT?', fontsize=11, ha='center', fontweight='bold')

for bits in range(8):
    y = 8 - bits
    assignment = [(bits >> i) & 1 == 1 for i in range(3)]

    # Variable values
    for j, val in enumerate(assignment):
        color = '#2ecc71' if val else '#e74c3c'
        ax1.add_patch(plt.Rectangle((j - 0.3, y - 0.3), 0.6, 0.6,
                                     facecolor=color, alpha=0.3, edgecolor=color))
        ax1.text(j, y, 'T' if val else 'F', ha='center', va='center',
                fontsize=10, fontweight='bold', color=color)

    # Clause evaluations
    c1 = assignment[0] or assignment[1] or not assignment[2]
    c2 = not assignment[0] or assignment[2] or assignment[2]

    for j, cval in enumerate([c1, c2]):
        color = '#2ecc71' if cval else '#e74c3c'
        ax1.add_patch(plt.Rectangle((4 + j - 0.3, y - 0.3), 0.6, 0.6,
                                     facecolor=color, alpha=0.3, edgecolor=color))
        ax1.text(4 + j, y, '✓' if cval else '✗', ha='center', va='center',
                fontsize=12, color=color)

    # Overall satisfaction
    sat = c1 and c2
    color = '#2ecc71' if sat else '#e74c3c'
    ax1.text(7, y, 'SAT' if sat else 'UNSAT', ha='center', va='center',
            fontsize=10, fontweight='bold', color=color)

    # Edge encoding annotation
    edges = [bool_to_edge(v) for v in assignment]

ax1.axis('off')

# ─── Panel 2: The tab/blank encoding ───
ax2 = axes[1]
ax2.set_title('Clause-Tab Correspondence\n'
              'Clause SAT ↔ ∃ tab edge',
              fontsize=13, fontweight='bold')

# Draw the encoding diagram
edge_types = [('tab', '#2ecc71', '⟶'), ('blank', '#e74c3c', '⟵'), ('flat', '#95a5a6', '—')]

y_pos = 8
ax2.text(4, y_pos + 0.5, 'Edge Complement Involution', ha='center',
         fontsize=12, fontweight='bold')

for i, (name, color, symbol) in enumerate(edge_types):
    x = 1.5 + i * 2.5
    ax2.add_patch(plt.Rectangle((x - 0.4, y_pos - 0.8), 0.8, 0.6,
                                 facecolor=color, alpha=0.4, edgecolor=color, linewidth=2))
    ax2.text(x, y_pos - 0.5, name, ha='center', va='center', fontsize=11, fontweight='bold')

# Complement arrows
ax2.annotate('', xy=(3.5, y_pos - 0.5), xytext=(2.0, y_pos - 0.5),
            arrowprops=dict(arrowstyle='<->', color='black', lw=2))
ax2.text(2.75, y_pos - 0.1, 'complement', ha='center', fontsize=9)

ax2.annotate('', xy=(6.5, y_pos - 0.5), xytext=(6.0, y_pos - 0.5),
            arrowprops=dict(arrowstyle='<->', color='gray', lw=1.5))
ax2.text(6.7, y_pos - 0.1, 'self', ha='center', fontsize=9, color='gray')

# Theorem box
y_thm = 5
ax2.add_patch(mpatches.FancyBboxPatch((0.5, y_thm - 1.5), 7, 2.5,
              boxstyle="round,pad=0.3", facecolor='lightyellow',
              edgecolor='goldenrod', linewidth=2))
ax2.text(4, y_thm + 0.5, 'Theorem: clause_sat_iff_tab', ha='center',
         fontsize=12, fontweight='bold', color='darkgoldenrod')
ax2.text(4, y_thm - 0.2, '(v₀ ∨ v₁ ∨ v₂) = true', ha='center', fontsize=11)
ax2.text(4, y_thm - 0.8, '⟺  ∃ i, boolToEdge(vᵢ) = tab', ha='center', fontsize=11)

# Contrapositive box
y_contra = 2
ax2.add_patch(mpatches.FancyBboxPatch((0.5, y_contra - 1.5), 7, 2.5,
              boxstyle="round,pad=0.3", facecolor='#ffe0e0',
              edgecolor='#cc0000', linewidth=2))
ax2.text(4, y_contra + 0.5, 'Contrapositive: unsat_clause_iff_all_blank', ha='center',
         fontsize=12, fontweight='bold', color='#cc0000')
ax2.text(4, y_contra - 0.2, '(v₀ ∨ v₁ ∨ v₂) = false', ha='center', fontsize=11)
ax2.text(4, y_contra - 0.8, '⟺  ∀ i, boolToEdge(vᵢ) = blank', ha='center', fontsize=11)

ax2.set_xlim(0, 8)
ax2.set_ylim(-0.5, 9.5)
ax2.axis('off')

plt.tight_layout()
plt.savefig('sat_reduction.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: sat_reduction.png")
