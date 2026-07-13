"""Numerical demonstrations for the singleton Isolation-Lemma results.

This self-contained script demonstrates, for the *singleton hypergraph* on ``n``
vertices with weights drawn from ``{0, 1, ..., d-1}``:

    1. The exact count of *isolating* assignments (those with a strict minimum
       vertex) equals   n * sum_{j=0}^{d-1} j^(n-1),   matching the Faber-Harris
       lower bound term for term  (Exact Isolation Count).

    2. This exact formula agrees with a brute-force enumeration of all d^n
       assignments (verification on small inputs).

    3. The isolation density  R(n, d) = (#isolating) / d^n  is trapped in the
       fence   1 - n/d  <=  R(n, d)  <=  1,   and tends to 1 as d -> infinity
       (Vanishing-Ties Theorem).

Run directly:  ``python demo.py``
"""

from __future__ import annotations

from itertools import product
from typing import Iterator


# --------------------------------------------------------------------------- #
#  Core quantities
# --------------------------------------------------------------------------- #
def exact_isolating_count(n: int, d: int) -> int:
    """Return the exact number of isolating assignments in ``{0,...,d-1}^n``.

    By the Exact Isolation Count theorem this equals ``n * sum_{j<d} j^(n-1)``.
    """
    if n <= 0 or d <= 0:
        return 0
    power_sum: int = sum(j ** (n - 1) for j in range(d))
    return n * power_sum


def brute_force_isolating_count(n: int, d: int) -> int:
    """Count isolating assignments by exhaustively enumerating ``{0,...,d-1}^n``.

    An assignment ``w`` is isolating iff some coordinate is a *strict* minimum,
    i.e. its unique smallest value is attained by exactly one vertex.
    """
    count: int = 0
    assignments: Iterator[tuple[int, ...]] = product(range(d), repeat=n)
    for w in assignments:
        smallest: int = min(w)
        if w.count(smallest) == 1:
            count += 1
    return count


def isolation_density(n: int, d: int) -> float:
    """Return ``R(n, d) = (#isolating) / d^n``, the probability of a strict min."""
    return exact_isolating_count(n, d) / (d ** n)


def density_fence(n: int, d: int) -> tuple[float, float]:
    """Return the analytic fence ``(1 - n/d, 1.0)`` bracketing ``R(n, d)``."""
    return (1.0 - n / d, 1.0)


def min_range_for_confidence(n: int, epsilon: float) -> int:
    """Smallest ``d`` with ``R(n, d) >= 1 - epsilon``, i.e. ``ceil(n/epsilon)``."""
    from math import ceil

    return ceil(n / epsilon)


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #
def demo_exact_matches_brute_force() -> None:
    """Confirm the closed form matches brute force on small (n, d)."""
    print("=" * 66)
    print("Exact formula  n * sum_{j<d} j^(n-1)  vs. brute-force enumeration")
    print("=" * 66)
    print(f"{'n':>3} {'d':>3} {'exact':>10} {'brute':>10} {'match':>7}")
    for n in range(1, 5):
        for d in range(1, 6):
            exact: int = exact_isolating_count(n, d)
            brute: int = brute_force_isolating_count(n, d)
            ok: str = "OK" if exact == brute else "MISMATCH"
            print(f"{n:>3} {d:>3} {exact:>10} {brute:>10} {ok:>7}")
    print()


def demo_opening_puzzle() -> None:
    """The two-runner, two-number race: exactly half the draws are decisive."""
    print("=" * 66)
    print("Opening puzzle:  n = 2 runners, d = 2 numbers")
    print("=" * 66)
    n, d = 2, 2
    count: int = exact_isolating_count(n, d)
    total: int = d ** n
    print(f"Decisive races: {count} out of {total}  (density = {count/total:.3f})")
    for w in product(range(d), repeat=n):
        smallest = min(w)
        decisive = w.count(smallest) == 1
        tag = "unique winner" if decisive else "TIE (void)"
        print(f"   draw {w}: {tag}")
    print()


def demo_density_tends_to_one() -> None:
    """Show R(n, d) climbing to 1 inside the fence [1 - n/d, 1]."""
    print("=" * 66)
    print("Vanishing-Ties Theorem:  R(n, d) -> 1  inside  [1 - n/d, 1]")
    print("=" * 66)
    for n in (2, 3, 5):
        print(f"\n  n = {n}:")
        print(f"  {'d':>8} {'1 - n/d':>12} {'R(n,d)':>12} {'upper':>8}")
        for d in (10, 100, 1_000, 10_000, 100_000):
            lo, hi = density_fence(n, d)
            r: float = isolation_density(n, d)
            assert lo - 1e-12 <= r <= hi + 1e-12, "R must lie in the fence"
            print(f"  {d:>8} {lo:>12.6f} {r:>12.6f} {hi:>8.3f}")
    print()


def demo_confidence_sizing() -> None:
    """Turn a target isolation confidence into a required weight range d."""
    print("=" * 66)
    print("Design rule:  d >= n / epsilon  guarantees  R(n, d) >= 1 - epsilon")
    print("=" * 66)
    for n in (3, 5, 10):
        for epsilon in (1e-2, 1e-4, 1e-6):
            d: int = min_range_for_confidence(n, epsilon)
            r: float = isolation_density(n, d)
            print(f"  n={n:>2}  eps={epsilon:.0e}  ->  d={d:>9}  "
                  f"R={r:.8f}  (>= {1-epsilon:.8f}? "
                  f"{'yes' if r >= 1 - epsilon else 'no'})")
    print()


def main() -> None:
    demo_opening_puzzle()
    demo_exact_matches_brute_force()
    demo_density_tends_to_one()
    demo_confidence_sizing()


if __name__ == "__main__":
    main()
