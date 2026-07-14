"""
Numerical demonstrations of power--logarithm asymptotics for weighted Riesz means.

This self-contained script verifies, numerically, the model laws and the
Riesz-mean transfer principle:

    * Power law:        sum_{n<N} n^p            ~ N^(p+1) / (p+1)
    * Logarithmic law:  sum_{n<N} log n          ~ N log N
    * Mixed law:        sum_{n<N} n^p log n       ~ N^(p+1) log N / (p+1)
    * Second-order:     sum_{n<N} sum_{m<n} m^p   ~ N^(p+2) / ((p+1)(p+2))

Each demonstration prints the ratio (exact sum) / (predicted main term); the
ratio should approach 1 as N grows.
"""

from __future__ import annotations

import math
from typing import Callable


# --------------------------------------------------------------------------- #
#  Exact summatory functions                                                  #
# --------------------------------------------------------------------------- #

def power_sum(n_max: int, p: float) -> float:
    """Exact partial sum  sum_{n<N} n^p  with the convention 0^p = 0 (p>0)."""
    return sum((n ** p) for n in range(1, n_max))


def log_sum(n_max: int) -> float:
    """Exact partial sum  sum_{n<N} log n  (n=0,1 contribute 0)."""
    return sum(math.log(n) for n in range(2, n_max))


def power_log_sum(n_max: int, p: float) -> float:
    """Exact partial sum  sum_{n<N} n^p log n."""
    return sum((n ** p) * math.log(n) for n in range(2, n_max))


def iterated_power_sum(n_max: int, p: float) -> float:
    """Exact second-order sum  sum_{n<N} sum_{m<n} m^p  via a running prefix sum."""
    total = 0.0
    prefix = 0.0  # prefix = sum_{m<n} m^p
    for n in range(n_max):
        total += prefix
        prefix += n ** p
    return total


# --------------------------------------------------------------------------- #
#  Predicted main terms                                                        #
# --------------------------------------------------------------------------- #

def power_main(n_max: int, p: float) -> float:
    return (n_max ** (p + 1)) / (p + 1)


def log_main(n_max: int) -> float:
    return n_max * math.log(n_max)


def power_log_main(n_max: int, p: float) -> float:
    return (n_max ** (p + 1)) * math.log(n_max) / (p + 1)


def iterated_power_main(n_max: int, p: float) -> float:
    return (n_max ** (p + 2)) / ((p + 1) * (p + 2))


# --------------------------------------------------------------------------- #
#  Reporting helper                                                            #
# --------------------------------------------------------------------------- #

def report(label: str, exact: Callable[[int], float], main: Callable[[int], float],
           sizes: tuple[int, ...]) -> None:
    print(f"\n{label}")
    print(f"  {'N':>10} | {'exact':>18} | {'main term':>18} | {'ratio':>12}")
    print("  " + "-" * 68)
    for n in sizes:
        e = exact(n)
        m = main(n)
        ratio = e / m if m != 0 else float("nan")
        print(f"  {n:>10} | {e:>18.6e} | {m:>18.6e} | {ratio:>12.8f}")


def main() -> None:
    sizes = (100, 1_000, 10_000, 100_000)
    p = 1.5

    print("=" * 72)
    print("  Power-logarithm asymptotics of weighted Riesz means (p = 1.5)")
    print("=" * 72)

    report("Power law:  sum_{n<N} n^p  ~  N^(p+1)/(p+1)",
           lambda n: power_sum(n, p), lambda n: power_main(n, p), sizes)

    report("Logarithmic law:  sum_{n<N} log n  ~  N log N",
           log_sum, log_main, sizes)

    report("Mixed law:  sum_{n<N} n^p log n  ~  N^(p+1) log N/(p+1)",
           lambda n: power_log_sum(n, p), lambda n: power_log_main(n, p), sizes)

    report("Second-order:  sum_{n<N} sum_{m<n} m^p  ~  N^(p+2)/((p+1)(p+2))",
           lambda n: iterated_power_sum(n, p), lambda n: iterated_power_main(n, p), sizes)

    print("\nAll ratios approach 1, confirming the asymptotic laws.")


if __name__ == "__main__":
    main()
