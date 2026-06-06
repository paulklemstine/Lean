#!/usr/bin/env python3
"""
Asymmetric Duration Games: Core Algorithms
Type-hinted implementations of all key strategies and game mechanics.
"""

from typing import FrozenSet, Set, Callable, Tuple, List, Optional
from dataclasses import dataclass


# ============================================================
# Type Aliases
# ============================================================
BannedSet = FrozenSet[int]
MortalStrategy = Callable[[Set[int]], int]
EternityStrategy = Callable[[Set[int], int], int]


# ============================================================
# Core Strategies
# ============================================================

def ascending_strategy(banned: Set[int]) -> int:
    """The ascending strategy: always pick above the maximum banned value.
    
    Theorem: This strategy is safe (never picks a banned position)
    and achieves ω-survival (survives any finite number of rounds).
    
    Time complexity: O(|banned|) per round.
    Space complexity: O(1) additional (beyond the banned set).
    """
    if not banned:
        return 0
    return max(banned) + 1


def cardinality_strategy(banned: Set[int]) -> int:
    """The cardinality strategy: pick |banned| as position.
    
    Theorem: This strategy is finite-state (depends only on |banned|).
    Note: NOT always safe — fails if |banned| ∈ banned.
    """
    return len(banned)


def spread_strategy(lane: int, k: int) -> MortalStrategy:
    """k-lane spread strategy: play ascending in region [lane * stride, ...].
    
    Used for k-player coalition games.
    """
    def strategy(banned: Set[int]) -> int:
        stride = 1000  # Large separation between lanes
        local_banned = {x for x in banned if x >= lane * stride}
        if not local_banned:
            return lane * stride
        return max(local_banned) + 1
    return strategy


# ============================================================
# Game Engine
# ============================================================

@dataclass
class GameResult:
    """Result of playing an evasion game."""
    mortal_moves: List[int]
    eternity_bans: List[int]
    survived: bool
    rounds_played: int
    final_banned_set: Set[int]


def play_evasion_game(
    mortal: MortalStrategy,
    eternity: EternityStrategy,
    n_rounds: int
) -> GameResult:
    """Play the standard evasion game for n rounds.
    
    Each round:
    1. Mortal picks a position based on the current banned set
    2. If the position is banned, Mortal loses
    3. Eternity bans a new position based on the banned set and Mortal's choice
    """
    banned: Set[int] = set()
    mortal_moves: List[int] = []
    eternity_bans: List[int] = []
    
    for i in range(n_rounds):
        pos = mortal(banned)
        mortal_moves.append(pos)
        if pos in banned:
            return GameResult(mortal_moves, eternity_bans, False, i, banned)
        ban = eternity(banned, pos)
        eternity_bans.append(ban)
        banned.add(ban)
    
    return GameResult(mortal_moves, eternity_bans, True, n_rounds, banned)


def play_power_evasion_game(
    mortal: MortalStrategy,
    eternity_power: Callable[[Set[int], int], List[int]],
    n_rounds: int
) -> GameResult:
    """Play with k-power Eternity (bans multiple positions per round).
    
    Theorem: The ascending strategy survives against any k-power Eternity.
    """
    banned: Set[int] = set()
    mortal_moves: List[int] = []
    all_bans: List[int] = []
    
    for i in range(n_rounds):
        pos = mortal(banned)
        mortal_moves.append(pos)
        if pos in banned:
            return GameResult(mortal_moves, all_bans, False, i, banned)
        new_bans = eternity_power(banned, pos)
        all_bans.extend(new_bans)
        banned.update(new_bans)
    
    return GameResult(mortal_moves, all_bans, True, n_rounds, banned)


# ============================================================
# Survival Verification
# ============================================================

def verify_omega_survival(
    mortal: MortalStrategy,
    eternity: EternityStrategy,
    max_n: int = 1000
) -> Tuple[bool, int]:
    """Verify ω-survival up to max_n rounds.
    
    Returns (all_survived, max_rounds_tested).
    """
    for n in range(1, max_n + 1):
        result = play_evasion_game(mortal, eternity, n)
        if not result.survived:
            return False, n
    return True, max_n


def verify_omega_squared_survival(
    mortal: MortalStrategy,
    eternity: EternityStrategy,
    max_m: int = 50,
    max_n: int = 50
) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """Verify ω²-survival: check survival for m*n rounds for all m,n ≤ max.
    
    Returns (all_survived, first_failure or None).
    """
    for m in range(1, max_m + 1):
        for n in range(1, max_n + 1):
            result = play_evasion_game(mortal, eternity, m * n)
            if not result.survived:
                return False, (m, n)
    return True, None


# ============================================================
# Strategy Analysis
# ============================================================

def is_finite_state(mortal: MortalStrategy, test_size: int = 100) -> bool:
    """Test if a strategy is finite-state (depends only on |banned|).
    
    Checks by comparing outputs on sets of the same cardinality.
    """
    import itertools
    for card in range(1, min(test_size, 5)):
        outputs: Set[int] = set()
        for combo in itertools.combinations(range(min(test_size, 15)), card):
            banned = set(combo)
            outputs.add(mortal(banned))
        if len(outputs) > 1:
            return False
    return True


def strategy_growth_rate(mortal: MortalStrategy, n_rounds: int = 100) -> List[int]:
    """Measure how the strategy's chosen positions grow over rounds.
    
    Uses a "worst-case" Eternity (bans Mortal's position) to maximize growth.
    """
    banned: Set[int] = set()
    positions: List[int] = []
    
    for _ in range(n_rounds):
        pos = mortal(banned)
        positions.append(pos)
        banned.add(pos)  # Ban Mortal's position (worst case for growth)
    
    return positions


# ============================================================
# Ordinal Game Value Computation
# ============================================================

def compute_finite_game_value(k: int) -> int:
    """Compute the exact game value on Fin(k).
    
    On Fin(k), the game value is exactly k: Mortal can visit each
    position once, then all positions are banned.
    """
    return k


def compute_survival_hierarchy(max_level: int = 5) -> dict:
    """Compute the survival hierarchy up to the given level.
    
    Level 0: ω (any finite n)
    Level 1: ω·k (for fixed k)
    Level 2: ω² (all finite products)
    """
    hierarchy = {}
    for level in range(max_level):
        if level == 0:
            hierarchy[level] = "ω (any finite n)"
        elif level == 1:
            hierarchy[level] = "ω·k (k-fold composition)"
        else:
            hierarchy[level] = f"ω^{level} ({level}-fold products)"
    return hierarchy


if __name__ == "__main__":
    import random
    random.seed(42)
    
    # Verify ascending strategy
    def random_eternity(banned: Set[int], pos: int) -> int:
        return random.randint(0, pos + 10)
    
    print("Verifying ω-survival of ascending strategy...")
    ok, n = verify_omega_survival(ascending_strategy, random_eternity, 500)
    print(f"  Result: {'PASS' if ok else 'FAIL'} up to n={n}")
    
    print("\nVerifying ω²-survival...")
    ok, fail = verify_omega_squared_survival(ascending_strategy, random_eternity, 20, 20)
    print(f"  Result: {'PASS' if ok else f'FAIL at {fail}'}")
    
    print("\nFinite-state check:")
    print(f"  ascending_strategy: {is_finite_state(ascending_strategy)}")
    print(f"  cardinality_strategy: {is_finite_state(cardinality_strategy)}")
    
    print("\nGrowth rate (ascending, 20 rounds):")
    print(f"  {strategy_growth_rate(ascending_strategy, 20)}")
    
    print("\nSurvival hierarchy:")
    for level, desc in compute_survival_hierarchy().items():
        print(f"  Level {level}: {desc}")
    
    print("\nFinite game values:")
    for k in [3, 5, 10, 100]:
        print(f"  Fin({k}): value = {compute_finite_game_value(k)}")
