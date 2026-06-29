#!/usr/bin/env python3
"""
Algorithms for Transfinite Game Theory

Type-hinted implementations of core algorithms:
1. Minimax — solve finite games by backward induction
2. Quasistrategy pruning — compute winning quasistrategies
3. Ordinal rank computation — assign ordinal ranks to game nodes
4. Strategy composition — combine strategies with switch points
5. Canonical play generation — simulate games from strategies
"""

from typing import List, Optional, Callable, Dict, Tuple, Set
from dataclasses import dataclass, field
from enum import Enum


# ============================================================
# Core Types
# ============================================================

class Player(Enum):
    I = 0   # Maximizer
    II = 1  # Minimizer


@dataclass
class GameNode:
    """A node in a finite game tree."""
    children: List['GameNode'] = field(default_factory=list)
    terminal_value: Optional[bool] = None  # True = Player I wins, None = non-terminal
    label: str = ""

    @property
    def is_terminal(self) -> bool:
        return len(self.children) == 0


Strategy = Callable[[List[int]], int]


# ============================================================
# Algorithm 1: Minimax
# ============================================================

def minimax(node: GameNode, depth: int = 0) -> bool:
    """Solve a finite game by backward induction (minimax).

    At even depths, Player I moves (maximizer: wins if ANY child wins).
    At odd depths, Player II moves (minimizer: wins if ALL children win for I,
    equivalently, loses if ANY child loses for I).

    Args:
        node: Current game tree node
        depth: Current depth (0 = Player I's turn)

    Returns:
        True if Player I has a winning strategy from this position.

    Time complexity: O(|T|) where |T| is the tree size.
    Space complexity: O(h) where h is the tree height (recursion stack).
    """
    if node.is_terminal:
        return node.terminal_value if node.terminal_value is not None else False

    player = Player.I if depth % 2 == 0 else Player.II

    if player == Player.I:
        # Player I wins if some child is winning for Player I
        return any(minimax(child, depth + 1) for child in node.children)
    else:
        # Player II wins if all children are winning for Player I
        # (Player II tries to avoid Player I winning)
        return all(minimax(child, depth + 1) for child in node.children)


def minimax_with_strategy(
    node: GameNode, depth: int = 0
) -> Tuple[bool, Dict[int, int]]:
    """Minimax with strategy extraction.

    Returns both the game value and a strategy (mapping node id to chosen child index).
    """
    strategy: Dict[int, int] = {}

    def solve(n: GameNode, d: int) -> bool:
        if n.is_terminal:
            return n.terminal_value if n.terminal_value is not None else False

        player = Player.I if d % 2 == 0 else Player.II
        results = [solve(child, d + 1) for child in n.children]

        if player == Player.I:
            for i, r in enumerate(results):
                if r:
                    strategy[id(n)] = i
                    return True
            return False
        else:
            for i, r in enumerate(results):
                if not r:
                    strategy[id(n)] = i
                    return False
            if results:
                strategy[id(n)] = 0
            return True

    value = solve(node, depth)
    return value, strategy


# ============================================================
# Algorithm 2: Quasistrategy Pruning
# ============================================================

@dataclass
class QuasistrategyNode:
    """A node in a quasistrategy (pruned game tree)."""
    position: Tuple[int, ...]
    children: List['QuasistrategyNode'] = field(default_factory=list)
    is_winning: Optional[bool] = None


def compute_quasistrategy(
    game_tree: GameNode,
    is_player_i_position: Callable[[int], bool] = lambda d: d % 2 == 0
) -> Optional[QuasistrategyNode]:
    """Compute a winning quasistrategy for Player I.

    A quasistrategy is a subtree that:
    - Preserves all opponent moves (closed under Player II's moves)
    - Has at least one move at each Player I position
    - All plays through it are winning for Player I

    Algorithm:
    1. Compute minimax values for all nodes.
    2. At Player I nodes, keep only winning children.
    3. At Player II nodes, keep all children.

    Returns None if Player I has no winning strategy.
    """
    def build(node: GameNode, depth: int, position: Tuple[int, ...]) -> Optional[QuasistrategyNode]:
        if node.is_terminal:
            val = node.terminal_value if node.terminal_value is not None else False
            return QuasistrategyNode(position=position, is_winning=val) if val else None

        is_pi = is_player_i_position(depth)
        qs_children = []

        for i, child in enumerate(node.children):
            child_qs = build(child, depth + 1, position + (i,))
            if child_qs is not None:
                qs_children.append(child_qs)

        if is_pi:
            # Player I: need at least one winning child
            if qs_children:
                return QuasistrategyNode(position=position, children=qs_children, is_winning=True)
            return None
        else:
            # Player II: need ALL children winning (keep all, but check)
            if len(qs_children) == len(node.children):
                return QuasistrategyNode(position=position, children=qs_children, is_winning=True)
            return None

    return build(game_tree, 0, ())


# ============================================================
# Algorithm 3: Ordinal Rank Computation
# ============================================================

def ordinal_rank(node: GameNode) -> int:
    """Compute the ordinal rank of a game tree node.

    For finite trees, the ordinal rank equals the natural number rank:
    - Leaf: rank 0
    - Node: max(child ranks) + 1

    Time complexity: O(|T|)
    """
    if node.is_terminal:
        return 0
    if not node.children:
        return 0
    return max(ordinal_rank(child) for child in node.children) + 1


def rank_hierarchy(node: GameNode) -> Dict[int, int]:
    """Compute the rank distribution: how many nodes at each rank level.

    Returns a dictionary mapping rank → count.
    """
    distribution: Dict[int, int] = {}

    def traverse(n: GameNode) -> None:
        r = ordinal_rank(n)
        distribution[r] = distribution.get(r, 0) + 1
        for child in n.children:
            traverse(child)

    traverse(node)
    return distribution


# ============================================================
# Algorithm 4: Strategy Composition
# ============================================================

def compose_strategies(
    sigma1: Strategy, sigma2: Strategy, switch_point: int
) -> Strategy:
    """Compose two strategies with a switch point.

    Uses sigma1 for histories shorter than switch_point,
    sigma2 for longer histories.

    Theorem (compose_eq_first): For |h| < n, compose(σ₁, σ₂, n)(h) = σ₁(h).
    Theorem (compose_eq_second): For |h| ≥ n, compose(σ₁, σ₂, n)(h) = σ₂(h).
    """
    def composed(history: List[int]) -> int:
        if len(history) < switch_point:
            return sigma1(history)
        return sigma2(history)
    return composed


def map_strategy(sigma: Strategy, f: Callable[[int], int]) -> Strategy:
    """Transform a strategy's output through a function."""
    def mapped(history: List[int]) -> int:
        return f(sigma(history))
    return mapped


# ============================================================
# Algorithm 5: Canonical Play Generation
# ============================================================

def build_history(sigma: Strategy, tau: Strategy, n: int) -> List[int]:
    """Build the first n moves of a canonical play.

    Theorem (buildHistory_length): len(build_history(σ, τ, n)) = n.
    """
    history: List[int] = []
    for step in range(n):
        if step % 2 == 0:
            history.append(sigma(list(history)))
        else:
            history.append(tau(list(history)))
    return history


def canonical_play(sigma: Strategy, tau: Strategy, length: int = 100) -> List[int]:
    """Generate the canonical play from two strategies.

    The play at position n is the (n+1)-th element of build_history(σ, τ, n+1).
    """
    return build_history(sigma, tau, length)


def verify_exclusivity(
    sigma: Strategy, tau: Strategy,
    payoff: Callable[[List[int]], bool],
    length: int = 50
) -> Tuple[bool, str]:
    """Verify the exclusivity theorem computationally.

    For any pair (σ, τ), exactly one player wins the canonical play.
    Returns (player_i_wins, explanation).
    """
    play = canonical_play(sigma, tau, length)
    pi_wins = payoff(play)
    winner = "Player I" if pi_wins else "Player II"
    return pi_wins, f"{winner} wins: play = {play[:10]}..."


# ============================================================
# Algorithm 6: Determinacy at Stage n
# ============================================================

def check_determined_at_stage(
    payoff: Callable[[List[int]], bool],
    stage: int,
    num_samples: int = 1000,
    max_val: int = 10
) -> bool:
    """Heuristically check if a game is determined at a given stage.

    Tests whether plays agreeing on the first `stage` moves always
    have the same outcome.
    """
    import random
    random.seed(42)

    for _ in range(num_samples):
        # Generate a random prefix of length `stage`
        prefix = [random.randint(0, max_val) for _ in range(stage)]
        # Generate two random extensions
        ext1 = prefix + [random.randint(0, max_val) for _ in range(20)]
        ext2 = prefix + [random.randint(0, max_val) for _ in range(20)]
        if payoff(ext1) != payoff(ext2):
            return False
    return True


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    # Build a sample game tree
    leaf_w = GameNode(terminal_value=True, label="win")
    leaf_l = GameNode(terminal_value=False, label="lose")

    # Player I chooses between: a winning leaf and a subtree
    subtree = GameNode(children=[leaf_w, leaf_l], label="PII_choice")
    root = GameNode(children=[leaf_w, subtree, leaf_l], label="PI_choice")

    # Minimax
    value = minimax(root)
    print(f"Game value (Player I wins): {value}")
    print(f"Ordinal rank: {ordinal_rank(root)}")

    # Strategy extraction
    val, strat = minimax_with_strategy(root)
    print(f"Winning strategy found: {val}")

    # Quasistrategy
    qs = compute_quasistrategy(root)
    print(f"Quasistrategy exists: {qs is not None}")

    # Canonical play
    sigma: Strategy = lambda h: 0
    tau: Strategy = lambda h: 1
    play = build_history(sigma, tau, 10)
    print(f"Canonical play (σ=0, τ=1): {play}")

    # Determinacy check
    payoff = lambda p: sum(p[:3]) % 2 == 0
    for stage in range(5):
        det = check_determined_at_stage(payoff, stage)
        print(f"Determined at stage {stage}: {det}")
