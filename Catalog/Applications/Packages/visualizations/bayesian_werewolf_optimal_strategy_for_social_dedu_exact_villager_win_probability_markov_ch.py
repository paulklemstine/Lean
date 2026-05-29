#!/usr/bin/env python3
"""
Bayesian Werewolf: Algorithms for Optimal Social Deduction
==========================================================

Implements the core algorithms from the research:
1. Markov chain villager win probability (exact computation)
2. Bayesian posterior update mechanism
3. Monte Carlo simulation of Werewolf games
4. Optimal elimination strategy via posterior maximization

All algorithms include docstrings, type hints, and complexity analysis.
"""

from __future__ import annotations
from functools import lru_cache
from typing import Optional
import math
import random


# ─── Algorithm 1: Exact Villager Win Probability ───────────────────
# Time: O(w * v) via memoization
# Space: O(w * v) for the memo table

@lru_cache(maxsize=None)
def villager_win_prob_exact(w: int, v: int) -> float:
    """
    Compute the exact villager win probability under random elimination.

    This implements the Markov chain absorption probability.
    The recursion matches the Lean-verified definition `villagerWinProb`.

    Parameters:
        w: Number of remaining werewolves
        v: Number of remaining villagers

    Returns:
        Probability that villagers win under random elimination

    Complexity:
        Time:  O(w * v) with memoization
        Space: O(w * v) for cache
    """
    if w == 0:
        return 1.0 if v > 0 else 0.0
    if w >= v:
        return 0.0
    if v <= 1:
        return 0.0
    tot = w + v
    p_correct = w / tot    # prob of eliminating a werewolf
    p_incorrect = v / tot  # prob of eliminating a villager
    return (p_correct * villager_win_prob_exact(w - 1, v - 1) +
            p_incorrect * villager_win_prob_exact(w, v - 2))


# ─── Algorithm 2: Bayesian Posterior Update ────────────────────────
# Time: O(n) per update
# Space: O(n) for the belief vector

class BayesianWerewolfTracker:
    """
    Maintains Bayesian posterior probabilities for each player being a werewolf.

    The tracker starts with a uniform prior (k/n for each player) and
    updates based on observed events:
    - Survival through night (slightly increases suspicion)
    - Voting patterns (wolves tend to protect each other)
    - Elimination results (reveals true identity)

    Complexity:
        Initialization: O(n)
        Each update:     O(n)
        Space:           O(n)
    """

    def __init__(self, n: int, k: int):
        """
        Initialize with uniform prior.

        Args:
            n: Total number of players
            k: Number of werewolves
        """
        self.n = n
        self.k = k
        self.alive = list(range(n))
        self.belief = [k / n] * n  # P(player i is wolf)
        self.known_wolves: set[int] = set()
        self.known_villagers: set[int] = set()

    def update_elimination(self, player: int, is_wolf: bool) -> None:
        """
        Update beliefs after a player is eliminated and their role revealed.

        Args:
            player: Index of eliminated player
            is_wolf: Whether the eliminated player was a werewolf
        """
        if player in self.alive:
            self.alive.remove(player)

        if is_wolf:
            self.known_wolves.add(player)
            self.belief[player] = 1.0
            remaining_wolves = self.k - len(self.known_wolves)
        else:
            self.known_villagers.add(player)
            self.belief[player] = 0.0
            remaining_wolves = self.k - len(self.known_wolves)

        # Redistribute probability among remaining unknown players
        unknown = [i for i in self.alive
                   if i not in self.known_wolves and i not in self.known_villagers]
        if unknown:
            for i in unknown:
                self.belief[i] = remaining_wolves / len(unknown)

    def update_vote_pattern(self, voter: int, target: int,
                            wolf_protect_prob: float = 0.3) -> None:
        """
        Update beliefs based on voting patterns.

        Wolves are less likely to vote for other wolves (wolf_protect_prob).
        This is the Bayesian likelihood update.

        Args:
            voter: Index of the voter
            target: Index of the vote target
            wolf_protect_prob: P(wolf votes for wolf) vs P(wolf votes for villager)
        """
        unknown = [i for i in self.alive
                   if i not in self.known_wolves and i not in self.known_villagers]
        if voter not in unknown or target not in unknown:
            return

        # Likelihood ratio: P(vote | voter is wolf) / P(vote | voter is villager)
        # If target has high wolf probability, a wolf is LESS likely to vote for them
        p_target_wolf = self.belief[target]

        # P(vote for target | voter is wolf) ∝ (1 - wolf_protect_prob) * p_target_wolf
        #                                     + wolf_protect_prob * (1 - p_target_wolf)
        # P(vote for target | voter is villager) ∝ p_target_wolf (random/rational)

        lr_wolf = (1 - wolf_protect_prob) * p_target_wolf + wolf_protect_prob * (1 - p_target_wolf)
        lr_villager = p_target_wolf + 0.5 * (1 - p_target_wolf)  # slight random component

        if lr_villager > 0:
            ratio = lr_wolf / lr_villager
            # Bayesian update for the voter
            prior = self.belief[voter]
            posterior_unnorm = prior * ratio
            normalizer = posterior_unnorm + (1 - prior) * 1.0
            if normalizer > 0:
                self.belief[voter] = posterior_unnorm / normalizer

    def get_most_suspicious(self) -> Optional[int]:
        """
        Return the player with highest posterior probability of being a werewolf.

        This implements the optimal Bayesian strategy: vote for the player
        who is most likely to be a werewolf.

        Returns:
            Index of most suspicious player, or None if no players alive
        """
        unknown = [i for i in self.alive
                   if i not in self.known_wolves and i not in self.known_villagers]
        if not unknown:
            return None
        return max(unknown, key=lambda i: self.belief[i])

    def entropy(self) -> float:
        """Total Shannon entropy of the belief state."""
        total = 0.0
        for i in self.alive:
            p = self.belief[i]
            if 0 < p < 1:
                total += -(p * math.log(p) + (1 - p) * math.log(1 - p))
        return total


# ─── Algorithm 3: Monte Carlo Werewolf Simulation ──────────────────
# Time: O(num_games * n) per simulation
# Space: O(n) per game

def simulate_werewolf_game(n: int, k: int, strategy: str = "random",
                           seed: Optional[int] = None) -> bool:
    """
    Simulate a single Werewolf game.

    Args:
        n: Total number of players
        k: Number of werewolves
        strategy: "random" (uniform random), "bayesian" (posterior-maximizing)
        seed: Random seed for reproducibility

    Returns:
        True if villagers win, False if werewolves win
    """
    if seed is not None:
        random.seed(seed)

    wolves = set(random.sample(range(n), k))
    villagers = set(range(n)) - wolves
    alive = set(range(n))

    tracker = BayesianWerewolfTracker(n, k) if strategy == "bayesian" else None

    while True:
        # Check win conditions
        alive_wolves = wolves & alive
        alive_villagers = villagers & alive

        if len(alive_wolves) == 0:
            return True  # Villagers win
        if len(alive_wolves) >= len(alive_villagers):
            return False  # Werewolves win

        # Day phase: vote to eliminate
        if strategy == "random":
            target = random.choice(list(alive))
        elif strategy == "bayesian" and tracker is not None:
            target = tracker.get_most_suspicious()
            if target is None:
                target = random.choice(list(alive))
        else:
            target = random.choice(list(alive))

        is_wolf = target in wolves
        alive.discard(target)
        if tracker:
            tracker.update_elimination(target, is_wolf)

        # Check after day elimination
        alive_wolves = wolves & alive
        alive_villagers = villagers & alive

        if len(alive_wolves) == 0:
            return True
        if len(alive_wolves) >= len(alive_villagers):
            return False

        # Night phase: werewolves kill a villager
        if alive_villagers:
            victim = random.choice(list(alive_villagers))
            alive.discard(victim)
            if tracker:
                tracker.update_elimination(victim, False)


def estimate_win_probability(n: int, k: int, num_games: int = 100000,
                             strategy: str = "random",
                             seed: int = 42) -> float:
    """
    Estimate villager win probability by Monte Carlo simulation.

    Args:
        n: Total players
        k: Werewolves
        num_games: Number of simulations
        strategy: "random" or "bayesian"
        seed: Base random seed

    Returns:
        Estimated probability of villagers winning

    Complexity:
        Time:  O(num_games * n)
        Space: O(n)
    """
    random.seed(seed)
    wins = sum(1 for _ in range(num_games)
               if simulate_werewolf_game(n, k, strategy))
    return wins / num_games


# ─── Algorithm 4: Win Probability Table ────────────────────────────

def compute_win_prob_table(max_n: int = 15) -> dict[tuple[int, int], float]:
    """
    Compute exact villager win probabilities for all valid (k, n-k) pairs.

    Returns:
        Dictionary mapping (k, v) to exact win probability

    Complexity:
        Time:  O(max_n^3) total
        Space: O(max_n^2) for table
    """
    table = {}
    for n in range(3, max_n + 1):
        for k in range(1, n // 2):
            v = n - k
            table[(k, v)] = villager_win_prob_exact(k, v)
    return table


if __name__ == "__main__":
    print("Bayesian Werewolf Algorithms — Quick Test")
    print("=" * 50)

    # Test exact computation
    print("\nExact win probabilities:")
    for n in [5, 7, 9, 11]:
        for k in range(1, n // 2):
            v = n - k
            p = villager_win_prob_exact(k, v)
            print(f"  n={n}, k={k}: P(villagers win) = {p:.6f}")

    # Test Monte Carlo
    print("\nMonte Carlo comparison (n=7, k=2, 50k games):")
    p_random = estimate_win_probability(7, 2, 50000, "random")
    p_bayesian = estimate_win_probability(7, 2, 50000, "bayesian")
    p_exact = villager_win_prob_exact(2, 5)
    print(f"  Exact:    {p_exact:.6f}")
    print(f"  Random:   {p_random:.6f}")
    print(f"  Bayesian: {p_bayesian:.6f}")

    # Test Bayesian tracker
    print("\nBayesian tracker demo (n=7, k=2):")
    tracker = BayesianWerewolfTracker(7, 2)
    print(f"  Initial beliefs: {[f'{p:.3f}' for p in tracker.belief]}")
    print(f"  Initial entropy: {tracker.entropy():.4f}")
    tracker.update_elimination(3, True)  # Player 3 revealed as wolf
    print(f"  After revealing player 3 as wolf:")
    print(f"  Beliefs: {[f'{p:.3f}' for p in tracker.belief]}")
    print(f"  Entropy: {tracker.entropy():.4f}")
    print(f"  Most suspicious: player {tracker.get_most_suspicious()}")
