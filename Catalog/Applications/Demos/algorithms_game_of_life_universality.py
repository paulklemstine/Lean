"""
Algorithms for Game of Life Simulation and Analysis

Type-hinted implementations of the key algorithms underlying the
formal proofs in Theorems.lean.
"""

from typing import Set, Dict, Tuple, Optional, Callable
from dataclasses import dataclass


# ============================================================
# Core Game of Life
# ============================================================

Position = Tuple[int, int]
Config = Set[Position]


def moore_neighbors(p: Position) -> list[Position]:
    """The 8 Moore neighbors of position p."""
    x, y = p
    return [(x+dx, y+dy) for dx in [-1, 0, 1] for dy in [-1, 0, 1]
            if (dx, dy) != (0, 0)]


def alive_count(config: Config, p: Position) -> int:
    """Count alive neighbors of p in the configuration."""
    return sum(1 for n in moore_neighbors(p) if n in config)


def gol_rule(config: Config, p: Position) -> bool:
    """Conway's B3/S23 rule at position p. Returns True if alive."""
    n = alive_count(config, p)
    if p in config:
        return n in (2, 3)  # Survival
    else:
        return n == 3  # Birth


def gol_step(config: Config) -> Config:
    """One step of Conway's Game of Life."""
    candidates: Set[Position] = set()
    for p in config:
        candidates.add(p)
        candidates.update(moore_neighbors(p))
    return {p for p in candidates if gol_rule(config, p)}


def gol_iterate(config: Config, steps: int) -> Config:
    """Iterate GoL for the given number of steps."""
    for _ in range(steps):
        config = gol_step(config)
    return config


# ============================================================
# Chebyshev Distance and Light Cone
# ============================================================

def chebyshev_distance(p: Position, q: Position) -> int:
    """Chebyshev (L∞) distance between two positions."""
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


def light_cone(center: Position, radius: int) -> Set[Position]:
    """All positions within Chebyshev distance radius of center."""
    cx, cy = center
    return {(cx + dx, cy + dy)
            for dx in range(-radius, radius + 1)
            for dy in range(-radius, radius + 1)}


def verify_light_cone_theorem(
    config1: Config, config2: Config, p: Position, t: int
) -> bool:
    """Verify the light cone theorem for specific configurations.

    If config1 and config2 agree on light_cone(p, t+1),
    then they agree at p after t+1 steps.
    """
    # Check agreement on input cone
    cone = light_cone(p, t + 1)
    for q in cone:
        if (q in config1) != (q in config2):
            return True  # Hypothesis not satisfied, theorem holds vacuously

    # Check conclusion
    result1 = gol_iterate(config1, t + 1)
    result2 = gol_iterate(config2, t + 1)
    return (p in result1) == (p in result2)


# ============================================================
# Simulation Framework
# ============================================================

@dataclass
class TuringMachine:
    """A simple Turing machine with binary alphabet."""
    num_states: int
    transitions: Dict[Tuple[int, bool], Tuple[int, bool, bool]]
    initial_state: int
    halting_states: Set[int]


@dataclass
class TMConfig:
    """A Turing machine configuration."""
    state: int
    head_pos: int
    tape: Dict[int, bool]  # Sparse representation

    def read(self) -> bool:
        return self.tape.get(self.head_pos, False)


def tm_step(tm: TuringMachine, config: TMConfig) -> TMConfig:
    """One step of a Turing machine."""
    symbol = config.read()
    new_state, new_symbol, move_right = tm.transitions[(config.state, symbol)]
    new_tape = dict(config.tape)
    new_tape[config.head_pos] = new_symbol
    new_head = config.head_pos + (1 if move_right else -1)
    return TMConfig(new_state, new_head, new_tape)


def tm_run(tm: TuringMachine, config: TMConfig, steps: int) -> TMConfig:
    """Run a Turing machine for the given number of steps."""
    for _ in range(steps):
        if config.state in tm.halting_states:
            break
        config = tm_step(tm, config)
    return config


# ============================================================
# Simulation Overhead Analysis
# ============================================================

def simulation_space_bound(D: int, t: int) -> int:
    """Upper bound on space needed for GoL simulation.

    A simulation of a region of diameter D for t steps
    requires at most (D + 2t + 1)² cells.
    """
    return (D + 2 * t + 1) ** 2


def simulation_chain_overhead(factors: list[int]) -> int:
    """Total overhead of a chain of simulations.

    The overhead is the product of individual time dilation factors.
    """
    result = 1
    for f in factors:
        result *= f
    return result


# ============================================================
# Pattern Recognition
# ============================================================

def find_period(config: Config, max_period: int = 100) -> Optional[int]:
    """Find the period of a GoL pattern, or None if not periodic."""
    states = [config]
    current = config
    for t in range(1, max_period + 1):
        current = gol_step(current)
        if current == config:
            return t
        states.append(current)
    return None


def find_translation_period(
    config: Config, max_period: int = 100
) -> Optional[Tuple[int, Position]]:
    """Find the translation period and offset of a spaceship pattern."""
    current = config
    for t in range(1, max_period + 1):
        current = gol_step(current)
        if not current:
            continue
        # Check if current is a translation of config
        if len(current) != len(config):
            continue
        # Try all possible offsets
        p1 = min(config)
        p2 = min(current)
        dx, dy = p2[0] - p1[0], p2[1] - p1[1]
        translated = {(x + dx, y + dy) for x, y in config}
        if translated == current:
            return t, (dx, dy)
    return None


if __name__ == "__main__":
    # Verify the glider is a period-4 spaceship
    glider: Config = {(0, 1), (1, 2), (2, 0), (2, 1), (2, 2)}
    result = find_translation_period(glider)
    assert result is not None
    period, offset = result
    print(f"Glider: period={period}, offset={offset}")
    assert period == 4

    # Verify the blinker is period 2
    blinker: Config = {(0, 0), (1, 0), (2, 0)}
    p = find_period(blinker)
    print(f"Blinker: period={p}")
    assert p == 2

    # Verify light cone theorem
    config1: Config = {(0, 0), (0, 1), (1, 0)}
    config2: Config = {(0, 0), (0, 1), (1, 0), (10, 10)}
    assert verify_light_cone_theorem(config1, config2, (0, 0), 3)
    print("Light cone theorem verified for test case!")

    # Simulation overhead
    print(f"\nSimulation space bounds:")
    for D in [10, 50, 100]:
        for t in [100, 1000]:
            bound = simulation_space_bound(D, t)
            print(f"  D={D}, t={t}: space ≤ {bound:,}")
