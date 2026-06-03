#!/usr/bin/env python3
"""
Algorithms for Social Deduction Game Analysis

Type-hinted implementations of the core algorithms for computing
win probabilities, parity defects, and game-theoretic quantities.
"""

from fractions import Fraction
from functools import lru_cache
from typing import Dict, List, Tuple, Optional


@lru_cache(maxsize=None)
def win_prob(v: int, w: int) -> Fraction:
    """Compute exact win probability for villagers via dynamic programming.
    
    Uses the recurrence:
        P(v, 0) = 1
        P(v, w) = 0 if w >= v
        P(v, w) = w/(v+w) * [w=1 ? 1 : P(v-1,w-1)]
                + v/(v+w) * [v<=w+2 ? 0 : P(v-2, w)]
    
    Time complexity: O(v * w) with memoization
    Space complexity: O(v * w)
    
    Args:
        v: Number of villagers (non-negative)
        w: Number of werewolves (non-negative)
    
    Returns:
        Exact rational probability that villagers win
    """
    if w == 0:
        return Fraction(1)
    if v <= w:
        return Fraction(0)
    
    total = Fraction(v + w)
    day_werewolf = Fraction(w) / total * (Fraction(1) if w == 1 else win_prob(v - 1, w - 1))
    day_villager = Fraction(0) if v <= w + 2 else Fraction(v) / total * win_prob(v - 2, w)
    
    return day_werewolf + day_villager


def win_prob_table(max_v: int, max_w: int) -> Dict[Tuple[int, int], Fraction]:
    """Compute a table of win probabilities.
    
    Args:
        max_v: Maximum number of villagers
        max_w: Maximum number of werewolves
    
    Returns:
        Dictionary mapping (v, w) -> P(v, w)
    """
    table: Dict[Tuple[int, int], Fraction] = {}
    for v in range(max_v + 1):
        for w in range(max_w + 1):
            table[(v, w)] = win_prob(v, w)
    return table


def parity_defect(v: int, w: int) -> Fraction:
    """Compute the parity defect D(v, w) = P(v, w) / P(v+1, w).
    
    Values > 1 indicate the parity paradox (adding a villager hurts).
    
    Args:
        v: Number of villagers
        w: Number of werewolves
    
    Returns:
        Parity defect ratio (0 if P(v+1, w) = 0)
    """
    denom = win_prob(v + 1, w)
    if denom == 0:
        return Fraction(0)
    return win_prob(v, w) / denom


def find_parity_paradox_instances(max_v: int, max_w: int) -> List[Tuple[int, int, Fraction]]:
    """Find all (v, w) where P(v+1, w) < P(v, w).
    
    Args:
        max_v: Maximum v to check
        max_w: Maximum w to check
    
    Returns:
        List of (v, w, defect) tuples where defect > 1
    """
    instances: List[Tuple[int, int, Fraction]] = []
    for w in range(1, max_w + 1):
        for v in range(w + 2, max_v + 1):
            d = parity_defect(v, w)
            if d > 1:
                instances.append((v, w, d))
    return instances


def verify_skip_two(max_v: int, max_w: int) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """Verify skip-two monotonicity: P(v+2, w) >= P(v, w).
    
    Args:
        max_v: Maximum v to check
        max_w: Maximum w to check
    
    Returns:
        (True, None) if conjecture holds for all tested cases
        (False, (v, w)) giving a counterexample if found
    """
    for w in range(1, max_w + 1):
        for v in range(w + 2, max_v + 1):
            if win_prob(v + 2, w) < win_prob(v, w):
                return False, (v, w)
    return True, None


def verify_diagonal(max_v: int, max_w: int) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """Verify diagonal monotonicity: P(v+1, w-1) >= P(v, w).
    
    Args:
        max_v: Maximum v to check
        max_w: Maximum w to check
    
    Returns:
        (True, None) if conjecture holds
        (False, (v, w)) giving a counterexample if found
    """
    for w in range(2, max_w + 1):
        for v in range(w + 2, max_v + 1):
            if win_prob(v + 1, w - 1) < win_prob(v, w):
                return False, (v, w)
    return True, None


def game_depth(v: int, w: int) -> int:
    """Compute the information-theoretic depth of the game.
    
    Args:
        v: Number of villagers
        w: Number of werewolves
    
    Returns:
        Number of rounds in the longest game path
    """
    if w == 0 or v <= w:
        return 0
    branch_w = 0 if w == 1 else game_depth(v - 1, w - 1)
    branch_v = 0 if v <= w + 2 else game_depth(v - 2, w)
    return 1 + max(branch_w, branch_v)


def expected_rounds(v: int, w: int) -> Fraction:
    """Compute expected number of rounds until game ends.
    
    Uses a similar recurrence to win_prob but tracks expected value.
    
    Args:
        v: Number of villagers
        w: Number of werewolves
    
    Returns:
        Expected number of complete day+night rounds
    """
    if w == 0 or v <= w:
        return Fraction(0)
    
    total = Fraction(v + w)
    
    if w == 1:
        ew = Fraction(0)
    else:
        ew = Fraction(1) + expected_rounds(v - 1, w - 1)
    
    if v <= w + 2:
        ev = Fraction(0)
    else:
        ev = Fraction(1) + expected_rounds(v - 2, w)
    
    return Fraction(w) / total * ew + Fraction(v) / total * ev


if __name__ == "__main__":
    # Quick verification
    print("Win probability table (w=1):")
    for v in range(2, 11):
        print(f"  P({v}, 1) = {win_prob(v, 1)}")
    
    print("\nSkip-two verification (up to v=50, w=10):")
    ok, ce = verify_skip_two(50, 10)
    print(f"  Result: {'HOLDS' if ok else f'FAILS at {ce}'}")
    
    print("\nDiagonal verification (up to v=50, w=10):")
    ok, ce = verify_diagonal(50, 10)
    print(f"  Result: {'HOLDS' if ok else f'FAILS at {ce}'}")
    
    print("\nParity paradox instances (up to v=20, w=5):")
    for v, w, d in find_parity_paradox_instances(20, 5):
        print(f"  ({v},{w}): defect = {d} ≈ {float(d):.4f}")
