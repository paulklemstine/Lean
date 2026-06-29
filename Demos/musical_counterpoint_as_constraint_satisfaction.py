"""
Musical Counterpoint as Constraint Satisfaction — Demo

Demonstrates the key results: cost function properties, lattice-cost identity,
optimal voice leading, and constraint satisfaction.
"""

from algorithms import (
    voice_leading_cost, lattice_meet, lattice_join, verify_lattice_cost_identity,
    no_parallel_fifths, no_parallel_octaves, stepwise_motion,
    CounterpointSystem, consonance_score, pitch_class, chord_interval
)


def demo_cost_properties():
    """Demonstrate voice leading cost function properties."""
    print("=" * 60)
    print("VOICE LEADING COST FUNCTION PROPERTIES")
    print("=" * 60)

    m1 = (2, -1, 0, 3)
    m2 = (-1, 2, 1, -2)

    print(f"\nMotion m₁ = {m1}")
    print(f"Motion m₂ = {m2}")
    print(f"Cost(m₁) = {voice_leading_cost(m1)}")
    print(f"Cost(m₂) = {voice_leading_cost(m2)}")

    m_sum = tuple(a + b for a, b in zip(m1, m2))
    print(f"\nm₁ + m₂ = {m_sum}")
    print(f"Cost(m₁ + m₂) = {voice_leading_cost(m_sum)}")
    print(f"Cost(m₁) + Cost(m₂) = {voice_leading_cost(m1) + voice_leading_cost(m2)}")
    print(f"Triangle inequality holds: {voice_leading_cost(m_sum) <= voice_leading_cost(m1) + voice_leading_cost(m2)}")

    m_neg = tuple(-x for x in m1)
    print(f"\n-m₁ = {m_neg}")
    print(f"Cost(-m₁) = {voice_leading_cost(m_neg)} = Cost(m₁) = {voice_leading_cost(m1)}")

    # Homogeneity
    c = 3
    m_scaled = tuple(c * x for x in m1)
    print(f"\n{c} · m₁ = {m_scaled}")
    print(f"Cost({c}·m₁) = {voice_leading_cost(m_scaled)}")
    print(f"|{c}| · Cost(m₁) = {abs(c) * voice_leading_cost(m1)}")
    print(f"Homogeneity holds: {voice_leading_cost(m_scaled) == abs(c) * voice_leading_cost(m1)}")


def demo_lattice_cost_identity():
    """Demonstrate the L¹-lattice identity: cost(meet) + cost(join) = cost(m₁) + cost(m₂)."""
    print("\n" + "=" * 60)
    print("L¹-LATTICE IDENTITY")
    print("=" * 60)

    test_cases = [
        ((2, -1, 3), (-1, 2, -2)),
        ((1, 1, 1, 1), (2, 2, 2, 2)),
        ((-3, 5, -1), (4, -2, 3)),
        ((0, 0, 0), (1, -1, 2)),
        ((7, -3, 2, -5), (-2, 4, -1, 6)),
    ]

    all_pass = True
    for m1, m2 in test_cases:
        meet = lattice_meet(m1, m2)
        join = lattice_join(m1, m2)
        lhs = voice_leading_cost(meet) + voice_leading_cost(join)
        rhs = voice_leading_cost(m1) + voice_leading_cost(m2)

        passed = verify_lattice_cost_identity(m1, m2)
        all_pass = all_pass and passed

        print(f"\nm₁={m1}, m₂={m2}")
        print(f"  meet={meet}, join={join}")
        print(f"  Cost(meet)={voice_leading_cost(meet)}, Cost(join)={voice_leading_cost(join)}")
        print(f"  LHS={lhs}, RHS={rhs}, Identity holds: {passed}")

    print(f"\n{'All tests passed!' if all_pass else 'SOME TESTS FAILED!'}")


def demo_counterpoint_constraints():
    """Demonstrate counterpoint constraint satisfaction."""
    print("\n" + "=" * 60)
    print("COUNTERPOINT CONSTRAINT SATISFACTION")
    print("=" * 60)

    # C major chord in SATB voicing: C3(48), E3(52), G3(55), C4(60)
    source = (48, 52, 55, 60)
    print(f"\nSource chord (SATB): C3={source[0]}, E3={source[1]}, G3={source[2]}, C4={source[3]}")

    # Check intervals
    for i in range(4):
        for j in range(i + 1, 4):
            interval = chord_interval(source, i, j)
            pc = pitch_class(interval)
            print(f"  Interval {i}→{j}: {interval} semitones (class {pc}, consonance={consonance_score(pc)})")

    # Set up system with standard counterpoint rules
    system = CounterpointSystem(
        source=source,
        constraints=[no_parallel_fifths, no_parallel_octaves, stepwise_motion(4)]
    )

    # Find optimal voice leading
    print("\nSearching for optimal voice leading (bound=4)...")
    feasible = system.enumerate_feasible(4)
    print(f"Total feasible motions: {len(feasible)}")

    if feasible:
        best_motion, best_cost = feasible[0]
        print(f"Optimal motion: {best_motion} with cost {best_cost}")
        target = tuple(source[i] + best_motion[i] for i in range(4))
        print(f"Target chord: {target}")

        # Show top 5
        print("\nTop 5 feasible motions by cost:")
        for motion, cost in feasible[:5]:
            target = tuple(source[i] + motion[i] for i in range(4))
            print(f"  {motion} → cost={cost}, target={target}")


def demo_ascending_sublattice():
    """Demonstrate that ascending motions form a sublattice."""
    print("\n" + "=" * 60)
    print("ASCENDING MOTION SUBLATTICE")
    print("=" * 60)

    # Two ascending motions
    m1 = (1, 3, 2, 0)
    m2 = (2, 1, 4, 1)

    print(f"\nm₁ = {m1} (ascending: {all(x >= 0 for x in m1)})")
    print(f"m₂ = {m2} (ascending: {all(x >= 0 for x in m2)})")

    meet = lattice_meet(m1, m2)
    join = lattice_join(m1, m2)

    print(f"\nMeet = {meet} (ascending: {all(x >= 0 for x in meet)})")
    print(f"Join = {join} (ascending: {all(x >= 0 for x in join)})")

    print(f"\nCost(m₁) = {voice_leading_cost(m1)} = sum(m₁) = {sum(m1)}")
    print(f"Cost(m₂) = {voice_leading_cost(m2)} = sum(m₂) = {sum(m2)}")
    print(f"Cost(meet) = {voice_leading_cost(meet)} ≤ Cost(m₁) = {voice_leading_cost(m1)}: "
          f"{voice_leading_cost(meet) <= voice_leading_cost(m1)}")
    print(f"Cost(meet) = {voice_leading_cost(meet)} ≤ Cost(m₂) = {voice_leading_cost(m2)}: "
          f"{voice_leading_cost(meet) <= voice_leading_cost(m2)}")


def demo_parallel_motion():
    """Demonstrate interval preservation under parallel motion."""
    print("\n" + "=" * 60)
    print("INTERVAL PRESERVATION UNDER PARALLEL MOTION")
    print("=" * 60)

    source = (48, 55, 60, 67)  # C3, G3, C4, G4
    print(f"\nSource: {source}")

    # Parallel motion: all voices move by +2
    parallel = (2, 2, 2, 2)
    target_p = tuple(source[i] + parallel[i] for i in range(4))
    print(f"\nParallel motion {parallel}:")
    print(f"  Target: {target_p}")
    for i in range(4):
        for j in range(i + 1, 4):
            old_int = chord_interval(source, i, j)
            new_int = chord_interval(target_p, i, j)
            print(f"  Interval {i}→{j}: {old_int} → {new_int} ({'preserved ✓' if old_int == new_int else 'changed ✗'})")

    # Non-parallel motion
    non_parallel = (2, 1, 3, 0)
    target_np = tuple(source[i] + non_parallel[i] for i in range(4))
    print(f"\nNon-parallel motion {non_parallel}:")
    print(f"  Target: {target_np}")
    for i in range(4):
        for j in range(i + 1, 4):
            old_int = chord_interval(source, i, j)
            new_int = chord_interval(target_np, i, j)
            print(f"  Interval {i}→{j}: {old_int} → {new_int} ({'preserved ✓' if old_int == new_int else 'changed ✗'})")


if __name__ == "__main__":
    demo_cost_properties()
    demo_lattice_cost_identity()
    demo_counterpoint_constraints()
    demo_ascending_sublattice()
    demo_parallel_motion()


"""
Visualization of voice leading cost landscape and lattice structure.
Standalone script using matplotlib.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def voice_leading_cost(motion):
    return sum(abs(m) for m in motion)


def lattice_meet(m1, m2):
    return tuple(min(a, b) for a, b in zip(m1, m2))


def lattice_join(m1, m2):
    return tuple(max(a, b) for a, b in zip(m1, m2))


def pitch_class(p):
    return p % 12


def no_parallel_fifths(source, motion):
    n = len(source)
    for i in range(n):
        for j in range(i + 1, n):
            if pitch_class(source[j] - source[i]) == 7:
                if motion[i] == motion[j]:
                    return False
    return True


def no_parallel_octaves(source, motion):
    n = len(source)
    for i in range(n):
        for j in range(i + 1, n):
            interval = source[j] - source[i]
            if pitch_class(interval) == 0 and interval != 0:
                if motion[i] == motion[j]:
                    return False
    return True


def plot_cost_landscape():
    """Plot the voice leading cost function for 2 voices as a heatmap."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Cost landscape
    bound = 6
    x = np.arange(-bound, bound + 1)
    y = np.arange(-bound, bound + 1)
    X, Y = np.meshgrid(x, y)
    Z = np.abs(X) + np.abs(Y)

    ax = axes[0]
    im = ax.contourf(X, Y, Z, levels=20, cmap='viridis_r')
    ax.set_xlabel('Voice 1 Motion (semitones)')
    ax.set_ylabel('Voice 2 Motion (semitones)')
    ax.set_title('Voice Leading Cost (L¹ Norm)')
    plt.colorbar(im, ax=ax, label='Cost')
    ax.set_aspect('equal')

    # Lattice meet/join illustration
    ax = axes[1]
    m1 = (3, -2)
    m2 = (-1, 4)
    meet = lattice_meet(m1, m2)
    join = lattice_join(m1, m2)

    points = {'m₁': m1, 'm₂': m2, 'meet': meet, 'join': join}
    colors = {'m₁': 'blue', 'm₂': 'red', 'meet': 'green', 'join': 'purple'}

    for name, pt in points.items():
        ax.plot(pt[0], pt[1], 'o', color=colors[name], markersize=12, zorder=5)
        ax.annotate(f'{name}\n{pt}\ncost={voice_leading_cost(pt)}',
                    xy=pt, xytext=(10, 10), textcoords='offset points',
                    fontsize=9, fontweight='bold')

    # Draw lattice edges
    ax.plot([meet[0], m1[0]], [meet[1], m1[1]], 'k--', alpha=0.5)
    ax.plot([meet[0], m2[0]], [meet[1], m2[1]], 'k--', alpha=0.5)
    ax.plot([m1[0], join[0]], [m1[1], join[1]], 'k--', alpha=0.5)
    ax.plot([m2[0], join[0]], [m2[1], join[1]], 'k--', alpha=0.5)

    # Verify identity
    lhs = voice_leading_cost(meet) + voice_leading_cost(join)
    rhs = voice_leading_cost(m1) + voice_leading_cost(m2)
    ax.set_title(f'Lattice Structure\ncost(⊓)+cost(⊔)={lhs} = cost(m₁)+cost(m₂)={rhs}')
    ax.set_xlabel('Voice 1')
    ax.set_ylabel('Voice 2')
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    # Feasible region under constraints
    ax = axes[2]
    source = (48, 55)  # C3, G3 (perfect fifth)
    bound = 4

    feasible_x, feasible_y = [], []
    infeasible_x, infeasible_y = [], []
    costs = []

    for m1_val in range(-bound, bound + 1):
        for m2_val in range(-bound, bound + 1):
            motion = (m1_val, m2_val)
            if no_parallel_fifths(source, motion):
                feasible_x.append(m1_val)
                feasible_y.append(m2_val)
                costs.append(voice_leading_cost(motion))
            else:
                infeasible_x.append(m1_val)
                infeasible_y.append(m2_val)

    sc = ax.scatter(feasible_x, feasible_y, c=costs, cmap='viridis_r',
                    s=80, zorder=3, edgecolors='black', linewidth=0.5)
    ax.scatter(infeasible_x, infeasible_y, c='red', s=40, marker='x',
               alpha=0.5, zorder=2, label='Parallel 5ths (forbidden)')
    plt.colorbar(sc, ax=ax, label='Cost')
    ax.set_xlabel('Voice 1 Motion')
    ax.set_ylabel('Voice 2 Motion')
    ax.set_title('Feasible Region\n(Source: C3-G3, no parallel 5ths)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    plt.tight_layout()
    plt.savefig('counterpoint_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved counterpoint_landscape.png")


def plot_consonance_lattice():
    """Plot the consonance ordering of interval classes."""
    fig, ax = plt.subplots(figsize=(10, 8))

    CONSONANCE_SCORE = {
        0: 8, 7: 7, 5: 6, 4: 5, 3: 5, 9: 4, 8: 4,
        2: 2, 1: 1, 10: 1, 11: 1, 6: 0
    }

    NAMES = {
        0: 'Unison/Oct', 7: 'P5', 5: 'P4', 4: 'M3', 3: 'm3',
        9: 'M6', 8: 'm6', 2: 'M2', 1: 'm2', 10: 'm7', 11: 'M7', 6: 'Tritone'
    }

    COLORS = {8: '#2196F3', 7: '#2196F3', 6: '#4CAF50', 5: '#8BC34A',
              4: '#FF9800', 2: '#FF5722', 1: '#F44336', 0: '#9C27B0'}

    # Group by score
    by_score = {}
    for ic, score in CONSONANCE_SCORE.items():
        by_score.setdefault(score, []).append(ic)

    for score, ics in sorted(by_score.items()):
        y = score
        for idx, ic in enumerate(ics):
            x = idx - (len(ics) - 1) / 2
            color = COLORS.get(score, 'gray')
            ax.scatter(x, y, s=800, c=color, zorder=5, edgecolors='black', linewidth=2)
            ax.text(x, y, f'{NAMES[ic]}\n({ic})', ha='center', va='center',
                    fontsize=8, fontweight='bold', color='white')

    ax.set_ylabel('Consonance Score', fontsize=14)
    ax.set_title('Consonance Lattice of Interval Classes', fontsize=16)
    ax.set_yticks(range(9))
    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-0.5, 8.5)

    # Add consonance/dissonance regions
    ax.axhspan(3.5, 8.5, alpha=0.1, color='green', label='Consonant (≥4)')
    ax.axhspan(-0.5, 3.5, alpha=0.1, color='red', label='Dissonant (<4)')
    ax.axhspan(5.5, 8.5, alpha=0.1, color='blue', label='Perfect (≥6)')
    ax.legend(loc='upper left', fontsize=10)

    ax.grid(True, alpha=0.2, axis='y')
    ax.set_xticks([])

    plt.tight_layout()
    plt.savefig('consonance_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved consonance_lattice.png")


if __name__ == "__main__":
    plot_cost_landscape()
    plot_consonance_lattice()
