#!/usr/bin/env python3
"""
Theory Ecosystem Demo
=====================

Demonstrates the key results from the Theory Ecosystem framework:
1. Quadratic Axiom Penalty
2. ZFC vs ZFC+LC comparison
3. Evolution dynamics and the Matthew effect
4. Competitive exclusion in a multi-niche ecosystem
5. Extension threshold analysis
"""

from algorithms import (
    FormalTheory, evolve_step, fitness_decomposition,
    extension_threshold, content_gain_ratio, axiom_cost_ratio,
    TheoryEcosystem, simulate_evolution,
    ZFC, ZFC_LC, PEANO, EUCLIDEAN, CATEGORY
)


def demo_quadratic_penalty():
    """Demonstrate the quadratic axiom penalty."""
    print("=" * 60)
    print("DEMO 1: Quadratic Axiom Penalty")
    print("=" * 60)
    print()
    print("Adding axioms without new content STRICTLY decreases fitness.")
    print("The penalty is quadratic: each axiom costs more than the last.")
    print()

    base = FormalTheory(5, 100, 10, "Base Theory")
    print(f"  Base theory (5 axioms): fitness = {base.fitness:.2f}")

    for extra in range(1, 6):
        extended = FormalTheory(5 + extra, 100, 10, f"+{extra} axiom(s)")
        ratio = base.fitness / extended.fitness
        print(f"  +{extra} axiom(s) ({5+extra} total):  fitness = {extended.fitness:.2f}  "
              f"(ratio: {ratio:.2f}x worse)")

    print()
    print("  The penalty grows quadratically: ratio ≈ ((a+k)/a)²")
    print()


def demo_zfc_comparison():
    """Demonstrate ZFC vs ZFC+LC fitness comparison."""
    print("=" * 60)
    print("DEMO 2: ZFC vs ZFC + Large Cardinals")
    print("=" * 60)
    print()

    print(f"  ZFC:    {ZFC.axioms} axioms, {ZFC.theorems} theorems, "
          f"{ZFC.connections} connections → fitness = {ZFC.fitness:.2f}")
    print(f"  ZFC+LC: {ZFC_LC.axioms} axioms, {ZFC_LC.theorems} theorems, "
          f"{ZFC_LC.connections} connections → fitness = {ZFC_LC.fitness:.2f}")
    print()

    # Cross-multiplied comparison (exact)
    lhs = ZFC_LC.raw_fitness * ZFC.axioms ** 2
    rhs = ZFC.raw_fitness * ZFC_LC.axioms ** 2
    print(f"  Cross-multiplied: {lhs} > {rhs} ? {lhs > rhs}")
    print(f"  Fitness ratio: {ZFC_LC.fitness / ZFC.fitness:.2f}x")
    print()

    cgr = content_gain_ratio(ZFC.theorems, ZFC.connections, 500, 3)
    acr = axiom_cost_ratio(ZFC.axioms, 2)
    print(f"  Content gain ratio: {cgr:.2f}")
    print(f"  Axiom cost ratio:   {acr:.2f}")
    print(f"  Verdict: {'Extension beneficial' if cgr > acr else 'Extension harmful'}")
    print()


def demo_evolution():
    """Demonstrate evolution dynamics and the Matthew effect."""
    print("=" * 60)
    print("DEMO 3: Evolution Dynamics (Matthew Effect)")
    print("=" * 60)
    print()

    # Start with a modest theory
    T = FormalTheory(3, 10, 10, "Seed Theory")
    print(f"  Initial: t={T.theorems}, c={T.connections}, fitness={T.fitness:.2f}")
    print()

    trajectory = simulate_evolution(T, 1, 1, 8)
    for i, t in enumerate(trajectory):
        orig, dt_gain, dc_gain, synergy = fitness_decomposition(
            trajectory[max(0, i-1)], 1, 1) if i > 0 else (t.raw_fitness, 0, 0, 0)
        print(f"  Step {i}: t={t.theorems:6d}, c={t.connections:6d}, "
              f"rawFitness={t.raw_fitness:12d}, fitness={t.fitness:12.2f}"
              + (f"  [synergy={synergy:10d}]" if i > 0 else ""))

    print()
    print("  Notice: fitness grows SUPERLINEARLY due to the synergy term.")
    print("  The synergy term = α·β·rawFitness grows proportionally to existing fitness.")
    print("  This is the Matthew effect: 'to those who have, more will be given.'")
    print()


def demo_competitive_exclusion():
    """Demonstrate competitive exclusion in a multi-niche ecosystem."""
    print("=" * 60)
    print("DEMO 4: Competitive Exclusion")
    print("=" * 60)
    print()

    theories = [
        FormalTheory(5, 100, 10, "Analysis-A"),
        FormalTheory(6, 120, 10, "Analysis-B"),
        FormalTheory(4, 80, 12, "Algebra-A"),
        FormalTheory(5, 90, 11, "Algebra-B"),
        FormalTheory(3, 60, 8, "Topology"),
    ]
    niches = [1, 1, 2, 2, 3]  # Analysis, Algebra, Topology

    print("  All theories:")
    for t, n in zip(theories, niches):
        print(f"    {t.name:15s}  niche={n}  fitness={t.fitness:.2f}")
    print()

    eco = TheoryEcosystem(theories, niches)
    survivors = eco.niche_dominant()

    print("  After competitive exclusion (one winner per niche):")
    for t in survivors:
        print(f"    {t.name:15s}  fitness={t.fitness:.2f}  ← SURVIVES")
    print()
    print(f"  Diversity: {eco.diversity()} niches")
    print(f"  Entropy: {eco.ecosystem_entropy():.3f} bits")
    print()


def demo_extension_threshold():
    """Demonstrate the extension threshold analysis."""
    print("=" * 60)
    print("DEMO 5: Extension Threshold Analysis")
    print("=" * 60)
    print()

    base_a, base_t, base_c = 5, 100, 10
    print(f"  Base theory: a={base_a}, t={base_t}, c={base_c}, "
          f"fitness={FormalTheory(base_a, base_t, base_c).fitness:.2f}")
    print()

    test_cases = [
        (1, 0, 0, "Add 1 axiom, nothing else"),
        (1, 30, 0, "Add 1 axiom + 30 theorems"),
        (1, 30, 3, "Add 1 axiom + 30 theorems + 3 connections"),
        (1, 50, 5, "Add 1 axiom + 50 theorems + 5 connections"),
        (2, 100, 5, "Add 2 axioms + 100 theorems + 5 connections"),
        (3, 200, 10, "Add 3 axioms + 200 theorems + 10 connections"),
    ]

    for k, dt, dc, desc in test_cases:
        beneficial = extension_threshold(base_a, base_t, base_c, k, dt, dc)
        new_theory = FormalTheory(base_a + k, base_t + dt, base_c + dc)
        cgr = content_gain_ratio(base_t, base_c, dt, dc)
        acr = axiom_cost_ratio(base_a, k)
        print(f"  {desc:50s}  "
              f"CGR={cgr:.2f}  ACR={acr:.2f}  "
              f"{'✓ BENEFICIAL' if beneficial else '✗ HARMFUL':>14s}  "
              f"(fitness: {new_theory.fitness:.2f})")

    print()


def demo_synergy():
    """Demonstrate the connection-theorem synergy."""
    print("=" * 60)
    print("DEMO 6: Connection-Theorem Synergy")
    print("=" * 60)
    print()

    a = 5
    print(f"  For a theory with {a} axioms:")
    print()
    header = 'c\\t'
    print(f"  {header:>5s}", end="")
    for t in [10, 20, 50, 100]:
        print(f"  {'t='+str(t):>10s}", end="")
    print()
    print("  " + "-" * 50)

    for c in [2, 5, 10, 20]:
        print(f"  {'c='+str(c):>5s}", end="")
        for t in [10, 20, 50, 100]:
            f = c * t / a**2
            print(f"  {f:10.2f}", end="")
        print()

    print()
    print("  Key insight: the cross-derivative ∂²f/∂c∂t = 1/a² = "
          f"{1/a**2:.4f} is CONSTANT.")
    print("  Each new connection is worth exactly the same extra fitness per theorem.")
    print()


if __name__ == "__main__":
    demo_quadratic_penalty()
    demo_zfc_comparison()
    demo_evolution()
    demo_competitive_exclusion()
    demo_extension_threshold()
    demo_synergy()

    print("=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Theory Fitness Landscape
========================================

3D surface plot of the fitness function f(t, c) = c*t/a² for fixed axiom count,
showing how fitness depends on theorem count and connection count.
"""

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.mplot3d import Axes3D


def plot_fitness_landscape():
    fig = plt.figure(figsize=(14, 5))

    axiom_counts = [3, 5, 9]
    for idx, a in enumerate(axiom_counts):
        ax = fig.add_subplot(1, 3, idx + 1, projection='3d')

        t_vals = np.linspace(1, 200, 50)
        c_vals = np.linspace(1, 20, 50)
        T, C = np.meshgrid(t_vals, c_vals)
        F = C * T / a**2

        surf = ax.plot_surface(T, C, F, cmap='viridis', alpha=0.8,
                               edgecolor='none')
        ax.set_xlabel('Theorems')
        ax.set_ylabel('Connections')
        ax.set_zlabel('Fitness')
        ax.set_title(f'a = {a} axioms')
        ax.view_init(elev=25, azim=45)

    plt.suptitle('Theory Fitness Landscape: f(t, c) = c·t / a²', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('viz_fitness_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_fitness_landscape.png")


def plot_axiom_penalty():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Fixed t=100, c=10
    t, c = 100, 10
    axioms = np.arange(1, 20)
    fitness = c * t / axioms**2

    ax1.plot(axioms, fitness, 'b-o', linewidth=2, markersize=6)
    ax1.set_xlabel('Axiom Count', fontsize=12)
    ax1.set_ylabel('Fitness', fontsize=12)
    ax1.set_title('Quadratic Axiom Penalty\n(t=100, c=10)', fontsize=13)
    ax1.grid(True, alpha=0.3)
    ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)

    # Penalty ratio
    ratios = [(a+1)**2 / a**2 for a in axioms[:-1]]
    ax2.bar(axioms[:-1], ratios, color='coral', alpha=0.8)
    ax2.set_xlabel('Axiom Count', fontsize=12)
    ax2.set_ylabel('Penalty Ratio (a+1)²/a²', fontsize=12)
    ax2.set_title('Cost of Adding One More Axiom', fontsize=13)
    ax2.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_axiom_penalty.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_axiom_penalty.png")


def plot_evolution():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Simulate evolution for different initial conditions
    configs = [
        (10, 10, 'Balanced (t=c=10)'),
        (20, 5, 'Theorem-heavy (t=20, c=5)'),
        (5, 20, 'Connection-heavy (t=5, c=20)'),
    ]

    for t0, c0, label in configs:
        a = 3
        steps = 8
        t_vals, c_vals, f_vals = [t0], [c0], [c0 * t0 / a**2]

        t_curr, c_curr = t0, c0
        for _ in range(steps):
            t_new = t_curr + c_curr
            c_new = c_curr + t_curr
            t_curr, c_curr = t_new, c_new
            f_vals.append(c_curr * t_curr / a**2)
            t_vals.append(t_curr)
            c_vals.append(c_curr)

        ax1.semilogy(range(steps + 1), f_vals, '-o', label=label, linewidth=2)
        ax2.plot(t_vals, c_vals, '-o', label=label, linewidth=2)

    ax1.set_xlabel('Evolution Step', fontsize=12)
    ax1.set_ylabel('Fitness (log scale)', fontsize=12)
    ax1.set_title('Superlinear Fitness Growth\n(α=β=1, a=3)', fontsize=13)
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    ax2.set_xlabel('Theorems', fontsize=12)
    ax2.set_ylabel('Connections', fontsize=12)
    ax2.set_title('Theory Evolution Trajectories\nin (t, c) Space', fontsize=13)
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_evolution.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_evolution.png")


if __name__ == "__main__":
    plot_fitness_landscape()
    plot_axiom_penalty()
    plot_evolution()
    print("All visualizations generated.")
