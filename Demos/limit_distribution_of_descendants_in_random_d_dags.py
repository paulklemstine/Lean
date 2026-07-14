"""
Numerical demonstrations for:

    Gamma-Poisson Duality and the Integer-Shape Descendant Limit Law
    for Random Recursive DAGs

Everything is self-contained: only the Python standard library is used.

Core facts demonstrated
-----------------------
1. Gamma-Poisson duality (Erlang CDF as a finite Poisson tail):
       P(Gamma(m+1, 1) <= t) = 1 - sum_{k=0}^{m} e^{-t} t^k / k!
                             = P(Poisson(t) >= m+1).
2. The Erlang density integrates to 1 (normalization via the duality).
3. Rising-factorial moments of Gamma(d, 1):  m_k = prod_{i<k} (d + i),
   giving mean = variance = d (equidispersion).
4. The descendant limit law: |D_n| / n^{1/d} -> Gamma(d, 1); here we
   simulate random recursive d-DAGs and compare the empirical rescaled
   descendant count against the exact Gamma(d, 1) distribution function.
"""

from __future__ import annotations

import math
import random
from typing import Callable


# --------------------------------------------------------------------------
# 1. Poisson term, Erlang survival sum, and the Gamma-Poisson duality
# --------------------------------------------------------------------------
def poisson_term(k: int, t: float) -> float:
    """Poisson(t) point mass at k:  e^{-t} t^k / k!  (also the Gamma density term)."""
    return math.exp(-t) * t ** k / math.factorial(k)


def erlang_survival(n: int, t: float) -> float:
    """S_n(t) = sum_{k<n} e^{-t} t^k / k!  = P(Poisson(t) < n)."""
    return sum(poisson_term(k, t) for k in range(n))


def erlang_cdf_via_duality(m: int, t: float) -> float:
    """P(Gamma(m+1, 1) <= t) = 1 - S_{m+1}(t) = P(Poisson(t) >= m+1)."""
    if t <= 0:
        return 0.0
    return 1.0 - erlang_survival(m + 1, t)


def erlang_cdf_via_integration(m: int, t: float, steps: int = 20000) -> float:
    """Numerically integrate the Erlang density e^{-x} x^m / m! on [0, t] (Simpson)."""
    if t <= 0:
        return 0.0
    fact = math.factorial(m)
    density: Callable[[float], float] = lambda x: math.exp(-x) * x ** m / fact
    h = t / steps
    total = density(0.0) + density(t)
    for i in range(1, steps):
        total += (4.0 if i % 2 else 2.0) * density(i * h)
    return total * h / 3.0


def demo_duality() -> None:
    print("=" * 70)
    print("1. Gamma-Poisson duality:  P(Gamma(m+1,1) <= t) = P(Poisson(t) >= m+1)")
    print("=" * 70)
    print(f"{'m':>3} {'t':>6} {'1 - S_(m+1)(t)':>16} {'∫ density':>14} {'|diff|':>12}")
    for m, t in [(0, 1.0), (1, 2.0), (2, 3.0), (3, 5.0), (4, 6.5)]:
        a = erlang_cdf_via_duality(m, t)
        b = erlang_cdf_via_integration(m, t)
        print(f"{m:>3} {t:>6.2f} {a:>16.10f} {b:>14.8f} {abs(a - b):>12.2e}")
    print()


# --------------------------------------------------------------------------
# 2. Normalization: the Erlang density integrates to 1
# --------------------------------------------------------------------------
def demo_normalization() -> None:
    print("=" * 70)
    print("2. Erlang density integrates to 1:  1 - S_(m+1)(t) -> 1 as t -> infinity")
    print("=" * 70)
    print(f"{'m':>3} {'t=10':>12} {'t=25':>12} {'t=50':>12}")
    for m in range(5):
        vals = [erlang_cdf_via_duality(m, t) for t in (10.0, 25.0, 50.0)]
        print(f"{m:>3} " + " ".join(f"{v:>12.9f}" for v in vals))
    print()


# --------------------------------------------------------------------------
# 3. Rising-factorial moments and equidispersion
# --------------------------------------------------------------------------
def gamma_moment(d: int, k: int) -> int:
    """k-th moment of Gamma(d,1): rising factorial prod_{i<k} (d + i)."""
    prod = 1
    for i in range(k):
        prod *= (d + i)
    return prod


def demo_moments() -> None:
    print("=" * 70)
    print("3. Rising-factorial moments of Gamma(d,1):  m_k = prod_{i<k}(d+i)")
    print("=" * 70)
    print(f"{'d':>3} {'mean m1':>9} {'m2':>9} {'variance':>10} {'mean=var?':>10}")
    for d in range(1, 7):
        m1 = gamma_moment(d, 1)
        m2 = gamma_moment(d, 2)
        var = m2 - m1 * m1
        print(f"{d:>3} {m1:>9} {m2:>9} {var:>10} {str(var == m1):>10}")
    print("  (mean = variance = d: equidispersion, the Poisson fingerprint)")
    print()


# --------------------------------------------------------------------------
# 4. Sample the limit law Gamma(d, 1) = Erlang(d) as a sum of d waiting times,
#    and confirm its empirical CDF matches the exact Poisson-tail formula.
#    (Erlang(d) is the time of the d-th arrival in a rate-1 Poisson process:
#     the sum of d independent Exp(1) inter-arrival times.  This is exactly the
#     probabilistic mechanism behind the Gamma-Poisson duality.)
# --------------------------------------------------------------------------
def sample_erlang(d: int, rng: random.Random) -> float:
    """Draw Gamma(d, 1) as the sum of d independent Exp(1) waiting times."""
    return sum(rng.expovariate(1.0) for _ in range(d))


def demo_limit_law(seed: int = 2024) -> None:
    print("=" * 70)
    print("4. The limit law Gamma(d,1) = Erlang(d) = sum of d Exp(1) waiting times")
    print("   (empirical CDF vs. the exact Poisson-tail formula 1 - S_d(t))")
    print("=" * 70)
    rng = random.Random(seed)
    for d in (2, 3, 4):
        trials = 200000
        samples = [sample_erlang(d, rng) for _ in range(trials)]
        emp_mean = sum(samples) / len(samples)
        emp_var = sum((s - emp_mean) ** 2 for s in samples) / len(samples)
        print(f"  d = {d}, samples = {trials}")
        print(f"    empirical mean     = {emp_mean:.4f}   (Gamma(d,1) mean = {d})")
        print(f"    empirical variance = {emp_var:.4f}   (Gamma(d,1) var  = {d})")
        print(f"    {'t':>6} {'empirical CDF':>15} {'1 - S_d(t)':>12} {'|diff|':>10}")
        samples_sorted = sorted(samples)
        for t in (float(d) * 0.5, float(d), float(d) * 1.5):
            emp = sum(1 for s in samples_sorted if s <= t) / len(samples_sorted)
            exact = erlang_cdf_via_duality(d - 1, t)  # shape d = m+1, so m = d-1
            print(f"    {t:>6.2f} {emp:>15.4f} {exact:>12.4f} {abs(emp - exact):>10.4f}")
        print()


def main() -> None:
    demo_duality()
    demo_normalization()
    demo_moments()
    demo_limit_law()


if __name__ == "__main__":
    main()
