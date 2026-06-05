#!/usr/bin/env python3
"""
Theory Ecosystem Algorithms

Type-hinted implementations of core algorithms from the Theory Ecosystem framework.
"""

from fractions import Fraction
from dataclasses import dataclass


@dataclass
class TheorySpecies:
    """A mathematical theory modeled as an ecosystem species.
    
    Attributes:
        name: Human-readable name
        axioms: Number of independent axioms (must be > 0)
        theorems: Number of provable theorems
        connections: Number of connections to other theories
    """
    name: str
    axioms: int
    theorems: int
    connections: int
    
    def __post_init__(self) -> None:
        if self.axioms <= 0:
            raise ValueError(f"axioms must be positive, got {self.axioms}")
    
    def fitness(self) -> Fraction:
        """Compute fitness: f(T) = connections * theorems / axioms."""
        return Fraction(self.connections * self.theorems, self.axioms)
    
    def niche_signature(self) -> tuple[Fraction, Fraction]:
        """Compute niche signature: (theorems/axioms, connections/axioms)."""
        return (Fraction(self.theorems, self.axioms),
                Fraction(self.connections, self.axioms))
    
    def productivity(self) -> int:
        """Raw productivity: connections * theorems."""
        return self.connections * self.theorems


def extension_criterion(
    T: TheorySpecies, 
    delta_axioms: int, 
    delta_theorems: int, 
    delta_connections: int
) -> bool:
    """Check whether extending theory T increases fitness.
    
    Returns True iff adding (da, dt, dc) to T increases fitness.
    Uses the exact algebraic criterion from Theorem 3.1:
      (c + dc)(t + dt) * a > c * t * (a + da)
    """
    c, t, a = T.connections, T.theorems, T.axioms
    dc, dt, da = delta_connections, delta_theorems, delta_axioms
    return (c + dc) * (t + dt) * a > c * t * (a + da)


def extend_theory(
    T: TheorySpecies,
    delta_axioms: int,
    delta_theorems: int,
    delta_connections: int,
    new_name: str | None = None
) -> TheorySpecies:
    """Create an extended theory by adding axioms, theorems, and connections."""
    return TheorySpecies(
        name=new_name or f"{T.name}+ext",
        axioms=T.axioms + delta_axioms,
        theorems=T.theorems + delta_theorems,
        connections=T.connections + delta_connections
    )


def merge_theories(T1: TheorySpecies, T2: TheorySpecies) -> TheorySpecies:
    """Merge two theories by combining all components."""
    return TheorySpecies(
        name=f"{T1.name}⊕{T2.name}",
        axioms=T1.axioms + T2.axioms,
        theorems=T1.theorems + T2.theorems,
        connections=T1.connections + T2.connections
    )


def specialize_theory(
    T: TheorySpecies, 
    remove_axioms: int,
    new_name: str | None = None
) -> TheorySpecies:
    """Create a specialized theory by removing redundant axioms.
    
    Precondition: remove_axioms < T.axioms
    """
    if remove_axioms >= T.axioms:
        raise ValueError(f"Cannot remove {remove_axioms} axioms from theory with {T.axioms}")
    return TheorySpecies(
        name=new_name or f"{T.name}-spec",
        axioms=T.axioms - remove_axioms,
        theorems=T.theorems,
        connections=T.connections
    )


def competitive_exclusion(
    ecosystem: dict[str, list[TheorySpecies]]
) -> dict[str, TheorySpecies]:
    """Simulate competitive exclusion: in each niche, only the fittest survives.
    
    Args:
        ecosystem: Mapping from niche names to lists of competing theories
    
    Returns:
        Mapping from niche names to surviving theory (the fittest in each niche)
    """
    survivors: dict[str, TheorySpecies] = {}
    for niche, species in ecosystem.items():
        if species:
            survivors[niche] = max(species, key=lambda t: t.fitness())
    return survivors


def niche_fiber_bound(n_species: int, n_niches: int) -> int:
    """Compute the pigeonhole lower bound on maximum niche occupancy.
    
    At least one niche must contain at least ceil(n/m) species.
    Returns floor(n/m) as a conservative bound.
    """
    if n_niches <= 0:
        raise ValueError("Number of niches must be positive")
    return n_species // n_niches


def large_cardinal_threshold(axiom_count: int) -> Fraction:
    """Compute the minimum productivity growth ratio for a 1-axiom extension to pay off.
    
    For a theory with `a` axioms, adding 1 axiom increases fitness iff
    the new productivity exceeds the old productivity by a factor of (a+1)/a.
    """
    return Fraction(axiom_count + 1, axiom_count)


def fitness_landscape(
    theories: list[TheorySpecies]
) -> list[tuple[TheorySpecies, Fraction, tuple[Fraction, Fraction]]]:
    """Compute the fitness landscape: (theory, fitness, niche_signature) for each theory."""
    return [(T, T.fitness(), T.niche_signature()) for T in theories]


def ecosystem_equilibrium_simulation(
    species: list[TheorySpecies],
    niche_assignment: dict[str, str],
    rounds: int = 100
) -> list[tuple[str, TheorySpecies, float]]:
    """Simulate ecosystem dynamics with discrete Lotka-Volterra selection.
    
    Args:
        species: List of theory species
        niche_assignment: Mapping from species name to niche name
        rounds: Number of simulation rounds
    
    Returns:
        List of (niche, surviving_theory, final_population_share) tuples
    """
    # Group by niche
    niches: dict[str, list[tuple[TheorySpecies, float]]] = {}
    for T in species:
        niche = niche_assignment.get(T.name, "default")
        if niche not in niches:
            niches[niche] = []
        niches[niche].append((T, 1.0 / len(species)))
    
    # Simulate selection
    for _ in range(rounds):
        for niche, pop in niches.items():
            if len(pop) <= 1:
                continue
            total_fitness = sum(float(T.fitness()) * p for T, p in pop)
            if total_fitness <= 0:
                continue
            new_pop = []
            for T, p in pop:
                new_p = p * float(T.fitness()) / total_fitness * sum(pp for _, pp in pop)
                if new_p > 1e-10:
                    new_pop.append((T, new_p))
            niches[niche] = new_pop
    
    results = []
    for niche, pop in niches.items():
        for T, p in pop:
            results.append((niche, T, p))
    return sorted(results, key=lambda x: -x[2])


if __name__ == "__main__":
    # Quick test
    zfc = TheorySpecies("ZFC", 9, 10000, 50)
    zfc_lc = TheorySpecies("ZFC+LC", 10, 12000, 60)
    
    print(f"ZFC fitness: {float(zfc.fitness()):.1f}")
    print(f"ZFC+LC fitness: {float(zfc_lc.fitness()):.1f}")
    print(f"Extension threshold (9 axioms): {float(large_cardinal_threshold(9)):.4f}")
    print(f"Actual growth ratio: {float(Fraction(zfc_lc.productivity(), zfc.productivity())):.4f}")
    print(f"Worth extending: {extension_criterion(zfc, 1, 2000, 10)}")
