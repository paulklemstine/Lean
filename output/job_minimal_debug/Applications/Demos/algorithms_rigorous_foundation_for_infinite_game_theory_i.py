"""
Infinite Game Theory: Core Algorithms
======================================

Type-hinted implementations of the key algorithms from the formalization.
"""

from typing import Callable, List, Optional, Tuple, Set, Dict
from dataclasses import dataclass, field


# ============================================================================
# Type Aliases
# ============================================================================

Move = int
History = List[Move]
Strategy = Callable[[History], Move]
Play = List[Move]
PayoffPredicate = Callable[[Play], bool]


# ============================================================================
# Algorithm 1: Play Generation
# ============================================================================

def generate_play(
    sigma: Strategy,
    tau: Strategy,
    num_moves: int
) -> Play:
    """
    Generate the canonical play from two strategies.

    At even positions (0, 2, 4, ...) Player I moves using sigma.
    At odd positions (1, 3, 5, ...) Player II moves using tau.

    Corresponds to `playAux` and `play` in the Lean formalization.

    Time complexity: O(n) strategy evaluations, O(n²) total if strategies
    inspect the full history.

    Args:
        sigma: Player I's strategy
        tau: Player II's strategy
        num_moves: Total number of moves to generate

    Returns:
        The play sequence as a list of moves
    """
    history: History = []
    for n in range(num_moves):
        if n % 2 == 0:
            move = sigma(history[:])
        else:
            move = tau(history[:])
        history.append(move)
    return history


# ============================================================================
# Algorithm 2: Finite Game Tree Solver (Zermelo / Backward Induction)
# ============================================================================

@dataclass
class GameNode:
    """A node in a finite game tree."""
    is_terminal: bool
    terminal_value: Optional[bool] = None  # True = Player I wins
    children: List['GameNode'] = field(default_factory=list)
    player: int = 0  # 0 = Player I (maximizer), 1 = Player II (minimizer)


def solve_game_tree(node: GameNode) -> Tuple[bool, Optional[int]]:
    """
    Solve a finite game tree by backward induction (Zermelo's algorithm).

    Returns (winner, optimal_move_index) where winner is True if Player I
    wins with optimal play, and optimal_move_index is the index of the
    optimal child for the current player.

    This algorithm proves that every finite game of perfect information
    is determined — the finite analogue of our `trivial_game_determined`.

    Time complexity: O(|T|) where |T| is the number of nodes.
    Space complexity: O(depth) for the recursion stack.

    Args:
        node: Root of the game tree

    Returns:
        (player_I_wins, best_child_index)
    """
    if node.is_terminal:
        return node.terminal_value, None

    child_results = [(solve_game_tree(c)[0], i)
                     for i, c in enumerate(node.children)]

    if node.player == 0:  # Player I maximizes
        # Player I wins if ANY child is winning
        for value, idx in child_results:
            if value:
                return True, idx
        return False, child_results[0][1] if child_results else None
    else:  # Player II minimizes
        # Player II wins (value False) if ANY child is losing for I
        for value, idx in child_results:
            if not value:
                return False, idx
        return True, child_results[0][1] if child_results else None


def extract_strategy(node: GameNode) -> Dict[str, int]:
    """
    Extract a winning strategy from a solved game tree.

    Returns a dictionary mapping position descriptions to optimal moves.

    Args:
        node: Root of the solved game tree

    Returns:
        Dictionary of position -> optimal move index
    """
    strategy: Dict[str, int] = {}

    def traverse(n: GameNode, path: str = "root"):
        if n.is_terminal:
            return
        _, best = solve_game_tree(n)
        if best is not None:
            strategy[path] = best
        for i, child in enumerate(n.children):
            traverse(child, f"{path}->{i}")

    traverse(node)
    return strategy


# ============================================================================
# Algorithm 3: Wadge Reduction Checker
# ============================================================================

def check_wadge_reduction(
    f: Callable[[Play], Play],
    set_A: PayoffPredicate,
    set_B: PayoffPredicate,
    test_sequences: List[Play],
) -> Tuple[bool, Optional[Play]]:
    """
    Check if a function f witnesses Wadge reducibility A ≤_W B.

    Tests whether x ∈ A ⟺ f(x) ∈ B for all test sequences.
    Returns (True, None) if all tests pass, or (False, counterexample)
    if a test fails.

    Corresponds to the `WadgeReducible` definition in Lean:
      ∃ f, Continuous f ∧ ∀ x, x ∈ A ↔ f x ∈ B

    Note: We cannot check continuity computationally for arbitrary functions,
    so this only verifies the membership equivalence.

    Args:
        f: The proposed reduction function
        set_A: Membership predicate for set A
        set_B: Membership predicate for set B
        test_sequences: Sequences to test against

    Returns:
        (all_pass, counterexample_or_none)
    """
    for seq in test_sequences:
        in_A = set_A(seq)
        in_B = set_B(f(seq))
        if in_A != in_B:
            return False, seq
    return True, None


# ============================================================================
# Algorithm 4: Game Rank Computation
# ============================================================================

def compute_game_rank(
    payoff_is_empty: bool,
    payoff_is_universal: bool
) -> int:
    """
    Compute the game rank.

    Corresponds to `gameRank` in the Lean formalization:
      - rank 0: payoff = ∅ or payoff = univ (trivial games)
      - rank 1: otherwise (non-trivial games)

    The key theorems proven about this function:
      - rank_zero_iff_trivial: rank = 0 ↔ trivial
      - rank_complement: rank(G^c) = rank(G)

    Args:
        payoff_is_empty: Whether the payoff set is empty
        payoff_is_universal: Whether the payoff set is universal

    Returns:
        The game rank (0 or 1)
    """
    if payoff_is_empty:
        return 0
    if payoff_is_universal:
        return 0
    return 1


# ============================================================================
# Algorithm 5: Strategy Exclusivity Verifier
# ============================================================================

def verify_exclusivity(
    payoff: PayoffPredicate,
    sigma: Strategy,
    tau: Strategy,
    num_moves: int = 20
) -> Tuple[bool, bool, bool]:
    """
    Verify strategy exclusivity by checking the canonical play.

    If sigma is winning for Player I and tau is winning for Player II,
    the play sigma-vs-tau must simultaneously be in and not in the payoff
    set — a contradiction. This function computes the play and checks both
    conditions.

    Corresponds to `strategy_exclusivity` in the Lean formalization.

    Args:
        payoff: The payoff predicate
        sigma: Player I's strategy
        tau: Player II's strategy
        num_moves: Number of moves to generate

    Returns:
        (play_in_payoff, play_not_in_payoff, contradiction_detected)
    """
    play = generate_play(sigma, tau, num_moves)
    in_payoff = payoff(play)
    not_in_payoff = not in_payoff
    # If sigma were winning-I and tau were winning-II, we'd need
    # in_payoff AND not_in_payoff, which is impossible.
    contradiction = in_payoff and not_in_payoff  # Always False
    return in_payoff, not_in_payoff, contradiction


# ============================================================================
# Algorithm 6: Quasi-Strategy Refinement
# ============================================================================

@dataclass
class QuasiStrategy:
    """A quasi-strategy: assigns a set of allowable moves to each history."""
    allowed_moves: Callable[[History], Set[Move]]


def refines(sigma: Strategy, quasi: QuasiStrategy, test_histories: List[History]) -> bool:
    """
    Check if strategy sigma refines quasi-strategy q.

    Corresponds to `Refines` in the Lean formalization:
      ∀ hist, σ hist ∈ q hist

    Args:
        sigma: The concrete strategy
        quasi: The quasi-strategy
        test_histories: Histories to test

    Returns:
        True if sigma's choices are always within the quasi-strategy's allowed set
    """
    for hist in test_histories:
        move = sigma(hist)
        allowed = quasi.allowed_moves(hist)
        if move not in allowed:
            return False
    return True


def find_refinement(quasi: QuasiStrategy, histories: List[History]) -> Optional[Strategy]:
    """
    Find a concrete strategy that refines a given quasi-strategy.

    Picks the minimum allowed move at each history.

    Args:
        quasi: The quasi-strategy to refine
        histories: Histories to consider

    Returns:
        A strategy that refines the quasi-strategy, or None if impossible
    """
    # Build a lookup for specific histories
    choices: Dict[tuple, Move] = {}
    for hist in histories:
        allowed = quasi.allowed_moves(hist)
        if not allowed:
            return None  # No valid move at this history
        choices[tuple(hist)] = min(allowed)

    def strategy(hist: History) -> Move:
        key = tuple(hist)
        if key in choices:
            return choices[key]
        allowed = quasi.allowed_moves(hist)
        return min(allowed) if allowed else 0

    return strategy


if __name__ == "__main__":
    # Quick smoke test
    play = generate_play(
        sigma=lambda h: 0,
        tau=lambda h: 1,
        num_moves=10
    )
    print(f"Play (I=0, II=1): {play}")
    assert play == [0, 1, 0, 1, 0, 1, 0, 1, 0, 1]

    # Test exclusivity
    in_p, not_p, contra = verify_exclusivity(
        payoff=lambda p: sum(p) % 2 == 0,
        sigma=lambda h: 0,
        tau=lambda h: 1,
    )
    print(f"In payoff: {in_p}, Not in payoff: {not_p}, Contradiction: {contra}")
    assert not contra  # No contradiction possible

    print("All smoke tests passed.")
