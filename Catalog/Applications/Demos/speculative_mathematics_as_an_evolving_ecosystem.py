#!/usr/bin/env python3
"""
Theory Ecosystem Demo: Numerical Examples and Demonstrations

Demonstrates the key results from the Theory Ecosystem framework:
1. Fitness computation for ZFC and ZFC + Large Cardinals
2. Non-monotonicity of fitness under naive extension
3. Red Queen effect visualization
4. Competitive exclusion in a sample ecosystem
5. Shared axioms boost analysis
"""

from fractions import Fraction
from algorithms import (
    FormalTheory, PositionedTheory, is_fertile_extension,
    fitness_comparison, find_survivors, merge_theories,
    axiom_efficiency_threshold, optimal_extension,
    simulate_ecosystem_dynamics
)


def demo_zfc_comparison():
    """Demo 1: ZFC vs ZFC + Large Cardinals fitness comparison."""
    print("=" * 60)
    print("DEMO 1: ZFC vs ZFC + Large Cardinals")
    print("=" * 60)
    
    zfc = FormalTheory(9, 1000, 50, "ZFC")
    zfc_lc = FormalTheory(12, 3000, 150, "ZFC+LC")
    
    print(f"\n{zfc.name}:")
    print(f"  Axioms: {zfc.axiom_count}, Theorems: {zfc.theorem_count}, "
          f"Connections: {zfc.connection_count}")
    print(f"  Fitness: {zfc.fitness} ≈ {float(zfc.fitness):.2f}")
    print(f"  Proof Density: {zfc.proof_density} ≈ {float(zfc.proof_density):.2f}")
    
    print(f"\n{zfc_lc.name}:")
    print(f"  Axioms: {zfc_lc.axiom_count}, Theorems: {zfc_lc.theorem_count}, "
          f"Connections: {zfc_lc.connection_count}")
    print(f"  Fitness: {zfc_lc.fitness} ≈ {float(zfc_lc.fitness):.2f}")
    print(f"  Proof Density: {zfc_lc.proof_density} ≈ {float(zfc_lc.proof_density):.2f}")
    
    ratio = zfc_lc.fitness / zfc.fitness
    print(f"\n  Fitness ratio (ZFC+LC / ZFC): {ratio} ≈ {float(ratio):.2f}x")
    print(f"  ZFC+LC is a fertile extension: {is_fertile_extension(zfc, zfc_lc)}")
    print(f"  Fitness comparison: {fitness_comparison(zfc_lc, zfc)} "
          "(1 = ZFC+LC wins)")


def demo_non_monotonicity():
    """Demo 2: Fitness non-monotonicity."""
    print("\n" + "=" * 60)
    print("DEMO 2: Fitness Non-Monotonicity (Bigger ≠ Fitter)")
    print("=" * 60)
    
    t1 = FormalTheory(2, 100, 10, "Lean")
    t2 = FormalTheory(10, 150, 12, "Bloated")
    
    print(f"\n{t1.name} theory: ({t1.axiom_count}, {t1.theorem_count}, "
          f"{t1.connection_count})")
    print(f"  Fitness: {t1.fitness} = {float(t1.fitness):.1f}")
    
    print(f"\n{t2.name} theory: ({t2.axiom_count}, {t2.theorem_count}, "
          f"{t2.connection_count})")
    print(f"  Fitness: {t2.fitness} = {float(t2.fitness):.1f}")
    
    print(f"\n  {t2.name} has MORE axioms: {t2.axiom_count} > {t1.axiom_count} ✓")
    print(f"  {t2.name} has MORE theorems: {t2.theorem_count} > {t1.theorem_count} ✓")
    print(f"  {t2.name} has MORE connections: {t2.connection_count} > "
          f"{t1.connection_count} ✓")
    print(f"  Yet {t2.name} has LESS fitness: {float(t2.fitness):.1f} < "
          f"{float(t1.fitness):.1f} ✗")
    print(f"  Fitness ratio: {float(t1.fitness / t2.fitness):.1f}x difference!")


def demo_red_queen():
    """Demo 3: Red Queen effect — linear growth kills fitness."""
    print("\n" + "=" * 60)
    print("DEMO 3: The Red Queen Effect")
    print("=" * 60)
    
    base_r, base_c = 10, 5
    
    print(f"\nTheory family: T(a) = (a, {base_r}a, {base_c})")
    print(f"{'Axioms':>8} {'Theorems':>10} {'Fitness':>12} {'Change':>10}")
    print("-" * 44)
    
    prev_fitness = None
    for a in [1, 2, 4, 8, 16, 32]:
        t = FormalTheory(a, a * base_r, base_c, f"T({a})")
        change = ""
        if prev_fitness is not None:
            ratio = t.fitness / prev_fitness
            change = f"{float(ratio):.3f}x"
        prev_fitness = t.fitness
        print(f"{a:>8} {a * base_r:>10} {float(t.fitness):>12.2f} {change:>10}")
    
    print(f"\nRed Queen threshold: to maintain fitness when doubling axioms,")
    print(f"theorems must grow by 4x (not 2x). The critical exponent is 2.")
    
    print(f"\nVerification with superlinear growth (β = 2.5):")
    print(f"{'Axioms':>8} {'Theorems':>10} {'Fitness':>12}")
    print("-" * 34)
    for a in [1, 2, 4, 8]:
        t_count = max(1, int(a ** 2.5))
        t = FormalTheory(a, t_count, base_c, f"T({a})")
        print(f"{a:>8} {t_count:>10} {float(t.fitness):>12.2f}")


def demo_competitive_exclusion():
    """Demo 4: Competitive exclusion in a sample ecosystem."""
    print("\n" + "=" * 60)
    print("DEMO 4: Competitive Exclusion")
    print("=" * 60)
    
    ecosystem = [
        PositionedTheory(FormalTheory(5, 500, 20, "GroupTheory"), niche=0),
        PositionedTheory(FormalTheory(5, 600, 25, "RingTheory"), niche=0),
        PositionedTheory(FormalTheory(3, 200, 15, "GraphTheory"), niche=1),
        PositionedTheory(FormalTheory(4, 300, 12, "CombTheory"), niche=1),
        PositionedTheory(FormalTheory(8, 800, 30, "Topology"), niche=2),
    ]
    
    print("\nInitial ecosystem:")
    for pt in ecosystem:
        f = pt.theory.fitness
        print(f"  [{pt.niche}] {pt.theory.name}: fitness = "
              f"{float(f):.2f}")
    
    survivors = find_survivors(ecosystem)
    print(f"\nSurvivors (after competitive exclusion):")
    for pt in survivors:
        f = pt.theory.fitness
        print(f"  [{pt.niche}] {pt.theory.name}: fitness = "
              f"{float(f):.2f}")
    
    eliminated = [pt for pt in ecosystem if pt not in survivors]
    print(f"\nEliminated:")
    for pt in eliminated:
        f = pt.theory.fitness
        winner = [s for s in survivors if s.niche == pt.niche][0]
        print(f"  [{pt.niche}] {pt.theory.name} (fitness {float(f):.2f}) "
              f"< {winner.theory.name} (fitness {float(winner.theory.fitness):.2f})")


def demo_shared_axioms():
    """Demo 5: Shared axioms boost fitness of merged theories."""
    print("\n" + "=" * 60)
    print("DEMO 5: Shared Axioms Boost (Unification Dividend)")
    print("=" * 60)
    
    t1 = FormalTheory(5, 300, 20, "Algebra")
    t2 = FormalTheory(4, 200, 15, "Topology")
    
    print(f"\n{t1.name}: fitness = {float(t1.fitness):.2f}")
    print(f"{t2.name}: fitness = {float(t2.fitness):.2f}")
    
    print(f"\nMerge fitness by shared axiom count:")
    print(f"{'Shared':>8} {'Total Axioms':>14} {'Fitness':>10} {'Gain':>10}")
    print("-" * 46)
    
    prev_f = None
    for s in range(5):  # 0 to 4 shared axioms
        merged = merge_theories(t1, t2, s, f"Merged(s={s})")
        f = merged.fitness
        gain = ""
        if prev_f is not None:
            gain = f"+{float(f - prev_f):.2f}"
        prev_f = f
        print(f"{s:>8} {merged.axiom_count:>14} {float(f):>10.2f} {gain:>10}")
    
    print(f"\nMore shared axioms → fewer total axioms → higher fitness")
    print(f"This is the 'unification dividend': discovering shared")
    print(f"foundations makes both theories fitter.")


def demo_axiom_efficiency():
    """Demo 6: Axiom efficiency threshold."""
    print("\n" + "=" * 60)
    print("DEMO 6: Axiom Efficiency Threshold")
    print("=" * 60)
    
    theory = FormalTheory(5, 400, 25, "BaseTheory")
    threshold = axiom_efficiency_threshold(theory)
    
    print(f"\nBase theory: ({theory.axiom_count}, {theory.theorem_count}, "
          f"{theory.connection_count})")
    print(f"  Current fitness: {float(theory.fitness):.2f}")
    print(f"  Threshold for 1-axiom extension: (c+Δc)(t+Δt) must exceed "
          f"{float(threshold):.2f}")
    
    candidates = [
        (50, 5, "Weak Extension"),
        (200, 10, "Moderate Extension"),
        (500, 20, "Strong Extension"),
        (1000, 50, "Powerful Extension"),
    ]
    
    print(f"\n{'Extension':>20} {'(Δt, Δc)':>10} {'New Fitness':>12} {'Improves?':>10}")
    print("-" * 56)
    
    for dt, dc, name in candidates:
        ext = FormalTheory(
            theory.axiom_count + 1,
            theory.theorem_count + dt,
            theory.connection_count + dc,
            name
        )
        improves = ext.fitness > theory.fitness
        print(f"{name:>20} ({dt},{dc:>3}) {float(ext.fitness):>12.2f} "
              f"{'✓' if improves else '✗':>10}")


if __name__ == "__main__":
    demo_zfc_comparison()
    demo_non_monotonicity()
    demo_red_queen()
    demo_competitive_exclusion()
    demo_shared_axioms()
    demo_axiom_efficiency()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization 2: Ecosystem Competition and Competitive Exclusion

Shows how theories compete within niches and illustrates the competitive
exclusion principle through ecosystem dynamics simulation.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def compute_fitness(axioms, theorems, connections):
    """Compute fitness = connections * theorems / axioms^2"""
    return connections * theorems / (axioms ** 2)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Plot 1: Theory comparison bar chart
    ax = axes[0]
    theories = [
        ("ZFC", 9, 1000, 50),
        ("ZFC+LC", 12, 3000, 150),
        ("Lean (2,100,10)", 2, 100, 10),
        ("Bloated (10,150,12)", 10, 150, 12),
        ("Balanced (5,500,25)", 5, 500, 25),
    ]
    
    names = [t[0] for t in theories]
    fitnesses = [compute_fitness(t[1], t[2], t[3]) for t in theories]
    colors = ['steelblue', 'darkblue', 'green', 'red', 'orange']
    
    bars = ax.barh(names, fitnesses, color=colors)
    ax.set_xlabel('Fitness')
    ax.set_title('Theory Fitness Comparison')
    ax.set_xscale('log')
    
    for bar, f in zip(bars, fitnesses):
        ax.text(f * 1.1, bar.get_y() + bar.get_height()/2,
                f'{f:.1f}', va='center', fontsize=9)
    
    # Plot 2: Competitive exclusion dynamics
    ax = axes[1]
    
    # Simulate ecosystem with 3 niches
    niche_data = {
        'Niche 0\n(Foundations)': [
            ("ZFC", compute_fitness(9, 1000, 50)),
            ("ZFC+LC", compute_fitness(12, 3000, 150)),
            ("NF", compute_fitness(6, 200, 15)),
        ],
        'Niche 1\n(Algebra)': [
            ("Group Th.", compute_fitness(4, 800, 30)),
            ("Ring Th.", compute_fitness(5, 600, 25)),
            ("Monoid Th.", compute_fitness(3, 200, 10)),
        ],
        'Niche 2\n(Geometry)': [
            ("Diff. Geom.", compute_fitness(6, 700, 35)),
            ("Alg. Geom.", compute_fitness(7, 900, 40)),
            ("Euclidean", compute_fitness(5, 300, 12)),
        ],
    }
    
    y_pos = 0
    y_positions = []
    y_labels = []
    
    for niche_name, theories in niche_data.items():
        max_f = max(f for _, f in theories)
        for name, f in theories:
            is_survivor = (f == max_f)
            color = 'green' if is_survivor else 'lightcoral'
            alpha = 1.0 if is_survivor else 0.6
            ax.barh(y_pos, f, color=color, alpha=alpha, edgecolor='black', linewidth=0.5)
            label = f"{name} ({f:.0f})"
            if is_survivor:
                label += " ★"
            ax.text(f + max_f * 0.02, y_pos, label, va='center', fontsize=8)
            y_positions.append(y_pos)
            y_pos += 1
        y_pos += 0.5  # gap between niches
    
    ax.set_yticks([])
    ax.set_xlabel('Fitness')
    ax.set_title('Competitive Exclusion\n(★ = survivor, red = eliminated)')
    
    # Add niche labels
    niche_starts = [0, 3.5, 7]
    for start, name in zip(niche_starts, niche_data.keys()):
        ax.text(-ax.get_xlim()[1] * 0.15, start + 1, name,
                va='center', ha='center', fontsize=9, fontweight='bold')
    
    # Plot 3: Merge fitness vs shared axioms
    ax = axes[2]
    
    # Two theories being merged
    a1, t1, c1 = 6, 400, 20
    a2, t2, c2 = 5, 300, 15
    
    shared_range = range(0, min(a1, a2) + 1)
    merge_fitnesses = []
    for s in shared_range:
        total_a = a1 + a2 - s
        total_t = t1 + t2
        total_c = c1 + c2
        merge_fitnesses.append(compute_fitness(total_a, total_t, total_c))
    
    ax.plot(list(shared_range), merge_fitnesses, 'bo-', markersize=10, linewidth=2)
    ax.fill_between(list(shared_range), merge_fitnesses, alpha=0.2, color='blue')
    ax.set_xlabel('Shared Axiom Count')
    ax.set_ylabel('Merged Theory Fitness')
    ax.set_title(f'Unification Dividend\n(Merging ({a1},{t1},{c1}) + ({a2},{t2},{c2}))')
    ax.grid(True, alpha=0.3)
    
    for s, f in zip(shared_range, merge_fitnesses):
        ax.annotate(f'{f:.1f}', (s, f), textcoords="offset points",
                   xytext=(0, 10), ha='center', fontsize=9)
    
    plt.tight_layout()
    plt.savefig('ecosystem_dynamics.png', dpi=150, bbox_inches='tight')
    print("Saved ecosystem_dynamics.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 1: Theory Fitness Landscape

Generates a heatmap showing how fitness varies with axiom count and theorem count
for fixed connection count, revealing the non-monotonicity and phase structure.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def compute_fitness(axioms: np.ndarray, theorems: np.ndarray, connections: int) -> np.ndarray:
    """Compute fitness = connections * theorems / axioms^2"""
    return connections * theorems / (axioms ** 2)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Plot 1: Fitness heatmap
    ax = axes[0]
    axiom_range = np.arange(1, 21)
    theorem_range = np.arange(0, 501, 5)
    A, T = np.meshgrid(axiom_range, theorem_range)
    F = compute_fitness(A, T, connections=10)
    
    im = ax.pcolormesh(A, T, F, shading='auto', cmap='viridis')
    plt.colorbar(im, ax=ax, label='Fitness')
    ax.set_xlabel('Axiom Count')
    ax.set_ylabel('Theorem Count')
    ax.set_title('Fitness Landscape (c=10)')
    
    # Mark ZFC and ZFC+LC
    zfc_f = compute_fitness(9, 1000, 50)
    zfc_lc_f = compute_fitness(12, 3000, 150)
    
    # Plot 2: Red Queen effect - fitness vs axiom count for different growth rates
    ax = axes[1]
    axioms = np.arange(1, 31)
    c = 10
    
    for beta, label, color in [(1.0, 'β=1 (linear)', 'red'),
                                (1.5, 'β=1.5', 'orange'),
                                (2.0, 'β=2 (critical)', 'blue'),
                                (2.5, 'β=2.5', 'green'),
                                (3.0, 'β=3 (cubic)', 'purple')]:
        theorems = axioms ** beta
        fitness = c * theorems / axioms ** 2
        ax.plot(axioms, fitness, label=label, color=color, linewidth=2)
    
    ax.set_xlabel('Axiom Count')
    ax.set_ylabel('Fitness')
    ax.set_title('Red Queen Effect: Critical Exponent β*=2')
    ax.legend(fontsize=9)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    
    # Plot 3: Fitness scaling - k^2 law
    ax = axes[2]
    k_values = np.arange(1, 11)
    base_fitness = compute_fitness(5, 100, 10)
    
    actual = [compute_fitness(5, k * 100, k * 10) for k in k_values]
    predicted = [k**2 * base_fitness for k in k_values]
    
    ax.plot(k_values, actual, 'bo-', label='Actual fitness', markersize=8)
    ax.plot(k_values, predicted, 'r--', label='k² × base', linewidth=2)
    ax.set_xlabel('Scaling Factor k')
    ax.set_ylabel('Fitness')
    ax.set_title('Fitness Scaling Law: f(kT) = k²f(T)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('fitness_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved fitness_landscape.png")


if __name__ == "__main__":
    main()
