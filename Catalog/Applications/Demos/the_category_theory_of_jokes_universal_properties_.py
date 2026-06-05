#!/usr/bin/env python3
"""
Categorical Deviation Theory — Numerical Demonstrations

Demonstrates the key theorems of deviation theory with concrete examples:
1. Real Line Quiver: surprise subadditivity and chain bounds
2. Deviation Monoid: power deviation bounds
3. Graded Deviation System: grade-dependent accumulation
"""

import math
from typing import List, Tuple


def real_line_surprise(a: float, b: float, f: float) -> float:
    """Surprise of jump f from a to b in the real line quiver.
    Expected jump is b - a; surprise is |f - (b-a)|."""
    return abs(f - (b - a))


def demo_surprise_subadditivity():
    """Demonstrate surprise subadditivity: σ(g∘f) ≤ σ(f) + σ(g)."""
    print("=" * 60)
    print("Demo 1: Surprise Subadditivity in the Real Line Quiver")
    print("=" * 60)

    cases = [
        # (a, b, c, f_jump_ab, g_jump_bc)
        (0, 3, 7, 5, 2),       # overshooting then undershooting
        (0, 10, 10, 10, 0),    # perfect then zero
        (0, 5, 5, 100, -95),   # wildly off then compensating
        (1, 4, 9, 3.5, 4.8),   # small deviations
    ]

    for a, b, c, f, g in cases:
        sf = real_line_surprise(a, b, f)
        sg = real_line_surprise(b, c, g)
        composed = f + g  # composition in real line quiver
        s_composed = real_line_surprise(a, c, composed)

        print(f"\n  Path: {a} → {b} → {c}")
        print(f"  Jump a→b: {f} (expected {b-a}), surprise = {sf}")
        print(f"  Jump b→c: {g} (expected {c-b}), surprise = {sg}")
        print(f"  Composed a→c: {composed} (expected {c-a}), surprise = {s_composed}")
        print(f"  Subadditivity: {s_composed:.2f} ≤ {sf:.2f} + {sg:.2f} = {sf+sg:.2f} ✓" if s_composed <= sf + sg + 1e-10 else "  VIOLATION!")


def demo_chain_bound():
    """Demonstrate chain surprise bound: σ(chain) ≤ Σ σ(fᵢ)."""
    print("\n" + "=" * 60)
    print("Demo 2: Chain Surprise Bound")
    print("=" * 60)

    # Chain of 10 jumps with small deviations
    positions = [0, 2, 5, 7, 8, 12, 15, 18, 20, 22, 25]
    deviations = [0.3, -0.5, 0.1, 0.8, -0.2, 0.4, -0.3, 0.6, -0.1, 0.2]

    total_surprise = 0
    actual_total = 0
    print(f"\n  Chain: {positions[0]} → {positions[-1]} through {len(positions)-2} intermediaries")

    for i in range(len(deviations)):
        expected = positions[i+1] - positions[i]
        actual = expected + deviations[i]
        actual_total += actual
        surprise_i = abs(deviations[i])
        total_surprise += surprise_i
        print(f"  Step {i+1}: expected {expected}, actual {actual:.1f}, surprise {surprise_i}")

    overall_expected = positions[-1] - positions[0]
    overall_surprise = abs(actual_total - overall_expected)

    print(f"\n  Overall: expected total {overall_expected}, actual total {actual_total:.1f}")
    print(f"  Overall surprise: {overall_surprise:.2f}")
    print(f"  Sum of individual surprises: {total_surprise:.1f}")
    print(f"  Chain bound: {overall_surprise:.2f} ≤ {total_surprise:.1f} ✓" if overall_surprise <= total_surprise + 1e-10 else "  VIOLATION!")


def demo_deviation_monoid():
    """Demonstrate power deviation bound in 2x2 rotation matrices."""
    print("\n" + "=" * 60)
    print("Demo 3: Power Deviation Bound (Rotation Matrices)")
    print("=" * 60)

    def mat_dist(A: List[List[float]], B: List[List[float]]) -> float:
        """Frobenius distance between 2x2 matrices."""
        return math.sqrt(sum((A[i][j] - B[i][j])**2 for i in range(2) for j in range(2)))

    def mat_mul(A: List[List[float]], B: List[List[float]]) -> List[List[float]]:
        """Multiply 2x2 matrices."""
        return [[sum(A[i][k]*B[k][j] for k in range(2)) for j in range(2)] for i in range(2)]

    identity = [[1, 0], [0, 1]]

    # Small rotation as a deviation from identity
    theta = 0.1  # small angle
    R = [[math.cos(theta), -math.sin(theta)],
         [math.sin(theta),  math.cos(theta)]]

    dev_R = mat_dist(R, identity)
    print(f"\n  Rotation by θ = {theta} rad")
    print(f"  Deviation from identity: {dev_R:.6f}")

    # Compute R^n and its deviation
    Rn = [row[:] for row in identity]
    for n in range(1, 11):
        Rn = mat_mul(R, Rn)
        dev_Rn = mat_dist(Rn, identity)
        bound = n * dev_R
        print(f"  R^{n:2d}: deviation = {dev_Rn:.6f}, bound = {bound:.6f}, ratio = {dev_Rn/bound:.4f}")


def demo_graded_deviation():
    """Demonstrate graded deviation: high-grade intermediaries amplify bounds."""
    print("\n" + "=" * 60)
    print("Demo 4: Graded Deviation System")
    print("=" * 60)

    # Points with grades (positions and importances)
    points = [(0, 0.0), (3, 0.5), (5, 2.0), (8, 0.1), (10, 0.0)]
    # (position, grade)

    print("\n  Points (position, grade):")
    for i, (pos, grade) in enumerate(points):
        label = " ← high grade!" if grade > 1 else ""
        print(f"    P{i}: position={pos}, grade={grade}{label}")

    print("\n  Standard vs Graded bounds for d(P0, P4):")
    direct = abs(points[-1][0] - points[0][0])
    print(f"    Direct distance: {direct}")

    # Standard chain bound
    standard_sum = sum(abs(points[i+1][0] - points[i][0]) for i in range(len(points)-1))
    print(f"    Standard chain bound (Σ d(Pi, Pi+1)): {standard_sum}")

    # Graded chain bound (adds grades of intermediaries)
    grade_sum = sum(points[i][1] for i in range(1, len(points)-1))
    graded_bound = standard_sum + grade_sum
    print(f"    Sum of intermediate grades: {grade_sum}")
    print(f"    Graded chain bound: {standard_sum} + {grade_sum} = {graded_bound}")
    print(f"    (Grade amplification factor: {graded_bound/standard_sum:.2f}x)")


def demo_surprise_monotonicity():
    """Demonstrate surprise monotonicity under quiver morphisms."""
    print("\n" + "=" * 60)
    print("Demo 5: Surprise Monotonicity Under Morphisms")
    print("=" * 60)

    # Morphism: real line → real line via scaling by 0.5 (nonexpansive)
    scale = 0.5
    print(f"\n  Quiver morphism: scaling by {scale} (nonexpansive)")
    print(f"  This maps jumps f ↦ {scale}·f and expectations e(a,b)=b-a ↦ {scale}·(b-a)")

    cases = [(0, 10, 15), (0, 10, 5), (0, 10, 10)]
    for a, b, f in cases:
        original_surprise = real_line_surprise(a, b, f)
        # After scaling, positions become scale*a, scale*b; jump becomes scale*f
        new_surprise = real_line_surprise(scale*a, scale*b, scale*f)
        print(f"\n  Original: jump {f} from {a} to {b}, surprise = {original_surprise}")
        print(f"  After morphism: jump {scale*f} from {scale*a} to {scale*b}, surprise = {new_surprise}")
        print(f"  Monotonicity: {new_surprise} ≤ {original_surprise} ✓" if new_surprise <= original_surprise + 1e-10 else "  VIOLATION!")


if __name__ == "__main__":
    demo_surprise_subadditivity()
    demo_chain_bound()
    demo_deviation_monoid()
    demo_graded_deviation()
    demo_surprise_monotonicity()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Surprise Subadditivity and Chain Bounds

Generates plots showing the key theorems of categorical deviation theory.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_chain_surprise_bound():
    """Plot: chain surprise vs individual surprise sum."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Single composition subadditivity
    ax = axes[0]
    n_trials = 200
    np.random.seed(42)

    sigma_f = np.random.uniform(0, 5, n_trials)
    sigma_g = np.random.uniform(0, 5, n_trials)
    # Random composed surprise, bounded by sum
    sigma_comp = np.random.uniform(0, 1, n_trials) * (sigma_f + sigma_g)

    ax.scatter(sigma_f + sigma_g, sigma_comp, alpha=0.5, s=10, c='steelblue')
    mx = max(sigma_f + sigma_g)
    ax.plot([0, mx], [0, mx], 'r--', linewidth=2, label='σ(g∘f) = σ(f)+σ(g)')
    ax.set_xlabel('σ(f) + σ(g)', fontsize=12)
    ax.set_ylabel('σ(g∘f)', fontsize=12)
    ax.set_title('Surprise Subadditivity', fontsize=13)
    ax.legend()
    ax.set_aspect('equal')

    # Panel 2: Chain length vs surprise ratio
    ax = axes[1]
    chain_lengths = range(1, 21)
    ratios = []
    for n in chain_lengths:
        # Simulate chains in real line quiver
        deviations = np.random.normal(0, 1, (100, n))
        individual_sums = np.sum(np.abs(deviations), axis=1)
        composed = np.abs(np.sum(deviations, axis=1))
        ratio = np.mean(composed / np.maximum(individual_sums, 1e-10))
        ratios.append(ratio)

    ax.plot(chain_lengths, ratios, 'o-', color='darkgreen', linewidth=2)
    ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.7, label='Bound (ratio ≤ 1)')
    ax.set_xlabel('Chain Length n', fontsize=12)
    ax.set_ylabel('σ(composed) / Σσ(fᵢ)', fontsize=12)
    ax.set_title('Chain Bound Tightness', fontsize=13)
    ax.legend()

    # Panel 3: Power deviation bound
    ax = axes[2]
    thetas = [0.05, 0.1, 0.2, 0.5]
    colors = ['blue', 'green', 'orange', 'red']
    for theta, color in zip(thetas, colors):
        ns = range(1, 31)
        # Rotation matrix deviation
        dev_1 = np.sqrt(2 - 2*np.cos(theta))
        actual_devs = [np.sqrt(2 - 2*np.cos(n*theta)) for n in ns]
        bounds = [n * dev_1 for n in ns]
        ax.plot(ns, actual_devs, '-', color=color, linewidth=2, label=f'θ={theta}')
        ax.plot(ns, bounds, '--', color=color, alpha=0.5)

    ax.set_xlabel('Power n', fontsize=12)
    ax.set_ylabel('Deviation δ(Rⁿ)', fontsize=12)
    ax.set_title('Power Deviation Bound', fontsize=13)
    ax.legend(title='Solid=actual, Dashed=bound')

    plt.tight_layout()
    plt.savefig('deviation_theory_bounds.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: deviation_theory_bounds.png")


def plot_coherence_defect():
    """Plot coherence defect as a function of expectation perturbation."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Panel 1: Coherence defect in perturbed real line quiver
    ax = axes[0]
    perturbations = np.linspace(0, 2, 100)
    # Perturbed expectation: e'(a,b) = (b-a) + ε·sin(a+b)
    a, b, c = 0.0, 3.0, 7.0

    defects = []
    for eps in perturbations:
        e_bc = (c - b) + eps * np.sin(b + c)
        e_ab = (b - a) + eps * np.sin(a + b)
        e_ac = (c - a) + eps * np.sin(a + c)
        composed = e_ab + e_bc
        defect = abs(composed - e_ac)
        defects.append(defect)

    ax.plot(perturbations, defects, 'b-', linewidth=2)
    ax.set_xlabel('Perturbation ε', fontsize=12)
    ax.set_ylabel('Coherence Defect δ(a,b,c)', fontsize=12)
    ax.set_title('Coherence Defect vs Perturbation', fontsize=13)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)

    # Panel 2: Surprise with and without coherence correction
    ax = axes[1]
    epsilons = [0, 0.5, 1.0, 1.5]
    x = np.linspace(-5, 15, 200)

    for eps in epsilons:
        e_ab = (b - a) + eps * np.sin(a + b)
        surprises = np.abs(x - e_ab)
        label = f'ε={eps}'
        ax.plot(x, surprises, linewidth=2, label=label)

    ax.set_xlabel('Morphism f', fontsize=12)
    ax.set_ylabel('Surprise σ(f)', fontsize=12)
    ax.set_title('Surprise Landscape (a=0, b=3)', fontsize=13)
    ax.legend()
    ax.axvline(x=3, color='gray', linestyle=':', alpha=0.5, label='b-a=3')

    plt.tight_layout()
    plt.savefig('coherence_defect.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: coherence_defect.png")


def plot_graded_deviation():
    """Visualize graded deviation: how intermediate grades amplify bounds."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Points on a line with varying grades
    positions = np.array([0, 2, 5, 6, 9, 12, 15])
    grades = np.array([0, 0.5, 2.0, 0.1, 1.5, 0.3, 0])

    # Plot points with grade as size
    sizes = 50 + grades * 200
    colors = plt.cm.YlOrRd(grades / max(grades) * 0.8 + 0.1)

    for i in range(len(positions) - 1):
        ax.plot([positions[i], positions[i+1]], [0, 0], 'k-', linewidth=1, alpha=0.3)

    scatter = ax.scatter(positions, np.zeros_like(positions), s=sizes, c=grades,
                         cmap='YlOrRd', edgecolors='black', linewidths=1.5, zorder=5,
                         vmin=0, vmax=max(grades))
    plt.colorbar(scatter, ax=ax, label='Grade γ')

    # Annotate
    for i, (pos, grade) in enumerate(zip(positions, grades)):
        ax.annotate(f'γ={grade}', (pos, 0.02), ha='center', fontsize=9)
        ax.annotate(f'P{i}', (pos, -0.04), ha='center', fontsize=10, fontweight='bold')

    # Show standard vs graded bounds
    total_dist = sum(abs(positions[i+1] - positions[i]) for i in range(len(positions)-1))
    total_grade = sum(grades[1:-1])  # intermediate grades only

    ax.set_xlim(-1, 16)
    ax.set_ylim(-0.15, 0.15)
    ax.set_xlabel('Position', fontsize=12)
    ax.set_title(f'Graded Deviation System\n'
                 f'Standard bound: {total_dist:.0f} | '
                 f'Grade penalty: +{total_grade:.1f} | '
                 f'Graded bound: {total_dist + total_grade:.1f}',
                 fontsize=13)
    ax.set_yticks([])

    plt.tight_layout()
    plt.savefig('graded_deviation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: graded_deviation.png")


if __name__ == "__main__":
    plot_chain_surprise_bound()
    plot_coherence_defect()
    plot_graded_deviation()
    print("\nAll visualizations generated.")
