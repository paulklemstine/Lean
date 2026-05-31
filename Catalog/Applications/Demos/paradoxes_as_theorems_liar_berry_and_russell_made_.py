#!/usr/bin/env python3
"""
Paraconsistent Logic Demo
==========================

Demonstrates the key results from the formal Lean proofs:
1. Belnap four-valued logic operations
2. Liar sentence resolution
3. Russell's paradox resolution
4. Berry's paradox via pigeonhole
5. Failure of classical laws in FDE
"""

from algorithms import (
    BelnapVal, FDEFormula, check_fde_tautology,
    find_counterexample, inconsistency_degree,
    berry_pigeonhole, liar_tower
)


def demo_belnap_truth_tables():
    """Show the 4x4 truth tables for Belnap operations."""
    print("=" * 60)
    print("BELNAP FOUR-VALUED LOGIC TRUTH TABLES")
    print("=" * 60)

    vals = list(BelnapVal)
    labels = {BelnapVal.T: "T", BelnapVal.F: "F",
              BelnapVal.B: "B", BelnapVal.N: "N"}

    # Negation
    print("\n--- Negation ---")
    print("  v  | ¬v")
    print("-----+----")
    for v in vals:
        print(f"  {labels[v]}  |  {labels[v.neg()]}")

    # Conjunction
    print("\n--- Conjunction (∧) ---")
    header = "  ∧  | " + " | ".join(labels[v] for v in vals)
    print(header)
    print("-" * len(header))
    for a in vals:
        row = f"  {labels[a]}  | " + " | ".join(
            labels[a.conj(b)] for b in vals)
        print(row)

    # Disjunction
    print("\n--- Disjunction (∨) ---")
    header = "  ∨  | " + " | ".join(labels[v] for v in vals)
    print(header)
    print("-" * len(header))
    for a in vals:
        row = f"  {labels[a]}  | " + " | ".join(
            labels[a.disj(b)] for b in vals)
        print(row)


def demo_liar_paradox():
    """Demonstrate the Liar sentence resolution."""
    print("\n" + "=" * 60)
    print("THE LIAR PARADOX: 'This sentence is false'")
    print("=" * 60)

    print("\nIn classical logic: L ↔ ¬L leads to contradiction.")
    print("In Belnap logic: L gets value B (both true AND false).")
    print()

    # Check: if L has value B, then ¬L also has value B
    liar_val = BelnapVal.B
    neg_liar = liar_val.neg()
    print(f"  L  = {liar_val.value}")
    print(f"  ¬L = {neg_liar.value}")
    print(f"  L = ¬L? {liar_val == neg_liar} ✓")
    print(f"  L is at-least-true? {liar_val.is_true} (the Liar IS 'true')")
    print(f"  L is at-least-false? {liar_val.is_false} (the Liar IS also 'false')")
    print(f"\n  → No contradiction! Both hold simultaneously.")

    # Show the Liar tower stabilizes
    print("\n--- Liar Tower (iterated self-reference) ---")
    tower = liar_tower(5)
    for i, v in enumerate(tower):
        prefix = "L" if i == 0 else f"¬^{i}L"
        print(f"  {prefix:6s} = {v.value}")
    print("  Tower is constant at B — self-reference stabilizes.")


def demo_russell_paradox():
    """Demonstrate Russell's paradox resolution."""
    print("\n" + "=" * 60)
    print("RUSSELL'S PARADOX: R = {x | x ∉ x}")
    print("=" * 60)

    print("\nClassically: R ∈ R ↔ R ∉ R → contradiction.")
    print("Paraconsistently: R ∈ R gets value B.")
    print()

    r_mem = BelnapVal.B
    neg_r_mem = r_mem.neg()
    print(f"  R ∈ R  = {r_mem.value}")
    print(f"  R ∉ R  = {neg_r_mem.value}")
    print(f"  R ∈ R = R ∉ R? {r_mem == neg_r_mem} ✓")
    print(f"\n  → R belongs to itself AND doesn't. No explosion.")


def demo_berry_paradox():
    """Demonstrate Berry's paradox via pigeonhole."""
    print("\n" + "=" * 60)
    print("BERRY'S PARADOX: 'The least number not definable in < 100 words'")
    print("=" * 60)

    for n_obj, n_desc in [(100, 50), (1000, 999), (11, 10)]:
        is_paradoxical, msg = berry_pigeonhole(n_obj, n_desc)
        symbol = "⚠" if is_paradoxical else "✓"
        print(f"\n  {symbol} {msg}")

    print("\n  Key insight: definability is bounded by description length.")
    print("  With n+1 objects and n descriptions, some object lacks")
    print("  a unique description (pigeonhole principle).")


def demo_classical_failures():
    """Show which classical laws fail in FDE."""
    print("\n" + "=" * 60)
    print("CLASSICAL LAWS THAT FAIL IN FDE")
    print("=" * 60)

    p = FDEFormula.atom(0)
    q = FDEFormula.atom(1)

    laws = [
        ("Excluded Middle: p ∨ ¬p", FDEFormula.disj(p, FDEFormula.neg(p))),
        ("Non-Contradiction: ¬(p ∧ ¬p)",
         FDEFormula.neg(FDEFormula.conj(p, FDEFormula.neg(p)))),
        ("Explosion: (p ∧ ¬p) → q",
         FDEFormula.impl(FDEFormula.conj(p, FDEFormula.neg(p)), q)),
        ("Double Negation: ¬¬p → p",
         FDEFormula.impl(FDEFormula.neg(FDEFormula.neg(p)), p)),
        ("Modus Ponens: p ∧ (p → q) → q",
         FDEFormula.impl(FDEFormula.conj(p, FDEFormula.impl(p, q)), q)),
    ]

    for name, formula in laws:
        is_taut = check_fde_tautology(formula, [0, 1])
        cx = find_counterexample(formula, [0, 1])
        status = "✓ VALID" if is_taut else "✗ FAILS"
        print(f"\n  {status}: {name}")
        if cx:
            labels = {BelnapVal.T: "T", BelnapVal.F: "F",
                      BelnapVal.B: "B", BelnapVal.N: "N"}
            cx_str = ", ".join(f"p{k}={labels[v]}" for k, v in sorted(cx.items()))
            print(f"         Counterexample: {cx_str}")


def demo_explosion_failure():
    """Demonstrate that contradictions don't explode in FDE."""
    print("\n" + "=" * 60)
    print("EXPLOSION FAILURE: p ∧ ¬p does NOT entail everything")
    print("=" * 60)

    print("\nClassical: A ∧ ¬A ⊢ B  (ex falso quodlibet)")
    print("FDE:       A ∧ ¬A ⊬ B  (contradictions are contained)")
    print()

    # Show: with A = B (both), A ∧ ¬A = B, but we can have C = F
    a_val = BelnapVal.B
    contradiction = a_val.conj(a_val.neg())
    print(f"  A = B (both true and false)")
    print(f"  A ∧ ¬A = {contradiction.value}")
    print(f"  is_true(A ∧ ¬A) = {contradiction.is_true}")
    print(f"  But we can still have C = F (false)")
    print(f"  is_true(C) = {BelnapVal.F.is_true}")
    print(f"  → Contradiction in A does NOT force C to be true!")


def demo_inconsistency_degree():
    """Show the inconsistency degree measure."""
    print("\n" + "=" * 60)
    print("INCONSISTENCY DEGREE OF THEORIES")
    print("=" * 60)

    theories = [
        ("Classical (all T/F)",
         [BelnapVal.T, BelnapVal.F, BelnapVal.T, BelnapVal.F]),
        ("One dialetheia",
         [BelnapVal.T, BelnapVal.F, BelnapVal.B, BelnapVal.T]),
        ("Two dialetheias",
         [BelnapVal.B, BelnapVal.F, BelnapVal.B, BelnapVal.T]),
        ("Maximally inconsistent",
         [BelnapVal.B, BelnapVal.B, BelnapVal.B, BelnapVal.B]),
    ]

    for name, vals in theories:
        deg = inconsistency_degree(vals)
        n = len(vals)
        labels = {BelnapVal.T: "T", BelnapVal.F: "F",
                  BelnapVal.B: "B", BelnapVal.N: "N"}
        val_str = "[" + ", ".join(labels[v] for v in vals) + "]"
        print(f"\n  {name}:")
        print(f"    Values: {val_str}")
        print(f"    Inconsistency degree: {deg}/{n}")
        if any(v == BelnapVal.T for v in vals):
            print(f"    Non-trivial: degree < n ✓ (proven bound: ≤ {n-1})")


if __name__ == "__main__":
    demo_belnap_truth_tables()
    demo_liar_paradox()
    demo_russell_paradox()
    demo_berry_paradox()
    demo_classical_failures()
    demo_explosion_failure()
    demo_inconsistency_degree()

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Belnap's Four-Valued Logic Lattice
==================================================

Shows the two orderings on Belnap values:
1. Truth ordering (vertical): F ≤ N,B ≤ T
2. Information ordering (horizontal): N ≤ T,F ≤ B

Also shows the explosion comparison between classical and FDE.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_belnap_lattice(ax, title, positions, edges, colors):
    """Draw a lattice diagram."""
    ax.set_title(title, fontsize=14, fontweight='bold')
    for (x1, y1), (x2, y2) in edges:
        ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1.5, zorder=1)
    for label, (x, y) in positions.items():
        color = colors.get(label, '#4ECDC4')
        circle = plt.Circle((x, y), 0.15, color=color, ec='black',
                             linewidth=2, zorder=2)
        ax.add_patch(circle)
        ax.text(x, y, label, ha='center', va='center',
                fontsize=16, fontweight='bold', zorder=3)
    ax.set_xlim(-0.5, 2.5)
    ax.set_ylim(-0.5, 2.5)
    ax.set_aspect('equal')
    ax.axis('off')


def draw_explosion_comparison(ax):
    """Compare explosion in classical vs FDE logic."""
    categories = ['Classical\n(A ∧ ¬A → B)', 'FDE\n(A ∧ ¬A → B)']
    explodes = [1.0, 0.0]
    colors_bar = ['#FF6B6B', '#4ECDC4']

    bars = ax.bar(categories, explodes, color=colors_bar, edgecolor='black',
                  linewidth=2, width=0.5)
    ax.set_ylim(0, 1.3)
    ax.set_ylabel('Explosion Power', fontsize=12)
    ax.set_title('Explosion Principle', fontsize=14, fontweight='bold')

    ax.text(0, 1.05, 'EXPLODES', ha='center', fontsize=11,
            color='#FF6B6B', fontweight='bold')
    ax.text(1, 0.05, 'CONTAINED', ha='center', fontsize=11,
            color='#4ECDC4', fontweight='bold')
    ax.set_yticks([0, 0.5, 1.0])
    ax.set_yticklabels(['None', 'Partial', 'Full'])


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Truth ordering lattice
    truth_pos = {
        'T': (1, 2), 'F': (1, 0),
        'B': (0, 1), 'N': (2, 1)
    }
    truth_edges = [
        ((1, 0), (0, 1)), ((1, 0), (2, 1)),
        ((0, 1), (1, 2)), ((2, 1), (1, 2))
    ]
    truth_colors = {'T': '#4ECDC4', 'F': '#FF6B6B', 'B': '#FFE66D', 'N': '#95E1D3'}
    draw_belnap_lattice(axes[0], 'Truth Ordering\nF ≤ {B,N} ≤ T',
                        truth_pos, truth_edges, truth_colors)

    # Information ordering lattice
    info_pos = {
        'B': (1, 2), 'N': (1, 0),
        'T': (0, 1), 'F': (2, 1)
    }
    info_edges = [
        ((1, 0), (0, 1)), ((1, 0), (2, 1)),
        ((0, 1), (1, 2)), ((2, 1), (1, 2))
    ]
    info_colors = {'B': '#FFE66D', 'N': '#95E1D3', 'T': '#4ECDC4', 'F': '#FF6B6B'}
    draw_belnap_lattice(axes[1], 'Information Ordering\nN ≤ {T,F} ≤ B',
                        info_pos, info_edges, info_colors)

    # Explosion comparison
    draw_explosion_comparison(axes[2])

    plt.suptitle("Belnap's Four-Valued Logic (FDE)", fontsize=16,
                 fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_belnap_lattice.png', dpi=150, bbox_inches='tight')
    print("Saved viz_belnap_lattice.png")


if __name__ == "__main__":
    main()
