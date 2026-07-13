"""
Numerical demonstrations for
"Sharp Lower Bounds for Sumsets in L1 Balls in Z^d".

Self-contained. Standard library only. Run with:  python demo.py

We verify, by direct enumeration for small parameters:

  1. Iterated Cauchy-Davenport:      sum_j |A_j| + 1 <= |sumset| + n
  2. Multiplicative bound:           prod_j |A_j| <= |sumset|^n
  3. Geometric-mean bound (p = n):   (prod_j |A_j|)^(1/n) <= |sumset|
  4. Containment in the L1 ball:     A_1 + ... + A_n  subset  B_d(n*m)
  5. Sharp exponent identity:        (m+1)^(n/p) = n*m + 1,  1 <= p <= n
  6. Extremal interval sharpness:    equality in (1) and in (prod)^(1/p) = |sumset|
"""

from __future__ import annotations

import math
from itertools import product
from typing import Iterable, List, Sequence, Set, Tuple

Point = Tuple[int, ...]


# --------------------------------------------------------------------------
# Core set operations
# --------------------------------------------------------------------------
def l1_norm(x: Point) -> int:
    """L1 (taxicab) norm of a lattice point."""
    return sum(abs(c) for c in x)


def l1_ball(d: int, m: int) -> Set[Point]:
    """All integer points x in Z^d with |x_1| + ... + |x_d| <= m."""
    ranges = [range(-m, m + 1)] * d
    return {x for x in product(*ranges) if l1_norm(x) <= m}


def add_point(x: Point, y: Point) -> Point:
    return tuple(a + b for a, b in zip(x, y))


def sumset(sets: Sequence[Set[Point]]) -> Set[Point]:
    """Iterated pointwise sumset A_1 + A_2 + ... + A_n."""
    acc: Set[Point] = {tuple([0] * len(next(iter(sets[0]))))}
    for A in sets:
        acc = {add_point(x, a) for x in acc for a in A}
    return acc


# --------------------------------------------------------------------------
# The sharp exponent
# --------------------------------------------------------------------------
def sharp_exponent(n: int, m: int) -> float:
    """p(n, m) = n * log(m+1) / log(n*m + 1)."""
    return n * math.log(m + 1) / math.log(n * m + 1)


def l1_ball_cardinality_formula(d: int, m: int) -> int:
    """|B_d(m)| = sum_k 2^k C(d,k) C(m,k)  (Delannoy-type count)."""
    return sum(
        (2 ** k) * math.comb(d, k) * math.comb(m, k)
        for k in range(min(d, m) + 1)
    )


# --------------------------------------------------------------------------
# Bound checkers
# --------------------------------------------------------------------------
def check_bounds(sets: Sequence[Set[Point]], d: int, m: int) -> None:
    n = len(sets)
    sizes = [len(A) for A in sets]
    S = sumset(sets)
    csum = len(S)

    add_ok = sum(sizes) + 1 <= csum + n
    mult_ok = math.prod(sizes) <= csum ** n
    gm = math.prod(sizes) ** (1.0 / n)
    gm_ok = gm <= csum + 1e-9
    contain_ok = all(l1_norm(x) <= n * m for x in S)

    print(f"  sizes={sizes}  |sumset|={csum}")
    print(f"    (1) additive        {sum(sizes)+1} <= {csum+n}      : {add_ok}")
    print(f"    (2) multiplicative  {math.prod(sizes)} <= {csum**n}   : {mult_ok}")
    print(f"    (3) geom-mean       {gm:.4f} <= {csum}          : {gm_ok}")
    print(f"    (4) containment in B_{d}({n*m})                 : {contain_ok}")
    assert add_ok and mult_ok and gm_ok and contain_ok


def demo_random_configs() -> None:
    print("=" * 68)
    print("Demo 1: bounds hold for sample configurations inside B_d(m)")
    print("=" * 68)
    import random
    random.seed(2026)
    for d, m, n in [(1, 3, 2), (2, 2, 3), (2, 3, 2), (3, 2, 2)]:
        ball = sorted(l1_ball(d, m))
        print(f"\n d={d}, m={m}, n={n}, |B_d(m)|={len(ball)}")
        for _ in range(3):
            sets = []
            for _ in range(n):
                k = random.randint(1, len(ball))
                sets.append(set(random.sample(ball, k)))
            check_bounds(sets, d, m)


def demo_sharp_exponent() -> None:
    print("\n" + "=" * 68)
    print("Demo 2: the sharp exponent p = n log(m+1)/log(nm+1)")
    print("=" * 68)
    print(f"{'n':>3}{'m':>4}{'p':>12}{'(m+1)^(n/p)':>16}{'nm+1':>8}{'1<=p<=n':>10}")
    for n in (2, 3, 5):
        for m in (1, 2, 5, 10):
            p = sharp_exponent(n, m)
            lhs = (m + 1) ** (n / p)
            rng = 1.0 <= p <= n
            print(f"{n:>3}{m:>4}{p:>12.6f}{lhs:>16.6f}{n*m+1:>8}{str(rng):>10}")
            assert abs(lhs - (n * m + 1)) < 1e-9 and rng


def demo_extremal_interval() -> None:
    print("\n" + "=" * 68)
    print("Demo 3: extremal interval A_j = {0,...,m} attains equality (d=1)")
    print("=" * 68)
    for n in (2, 3, 4):
        for m in (1, 3, 5):
            A = {(k,) for k in range(m + 1)}
            sets = [A] * n
            S = sumset(sets)
            csum = len(S)                       # should be n*m + 1
            prod = (m + 1) ** n
            p = sharp_exponent(n, m)
            add_eq = (n * (m + 1) + 1 == csum + n)
            sharp_eq = abs(prod ** (1.0 / p) - csum) < 1e-9
            print(f" n={n}, m={m}: |sumset|={csum} (=nm+1={n*m+1}), "
                  f"additive equality={add_eq}, (prod)^(1/p)={prod**(1/p):.4f}"
                  f" == |sumset| : {sharp_eq}")
            assert add_eq and sharp_eq and csum == n * m + 1


def demo_ball_counts() -> None:
    print("\n" + "=" * 68)
    print("Demo 4: |B_d(m)| by enumeration vs. Delannoy-type formula")
    print("=" * 68)
    print(f"{'d':>3}{'m':>4}{'enumerated':>14}{'formula':>10}")
    for d in (1, 2, 3):
        for m in (0, 1, 2, 3, 4):
            enum = len(l1_ball(d, m))
            form = l1_ball_cardinality_formula(d, m)
            print(f"{d:>3}{m:>4}{enum:>14}{form:>10}")
            assert enum == form


def main() -> None:
    demo_random_configs()
    demo_sharp_exponent()
    demo_extremal_interval()
    demo_ball_counts()
    print("\nAll checks passed.")


if __name__ == "__main__":
    main()
