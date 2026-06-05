#!/usr/bin/env python3
"""
Game of Life Universality — Core Algorithms

Type-hinted implementations of the key algorithms from the formalization:
1. Cellular automaton simulation
2. Simulation chain composition
3. Overhead bound computation
4. GoL pattern analysis
"""

from typing import Set, Tuple, Dict, List, Callable, Optional, TypeVar
from dataclasses import dataclass


# ============================================================
# Type Aliases
# ============================================================

Cell = Tuple[int, int]
Config = Set[Cell]
TransitionFn = Callable[[Config], Config]

T = TypeVar('T')


# ============================================================
# Algorithm 1: Generic Cellular Automaton
# ============================================================

@dataclass
class CellularAutomaton:
    """Abstract cellular automaton with a step function."""
    name: str
    step: TransitionFn
    
    def orbit(self, config: Config, t: int) -> Config:
        """Compute the orbit (t-step iteration) of a configuration.
        
        Corresponds to CellularAutomaton.orbit in the Lean formalization.
        """
        current = config
        for _ in range(t):
            current = self.step(current)
        return current


# ============================================================
# Algorithm 2: Game of Life Step
# ============================================================

def moore_neighbors(cell: Cell) -> List[Cell]:
    """The 8 Moore neighbors of a cell.
    
    Corresponds to mooreNeighbors in the Lean formalization.
    """
    x, y = cell
    return [
        (x-1, y-1), (x-1, y), (x-1, y+1),
        (x, y-1),             (x, y+1),
        (x+1, y-1), (x+1, y), (x+1, y+1)
    ]


def alive_count(config: Config, cell: Cell) -> int:
    """Count alive neighbors. Corresponds to aliveCount in Lean."""
    return sum(1 for nb in moore_neighbors(cell) if nb in config)


def gol_transition(config: Config, cell: Cell) -> bool:
    """GoL transition rule for a single cell.
    
    Corresponds to golTransition in the Lean formalization.
    - Live cell with 2 or 3 neighbors survives
    - Dead cell with exactly 3 neighbors becomes alive
    """
    n = alive_count(config, cell)
    if cell in config:
        return n in (2, 3)
    else:
        return n == 3


def gol_step(config: Config) -> Config:
    """Global GoL step function. Corresponds to golStep in Lean."""
    candidates: Set[Cell] = set()
    for cell in config:
        candidates.add(cell)
        for nb in moore_neighbors(cell):
            candidates.add(nb)
    
    return {cell for cell in candidates if gol_transition(config, cell)}


# ============================================================
# Algorithm 3: Simulation Chain Composition
# ============================================================

@dataclass
class CASimulation:
    """A simulation of one CA by another.
    
    Corresponds to CASimulation in the Lean formalization.
    The key property is the commuting diagram:
        ca1.orbit(encode(c), time_factor) = encode(ca2.step(c))
    """
    time_factor: int
    encode: Callable[[Config], Config]
    source_name: str
    target_name: str


def compose_simulations(sim1: CASimulation, sim2: CASimulation) -> CASimulation:
    """Compose two simulations. Corresponds to CASimulation.trans in Lean.
    
    If CA₁ simulates CA₂ with factor τ₁, and CA₂ simulates CA₃ with factor τ₂,
    then CA₁ simulates CA₃ with factor τ₁ × τ₂.
    
    This is the key theorem: simulation overhead composes multiplicatively.
    """
    return CASimulation(
        time_factor=sim1.time_factor * sim2.time_factor,
        encode=lambda c: sim1.encode(sim2.encode(c)),
        source_name=sim1.source_name,
        target_name=sim2.target_name
    )


def simulation_chain_overhead(factors: List[int]) -> int:
    """Total overhead of a simulation chain.
    
    Corresponds to overhead_polynomial_chain in Lean:
    total = ∏ τᵢ ≤ f^k where f = max(τᵢ) and k = len(factors)
    """
    total = 1
    for f in factors:
        total *= f
    return total


def overhead_bound(factors: List[int]) -> int:
    """Upper bound on overhead: max(factors)^len(factors)."""
    if not factors:
        return 1
    return max(factors) ** len(factors)


# ============================================================
# Algorithm 4: GoL Pattern Analysis
# ============================================================

def is_still_life(config: Config) -> bool:
    """Check if a configuration is a still life (fixed point).
    
    Corresponds to IsStillLife in the Lean formalization.
    """
    return gol_step(config) == config


def find_period(config: Config, max_period: int = 1000) -> Optional[int]:
    """Find the period of an oscillator (or None if aperiodic within limit).
    
    Corresponds to IsOscillator in the Lean formalization.
    """
    current = config
    for t in range(1, max_period + 1):
        current = gol_step(current)
        if current == config:
            return t
    return None


def translate_config(config: Config, v: Cell) -> Config:
    """Translate a configuration by vector v.
    
    Corresponds to translateConfig in the Lean formalization.
    """
    return {(x + v[0], y + v[1]) for (x, y) in config}


def reflect_x(config: Config) -> Config:
    """Reflect across x-axis. Corresponds to reflectX in Lean."""
    return {(x, -y) for (x, y) in config}


def bounding_box(config: Config) -> Tuple[int, int, int, int]:
    """Compute the bounding box of a configuration."""
    if not config:
        return (0, 0, 0, 0)
    xs = [p[0] for p in config]
    ys = [p[1] for p in config]
    return (min(xs), max(xs), min(ys), max(ys))


def population_growth_rate(config: Config, steps: int) -> List[int]:
    """Track population over time. Related to gol_quadratic_population_principle."""
    populations = [len(config)]
    current = config
    for _ in range(steps):
        current = gol_step(current)
        populations.append(len(current))
    return populations


# ============================================================
# Algorithm 5: TM Simulation Overhead Calculator
# ============================================================

def tm_simulation_overhead(states: int, symbols: int) -> Dict[str, int]:
    """Compute overhead bounds for simulating a TM in GoL.
    
    Corresponds to gol_simulation_overhead in the Lean formalization.
    
    Returns time overhead T ≤ k²m² and space overhead S ≤ km.
    """
    return {
        "time_overhead_bound": states ** 2 * symbols ** 2,
        "space_overhead_bound": states * symbols,
        "states": states,
        "symbols": symbols
    }


if __name__ == "__main__":
    # Quick self-test
    gol = CellularAutomaton("GoL", gol_step)
    
    # Test glider
    glider: Config = {(0, 0), (1, 0), (2, 0), (2, 1), (1, 2)}
    g4 = gol.orbit(glider, 4)
    g4_expected = translate_config(glider, (1, -1))
    assert g4 == g4_expected, f"Glider test failed: {g4} != {g4_expected}"
    
    # Test still life
    block: Config = {(0, 0), (1, 0), (0, 1), (1, 1)}
    assert is_still_life(block), "Block should be a still life"
    
    # Test simulation chain
    factors = [120, 8, 4, 2]
    total = simulation_chain_overhead(factors)
    bound = overhead_bound(factors)
    assert total <= bound, f"Overhead bound violated: {total} > {bound}"
    
    print("All self-tests passed ✓")
