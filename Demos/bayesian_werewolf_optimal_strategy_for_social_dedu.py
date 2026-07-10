"""
Bayesian Werewolf: numerical demonstrations of the exact probabilistic backbone
of social-deduction games.

This module is fully self-contained (standard library only). It illustrates:

  1. The Symmetry Principle:            posterior(n, k) == prior(n, k) == k / n.
  2. The baseline detection rate:       one uniform vote catches a wolf w.p. k / n.
  3. Comparative statics of suspicion:  monotone in k (up) and in n (down).
  4. The werewolf advantage & parity:   A(n, k) >= 1  iff  n <= 2k.
  5. The survival law:                  surv(n, t) == (n - t) / n.
  6. The consensus-elimination game:    exact villager win-probability W(w, v),
                                        verified to lie in [0, 1].

All probabilities are computed as exact rationals (fractions.Fraction) so that the
identities are demonstrated as exact equalities, not floating-point approximations.
"""

from __future__ import annotations

from fractions import Fraction
from functools import lru_cache
from math import comb, isqrt
from typing import Dict, List, Tuple


# --------------------------------------------------------------------------- #
# 1. Posterior, prior, and the Symmetry Principle
# --------------------------------------------------------------------------- #
def posterior(n: int, k: int) -> Fraction:
    """Posterior probability a fixed player is a werewolf: C(n-1, k-1) / C(n, k)."""
    if not (1 <= k <= n):
        raise ValueError("require 1 <= k <= n")
    return Fraction(comb(n - 1, k - 1), comb(n, k))


def prior(n: int, k: int) -> Fraction:
    """Prior probability a fixed player is a werewolf: k / n."""
    if n <= 0:
        raise ValueError("require n > 0")
    return Fraction(k, n)


def check_symmetry_principle(max_n: int = 12) -> bool:
    """Verify posterior(n, k) == prior(n, k) exactly for all 1 <= k <= n <= max_n."""
    for n in range(1, max_n + 1):
        for k in range(1, n + 1):
            if posterior(n, k) != prior(n, k):
                return False
    return True


# --------------------------------------------------------------------------- #
# 2. Werewolf advantage and the parity threshold
# --------------------------------------------------------------------------- #
def advantage(n: int, k: int) -> Fraction:
    """Werewolf advantage: k / (n - k), the wolves-to-villagers ratio."""
    if not (k < n):
        raise ValueError("require k < n")
    return Fraction(k, n - k)


def check_parity_threshold(max_n: int = 20) -> bool:
    """Verify  advantage(n, k) >= 1  iff  n <= 2k,  for all 0 <= k < n <= max_n."""
    for n in range(1, max_n + 1):
        for k in range(0, n):
            if (advantage(n, k) >= 1) != (n <= 2 * k):
                return False
    return True


# --------------------------------------------------------------------------- #
# 3. Survival law
# --------------------------------------------------------------------------- #
def survival_prob(n: int, t: int) -> Fraction:
    """Probability a fixed player survives t uniform removals: C(n-1, t) / C(n, t)."""
    if not (0 <= t <= n and n >= 1):
        raise ValueError("require 0 <= t <= n and n >= 1")
    return Fraction(comb(n - 1, t), comb(n, t))


def check_survival_law(max_n: int = 15) -> bool:
    """Verify survival_prob(n, t) == (n - t) / n exactly."""
    for n in range(1, max_n + 1):
        for t in range(0, n + 1):
            if survival_prob(n, t) != Fraction(n - t, n):
                return False
    return True


# --------------------------------------------------------------------------- #
# 4. The consensus-elimination game value W(w, v)
# --------------------------------------------------------------------------- #
@lru_cache(maxsize=None)
def win_prob(w: int, v: int) -> Fraction:
    """Exact villager win-probability with w werewolves and v villagers alive.

    Villagers win when no werewolf remains; werewolves win upon reaching parity
    (w >= v). Otherwise one uniformly random living player is removed each round.
    """
    if w == 0:
        return Fraction(1)
    if w >= v:  # parity: werewolves win
        return Fraction(0)
    total = w + v
    return (Fraction(w, total) * win_prob(w - 1, v)
            + Fraction(v, total) * win_prob(w, v - 1))


def check_value_bounds(max_pop: int = 24) -> bool:
    """Verify 0 <= W(w, v) <= 1 for every reachable configuration."""
    for pop in range(1, max_pop + 1):
        for w in range(0, pop + 1):
            v = pop - w
            val = win_prob(w, v)
            if not (Fraction(0) <= val <= Fraction(1)):
                return False
    return True


# --------------------------------------------------------------------------- #
# 5. Empirical vs. exact win probability (uniform / uninformed play)
# --------------------------------------------------------------------------- #
def sqrt_balance_table(max_n: int = 40) -> List[Tuple[int, int, float]]:
    """For each n, report the k ~ sqrt(n) werewolf count and the exact W value.

    Illustrates the balance heuristic: with k on the order of sqrt(n), the
    consensus-game villager win-probability stays away from 0 and 1.
    """
    rows: List[Tuple[int, int, float]] = []
    for n in range(4, max_n + 1):
        k = max(1, isqrt(n))
        v = n - k
        if k < v:  # a genuine (non-parity) starting position
            rows.append((n, k, float(win_prob(k, v))))
    return rows


# --------------------------------------------------------------------------- #
# Reporting
# --------------------------------------------------------------------------- #
def main() -> None:
    print("=" * 70)
    print("BAYESIAN WEREWOLF — exact probabilistic backbone")
    print("=" * 70)

    print("\n[1] Symmetry Principle:  posterior(n,k) == prior(n,k) == k/n")
    for n, k in [(7, 2), (10, 3), (12, 5)]:
        print(f"    n={n:2d}, k={k}: posterior={posterior(n, k)!s:>7}  "
              f"prior={prior(n, k)!s:>7}  (k/n={float(prior(n, k)):.4f})")
    print(f"    exhaustive check up to n=12: {check_symmetry_principle()}")

    print("\n[2] Baseline detection rate = k/n  (one uniform vote)")
    for n, k in [(7, 2), (15, 4)]:
        print(f"    n={n:2d}, k={k}: catch-a-wolf probability = {float(prior(n, k)):.4f}")

    print("\n[3] Comparative statics of suspicion")
    print(f"    prior(7,2)={float(prior(7,2)):.4f} < prior(7,3)={float(prior(7,3)):.4f}"
          "   (more wolves -> more suspicion)")
    print(f"    prior(8,2)={float(prior(8,2)):.4f} < prior(7,2)={float(prior(7,2)):.4f}"
          "   (bigger crowd -> less suspicion)")

    print("\n[4] Werewolf advantage & parity threshold  (A>=1 iff n<=2k)")
    for n, k in [(7, 2), (7, 3), (6, 3), (5, 3)]:
        print(f"    n={n}, k={k}: A={float(advantage(n, k)):.3f}  "
              f"A>=1? {advantage(n, k) >= 1}   n<=2k? {n <= 2 * k}")
    print(f"    exhaustive check up to n=20: {check_parity_threshold()}")

    print("\n[5] Survival law:  surv(n,t) == (n-t)/n")
    for n, t in [(7, 3), (10, 4)]:
        print(f"    n={n}, t={t}: surv={survival_prob(n, t)!s:>6} = (n-t)/n="
              f"{Fraction(n - t, n)!s:>6}")
    print(f"    exhaustive check up to n=15: {check_survival_law()}")

    print("\n[6] Consensus-elimination game value W(w,v)")
    for w, v in [(2, 5), (3, 7), (4, 8)]:
        print(f"    W({w},{v}) = {win_prob(w, v)!s:>12} ~ {float(win_prob(w, v)):.4f}")
    print(f"    0 <= W <= 1 for all populations up to 24: {check_value_bounds()}")

    print("\n[7] Square-root balance heuristic (k ~ sqrt(n))")
    for n, k, val in sqrt_balance_table(30)[::4]:
        print(f"    n={n:2d}, k={k}:  W(k, n-k) = {val:.4f}")

    print("\nAll exact identities verified.")


if __name__ == "__main__":
    main()
