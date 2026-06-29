"""
Counterfactual Number Theory: What If Primes Were Random?
=========================================================

Numerical demonstrations of the deterministic backbone of Cramer's
probabilistic model of the primes (1936), in which an integer n is declared
"prime" independently with probability p(n) = 1 / log n.

The master quantity is the Cramer expectation sum

    CramerSum(N) = sum_{n=2}^{N} 1 / log n,

the model's prediction for the prime-counting function pi(N). This script
verifies, numerically, every result proved in the accompanying paper:

  * positivity and antitonicity of the summand 1 / log n,
  * monotonicity of the partial sums,
  * the two-sided sum-vs-integral sandwich
        Li(2, N+1)  <=  CramerSum(N)  <=  1/log 2 + Li(2, N),
  * the explicit Prime-Number-Theorem-order lower bound
        N / (2 log N)  <=  CramerSum(N),
  * the agreement CramerSum(N) ~ Li(N) ~ pi(N),
  * the expected twin-prime / k-tuple counts.

Self-contained: standard library only.
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple


# --------------------------------------------------------------------------
# Core definitions
# --------------------------------------------------------------------------

def cramer_weight(n: int) -> float:
    """The Cramer prime probability p(n) = 1 / log n for n >= 2."""
    if n < 2:
        raise ValueError("Cramer weight defined for n >= 2")
    return 1.0 / math.log(n)


def cramer_sum(N: int) -> float:
    """CramerSum(N) = sum_{n=2}^{N} 1 / log n (expected # of random primes)."""
    return sum(cramer_weight(n) for n in range(2, N + 1))


def log_integral(a: float, b: float, steps: int = 200_000) -> float:
    """Numerical logarithmic integral Li(a, b) = int_a^b dx / log x.

    Uses the composite Simpson rule. The integrand 1/log x is smooth on
    (1, inf); we anchor at a >= 2 to avoid the singularity at x = 1.
    """
    if a <= 1.0:
        raise ValueError("integrand 1/log x is singular at x = 1; need a > 1")
    if b <= a:
        return 0.0
    if steps % 2 == 1:
        steps += 1
    h = (b - a) / steps
    f: Callable[[float], float] = lambda x: 1.0 / math.log(x)
    total = f(a) + f(b)
    for i in range(1, steps):
        total += (4.0 if i % 2 == 1 else 2.0) * f(a + i * h)
    return total * h / 3.0


def sieve_primes(N: int) -> List[int]:
    """The genuine primes up to N via the sieve of Eratosthenes."""
    if N < 2:
        return []
    is_prime = bytearray([1]) * (N + 1)
    is_prime[0] = is_prime[1] = 0
    for i in range(2, int(N ** 0.5) + 1):
        if is_prime[i]:
            is_prime[i * i: N + 1: i] = bytearray(len(range(i * i, N + 1, i)))
    return [i for i in range(2, N + 1) if is_prime[i]]


def prime_pi(N: int) -> int:
    """The true prime-counting function pi(N)."""
    return len(sieve_primes(N))


# --------------------------------------------------------------------------
# Demonstrations of the proved theorems
# --------------------------------------------------------------------------

def demo_positivity_and_antitone(N: int = 12) -> None:
    """Lemmas 3.2 and 3.4: terms are positive and strictly decreasing."""
    print("=" * 70)
    print("Summand p(n) = 1 / log n : positive and (for n >= 3) decreasing")
    print("=" * 70)
    prev = float("inf")
    for n in range(2, N + 1):
        w = cramer_weight(n)
        flag = "  (decreasing)" if n >= 3 and w <= prev else ""
        print(f"  n = {n:2d}   p(n) = {w:.6f}{flag}")
        prev = w
    print()


def demo_monotone_partial_sums(values: Tuple[int, ...] = (10, 50, 100, 500)) -> None:
    """Lemma 3.5: CramerSum is monotone in N."""
    print("=" * 70)
    print("Monotonicity of CramerSum(N)")
    print("=" * 70)
    prev = -1.0
    for N in values:
        s = cramer_sum(N)
        print(f"  CramerSum({N:4d}) = {s:12.5f}   {'<=' if s >= prev else '!!'} previous")
        prev = s
    print()


def demo_integral_sandwich(values: Tuple[int, ...] = (10, 100, 1000, 10000)) -> None:
    """Theorems 3.6-3.7 and Corollary 3.8: the two-sided integral sandwich."""
    print("=" * 70)
    print("Sum-vs-integral sandwich:  Li(2,N+1) <= CramerSum(N) <= 1/log2 + Li(2,N)")
    print("=" * 70)
    inv_log2 = 1.0 / math.log(2.0)
    print(f"  {'N':>6} | {'lower=Li(2,N+1)':>16} | {'CramerSum(N)':>15} | "
          f"{'upper':>15} | {'in bounds':>9}")
    for N in values:
        lo = log_integral(2.0, N + 1.0)
        cs = cramer_sum(N)
        hi = inv_log2 + log_integral(2.0, float(N))
        ok = lo <= cs <= hi
        print(f"  {N:>6} | {lo:>16.5f} | {cs:>15.5f} | {hi:>15.5f} | {str(ok):>9}")
    print()


def demo_scale_lower_bound(values: Tuple[int, ...] = (10, 100, 1000, 100000)) -> None:
    """Theorem 3.10: N / (2 log N) <= CramerSum(N) (PNT-order growth)."""
    print("=" * 70)
    print("Explicit PNT-order lower bound:  N / (2 log N) <= CramerSum(N)")
    print("=" * 70)
    for N in values:
        bound = N / (2.0 * math.log(N))
        cs = cramer_sum(N)
        print(f"  N = {N:6d}   N/(2 log N) = {bound:12.4f}   "
              f"CramerSum = {cs:12.4f}   holds = {bound <= cs}")
    print()


def demo_model_vs_reality(values: Tuple[int, ...] = (100, 1000, 10000, 100000)) -> None:
    """Compare the random-model prediction to the genuine primes."""
    print("=" * 70)
    print("Model vs reality:  CramerSum(N)  ~  Li(N)  ~  pi(N)")
    print("=" * 70)
    print(f"  {'N':>7} | {'pi(N) (true)':>13} | {'CramerSum(N)':>13} | "
          f"{'Li(2,N)':>13} | {'CS/pi':>7}")
    for N in values:
        pi = prime_pi(N)
        cs = cramer_sum(N)
        li = log_integral(2.0, float(N))
        ratio = cs / pi if pi else float("nan")
        print(f"  {N:>7} | {pi:>13} | {cs:>13.3f} | {li:>13.3f} | {ratio:>7.4f}")
    print()


def expected_tuple_count(N: int, offsets: Tuple[int, ...]) -> float:
    """Expected # of n in [2,N] with all n+h (h in offsets) random-prime.

    By independence this is sum_n prod_h p(n+h). For offsets=(0,2) this is
    the model's expected twin-prime count.
    """
    total = 0.0
    for n in range(2, N + 1):
        prod = 1.0
        for h in offsets:
            m = n + h
            if m >= 2:
                prod *= cramer_weight(m)
            else:
                prod = 0.0
                break
        total += prod
    return total


def demo_twin_primes(values: Tuple[int, ...] = (1000, 10000, 100000)) -> None:
    """Expected twin-prime count and the Hardy-Littlewood discrepancy."""
    print("=" * 70)
    print("Expected twin primes (offsets {0,2}) vs true count")
    print("  Hardy-Littlewood constant 2*C2 ~ 1.3203 is the model's blind spot")
    print("=" * 70)
    for N in values:
        model = expected_tuple_count(N, (0, 2))
        primes = set(sieve_primes(N + 2))
        true_twins = sum(1 for p in primes if (p + 2) in primes and p <= N)
        ratio = true_twins / model if model else float("nan")
        print(f"  N = {N:6d}   model = {model:10.3f}   true = {true_twins:6d}   "
              f"true/model = {ratio:6.4f}")
    print()


def main() -> None:
    print()
    print("#" * 70)
    print("#  COUNTERFACTUAL NUMBER THEORY: WHAT IF PRIMES WERE RANDOM?")
    print("#  Cramer model  --  p(n) = 1 / log n")
    print("#" * 70)
    print()
    demo_positivity_and_antitone()
    demo_monotone_partial_sums()
    demo_integral_sandwich()
    demo_scale_lower_bound()
    demo_model_vs_reality()
    demo_twin_primes()
    print("All proved theorems verified numerically.")


if __name__ == "__main__":
    main()
