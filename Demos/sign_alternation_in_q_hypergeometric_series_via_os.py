"""
Numerical demonstrations for
"Sign Alternation in q-Hypergeometric Series via Oscillatory Asymptotics
 Near Roots of Unity".

This self-contained script illustrates the paper's three central phenomena:

  1. Uniform amplitude dominance forces strict sign alternation with a FINITE
     (here empty) exceptional set.
  2. A degenerate amplitude that vanishes on the perfect squares produces an
     INFINITE exceptional set that nonetheless has natural density ZERO.
  3. The square-counting bound  #{k^2 < N} <= sqrt(N) + 1  and the decay of the
     density ratio below 2 / sqrt(N).

Run with:  python demo.py
"""

from __future__ import annotations

import math
from typing import Callable, List


# --------------------------------------------------------------------------- #
#  Core definitions
# --------------------------------------------------------------------------- #
def is_square(n: int) -> bool:
    """Return True iff the natural number n is a perfect square."""
    if n < 0:
        return False
    r = math.isqrt(n)
    return r * r == n


def sq_amplitude(n: int) -> float:
    """Amplitude A_n that degenerates exactly on the perfect squares."""
    return 0.0 if is_square(n) else 1.0


def sq_coeff(n: int) -> float:
    """The omega = -1 oscillatory coefficient a_n = (-1)^n * A_n."""
    return ((-1) ** n) * sq_amplitude(n)


def alternation_exceptions(a: List[float]) -> List[int]:
    """Indices n in {0,...,len(a)-2} with a[n]*a[n+1] >= 0 (alternation fails)."""
    return [n for n in range(len(a) - 1) if a[n] * a[n + 1] >= 0.0]


def density_ratio(indicator: Callable[[int], bool], N: int) -> float:
    """Empirical density  #{n < N : indicator(n)} / N."""
    if N == 0:
        return 0.0
    return sum(1 for n in range(N) if indicator(n)) / N


# --------------------------------------------------------------------------- #
#  Demo 1: uniform dominance => strict alternation, empty exceptional set
# --------------------------------------------------------------------------- #
def demo_uniform_dominance(N: int = 40, c: float = 3.0) -> None:
    """
    Model a_n = (-1)^n (c + n) + E_n with a small bounded error |E_n| < c + n.
    Lemma 2.1 predicts sign(a_n) = (-1)^n, so the exceptional set is empty.
    """
    print("=" * 70)
    print("DEMO 1  Uniform amplitude dominance  ->  finite (empty) exceptions")
    print("=" * 70)
    # error term: a deterministic wobble strictly smaller than the amplitude.
    a = [((-1) ** n) * (c + n) + 0.5 * math.cos(1.3 * n) for n in range(N)]
    exc = alternation_exceptions(a)
    print(f"first signs : {''.join('+' if x > 0 else '-' for x in a[:24])}")
    print(f"exceptional set below N={N}: {exc}")
    print(f"strictly alternating for all n < {N}: {exc == []}")
    print()


# --------------------------------------------------------------------------- #
#  Demo 2: degenerate amplitude => infinite, density-zero exceptions
# --------------------------------------------------------------------------- #
def demo_degenerate_amplitude(N: int = 2000) -> None:
    """
    Coefficients a_n = (-1)^n A_n with A_n = 0 on squares, else 1.
    Corollary 4.3: exceptional set = {n : n or n+1 is a square}.
    """
    print("=" * 70)
    print("DEMO 2  Degenerate amplitude  ->  infinite BUT density-zero exceptions")
    print("=" * 70)
    a = [sq_coeff(n) for n in range(N)]
    exc = alternation_exceptions(a)

    def in_exc(n: int) -> bool:
        return is_square(n) or is_square(n + 1)

    predicted = [n for n in range(N - 1) if in_exc(n)]
    print(f"exceptional set matches theory prediction: {exc == predicted}")
    print(f"number of exceptions below N={N}: {len(exc)}  (~2*sqrt(N) = "
          f"{2 * math.sqrt(N):.1f})")
    print(f"first few exceptions: {exc[:12]}")
    print("density ratio |E ∩ [0,N)| / N as N grows:")
    for M in (100, 500, 2000, 10000, 50000):
        d = density_ratio(in_exc, M)
        print(f"   N={M:6d}   density={d:.5f}   2/sqrt(N)={2 / math.sqrt(M):.5f}")
    print()


# --------------------------------------------------------------------------- #
#  Demo 3: square-counting bound and density decay
# --------------------------------------------------------------------------- #
def demo_square_counting(N_values: tuple = (10, 100, 1000, 10000, 100000)) -> None:
    """
    Verify  #{k^2 < N} <= sqrt(N) + 1  and that the density decays like 2/sqrt(N).
    """
    print("=" * 70)
    print("DEMO 3  Square-counting bound and density-zero decay")
    print("=" * 70)
    print(f"{'N':>8} {'#squares':>10} {'sqrt(N)+1':>12} {'bound holds':>12} "
          f"{'density':>10}")
    for N in N_values:
        count = sum(1 for n in range(N) if is_square(n))
        bound = math.sqrt(N) + 1
        print(f"{N:>8} {count:>10} {bound:>12.3f} {str(count <= bound):>12} "
              f"{count / N:>10.5f}")
    print()


def main() -> None:
    demo_uniform_dominance()
    demo_degenerate_amplitude()
    demo_square_counting()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
