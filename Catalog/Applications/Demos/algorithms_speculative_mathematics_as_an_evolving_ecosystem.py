"""
Theory Ecosystem Algorithms: Fitness, Competition, and Evolution

Implements the mathematical framework for modeling mathematical theories
as species in an intellectual ecosystem with fitness-driven evolution.
"""

from typing import List, Tuple, Optional
from dataclasses import dataclass
import math


@dataclass
class TheorySpec:
    """A mathematical theory modeled as an ecosystem species."""
    name: str
    axiom_count: int      # Number of axioms (parsimony)
    theorem_count: int    # Number of theorems (productivity)
    connection_count: int # Inter-theoretic connections

    def __post_init__(self):
        assert self.axiom_count > 0, "Axiom count must be positive"

    def fitness(self) -> float:
        """f(T) = connections * theorems / axioms^2"""
        return (self.connection_count * self.theorem_count) / (self.axiom_count ** 2)

    def explanatory_power(self) -> int:
        """connections * theorems: the numerator of fitness"""
        return self.connection_count * self.theorem_count


def fitness_comparison(t1: TheorySpec, t2: TheorySpec) -> int:
    """Compare fitness without floating point: returns +1 if t1 fitter, -1 if t2 fitter, 0 if equal.
    Uses cross-multiplication: c1*t1*a2^2 vs c2*t2*a1^2"""
    lhs = t1.connection_count * t1.theorem_count * t2.axiom_count ** 2
    rhs = t2.connection_count * t2.theorem_count * t1.axiom_count ** 2
    if lhs > rhs:
        return 1
    elif lhs < rhs:
        return -1
    return 0


def extension_beneficial(theory: TheorySpec, new_axioms: int,
                          new_theorems: int, new_connections: int) -> bool:
    """Check if extending a theory increases fitness.
    Extension is beneficial iff:
    (c + Δc)(t + Δt) * a^2 > c * t * (a + Δa)^2"""
    c, t, a = theory.connection_count, theory.theorem_count, theory.axiom_count
    lhs = (c + new_connections) * (t + new_theorems) * a ** 2
    rhs = c * t * (a + new_axioms) ** 2
    return lhs > rhs


def critical_threshold(a: int, c: int, t: int) -> float:
    """The minimum gain in explanatory power needed for a single-axiom
    extension to increase fitness.
    Threshold = c * t * (2a + 1) / a^2"""
    return c * t * (2 * a + 1) / (a ** 2)


def quadratic_penalty(a: int) -> int:
    """The quadratic cost of adding one more axiom: (a+1)^2 - a^2 = 2a+1"""
    return 2 * a + 1


def ecosystem_evolution(theories: List[TheorySpec],
                        generations: int = 100,
                        mutation_rate: float = 0.1) -> List[List[TheorySpec]]:
    """Simulate ecosystem evolution with fitness-driven selection.

    At each generation:
    1. Compute fitness for all theories
    2. Theories below median fitness lose connections (competitive exclusion)
    3. Theories above median gain connections (reinforcement)
    4. Random mutations add/remove axioms with probability mutation_rate

    Returns history of theory states over generations.
    """
    import random
    history = [list(theories)]

    for _ in range(generations):
        fitnesses = [(t, t.fitness()) for t in theories]
        fitnesses.sort(key=lambda x: x[1])
        median_fitness = fitnesses[len(fitnesses) // 2][1]

        new_theories = []
        for theory, fit in fitnesses:
            new_conn = theory.connection_count
            new_thm = theory.theorem_count
            new_ax = theory.axiom_count

            # Fitness-driven dynamics
            if fit > median_fitness:
                new_conn = int(new_conn * 1.05)  # Winners gain connections
                new_thm = int(new_thm * 1.02)    # And prove more theorems
            else:
                new_conn = max(1, int(new_conn * 0.95))  # Losers lose connections

            # Random mutations
            if random.random() < mutation_rate:
                if random.random() < 0.5 and new_ax > 1:
                    new_ax -= 1  # Axiom reduction (Occam pressure)
                else:
                    new_ax += 1  # Axiom addition
                    new_thm = int(new_thm * 1.1)  # New axiom enables more theorems
                    new_conn = int(new_conn * 1.15)  # And more connections

            new_theories.append(TheorySpec(
                name=theory.name,
                axiom_count=max(1, new_ax),
                theorem_count=max(1, new_thm),
                connection_count=max(1, new_conn)
            ))

        theories = new_theories
        history.append(list(theories))

    return history


def find_fitness_fixed_points(theories: List[TheorySpec],
                               max_iter: int = 1000,
                               tolerance: float = 1e-6) -> List[TheorySpec]:
    """Find equilibrium states where no single-axiom extension is beneficial."""
    equilibrium = list(theories)

    for _ in range(max_iter):
        changed = False
        for i, theory in enumerate(equilibrium):
            # Check if adding an axiom would help
            best_fitness = theory.fitness()
            best_spec = theory

            for delta_t in range(0, 100, 10):
                for delta_c in range(0, 50, 5):
                    if extension_beneficial(theory, 1, delta_t, delta_c):
                        extended = TheorySpec(
                            name=theory.name,
                            axiom_count=theory.axiom_count + 1,
                            theorem_count=theory.theorem_count + delta_t,
                            connection_count=theory.connection_count + delta_c
                        )
                        if extended.fitness() > best_fitness + tolerance:
                            best_fitness = extended.fitness()
                            best_spec = extended
                            changed = True

            equilibrium[i] = best_spec

        if not changed:
            break

    return equilibrium


# ===== Named theory instances =====

ZFC = TheorySpec("ZFC", axiom_count=9, theorem_count=1000, connection_count=20)
ZFC_LC = TheorySpec("ZFC+LC", axiom_count=10, theorem_count=1400, connection_count=35)
PA = TheorySpec("PA", axiom_count=5, theorem_count=800, connection_count=15)
CATEGORY_THEORY = TheorySpec("Category Theory", axiom_count=4, theorem_count=600, connection_count=30)
TYPE_THEORY = TheorySpec("Type Theory", axiom_count=7, theorem_count=500, connection_count=25)
EUCLIDEAN_GEOMETRY = TheorySpec("Euclidean Geometry", axiom_count=5, theorem_count=400, connection_count=10)


if __name__ == "__main__":
    theories = [ZFC, ZFC_LC, PA, CATEGORY_THEORY, TYPE_THEORY, EUCLIDEAN_GEOMETRY]

    print("=== Theory Fitness Rankings ===")
    ranked = sorted(theories, key=lambda t: t.fitness(), reverse=True)
    for i, t in enumerate(ranked, 1):
        print(f"  {i}. {t.name}: f = {t.fitness():.2f} "
              f"(a={t.axiom_count}, t={t.theorem_count}, c={t.connection_count})")

    print(f"\n=== ZFC vs ZFC+LC ===")
    print(f"  ZFC fitness:    {ZFC.fitness():.2f}")
    print(f"  ZFC+LC fitness: {ZFC_LC.fitness():.2f}")
    print(f"  Comparison: {'ZFC+LC wins' if fitness_comparison(ZFC_LC, ZFC) > 0 else 'ZFC wins'}")

    print(f"\n=== Extension Analysis ===")
    print(f"  Critical threshold for ZFC: {critical_threshold(9, 20, 1000):.2f}")
    print(f"  Actual gain from LC: {(35*1400 - 20*1000):.0f}")
    print(f"  Quadratic penalty at a=9: {quadratic_penalty(9)}")
    print(f"  Quadratic penalty at a=10: {quadratic_penalty(10)}")
