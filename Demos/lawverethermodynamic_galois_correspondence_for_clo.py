#!/usr/bin/env python3
"""
Demonstration: Lawvere–Thermodynamic Galois Correspondence

This script illustrates the Galois connection between proof states and
thermodynamic observables with concrete finite examples. It shows:
1. How the Galois connection works on a small poset
2. The induced closure operator
3. The fixed-point / range-of-theoryOf correspondence
4. Iterative refinement and its stabilization

All theorems demonstrated here have been formally verified in Lean 4.
"""

from itertools import product

try:
    import matplotlib
    matplotlib.use('Agg')  # non-interactive backend
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False

# ============================================================
# Example 1: A Galois connection on small finite posets
# ============================================================

def example_galois_connection():
    """
    Concrete example:
    P = powerset of {a, b} ordered by inclusion = {∅, {a}, {b}, {a,b}}
    O = {0, 1, 2, 3} with natural order (we use OrderDual, so ≤ on O^op is ≥ on O)

    We define:
      lowerEnv: P → O^op  (maps proof states to dual observables)
      theoryOf: O^op → P   (maps dual observables to proof states)

    such that lowerEnv(p) ≤_{O^op} o  iff  p ⊆ theoryOf(o)
    i.e.      lowerEnv(p) ≥_O o      iff  p ⊆ theoryOf(o)
    """
    # P elements as frozensets
    P_elements = [frozenset(), frozenset('a'), frozenset('b'), frozenset('ab')]
    P_labels = ['∅', '{a}', '{b}', '{a,b}']

    # O^op elements: 0, 1, 2, 3 (dual order: i ≤_dual j iff i ≥ j)
    O_elements = [0, 1, 2, 3]

    # Define theoryOf: O^op → P
    # theoryOf(o) should be monotone in the dual order
    # In dual order: 3 ≤ 2 ≤ 1 ≤ 0
    # So theoryOf should satisfy: theoryOf(3) ⊆ theoryOf(2) ⊆ theoryOf(1) ⊆ theoryOf(0)
    theory_of = {
        3: frozenset(),       # most restrictive observable → empty theory
        2: frozenset('a'),    # → theory containing just a
        1: frozenset('ab'),   # → theory containing a and b
        0: frozenset('ab'),   # least restrictive → full theory
    }

    # Define lowerEnv: P → O^op
    # Must satisfy the Galois connection law:
    # lowerEnv(p) ≥_O o  iff  p ⊆ theoryOf(o)
    # i.e., lowerEnv(p) = max{o : p ⊆ theoryOf(o)}  (max in O order = min in dual)
    def lower_env(p):
        # Find the maximum o in O-order such that p ⊆ theoryOf(o)
        candidates = [o for o in O_elements if p <= theory_of[o]]
        return max(candidates) if candidates else 3

    lower_env_map = {p: lower_env(p) for p in P_elements}

    # Compute thermoClosure = theoryOf ∘ lowerEnv
    thermo_closure = {p: theory_of[lower_env_map[p]] for p in P_elements}

    print("=" * 60)
    print("Example 1: Galois Connection on Finite Posets")
    print("=" * 60)
    print()
    print("P = powerset of {a, b} ordered by inclusion")
    print("O = {0, 1, 2, 3} with natural order")
    print("O^op = {0, 1, 2, 3} with reversed order (3 ≤ 2 ≤ 1 ≤ 0)")
    print()

    print("theoryOf map (O^op → P):")
    for o in O_elements:
        print(f"  theoryOf({o}) = {P_labels[P_elements.index(theory_of[o])]}")
    print()

    print("lowerEnv map (P → O^op):")
    for i, p in enumerate(P_elements):
        print(f"  lowerEnv({P_labels[i]}) = {lower_env_map[p]}")
    print()

    print("Galois connection verification:")
    print("  lowerEnv(p) ≥ o  ⟺  p ⊆ theoryOf(o)")
    for p, o in product(P_elements, O_elements):
        lhs = lower_env_map[p] >= o
        rhs = p <= theory_of[o]
        status = "✓" if lhs == rhs else "✗"
        pi = P_labels[P_elements.index(p)]
        print(f"  {status} lowerEnv({pi})={lower_env_map[p]} ≥ {o} is {lhs}, "
              f"{pi} ⊆ theoryOf({o})={P_labels[P_elements.index(theory_of[o])]} is {rhs}")
    print()

    print("Thermodynamic closure (theoryOf ∘ lowerEnv):")
    for i, p in enumerate(P_elements):
        ci = P_labels[P_elements.index(thermo_closure[p])]
        print(f"  closure({P_labels[i]}) = {ci}")
    print()

    # Verify closure properties
    print("Closure operator properties:")

    # Extensivity
    extensive = all(p <= thermo_closure[p] for p in P_elements)
    print(f"  Extensive (p ⊆ closure(p)): {'✓' if extensive else '✗'}")

    # Monotonicity
    monotone = all(
        thermo_closure[p1] <= thermo_closure[p2]
        for p1 in P_elements for p2 in P_elements if p1 <= p2
    )
    print(f"  Monotone: {'✓' if monotone else '✗'}")

    # Idempotency
    idempotent = all(
        thermo_closure[thermo_closure[p]] == thermo_closure[p]
        for p in P_elements
    )
    print(f"  Idempotent: {'✓' if idempotent else '✗'}")
    print()

    # Fixed points
    fixed_points = {p for p in P_elements if thermo_closure[p] == p}
    range_theory = set(theory_of.values())
    print(f"Fixed points of closure:  {{{', '.join(P_labels[P_elements.index(p)] for p in fixed_points)}}}")
    print(f"Range of theoryOf:        {{{', '.join(P_labels[P_elements.index(p)] for p in range_theory)}}}")
    print(f"Equal (Representation Theorem): {'✓' if fixed_points == range_theory else '✗'}")

    return P_elements, P_labels, O_elements, theory_of, lower_env_map, thermo_closure


# ============================================================
# Example 2: Iterative refinement visualization
# ============================================================

def example_iterative_refinement():
    """
    Demonstrate iterative refinement on a larger lattice.
    We use the divisor lattice of 12: {1, 2, 3, 4, 6, 12}
    """
    print()
    print("=" * 60)
    print("Example 2: Iterative Refinement on Divisor Lattice")
    print("=" * 60)
    print()

    # P = divisors of 12 ordered by divisibility
    P = [1, 2, 3, 4, 6, 12]
    P_labels = {d: str(d) for d in P}

    # O = same lattice, O^op is reverse divisibility
    # theoryOf: O^op → P, monotone in dual order
    # In O^op: 12 ≤ 6 ≤ 3, 12 ≤ 4 ≤ 2, etc.
    # theoryOf should map: if o is "large" in O (small in O^op), map to small theory
    theory_of = {12: 1, 6: 2, 4: 3, 3: 4, 2: 6, 1: 12}

    def lower_env(p):
        # Find max o in O-order such that p divides theoryOf(o)
        candidates = [o for o in P if p <= theory_of[o] or theory_of[o] % p == 0 and p <= theory_of[o]]
        # Actually for divisibility: p | theoryOf(o) means p divides theoryOf(o)
        candidates = [o for o in P if theory_of[o] % p == 0]
        return max(candidates) if candidates else 12

    print("theoryOf map:")
    for o in P:
        print(f"  theoryOf({o}) = {theory_of[o]}")

    print()
    print("lowerEnv map:")
    for p in P:
        print(f"  lowerEnv({p}) = {lower_env(p)}")

    print()
    print("Thermodynamic closure:")
    for p in P:
        cl = theory_of[lower_env(p)]
        print(f"  closure({p}) = {cl}")

    print()
    print("Iterative refinement from p=1:")
    p = 1
    for n in range(5):
        print(f"  step {n}: {p}")
        p_next = theory_of[lower_env(p)]
        if p_next == p:
            print(f"  Stabilized at step {n}!")
            break
        p = p_next
    else:
        print(f"  step 5: {p}")

    print()
    print("Key insight: Since thermoClosure is idempotent,")
    print("refinement always stabilizes after exactly 1 step.")


# ============================================================
# Visualization: Galois Connection Diagram
# ============================================================

def visualize_galois_connection():
    """Create a visual diagram of the Galois connection."""
    if not HAS_MATPLOTLIB:
        print("\n(Visualization skipped: matplotlib not installed)")
        return
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # --- Panel 1: The two posets with maps ---
    ax = axes[0]
    ax.set_xlim(-1, 5)
    ax.set_ylim(-0.5, 4.5)
    ax.set_aspect('equal')
    ax.set_title('Galois Connection\nlowerEnv ⊣ theoryOf', fontsize=14, fontweight='bold')

    # P positions (left side)
    p_pos = {
        '∅': (0.5, 0),
        '{a}': (0, 1.5),
        '{b}': (1, 1.5),
        '{a,b}': (0.5, 3),
    }
    # O^op positions (right side, dual order: 0 at top)
    o_pos = {
        '3': (3.5, 0),
        '2': (3, 1),
        '1': (4, 1),
        '0': (3.5, 3),
    }

    # Draw P edges (Hasse diagram)
    for a, b in [('∅', '{a}'), ('∅', '{b}'), ('{a}', '{a,b}'), ('{b}', '{a,b}')]:
        ax.plot([p_pos[a][0], p_pos[b][0]], [p_pos[a][1], p_pos[b][1]], 'b-', lw=1.5)

    # Draw O^op edges
    for a, b in [('3', '2'), ('3', '1'), ('2', '0'), ('1', '0')]:
        ax.plot([o_pos[a][0], o_pos[b][0]], [o_pos[a][1], o_pos[b][1]], 'r-', lw=1.5)

    # Draw nodes
    for label, pos in p_pos.items():
        ax.plot(*pos, 'bo', markersize=12)
        ax.annotate(label, pos, textcoords="offset points", xytext=(-15, 8),
                   fontsize=10, color='blue', fontweight='bold')

    for label, pos in o_pos.items():
        ax.plot(*pos, 'rs', markersize=12)
        ax.annotate(label, pos, textcoords="offset points", xytext=(8, 0),
                   fontsize=10, color='red', fontweight='bold')

    # Draw lowerEnv arrows (P → O^op)
    env_map = {'∅': '0', '{a}': '2', '{b}': '1', '{a,b}': '3'}
    for p_label, o_label in env_map.items():
        px, py = p_pos[p_label]
        ox, oy = o_pos[o_label]
        ax.annotate('', xy=(ox - 0.15, oy), xytext=(px + 0.15, py),
                   arrowprops=dict(arrowstyle='->', color='green', lw=1.5,
                                  connectionstyle='arc3,rad=0.2'))

    ax.text(0.5, 4.2, 'P', fontsize=14, color='blue', fontweight='bold', ha='center')
    ax.text(3.5, 4.2, 'O^op', fontsize=14, color='red', fontweight='bold', ha='center')
    ax.text(2, 2, 'lowerEnv →', fontsize=10, color='green', ha='center', rotation=0)
    ax.axis('off')

    # --- Panel 2: Closure operator ---
    ax = axes[1]
    ax.set_xlim(-1, 3)
    ax.set_ylim(-0.5, 4.5)
    ax.set_aspect('equal')
    ax.set_title('Thermodynamic Closure\nc(p) = theoryOf(lowerEnv(p))', fontsize=14, fontweight='bold')

    # Show P with closure arrows
    closure_map = {'∅': '{a,b}', '{a}': '{a}', '{b}': '{b}', '{a,b}': '{a,b}'}
    for label, pos in p_pos.items():
        cl = closure_map[label]
        is_fixed = (label == cl)
        color = 'darkgreen' if is_fixed else 'gray'
        marker = 'D' if is_fixed else 'o'
        ax.plot(*pos, marker=marker, color=color, markersize=14)
        ax.annotate(label, pos, textcoords="offset points", xytext=(-15, 10),
                   fontsize=10, color=color, fontweight='bold')

    # Draw P edges
    for a, b in [('∅', '{a}'), ('∅', '{b}'), ('{a}', '{a,b}'), ('{b}', '{a,b}')]:
        ax.plot([p_pos[a][0], p_pos[b][0]], [p_pos[a][1], p_pos[b][1]], 'k-', lw=1, alpha=0.3)

    # Draw closure arrows
    for label, cl in closure_map.items():
        if label != cl:
            px, py = p_pos[label]
            cx, cy = p_pos[cl]
            ax.annotate('', xy=(cx, cy - 0.2), xytext=(px, py + 0.2),
                       arrowprops=dict(arrowstyle='->', color='purple', lw=2,
                                      connectionstyle='arc3,rad=0.3'))

    fixed = mpatches.Patch(color='darkgreen', label='Fixed points (closed)')
    mobile = mpatches.Patch(color='gray', label='Non-fixed (open)')
    ax.legend(handles=[fixed, mobile], loc='lower right', fontsize=9)
    ax.axis('off')

    # --- Panel 3: Refinement convergence ---
    ax = axes[2]
    ax.set_title('Refinement Convergence\n(stabilizes after 1 step)', fontsize=14, fontweight='bold')

    # Show convergence for different starting points
    starts = ['∅', '{a}', '{b}', '{a,b}']
    closures = ['{a,b}', '{a}', '{b}', '{a,b}']
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

    for i, (start, cl) in enumerate(zip(starts, closures)):
        steps = list(range(5))
        # Value index for plotting
        val_map = {'∅': 0, '{a}': 1, '{b}': 2, '{a,b}': 3}
        values = [val_map[start]] + [val_map[cl]] * 4
        ax.plot(steps, values, 'o-', color=colors[i], label=f'start={start}',
               markersize=8, lw=2)

    ax.set_xlabel('Iteration step n', fontsize=12)
    ax.set_ylabel('Proof state (index)', fontsize=12)
    ax.set_yticks([0, 1, 2, 3])
    ax.set_yticklabels(['∅', '{a}', '{b}', '{a,b}'])
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('thermo_galois_demo.png', dpi=150, bbox_inches='tight')
    plt.savefig('thermo_galois_demo.pdf', bbox_inches='tight')
    print()
    print("Saved visualization to thermo_galois_demo.png and .pdf")


# ============================================================
# Example 3: The Representation Theorem in action
# ============================================================

def example_representation_theorem():
    """
    Demonstrate the Representation Theorem:
    Fixed points of thermoClosure = Range of theoryOf
    """
    print()
    print("=" * 60)
    print("Example 3: The Representation Theorem")
    print("=" * 60)
    print()
    print("Theorem (formally verified in Lean 4):")
    print("  {p : P | thermoClosure p = p} = Set.range theoryOf")
    print()
    print("This means: a proof state is derivability-closed")
    print("if and only if it is cut out by some thermodynamic observable.")
    print()
    print("Interpretation:")
    print("  • 'Derivability-closed' = applying the closure doesn't change it")
    print("  • 'Cut out by an observable' = equals theoryOf(o) for some o")
    print("  • The theorem says these are THE SAME THING")
    print()
    print("This is the conceptual bridge: proof-theoretic closure")
    print("is identified with thermodynamic observable selection.")
    print()
    print("Consequences:")
    print("  1. Every closed theory has a 'thermodynamic witness' (an observable)")
    print("  2. Every observable determines a unique closed theory")
    print("  3. Proof search becomes observable optimization:")
    print("     finding the right observable = finding the closed theory")


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║   Lawvere–Thermodynamic Galois Correspondence Demo         ║")
    print("║   All theorems formally verified in Lean 4 with Mathlib    ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    example_galois_connection()
    example_iterative_refinement()
    example_representation_theorem()

    try:
        visualize_galois_connection()
    except Exception as e:
        print(f"\n(Visualization skipped: {e})")
        print("Install matplotlib to generate diagrams: pip install matplotlib")

    print()
    print("=" * 60)
    print("Summary of Formally Verified Results (Lean 4)")
    print("=" * 60)
    print("""
1. thermoClosure = theoryOf ∘ lowerEnv is a closure operator
   (extensive, monotone, idempotent)

2. Representation Theorem:
   {p | thermoClosure p = p} = range(theoryOf)
   "Closed theories ARE observable-determined theories"

3. Derivability characterization:
   thermoClosure p = p ⟺ ∃ o, theoryOf(o) = p

4. Closure uniqueness:
   Any closure with the same fixed points equals thermoClosure

5. Finite stabilization:
   Iterative refinement stabilizes after 1 step (by idempotency)
   On finite posets, bounded by Fintype.card P steps

6. Limit closure:
   The stabilized value is a fixed point of thermoClosure
""")
