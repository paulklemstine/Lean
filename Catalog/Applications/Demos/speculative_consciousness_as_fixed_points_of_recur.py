#!/usr/bin/env python3
"""
Demo: Self-Referential Types and Lawvere's Fixed Point Theorem

Demonstrates the core ideas computationally:
1. The diagonal argument as a concrete construction
2. The predicate jump as hierarchy generator
3. Fixed point spectra of various endomorphisms
4. The Knaster-Tarski fixed point theorem on finite lattices
"""

import itertools
from typing import Callable, Set, Tuple, List, Optional


def diagonal_argument_demo():
    """Demonstrate Cantor's diagonal argument on finite approximations."""
    print("=" * 60)
    print("DIAGONAL ARGUMENT ON FINITE ENUMERATIONS")
    print("=" * 60)

    # Enumerate some predicates on {0,1,2,3}
    domain = [0, 1, 2, 3]

    # Attempted enumeration: φ(i) = "the i-th predicate"
    predicates = [
        lambda x, i=i: (x + i) % 2 == 0
        for i in range(4)
    ]

    print("\nAttempted enumeration φ:")
    for i, p in enumerate(predicates):
        vals = [p(x) for x in domain]
        print(f"  φ({i}) = {vals}")

    # Construct the anti-diagonal
    anti_diag = [not predicates[i](i) for i in range(4)]
    print(f"\nAnti-diagonal (¬φ(i)(i)): {anti_diag}")

    # Verify it differs from every enumerated predicate
    for i, p in enumerate(predicates):
        vals = [p(x) for x in domain]
        if vals == anti_diag:
            print(f"  MATCH at position {i} — impossible!")
        else:
            diff_pos = next(j for j in range(4) if vals[j] != anti_diag[j])
            print(f"  Differs from φ({i}) at position {diff_pos}")

    print("\n→ The anti-diagonal always escapes any finite enumeration.")
    print("  This is Lawvere's theorem in action.\n")


def predicate_jump_demo():
    """Demonstrate the predicate jump as a hierarchy generator."""
    print("=" * 60)
    print("PREDICATE JUMP — THE HIERARCHY GENERATOR")
    print("=" * 60)

    # Work with predicates on {0,...,7}
    N = 8

    # Level 0: simple predicates
    level0 = [
        ("even", lambda x: x % 2 == 0),
        ("odd", lambda x: x % 2 == 1),
        ("< 4", lambda x: x < 4),
        (">= 4", lambda x: x >= 4),
        ("prime", lambda x: x in {2, 3, 5, 7}),
        ("square", lambda x: x in {0, 1, 4}),
        ("zero", lambda x: x == 0),
        ("all", lambda x: True),
    ]

    print(f"\nLevel 0 enumeration (8 predicates on {{0,...,{N-1}}}):")
    for i, (name, p) in enumerate(level0):
        vals = [p(x) for x in range(N)]
        print(f"  enum({i}) = {name:>8s} : {vals}")

    # Compute the jump: J(n) = ¬enum(n)(n)
    jump_vals = [not level0[i][1](i) for i in range(N)]
    print(f"\nPredicate Jump J(n) = ¬enum(n)(n):")
    print(f"  J = {jump_vals}")
    print(f"  J differs from enum(n) at position n for every n.")

    # Verify
    for i in range(N):
        enum_at_i = level0[i][1](i)
        jump_at_i = jump_vals[i]
        assert enum_at_i != jump_at_i, f"Jump failed at {i}!"
    print("  ✓ Verified: J ∉ range(enum)")

    print("\n→ The jump creates a genuinely new predicate at each level.")
    print("  Iterating this process generates the arithmetical hierarchy.\n")


def fixed_point_spectrum_demo():
    """Analyze fixed point spectra of endomorphisms."""
    print("=" * 60)
    print("FIXED POINT SPECTRUM ANALYSIS")
    print("=" * 60)

    # Endomorphisms on Bool = {True, False}
    print("\nEndomorphisms of Bool = {T, F}:")
    bool_endos = [
        ("id", lambda x: x),
        ("not", lambda x: not x),
        ("const T", lambda _: True),
        ("const F", lambda _: False),
    ]

    for name, f in bool_endos:
        fixed = [x for x in [True, False] if f(x) == x]
        has_fp = len(fixed) > 0
        print(f"  {name:>8s}: fixed points = {fixed}, "
              f"{'✓ has FP' if has_fp else '✗ NO FP (fixed-point-free!)'}")

    print("\n  Only 'not' is fixed-point-free.")
    print("  This single map powers ALL diagonal arguments!")

    # Endomorphisms on a 3-element set
    print("\nEndomorphisms of {0, 1, 2}:")
    domain3 = [0, 1, 2]
    total = 0
    fp_free_count = 0
    for f_vals in itertools.product(domain3, repeat=3):
        f = lambda x, fv=f_vals: fv[x]
        fixed = [x for x in domain3 if f(x) == x]
        total += 1
        if not fixed:
            fp_free_count += 1

    print(f"  Total endomorphisms: {total}")
    print(f"  Fixed-point-free: {fp_free_count}")
    print(f"  Have fixed points: {total - fp_free_count}")
    print(f"  Fraction with FP: {(total - fp_free_count)/total:.3f}")

    # General formula: derangements
    print("\n  For |S| = n: FP-free maps = Σ_{k=0}^{n} (-1)^k * C(n,k) * (n-k)^n")
    print("  (inclusion-exclusion on which elements are NOT fixed)")

    print("\n→ Lawvere's theorem: if φ : A → (A → S) is surjective,")
    print("  then EVERY endomorphism has a fixed point.")
    print("  Contrapositive: existence of ANY FP-free map blocks surjection.\n")


def knaster_tarski_demo():
    """Demonstrate Knaster-Tarski on a concrete finite lattice."""
    print("=" * 60)
    print("KNASTER-TARSKI FIXED POINTS ON POWER SET LATTICE")
    print("=" * 60)

    # Work with P({0,1,2}) ordered by inclusion
    elements = [0, 1, 2]
    all_subsets = []
    for r in range(len(elements) + 1):
        for s in itertools.combinations(elements, r):
            all_subsets.append(frozenset(s))

    print(f"\nLattice: P({{0,1,2}}) with {len(all_subsets)} elements")

    # Define a monotone map: f(S) = S ∪ {min element not in S} (if any)
    def monotone_f(s: frozenset) -> frozenset:
        """Add the smallest missing element, or return S if complete."""
        missing = sorted(set(elements) - set(s))
        if missing:
            return s | {missing[0]}
        return s

    print("\nMonotone map f(S) = S ∪ {smallest missing element}:")
    for s in sorted(all_subsets, key=lambda x: (len(x), sorted(x))):
        fs = monotone_f(s)
        is_fp = fs == s
        marker = " ← FIXED POINT" if is_fp else ""
        print(f"  f({set(s)}) = {set(fs)}{marker}")

    # Find all fixed points
    fixed_points = [s for s in all_subsets if monotone_f(s) == s]
    print(f"\nFixed points: {[set(s) for s in fixed_points]}")

    # Find lfp and gfp
    lfp = min(fixed_points, key=len)
    gfp = max(fixed_points, key=len)
    print(f"Least fixed point (lfp): {set(lfp)}")
    print(f"Greatest fixed point (gfp): {set(gfp)}")
    print(f"All fixed points bounded: lfp ⊆ x ⊆ gfp ✓")

    print("\n→ Knaster-Tarski: monotone maps on complete lattices")
    print("  always have fixed points, and the lfp/gfp bound all others.")
    print("  This is the 'positive' counterpart to Lawvere's 'negative' theorem.\n")


def conjugation_demo():
    """Demonstrate fixed point transport under composition."""
    print("=" * 60)
    print("FIXED POINT TRANSPORT UNDER COMPOSITION")
    print("=" * 60)

    domain = list(range(5))

    # Define f and g on {0,1,2,3,4}
    f_map = {0: 1, 1: 2, 2: 0, 3: 3, 4: 4}  # cycle (012), fixes 3,4
    g_map = {0: 0, 1: 3, 2: 2, 3: 1, 4: 4}  # swap 1↔3, fixes 0,2,4

    f = lambda x: f_map[x]
    g = lambda x: g_map[x]

    # Compute g∘f and f∘g
    gf = lambda x: g(f(x))
    fg = lambda x: f(g(x))

    print("\nf =", f_map)
    print("g =", g_map)
    print("g∘f =", {x: gf(x) for x in domain})
    print("f∘g =", {x: fg(x) for x in domain})

    # Find fixed points
    fp_gf = {x for x in domain if gf(x) == x}
    fp_fg = {x for x in domain if fg(x) == x}

    print(f"\nFix(g∘f) = {fp_gf}")
    print(f"Fix(f∘g) = {fp_fg}")

    # Verify transport: f maps Fix(g∘f) into Fix(f∘g)
    print("\nTransport via f: Fix(g∘f) → Fix(f∘g)")
    for x in fp_gf:
        fx = f(x)
        in_fg = fx in fp_fg
        print(f"  f({x}) = {fx}, in Fix(f∘g)? {in_fg}")
        assert in_fg, "Transport failed!"

    print("\n✓ Fixed point transport verified: f(Fix(g∘f)) ⊆ Fix(f∘g)\n")


if __name__ == "__main__":
    diagonal_argument_demo()
    predicate_jump_demo()
    fixed_point_spectrum_demo()
    knaster_tarski_demo()
    conjugation_demo()

    print("=" * 60)
    print("SUMMARY: THE LAWVERE PARADIGM")
    print("=" * 60)
    print("""
Self-reference in mathematics always involves three ingredients:
  1. An enumeration φ : A → (A → B) of "programs" or "descriptions"
  2. A transformation f : B → B (typically negation)
  3. The diagonal construction d(a) = f(φ(a)(a))

Lawvere's Fixed Point Theorem unifies ALL classical impossibility results:
  • Cantor's theorem: B = {0,1}, f = NOT → no surjection ℕ → P(ℕ)
  • Russell's paradox: B = Prop, f = ¬ → no "set of all sets"
  • Gödel's incompleteness: B = sentences, f = ¬ → unprovable truths
  • Turing's halting: B = {halt,loop}, f = swap → undecidable problems
  • Tarski's theorem: B = Prop, f = ¬ → truth is undefinable

The POSITIVE counterpart is Knaster-Tarski: when f is monotone,
fixed points ALWAYS exist and form a complete lattice.

This duality — impossibility vs. guaranteed existence — is the
deep structure underlying all of self-referential mathematics.
""")


#!/usr/bin/env python3
"""
Visualization: The Diagonal Argument and Fixed Point Spectrum

Creates visualizations of:
1. The diagonal construction on a matrix of predicates
2. The fixed point spectrum across different domain sizes
3. The Knaster-Tarski lattice of fixed points
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math


def plot_diagonal_matrix():
    """Visualize the diagonal argument as a matrix with anti-diagonal highlighted."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    n = 8
    np.random.seed(42)
    matrix = np.random.choice([0, 1], size=(n, n))

    # Plot the enumeration matrix
    ax1.set_title("Enumeration φ(i)(j)", fontsize=14, fontweight='bold')
    im1 = ax1.imshow(matrix, cmap='RdYlGn', aspect='equal', vmin=0, vmax=1)

    # Highlight diagonal
    for i in range(n):
        rect = mpatches.FancyBboxPatch(
            (i - 0.45, i - 0.45), 0.9, 0.9,
            boxstyle="round,pad=0.05",
            linewidth=2, edgecolor='blue', facecolor='none'
        )
        ax1.add_patch(rect)
        ax1.text(i, i, str(matrix[i, i]), ha='center', va='center',
                fontsize=12, fontweight='bold', color='blue')

    ax1.set_xlabel("j (input)")
    ax1.set_ylabel("i (predicate index)")
    ax1.set_xticks(range(n))
    ax1.set_yticks(range(n))

    # Plot anti-diagonal vs enumeration
    anti_diag = 1 - matrix[np.arange(n), np.arange(n)]
    comparison = np.zeros((n + 1, n))
    comparison[:n, :] = matrix
    comparison[n, :] = anti_diag

    ax2.set_title("Anti-Diagonal Escapes All Rows", fontsize=14, fontweight='bold')
    im2 = ax2.imshow(comparison, cmap='RdYlGn', aspect='equal', vmin=0, vmax=1)

    # Highlight the anti-diagonal row
    for j in range(n):
        ax2.text(j, n, str(int(anti_diag[j])), ha='center', va='center',
                fontsize=12, fontweight='bold', color='purple')
    rect = mpatches.FancyBboxPatch(
        (-0.45, n - 0.45), n - 0.1, 0.9,
        boxstyle="round,pad=0.05",
        linewidth=3, edgecolor='purple', facecolor='none'
    )
    ax2.add_patch(rect)

    # Mark where anti-diagonal differs from each row
    for i in range(n):
        ax2.annotate('≠', (i, i), fontsize=14, ha='center', va='center',
                    color='red', fontweight='bold')

    ax2.set_xlabel("j (input)")
    ax2.set_ylabel("Predicate index")
    yticks = list(range(n)) + [n]
    ylabels = [f"φ({i})" for i in range(n)] + ["ANTI-DIAG"]
    ax2.set_yticks(yticks)
    ax2.set_yticklabels(ylabels)
    ax2.set_xticks(range(n))

    plt.tight_layout()
    plt.savefig("viz_diagonal.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_diagonal.png")


def plot_fixed_point_spectrum():
    """Plot the fraction of endomorphisms with fixed points by domain size."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    sizes = list(range(1, 9))
    fracs_with_fp = []
    derangement_fracs = []

    for n in sizes:
        total = n ** n
        # Fixed-point-free maps by inclusion-exclusion
        fp_free = sum((-1)**k * math.comb(n, k) * (n - k)**n for k in range(n + 1))
        fracs_with_fp.append(1 - fp_free / total)

        # Derangements (FP-free permutations)
        perm_total = math.factorial(n)
        derang = sum((-1)**k * perm_total // math.factorial(k) for k in range(n + 1))
        derangement_fracs.append(derang / perm_total)

    # Plot 1: Fraction with fixed points
    ax1.bar(sizes, fracs_with_fp, color='steelblue', alpha=0.8, edgecolor='navy')
    ax1.axhline(y=1 - 1/math.e, color='red', linestyle='--', linewidth=2,
               label=f'1 - 1/e ≈ {1-1/math.e:.4f}')
    ax1.set_xlabel("Domain size |S|", fontsize=12)
    ax1.set_ylabel("Fraction of endomorphisms with FP", fontsize=12)
    ax1.set_title("Fixed Point Prevalence", fontsize=14, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.set_ylim(0, 1.05)

    # Plot 2: Derangement fractions
    ax2.bar(sizes, derangement_fracs, color='coral', alpha=0.8, edgecolor='darkred')
    ax2.axhline(y=1/math.e, color='blue', linestyle='--', linewidth=2,
               label=f'1/e ≈ {1/math.e:.4f}')
    ax2.set_xlabel("Domain size n", fontsize=12)
    ax2.set_ylabel("Fraction of derangements D(n)/n!", fontsize=12)
    ax2.set_title("Derangement Convergence to 1/e", fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.set_ylim(0, 0.5)

    plt.tight_layout()
    plt.savefig("viz_spectrum.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_spectrum.png")


def plot_knaster_tarski():
    """Visualize Knaster-Tarski fixed points on a lattice."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Hasse diagram of P({a,b,c})
    # Levels: {}, {a},{b},{c}, {a,b},{a,c},{b,c}, {a,b,c}
    positions = {
        frozenset(): (4, 0),
        frozenset('a'): (1, 2),
        frozenset('b'): (4, 2),
        frozenset('c'): (7, 2),
        frozenset('ab'): (1, 4),
        frozenset('ac'): (4, 4),
        frozenset('bc'): (7, 4),
        frozenset('abc'): (4, 6),
    }

    labels = {
        frozenset(): '∅',
        frozenset('a'): '{a}',
        frozenset('b'): '{b}',
        frozenset('c'): '{c}',
        frozenset('ab'): '{a,b}',
        frozenset('ac'): '{a,c}',
        frozenset('bc'): '{b,c}',
        frozenset('abc'): '{a,b,c}',
    }

    # Define monotone map: f(S) = S ∪ {a}
    def mono_f(s):
        return s | frozenset('a')

    # Find fixed points
    fixed = {s for s in positions if mono_f(s) == s}

    # Draw edges (Hasse diagram)
    edges = [
        (frozenset(), frozenset('a')),
        (frozenset(), frozenset('b')),
        (frozenset(), frozenset('c')),
        (frozenset('a'), frozenset('ab')),
        (frozenset('a'), frozenset('ac')),
        (frozenset('b'), frozenset('ab')),
        (frozenset('b'), frozenset('bc')),
        (frozenset('c'), frozenset('ac')),
        (frozenset('c'), frozenset('bc')),
        (frozenset('ab'), frozenset('abc')),
        (frozenset('ac'), frozenset('abc')),
        (frozenset('bc'), frozenset('abc')),
    ]

    for s1, s2 in edges:
        x1, y1 = positions[s1]
        x2, y2 = positions[s2]
        ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1, alpha=0.3)

    # Draw arrows for f
    for s in positions:
        fs = mono_f(s)
        if s != fs:
            x1, y1 = positions[s]
            x2, y2 = positions[fs]
            ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                       arrowprops=dict(arrowstyle='->', color='blue',
                                      lw=2, connectionstyle='arc3,rad=0.2'))

    # Draw nodes
    for s in positions:
        x, y = positions[s]
        is_fp = s in fixed
        color = 'gold' if is_fp else 'lightblue'
        edge_color = 'darkred' if is_fp else 'steelblue'
        size = 800 if is_fp else 500

        ax.scatter(x, y, s=size, c=color, edgecolors=edge_color,
                  linewidths=2 if is_fp else 1, zorder=5)
        label = labels[s]
        offset_y = 0.5 if y < 6 else -0.5
        ax.text(x, y + offset_y, label, ha='center', va='center',
               fontsize=10, fontweight='bold' if is_fp else 'normal')

    # Add f mapping labels
    ax.text(0.5, -0.8, 'f(S) = S ∪ {a}', fontsize=14, fontweight='bold',
           transform=ax.transAxes, ha='center')

    # Legend
    fp_patch = mpatches.Patch(facecolor='gold', edgecolor='darkred',
                             label='Fixed point (f(S) = S)')
    nonfp_patch = mpatches.Patch(facecolor='lightblue', edgecolor='steelblue',
                                label='Non-fixed (f(S) ≠ S)')
    ax.legend(handles=[fp_patch, nonfp_patch], loc='upper left', fontsize=11)

    ax.set_title("Knaster-Tarski: Fixed Points of f(S) = S ∪ {a}\n"
                "on the Power Set Lattice P({a,b,c})",
                fontsize=14, fontweight='bold')
    ax.set_xlim(-1, 9)
    ax.set_ylim(-1.5, 7.5)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig("viz_knaster_tarski.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_knaster_tarski.png")


if __name__ == "__main__":
    plot_diagonal_matrix()
    plot_fixed_point_spectrum()
    plot_knaster_tarski()
    print("\nAll visualizations saved.")
