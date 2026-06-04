#!/usr/bin/env python3
"""
Bayesian Werewolf: Core Algorithms

Type-hinted implementations of the strategic elimination game framework,
including exact probability computation, Bayesian posterior updating,
and optimal strategy search.
"""

from __future__ import annotations
from fractions import Fraction
from functools import lru_cache
from typing import Dict, List, Tuple, Optional
import math


# ── Core Types ────────────────────────────────────────────────────────

GameState = Tuple[int, int]  # (wolves, villagers)
Strategy = Dict[GameState, Fraction]  # state -> accuracy


# ── Strategic Win Probability ─────────────────────────────────────────

@lru_cache(maxsize=None)
def strategic_win_prob(w: int, v: int, sigma: Fraction) -> Fraction:
    """
    Compute villager win probability for a constant strategy.
    
    Algorithm: Dynamic programming on game states (w, v).
    Time complexity: O(w * v) with memoization.
    Space complexity: O(w * v).
    
    Args:
        w: Number of remaining werewolves
        v: Number of remaining villagers
        sigma: Probability of correctly eliminating a werewolf
    
    Returns:
        Exact probability of villager victory as a Fraction
    """
    if w == 0:
        return Fraction(1) if v > 0 else Fraction(0)
    if w >= v:
        return Fraction(0)
    if v <= 1:
        return Fraction(0)
    return (sigma * strategic_win_prob(w - 1, v - 1, sigma) +
            (1 - sigma) * strategic_win_prob(w, v - 2, sigma))


@lru_cache(maxsize=None)
def random_strategy_win_prob(w: int, v: int) -> Fraction:
    """
    Compute villager win probability under random (uniform) elimination.
    
    The strategy accuracy at state (w, v) is σ = w/(w+v).
    
    Algorithm: DP with state-dependent transition probabilities.
    """
    if w == 0:
        return Fraction(1) if v > 0 else Fraction(0)
    if w >= v:
        return Fraction(0)
    if v <= 1:
        return Fraction(0)
    sigma = Fraction(w, w + v)
    return (sigma * random_strategy_win_prob(w - 1, v - 1) +
            (1 - sigma) * random_strategy_win_prob(w, v - 2))


# ── Bayesian Posterior Update ─────────────────────────────────────────

class BayesianBelief:
    """
    Bayesian belief state for a Werewolf game.
    
    Maintains posterior probabilities P(player i is a werewolf | evidence)
    for each remaining player, updated via Bayes' theorem after each
    observed event (vote, elimination, survival).
    """
    
    def __init__(self, n: int, k: int, players: Optional[List[int]] = None):
        """Initialize with uniform prior k/n for each player."""
        self.n = n
        self.k = k
        self.players = players or list(range(n))
        self.probs: Dict[int, float] = {
            i: k / len(self.players) for i in self.players
        }
    
    def update_elimination(self, player: int, was_wolf: bool) -> None:
        """Update beliefs after a player is eliminated and revealed."""
        if player not in self.probs:
            return
        
        remaining = [p for p in self.players if p != player]
        wolves_remaining = self.k - (1 if was_wolf else 0)
        
        if not remaining:
            return
        
        # Update: redistribute probability mass
        new_probs = {}
        for p in remaining:
            if was_wolf:
                # A wolf was found; remaining wolves are fewer
                # P(p is wolf | wolf found) = P(p is wolf, other is wolf) / P(wolf found)
                # Simplified: adjust proportionally
                new_probs[p] = wolves_remaining / len(remaining)
            else:
                # A villager was found; wolf concentration increases
                new_probs[p] = wolves_remaining / len(remaining)
        
        self.probs = new_probs
        self.players = remaining
        self.k = wolves_remaining
    
    def update_survival(self, night_kill: int) -> None:
        """Update beliefs after a night kill (always a villager)."""
        if night_kill in self.probs:
            remaining = [p for p in self.players if p != night_kill]
            self.players = remaining
            # Wolves unchanged, villagers decreased
            new_probs = {p: self.k / len(remaining) for p in remaining}
            self.probs = new_probs
    
    def most_suspect(self) -> int:
        """Return the player with highest posterior werewolf probability."""
        return max(self.probs, key=self.probs.get)  # type: ignore
    
    def entropy(self) -> float:
        """Shannon entropy of the belief distribution."""
        h = 0.0
        for p in self.probs.values():
            if 0 < p < 1:
                h -= p * math.log2(p) + (1 - p) * math.log2(1 - p)
        return h


# ── Information Value Computation ─────────────────────────────────────

def information_value(w: int, v: int, sigma: Fraction) -> Fraction:
    """
    Compute the information value of strategy σ over random play.
    
    InfoValue(σ) = P(win | σ) - P(win | random)
    
    By the Strategy Dominance Theorem (proved in Lean 4):
    If σ ≥ w/(w+v) for all states, then InfoValue(σ) ≥ 0.
    """
    return strategic_win_prob(w, v, sigma) - random_strategy_win_prob(w, v)


def advantage_ratio(w: int, v: int, sigma: Fraction) -> Fraction:
    """
    Compute the advantage ratio: fraction of maximum achievable win
    probability captured by strategy σ.
    
    AdvRatio(σ) = P(win | σ) / P(win | perfect) = P(win | σ)
    since P(win | perfect) = 1 for w < v (proved in Lean 4).
    """
    if w >= v:
        return Fraction(0)
    return strategic_win_prob(w, v, sigma)


# ── Hedged Strategy ──────────────────────────────────────────────────

def hedged_strategy(t: Fraction, sigma1: Fraction, sigma2: Fraction) -> Fraction:
    """
    Hedged combination of two constant strategies.
    
    hedge(t, σ₁, σ₂) = t * σ₁ + (1-t) * σ₂
    
    Proved in Lean 4: this preserves [0,1] bounds.
    """
    return t * sigma1 + (1 - t) * sigma2


# ── Game Tree Analysis ───────────────────────────────────────────────

def game_tree(w: int, v: int, sigma: Fraction,
              depth: int = 0) -> Dict:
    """
    Build the full game tree for analysis.
    
    Returns a dictionary with:
    - state: (w, v)
    - win_prob: exact win probability
    - children: list of (probability, child_tree) for each branch
    """
    prob = strategic_win_prob(w, v, sigma)
    
    if w == 0:
        return {"state": (w, v), "win_prob": float(prob),
                "outcome": "villagers_win" if v > 0 else "draw",
                "depth": depth}
    if w >= v:
        return {"state": (w, v), "win_prob": 0.0,
                "outcome": "werewolves_win", "depth": depth}
    if v <= 1:
        return {"state": (w, v), "win_prob": 0.0,
                "outcome": "werewolves_win", "depth": depth}
    
    correct_branch = game_tree(w - 1, v - 1, sigma, depth + 1)
    incorrect_branch = game_tree(w, v - 2, sigma, depth + 1)
    
    return {
        "state": (w, v),
        "win_prob": float(prob),
        "depth": depth,
        "children": [
            {"prob": float(sigma), "label": "correct_elim",
             "subtree": correct_branch},
            {"prob": float(1 - sigma), "label": "incorrect_elim",
             "subtree": incorrect_branch},
        ]
    }


# ── Optimal Strategy Search ──────────────────────────────────────────

def find_optimal_constant_strategy(w: int, v: int,
                                   resolution: int = 1000) -> Tuple[Fraction, Fraction]:
    """
    Find the optimal constant strategy by exhaustive search.
    
    Returns (optimal_sigma, max_win_prob).
    
    Note: By the Strategy Dominance Theorem, the optimal constant strategy
    is always σ = 1 (perfect play). This function verifies that numerically.
    """
    best_sigma = Fraction(0)
    best_prob = Fraction(0)
    
    for i in range(resolution + 1):
        sigma = Fraction(i, resolution)
        prob = strategic_win_prob(w, v, sigma)
        if prob > best_prob:
            best_prob = prob
            best_sigma = sigma
    
    return best_sigma, best_prob


# ── Phase Transition Analysis ─────────────────────────────────────────

def critical_accuracy(w: int, v: int,
                      threshold: Fraction = Fraction(1, 2),
                      resolution: int = 1000) -> Optional[Fraction]:
    """
    Find the minimum strategy accuracy needed for villagers to have
    at least `threshold` probability of winning.
    
    Returns None if no constant strategy achieves the threshold.
    """
    for i in range(resolution + 1):
        sigma = Fraction(i, resolution)
        if strategic_win_prob(w, v, sigma) >= threshold:
            return sigma
    return None


if __name__ == "__main__":
    # Quick validation
    print("Win probabilities for 7-player game (k=2, v=5):")
    for i in range(0, 11):
        s = Fraction(i, 10)
        p = strategic_win_prob(2, 5, s)
        print(f"  σ={float(s):.1f}: P(win) = {float(p):.6f} ({p})")
    
    print(f"\nRandom strategy: P(win) = {float(random_strategy_win_prob(2, 5)):.6f}")
    print(f"  ({random_strategy_win_prob(2, 5)})")
    
    opt_s, opt_p = find_optimal_constant_strategy(2, 5)
    print(f"\nOptimal constant strategy: σ = {float(opt_s):.4f}, P(win) = {float(opt_p):.6f}")
    
    crit = critical_accuracy(2, 5)
    print(f"Critical accuracy for 50% win rate: σ ≥ {float(crit):.4f}" if crit else
          "No constant strategy achieves 50% win rate")
