"""
demo.py — The Werewolf Paradox: Non-Monotone Reasoning in Random-Elimination Games
===================================================================================

A fully self-contained numerical companion to the formalized theory of villager
win probabilities in a random-elimination social-deduction game (Werewolf/Mafia).

Everything here mirrors, in exact rational arithmetic, the recursive win-probability
function `winProb` and the surprising structural facts proved about it:

  * The Parity Paradox            — adding one villager can DECREASE the villagers'
                                     chance of winning.
  * Skip-Two Monotonicity         — adding TWO villagers always helps.
  * Diagonal Monotonicity         — trading a werewolf for a villager helps.
  * Win-probability bounds        — 0 <= P(v, w) <= 1 always.
  * The Parity Defect             — a single number that quantifies the paradox,
                                     and which shrinks as the game grows.

All arithmetic uses Python's `fractions.Fraction`, so every printed value is exact
and matches the rational numbers proved in the formal development.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from functools import lru_cache
from typing import List, Tuple


# ---------------------------------------------------------------------------
# The win-probability recursion (exact rational arithmetic)
# ---------------------------------------------------------------------------
#
# Game model.  There are `v` villagers and `w` werewolves.  Each round:
#   1. DAY:   one of the v + w players is eliminated uniformly at random.
#   2. NIGHT: if the game has not ended, the werewolves kill one villager.
# Villagers WIN iff every werewolf is eventually eliminated.
# Werewolves WIN iff they reach a majority (w >= v) at any point.
#
# winProb(v, w) is the probability that the villagers win from state (v, w).

@lru_cache(maxsize=None)
def win_prob(v: int, w: int) -> Fraction:
    """Exact villager win probability from a state with v villagers, w werewolves."""
    # Base case: no werewolves left -> villagers have already won.
    if w == 0:
        return Fraction(1, 1)

    # Werewolves already at majority -> villagers have already lost.
    if v <= w:
        return Fraction(0, 1)

    total = v + w  # players eligible for the daytime elimination

    # Branch A: the daytime vote eliminates a werewolf (prob w / total).
    if w == 1:
        # Eliminating the last werewolf ends the game in a villager victory.
        after_wolf = Fraction(1, 1)
    else:
        # One werewolf removed; the remaining w-1 wolves kill a villager at night,
        # leaving (v - 1, w - 1).  (Matches winProb (v-1) w with w := w-1.)
        after_wolf = win_prob(v - 1, w - 1)
    branch_wolf = Fraction(w, total) * after_wolf

    # Branch B: the daytime vote eliminates a villager (prob v / total).
    # Then the wolves kill another villager at night, costing TWO villagers.
    # If that would hand the wolves a majority, the villagers lose outright.
    if v <= w + 2:
        after_villager = Fraction(0, 1)
    else:
        after_villager = win_prob(v - 2, w)
    branch_villager = Fraction(v, total) * after_villager

    return branch_wolf + branch_villager


# ---------------------------------------------------------------------------
# The parity defect:  P(v, w) / P(v+1, w)
# ---------------------------------------------------------------------------
#
# When > 1, the paradox is active: the smaller team (v) outperforms the larger
# team (v + 1).  As v grows the defect decays toward 1.

def parity_defect(v: int, w: int) -> Fraction:
    """Ratio P(v, w) / P(v+1, w); > 1 exactly when adding a villager hurts."""
    denom = win_prob(v + 1, w)
    if denom == 0:
        return Fraction(0, 1)
    return win_prob(v, w) / denom


# ---------------------------------------------------------------------------
# Pretty-printing helpers
# ---------------------------------------------------------------------------

def fmt(x: Fraction) -> str:
    """Render a Fraction as 'p/q' (or 'p') plus a decimal approximation."""
    rational = f"{x.numerator}/{x.denominator}" if x.denominator != 1 else f"{x.numerator}"
    return f"{rational:>9}  (~{float(x):.4f})"


def win_table(max_v: int, max_w: int) -> None:
    print("Villager win probability  P(v, w)\n")
    header = "v\\w |" + "".join(f"{w:>12}" for w in range(max_w + 1))
    print(header)
    print("-" * len(header))
    for v in range(1, max_v + 1):
        row = f"{v:>3} |"
        for w in range(max_w + 1):
            p = win_prob(v, w)
            cell = f"{p.numerator}/{p.denominator}" if p.denominator != 1 else f"{p.numerator}"
            row += f"{cell:>12}"
        print(row)
    print()


# ---------------------------------------------------------------------------
# Demonstrations of the proved theorems
# ---------------------------------------------------------------------------

def demo_concrete_values() -> None:
    print("=" * 70)
    print("1. EXACT VALUES (matching the formally verified rationals)")
    print("=" * 70)
    checks: List[Tuple[int, int, Fraction]] = [
        (2, 1, Fraction(1, 3)),
        (3, 1, Fraction(1, 4)),
        (4, 1, Fraction(7, 15)),
        (5, 1, Fraction(3, 8)),
        (6, 1, Fraction(19, 35)),
        (3, 2, Fraction(2, 15)),
        (4, 2, Fraction(1, 12)),
        (5, 2, Fraction(8, 35)),
        (6, 2, Fraction(5, 32)),
    ]
    for v, w, expected in checks:
        got = win_prob(v, w)
        ok = "OK" if got == expected else "MISMATCH"
        print(f"  P({v}, {w}) = {fmt(got)}   expected {expected}   [{ok}]")
    print()


def demo_parity_paradox() -> None:
    print("=" * 70)
    print("2. THE PARITY PARADOX  (adding ONE villager can HURT)")
    print("=" * 70)
    pairs = [(2, 3, 1), (4, 5, 1), (3, 4, 2), (5, 6, 2)]
    for v, vp, w in pairs:
        a, b = win_prob(v, w), win_prob(vp, w)
        verdict = "PARADOX: more villagers, lower chance!" if b < a else "monotone"
        print(f"  P({v},{w}) = {float(a):.4f}   vs   P({vp},{w}) = {float(b):.4f}   -> {verdict}")
    print()


def demo_skip_two() -> None:
    print("=" * 70)
    print("3. SKIP-TWO MONOTONICITY  (adding TWO villagers always helps)")
    print("=" * 70)
    pairs = [(2, 4, 1), (3, 5, 1), (4, 6, 1), (3, 5, 2), (4, 6, 2)]
    for v, vp, w in pairs:
        a, b = win_prob(v, w), win_prob(vp, w)
        verdict = "increase (as proved)" if a < b else "FAILS"
        print(f"  P({v},{w}) = {float(a):.4f}   <   P({vp},{w}) = {float(b):.4f}   -> {verdict}")
    print()


def demo_diagonal() -> None:
    print("=" * 70)
    print("4. DIAGONAL MONOTONICITY  (trade a werewolf for a villager -> helps)")
    print("=" * 70)
    pairs = [(3, 2, 4, 1), (4, 2, 5, 1), (5, 2, 6, 1)]
    for v, w, vp, wp in pairs:
        a, b = win_prob(v, w), win_prob(vp, wp)
        verdict = "improves (as proved)" if a < b else "FAILS"
        print(f"  P({v},{w}) = {float(a):.4f}   <   P({vp},{wp}) = {float(b):.4f}   -> {verdict}")
    print()


def demo_parity_defect() -> None:
    print("=" * 70)
    print("5. THE PARITY DEFECT  D(v, w) = P(v, w) / P(v+1, w)")
    print("=" * 70)
    print("  D > 1 means the paradox is active; it decays toward 1 as v grows.\n")
    for w in (1, 2):
        print(f"  werewolves w = {w}:")
        # Start at v = w+1: these are the states where the paradox is strongest.
        for v in range(w + 1, w + 14, 2):
            d = parity_defect(v, w)
            tag = "  (paradox: more villagers hurt)" if d > 1 else ""
            print(f"     D({v},{w}) = {float(d):.5f}{tag}")
        print()


def demo_bounds() -> None:
    print("=" * 70)
    print("6. BOUNDS:  0 <= P(v, w) <= 1  for all states")
    print("=" * 70)
    ok = True
    for v in range(0, 15):
        for w in range(0, 15):
            p = win_prob(v, w)
            if not (Fraction(0) <= p <= Fraction(1)):
                ok = False
                print(f"  BOUND VIOLATED at ({v},{w}): {p}")
    print("  All sampled states satisfy 0 <= P <= 1." if ok else "  VIOLATION FOUND")
    print()


def main() -> None:
    print("\nTHE WEREWOLF PARADOX — numerical companion\n")
    win_table(max_v=8, max_w=4)
    demo_concrete_values()
    demo_parity_paradox()
    demo_skip_two()
    demo_diagonal()
    demo_parity_defect()
    demo_bounds()
    print("Done.  Every value above is exact and matches the formal theory.")


if __name__ == "__main__":
    main()
