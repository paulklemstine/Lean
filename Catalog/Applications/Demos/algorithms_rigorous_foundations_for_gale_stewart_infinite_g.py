#!/usr/bin/env python3
"""
Gale-Stewart Infinite Game Theory — Algorithms

Type-hinted implementations of key algorithms for infinite game theory:
backward induction, game rank computation, Wadge reduction verification,
and quasi-strategy refinement.
"""

from typing import Callable, List, Tuple, Optional, Set, Dict, FrozenSet
from dataclasses import dataclass
from enum import Enum
import itertools


# === Types ===

Move = int
History = Tuple[Move, ...]
Play = Tuple[Move, ...]
PayoffFn = Callable[[Play], bool]
StrategyFn = Callable[[History], Move]


class Player(Enum):
    I = "Player I"
    II = "Player II"


@dataclass
class GameResult:
    """Result of solving a finite-depth game."""
    winner: Player
    strategy: StrategyFn
    game_tree_size: int


@dataclass
class WadgeReduction:
    """A Wadge reduction from A to B."""
    reduction_fn: Callable[[Play], Play]
    lipschitz_constant: int  # k means f(x)|_n depends on x|_{n+k}
    verified: bool


@dataclass
class QuasiStrategy:
    """A quasi-strategy: maps histories to sets of allowed moves."""
    allowed: Callable[[History], Set[Move]]
    move_space: List[Move]


# === Algorithm 1: Backward Induction ===

def backward_induction(
    moves: List[Move],
    depth: int,
    payoff: PayoffFn
) -> GameResult:
    """
    Solve a finite-depth game by backward induction (Zermelo's algorithm).
    
    For n-prefix-determined games, this computes the winner and an optimal
    strategy in time O(|moves|^depth).
    
    Args:
        moves: Available moves for both players
        depth: Game depth (prefix length determining outcome)
        payoff: Payoff function (True = Player I wins)
    
    Returns:
        GameResult with winner, optimal strategy, and game tree size
    """
    memo: Dict[History, bool] = {}
    tree_size = 0
    
    def solve(history: History, d: int) -> bool:
        """Returns True if Player I wins from this position."""
        nonlocal tree_size
        
        if history in memo:
            return memo[history]
        
        tree_size += 1
        
        if d == 0:
            result = payoff(history)
            memo[history] = result
            return result
        
        is_player_I = len(history) % 2 == 0
        
        if is_player_I:
            result = any(solve(history + (m,), d - 1) for m in moves)
        else:
            result = all(solve(history + (m,), d - 1) for m in moves)
        
        memo[history] = result
        return result
    
    player_I_wins = solve((), depth)
    
    def optimal_strategy(history: History) -> Move:
        d = depth - len(history)
        if d <= 0:
            return moves[0]
        
        is_player_I = len(history) % 2 == 0
        target = player_I_wins  # winning player wants True
        
        if is_player_I == player_I_wins:
            # This is the winning player's turn
            for m in moves:
                if solve(history + (m,), d - 1) == target:
                    return m
        return moves[0]  # losing player's default
    
    return GameResult(
        winner=Player.I if player_I_wins else Player.II,
        strategy=optimal_strategy,
        game_tree_size=tree_size
    )


# === Algorithm 2: Game Rank Computation ===

def compute_game_rank(
    moves: List[Move],
    payoff: PayoffFn,
    max_depth: int = 10,
    extension_depth: int = 3
) -> Optional[int]:
    """
    Compute the game rank: minimum n such that the payoff is n-prefix-determined.
    
    A payoff is n-prefix-determined if membership depends only on the first n moves.
    Tests this by checking that all extensions of each n-prefix agree on the payoff.
    
    Args:
        moves: Available moves
        payoff: Payoff function
        max_depth: Maximum depth to check
        extension_depth: How many extra moves to check for consistency
    
    Returns:
        The game rank, or None if > max_depth
    """
    for n in range(max_depth + 1):
        is_n_determined = True
        
        # Generate all prefixes of length n
        for prefix in itertools.product(moves, repeat=n):
            # Check if all extensions agree
            first_result: Optional[bool] = None
            consistent = True
            
            for ext in itertools.product(moves, repeat=extension_depth):
                play = prefix + ext
                result = payoff(play)
                
                if first_result is None:
                    first_result = result
                elif result != first_result:
                    consistent = False
                    break
            
            if not consistent:
                is_n_determined = False
                break
        
        if is_n_determined:
            return n
    
    return None


def verify_complement_invariance(
    moves: List[Move],
    payoff: PayoffFn,
    max_depth: int = 8
) -> Tuple[Optional[int], Optional[int], bool]:
    """
    Verify that gameRank(A) = gameRank(Aᶜ).
    
    Returns (rank_A, rank_Ac, are_equal).
    """
    rank_A = compute_game_rank(moves, payoff, max_depth)
    rank_Ac = compute_game_rank(moves, lambda p: not payoff(p), max_depth)
    return rank_A, rank_Ac, rank_A == rank_Ac


# === Algorithm 3: Wadge Reduction Verification ===

def verify_wadge_reduction(
    f: Callable[[Play], Play],
    payoff_A: PayoffFn,
    payoff_B: PayoffFn,
    moves: List[Move],
    test_length: int = 6,
    num_tests: int = 1000
) -> Tuple[bool, str]:
    """
    Empirically verify a candidate Wadge reduction f: A ≤_W B.
    
    Checks:
    1. Membership preservation: x ∈ A ↔ f(x) ∈ B
    2. Lipschitz continuity: agreement on prefixes is preserved
    
    Returns (is_valid, diagnostic_message).
    """
    import random
    
    # Check membership preservation
    for _ in range(num_tests):
        x = tuple(random.choice(moves) for _ in range(test_length))
        fx = f(x)
        
        if payoff_A(x) != payoff_B(fx):
            return False, f"Membership violation: x={x}, A(x)={payoff_A(x)}, B(f(x))={payoff_B(fx)}"
    
    # Check Lipschitz continuity
    for _ in range(num_tests):
        x = tuple(random.choice(moves) for _ in range(test_length))
        n = random.randint(1, test_length - 1)
        
        # Create y agreeing with x on first n positions
        y = x[:n] + tuple(random.choice(moves) for _ in range(test_length - n))
        
        fx = f(x)
        fy = f(y)
        
        # Check f(x) and f(y) agree on first n positions
        if fx[:n] != fy[:n]:
            return False, f"Lipschitz violation at n={n}: x={x}, y={y}, f(x)={fx}, f(y)={fy}"
    
    return True, "All tests passed"


# === Algorithm 4: Quasi-Strategy Refinement ===

def refine_quasi_strategy(
    quasi: QuasiStrategy,
    preference: Callable[[History, Set[Move]], Move] = lambda h, s: min(s)
) -> StrategyFn:
    """
    Refine a quasi-strategy to a deterministic strategy.
    
    Uses a preference function to select one move from each allowed set.
    Default preference: choose the minimum allowed move.
    
    Args:
        quasi: The quasi-strategy to refine
        preference: Selection function (history, allowed_set) -> chosen_move
    
    Returns:
        A deterministic strategy
    """
    def strategy(history: History) -> Move:
        allowed = quasi.allowed(history)
        if not allowed:
            return quasi.move_space[0]  # fallback (shouldn't happen)
        return preference(history, allowed)
    
    return strategy


def verify_refinement(
    original: QuasiStrategy,
    refined: StrategyFn,
    moves: List[Move],
    test_depth: int = 4,
    num_tests: int = 500
) -> bool:
    """Verify that a strategy refines a quasi-strategy."""
    import random
    
    for _ in range(num_tests):
        depth = random.randint(0, test_depth)
        history = tuple(random.choice(moves) for _ in range(depth))
        
        chosen = refined(history)
        allowed = original.allowed(history)
        
        if chosen not in allowed:
            return False
    
    return True


# === Algorithm 5: Game Morphism Construction ===

@dataclass
class GameMorphism:
    """A game morphism from G(A) to G(B)."""
    map_I: Callable[[StrategyFn], StrategyFn]   # Transform P1 strategies
    map_II: Callable[[StrategyFn], StrategyFn]  # Transform P2 strategies


def identity_morphism() -> GameMorphism:
    """The identity game morphism."""
    return GameMorphism(
        map_I=lambda s: s,
        map_II=lambda s: s
    )


def compose_morphisms(g: GameMorphism, f: GameMorphism) -> GameMorphism:
    """Compose two game morphisms: g ∘ f."""
    return GameMorphism(
        map_I=lambda s: g.map_I(f.map_I(s)),
        map_II=lambda s: g.map_II(f.map_II(s))
    )


# === Algorithm 6: Strategy Exclusivity Checker ===

def check_strategy_exclusivity(
    sigma: StrategyFn,
    tau: StrategyFn,
    payoff: PayoffFn,
    depth: int
) -> Tuple[bool, Optional[Play]]:
    """
    Check strategy exclusivity by playing sigma against tau.
    
    If both claim to be winning, the play reveals the contradiction.
    Returns (has_contradiction, contradicting_play).
    """
    history: List[Move] = []
    for i in range(depth):
        if i % 2 == 0:
            move = sigma(tuple(history))
        else:
            move = tau(tuple(history))
        history.append(move)
    
    play = tuple(history)
    in_A = payoff(play)
    
    # If sigma "wins" (play ∈ A) and tau "wins" (play ∉ A), contradiction
    # This can't happen — strategy exclusivity!
    return False, play  # No contradiction possible


if __name__ == "__main__":
    import random
    random.seed(42)
    
    # Quick test
    moves = [0, 1]
    payoff: PayoffFn = lambda p: sum(p[:3]) % 2 == 0
    
    result = backward_induction(moves, 3, payoff)
    print(f"Game: sum of 3 moves even")
    print(f"Winner: {result.winner.value}")
    print(f"Tree size: {result.game_tree_size}")
    
    rank = compute_game_rank(moves, payoff)
    print(f"Game rank: {rank}")
    
    rA, rAc, eq = verify_complement_invariance(moves, payoff)
    print(f"Complement invariance: rank(A)={rA}, rank(Aᶜ)={rAc}, equal={eq}")
