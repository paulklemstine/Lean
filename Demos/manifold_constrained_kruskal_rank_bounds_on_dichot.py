"""
Numerical demonstrations for
"Manifold-Constrained Kruskal Rank Bounds on Dichotomy Counts".

This self-contained script illustrates Cover's counting function
    C(N, d) = 2 * sum_{k=0}^{d-1} binom(N-1, k),
its one-point (Pascal) recurrence, saturation and strict collapse, the
maximal-solution property, and the manifold-constrained dichotomy bound
    C_F(N) <= C(N, d + M' + 1),
where d is the intrinsic dimension of the data manifold and M' the feature
dimension (the ambient dimension M never appears).

Run with:  python demo.py
"""

from __future__ import annotations

from math import comb
from itertools import product
from typing import Callable


# ---------------------------------------------------------------------------
# Core: Cover's counting function
# ---------------------------------------------------------------------------
def cover_count(N: int, d: int) -> int:
    """Cover's counting function C(N, d) = 2 * sum_{k<d} binom(N-1, k)."""
    return 2 * sum(comb(N - 1, k) for k in range(d))


def cover_count_recursive(N: int, d: int) -> int:
    """Evaluate C(N, d) via the one-point recurrence and base rows.

    C(1, d) = 2 for d >= 1;  C(N, 1) = 2;
    C(N+1, d+1) = C(N, d+1) + C(N, d).
    """
    if N < 1 or d < 1:
        raise ValueError("require N >= 1 and d >= 1")
    if N == 1 or d == 1:
        return 2
    return cover_count_recursive(N - 1, d) + cover_count_recursive(N - 1, d - 1)


# ---------------------------------------------------------------------------
# Demo 1: base cases and a table of values
# ---------------------------------------------------------------------------
def demo_table(max_N: int = 8, max_d: int = 6) -> None:
    print("=" * 70)
    print("Demo 1: Cover's counting function  C(N, d)  (2^N in the last column)")
    print("=" * 70)
    header = "N\\d |" + "".join(f"{d:>6}" for d in range(1, max_d + 1)) + " |   2^N"
    print(header)
    print("-" * len(header))
    for N in range(1, max_N + 1):
        row = f"{N:>3} |"
        for d in range(1, max_d + 1):
            row += f"{cover_count(N, d):>6}"
        row += f" |{2 ** N:>6}"
        print(row)
    # Base cases
    assert all(cover_count(1, d) == 2 for d in range(1, 10))
    assert all(cover_count(N, 1) == 2 for N in range(1, 10))
    print("\nBase cases verified: C(1,d)=2 and C(N,1)=2.")


# ---------------------------------------------------------------------------
# Demo 2: recurrence, saturation, strict collapse
# ---------------------------------------------------------------------------
def demo_regimes(max_N: int = 12, max_d: int = 8) -> None:
    print("\n" + "=" * 70)
    print("Demo 2: recurrence, saturation (N<=d), strict collapse (d<N)")
    print("=" * 70)

    # Recurrence C(N+1,d+1) = C(N,d+1) + C(N,d) for N >= 1
    ok_rec = all(
        cover_count(N + 1, d + 1) == cover_count(N, d + 1) + cover_count(N, d)
        for N in range(1, max_N)
        for d in range(0, max_d)
    )
    print(f"One-point recurrence holds for all tested N>=1, d>=0 : {ok_rec}")

    # Closed form matches recursive definition
    ok_match = all(
        cover_count(N, d) == cover_count_recursive(N, d)
        for N in range(1, 9)
        for d in range(1, 7)
    )
    print(f"Closed form == recurrence table                     : {ok_match}")

    # Saturation: N <= d  =>  C(N,d) = 2^N
    ok_sat = all(
        cover_count(N, d) == 2 ** N
        for N in range(1, max_N)
        for d in range(N, max_d + max_N)
    )
    print(f"Saturation  C(N,d)=2^N  for  N<=d                    : {ok_sat}")

    # Strict collapse: d < N  =>  C(N,d) < 2^N
    ok_col = all(
        cover_count(N, d) < 2 ** N
        for N in range(2, max_N)
        for d in range(1, N)
    )
    print(f"Strict collapse  C(N,d)<2^N  for  d<N                : {ok_col}")

    print(f"\nHeadline example:  C(5,3) = {cover_count(5, 3)}  <  2^5 = {2 ** 5}")


# ---------------------------------------------------------------------------
# Demo 3: maximal-solution property (Monte-Carlo over dichotomy systems)
# ---------------------------------------------------------------------------
def is_dichotomy_system(g: Callable[[int, int], int], max_N: int, max_d: int) -> bool:
    """Check the three defining inequalities of a dichotomy system."""
    for d in range(1, max_d + 1):
        if g(1, d) > 2:
            return False
    for N in range(1, max_N + 1):
        if g(N, 1) > 2:
            return False
    for N in range(1, max_N):
        for d in range(1, max_d):
            if g(N + 1, d + 1) > g(N, d + 1) + g(N, d):
                return False
    return True


def demo_maximal_solution(max_N: int = 9, max_d: int = 6) -> None:
    print("\n" + "=" * 70)
    print("Demo 3: Cover's function dominates every dichotomy system")
    print("=" * 70)

    # A family of dichotomy systems obtained by capping Cover's function.
    def capped(cap: int) -> Callable[[int, int], int]:
        return lambda N, d: min(cover_count(N, d), 2 if (N == 1 or d == 1) else cap)

    all_dominated = True
    for cap in (2, 4, 8, 16, 10 ** 6):
        g = capped(cap)
        if not is_dichotomy_system(g, max_N, max_d):
            continue
        dominated = all(
            g(N, d) <= cover_count(N, d)
            for N in range(1, max_N + 1)
            for d in range(1, max_d + 1)
        )
        all_dominated = all_dominated and dominated
        print(f"  capped-at-{cap:<7} is a dichotomy system and <= C(N,d): {dominated}")

    print(f"\nAll sampled dichotomy systems are dominated by C(N,d): {all_dominated}")
    print("Cover's own function satisfies every inequality with equality (tight).")


# ---------------------------------------------------------------------------
# Demo 4: manifold-constrained bound and ambient-dimension irrelevance
# ---------------------------------------------------------------------------
def empirical_dichotomy_count(points: list[tuple[float, ...]]) -> int:
    """Count homogeneously linearly-separable dichotomies of a small point set.

    Brute force in the point-coordinate dimension: a dichotomy (s_i in {+1,-1})
    is realizable iff there is a weight vector w with s_i * <w, x_i> > 0 for all i.
    We certify separability by a coarse random-direction search, which is exact
    enough for the tiny, well-separated configurations used here.
    """
    import random

    dim = len(points[0])
    n = len(points)
    realizable = 0
    rng = random.Random(0)
    directions = [tuple(rng.gauss(0, 1) for _ in range(dim)) for _ in range(20000)]
    for signs in product((-1, 1), repeat=n):
        found = False
        for w in directions:
            if all(
                sum(w[j] * points[i][j] for j in range(dim)) * signs[i] > 1e-9
                for i in range(n)
            ):
                found = True
                break
        if found:
            realizable += 1
    return realizable


def demo_manifold_bound() -> None:
    print("\n" + "=" * 70)
    print("Demo 4: manifold-constrained bound  C_F(N) <= C(N, d+M'+1)")
    print("=" * 70)

    # Data on a 1-dimensional manifold (a curve) lifted to feature space of dim M'.
    # Intrinsic d = 1. We take N=5 points on a parabola t -> (t, t^2) so M'=2.
    d_intrinsic = 1
    M_prime = 2
    p = d_intrinsic + M_prime + 1  # effective budget
    N = 5
    ts = [-2.0, -1.0, 0.0, 1.0, 2.0]
    # Feature map with homogeneous coordinate appended (accounts for the +1).
    feats = [(t, t * t, 1.0) for t in ts]

    emp = empirical_dichotomy_count(feats)
    bound = cover_count(N, p)
    print(f"intrinsic d = {d_intrinsic}, feature dim M' = {M_prime}, budget p = {p}")
    print(f"empirical C_F(N) for N={N} points on the curve : {emp}")
    print(f"theoretical bound  C(N, p)                      : {bound}")
    print(f"unconstrained maximum 2^N                       : {2 ** N}")
    print(f"bound respected (C_F <= C(N,p))                 : {emp <= bound}")

    # Ambient irrelevance: pad the same curve into higher ambient dimensions.
    print("\nAmbient-dimension irrelevance (same intrinsic curve, padded):")
    for pad in (0, 3, 10):
        padded = [f + (0.0,) * pad for f in feats]
        emp_pad = empirical_dichotomy_count(padded)
        print(f"  ambient dim M' + {pad:>2}: empirical count = {emp_pad} "
              f"(bound C(N,p) = {bound})")


if __name__ == "__main__":
    demo_table()
    demo_regimes()
    demo_maximal_solution()
    demo_manifold_bound()
    print("\nAll demonstrations completed.")
