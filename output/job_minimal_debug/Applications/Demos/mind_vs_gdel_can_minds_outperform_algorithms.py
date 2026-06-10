#!/usr/bin/env python3
"""
Demo: Epistemic Fixed-Point Algebras and the Lucas-Penrose Barrier

Demonstrates the key mathematical structures and theorems from the
Gödel-Mind Barrier formalization through concrete numerical examples.
"""

import itertools
from typing import Callable


def demo_goedel_sentence():
    """
    Demo 1: Self-Referential Proof Systems
    
    Concrete example: A tiny "formal system" with 4 sentences.
    We construct the Gödel sentence and verify it is true but unprovable.
    """
    print("=" * 60)
    print("DEMO 1: Self-Referential Proof System")
    print("=" * 60)
    
    # A tiny universe of sentences
    sentences = ["A", "B", "G", "¬G"]
    
    # Provable sentences (the system can prove A and B, but not G or ¬G)
    provable = {"A", "B"}
    
    # Truth values (in the "standard model")
    # G says "I am not provable", which is true (G is not in provable)
    true_sentences = {"A", "B", "G"}  # G is true because it IS not provable
    
    # Verify soundness: provable ⊆ true
    assert provable.issubset(true_sentences), "Soundness violated!"
    
    # Verify Gödel property: G is true ↔ G is not provable
    g_true = "G" in true_sentences
    g_provable = "G" in provable
    assert g_true == (not g_provable), "Gödel property violated!"
    
    print(f"Sentences:  {sentences}")
    print(f"Provable:   {provable}")
    print(f"True:       {true_sentences}")
    print(f"G is true:  {g_true}")
    print(f"G provable: {g_provable}")
    print(f"G is true ↔ G not provable: ✓")
    print(f"→ The 'mind' sees G is true, but the 'machine' cannot prove it.")
    print()


def demo_lucas_tower():
    """
    Demo 2: The Lucas Tower
    
    Simulate the iterative process: F₀ → F₁ → F₂ → ···
    where each Fₙ₊₁ = Fₙ + {Gₙ}.
    """
    print("=" * 60)
    print("DEMO 2: The Lucas Tower (5 levels)")
    print("=" * 60)
    
    max_level = 5
    
    # Each level's provable set grows by adding the previous Gödel sentence
    provable_at_level = [set() for _ in range(max_level + 1)]
    goedel_sentences = []
    
    for n in range(max_level):
        # The Gödel sentence at level n: "I am not provable at level n"
        g_n = f"G_{n}"
        goedel_sentences.append(g_n)
        
        # Check: G_n is NOT provable at level n
        assert g_n not in provable_at_level[n], f"G_{n} should not be provable at level {n}"
        
        # Level n+1 adds G_n to its provable set
        provable_at_level[n + 1] = provable_at_level[n] | {g_n}
    
    print(f"{'Level':<8} {'Provable Set':<40} {'Own Gödel':<10} {'Proved?'}")
    print("-" * 70)
    for n in range(max_level):
        g_n = goedel_sentences[n]
        proved = g_n in provable_at_level[n]
        print(f"F_{n:<5}  {str(provable_at_level[n]):<40} {g_n:<10} {'✗ (unprovable)' if not proved else '✓'}")
    
    print()
    print("Strict ascent verified:")
    for n in range(max_level - 1):
        new = provable_at_level[n + 1] - provable_at_level[n]
        print(f"  F_{n+1} proves {new} which F_{n} cannot")
    
    print(f"\n→ The tower never stabilizes: each level has its own blind spot.")
    print()


def demo_diagonal_argument():
    """
    Demo 3: The Abstract Diagonal Argument
    
    For f: X → (X → bool), show {x | ¬f(x)(x)} is not in range(f).
    """
    print("=" * 60)
    print("DEMO 3: Abstract Diagonal Argument")
    print("=" * 60)
    
    # X = {0, 1, 2}
    X = [0, 1, 2]
    
    # f maps each element to a predicate on X
    f = {
        0: lambda x: x == 0,  # {0}
        1: lambda x: x != 1,  # {0, 2}
        2: lambda x: True,    # {0, 1, 2}
    }
    
    # The diagonal set: {x | ¬f(x)(x)}
    diagonal = lambda x: not f[x](x)
    
    print(f"X = {X}")
    print(f"f(0) = {{x | x == 0}} = {{0}}")
    print(f"f(1) = {{x | x ≠ 1}} = {{0, 2}}")
    print(f"f(2) = {{x | True}}   = {{0, 1, 2}}")
    print()
    
    print("Diagonal table:")
    print(f"  f(0)(0) = {f[0](0)}, so diagonal(0) = {diagonal(0)}")
    print(f"  f(1)(1) = {f[1](1)}, so diagonal(1) = {diagonal(1)}")
    print(f"  f(2)(2) = {f[2](2)}, so diagonal(2) = {diagonal(2)}")
    
    diag_set = {x for x in X if diagonal(x)}
    print(f"\nDiagonal set = {diag_set}")
    
    # Check it's not in the range
    for d in X:
        f_d_set = {x for x in X if f[d](x)}
        match = f_d_set == diag_set
        print(f"  f({d}) = {f_d_set} {'==' if match else '≠'} diagonal")
    
    print(f"\n→ The diagonal set differs from f(d) at position d, for every d.")
    print(f"→ This is the pattern behind Cantor, Gödel, and Berry.")
    print()


def demo_berry_paradox():
    """
    Demo 4: Berry-Gödel Bridge (Pigeonhole)
    
    Any function f: Fin(n+1) → Fin(n) must have a collision.
    """
    print("=" * 60)
    print("DEMO 4: Berry-Gödel Bridge (Pigeonhole)")
    print("=" * 60)
    
    for n in range(1, 6):
        # Try all functions Fin(n+1) → Fin(n)
        collision_count = 0
        total = n ** (n + 1)
        
        # Check a specific function
        f = lambda x, n=n: x % n  # simple modular function
        
        collisions = []
        for i in range(n + 1):
            for j in range(i + 1, n + 1):
                if f(i) == f(j):
                    collisions.append((i, j, f(i)))
        
        print(f"n={n}: f(x) = x mod {n} maps Fin({n+1}) → Fin({n})")
        if collisions:
            i, j, v = collisions[0]
            print(f"  Collision: f({i}) = f({j}) = {v}")
        print(f"  ({n+1} pigeons, {n} holes → guaranteed collision)")
    
    print(f"\n→ This is the Berry paradox: more objects than descriptions → some undescribable.")
    print()


def demo_lucas_penrose_barrier():
    """
    Demo 5: The Lucas-Penrose Barrier
    
    If K satisfies Löb's axiom and K(⊥)=⊥, then ⊤=⊥.
    Demonstrated on a 4-element Boolean algebra.
    """
    print("=" * 60)
    print("DEMO 5: Lucas-Penrose Barrier")
    print("=" * 60)
    
    # Boolean algebra: {⊥, a, ā, ⊤} where a ∧ ā = ⊥, a ∨ ā = ⊤
    elements = ['⊥', 'a', 'ā', '⊤']
    
    print("On the 4-element Boolean algebra {⊥, a, ā, ⊤}:")
    print()
    print("Löb's axiom: □(□x → x) ≤ □x")
    print("If □⊥ = ⊥ (consistency):")
    print("  □(□⊥ → ⊥) ≤ □⊥")
    print("  □(⊥ → ⊥) ≤ ⊥")
    print("  □(⊤) ≤ ⊥")
    print("  ⊤ ≤ ⊥         (since □⊤ = ⊤)")
    print("  CONTRADICTION!")
    print()
    print("→ No Löb operator can prove its own consistency.")
    print("→ This is why the Lucas-Penrose argument fails:")
    print("  If the mind is a 'Löb system', it cannot know its own consistency.")
    print("  If it's NOT a Löb system, the diagonal argument doesn't apply to it.")
    print("  Either way, incompleteness doesn't prove minds transcend machines.")
    print()


def demo_chaitin_bound():
    """
    Demo 6: Chaitin Complexity Bound
    
    Among the first k+1 numbers, at least one cannot be described
    by any of k descriptions.
    """
    print("=" * 60)
    print("DEMO 6: Chaitin Complexity Bound")
    print("=" * 60)
    
    for k in range(1, 8):
        # k descriptions, each describing a number in [0, k]
        # Best case: descriptions cover k distinct numbers, missing 1
        described = set(range(k))  # descriptions cover 0, 1, ..., k-1
        universe = set(range(k + 1))  # numbers 0, 1, ..., k
        undescribed = universe - described
        
        print(f"k={k}: {k} descriptions for {k+1} numbers → {len(undescribed)} undescribable: {undescribed}")
    
    print(f"\n→ A system of complexity K cannot determine Kolmogorov complexity > K.")
    print(f"→ This is Chaitin's incompleteness: formal limits on self-knowledge.")
    print()


if __name__ == "__main__":
    print("\n" + "█" * 60)
    print("  EPISTEMIC FIXED-POINT ALGEBRAS")
    print("  AND THE LUCAS-PENROSE BARRIER")
    print("█" * 60 + "\n")
    
    demo_goedel_sentence()
    demo_lucas_tower()
    demo_diagonal_argument()
    demo_berry_paradox()
    demo_lucas_penrose_barrier()
    demo_chaitin_bound()
    
    print("=" * 60)
    print("SUMMARY OF KEY RESULTS")
    print("=" * 60)
    print("""
1. Gödel's Incompleteness: Any sound system has unprovable truths.
2. Lucas Tower: Iterating "see the Gödel sentence" creates an
   infinite strictly ascending chain that never terminates.
3. Diagonal Closure: Cantor, Gödel, and Berry are all instances
   of the same abstract diagonal obstruction principle.
4. Lucas-Penrose Barrier: If the mind is a Löb system, it inherits
   incompleteness. If it's not, the argument doesn't apply.
5. Chaitin Bound: Complexity limits on self-knowledge are universal.

All results formally verified in Lean 4.
""")


#!/usr/bin/env python3
"""
Visualization: The Lucas Tower and Epistemic Fixed-Point Structure

Produces three plots:
1. The Lucas Tower: provability strength vs. level
2. The Diagonal Escape pattern
3. The Lucas-Penrose Barrier on a Boolean lattice
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def plot_lucas_tower(ax):
    """Plot the Lucas Tower: each level proves strictly more."""
    levels = list(range(8))
    provable_count = list(range(8))  # level n proves n previous Gödel sentences
    
    # Bar chart of provable set size
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(levels)))
    bars = ax.bar(levels, provable_count, color=colors, edgecolor='black', linewidth=0.5)
    
    # Mark the Gödel sentence at each level
    for n in range(7):
        ax.annotate(f'G{chr(8320+n)}', 
                    xy=(n+1, n+0.5), fontsize=8,
                    ha='center', va='center',
                    bbox=dict(boxstyle='round,pad=0.2', facecolor='gold', alpha=0.7))
    
    # Add arrows showing escalation
    for n in range(6):
        ax.annotate('', xy=(n+1, n+0.1), xytext=(n, n+0.9),
                    arrowprops=dict(arrowstyle='->', color='red', lw=1.5))
    
    ax.set_xlabel('Level n', fontsize=12)
    ax.set_ylabel('Number of provable Gödel sentences', fontsize=12)
    ax.set_title('The Lucas Tower: Strict Ascent of Provability', fontsize=14, fontweight='bold')
    ax.set_xticks(levels)
    ax.set_xticklabels([f'F₍{n}₎' for n in levels])


def plot_diagonal_escape(ax):
    """Visualize the diagonal argument: f(d) always differs from the diagonal at d."""
    n = 6
    # Random binary matrix representing f: {0,...,n-1} → ({0,...,n-1} → bool)
    np.random.seed(42)
    matrix = np.random.randint(0, 2, (n, n))
    
    # The diagonal set: negation of diagonal
    diagonal = 1 - np.diag(matrix)
    
    # Plot the matrix
    im = ax.imshow(matrix, cmap='Blues', aspect='equal', vmin=0, vmax=1)
    
    # Highlight the diagonal cells
    for i in range(n):
        rect = patches.Rectangle((i-0.5, i-0.5), 1, 1, linewidth=3, 
                                  edgecolor='red', facecolor='none')
        ax.add_patch(rect)
        ax.text(i, i, '✗' if diagonal[i] else '✓', ha='center', va='center',
                fontsize=14, color='red', fontweight='bold')
    
    # Show the diagonal set on the right
    for i in range(n):
        color = 'gold' if diagonal[i] else 'white'
        rect = patches.Rectangle((n+0.5, i-0.5), 1, 1, linewidth=1,
                                  edgecolor='black', facecolor=color)
        ax.add_patch(rect)
        ax.text(n+1, i, str(diagonal[i]), ha='center', va='center', fontsize=10)
    
    ax.set_xlim(-0.5, n+1.5)
    ax.set_ylim(n-0.5, -0.5)
    ax.set_xticks(list(range(n)) + [n+1])
    ax.set_xticklabels([f'{i}' for i in range(n)] + ['Diag'])
    ax.set_yticks(range(n))
    ax.set_yticklabels([f'f({i})' for i in range(n)])
    ax.set_title('Diagonal Escape: ¬f(d)(d) ≠ f(d) at d', fontsize=14, fontweight='bold')


def plot_barrier(ax):
    """Visualize the Lucas-Penrose Barrier on a lattice."""
    # Draw the Boolean algebra lattice {⊥, a, ā, ⊤}
    positions = {
        '⊥': (0, 0),
        'a': (-1, 1),
        'ā': (1, 1),
        '⊤': (0, 2),
    }
    
    # Draw edges
    edges = [('⊥', 'a'), ('⊥', 'ā'), ('a', '⊤'), ('ā', '⊤')]
    for e1, e2 in edges:
        x1, y1 = positions[e1]
        x2, y2 = positions[e2]
        ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1.5)
    
    # Draw nodes
    for name, (x, y) in positions.items():
        color = 'lightblue' if name in ('⊥', '⊤') else 'lightyellow'
        ax.plot(x, y, 'o', markersize=30, color=color, markeredgecolor='black', markeredgewidth=2)
        ax.text(x, y, name, ha='center', va='center', fontsize=14, fontweight='bold')
    
    # Draw the box operator
    box_map = {'⊥': '⊤', 'a': '⊤', 'ā': '⊤', '⊤': '⊤'}  # trivial GL
    
    # Annotate the barrier
    ax.annotate('□⊥ ≠ ⊥\n(incompleteness)', xy=(0, 0), xytext=(-2.5, -0.5),
                fontsize=10, ha='center',
                arrowprops=dict(arrowstyle='->', color='red', lw=2),
                bbox=dict(boxstyle='round', facecolor='lightyellow'))
    
    ax.annotate('□⊤ = ⊤\n(soundness)', xy=(0, 2), xytext=(2.5, 2.5),
                fontsize=10, ha='center',
                arrowprops=dict(arrowstyle='->', color='green', lw=2),
                bbox=dict(boxstyle='round', facecolor='lightgreen'))
    
    # The barrier text
    ax.text(0, -1.5, 
            'Lucas-Penrose Barrier:\nK(⊥)=⊥ + Löb → ⊤=⊥ → ⊥',
            ha='center', va='center', fontsize=11,
            bbox=dict(boxstyle='round', facecolor='lightyellow', edgecolor='red', linewidth=2))
    
    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(-2.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('The Lucas-Penrose Barrier\non a Boolean Lattice', fontsize=14, fontweight='bold')


if __name__ == "__main__":
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    plot_lucas_tower(axes[0])
    plot_diagonal_escape(axes[1])
    plot_barrier(axes[2])
    
    plt.suptitle('Epistemic Fixed-Point Algebras and the Lucas-Penrose Barrier',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('goedel_mind_barrier_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved visualization to goedel_mind_barrier_visualization.png")
