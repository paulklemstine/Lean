#!/usr/bin/env python3
"""
Algorithms for Mortality Games: Ordinal Survival Against Transfinite Adversaries
================================================================================

Type-hinted implementations of the key algorithms from the formal framework.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import List, Optional, Tuple, Dict, Set
from enum import Enum


# ============================================================
# Ordinal Arithmetic (below ω²)
# ============================================================

@dataclass(frozen=True, order=True)
class OrdinalBelowOmegaSq:
    """Ordinals below ω² in Cantor normal form: ω·a + b where a, b ∈ ℕ."""
    omega_coeff: int = 0
    finite_part: int = 0

    def __post_init__(self) -> None:
        assert self.omega_coeff >= 0 and self.finite_part >= 0

    @staticmethod
    def zero() -> OrdinalBelowOmegaSq:
        return OrdinalBelowOmegaSq(0, 0)

    @staticmethod
    def from_nat(n: int) -> OrdinalBelowOmegaSq:
        return OrdinalBelowOmegaSq(0, n)

    @staticmethod
    def omega() -> OrdinalBelowOmegaSq:
        return OrdinalBelowOmegaSq(1, 0)

    @staticmethod
    def omega_times(k: int) -> OrdinalBelowOmegaSq:
        return OrdinalBelowOmegaSq(k, 0)

    def is_finite(self) -> bool:
        return self.omega_coeff == 0

    def is_limit(self) -> bool:
        """A limit ordinal has no immediate predecessor."""
        if self.omega_coeff == 0:
            return self.finite_part == 0  # only 0 is a limit among finites (by convention)
        return self.finite_part == 0

    def ordinal_add(self, other: OrdinalBelowOmegaSq) -> OrdinalBelowOmegaSq:
        """Ordinal addition: left addition by finite part is absorbed by ω."""
        if other.omega_coeff > 0:
            if self.omega_coeff == 0:
                return other  # n + (ω·a + b) = ω·a + b
            return OrdinalBelowOmegaSq(
                self.omega_coeff + other.omega_coeff,
                other.finite_part
            )
        return OrdinalBelowOmegaSq(
            self.omega_coeff,
            self.finite_part + other.finite_part
        )

    def ordinal_mul_nat(self, k: int) -> OrdinalBelowOmegaSq:
        """Right-multiply by a natural number: α · k."""
        if k == 0:
            return OrdinalBelowOmegaSq.zero()
        if self.omega_coeff == 0:
            return OrdinalBelowOmegaSq(0, self.finite_part * k)
        # (ω·a + b) · k = ω·a·k + b (last copy keeps the finite part)
        return OrdinalBelowOmegaSq(self.omega_coeff * k, self.finite_part)

    def eternity_number(self) -> OrdinalBelowOmegaSq:
        """The Eternity number: minimum adversarial power to defeat this game."""
        if self.is_finite():
            return self
        return OrdinalBelowOmegaSq.omega()

    def __repr__(self) -> str:
        if self.omega_coeff == 0:
            return str(self.finite_part)
        elif self.omega_coeff == 1 and self.finite_part == 0:
            return "ω"
        elif self.finite_part == 0:
            return f"ω·{self.omega_coeff}"
        elif self.omega_coeff == 1:
            return f"ω+{self.finite_part}"
        return f"ω·{self.omega_coeff}+{self.finite_part}"


# ============================================================
# Game Tree Structures
# ============================================================

class Player(Enum):
    MORTAL = "mortal"
    ETERNITY = "eternity"


@dataclass
class GameNode:
    """A node in a mortality game tree."""
    player: Player
    children: List[GameNode] = field(default_factory=list)

    @staticmethod
    def terminal() -> GameNode:
        """Terminal node: Mortal loses."""
        return GameNode(player=Player.MORTAL, children=[])

    @staticmethod
    def mortal_choice(children: List[GameNode]) -> GameNode:
        """Mortal picks the best child."""
        return GameNode(player=Player.MORTAL, children=children)

    @staticmethod
    def eternity_choice(children: List[GameNode]) -> GameNode:
        """Eternity picks the worst child for Mortal."""
        return GameNode(player=Player.ETERNITY, children=children)


# ============================================================
# Algorithm 1: Minimax Game Value Computation
# ============================================================

def compute_game_value(node: GameNode, memo: Optional[Dict[int, int]] = None) -> int:
    """
    Compute the finite game value of a game tree using minimax.

    Mortal maximizes depth, Eternity minimizes it.

    Time complexity: O(|tree|)
    Space complexity: O(depth) for recursion stack

    Args:
        node: Root of the game tree
        memo: Optional memoization dictionary (by id)

    Returns:
        The minimax game value (number of rounds Mortal survives)
    """
    if memo is None:
        memo = {}

    node_id = id(node)
    if node_id in memo:
        return memo[node_id]

    if not node.children:
        memo[node_id] = 0
        return 0

    child_values = [compute_game_value(c, memo) for c in node.children]

    if node.player == Player.MORTAL:
        result = 1 + max(child_values)
    else:
        result = 1 + min(child_values)

    memo[node_id] = result
    return result


# ============================================================
# Algorithm 2: Survival Ordinal Classification
# ============================================================

def classify_survival(game_values: List[int]) -> Tuple[str, OrdinalBelowOmegaSq]:
    """
    Classify the survival ordinal of a family of games.

    Given a list of finite game values, determine whether the
    survival ordinal is finite or transfinite.

    Algorithm:
    1. If the values are bounded, survival = max value (finite)
    2. If unbounded, survival ≥ ω (Omega Survival Theorem)

    Args:
        game_values: List of game values (one per game in the family)

    Returns:
        Tuple of (classification string, survival ordinal)
    """
    if not game_values:
        return ("EMPTY", OrdinalBelowOmegaSq.zero())

    max_val = max(game_values)

    # Check if the values are bounded
    # (In practice, check if there's a clear growth trend)
    is_bounded = all(v <= max_val for v in game_values)

    # For a truly unbounded family, we'd need infinite values
    # Here we check if the growth is consistent with unboundedness
    if len(game_values) >= 2:
        growth = game_values[-1] - game_values[0]
        if growth > 0 and game_values[-1] >= len(game_values):
            return ("TRANSFINITE (≥ω)", OrdinalBelowOmegaSq.omega())

    return ("FINITE", OrdinalBelowOmegaSq.from_nat(max_val))


# ============================================================
# Algorithm 3: Cantor Normal Form Decomposition
# ============================================================

def cantor_decompose(alpha: OrdinalBelowOmegaSq) -> Tuple[int, int]:
    """
    Decompose an ordinal below ω² into its Cantor normal form.

    Every α < ω² has a unique representation α = ω·a + b
    where a, b are natural numbers.

    This is the game-theoretic decomposition:
    - a = number of transfinite phases
    - b = residual finite rounds

    Args:
        alpha: An ordinal below ω²

    Returns:
        Tuple (a, b) where alpha = ω·a + b
    """
    return (alpha.omega_coeff, alpha.finite_part)


def cantor_compose(a: int, b: int) -> OrdinalBelowOmegaSq:
    """Inverse of cantor_decompose."""
    return OrdinalBelowOmegaSq(a, b)


# ============================================================
# Algorithm 4: Optimal Strategy Extraction
# ============================================================

def extract_mortal_strategy(node: GameNode) -> List[int]:
    """
    Extract Mortal's optimal strategy from a game tree.

    At each Mortal node, pick the child with highest game value.
    At each Eternity node, assume worst case (lowest value child).

    Returns:
        List of child indices representing Mortal's optimal choices
    """
    strategy: List[int] = []
    current = node

    while current.children:
        child_values = [compute_game_value(c) for c in current.children]

        if current.player == Player.MORTAL:
            best_idx = max(range(len(child_values)), key=lambda i: child_values[i])
            strategy.append(best_idx)
            current = current.children[best_idx]
        else:
            worst_idx = min(range(len(child_values)), key=lambda i: child_values[i])
            current = current.children[worst_idx]

    return strategy


# ============================================================
# Algorithm 5: Nondeterministic Survival Computation
# ============================================================

def nondeterministic_survival(
    parallel_values: List[OrdinalBelowOmegaSq]
) -> OrdinalBelowOmegaSq:
    """
    Compute the survival ordinal under k-nondeterministic play.

    Mortal runs k strategies in parallel and survives if ANY survives.
    The survival ordinal is the supremum of individual values.

    Args:
        parallel_values: List of ordinal values for each parallel strategy

    Returns:
        The supremum (maximum) of the values
    """
    if not parallel_values:
        return OrdinalBelowOmegaSq.zero()
    return max(parallel_values)


# ============================================================
# Algorithm 6: Omega-Squared Escalation Check
# ============================================================

def check_escalation(k_max: int) -> List[Tuple[int, OrdinalBelowOmegaSq]]:
    """
    Demonstrate the Omega-Squared Escalation.

    For each k from 0 to k_max, compute ω·k and show how the
    sequence approaches ω².

    Args:
        k_max: Maximum value of k to check

    Returns:
        List of (k, ω·k) pairs
    """
    results = []
    for k in range(k_max + 1):
        value = OrdinalBelowOmegaSq.omega_times(k)
        results.append((k, value))
    return results


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    # Demo: Build a game tree and compute its value
    leaf = GameNode.terminal()
    n1 = GameNode.mortal_choice([leaf])
    n2 = GameNode.mortal_choice([n1, leaf])
    n3 = GameNode.eternity_choice([n2, n1])
    root = GameNode.mortal_choice([n3, n2, n1])

    print(f"Game value: {compute_game_value(root)}")
    print(f"Optimal strategy: {extract_mortal_strategy(root)}")

    # Demo: Survival classification
    values = list(range(1, 101))
    classification, ordinal = classify_survival(values)
    print(f"Classification: {classification}, Ordinal: {ordinal}")

    # Demo: Cantor normal form
    alpha = OrdinalBelowOmegaSq(3, 7)
    a, b = cantor_decompose(alpha)
    print(f"Cantor({alpha}) = ω·{a} + {b}")

    # Demo: Nondeterministic survival
    parallel = [OrdinalBelowOmegaSq.omega(), OrdinalBelowOmegaSq.from_nat(5)]
    print(f"Nondeterministic survival: {nondeterministic_survival(parallel)}")

    # Demo: Escalation
    for k, val in check_escalation(5):
        print(f"  k={k}: ω·{k} = {val}")
