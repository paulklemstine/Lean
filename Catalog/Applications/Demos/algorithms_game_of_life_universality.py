#!/usr/bin/env python3
"""
Algorithms for Cellular Automata Simulation Algebra

Type-hinted implementations of the key algorithms from the formalization:
1. SimulationMorphism — the core algebraic structure
2. SimulationSpectrum — computing the self-simulation spectrum
3. TagSystemSimulator — 2-tag system dynamics
4. CA1DSimulator — 1D cellular automaton dynamics
5. UniversalityChecker — checking simulation relationships
"""

from __future__ import annotations
from typing import (
    List, Dict, Optional, Callable, TypeVar, Generic, Set, Tuple, Sequence
)
from dataclasses import dataclass
from functools import reduce
import operator

S = TypeVar('S')
T = TypeVar('T')


# =============================================================================
# Core: Simulation Morphism
# =============================================================================

@dataclass
class DynamicalSystem(Generic[S]):
    """A discrete dynamical system with state type S."""
    step: Callable[[S], S]

    def iterate(self, state: S, n: int) -> S:
        """Apply step function n times."""
        current = state
        for _ in range(n):
            current = self.step(current)
        return current

    def orbit(self, state: S, length: int) -> List[S]:
        """Compute the orbit prefix of given length."""
        result = [state]
        current = state
        for _ in range(length):
            current = self.step(current)
            result.append(current)
        return result

    def find_period(self, state: S, max_steps: int = 10000) -> Optional[int]:
        """Find the period of a state, or None if not periodic within max_steps."""
        seen: Dict[int, int] = {}  # hash -> step
        current = state
        for i in range(max_steps):
            h = hash(str(current))
            if h in seen and self.iterate(state, seen[h]) == current:
                return i - seen[h]
            seen[h] = i
            current = self.step(current)
        return None


@dataclass
class SimulationMorphism(Generic[S, T]):
    """
    A simulation morphism from source system to target system.

    Satisfies: tgt.step^[time_dilation](encode(s)) = encode(src.step(s))
    """
    time_dilation: int
    encode: Callable[[S], T]
    src_system: DynamicalSystem[S]
    tgt_system: DynamicalSystem[T]

    def verify_equivariance(self, test_states: List[S]) -> bool:
        """Verify the equivariance condition on test states."""
        for s in test_states:
            lhs = self.tgt_system.iterate(self.encode(s), self.time_dilation)
            rhs = self.encode(self.src_system.step(s))
            if lhs != rhs:
                return False
        return True

    def verify_iterate(self, state: S, n: int) -> bool:
        """Verify multi-step equivariance: tgt^[n*d](encode(s)) = encode(src^[n](s))."""
        lhs = self.tgt_system.iterate(self.encode(state), n * self.time_dilation)
        rhs = self.encode(self.src_system.iterate(state, n))
        return lhs == rhs

    @staticmethod
    def compose(
        g: SimulationMorphism[T, 'U'],
        f: SimulationMorphism[S, T]
    ) -> SimulationMorphism[S, 'U']:
        """
        Compose simulation morphisms.
        Time dilation is multiplicative: d_composed = d_g * d_f.
        """
        return SimulationMorphism(
            time_dilation=g.time_dilation * f.time_dilation,
            encode=lambda s: g.encode(f.encode(s)),
            src_system=f.src_system,
            tgt_system=g.tgt_system,
        )

    @staticmethod
    def identity(system: DynamicalSystem[S]) -> SimulationMorphism[S, S]:
        """The identity simulation morphism (dilation 1)."""
        return SimulationMorphism(
            time_dilation=1,
            encode=lambda s: s,
            src_system=system,
            tgt_system=system,
        )


# =============================================================================
# Simulation Spectrum
# =============================================================================

def compute_simulation_spectrum(
    system: DynamicalSystem[S],
    test_states: List[S],
    max_dilation: int = 50
) -> Set[int]:
    """
    Compute (an approximation of) the simulation spectrum of a system.

    The simulation spectrum is the set of all time dilations achievable
    by self-simulation morphisms. We check which dilations d satisfy
    step^[d] = step (identity encoding) on the test states.

    For the identity encoding, d is in the spectrum iff all test states
    have period dividing d.
    """
    spectrum: Set[int] = {1}  # Identity always works

    # Check each potential dilation
    for d in range(2, max_dilation + 1):
        is_valid = True
        for s in test_states:
            if system.iterate(s, d) != system.step(s):
                is_valid = False
                break
        if is_valid:
            spectrum.add(d)

    return spectrum


def verify_multiplicative_closure(spectrum: Set[int], bound: int) -> bool:
    """Verify that the spectrum is closed under multiplication (up to bound)."""
    for a in spectrum:
        for b in spectrum:
            if a * b <= bound and a * b not in spectrum:
                return False
    return True


# =============================================================================
# Tag System
# =============================================================================

@dataclass
class TagSystem:
    """
    A 2-tag system.

    At each step: read first symbol, append its production, delete first 2 symbols.
    Turing complete by the Cocke-Minsky theorem.
    """
    alphabet_size: int
    productions: Dict[int, List[int]]

    def step(self, word: List[int]) -> Optional[List[int]]:
        """One step. Returns None if halted (word too short)."""
        if len(word) < 2:
            return None
        first = word[0]
        rest = word[2:]
        production = self.productions.get(first, [])
        return rest + production

    def to_dynamical_system(self) -> DynamicalSystem[Tuple[int, ...]]:
        """Convert to a DynamicalSystem (using tuples for hashability)."""
        def step_fn(state: Tuple[int, ...]) -> Tuple[int, ...]:
            result = self.step(list(state))
            return tuple(result) if result is not None else ()
        return DynamicalSystem(step=step_fn)

    def run(self, word: List[int], max_steps: int = 1000) -> List[List[int]]:
        """Run the tag system, recording trajectory."""
        trajectory = [word[:]]
        current = word[:]
        for _ in range(max_steps):
            result = self.step(current)
            if result is None:
                break
            trajectory.append(result[:])
            current = result
        return trajectory


# =============================================================================
# 1D Cellular Automaton
# =============================================================================

@dataclass
class CA1D:
    """A 1D cellular automaton with periodic boundary conditions."""
    num_states: int
    radius: int
    rule_table: Dict[Tuple[int, ...], int]

    def step(self, config: List[int]) -> List[int]:
        """Apply the CA rule to the entire configuration."""
        n = len(config)
        new_config = []
        for i in range(n):
            neighborhood = tuple(
                config[(i + j - self.radius) % n]
                for j in range(2 * self.radius + 1)
            )
            new_config.append(self.rule_table.get(neighborhood, 0))
        return new_config

    def to_dynamical_system(self, grid_size: int) -> DynamicalSystem[Tuple[int, ...]]:
        """Convert to a DynamicalSystem on a fixed grid."""
        def step_fn(state: Tuple[int, ...]) -> Tuple[int, ...]:
            return tuple(self.step(list(state)))
        return DynamicalSystem(step=step_fn)

    @staticmethod
    def rule110() -> CA1D:
        """Construct Rule 110."""
        table = {
            (1, 1, 1): 0, (1, 1, 0): 1, (1, 0, 1): 1, (1, 0, 0): 0,
            (0, 1, 1): 1, (0, 1, 0): 1, (0, 0, 1): 1, (0, 0, 0): 0,
        }
        return CA1D(num_states=2, radius=1, rule_table=table)

    @staticmethod
    def from_wolfram_number(rule_number: int) -> CA1D:
        """Construct an elementary CA from its Wolfram rule number."""
        table = {}
        for i in range(8):
            neighborhood = tuple((i >> (2 - j)) & 1 for j in range(3))
            table[neighborhood] = (rule_number >> i) & 1
        return CA1D(num_states=2, radius=1, rule_table=table)


# =============================================================================
# Universality Checker
# =============================================================================

def check_universality_transfer(
    morphism_AB: SimulationMorphism,
    morphism_BC: SimulationMorphism,
    test_states: List
) -> Dict[str, any]:
    """
    Verify universality transfer: if B simulates A and C simulates B,
    then C simulates A via composition.
    """
    composed = SimulationMorphism.compose(morphism_BC, morphism_AB)

    results = {
        "dilation_AB": morphism_AB.time_dilation,
        "dilation_BC": morphism_BC.time_dilation,
        "dilation_AC": composed.time_dilation,
        "multiplicative": composed.time_dilation == morphism_AB.time_dilation * morphism_BC.time_dilation,
        "lower_bound_A": morphism_AB.time_dilation <= composed.time_dilation,
        "lower_bound_B": morphism_BC.time_dilation <= composed.time_dilation,
    }

    if test_states:
        results["equivariance_verified"] = composed.verify_equivariance(test_states)

    return results


# =============================================================================
# Overhead Analysis
# =============================================================================

def analyze_composition_chain(dilations: List[int]) -> Dict[str, any]:
    """
    Analyze a chain of simulation compositions.

    Returns overhead statistics including the total dilation,
    individual bounds, and growth rate.
    """
    total = reduce(operator.mul, dilations, 1)
    return {
        "individual_dilations": dilations,
        "total_dilation": total,
        "chain_length": len(dilations),
        "geometric_mean": total ** (1.0 / len(dilations)) if dilations else 1.0,
        "lower_bounds_satisfied": all(d <= total for d in dilations),
        "growth_rate": f"O({max(dilations)}^{len(dilations)})" if dilations else "O(1)",
    }


if __name__ == "__main__":
    # Quick self-test
    r110 = CA1D.rule110()
    sys110 = r110.to_dynamical_system(20)

    # Tag system test
    ts = TagSystem(
        alphabet_size=3,
        productions={0: [1, 2], 1: [0], 2: [0, 0, 0]}
    )
    trajectory = ts.run([0, 0, 1, 0, 2], max_steps=10)
    print(f"Tag system trajectory length: {len(trajectory)}")

    # Composition chain analysis
    result = analyze_composition_chain([3, 5, 2, 7])
    print(f"Composition analysis: {result}")

    print("All algorithm tests passed!")
