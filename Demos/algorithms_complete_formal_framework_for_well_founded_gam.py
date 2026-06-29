#!/usr/bin/env python3
"""
Algorithms for Transfinite Game Values

Type-hinted implementations of the key algorithms from the formalization.
These operate on finite games (where ordinals reduce to natural numbers).
"""

from typing import Dict, FrozenSet, List, Optional, Set, Tuple
from dataclasses import dataclass, field
from enum import Enum


@dataclass(frozen=True)
class GamePosition:
    """A position in a well-founded game."""
    id: int
    label: str = ""


@dataclass
class WFGame:
    """
    A well-founded combinatorial game.
    
    Represents the WFGame structure from Lean:
    - positions: set of game positions
    - moves: dict mapping parent position to set of child positions
      (moves[p] contains q iff there is a move from p to q)
    """
    positions: Set[GamePosition]
    moves: Dict[GamePosition, Set[GamePosition]]
    
    def successors(self, pos: GamePosition) -> Set[GamePosition]:
        """Get all positions reachable from pos in one move."""
        return self.moves.get(pos, set())
    
    def is_terminal(self, pos: GamePosition) -> bool:
        """Check if pos has no available moves."""
        return len(self.successors(pos)) == 0
    
    def is_forced(self, pos: GamePosition) -> bool:
        """Check if pos has at most one available move (isForced)."""
        return len(self.successors(pos)) <= 1
    
    def is_strategically_trivial(self) -> bool:
        """Check if every position is forced (isStrategicallyTrivial)."""
        return all(self.is_forced(p) for p in self.positions)


def compute_game_values(game: WFGame) -> Dict[GamePosition, int]:
    """
    Compute game values for all positions in a finite well-founded game.
    
    Uses topological sort / memoized recursion.
    For finite games, game values are natural numbers.
    
    gameValue(p) = 0                         if p is terminal
    gameValue(p) = max(gameValue(q) for q in moves(p)) + 1  otherwise
    
    This implements the lsub formulation from the Lean definition.
    """
    values: Dict[GamePosition, int] = {}
    computing: Set[GamePosition] = set()  # cycle detection
    
    def compute(pos: GamePosition) -> int:
        if pos in values:
            return values[pos]
        if pos in computing:
            raise ValueError(f"Cycle detected at {pos} — game is not well-founded!")
        computing.add(pos)
        
        succs = game.successors(pos)
        if not succs:
            values[pos] = 0
        else:
            max_succ = max(compute(q) for q in succs)
            values[pos] = max_succ + 1
        
        computing.discard(pos)
        return values[pos]
    
    for pos in game.positions:
        compute(pos)
    return values


def compute_depth_spectrum(game: WFGame, pos: GamePosition,
                           values: Dict[GamePosition, int]) -> Set[int]:
    """
    Compute the depth spectrum of a position.
    
    depthSpectrum(p) = {gameValue(q) | q is reachable from p via 1+ moves}
    
    Corresponds to the depthSpectrum definition from Lean.
    """
    spectrum: Set[int] = set()
    visited: Set[GamePosition] = set()
    
    def explore(p: GamePosition, depth: int) -> None:
        if p in visited:
            return
        visited.add(p)
        for q in game.successors(p):
            spectrum.add(values[q])
            explore(q, depth + 1)
    
    # Start from successors of pos (TransGen requires at least one step)
    for q in game.successors(pos):
        spectrum.add(values[q])
        explore(q, 1)
    
    return spectrum


def verify_spectrum_bounded(game: WFGame, pos: GamePosition,
                            values: Dict[GamePosition, int],
                            spectrum: Set[int]) -> bool:
    """
    Verify the spectrum boundedness theorem:
    all elements of depthSpectrum(p) are < gameValue(p).
    """
    return all(v < values[pos] for v in spectrum)


@dataclass
class GameEmbedding:
    """
    A game embedding from game1 into game2.
    
    Corresponds to GameEmbedding from Lean:
    - to_fun maps positions of game1 to positions of game2
    - preserves moves: if moves₁(q, p) then moves₂(f(q), f(p))
    - reflects moves: if moves₂(r, f(p)) then ∃q, moves₁(q, p) ∧ f(q) = r
    """
    game1: WFGame
    game2: WFGame
    mapping: Dict[GamePosition, GamePosition]
    
    def verify_preservation(self) -> bool:
        """Verify that the embedding preserves moves."""
        for p, succs in self.game1.moves.items():
            fp = self.mapping[p]
            for q in succs:
                fq = self.mapping[q]
                if fq not in self.game2.successors(fp):
                    return False
        return True
    
    def verify_reflection(self) -> bool:
        """Verify that the embedding reflects moves."""
        inverse = {v: k for k, v in self.mapping.items()}
        for p in self.game1.positions:
            fp = self.mapping[p]
            for r in self.game2.successors(fp):
                if r not in inverse:
                    return False
                q = inverse[r]
                if q not in self.game1.successors(p):
                    return False
        return True
    
    def verify_value_preservation(self) -> bool:
        """
        Verify the embedding preservation theorem:
        gameValue₁(p) = gameValue₂(f(p)) for all p.
        """
        v1 = compute_game_values(self.game1)
        v2 = compute_game_values(self.game2)
        return all(v1[p] == v2[self.mapping[p]] for p in self.game1.positions)


def nim_game(heap_size: int) -> WFGame:
    """
    Construct the Nim game on a heap of given size.
    
    Corresponds to NimGame from Lean (restricted to finite ordinals).
    Position i represents a heap of i stones.
    From position i, one can move to any j < i.
    """
    positions = {GamePosition(i, f"nim_{i}") for i in range(heap_size + 1)}
    moves: Dict[GamePosition, Set[GamePosition]] = {}
    pos_by_id = {p.id: p for p in positions}
    
    for p in positions:
        moves[p] = {pos_by_id[j] for j in range(p.id)}
    
    return WFGame(positions=positions, moves=moves)


def canonical_game(n: int) -> WFGame:
    """
    Construct the canonical game on ordinal n (for finite n).
    
    Corresponds to CanonicalGame from Lean.
    Positions are {0, 1, ..., n-1} with moves q → p iff q < p.
    """
    positions = {GamePosition(i, f"ord_{i}") for i in range(n)}
    moves: Dict[GamePosition, Set[GamePosition]] = {}
    pos_by_id = {p.id: p for p in positions}
    
    for p in positions:
        moves[p] = {pos_by_id[j] for j in range(p.id)}
    
    return WFGame(positions=positions, moves=moves)


def linear_game(length: int) -> WFGame:
    """
    Construct a linear (strategically trivial) game of given length.
    
    Each position has exactly one move to its predecessor.
    Game value = position index, strategic depth = 0.
    """
    positions = {GamePosition(i, f"lin_{i}") for i in range(length + 1)}
    moves: Dict[GamePosition, Set[GamePosition]] = {}
    pos_by_id = {p.id: p for p in positions}
    
    for p in positions:
        if p.id > 0:
            moves[p] = {pos_by_id[p.id - 1]}
        else:
            moves[p] = set()
    
    return WFGame(positions=positions, moves=moves)


class OrdinalSymbolic:
    """
    Symbolic ordinal arithmetic for demonstration purposes.
    Represents ordinals in Cantor Normal Form (finite approximation).
    """
    
    def __init__(self, terms: List[Tuple[int, int]]):
        """
        terms: list of (exponent, coefficient) pairs in decreasing order.
        Represents sum of ω^e * c terms.
        Empty list = 0.
        """
        self.terms = [(e, c) for e, c in terms if c > 0]
    
    @classmethod
    def zero(cls) -> 'OrdinalSymbolic':
        return cls([])
    
    @classmethod
    def finite(cls, n: int) -> 'OrdinalSymbolic':
        if n == 0:
            return cls.zero()
        return cls([(0, n)])
    
    @classmethod
    def omega_power(cls, n: int) -> 'OrdinalSymbolic':
        if n == 0:
            return cls.finite(1)
        return cls([(n, 1)])
    
    def __str__(self) -> str:
        if not self.terms:
            return "0"
        parts = []
        for e, c in self.terms:
            if e == 0:
                parts.append(str(c))
            elif e == 1:
                parts.append(f"ω·{c}" if c > 1 else "ω")
            else:
                parts.append(f"ω^{e}·{c}" if c > 1 else f"ω^{e}")
        return " + ".join(parts)
    
    def __repr__(self) -> str:
        return f"OrdinalSymbolic({self.terms})"


def epsilon0_tower(depth: int) -> List[str]:
    """
    Generate the ε₀ approximation tower.
    
    ε₀ = nfp(ω^·, 0) = sup { 0, 1, ω, ω^ω, ω^(ω^ω), ... }
    
    Returns symbolic representations of each iterate.
    """
    if depth <= 0:
        return ["0"]
    
    result = ["0", "1", "ω"]
    current = "ω"
    for _ in range(depth - 3):
        current = f"ω^({current})"
        result.append(current)
    return result[:depth]


if __name__ == "__main__":
    # Quick self-test
    game = canonical_game(5)
    values = compute_game_values(game)
    
    # Verify canonical_value_eq: value of position i = i
    pos_by_id = {p.id: p for p in game.positions}
    for i in range(5):
        assert values[pos_by_id[i]] == i, f"canonical_value_eq failed at {i}"
    
    # Verify nim_value_eq
    nim = nim_game(5)
    nim_values = compute_game_values(nim)
    nim_by_id = {p.id: p for p in nim.positions}
    for i in range(6):
        assert nim_values[nim_by_id[i]] == i, f"nim_value_eq failed at {i}"
    
    # Verify spectrum boundedness
    root = pos_by_id[4]
    spectrum = compute_depth_spectrum(game, root, values)
    assert verify_spectrum_bounded(game, root, values, spectrum)
    
    # Verify strategically trivial
    lin = linear_game(5)
    assert lin.is_strategically_trivial()
    assert not game.is_strategically_trivial()
    
    print("All self-tests passed!")
