"""
Gödel's Casino — Numerical demonstrations of the expected-profit theory.

This self-contained script demonstrates the core results of the theory of
betting on undecidable statements:

  * expected_payoff(p) = 2p - 1           (a single card)
  * total_expected_payoff(ps)             (a finite deck)
  * hedge_break_even                       (p = 1/2  ->  payoff 0)
  * payoff_pos_iff                         (payoff > 0  <->  p > 1/2)
  * casino_positive_profit                 (one strict winner suffices)
  * fraction_bound                         (payoff >= alpha * n * 2*eps)
  * one_third_theorem                      (>= 1/3 strict winners  ->  profit)

Each card is a statement; its "win-probability" p in [0, 1] is the measure of
the set of models in which the player's bet matches the statement's truth value.
A correct bet pays +1, an incorrect bet pays -1.

Run:  python demo.py
"""

from __future__ import annotations

import random
from typing import Sequence


# --------------------------------------------------------------------------
# Core payoff functionals
# --------------------------------------------------------------------------

def expected_payoff(p: float) -> float:
    """Expected payoff of a single card with win-probability ``p``: 2p - 1."""
    return 2.0 * p - 1.0


def total_expected_payoff(ps: Sequence[float]) -> float:
    """Total expected payoff of a finite deck of win-probabilities."""
    return sum(expected_payoff(p) for p in ps)


# --------------------------------------------------------------------------
# Certificates mirroring the theorems
# --------------------------------------------------------------------------

def all_break_even_or_better(ps: Sequence[float], tol: float = 1e-12) -> bool:
    """Check every card is at least break-even: p_i >= 1/2."""
    return all(p >= 0.5 - tol for p in ps)


def count_strict_winners(ps: Sequence[float], tol: float = 1e-12) -> int:
    """Number of strictly profitable cards: p_i > 1/2."""
    return sum(1 for p in ps if p > 0.5 + tol)


def one_third_certificate(ps: Sequence[float]) -> bool:
    """One-Third Theorem hypotheses: all >= 1/2 and at least n/3 strict winners.

    When satisfied on a nonempty deck, total_expected_payoff(ps) > 0 is
    guaranteed.
    """
    n = len(ps)
    if n == 0:
        return False
    return all_break_even_or_better(ps) and count_strict_winners(ps) >= n / 3.0


def fraction_bound_floor(ps: Sequence[float], eps: float) -> float:
    """Certified lower bound alpha * n * (2 eps) from the fraction bound.

    Here alpha = |G| / n where G = {i : p_i >= 1/2 + eps}. The returned floor
    equals 2 * |G| * eps and is a proven lower bound on total_expected_payoff.
    """
    n = len(ps)
    if n == 0:
        return 0.0
    good = sum(1 for p in ps if p >= 0.5 + eps)
    alpha = good / n
    return alpha * n * (2.0 * eps)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_endpoints() -> None:
    print("=" * 70)
    print("1. Endpoints: hedge (p=1/2) and winnable (p=1)")
    print("=" * 70)
    print(f"  hedged  card p=1/2 -> payoff {expected_payoff(0.5):+.4f}  (breaks even)")
    print(f"  winnable card p=1   -> payoff {expected_payoff(1.0):+.4f}  (maximal)")
    print(f"  losing  card p=0   -> payoff {expected_payoff(0.0):+.4f}  (never chosen)")
    print()


def demo_positivity_criterion() -> None:
    print("=" * 70)
    print("2. Positivity criterion: payoff > 0  <->  p > 1/2")
    print("=" * 70)
    for p in [0.40, 0.50, 0.5001, 0.60, 0.90]:
        payoff = expected_payoff(p)
        flag = "PROFIT" if payoff > 0 else ("even  " if payoff == 0 else "loss  ")
        print(f"  p={p:.4f}  payoff={payoff:+.4f}  [{flag}]  (p>1/2 is {p > 0.5})")
    print()


def demo_one_strict_winner() -> None:
    print("=" * 70)
    print("3. One strict winner lifts a deck of hedges into profit")
    print("=" * 70)
    deck = [0.5] * 999 + [0.6]  # 999 undecidable hedges, 1 genuine edge
    print(f"  deck: 999 cards at p=1/2, 1 card at p=0.6")
    print(f"  all break-even or better : {all_break_even_or_better(deck)}")
    print(f"  strict winners           : {count_strict_winners(deck)}")
    print(f"  total expected payoff    : {total_expected_payoff(deck):+.4f}  (> 0)")
    print()


def demo_fraction_bound() -> None:
    print("=" * 70)
    print("4. Fraction bound: T >= alpha * n * (2 eps)")
    print("=" * 70)
    eps = 0.1
    # 300 cards with margin >= 1/2 + eps, 700 hedges.
    deck = [0.5 + eps] * 300 + [0.5] * 700
    floor = fraction_bound_floor(deck, eps)
    actual = total_expected_payoff(deck)
    print(f"  n=1000, 300 cards at p=0.6 (margin eps=0.1), 700 hedges")
    print(f"  certified floor  alpha*n*2eps = {floor:+.4f}")
    print(f"  actual total payoff          = {actual:+.4f}")
    print(f"  floor <= actual : {floor <= actual + 1e-9}")
    print()


def demo_one_third_theorem() -> None:
    print("=" * 70)
    print("5. One-Third Theorem")
    print("=" * 70)
    n = 999
    winners = n // 3          # exactly one third are strict winners
    deck = [0.7] * winners + [0.5] * (n - winners)
    print(f"  n={n}, {winners} strict winners at p=0.7, rest hedged at p=1/2")
    print(f"  one-third certificate holds : {one_third_certificate(deck)}")
    print(f"  total expected payoff       : {total_expected_payoff(deck):+.4f}  (> 0)")
    print()


def demo_simulation() -> None:
    print("=" * 70)
    print("6. Simulation: 1000 independent ZFC-statement cards")
    print("=" * 70)
    rng = random.Random(20260709)
    n = 1000
    # Model the arithmetic hierarchy heuristic: ~1/3 of cards are decidable
    # (winnable, p=1); the rest are undecidable and hedged (p=1/2).
    deck: list[float] = []
    for _ in range(n):
        if rng.random() < 1.0 / 3.0:
            deck.append(1.0)      # decidable -> winnable
        else:
            deck.append(0.5)      # undecidable -> hedged
    winners = count_strict_winners(deck)
    total = total_expected_payoff(deck)
    print(f"  cards        : {n}")
    print(f"  winnable     : {winners}  (~1/3)")
    print(f"  hedged       : {n - winners}")
    print(f"  all >= 1/2   : {all_break_even_or_better(deck)}")
    print(f"  one-third    : {one_third_certificate(deck)}")
    print(f"  TOTAL PAYOFF : {total:+.2f}   (expected profit > 0)")
    print()

    # Simulate actual realized profit with independent +/-1 outcomes.
    trials = 2000
    wins_positive = 0
    for _ in range(trials):
        realized = 0
        for p in deck:
            realized += 1 if rng.random() < p else -1
        if realized > 0:
            wins_positive += 1
    print(f"  realized profit > 0 in {wins_positive}/{trials} "
          f"({100.0 * wins_positive / trials:.1f}%) of independent trials")
    print()


def main() -> None:
    print()
    print("#" * 70)
    print("#  GÖDEL'S CASINO — Betting on Undecidable Statements")
    print("#" * 70)
    print()
    demo_endpoints()
    demo_positivity_criterion()
    demo_one_strict_winner()
    demo_fraction_bound()
    demo_one_third_theorem()
    demo_simulation()
    print("All demonstrations complete: the winning strategy yields positive profit.")


if __name__ == "__main__":
    main()
