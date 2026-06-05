#!/usr/bin/env python3
"""
Algorithms for Game of Life Simulation Algebra

Type-hinted implementations of the core mathematical structures
from the formalization.
"""

from typing import TypeVar, Generic, Callable, Optional, Set, Tuple, List, Dict
from dataclasses import dataclass
from abc import ABC, abstractmethod


# ============================================================
# Simulation System
# ============================================================

S = TypeVar('S')


@dataclass
class SimSystem(Generic[S]):
    """A discrete dynamical system: state type + step function."""
    step: Callable[[S], S]

    def iterate(self, n: int, state: S) -> S:
        """Apply step function n times."""
        result = state
        for _ in range(n):
            result = self.step(result)
        return result


@dataclass
class SimMorphism(Generic[S]):
    """A simulation morphism between two dynamical systems.

    Encodes the concept: system A can simulate system B with time factor k.
    The encode function maps B-states to A-states such that
    A^k(encode(s)) = encode(B.step(s)) for all s.
    """
    source: SimSystem  # System A (simulator)
    target: SimSystem  # System B (simulated)
    time_factor: int   # k
    encode: Callable   # B.State -> A.State

    def verify_commutation(self, test_state) -> bool:
        """Check commutation diagram on a test state."""
        # A^k(encode(s)) should equal encode(B.step(s))
        lhs = self.source.iterate(self.time_factor, self.encode(test_state))
        rhs = self.encode(self.target.step(test_state))
        return lhs == rhs


def compose_morphisms(f: SimMorphism, g: SimMorphism) -> SimMorphism:
    """Compose two simulation morphisms.

    If f: A simulates B with factor k1
    and g: B simulates C with factor k2
    then compose(f, g): A simulates C with factor k1 * k2
    """
    return SimMorphism(
        source=f.source,
        target=g.target,
        time_factor=f.time_factor * g.time_factor,
        encode=lambda s: f.encode(g.encode(s))
    )


def simulation_chain_overhead(factors: List[int]) -> int:
    """Compute total overhead of a simulation chain.

    Theorem (overhead_exponential): if all factors >= 2,
    then overhead >= 2^len(factors).
    """
    result = 1
    for k in factors:
        result *= k
    return result


# ============================================================
# Game of Life
# ============================================================

Cell = Tuple[int, int]
Grid = Set[Cell]

MOORE_OFFSETS: List[Cell] = [
    (-1, -1), (-1, 0), (-1, 1),
    (0, -1),           (0, 1),
    (1, -1),  (1, 0),  (1, 1),
]


def neighbor_count(grid: Grid, cell: Cell) -> int:
    """Count live Moore neighbors of a cell."""
    x, y = cell
    return sum(1 for dx, dy in MOORE_OFFSETS if (x + dx, y + dy) in grid)


def gol_step(grid: Grid) -> Grid:
    """Conway's Game of Life step function.

    Rules:
    - Live cell with 2 or 3 neighbors survives
    - Dead cell with exactly 3 neighbors is born
    - All other cells die or stay dead
    """
    # Count neighbors for all relevant cells
    counts: Dict[Cell, int] = {}
    for cell in grid:
        for dx, dy in MOORE_OFFSETS:
            nb = (cell[0] + dx, cell[1] + dy)
            counts[nb] = counts.get(nb, 0) + 1

    new_grid: Grid = set()
    for cell, count in counts.items():
        if cell in grid:
            if count in (2, 3):
                new_grid.add(cell)
        else:
            if count == 3:
                new_grid.add(cell)
    return new_grid


def gol_system() -> SimSystem[Grid]:
    """The Game of Life as a SimSystem."""
    return SimSystem(step=gol_step)


def is_still_life(grid: Grid) -> bool:
    """Check if a pattern is a still life (fixed point).

    Theorem (isStillLife_iff): g is a still life iff
    every live cell has 2 or 3 neighbors and
    no dead cell has exactly 3 neighbors.
    """
    return gol_step(grid) == grid


def is_oscillator(grid: Grid, period: int) -> bool:
    """Check if a pattern is an oscillator with given period."""
    if period <= 0:
        return False
    current = grid
    for _ in range(period):
        current = gol_step(current)
    return current == grid


def translate(grid: Grid, dx: int, dy: int) -> Grid:
    """Translate a grid by (dx, dy).

    Theorem (step_translate): step(translate(g, dx, dy)) = translate(step(g), dx, dy)
    """
    return {(x + dx, y + dy) for x, y in grid}


# ============================================================
# Tag Systems
# ============================================================

@dataclass
class TagSystem:
    """A tag system: string-rewriting computation model.

    At each step: read first symbol, append its production,
    delete first `deletion_num` symbols.
    """
    deletion_num: int
    productions: Dict[str, str]
    halting_symbols: Set[str]

    def step(self, config: str) -> Optional[str]:
        """One step. Returns None on halt or underflow."""
        if not config:
            return None
        first = config[0]
        if first in self.halting_symbols:
            return None
        production = self.productions.get(first, "")
        appended = config + production
        if len(appended) <= self.deletion_num:
            return None
        return appended[self.deletion_num:]

    def run(self, config: str, max_steps: int = 10000) -> Tuple[str, int, bool]:
        """Run until halt or max_steps. Returns (final_config, steps, halted)."""
        for i in range(max_steps):
            result = self.step(config)
            if result is None:
                return config, i, True
            config = result
        return config, max_steps, False


# ============================================================
# Known Patterns
# ============================================================

BLOCK: Grid = {(0, 0), (0, 1), (1, 0), (1, 1)}
BLINKER: Grid = {(0, -1), (0, 0), (0, 1)}
GLIDER: Grid = {(0, 0), (1, 0), (2, 0), (2, 1), (1, 2)}
BEEHIVE: Grid = {(0, 0), (0, 1), (1, -1), (1, 2), (2, 0), (2, 1)}


if __name__ == "__main__":
    # Verify key theorems computationally
    print("Verifying formalized theorems computationally...\n")

    # Theorem: block is a still life
    assert is_still_life(BLOCK), "Block should be a still life"
    print("✓ block_isStillLife: Block is a still life")

    # Theorem: singleton dies
    singleton = {(5, 5)}
    assert len(gol_step(singleton)) == 0, "Singleton should die"
    print("✓ singleton_dies: Isolated cell dies")

    # Theorem: blinker is period-2 oscillator
    assert is_oscillator(BLINKER, 2), "Blinker should be period 2"
    print("✓ Blinker is a period-2 oscillator")

    # Theorem: translation invariance
    for pattern in [BLOCK, BLINKER, GLIDER]:
        for dx, dy in [(1, 0), (0, 1), (-3, 7)]:
            lhs = gol_step(translate(pattern, dx, dy))
            rhs = translate(gol_step(pattern), dx, dy)
            assert lhs == rhs, f"Translation invariance failed for dx={dx}, dy={dy}"
    print("✓ step_translate: GoL commutes with translation")

    # Theorem: overhead is multiplicative
    chain = [3, 5, 7]
    assert simulation_chain_overhead(chain) == 105
    assert simulation_chain_overhead(chain) >= 2 ** len(chain)
    print("✓ overhead_exponential: Chain overhead ≥ 2^n")

    # Theorem: underpopulation
    for pattern in [BLOCK, BLINKER]:
        for cell in pattern:
            nc = neighbor_count(pattern, cell)
            result = cell in gol_step(pattern)
            if nc <= 1:
                assert not result, f"Cell {cell} with {nc} neighbors should die"
    print("✓ underpopulation_extinction: Cells with ≤1 neighbor die")

    print("\nAll computational verifications passed!")
