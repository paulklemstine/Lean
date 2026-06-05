#!/usr/bin/env python3
"""
Bayesian Werewolf: Core Algorithms
===================================

Type-hinted implementations of the key algorithms for computing
optimal strategies in Werewolf/Mafia social deduction games.
"""

from fractions import Fraction
from typing import Dict, Tuple, List, Optional
from dataclasses import dataclass
import math


@dataclass(frozen=True)
class GameState:
    """State of a Werewolf game: (wolves, villagers) remaining."""
    wolves: int
    villagers: int

    @property
    def total(self) -> int:
        return self.wolves + self.villagers

    @property
    def is_terminal(self) -> bool:
        return self.wolves == 0 or self.villagers <= self.wolves

    @property
    def villagers_win(self) -> bool:
        return self.wolves == 0

    @property
    def wolves_win(self) -> bool:
        return self.villagers <= self.wolves and self.wolves > 0

    def elim_wolf(self) -> 'GameState':
        return GameState(self.wolves - 1, self.villagers)

    def elim_villager(self) -> 'GameState':
        return GameState(self.wolves, self.villagers - 1)

    def night_kill(self) -> 'GameState':
        return GameState(self.wolves, self.villagers - 1)


@dataclass
class SuspicionProfile:
    """
    A suspicion profile assigns each player a posterior probability
    of being a werewolf. Probabilities must sum to k (expected wolves).
    """
    suspicions: List[Fraction]
    k: int

    def __post_init__(self):
        assert all(0 <= s <= 1 for s in self.suspicions), \
            "Suspicions must be in [0, 1]"
        total = sum(self.suspicions)
        assert total == self.k, \
            f"Suspicions must sum to {self.k}, got {total}"

    @classmethod
    def uniform(cls, n: int, k: int) -> 'SuspicionProfile':
        """Create uniform suspicion: each player has probability k/n."""
        return cls([Fraction(k, n)] * n, k)

    @property
    def max_suspicion(self) -> Fraction:
        return max(self.suspicions) if self.suspicions else Fraction(0)

    @property
    def min_suspicion(self) -> Fraction:
        return min(self.suspicions) if self.suspicions else Fraction(0)

    @property
    def entropy(self) -> float:
        """Shannon entropy of the suspicion distribution (normalized)."""
        if not self.suspicions or self.k == 0:
            return 0.0
        probs = [float(s / self.k) for s in self.suspicions if s > 0]
        return -sum(p * math.log2(p) for p in probs)

    def bayesian_update(self, likelihoods: List[Fraction]) -> 'SuspicionProfile':
        """
        Update suspicions using Bayes' theorem with given likelihood ratios.

        P(wolf_i | evidence) ∝ P(evidence | wolf_i) * P(wolf_i)
        """
        assert len(likelihoods) == len(self.suspicions)
        unnorm = [s * l for s, l in zip(self.suspicions, likelihoods)]
        total = sum(unnorm)
        if total == 0:
            return self
        normalized = [u * self.k / total for u in unnorm]
        return SuspicionProfile(normalized, self.k)


def exact_survival_value(
    state: GameState,
    strategy: str = "random",
    alpha: Fraction = Fraction(0),
    memo: Optional[Dict] = None
) -> Fraction:
    """
    Compute the exact rational survival probability for villagers.

    Algorithm:
        1. Check terminal conditions
        2. Compute wolf-elimination probability based on strategy
        3. Recursively compute values for wolf-eliminated and villager-eliminated branches
        4. Return weighted sum

    Time complexity: O(w * v) with memoization
    Space complexity: O(w * v) for memo table
    """
    if memo is None:
        memo = {}
    key = (state, strategy, alpha)
    if key in memo:
        return memo[key]

    if state.wolves == 0:
        return Fraction(1)
    if state.villagers <= state.wolves:
        return Fraction(0)

    # Strategy-dependent wolf elimination probability
    if strategy == "random":
        p = Fraction(state.wolves, state.total)
    elif strategy == "perfect":
        p = Fraction(1)
    elif strategy == "skilled":
        p = alpha + (1 - alpha) * Fraction(state.wolves, state.total)
    else:
        raise ValueError(f"Unknown strategy: {strategy}")

    # Day: wolf eliminated
    day_wolf = state.elim_wolf()
    if day_wolf.wolves == 0:
        after_wolf = Fraction(1)
    else:
        night = day_wolf.night_kill()
        if night.villagers <= night.wolves:
            after_wolf = Fraction(0)
        else:
            after_wolf = exact_survival_value(
                night, strategy, alpha, memo)

    # Day: villager eliminated
    day_vill = state.elim_villager()
    if day_vill.villagers <= day_vill.wolves:
        after_vill = Fraction(0)
    else:
        night = day_vill.night_kill()
        if night.villagers <= night.wolves:
            after_vill = Fraction(0)
        else:
            after_vill = exact_survival_value(
                night, strategy, alpha, memo)

    result = p * after_wolf + (1 - p) * after_vill
    memo[key] = result
    return result


def compute_game_table(
    max_wolves: int = 5,
    max_villagers: int = 15
) -> Dict[Tuple[int, int], Dict[str, Fraction]]:
    """
    Compute a table of survival values for all (w, v) states.

    Returns dictionary mapping (w, v) to {strategy: value}.
    """
    table: Dict[Tuple[int, int], Dict[str, Fraction]] = {}
    for w in range(1, max_wolves + 1):
        for v in range(w + 1, max_villagers + 1):
            state = GameState(w, v)
            table[(w, v)] = {
                "random": exact_survival_value(state, "random"),
                "perfect": exact_survival_value(state, "perfect"),
            }
    return table


def information_gap(w: int, v: int) -> Fraction:
    """
    Compute the information gap: V_perfect - V_random.

    This measures how much information is worth in the game.
    """
    state = GameState(w, v)
    return (exact_survival_value(state, "perfect") -
            exact_survival_value(state, "random"))


def optimal_vote_target(profile: SuspicionProfile) -> int:
    """
    Given a suspicion profile, return the index of the player
    with the highest posterior probability of being a wolf.

    This is the optimal Bayesian strategy: vote for the most suspicious player.
    """
    if not profile.suspicions:
        return -1
    return max(range(len(profile.suspicions)),
               key=lambda i: profile.suspicions[i])


def simulate_bayesian_game(
    n: int,
    k: int,
    num_simulations: int = 100000
) -> float:
    """
    Monte Carlo simulation of a Werewolf game with Bayesian villagers.

    In each game:
    - Wolves are randomly assigned
    - Each day, villagers vote for the most suspicious player
      (using a simple frequency-based heuristic)
    - Each night, wolves randomly eliminate a villager

    Returns estimated villager win probability.
    """
    import random

    wins = 0
    for _ in range(num_simulations):
        # Assign wolves randomly
        players = list(range(n))
        wolves = set(random.sample(players, k))
        alive = set(players)

        villager_won = False
        while True:
            # Check terminal conditions
            alive_wolves = wolves & alive
            alive_villagers = alive - wolves
            if not alive_wolves:
                villager_won = True
                break
            if len(alive_wolves) >= len(alive_villagers):
                break

            # Day vote: random (no information in simple model)
            target = random.choice(list(alive))
            alive.discard(target)

            # Check again
            alive_wolves = wolves & alive
            alive_villagers = alive - wolves
            if not alive_wolves:
                villager_won = True
                break
            if len(alive_wolves) >= len(alive_villagers):
                break

            # Night kill: wolves eliminate random villager
            if alive_villagers:
                victim = random.choice(list(alive_villagers))
                alive.discard(victim)

        if villager_won:
            wins += 1

    return wins / num_simulations


if __name__ == "__main__":
    # Print game table
    table = compute_game_table(4, 10)
    print("Game Value Table (Random Strategy)")
    print("-" * 50)
    for (w, v), values in sorted(table.items()):
        r = values["random"]
        print(f"  ({w},{v:2d}): {r} ≈ {float(r):.6f}")

    # Monte Carlo validation
    print("\nMonte Carlo Validation (100k games each)")
    print("-" * 50)
    for n, k in [(5, 1), (7, 2), (9, 3), (10, 2)]:
        v = n - k
        exact = float(exact_survival_value(GameState(k, v)))
        simulated = simulate_bayesian_game(n, k, 100000)
        print(f"  n={n}, k={k}: exact={exact:.4f}, simulated={simulated:.4f}, "
              f"error={abs(exact-simulated):.4f}")
