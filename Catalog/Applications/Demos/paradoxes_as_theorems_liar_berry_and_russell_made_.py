#!/usr/bin/env python3
"""
Paradoxes as Theorems: Demo of the LP (Logic of Paradox) System

Demonstrates the three-valued paraconsistent logic where Liar, Russell,
and Berry paradoxes coexist as theorems in a nontrivial, self-sound system.
"""

from enum import Enum
from typing import Callable


class TV(Enum):
    """Three-valued truth: true, false, both."""
    TT = "true"
    FF = "false"
    BOTH = "both"

    def designated(self) -> bool:
        return self in (TV.TT, TV.BOTH)

    def neg(self) -> "TV":
        if self == TV.TT: return TV.FF
        if self == TV.FF: return TV.TT
        return TV.BOTH

    @staticmethod
    def conj(a: "TV", b: "TV") -> "TV":
        if a == TV.FF or b == TV.FF: return TV.FF
        if a == TV.TT: return b
        if b == TV.TT: return a
        return TV.BOTH

    @staticmethod
    def disj(a: "TV", b: "TV") -> "TV":
        if a == TV.TT or b == TV.TT: return TV.TT
        if a == TV.FF: return b
        if b == TV.FF: return a
        return TV.BOTH


def demo_explosion_fails():
    """Show that P ∧ ¬P does NOT imply Q in LP."""
    print("=" * 60)
    print("DEMO 1: Explosion Fails in LP")
    print("=" * 60)

    P = TV.BOTH
    Q = TV.FF

    contradiction = TV.conj(P, P.neg())
    print(f"  P = {P.value}")
    print(f"  ¬P = {P.neg().value}")
    print(f"  P ∧ ¬P = {contradiction.value}")
    print(f"  P ∧ ¬P designated? {contradiction.designated()}")
    print(f"  Q = {Q.value}")
    print(f"  Q designated? {Q.designated()}")
    print(f"  → Contradiction exists but Q is NOT proved!")
    print()

    print("  Classical comparison:")
    for p_bool in [True, False]:
        result = p_bool and (not p_bool)
        print(f"    P={p_bool}: P ∧ ¬P = {result} (always False)")
    print()


def demo_liar_sentence():
    """Show the Liar sentence works in LP."""
    print("=" * 60)
    print("DEMO 2: The Liar Sentence")
    print("=" * 60)

    L = TV.BOTH
    neg_L = L.neg()

    print(f"  Liar sentence L = '{L.value}'")
    print(f"  ¬L = '{neg_L.value}'")
    print(f"  L = ¬L? {L == neg_L}")
    print(f"  L designated (accepted as true)? {L.designated()}")
    print(f"  ¬L designated (accepted as true)? {neg_L.designated()}")
    print(f"  → L is both true AND false — the paradox is a theorem!")
    print()

    print("  Classical comparison:")
    for l_bool in [True, False]:
        print(f"    L={l_bool}: ¬L={not l_bool}, L=¬L? {l_bool == (not l_bool)}")
    print("    → No classical assignment works!")
    print()


def demo_russell_set():
    """Show Russell's set works in LP."""
    print("=" * 60)
    print("DEMO 3: Russell's Set")
    print("=" * 60)

    R_mem_R = TV.BOTH
    not_R_mem_R = R_mem_R.neg()

    print(f"  R ∈ R = '{R_mem_R.value}'")
    print(f"  R ∉ R = ¬(R ∈ R) = '{not_R_mem_R.value}'")
    print(f"  R ∈ R = ¬(R ∈ R)? {R_mem_R == not_R_mem_R}")
    print(f"  R ∈ R designated? {R_mem_R.designated()}")
    print(f"  R ∉ R designated? {not_R_mem_R.designated()}")
    print(f"  → Russell's set is simultaneously a member and non-member!")
    print()


def demo_berry_paradox():
    """Show Berry's paradox resolution in LP."""
    print("=" * 60)
    print("DEMO 4: Berry's Paradox")
    print("=" * 60)

    definable = {
        0: TV.TT, 1: TV.TT, 2: TV.TT,  # Small numbers: definable
        3: TV.TT, 4: TV.TT, 5: TV.TT,
        42: TV.BOTH,  # Berry's number: both definable and not
        1000: TV.FF, 1001: TV.FF,  # Large numbers: not definable
    }

    print("  Number → Definability status:")
    for n, v in sorted(definable.items()):
        status = "definable" if v == TV.TT else "undefinable" if v == TV.FF else "BOTH (Berry!)"
        print(f"    {n:>5}: {v.value:>5} — {status}")
    print()
    print("  Berry's number (42) is BOTH definable and undefinable.")
    print("  This is consistent because 'both' is a fixed point of negation.")
    print()


def demo_self_soundness():
    """Show the system proves its own soundness."""
    print("=" * 60)
    print("DEMO 5: Self-Soundness")
    print("=" * 60)

    atoms = {"Liar": TV.BOTH, "Normal_True": TV.TT, "Normal_False": TV.FF}

    print("  Atom valuations:")
    for name, v in atoms.items():
        print(f"    {name}: {v.value} (designated: {v.designated()})")

    print()
    print("  Truth predicate T(φ) = φ (transparent):")
    for name, v in atoms.items():
        t_v = v  # transparent truth
        print(f"    T({name}) = {t_v.value}")
        if v.designated():
            print(f"      → {name} designated → T({name}) designated ✓")

    print()
    print("  Self-soundness: every designated φ has T(φ) designated ✓")
    print("  Nontriviality: Normal_False is NOT designated ✓")
    print("  → System proves its own soundness without collapsing!")
    print()


def demo_de_morgan():
    """Verify De Morgan's laws hold in LP."""
    print("=" * 60)
    print("DEMO 6: De Morgan's Laws in LP")
    print("=" * 60)

    all_tv = [TV.TT, TV.FF, TV.BOTH]
    all_pass = True

    for a in all_tv:
        for b in all_tv:
            lhs1 = TV.conj(a, b).neg()
            rhs1 = TV.disj(a.neg(), b.neg())
            lhs2 = TV.disj(a, b).neg()
            rhs2 = TV.conj(a.neg(), b.neg())

            ok1 = lhs1 == rhs1
            ok2 = lhs2 == rhs2
            if not ok1 or not ok2:
                all_pass = False
                print(f"  FAIL: a={a.value}, b={b.value}")

    if all_pass:
        print("  All 9 × 2 = 18 De Morgan checks passed ✓")
    print()


def demo_inconsistency_degree():
    """Show minimal inconsistency measurement."""
    print("=" * 60)
    print("DEMO 7: Inconsistency Degree")
    print("=" * 60)

    for n in [3, 5, 10, 50, 100]:
        # One glutty atom (the Liar), rest classical
        degree = 1.0 / n
        print(f"  n={n:>3} atoms, 1 paradoxical → δ = {degree:.4f} ({degree*100:.1f}%)")

    print()
    print("  As the system grows, inconsistency → 0.")
    print("  The paradox is an infinitesimal fraction of the whole.")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   PARADOXES AS THEOREMS: LP Logic Demo                  ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_explosion_fails()
    demo_liar_sentence()
    demo_russell_set()
    demo_berry_paradox()
    demo_self_soundness()
    demo_de_morgan()
    demo_inconsistency_degree()

    print("All demos completed successfully.")


#!/usr/bin/env python3
"""
Visualization: LP Truth Tables and Explosion Comparison

Creates a side-by-side comparison of classical vs LP truth tables,
showing how explosion fails in LP but holds in classical logic.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def tv_neg(v: str) -> str:
    return {"T": "F", "F": "T", "B": "B"}[v]

def tv_conj(a: str, b: str) -> str:
    if a == "F" or b == "F": return "F"
    if a == "T": return b
    if b == "T": return a
    return "B"

def tv_disj(a: str, b: str) -> str:
    if a == "T" or b == "T": return "T"
    if a == "F": return b
    if b == "F": return a
    return "B"

def designated(v: str) -> bool:
    return v in ("T", "B")


def create_truth_table_figure():
    fig, axes = plt.subplots(1, 3, figsize=(16, 6))
    fig.suptitle("Paraconsistent Logic (LP): Three-Valued Truth Tables",
                 fontsize=16, fontweight='bold', y=0.98)

    colors = {"T": "#2ecc71", "F": "#e74c3c", "B": "#f39c12"}
    labels = {"T": "True", "F": "False", "B": "Both"}

    # Negation table
    ax = axes[0]
    ax.set_title("Negation (¬)", fontsize=14, fontweight='bold')
    vals = ["T", "F", "B"]
    table_data = []
    cell_colors = []
    for v in vals:
        nv = tv_neg(v)
        table_data.append([labels[v], labels[nv]])
        cell_colors.append([colors[v], colors[nv]])

    table = ax.table(cellText=table_data,
                     colLabels=["a", "¬a"],
                     cellColours=cell_colors,
                     loc='center',
                     cellLoc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(12)
    table.scale(1, 2)
    for cell in table.get_celld().values():
        cell.set_text_props(color='white', fontweight='bold')
    ax.axis('off')

    # Conjunction table
    ax = axes[1]
    ax.set_title("Conjunction (∧)", fontsize=14, fontweight='bold')
    table_data = []
    cell_colors = []
    for a in vals:
        row = []
        row_colors = []
        for b in vals:
            r = tv_conj(a, b)
            row.append(labels[r])
            row_colors.append(colors[r])
        table_data.append(row)
        cell_colors.append(row_colors)

    table = ax.table(cellText=table_data,
                     rowLabels=[labels[v] for v in vals],
                     colLabels=[labels[v] for v in vals],
                     cellColours=cell_colors,
                     loc='center',
                     cellLoc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(11)
    table.scale(1, 2)
    for cell in table.get_celld().values():
        cell.set_text_props(color='white', fontweight='bold')
    ax.axis('off')

    # Disjunction table
    ax = axes[2]
    ax.set_title("Disjunction (∨)", fontsize=14, fontweight='bold')
    table_data = []
    cell_colors = []
    for a in vals:
        row = []
        row_colors = []
        for b in vals:
            r = tv_disj(a, b)
            row.append(labels[r])
            row_colors.append(colors[r])
        table_data.append(row)
        cell_colors.append(row_colors)

    table = ax.table(cellText=table_data,
                     rowLabels=[labels[v] for v in vals],
                     colLabels=[labels[v] for v in vals],
                     cellColours=cell_colors,
                     loc='center',
                     cellLoc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(11)
    table.scale(1, 2)
    for cell in table.get_celld().values():
        cell.set_text_props(color='white', fontweight='bold')
    ax.axis('off')

    plt.tight_layout(rect=[0, 0.05, 1, 0.93])

    legend_patches = [mpatches.Patch(color=colors[k], label=labels[k]) for k in vals]
    fig.legend(handles=legend_patches, loc='lower center', ncol=3, fontsize=12)

    plt.savefig("viz_truth_tables.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_truth_tables.png")


def create_explosion_comparison():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    fig.suptitle("Explosion: Classical vs Paraconsistent",
                 fontsize=16, fontweight='bold')

    # Classical
    ax1.set_title("Classical Logic", fontsize=14)
    ax1.text(0.5, 0.85, "P ∧ ¬P → Q", fontsize=18, ha='center',
             fontfamily='monospace', fontweight='bold')
    ax1.text(0.5, 0.65, "Always valid!", fontsize=14, ha='center',
             color='red', fontweight='bold')
    ax1.text(0.5, 0.45, "If P=T: T ∧ F = F (premise false)", fontsize=11, ha='center')
    ax1.text(0.5, 0.30, "If P=F: F ∧ T = F (premise false)", fontsize=11, ha='center')
    ax1.text(0.5, 0.15, "Contradiction → ANYTHING follows", fontsize=12,
             ha='center', color='red', style='italic')
    ax1.set_xlim(0, 1)
    ax1.set_ylim(0, 1)
    ax1.axis('off')
    ax1.patch.set_facecolor('#ffebee')

    # Paraconsistent
    ax2.set_title("LP (Paraconsistent)", fontsize=14)
    ax2.text(0.5, 0.85, "P ∧ ¬P → Q", fontsize=18, ha='center',
             fontfamily='monospace', fontweight='bold')
    ax2.text(0.5, 0.65, "INVALID when P = Both!", fontsize=14, ha='center',
             color='green', fontweight='bold')
    ax2.text(0.5, 0.45, "P=Both: Both ∧ Both = Both ✓", fontsize=11, ha='center')
    ax2.text(0.5, 0.30, "Q=False: not designated ✗", fontsize=11, ha='center')
    ax2.text(0.5, 0.15, "Contradiction is CONTAINED", fontsize=12,
             ha='center', color='green', style='italic')
    ax2.set_xlim(0, 1)
    ax2.set_ylim(0, 1)
    ax2.axis('off')
    ax2.patch.set_facecolor('#e8f5e9')

    plt.tight_layout()
    plt.savefig("viz_explosion.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_explosion.png")


def create_inconsistency_degree_plot():
    fig, ax = plt.subplots(figsize=(10, 6))

    ns = list(range(1, 101))
    degrees = [1.0 / n for n in ns]

    ax.fill_between(ns, degrees, alpha=0.3, color='#f39c12')
    ax.plot(ns, degrees, color='#e67e22', linewidth=2, label='δ = 1/n')
    ax.axhline(y=0, color='#2ecc71', linewidth=1, linestyle='--',
               label='Classical (δ = 0)')

    ax.set_xlabel("Number of atoms (n)", fontsize=13)
    ax.set_ylabel("Inconsistency degree (δ)", fontsize=13)
    ax.set_title("Minimal Inconsistency: Paradox as Vanishing Fraction",
                 fontsize=15, fontweight='bold')
    ax.legend(fontsize=12)
    ax.set_xlim(1, 100)
    ax.set_ylim(0, 1.05)

    ax.annotate('One paradoxical atom\namong n total',
                xy=(10, 0.1), xytext=(40, 0.5),
                fontsize=11, arrowprops=dict(arrowstyle='->', color='black'),
                ha='center')

    plt.tight_layout()
    plt.savefig("viz_inconsistency.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_inconsistency.png")


if __name__ == "__main__":
    create_truth_table_figure()
    create_explosion_comparison()
    create_inconsistency_degree_plot()
    print("All visualizations generated.")
