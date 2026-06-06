"""
Theory Ecosystem: Algorithms for Mathematical Theory Fitness Analysis

Implements the formal theory fitness framework with typed Python classes
for theory representation, fitness computation, ecosystem simulation,
and optimal extension analysis.
"""

from __future__ import annotations
from dataclasses import dataclass
from fractions import Fraction
from typing import List, Tuple, Optional, Dict


@dataclass(frozen=True)
class FormalTheory:
    """A mathematical theory characterized by structural parameters.
    
    Attributes:
        axiom_count: Number of independent axioms (must be > 0)
        theorem_count: Number of proved theorems
        connection_count: Number of connections to other theories
        name: Optional human-readable name
    """
    axiom_count: int
    theorem_count: int
    connection_count: int
    name: str = "unnamed"
    
    def __post_init__(self):
        if self.axiom_count <= 0:
            raise ValueError(f"axiom_count must be positive, got {self.axiom_count}")
    
    @property
    def fitness(self) -> Fraction:
        """Compute fitness: connections * theorems / axioms^2"""
        return Fraction(
            self.connection_count * self.theorem_count,
            self.axiom_count ** 2
        )
    
    @property
    def proof_density(self) -> Fraction:
        """Compute proof density: theorems / axioms"""
        return Fraction(self.theorem_count, self.axiom_count)
    
    def is_non_degenerate(self) -> bool:
        """Check if theory has positive theorems and connections."""
        return self.theorem_count > 0 and self.connection_count > 0


def is_fertile_extension(t1: FormalTheory, t2: FormalTheory) -> bool:
    """Check if t2 is a fertile extension of t1.
    
    A fertile extension maintains connections and generates theorems
    faster than the quadratic axiom penalty grows.
    """
    return (
        t2.connection_count >= t1.connection_count
        and t1.connection_count > 0
        and t2.theorem_count * t1.axiom_count**2 
            > t1.theorem_count * t2.axiom_count**2
    )


def fitness_comparison(t1: FormalTheory, t2: FormalTheory) -> int:
    """Compare fitness using integer arithmetic (no division).
    
    Returns:
        1 if f(t1) > f(t2)
        -1 if f(t1) < f(t2)
        0 if f(t1) == f(t2)
    """
    lhs = t1.connection_count * t1.theorem_count * t2.axiom_count**2
    rhs = t2.connection_count * t2.theorem_count * t1.axiom_count**2
    if lhs > rhs:
        return 1
    elif lhs < rhs:
        return -1
    return 0


@dataclass(frozen=True)
class PositionedTheory:
    """A theory with its ecological niche assignment."""
    theory: FormalTheory
    niche: int  # niche identifier


def find_survivors(ecosystem: List[PositionedTheory]) -> List[PositionedTheory]:
    """Find all surviving theories in an ecosystem.
    
    A theory survives if no theory in the same niche has higher fitness.
    
    Algorithm: O(n) — compute max fitness per niche, filter.
    """
    # Find maximum fitness per niche
    niche_max: Dict[int, Fraction] = {}
    for pt in ecosystem:
        f = pt.theory.fitness
        if pt.niche not in niche_max or f > niche_max[pt.niche]:
            niche_max[pt.niche] = f
    
    # Filter to survivors
    return [
        pt for pt in ecosystem
        if pt.theory.fitness >= niche_max[pt.niche]
    ]


def merge_theories(
    t1: FormalTheory, 
    t2: FormalTheory, 
    shared_axioms: int,
    name: str = "merged"
) -> FormalTheory:
    """Merge two theories with shared axioms.
    
    Args:
        t1, t2: Theories to merge
        shared_axioms: Number of axioms shared between theories
        name: Name for the merged theory
    
    Returns:
        Merged theory with combined parameters
    """
    if shared_axioms >= t1.axiom_count + t2.axiom_count:
        raise ValueError("Shared axioms must be less than total axioms")
    if shared_axioms > min(t1.axiom_count, t2.axiom_count):
        raise ValueError("Shared axioms cannot exceed either theory's axiom count")
    
    return FormalTheory(
        axiom_count=t1.axiom_count + t2.axiom_count - shared_axioms,
        theorem_count=t1.theorem_count + t2.theorem_count,
        connection_count=t1.connection_count + t2.connection_count,
        name=name
    )


def axiom_efficiency_threshold(theory: FormalTheory) -> Fraction:
    """Compute the minimum marginal product (Δc+c)(Δt+t) needed
    for adding one axiom to increase fitness.
    
    Returns the threshold: c * t * (a+1)^2 / a^2
    """
    a = theory.axiom_count
    return Fraction(
        theory.connection_count * theory.theorem_count * (a + 1)**2,
        a**2
    )


def optimal_extension(
    theory: FormalTheory,
    candidates: List[Tuple[int, int, str]]  # (delta_t, delta_c, name)
) -> Optional[Tuple[FormalTheory, Fraction]]:
    """Find the single-axiom extension that maximizes fitness gain.
    
    Args:
        theory: Base theory to extend
        candidates: List of (theorem_gain, connection_gain, name) tuples
    
    Returns:
        (extended_theory, fitness_gain) or None if no extension improves fitness
    """
    best = None
    best_gain = Fraction(0)
    
    for dt, dc, name in candidates:
        extended = FormalTheory(
            axiom_count=theory.axiom_count + 1,
            theorem_count=theory.theorem_count + dt,
            connection_count=theory.connection_count + dc,
            name=name
        )
        gain = extended.fitness - theory.fitness
        if gain > best_gain:
            best = extended
            best_gain = gain
    
    if best is None:
        return None
    return best, best_gain


def red_queen_critical_exponent() -> int:
    """Return the critical exponent for the Red Queen effect.
    
    For theory families T(a) = (a, α·a^β, c):
    - β < 2: fitness decreases with axiom count
    - β = 2: fitness is constant  
    - β > 2: fitness increases with axiom count
    """
    return 2


def simulate_ecosystem_dynamics(
    ecosystem: List[PositionedTheory],
    rounds: int = 100
) -> List[List[PositionedTheory]]:
    """Simulate competitive dynamics by iteratively removing dominated theories.
    
    In each round, theories with below-maximum fitness in their niche
    are eliminated. Returns the history of ecosystem states.
    """
    history = [list(ecosystem)]
    current = list(ecosystem)
    
    for _ in range(rounds):
        survivors = find_survivors(current)
        if len(survivors) == len(current):
            break  # equilibrium reached
        current = survivors
        history.append(list(current))
    
    return history
