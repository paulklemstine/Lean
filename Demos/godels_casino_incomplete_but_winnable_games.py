"""Gödel's Casino: numerical demonstrations of a guaranteed-win strategy.

This self-contained script models a formal theory abstractly and simulates the
betting game described in the accompanying paper.  It demonstrates:

  * shape determines truth: independent Pi_1 sentences are TRUE, independent
    Sigma_1 sentences are FALSE (Theorems 3.1 and 3.2);
  * the winning strategy (bet TRUE on Pi_1, FALSE on Sigma_1, hedge otherwise)
    never loses a single round and profits +1 on each decidable-shape card;
  * total deck profit equals the number of decidable-shape cards;
  * a >= 1/3 decidable-shape density guarantees average profit >= 1/3;
  * the naive strategy is the pointwise inverse and loses exactly what the
    winning strategy wins.

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Callable, List
import random


# --------------------------------------------------------------------------- #
# Model of a theory
# --------------------------------------------------------------------------- #

class Kind(Enum):
    """Syntactic shape of a sentence card."""
    SIGMA1 = "Sigma_1"
    PI1 = "Pi_1"
    OTHER = "other"


class Bet(Enum):
    BET_TRUE = "betTrue"
    BET_FALSE = "betFalse"
    HEDGE = "hedge"


@dataclass(frozen=True)
class Card:
    """A card dealt by the house.

    `truth` is the sentence's truth value in the standard model N.  Crucially,
    the *player never inspects `truth`*: the strategy depends only on `kind`.
    `truth` is used solely to score the resulting bet, mirroring how an external
    observer settles the wager.  For an independent card the paper *proves*
    truth is forced by kind, so we enforce that invariant on construction.
    """
    name: str
    kind: Kind
    truth: bool
    independent: bool = True

    def __post_init__(self) -> None:
        # Enforce the shape-determines-truth theorems for independent cards.
        if self.independent and self.kind is Kind.PI1 and not self.truth:
            raise ValueError(f"independent Pi_1 card {self.name!r} must be TRUE")
        if self.independent and self.kind is Kind.SIGMA1 and self.truth:
            raise ValueError(f"independent Sigma_1 card {self.name!r} must be FALSE")


def strat(kind: Kind) -> Bet:
    """The winning strategy: TRUE on Pi_1, FALSE on Sigma_1, hedge otherwise."""
    return {
        Kind.PI1: Bet.BET_TRUE,
        Kind.SIGMA1: Bet.BET_FALSE,
        Kind.OTHER: Bet.HEDGE,
    }[kind]


def naive_strat(kind: Kind) -> Bet:
    """The tempting-but-wrong strategy: the pointwise inverse of `strat`."""
    return {
        Kind.PI1: Bet.BET_FALSE,   # bets FALSE on Con(T) -- loses
        Kind.SIGMA1: Bet.BET_TRUE,
        Kind.OTHER: Bet.HEDGE,
    }[kind]


def payoff(bet: Bet, truth: bool) -> int:
    """+1 for a correct bet, -1 for a wrong bet, 0 for a hedge."""
    if bet is Bet.HEDGE:
        return 0
    if bet is Bet.BET_TRUE:
        return 1 if truth else -1
    return -1 if truth else 1  # BET_FALSE


def card_profit(card: Card, strategy: Callable[[Kind], Bet]) -> int:
    return payoff(strategy(card.kind), card.truth)


def deck_profit(deck: List[Card], strategy: Callable[[Kind], Bet]) -> int:
    return sum(card_profit(c, strategy) for c in deck)


def is_decidable_shape(card: Card) -> bool:
    return card.kind in (Kind.SIGMA1, Kind.PI1)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #

def demo_famous_cards() -> None:
    """A small deck of famous independent sentences."""
    print("=" * 68)
    print("Demo 1: A deck of famous independent cards")
    print("=" * 68)
    deck = [
        Card("Con(ZFC)                ", Kind.PI1, truth=True),
        Card("Con(PA)                 ", Kind.PI1, truth=True),
        Card("Goodstein-style Pi_1    ", Kind.PI1, truth=True),
        Card("Rosser-style Sigma_1    ", Kind.SIGMA1, truth=False),
        Card("false halting witness   ", Kind.SIGMA1, truth=False),
        Card("Continuum Hypothesis    ", Kind.OTHER, truth=False, independent=False),
    ]
    print(f"{'card':26} {'kind':9} {'bet':9} {'truth':6} {'profit':>6}")
    for c in deck:
        b = strat(c.kind)
        print(f"{c.name} {c.kind.value:9} {b.value:9} "
              f"{str(c.truth):6} {card_profit(c, strat):>6}")
    total = deck_profit(deck, strat)
    dec = sum(is_decidable_shape(c) for c in deck)
    print(f"\nTotal profit            = {total}")
    print(f"Decidable-shape count   = {dec}   (Theorem 4.9: they are equal)")
    assert total == dec
    print("Note: Con(ZFC) is Pi_1 => TRUE => the winning bet is TRUE, not FALSE.")


def demo_never_loses(n: int = 1000, seed: int = 0) -> None:
    """Simulate 1000 random independent cards; verify profit is never negative."""
    print("\n" + "=" * 68)
    print(f"Demo 2: {n} random independent cards -- the strategy never loses")
    print("=" * 68)
    rng = random.Random(seed)
    deck: List[Card] = []
    for i in range(n):
        k = rng.choice([Kind.SIGMA1, Kind.PI1, Kind.OTHER])
        if k is Kind.PI1:
            truth = True
        elif k is Kind.SIGMA1:
            truth = False
        else:
            truth = rng.random() < 0.5
        deck.append(Card(f"s{i}", k, truth, independent=(k is not Kind.OTHER)))

    per_round = [card_profit(c, strat) for c in deck]
    total = sum(per_round)
    dec = sum(is_decidable_shape(c) for c in deck)
    print(f"min per-round profit    = {min(per_round)}   (>= 0 always)")
    print(f"max per-round profit    = {max(per_round)}")
    print(f"total profit            = {total}")
    print(f"decidable-shape count   = {dec}   (equal, by Theorem 4.9)")
    print(f"average profit / round  = {total / n:.4f}")
    assert min(per_round) >= 0
    assert total == dec


def demo_one_third_edge(n: int = 999, seed: int = 1) -> None:
    """Force a >= 1/3 decidable-shape density and confirm average >= 1/3."""
    print("\n" + "=" * 68)
    print("Demo 3: one-third density guarantees average profit >= 1/3")
    print("=" * 68)
    rng = random.Random(seed)
    # exactly one third decidable shape, split between Sigma_1 and Pi_1
    deck: List[Card] = []
    third = n // 3
    for i in range(third):
        if i % 2 == 0:
            deck.append(Card(f"p{i}", Kind.PI1, True))
        else:
            deck.append(Card(f"g{i}", Kind.SIGMA1, False))
    for i in range(n - third):
        deck.append(Card(f"o{i}", Kind.OTHER, rng.random() < 0.5, independent=False))
    rng.shuffle(deck)

    total = deck_profit(deck, strat)
    rho = sum(is_decidable_shape(c) for c in deck) / n
    avg = total / n
    print(f"deck size               = {n}")
    print(f"decidable-shape density = {rho:.4f}  (>= 1/3)")
    print(f"average profit / round  = {avg:.4f}  (>= 1/3 = {1/3:.4f})")
    assert avg >= 1 / 3 - 1e-9


def demo_naive_inversion(n: int = 500, seed: int = 2) -> None:
    """Confirm naive profit = - winning profit pointwise."""
    print("\n" + "=" * 68)
    print("Demo 4: the naive strategy loses exactly what the winning one wins")
    print("=" * 68)
    rng = random.Random(seed)
    deck: List[Card] = []
    for i in range(n):
        k = rng.choice([Kind.SIGMA1, Kind.PI1, Kind.OTHER])
        truth = True if k is Kind.PI1 else (False if k is Kind.SIGMA1
                                            else rng.random() < 0.5)
        deck.append(Card(f"s{i}", k, truth, independent=(k is not Kind.OTHER)))

    win = deck_profit(deck, strat)
    naive = deck_profit(deck, naive_strat)
    print(f"winning-strategy profit = {win}")
    print(f"naive-strategy profit   = {naive}")
    print(f"sum                     = {win + naive}   (should be 0)")
    for c in deck:
        assert card_profit(c, naive_strat) == -card_profit(c, strat)
    assert win + naive == 0


if __name__ == "__main__":
    demo_famous_cards()
    demo_never_loses()
    demo_one_third_edge()
    demo_naive_inversion()
    print("\nAll demonstrations completed and all invariants verified.")
