#!/usr/bin/env python3
"""
Theory Ecosystem Demo: Fitness, Competition, and Evolution

Demonstrates the key results from the theory ecosystem framework:
1. Fitness rankings of major mathematical theories
2. ZFC vs ZFC+LC fitness comparison
3. Extension threshold analysis
4. Competitive exclusion dynamics
5. Ecosystem evolution simulation
"""

from algorithms import (
    TheorySpec, fitness_comparison, extension_beneficial,
    critical_threshold, quadratic_penalty, ecosystem_evolution,
    ZFC, ZFC_LC, PA, CATEGORY_THEORY, TYPE_THEORY, EUCLIDEAN_GEOMETRY
)


def demo_fitness_rankings():
    """Demonstrate fitness rankings across mathematical theories."""
    print("=" * 60)
    print("DEMO 1: Theory Fitness Rankings")
    print("=" * 60)
    print()
    print("Fitness function: f(T) = connections × theorems / axioms²")
    print()

    theories = [ZFC, ZFC_LC, PA, CATEGORY_THEORY, TYPE_THEORY, EUCLIDEAN_GEOMETRY]
    ranked = sorted(theories, key=lambda t: t.fitness(), reverse=True)

    for i, t in enumerate(ranked, 1):
        bar = "█" * int(t.fitness() / 10)
        print(f"  {i}. {t.name:25s} f = {t.fitness():8.2f}  {bar}")
        print(f"     axioms={t.axiom_count}, theorems={t.theorem_count}, "
              f"connections={t.connection_count}")

    print()
    print("Key insight: Category Theory ranks highest due to extreme parsimony")
    print("(only 4 axioms) combined with high interconnectedness (30 connections).")
    print("This aligns with its role as a 'universal language' of mathematics.")


def demo_zfc_comparison():
    """Demonstrate the ZFC vs ZFC+LC fitness comparison."""
    print()
    print("=" * 60)
    print("DEMO 2: ZFC vs ZFC + Large Cardinals")
    print("=" * 60)
    print()

    print(f"  ZFC:    {ZFC.axiom_count} axioms, {ZFC.theorem_count} theorems, "
          f"{ZFC.connection_count} connections")
    print(f"  ZFC+LC: {ZFC_LC.axiom_count} axioms, {ZFC_LC.theorem_count} theorems, "
          f"{ZFC_LC.connection_count} connections")
    print()
    print(f"  ZFC fitness:    {ZFC.fitness():.4f}")
    print(f"  ZFC+LC fitness: {ZFC_LC.fitness():.4f}")
    print(f"  Ratio:          {ZFC_LC.fitness() / ZFC.fitness():.4f}×")
    print()

    # Cross-multiplication proof
    lhs = ZFC_LC.connection_count * ZFC_LC.theorem_count * ZFC.axiom_count ** 2
    rhs = ZFC.connection_count * ZFC.theorem_count * ZFC_LC.axiom_count ** 2
    print(f"  Cross-multiplication proof:")
    print(f"    35 × 1400 × 9² = {lhs}")
    print(f"    20 × 1000 × 10² = {rhs}")
    print(f"    {lhs} > {rhs} ✓")
    print()
    print("  Large cardinals are fitness-increasing because the explosion of new")
    print("  theorems (descriptive set theory, inner models) and connections")
    print("  (model theory, category theory) more than compensates for the")
    print("  additional axiom's quadratic penalty.")


def demo_extension_threshold():
    """Demonstrate the extension threshold analysis."""
    print()
    print("=" * 60)
    print("DEMO 3: Extension Threshold Analysis")
    print("=" * 60)
    print()

    for theory in [ZFC, PA, CATEGORY_THEORY]:
        threshold = critical_threshold(
            theory.axiom_count, theory.connection_count, theory.theorem_count
        )
        penalty = quadratic_penalty(theory.axiom_count)
        print(f"  {theory.name}:")
        print(f"    Current fitness: {theory.fitness():.2f}")
        print(f"    Axiom penalty (2a+1): {penalty}")
        print(f"    Critical threshold: {threshold:.2f}")
        print(f"    Meaning: adding 1 axiom requires gaining >{threshold:.0f}")
        print(f"    units of explanatory power to be beneficial.")
        print()


def demo_competitive_exclusion():
    """Demonstrate competitive exclusion dynamics."""
    print()
    print("=" * 60)
    print("DEMO 4: Competitive Exclusion Principle")
    print("=" * 60)
    print()

    # Two theories in the same niche (same connections and theorems)
    theory_a = TheorySpec("Theory A", axiom_count=5, theorem_count=500, connection_count=20)
    theory_b = TheorySpec("Theory B", axiom_count=8, theorem_count=500, connection_count=20)

    print(f"  Two theories with SAME connections (20) and theorems (500):")
    print(f"    Theory A: {theory_a.axiom_count} axioms → fitness = {theory_a.fitness():.2f}")
    print(f"    Theory B: {theory_b.axiom_count} axioms → fitness = {theory_b.fitness():.2f}")
    print(f"    Comparison: {'A' if fitness_comparison(theory_a, theory_b) > 0 else 'B'} dominates")
    print()
    print("  Competitive Exclusion: In the same niche, the more parsimonious")
    print("  theory ALWAYS wins. This is a mathematical selection pressure")
    print("  toward Occam's razor.")


def demo_diminishing_returns():
    """Demonstrate the diminishing returns of axiom addition."""
    print()
    print("=" * 60)
    print("DEMO 5: Diminishing Returns (Quadratic Penalty)")
    print("=" * 60)
    print()

    print("  Axiom count → Marginal penalty (2a+1):")
    for a in range(1, 16):
        penalty = quadratic_penalty(a)
        bar = "█" * penalty
        print(f"    a = {a:2d}: penalty = {penalty:3d}  {bar}")

    print()
    print("  The quadratic penalty grows linearly in axiom count,")
    print("  meaning each successive axiom is harder to justify.")
    print("  This creates a natural pressure toward minimal axiomatizations.")


def demo_evolution():
    """Demonstrate ecosystem evolution."""
    print()
    print("=" * 60)
    print("DEMO 6: Ecosystem Evolution (50 generations)")
    print("=" * 60)
    print()

    import random
    random.seed(42)

    initial = [ZFC, ZFC_LC, PA, CATEGORY_THEORY, TYPE_THEORY, EUCLIDEAN_GEOMETRY]
    history = ecosystem_evolution(initial, generations=50, mutation_rate=0.15)

    print("  Initial state:")
    for t in history[0]:
        print(f"    {t.name:25s} fitness = {t.fitness():.2f}")

    print()
    print("  After 50 generations:")
    for t in history[-1]:
        print(f"    {t.name:25s} fitness = {t.fitness():.2f} "
              f"(a={t.axiom_count}, t={t.theorem_count}, c={t.connection_count})")

    # Track fitness over time
    print()
    print("  Fitness trajectory (every 10 generations):")
    for gen in [0, 10, 20, 30, 40, 50]:
        if gen < len(history):
            avg_fitness = sum(t.fitness() for t in history[gen]) / len(history[gen])
            print(f"    Gen {gen:3d}: avg fitness = {avg_fitness:.2f}")


if __name__ == "__main__":
    demo_fitness_rankings()
    demo_zfc_comparison()
    demo_extension_threshold()
    demo_competitive_exclusion()
    demo_diminishing_returns()
    demo_evolution()

    print()
    print("=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Theory Ecosystem Evolution Over Time

Simulates and plots the evolution of mathematical theories under
fitness-driven selection, showing competitive exclusion in action.
"""

import matplotlib.pyplot as plt
import numpy as np
import random

random.seed(42)
np.random.seed(42)


def fitness(axioms, theorems, connections):
    return connections * theorems / (axioms ** 2)


def simulate_evolution(theories, generations=100, mutation_rate=0.12):
    """Simulate ecosystem evolution, return history."""
    history = {name: {'fitness': [], 'axioms': [], 'theorems': [], 'connections': []}
               for name, _, _, _ in theories}
    state = {name: (a, t, c) for name, a, t, c in theories}

    for gen in range(generations + 1):
        fitnesses = {name: fitness(*params) for name, params in state.items()}
        median_f = sorted(fitnesses.values())[len(fitnesses) // 2]

        for name in state:
            a, t, c = state[name]
            history[name]['fitness'].append(fitness(a, t, c))
            history[name]['axioms'].append(a)
            history[name]['theorems'].append(t)
            history[name]['connections'].append(c)

        if gen < generations:
            new_state = {}
            for name, (a, t, c) in state.items():
                f = fitness(a, t, c)
                if f > median_f:
                    c = int(c * 1.04)
                    t = int(t * 1.02)
                else:
                    c = max(1, int(c * 0.96))

                if random.random() < mutation_rate:
                    if random.random() < 0.5 and a > 1:
                        a -= 1
                    else:
                        a += 1
                        t = int(t * 1.08)
                        c = int(c * 1.12)

                new_state[name] = (max(1, a), max(1, t), max(1, c))
            state = new_state

    return history


theories = [
    ('ZFC', 9, 1000, 20),
    ('ZFC+LC', 10, 1400, 35),
    ('PA', 5, 800, 15),
    ('Category Theory', 4, 600, 30),
    ('Type Theory', 7, 500, 25),
    ('Euclidean Geometry', 5, 400, 10),
]

history = simulate_evolution(theories, generations=80)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

colors = {'ZFC': '#1976D2', 'ZFC+LC': '#D32F2F', 'PA': '#388E3C',
          'Category Theory': '#7B1FA2', 'Type Theory': '#F57C00',
          'Euclidean Geometry': '#00796B'}

# Fitness over time
ax = axes[0, 0]
for name, data in history.items():
    ax.plot(data['fitness'], label=name, color=colors[name], linewidth=2)
ax.set_xlabel('Generation')
ax.set_ylabel('Fitness')
ax.set_title('Fitness Evolution Over Time')
ax.legend(fontsize=8)
ax.set_yscale('log')

# Axiom count over time
ax = axes[0, 1]
for name, data in history.items():
    ax.plot(data['axioms'], label=name, color=colors[name], linewidth=2)
ax.set_xlabel('Generation')
ax.set_ylabel('Axiom Count')
ax.set_title('Axiom Count Evolution (Occam Pressure)')
ax.legend(fontsize=8)

# Connection count over time
ax = axes[1, 0]
for name, data in history.items():
    ax.plot(data['connections'], label=name, color=colors[name], linewidth=2)
ax.set_xlabel('Generation')
ax.set_ylabel('Connection Count')
ax.set_title('Inter-theoretic Connections Over Time')
ax.legend(fontsize=8)

# Final state scatter
ax = axes[1, 1]
for name, data in history.items():
    final_a = data['axioms'][-1]
    final_c = data['connections'][-1]
    final_f = data['fitness'][-1]
    ax.scatter(final_a, final_c, s=final_f * 0.5 + 50, color=colors[name],
               alpha=0.8, edgecolors='black', linewidth=1)
    ax.annotate(name, (final_a, final_c), textcoords="offset points",
                xytext=(5, 5), fontsize=8)
ax.set_xlabel('Final Axiom Count')
ax.set_ylabel('Final Connection Count')
ax.set_title('Final Ecosystem State (size ∝ fitness)')

plt.tight_layout()
plt.savefig('evolution_dynamics.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved evolution_dynamics.png")


#!/usr/bin/env python3
"""
Visualization: Theory Ecosystem Fitness Landscape

Generates a 3D surface plot showing how fitness varies with axiom count
and connection count, revealing the fitness landscape that theories navigate.
"""

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.mplot3d import Axes3D

def fitness(axioms, connections, theorems=500):
    """f(T) = connections * theorems / axioms^2"""
    return connections * theorems / (axioms ** 2)

# Create meshgrid
axioms = np.linspace(1, 15, 100)
connections = np.linspace(1, 50, 100)
A, C = np.meshgrid(axioms, connections)
F = fitness(A, C)

fig = plt.figure(figsize=(14, 10))

# 3D surface
ax1 = fig.add_subplot(221, projection='3d')
surf = ax1.plot_surface(A, C, F, cmap='viridis', alpha=0.8)
ax1.set_xlabel('Axiom Count')
ax1.set_ylabel('Connection Count')
ax1.set_zlabel('Fitness')
ax1.set_title('Fitness Landscape f(a,c) = c·t/a²')
fig.colorbar(surf, ax=ax1, shrink=0.5)

# Named theories
theories = {
    'ZFC': (9, 20, 1000), 'ZFC+LC': (10, 35, 1400),
    'PA': (5, 15, 800), 'Cat. Theory': (4, 30, 600),
    'Type Theory': (7, 25, 500), 'Euclid. Geom.': (5, 10, 400)
}
for name, (a, c, t) in theories.items():
    ax1.scatter([a], [c], [fitness(a, c, t)], s=100, zorder=5)

# Contour plot
ax2 = fig.add_subplot(222)
contour = ax2.contourf(A, C, F, levels=20, cmap='viridis')
fig.colorbar(contour, ax=ax2)
for name, (a, c, t) in theories.items():
    ax2.plot(a, c, 'ro', markersize=8)
    ax2.annotate(name, (a, c), textcoords="offset points",
                 xytext=(5, 5), fontsize=7, color='white',
                 fontweight='bold')
ax2.set_xlabel('Axiom Count')
ax2.set_ylabel('Connection Count')
ax2.set_title('Fitness Contours (t=500 baseline)')

# Quadratic penalty
ax3 = fig.add_subplot(223)
a_vals = np.arange(1, 20)
penalties = 2 * a_vals + 1
ax3.bar(a_vals, penalties, color='coral', alpha=0.7)
ax3.set_xlabel('Current Axiom Count')
ax3.set_ylabel('Marginal Penalty (2a+1)')
ax3.set_title('Diminishing Returns: Quadratic Axiom Penalty')

# Fitness comparison: ZFC vs ZFC+LC
ax4 = fig.add_subplot(224)
labels = list(theories.keys())
fitnesses = [fitness(a, c, t) for a, c, t in theories.values()]
colors = ['#2196F3' if name != 'ZFC+LC' else '#FF5722' for name in labels]
bars = ax4.barh(labels, fitnesses, color=colors, alpha=0.8)
ax4.set_xlabel('Fitness')
ax4.set_title('Theory Fitness Rankings')
for bar, f in zip(bars, fitnesses):
    ax4.text(bar.get_width() + 10, bar.get_y() + bar.get_height()/2,
             f'{f:.0f}', va='center', fontsize=9)

plt.tight_layout()
plt.savefig('fitness_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved fitness_landscape.png")
