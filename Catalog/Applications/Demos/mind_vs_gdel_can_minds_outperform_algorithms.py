#!/usr/bin/env python3
"""
Reflective Proof Towers and the Penrose Diagonal Limiter
=========================================================

Demonstrates the key concepts from the formalization:
1. The Reflective Tower hierarchy
2. The Penrose Diagonal construction
3. Lawvere's Fixed Point Theorem
4. The Berry-Chaitin complexity bound
"""

from typing import Callable, Set, FrozenSet, Optional
from dataclasses import dataclass


# ============================================================
# Demo 1: Reflective Tower Simulation
# ============================================================

def demo_reflective_tower():
    """Simulate a reflective tower over natural numbers as 'sentences'.

    We model PA-like systems where:
    - Level 0 proves basic arithmetic (sentences 0..99)
    - Level n+1 proves everything level n proves + Con(level n)
    - Con(n) is represented by the number 100 + n
    """
    print("=" * 60)
    print("DEMO 1: Reflective Tower Simulation")
    print("=" * 60)

    base_sentences = set(range(100))  # PA proves sentences 0..99

    def provable(n: int) -> set:
        """Return the set of sentences provable at level n."""
        s = set(base_sentences)
        for k in range(n):
            s.add(100 + k)  # Add Con(k) for k < n
        return s

    def con(n: int) -> int:
        """The consistency sentence for level n."""
        return 100 + n

    # Verify tower properties
    for n in range(5):
        level_n = provable(n)
        level_n1 = provable(n + 1)
        c = con(n)

        assert level_n.issubset(level_n1), f"Monotonicity fails at level {n}"
        assert c not in level_n, f"Gödel's second fails at level {n}"
        assert c in level_n1, f"Reflection fails at level {n}"
        assert level_n != level_n1, f"Strict ascending fails at level {n}"

        print(f"Level {n}: |provable| = {len(level_n)}, "
              f"Con({n}) = {c}, "
              f"Con({n}) ∈ level({n})? {c in level_n}, "
              f"Con({n}) ∈ level({n+1})? {c in level_n1}")

    # Tower limit
    limit = set()
    for n in range(100):
        limit |= provable(n)
    print(f"\nTower limit (100 levels): |limit| = {len(limit)}")
    print(f"Limit ≠ any finite level: "
          f"{all(provable(n) != limit for n in range(100))}")

    # Incompleteness gaps
    print("\nIncompleteness gaps:")
    for n in range(5):
        gap = provable(n + 1) - provable(n)
        print(f"  gap({n}) = provable({n+1}) \\ provable({n}) = {gap}")

    print()


# ============================================================
# Demo 2: Penrose Diagonal Limiter
# ============================================================

def demo_penrose_diagonal():
    """Demonstrate the Penrose Diagonal Limiter.

    We show that for ANY Gödel oracle G, there exists a theory T
    where G(T) ∈ T — the oracle fails.
    """
    print("=" * 60)
    print("DEMO 2: Penrose Diagonal Limiter")
    print("=" * 60)

    # Define several "Gödel oracles" — functions from theories to sentences
    def oracle_max(theory: frozenset) -> int:
        """Oracle that outputs max(theory) + 1."""
        return max(theory) + 1 if theory else 0

    def oracle_hash(theory: frozenset) -> int:
        """Oracle that outputs hash of theory mod 1000."""
        return hash(theory) % 1000

    def oracle_fixed(theory: frozenset) -> int:
        """Oracle that always outputs 42."""
        return 42

    oracles = [
        ("max+1", oracle_max),
        ("hash", oracle_hash),
        ("fixed(42)", oracle_fixed),
    ]

    for name, G in oracles:
        # For each oracle, find a theory T where G(T) ∈ T
        # The simplest: T = universal set (contains everything)
        # But let's find a more interesting one

        # Strategy: start with T = {G(∅)}, then iterate
        T = frozenset()
        for _ in range(10):
            g = G(T)
            T = T | frozenset([g])

        g = G(T)
        success = g in T
        print(f"Oracle '{name}': G(T) = {g}, G(T) ∈ T? {success}")
        if success:
            print(f"  → Oracle fails on T = {sorted(T)[:10]}{'...' if len(T) > 10 else ''}")

    # The diagonal construction
    print("\nDiagonal construction:")
    print("  For ANY oracle G, take T = {0, 1, 2, ...} (all naturals).")
    print("  Then G(T) ∈ T trivially. QED.")
    print()


# ============================================================
# Demo 3: Lawvere's Fixed Point Theorem
# ============================================================

def demo_lawvere():
    """Demonstrate Lawvere's Fixed Point Theorem.

    If f : A → (A → Bool) is surjective, then every g : Bool → Bool
    has a fixed point. Since NOT has no fixed point, f cannot be surjective.
    """
    print("=" * 60)
    print("DEMO 3: Lawvere's Fixed Point Theorem")
    print("=" * 60)

    # Try to build a surjection from {0,1,...,n} to all functions {0,...,n} → {0,1}
    n = 3
    # There are 2^(n+1) such functions but only n+1 elements in the domain
    num_functions = 2 ** (n + 1)
    print(f"Domain size: {n + 1}")
    print(f"Number of functions {{0,...,{n}}} → {{0,1}}: {num_functions}")
    print(f"Surjection impossible: {n + 1} < {num_functions}")

    # The diagonal argument
    print("\nDiagonal argument:")
    print("If f were surjective, define d(a) = NOT(f(a)(a))")
    print("Then d is a function in the codomain, so d = f(e) for some e.")
    print("But d(e) = NOT(f(e)(e)) = NOT(d(e)). Contradiction!")

    # Concrete demonstration
    # Define f : {0,1,2,3} → ({0,1,2,3} → Bool)
    f = {
        0: lambda x: x % 2 == 0,
        1: lambda x: x < 2,
        2: lambda x: True,
        3: lambda x: x == 3,
    }

    print(f"\nConcrete f:")
    for a in range(4):
        vals = [f[a](x) for x in range(4)]
        print(f"  f({a}) = {[int(v) for v in vals]}")

    # Diagonal
    diag = [f[a](a) for a in range(4)]
    anti_diag = [not d for d in diag]
    print(f"\nDiagonal:      {[int(d) for d in diag]}")
    print(f"Anti-diagonal: {[int(d) for d in anti_diag]}")
    print(f"Anti-diagonal ≠ f(a) for all a: "
          f"{all([f[a](x) for x in range(4)] != anti_diag for a in range(4))}")
    print()


# ============================================================
# Demo 4: Berry-Chaitin Complexity Bound
# ============================================================

def demo_berry_chaitin():
    """Demonstrate the Berry-Chaitin complexity bound.

    You can't injectively map n+1 objects to n names.
    This is the pigeonhole principle driving incompleteness.
    """
    print("=" * 60)
    print("DEMO 4: Berry-Chaitin Complexity Bound")
    print("=" * 60)

    for n in range(1, 6):
        objects = list(range(n + 1))  # n+1 objects
        names = list(range(n))        # n names

        # Try random "naming" functions
        import random
        random.seed(42 + n)

        attempts = 100
        injective_count = 0
        for _ in range(attempts):
            naming = {obj: random.choice(names) for obj in objects}
            is_injective = len(set(naming.values())) == len(naming)
            if is_injective:
                injective_count += 1

        print(f"Mapping {n+1} objects → {n} names: "
              f"{injective_count}/{attempts} injective "
              f"(should be 0)")

    print("\nBerry paradox: 'The smallest number not definable in")
    print("under 100 words' defines a number in under 100 words!")
    print("Resolution: the naming function is non-injective (pigeonhole).")
    print()


# ============================================================
# Demo 5: Self-Referential Blindness
# ============================================================

def demo_self_referential_blindness():
    """Demonstrate that adding Gödel sentences doesn't escape incompleteness.

    Starting with a base theory, we iteratively add "the Gödel sentence"
    and show that each enhanced theory has its own blind spot.
    """
    print("=" * 60)
    print("DEMO 5: Self-Referential Blindness (Iterated)")
    print("=" * 60)

    depth = 8
    blind_spots = []

    beliefs = set(range(10))  # Initial beliefs

    for i in range(depth):
        # The "Gödel sentence" for the current belief set
        godel_sentence = hash(frozenset(beliefs)) % 10000 + 1000

        # Check: is the Gödel sentence in our beliefs?
        in_beliefs = godel_sentence in beliefs
        blind_spots.append(godel_sentence)

        print(f"Iteration {i}: |beliefs| = {len(beliefs)}, "
              f"G(beliefs) = {godel_sentence}, "
              f"G ∈ beliefs? {in_beliefs}")

        # Add the Gödel sentence to beliefs
        beliefs.add(godel_sentence)

    print(f"\nAfter {depth} iterations: |beliefs| = {len(beliefs)}")
    print(f"Blind spots encountered: {blind_spots}")
    print("Each addition created a NEW blind spot — iteration doesn't help!")
    print()


if __name__ == "__main__":
    demo_reflective_tower()
    demo_penrose_diagonal()
    demo_lawvere()
    demo_berry_chaitin()
    demo_self_referential_blindness()


#!/usr/bin/env python3
"""
Visualization: Reflective Tower Structure
==========================================

Visualizes the strictly ascending chain of proof systems in a Reflective Tower,
showing incompleteness gaps and consistency sentences at each level.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def visualize_reflective_tower():
    """Create a visualization of the Reflective Tower hierarchy."""

    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    # --- Left panel: Tower as nested sets ---
    ax1 = axes[0]
    ax1.set_xlim(-0.5, 10.5)
    ax1.set_ylim(-0.5, 7)
    ax1.set_aspect('equal')
    ax1.set_title('Reflective Tower: Strictly Ascending Chain\n'
                   'provable(0) ⊂ provable(1) ⊂ provable(2) ⊂ ···',
                   fontsize=12, fontweight='bold')

    colors = plt.cm.Blues(np.linspace(0.2, 0.8, 6))

    for n in range(5, -1, -1):
        width = 2 + n * 1.5
        height = 1 + n * 0.8
        x = 5 - width / 2
        y = 0.5

        rect = mpatches.FancyBboxPatch(
            (x, y), width, height,
            boxstyle="round,pad=0.1",
            facecolor=colors[n],
            edgecolor='black',
            linewidth=1.5,
            alpha=0.7
        )
        ax1.add_patch(rect)

        # Label the level
        ax1.text(x + 0.3, y + height - 0.3,
                f'Level {n}', fontsize=9, fontweight='bold',
                color='black')

        # Mark Con(n) in the gap
        if n < 5:
            gap_x = x + width - 0.8
            gap_y = y + 0.3
            ax1.plot(gap_x, gap_y, 'r*', markersize=12)
            ax1.text(gap_x + 0.15, gap_y - 0.05,
                    f'Con({n})', fontsize=7, color='red',
                    fontweight='bold')

    ax1.text(5, 0.1, '← Base theory (e.g., PA) →',
            ha='center', fontsize=9, style='italic', color='gray')

    ax1.legend(
        [mpatches.Patch(color='red', alpha=0.7),
         mpatches.Patch(color=colors[3], alpha=0.7)],
        ['Con(n): in gap(n), not in level n',
         'provable(n): strictly ascending'],
        loc='upper left', fontsize=9
    )
    ax1.axis('off')

    # --- Right panel: Incompleteness gap sizes ---
    ax2 = axes[1]

    levels = list(range(8))
    base_size = 100
    gap_sizes = [1] * 8  # Each gap adds exactly Con(n)

    # Cumulative size
    cumulative = [base_size + n for n in range(9)]

    bars = ax2.bar(levels, [1]*8, bottom=[base_size + n for n in range(8)],
                   color='red', alpha=0.6, label='Incompleteness gap')
    ax2.bar(levels, [base_size + n for n in range(8)],
            color='steelblue', alpha=0.4, label='Inherited theorems')

    # Mark Con(n)
    for n in range(8):
        ax2.text(n, base_size + n + 0.5, f'Con({n})',
                fontsize=7, ha='center', color='darkred', fontweight='bold')

    ax2.set_xlabel('Tower Level n', fontsize=11)
    ax2.set_ylabel('Number of Provable Sentences', fontsize=11)
    ax2.set_title('Incompleteness Gaps:\n'
                  'Each Level Adds New Truths',
                  fontsize=12, fontweight='bold')
    ax2.legend(loc='upper left', fontsize=9)
    ax2.set_xticks(levels)

    # Add annotation
    ax2.annotate('Tower strictly\nascends: each\nlevel adds Con(n)',
                xy=(5, 105.5), xytext=(6, 108),
                fontsize=9, style='italic',
                arrowprops=dict(arrowstyle='->', color='red'),
                color='darkred')

    plt.tight_layout()
    plt.savefig('tower_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tower_visualization.png")


def visualize_diagonal_argument():
    """Visualize the Lawvere/Cantor diagonal argument."""

    fig, ax = plt.subplots(figsize=(8, 8))

    n = 6
    # Create a matrix representing f : {0,...,n-1} → ({0,...,n-1} → {0,1})
    np.random.seed(42)
    matrix = np.random.randint(0, 2, (n, n))

    # The diagonal
    diagonal = np.array([matrix[i, i] for i in range(n)])
    anti_diagonal = 1 - diagonal

    # Plot the matrix
    im = ax.imshow(matrix, cmap='RdYlBu', aspect='equal', vmin=0, vmax=1)

    # Highlight diagonal
    for i in range(n):
        rect = mpatches.Rectangle((i - 0.5, i - 0.5), 1, 1,
                                   linewidth=3, edgecolor='red',
                                   facecolor='none')
        ax.add_patch(rect)

    # Labels
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels([f'x={i}' for i in range(n)])
    ax.set_yticklabels([f'f({i})' for i in range(n)])

    # Cell values
    for i in range(n):
        for j in range(n):
            color = 'white' if matrix[i, j] == 0 else 'black'
            ax.text(j, i, str(matrix[i, j]), ha='center', va='center',
                   fontsize=14, fontweight='bold', color=color)

    # Anti-diagonal annotation
    ax.set_title(f'Lawvere/Cantor Diagonal Argument\n'
                 f'Diagonal: {list(diagonal)} → '
                 f'Anti-diagonal: {list(anti_diagonal)}\n'
                 f'Anti-diagonal ≠ f(a) for any a (Cantor\'s theorem)',
                 fontsize=11, fontweight='bold')

    ax.set_xlabel('Column (input to f(a))', fontsize=11)
    ax.set_ylabel('Row (function index a)', fontsize=11)

    plt.colorbar(im, ax=ax, label='Function value', shrink=0.8)
    plt.tight_layout()
    plt.savefig('diagonal_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: diagonal_visualization.png")


def visualize_penrose_dilemma():
    """Visualize the Penrose Dilemma as a decision tree."""

    fig, ax = plt.subplots(figsize=(12, 6))
    ax.axis('off')
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 6)

    # Title
    ax.text(6, 5.5, 'The Penrose Dilemma', fontsize=16,
            ha='center', fontweight='bold')

    # Root node
    ax.text(6, 4.5, 'Is the mind M\na formal system F?',
            ha='center', va='center', fontsize=11,
            bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow',
                     edgecolor='black', linewidth=2))

    # Left branch: Yes
    ax.annotate('', xy=(3, 3.2), xytext=(5.2, 4),
               arrowprops=dict(arrowstyle='->', lw=2, color='red'))
    ax.text(4, 3.7, 'Yes', fontsize=10, color='red', fontweight='bold')

    ax.text(3, 2.8, 'Then ∃ G(F)\nthat F cannot prove',
            ha='center', va='center', fontsize=10,
            bbox=dict(boxstyle='round,pad=0.4', facecolor='lightsalmon',
                     edgecolor='red'))

    ax.annotate('', xy=(2, 1.5), xytext=(2.5, 2.3),
               arrowprops=dict(arrowstyle='->', lw=2, color='red'))
    ax.text(2, 1, 'But M "sees" G(F)\nis true!',
            ha='center', va='center', fontsize=10,
            bbox=dict(boxstyle='round,pad=0.4', facecolor='lightsalmon',
                     edgecolor='red'))

    ax.annotate('', xy=(2, 0.2), xytext=(2, 0.6),
               arrowprops=dict(arrowstyle='->', lw=2, color='darkred'))
    ax.text(2, -0.1, 'Contradiction!\n(if M = F)',
            ha='center', va='center', fontsize=10, fontweight='bold',
            color='darkred')

    # Right branch: No
    ax.annotate('', xy=(9, 3.2), xytext=(6.8, 4),
               arrowprops=dict(arrowstyle='->', lw=2, color='green'))
    ax.text(8, 3.7, 'No', fontsize=10, color='green', fontweight='bold')

    ax.text(9, 2.8, 'Mind transcends\nformal systems?',
            ha='center', va='center', fontsize=10,
            bbox=dict(boxstyle='round,pad=0.4', facecolor='lightgreen',
                     edgecolor='green'))

    # The catch
    ax.annotate('', xy=(9, 1.5), xytext=(9, 2.3),
               arrowprops=dict(arrowstyle='->', lw=2, color='orange'))
    ax.text(9, 1, 'Hidden premise:\nM must KNOW\nF is consistent!',
            ha='center', va='center', fontsize=10,
            bbox=dict(boxstyle='round,pad=0.4', facecolor='wheat',
                     edgecolor='orange', linewidth=2))

    ax.annotate('', xy=(9, 0.1), xytext=(9, 0.5),
               arrowprops=dict(arrowstyle='->', lw=2, color='orange'))
    ax.text(9, -0.2, 'Self-Referential Blindness:\nAdding G(F) creates\nnew blind spot G(F\')',
            ha='center', va='center', fontsize=9,
            fontweight='bold', color='darkorange')

    plt.tight_layout()
    plt.savefig('penrose_dilemma.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: penrose_dilemma.png")


if __name__ == '__main__':
    visualize_reflective_tower()
    visualize_diagonal_argument()
    visualize_penrose_dilemma()
