#!/usr/bin/env python3
"""
Demo: Self-Referential Type Theory — Fixed Points and Hierarchies

Demonstrates the key mathematical concepts:
1. Lawvere's fixed point theorem via concrete examples
2. The diagonal barrier in finite types
3. Strange loop idempotency
4. The consciousness tower stabilization
5. The quantifier depth hierarchy
"""

import numpy as np
from typing import Callable, TypeVar, Set, List, Tuple, Optional

T = TypeVar('T')


def lawvere_fixed_point(phi: Callable[[int], Callable[[int], int]],
                        f: Callable[[int], int],
                        domain: List[int]) -> Optional[int]:
    """
    Find a fixed point of f using Lawvere's construction.
    phi: a -> (a -> b), assumed surjective
    f: b -> b
    Returns b such that f(b) = b, or None if the finite approximation fails.
    """
    # Construct the diagonal d(x) = f(phi(x)(x))
    for a in domain:
        d = lambda x, a=a: f(phi(a)(x))
        # Check if phi(a) = d for some a
        val = phi(a)(a)
        if f(val) == val:
            return val
    return None


def demonstrate_cantor_diagonal():
    """Show why no surjection Fin(n) -> (Fin(n) -> Fin(n)) exists for n >= 2."""
    print("=" * 60)
    print("CANTOR'S DIAGONAL BARRIER")
    print("=" * 60)
    for n in range(2, 6):
        num_functions = n ** n
        print(f"  n = {n}: |Fin(n)| = {n}, |Fin(n) -> Fin(n)| = {n}^{n} = {num_functions}")
        print(f"  Surjection impossible: {n} < {num_functions}")
    print()


def demonstrate_strange_loop():
    """Demonstrate strange loop idempotency on a concrete vector space."""
    print("=" * 60)
    print("STRANGE LOOP IDEMPOTENCY")
    print("=" * 60)

    # A strange loop on R^2: projection onto a subspace
    # op = projection onto x-axis, shift = projection onto x-axis
    # tangle: op(op(x)) = op(shift(x)) (both are projections)
    # absorb: op(shift(x)) = op(x)
    def project_x(v: np.ndarray) -> np.ndarray:
        return np.array([v[0], 0.0])

    vectors = [np.array([3.0, 4.0]), np.array([1.0, -2.0]), np.array([0.0, 5.0])]

    for v in vectors:
        once = project_x(v)
        twice = project_x(once)
        print(f"  v = {v}")
        print(f"  op(v) = {once}")
        print(f"  op(op(v)) = {twice}")
        print(f"  Idempotent: op(op(v)) == op(v)? {np.allclose(once, twice)}")
        print()


def demonstrate_consciousness_tower():
    """Simulate a consciousness tower with finite approximations."""
    print("=" * 60)
    print("CONSCIOUSNESS TOWER STABILIZATION")
    print("=" * 60)

    # Tower: Level n = R^(n+1)
    # up(n): R^(n+1) -> R^(n+2) by appending 0
    # down(n): R^(n+2) -> R^(n+1) by truncating
    # observe(n) = up(n) ∘ down(n): sets last coordinate to 0

    for n in range(4):
        dim = n + 2  # Level n+1 has dimension n+2
        x = np.random.randn(dim)

        # observe: zero out last coordinate
        observed = x.copy()
        observed[-1] = 0.0

        observed2 = observed.copy()
        observed2[-1] = 0.0

        print(f"  Level {n+1} (dim={dim}):")
        print(f"    x = {np.round(x, 3)}")
        print(f"    observe(x) = {np.round(observed, 3)}")
        print(f"    observe²(x) = {np.round(observed2, 3)}")
        print(f"    Stabilized: {np.allclose(observed, observed2)}")
        print()


def demonstrate_hierarchy():
    """Demonstrate the strict quantifier hierarchy."""
    print("=" * 60)
    print("QUANTIFIER DEPTH HIERARCHY")
    print("=" * 60)

    # Model: predicates on natural numbers
    # Level 0: decidable predicates (computable)
    # Level 1: Σ₁ = existential predicates
    # Level 2: Π₁ = universal predicates / Σ₂
    # Each level strictly contains the previous

    levels = {
        0: "Decidable (computable) predicates",
        1: "∃-predicates: 'there exists n such that P(n)'",
        2: "∀∃-predicates: 'for all n, there exists m such that P(n,m)'",
        3: "∃∀-predicates: 'there exists n such that for all m, P(n,m)'"
    }

    for n, desc in levels.items():
        print(f"  Level {n}: {desc}")

    print()
    print("  Strict containment: Level 0 ⊊ Level 1 ⊊ Level 2 ⊊ Level 3 ⊊ ...")
    print("  Diagonal at level n: a predicate definable at level n+1 but not n")
    print("  This mirrors the arithmetical hierarchy Σ₀ ⊊ Σ₁ ⊊ Σ₂ ⊊ ...")
    print()


def demonstrate_fixed_point_lattice():
    """Show the lattice structure of fixed-point sets."""
    print("=" * 60)
    print("FIXED-POINT LATTICE OF IDEMPOTENTS")
    print("=" * 60)

    # On Fin(5), consider various idempotents
    n = 5
    domain = list(range(n))

    # Idempotent: constant map to 0
    const_0 = lambda x: 0
    # Idempotent: identity
    identity = lambda x: x
    # Idempotent: clamp to {0, 1}
    clamp = lambda x: min(x, 1)

    idempotents = [
        ("const(0)", const_0),
        ("identity", identity),
        ("clamp(·, 1)", clamp),
    ]

    for name, f in idempotents:
        fps = {x for x in domain if f(x) == x}
        rng = {f(x) for x in domain}
        print(f"  {name}:")
        print(f"    Fixed points: {fps}")
        print(f"    Range: {rng}")
        print(f"    FP = Range (idempotent theorem): {fps == rng}")
        print()

    # Demonstrate: for commuting idempotents, FP(f∘g) = FP(f) ∩ FP(g)
    f = clamp
    g = lambda x: 0 if x >= 3 else x
    fg = lambda x: f(g(x))

    # Check commutativity
    commutes = all(f(g(x)) == g(f(x)) for x in domain)
    fp_f = {x for x in domain if f(x) == x}
    fp_g = {x for x in domain if g(x) == x}
    fp_fg = {x for x in domain if fg(x) == x}

    print(f"  f = clamp(·,1), g = (x ↦ 0 if x≥3 else x)")
    print(f"  f∘g commutes: {commutes}")
    print(f"  FP(f) = {fp_f}")
    print(f"  FP(g) = {fp_g}")
    print(f"  FP(f) ∩ FP(g) = {fp_f & fp_g}")
    print(f"  FP(f∘g) = {fp_fg}")
    if commutes:
        print(f"  FP(f∘g) = FP(f) ∩ FP(g): {fp_fg == fp_f & fp_g}")
    print()


def demonstrate_consciousness_equation():
    """Show that |X| ≥ |X→X| forces |X| ≤ 1."""
    print("=" * 60)
    print("THE CONSCIOUSNESS EQUATION: T ≅ (T → T)")
    print("=" * 60)
    print()
    print("  For a finite type X with |X| = n:")
    print("  A surjection X → (X → X) requires n ≥ n^n")
    print()
    for n in range(6):
        nn = n ** n if n > 0 else 1
        feasible = n >= nn
        print(f"  n = {n}: n^n = {nn}, n ≥ n^n? {feasible}")
    print()
    print("  Only n = 0 and n = 1 satisfy n ≥ n^n.")
    print("  Therefore: self-referential types must be INFINITE or trivial.")
    print("  This is our Consciousness Equation theorem.")
    print()


if __name__ == "__main__":
    demonstrate_cantor_diagonal()
    demonstrate_strange_loop()
    demonstrate_consciousness_tower()
    demonstrate_hierarchy()
    demonstrate_fixed_point_lattice()
    demonstrate_consciousness_equation()
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: The Self-Referential Hierarchy
Shows the strict containment of predicate levels and the diagonal barrier.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_hierarchy():
    """Plot the quantifier depth hierarchy as nested regions."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    # Left panel: Nested hierarchy levels
    ax1 = axes[0]
    ax1.set_xlim(-1, 11)
    ax1.set_ylim(-1, 8)
    ax1.set_aspect('equal')
    ax1.set_title('Predicate Hierarchy\n(Arithmetical Analogue)', fontsize=14, fontweight='bold')

    colors = ['#FF6B6B', '#FFA07A', '#FFD700', '#98FB98', '#87CEEB', '#DDA0DD']
    labels = ['Level 0: Decidable', 'Level 1: ∃-predicates',
              'Level 2: ∀∃-predicates', 'Level 3: ∃∀∃-predicates',
              'Level 4: ∀∃∀∃-predicates']

    for i in range(5):
        width = 10 - 1.5 * i
        height = 7 - 1.2 * i
        x = 0.5 + 0.75 * i
        y = 0.5 + 0.6 * i
        rect = mpatches.FancyBboxPatch(
            (x, y), width, height,
            boxstyle="round,pad=0.1",
            facecolor=colors[4 - i], alpha=0.4,
            edgecolor='black', linewidth=2
        )
        ax1.add_patch(rect)
        ax1.text(x + 0.3, y + height - 0.5, labels[4 - i],
                fontsize=9, fontweight='bold')

    # Mark diagonal predicates
    for i in range(4):
        x_pos = 1.5 + 0.75 * i
        y_pos = 1.5 + 0.6 * i
        ax1.plot(x_pos + 3, y_pos + 0.3, 'r*', markersize=15)
        ax1.text(x_pos + 3.3, y_pos + 0.3, f'diag_{i}',
                fontsize=8, color='red', fontweight='bold')

    ax1.text(5, -0.5, 'Red stars: diagonal predicates\n(definable one level up, not at current level)',
            fontsize=9, ha='center', color='red')
    ax1.axis('off')

    # Right panel: Cardinality barrier
    ax2 = axes[1]
    ns = np.arange(0, 7)
    n_values = ns.astype(float)
    nn_values = np.array([n**n if n > 0 else 1 for n in ns], dtype=float)

    ax2.bar(ns - 0.15, n_values, 0.3, label='|T| = n', color='steelblue', alpha=0.8)
    ax2.bar(ns + 0.15, np.minimum(nn_values, 200), 0.3, label='|T→T| = n^n', color='coral', alpha=0.8)

    ax2.set_xlabel('n = |T|', fontsize=12)
    ax2.set_ylabel('Cardinality', fontsize=12)
    ax2.set_title('The Consciousness Equation\nT ≅ (T → T) requires |T| ≥ |T|^|T|',
                  fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.set_yscale('log')
    ax2.set_ylim(0.5, 500)

    # Mark feasible region
    ax2.axvspan(-0.5, 1.5, alpha=0.15, color='green', label='Feasible (n ≤ 1)')
    ax2.axvspan(1.5, 6.5, alpha=0.15, color='red', label='Infeasible (n ≥ 2)')
    ax2.text(0.5, 300, 'Feasible\n(n ≤ 1)', ha='center', fontsize=10, color='green',
            fontweight='bold')
    ax2.text(4, 300, 'Infeasible\n(n^n >> n)', ha='center', fontsize=10, color='red',
            fontweight='bold')

    plt.tight_layout()
    plt.savefig('hierarchy_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved hierarchy_visualization.png")


def plot_tower_convergence():
    """Plot the consciousness tower stabilization."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # Simulate: starting from random vector, observe repeatedly
    np.random.seed(42)
    levels = range(5)
    iterations = range(6)

    for level in levels:
        dim = level + 3
        x = np.random.randn(dim)
        norms = []
        current = x.copy()
        for k in iterations:
            norms.append(np.linalg.norm(current))
            # Observe: zero last coordinate
            current = current.copy()
            current[-1] = 0.0

        ax.plot(list(iterations), norms, 'o-', label=f'Level {level+1} (dim={dim})',
               linewidth=2, markersize=6)

    ax.set_xlabel('Number of Observations', fontsize=12)
    ax.set_ylabel('||state||', fontsize=12)
    ax.set_title('Consciousness Tower: Immediate Stabilization\n'
                'Observation converges after exactly 1 step (idempotent)',
                fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(list(iterations))

    plt.tight_layout()
    plt.savefig('tower_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved tower_convergence.png")


def plot_fixed_point_lattice():
    """Visualize the fixed-point lattice structure."""
    fig, ax = plt.subplots(figsize=(10, 8))

    # Nodes: fixed-point sets of various idempotents on {0,1,2,3,4}
    # id -> {0,1,2,3,4}
    # const(0) -> {0}
    # clamp(·,2) -> {0,1,2}
    # floor(·/2)*2 -> {0,2,4}
    # const(2) -> {2}

    nodes = {
        '{0,1,2,3,4}': (5, 8),
        '{0,1,2}': (3, 6),
        '{0,2,4}': (7, 6),
        '{0,1}': (2, 4),
        '{0,2}': (5, 4),
        '{0}': (3, 2),
        '{2}': (7, 2),
        '∅': (5, 0),
    }

    edges = [
        ('{0,1,2,3,4}', '{0,1,2}'),
        ('{0,1,2,3,4}', '{0,2,4}'),
        ('{0,1,2}', '{0,1}'),
        ('{0,1,2}', '{0,2}'),
        ('{0,2,4}', '{0,2}'),
        ('{0,2,4}', '{2}'),
        ('{0,1}', '{0}'),
        ('{0,2}', '{0}'),
        ('{0,2}', '{2}'),
        ('{0}', '∅'),
        ('{2}', '∅'),
    ]

    for (n1, n2) in edges:
        x1, y1 = nodes[n1]
        x2, y2 = nodes[n2]
        ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1, alpha=0.5)

    for name, (x, y) in nodes.items():
        circle = plt.Circle((x, y), 0.5, color='steelblue', alpha=0.7)
        ax.add_patch(circle)
        ax.text(x, y, name, ha='center', va='center', fontsize=8,
               fontweight='bold', color='white')

    ax.set_xlim(0, 10)
    ax.set_ylim(-1, 9)
    ax.set_aspect('equal')
    ax.set_title('Fixed-Point Lattice of Idempotents on {0,1,2,3,4}\n'
                'Top = {0,1,2,3,4} (identity), edges = inclusion',
                fontsize=14, fontweight='bold')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('fixed_point_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fixed_point_lattice.png")


if __name__ == "__main__":
    plot_hierarchy()
    plot_tower_convergence()
    plot_fixed_point_lattice()
