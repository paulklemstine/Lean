"""
Numerical demonstrations for the analytic backbone of the
Fyodorov-Hiary-Keating (FHK) conjecture.

This standalone script illustrates the core results:

  * The standard Gumbel law  G(x) = exp(-exp(-x))  is a valid CDF, with density
    g(x) = exp(-x - exp(-x)) that integrates to 1 and has median -log(log 2).
  * Max-stability:  G(x + log n)^n = G(x)  exactly.
  * Extreme-value convergence:  (1 - e^{-x}/n)^n -> G(x)  as n -> infinity
    (recentered maximum of n i.i.d. Exp(1) variables).
  * The location-scale family  G_{mu,beta}(x) = exp(-exp(-(x-mu)/beta))
    with scaled max-stability  G_{mu,beta}(x + beta log n)^n = G_{mu,beta}(x).
  * The sum of two independent Gumbel variables (the FHK limiting law), via
    Monte-Carlo sampling.

No third-party dependencies are required.
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Tuple


# --------------------------------------------------------------------------- #
#  Core definitions
# --------------------------------------------------------------------------- #
def gumbel_cdf(x: float) -> float:
    """Standard Gumbel cumulative distribution function G(x) = exp(-exp(-x))."""
    return math.exp(-math.exp(-x))


def gumbel_pdf(x: float) -> float:
    """Standard Gumbel probability density g(x) = exp(-x - exp(-x))."""
    return math.exp(-x - math.exp(-x))


def gumbel_cdf_ls(mu: float, beta: float, x: float) -> float:
    """Location-scale Gumbel CDF G_{mu,beta}(x) = exp(-exp(-(x-mu)/beta))."""
    return math.exp(-math.exp(-(x - mu) / beta))


# --------------------------------------------------------------------------- #
#  1. G is a valid CDF
# --------------------------------------------------------------------------- #
def demo_valid_cdf() -> None:
    print("=" * 70)
    print("1. The Gumbel CDF G(x) = exp(-exp(-x)) is a valid distribution")
    print("=" * 70)
    xs = [-4.0, -2.0, 0.0, 2.0, 4.0, 8.0]
    print(f"{'x':>6} | {'G(x)':>12} | 0<G<1 | monotone")
    prev = -1.0
    for x in xs:
        val = gumbel_cdf(x)
        mono = val > prev
        prev = val
        print(f"{x:>6.1f} | {val:>12.8f} | {0 < val < 1!s:>5} | {mono!s}")
    print(f"limit x->-inf : G(-40) = {gumbel_cdf(-40):.3e}  (-> 0)")
    print(f"limit x->+inf : G( 40) = {gumbel_cdf(40):.8f}  (-> 1)")
    median_pt = -math.log(math.log(2.0))
    print(f"median: G(-log(log 2)) = G({median_pt:.6f}) = {gumbel_cdf(median_pt):.8f}"
          "  (should be 0.5)")
    print()


# --------------------------------------------------------------------------- #
#  2. The density integrates to 1
# --------------------------------------------------------------------------- #
def numerical_integral(f: Callable[[float], float],
                       lo: float, hi: float, steps: int = 200_000) -> float:
    """Composite trapezoidal rule."""
    h = (hi - lo) / steps
    total = 0.5 * (f(lo) + f(hi))
    for i in range(1, steps):
        total += f(lo + i * h)
    return total * h


def demo_density_normalized() -> None:
    print("=" * 70)
    print("2. The Gumbel density g(x) = exp(-x - exp(-x)) integrates to 1")
    print("=" * 70)
    integral = numerical_integral(gumbel_pdf, -30.0, 40.0)
    print(f"integral_{{-30}}^{{40}} g(x) dx = {integral:.8f}  (should be 1)")
    # g is the derivative of G: finite-difference check
    h = 1e-6
    for x in (-1.0, 0.0, 1.5):
        deriv = (gumbel_cdf(x + h) - gumbel_cdf(x - h)) / (2 * h)
        print(f"x={x:>5.1f}:  G'(x) ~= {deriv:.8f}   g(x) = {gumbel_pdf(x):.8f}")
    print()


# --------------------------------------------------------------------------- #
#  3. Max-stability
# --------------------------------------------------------------------------- #
def demo_max_stability() -> None:
    print("=" * 70)
    print("3. Max-stability:  G(x + log n)^n = G(x)  (exact identity)")
    print("=" * 70)
    print(f"{'n':>6} | {'x':>5} | {'G(x+log n)^n':>16} | {'G(x)':>12} | err")
    for n in (2, 5, 20, 100, 1000):
        for x in (-1.0, 0.5):
            lhs = gumbel_cdf(x + math.log(n)) ** n
            rhs = gumbel_cdf(x)
            print(f"{n:>6} | {x:>5.1f} | {lhs:>16.10f} | {rhs:>12.10f} | "
                  f"{abs(lhs - rhs):.2e}")
    print()


# --------------------------------------------------------------------------- #
#  4. Extreme-value convergence of maxima of Exp(1)
# --------------------------------------------------------------------------- #
def demo_extreme_value_convergence() -> None:
    print("=" * 70)
    print("4. Fisher-Tippett-Gnedenko:  (1 - e^{-x}/n)^n -> G(x)")
    print("=" * 70)
    print(f"{'n':>8} | {'(1 - e^-x / n)^n':>18} | {'G(x)':>12} | err   (x=0.7)")
    x = 0.7
    target = gumbel_cdf(x)
    for n in (10, 100, 1_000, 10_000, 100_000):
        approx = (1.0 - math.exp(-x) / n) ** n
        print(f"{n:>8} | {approx:>18.10f} | {target:>12.10f} | "
              f"{abs(approx - target):.2e}")
    print()


def demo_empirical_maxima(n: int = 500, trials: int = 40_000,
                          seed: int = 12345) -> None:
    """Monte-Carlo: recentered max of n i.i.d. Exp(1) matches Gumbel."""
    print("=" * 70)
    print(f"4b. Monte-Carlo: recentered max of n={n} Exp(1) vs Gumbel CDF")
    print("=" * 70)
    rng = random.Random(seed)
    samples: List[float] = []
    for _ in range(trials):
        m = max(-math.log(rng.random()) for _ in range(n))  # Exp(1) via inverse
        samples.append(m - math.log(n))
    samples.sort()
    print(f"{'x':>6} | {'empirical CDF':>14} | {'G(x)':>12} | err")
    for x in (-1.0, 0.0, 1.0, 2.0, 3.0):
        emp = sum(1 for s in samples if s <= x) / trials
        print(f"{x:>6.1f} | {emp:>14.6f} | {gumbel_cdf(x):>12.6f} | "
              f"{abs(emp - gumbel_cdf(x)):.3e}")
    print()


# --------------------------------------------------------------------------- #
#  5. Location-scale family and scaled max-stability
# --------------------------------------------------------------------------- #
def demo_location_scale() -> None:
    print("=" * 70)
    print("5. Location-scale family G_{mu,beta} and scaled max-stability")
    print("=" * 70)
    mu, beta = 2.0, 1.5
    print(f"parameters: mu={mu}, beta={beta}")
    print(f"{'n':>6} | {'x':>5} | {'G(x+beta log n)^n':>18} | {'G(x)':>12} | err")
    for n in (3, 25, 400):
        for x in (0.0, 3.0):
            lhs = gumbel_cdf_ls(mu, beta, x + beta * math.log(n)) ** n
            rhs = gumbel_cdf_ls(mu, beta, x)
            print(f"{n:>6} | {x:>5.1f} | {lhs:>18.10f} | {rhs:>12.10f} | "
                  f"{abs(lhs - rhs):.2e}")
    print()


# --------------------------------------------------------------------------- #
#  6. Sum of two independent Gumbels: the FHK limiting law
# --------------------------------------------------------------------------- #
def sample_gumbel(rng: random.Random) -> float:
    """Inverse-transform sampling: G^{-1}(u) = -log(-log u)."""
    u = rng.random()
    return -math.log(-math.log(u))


def demo_sum_of_two_gumbels(trials: int = 200_000, seed: int = 999) -> None:
    print("=" * 70)
    print("6. The FHK limiting law: sum of two independent Gumbel variables")
    print("=" * 70)
    rng = random.Random(seed)
    data: List[float] = [sample_gumbel(rng) + sample_gumbel(rng)
                         for _ in range(trials)]
    mean = sum(data) / trials
    var = sum((d - mean) ** 2 for d in data) / trials
    # Mean of one Gumbel = Euler-Mascheroni gamma; variance = pi^2/6.
    gamma = 0.5772156649015329
    print(f"sample mean      = {mean:.5f}   (theory 2*gamma = {2 * gamma:.5f})")
    print(f"sample variance  = {var:.5f}   (theory 2*pi^2/6 = "
          f"{2 * math.pi ** 2 / 6:.5f})")
    data.sort()
    for q in (0.1, 0.5, 0.9):
        idx = min(int(q * trials), trials - 1)
        print(f"empirical {int(q*100):>2}% quantile = {data[idx]:.5f}")
    print()


def main() -> None:
    demo_valid_cdf()
    demo_density_normalized()
    demo_max_stability()
    demo_extreme_value_convergence()
    demo_empirical_maxima()
    demo_location_scale()
    demo_sum_of_two_gumbels()


if __name__ == "__main__":
    main()
