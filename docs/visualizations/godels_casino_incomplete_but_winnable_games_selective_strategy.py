#!/usr/bin/env python3
"""
Gödel's Casino: Algorithms

Implements the core algorithms from the research paper:
1. Selective Strategy computation
2. Casino simulation with statistical analysis
3. Incompleteness gap calculation
4. Tropical profit computation
5. Decidable fraction profit bound verification
"""

import random
from dataclasses import dataclass
from typing import List, Callable, Tuple, Dict
import math


@dataclass
class CasinoRound:
    """A round in Gödel's Casino with truth value and decidability flag."""
    truth: bool
    is_decidable: bool


@dataclass
class GameResult:
    """Result of a complete casino game."""
    profit: int
    decidable_count: int
    undecidable_count: int
    correct_bets: int
    incorrect_bets: int
    abstentions: int


Strategy = Callable[[CasinoRound], str]


def bet_payoff(truth: bool, bet: str) -> int:
    """
    Compute payoff for a single bet.

    Args:
        truth: The ground truth of the statement
        bet: One of "TRUE", "FALSE", "ABSTAIN"

    Returns:
        +1 for correct bet, -1 for incorrect bet, 0 for abstain
    """
    if bet == "ABSTAIN":
        return 0
    elif bet == "TRUE":
        return 1 if truth else -1
    elif bet == "FALSE":
        return -1 if truth else 1
    raise ValueError(f"Invalid bet: {bet}")


def selective_strategy(round: CasinoRound) -> str:
    """
    The selective strategy: bet correctly on decidable, abstain on undecidable.

    Time complexity: O(1) per round (assumes decidability oracle is constant time)
    Space complexity: O(1)

    This is the optimal strategy proved in Theorem 3.5.
    """
    if round.is_decidable:
        return "TRUE" if round.truth else "FALSE"
    return "ABSTAIN"


def naive_strategy(_round: CasinoRound) -> str:
    """Always bet TRUE. Used as a baseline comparison."""
    return "TRUE"


def random_strategy(_round: CasinoRound) -> str:
    """Random bet between TRUE and FALSE."""
    return random.choice(["TRUE", "FALSE"])


def contrarian_strategy(_round: CasinoRound) -> str:
    """Always bet FALSE. Dual of naive strategy."""
    return "FALSE"


def play_game(strategy: Strategy, rounds: List[CasinoRound]) -> GameResult:
    """
    Play a complete casino game.

    Args:
        strategy: Function mapping rounds to bets
        rounds: List of casino rounds

    Returns:
        GameResult with full statistics

    Time complexity: O(n) where n = len(rounds)
    Space complexity: O(1)
    """
    profit = 0
    decidable_count = 0
    correct = 0
    incorrect = 0
    abstentions = 0

    for r in rounds:
        if r.is_decidable:
            decidable_count += 1
        bet = strategy(r)
        p = bet_payoff(r.truth, bet)
        profit += p
        if p > 0:
            correct += 1
        elif p < 0:
            incorrect += 1
        else:
            abstentions += 1

    return GameResult(
        profit=profit,
        decidable_count=decidable_count,
        undecidable_count=len(rounds) - decidable_count,
        correct_bets=correct,
        incorrect_bets=incorrect,
        abstentions=abstentions
    )


def tropical_optimal_payoff(_round: CasinoRound) -> int:
    """
    Tropical (max-plus) optimal payoff.
    Always returns 1 (Theorem 4.2).

    In the max-plus semiring, this is max(betPayoff(TRUE), betPayoff(FALSE), 0) = 1.
    """
    return 1


def incompleteness_gap(rounds: List[CasinoRound]) -> int:
    """
    Compute the incompleteness gap: |rounds| - decidable_count.

    This is the irreducible cost of incompleteness (Theorem in the paper).
    """
    dec = sum(1 for r in rounds if r.is_decidable)
    return len(rounds) - dec


def decidable_fraction(rounds: List[CasinoRound]) -> float:
    """
    Compute the decidable fraction of a game.

    Returns a value in [0, 1] representing the proportion of decidable rounds.
    """
    if not rounds:
        return 0.0
    dec = sum(1 for r in rounds if r.is_decidable)
    return dec / len(rounds)


def verify_bridge_theorem(rounds: List[CasinoRound]) -> Tuple[int, int, bool]:
    """
    Verify the Tropical-Casino Bridge Theorem:
    selective_profit * |rounds| = decidable_count * tropical_total

    Returns:
        (lhs, rhs, equal)
    """
    sel_profit = play_game(selective_strategy, rounds).profit
    dec_count = sum(1 for r in rounds if r.is_decidable)
    trop_total = sum(tropical_optimal_payoff(r) for r in rounds)

    lhs = sel_profit * len(rounds)
    rhs = dec_count * trop_total
    return lhs, rhs, lhs == rhs


def verify_profit_bound(rounds: List[CasinoRound], k: int) -> Tuple[bool, int, int]:
    """
    Verify the decidable fraction profit bound:
    If k * decidable_count >= |rounds|, then k * selective_profit >= |rounds|.

    Args:
        rounds: Casino game rounds
        k: Bound parameter

    Returns:
        (hypothesis_holds, k_times_profit, n)
    """
    dec_count = sum(1 for r in rounds if r.is_decidable)
    n = len(rounds)
    sel_profit = play_game(selective_strategy, rounds).profit

    hypothesis = k * dec_count >= n
    conclusion = k * sel_profit >= n
    return hypothesis and conclusion == hypothesis, k * sel_profit, n


def simulate_casino(
    n: int,
    decidable_frac: float,
    num_trials: int = 1000,
    adversarial: bool = False
) -> Dict[str, float]:
    """
    Monte Carlo simulation of Gödel's Casino.

    Args:
        n: Number of rounds per game
        decidable_frac: Fraction of rounds that are decidable
        num_trials: Number of games to simulate
        adversarial: If True, undecidable statements are all FALSE

    Returns:
        Dictionary with average profits for each strategy
    """
    results = {
        "selective_avg": 0.0,
        "naive_avg": 0.0,
        "random_avg": 0.0,
        "advantage_avg": 0.0,
        "bridge_verified": 0,
    }

    for _ in range(num_trials):
        rounds = []
        for _ in range(n):
            is_dec = random.random() < decidable_frac
            if adversarial and not is_dec:
                truth = False
            else:
                truth = random.choice([True, False])
            rounds.append(CasinoRound(truth=truth, is_decidable=is_dec))

        sel = play_game(selective_strategy, rounds).profit
        nai = play_game(naive_strategy, rounds).profit
        ran = play_game(random_strategy, rounds).profit

        results["selective_avg"] += sel / num_trials
        results["naive_avg"] += nai / num_trials
        results["random_avg"] += ran / num_trials
        results["advantage_avg"] += (sel - nai) / num_trials

        _, _, verified = verify_bridge_theorem(rounds)
        if verified:
            results["bridge_verified"] += 1

    results["bridge_verified"] /= num_trials  # Convert to fraction
    return results


if __name__ == "__main__":
    print("Gödel's Casino: Algorithm Verification")
    print("=" * 50)

    # Test 1: Bridge theorem
    random.seed(42)
    for _ in range(100):
        n = random.randint(5, 200)
        d = random.random()
        rounds = []
        for _ in range(n):
            rounds.append(CasinoRound(
                truth=random.choice([True, False]),
                is_decidable=random.random() < d
            ))
        lhs, rhs, eq = verify_bridge_theorem(rounds)
        assert eq, f"Bridge theorem failed: {lhs} != {rhs}"
    print("✓ Bridge theorem verified on 100 random instances")

    # Test 2: Profit bound
    for _ in range(100):
        n = random.randint(5, 200)
        d = random.random()
        rounds = []
        for _ in range(n):
            rounds.append(CasinoRound(
                truth=random.choice([True, False]),
                is_decidable=random.random() < d
            ))
        dec = sum(1 for r in rounds if r.is_decidable)
        if dec > 0:
            k = math.ceil(n / dec)
            ok, kp, nn = verify_profit_bound(rounds, k)
            assert ok, f"Profit bound failed: k={k}, profit={kp}, n={nn}"
    print("✓ Profit bound verified on 100 random instances")

    # Test 3: Simulation
    print("\nSimulation results (n=100, 1000 trials):")
    for d in [0.2, 0.5, 0.8]:
        r = simulate_casino(100, d, 1000)
        print(f"  d={d:.1f}: selective={r['selective_avg']:.1f}, "
              f"naive={r['naive_avg']:.1f}, "
              f"bridge_verified={r['bridge_verified']:.0%}")
