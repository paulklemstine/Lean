#!/usr/bin/env python3
"""
Transreal Arithmetic Demo: Interactive exploration of Anderson's number system.

Demonstrates key properties:
1. Total division (no undefined operations)
2. Nullity absorption
3. Ring axiom failures
4. Preserved algebraic structure
"""

from algorithms import Transreal, verify_ring_axiom_failure, find_distributivity_counterexample


def demo_total_division():
    """Show that division is total in transreal arithmetic."""
    print("=" * 60)
    print("DEMO 1: Total Division — No 'Undefined' Operations")
    print("=" * 60)

    cases = [
        (Transreal.real(6), Transreal.real(3), "6 / 3"),
        (Transreal.real(1), Transreal.real(0), "1 / 0"),
        (Transreal.real(-1), Transreal.real(0), "-1 / 0"),
        (Transreal.real(0), Transreal.real(0), "0 / 0"),
        (Transreal.pos_inf(), Transreal.pos_inf(), "+∞ / +∞"),
        (Transreal.pos_inf(), Transreal.real(0), "+∞ / 0"),
        (Transreal.nullity(), Transreal.real(5), "Φ / 5"),
    ]

    for a, b, label in cases:
        result = a / b
        print(f"  {label:12s} = {result}")


def demo_nullity_absorption():
    """Show that nullity absorbs all operations."""
    print("\n" + "=" * 60)
    print("DEMO 2: Nullity Absorption — The Arithmetic Black Hole")
    print("=" * 60)

    phi = Transreal.nullity()
    elems = [
        ("5", Transreal.real(5)),
        ("+∞", Transreal.pos_inf()),
        ("-∞", Transreal.neg_inf()),
        ("Φ", Transreal.nullity()),
    ]

    for name, x in elems:
        print(f"  Φ + {name:3s} = {phi + x}")
        print(f"  Φ × {name:3s} = {phi * x}")
        print(f"  Φ / {name:3s} = {phi / x}")
        print(f"  {name:3s} / Φ = {x / phi}")
        print()


def demo_indeterminate_forms():
    """Show how indeterminate forms produce nullity."""
    print("=" * 60)
    print("DEMO 3: Indeterminate Forms → Nullity")
    print("=" * 60)

    inf = Transreal.pos_inf()
    ninf = Transreal.neg_inf()
    zero = Transreal.real(0)

    forms = [
        ("+∞ + (-∞)", inf + ninf),
        ("+∞ × 0", inf * zero),
        ("0 / 0", zero / zero),
        ("+∞ / +∞", inf / inf),
        ("-∞ / -∞", ninf / ninf),
        ("+∞ / -∞", inf / ninf),
    ]

    for label, result in forms:
        print(f"  {label:12s} = {result}")


def demo_ring_axiom_test():
    """Systematic test of ring axioms."""
    print("\n" + "=" * 60)
    print("DEMO 4: Ring Axiom Test — What Survives?")
    print("=" * 60)

    results = verify_ring_axiom_failure()
    for axiom, holds in results.items():
        status = "✓ HOLDS" if holds else "✗ FAILS"
        print(f"  {axiom:40s} {status}")


def demo_distributivity_failure():
    """Detailed analysis of distributivity failure."""
    print("\n" + "=" * 60)
    print("DEMO 5: Distributivity Failure — The Core Obstruction")
    print("=" * 60)

    a = Transreal.pos_inf()
    b = Transreal.real(1)
    c = Transreal.neg_inf()

    print(f"  a = +∞, b = 1, c = -∞")
    print(f"  b + c = 1 + (-∞) = {b + c}")
    print(f"  a × (b + c) = +∞ × (-∞) = {a * (b + c)}")
    print(f"  a × b = +∞ × 1 = {a * b}")
    print(f"  a × c = +∞ × (-∞) = {a * c}")
    print(f"  a×b + a×c = +∞ + (-∞) = {a * b + a * c}")
    print(f"  LHS = {a * (b + c)}, RHS = {a * b + a * c}")
    print(f"  Equal? {a * (b + c) == a * b + a * c}")


def demo_negation_homomorphism():
    """Show that negation distributes over addition globally."""
    print("\n" + "=" * 60)
    print("DEMO 6: Negation Homomorphism — -(a+b) = (-a)+(-b)")
    print("=" * 60)

    elems = [Transreal.real(3), Transreal.real(-2), Transreal.pos_inf(),
             Transreal.neg_inf(), Transreal.nullity()]

    all_ok = True
    for a in elems:
        for b in elems:
            lhs = -(a + b)
            rhs = (-a) + (-b)
            if lhs != rhs:
                print(f"  FAIL: a={a}, b={b}: -(a+b)={lhs}, (-a)+(-b)={rhs}")
                all_ok = False

    if all_ok:
        print("  ✓ Negation distributes over addition for all tested elements!")


def demo_multiplication_table():
    """Display the full transreal multiplication table."""
    print("\n" + "=" * 60)
    print("DEMO 7: Multiplication Table")
    print("=" * 60)

    elems = [
        ("2", Transreal.real(2)),
        ("-1", Transreal.real(-1)),
        ("0", Transreal.real(0)),
        ("+∞", Transreal.pos_inf()),
        ("-∞", Transreal.neg_inf()),
        ("Φ", Transreal.nullity()),
    ]

    header = "    ×  |" + "|".join(f" {n:>5s} " for n, _ in elems)
    print(header)
    print("  " + "-" * len(header))

    for name_a, a in elems:
        row = f"  {name_a:>4s} |"
        for _, b in elems:
            result = a * b
            if result.kind.name == "REAL":
                row += f" {result.value:>5g} "
            elif result.kind.name == "POS_INF":
                row += "    +∞ "
            elif result.kind.name == "NEG_INF":
                row += "    -∞ "
            else:
                row += "     Φ "
            row += "|"
        print(row)


if __name__ == "__main__":
    demo_total_division()
    demo_nullity_absorption()
    demo_indeterminate_forms()
    demo_ring_axiom_test()
    demo_distributivity_failure()
    demo_negation_homomorphism()
    demo_multiplication_table()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization of transreal arithmetic operations as heatmaps.
Shows the multiplication and addition tables with color-coding by element type.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def transreal_add(a_kind, a_val, b_kind, b_val):
    """Compute a + b in transreal arithmetic. Returns (kind, value)."""
    if a_kind == 'N' or b_kind == 'N':
        return ('N', 0)
    if a_kind == 'R' and b_kind == 'R':
        return ('R', a_val + b_val)
    if a_kind == 'R':
        return (b_kind, 0)
    if b_kind == 'R':
        return (a_kind, 0)
    if a_kind == b_kind:
        return (a_kind, 0)
    return ('N', 0)


def transreal_mul(a_kind, a_val, b_kind, b_val):
    """Compute a * b in transreal arithmetic. Returns (kind, value)."""
    if a_kind == 'N' or b_kind == 'N':
        return ('N', 0)
    if a_kind == 'R' and b_kind == 'R':
        return ('R', a_val * b_val)

    def sign(x):
        if x > 0: return 1
        if x < 0: return -1
        return 0

    def inf_sign(k):
        return 1 if k == 'P' else -1

    def sign_mul(s, k):
        if s == 0:
            return ('N', 0)
        if k == 'P':
            return ('P', 0) if s > 0 else ('M', 0)
        else:
            return ('M', 0) if s > 0 else ('P', 0)

    if a_kind == 'R':
        return sign_mul(sign(a_val), b_kind)
    if b_kind == 'R':
        return sign_mul(sign(b_val), a_kind)

    s = inf_sign(a_kind) * inf_sign(b_kind)
    return ('P', 0) if s > 0 else ('M', 0)


def kind_to_color(kind):
    """Map element kind to color."""
    colors = {'R': '#4CAF50', 'P': '#2196F3', 'M': '#FF9800', 'N': '#F44336'}
    return colors.get(kind, '#999')


def kind_to_label(kind, val):
    """Map element kind to display label."""
    if kind == 'R':
        return f"{val:g}" if val != int(val) else f"{int(val)}"
    if kind == 'P':
        return '+∞'
    if kind == 'M':
        return '-∞'
    return 'Φ'


def create_operation_heatmap(op_func, op_name, elements, filename):
    """Create a heatmap for a transreal operation."""
    n = len(elements)
    fig, ax = plt.subplots(figsize=(8, 7))

    for i, (ak, av) in enumerate(elements):
        for j, (bk, bv) in enumerate(elements):
            rk, rv = op_func(ak, av, bk, bv)
            color = kind_to_color(rk)
            label = kind_to_label(rk, rv)

            rect = plt.Rectangle((j, n - 1 - i), 1, 1, facecolor=color, edgecolor='white', linewidth=2)
            ax.add_patch(rect)
            ax.text(j + 0.5, n - 0.5 - i, label, ha='center', va='center',
                    fontsize=11, fontweight='bold', color='white')

    labels = [kind_to_label(k, v) for k, v in elements]
    ax.set_xticks([x + 0.5 for x in range(n)])
    ax.set_xticklabels(labels, fontsize=12)
    ax.set_yticks([y + 0.5 for y in range(n)])
    ax.set_yticklabels(labels[::-1], fontsize=12)
    ax.set_xlim(0, n)
    ax.set_ylim(0, n)
    ax.set_title(f'Transreal {op_name} Table', fontsize=16, fontweight='bold', pad=15)
    ax.set_xlabel('Second operand', fontsize=12)
    ax.set_ylabel('First operand', fontsize=12)

    legend_patches = [
        mpatches.Patch(color='#4CAF50', label='Finite Real'),
        mpatches.Patch(color='#2196F3', label='+∞'),
        mpatches.Patch(color='#FF9800', label='-∞'),
        mpatches.Patch(color='#F44336', label='Φ (Nullity)'),
    ]
    ax.legend(handles=legend_patches, loc='upper left', bbox_to_anchor=(1.02, 1),
              fontsize=10, framealpha=0.9)

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved {filename}")


def create_distributivity_failure_plot(filename):
    """Visualize the distributivity failure landscape."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    reals = np.linspace(-3, 3, 50)
    elements = [('R', r) for r in reals] + [('P', 0), ('M', 0)]

    a_kind, a_val = 'P', 0  # a = +∞

    lhs_kinds = []
    rhs_kinds = []

    for bk, bv in [('R', r) for r in reals]:
        for ck, cv in [('R', r) for r in reals]:
            sum_bc = transreal_add(bk, bv, ck, cv)
            lhs = transreal_mul(a_kind, a_val, sum_bc[0], sum_bc[1])

            ab = transreal_mul(a_kind, a_val, bk, bv)
            ac = transreal_mul(a_kind, a_val, ck, cv)
            rhs = transreal_add(ab[0], ab[1], ac[0], ac[1])

            lhs_kinds.append(lhs[0])
            rhs_kinds.append(rhs[0])

    kind_map = {'R': 0, 'P': 1, 'M': 2, 'N': 3}
    lhs_grid = np.array([kind_map[k] for k in lhs_kinds]).reshape(50, 50)
    rhs_grid = np.array([kind_map[k] for k in rhs_kinds]).reshape(50, 50)

    cmap = plt.cm.colors.ListedColormap(['#4CAF50', '#2196F3', '#FF9800', '#F44336'])
    bounds = [-0.5, 0.5, 1.5, 2.5, 3.5]
    norm = plt.cm.colors.BoundaryNorm(bounds, cmap.N)

    im1 = axes[0].imshow(lhs_grid, cmap=cmap, norm=norm, extent=[-3, 3, -3, 3], origin='lower')
    axes[0].set_title('a · (b + c)\n(a = +∞)', fontsize=14, fontweight='bold')
    axes[0].set_xlabel('c (real)', fontsize=12)
    axes[0].set_ylabel('b (real)', fontsize=12)

    im2 = axes[1].imshow(rhs_grid, cmap=cmap, norm=norm, extent=[-3, 3, -3, 3], origin='lower')
    axes[1].set_title('a·b + a·c\n(a = +∞)', fontsize=14, fontweight='bold')
    axes[1].set_xlabel('c (real)', fontsize=12)
    axes[1].set_ylabel('b (real)', fontsize=12)

    legend_patches = [
        mpatches.Patch(color='#4CAF50', label='Finite Real'),
        mpatches.Patch(color='#2196F3', label='+∞'),
        mpatches.Patch(color='#FF9800', label='-∞'),
        mpatches.Patch(color='#F44336', label='Φ (Nullity)'),
    ]
    fig.legend(handles=legend_patches, loc='lower center', ncol=4, fontsize=11,
               bbox_to_anchor=(0.5, -0.02))

    fig.suptitle('Distributivity Failure: LHS vs RHS differ where colors disagree',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved {filename}")


if __name__ == "__main__":
    elements = [
        ('R', 2), ('R', 1), ('R', 0), ('R', -1), ('R', -2),
        ('P', 0), ('M', 0), ('N', 0)
    ]

    create_operation_heatmap(transreal_add, "Addition", elements, "transreal_addition.png")
    create_operation_heatmap(transreal_mul, "Multiplication", elements, "transreal_multiplication.png")
    create_distributivity_failure_plot("distributivity_failure.png")

    print("\nAll visualizations generated!")
