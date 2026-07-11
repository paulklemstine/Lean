"""
Counterfactual Number Theory: What If Primes Were Random?
=========================================================

Numerical demonstrations of the Cramer random prime model and the
Borel-Cantelli dictionary that governs it.

Main results demonstrated:
  1. The prime-density series sum_n 1/log(n+2) diverges (comparison with the
     harmonic series), so by the second Borel-Cantelli lemma the random prime
     set is INFINITE almost surely.
  2. A subcritical density such as 1/(n+2)^2 is summable, so by the first
     Borel-Cantelli lemma the random prime set is FINITE almost surely.
  3. Monte-Carlo simulation of both regimes, confirming the phase transition.
  4. The true prime density 1/log n tracks the empirical density of the primes,
     validating Cramer's choice.

Self-contained: standard library plus (optional) no external dependencies.
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Tuple


# ---------------------------------------------------------------------------
# Densities
# ---------------------------------------------------------------------------

def cramer_density(n: int) -> float:
    """Cramer prime density p_n = 1 / log(n + 2) (shift avoids log 0, log 1)."""
    return 1.0 / math.log(n + 2)


def harmonic_term(n: int) -> float:
    """Shifted harmonic term 1 / (n + 2), a lower bound for the Cramer density."""
    return 1.0 / (n + 2)


def subcritical_density(n: int) -> float:
    """A summable ('subcritical') density 1 / (n + 2)^2."""
    return 1.0 / (n + 2) ** 2


# ---------------------------------------------------------------------------
# 1. The comparison  1/(n+2) <= 1/log(n+2)
# ---------------------------------------------------------------------------

def verify_comparison(upto: int = 20) -> None:
    """Show term by term that the Cramer density dominates the harmonic term."""
    print("=" * 68)
    print("1. Comparison  1/(n+2) <= 1/log(n+2)   (drives divergence)")
    print("=" * 68)
    print(f"{'n':>4} | {'1/(n+2)':>12} | {'1/log(n+2)':>12} | {'dominates?':>10}")
    print("-" * 68)
    for n in range(upto):
        h, c = harmonic_term(n), cramer_density(n)
        print(f"{n:>4} | {h:>12.6f} | {c:>12.6f} | {str(h <= c + 1e-15):>10}")
    print()


# ---------------------------------------------------------------------------
# 2. Divergence vs. convergence of the density series
# ---------------------------------------------------------------------------

def partial_sum(density: Callable[[int], float], upto: int) -> float:
    return sum(density(n) for n in range(upto))


def compare_partial_sums(cutoffs: List[int]) -> None:
    """Contrast the diverging Cramer series with the converging subcritical one."""
    print("=" * 68)
    print("2. Partial sums of the density series (as the cutoff N grows)")
    print("=" * 68)
    print(f"{'N':>8} | {'sum 1/log(n+2)':>16} | {'sum 1/(n+2)^2':>16}")
    print("-" * 68)
    for N in cutoffs:
        cramer = partial_sum(cramer_density, N)
        sub = partial_sum(subcritical_density, N)
        print(f"{N:>8} | {cramer:>16.6f} | {sub:>16.6f}")
    print()
    print("The Cramer column grows without bound  -> DIVERGES -> infinitely many primes a.s.")
    print("The subcritical column stabilizes      -> CONVERGES -> finitely many primes a.s.")
    print(f"(subcritical limit = sum_{{k>=2}} 1/k^2 = pi^2/6 - 1 "
          f"= {math.pi ** 2 / 6 - 1:.6f})")
    print()


# ---------------------------------------------------------------------------
# 3. Monte-Carlo simulation of the two regimes
# ---------------------------------------------------------------------------

def sample_random_primes(density: Callable[[int], float], upto: int,
                         rng: random.Random) -> List[int]:
    """Draw one random 'prime set' in [0, upto): include n w.p. density(n)."""
    return [n for n in range(upto) if rng.random() < density(n)]


def monte_carlo_counts(density: Callable[[int], float], upto: int,
                       trials: int, seed: int = 0) -> Tuple[float, float]:
    """Return (mean, max) count of random primes over several trials."""
    rng = random.Random(seed)
    counts = [len(sample_random_primes(density, upto, rng)) for _ in range(trials)]
    return sum(counts) / trials, max(counts)


def run_monte_carlo(upto: int = 5000, trials: int = 200) -> None:
    """Empirically confirm: Cramer regime is prolific, subcritical regime is sparse."""
    print("=" * 68)
    print(f"3. Monte-Carlo over [0, {upto}), {trials} trials each")
    print("=" * 68)
    c_mean, c_max = monte_carlo_counts(cramer_density, upto, trials, seed=1)
    s_mean, s_max = monte_carlo_counts(subcritical_density, upto, trials, seed=2)
    print(f"Cramer density 1/log(n+2):   mean # primes = {c_mean:8.2f},  max = {c_max}")
    print(f"Subcritical 1/(n+2)^2:       mean # primes = {s_mean:8.4f},  max = {s_max}")
    print()
    print("As the window grows, the Cramer count grows ~ N/log N (unbounded),")
    print("while the subcritical count saturates near a small constant.")
    print()


# ---------------------------------------------------------------------------
# 4. Cramer density vs. the true primes
# ---------------------------------------------------------------------------

def sieve_primes(upto: int) -> List[int]:
    """Sieve of Eratosthenes: all primes < upto."""
    if upto < 2:
        return []
    is_p = [True] * upto
    is_p[0] = is_p[1] = False
    for i in range(2, int(upto ** 0.5) + 1):
        if is_p[i]:
            for j in range(i * i, upto, i):
                is_p[j] = False
    return [i for i in range(upto) if is_p[i]]


def compare_to_true_primes(cutoffs: List[int]) -> None:
    """Compare pi(N) with the Cramer estimate integral ~ sum 1/log n."""
    print("=" * 68)
    print("4. True prime count pi(N) vs. Cramer estimate sum_{n<N} 1/log(n+2)")
    print("=" * 68)
    print(f"{'N':>8} | {'pi(N)':>10} | {'Cramer sum':>12} | {'N/log N':>12}")
    print("-" * 68)
    for N in cutoffs:
        pi_N = len(sieve_primes(N))
        cramer = partial_sum(cramer_density, N)
        pnt = N / math.log(N) if N > 1 else 0.0
        print(f"{N:>8} | {pi_N:>10} | {cramer:>12.2f} | {pnt:>12.2f}")
    print()
    print("All three columns grow together: Cramer's density 1/log n is a")
    print("faithful model of the empirical prime density.")
    print()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    verify_comparison(upto=15)
    compare_partial_sums([10, 100, 1000, 10_000, 100_000])
    run_monte_carlo(upto=5000, trials=200)
    compare_to_true_primes([100, 1000, 10_000, 100_000])
    print("Conclusion: the infinitude of primes survives randomization")
    print("precisely because the density series sum 1/log n diverges.")


if __name__ == "__main__":
    main()
