#!/usr/bin/env python3
"""
Theory Ecosystem Algorithms: Fitness computation, ecosystem simulation,
and niche analysis.
"""

from dataclasses import dataclass, field
from typing import List, Tuple, Dict, Optional
import math


@dataclass
class MathTheory:
    """A mathematical theory with measurable properties."""
    name: str
    axiom_count: int
    theorem_count: int
    connection_count: int

    def fitness(self) -> float:
        """Compute fitness: connections × theorems / axioms."""
        if self.axiom_count <= 0:
            raise ValueError("Axiom count must be positive")
        return (self.connection_count * self.theorem_count) / self.axiom_count

    def niche(self) -> Tuple[int, int]:
        """Return the niche identifier: (connections, axioms)."""
        return (self.connection_count, self.axiom_count)

    def productivity(self) -> int:
        """Raw productivity: connections × theorems."""
        return self.connection_count * self.theorem_count


def is_productive_extension(base: MathTheory, ext: MathTheory) -> bool:
    """Check if ext is a productive extension of base.

    A productive extension has:
    - Weakly more axioms, theorems, and connections
    - Strictly higher fitness (cross-multiplication test)
    """
    if not (ext.axiom_count >= base.axiom_count and
            ext.theorem_count >= base.theorem_count and
            ext.connection_count >= base.connection_count):
        return False
    return (ext.connection_count * ext.theorem_count * base.axiom_count >
            base.connection_count * base.theorem_count * ext.axiom_count)


def fitness_gap(base: MathTheory, ext: MathTheory) -> float:
    """Compute the fitness gap between an extension and its base."""
    return ext.fitness() - base.fitness()


def merge_theories(t1: MathTheory, t2: MathTheory,
                   name: Optional[str] = None) -> MathTheory:
    """Merge two theories sharing the same axiom base.

    Assumes same axiom count. Sums theorems and connections.
    Cross-terms make fitness superadditive.
    """
    if t1.axiom_count != t2.axiom_count:
        raise ValueError("Can only merge theories with same axiom count")
    return MathTheory(
        name=name or f"{t1.name}+{t2.name}",
        axiom_count=t1.axiom_count,
        theorem_count=t1.theorem_count + t2.theorem_count,
        connection_count=t1.connection_count + t2.connection_count
    )


def cross_term_bonus(t1: MathTheory, t2: MathTheory) -> float:
    """Compute the cross-term fitness bonus from merging.

    When merging theories with the same axiom base, the fitness gain
    beyond the sum of individual fitnesses is:
    (t1.theorems * t2.connections + t2.theorems * t1.connections) / axioms
    """
    if t1.axiom_count != t2.axiom_count:
        raise ValueError("Can only compute cross-term for same axiom count")
    return (t1.theorem_count * t2.connection_count +
            t2.theorem_count * t1.connection_count) / t1.axiom_count


@dataclass
class TheoryEcosystem:
    """A collection of mathematical theories forming an ecosystem."""
    theories: List[MathTheory] = field(default_factory=list)

    def add_theory(self, theory: MathTheory) -> None:
        self.theories.append(theory)

    def fitness_ranking(self) -> List[Tuple[MathTheory, float]]:
        """Rank theories by fitness, highest first."""
        ranked = [(t, t.fitness()) for t in self.theories]
        ranked.sort(key=lambda x: x[1], reverse=True)
        return ranked

    def niche_partition(self) -> Dict[Tuple[int, int], List[MathTheory]]:
        """Partition theories by niche."""
        partition: Dict[Tuple[int, int], List[MathTheory]] = {}
        for t in self.theories:
            n = t.niche()
            if n not in partition:
                partition[n] = []
            partition[n].append(t)
        return partition

    def check_competitive_exclusion(self) -> List[Tuple[MathTheory, MathTheory]]:
        """Find pairs violating competitive exclusion (same niche, same fitness,
        different theorem count). Should always return empty list."""
        violations = []
        partition = self.niche_partition()
        for niche, theories in partition.items():
            for i, t1 in enumerate(theories):
                for t2 in theories[i+1:]:
                    if (abs(t1.fitness() - t2.fitness()) < 1e-10 and
                            t1.theorem_count != t2.theorem_count and
                            t1.connection_count > 0):
                        violations.append((t1, t2))
        return violations

    def simulate_selection(self, generations: int = 10,
                           growth_rate: float = 1.1) -> List[List[Tuple[str, float]]]:
        """Simulate ecosystem dynamics where fitness determines growth.

        Each generation, each theory's theorem count grows proportionally
        to its relative fitness. Low-fitness theories eventually die out.
        """
        history = []
        current = [MathTheory(t.name, t.axiom_count, t.theorem_count,
                               t.connection_count) for t in self.theories]

        for gen in range(generations):
            fitnesses = [t.fitness() for t in current]
            max_f = max(fitnesses) if fitnesses else 1.0
            history.append([(t.name, f) for t, f in zip(current, fitnesses)])

            # Growth proportional to relative fitness
            for i, t in enumerate(current):
                relative_fitness = fitnesses[i] / max_f if max_f > 0 else 0
                growth = max(1, int(t.theorem_count * relative_fitness * growth_rate))
                current[i] = MathTheory(t.name, t.axiom_count, growth,
                                         t.connection_count)

        return history


def optimal_axiom_count(theorems: int, connections: int,
                        max_axioms: int = 100) -> int:
    """Find the axiom count that maximizes fitness.

    Since fitness = c*t/a, and c and t are fixed, fitness is maximized
    by minimizing a. The minimum is a=1 (trivially).
    But in practice, more axioms enable more theorems and connections.
    This function finds the optimal tradeoff assuming linear growth.
    """
    best_a = 1
    best_fitness = connections * theorems
    for a in range(1, max_axioms + 1):
        # Model: theorems grow as t * sqrt(a), connections grow as c * log(a+1)
        t = int(theorems * math.sqrt(a))
        c = int(connections * math.log(a + 1))
        f = c * t / a
        if f > best_fitness:
            best_fitness = f
            best_a = a
    return best_a


if __name__ == "__main__":
    # Build ecosystem
    eco = TheoryEcosystem()
    eco.add_theory(MathTheory("Peano Arithmetic", 5, 500, 30))
    eco.add_theory(MathTheory("ZFC", 9, 1000, 50))
    eco.add_theory(MathTheory("ZFC+LC", 12, 1800, 120))
    eco.add_theory(MathTheory("Category Theory", 4, 600, 80))
    eco.add_theory(MathTheory("Type Theory", 7, 900, 70))

    print("Fitness Ranking:")
    for t, f in eco.fitness_ranking():
        print(f"  {t.name:<25} fitness = {f:.2f}")

    print("\nNiche Partition:")
    for niche, theories in eco.niche_partition().items():
        names = ", ".join(t.name for t in theories)
        print(f"  Niche {niche}: {names}")

    print(f"\nCompetitive exclusion violations: {len(eco.check_competitive_exclusion())}")

    print("\nSimulation (5 generations):")
    history = eco.simulate_selection(5)
    for i, gen in enumerate(history):
        top = max(gen, key=lambda x: x[1])
        print(f"  Gen {i}: top = {top[0]} (fitness {top[1]:.2f})")
