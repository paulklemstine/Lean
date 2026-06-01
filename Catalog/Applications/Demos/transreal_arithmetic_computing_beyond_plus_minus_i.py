#!/usr/bin/env python3
"""
Transreal Arithmetic Demo
==========================

Demonstrates the key properties of Anderson's transreal number system,
including ring axiom failures, nullity absorption, wheel identity behavior,
and the additive defect characterization.
"""

from algorithms import (
    Transreal, transreal_add, transreal_mul, transreal_div,
    nullity_pair_count, additive_defect, wheel_identity_check,
    classify_operation_table, nullity_fragility_index
)


def separator(title: str) -> None:
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


def demo_basic_arithmetic():
    separator("Basic Transreal Arithmetic")

    r1 = Transreal.of_real(3.0)
    r2 = Transreal.of_real(-2.0)
    inf = Transreal.pos_inf()
    ninf = Transreal.neg_inf()
    phi = Transreal.phi()

    print("Addition:")
    print(f"  3 + (-2) = {r1 + r2}")
    print(f"  3 + ∞ = {r1 + inf}")
    print(f"  3 + (-∞) = {r1 + ninf}")
    print(f"  ∞ + ∞ = {inf + inf}")
    print(f"  ∞ + (-∞) = {inf + ninf}  ← The key equation!")
    print(f"  Φ + 3 = {phi + r1}  ← Nullity absorption")

    print("\nMultiplication:")
    print(f"  3 × 2 = {Transreal.of_real(3.0) * Transreal.of_real(2.0)}")
    print(f"  3 × ∞ = {r1 * inf}")
    print(f"  (-2) × ∞ = {r2 * inf}")
    print(f"  0 × ∞ = {Transreal.of_real(0.0) * inf}  ← 0·∞ = Φ!")
    print(f"  ∞ × ∞ = {inf * inf}")
    print(f"  ∞ × (-∞) = {inf * ninf}")

    print("\nDivision:")
    print(f"  6 / 2 = {transreal_div(Transreal.of_real(6.0), Transreal.of_real(2.0))}")
    print(f"  1 / 0 = {transreal_div(Transreal.of_real(1.0), Transreal.of_real(0.0))}")
    print(f"  0 / 0 = {transreal_div(Transreal.of_real(0.0), Transreal.of_real(0.0))}  ← Φ!")
    print(f"  ∞ / ∞ = {transreal_div(inf, inf)}  ← Φ!")


def demo_ring_failures():
    separator("Ring Axiom Failures")

    inf = Transreal.pos_inf()
    ninf = Transreal.neg_inf()
    phi = Transreal.phi()
    zero = Transreal.of_real(0.0)
    one = Transreal.of_real(1.0)

    # Failure 1: No additive inverse for ∞
    print("1. No additive inverse for ∞:")
    for candidate in [ninf, zero, one, phi]:
        result = inf + candidate
        print(f"   ∞ + {candidate} = {result}  {'✗ ≠ 0' if result != zero else '= 0'}")

    # Failure 2: Distributivity fails
    print("\n2. Distributivity failure:")
    a, b, c = inf, one, Transreal.of_real(0.0)
    lhs = a * (b + c)
    rhs = a * b + a * c
    print(f"   ∞ × (1 + 0) = ∞ × 1 = {lhs}")
    print(f"   ∞ × 1 + ∞ × 0 = ∞ + Φ = {rhs}")
    print(f"   {lhs} ≠ {rhs}  ← Distributivity fails!")

    # Positive: Associativity HOLDS
    print("\n3. Associativity holds (surprising!):")
    tests = [
        (inf, ninf, inf),
        (inf, one, ninf),
        (one, inf, ninf),
    ]
    for a, b, c in tests:
        lhs = a + (b + c)
        rhs = (a + b) + c
        status = "✓" if lhs == rhs else "✗"
        print(f"   {a} + ({b} + {c}) = {lhs}, ({a} + {b}) + {c} = {rhs}  {status}")


def demo_additive_defect():
    separator("Additive Defect: x + (-x)")

    values = [
        Transreal.of_real(5.0),
        Transreal.of_real(-3.14),
        Transreal.of_real(0.0),
        Transreal.pos_inf(),
        Transreal.neg_inf(),
        Transreal.phi(),
    ]

    print("The additive defect x + (-x) = 0 iff x is finite:\n")
    for x in values:
        defect = additive_defect(x)
        is_zero = defect == Transreal.of_real(0.0)
        print(f"  x = {str(x):>15}  →  x + (-x) = {str(defect):>15}  {'= 0 ✓ (finite)' if is_zero else '≠ 0 ✗ (non-finite)'}")


def demo_wheel_identity():
    separator("Wheel Identity: x + 0·x = x")

    values = [
        Transreal.of_real(1.0),
        Transreal.of_real(-5.0),
        Transreal.of_real(0.0),
        Transreal.pos_inf(),
        Transreal.neg_inf(),
        Transreal.phi(),
    ]

    print("The wheel identity holds for finite values but fails for ∞:\n")
    zero = Transreal.of_real(0.0)
    for x in values:
        zero_x = zero * x
        result = x + zero_x
        holds = result == x
        print(f"  x = {str(x):>15}  →  0·x = {str(zero_x):>15}, x + 0·x = {str(result):>15}  {'✓ holds' if holds else '✗ FAILS'}")


def demo_nullity_fragility():
    separator("Nullity Fragility Analysis")

    test_sets = [
        ("Finite only", [Transreal.of_real(i) for i in range(1, 5)]),
        ("With +∞", [Transreal.of_real(1.0), Transreal.of_real(2.0), Transreal.pos_inf()]),
        ("With both ∞", [Transreal.of_real(1.0), Transreal.pos_inf(), Transreal.neg_inf()]),
        ("All special", [Transreal.pos_inf(), Transreal.neg_inf(), Transreal.phi()]),
        ("Full mix", [Transreal.of_real(1.0), Transreal.of_real(-1.0),
                       Transreal.pos_inf(), Transreal.neg_inf(), Transreal.phi()]),
    ]

    for name, vals in test_sets:
        nfrag = nullity_fragility_index(vals)
        npairs = nullity_pair_count(vals)
        total = len(vals) ** 2
        print(f"  {name:20s}: {npairs:2d}/{total:2d} nullity pairs, fragility = {nfrag:.3f}")


def demo_classification_table():
    separator("Operation Classification Table")

    vals = [
        Transreal.of_real(1.0),
        Transreal.of_real(-1.0),
        Transreal.of_real(0.0),
        Transreal.pos_inf(),
        Transreal.neg_inf(),
        Transreal.phi(),
    ]

    for op_name in ["add", "mul"]:
        counts = classify_operation_table(vals, op_name)
        total = sum(counts.values())
        print(f"\n  {op_name.upper()} results ({total} pairs):")
        for cls, count in counts.items():
            pct = 100 * count / total
            print(f"    {cls:15s}: {count:3d} ({pct:5.1f}%)")


def demo_nullity_cascade():
    separator("Nullity Absorption Cascade")

    values = [Transreal.of_real(1.0), Transreal.of_real(2.0),
              Transreal.of_real(3.0), Transreal.of_real(4.0)]
    phi = Transreal.phi()

    print("Normal sum: 0 + 1 + 2 + 3 + 4")
    acc = Transreal.of_real(0.0)
    for v in values:
        acc = acc + v
        print(f"  + {v} → {acc}")

    print(f"\nWith Φ injected after 2:")
    values_with_phi = [Transreal.of_real(1.0), Transreal.of_real(2.0),
                       phi, Transreal.of_real(3.0), Transreal.of_real(4.0)]
    acc = Transreal.of_real(0.0)
    for v in values_with_phi:
        acc = acc + v
        print(f"  + {v} → {acc}")
    print("  Once Φ enters, everything stays Φ!")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     TRANSREAL ARITHMETIC: Computing Beyond ±∞          ║")
    print("║     Anderson's System: ℝ ∪ {Φ, +∞, -∞}                ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_basic_arithmetic()
    demo_ring_failures()
    demo_additive_defect()
    demo_wheel_identity()
    demo_nullity_fragility()
    demo_classification_table()
    demo_nullity_cascade()

    separator("Summary")
    print("Key findings:")
    print("  • Transreal addition is commutative AND associative")
    print("  • Ring axioms fail: no additive inverses for ∞/Φ, distributivity breaks")
    print("  • Nullity (Φ) absorbs: once it appears, it never goes away")
    print("  • The additive defect x+(-x)=0 characterizes exactly the finite reals")
    print("  • The wheel identity x+0·x=x holds for finite but fails for infinite")
    print("  • Real analysis survives on the finite subalgebra")
    print()


#!/usr/bin/env python3
"""
Transreal Arithmetic Visualization
====================================

Generates heatmaps of transreal addition and multiplication tables,
showing the three-tier structure (finite, infinite, indeterminate).
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def classify_result(kind):
    if kind == "real":
        return 0  # finite
    elif kind in ("posInf", "negInf"):
        return 1  # infinite
    else:
        return 2  # indeterminate (nullity)


def transreal_add_classify(a_kind, b_kind):
    if a_kind == "nullity" or b_kind == "nullity":
        return 2
    if a_kind == "real" and b_kind == "real":
        return 0
    if a_kind == "real" or b_kind == "real":
        # finite + infinite = infinite
        return 1
    # Both infinite
    if a_kind == b_kind:
        return 1  # same sign
    return 2  # opposite signs → nullity


def transreal_mul_classify(a_kind, a_sign, b_kind, b_sign):
    if a_kind == "nullity" or b_kind == "nullity":
        return 2
    if a_kind == "real" and b_kind == "real":
        return 0
    # At least one infinite
    if a_sign == 0 or b_sign == 0:
        return 2  # 0 * ∞ = Φ
    return 1  # nonzero * ∞ = ∞


def main():
    labels = ["−2", "−1", "0", "1", "2", "+∞", "−∞", "Φ"]
    kinds = ["real", "real", "real", "real", "real", "posInf", "negInf", "nullity"]
    signs = [-1, -1, 0, 1, 1, 1, -1, 0]
    n = len(labels)

    # Build classification matrices
    add_matrix = np.zeros((n, n), dtype=int)
    mul_matrix = np.zeros((n, n), dtype=int)

    for i in range(n):
        for j in range(n):
            add_matrix[i, j] = transreal_add_classify(kinds[i], kinds[j])
            mul_matrix[i, j] = transreal_mul_classify(kinds[i], signs[i], kinds[j], signs[j])

    # Color map: finite=blue, infinite=orange, indeterminate=red
    cmap = mcolors.ListedColormap(['#3498db', '#e67e22', '#e74c3c'])
    bounds = [-0.5, 0.5, 1.5, 2.5]
    norm = mcolors.BoundaryNorm(bounds, cmap.N)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Addition table
    im1 = ax1.imshow(add_matrix, cmap=cmap, norm=norm)
    ax1.set_xticks(range(n))
    ax1.set_xticklabels(labels, fontsize=10)
    ax1.set_yticks(range(n))
    ax1.set_yticklabels(labels, fontsize=10)
    ax1.set_title("Transreal Addition Classification", fontsize=14, fontweight='bold')
    ax1.set_xlabel("b", fontsize=12)
    ax1.set_ylabel("a", fontsize=12)

    # Multiplication table
    im2 = ax2.imshow(mul_matrix, cmap=cmap, norm=norm)
    ax2.set_xticks(range(n))
    ax2.set_xticklabels(labels, fontsize=10)
    ax2.set_yticks(range(n))
    ax2.set_yticklabels(labels, fontsize=10)
    ax2.set_title("Transreal Multiplication Classification", fontsize=14, fontweight='bold')
    ax2.set_xlabel("b", fontsize=12)
    ax2.set_ylabel("a", fontsize=12)

    # Add grid lines
    for ax in [ax1, ax2]:
        ax.set_xticks(np.arange(-0.5, n, 1), minor=True)
        ax.set_yticks(np.arange(-0.5, n, 1), minor=True)
        ax.grid(which='minor', color='white', linewidth=2)
        ax.tick_params(which='minor', bottom=False, left=False)

    # Legend
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='#3498db', label='Finite (real)'),
        Patch(facecolor='#e67e22', label='Infinite (±∞)'),
        Patch(facecolor='#e74c3c', label='Indeterminate (Φ)'),
    ]
    fig.legend(handles=legend_elements, loc='lower center', ncol=3,
               fontsize=11, bbox_to_anchor=(0.5, 0.02))

    plt.tight_layout()
    plt.subplots_adjust(bottom=0.15)
    plt.savefig("transreal_classification.png", dpi=150, bbox_inches='tight')
    print("Saved: transreal_classification.png")
    plt.close()


if __name__ == "__main__":
    main()
