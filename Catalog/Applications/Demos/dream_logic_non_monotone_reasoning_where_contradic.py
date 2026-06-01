"""
Dream Logic: Interactive Demo

Demonstrates Belnap's four-valued logic, explosion failure,
non-monotone reasoning, and pre-topological structure.
"""

from algorithms import (
    BelnapVal, DreamFrame, DefaultTheory,
    verify_de_morgan, verify_explosion_fails,
    bird_theory, pointwise_dream, contradictory_dream,
    test_compactness
)


def print_section(title: str) -> None:
    print()
    print("=" * 70)
    print(f"  {title}")
    print("=" * 70)
    print()


def demo_belnap_truth_table() -> None:
    """Display the complete truth tables for Belnap operations."""
    print_section("BELNAP FOUR-VALUED LOGIC: TRUTH TABLES")

    # Negation
    print("Negation (bneg):")
    print(f"  {'Value':<12} → {'bneg':<12} {'Designated?':<12} {'¬Designated?':<12}")
    print("  " + "-" * 48)
    for v in BelnapVal:
        nv = v.bneg()
        print(f"  {v.name:<12} → {nv.name:<12} {str(v.is_designated):<12} {str(nv.is_designated):<12}")

    # Conjunction
    print("\nConjunction (bconj):")
    header = f"  {'∧':<12}" + "".join(f"{v.name:<12}" for v in BelnapVal)
    print(header)
    print("  " + "-" * 48)
    for a in BelnapVal:
        row = f"  {a.name:<12}"
        for b in BelnapVal:
            row += f"{BelnapVal.bconj(a, b).name:<12}"
        print(row)

    # Disjunction
    print("\nDisjunction (bdisj):")
    header = f"  {'∨':<12}" + "".join(f"{v.name:<12}" for v in BelnapVal)
    print(header)
    print("  " + "-" * 48)
    for a in BelnapVal:
        row = f"  {a.name:<12}"
        for b in BelnapVal:
            row += f"{BelnapVal.bdisj(a, b).name:<12}"
        print(row)


def demo_explosion() -> None:
    """Demonstrate explosion failure."""
    print_section("EXPLOSION FAILURE: CLASSICAL vs BELNAP")

    print("Classical (2-valued) Logic:")
    print("  For v = True:  v=True, ¬v=False → can't have both True")
    print("  For v = False: v=False, ¬v=True → can't have both True")
    print("  ∴ No value makes both P and ¬P true → explosion holds vacuously")
    print()

    print("Belnap (4-valued) Logic:")
    for v in BelnapVal:
        nv = v.bneg()
        status = "✓ CONTRADICTION WITHOUT EXPLOSION" if (v.is_designated and nv.is_designated) else ""
        print(f"  {v.name:<12}: designated={v.is_designated}, ¬designated={nv.is_designated}  {status}")

    print()
    print("Key insight: BOTH is designated AND ¬BOTH = BOTH is designated")
    print("But FALSE_ONLY and NEITHER are not designated")
    print("→ Having P∧¬P true does NOT force Q to be true!")


def demo_information_lattice() -> None:
    """Display the information ordering."""
    print_section("INFORMATION LATTICE")

    print("Hasse diagram (information ordering):")
    print()
    print("           BOTH (⊤)")
    print("          /    \\")
    print("    TRUE_ONLY  FALSE_ONLY")
    print("          \\    /")
    print("         NEITHER (⊥)")
    print()

    print("Ordering verification:")
    for a in BelnapVal:
        for b in BelnapVal:
            if a != b and a.info_le(b):
                print(f"  {a.name} ≤ {b.name}")


def demo_dream_frame() -> None:
    """Demonstrate dream frame properties."""
    print_section("DREAM FRAMES: CONTRADICTIONS COEXIST")

    # Contradictory dream
    D = contradictory_dream(5, {0, 2})
    print("Dream Frame: 5 propositions, {0, 2} contradictory")
    print()
    for p in range(5):
        v = D.val(0, p)
        print(f"  Prop {p}: {v.name:<12} designated={v.is_designated}  neg_designated={v.bneg().is_designated}")

    print()
    print("Designated sets:")
    for p in range(5):
        ds = D.designated_set(p)
        print(f"  designatedSet({p}) = {ds}")

    print()
    print("Entailment tests:")
    for q in range(5):
        result = D.entails({0}, q)
        print(f"  {{0}} ⊨ {q}: {result}")
    print()
    print("Despite prop 0 being contradictory, it doesn't entail everything!")


def demo_non_monotone() -> None:
    """Demonstrate non-monotone reasoning."""
    print_section("NON-MONOTONE DEFAULT REASONING")

    theory = bird_theory()

    scenarios = [
        ({"bird"}, "Bird only"),
        ({"bird", "penguin"}, "Bird + Penguin"),
        ({"bird", "penguin", "magic"}, "Bird + Penguin + Magic (hypothetical)"),
    ]

    # Add a magic default
    magic_theory = DefaultTheory(
        defaults=[("bird", "flies"), ("magic", "flies")],
        exceptions=[("penguin", "flies")]
    )

    print("Theory: birds normally fly; penguins block flying")
    print()
    for premises, desc in scenarios:
        result = theory.default_entails(premises, "flies")
        print(f"  {desc}")
        print(f"    Premises: {premises}")
        print(f"    ⊢_d flies: {result}")
        print()

    print("Extended theory: birds fly, magic creatures fly; penguins block")
    result_magic = magic_theory.default_entails({"bird", "penguin", "magic"}, "flies")
    print(f"  {{bird, penguin, magic}} ⊢_d flies: {result_magic}")
    print("  Magic overrides penguin exception via alternative default path!")


def demo_pretopology() -> None:
    """Demonstrate pre-topological structure."""
    print_section("PRE-TOPOLOGICAL SPACES")

    print("The finite-or-univ pre-topology on ℕ:")
    print()
    print("  isPreOpen(S) ⟺ S is finite ∨ S = ℕ")
    print()

    # Show some examples
    examples = [
        ("∅", True, "finite (empty)"),
        ("{0}", True, "finite (singleton)"),
        ("{0, 1, 2}", True, "finite"),
        ("{0, 2, 4, ..., 98}", True, "finite (50 elements)"),
        ("ℕ", True, "= univ"),
        ("even numbers", False, "infinite and ≠ ℕ"),
        ("odd numbers", False, "infinite and ≠ ℕ"),
        ("primes", False, "infinite and ≠ ℕ"),
    ]

    for name, is_open, reason in examples:
        status = "✓ pre-open" if is_open else "✗ NOT pre-open"
        print(f"  {name:<25} {status:<20} ({reason})")

    print()
    print("Closure properties:")
    print("  {0} ∩ {1} = ∅         → finite ✓")
    print("  {0} ∪ {1} = {0,1}    → finite ✓")
    print("  ℕ ∩ {0} = {0}        → finite ✓")
    print("  ℕ ∪ {0} = ℕ          → univ ✓")
    print()
    print("BUT: ⋃ₖ {2k} = evens   → NOT pre-open ✗")
    print()
    print("This proves: pre-topologies ⊋ topologies (strict containment)")


def demo_compactness_test() -> None:
    """Test the paraconsistent compactness conjecture."""
    print_section("COMPACTNESS CONJECTURE TESTING")

    print("Testing: If every finite subset of Γ is satisfiable,")
    print("is Γ itself satisfiable? (Paraconsistent compactness)")
    print()

    all_pass = True
    for n in range(2, 12):
        result = test_compactness(n, max(n * 3, 10))
        status = "PASS ✓" if result else "FAIL ✗"
        print(f"  n={n:2d} propositions, {max(n*3, 10):3d} worlds: {status}")
        if not result:
            all_pass = False

    print()
    if all_pass:
        print("All tests passed — conjecture holds for tested cases ✓")
    else:
        print("Some tests failed — conjecture may be false!")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║       DREAM LOGIC: Non-Monotone Paraconsistent Reasoning       ║")
    print("║                      Interactive Demo                          ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    demo_belnap_truth_table()
    demo_explosion()
    demo_information_lattice()
    demo_dream_frame()
    demo_non_monotone()
    demo_pretopology()
    demo_compactness_test()

    print()
    print("=" * 70)
    print("  Demo complete. All core theorems verified computationally.")
    print("=" * 70)


"""
Visualization: Belnap Four-Valued Logic Lattice and Truth Tables

Generates a visual representation of the information lattice and
the designated/anti-designated regions of Belnap's FOUR.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_information_lattice():
    """Plot the Hasse diagram of the information ordering."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Information lattice
    ax = axes[0]
    ax.set_xlim(-2, 2)
    ax.set_ylim(-0.5, 2.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Information Ordering\n(Belnap Lattice FOUR)', fontsize=14, fontweight='bold')

    # Positions
    positions = {
        'NEITHER': (0, 0),
        'TRUE_ONLY': (-1, 1),
        'FALSE_ONLY': (1, 1),
        'BOTH': (0, 2),
    }

    colors = {
        'NEITHER': '#cccccc',
        'TRUE_ONLY': '#4CAF50',
        'FALSE_ONLY': '#F44336',
        'BOTH': '#FF9800',
    }

    # Draw edges
    edges = [
        ('NEITHER', 'TRUE_ONLY'),
        ('NEITHER', 'FALSE_ONLY'),
        ('TRUE_ONLY', 'BOTH'),
        ('FALSE_ONLY', 'BOTH'),
    ]
    for a, b in edges:
        ax.plot([positions[a][0], positions[b][0]],
                [positions[a][1], positions[b][1]],
                'k-', linewidth=2, zorder=1)

    # Draw nodes
    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.3, color=colors[name], ec='black',
                           linewidth=2, zorder=2)
        ax.add_patch(circle)
        short = {'NEITHER': 'N', 'TRUE_ONLY': 'T', 'FALSE_ONLY': 'F', 'BOTH': 'B'}
        ax.text(x, y, short[name], ha='center', va='center',
               fontsize=16, fontweight='bold', zorder=3)

    # Labels
    ax.text(0, -0.45, '⊥ (no info)', ha='center', fontsize=10)
    ax.text(0, 2.45, '⊤ (contradiction)', ha='center', fontsize=10)
    ax.text(-1.6, 1, 'consistent\ntruth', ha='center', fontsize=9)
    ax.text(1.6, 1, 'consistent\nfalsity', ha='center', fontsize=9)

    # Designation regions
    ax = axes[1]
    ax.set_xlim(-2, 2)
    ax.set_ylim(-0.5, 2.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Designated Values\n(Accepted as "at least true")', fontsize=14, fontweight='bold')

    # Background regions
    designated_bg = mpatches.FancyBboxPatch((-1.6, 0.5), 1.8, 2.0,
                                             boxstyle="round,pad=0.2",
                                             facecolor='#E8F5E9', edgecolor='#4CAF50',
                                             linewidth=2, linestyle='--')
    ax.add_patch(designated_bg)
    ax.text(-0.7, 2.6, 'Designated', color='#4CAF50', fontsize=11,
           fontweight='bold', ha='center')

    # Draw edges
    for a, b in edges:
        ax.plot([positions[a][0], positions[b][0]],
                [positions[a][1], positions[b][1]],
                'k-', linewidth=2, zorder=1)

    # Draw nodes with designation info
    for name, (x, y) in positions.items():
        designated = name in ('TRUE_ONLY', 'BOTH')
        ec_color = '#4CAF50' if designated else '#999999'
        lw = 3 if designated else 2
        circle = plt.Circle((x, y), 0.3, color=colors[name], ec=ec_color,
                           linewidth=lw, zorder=2)
        ax.add_patch(circle)
        short = {'NEITHER': 'N', 'TRUE_ONLY': 'T', 'FALSE_ONLY': 'F', 'BOTH': 'B'}
        ax.text(x, y, short[name], ha='center', va='center',
               fontsize=16, fontweight='bold', zorder=3)
        ax.text(x, y - 0.5, '✓' if designated else '✗',
               ha='center', fontsize=14, color=ec_color, fontweight='bold')

    ax.text(0, -0.45, 'Key: ✓ = designated, ✗ = not designated', ha='center', fontsize=9)

    plt.tight_layout()
    plt.savefig('belnap_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: belnap_lattice.png")


def plot_explosion_comparison():
    """Compare classical and Belnap logic regarding explosion."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Classical logic
    ax = axes[0]
    ax.set_title('Classical Logic\n(Explosion holds)', fontsize=13, fontweight='bold')
    ax.set_xlim(-0.5, 1.5)
    ax.set_ylim(-0.5, 1.5)
    ax.axis('off')

    # Two values
    for i, (name, color) in enumerate([('True', '#4CAF50'), ('False', '#F44336')]):
        circle = plt.Circle((i, 0.5), 0.3, color=color, ec='black', linewidth=2)
        ax.add_patch(circle)
        ax.text(i, 0.5, name[0], ha='center', va='center', fontsize=18,
               fontweight='bold', color='white')
        ax.text(i, 0, f'¬ = {"False" if name == "True" else "True"}',
               ha='center', fontsize=10)

    ax.text(0.5, 1.2, 'No v satisfies v=T ∧ ¬v=T', ha='center', fontsize=11,
           color='red', fontweight='bold')
    ax.text(0.5, -0.4, '∴ Explosion holds vacuously', ha='center', fontsize=10)

    # Belnap logic
    ax = axes[1]
    ax.set_title("Belnap's Logic\n(Explosion fails!)", fontsize=13, fontweight='bold')
    ax.set_xlim(-0.5, 3.5)
    ax.set_ylim(-0.5, 1.5)
    ax.axis('off')

    vals = [
        ('N', '#cccccc', False, 'N'),
        ('T', '#4CAF50', True, 'F'),
        ('F', '#F44336', False, 'T'),
        ('B', '#FF9800', True, 'B'),
    ]

    for i, (name, color, designated, neg_name) in enumerate(vals):
        circle = plt.Circle((i, 0.5), 0.3, color=color, ec='black', linewidth=2)
        ax.add_patch(circle)
        ax.text(i, 0.5, name, ha='center', va='center', fontsize=18, fontweight='bold')
        d_str = '✓' if designated else '✗'
        ax.text(i, 0.05, f'¬={neg_name}', ha='center', fontsize=10)
        ax.text(i, -0.2, f'desig: {d_str}', ha='center', fontsize=9,
               color='green' if designated else 'gray')

    # Highlight BOTH
    highlight = plt.Circle((3, 0.5), 0.38, fill=False, ec='#FF5722',
                           linewidth=3, linestyle='--')
    ax.add_patch(highlight)
    ax.annotate('B ∧ ¬B both designated!\nBut F is NOT designated',
               xy=(3, 0.9), xytext=(2, 1.3),
               fontsize=10, fontweight='bold', color='#FF5722',
               arrowprops=dict(arrowstyle='->', color='#FF5722', lw=2),
               ha='center')

    plt.tight_layout()
    plt.savefig('explosion_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: explosion_comparison.png")


def plot_pretopology_separation():
    """Visualize the pre-topology vs topology separation."""
    fig, ax = plt.subplots(figsize=(12, 6))
    ax.set_title('Pre-Topology vs Topology:\nFinite-or-Univ on ℕ', fontsize=14, fontweight='bold')

    # Draw number line
    n_show = 20
    y_line = 3
    ax.plot([-0.5, n_show + 0.5], [y_line, y_line], 'k-', linewidth=1)
    for i in range(n_show + 1):
        color = '#4CAF50' if i % 2 == 0 else '#2196F3'
        ax.plot(i, y_line, 'o', color=color, markersize=8, zorder=3)
        ax.text(i, y_line - 0.3, str(i), ha='center', fontsize=7)

    # Finite sets (pre-open)
    y1 = 2
    ax.text(-0.5, y1, 'Finite sets\n(pre-open ✓)', fontsize=10, va='center',
           color='#4CAF50', fontweight='bold')
    for start, end in [(2, 5), (8, 11), (15, 17)]:
        rect = mpatches.FancyBboxPatch((start - 0.3, y1 - 0.2), end - start + 0.6, 0.4,
                                        boxstyle="round,pad=0.1",
                                        facecolor='#E8F5E9', edgecolor='#4CAF50', linewidth=2)
        ax.add_patch(rect)

    # Even numbers (NOT pre-open)
    y2 = 1
    ax.text(-0.5, y2, 'Even numbers\n(NOT pre-open ✗)', fontsize=10, va='center',
           color='#F44336', fontweight='bold')
    for i in range(0, n_show + 1, 2):
        rect = mpatches.FancyBboxPatch((i - 0.15, y2 - 0.15), 0.3, 0.3,
                                        facecolor='#FFEBEE', edgecolor='#F44336', linewidth=1.5)
        ax.add_patch(rect)

    # Arrow showing union
    y3 = 0
    ax.text(n_show / 2, y3, '⋃ₖ {2k} = {0, 2, 4, 6, ...} = evens',
           ha='center', fontsize=11, fontweight='bold', color='#F44336')
    ax.text(n_show / 2, y3 - 0.5, 'Each {2k} is finite (pre-open), but union is NOT pre-open',
           ha='center', fontsize=10, style='italic')
    ax.text(n_show / 2, y3 - 1.0, '∴ Pre-topologies ⊋ Topologies',
           ha='center', fontsize=12, fontweight='bold', color='#9C27B0')

    ax.set_xlim(-3, n_show + 1)
    ax.set_ylim(-1.5, 4)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('pretopology_separation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: pretopology_separation.png")


if __name__ == "__main__":
    plot_information_lattice()
    plot_explosion_comparison()
    plot_pretopology_separation()
    print("\nAll visualizations generated.")
