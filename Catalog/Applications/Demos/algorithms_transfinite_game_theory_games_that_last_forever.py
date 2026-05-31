"""
Transfinite Game Theory — Core Algorithms

Implements game tree evaluation, determinacy rank computation,
and strategy extraction for finite two-player games.
"""

from typing import Optional, Callable
from dataclasses import dataclass
from enum import Enum


class Player(Enum):
    """Which player moves at a node."""
    I = "I"
    II = "II"


@dataclass
class GameTree:
    """A finite two-player game tree with binary branching.

    Attributes:
        player: Which player moves at this node (None for leaves).
        value: The leaf value (True = Player I wins). None for internal nodes.
        left: Left subtree (None for leaves).
        right: Right subtree (None for leaves).
    """
    player: Optional[Player]
    value: Optional[bool]
    left: Optional['GameTree']
    right: Optional['GameTree']

    @staticmethod
    def leaf(winner: bool) -> 'GameTree':
        """Create a leaf node."""
        return GameTree(player=None, value=winner, left=None, right=None)

    @staticmethod
    def node_I(left: 'GameTree', right: 'GameTree') -> 'GameTree':
        """Create a Player I decision node."""
        return GameTree(player=Player.I, value=None, left=left, right=right)

    @staticmethod
    def node_II(left: 'GameTree', right: 'GameTree') -> 'GameTree':
        """Create a Player II decision node."""
        return GameTree(player=Player.II, value=None, left=left, right=right)

    def is_leaf(self) -> bool:
        return self.player is None


def minimax_value(tree: GameTree) -> bool:
    """Compute the minimax value of a game tree.

    Returns True if Player I wins with optimal play, False otherwise.

    Algorithm: Recursive evaluation following the minimax principle.
    - At Player I nodes: OR of children (I picks the best)
    - At Player II nodes: AND of children (II picks the worst for I)

    Time complexity: O(n) where n = number of nodes.
    """
    if tree.is_leaf():
        assert tree.value is not None
        return tree.value
    left_val = minimax_value(tree.left)
    right_val = minimax_value(tree.right)
    if tree.player == Player.I:
        return left_val or right_val
    else:
        return left_val and right_val


def depth(tree: GameTree) -> int:
    """Compute the depth of a game tree."""
    if tree.is_leaf():
        return 0
    return max(depth(tree.left), depth(tree.right)) + 1


def num_leaves(tree: GameTree) -> int:
    """Count the number of leaves in a game tree."""
    if tree.is_leaf():
        return 1
    return num_leaves(tree.left) + num_leaves(tree.right)


def determinacy_rank(tree: GameTree) -> int:
    """Compute the determinacy rank of a game tree.

    The determinacy rank measures strategic complexity: how deeply the
    tree must be analyzed to determine the winner.

    Key property: the rank increases only when the non-moving player wins,
    requiring verification of all branches. When the moving player wins,
    they can find a winning path without exhaustive analysis.

    Returns:
        Non-negative integer ≤ depth(tree).
    """
    if tree.is_leaf():
        return 0

    lv = minimax_value(tree.left)
    rv = minimax_value(tree.right)
    lr = determinacy_rank(tree.left)
    rr = determinacy_rank(tree.right)

    if tree.player == Player.I:
        if lv or rv:  # Player I wins
            if lv and rv:
                return min(lr, rr)
            elif lv:
                return lr
            else:
                return rr
        else:  # Player II wins, must check both
            return max(lr, rr) + 1
    else:  # Player II's node
        if lv and rv:  # Player I wins, must check both
            return max(lr, rr) + 1
        else:  # Player II wins
            if (not lv) and (not rv):
                return min(lr, rr)
            elif not lv:
                return lr
            else:
                return rr


def swap_tree(tree: GameTree) -> GameTree:
    """Swap the roles of Player I and Player II.

    Negates leaf values and exchanges node types.
    This is an involution: swap(swap(t)) = t.
    """
    if tree.is_leaf():
        return GameTree.leaf(not tree.value)
    if tree.player == Player.I:
        return GameTree.node_II(swap_tree(tree.left), swap_tree(tree.right))
    else:
        return GameTree.node_I(swap_tree(tree.left), swap_tree(tree.right))


def balanced_tree(depth_n: int, leaf_values: list[bool]) -> GameTree:
    """Create a balanced game tree of given depth.

    Args:
        depth_n: Depth of the tree (0 = single leaf).
        leaf_values: List of 2^depth_n boolean leaf values, left to right.

    Returns:
        A balanced GameTree where Player I moves at even depths
        and Player II at odd depths (counting from root).
    """
    if depth_n == 0:
        return GameTree.leaf(leaf_values[0])
    mid = len(leaf_values) // 2
    left = balanced_tree(depth_n - 1, leaf_values[:mid])
    right = balanced_tree(depth_n - 1, leaf_values[mid:])
    if depth_n % 2 == 1:  # Root is at depth 0 (even), children at depth 1 (odd)
        return GameTree.node_I(left, right)
    else:
        return GameTree.node_II(left, right)


def extract_strategy_I(tree: GameTree) -> dict[int, bool]:
    """Extract Player I's optimal strategy as a dict of node_id -> choice.

    Returns a mapping from node indices (pre-order) to choices:
    True = go left, False = go right.
    Only includes Player I's nodes.
    """
    strategy: dict[int, bool] = {}
    counter = [0]

    def traverse(t: GameTree) -> None:
        node_id = counter[0]
        counter[0] += 1
        if t.is_leaf():
            return
        if t.player == Player.I:
            lv = minimax_value(t.left)
            strategy[node_id] = lv  # Go left if left subtree is winning
        traverse(t.left)
        traverse(t.right)

    traverse(tree)
    return strategy


def extract_strategy_II(tree: GameTree) -> dict[int, bool]:
    """Extract Player II's optimal strategy."""
    strategy: dict[int, bool] = {}
    counter = [0]

    def traverse(t: GameTree) -> None:
        node_id = counter[0]
        counter[0] += 1
        if t.is_leaf():
            return
        if t.player == Player.II:
            lv = minimax_value(t.left)
            # Player II goes left if left subtree is losing (for Player I)
            strategy[node_id] = not lv
        traverse(t.left)
        traverse(t.right)

    traverse(tree)
    return strategy


# ---------- Infinite Game Simulation ----------

def simulate_infinite_game(
    strategy_I: Callable[[list[bool]], bool],
    strategy_II: Callable[[list[bool]], bool],
    num_moves: int
) -> list[bool]:
    """Simulate an infinite game for a finite number of moves.

    Args:
        strategy_I: Player I's strategy (history → move).
        strategy_II: Player II's strategy (history → move).
        num_moves: Number of moves to simulate.

    Returns:
        List of moves played.
    """
    history: list[bool] = []
    for n in range(num_moves):
        if n % 2 == 0:
            move = strategy_I(history.copy())
        else:
            move = strategy_II(history.copy())
        history.append(move)
    return history


def is_in_open_set(
    play: list[bool],
    witnesses: dict[tuple[bool, ...], bool]
) -> Optional[int]:
    """Check if a finite play prefix witnesses membership in an open set.

    An open set is defined by a collection of finite prefixes.
    Returns the length of the witnessing prefix, or None.
    """
    for k in range(len(play) + 1):
        prefix = tuple(play[:k])
        if prefix in witnesses and witnesses[prefix]:
            return k
    return None
