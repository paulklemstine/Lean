#!/usr/bin/env python3
"""
Demo: Self-Referential Types and Fixed-Point Hierarchies

Demonstrates key mathematical concepts from the formalization:
1. Lawvere's diagonal construction
2. Fixed-point hierarchy iteration
3. Closure operator fixed points
"""

import numpy as np


def lawvere_diagonal(enum: list[list[bool]], f=lambda x: not x) -> list[bool]:
    """
    Lawvere's diagonal construction.
    Given an enumeration of Boolean functions (as a matrix),
    constructs a function not in the enumeration by applying f to the diagonal.

    This is the computational content of Lawvere's Fixed Point Theorem:
    the diagonal g(n) = f(enum[n][n]) always escapes the enumeration.
    """
    n = len(enum)
    return [f(enum[i][i]) if i < len(enum[i]) else True for i in range(n)]


def cantor_diagonal_demo():
    """Demonstrate Cantor's theorem as a special case of Lawvere."""
    print("=" * 60)
    print("CANTOR'S THEOREM via LAWVERE'S DIAGONAL")
    print("=" * 60)

    # Enumerate some subsets of {0,1,2,3,4}
    enum = [
        [True, False, True, False, True],    # {0, 2, 4}
        [False, True, False, True, False],   # {1, 3}
        [True, True, True, False, False],    # {0, 1, 2}
        [False, False, False, True, True],   # {3, 4}
        [True, True, True, True, True],      # {0, 1, 2, 3, 4}
    ]

    print("\nEnumeration (rows = encoded subsets):")
    for i, row in enumerate(enum):
        subset = {j for j, v in enumerate(row) if v}
        print(f"  enum[{i}] = {subset}")

    print(f"\nDiagonal entries: ", end="")
    diag = [enum[i][i] for i in range(5)]
    print([int(d) for d in diag])

    escaped = lawvere_diagonal(enum, f=lambda x: not x)
    escaped_set = {j for j, v in enumerate(escaped) if v}
    print(f"Diagonal escape (negated): {escaped_set}")

    # Verify it's not in the enumeration
    for i, row in enumerate(enum):
        if row == escaped:
            print(f"  ERROR: matches enum[{i}]!")
            return
    print("  ✓ Not equal to any enum[i] — Cantor's theorem confirmed!")


def fixed_point_hierarchy_demo():
    """Demonstrate the fixed-point hierarchy on [0,1] with monotone operators."""
    print("\n" + "=" * 60)
    print("FIXED-POINT HIERARCHY")
    print("=" * 60)

    # Each operator Φ_n(x) = 1 - (1-x)^(n+2) on [0,1]
    # These are monotone, and lfp(Φ_n) = 0 for all n,
    # but gfp(Φ_n) = 1 for all n.
    # More interestingly: Φ_n(x) = min(1, x + 1/(n+1))
    # lfp = 0, but the "convergence speed" to fixed points differs.

    print("\nOperator family: Φ_n(x) = min(1, x + 1/(n+1))")
    print("Each has lfp = 0 and unique non-trivial fixed point at x = 1")
    print()

    # More interesting: use x^(1/(n+1)) which has fixed points at 0 and 1
    for n in range(5):
        def phi(x, n=n):
            return x ** (1.0 / (n + 2))

        # Find fixed points by iteration from 0.5
        x = 0.5
        for _ in range(1000):
            x = phi(x)

        # Count iterations to converge within epsilon from a start point
        eps = 1e-8
        x = 0.01
        iters = 0
        while abs(phi(x) - x) > eps and iters < 10000:
            x = phi(x)
            iters += 1

        print(f"  Level {n}: Φ_{n}(x) = x^(1/{n+2}), "
              f"converges to {x:.6f} from 0.01 in {iters} iterations")

    print("\n  The hierarchy shows increasing 'attraction strength'")
    print("  of fixed points at higher levels.")


def closure_operator_demo():
    """Demonstrate closure operators and their fixed points on power sets."""
    print("\n" + "=" * 60)
    print("CLOSURE OPERATORS AND GALOIS CONNECTIONS")
    print("=" * 60)

    # Work with subsets of {0, 1, 2, 3, 4}
    universe = set(range(5))

    # Define a Galois connection via a relation R ⊆ A × B
    # A = {0,1,2,3,4}, B = {a,b,c}
    # R[i] = set of properties that object i has
    R = {
        0: {'a', 'b'},
        1: {'b', 'c'},
        2: {'a', 'b', 'c'},
        3: {'a'},
        4: {'b', 'c'},
    }

    # l(S) = ∩{R[i] : i ∈ S}  (common properties)
    def lower(S: set) -> set:
        if not S:
            return {'a', 'b', 'c'}
        return set.intersection(*(R[i] for i in S))

    # u(T) = {i : T ⊆ R[i]}  (objects having all properties in T)
    def upper(T: set) -> set:
        return {i for i in range(5) if T <= R[i]}

    # Closure: u ∘ l
    def closure(S: set) -> set:
        return upper(lower(S))

    print("\nGalois connection between objects {0-4} and properties {a,b,c}")
    print("Object properties:")
    for i in range(5):
        print(f"  Object {i}: {R[i]}")

    print("\nClosure operator u∘l (self-referentially stable sets):")
    # Find all fixed points (closed sets)
    closed_sets = []
    for mask in range(2**5):
        S = {i for i in range(5) if mask & (1 << i)}
        cl = closure(S)
        if cl == S:
            closed_sets.append(S)
            print(f"  {S} → l={lower(S)}, u∘l={cl}  ✓ FIXED POINT")

    print(f"\n  Total closed sets: {len(closed_sets)}")
    print(f"  These form a complete lattice under ⊆")

    # Verify: closed sets = range of u
    range_u = set()
    for pmask in range(2**3):
        T = set()
        props = ['a', 'b', 'c']
        for j, p in enumerate(props):
            if pmask & (1 << j):
                T.add(p)
        range_u.add(frozenset(upper(T)))

    print(f"\n  Range of u: {[set(s) for s in range_u]}")
    print(f"  Fixed points = Range of u: "
          f"{'✓' if {frozenset(s) for s in closed_sets} == range_u else '✗'}")


def reflective_system_demo():
    """Demonstrate why reflective systems are impossible."""
    print("\n" + "=" * 60)
    print("IMPOSSIBILITY OF REFLECTIVE SYSTEMS")
    print("=" * 60)

    print("\nAttempting to build a reflective system on {0, 1, 2}...")
    print("We need repr: (A→Bool) → A and eval: A → (A→Bool)")
    print("such that eval(repr(P)) = P for all P.")
    print()

    # There are 2^3 = 8 functions {0,1,2} → Bool
    # But only 3 elements to encode them.
    # By pigeonhole, repr cannot be injective.

    n = 3
    num_predicates = 2**n

    print(f"  |A| = {n}")
    print(f"  |A → Bool| = {num_predicates}")
    print(f"  We need repr to faithfully represent {num_predicates} predicates")
    print(f"  using only {n} codes.")
    print(f"  By pigeonhole: IMPOSSIBLE (need injective repr for faithfulness)")
    print()
    print("  But the Lawvere argument is deeper — it works even for infinite types:")
    print("  The 'liar predicate' L(a) = ¬eval(a)(a) must have a code repr(L),")
    print("  but then eval(repr(L))(repr(L)) = L(repr(L)) = ¬eval(repr(L))(repr(L))")
    print("  which is a contradiction regardless of the cardinality of A.")


if __name__ == "__main__":
    cantor_diagonal_demo()
    fixed_point_hierarchy_demo()
    closure_operator_demo()
    reflective_system_demo()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Visualization: Fixed-Point Hierarchy and Operator Convergence

Generates a multi-panel figure showing:
1. Convergence trajectories to fixed points at different hierarchy levels
2. The cobweb diagram for fixed-point iteration
3. Separation between hierarchy levels
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def compute_trajectory(f, x0, n_steps=50):
    """Iterate f from x0 for n_steps."""
    traj = [x0]
    x = x0
    for _ in range(n_steps):
        x = f(x)
        traj.append(x)
    return traj


def cobweb_data(f, x0, n_steps=30):
    """Generate cobweb diagram data for iteration of f from x0."""
    xs, ys = [x0], [0]
    x = x0
    for _ in range(n_steps):
        y = f(x)
        xs.extend([x, y])
        ys.extend([y, y])
        x = y
    return xs, ys


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle('Fixed-Point Hierarchy: Self-Referential Complexity', fontsize=16, fontweight='bold')

    # Panel 1: Operator family and fixed points
    ax1 = axes[0, 0]
    x = np.linspace(0, 1, 500)
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, 6))

    for n in range(6):
        exp = 1.0 / (n + 2)
        y = x ** exp
        ax1.plot(x, y, color=colors[n], linewidth=2, label=f'Φ_{n}(x) = x^(1/{n+2})')

    ax1.plot(x, x, 'k--', linewidth=1, alpha=0.5, label='y = x')
    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('Φ_n(x)', fontsize=12)
    ax1.set_title('Hierarchy of Monotone Operators', fontsize=13)
    ax1.legend(fontsize=8, loc='lower right')
    ax1.set_xlim(0, 1)
    ax1.set_ylim(0, 1)
    ax1.grid(True, alpha=0.3)

    # Panel 2: Cobweb diagram for level 2
    ax2 = axes[0, 1]
    f2 = lambda x: x ** (1.0 / 4)
    xs_cob, ys_cob = cobweb_data(f2, 0.01, 20)
    x_line = np.linspace(0, 1, 300)

    ax2.plot(x_line, f2(x_line), 'b-', linewidth=2, label='Φ₂(x) = x^(1/4)')
    ax2.plot(x_line, x_line, 'k--', linewidth=1, alpha=0.5)
    ax2.plot(xs_cob, ys_cob, 'r-', linewidth=0.8, alpha=0.7)
    ax2.plot(xs_cob[0], ys_cob[0], 'go', markersize=8, label='Start (0.01)')
    ax2.plot(1, 1, 'r*', markersize=15, label='Fixed point (1.0)')
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('Φ₂(x)', fontsize=12)
    ax2.set_title('Cobweb: Iteration to Fixed Point', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.set_xlim(0, 1.05)
    ax2.set_ylim(0, 1.05)
    ax2.grid(True, alpha=0.3)

    # Panel 3: Convergence speed comparison
    ax3 = axes[1, 0]
    x0 = 0.01
    for n in range(6):
        exp = 1.0 / (n + 2)
        f_n = lambda x, e=exp: x ** e
        traj = compute_trajectory(f_n, x0, 100)
        # Distance to fixed point (1.0)
        distances = [abs(1.0 - t) for t in traj]
        ax3.semilogy(distances[:60], color=colors[n], linewidth=2, label=f'Level {n}')

    ax3.set_xlabel('Iteration', fontsize=12)
    ax3.set_ylabel('|x_n - 1| (log scale)', fontsize=12)
    ax3.set_title('Convergence Speed by Hierarchy Level', fontsize=13)
    ax3.legend(fontsize=9)
    ax3.grid(True, alpha=0.3)

    # Panel 4: Diagonal escape visualization
    ax4 = axes[1, 1]
    np.random.seed(42)
    n = 10
    # Create a random binary matrix (enumeration)
    matrix = np.random.randint(0, 2, (n, n))
    # The diagonal
    diag = np.diag(matrix)
    # The escaped set (negation of diagonal)
    escaped = 1 - diag

    im = ax4.imshow(matrix, cmap='Blues', aspect='equal', vmin=0, vmax=1)

    # Highlight diagonal
    for i in range(n):
        ax4.add_patch(plt.Rectangle((i-0.5, i-0.5), 1, 1,
                                     fill=False, edgecolor='red', linewidth=2))

    # Show escaped set on the right
    for i in range(n):
        color = 'green' if escaped[i] else 'white'
        ax4.add_patch(plt.Rectangle((n+0.5, i-0.5), 1, 1,
                                     facecolor=color, edgecolor='black', linewidth=1))
        ax4.text(n+1, i, str(escaped[i]), ha='center', va='center', fontsize=9)

    ax4.set_xlim(-0.5, n+1.5)
    ax4.set_xticks(list(range(n)) + [n+1])
    ax4.set_xticklabels([str(i) for i in range(n)] + ['Esc'])
    ax4.set_yticks(range(n))
    ax4.set_xlabel('Column / Escape', fontsize=12)
    ax4.set_ylabel('Row (enum index)', fontsize=12)
    ax4.set_title('Diagonal Escape (Cantor/Lawvere)', fontsize=13)

    plt.tight_layout()
    plt.savefig('fixed_point_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fixed_point_hierarchy.png")


if __name__ == "__main__":
    main()
