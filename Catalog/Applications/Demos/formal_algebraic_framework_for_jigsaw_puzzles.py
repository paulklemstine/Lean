#!/usr/bin/env python3
"""
Jigsaw Puzzle Algebra — Demonstration Script

Demonstrates the key mathematical concepts from the formal framework:
1. Edge complementarity and the involution structure
2. Boolean-to-edge encoding
3. SAT-to-puzzle reduction
4. Grid constraint counting and Euler characteristic
5. Random assembly defect statistics
"""

from enum import Enum
import random
from typing import List, Tuple, Optional


class EdgeType(Enum):
    TAB = "tab"
    BLANK = "blank"
    FLAT = "flat"


def complement(e: EdgeType) -> EdgeType:
    """The complement involution: tab ↔ blank, flat ↔ flat."""
    if e == EdgeType.TAB:
        return EdgeType.BLANK
    elif e == EdgeType.BLANK:
        return EdgeType.TAB
    return EdgeType.FLAT


def is_compatible(e1: EdgeType, e2: EdgeType) -> bool:
    """Two edges are compatible iff one complements the other."""
    return complement(e1) == e2


def bool_to_edge(b: bool) -> EdgeType:
    """Boolean-to-edge encoding: True ↦ tab, False ↦ blank."""
    return EdgeType.TAB if b else EdgeType.BLANK


# --- Demonstrations ---

def demo_involution():
    """Demonstrate that complement is an involution."""
    print("=" * 60)
    print("DEMO 1: Complement Involution")
    print("=" * 60)
    for e in EdgeType:
        c = complement(e)
        cc = complement(c)
        print(f"  complement({e.value}) = {c.value}")
        print(f"  complement(complement({e.value})) = {cc.value}")
        assert cc == e, "Involution property failed!"
    print("  ✓ Complement is an involution (σ² = id)")
    print()


def demo_compatibility():
    """Demonstrate compatibility structure."""
    print("=" * 60)
    print("DEMO 2: Compatibility Matrix")
    print("=" * 60)
    edges = list(EdgeType)
    header = "         " + "  ".join(f"{e.value:>5}" for e in edges)
    print(header)
    for e1 in edges:
        row = f"  {e1.value:>5}  "
        for e2 in edges:
            row += f"  {'✓' if is_compatible(e1, e2) else '✗':>5}"
        print(row)
    print()
    print("  Key insight: tab-blank are compatible (complementary pair)")
    print("  flat-flat are compatible (boundary self-pair)")
    print("  No other pairs are compatible")
    print()


def demo_boolean_encoding():
    """Demonstrate Boolean-to-edge correspondence."""
    print("=" * 60)
    print("DEMO 3: Boolean-Edge Correspondence")
    print("=" * 60)
    for b1 in [True, False]:
        for b2 in [True, False]:
            e1 = bool_to_edge(b1)
            e2 = bool_to_edge(b2)
            compat = is_compatible(e1, e2)
            distinct = b1 != b2
            status = "✓" if compat == distinct else "✗"
            print(f"  {status} b₁={b1!s:>5}, b₂={b2!s:>5} → "
                  f"edges ({e1.value}, {e2.value}), "
                  f"compatible={compat}, distinct={distinct}")
    print()
    print("  ✓ compatible(β(b₁), β(b₂)) ⟺ b₁ ≠ b₂")
    print()


def demo_sat_reduction():
    """Demonstrate SAT-to-puzzle reduction."""
    print("=" * 60)
    print("DEMO 4: SAT-to-Puzzle Reduction")
    print("=" * 60)
    # Example: (x₀ ∨ x₁ ∨ ¬x₂) ∧ (¬x₀ ∨ x₂ ∨ x₂)
    clauses = [
        [(0, True), (1, True), (2, False)],   # x₀ ∨ x₁ ∨ ¬x₂
        [(0, False), (2, True), (2, True)],    # ¬x₀ ∨ x₂ ∨ x₂
    ]
    print("  Formula: (x₀ ∨ x₁ ∨ ¬x₂) ∧ (¬x₀ ∨ x₂ ∨ x₂)")
    print()

    # Try all 8 assignments
    for a0 in [False, True]:
        for a1 in [False, True]:
            for a2 in [False, True]:
                assignment = {0: a0, 1: a1, 2: a2}
                satisfied = True
                clause_info = []
                for clause in clauses:
                    has_tab = False
                    edges = []
                    for var, pol in clause:
                        val = assignment[var] if pol else not assignment[var]
                        edge = bool_to_edge(val)
                        edges.append(edge.value)
                        if edge == EdgeType.TAB:
                            has_tab = True
                    clause_info.append((has_tab, edges))
                    if not has_tab:
                        satisfied = False

                status = "SAT" if satisfied else "UNSAT"
                print(f"  x₀={a0!s:>5} x₁={a1!s:>5} x₂={a2!s:>5} → {status}")
                for i, (has_tab, edges) in enumerate(clause_info):
                    tab_mark = "✓ has tab" if has_tab else "✗ no tab"
                    print(f"    Clause {i+1}: edges={edges} ({tab_mark})")
    print()


def demo_euler_characteristic():
    """Demonstrate grid Euler characteristic."""
    print("=" * 60)
    print("DEMO 5: Grid Euler Characteristic (V - E + F = 2)")
    print("=" * 60)
    for m in range(1, 6):
        for n in range(1, 6):
            V = m * n
            E = m * (n - 1) + (m - 1) * n
            F = (m - 1) * (n - 1) + 1
            chi = V - E + F
            if m <= 3 and n <= 3:
                print(f"  Grid {m}×{n}: V={V}, E={E}, F={F}, χ={chi}")
            assert chi == 2, f"Euler characteristic failed for {m}×{n}!"
    print(f"  ... (verified for all grids up to 5×5)")
    print(f"  ✓ V - E + F = 2 for all grid sizes")
    print()


def demo_constraint_superadditivity():
    """Demonstrate constraint superadditivity."""
    print("=" * 60)
    print("DEMO 6: Constraint Superadditivity")
    print("=" * 60)
    for m in range(1, 5):
        for n in range(1, 5):
            E_single = m * (n - 1) + (m - 1) * n
            E_double = m * (2 * n - 1) + (m - 1) * 2 * n
            surplus = E_double - 2 * E_single
            print(f"  m={m}, n={n}: E(m,n)={E_single}, E(m,2n)={E_double}, "
                  f"surplus = E(m,2n) - 2·E(m,n) = {surplus} ≥ {m}")
            assert surplus >= m
    print(f"  ✓ E(m,2n) ≥ 2·E(m,n) + m for all tested cases")
    print()


def demo_random_defects():
    """Demonstrate defect statistics for random assemblies."""
    print("=" * 60)
    print("DEMO 7: Random Assembly Defect Statistics")
    print("=" * 60)
    random.seed(42)
    non_boundary = [EdgeType.TAB, EdgeType.BLANK]

    for k_pairs in [1, 2, 5, 10]:
        n = 5
        total_edges = 2 * n * (n - 1)
        # For k_pairs complementary pairs, probability of random match = 1/(2k)
        # (each of 2k types maps to exactly one of 2k types)
        trials = 1000
        total_defects = 0
        for _ in range(trials):
            # Assign random edges (from 2*k_pairs types) to each internal edge
            defects = 0
            for _ in range(total_edges):
                e1 = random.randint(0, 2 * k_pairs - 1)
                e2 = random.randint(0, 2 * k_pairs - 1)
                # Compatible if e2 is the complement of e1
                # Complement of i is (i + k_pairs) mod (2*k_pairs) for a cyclic pairing
                if e2 != (e1 + k_pairs) % (2 * k_pairs):
                    defects += 1
            total_defects += defects
        avg = total_defects / trials
        expected = total_edges * (1 - 1 / (2 * k_pairs))
        print(f"  k={k_pairs:>2} pairs, {n}×{n} grid: "
              f"avg defects = {avg:.1f}, "
              f"expected = {expected:.1f}, "
              f"total edges = {total_edges}")
    print()
    print("  As k increases, the expected defect count approaches the total edge count,")
    print("  meaning valid assemblies become exponentially rare.")
    print()


if __name__ == "__main__":
    demo_involution()
    demo_compatibility()
    demo_boolean_encoding()
    demo_sat_reduction()
    demo_euler_characteristic()
    demo_constraint_superadditivity()
    demo_random_defects()
    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""Visualization: Grid Euler Characteristic and Constraint Density"""
import matplotlib.pyplot as plt
import numpy as np


def internal_edges(m: int, n: int) -> int:
    return m * (n - 1) + (m - 1) * n


def euler_char(m: int, n: int) -> int:
    V = m * n
    E = internal_edges(m, n)
    F = (m - 1) * (n - 1) + 1
    return V - E + F


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Euler characteristic (always 2)
sizes = range(1, 20)
chi_values = [euler_char(n, n) for n in sizes]
axes[0].plot(sizes, chi_values, 'bo-', markersize=8)
axes[0].set_xlabel('Grid size n')
axes[0].set_ylabel('Euler characteristic χ')
axes[0].set_title('V - E + F = 2 (Topological Invariant)')
axes[0].set_ylim(0, 4)
axes[0].axhline(y=2, color='r', linestyle='--', alpha=0.5, label='χ = 2')
axes[0].legend()
axes[0].grid(True, alpha=0.3)

# Plot 2: Constraint density ratio
ratios = [internal_edges(n, n) / (n * n) for n in range(1, 50)]
axes[1].plot(range(1, 50), ratios, 'g-', linewidth=2)
axes[1].axhline(y=2, color='r', linestyle='--', alpha=0.5, label='Limit = 2')
axes[1].set_xlabel('Grid size n')
axes[1].set_ylabel('E(n,n) / n²')
axes[1].set_title('Constraint-to-Cell Ratio → 2')
axes[1].legend()
axes[1].grid(True, alpha=0.3)

# Plot 3: Superadditivity surplus
m_vals = range(1, 15)
for n in [2, 5, 10]:
    surplus = [internal_edges(m, 2*n) - 2*internal_edges(m, n) for m in m_vals]
    axes[2].plot(m_vals, surplus, 'o-', label=f'n={n}', markersize=4)
    # Also plot m (the lower bound)
axes[2].plot(m_vals, list(m_vals), 'k--', alpha=0.5, label='Lower bound = m')
axes[2].set_xlabel('Grid rows m')
axes[2].set_ylabel('E(m,2n) - 2·E(m,n)')
axes[2].set_title('Constraint Superadditivity Surplus')
axes[2].legend()
axes[2].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('euler_and_density.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved euler_and_density.png")


#!/usr/bin/env python3
"""Visualization: Phase Transition in Random Jigsaw Puzzles"""
import matplotlib.pyplot as plt
import numpy as np
import random


def simulate_defect_fraction(n: int, k_pairs: int, trials: int = 500) -> float:
    """Simulate average defect fraction for n×n grid with k complementary pairs."""
    total_edges = 2 * n * (n - 1)
    if total_edges == 0:
        return 0.0
    total_defect_frac = 0.0
    for _ in range(trials):
        defects = 0
        for _ in range(total_edges):
            e1 = random.randint(0, 2 * k_pairs - 1)
            e2 = random.randint(0, 2 * k_pairs - 1)
            if e2 != (e1 + k_pairs) % (2 * k_pairs):
                defects += 1
        total_defect_frac += defects / total_edges
    return total_defect_frac / trials


def expected_defect_fraction(k: int) -> float:
    """Theoretical expected defect fraction: 1 - 1/(2k)."""
    return 1 - 1 / (2 * k)


random.seed(42)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Defect fraction vs alphabet size
k_values = list(range(1, 21))
n_values = [3, 5, 8]
colors = ['blue', 'green', 'red']

for n, color in zip(n_values, colors):
    simulated = [simulate_defect_fraction(n, k, trials=200) for k in k_values]
    axes[0].plot(k_values, simulated, 'o', color=color, markersize=4, alpha=0.7)
    axes[0].plot(k_values, simulated, '-', color=color, alpha=0.3)

theoretical = [expected_defect_fraction(k) for k in k_values]
axes[0].plot(k_values, theoretical, 'k--', linewidth=2, label='Theory: 1-1/(2k)')
axes[0].set_xlabel('Complementary pairs k')
axes[0].set_ylabel('Average defect fraction')
axes[0].set_title('Defect Fraction vs Alphabet Size')
axes[0].legend([f'n={n}' for n in n_values] + ['Theory: 1-1/(2k)'])
axes[0].grid(True, alpha=0.3)

# Plot 2: Log expected valid assemblies
n_range = np.arange(2, 15)
for k in [1, 2, 5, 10]:
    total_edges = 2 * n_range * (n_range - 1)
    cells = n_range ** 2
    # Expected valid = (2k+1)^cells * (1/(2k+1))^edges
    # = (2k+1)^(cells - edges)
    log_expected = (cells - total_edges) * np.log10(2 * k + 1)
    axes[1].plot(n_range, log_expected, 'o-', markersize=4, label=f'k={k}')

axes[1].axhline(y=0, color='red', linestyle='--', alpha=0.5, label='N=1 threshold')
axes[1].set_xlabel('Grid size n')
axes[1].set_ylabel('log₁₀(expected valid assemblies)')
axes[1].set_title('Expected Valid Assemblies (Phase Transition)')
axes[1].legend()
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved phase_transition.png")
