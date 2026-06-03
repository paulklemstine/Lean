#!/usr/bin/env python3
"""
Algorithms for Infinite Games Against Death

Type-hinted implementations of the core algorithms from the Mortal-Eternity
game framework.
"""

from typing import TypeVar, Generic, Callable, List, Optional, Tuple, Set
from dataclasses import dataclass
from enum import Enum
import math

S = TypeVar('S')
A = TypeVar('A')

# ============================================================================
# Core Data Structures
# ============================================================================

@dataclass
class SurvivalGame(Generic[S]):
    """A survival game with finite out-degree at each state."""
    successors: Callable[[S], List[S]]
    
    def is_live(self, state: S) -> bool:
        """Check if state has available moves."""
        return len(self.successors(state)) > 0
    
    def is_everywhere_live(self, states: List[S]) -> bool:
        """Check liveness over a collection of states."""
        return all(self.is_live(s) for s in states)


@dataclass
class AdversarialGame(Generic[S, A]):
    """An adversarial game between Mortal (finite moves) and Eternity."""
    mortal_moves: Callable[[S], List[A]]
    eternity_response: Callable[[S, A], List[S]]
    
    def is_live(self, state: S) -> bool:
        """Check if Mortal has available moves."""
        return len(self.mortal_moves(state)) > 0


class OrdinalType(Enum):
    """Representation of small ordinals for game rank computation."""
    FINITE = "finite"
    OMEGA = "omega"
    OMEGA_SQUARED = "omega_squared"
    OMEGA_CUBED = "omega_cubed"


@dataclass
class Ordinal:
    """Simple ordinal representation: a * ω² + b * ω + c."""
    omega_sq_coeff: int  # coefficient of ω²
    omega_coeff: int     # coefficient of ω
    finite_part: int     # finite part
    
    @staticmethod
    def finite(n: int) -> 'Ordinal':
        return Ordinal(0, 0, n)
    
    @staticmethod
    def omega() -> 'Ordinal':
        return Ordinal(0, 1, 0)
    
    @staticmethod
    def omega_times(n: int) -> 'Ordinal':
        return Ordinal(0, n, 0)
    
    @staticmethod
    def omega_squared() -> 'Ordinal':
        return Ordinal(1, 0, 0)
    
    def __str__(self) -> str:
        parts = []
        if self.omega_sq_coeff > 0:
            parts.append(f"{self.omega_sq_coeff}·ω²" if self.omega_sq_coeff > 1 else "ω²")
        if self.omega_coeff > 0:
            parts.append(f"{self.omega_coeff}·ω" if self.omega_coeff > 1 else "ω")
        if self.finite_part > 0 or not parts:
            parts.append(str(self.finite_part))
        return " + ".join(parts)
    
    def __le__(self, other: 'Ordinal') -> bool:
        return (self.omega_sq_coeff, self.omega_coeff, self.finite_part) <= \
               (other.omega_sq_coeff, other.omega_coeff, other.finite_part)
    
    def __lt__(self, other: 'Ordinal') -> bool:
        return (self.omega_sq_coeff, self.omega_coeff, self.finite_part) < \
               (other.omega_sq_coeff, other.omega_coeff, other.finite_part)


# ============================================================================
# Core Algorithms
# ============================================================================

def compute_survival_time(
    game: SurvivalGame[S],
    strategy: Callable[[S, List[S]], S],
    initial: S,
    max_rounds: int = 1000
) -> int:
    """
    Compute how many rounds Mortal survives with a given strategy.
    
    Algorithm: Iterate the play sequence until the game is no longer live
    or max_rounds is reached.
    
    Time: O(max_rounds * T_successors)
    Space: O(1) (not storing full history)
    """
    current = initial
    for round_num in range(max_rounds):
        succs = game.successors(current)
        if not succs:
            return round_num
        current = strategy(current, succs)
    return max_rounds


def find_optimal_strategy_bounded(
    game: SurvivalGame[S],
    initial: S,
    max_depth: int = 10
) -> Tuple[int, List[S]]:
    """
    Find the strategy that maximizes survival time (for bounded games).
    
    Algorithm: DFS/BFS exploration of the game tree up to max_depth.
    Returns (survival_time, optimal_play_sequence).
    
    Time: O(b^d) where b = max branching, d = max_depth
    Space: O(d) for the recursion stack
    """
    def dfs(state: S, depth: int) -> Tuple[int, List[S]]:
        if depth >= max_depth:
            return (depth, [state])
        
        succs = game.successors(state)
        if not succs:
            return (depth, [state])
        
        best_time = -1
        best_path: List[S] = []
        
        for s in succs:
            time, path = dfs(s, depth + 1)
            if time > best_time:
                best_time = time
                best_path = [state] + path
        
        return (best_time, best_path)
    
    return dfs(initial, 0)


def compute_game_rank_wf(
    game: SurvivalGame[S],
    initial: S,
    visited: Optional[Set] = None,
    max_depth: int = 100
) -> Ordinal:
    """
    Compute the well-founded game rank (for terminating games).
    
    Algorithm: Recursive computation of rank = max(rank(s') + 1)
    over all successors s'. Uses memoization via visited set.
    
    Precondition: Game must be well-founded (no infinite plays).
    
    Time: O(|reachable states|)
    Space: O(|reachable states|)
    """
    if visited is None:
        visited = set()
    
    state_key = str(initial)
    if state_key in visited:
        return Ordinal.finite(0)  # Cycle detected, treat as terminal
    
    succs = game.successors(initial)
    if not succs:
        return Ordinal.finite(0)
    
    visited.add(state_key)
    max_rank = Ordinal.finite(0)
    
    for s in succs:
        if max_depth <= 0:
            break
        child_rank = compute_game_rank_wf(game, s, visited, max_depth - 1)
        successor_rank = Ordinal(
            child_rank.omega_sq_coeff,
            child_rank.omega_coeff,
            child_rank.finite_part + 1
        )
        if max_rank < successor_rank:
            max_rank = successor_rank
    
    visited.discard(state_key)
    return max_rank


def classify_survival_ordinal(
    game: SurvivalGame[S],
    test_states: List[S],
    max_test: int = 100
) -> str:
    """
    Heuristically classify the survival ordinal of a game.
    
    Algorithm: Test liveness at sampled states and measure survival
    with a greedy strategy. Returns a string classification.
    
    This is a heuristic — formal classification requires proof.
    """
    # Check if everywhere live on test states
    all_live = all(game.is_live(s) for s in test_states)
    
    if not all_live:
        # Find max survival
        def greedy(state, succs):
            return succs[0]
        max_surv = max(
            compute_survival_time(game, greedy, s, max_test)
            for s in test_states
        )
        return f"finite (≤ {max_surv})"
    
    # Check if nondeterministic (multiple choices)
    branching = [len(game.successors(s)) for s in test_states]
    max_branch = max(branching)
    
    if max_branch == 1:
        return "ω (deterministic, everywhere live)"
    elif max_branch == 2:
        return "≥ ω, structure suggests ω·k for some k"
    else:
        return f"≥ ω, branching factor {max_branch} suggests higher ordinal"


def layered_strategy(
    state: Tuple[int, int],
    succs: List[Tuple[int, int]],
    steps_per_layer: int = 5
) -> Tuple[int, int]:
    """
    Optimal strategy for the layered game: advance within layer for
    `steps_per_layer` steps, then jump to next layer.
    
    This strategy achieves survival ordinal ω·(n_layers + 1).
    """
    _, j = state
    if j >= steps_per_layer and len(succs) > 1:
        return succs[1]  # Jump: (i+1, 0)
    return succs[0]  # Advance: (i, j+1)


def simulate_ittm_game(
    num_states: int,
    transition: Callable[[int, bool], Tuple[int, bool, int]],
    initial_tape: List[bool],
    max_steps: int = 10000
) -> Tuple[int, bool]:
    """
    Simulate an ITTM-like game: Mortal provides initial tape,
    machine runs until halting or max_steps.
    
    transition(state, tape_symbol) -> (new_state, write_symbol, head_move)
    where head_move is +1 (right) or -1 (left)
    
    Returns (steps_survived, halted).
    """
    tape = dict(enumerate(initial_tape))
    head = 0
    state = 0
    halt_state = num_states  # Convention: state = num_states means halt
    
    for step in range(max_steps):
        if state >= num_states:
            return (step, True)
        
        symbol = tape.get(head, False)
        new_state, write, move = transition(state, symbol)
        tape[head] = write
        head = max(0, head + move)
        state = new_state
    
    return (max_steps, False)


# ============================================================================
# Main demonstration
# ============================================================================

if __name__ == "__main__":
    print("=== Algorithms for Infinite Games Against Death ===\n")
    
    # Bounded counting game rank
    bcg = SurvivalGame(lambda k: [k - 1] if k > 0 else [])
    for n in [3, 5, 10]:
        rank = compute_game_rank_wf(bcg, n)
        print(f"Bounded counting game rank from {n}: {rank}")
    
    print()
    
    # Counting game classification
    cg = SurvivalGame(lambda n: [n + 1])
    cls = classify_survival_ordinal(cg, list(range(20)))
    print(f"Counting game classification: {cls}")
    
    # Layered game classification  
    lg = SurvivalGame(lambda s: [(s[0], s[1] + 1), (s[0] + 1, 0)])
    cls = classify_survival_ordinal(lg, [(i, j) for i in range(5) for j in range(5)])
    print(f"Layered game classification: {cls}")
    
    print()
    
    # Optimal play in bounded counting
    time, path = find_optimal_strategy_bounded(bcg, 5, max_depth=20)
    print(f"Optimal play in bounded counting from 5: {path} (survived {time - 1} rounds)")
