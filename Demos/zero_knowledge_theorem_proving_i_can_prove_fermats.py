"""Numerical demonstrations of local-checkability soundness for zero-knowledge
certification.

This self-contained script illustrates the paper's main results:

  * Single-Round Soundness: an invalid certificate has at most |Omega| - 1
    passing challenges, so the single-round verifier rejects with probability
    at least 1 / |Omega|.
  * Strict Soundness Gap: the accepting fraction of an invalid certificate is
    strictly below 1.
  * Multi-Round Soundness Amplification: over k independent invalid rounds, the
    survival probability is at most ((|Omega| - 1) / |Omega|) ** k.
  * Three-Colouring Amplified Soundness: the abstract bound instantiated at the
    GMW graph 3-colouring verifier, giving ((|E| - 1) / |E|) ** k.

Every function is inlined; no third-party dependencies are required.
"""

from __future__ import annotations

import random
from fractions import Fraction
from typing import Callable, Dict, Hashable, List, Sequence, Tuple

Challenge = Hashable
Edge = Tuple[int, int]
Coloring = Dict[int, int]


# ---------------------------------------------------------------------------
# Abstract locally checkable certificates
# ---------------------------------------------------------------------------
def passing_set(
    omega: Sequence[Challenge], check: Callable[[Challenge], bool]
) -> List[Challenge]:
    """Return the challenges in `omega` that pass `check` (the passing set P)."""
    return [e for e in omega if check(e)]


def accepting_fraction(
    omega: Sequence[Challenge], check: Callable[[Challenge], bool]
) -> Fraction:
    """Exact single-round accepting probability |P| / |Omega| as a Fraction."""
    if len(omega) == 0:
        raise ValueError("challenge space must be nonempty")
    return Fraction(len(passing_set(omega, check)), len(omega))


def is_invalid(
    omega: Sequence[Challenge], check: Callable[[Challenge], bool]
) -> bool:
    """A certificate is invalid iff some challenge fails."""
    return any(not check(e) for e in omega)


def single_round_bound(num_challenges: int) -> Fraction:
    """Upper bound (|Omega| - 1) / |Omega| on the accepting fraction of any
    invalid certificate (Single-Round Soundness Theorem)."""
    if num_challenges <= 0:
        raise ValueError("challenge space must be nonempty")
    return Fraction(num_challenges - 1, num_challenges)


def kround_survival_probability(
    omega: Sequence[Challenge], checks: Sequence[Callable[[Challenge], bool]]
) -> Fraction:
    """Exact k-round survival probability = product of per-round accepting
    fractions (independent rounds)."""
    prob = Fraction(1)
    for check in checks:
        prob *= accepting_fraction(omega, check)
    return prob


def kround_bound(num_challenges: int, k: int) -> Fraction:
    """The amplified bound ((|Omega| - 1) / |Omega|) ** k."""
    return single_round_bound(num_challenges) ** k


# ---------------------------------------------------------------------------
# Graph 3-colouring instantiation (GMW verifier)
# ---------------------------------------------------------------------------
def is_proper(edges: Sequence[Edge], coloring: Coloring) -> bool:
    """True iff every edge has endpoints of distinct colours."""
    return all(coloring[u] != coloring[v] for (u, v) in edges)


def coloring_check(coloring: Coloring) -> Callable[[Edge], bool]:
    """The per-edge local check: edge (u, v) passes iff its endpoints differ."""
    return lambda e: coloring[e[0]] != coloring[e[1]]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_single_round() -> None:
    print("=" * 68)
    print("Single-Round Soundness: |P| <= |Omega| - 1 for invalid certificate")
    print("=" * 68)
    omega = list(range(10))  # |Omega| = 10
    # Invalid certificate: exactly one location fails (challenge 7).
    check = lambda e: e != 7
    assert is_invalid(omega, check)
    frac = accepting_fraction(omega, check)
    bound = single_round_bound(len(omega))
    print(f"|Omega|            = {len(omega)}")
    print(f"passing set        = {passing_set(omega, check)}")
    print(f"accepting fraction = {frac}  ({float(frac):.4f})")
    print(f"bound (|O|-1)/|O|  = {bound}  ({float(bound):.4f})")
    print(f"accepting <= bound : {frac <= bound}")
    print(f"strictly < 1       : {frac < 1}")
    print(f"catch prob >= 1/|O|: {1 - frac >= Fraction(1, len(omega))}")
    print()


def demo_amplification() -> None:
    print("=" * 68)
    print("Multi-Round Amplification: survival <= ((|O|-1)/|O|)^k")
    print("=" * 68)
    omega = list(range(10))
    header = f"{'k':>3} | {'survival (exact)':>22} | {'bound':>10} | ok"
    print(header)
    print("-" * len(header))
    for k in range(1, 9):
        # Each round corrupts one (possibly different) location -> invalid.
        checks = [(lambda e, i=i: e != (i % len(omega))) for i in range(k)]
        survival = kround_survival_probability(omega, checks)
        bound = kround_bound(len(omega), k)
        print(f"{k:>3} | {float(survival):>22.10f} | {float(bound):>10.6f} |"
              f" {survival <= bound}")
    print()


def demo_rounds_for_target() -> None:
    print("=" * 68)
    print("Round complexity: rounds to reach error 2^-k  (Theta(|O| * k))")
    print("=" * 68)
    import math
    for n in (2, 8, 64, 1024):
        r = single_round_bound(n)
        header = f"  |Omega| = {n}"
        print(header)
        for k in (10, 20, 40):
            rounds = math.ceil(k * math.log(2) / math.log(n / (n - 1)))
            print(f"    error 2^-{k:<3}: need R = {rounds:>7} rounds"
                  f"   (approx |O|*k = {n * k})")
        print()


def demo_graph_3coloring() -> None:
    print("=" * 68)
    print("Three-Colouring Amplified Soundness: survival <= ((|E|-1)/|E|)^k")
    print("=" * 68)
    # A 5-cycle: vertices 0..4, edges connecting consecutive ones.
    edges: List[Edge] = [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)]
    # An improper colouring: vertices 0 and 1 share colour 0 (edge (0,1) fails).
    improper: Coloring = {0: 0, 1: 0, 2: 1, 3: 2, 4: 1}
    print(f"edges |E|          = {len(edges)}")
    print(f"colouring          = {improper}")
    print(f"is proper          = {is_proper(edges, improper)}")
    check = coloring_check(improper)
    print(f"passing edges      = {passing_set(edges, check)}")
    frac = accepting_fraction(edges, check)
    print(f"per-round accept   = {frac}  ({float(frac):.4f})")
    print()
    print(f"{'k':>3} | {'survival bound ((|E|-1)/|E|)^k':>32}")
    print("-" * 40)
    for k in (1, 5, 10, 20, 50):
        print(f"{k:>3} | {float(kround_bound(len(edges), k)):>32.12f}")
    print()


def demo_monte_carlo() -> None:
    print("=" * 68)
    print("Monte-Carlo check: empirical survival vs. theoretical bound")
    print("=" * 68)
    random.seed(2026)
    edges: List[Edge] = [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)]
    improper: Coloring = {0: 0, 1: 0, 2: 1, 3: 2, 4: 1}
    check = coloring_check(improper)
    trials = 200_000
    for k in (1, 3, 5):
        survived = 0
        for _ in range(trials):
            # k independent uniform edge challenges; survive iff all pass.
            if all(check(random.choice(edges)) for _ in range(k)):
                survived += 1
        empirical = survived / trials
        bound = float(kround_bound(len(edges), k))
        exact = float(accepting_fraction(edges, check) ** k)
        print(f"k = {k}: empirical = {empirical:.5f}, exact = {exact:.5f}, "
              f"bound = {bound:.5f}, empirical <= bound + noise: "
              f"{empirical <= bound + 0.01}")
    print()


def main() -> None:
    demo_single_round()
    demo_amplification()
    demo_rounds_for_target()
    demo_graph_3coloring()
    demo_monte_carlo()


if __name__ == "__main__":
    main()
