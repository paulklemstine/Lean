"""Numerical demonstrations for balancing ratios of circular partitions.

This self-contained script illustrates the two structural theorems for the
balancing ratio of a periodic circular partition:

  1. Windowing monotonicity:   1 <= mu^r <= mu^1   for every window length r.
  2. Full-period balance:      mu^{k*n} = 1         for every k >= 1,
     where n is the period.

A circular partition is described by its finite tuple of arc lengths
(g_0, ..., g_{n-1}), repeated cyclically. All quantities are computed directly
from this tuple with no external dependencies.
"""

from __future__ import annotations

from typing import List, Sequence, Tuple


def window_sum(gaps: Sequence[float], r: int, i: int) -> float:
    """Length of r consecutive arcs starting at cyclic position i.

    W_r(i) = g_i + g_{i+1} + ... + g_{i+r-1}, indices taken modulo the period.
    """
    n = len(gaps)
    return sum(gaps[(i + j) % n] for j in range(r))


def max_min_window(gaps: Sequence[float], r: int) -> Tuple[float, float]:
    """Return (maxwin, minwin): extremal r-window sums over all cyclic starts."""
    n = len(gaps)
    sums = [window_sum(gaps, r, i) for i in range(n)]
    return max(sums), min(sums)


def gap_ratio(gaps: Sequence[float]) -> float:
    """Single-gap ratio mu^1 = g_max / g_min."""
    return max(gaps) / min(gaps)


def window_ratio(gaps: Sequence[float], r: int) -> float:
    """r-window ratio mu^r = maxwin(r) / minwin(r)."""
    hi, lo = max_min_window(gaps, r)
    return hi / lo


def total_length(gaps: Sequence[float]) -> float:
    """Total circumference L = sum of the arc lengths over one period."""
    return sum(gaps)


def balancing_profile(gaps: Sequence[float], r_max: int) -> List[Tuple[int, float]]:
    """Profile of window ratios mu^r for r = 1, ..., r_max."""
    return [(r, window_ratio(gaps, r)) for r in range(1, r_max + 1)]


def demo_uniform() -> None:
    """Uniform partition: mu^r = 1 at every scale."""
    print("=" * 64)
    print("Demo 1: Uniform partition into n equal arcs")
    print("=" * 64)
    n = 6
    gaps = [1.0 / n] * n
    print(f"arcs = {gaps}")
    print(f"single-gap ratio mu^1 = {gap_ratio(gaps):.6f}")
    for r in range(1, 10):
        print(f"  mu^{r} = {window_ratio(gaps, r):.6f}")
    print("All window ratios equal 1: perfect balance at every scale.\n")


def demo_vdc3() -> None:
    """van der Corput three-point partition {1/4, 1/4, 1/2}."""
    print("=" * 64)
    print("Demo 2: van der Corput three-point partition {1/4, 1/4, 1/2}")
    print("=" * 64)
    gaps = [0.25, 0.25, 0.5]
    n = len(gaps)
    print(f"arcs = {gaps}, period n = {n}")
    print(f"g_max = {max(gaps)}, g_min = {min(gaps)}")
    print(f"single-gap ratio mu^1 = {gap_ratio(gaps):.6f}  (benchmark value 2)")
    print("Window-ratio profile:")
    for r, mu in balancing_profile(gaps, 9):
        marker = "   <-- multiple of period: perfect balance" if r % n == 0 else ""
        print(f"  mu^{r} = {mu:.6f}{marker}")
    print()


def demo_monotonicity() -> None:
    """Verify 1 <= mu^r <= mu^1 for a random-looking non-uniform partition."""
    print("=" * 64)
    print("Demo 3: Windowing monotonicity 1 <= mu^r <= mu^1")
    print("=" * 64)
    gaps = [0.10, 0.30, 0.05, 0.20, 0.15, 0.20]
    mu1 = gap_ratio(gaps)
    print(f"arcs = {gaps}")
    print(f"single-gap ratio mu^1 = {mu1:.6f}")
    ok = True
    for r in range(1, 13):
        mu = window_ratio(gaps, r)
        within = 1.0 - 1e-12 <= mu <= mu1 + 1e-12
        ok = ok and within
        print(f"  mu^{r} = {mu:.6f}   {'OK' if within else 'VIOLATION'}")
    print(f"Monotonicity envelope holds for all r: {ok}\n")


def demo_full_period_balance() -> None:
    """Verify mu^{k*n} = 1 for several multiples of the period."""
    print("=" * 64)
    print("Demo 4: Full-period balance mu^{k*n} = 1")
    print("=" * 64)
    gaps = [0.10, 0.30, 0.05, 0.20, 0.15, 0.20]
    n = len(gaps)
    L = total_length(gaps)
    print(f"arcs = {gaps}, period n = {n}, circumference L = {L:.6f}")
    for k in range(1, 6):
        hi, lo = max_min_window(gaps, k * n)
        print(f"  window length {k*n}: maxwin = {hi:.6f}, minwin = {lo:.6f}, "
              f"mu = {hi / lo:.6f}  (expected k*L = {k * L:.6f})")
    print("Every full-period window has identical length k*L: mu = 1.\n")


def main() -> None:
    demo_uniform()
    demo_vdc3()
    demo_monotonicity()
    demo_full_period_balance()


if __name__ == "__main__":
    main()
