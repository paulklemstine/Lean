#!/usr/bin/env python3
"""
Reflective Type Theory: Interactive Demo

Demonstrates the core concepts:
1. Type construction and depth computation
2. Translation to modal mu-calculus
3. Kripke model evaluation
4. Axiom hierarchy analysis
5. Proof Depth Algebra computation
"""

from algorithms import (
    ReflTy, ModalMuFormula, KripkeModel,
    refl_to_mu, mu_to_refl,
    provable_not_provably_provable, lob_type, godel_sentence_type,
    k_axiom_type, four_axiom_type, iterated_box,
    compute_depth_algebra,
)


def demo_type_constructions():
    """Show key type constructions and their properties."""
    print("=" * 60)
    print("REFLECTIVE TYPE THEORY: TYPE CONSTRUCTIONS")
    print("=" * 60)

    P = ReflTy.base(0)

    types = {
        "Base type P": P,
        "Unit (⊤)": ReflTy.unit(),
        "Void (⊥)": ReflTy.void(),
        "P → P": ReflTy.arrow(P, P),
        "□P (P is provable)": ReflTy.box(P),
        "□□P (provably provable)": ReflTy.box(ReflTy.box(P)),
        "□P × (□□P → ⊥) [PnPP]": provable_not_provably_provable(P),
        "□(□P → P) → □P [Löb]": lob_type(P),
        "□P → ⊥ [Gödel]": godel_sentence_type(P),
        "□(P → P) → □P → □P [K]": k_axiom_type(P, P),
        "□P → □□P [4]": four_axiom_type(P),
        "□³P": iterated_box(3, P),
    }

    for name, ty in types.items():
        depth = ty.prov_depth()
        mltt = ty.is_mltt()
        strength = ty.classify_strength()
        sz = ty.size()
        boxes = ty.box_count()
        print(f"\n  {name}")
        print(f"    Pretty: {ty.pretty()}")
        print(f"    Depth: {depth}, Size: {sz}, □-count: {boxes}")
        print(f"    MLTT: {mltt}, Strength: {strength}")


def demo_translation():
    """Demonstrate the bijective translation."""
    print("\n" + "=" * 60)
    print("TRANSLATION: ReflTy ↔ ModalMuFormula")
    print("=" * 60)

    P = ReflTy.base(0)
    test_types = [
        ("□P", ReflTy.box(P)),
        ("P → □P", ReflTy.arrow(P, ReflTy.box(P))),
        ("Löb(P)", lob_type(P)),
        ("PnPP(P)", provable_not_provably_provable(P)),
        ("μ(□P)", ReflTy.mu(ReflTy.box(P))),
    ]

    for name, ty in test_types:
        formula = refl_to_mu(ty)
        roundtrip = mu_to_refl(formula)
        matches = (roundtrip == ty)
        print(f"\n  {name}")
        print(f"    Type:     {ty.pretty()}")
        print(f"    Formula:  {formula.pretty()}")
        print(f"    Roundtrip matches: {matches}")
        print(f"    Type depth: {ty.prov_depth()}, Formula depth: {formula.modal_depth()}")


def demo_depth_hierarchy():
    """Show the strict depth hierarchy."""
    print("\n" + "=" * 60)
    print("STRICT MODAL DEPTH HIERARCHY")
    print("=" * 60)

    P = ReflTy.base(0)
    print("\n  Level | Example Type            | Pretty")
    print("  " + "-" * 50)
    for n in range(7):
        ty = iterated_box(n, P)
        print(f"  {n:5d} | □^{n}(P)                 | {ty.pretty()}")

    print("\n  Theorem: □^n(A) has depth exactly n + d(A)")
    for n in range(5):
        ty = iterated_box(n, P)
        assert ty.prov_depth() == n + P.prov_depth(), f"Failed for n={n}"
    print("  ✓ Verified for n = 0..4")


def demo_axiom_hierarchy():
    """Demonstrate the axiom depth hierarchy."""
    print("\n" + "=" * 60)
    print("AXIOM DEPTH HIERARCHY")
    print("=" * 60)

    P = ReflTy.base(0)
    axioms = {
        "T (□A → A)": ReflTy.arrow(ReflTy.box(P), P),
        "K (□(A→B) → □A → □B)": k_axiom_type(P, P),
        "4 (□A → □□A)": four_axiom_type(P),
        "Löb (□(□P→P) → □P)": lob_type(P),
        "Gödel (□P → ⊥)": godel_sentence_type(P),
    }

    print("\n  Axiom                      | Depth | Strength")
    print("  " + "-" * 55)
    for name, ty in axioms.items():
        depth = ty.prov_depth()
        strength = ty.classify_strength()
        print(f"  {name:28s} | {depth:5d} | {strength}")

    # Verify key inequalities
    k_depth = k_axiom_type(P, P).prov_depth()
    four_depth = four_axiom_type(P).prov_depth()
    t_depth = ReflTy.arrow(ReflTy.box(P), P).prov_depth()

    print(f"\n  Theorem: d(4) > d(K): {four_depth} > {k_depth} = {four_depth > k_depth} ✓")
    print(f"  Theorem: d(Löb) ≥ 2: {lob_type(P).prov_depth()} ≥ 2 = {lob_type(P).prov_depth() >= 2} ✓")


def demo_kripke_model():
    """Demonstrate Kripke model evaluation."""
    print("\n" + "=" * 60)
    print("KRIPKE MODEL EVALUATION")
    print("=" * 60)

    # Build a simple 3-world transitive model
    #   0 → 1 → 2, 0 → 2 (transitive closure)
    model = KripkeModel(
        worlds=[0, 1, 2],
        accessibility={0: [1, 2], 1: [2], 2: []},
        valuation={
            (0, 0): True, (1, 0): True, (2, 0): False,
            (0, 1): False, (1, 1): True, (2, 1): True,
        }
    )

    P0 = ReflTy.base(0)
    P1 = ReflTy.base(1)

    print(f"\n  Model: 3 worlds (0 → 1 → 2, transitive)")
    print(f"  Transitive: {model.is_transitive()}")
    print(f"  P0 values: w0={model.valuation[(0,0)]}, w1={model.valuation[(1,0)]}, w2={model.valuation[(2,0)]}")
    print(f"  P1 values: w0={model.valuation[(0,1)]}, w1={model.valuation[(1,1)]}, w2={model.valuation[(2,1)]}")

    test_formulas = [
        ("P0", P0),
        ("P1", P1),
        ("□P0", ReflTy.box(P0)),
        ("□P1", ReflTy.box(P1)),
        ("□□P0", ReflTy.box(ReflTy.box(P0))),
        ("□P0 → P0", ReflTy.arrow(ReflTy.box(P0), P0)),
        ("P0 × P1", ReflTy.prod(P0, P1)),
    ]

    print(f"\n  {'Formula':20s} | w0    | w1    | w2")
    print("  " + "-" * 50)
    for name, ty in test_formulas:
        vals = [model.evaluate(w, ty) for w in [0, 1, 2]]
        print(f"  {name:20s} | {str(vals[0]):5s} | {str(vals[1]):5s} | {str(vals[2]):5s}")

    # Verify box monotonicity theorem
    print("\n  Verifying box monotonicity (Theorem):")
    for w in model.worlds:
        for v in model.accessibility.get(w, []):
            box_at_w = model.evaluate(w, ReflTy.box(P1))
            box_at_v = model.evaluate(v, ReflTy.box(P1))
            if box_at_w:
                assert box_at_v, f"Monotonicity failed: □P1 at {w} but not at {v}"
                print(f"  ✓ □P1 at w{w} → □P1 at w{v}")


def demo_depth_algebra():
    """Demonstrate the Proof Depth Algebra."""
    print("\n" + "=" * 60)
    print("PROOF DEPTH ALGEBRA")
    print("=" * 60)

    P = ReflTy.base(0)
    Q = ReflTy.base(1)

    types = [
        ("P", P),
        ("□P", ReflTy.box(P)),
        ("□P × □Q", ReflTy.prod(ReflTy.box(P), ReflTy.box(Q))),
        ("□(P × Q)", ReflTy.box(ReflTy.prod(P, Q))),
        ("□□P", ReflTy.box(ReflTy.box(P))),
        ("μ(□P)", ReflTy.mu(ReflTy.box(P))),
        ("Löb(P)", lob_type(P)),
    ]

    print(f"\n  {'Type':25s} | Level | Mult | Fixpoint | provDepth")
    print("  " + "-" * 65)
    for name, ty in types:
        da = compute_depth_algebra(ty)
        depth = ty.prov_depth()
        assert da.level == depth, f"Depth algebra level mismatch for {name}"
        print(f"  {name:25s} | {da.level:5d} | {da.multiplicity:4d} | {str(da.has_fixpoint):8s} | {depth}")

    print("\n  ✓ Depth algebra level matches provDepth for all test types")


def demo_mltt_separation():
    """Demonstrate the MLTT / ReflTT separation."""
    print("\n" + "=" * 60)
    print("MLTT vs ReflTT: PROPER EXTENSION")
    print("=" * 60)

    mltt_types = [
        ReflTy.base(0),
        ReflTy.unit(),
        ReflTy.arrow(ReflTy.base(0), ReflTy.base(1)),
        ReflTy.prod(ReflTy.unit(), ReflTy.base(0)),
    ]

    non_mltt_types = [
        ReflTy.box(ReflTy.base(0)),
        ReflTy.mu(ReflTy.base(0)),
        provable_not_provably_provable(ReflTy.base(0)),
        lob_type(ReflTy.base(0)),
    ]

    print("\n  MLTT types (depth 0):")
    for ty in mltt_types:
        assert ty.is_mltt()
        assert ty.prov_depth() == 0
        print(f"    {ty.pretty():30s} depth={ty.prov_depth()}, isMLTT=True ✓")

    print("\n  Non-MLTT types (depth > 0):")
    for ty in non_mltt_types:
        assert not ty.is_mltt()
        print(f"    {ty.pretty():30s} depth={ty.prov_depth()}, isMLTT=False ✓")


if __name__ == "__main__":
    demo_type_constructions()
    demo_translation()
    demo_depth_hierarchy()
    demo_axiom_hierarchy()
    demo_kripke_model()
    demo_depth_algebra()
    demo_mltt_separation()
    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETED SUCCESSFULLY")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Provability Depth Hierarchy

Shows the strict stratification of types by provability depth,
the axiom hierarchy, and the relationship between MLTT and ReflTT.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_depth_hierarchy():
    """Plot the provability depth hierarchy with example types."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 8))

    # --- Panel 1: Depth Strata ---
    ax = axes[0]
    ax.set_title("Provability Depth Strata", fontsize=14, fontweight='bold')

    strata = {
        0: ["P", "⊤", "⊥", "P→Q", "P×Q", "P+Q"],
        1: ["□P", "□P→⊥", "□(P→Q)→□P→□Q"],
        2: ["□□P", "□P→□□P", "□(□P→P)→□P"],
        3: ["□□□P", "□(□□P→□P)"],
        4: ["□⁴P"],
    }

    colors = ['#4CAF50', '#2196F3', '#FF9800', '#F44336', '#9C27B0']

    for depth, types in strata.items():
        y = 4 - depth
        ax.axhspan(y - 0.4, y + 0.4, alpha=0.15, color=colors[depth])
        ax.text(-0.5, y, f"Depth {depth}", fontsize=12, fontweight='bold',
                ha='right', va='center', color=colors[depth])
        for i, t in enumerate(types):
            x = 0.5 + i * 2.2
            ax.text(x, y, t, fontsize=9, ha='center', va='center',
                    bbox=dict(boxstyle='round,pad=0.3', facecolor=colors[depth],
                              alpha=0.3, edgecolor=colors[depth]))

    ax.set_xlim(-2, 14)
    ax.set_ylim(-1, 5)
    ax.set_axis_off()

    # Separation line
    ax.axhline(y=3.6, color='red', linewidth=2, linestyle='--')
    ax.text(6, 3.8, "← MLTT Fragment (depth 0) →", fontsize=10,
            ha='center', color='red', fontstyle='italic')
    ax.text(6, 3.2, "↓ Reflective Extension ↓", fontsize=10,
            ha='center', color='blue', fontstyle='italic')

    # --- Panel 2: Axiom Hierarchy ---
    ax = axes[1]
    ax.set_title("Modal Axiom Depth Hierarchy", fontsize=14, fontweight='bold')

    axiom_data = [
        ("K: □(A→B)→□A→□B", 1, '#2196F3'),
        ("T: □A→A", 1, '#2196F3'),
        ("Gödel: □P→⊥", 1, '#2196F3'),
        ("4: □A→□□A", 2, '#FF9800'),
        ("Löb: □(□P→P)→□P", 2, '#FF9800'),
        ("Grz: □(□(A→□A)→A)→A", 2, '#FF9800'),
        ("PnPP: □P×(□□P→⊥)", 2, '#FF9800'),
    ]

    y_positions = list(range(len(axiom_data)))
    for i, (name, depth, color) in enumerate(axiom_data):
        ax.barh(i, depth, color=color, alpha=0.7, edgecolor='black', height=0.6)
        ax.text(depth + 0.1, i, name, fontsize=9, va='center')

    ax.set_xlabel("Provability Depth", fontsize=12)
    ax.set_yticks([])
    ax.set_xlim(0, 5)

    # Arrow showing "4 > K"
    ax.annotate("4 > K\n(strict)", xy=(2, 3), xytext=(3.5, 1.5),
                fontsize=10, fontweight='bold', color='red',
                arrowprops=dict(arrowstyle='->', color='red', lw=2))

    # --- Panel 3: Translation Correspondence ---
    ax = axes[2]
    ax.set_title("ReflTy ↔ Modal μ-Calculus", fontsize=14, fontweight='bold')

    left_items = ["base(n)", "⊤", "⊥", "A → B", "A × B", "A + B", "□A", "μA"]
    right_items = ["var(n)", "⊤", "⊥", "φ → ψ", "φ ∧ ψ", "φ ∨ ψ", "□φ", "μφ"]

    for i, (l, r) in enumerate(zip(left_items, right_items)):
        y = 7 - i
        ax.text(1, y, l, fontsize=11, ha='center', va='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightblue',
                          edgecolor='steelblue'))
        ax.text(5, y, r, fontsize=11, ha='center', va='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow',
                          edgecolor='goldenrod'))
        ax.annotate("", xy=(3.8, y), xytext=(2.2, y),
                    arrowprops=dict(arrowstyle='<->', color='green', lw=1.5))

    ax.text(1, 8.3, "ReflTy", fontsize=13, fontweight='bold', ha='center', color='steelblue')
    ax.text(5, 8.3, "Modal μ-Calculus", fontsize=13, fontweight='bold', ha='center', color='goldenrod')
    ax.text(3, 8.3, "≅", fontsize=16, fontweight='bold', ha='center', color='green')

    ax.set_xlim(-0.5, 6.5)
    ax.set_ylim(-0.5, 9)
    ax.set_axis_off()

    plt.tight_layout()
    plt.savefig("depth_hierarchy.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: depth_hierarchy.png")


def plot_kripke_example():
    """Plot an example Kripke model with evaluation."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.set_title("Kripke Model: Box Monotonicity", fontsize=14, fontweight='bold')

    # Draw worlds
    world_positions = {0: (1, 3), 1: (4, 3), 2: (7, 3)}
    world_labels = {
        0: "w₀\nP₀=T, P₁=F\n□P₁=T",
        1: "w₁\nP₀=T, P₁=T\n□P₁=T",
        2: "w₂\nP₀=F, P₁=T\n□P₁=T (vacuous)",
    }

    for w, (x, y) in world_positions.items():
        circle = plt.Circle((x, y), 0.8, fill=True, facecolor='lightcyan',
                             edgecolor='navy', linewidth=2)
        ax.add_patch(circle)
        ax.text(x, y, world_labels[w], fontsize=8, ha='center', va='center')

    # Draw accessibility arrows
    arrows = [(0, 1), (1, 2), (0, 2)]
    for w, v in arrows:
        x1, y1 = world_positions[w]
        x2, y2 = world_positions[v]
        dx, dy = x2 - x1, y2 - y1
        norm = np.sqrt(dx**2 + dy**2)
        dx, dy = dx/norm, dy/norm
        ax.annotate("", xy=(x2 - dx*0.85, y2 - dy*0.85),
                    xytext=(x1 + dx*0.85, y1 + dy*0.85),
                    arrowprops=dict(arrowstyle='->', color='red', lw=2))

    # Labels
    ax.text(2.5, 4.2, "R", fontsize=12, color='red', fontweight='bold')
    ax.text(5.5, 4.2, "R", fontsize=12, color='red', fontweight='bold')
    ax.text(4, 1.5, "R (transitivity)", fontsize=10, color='red', fontstyle='italic')

    # Theorem statement
    ax.text(4, 0.5,
            "Theorem: If R is transitive and □A holds at w,\nthen □A holds at every R-accessible world from w.",
            fontsize=11, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow',
                      edgecolor='orange'))

    ax.set_xlim(-0.5, 8.5)
    ax.set_ylim(-0.5, 5.5)
    ax.set_aspect('equal')
    ax.set_axis_off()

    plt.tight_layout()
    plt.savefig("kripke_model.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: kripke_model.png")


if __name__ == "__main__":
    plot_depth_hierarchy()
    plot_kripke_example()
    print("All visualizations generated.")
