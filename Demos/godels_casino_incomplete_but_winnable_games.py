"""
Gödel's Casino: Incomplete but Winnable Games — Numerical Demonstrations
========================================================================

A self-contained numerical companion to the paper "Gödel's Casino: A Game-Theoretic
Analysis of Betting on Undecidable Statements".

The casino model
----------------
Fix a finite set of *worlds* Omega (the models of a background theory). A *statement*
is its truth-value pattern across worlds, s : Omega -> {True, False}, represented here
as a tuple of booleans indexed by the worlds. A *bet* is a single boolean.

Per-world payoff of betting `b` on statement `s` in world `w`:
    +1 if b == s[w]   (correct call)
    -1 if b != s[w]   (incorrect call)

We evaluate every bet two ways:
    * expected profit under the uniform prior over worlds, and
    * worst-case (adversarial) profit.

All arithmetic is done exactly with fractions.Fraction, so the printed numbers are exact.

Running this file prints a guided tour that reproduces every theorem of the paper on
concrete cards and decks.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, List, Sequence, Tuple
import random

# A statement is a tuple of truth values, one per world.
Statement = Tuple[bool, ...]


# --------------------------------------------------------------------------------------
# Core casino primitives
# --------------------------------------------------------------------------------------

def payoff(s: Statement, b: bool, w: int) -> int:
    """Per-world payoff of betting `b` on statement `s` in world index `w`."""
    return 1 if b == s[w] else -1


def expected_profit(s: Statement, b: bool) -> Fraction:
    """Expected profit of bet `b` on `s` under the uniform prior over worlds."""
    n = len(s)
    total = sum(payoff(s, b, w) for w in range(n))
    return Fraction(total, n)


def worst_case_profit(s: Statement, b: bool) -> int:
    """Adversarial profit: the house reveals the least favorable world."""
    return min(payoff(s, b, w) for w in range(len(s)))


def true_count(s: Statement) -> int:
    """Number of worlds in which `s` is true."""
    return sum(1 for v in s if v)


def opt_profit(s: Statement) -> Fraction:
    """Optimal expected profit: the better of betting TRUE or betting FALSE."""
    return max(expected_profit(s, True), expected_profit(s, False))


def deck_opt_profit(deck: Sequence[Statement]) -> Fraction:
    """Average optimal profit across a deck (one round per card)."""
    return sum((opt_profit(s) for s in deck), Fraction(0)) / len(deck)


# --------------------------------------------------------------------------------------
# Statement classifiers (matching the paper's definitions)
# --------------------------------------------------------------------------------------

def is_valid(s: Statement) -> bool:
    """True in every world (a decidable truth)."""
    return all(s)


def is_unsat(s: Statement) -> bool:
    """False in every world (a decidable falsehood)."""
    return not any(s)


def is_independent(s: Statement) -> bool:
    """True in some world and false in another (genuinely undecidable)."""
    return any(s) and not all(s)


def is_balanced(s: Statement) -> bool:
    """True in exactly half the worlds."""
    return 2 * true_count(s) == len(s)


# --------------------------------------------------------------------------------------
# Closed-form check (Theorem 4)
# --------------------------------------------------------------------------------------

def expected_profit_formula(s: Statement) -> Fraction:
    """Closed form for the TRUE bet: (2 * #true - #worlds) / #worlds."""
    n = len(s)
    return Fraction(2 * true_count(s) - n, n)


# --------------------------------------------------------------------------------------
# Guided demonstrations
# --------------------------------------------------------------------------------------

def demo_zero_sum() -> None:
    print("=" * 78)
    print("1. THE GAME IS ZERO-SUM (Theorem 2)")
    print("=" * 78)
    print("For any statement, betting TRUE and betting FALSE have opposite expected")
    print("profits, so they always sum to 0. The house has no built-in edge.\n")
    cards = {
        "valid card  (T,T,T,T)": (True, True, True, True),
        "balanced    (T,T,F,F)": (True, True, False, False),
        "biased      (T,T,T,F)": (True, True, True, False),
        "unsat       (F,F,F,F)": (False, False, False, False),
    }
    for name, s in cards.items():
        et, ef = expected_profit(s, True), expected_profit(s, False)
        print(f"  {name}:  E[TRUE]={et!s:>5}  E[FALSE]={ef!s:>5}  sum={et + ef}")
    print()


def demo_decidable_wins() -> None:
    print("=" * 78)
    print("2. DECIDABLE STATEMENTS ARE FULLY WINNABLE (Theorems 5-6)")
    print("=" * 78)
    valid = (True, True, True, True, True)
    unsat = (False, False, False, False, False)
    print(f"  valid card {valid}:")
    print(f"      bet TRUE  -> expected profit {expected_profit(valid, True)} "
          f"(worst case {worst_case_profit(valid, True)})")
    print(f"  unsatisfiable card {unsat}:")
    print(f"      bet FALSE -> expected profit {expected_profit(unsat, False)} "
          f"(worst case {worst_case_profit(unsat, False)})")
    print("  Decidable cards pay the maximum both in expectation and in the worst case.\n")


def demo_independence_cannot_be_beaten() -> None:
    print("=" * 78)
    print("3. INDEPENDENCE CANNOT BE BEATEN (Theorems 8-9)")
    print("=" * 78)
    print("The Continuum-Hypothesis card in miniature: TRUE in one world, FALSE in the")
    print("other. It is independent and balanced.\n")
    ch = (True, False)  # the identity card on two worlds
    print(f"  card {ch}: independent={is_independent(ch)}, balanced={is_balanced(ch)}")
    for b in (True, False):
        print(f"      bet {str(b):>5}: expected profit {expected_profit(ch, b)}, "
              f"worst-case profit {worst_case_profit(ch, b)}")
    print("  Expected profit is exactly 0 for EVERY bet, and the worst case is a")
    print("  guaranteed loss of -1. Undecidability buys nothing.\n")


def demo_refute_one_third() -> None:
    print("=" * 78)
    print("4. THE '>= 1/3 PER ROUND' BOUND FAILS (Theorem 12)")
    print("=" * 78)
    deck = [(True, False)]  # a deck of one balanced card
    avg = deck_opt_profit(deck)
    print(f"  Deck of balanced cards: average optimal profit = {avg}")
    print(f"  Claimed universal bound: >= 1/3 = {Fraction(1, 3)}")
    print(f"  {avg} < {Fraction(1, 3)}  ->  the bound is FALSE.\n")


def demo_edge_is_decidable_fraction() -> None:
    print("=" * 78)
    print("5. THE EDGE EQUALS THE DECIDABLE FRACTION (Theorems 13-15)")
    print("=" * 78)
    print("A mixed deck: a fraction f of decidable (valid) cards, the rest balanced.")
    print("Average optimal profit equals exactly f.\n")
    valid = (True, True)
    balanced = (True, False)
    for n_valid, n_bal in [(0, 6), (2, 4), (3, 3), (4, 2), (6, 0)]:
        deck = [valid] * n_valid + [balanced] * n_bal
        f = Fraction(n_valid, n_valid + n_bal)
        avg = deck_opt_profit(deck)
        flag = "OK" if avg == f else "MISMATCH"
        print(f"  {n_valid} valid + {n_bal} balanced: f = {f!s:>4},  "
              f"average optimal profit = {avg!s:>4}  [{flag}]")
    print()


def demo_large_simulation(n_cards: int = 1000, seed: int = 12345) -> None:
    print("=" * 78)
    print(f"6. LARGE SIMULATION: {n_cards} INDEPENDENT ZFC-STYLE CARDS")
    print("=" * 78)
    print("Each card is a genuinely independent (balanced) two-world statement — the")
    print("'right in some model' situation. We play optimally on every card.\n")
    rng = random.Random(seed)
    deck: List[Statement] = []
    for _ in range(n_cards):
        # A balanced two-world card in a random orientation.
        deck.append((True, False) if rng.random() < 0.5 else (False, True))
    avg = deck_opt_profit(deck)
    total_worst = sum(max(worst_case_profit(s, True), worst_case_profit(s, False))
                      for s in deck)
    print(f"  average optimal EXPECTED profit per round : {avg}  (= 0, a fair coin)")
    print(f"  total best WORST-CASE profit over the deck: {total_worst}  "
          f"(= -{n_cards}, an adversarial loss)")
    print("  Verdict: on purely undecidable cards the player breaks even at best and")
    print("  loses everything against an adversary. The conjecture is refuted.\n")


def demo_closed_form_check() -> None:
    print("=" * 78)
    print("7. CLOSED-FORM FORMULA CHECK (Theorem 4)")
    print("=" * 78)
    print("Verifying  E[TRUE] = (2*#true - #worlds)/#worlds  on random cards.\n")
    rng = random.Random(7)
    all_ok = True
    for _ in range(10):
        n = rng.randint(1, 8)
        s: Statement = tuple(rng.random() < 0.5 for _ in range(n))
        direct = expected_profit(s, True)
        formula = expected_profit_formula(s)
        ok = direct == formula
        all_ok = all_ok and ok
        print(f"  n={n}, #true={true_count(s)}: direct={direct!s:>6} "
              f"formula={formula!s:>6}  {'OK' if ok else 'FAIL'}")
    print(f"\n  All formula checks passed: {all_ok}\n")


def main() -> None:
    print("\n" + "#" * 78)
    print("#  GÖDEL'S CASINO — NUMERICAL DEMONSTRATIONS".ljust(77) + "#")
    print("#" * 78 + "\n")
    demo_zero_sum()
    demo_decidable_wins()
    demo_independence_cannot_be_beaten()
    demo_refute_one_third()
    demo_edge_is_decidable_fraction()
    demo_large_simulation()
    demo_closed_form_check()
    print("=" * 78)
    print("CONCLUSION: The player's entire edge comes from the DECIDABLE cards.")
    print("Genuine incompleteness contributes exactly 0 in expectation and -1 in the")
    print("worst case. Incompleteness is a barrier, not a free lunch.")
    print("=" * 78)


if __name__ == "__main__":
    main()
