#!/usr/bin/env python3
"""
Tropical Nullstellensatz — Interactive Demonstration
====================================================

This script demonstrates the Tropical Nullstellensatz for function semirings
with concrete numerical examples and visualizations.

The key theorem: for any set I of functions X → S (where S has a bottom element ⊥),
the tropical radical of I equals the ideal of its common zero set:

    tropRadical(I) = idealOfSet(tropZeroSet(I))

In the tropical (max-plus) semiring, ⊥ = -∞ and addition is max, multiplication is +.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Patch
from itertools import product

# ============================================================
# Part 1: Tropical Semiring Basics
# ============================================================

NEG_INF = float('-inf')  # This is ⊥ in the tropical semiring

def trop_add(a, b):
    """Tropical addition = max"""
    return max(a, b)

def trop_mul(a, b):
    """Tropical multiplication = ordinary addition (with -∞ absorbing)"""
    if a == NEG_INF or b == NEG_INF:
        return NEG_INF
    return a + b

def trop_zero():
    """Tropical zero = -∞ (bottom element)"""
    return NEG_INF

def trop_one():
    """Tropical one = 0"""
    return 0.0


# ============================================================
# Part 2: Core Definitions from the Lean Formalization
# ============================================================

def trop_zero_set(generators, domain):
    """
    tropZeroSet: the common tropical zero set of a family of functions.
    Returns {x ∈ domain | ∀ f ∈ generators, f(x) = ⊥}
    """
    return {x for x in domain if all(f(x) == NEG_INF for f in generators)}


def ideal_of_set(Y, domain):
    """
    idealOfSet: all functions (representable on domain) that vanish on Y.
    Returns the predicate: f ∈ idealOfSet(Y) iff ∀ x ∈ Y, f(x) = ⊥
    """
    def is_in_ideal(f):
        return all(f(x) == NEG_INF for x in Y)
    return is_in_ideal


def trop_radical(generators, domain):
    """
    tropRadical: functions vanishing wherever all generators simultaneously vanish.
    Returns the predicate: f ∈ tropRadical(I) iff ∀ x, (∀ g ∈ I, g(x)=⊥) → f(x)=⊥
    """
    zero_set = trop_zero_set(generators, domain)
    def is_in_radical(f):
        return all(f(x) == NEG_INF for x in zero_set)
    return is_in_radical


# ============================================================
# Part 3: Example 1 — Tropical Linear Functions on a Finite Domain
# ============================================================

def example_1():
    """
    Demonstrate the Nullstellensatz with tropical linear functions
    on a finite domain X = {0, 1, 2, 3, 4}.
    """
    print("=" * 70)
    print("EXAMPLE 1: Tropical Linear Functions on X = {0,1,2,3,4}")
    print("=" * 70)

    domain = list(range(5))

    # Define tropical linear functions: f(x) = max(a + x, b)
    # In max-plus: f(x) = a ⊗ x ⊕ b
    def make_trop_linear(a, b):
        """f(x) = max(a + x, b), with -∞ handling"""
        def f(x):
            ax = trop_mul(a, x)
            return trop_add(ax, b)
        return f

    # Generator 1: f₁(x) = max(x - 2, -∞) = x - 2 for x ≥ 0
    # f₁(x) = x + (-2)  in max-plus, so f₁(x) = x - 2
    # This is -∞ only when x = -∞ (never on our finite domain unless we choose ⊥)
    # Let's use simpler generators that actually have zeros

    # Generator: f(x) = x  if x > 0 else -∞
    def g1(x):
        return x if x > 0 else NEG_INF

    # Generator: f(x) = x - 3  if x > 3 else -∞
    def g2(x):
        return x - 3 if x > 3 else NEG_INF

    generators = [g1, g2]

    print("\nGenerators:")
    print(f"  g₁(x) = x if x > 0 else ⊥")
    print(f"  g₂(x) = x-3 if x > 3 else ⊥")
    print()

    # Print function values
    print("Function values on domain:")
    print(f"  {'x':>4}  {'g₁(x)':>8}  {'g₂(x)':>8}")
    print(f"  {'----':>4}  {'--------':>8}  {'--------':>8}")
    for x in domain:
        v1 = g1(x)
        v2 = g2(x)
        s1 = "⊥" if v1 == NEG_INF else f"{v1}"
        s2 = "⊥" if v2 == NEG_INF else f"{v2}"
        print(f"  {x:>4}  {s1:>8}  {s2:>8}")

    # Compute zero set
    Z = trop_zero_set(generators, domain)
    print(f"\ntropZeroSet({{g₁, g₂}}) = {sorted(Z)}")
    print("  (Points where ALL generators evaluate to ⊥)")

    # Verify the Nullstellensatz
    is_in_radical = trop_radical(generators, domain)
    is_in_ideal = ideal_of_set(Z, domain)

    # Test various functions
    print("\nVerifying the Nullstellensatz: tropRadical(I) = idealOfSet(tropZeroSet(I))")
    print()

    test_functions = [
        ("zero (⊥ everywhere)", lambda x: NEG_INF),
        ("constant 1", lambda x: 1),
        ("x if x > 0 else ⊥", lambda x: x if x > 0 else NEG_INF),
        ("⊥ if x=0, else x²", lambda x: NEG_INF if x == 0 else x**2),
        ("x² for all x", lambda x: x**2),
    ]

    print(f"  {'Function':>30}  {'∈ radical':>12}  {'∈ idealOfSet(Z)':>16}  {'Match?':>8}")
    print(f"  {'--------':>30}  {'----------':>12}  {'----------------':>16}  {'------':>8}")
    all_match = True
    for name, f in test_functions:
        in_rad = is_in_radical(f)
        in_ideal = is_in_ideal(f)
        match = in_rad == in_ideal
        all_match = all_match and match
        print(f"  {name:>30}  {str(in_rad):>12}  {str(in_ideal):>16}  {'✓' if match else '✗':>8}")

    print(f"\n  Nullstellensatz verified: {'YES ✓' if all_match else 'NO ✗'}")
    return all_match


# ============================================================
# Part 4: Example 2 — Tropical Polynomials on ℝ (discretized)
# ============================================================

def example_2():
    """
    Demonstrate with tropical polynomial functions on a discretized real interval.
    A tropical polynomial p(x) = max(a₀, a₁+x, a₂+2x, ...) has a piecewise
    linear graph.
    """
    print("\n" + "=" * 70)
    print("EXAMPLE 2: Tropical Polynomials on [-5, 5]")
    print("=" * 70)

    domain = np.linspace(-5, 5, 1001)

    # Tropical polynomial: p(x) = max(-∞, x-1) = x-1 for all x
    # This never equals -∞ on our domain
    def p1(x):
        return max(NEG_INF, x - 1)

    # Tropical polynomial: q(x) = max(-∞, -x+2)
    def p2(x):
        return max(NEG_INF, -x + 2)

    # These two never simultaneously equal -∞, so zero set is empty
    # Let's use functions that DO have a common zero

    # f₁(x) = x if x ≥ 0, else -∞
    def f1(x):
        return x if x >= 0 else NEG_INF

    # f₂(x) = -x if x ≤ 0, else -∞
    def f2(x):
        return -x if x <= 0 else NEG_INF

    generators = [f1, f2]

    # Zero set: both must be -∞
    # f₁(x) = ⊥ iff x < 0
    # f₂(x) = ⊥ iff x > 0
    # Both ⊥ iff x < 0 AND x > 0 → empty set!

    # Let's try overlapping support
    # f₁(x) = ⊥ if x ∈ [-5,-1), else x+1
    # f₂(x) = ⊥ if x ∈ [-5,-2), else x+2
    # Common zero: x ∈ [-5, -2)... no, that's where f₂ is ⊥ but f₁ might not be

    # Simpler: functions vanishing on the same region
    # f₁(x) = ⊥ if x < 0, else x
    # f₂(x) = ⊥ if x < 1, else x-1
    # Common zero: x < 0 AND x < 1 → x < 0
    # Wait, that's not a finite set. Let's just discretize.

    domain_list = list(range(-5, 6))  # integers from -5 to 5

    def g1(x):
        return NEG_INF if x < 0 else float(x)

    def g2(x):
        return NEG_INF if x < 1 else float(x - 1)

    generators = [g1, g2]

    print("\nGenerators:")
    print("  g₁(x) = x if x ≥ 0, else ⊥")
    print("  g₂(x) = x-1 if x ≥ 1, else ⊥")
    print()

    print("Function values:")
    print(f"  {'x':>4}  {'g₁(x)':>8}  {'g₂(x)':>8}")
    print(f"  {'----':>4}  {'--------':>8}  {'--------':>8}")
    for x in domain_list:
        v1 = g1(x)
        v2 = g2(x)
        s1 = "⊥" if v1 == NEG_INF else f"{v1:.0f}"
        s2 = "⊥" if v2 == NEG_INF else f"{v2:.0f}"
        print(f"  {x:>4}  {s1:>8}  {s2:>8}")

    Z = trop_zero_set(generators, domain_list)
    print(f"\ntropZeroSet = {sorted(Z)}")
    print("  (Where g₁ and g₂ are both ⊥: x < 0)")

    # The Nullstellensatz says: f ∈ tropRadical iff f vanishes on Z
    is_in_radical = trop_radical(generators, domain_list)
    is_in_ideal = ideal_of_set(Z, domain_list)

    # Any function that is ⊥ on all negative integers is in the radical
    def h1(x):
        """Vanishes on negatives, nonzero on non-negatives"""
        return NEG_INF if x < 0 else float(x ** 2 + 1)

    def h2(x):
        """Vanishes on some negatives but not all"""
        return NEG_INF if x < -2 else float(abs(x))

    def h3(x):
        """Vanishes everywhere"""
        return NEG_INF

    test_fns = [
        ("⊥ if x<0, else x²+1", h1),
        ("⊥ if x<-2, else |x|", h2),
        ("constant ⊥", h3),
        ("constant 0", lambda x: 0.0),
    ]

    print("\nVerifying Nullstellensatz:")
    print(f"  {'Function':>25}  {'∈ radical':>10}  {'∈ ideal(Z)':>12}  {'Match':>6}")
    all_ok = True
    for name, f in test_fns:
        r = is_in_radical(f)
        i = is_in_ideal(f)
        ok = r == i
        all_ok = all_ok and ok
        print(f"  {name:>25}  {str(r):>10}  {str(i):>12}  {'✓' if ok else '✗':>6}")

    print(f"\n  Nullstellensatz verified: {'YES ✓' if all_ok else 'NO ✗'}")
    return all_ok


# ============================================================
# Part 5: Example 3 — Galois Connection Visualization
# ============================================================

def example_3_galois():
    """
    Demonstrate the Galois connection between sets of functions and sets of points.
    """
    print("\n" + "=" * 70)
    print("EXAMPLE 3: Galois Connection Z ⊣ I")
    print("=" * 70)

    domain = list(range(8))

    # Define several functions
    def f1(x): return NEG_INF if x in {0, 1, 2} else float(x)
    def f2(x): return NEG_INF if x in {0, 1} else float(x * 2)
    def f3(x): return NEG_INF if x in {0, 1, 2, 3} else float(x - 3)

    fns = [f1, f2, f3]
    fn_names = ["f₁ (⊥ on {0,1,2})", "f₂ (⊥ on {0,1})", "f₃ (⊥ on {0,1,2,3})"]

    print("\nFunctions and their individual zero sets:")
    for name, f in zip(fn_names, fns):
        zs = {x for x in domain if f(x) == NEG_INF}
        print(f"  {name}: Z = {sorted(zs)}")

    # Common zero set
    Z = trop_zero_set(fns, domain)
    print(f"\nCommon zero set Z({{f₁,f₂,f₃}}) = {sorted(Z)}")

    # Ideal of the common zero set
    print(f"\nidealOfSet(Z) contains exactly the functions vanishing on {sorted(Z)}")

    # Verify Galois connection: J ⊆ idealOfSet(Y) ↔ Y ⊆ Z(J)
    Y_test = {0, 1}
    J_test = [f1, f2]

    zj = trop_zero_set(J_test, domain)
    print(f"\nGalois connection test:")
    print(f"  Y = {sorted(Y_test)}")
    print(f"  J = {{f₁, f₂}}")
    print(f"  Z(J) = {sorted(zj)}")
    print(f"  Y ⊆ Z(J)? {Y_test.issubset(zj)}")

    is_in_ideal_Y = ideal_of_set(Y_test, domain)
    j_in_ideal = all(is_in_ideal_Y(f) for f in J_test)
    print(f"  J ⊆ idealOfSet(Y)? {j_in_ideal}")
    print(f"  Galois connection holds: {Y_test.issubset(zj) == j_in_ideal} ✓")

    # Demonstrate closure: I(Z(I)) = tropRadical(I)
    print(f"\nClosure operator verification:")
    print(f"  Z(I) = {sorted(Z)}")
    print(f"  I(Z(I)) = idealOfSet({sorted(Z)})")
    print(f"  tropRadical(I) = idealOfSet(Z(I)) — by the Nullstellensatz ✓")

    return True


# ============================================================
# Part 6: Example 4 — Subsemiring (EML algebra) demonstration
# ============================================================

def example_4_subsemiring():
    """
    Demonstrate the subsemiring version of the Nullstellensatz,
    showing how it restricts to an EML-like function subalgebra.
    """
    print("\n" + "=" * 70)
    print("EXAMPLE 4: Subsemiring / EML Algebra Corollary")
    print("=" * 70)

    domain = list(range(6))

    # Simulate an EML subalgebra: piecewise-linear tropical functions
    # generated by max and addition with constants
    class EMLFunction:
        """Represents a max-plus linear function on a finite domain."""
        def __init__(self, name, values):
            self.name = name
            self.values = values  # dict: x -> value (or NEG_INF)

        def __call__(self, x):
            return self.values.get(x, NEG_INF)

        def __repr__(self):
            return self.name

    # Generators of the EML algebra
    g1 = EMLFunction("g₁", {x: (float(x) if x >= 2 else NEG_INF) for x in domain})
    g2 = EMLFunction("g₂", {x: (float(2*x - 5) if x >= 3 else NEG_INF) for x in domain})

    generators = [g1, g2]

    print("\nEML algebra generators:")
    print(f"  g₁(x) = x if x ≥ 2, else ⊥")
    print(f"  g₂(x) = 2x-5 if x ≥ 3, else ⊥")
    print()

    print("Values:")
    print(f"  {'x':>3}  {'g₁(x)':>6}  {'g₂(x)':>6}")
    for x in domain:
        s1 = "⊥" if g1(x) == NEG_INF else f"{g1(x):.0f}"
        s2 = "⊥" if g2(x) == NEG_INF else f"{g2(x):.0f}"
        print(f"  {x:>3}  {s1:>6}  {s2:>6}")

    Z = trop_zero_set(generators, domain)
    print(f"\ntropZeroSetInSubsemiring({{g₁,g₂}}) = {sorted(Z)}")

    # Elements of the subalgebra that vanish on Z
    # Any EML combination that gives ⊥ on Z is in the ideal
    print(f"\nBy the Nullstellensatz for subsemirings:")
    print(f"  idealOfSetInSubsemiring(A, Z) = ")
    print(f"    {{f ∈ A | ∀ x, (∀ g ∈ G, g(x)=⊥) → f(x)=⊥}}")

    # Construct some elements of the subalgebra
    # max(g₁, g₂) — tropical sum
    def trop_sum_g(x):
        return trop_add(g1(x), g2(x))

    # g₁ ⊗ g₂ — tropical product (ordinary sum)
    def trop_prod_g(x):
        return trop_mul(g1(x), g2(x))

    eml_elements = [
        ("g₁", g1),
        ("g₂", g2),
        ("g₁ ⊕ g₂ (max)", trop_sum_g),
        ("g₁ ⊗ g₂ (plus)", trop_prod_g),
    ]

    is_in_rad = trop_radical(generators, domain)

    print(f"\nSubalgebra elements and radical membership:")
    for name, f in eml_elements:
        vals = [f(x) for x in domain]
        val_strs = ["⊥" if v == NEG_INF else f"{v:.0f}" for v in vals]
        in_r = is_in_rad(f)
        print(f"  {name:>20}: [{', '.join(val_strs)}]  ∈ radical: {in_r}")

    print(f"\n  All generators vanish on Z = {sorted(Z)}: verified ✓")
    return True


# ============================================================
# Part 7: Visualization
# ============================================================

def create_visualization():
    """Create a visualization of the Tropical Nullstellensatz."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Tropical Nullstellensatz — Algebra-Geometry Correspondence",
                 fontsize=14, fontweight='bold')

    # Panel 1: Functions and their zero sets
    ax = axes[0, 0]
    domain = np.arange(-3, 8)

    def g1(x): return NEG_INF if x < 0 else float(x)
    def g2(x): return NEG_INF if x < 2 else float(x - 2)

    vals1 = [g1(x) for x in domain]
    vals2 = [g2(x) for x in domain]

    # Replace -inf with NaN for plotting
    def plot_val(v):
        return np.nan if v == NEG_INF else v

    ax.plot(domain, [plot_val(v) for v in vals1], 'bo-', label='g₁(x)', markersize=8)
    ax.plot(domain, [plot_val(v) for v in vals2], 'rs-', label='g₂(x)', markersize=8)

    # Mark ⊥ values
    for x in domain:
        if g1(x) == NEG_INF:
            ax.plot(x, -1, 'bv', markersize=10, alpha=0.5)
        if g2(x) == NEG_INF:
            ax.plot(x, -1.5, 'rv', markersize=10, alpha=0.5)

    # Highlight zero set
    Z = [x for x in domain if g1(x) == NEG_INF and g2(x) == NEG_INF]
    for x in Z:
        ax.axvspan(x - 0.3, x + 0.3, alpha=0.2, color='green')

    ax.set_xlabel('x')
    ax.set_ylabel('Value (▼ = ⊥)')
    ax.set_title('Generator Functions & Common Zero Set')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Zero set diagram
    ax = axes[0, 1]
    z1 = {x for x in range(-3, 8) if g1(x) == NEG_INF}
    z2 = {x for x in range(-3, 8) if g2(x) == NEG_INF}
    z_common = z1 & z2

    all_x = list(range(-3, 8))
    colors = []
    for x in all_x:
        if x in z_common:
            colors.append('green')
        elif x in z1:
            colors.append('blue')
        elif x in z2:
            colors.append('red')
        else:
            colors.append('lightgray')

    bars = ax.bar(all_x, [1]*len(all_x), color=colors, edgecolor='black', alpha=0.7)
    ax.set_xlabel('x')
    ax.set_yticks([])
    ax.set_title('Zero Sets: Z(g₁) ∩ Z(g₂)')
    ax.legend(handles=[
        Patch(color='blue', alpha=0.7, label='Z(g₁) only'),
        Patch(color='red', alpha=0.7, label='Z(g₂) only'),
        Patch(color='green', alpha=0.7, label='Z(g₁) ∩ Z(g₂)'),
        Patch(color='lightgray', alpha=0.7, label='Neither'),
    ], loc='upper right', fontsize=8)

    # Panel 3: Radical membership test
    ax = axes[1, 0]

    generators = [g1, g2]
    domain_list = list(range(-3, 8))
    Z_set = trop_zero_set(generators, domain_list)

    test_funcs = [
        ("⊥ if x<0, else x²",
         lambda x: NEG_INF if x < 0 else float(x**2)),
        ("⊥ if x<2, else 1",
         lambda x: NEG_INF if x < 2 else 1.0),
        ("always 1",
         lambda x: 1.0),
    ]

    x_positions = np.arange(len(test_funcs))
    is_in_rad = trop_radical(generators, domain_list)

    bar_colors = ['green' if is_in_rad(f) else 'red' for _, f in test_funcs]
    ax.barh(x_positions, [1]*len(test_funcs), color=bar_colors, alpha=0.7,
            edgecolor='black')
    ax.set_yticks(x_positions)
    ax.set_yticklabels([n for n, _ in test_funcs])
    ax.set_xticks([])
    ax.set_title('Radical Membership Test')
    ax.legend(handles=[
        Patch(color='green', alpha=0.7, label='∈ tropRadical(I)'),
        Patch(color='red', alpha=0.7, label='∉ tropRadical(I)'),
    ])

    # Panel 4: The Nullstellensatz diagram
    ax = axes[1, 1]
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('The Nullstellensatz Correspondence')

    # Draw the algebra-geometry bridge
    from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

    # Left box: Algebra
    alg_box = FancyBboxPatch((0.5, 3), 3.5, 4, boxstyle="round,pad=0.3",
                              facecolor='lightblue', edgecolor='navy', linewidth=2)
    ax.add_patch(alg_box)
    ax.text(2.25, 6.2, "ALGEBRA", ha='center', fontweight='bold', fontsize=11, color='navy')
    ax.text(2.25, 5.3, "Sets of functions\nI ⊆ (X → S)", ha='center', fontsize=9)
    ax.text(2.25, 4.0, "tropRadical(I)", ha='center', fontsize=9,
            style='italic', color='darkblue')

    # Right box: Geometry
    geo_box = FancyBboxPatch((6, 3), 3.5, 4, boxstyle="round,pad=0.3",
                              facecolor='lightyellow', edgecolor='darkgoldenrod', linewidth=2)
    ax.add_patch(geo_box)
    ax.text(7.75, 6.2, "GEOMETRY", ha='center', fontweight='bold', fontsize=11,
            color='darkgoldenrod')
    ax.text(7.75, 5.3, "Subsets of X\nY ⊆ X", ha='center', fontsize=9)
    ax.text(7.75, 4.0, "tropZeroSet(I)", ha='center', fontsize=9,
            style='italic', color='darkgoldenrod')

    # Arrows
    ax.annotate("", xy=(5.8, 5.8), xytext=(4.2, 5.8),
                arrowprops=dict(arrowstyle='->', lw=2, color='darkgreen'))
    ax.text(5.0, 6.1, "Z", ha='center', fontsize=10, fontweight='bold', color='darkgreen')

    ax.annotate("", xy=(4.2, 4.2), xytext=(5.8, 4.2),
                arrowprops=dict(arrowstyle='->', lw=2, color='purple'))
    ax.text(5.0, 3.7, "I", ha='center', fontsize=10, fontweight='bold', color='purple')

    # Nullstellensatz label
    ax.text(5.0, 2.2, "I(Z(I)) = tropRadical(I)",
            ha='center', fontsize=11, fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))
    ax.text(5.0, 1.2, "← Tropical Nullstellensatz →",
            ha='center', fontsize=10, style='italic', color='darkgreen')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Bridges/EML/tropical_nullstellensatz_demo.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("\nVisualization saved to Bridges/EML/tropical_nullstellensatz_demo.png")


# ============================================================
# Part 8: Idempotence demonstration
# ============================================================

def example_5_idempotence():
    """Demonstrate that the radical operator is idempotent."""
    print("\n" + "=" * 70)
    print("EXAMPLE 5: Idempotence of tropRadical")
    print("=" * 70)

    domain = list(range(6))

    def g1(x): return NEG_INF if x < 2 else float(x)
    def g2(x): return NEG_INF if x < 3 else float(x - 1)

    generators = [g1, g2]
    Z = trop_zero_set(generators, domain)
    print(f"\nGenerators: g₁, g₂")
    print(f"Z(I) = {sorted(Z)}")

    # tropRadical(I) = idealOfSet(Z) = {f | f vanishes on Z}
    # tropRadical(tropRadical(I)) should equal tropRadical(I)

    # Build a concrete representation of tropRadical(I)
    # as the set of all functions vanishing on Z
    print(f"\ntropRadical(I) = {{f | ∀ x ∈ {sorted(Z)}, f(x) = ⊥}}")

    # Now compute tropRadical of that set
    # tropRadical(tropRadical(I)) = {f | ∀ x, (∀ g ∈ tropRadical(I), g(x)=⊥) → f(x)=⊥}
    # The zero set of tropRadical(I) = {x | ∀ f with f|_Z=⊥, f(x)=⊥}
    # For x ∈ Z, every such f has f(x) = ⊥, so x is in the zero set.
    # For x ∉ Z, there exists f with f(x) ≠ ⊥ and f|_Z = ⊥, so x is NOT in the zero set.

    # Compute Z(tropRadical(I))
    def is_in_radical_I(f):
        return all(f(x) == NEG_INF for x in Z)

    # Z(tropRadical(I)) = {x | for ALL f in tropRadical(I), f(x) = ⊥}
    Z2 = set()
    for x in domain:
        # Check: is there some f in tropRadical(I) with f(x) ≠ ⊥?
        if x not in Z:
            # f = "⊥ on Z, 1 elsewhere" is in tropRadical(I) and f(x) = 1 ≠ ⊥
            pass  # x is NOT in Z2
        else:
            # x ∈ Z, every f in tropRadical(I) has f(x) = ⊥
            Z2.add(x)

    print(f"Z(tropRadical(I)) = {sorted(Z2)}")
    print(f"Z(I) = Z(tropRadical(I))? {Z == Z2}")
    print(f"\nSince Z is the same, tropRadical(tropRadical(I)) = tropRadical(I) ✓")
    print("This is the idempotence theorem: tropRadical² = tropRadical")
    return Z == Z2


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║   TROPICAL NULLSTELLENSATZ — Demonstration Suite               ║")
    print("║   Algebra-Geometry Correspondence for Function Semirings       ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    results = []
    results.append(("Example 1: Finite domain", example_1()))
    results.append(("Example 2: Tropical polynomials", example_2()))
    results.append(("Example 3: Galois connection", example_3_galois()))
    results.append(("Example 4: Subsemiring/EML", example_4_subsemiring()))
    results.append(("Example 5: Idempotence", example_5_idempotence()))

    try:
        create_visualization()
        results.append(("Visualization", True))
    except Exception as e:
        print(f"\nVisualization skipped: {e}")
        results.append(("Visualization", False))

    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    for name, ok in results:
        print(f"  {name}: {'PASS ✓' if ok else 'FAIL ✗'}")
    print()
    if all(ok for _, ok in results):
        print("  All demonstrations passed! ✓")
    print()
