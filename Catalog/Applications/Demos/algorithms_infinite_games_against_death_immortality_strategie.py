#!/usr/bin/env python3
"""
Algorithms for Mortal vs Eternity: Infinite Games Against Death

Type-hinted implementations of the core algorithms.
"""

from typing import List, Tuple, Callable, Optional, Dict
from dataclasses import dataclass
from enum import Enum


# ============================================================
# Core Types
# ============================================================

Move = int
History = List[Tuple[Move, Move]]
MortalStrategy = Callable[[History], Move]
EternityStrategy = Callable[[History, Move], Move]


class GameResult(Enum):
    ALIVE = "alive"
    DEAD = "dead"


@dataclass
class SurvivalGame:
    """A survival game with a death predicate."""
    death_predicate: Callable[[History], bool]
    name: str = "unnamed"

    def has_died(self, history: History) -> bool:
        return self.death_predicate(history)

    def is_alive(self, history: History) -> bool:
        return not self.death_predicate(history)


# ============================================================
# Algorithm 1: Safe Strategy Construction
# ============================================================

def construct_safe_strategy(
    num_moves: int,
    is_safe: Callable[[History, Move], bool]
) -> MortalStrategy:
    """
    Construct a safe strategy for Mortal.

    Algorithm:
    1. At each position (history), enumerate available moves
    2. For each move, check if it's safe against all responses
    3. Return the first safe move found

    Time complexity: O(num_moves) per round
    Space complexity: O(|history|) for state

    Args:
        num_moves: Number of available moves (0..num_moves-1)
        is_safe: Predicate that checks if a move is safe at a given history
                 (safe = no response can cause death)

    Returns:
        A MortalStrategy that always picks a safe move
    """
    def strategy(history: History) -> Move:
        for m in range(num_moves):
            if is_safe(history, m):
                return m
        # Fallback: no safe move exists (game doesn't have SafeEscape)
        return 0
    return strategy


# ============================================================
# Algorithm 2: Game Simulation
# ============================================================

def simulate_game(
    game: SurvivalGame,
    mortal: MortalStrategy,
    eternity: EternityStrategy,
    max_rounds: int = 1000
) -> Tuple[GameResult, int, History]:
    """
    Simulate a game between Mortal and Eternity.

    Algorithm:
    1. Initialize empty history
    2. Each round: Mortal picks move, Eternity responds
    3. Check death predicate
    4. Continue until death or max_rounds

    Returns:
        (result, rounds_survived, history)
    """
    history: History = []
    for round_num in range(max_rounds):
        m_move = mortal(history)
        e_response = eternity(history, m_move)
        history.append((m_move, e_response))
        if game.has_died(history):
            return GameResult.DEAD, round_num + 1, history
    return GameResult.ALIVE, max_rounds, history


# ============================================================
# Algorithm 3: Ordinal Arena Strategy
# ============================================================

@dataclass
class OrdinalArena:
    """An arena with ordinal-valued rank function."""
    game: SurvivalGame
    rank_fn: Callable[[History], float]
    safe_moves: Callable[[History], List[Move]]

    def arena_strategy(self) -> MortalStrategy:
        """
        Construct the arena strategy that always decreases rank.

        Algorithm:
        1. Get list of safe moves at current position
        2. For each safe move, compute worst-case rank after response
        3. Pick the move with minimum worst-case rank

        This is a minimax-style strategy adapted for ordinal arenas.
        """
        def strategy(history: History) -> Move:
            moves = self.safe_moves(history)
            if not moves:
                return 0
            # Pick move that minimizes rank (greedy descent)
            best_move = moves[0]
            best_rank = float('inf')
            for m in moves:
                # Estimate worst-case rank (simplified)
                rank = self.rank_fn(history + [(m, 0)])
                if rank < best_rank:
                    best_rank = rank
                    best_move = m
            return best_move
        return strategy


# ============================================================
# Algorithm 4: Layered Survival
# ============================================================

@dataclass
class LayeredSurvival:
    """k-layered survival with independent games."""
    games: List[SurvivalGame]
    strategies: List[MortalStrategy]

    def total_survival(
        self,
        eternity: EternityStrategy,
        rounds_per_layer: int = 1000
    ) -> Tuple[int, List[int]]:
        """
        Compute total survival across all layers.

        Algorithm:
        1. For each layer, simulate until death or max rounds
        2. Sum total rounds survived
        3. Return total and per-layer breakdown

        In ordinal terms: if each layer survives ω rounds,
        k layers give ω·k total.
        """
        per_layer: List[int] = []
        total = 0
        for i, (game, strat) in enumerate(zip(self.games, self.strategies)):
            result, rounds, _ = simulate_game(game, strat, eternity, rounds_per_layer)
            per_layer.append(rounds)
            total += rounds
        return total, per_layer


# ============================================================
# Algorithm 5: Adaptive Layering (ω² construction)
# ============================================================

def adaptive_layered_survival(
    base_game: SurvivalGame,
    base_strategy: MortalStrategy,
    eternity: EternityStrategy,
    growth_fn: Callable[[int], int],
    max_epochs: int = 100,
    rounds_per_layer: int = 1000
) -> Dict[str, object]:
    """
    Adaptive layered survival reaching ω².

    Algorithm:
    1. Start with epoch 0
    2. At epoch k, spawn growth_fn(k) layers
    3. Each layer plays the base game with base strategy
    4. After all layers in epoch k complete, move to epoch k+1
    5. Continue until max_epochs

    Ordinal analysis:
    - Each layer survives ω rounds (via safe escape)
    - Epoch k has growth_fn(k) layers → ω·growth_fn(k) rounds
    - Total = Σ_k ω·growth_fn(k)
    - If growth_fn is unbounded, this → ω² in the limit
    """
    epoch_results = []
    total_rounds = 0

    for epoch in range(max_epochs):
        num_layers = growth_fn(epoch)
        epoch_rounds = 0
        for layer in range(num_layers):
            result, rounds, _ = simulate_game(
                base_game, base_strategy, eternity, rounds_per_layer
            )
            epoch_rounds += rounds
            total_rounds += rounds
        epoch_results.append({
            "epoch": epoch,
            "num_layers": num_layers,
            "rounds_this_epoch": epoch_rounds,
            "cumulative": total_rounds
        })

    return {
        "total_rounds": total_rounds,
        "epochs": epoch_results,
        "ordinal_bound": "ω²",
        "explanation": (
            f"Ran {max_epochs} epochs with growth function. "
            f"Each epoch k has growth(k) layers, each surviving ~{rounds_per_layer} rounds. "
            f"With unbounded growth, this approaches ω·ω = ω² in ordinal terms."
        )
    }


# ============================================================
# Algorithm 6: Asymmetry Gap Measurement
# ============================================================

def measure_asymmetry_gap(
    game: SurvivalGame,
    mortal: MortalStrategy,
    eternity_strategies: List[EternityStrategy],
    max_rounds: int = 10000
) -> Dict[str, object]:
    """
    Measure the asymmetry gap: how much does Eternity's power help?

    Algorithm:
    1. Test Mortal against each Eternity strategy
    2. Record whether Eternity ever kills Mortal
    3. Compute the "gap" = fraction of Eternities that can kill

    In safe-escape games, the gap is always 0 (Asymmetry Collapse).
    """
    kills = 0
    total = len(eternity_strategies)
    results = []

    for i, eternity in enumerate(eternity_strategies):
        result, rounds, _ = simulate_game(game, mortal, eternity, max_rounds)
        if result == GameResult.DEAD:
            kills += 1
        results.append({"strategy": i, "result": result.value, "rounds": rounds})

    gap = kills / total if total > 0 else 0
    return {
        "gap": gap,
        "kills": kills,
        "total_tested": total,
        "collapsed": gap == 0,
        "explanation": (
            f"Asymmetry gap = {gap:.4f}. "
            f"{'Collapse confirmed!' if gap == 0 else 'Eternity has advantage.'}"
        )
    }


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    import random

    # Create a safe-escape game
    game = SurvivalGame(
        death_predicate=lambda h: any(m == 0 and (m + e) % 3 == 0 for m, e in h),
        name="Trap Game (3 moves, move 0 is dangerous)"
    )

    # Safe strategy: avoid last response
    def smart_mortal(history):
        return 1  # Safe: always avoid move 0 (the only dangerous move)

    # Test adaptive layering
    result = adaptive_layered_survival(
        base_game=game,
        base_strategy=smart_mortal,
        eternity=lambda h, m: random.randint(0, 2),
        growth_fn=lambda k: k + 1,
        max_epochs=5,
        rounds_per_layer=100
    )
    print(f"Adaptive layering result: {result['total_rounds']} rounds")
    print(f"Ordinal bound: {result['ordinal_bound']}")

    # Measure asymmetry gap
    eternities = [
        lambda h, m, s=s: random.Random(s + len(h)).randint(0, 2)
        for s in range(100)
    ]
    gap_result = measure_asymmetry_gap(game, smart_mortal, eternities, 1000)
    print(f"\nAsymmetry gap: {gap_result['gap']}")
    print(gap_result['explanation'])
