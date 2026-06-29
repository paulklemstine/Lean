#!/usr/bin/env python3
"""
Theory Ecosystem Dynamics: Numerical Demonstrations

Demonstrates the fitness function for mathematical theories, the productive
extension theorem, competitive exclusion, and superadditivity of fitness
under theory merging.
"""

from dataclasses import dataclass
from typing import List


@dataclass
class MathTheory:
    """A mathematical theory modeled as a species in an ecosystem."""
    name: str
    axiom_count: int
    theorem_count: int
    connection_count: int

    @property
    def fitness(self) -> float:
        """fitness(T) = connections × theorems / axioms"""
        if self.axiom_count == 0:
            return 0.0
        return (self.connection_count * self.theorem_count) / self.axiom_count

    @property
    def productivity(self) -> int:
        return self.connection_count * self.theorem_count

    def is_productive_extension_of(self, base: 'MathTheory') -> bool:
        """Check if self is a productive extension of base."""
        if not (self.axiom_count >= base.axiom_count and
                self.theorem_count >= base.theorem_count and
                self.connection_count >= base.connection_count):
            return False
        return (self.connection_count * self.theorem_count * base.axiom_count >
                base.connection_count * base.theorem_count * self.axiom_count)


def demo_zfc_comparison():
    """Demonstrate ZFC vs ZFC + Large Cardinals fitness comparison."""
    print("=" * 60)
    print("DEMO 1: ZFC vs ZFC + Large Cardinals")
    print("=" * 60)

    zfc = MathTheory("ZFC", axiom_count=9, theorem_count=1000, connection_count=50)
    zfc_lc = MathTheory("ZFC+LC", axiom_count=12, theorem_count=1800, connection_count=120)

    print(f"\n{zfc.name}:")
    print(f"  Axioms: {zfc.axiom_count}")
    print(f"  Theorems: {zfc.theorem_count}")
    print(f"  Connections: {zfc.connection_count}")
    print(f"  Fitness: {zfc.fitness:.2f}")
    print(f"  Productivity: {zfc.productivity}")

    print(f"\n{zfc_lc.name}:")
    print(f"  Axioms: {zfc_lc.axiom_count}")
    print(f"  Theorems: {zfc_lc.theorem_count}")
    print(f"  Connections: {zfc_lc.connection_count}")
    print(f"  Fitness: {zfc_lc.fitness:.2f}")
    print(f"  Productivity: {zfc_lc.productivity}")

    print(f"\n  Fitness ratio (ZFC+LC / ZFC): {zfc_lc.fitness / zfc.fitness:.2f}x")
    print(f"  Axiom increase: {(zfc_lc.axiom_count / zfc.axiom_count - 1) * 100:.0f}%")
    print(f"  Productive extension? {zfc_lc.is_productive_extension_of(zfc)}")
    print(f"  Cross-multiplication check: {zfc_lc.connection_count * zfc_lc.theorem_count * zfc.axiom_count}"
          f" > {zfc.connection_count * zfc.theorem_count * zfc_lc.axiom_count}")


def demo_theory_landscape():
    """Show a landscape of mathematical theories and their fitness."""
    print("\n" + "=" * 60)
    print("DEMO 2: Mathematical Theory Landscape")
    print("=" * 60)

    theories = [
        MathTheory("Peano Arithmetic", 5, 500, 30),
        MathTheory("ZFC", 9, 1000, 50),
        MathTheory("ZFC + Large Cardinals", 12, 1800, 120),
        MathTheory("Category Theory", 4, 600, 80),
        MathTheory("Type Theory (HoTT)", 7, 900, 70),
        MathTheory("Euclidean Geometry", 5, 300, 20),
        MathTheory("Abstract Algebra", 6, 800, 60),
        MathTheory("Topology", 8, 700, 55),
    ]

    theories.sort(key=lambda t: t.fitness, reverse=True)

    print(f"\n{'Theory':<25} {'Axioms':>7} {'Thms':>6} {'Conns':>6} {'Fitness':>10}")
    print("-" * 60)
    for t in theories:
        print(f"{t.name:<25} {t.axiom_count:>7} {t.theorem_count:>6} "
              f"{t.connection_count:>6} {t.fitness:>10.2f}")


def demo_superadditivity():
    """Demonstrate that merging theories is fitness-superadditive."""
    print("\n" + "=" * 60)
    print("DEMO 3: Superadditivity of Fitness Under Merging")
    print("=" * 60)

    t1 = MathTheory("Number Theory", 5, 400, 30)
    t2 = MathTheory("Algebraic Geometry", 5, 350, 25)
    merged = MathTheory("Arithmetic Geometry", 5,
                        t1.theorem_count + t2.theorem_count,
                        t1.connection_count + t2.connection_count)

    cross_term = (t1.theorem_count * t2.connection_count +
                  t2.theorem_count * t1.connection_count) / t1.axiom_count

    print(f"\n{t1.name}: fitness = {t1.fitness:.2f}")
    print(f"{t2.name}: fitness = {t2.fitness:.2f}")
    print(f"Sum of individual fitnesses: {t1.fitness + t2.fitness:.2f}")
    print(f"\n{merged.name} (merged): fitness = {merged.fitness:.2f}")
    print(f"Cross-term bonus: {cross_term:.2f}")
    print(f"Superadditivity gap: {merged.fitness - t1.fitness - t2.fitness:.2f}")
    print(f"Fitness gain from unification: {((merged.fitness / (t1.fitness + t2.fitness)) - 1) * 100:.1f}%")


def demo_scaling():
    """Demonstrate quadratic scaling of fitness."""
    print("\n" + "=" * 60)
    print("DEMO 4: Quadratic Scaling of Fitness")
    print("=" * 60)

    base = MathTheory("Base", 5, 100, 10)
    print(f"\nBase theory: fitness = {base.fitness:.2f}")
    print(f"\nScaling theorems and connections by factor k:")
    print(f"  {'k':>3} {'Theorems':>10} {'Connections':>12} {'Fitness':>10} {'k² × base':>10}")
    for k in range(1, 6):
        scaled = MathTheory(f"Scaled(k={k})", 5, k * 100, k * 10)
        print(f"  {k:>3} {scaled.theorem_count:>10} {scaled.connection_count:>12} "
              f"{scaled.fitness:>10.2f} {k**2 * base.fitness:>10.2f}")


def demo_competitive_exclusion():
    """Show competitive exclusion: same niche → same fitness → same theorem count."""
    print("\n" + "=" * 60)
    print("DEMO 5: Competitive Exclusion Principle")
    print("=" * 60)

    print("\nTwo theories in the same niche (same connections, same axioms):")
    t1 = MathTheory("Theory A", 7, 500, 40)
    t2 = MathTheory("Theory B", 7, 500, 40)
    t3 = MathTheory("Theory C", 7, 600, 40)

    print(f"  {t1.name}: axioms={t1.axiom_count}, conns={t1.connection_count}, "
          f"thms={t1.theorem_count}, fitness={t1.fitness:.2f}")
    print(f"  {t2.name}: axioms={t2.axiom_count}, conns={t2.connection_count}, "
          f"thms={t2.theorem_count}, fitness={t2.fitness:.2f}")
    print(f"  Same niche, same fitness → theorem counts must be equal: "
          f"{t1.theorem_count == t2.theorem_count}")

    print(f"\n  {t3.name}: axioms={t3.axiom_count}, conns={t3.connection_count}, "
          f"thms={t3.theorem_count}, fitness={t3.fitness:.2f}")
    print(f"  Same niche as A but different fitness → can coexist temporarily")
    print(f"  But C dominates A (higher fitness), so A will be excluded")


if __name__ == "__main__":
    demo_zfc_comparison()
    demo_theory_landscape()
    demo_superadditivity()
    demo_scaling()
    demo_competitive_exclusion()


#!/usr/bin/env python3
"""
Theory Ecosystem Visualization: Fitness landscape and dynamics.
Standalone script using matplotlib.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_fitness_landscape():
    """Plot the fitness landscape of mathematical theories."""
    theories = {
        "Peano\nArithmetic": (5, 500, 30),
        "ZFC": (9, 1000, 50),
        "ZFC +\nLarge Cardinals": (12, 1800, 120),
        "Category\nTheory": (4, 600, 80),
        "Type Theory\n(HoTT)": (7, 900, 70),
        "Euclidean\nGeometry": (5, 300, 20),
        "Abstract\nAlgebra": (6, 800, 60),
        "Topology": (8, 700, 55),
    }

    names = list(theories.keys())
    axioms = [theories[n][0] for n in names]
    theorems = [theories[n][1] for n in names]
    connections = [theories[n][2] for n in names]
    fitness = [c * t / a for a, t, c in zip(axioms, theorems, connections)]

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left: Bubble chart - axioms vs connections, size = theorems, color = fitness
    ax1 = axes[0]
    scatter = ax1.scatter(axioms, connections, s=[t/2 for t in theorems],
                          c=fitness, cmap='plasma', alpha=0.7, edgecolors='black', linewidth=1)
    for i, name in enumerate(names):
        ax1.annotate(name, (axioms[i], connections[i]),
                    textcoords="offset points", xytext=(10, 5),
                    fontsize=8, ha='left')
    ax1.set_xlabel("Axiom Count", fontsize=12)
    ax1.set_ylabel("Connection Count", fontsize=12)
    ax1.set_title("Theory Ecosystem: Fitness Landscape", fontsize=14)
    plt.colorbar(scatter, ax=ax1, label="Fitness")

    # Right: Bar chart of fitness
    ax2 = axes[1]
    sorted_idx = np.argsort(fitness)[::-1]
    sorted_names = [names[i] for i in sorted_idx]
    sorted_fitness = [fitness[i] for i in sorted_idx]
    colors = plt.cm.plasma(np.linspace(0.2, 0.9, len(sorted_names)))

    bars = ax2.barh(range(len(sorted_names)), sorted_fitness, color=colors,
                    edgecolor='black', linewidth=0.5)
    ax2.set_yticks(range(len(sorted_names)))
    ax2.set_yticklabels(sorted_names, fontsize=9)
    ax2.set_xlabel("Fitness (connections × theorems / axioms)", fontsize=12)
    ax2.set_title("Theory Fitness Ranking", fontsize=14)
    ax2.invert_yaxis()

    # Annotate ZFC vs ZFC+LC comparison
    for i, (name, f) in enumerate(zip(sorted_names, sorted_fitness)):
        ax2.text(f + 200, i, f"{f:.0f}", va='center', fontsize=9)

    plt.tight_layout()
    plt.savefig("theory_fitness_landscape.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: theory_fitness_landscape.png")


def plot_scaling_and_superadditivity():
    """Plot quadratic scaling and superadditivity."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Quadratic scaling
    ax1 = axes[0]
    base_fitness = 10 * 100 / 5  # c=10, t=100, a=5
    ks = np.arange(1, 8)
    scaled_fitness = [k**2 * base_fitness for k in ks]
    linear_fitness = [k * base_fitness for k in ks]

    ax1.plot(ks, scaled_fitness, 'o-', color='#e74c3c', linewidth=2,
             markersize=8, label='Actual fitness (k² scaling)')
    ax1.plot(ks, linear_fitness, 's--', color='#3498db', linewidth=2,
             markersize=6, label='Linear scaling (hypothetical)')
    ax1.fill_between(ks, linear_fitness, scaled_fitness, alpha=0.15, color='#e74c3c')
    ax1.set_xlabel("Scale factor k", fontsize=12)
    ax1.set_ylabel("Fitness", fontsize=12)
    ax1.set_title("Quadratic Scaling of Fitness", fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: Superadditivity
    ax2 = axes[1]
    a = 5
    t_range = np.arange(50, 500, 50)
    c1, c2 = 20, 15
    t1_base = 200

    superadditive_gaps = []
    for t2 in t_range:
        f1 = c1 * t1_base / a
        f2 = c2 * t2 / a
        f_merged = (c1 + c2) * (t1_base + t2) / a
        gap = f_merged - f1 - f2
        superadditive_gaps.append(gap)

    ax2.bar(range(len(t_range)), superadditive_gaps, color='#2ecc71',
            edgecolor='black', linewidth=0.5)
    ax2.set_xticks(range(len(t_range)))
    ax2.set_xticklabels([str(t) for t in t_range], fontsize=8)
    ax2.set_xlabel("Theorem count of Theory 2", fontsize=12)
    ax2.set_ylabel("Superadditivity bonus", fontsize=12)
    ax2.set_title("Cross-Term Fitness Bonus from Merging", fontsize=14)
    ax2.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig("theory_scaling_superadditivity.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: theory_scaling_superadditivity.png")


def plot_ecosystem_dynamics():
    """Simulate and plot ecosystem dynamics over generations."""
    import math

    theories = [
        ("Peano Arithmetic", 5, 500, 30),
        ("ZFC", 9, 1000, 50),
        ("ZFC+LC", 12, 1800, 120),
        ("Category Theory", 4, 600, 80),
        ("Type Theory", 7, 900, 70),
    ]

    generations = 15
    history = {name: [] for name, _, _, _ in theories}

    current = [(name, a, t, c) for name, a, t, c in theories]

    for gen in range(generations):
        fitnesses = [(c * t / a) for _, a, t, c in current]
        max_f = max(fitnesses)
        for i, (name, a, t, c) in enumerate(current):
            history[name].append(fitnesses[i])
        # Evolve: theorem count grows proportional to relative fitness
        new_current = []
        for i, (name, a, t, c) in enumerate(current):
            rel = fitnesses[i] / max_f
            new_t = max(1, int(t * (0.9 + 0.2 * rel)))
            new_current.append((name, a, new_t, c))
        current = new_current

    fig, ax = plt.subplots(figsize=(12, 7))
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6', '#f39c12']
    for i, (name, _, _, _) in enumerate(theories):
        ax.plot(range(generations), history[name], 'o-', color=colors[i],
                linewidth=2, markersize=5, label=name)

    ax.set_xlabel("Generation", fontsize=12)
    ax.set_ylabel("Fitness", fontsize=12)
    ax.set_title("Theory Ecosystem Dynamics: Fitness Over Generations", fontsize=14)
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("theory_ecosystem_dynamics.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: theory_ecosystem_dynamics.png")


if __name__ == "__main__":
    plot_fitness_landscape()
    plot_scaling_and_superadditivity()
    plot_ecosystem_dynamics()
