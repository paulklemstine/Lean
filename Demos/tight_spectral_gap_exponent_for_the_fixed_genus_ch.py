"""
Numerical demonstrations for:

    A Cubic Spectral-Gap Witness for Chord-Swap Reconfiguration Chains

The central object is the combinatorial spectral gap of a finite reversible
chain, described variationally as

    gamma = inf_{f non-constant}  E(f, f) / Vr(f),

where the Dirichlet energy and pairwise variation are

    E(f, f) = sum_{x, y} Q(x, y) (f(x) - f(y))^2,
    Vr(f)   = sum_{x, y} (f(x) - f(y))^2.

For the weighted path on vertices {0, ..., n-1} with the position statistic
f(x) = x, we have the exact closed forms

    E(f, f) = 2 (n - 1),
    Vr(f)   = n^2 (n^2 - 1) / 6,
    R(f)    = 12 / (n^2 (n + 1)),

and R(f) is pinched into the cubic window [6 n^{-3}, 12 n^{-3}].

This script verifies each closed form against a direct double-sum computation
using exact rational arithmetic, and illustrates the linear-energy /
quartic-variance / cubic-quotient scaling.

Run:  python demo.py
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, Dict, List, Sequence, Tuple


# --------------------------------------------------------------------------
# Core Rayleigh-quotient calculus (works for any finite weighted graph).
# --------------------------------------------------------------------------

def dirichlet_energy(
    vertices: Sequence[int],
    weight: Callable[[int, int], Fraction],
    f: Callable[[int], Fraction],
) -> Fraction:
    """Dirichlet energy E(f, f) = sum_{x, y} Q(x, y) (f(x) - f(y))^2."""
    total = Fraction(0)
    for x in vertices:
        for y in vertices:
            total += weight(x, y) * (f(x) - f(y)) ** 2
    return total


def pairwise_variation(
    vertices: Sequence[int],
    f: Callable[[int], Fraction],
) -> Fraction:
    """Pairwise variation Vr(f) = sum_{x, y} (f(x) - f(y))^2 (double sum)."""
    total = Fraction(0)
    for x in vertices:
        for y in vertices:
            total += (f(x) - f(y)) ** 2
    return total


def pairwise_variation_closed(
    vertices: Sequence[int],
    f: Callable[[int], Fraction],
) -> Fraction:
    """Vr(f) via the closed form 2 (|V| * sum f^2 - (sum f)^2)."""
    card = Fraction(len(vertices))
    sum_f = sum((f(x) for x in vertices), Fraction(0))
    sum_f2 = sum((f(x) ** 2 for x in vertices), Fraction(0))
    return 2 * (card * sum_f2 - sum_f ** 2)


def rayleigh_quotient(
    vertices: Sequence[int],
    weight: Callable[[int, int], Fraction],
    f: Callable[[int], Fraction],
) -> Fraction:
    """Rayleigh quotient R(f) = E(f, f) / Vr(f) for non-constant f."""
    vr = pairwise_variation(vertices, f)
    if vr == 0:
        raise ValueError("Rayleigh quotient undefined for constant f (Vr = 0).")
    return dirichlet_energy(vertices, weight, f) / vr


# --------------------------------------------------------------------------
# The one-dimensional swap chain: weighted path with position statistic.
# --------------------------------------------------------------------------

def path_weight(x: int, y: int) -> Fraction:
    """Adjacency weight of the path: 1 if |x - y| = 1, else 0."""
    return Fraction(1) if abs(x - y) == 1 else Fraction(0)


def path_witness_exact(n: int) -> Dict[str, Fraction]:
    """Closed-form energy, variance and quotient for the length-n path."""
    energy = Fraction(2 * (n - 1))
    variance = Fraction(n * n * (n * n - 1), 6)
    quotient = Fraction(12, n * n * (n + 1))
    return {"energy": energy, "variance": variance, "quotient": quotient}


def cubic_window(n: int) -> Tuple[Fraction, Fraction]:
    """The pinching interval [6 n^{-3}, 12 n^{-3}] containing R(f)."""
    return Fraction(6, n ** 3), Fraction(12, n ** 3)


# --------------------------------------------------------------------------
# Demonstrations.
# --------------------------------------------------------------------------

def demo_closed_forms(max_n: int = 12) -> None:
    """Verify every closed form against direct double-sum computation."""
    print("=" * 74)
    print("Exact verification of path closed forms (rational arithmetic)")
    print("=" * 74)
    header = f"{'n':>3} | {'E direct':>10} {'E form':>10} | " \
             f"{'Vr direct':>12} {'Vr closed':>12} | {'R(f)':>16}"
    print(header)
    print("-" * len(header))
    for n in range(2, max_n + 1):
        vertices = list(range(n))
        f = lambda x: Fraction(x)  # noqa: E731  (position statistic)
        e_direct = dirichlet_energy(vertices, path_weight, f)
        vr_direct = pairwise_variation(vertices, f)
        vr_closed = pairwise_variation_closed(vertices, f)
        r_direct = rayleigh_quotient(vertices, path_weight, f)
        exact = path_witness_exact(n)

        assert e_direct == exact["energy"], (n, e_direct, exact["energy"])
        assert vr_direct == exact["variance"], (n, vr_direct)
        assert vr_closed == vr_direct, (n, vr_closed, vr_direct)
        assert r_direct == exact["quotient"], (n, r_direct)

        print(f"{n:>3} | {int(e_direct):>10} {int(exact['energy']):>10} | "
              f"{int(vr_direct):>12} {int(vr_closed):>12} | "
              f"{str(exact['quotient']):>16}")
    print("All closed forms match the direct double sums exactly.\n")


def demo_cubic_pinching(ns: Sequence[int] = (2, 4, 8, 16, 32, 64, 128)) -> None:
    """Show R(f) trapped between 6 n^{-3} and 12 n^{-3}, hence Theta(n^-3)."""
    print("=" * 74)
    print("Cubic pinching:  6 n^-3  <=  R(f) = 12/(n^2(n+1))  <=  12 n^-3")
    print("=" * 74)
    print(f"{'n':>5} | {'6 n^-3':>14} | {'R(f)':>14} | {'12 n^-3':>14} | "
          f"{'n^3 * R(f)':>12}")
    print("-" * 74)
    for n in ns:
        lo, hi = cubic_window(n)
        r = path_witness_exact(n)["quotient"]
        assert lo <= r <= hi, (n, lo, r, hi)
        scaled = float(n ** 3 * r)
        print(f"{n:>5} | {float(lo):>14.3e} | {float(r):>14.3e} | "
              f"{float(hi):>14.3e} | {scaled:>12.6f}")
    print("n^3 * R(f) stays inside [6, 12] and tends to 12 as n grows.\n")


def demo_growth_rates(ns: Sequence[int] = (10, 20, 40, 80, 160)) -> None:
    """Illustrate energy Theta(n), variance Theta(n^4), quotient Theta(n^-3)."""
    print("=" * 74)
    print("Growth rates: energy ~ n, variance ~ n^4, quotient ~ n^-3")
    print("=" * 74)
    print(f"{'n':>5} | {'E/n':>10} | {'Vr/n^4':>12} | {'R(f)*n^3':>12}")
    print("-" * 50)
    for n in ns:
        w = path_witness_exact(n)
        e_ratio = float(w["energy"]) / n
        vr_ratio = float(w["variance"]) / n ** 4
        r_scaled = float(w["quotient"]) * n ** 3
        print(f"{n:>5} | {e_ratio:>10.4f} | {vr_ratio:>12.6f} | {r_scaled:>12.6f}")
    print("E/n -> 2, Vr/n^4 -> 1/6, R(f)*n^3 -> 12.\n")


def demo_general_witness() -> None:
    """The single-witness upper bound on a small custom weighted graph."""
    print("=" * 74)
    print("General single-witness gap bound on a 4-cycle")
    print("=" * 74)
    vertices = [0, 1, 2, 3]

    def cycle_weight(x: int, y: int) -> Fraction:
        return Fraction(1) if (x - y) % 4 in (1, 3) else Fraction(0)

    # Two candidate test functions; each certifies gamma <= R(f).
    candidates: List[Tuple[str, Callable[[int], Fraction]]] = [
        ("f(x) = x", lambda x: Fraction(x)),
        ("f = (0,1,0,1)", lambda x: Fraction(x % 2)),
    ]
    best = None
    for name, f in candidates:
        r = rayleigh_quotient(vertices, cycle_weight, f)
        print(f"  witness {name:>14}:  R(f) = {r}  ->  gamma <= {float(r):.4f}")
        best = r if best is None else min(best, r)
    print(f"  best certified upper bound: gamma <= {float(best):.4f}\n")


def main() -> None:
    demo_closed_forms()
    demo_cubic_pinching()
    demo_growth_rates()
    demo_general_witness()
    print("Done. Every closed form verified with exact rational arithmetic.")


if __name__ == "__main__":
    main()
