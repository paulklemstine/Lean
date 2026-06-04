#!/usr/bin/env python3
"""
Algorithms for Bayesian Werewolf / Elimination Game Theory

Type-hinted implementations of the core algorithms:
1. Exact win probability computation (dynamic programming)
2. Accuracy-parameterized win probability
3. Bayesian posterior update for werewolf identification
4. Monte Carlo simulation for empirical validation
"""

from fractions import Fraction
from functools import lru_cache
from typing import Dict, List, Optional, Tuple
import random


# ===========================================================
# Algorithm 1: Exact Win Probability (Dynamic Programming)
# ===========================================================

@lru_cache(maxsize=None)
def wolf_prob_exact(v: int, w: int) -> Fraction:
    """
    Compute the exact villager win probability under random day voting.
    
    Algorithm: Backward induction on the game tree.
    Time complexity: O(v * w) with memoization.
    Space complexity: O(v * w) for the memoization table.
    
    Args:
        v: Number of villagers remaining
        w: Number of werewolves remaining
    
    Returns:
        Exact win probability as a Fraction
    """
    if w == 0:
        return Fraction(1)
    if v <= w:
        return Fraction(0)
    
    total = v + w
    p_wolf = Fraction(w, total)
    p_vill = Fraction(v, total)
    
    # After eliminating a werewolf
    if w == 1:
        after_wolf = Fraction(1)
    else:
        after_wolf = wolf_prob_exact(v - 1, w - 1)
    
    # After eliminating a villager
    if w >= v - 1 or w >= v - 2:
        after_vill = Fraction(0)
    else:
        after_vill = wolf_prob_exact(v - 2, w)
    
    return p_wolf * after_wolf + p_vill * after_vill


# ===========================================================
# Algorithm 2: APEG Win Probability
# ===========================================================

@lru_cache(maxsize=None)
def apeg_win_prob(v: int, w: int, p_num: int, p_den: int) -> Fraction:
    """
    Win probability in an Accuracy-Parameterized Elimination Game.
    
    Uses fixed accuracy p = p_num/p_den across all rounds.
    
    Args:
        v: Number of villagers
        w: Number of werewolves  
        p_num, p_den: Numerator and denominator of accuracy p
    
    Returns:
        Win probability as Fraction
    """
    p = Fraction(p_num, p_den)
    
    if w == 0:
        return Fraction(1)
    if v <= w:
        return Fraction(0)
    
    if w == 1:
        after_wolf = Fraction(1)
    elif v <= w - 1:
        after_wolf = Fraction(0)
    else:
        after_wolf = apeg_win_prob(v - 1, w - 1, p_num, p_den)
    
    if w >= v - 1 or w >= v - 2:
        after_vill = Fraction(0)
    else:
        after_vill = apeg_win_prob(v - 2, w, p_num, p_den)
    
    return p * after_wolf + (1 - p) * after_vill


# ===========================================================
# Algorithm 3: Bayesian Posterior Update
# ===========================================================

class BayesianWerewolfTracker:
    """
    Maintains Bayesian posterior probabilities for each player being a werewolf.
    
    The tracker updates beliefs based on:
    - Survival (werewolves are never killed at night)
    - Voting patterns (werewolves tend to vote for villagers)
    - Elimination outcomes (if someone is revealed as werewolf/villager)
    """
    
    def __init__(self, n: int, k: int):
        """
        Initialize tracker for n players with k werewolves.
        
        Args:
            n: Total number of players
            k: Number of werewolves
        """
        self.n = n
        self.k = k
        self.alive: List[bool] = [True] * n
        self.revealed_wolf: List[bool] = [False] * n
        self.revealed_villager: List[bool] = [False] * n
        # Prior probability of being a werewolf
        self.posterior: List[float] = [k / n] * n
    
    def update_on_night_kill(self, victim: int) -> None:
        """
        Update posteriors when a player is killed at night.
        The victim is definitely a villager (werewolves choose victims).
        
        Args:
            victim: Index of the killed player
        """
        self.alive[victim] = False
        self.revealed_villager[victim] = True
        self.posterior[victim] = 0.0
        
        # Surviving players' posteriors increase (one less villager in pool)
        alive_unrevealed = [
            i for i in range(self.n)
            if self.alive[i] and not self.revealed_wolf[i] and not self.revealed_villager[i]
        ]
        remaining_wolves = self.k - sum(self.revealed_wolf)
        remaining_candidates = len(alive_unrevealed)
        
        if remaining_candidates > 0:
            for i in alive_unrevealed:
                self.posterior[i] = remaining_wolves / remaining_candidates
    
    def update_on_day_elimination(self, eliminated: int, is_wolf: bool) -> None:
        """
        Update posteriors when a player is eliminated during the day.
        
        Args:
            eliminated: Index of the eliminated player
            is_wolf: Whether the eliminated player was a werewolf
        """
        self.alive[eliminated] = False
        if is_wolf:
            self.revealed_wolf[eliminated] = True
        else:
            self.revealed_villager[eliminated] = True
        self.posterior[eliminated] = 0.0
        
        alive_unrevealed = [
            i for i in range(self.n)
            if self.alive[i] and not self.revealed_wolf[i]
        ]
        remaining_wolves = self.k - sum(self.revealed_wolf)
        remaining_candidates = len(alive_unrevealed)
        
        if remaining_candidates > 0:
            for i in alive_unrevealed:
                self.posterior[i] = remaining_wolves / remaining_candidates
    
    def get_vote_target(self) -> Optional[int]:
        """
        Return the player with highest posterior probability of being a werewolf.
        This is the Bayesian-optimal voting strategy.
        
        Returns:
            Index of the most-suspected player, or None if game is over
        """
        best_idx = None
        best_prob = -1.0
        
        for i in range(self.n):
            if self.alive[i] and self.posterior[i] > best_prob:
                best_prob = self.posterior[i]
                best_idx = i
        
        return best_idx


# ===========================================================
# Algorithm 4: Monte Carlo Simulation
# ===========================================================

def simulate_game(n: int, k: int, strategy: str = "random") -> bool:
    """
    Simulate a single Werewolf game.
    
    Args:
        n: Total players
        k: Number of werewolves
        strategy: "random" for random voting, "bayesian" for Bayesian optimal
    
    Returns:
        True if villagers win, False if werewolves win
    """
    wolves = set(random.sample(range(n), k))
    alive = set(range(n))
    
    while True:
        alive_wolves = wolves & alive
        alive_villagers = alive - wolves
        
        if len(alive_wolves) == 0:
            return True
        if len(alive_wolves) >= len(alive_villagers):
            return False
        
        # Day phase: vote to eliminate
        if strategy == "random":
            target = random.choice(list(alive))
        else:
            # Bayesian: vote for suspected wolf (simplified - without signals,
            # this is equivalent to random among non-cleared players)
            target = random.choice(list(alive))
        
        alive.discard(target)
        
        # Check win conditions
        alive_wolves = wolves & alive
        alive_villagers = alive - wolves
        if len(alive_wolves) == 0:
            return True
        if len(alive_wolves) >= len(alive_villagers):
            return False
        
        # Night phase: wolves eliminate a villager
        victim = random.choice(list(alive_villagers))
        alive.discard(victim)


def monte_carlo_win_prob(
    n: int, k: int, num_games: int = 100000, strategy: str = "random"
) -> Tuple[float, float]:
    """
    Estimate win probability via Monte Carlo simulation.
    
    Args:
        n: Total players
        k: Number of werewolves
        num_games: Number of games to simulate
        strategy: Voting strategy
    
    Returns:
        Tuple of (estimated probability, standard error)
    """
    wins = sum(simulate_game(n, k, strategy) for _ in range(num_games))
    p_hat = wins / num_games
    se = (p_hat * (1 - p_hat) / num_games) ** 0.5
    return p_hat, se


# ===========================================================
# Algorithm 5: Information Value Computation
# ===========================================================

def information_value(v: int, w: int, accuracy: Fraction) -> Fraction:
    """
    Compute the marginal value of information: the difference in win probability
    between playing with the given accuracy vs random play.
    
    Args:
        v: Number of villagers
        w: Number of werewolves
        accuracy: Day-vote accuracy (probability of eliminating werewolf)
    
    Returns:
        Win probability improvement over random play
    """
    random_prob = wolf_prob_exact(v, w)
    informed_prob = apeg_win_prob(v, w, accuracy.numerator, accuracy.denominator)
    return informed_prob - random_prob


def threshold_accuracy(v: int, w: int, target: Fraction = Fraction(1, 2)) -> float:
    """
    Find the minimum accuracy needed to achieve a target win probability.
    Uses binary search.
    
    Args:
        v: Number of villagers
        w: Number of werewolves
        target: Target win probability (default 50%)
    
    Returns:
        Minimum accuracy as float
    """
    lo, hi = 0.0, 1.0
    for _ in range(100):
        mid = (lo + hi) / 2
        mid_frac = Fraction(mid).limit_denominator(10000)
        wp = apeg_win_prob(v, w, mid_frac.numerator, mid_frac.denominator)
        if wp < target:
            lo = mid
        else:
            hi = mid
    return (lo + hi) / 2


if __name__ == "__main__":
    # Verify exact computation matches Monte Carlo
    print("Verification: Exact vs Monte Carlo")
    print("-" * 50)
    
    for v, w in [(2, 1), (4, 1), (5, 2), (7, 2)]:
        exact = float(wolf_prob_exact(v, w))
        mc, se = monte_carlo_win_prob(v + w, w, 50000)
        print(f"  ({v}v, {w}w): exact={exact:.4f}, MC={mc:.4f} ± {se:.4f}")
    
    print("\nInformation Value at 50% accuracy:")
    print("-" * 50)
    for v, w in [(5, 2), (7, 2), (10, 3)]:
        iv = information_value(v, w, Fraction(1, 2))
        print(f"  ({v}v, {w}w): ΔP = {float(iv):.4f}")
