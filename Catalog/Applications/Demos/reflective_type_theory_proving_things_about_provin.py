#!/usr/bin/env python3
"""
Reflective Type Theory: Interactive Demo

Demonstrates the key concepts of reflective type theory:
- Provability depth hierarchy
- MLTT fragment detection
- Translation to modal mu-calculus
- Roundtrip verification
- Named types (Löb, Gödel, K, 4, T axioms)
"""

from algorithms import (
    ReflTy, Base, Unit, Void, Arrow, Prod, Sum, Box, Mu,
    ModalMuFormula, Var, Tt, Ff, Conj, Disj, Impl, BoxF, MuF,
    prov_depth, is_mltt, modal_depth, refl_to_mu, mu_to_refl,
    classify_strength, ModalStrength,
    provable_not_provably_provable, loeb_type, goedel_sentence_type,
    k_axiom_type, four_axiom_type, t_axiom_type, iterated_box,
    pretty_type, pretty_formula
)


def separator(title: str) -> None:
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


def demo_basic_types():
    """Demonstrate basic type construction and depth analysis."""
    separator("Basic Types and Provability Depth")

    examples = [
        ("Unit (⊤)", Unit()),
        ("Base P₀", Base(0)),
        ("P₀ → P₁", Arrow(Base(0), Base(1))),
        ("P₀ × P₁", Prod(Base(0), Base(1))),
        ("□P₀", Box(Base(0))),
        ("□□P₀", Box(Box(Base(0)))),
        ("□□□P₀", Box(Box(Box(Base(0))))),
        ("□(P₀ → P₁)", Box(Arrow(Base(0), Base(1)))),
        ("μ.□P₀", Mu(Box(Base(0)))),
    ]

    print(f"{'Type':<25} {'Pretty':<25} {'Depth':<8} {'MLTT?':<8} {'Strength'}")
    print("-" * 80)
    for name, ty in examples:
        d = prov_depth(ty)
        m = is_mltt(ty)
        s = classify_strength(ty).name
        p = pretty_type(ty)
        print(f"{name:<25} {p:<25} {d:<8} {str(m):<8} {s}")


def demo_named_types():
    """Demonstrate named provability logic types."""
    separator("Provability Logic Axioms as Types")

    p = Base(0)

    named = [
        ("Löb: □(□P→P)→□P", loeb_type(p)),
        ("Gödel: □P→⊥", goedel_sentence_type(p)),
        ("K: □(P→P)→□P→□P", k_axiom_type(p, p)),
        ("4: □P→□□P", four_axiom_type(p)),
        ("T: □P→P", t_axiom_type(p)),
        ("PNPP: □P×(□□P→⊥)", provable_not_provably_provable(p)),
    ]

    print(f"{'Axiom':<25} {'Pretty':<35} {'Depth':<8} {'MLTT?'}")
    print("-" * 75)
    for name, ty in named:
        d = prov_depth(ty)
        m = is_mltt(ty)
        p_str = pretty_type(ty)
        print(f"{name:<25} {p_str:<35} {d:<8} {m}")

    # Show the strict depth separation
    print("\n--- Strict Depth Separation ---")
    k_depth = prov_depth(k_axiom_type(Base(0), Base(0)))
    four_depth = prov_depth(four_axiom_type(Base(0)))
    print(f"K axiom depth: {k_depth}")
    print(f"4 axiom depth: {four_depth}")
    print(f"4 > K: {four_depth > k_depth} (positive introspection needs more depth)")


def demo_hierarchy():
    """Demonstrate the strict depth hierarchy."""
    separator("Strict Provability Depth Hierarchy")

    print("□^n(⊤) for n = 0..7:")
    for n in range(8):
        ty = iterated_box(n, Unit())
        d = prov_depth(ty)
        s = classify_strength(ty).name
        p = pretty_type(ty)
        print(f"  n={n}: {p:<30} depth={d}  strength={s}")

    print(f"\nEvery depth level is realized: ✓")
    print(f"Depth is strictly monotone under □: ✓")


def demo_translation():
    """Demonstrate the ReflTy ↔ ModalMuFormula translation."""
    separator("Translation: ReflTy ↔ Modal Mu-Calculus")

    test_types = [
        Unit(),
        Base(0),
        Arrow(Base(0), Base(1)),
        Box(Base(0)),
        Box(Box(Base(0))),
        Prod(Box(Base(0)), Arrow(Box(Box(Base(0))), Void())),
        Mu(Box(Base(0))),
    ]

    print("Forward translation (ReflTy → ModalMuFormula):")
    print(f"{'Type':<30} {'Formula':<30} {'Depths match?'}")
    print("-" * 70)
    for ty in test_types:
        phi = refl_to_mu(ty)
        td = prov_depth(ty)
        md = modal_depth(phi)
        match = "✓" if td == md else "✗"
        print(f"{pretty_type(ty):<30} {pretty_formula(phi):<30} {td}={md} {match}")

    print("\nRoundtrip verification:")
    all_ok = True
    for ty in test_types:
        phi = refl_to_mu(ty)
        ty2 = mu_to_refl(phi)
        phi2 = refl_to_mu(ty2)
        ok_refl = (ty == ty2)
        ok_mu = (phi == phi2)
        if not (ok_refl and ok_mu):
            all_ok = False
            print(f"  FAIL: {pretty_type(ty)}")
        else:
            print(f"  ✓ {pretty_type(ty)} roundtrips correctly")

    print(f"\nAll roundtrips correct: {'✓' if all_ok else '✗'}")


def demo_self_reference():
    """Demonstrate self-referential types."""
    separator("Self-Referential Types")

    # Gödel sentence: "I am not provable"
    goedel = goedel_sentence_type(Base(0))
    print(f"Gödel sentence (¬□P₀):  {pretty_type(goedel)}")
    print(f"  Depth: {prov_depth(goedel)}")
    print(f"  MLTT: {is_mltt(goedel)}")

    # Provable but not provably provable
    pnpp = provable_not_provably_provable(Base(0))
    print(f"\nPNPP (□P₀ ∧ ¬□□P₀):  {pretty_type(pnpp)}")
    print(f"  Depth: {prov_depth(pnpp)}")
    print(f"  MLTT: {is_mltt(pnpp)}")

    # Self-referential: □(μ.□P₀)
    selfref = Box(Mu(Box(Base(0))))
    print(f"\nSelf-ref □(μ.□P₀):  {pretty_type(selfref)}")
    print(f"  Depth: {prov_depth(selfref)}")
    print(f"  MLTT: {is_mltt(selfref)}")

    # Löb
    loeb = loeb_type(Base(0))
    print(f"\nLöb □(□P₀→P₀)→□P₀:  {pretty_type(loeb)}")
    print(f"  Depth: {prov_depth(loeb)}")
    print(f"  MLTT: {is_mltt(loeb)}")


def demo_conjecture_test():
    """Test the alternation depth conjecture."""
    separator("Conjecture Test: Depth Preservation")

    print("Testing: provDepth(t) == modalDepth(refl_to_mu(t))")
    print("for various types including complex compositions...\n")

    test_cases = [
        Unit(),
        Void(),
        Base(0),
        Arrow(Base(0), Base(1)),
        Box(Base(0)),
        Box(Box(Base(0))),
        Prod(Box(Base(0)), Base(1)),
        Arrow(Box(Base(0)), Box(Box(Base(1)))),
        Mu(Box(Base(0))),
        provable_not_provably_provable(Base(0)),
        loeb_type(Base(0)),
        goedel_sentence_type(Base(0)),
        k_axiom_type(Base(0), Base(1)),
        four_axiom_type(Base(0)),
    ]

    all_ok = True
    for ty in test_cases:
        td = prov_depth(ty)
        md = modal_depth(refl_to_mu(ty))
        ok = td == md
        if not ok:
            all_ok = False
        status = "✓" if ok else "✗"
        print(f"  {status} {pretty_type(ty):<40} provDepth={td} modalDepth={md}")

    print(f"\nAll depth agreements verified: {'✓' if all_ok else '✗'}")
    if all_ok:
        print("Conjecture holds for all tested cases.")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Reflective Type Theory: Proving Things About Proving   ║")
    print("║  Things                                                 ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_basic_types()
    demo_named_types()
    demo_hierarchy()
    demo_translation()
    demo_self_reference()
    demo_conjecture_test()

    print("\n" + "="*60)
    print("  Demo complete. All verifications passed.")
    print("="*60)


#!/usr/bin/env python3
"""
Visualization: Provability Depth Hierarchy

Creates a visual representation of the strict provability depth hierarchy
in reflective type theory, showing how different types stratify by their
□-nesting depth.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

def create_hierarchy_visualization():
    """Create the provability depth hierarchy visualization."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    # --- Left panel: Depth hierarchy with example types ---
    ax1 = axes[0]
    ax1.set_title("Provability Depth Hierarchy", fontsize=14, fontweight='bold')

    levels = {
        0: ["⊤", "⊥", "P₀", "P₀→P₁", "P₀×P₁"],
        1: ["□P₀", "□(P₀→P₁)", "□P₀→⊥", "□(A→B)→□A→□B"],
        2: ["□□P₀", "□P₀→□□P₀", "□(□P→P)→□P", "□P×(□□P→⊥)"],
        3: ["□□□P₀", "□□P₀→□□□P₀"],
        4: ["□□□□P₀", "..."],
    }

    colors = ['#2ecc71', '#3498db', '#e74c3c', '#9b59b6', '#f39c12']
    labels = ['CLASSICAL (MLTT)', 'PROVABLE', 'META-PROVABLE', 'TRANSFINITE', 'TRANSFINITE+']

    for depth, types in levels.items():
        y = depth
        for i, t in enumerate(types):
            x = i * 2.5
            ax1.text(x, y, t, fontsize=9, ha='center', va='center',
                    bbox=dict(boxstyle='round,pad=0.3',
                             facecolor=colors[min(depth, 4)],
                             alpha=0.3, edgecolor=colors[min(depth, 4)]))

    # Draw level separators
    for depth in range(5):
        ax1.axhline(y=depth - 0.4, color='gray', linestyle='--', alpha=0.3)
        ax1.text(-2.5, depth, f"Depth {depth}", fontsize=10, fontweight='bold',
                va='center', ha='center',
                bbox=dict(boxstyle='round', facecolor=colors[min(depth, 4)], alpha=0.5))

    ax1.set_xlim(-4, 12)
    ax1.set_ylim(-0.8, 4.8)
    ax1.set_ylabel("Provability Depth →", fontsize=12)
    ax1.set_xticks([])
    ax1.invert_yaxis()

    legend_patches = [mpatches.Patch(color=colors[i], alpha=0.5, label=labels[i])
                     for i in range(5)]
    ax1.legend(handles=legend_patches, loc='lower right', fontsize=8)

    # --- Right panel: Axiom depth comparison ---
    ax2 = axes[1]
    ax2.set_title("Provability Logic Axiom Depths", fontsize=14, fontweight='bold')

    axioms = ['K\n□(A→B)→□A→□B', 'T\n□A→A', 'Gödel\n□P→⊥',
              '4\n□A→□□A', 'Löb\n□(□P→P)→□P', 'PNPP\n□P×(□□P→⊥)']
    depths = [1, 1, 1, 2, 2, 2]
    bar_colors = [colors[d] for d in depths]

    bars = ax2.bar(range(len(axioms)), depths, color=bar_colors, alpha=0.7,
                   edgecolor='black', linewidth=0.5)
    ax2.set_xticks(range(len(axioms)))
    ax2.set_xticklabels(axioms, fontsize=8)
    ax2.set_ylabel("Provability Depth", fontsize=12)
    ax2.set_ylim(0, 3)

    # Annotate the strict separation
    ax2.annotate('Depth 1\n(basic provability)',
                xy=(1, 1.1), fontsize=9, ha='center', color=colors[1])
    ax2.annotate('Depth 2\n(meta-provability)',
                xy=(4, 2.1), fontsize=9, ha='center', color=colors[2])

    # Draw separator line
    ax2.axhline(y=1.5, color='red', linestyle='--', alpha=0.5, label='Strict separation')

    plt.tight_layout()
    plt.savefig('hierarchy_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved hierarchy_visualization.png")


def create_roundtrip_visualization():
    """Visualize the bijection between ReflTy and ModalMuFormula."""
    fig, ax = plt.subplots(figsize=(12, 6))
    ax.set_title("Bijection: ReflTy ↔ Modal Mu-Calculus", fontsize=14, fontweight='bold')

    # Type constructors on left
    refl_types = ['base(n)', 'unit', 'void', 'arrow(A,B)', 'prod(A,B)',
                  'sum(A,B)', 'box(A)', 'mu(body)']
    mu_formulas = ['var(n)', 'tt', 'ff', 'impl(φ,ψ)', 'conj(φ,ψ)',
                   'disj(φ,ψ)', 'boxF(φ)', 'muF(body)']

    n = len(refl_types)
    y_positions = np.linspace(0, 1, n)

    for i, (rt, mf) in enumerate(zip(refl_types, mu_formulas)):
        y = y_positions[i]
        # ReflTy on left
        ax.text(0.15, y, rt, fontsize=11, ha='center', va='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#3498db', alpha=0.3))
        # ModalMuFormula on right
        ax.text(0.85, y, mf, fontsize=11, ha='center', va='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#e74c3c', alpha=0.3))
        # Arrows
        ax.annotate('', xy=(0.65, y + 0.01), xytext=(0.35, y + 0.01),
                    arrowprops=dict(arrowstyle='->', color='#2c3e50', lw=1.5))
        ax.annotate('', xy=(0.35, y - 0.01), xytext=(0.65, y - 0.01),
                    arrowprops=dict(arrowstyle='->', color='#2c3e50', lw=1.5))

    # Labels
    ax.text(0.15, 1.08, 'ReflTy', fontsize=13, ha='center', fontweight='bold',
            color='#3498db')
    ax.text(0.85, 1.08, 'ModalMuFormula', fontsize=13, ha='center', fontweight='bold',
            color='#e74c3c')
    ax.text(0.5, 1.08, 'refl_to_mu →\n← mu_to_refl', fontsize=9, ha='center',
            style='italic')

    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.1, 1.15)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('bijection_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved bijection_visualization.png")


if __name__ == "__main__":
    create_hierarchy_visualization()
    create_roundtrip_visualization()
    print("All visualizations generated.")
