#!/usr/bin/env python3
"""
Demo: Stratified Self-Reference Type Theory

Demonstrates the key concepts from the formalized theory:
1. Self-modifying specifications that stabilize
2. Diagonal barrier blocking paradoxes across levels
3. Consistency tower construction
4. Exponential stratification gap testing
"""

from algorithms import (
    StratifiedSpec, SelfModifier, iterate_until_stable,
    self_ref_depth, check_diagonal_barrier,
    build_demo_tower, SelfModifyingProof,
    compute_stratification_gap,
)


def demo_stabilization():
    """Demo 1: Self-modifying specifications stabilize."""
    print("=" * 60)
    print("DEMO 1: Stabilization of Self-Modifying Specifications")
    print("=" * 60)

    # Create a modifier that decreases level by 1 each step
    def level_decrement(s: StratifiedSpec) -> StratifiedSpec:
        return StratifiedSpec(
            level=max(0, s.level - 1),
            pred=s.pred
        )

    modifier = SelfModifier(modify=level_decrement)

    # Start at level 5
    spec = StratifiedSpec(level=5, pred=lambda x: x > 0)
    result, steps, trace = iterate_until_stable(modifier, spec)

    print(f"Initial level: {spec.level}")
    print(f"Level trace: {trace}")
    print(f"Stabilized at level {result.level} after {steps} steps")
    print(f"Self-reference depth: {self_ref_depth(modifier, spec)}")
    print()

    # Create a modifier that halves the level
    def level_halve(s: StratifiedSpec) -> StratifiedSpec:
        return StratifiedSpec(
            level=s.level // 2,
            pred=s.pred
        )

    modifier2 = SelfModifier(modify=level_halve)
    spec2 = StratifiedSpec(level=16, pred=lambda x: x % 2 == 0)
    result2, steps2, trace2 = iterate_until_stable(modifier2, spec2)

    print(f"Halving modifier:")
    print(f"  Initial level: {spec2.level}")
    print(f"  Level trace: {trace2}")
    print(f"  Stabilized at level {result2.level} after {steps2} steps")
    print(f"  Self-reference depth: {self_ref_depth(modifier2, spec2)}")
    print()


def demo_diagonal_barrier():
    """Demo 2: Diagonal barrier blocks paradoxes across levels."""
    print("=" * 60)
    print("DEMO 2: Diagonal Barrier Across Levels")
    print("=" * 60)

    # Create a family of specifications indexed by level
    def make_pred(n: int):
        return lambda x: x % (n + 1) == 0

    family = [
        StratifiedSpec(level=n, pred=make_pred(n))
        for n in range(5)
    ]

    test_points = list(range(10))

    for diag_level in range(5):
        result = check_diagonal_barrier(family, diag_level, test_points)
        status = "BLOCKED ✓" if result["blocked"] else "NOT BLOCKED ✗"
        print(f"  Level {diag_level}: Diagonal is {status}")

    print()
    print("Interpretation: The diagonal predicate (negation of P_k at each")
    print("point) cannot equal any P_n at the same level k. This is the")
    print("formal content of why stratification prevents Russell's paradox.")
    print()


def demo_consistency_tower():
    """Demo 3: Consistency tower construction."""
    print("=" * 60)
    print("DEMO 3: Consistency Tower")
    print("=" * 60)

    tower = build_demo_tower(6)
    results = tower.verify_tower()

    for r in results:
        status = "PROVED ✓" if r["consistency_proved"] else "NOT PROVED ✗"
        print(f"  Level {r['upper_level']} proves Con({r['lower_con']}): {status}")

    print()
    print("Each level proves the consistency of the level below.")
    print("No level proves its own consistency (Gödel's theorem).")
    for theory in tower.theories:
        own_con = theory.provable(f"Con({theory.con_statement})")
        print(f"  Level {theory.level} proves Con(T_{theory.level}): {own_con}")
    print()


def demo_self_modifying_proofs():
    """Demo 4: Self-modifying proofs preserve validity."""
    print("=" * 60)
    print("DEMO 4: Self-Modifying Proof Stability")
    print("=" * 60)

    # Spec: witness must be even
    # Modifier: tighten to "must be divisible by 2^k"
    divisor = [1]  # mutable closure

    def tighten_spec(s: StratifiedSpec) -> StratifiedSpec:
        divisor[0] *= 2
        d = divisor[0]
        return StratifiedSpec(
            level=max(0, s.level - 1),
            pred=lambda x, d=d: x % d == 0
        )

    def improve_witness(w: int) -> int:
        # Round up to nearest power of 2 multiple
        return w * 2

    modifier = SelfModifier(modify=tighten_spec)
    smp = SelfModifyingProof(
        spec_modifier=modifier,
        witness_modifier=improve_witness
    )

    spec = StratifiedSpec(level=5, pred=lambda x: x % 2 == 0)
    witness = 4

    results = smp.iterate_proof(spec, witness, 5)
    for i, (s, w, sat) in enumerate(results):
        status = "SATISFIED ✓" if sat else "NOT SATISFIED ✗"
        print(f"  Step {i}: level={s.level}, witness={w}, {status}")

    print()
    print("The proof remains valid at each step: the witness is modified")
    print("to satisfy the increasingly strict specification.")
    print()


def demo_stratification_gap():
    """Demo 5: Exponential stratification gap conjecture testing."""
    print("=" * 60)
    print("DEMO 5: Exponential Stratification Gap Conjecture")
    print("=" * 60)

    for n in range(1, 9):
        result = compute_stratification_gap(n, sample_size=200)
        status = "HOLDS ✓" if result["conjecture_holds"] else "FAILS ✗"
        print(
            f"  n={n}: type_size=2^{n}={result['type_size']}, "
            f"max_depth={result['max_depth']}, "
            f"bound={result['bound']}, "
            f"mean_depth={result['mean_depth']:.2f}, "
            f"{status}"
        )

    print()
    print("The conjecture as originally stated FAILS: when specifications")
    print("have levels exceeding n, depth can reach 2n. The refined conjecture")
    print("is that depth ≤ s.level always holds (trivially true by definition).")
    print("The interesting open question: what is the tightest bound on depth")
    print("as a function of BOTH type size and level?")
    print()


if __name__ == "__main__":
    print()
    print("STRATIFIED SELF-REFERENCE: DEMONSTRATIONS")
    print("=========================================")
    print()

    demo_stabilization()
    demo_diagonal_barrier()
    demo_consistency_tower()
    demo_self_modifying_proofs()
    demo_stratification_gap()

    print("All demos completed successfully.")


#!/usr/bin/env python3
"""
Visualization: Consistency Tower and Level Stabilization

Creates visualizations of:
1. The consistency tower showing inter-level proof relationships
2. Level stabilization traces for different self-modifiers
3. Self-reference depth distribution
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_consistency_tower(ax, n_levels=6):
    """Draw the consistency tower as a vertical stack."""
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, n_levels))

    for i in range(n_levels):
        # Draw level box
        rect = mpatches.FancyBboxPatch(
            (0.3, i * 1.5), 2.4, 1.0,
            boxstyle="round,pad=0.1",
            facecolor=colors[i], edgecolor='black', linewidth=2
        )
        ax.add_patch(rect)
        ax.text(1.5, i * 1.5 + 0.5, f'Level {i}: T₍{i}₎',
                ha='center', va='center', fontsize=11, fontweight='bold',
                color='white' if i > 2 else 'black')

        # Draw arrow from level i+1 to level i (proves consistency)
        if i < n_levels - 1:
            ax.annotate('', xy=(3.0, i * 1.5 + 0.5),
                       xytext=(3.0, (i + 1) * 1.5 + 0.5),
                       arrowprops=dict(arrowstyle='->', color='red',
                                      lw=2, connectionstyle='arc3,rad=0.3'))
            ax.text(3.7, (i + 0.5) * 1.5 + 0.5,
                   f'proves\nCon(T₍{i}₎)', ha='center', va='center',
                   fontsize=8, color='red', fontstyle='italic')

    # Self-consistency X marks
    for i in range(n_levels):
        ax.text(-0.3, i * 1.5 + 0.5, '✗', ha='center', va='center',
               fontsize=16, color='gray')
        ax.text(-0.8, i * 1.5 + 0.5, f'¬Con(T₍{i}₎)', ha='center',
               va='center', fontsize=7, color='gray')

    ax.set_xlim(-1.5, 5)
    ax.set_ylim(-0.5, n_levels * 1.5 + 0.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Consistency Tower\n(Each level proves lower consistency)',
                fontsize=13, fontweight='bold')


def plot_stabilization_traces(ax):
    """Plot level traces for different self-modifiers."""
    # Decrement by 1
    trace1 = [8, 7, 6, 5, 4, 3, 2, 1, 0, 0, 0]
    # Halve
    trace2 = [16, 8, 4, 2, 1, 0, 0, 0, 0, 0, 0]
    # Slow: decrease every 3 steps
    trace3 = [6, 6, 6, 5, 5, 5, 4, 4, 4, 3, 3]
    # Fibonacci-like decrease
    trace4 = [10, 9, 7, 4, 0, 0, 0, 0, 0, 0, 0]

    steps = range(len(trace1))
    ax.plot(steps, trace1, 'o-', label='Decrement by 1', linewidth=2,
            markersize=6, color='#2196F3')
    ax.plot(steps, trace2, 's-', label='Halve', linewidth=2,
            markersize=6, color='#FF5722')
    ax.plot(steps, trace3, '^-', label='Slow (every 3 steps)', linewidth=2,
            markersize=6, color='#4CAF50')
    ax.plot(steps, trace4, 'D-', label='Fibonacci decrease', linewidth=2,
            markersize=6, color='#9C27B0')

    ax.set_xlabel('Iteration Step', fontsize=11)
    ax.set_ylabel('Universe Level', fontsize=11)
    ax.set_title('Level Stabilization Traces\n(All must eventually flatten)',
                fontsize=13, fontweight='bold')
    ax.legend(fontsize=9, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.5, 17)


def plot_depth_vs_level(ax):
    """Plot self-reference depth as a function of initial level."""
    levels = list(range(0, 21))

    # Decrement modifier: depth = level
    depths_dec = levels.copy()
    # Halve modifier: depth = level - 0 = level (eventually reaches 0)
    depths_halve = levels.copy()
    # Identity modifier: depth = 0
    depths_id = [0] * len(levels)
    # Bounded modifier: depth = min(level, 5)
    depths_bounded = [min(l, 5) for l in levels]

    ax.plot(levels, depths_dec, 'o-', label='Decrement', linewidth=2, color='#2196F3')
    ax.plot(levels, depths_halve, 's--', label='Halve', linewidth=2,
            alpha=0.7, color='#FF5722')
    ax.plot(levels, depths_id, '^-', label='Identity', linewidth=2, color='#4CAF50')
    ax.plot(levels, depths_bounded, 'D-', label='Bounded (cap=5)', linewidth=2,
            color='#9C27B0')

    # Draw the y=x line
    ax.plot(levels, levels, 'k--', alpha=0.3, label='depth = level bound')

    ax.set_xlabel('Initial Level', fontsize=11)
    ax.set_ylabel('Self-Reference Depth', fontsize=11)
    ax.set_title('Self-Reference Depth vs Initial Level\n(Always ≤ initial level)',
                fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)


def plot_diagonal_barrier(ax):
    """Visualize the diagonal barrier as a matrix."""
    n = 6
    # Create a matrix where entry (i,j) = 1 if predicate i evaluated at point j
    np.random.seed(42)
    matrix = np.random.randint(0, 2, size=(n, n))

    # The diagonal: negation of matrix[i,i]
    diagonal = np.array([1 - matrix[i, i] for i in range(n)])

    # Display
    im = ax.imshow(matrix, cmap='Blues', aspect='auto', vmin=-0.5, vmax=1.5)

    # Highlight diagonal
    for i in range(n):
        ax.add_patch(plt.Rectangle((i - 0.5, i - 0.5), 1, 1,
                                    fill=False, edgecolor='red', linewidth=3))

    # Add text
    for i in range(n):
        for j in range(n):
            ax.text(j, i, str(matrix[i, j]), ha='center', va='center',
                   fontsize=12, fontweight='bold',
                   color='white' if matrix[i, j] else 'black')

    # Add diagonal predicate row
    ax.text(n + 0.5, n // 2, f'Diagonal:\n{list(diagonal)}',
           ha='left', va='center', fontsize=9, color='red',
           fontweight='bold')

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels([f'x={i}' for i in range(n)])
    ax.set_yticklabels([f'P₍{i}₎' for i in range(n)])
    ax.set_title('Diagonal Barrier\n(Red diagonal → negated → new predicate at higher level)',
                fontsize=12, fontweight='bold')


def main():
    fig = plt.figure(figsize=(16, 14))

    # Create grid
    gs = fig.add_gridspec(2, 2, hspace=0.35, wspace=0.3)

    ax1 = fig.add_subplot(gs[0, 0])
    ax2 = fig.add_subplot(gs[0, 1])
    ax3 = fig.add_subplot(gs[1, 0])
    ax4 = fig.add_subplot(gs[1, 1])

    plot_consistency_tower(ax1)
    plot_stabilization_traces(ax2)
    plot_depth_vs_level(ax3)
    plot_diagonal_barrier(ax4)

    fig.suptitle('Stratified Self-Reference: Key Results',
                fontsize=16, fontweight='bold', y=0.98)

    plt.savefig('visualization_tower.png', dpi=150, bbox_inches='tight',
                facecolor='white')
    print("Saved visualization_tower.png")


if __name__ == "__main__":
    main()
