#!/usr/bin/env python3
"""
Algorithms for Game of Life Simulation and Tropical Threshold Computation

Type-hinted implementations of the core algorithms from the formalized theory.
"""

from typing import List, Tuple, Set, Dict, Callable, Optional
import numpy as np


# ============================================================
# Tropical Threshold Gate
# ============================================================

def tropical_threshold(s: int, lo: int, hi: int) -> int:
    """
    Tropical threshold gate.

    Returns 1 if lo <= s <= hi, else 0.
    Implementation uses only min, max (for truncating subtraction), and multiplication.

    Time complexity: O(1)
    Space complexity: O(1)
    """
    left = min(1, max(0, s + 1 - lo))
    right = min(1, max(0, hi + 1 - s))
    return left * right


def tropical_and(x: int, y: int) -> int:
    """AND gate via tropical threshold: TT(x+y, 2, 2)."""
    return tropical_threshold(x + y, 2, 2)


def tropical_or(x: int, y: int) -> int:
    """OR gate via tropical threshold: TT(x+y, 1, 2)."""
    return tropical_threshold(x + y, 1, 2)


def tropical_not(x: int) -> int:
    """NOT gate via tropical threshold: TT(1-x, 1, 1)."""
    return tropical_threshold(1 - x, 1, 1)


def tropical_nand(x: int, y: int) -> int:
    """NAND gate via composition of tropical thresholds."""
    return tropical_threshold(1 - tropical_threshold(x + y, 2, 2), 1, 1)


def tropical_xor(x: int, y: int) -> int:
    """XOR gate via tropical threshold: TT(x+y, 1, 1)."""
    return tropical_threshold(x + y, 1, 1)


# ============================================================
# Boolean Function Synthesis via Tropical Thresholds
# ============================================================

def synthesize_boolean_function(
    truth_table: List[int]
) -> Callable[[int, int], int]:
    """
    Synthesize a tropical threshold implementation of any 2-input Boolean function.

    Args:
        truth_table: [f(0,0), f(0,1), f(1,0), f(1,1)] where each value is 0 or 1

    Returns:
        A function g(x, y) -> {0, 1} computing the same function using
        tropical threshold primitives.

    This implements the functional_completeness theorem constructively.
    """
    assert len(truth_table) == 4
    assert all(v in (0, 1) for v in truth_table)

    c00, c01, c10, c11 = truth_table

    def g(x: int, y: int) -> int:
        # Interpolation formula using tropical operations
        # Each term selects the correct truth table entry
        t00 = c00 * tropical_threshold(x, 0, 0) * tropical_threshold(y, 0, 0)
        t01 = c01 * tropical_threshold(x, 0, 0) * tropical_threshold(y, 1, 1)
        t10 = c10 * tropical_threshold(x, 1, 1) * tropical_threshold(y, 0, 0)
        t11 = c11 * tropical_threshold(x, 1, 1) * tropical_threshold(y, 1, 1)
        return min(1, t00 + t01 + t10 + t11)

    return g


# ============================================================
# Game of Life on ℤ × ℤ
# ============================================================

# Moore neighborhood offsets
MOORE_OFFSETS: List[Tuple[int, int]] = [
    (-1, -1), (-1, 0), (-1, 1),
    (0, -1),           (0, 1),
    (1, -1),  (1, 0),  (1, 1),
]


def neighbor_count(config: Set[Tuple[int, int]], p: Tuple[int, int]) -> int:
    """Count the live Moore neighbors of cell p."""
    count = 0
    for di, dj in MOORE_OFFSETS:
        if (p[0] + di, p[1] + dj) in config:
            count += 1
    return count


def gol_step_sparse(config: Set[Tuple[int, int]]) -> Set[Tuple[int, int]]:
    """
    One step of the Game of Life using sparse (set-based) representation.

    Time complexity: O(|support| * 8) = O(|support|)
    Space complexity: O(|support|)

    This is the efficient implementation for finitely-supported configurations.
    """
    # Collect all cells that need to be checked (alive cells + their neighbors)
    candidates: Set[Tuple[int, int]] = set()
    for p in config:
        candidates.add(p)
        for di, dj in MOORE_OFFSETS:
            candidates.add((p[0] + di, p[1] + dj))

    # Apply the local rule to each candidate
    new_config: Set[Tuple[int, int]] = set()
    for p in candidates:
        n = neighbor_count(config, p)
        alive = p in config
        if alive:
            if n in (2, 3):  # survival
                new_config.add(p)
        else:
            if n == 3:  # birth
                new_config.add(p)

    return new_config


def gol_step_tropical_sparse(config: Set[Tuple[int, int]]) -> Set[Tuple[int, int]]:
    """
    GoL step using tropical threshold gates (algebraically equivalent).

    This demonstrates the tropical decomposition theorem:
    the GoL local rule = alive * TT(n, 2, 3) + (1-alive) * TT(n, 3, 3)
    """
    candidates: Set[Tuple[int, int]] = set()
    for p in config:
        candidates.add(p)
        for di, dj in MOORE_OFFSETS:
            candidates.add((p[0] + di, p[1] + dj))

    new_config: Set[Tuple[int, int]] = set()
    for p in candidates:
        n = neighbor_count(config, p)
        alive = 1 if p in config else 0
        # Tropical threshold formulation
        value = alive * tropical_threshold(n, 2, 3) + (1 - alive) * tropical_threshold(n, 3, 3)
        if value == 1:
            new_config.add(p)

    return new_config


# ============================================================
# Pattern Analysis
# ============================================================

def classify_pattern(
    config: Set[Tuple[int, int]], max_period: int = 100
) -> Dict[str, object]:
    """
    Classify a GoL pattern as still life, oscillator, or spaceship.

    Returns a dict with:
    - 'type': 'still_life', 'oscillator', 'spaceship', or 'unknown'
    - 'period': the period (if oscillator or spaceship)
    - 'velocity': (dx, dy) (if spaceship)
    """
    if not config:
        return {'type': 'still_life', 'period': 1}

    original = frozenset(config)
    current = set(config)

    for t in range(1, max_period + 1):
        current = gol_step_sparse(current)
        current_frozen = frozenset(current)

        if current_frozen == original:
            if t == 1:
                return {'type': 'still_life', 'period': 1}
            else:
                return {'type': 'oscillator', 'period': t}

        # Check for spaceship (translation)
        if len(current) == len(config):
            # Find center of mass shift
            if current:
                ox = sum(p[0] for p in config) / len(config)
                oy = sum(p[1] for p in config) / len(config)
                cx = sum(p[0] for p in current) / len(current)
                cy = sum(p[1] for p in current) / len(current)
                dx, dy = round(cx - ox), round(cy - oy)
                if dx != 0 or dy != 0:
                    shifted = frozenset((p[0] - dx, p[1] - dy) for p in current)
                    if shifted == original:
                        return {'type': 'spaceship', 'period': t, 'velocity': (dx, dy)}

    return {'type': 'unknown', 'max_period_checked': max_period}


def chebyshev_distance(p: Tuple[int, int], q: Tuple[int, int]) -> int:
    """Chebyshev (L∞) distance between two grid points."""
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


def support_bounding_box(
    config: Set[Tuple[int, int]]
) -> Optional[Tuple[int, int, int, int]]:
    """Return (min_row, max_row, min_col, max_col) or None if empty."""
    if not config:
        return None
    rows = [p[0] for p in config]
    cols = [p[1] for p in config]
    return (min(rows), max(rows), min(cols), max(cols))


# ============================================================
# Simulation Overhead Computation
# ============================================================

def turing_simulation_overhead(
    tm_states: int, tm_symbols: int, tape_length: int
) -> Dict[str, int]:
    """
    Compute the overhead of simulating a Turing machine using a 2D CA.

    Returns bounds on:
    - cells_per_tape_cell: number of CA cells per TM tape cell
    - time_per_tm_step: CA steps per TM step
    - total_ca_cells: total CA cells needed
    """
    import math

    cells_per_tape_cell = math.ceil(math.log2(max(1, tm_states * tm_symbols)))
    time_per_tm_step = tape_length  # information must propagate across tape
    total_ca_cells = tape_length * cells_per_tape_cell

    return {
        'cells_per_tape_cell': cells_per_tape_cell,
        'time_per_tm_step': time_per_tm_step,
        'total_ca_cells': total_ca_cells,
        'config_space_size': tm_states * (tm_symbols ** tape_length) * (tape_length + 1),
    }


if __name__ == "__main__":
    # Test tropical gates
    print("Testing tropical gates...")
    for x in [0, 1]:
        for y in [0, 1]:
            assert tropical_and(x, y) == x * y
            assert tropical_or(x, y) == max(x, y)
            assert tropical_nand(x, y) == 1 - x * y
    for x in [0, 1]:
        assert tropical_not(x) == 1 - x
    print("  All gate tests passed ✓")

    # Test functional completeness
    print("Testing functional completeness...")
    for i in range(16):
        tt = [(i >> 3) & 1, (i >> 2) & 1, (i >> 1) & 1, i & 1]
        g = synthesize_boolean_function(tt)
        for x in [0, 1]:
            for y in [0, 1]:
                assert g(x, y) == tt[2*x + y], f"Failed for function {i}: g({x},{y}) = {g(x,y)}, expected {tt[2*x+y]}"
    print("  All 16 functions synthesized correctly ✓")

    # Test pattern classification
    print("Testing pattern classification...")
    block = {(0,0), (0,1), (1,0), (1,1)}
    result = classify_pattern(block)
    assert result['type'] == 'still_life', f"Block: {result}"
    print(f"  Block: {result}")

    blinker = {(0,0), (0,1), (0,2)}
    result = classify_pattern(blinker)
    assert result['type'] == 'oscillator' and result['period'] == 2
    print(f"  Blinker: {result}")

    glider = {(0,1), (1,2), (2,0), (2,1), (2,2)}
    result = classify_pattern(glider)
    print(f"  Glider: {result}")

    # Test simulation overhead
    print("\nSimulation overhead for TM(5 states, 2 symbols, tape 100):")
    overhead = turing_simulation_overhead(5, 2, 100)
    for k, v in overhead.items():
        print(f"  {k}: {v}")

    print("\nAll tests passed ✓")
