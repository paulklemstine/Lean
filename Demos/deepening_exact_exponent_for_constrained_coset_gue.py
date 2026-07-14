"""
Numerical demonstrations for the exact constrained-coset guesswork exponent
at the symmetric (maximal-entropy) source p = 1/2.

Main facts illustrated
----------------------
Let rho > 0 be the guesswork risk parameter. For a candidate set of N = 2^k
equiprobable secrets, the rho-th guesswork moment is the exact average

    M(rho, k) = 2^{-k} * sum_{j=1}^{2^k} j^rho.

The power sum S(rho, 2^j) = sum_{k=1}^{2^j} k^rho is bracketed by

    2^{(j-1)(rho+1)}  <=  S(rho, 2^j)  <=  2^{j(rho+1)}.

Consequently, for a rate-R code family with coset dimension k_m ~ R*m,

    (1/m) log2 M_coset(rho, k_m)  ->  rho * R      as m -> infinity,

and since the Arikan-Merhav exponent at p = 1/2 equals rho, the constrained
exponent is shifted down by exactly rho*(1 - R):

    rho*R = rho - rho*(1 - R).

This script is fully self-contained (standard library only).
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple


# --------------------------------------------------------------------------- #
# Core quantities                                                             #
# --------------------------------------------------------------------------- #

def power_sum(rho: float, n: int) -> float:
    """Exact power sum S(rho, n) = sum_{k=1}^{n} k^rho."""
    total: float = 0.0
    for k in range(1, n + 1):
        total += float(k) ** rho
    return total


def guesswork_moment(rho: float, k: int) -> float:
    """rho-th guesswork moment M(rho, k) = 2^{-k} * S(rho, 2^k)."""
    n: int = 2 ** k
    return (2.0 ** (-k)) * power_sum(rho, n)


def am_exponent(rho: float, p: float) -> float:
    """Arikan-Merhav exponent E(rho, p) = (1+rho) log2(p^s + (1-p)^s), s=1/(1+rho)."""
    s: float = 1.0 / (1.0 + rho)
    inner: float = p ** s + (1.0 - p) ** s
    return (1.0 + rho) * math.log2(inner)


def empirical_rate(rho: float, k_m: int, m: int) -> float:
    """(1/m) log2 M(rho, k_m): the finite-m estimate of the coset exponent."""
    return (1.0 / m) * math.log2(guesswork_moment(rho, k_m))


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #

def demo_am_half() -> None:
    """The Arikan-Merhav exponent at p = 1/2 equals rho."""
    print("=" * 68)
    print("Demo 1:  E(rho, 1/2) = rho   (symmetric-source exponent)")
    print("=" * 68)
    print(f"{'rho':>8} | {'E(rho,1/2)':>14} | {'rho':>10} | {'abs err':>10}")
    print("-" * 52)
    for rho in [0.25, 0.5, 1.0, 2.0, 4.0]:
        e: float = am_exponent(rho, 0.5)
        print(f"{rho:>8.3f} | {e:>14.10f} | {rho:>10.4f} | {abs(e - rho):>10.2e}")
    print()


def demo_sandwich() -> None:
    """Verify 2^{(j-1)(rho+1)} <= S(rho,2^j) <= 2^{j(rho+1)}."""
    print("=" * 68)
    print("Demo 2:  power-sum sandwich  2^{(j-1)(r+1)} <= S <= 2^{j(r+1)}")
    print("=" * 68)
    rho: float = 1.5
    print(f"rho = {rho}")
    print(f"{'j':>3} | {'lower':>16} | {'S(rho,2^j)':>16} | {'upper':>16} | ok")
    print("-" * 66)
    for j in range(1, 12):
        lower: float = 2.0 ** ((j - 1) * (rho + 1.0))
        s: float = power_sum(rho, 2 ** j)
        upper: float = 2.0 ** (j * (rho + 1.0))
        ok: bool = lower <= s <= upper
        print(f"{j:>3} | {lower:>16.4e} | {s:>16.4e} | {upper:>16.4e} | {ok}")
    print()


def demo_rate_convergence() -> None:
    """(1/m) log2 M_coset(rho, floor(R m)) -> rho * R."""
    print("=" * 68)
    print("Demo 3:  coset rate convergence   (1/m) log2 M  ->  rho * R")
    print("=" * 68)
    rho: float = 1.0
    R: float = 0.6
    target: float = rho * R
    print(f"rho = {rho}, R = {R}, target rho*R = {target}")
    print(f"{'m':>4} | {'k_m':>4} | {'(1/m)log2 M':>14} | {'target':>10} | {'gap':>10}")
    print("-" * 56)
    for m in [4, 8, 12, 16, 20, 24]:
        k_m: int = int(math.floor(R * m))
        if k_m < 1:
            continue
        rate: float = empirical_rate(rho, k_m, m)
        print(f"{m:>4} | {k_m:>4} | {rate:>14.6f} | {target:>10.4f} | {rate - target:>10.2e}")
    print()


def demo_exact_shift() -> None:
    """The unconstrained (R=1) minus constrained rate equals rho*(1-R)."""
    print("=" * 68)
    print("Demo 4:  exact exponent shift   rho - rho*R = rho*(1 - R)")
    print("=" * 68)
    rho: float = 2.0
    m: int = 22
    print(f"rho = {rho}, block length m = {m}")
    print(f"{'R':>6} | {'coset rate':>12} | {'rho*R':>10} | "
          f"{'shift rho(1-R)':>16} | {'rho - rate':>12}")
    print("-" * 68)
    unconstrained: float = empirical_rate(rho, m, m)  # R = 1
    for R in [0.2, 0.4, 0.6, 0.8, 1.0]:
        k_m: int = int(math.floor(R * m))
        rate: float = empirical_rate(rho, k_m, m)
        print(f"{R:>6.2f} | {rate:>12.6f} | {rho * R:>10.4f} | "
              f"{rho * (1.0 - R):>16.4f} | {unconstrained - rate:>12.6f}")
    print()


def demo_summary_table() -> Tuple[List[float], List[float]]:
    """Return (rho values, |E(rho,1/2)-rho|) for programmatic checking."""
    rhos: List[float] = [0.5, 1.0, 2.0, 3.0]
    errs: List[float] = [abs(am_exponent(r, 0.5) - r) for r in rhos]
    return rhos, errs


def main() -> None:
    demo_am_half()
    demo_sandwich()
    demo_rate_convergence()
    demo_exact_shift()
    rhos, errs = demo_summary_table()
    assert max(errs) < 1e-9, "E(rho,1/2) should equal rho"
    print("All internal checks passed:  E(rho,1/2) = rho to within 1e-9.")


if __name__ == "__main__":
    main()
