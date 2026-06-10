#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for the SimulatorAlgebra framework.

Type-hinted implementations of:
1. Knaster-Tarski least/greatest fixed point computation
2. Self-simulation iteration
3. Fixed-point defect measurement
4. Complexity-weighted selection
5. Simulator composition
"""

from typing import TypeVar, Callable, Optional, Set, FrozenSet, List, Tuple
from dataclasses import dataclass
import math

T = TypeVar('T')


@dataclass
class SimulatorAlgebra:
    """
    A SimulatorAlgebra over a finite lattice represented as subsets of a universe.
    
    Elements are frozensets (subsets of `universe`).
    The lattice order is set inclusion.
    sim: (frozenset, frozenset) -> frozenset is a monotone binary operator.
    """
    universe: FrozenSet[int]
    sim: Callable[[FrozenSet[int], FrozenSet[int]], FrozenSet[int]]
    
    def self_sim(self, L: FrozenSet[int]) -> FrozenSet[int]:
        """The diagonal self-simulation operator Φ(L) = sim(L, L)."""
        return self.sim(L, L)
    
    def is_self_consistent(self, L: FrozenSet[int]) -> bool:
        """Check if L is a fixed point of Φ."""
        return self.self_sim(L) == L
    
    def all_elements(self) -> List[FrozenSet[int]]:
        """Generate all elements of the powerset lattice."""
        n = len(self.universe)
        elems = list(self.universe)
        result = []
        for mask in range(2**n):
            result.append(frozenset(elems[i] for i in range(n) if mask & (1 << i)))
        return result
    
    def find_all_fixed_points(self) -> List[FrozenSet[int]]:
        """Find all self-consistent law configurations."""
        return [L for L in self.all_elements() if self.is_self_consistent(L)]
    
    def minimal_law(self) -> FrozenSet[int]:
        """
        Compute the minimal (least) fixed point by Knaster-Tarski iteration.
        
        Algorithm: Start from ⊥ = ∅, iterate Φ until convergence.
        For finite lattices, this always terminates and gives the LFP.
        """
        L = frozenset()  # ⊥
        while True:
            L_next = self.self_sim(L)
            if L_next == L:
                return L
            # For finite lattices, if Φ(L) ⊇ L (which holds by monotonicity
            # from ⊥), iteration converges in at most |universe| steps.
            if not L_next >= L:
                # Fallback: find LFP by enumeration
                fps = self.find_all_fixed_points()
                return min(fps, key=lambda s: len(s))
            L = L_next
    
    def maximal_law(self) -> FrozenSet[int]:
        """
        Compute the maximal (greatest) fixed point by reverse iteration.
        
        Algorithm: Start from ⊤ = universe, iterate Φ downward.
        """
        L = self.universe  # ⊤
        while True:
            L_next = self.self_sim(L)
            if L_next == L:
                return L
            if not L_next <= L:
                fps = self.find_all_fixed_points()
                return max(fps, key=lambda s: len(s))
            L = L_next
    
    def fixed_point_defect(self, L: FrozenSet[int]) -> FrozenSet[int]:
        """The fixed-point defect: Φ(L) ∪ L."""
        return self.self_sim(L) | L
    
    def iterate_from_bottom(self, max_steps: int = 100) -> List[FrozenSet[int]]:
        """Return the iteration sequence Φ^n(⊥) until convergence."""
        trajectory = []
        L = frozenset()
        for _ in range(max_steps):
            trajectory.append(L)
            L_next = self.self_sim(L)
            if L_next == L:
                break
            L = L_next
        return trajectory


def compose_simulators(S: SimulatorAlgebra, T: SimulatorAlgebra) -> SimulatorAlgebra:
    """
    Compose two simulator algebras: (S∘T).sim(a,b) = S.sim(T.sim(a,b), T.sim(a,b)).
    """
    def composed_sim(a: FrozenSet[int], b: FrozenSet[int]) -> FrozenSet[int]:
        t_val = T.sim(a, b)
        return S.sim(t_val, t_val)
    
    return SimulatorAlgebra(
        universe=S.universe,
        sim=composed_sim
    )


@dataclass
class ComplexityMeasure:
    """A complexity measure on subsets: maps each subset to a nonneg real."""
    measure: Callable[[FrozenSet[int]], float]
    
    def complexity_minimal_law(self, S: SimulatorAlgebra) -> Tuple[FrozenSet[int], float]:
        """Find the self-consistent law with minimal complexity."""
        fps = S.find_all_fixed_points()
        if not fps:
            raise ValueError("No fixed points found")
        best = min(fps, key=lambda L: self.measure(L))
        return best, self.measure(best)


def knaster_tarski_lfp_real(
    phi: Callable[[float], float],
    lower: float = 0.0,
    upper: float = 1.0,
    tol: float = 1e-12,
    max_iter: int = 1000
) -> float:
    """
    Compute the least fixed point of a monotone function φ: [lower, upper] → [lower, upper]
    by iteration from the bottom element.
    
    Returns the approximate LFP.
    """
    x = lower
    for _ in range(max_iter):
        x_new = phi(x)
        x_new = max(lower, min(upper, x_new))
        if abs(x_new - x) < tol:
            return x_new
        x = x_new
    return x


def knaster_tarski_gfp_real(
    phi: Callable[[float], float],
    lower: float = 0.0,
    upper: float = 1.0,
    tol: float = 1e-12,
    max_iter: int = 1000
) -> float:
    """
    Compute the greatest fixed point by iteration from top.
    """
    x = upper
    for _ in range(max_iter):
        x_new = phi(x)
        x_new = max(lower, min(upper, x_new))
        if abs(x_new - x) < tol:
            return x_new
        x = x_new
    return x


# ─── Example Constructions ───

def make_union_sim(universe: FrozenSet[int]) -> SimulatorAlgebra:
    """Create a simulator where sim(A,B) = A ∪ B ∪ {next element}."""
    elems = sorted(universe)
    
    def sim(A: FrozenSet[int], B: FrozenSet[int]) -> FrozenSet[int]:
        result = A | B
        if A & B:
            m = min(A & B)
            idx = elems.index(m)
            if idx + 1 < len(elems):
                result = result | frozenset({elems[idx + 1]})
        return result
    
    return SimulatorAlgebra(universe=universe, sim=sim)


def make_cardinality_complexity() -> ComplexityMeasure:
    """Complexity = number of elements (cardinality)."""
    return ComplexityMeasure(measure=lambda L: float(len(L)))


if __name__ == "__main__":
    # Demo
    U = frozenset({0, 1, 2, 3})
    S = make_union_sim(U)
    
    print("SimulatorAlgebra on P({0,1,2,3})")
    print(f"All fixed points: {[set(fp) for fp in S.find_all_fixed_points()]}")
    print(f"Minimal law: {set(S.minimal_law())}")
    print(f"Maximal law: {set(S.maximal_law())}")
    
    trajectory = S.iterate_from_bottom()
    print(f"Iteration from ⊥: {[set(t) for t in trajectory]}")
    
    C = make_cardinality_complexity()
    best, val = C.complexity_minimal_law(S)
    print(f"Complexity-minimal fixed point: {set(best)} (complexity={val})")
    
    # Real-valued example
    print("\nReal-valued self-simulation:")
    phi = lambda x: (x + 0.5) / 2  # Fixed point at 0.5
    lfp = knaster_tarski_lfp_real(phi)
    gfp = knaster_tarski_gfp_real(phi)
    print(f"  LFP of φ(x)=(x+0.5)/2: {lfp:.6f}")
    print(f"  GFP of φ(x)=(x+0.5)/2: {gfp:.6f}")
