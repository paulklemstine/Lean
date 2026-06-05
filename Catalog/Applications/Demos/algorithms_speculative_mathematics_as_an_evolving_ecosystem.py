"""
Theory Ecosystem Algorithms
============================

Type-hinted implementations of the core algorithms from the Theory Ecosystem framework.
"""

from dataclasses import dataclass
from typing import List, Tuple, Optional
import math


@dataclass
class FormalTheory:
    """A mathematical theory characterized by axioms, theorems, and connections."""
    axioms: int
    theorems: int
    connections: int
    name: str = ""

    def __post_init__(self) -> None:
        if self.axioms < 1:
            raise ValueError("A theory must have at least one axiom")

    @property
    def raw_fitness(self) -> int:
        """Raw fitness numerator: connections × theorems."""
        return self.connections * self.theorems

    @property
    def fitness(self) -> float:
        """Fitness: connections × theorems / axioms²."""
        return self.raw_fitness / (self.axioms ** 2)

    @property
    def proof_density(self) -> float:
        """Theorems per axiom."""
        return self.theorems / self.axioms

    def fitter_than(self, other: 'FormalTheory') -> bool:
        """Cross-multiplied fitness comparison (exact, no floating point)."""
        return (self.raw_fitness * other.axioms ** 2 >
                other.raw_fitness * self.axioms ** 2)


def evolve_step(theory: FormalTheory, alpha: int, beta: int) -> FormalTheory:
    """One step of theory evolution.

    Theorems grow by α × connections (cross-pollination).
    Connections grow by β × theorems (influence).
    Axioms remain fixed.
    """
    return FormalTheory(
        axioms=theory.axioms,
        theorems=theory.theorems + alpha * theory.connections,
        connections=theory.connections + beta * theory.theorems,
        name=theory.name
    )


def fitness_decomposition(theory: FormalTheory, alpha: int, beta: int
                          ) -> Tuple[int, int, int, int]:
    """Decompose the fitness gain from one evolution step.

    Returns (original, direct_theorem, direct_connection, synergy).
    """
    original = theory.raw_fitness
    direct_theorem = alpha * theory.connections ** 2
    direct_connection = beta * theory.theorems ** 2
    synergy = alpha * beta * theory.raw_fitness
    return original, direct_theorem, direct_connection, synergy


def extension_threshold(a: int, t: int, c: int, k: int, dt: int, dc: int) -> bool:
    """Check if extending a theory (adding k axioms, dt theorems, dc connections)
    improves fitness.

    Uses exact integer arithmetic (cross-multiplication).
    """
    return (c + dc) * (t + dt) * a ** 2 > c * t * (a + k) ** 2


def content_gain_ratio(t: int, c: int, dt: int, dc: int) -> float:
    """The content gain ratio: how much new content relative to original."""
    if c * t == 0:
        return float('inf') if (c + dc) * (t + dt) > 0 else 0.0
    return (c + dc) * (t + dt) / (c * t)


def axiom_cost_ratio(a: int, k: int) -> float:
    """The quadratic axiom cost ratio."""
    return ((a + k) / a) ** 2


@dataclass
class TheoryEcosystem:
    """A collection of theories with niche assignments."""
    theories: List[FormalTheory]
    niches: List[int]

    def __post_init__(self) -> None:
        if len(self.theories) != len(self.niches):
            raise ValueError("Each theory must have a niche assignment")

    def niche_dominant(self) -> List[FormalTheory]:
        """Return the dominant theory in each niche (competitive exclusion)."""
        niche_best: dict[int, Tuple[int, FormalTheory]] = {}
        for i, (theory, niche) in enumerate(zip(self.theories, self.niches)):
            if niche not in niche_best or theory.fitter_than(niche_best[niche][1]):
                niche_best[niche] = (i, theory)
        return [t for _, t in sorted(niche_best.values())]

    def total_fitness(self) -> float:
        """Sum of all theories' fitness values."""
        return sum(t.fitness for t in self.theories)

    def diversity(self) -> int:
        """Number of distinct niches occupied."""
        return len(set(self.niches))

    def ecosystem_entropy(self) -> float:
        """Shannon entropy of the fitness distribution."""
        total = self.total_fitness()
        if total == 0:
            return 0.0
        probs = [t.fitness / total for t in self.theories if t.fitness > 0]
        return -sum(p * math.log2(p) for p in probs if p > 0)


def simulate_evolution(theory: FormalTheory, alpha: int, beta: int,
                       steps: int) -> List[FormalTheory]:
    """Simulate multiple evolution steps, returning the trajectory."""
    trajectory = [theory]
    current = theory
    for _ in range(steps):
        current = evolve_step(current, alpha, beta)
        trajectory.append(current)
    return trajectory


def find_optimal_split(a: int, t: int, c: int
                       ) -> Optional[Tuple[FormalTheory, FormalTheory, float]]:
    """Find the optimal way to split a theory into two theories
    that maximizes total fitness.

    Returns (theory1, theory2, total_fitness) or None if no split improves fitness.
    """
    original = FormalTheory(a, t, c)
    original_fitness = original.fitness

    best_split: Optional[Tuple[FormalTheory, FormalTheory, float]] = None
    best_fitness = original_fitness

    for a1 in range(1, a):
        a2 = a - a1
        if a2 < 1:
            continue
        for t1 in range(0, t + 1):
            t2 = t - t1
            for c1 in range(1, c + 1):
                c2 = max(1, c - c1 + 1)  # +1 for cross-connection
                t1_theory = FormalTheory(a1, t1, c1)
                t2_theory = FormalTheory(a2, t2, c2)
                total = t1_theory.fitness + t2_theory.fitness
                if total > best_fitness:
                    best_fitness = total
                    best_split = (t1_theory, t2_theory, total)

    return best_split


# Key examples
ZFC = FormalTheory(axioms=9, theorems=1000, connections=5, name="ZFC")
ZFC_LC = FormalTheory(axioms=11, theorems=1500, connections=8, name="ZFC+LC")
PEANO = FormalTheory(axioms=5, theorems=800, connections=4, name="Peano Arithmetic")
EUCLIDEAN = FormalTheory(axioms=5, theorems=465, connections=6, name="Euclidean Geometry")
CATEGORY = FormalTheory(axioms=4, theorems=600, connections=10, name="Category Theory")


if __name__ == "__main__":
    theories = [ZFC, ZFC_LC, PEANO, EUCLIDEAN, CATEGORY]
    print("=== Theory Fitness Rankings ===\n")
    for t in sorted(theories, key=lambda x: x.fitness, reverse=True):
        print(f"  {t.name:25s}  fitness = {t.fitness:8.2f}  "
              f"(a={t.axioms}, t={t.theorems}, c={t.connections})")

    print(f"\n=== ZFC vs ZFC+LC ===")
    print(f"  ZFC fitness:    {ZFC.fitness:.2f}")
    print(f"  ZFC+LC fitness: {ZFC_LC.fitness:.2f}")
    print(f"  ZFC+LC dominates: {ZFC_LC.fitter_than(ZFC)}")
    print(f"  Content gain ratio: {content_gain_ratio(1000, 5, 500, 3):.2f}")
    print(f"  Axiom cost ratio:   {axiom_cost_ratio(9, 2):.2f}")

    print(f"\n=== Evolution Simulation (Category Theory, α=β=1, 5 steps) ===")
    trajectory = simulate_evolution(CATEGORY, 1, 1, 5)
    for i, t in enumerate(trajectory):
        print(f"  Step {i}: fitness = {t.fitness:10.2f}  "
              f"(t={t.theorems}, c={t.connections})")
