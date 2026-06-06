#!/usr/bin/env python3
"""
Algorithms for Infinite Games Against Death

Type-hinted implementations of the key algorithms from the
Mortal-Eternity game framework.
"""

from typing import List, Tuple, Optional, Callable, Iterator
from dataclasses import dataclass
from enum import Enum


class GameOutcome(Enum):
    """Outcome of a single round."""
    SURVIVED = "survived"
    CAUGHT = "caught"


@dataclass
class GameState:
    """State of a layered survival game."""
    counters: List[int]  # Stack of counters (depth = len(counters))
    total_rounds: int = 0
    
    @property
    def depth(self) -> int:
        return len(self.counters)
    
    @property  
    def is_alive(self) -> bool:
        return any(c > 0 for c in self.counters)


def cyclic_shift(position: int, board_size: int) -> int:
    """
    Mortal's reactive evasion strategy.
    
    The cyclic shift i ↦ (i+1) mod n is fixed-point-free for n ≥ 2,
    guaranteeing survival at every reactive round.
    
    Args:
        position: Eternity's search position (0 ≤ position < board_size)
        board_size: Number of positions on the board (n ≥ 2)
    
    Returns:
        Mortal's hiding position, guaranteed ≠ position
    
    Complexity: O(1) time, O(1) space
    """
    assert board_size >= 2, "Need at least 2 positions for evasion"
    return (position + 1) % board_size


def reactive_evasion_game(
    board_size: int,
    eternity_strategy: Callable[[int], int],
    max_rounds: int = 1000
) -> Iterator[Tuple[int, int, int, GameOutcome]]:
    """
    Simulate a reactive evasion game.
    
    Yields (round, search, hide, outcome) tuples.
    Game runs until max_rounds or until Mortal is caught (never with cyclic shift).
    
    Args:
        board_size: Number of positions (n ≥ 2)
        eternity_strategy: Maps round number to search position
        max_rounds: Maximum rounds to simulate
    
    Yields:
        (round_number, search_position, hide_position, outcome)
    """
    for t in range(max_rounds):
        search = eternity_strategy(t) % board_size
        hide = cyclic_shift(search, board_size)
        outcome = GameOutcome.SURVIVED if hide != search else GameOutcome.CAUGHT
        yield (t, search, hide, outcome)
        if outcome == GameOutcome.CAUGHT:
            return


def hierarchical_survival(
    depth: int,
    reset_values: Callable[[int], int],
    board_size: int = 2
) -> int:
    """
    Compute total survival time for a hierarchical game.
    
    A depth-d game has d levels of counters. Each level provides
    ω additional ordinal value. Total game value: ω^d.
    
    Args:
        depth: Nesting depth (d ≥ 0)
        reset_values: Function mapping level to reset value
        board_size: Board size for base-level evasion
    
    Returns:
        Total number of rounds survived
    
    Complexity: O(Π reset_values(i)) time, O(depth) space
    """
    if depth == 0:
        return reset_values(0)
    
    total = 0
    outer_count = reset_values(depth)
    for _ in range(outer_count):
        # Each outer iteration runs a (depth-1)-level game
        total += hierarchical_survival(depth - 1, reset_values, board_size)
    return total


def compute_layered_survival(tracks: List[int]) -> int:
    """
    Compute total survival for k parallel tracks.
    
    Each track contributes its duration to total survival.
    With k tracks of ω-games, ordinal value is ω·k.
    
    Args:
        tracks: List of track durations [d₁, d₂, ..., dₖ]
    
    Returns:
        Total survival time = Σ dᵢ
    """
    return sum(tracks)


def compute_nested_survival(
    durations: List[List[int]]
) -> int:
    """
    Compute total survival for doubly-nested games.
    
    durations[i][j] = duration of sub-round j in macro-round i.
    Ordinal value: ω² (since both levels are unbounded).
    
    Args:
        durations: Nested list of durations
    
    Returns:
        Total survival time = Σᵢ Σⱼ durations[i][j]
    """
    return sum(sum(inner) for inner in durations)


def exceed_bound_layered(bound: int, k: int) -> List[int]:
    """
    Find reset values for k tracks that exceed a given bound.
    
    This witnesses the ω·k game value: for any bound,
    we can find durations making total survival ≥ bound.
    
    Args:
        bound: Target survival lower bound
        k: Number of tracks (≥ 1)
    
    Returns:
        List of k track durations whose sum ≥ bound
    """
    assert k >= 1
    per_track = (bound + k - 1) // k  # Ceiling division
    return [per_track] * k


def exceed_bound_nested(bound: int) -> List[List[int]]:
    """
    Find nested reset values that exceed a given bound.
    
    This witnesses the ω² game value: for any bound,
    we can find a doubly-nested configuration with total ≥ bound.
    
    Args:
        bound: Target survival lower bound
    
    Returns:
        Nested list of durations whose double sum ≥ bound
    """
    # Use bound macro-rounds of 1 sub-round each
    return [[1] for _ in range(bound)]


@dataclass
class OrdinalGameValue:
    """Representation of ordinal game values up to ω^ω."""
    coefficients: List[int]  # coefficients[d] = coefficient of ω^d
    
    def __str__(self) -> str:
        if not self.coefficients or all(c == 0 for c in self.coefficients):
            return "0"
        terms = []
        for d in range(len(self.coefficients) - 1, -1, -1):
            c = self.coefficients[d]
            if c == 0:
                continue
            if d == 0:
                terms.append(str(c))
            elif d == 1:
                terms.append(f"ω·{c}" if c > 1 else "ω")
            else:
                terms.append(f"ω^{d}·{c}" if c > 1 else f"ω^{d}")
        return " + ".join(terms) if terms else "0"
    
    @staticmethod
    def from_depth(depth: int) -> 'OrdinalGameValue':
        """Game value for a depth-d nested game: ω^d."""
        coeffs = [0] * (depth + 1)
        coeffs[depth] = 1
        return OrdinalGameValue(coefficients=coeffs)
    
    def exceeds_finite(self) -> bool:
        """Whether this ordinal is ≥ ω (transfinite)."""
        return any(c > 0 for c in self.coefficients[1:])


def mortal_strategy_memory(depth: int) -> str:
    """
    Describe Mortal's memory requirements for depth-d survival.
    
    A depth-d strategy needs d natural-number counters.
    Memory per play = d · ⌈log₂(max_counter)⌉ bits,
    but max_counter is chosen at runtime (unbounded).
    
    Args:
        depth: Game nesting depth
    
    Returns:
        Human-readable description of memory requirements
    """
    if depth == 0:
        return "No state needed (memoryless reactive strategy)"
    return (f"{depth} natural-number counter{'s' if depth > 1 else ''} "
            f"({depth} words of memory, "
            f"game value = {OrdinalGameValue.from_depth(depth)})")


def demonstrate_ordinal_arithmetic():
    """Show the correspondence between game operations and ordinal arithmetic."""
    print("Game Operation → Ordinal Operation")
    print("-" * 50)
    
    # Sequential composition = ordinal addition
    g1 = OrdinalGameValue([3])  # 3 rounds
    g2 = OrdinalGameValue([5])  # 5 rounds
    g_seq = OrdinalGameValue([8])  # 3 + 5 = 8
    print(f"Sequential({g1}, {g2}) = {g_seq}  (ordinal addition)")
    
    # Layered = ordinal multiplication
    g_layer = OrdinalGameValue([0, 3])  # ω·3
    print(f"Layered(3 tracks × ω) = {g_layer}  (ordinal multiplication)")
    
    # Nested = ordinal exponentiation
    g_nested = OrdinalGameValue([0, 0, 1])  # ω²
    print(f"Nested(2 levels) = {g_nested}  (ordinal exponentiation)")
    
    # Depth hierarchy
    for d in range(6):
        gv = OrdinalGameValue.from_depth(d)
        mem = mortal_strategy_memory(d)
        print(f"Depth {d}: value = {gv}, memory = {mem}")


if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHMS: Infinite Games Against Death")
    print("=" * 60)
    
    # Demo 1: Cyclic shift evasion
    print("\n--- Cyclic Shift Evasion ---")
    for n in [2, 3, 5, 10]:
        shifts = [(i, cyclic_shift(i, n)) for i in range(n)]
        fpf = all(s != i for i, s in shifts)
        print(f"n={n}: {shifts} (fixed-point-free: {fpf})")
    
    # Demo 2: Hierarchical survival
    print("\n--- Hierarchical Survival ---")
    for depth in [1, 2, 3]:
        total = hierarchical_survival(depth, lambda _: 3, board_size=2)
        print(f"Depth {depth}, reset=3: total = {total} rounds "
              f"(value = {OrdinalGameValue.from_depth(depth)})")
    
    # Demo 3: Exceeding bounds
    print("\n--- Exceeding Arbitrary Bounds ---")
    for bound in [100, 10000, 1000000]:
        tracks = exceed_bound_layered(bound, k=5)
        total = compute_layered_survival(tracks)
        print(f"Bound {bound}: tracks={tracks[:3]}..., total={total} ≥ {bound} ✓")
    
    # Demo 4: Ordinal arithmetic
    print("\n--- Ordinal Arithmetic Correspondence ---")
    demonstrate_ordinal_arithmetic()
