"""Numerical demonstrations for
'The Topological Kernel of Social Choice'.

This self-contained script illustrates the two halves of the story:

  Part I  -- the one-dimensional Borsuk-Ulam theorem: a continuous
             2*pi-periodic function f must have an antipodal coincidence
             f(x) = f(x + pi). We locate one numerically.

  Part II -- the disproof of 'continuous implies dictatorial': the mean
             aggregator on n >= 2 agents is continuous, unanimous (Pareto),
             anonymous, monotone, translation-invariant, and non-dictatorial.
             We audit each axiom empirically.

Only the Python standard library is used.
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Sequence


# ---------------------------------------------------------------------------
# Part I: one-dimensional Borsuk-Ulam
# ---------------------------------------------------------------------------

def antipodal_difference(f: Callable[[float], float]) -> Callable[[float], float]:
    """Return g(x) = f(x) - f(x + pi), the antipodal difference of f."""
    return lambda x: f(x) - f(x + math.pi)


def find_antipodal_coincidence(
    f: Callable[[float], float],
    tol: float = 1e-12,
    max_iter: int = 200,
) -> float:
    """Find x in [0, pi] with f(x) ~= f(x + pi) for a 2*pi-periodic f.

    Uses the constructive proof: g(x) = f(x) - f(x + pi) satisfies
    g(0) = -g(pi), so g has a sign change on [0, pi]; bisect to a root.
    """
    g = antipodal_difference(f)
    lo, hi = 0.0, math.pi
    g_lo = g(lo)
    if abs(g_lo) < tol:
        return lo
    # g(0) = -g(pi), so g_lo and g(hi) straddle zero (unless already zero).
    for _ in range(max_iter):
        mid = 0.5 * (lo + hi)
        g_mid = g(mid)
        if abs(g_mid) < tol or (hi - lo) < tol:
            return mid
        if (g_lo > 0) != (g_mid > 0):
            hi = mid
        else:
            lo, g_lo = mid, g_mid
    return 0.5 * (lo + hi)


def demo_borsuk_ulam() -> None:
    print("=" * 70)
    print("Part I: one-dimensional Borsuk-Ulam theorem")
    print("=" * 70)

    # A generic continuous 2*pi-periodic 'social score'.
    def f(x: float) -> float:
        return (math.sin(x + 0.7) + 0.5 * math.cos(2 * x)
                + 0.3 * math.sin(3 * x + 1.1))

    x = find_antipodal_coincidence(f)
    print(f"Found antipodal coincidence at x = {x:.10f}")
    print(f"  f(x)       = {f(x):.10f}")
    print(f"  f(x + pi)  = {f(x + math.pi):.10f}")
    print(f"  |f(x) - f(x+pi)| = {abs(f(x) - f(x + math.pi)):.2e}")
    print("=> No continuous periodic score can STRICTLY prefer every")
    print("   opinion to its antipode: the tie above is unavoidable.\n")


# ---------------------------------------------------------------------------
# Part II: the mean aggregator and its fairness audit
# ---------------------------------------------------------------------------

def avg(p: Sequence[float]) -> float:
    """The mean aggregator: social outcome = average of individual positions."""
    n = len(p)
    return sum(p) / n


def check_unanimity(n: int, trials: int = 1000) -> bool:
    for _ in range(trials):
        c = random.uniform(-100, 100)
        if abs(avg([c] * n) - c) > 1e-9:
            return False
    return True


def check_anonymity(n: int, trials: int = 1000) -> bool:
    for _ in range(trials):
        p = [random.uniform(-100, 100) for _ in range(n)]
        q = p[:]
        random.shuffle(q)
        if abs(avg(p) - avg(q)) > 1e-9:
            return False
    return True


def check_monotonicity(n: int, trials: int = 1000) -> bool:
    for _ in range(trials):
        p = [random.uniform(-100, 100) for _ in range(n)]
        q = [pi + random.uniform(0, 10) for pi in p]  # weakly increase each
        if avg(q) < avg(p) - 1e-9:
            return False
    return True


def check_translation_invariance(n: int, trials: int = 1000) -> bool:
    for _ in range(trials):
        p = [random.uniform(-100, 100) for _ in range(n)]
        c = random.uniform(-100, 100)
        shifted = [pi + c for pi in p]
        if abs(avg(shifted) - (avg(p) + c)) > 1e-9:
            return False
    return True


def non_dictatorship_witnesses(n: int) -> List[float]:
    """For each agent i, return avg(witness) where the witness sets agent i
    to 0 and everyone else to 1. By Lemma 4.6 this equals (n-1)/n != 0,
    certifying that agent i is not a dictator."""
    outcomes = []
    for i in range(n):
        profile = [0.0 if j == i else 1.0 for j in range(n)]
        outcomes.append(avg(profile))
    return outcomes


def demo_mean_fairness() -> None:
    print("=" * 70)
    print("Part II: the mean is continuous, fair, and non-dictatorial")
    print("=" * 70)
    for n in (2, 3, 5):
        print(f"\nn = {n} agents:")
        print(f"  unanimity (Pareto)     : {check_unanimity(n)}")
        print(f"  anonymity              : {check_anonymity(n)}")
        print(f"  monotonicity           : {check_monotonicity(n)}")
        print(f"  translation invariance : {check_translation_invariance(n)}")
        outcomes = non_dictatorship_witnesses(n)
        expected = (n - 1) / n
        ok = all(abs(o - expected) < 1e-12 and abs(o) > 1e-12 for o in outcomes)
        print(f"  non-dictatorship       : {ok} "
              f"(each witness -> {expected:.4f} != 0)")
    print("\n=> For every n >= 2 the mean satisfies all axioms at once,")
    print("   disproving 'continuous implies dictatorial'.\n")


if __name__ == "__main__":
    random.seed(0)
    demo_borsuk_ulam()
    demo_mean_fairness()
