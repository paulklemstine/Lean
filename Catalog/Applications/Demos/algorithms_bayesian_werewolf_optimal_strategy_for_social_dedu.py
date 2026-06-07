#!/usr/bin/env python3
"""
Bayesian Werewolf: Core Algorithms

Type-hinted implementations of the key mathematical objects and algorithms
formalized in the Lean 4 proofs.
"""

from fractions import Fraction
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
import math


# ============================================================
# §1. Game State
# ============================================================

@dataclass(frozen=True)
class WerewolfState:
    """A Werewolf game state: (villagers, werewolves)."""
    villagers: int
    werewolves: int

    @property
    def total_players(self) -> int:
        return self.villagers + self.werewolves

    @property
    def wolf_fraction(self) -> Fraction:
        if self.total_players == 0:
            return Fraction(0)
        return Fraction(self.werewolves, self.total_players)

    @property
    def is_game_over(self) -> bool:
        return self.werewolves == 0 or self.werewolves >= self.villagers

    @property
    def villagers_win(self) -> bool:
        return self.werewolves == 0 and self.villagers > 0

    @property
    def wolves_win(self) -> bool:
        return self.werewolves >= self.villagers and self.werewolves > 0

    def after_correct_elimination(self) -> 'WerewolfState':
        """State after eliminating a wolf (day) and losing a villager (night)."""
        return WerewolfState(self.villagers - 1, self.werewolves - 1)

    def after_wrong_elimination(self) -> 'WerewolfState':
        """State after eliminating a villager (day) and losing another (night)."""
        return WerewolfState(self.villagers - 2, self.werewolves)


# ============================================================
# §2. Win Probability (exact rational arithmetic)
# ============================================================

_win_prob_cache: Dict[Tuple[int, int], Fraction] = {}

def win_probability(state: WerewolfState) -> Fraction:
    """Exact win probability under random elimination strategy.

    Algorithm: Dynamic programming on the game tree.
    Complexity: O(v * w) time and space.

    Matches the Lean 4 definition `winProb` exactly.
    """
    key = (state.villagers, state.werewolves)
    if key in _win_prob_cache:
        return _win_prob_cache[key]

    v, w = state.villagers, state.werewolves

    if w == 0:
        result = Fraction(1)
    elif v <= w:
        result = Fraction(0)
    else:
        total = v + w
        # Probability of correctly eliminating a wolf
        p_correct = Fraction(w, total)
        # Probability of incorrectly eliminating a villager
        p_wrong = Fraction(v, total)

        # After correct: remove wolf, night kills villager → (v-1, w-1)
        if w == 1:
            correct_value = Fraction(1)  # Last wolf eliminated
        else:
            correct_value = win_probability(
                WerewolfState(v - 1, w - 1))

        # After wrong: remove villager, night kills another → (v-2, w)
        next_wrong = WerewolfState(v - 2, w)
        if next_wrong.villagers <= next_wrong.werewolves:
            wrong_value = Fraction(0)
        else:
            wrong_value = win_probability(next_wrong)

        result = p_correct * correct_value + p_wrong * wrong_value

    _win_prob_cache[key] = result
    return result


# ============================================================
# §3. Parity Defect
# ============================================================

def parity_defect(v: int, w: int) -> Optional[Fraction]:
    """The parity defect D(v, w) = P(v, w) / P(v+1, w).

    When D > 1, the parity paradox is active: having one fewer
    villager is actually better!

    Returns None if P(v+1, w) = 0.
    """
    p_next = win_probability(WerewolfState(v + 1, w))
    if p_next == 0:
        return None
    return win_probability(WerewolfState(v, w)) / p_next


# ============================================================
# §4. Even-Odd Decomposition
# ============================================================

def even_win_prob(m: int) -> Fraction:
    """E(m) = P(2m, 1): the even subsequence for w=1."""
    return win_probability(WerewolfState(2 * m, 1))

def odd_win_prob(m: int) -> Fraction:
    """O(m) = P(2m+1, 1): the odd subsequence for w=1."""
    return win_probability(WerewolfState(2 * m + 1, 1))


# ============================================================
# §5. Bayesian Update
# ============================================================

@dataclass
class BayesianBelief:
    """Bayesian belief state: probability each player is a werewolf."""
    probs: List[float]

    @classmethod
    def uniform_prior(cls, n: int, k: int) -> 'BayesianBelief':
        """Create uniform prior: each player has probability k/n."""
        return cls(probs=[k / n] * n)

    def update(self, eliminated_idx: int, was_wolf: bool,
               night_killed_idx: int) -> 'BayesianBelief':
        """Update beliefs after a round of play.

        Parameters:
            eliminated_idx: index of player eliminated during day
            was_wolf: whether the eliminated player was a werewolf
            night_killed_idx: index of player killed at night
        """
        n = len(self.probs)
        remaining = [i for i in range(n)
                    if i != eliminated_idx and i != night_killed_idx]

        if was_wolf:
            # Eliminated a wolf: remaining wolves = k-1 among v-1 players
            total_wolf_prob = sum(self.probs[i] for i in remaining)
            if total_wolf_prob > 0:
                new_probs = [self.probs[i] / total_wolf_prob *
                           (total_wolf_prob - self.probs[eliminated_idx])
                           if i in remaining else 0.0
                           for i in range(n)]
            else:
                new_probs = [0.0] * n
        else:
            # Eliminated a villager: remaining wolves = k among v-2 players
            total_wolf_prob = sum(self.probs[i] for i in remaining)
            if total_wolf_prob > 0:
                scale = 1.0 / (1.0 - self.probs[eliminated_idx] -
                              self.probs[night_killed_idx])
                new_probs = [self.probs[i] * scale if i in remaining else 0.0
                           for i in range(n)]
            else:
                new_probs = [0.0] * n

        return BayesianBelief(probs=new_probs)

    @property
    def entropy(self) -> float:
        """Shannon entropy of the belief state."""
        return sum(binary_entropy(p) for p in self.probs)

    def most_suspicious(self, alive: List[int]) -> int:
        """Return the alive player with highest wolf probability."""
        return max(alive, key=lambda i: self.probs[i])


def binary_entropy(p: float) -> float:
    """Binary entropy H(p) = -p log₂(p) - (1-p) log₂(1-p)."""
    if p <= 0 or p >= 1:
        return 0.0
    return -(p * math.log2(p) + (1 - p) * math.log2(1 - p))


# ============================================================
# §6. Information Gain Ratio
# ============================================================

def information_gain_ratio(v: int, w: int, accuracy: float) -> float:
    """How much better than random: accuracy * (v+w) / w.

    Random strategy achieves ratio 1.0.
    Any informed strategy has ratio > 1.0.
    """
    if w == 0 or v + w == 0:
        return 1.0
    return accuracy * (v + w) / w


# ============================================================
# §7. Game Simulation
# ============================================================

def simulate_game(n: int, k: int, strategy: str = "random",
                  rng=None) -> Tuple[bool, List[WerewolfState]]:
    """Simulate a single Werewolf game.

    Parameters:
        n: total players
        k: number of werewolves
        strategy: "random" or "bayesian"
        rng: random number generator (for reproducibility)

    Returns:
        (villagers_won, trajectory of states)
    """
    import random
    if rng is None:
        rng = random.Random()

    v, w = n - k, k
    trajectory = [WerewolfState(v, w)]

    while True:
        state = trajectory[-1]
        if state.is_game_over:
            return state.villagers_win, trajectory

        # Day phase: eliminate a player
        total = state.total_players
        if rng.random() < state.werewolves / total:
            # Hit a wolf
            if state.werewolves == 1:
                trajectory.append(WerewolfState(state.villagers, 0))
                return True, trajectory
            new_state = state.after_correct_elimination()
        else:
            # Hit a villager
            new_state = state.after_wrong_elimination()

        if new_state.is_game_over:
            trajectory.append(new_state)
        else:
            trajectory.append(new_state)


def estimate_win_probability(n: int, k: int,
                             num_games: int = 100000,
                             seed: int = 42) -> float:
    """Monte Carlo estimate of villager win probability."""
    import random
    rng = random.Random(seed)
    wins = sum(1 for _ in range(num_games)
               if simulate_game(n, k, rng=rng)[0])
    return wins / num_games


if __name__ == "__main__":
    # Verify exact values match Lean
    print("Exact win probabilities (matching Lean 4):")
    test_cases = [
        (2, 1, Fraction(1, 3)),
        (3, 1, Fraction(1, 4)),
        (4, 1, Fraction(7, 15)),
        (5, 1, Fraction(3, 8)),
        (6, 1, Fraction(19, 35)),
        (3, 2, Fraction(2, 15)),
        (5, 2, Fraction(8, 35)),
    ]
    for v, w, expected in test_cases:
        actual = win_probability(WerewolfState(v, w))
        status = "✓" if actual == expected else "✗"
        print(f"  P({v}, {w}) = {actual} = {float(actual):.6f}  {status}")

    # Monte Carlo verification
    print("\nMonte Carlo vs Exact (10^5 games each):")
    for v, w in [(5, 1), (5, 2), (7, 2), (7, 3)]:
        exact = float(win_probability(WerewolfState(v, w)))
        mc = estimate_win_probability(v + w, w)
        print(f"  P({v},{w}): exact={exact:.4f}, MC={mc:.4f}, "
              f"error={abs(exact-mc):.4f}")
