"""
Numerical demonstration of the sharp sqrt(2) Vietoris-Rips threshold for the
standard-basis configuration in R^n.

The canonical configuration is the set of standard basis vectors
    e_1, ..., e_n  in  R^n,
which are pairwise at Euclidean distance exactly sqrt(2).

This script demonstrates, for that configuration:
  * The exact sqrt(2) pairwise geometry.
  * The Vietoris-Rips simplex count:
        n + 1   for every scale r < sqrt(2)   (collapse to vertices),
        2 ** n  at scale r = sqrt(2)          (full power set).
  * The two-sided interleaving localisation of the exponential blow-up.
  * The contrast with the graded rate gamma(c) = (sqrt(2)/c - 1) / (sqrt(2) - 1).

All functions are self-contained and type-hinted. Requires only the standard
library.
"""

from __future__ import annotations

import math
from itertools import combinations, product
from typing import Iterator

SQRT2: float = math.sqrt(2.0)


# ---------------------------------------------------------------------------
# The canonical configuration and its geometry
# ---------------------------------------------------------------------------
def basis_vector(n: int, i: int) -> tuple[float, ...]:
    """Return the i-th standard basis vector e_i of R^n (0-indexed)."""
    return tuple(1.0 if k == i else 0.0 for k in range(n))


def euclidean_distance(x: tuple[float, ...], y: tuple[float, ...]) -> float:
    """Standard l2 distance in R^n."""
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))


def max_pairwise_distance(points: list[tuple[float, ...]]) -> float:
    """Largest pairwise distance among a list of points (0.0 if < 2 points)."""
    if len(points) < 2:
        return 0.0
    return max(euclidean_distance(a, b) for a, b in combinations(points, 2))


# ---------------------------------------------------------------------------
# The Vietoris-Rips complex of the canonical configuration
# ---------------------------------------------------------------------------
def is_vr_simplex(n: int, r: float, subset: tuple[int, ...]) -> bool:
    """True iff every pair in `subset` is within distance r (a VR simplex)."""
    pts = [basis_vector(n, i) for i in subset]
    return max_pairwise_distance(pts) <= r + 1e-12


def vr_complex_count_bruteforce(n: int, r: float) -> int:
    """Count VR simplices by enumerating all 2**n subsets (validation only)."""
    count = 0
    for mask in range(1 << n):
        subset = tuple(i for i in range(n) if (mask >> i) & 1)
        if is_vr_simplex(n, r, subset):
            count += 1
    return count


def vr_complex_count_closed_form(n: int, r: float) -> int:
    """Closed-form simplex count from the Sharp Threshold Theorem."""
    if r + 1e-12 >= SQRT2:
        return 2 ** n
    return n + 1


# ---------------------------------------------------------------------------
# Interleaving envelope (two-sided localisation of the blow-up)
# ---------------------------------------------------------------------------
def interleaving_envelope(n: int, c: float, t: float) -> tuple[int | None, int | None]:
    """
    Provable (lower, upper) envelope on |G(t)| for any c-approximation G.

    lower = 2**n whenever t >= c * sqrt(2)  (completeness at sqrt(2));
    upper = n+1  whenever c * t < sqrt(2)   (soundness below the threshold).
    Either entry is None when the corresponding bound does not apply at t.
    """
    lower = 2 ** n if t + 1e-12 >= c * SQRT2 else None
    upper = n + 1 if c * t < SQRT2 - 1e-12 else None
    return lower, upper


# ---------------------------------------------------------------------------
# The graded rate for contrast
# ---------------------------------------------------------------------------
def gamma(c: float) -> float:
    """Effective graded rate gamma(c) = (sqrt(2)/c - 1)/(sqrt(2) - 1)."""
    return (SQRT2 / c - 1.0) / (SQRT2 - 1.0)


def graded_lower_bound_exponent(n: int, c: float) -> int:
    """Sub-threshold exponent floor(n * gamma(c)) of the graded construction."""
    return math.floor(n * gamma(c))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_exact_geometry(n: int = 5) -> None:
    print(f"[1] Exact sqrt(2) geometry in R^{n}")
    print(f"    sqrt(2) = {SQRT2:.10f}")
    pts = [basis_vector(n, i) for i in range(n)]
    for i, j in combinations(range(n), 2):
        d = euclidean_distance(pts[i], pts[j])
        assert abs(d - SQRT2) < 1e-12
    print(f"    All {n*(n-1)//2} pairwise distances equal sqrt(2): verified.\n")


def demo_sharp_threshold(max_n: int = 8) -> None:
    print("[2] Sharp threshold: simplex count below vs. at sqrt(2)")
    print(f"    {'n':>3} | {'r<sqrt2 (=n+1)':>16} | {'r=sqrt2 (=2^n)':>16} | brute-check")
    print("    " + "-" * 60)
    for n in range(1, max_n + 1):
        below_cf = vr_complex_count_closed_form(n, SQRT2 - 0.01)
        at_cf = vr_complex_count_closed_form(n, SQRT2)
        below_bf = vr_complex_count_bruteforce(n, SQRT2 - 0.01)
        at_bf = vr_complex_count_bruteforce(n, SQRT2)
        ok = (below_cf == below_bf) and (at_cf == at_bf)
        print(f"    {n:>3} | {below_cf:>16} | {at_cf:>16} | {'OK' if ok else 'MISMATCH'}")
    print()


def demo_jump_gap(max_n: int = 12) -> None:
    print("[3] The exponential gap n+1 -> 2^n (strict for n >= 2)")
    for n in range(1, max_n + 1):
        lin, exp = n + 1, 2 ** n
        strict = "strict jump" if lin < exp else "no gap"
        print(f"    n={n:>2}: {lin:>5}  ->  {exp:>8}   ({strict})")
    print()


def demo_interleaving(n: int = 6, c: float = 1.2) -> None:
    print(f"[4] Interleaving envelope for n={n}, c={c}")
    print(f"    c*sqrt(2) = {c*SQRT2:.6f}")
    for t in [0.5, 1.0, SQRT2 / c - 0.05, SQRT2, c * SQRT2, c * SQRT2 + 0.1]:
        lo, hi = interleaving_envelope(n, c, t)
        lo_s = str(lo) if lo is not None else "-"
        hi_s = str(hi) if hi is not None else "-"
        print(f"    t={t:6.3f} :  lower |G(t)| >= {lo_s:>4}   upper |G(t)| <= {hi_s:>4}")
    print("    (below the interleaved threshold: <= n+1; at/above: >= 2^n)\n")


def demo_graded_contrast(n: int = 100) -> None:
    print(f"[5] Contrast with the graded rate gamma(c), n={n}")
    print(f"    {'c':>6} | {'gamma(c)':>10} | {'floor(n*gamma)':>14} | sub-thresh 2^exp")
    print("    " + "-" * 56)
    for c in [1.0, 1.05, 1.1, 1.2, 1.3, 1.4, 1.41]:
        g = gamma(c)
        e = graded_lower_bound_exponent(n, c)
        print(f"    {c:>6.2f} | {g:>10.5f} | {e:>14} | 2^{e}")
    print(f"    gamma -> 0 as c -> sqrt(2) = {SQRT2:.5f}")
    print("    (equidistant standard basis has gamma == 0: no sub-threshold content)\n")


def main() -> None:
    print("=" * 68)
    print(" Sharp sqrt(2) Vietoris-Rips threshold of the standard simplex")
    print("=" * 68 + "\n")
    demo_exact_geometry()
    demo_sharp_threshold()
    demo_jump_gap()
    demo_interleaving()
    demo_graded_contrast()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
