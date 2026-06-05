#!/usr/bin/env python3
"""
Bayesian Werewolf: Core algorithms for optimal strategy computation.

Type-hinted implementations of the game-theoretic algorithms formalized
in our Lean 4 proofs.
"""
from fractions import Fraction
from functools import lru_cache
from typing import List, Tuple, Optional
import math


# =============================================================================
# Core Game Model
# =============================================================================

class WerewolfState:
    """Immutable game state: (werewolves, villagers)."""

    def __init__(self, w: int, v: int) -> None:
        self.w = w
        self.v = v

    @property
    def total(self) -> int:
        return self.w + self.v

    @property
    def active(self) -> bool:
        return self.w > 0 and self.w < self.v

    @property
    def villagers_win(self) -> bool:
        return self.w == 0 and self.v > 0

    @property
    def werewolves_win(self) -> bool:
        return self.v <= self.w and self.w > 0

    @property
    def wolf_fraction(self) -> float:
        return self.w / self.total if self.total > 0 else 0.0

    def __repr__(self) -> str:
        return f"WerewolfState(w={self.w}, v={self.v})"


# =============================================================================
# Algorithm 1: Exact Win Probability via Markov Chain Absorption
# =============================================================================

@lru_cache(maxsize=None)
def win_probability(w: int, v: int) -> Fraction:
    """Compute exact villager win probability under random elimination.

    Uses the Markov chain recurrence:
        P(0, v) = 1             (v > 0)
        P(w, v) = 0             (w ≥ v, w > 0)
        P(w, v) = w/(w+v) · P(w-1, v-1) + v/(w+v) · P(w, v-2)

    Time complexity: O(w * v)
    Space complexity: O(w * v) with memoization

    Args:
        w: Number of werewolves
        v: Number of villagers

    Returns:
        Exact win probability as a Fraction
    """
    if w == 0:
        return Fraction(1) if v > 0 else Fraction(0)
    if w >= v or v <= 1:
        return Fraction(0)
    n = Fraction(w + v)
    return (Fraction(w) / n) * win_probability(w - 1, v - 1) + \
           (Fraction(v) / n) * win_probability(w, v - 2)


# =============================================================================
# Algorithm 2: Bayesian Posterior Update
# =============================================================================

def bayesian_update(
    priors: List[float],
    likelihoods: List[float],
) -> List[float]:
    """Update werewolf probabilities given new evidence.

    Implements Bayes' rule: P(W_i | E) ∝ P(E | W_i) · P(W_i)

    Args:
        priors: Prior probability of each player being a werewolf
        likelihoods: P(evidence | player i is werewolf) for each player

    Returns:
        Posterior probabilities (normalized)
    """
    n = len(priors)
    assert len(likelihoods) == n, "Priors and likelihoods must have same length"

    unnormalized = [p * l for p, l in zip(priors, likelihoods)]
    total = sum(unnormalized)

    if total == 0:
        return [1.0 / n] * n  # Uniform fallback

    return [u / total for u in unnormalized]


# =============================================================================
# Algorithm 3: Information Advantage Computation
# =============================================================================

def information_advantage(w: int, v: int) -> float:
    """Compute the information advantage ratio: 1 / P(w, v).

    This measures how many times more likely perfect-information players
    are to win compared to random-elimination players.

    Args:
        w: Number of werewolves
        v: Number of villagers

    Returns:
        Information advantage ratio (≥ 1 for winnable games)
    """
    p = win_probability(w, v)
    if p == 0:
        return float('inf')
    return float(Fraction(1) / p)


# =============================================================================
# Algorithm 4: Wolf Fraction Trajectory
# =============================================================================

def wolf_fraction_trajectory(
    w: int, v: int, outcomes: List[bool]
) -> List[float]:
    """Compute wolf fraction after each round.

    Args:
        w: Initial werewolves
        v: Initial villagers
        outcomes: True = correct vote (wolf eliminated), False = incorrect

    Returns:
        List of wolf fractions after each round (including initial)
    """
    trajectory = [w / (w + v) if w + v > 0 else 0.0]

    for correct in outcomes:
        if correct:
            w -= 1
            v -= 1  # night kill
        else:
            v -= 2  # wrong vote + night kill

        if w + v > 0:
            trajectory.append(w / (w + v))
        else:
            trajectory.append(0.0)

        if w <= 0 or w >= v:
            break

    return trajectory


# =============================================================================
# Algorithm 5: Perfect Play Trajectory
# =============================================================================

def perfect_play_trajectory(k: int, v0: int) -> List[Tuple[int, int]]:
    """Generate the game state trajectory under perfect play.

    Under perfect play, each round:
    1. Day: correctly eliminate one werewolf
    2. Night: werewolves kill one villager

    Args:
        k: Number of werewolves
        v0: Number of initial villagers

    Returns:
        List of (wolves, villagers) states from start to villager victory
    """
    assert 2 * k < k + v0, "Need 2k < n for villagers to win"

    trajectory = [(k, v0)]
    w, v = k, v0

    for _ in range(k):
        w -= 1  # day: eliminate wolf
        v -= 1  # night: lose villager
        trajectory.append((w, v))

    return trajectory


# =============================================================================
# Algorithm 6: Configuration Counting
# =============================================================================

def werewolf_configs(n: int, k: int) -> int:
    """Number of possible werewolf configurations: C(n, k)."""
    return math.comb(n, k)


def configs_after_elimination(
    n: int, k: int, correct: bool
) -> Tuple[int, int]:
    """Configuration count after one elimination.

    Args:
        n: Current total players
        k: Current werewolves
        correct: True if a werewolf was eliminated

    Returns:
        (new_configs, new_n) tuple
    """
    if correct:
        return math.comb(n - 1, k - 1), n - 1
    else:
        return math.comb(n - 1, k), n - 1


# =============================================================================
# Algorithm 7: BFT Threshold Analysis
# =============================================================================

def bft_analysis(n: int, k: int) -> dict:
    """Analyze the game state relative to the BFT threshold.

    The Byzantine Fault Tolerance threshold is w/n > 1/3.
    Below this threshold, the game is in the "safe zone."
    Above it, a single incorrect vote can be fatal.

    Args:
        n: Total players
        k: Werewolves

    Returns:
        Dictionary with threshold analysis results
    """
    v = n - k
    return {
        "n": n,
        "k": k,
        "v": v,
        "wolf_fraction": k / n if n > 0 else 0,
        "bft_threshold": 1 / 3,
        "in_safe_zone": 3 * k < n,
        "in_critical_zone": v <= 2 * k,
        "margin": v - 2 * k,
        "rounds_to_crisis": max(0, (v - 2 * k) // 2) if k > 0 else v,
    }


if __name__ == "__main__":
    # Demo: compute and display key results
    print("Win Probabilities:")
    for w, v in [(1, 2), (1, 4), (2, 5), (3, 8)]:
        p = win_probability(w, v)
        print(f"  P({w},{v}) = {p} ≈ {float(p):.4f}")

    print("\nInformation Advantages:")
    for w, v in [(1, 2), (2, 5), (3, 8)]:
        adv = information_advantage(w, v)
        print(f"  Advantage({w},{v}) = {adv:.2f}x")

    print("\nPerfect Play (k=2, v=5):")
    for state in perfect_play_trajectory(2, 5):
        print(f"  {state}")

    print("\nBFT Analysis (n=7, k=2):")
    analysis = bft_analysis(7, 2)
    for key, value in analysis.items():
        print(f"  {key}: {value}")
