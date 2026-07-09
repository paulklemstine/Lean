"""Numerical demonstrations for the variance of Rademacher random multiplicative
functions in short intervals.

This self-contained script verifies, numerically and by exact enumeration, the
central results:

  (1) Variance identity: for a Rademacher random multiplicative function f and a
      finite set A of integers,
          Var( sum_{n in A} f(n) )  =  #{ n in A : n squarefree }.
      We check this exactly by averaging over all 2^{|P|} sign patterns, where P
      is the set of primes dividing elements of A.

  (2) Orthogonality: E[f(m) f(n)] = 1 if m == n and m squarefree, else 0.

  (3) Squarefree-indicator variance under the uniform law on {1, ..., N}:
          Var_N(chi) = q_N (1 - q_N),  q_N = Q(N)/N,  and q_N -> 6/pi^2.

  (4) Asymptotic normalization: sigma(x,y)^2 = squarefree count in [x, x+y]
      ~ (6/pi^2) y, and the normalized short-interval sum looks Gaussian.

Run:  python demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Dict, Iterable, List, Sequence, Tuple


# --------------------------------------------------------------------------- #
# Basic number theory
# --------------------------------------------------------------------------- #
def prime_factors(n: int) -> List[int]:
    """Return the sorted list of distinct primes dividing n (n >= 1)."""
    factors: List[int] = []
    d = 2
    m = n
    while d * d <= m:
        if m % d == 0:
            factors.append(d)
            while m % d == 0:
                m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors.append(m)
    return factors


def is_squarefree(n: int) -> bool:
    """Return True iff n is squarefree (no prime appears with exponent >= 2)."""
    if n < 1:
        return False
    m = n
    d = 2
    while d * d <= m:
        if m % (d * d) == 0:
            return False
        if m % d == 0:
            m //= d
        else:
            d += 1 if d == 2 else 2
    return True


def squarefree_sieve(limit: int) -> List[bool]:
    """Return sf[0..limit] with sf[n] True iff n is squarefree (n >= 1)."""
    sf = [True] * (limit + 1)
    sf[0] = False
    d = 2
    while d * d <= limit:
        step = d * d
        for k in range(step, limit + 1, step):
            sf[k] = False
        d += 1
    return sf


def squarefree_count(a: int, b: int) -> int:
    """Number of squarefree integers n with a <= n <= b (uses a sieve)."""
    sf = squarefree_sieve(b)
    return sum(1 for n in range(a, b + 1) if sf[n])


# --------------------------------------------------------------------------- #
# The Rademacher random multiplicative function
# --------------------------------------------------------------------------- #
def f_value(n: int, signs: Dict[int, int]) -> int:
    """Evaluate the Rademacher random multiplicative function at n.

    signs maps each prime to +/-1. Returns 0 unless n is squarefree, otherwise
    the product of signs over the distinct primes dividing n.
    """
    if not is_squarefree(n):
        return 0
    prod = 1
    for p in prime_factors(n):
        prod *= signs[p]
    return prod


def primes_dividing(numbers: Iterable[int]) -> List[int]:
    """All distinct primes dividing any element of `numbers`."""
    ps: set[int] = set()
    for n in numbers:
        ps.update(prime_factors(n))
    return sorted(ps)


# --------------------------------------------------------------------------- #
# (1)+(2) Exact variance and orthogonality by full enumeration
# --------------------------------------------------------------------------- #
def exact_variance(A: Sequence[int]) -> float:
    """Exact Var( sum_{n in A} f(n) ) by averaging over all 2^{|P|} sign patterns."""
    P = primes_dividing(A)
    total = 0.0
    total_sq = 0.0
    count = 0
    for pattern in itertools.product((-1, 1), repeat=len(P)):
        signs = dict(zip(P, pattern))
        s = sum(f_value(n, signs) for n in A)
        total += s
        total_sq += s * s
        count += 1
    mean = total / count
    return total_sq / count - mean * mean


def exact_covariance(m: int, n: int) -> float:
    """Exact E[f(m) f(n)] by averaging over all sign patterns on relevant primes."""
    P = primes_dividing((m, n))
    total = 0.0
    count = 0
    for pattern in itertools.product((-1, 1), repeat=len(P)):
        signs = dict(zip(P, pattern))
        total += f_value(m, signs) * f_value(n, signs)
        count += 1
    return total / count


# --------------------------------------------------------------------------- #
# (3) Squarefree-indicator variance under the uniform law
# --------------------------------------------------------------------------- #
def indicator_variance(N: int) -> Tuple[float, float]:
    """Return (empirical Var_N(chi), Bernoulli formula q_N(1-q_N))."""
    sf = squarefree_sieve(N)
    Q = sum(1 for m in range(1, N + 1) if sf[m])
    q = Q / N
    # Var_N(chi) = E[chi^2] - (E chi)^2 = q - q^2 since chi in {0,1}.
    emp = sum((1.0 if sf[m] else 0.0) ** 2 for m in range(1, N + 1)) / N - q * q
    return emp, q * (1.0 - q)


# --------------------------------------------------------------------------- #
# (4) Monte Carlo histogram of the normalized short-interval sum
# --------------------------------------------------------------------------- #
def normalized_interval_samples(x: int, y: int, trials: int, seed: int = 0) -> List[float]:
    """Sample the normalized sum S(x,y)/sigma(x,y) over random sign patterns."""
    rng = random.Random(seed)
    A = list(range(x, x + y + 1))
    P = primes_dividing(A)
    # Precompute the (distinct prime) support of each squarefree n in A.
    supports: List[List[int]] = [prime_factors(n) for n in A if is_squarefree(n)]
    sigma_sq = squarefree_count(x, x + y)  # exact variance from the identity
    sigma = math.sqrt(sigma_sq)
    samples: List[float] = []
    for _ in range(trials):
        signs = {p: (1 if rng.random() < 0.5 else -1) for p in P}
        s = 0
        for supp in supports:
            prod = 1
            for p in supp:
                prod *= signs[p]
            s += prod
        samples.append(s / sigma)
    return samples


def histogram(samples: Sequence[float], bins: int = 11, lo: float = -3.0,
              hi: float = 3.0) -> None:
    """Print a simple ASCII histogram compared with the N(0,1) density."""
    width = (hi - lo) / bins
    counts = [0] * bins
    for s in samples:
        idx = int((s - lo) / width)
        if 0 <= idx < bins:
            counts[idx] += 1
    n = len(samples)
    print(f"  {'center':>7} {'empirical':>10} {'N(0,1)':>9}")
    for i in range(bins):
        center = lo + (i + 0.5) * width
        emp = counts[i] / n / width
        gauss = math.exp(-center * center / 2) / math.sqrt(2 * math.pi)
        bar = "#" * int(emp * 40)
        print(f"  {center:7.2f} {emp:10.4f} {gauss:9.4f}  {bar}")


# --------------------------------------------------------------------------- #
# Driver
# --------------------------------------------------------------------------- #
def main() -> None:
    print("=" * 70)
    print("(1) Variance identity:  Var(sum_{n in A} f(n)) = #squarefree in A")
    print("=" * 70)
    # Intervals are kept small so that the full 2^{|P|} enumeration is feasible;
    # |P| grows with the largest prime in the interval.
    for (a, b) in [(2, 12), (8, 24), (20, 36), (30, 46)]:
        A = list(range(a, b + 1))
        var = exact_variance(A)
        sf = squarefree_count(a, b)
        print(f"  A = [{a}, {b}]:  enumerated Var = {var:8.4f}   "
              f"squarefree count = {sf}   match: {abs(var - sf) < 1e-9}")

    print()
    print("=" * 70)
    print("(2) Orthogonality:  E[f(m) f(n)] = delta_{m,n} * [m squarefree]")
    print("=" * 70)
    pairs = [(6, 6), (6, 10), (12, 12), (7, 7), (15, 21), (30, 30)]
    for (m, n) in pairs:
        cov = exact_covariance(m, n)
        expected = 1.0 if (m == n and is_squarefree(m)) else 0.0
        print(f"  E[f({m}) f({n})] = {cov:6.3f}   expected = {expected:.0f}   "
              f"match: {abs(cov - expected) < 1e-9}")

    print()
    print("=" * 70)
    print("(3) Squarefree-indicator variance:  Var_N(chi) = q_N (1 - q_N)")
    print("=" * 70)
    six_over_pi2 = 6.0 / math.pi ** 2
    for N in [100, 1000, 10000, 100000]:
        emp, formula = indicator_variance(N)
        q = squarefree_count(1, N) / N
        print(f"  N = {N:7d}:  Var = {emp:.6f}   q(1-q) = {formula:.6f}   "
              f"q_N = {q:.5f}  (6/pi^2 = {six_over_pi2:.5f})")

    print()
    print("=" * 70)
    print("(4) Normalized short-interval sum vs. standard Gaussian")
    print("=" * 70)
    x, y, trials = 1000, 400, 15000
    sf = squarefree_count(x, x + y)
    print(f"  interval [{x}, {x + y}]:  sigma^2 = squarefree count = {sf}")
    print(f"  (6/pi^2) * y = {six_over_pi2 * y:.2f}   ratio = {sf / (six_over_pi2 * y):.4f}")
    samples = normalized_interval_samples(x, y, trials)
    mean = sum(samples) / len(samples)
    var = sum((s - mean) ** 2 for s in samples) / len(samples)
    print(f"  sample mean = {mean:+.4f}   sample variance = {var:.4f}  (target ~ 1)")
    histogram(samples)


if __name__ == "__main__":
    main()
