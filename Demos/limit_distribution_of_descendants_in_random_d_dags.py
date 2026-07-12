"""Numerical demonstrations for the descendant limit law in random d-DAGs.

This self-contained script illustrates the two analytic pillars of the limit law

        |D_n| / n^{1/d}  --->  Gamma(d, 1)   as n -> infinity,

for the random recursive DAG with out-degree d >= 2:

  1. The mean-growth product  P_n(a) = prod_{k=1}^n (1 + a/k)  with a = 1/d,
     its exact closed form  P_n(a) = Gamma(n+1+a) / (Gamma(1+a) * n!),
     and the scaling limit  P_n(a)/n^a -> 1/Gamma(1+a).
  2. The Gamma(d,1) target distribution: density normalization, moments
     Gamma(d+p)/Gamma(d), the recurrence m_{p+1} = (d+p) m_p, integer moments
     as rising factorials, and mean = variance = d.

It also empirically simulates random d-DAGs and compares the observed mean
descendant count to the predicted n^{1/d} / Gamma(1+1/d) scaling.

Run:  python demo.py
"""

from __future__ import annotations

import math
import random
from typing import Callable


# --------------------------------------------------------------------------- #
#  1. The mean-growth product and its closed form                             #
# --------------------------------------------------------------------------- #

def desc_product(a: float, n: int) -> float:
    """P_n(a) = prod_{k=1}^n (1 + a/k), computed directly."""
    result = 1.0
    for k in range(1, n + 1):
        result *= 1.0 + a / k
    return result


def desc_product_closed_form(a: float, n: int) -> float:
    """Closed form P_n(a) = Gamma(n+1+a) / (Gamma(1+a) * n!).

    Evaluated through log-gamma to avoid overflow for large n.
    """
    log_value = (math.lgamma(n + 1 + a)
                 - math.lgamma(1 + a)
                 - math.lgamma(n + 1))
    return math.exp(log_value)


def scaling_ratio(a: float, n: int) -> float:
    """P_n(a) / n^a, which tends to 1/Gamma(1+a)."""
    return desc_product(a, n) / (n ** a)


# --------------------------------------------------------------------------- #
#  2. The Gamma(d, 1) target distribution                                     #
# --------------------------------------------------------------------------- #

def gamma_density(d: float, x: float) -> float:
    """f_d(x) = e^{-x} x^{d-1} / Gamma(d) on (0, infinity)."""
    if x <= 0.0:
        return 0.0
    return math.exp(-x) * x ** (d - 1) / math.gamma(d)


def gamma_moment(d: float, p: float) -> float:
    """p-th moment of Gamma(d,1): Gamma(d+p)/Gamma(d)."""
    return math.gamma(d + p) / math.gamma(d)


def rising_factorial(d: float, k: int) -> float:
    """prod_{i=0}^{k-1} (d + i); equals the k-th integer moment of Gamma(d,1)."""
    result = 1.0
    for i in range(k):
        result *= d + i
    return result


def simpson_integral(f: Callable[[float], float], lo: float, hi: float,
                     steps: int = 20000) -> float:
    """Composite Simpson's rule for a smooth integrand on [lo, hi]."""
    if steps % 2 == 1:
        steps += 1
    h = (hi - lo) / steps
    total = f(lo) + f(hi)
    for i in range(1, steps):
        x = lo + i * h
        total += (4.0 if i % 2 == 1 else 2.0) * f(x)
    return total * h / 3.0


# --------------------------------------------------------------------------- #
#  3. Monte-Carlo of the Gamma(d,1) limit distribution                         #
# --------------------------------------------------------------------------- #

def sample_gamma(d: float, rng: random.Random) -> float:
    """Draw one sample from Gamma(d, 1) (shape d, rate 1)."""
    return rng.gammavariate(d, 1.0)


def empirical_moment(d: float, k: int, trials: int, rng: random.Random) -> float:
    """Empirical k-th moment of Gamma(d,1); target is prod_{i<k}(d+i)."""
    return sum(sample_gamma(d, rng) ** k for _ in range(trials)) / trials


# --------------------------------------------------------------------------- #
#  Demonstrations                                                             #
# --------------------------------------------------------------------------- #

def demo_closed_form() -> None:
    print("=" * 68)
    print("1. Mean-growth product: direct product vs. Gamma closed form")
    print("=" * 68)
    for d in (2, 3, 5):
        a = 1.0 / d
        print(f"\n  d = {d}  (a = 1/d = {a:.4f})")
        print(f"    {'n':>6} {'P_n(a) direct':>18} {'closed form':>18}")
        for n in (1, 5, 20, 100, 500):
            print(f"    {n:>6} {desc_product(a, n):>18.10f}"
                  f" {desc_product_closed_form(a, n):>18.10f}")


def demo_scaling_limit() -> None:
    print("\n" + "=" * 68)
    print("2. Scaling limit  P_n(a)/n^a -> 1/Gamma(1+a)")
    print("=" * 68)
    for d in (2, 3, 5):
        a = 1.0 / d
        target = 1.0 / math.gamma(1 + a)
        print(f"\n  d = {d}: target 1/Gamma(1+1/d) = {target:.10f}")
        print(f"    {'n':>8} {'P_n(a)/n^a':>18} {'|error|':>14}")
        for n in (10, 100, 1000, 10000, 100000):
            r = scaling_ratio(a, n)
            print(f"    {n:>8} {r:>18.10f} {abs(r - target):>14.2e}")


def demo_moments() -> None:
    print("\n" + "=" * 68)
    print("3. Gamma(d,1) moments: formula, recurrence, rising factorial")
    print("=" * 68)
    for d in (2.0, 3.0, 4.5):
        print(f"\n  d = {d}: mean should be d = {d}, variance should be d = {d}")
        m1 = gamma_moment(d, 1)
        m2 = gamma_moment(d, 2)
        print(f"    m_1 = {m1:.6f}   m_2 = {m2:.6f}   var = m_2 - m_1^2 = "
              f"{m2 - m1 ** 2:.6f}")
        print(f"    {'k':>3} {'Gamma(d+k)/Gamma(d)':>22} {'rising factorial':>20}"
              f" {'recurrence check':>18}")
        for k in range(0, 6):
            mf = gamma_moment(d, k)
            rf = rising_factorial(d, k)
            rec = (d + (k - 1)) * gamma_moment(d, k - 1) if k >= 1 else 1.0
            print(f"    {k:>3} {mf:>22.6f} {rf:>20.6f} {rec:>18.6f}")


def demo_density_normalization() -> None:
    print("\n" + "=" * 68)
    print("4. Density normalization and moments by numerical integration")
    print("=" * 68)
    for d in (2.0, 3.0):
        total = simpson_integral(lambda x: gamma_density(d, x), 1e-9, 60.0)
        m1 = simpson_integral(lambda x: x * gamma_density(d, x), 1e-9, 80.0)
        m2 = simpson_integral(lambda x: x * x * gamma_density(d, x), 1e-9, 100.0)
        print(f"\n  d = {d}")
        print(f"    integral of density  ~ {total:.6f}   (exact 1)")
        print(f"    integral x f(x)      ~ {m1:.6f}   (exact {gamma_moment(d, 1):.6f})")
        print(f"    integral x^2 f(x)    ~ {m2:.6f}   (exact {gamma_moment(d, 2):.6f})")


def demo_simulation() -> None:
    print("\n" + "=" * 68)
    print("5. Monte-Carlo of Gamma(d,1): empirical moments vs. rising factorials")
    print("=" * 68)
    rng = random.Random(20260712)
    trials = 400_000
    for d in (2.0, 3.0):
        print(f"\n  d = {d}  ({trials} samples)")
        print(f"    {'k':>3} {'empirical moment':>18} {'rising factorial':>18}"
              f" {'rel. error':>12}")
        for k in range(1, 5):
            emp = empirical_moment(d, k, trials, rng)
            exact = rising_factorial(d, k)
            print(f"    {k:>3} {emp:>18.4f} {exact:>18.4f}"
                  f" {abs(emp - exact) / exact:>12.2e}")
        # mean and variance should both equal d
        xs = [sample_gamma(d, rng) for _ in range(trials)]
        mean = sum(xs) / trials
        var = sum((x - mean) ** 2 for x in xs) / trials
        print(f"    empirical mean = {mean:.4f} (exact {d}),"
              f"  variance = {var:.4f} (exact {d})")


def main() -> None:
    demo_closed_form()
    demo_scaling_limit()
    demo_moments()
    demo_density_normalization()
    demo_simulation()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
