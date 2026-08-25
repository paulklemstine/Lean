#!/usr/bin/env python3
"""
Parameter-derived depth: numerical demonstration of the maximal refinement depth
of a budgeted B-ary hierarchical cascade.

Model
-----
A region of space (or a lattice, or a nested code) is refined recursively: every cell
of level k splits into B cells of level k+1.  A cascade carried down to depth d
materialises

    S_B(d) = 1 + B + B^2 + ... + B^d

cells in total.  Physics supplies an information threshold T (a holographic /
Bekenstein-type bound on the number of distinguishable cells).  Depth d is
*supported* when S_B(d) <= T.

Main result demonstrated here
-----------------------------
The greatest supported depth is the closed form

    d_max(B, T) = floor(log_B((B-1)T + 1)) - 1,

and it is genuinely maximal: S_B(d_max) <= T < S_B(d_max + 1).

The script also demonstrates:
  * the uniform logarithmic law   log_B T - 2 < d_max <= log_B T;
  * resolution scaling            l0/T <= l0 * B^(-d_max) < B^2 * l0 / T;
  * universality of the law for geometrically sandwiched cost models;
  * the composition law           d(T1)+d(T2) <= d(T1*T2) <= d(T1)+d(T2)+2;
  * the coarse-level deficit and its limiting density 1/(B-1)^2;
  * quenched disorder in the branching schedule.

Self-contained: standard library only.
"""

from __future__ import annotations

import math
from typing import Callable, Dict, List, Sequence, Tuple

# --------------------------------------------------------------------------- #
# Core arithmetic
# --------------------------------------------------------------------------- #


def cascade_cells(B: int, d: int) -> int:
    """S_B(d) = 1 + B + ... + B^d, the total cell count of a depth-d B-ary cascade."""
    if B < 2:
        raise ValueError("branching number must satisfy B >= 2")
    if d < 0:
        raise ValueError("depth must be non-negative")
    return (B ** (d + 1) - 1) // (B - 1)


def integer_log(B: int, n: int) -> int:
    """Greatest m with B^m <= n (integer logarithm); integer_log(B, 0) := 0."""
    if B < 2:
        raise ValueError("base must satisfy B >= 2")
    if n < 1:
        return 0
    m, p = 0, 1
    while p * B <= n:
        p *= B
        m += 1
    return m


def parameter_depth(B: int, T: int) -> int:
    """Closed form d_max(B, T) = floor(log_B((B-1)T + 1)) - 1."""
    if T < 1:
        raise ValueError("threshold must satisfy T >= 1")
    return integer_log(B, (B - 1) * T + 1) - 1


def max_depth_by_search(cost: Callable[[int], int], T: int) -> int:
    """Greatest d with cost(d) <= T, found by direct search (strictly monotone cost)."""
    if cost(0) > T:
        return 0
    d = 0
    while cost(d + 1) <= T:
        d += 1
    return d


def frontier_certificate(B: int, T: int) -> Tuple[int, int, int, bool]:
    """Return (d, S_B(d), S_B(d+1), valid) certifying maximality: S(d) <= T < S(d+1)."""
    d = parameter_depth(B, T)
    lo, hi = cascade_cells(B, d), cascade_cells(B, d + 1)
    return d, lo, hi, (lo <= T < hi)


def deficit(B: int, T: int) -> int:
    """floor(log_B T) - d_max(B, T); provably 0 or 1."""
    return integer_log(B, T) - parameter_depth(B, T)


# --------------------------------------------------------------------------- #
# Demonstration 1: the closed form, and its maximality
# --------------------------------------------------------------------------- #


def demo_closed_form() -> None:
    print("=" * 78)
    print("1.  CLOSED FORM AND MAXIMALITY:  d_max(B,T) = floor(log_B((B-1)T+1)) - 1")
    print("=" * 78)
    cases: List[Tuple[int, int]] = [
        (2, 1000), (3, 100), (10, 10 ** 6), (5, 10 ** 6),
        (4, 1000), (2, 10), (2, 100), (2, 10000),
    ]
    header = f"{'B':>4} {'T':>10} {'d_max':>6} {'S_B(d)':>12} {'S_B(d+1)':>12} {'cert':>6} {'search':>7}"
    print(header)
    print("-" * len(header))
    for B, T in cases:
        d, lo, hi, ok = frontier_certificate(B, T)
        srch = max_depth_by_search(lambda k, B=B: cascade_cells(B, k), T)
        print(f"{B:>4} {T:>10} {d:>6} {lo:>12} {hi:>12} {'OK' if ok else 'FAIL':>6} {srch:>7}")
        assert ok and srch == d, "closed form disagrees with the certified frontier"
    print("\nEvery row satisfies S_B(d) <= T < S_B(d+1): the depth is the greatest")
    print("supported one, not merely a supported one.  The independent bounded search")
    print("agrees with the closed form in every case.\n")


# --------------------------------------------------------------------------- #
# Demonstration 2: the logarithmic law and resolution scaling
# --------------------------------------------------------------------------- #


def demo_scaling(l0: float = 1.0) -> None:
    print("=" * 78)
    print("2.  SCALING LAWS:  log_B T - 2 < d_max <= log_B T   and   l0/T <= l < B^2 l0/T")
    print("=" * 78)
    header = (f"{'B':>4} {'T':>10} {'d_max':>6} {'log_B T':>10} "
              f"{'slack':>8} {'l = l0 B^-d':>14} {'l0/T':>12} {'B^2 l0/T':>12}")
    print(header)
    print("-" * len(header))
    for B in (2, 3, 5, 10):
        for T in (10 ** 3, 10 ** 6, 10 ** 9):
            d = parameter_depth(B, T)
            lb = math.log(T, B)
            ell = l0 * B ** (-d)
            lo, hi = l0 / T, B ** 2 * l0 / T
            print(f"{B:>4} {T:>10} {d:>6} {lb:>10.4f} {lb - d:>8.4f} "
                  f"{ell:>14.3e} {lo:>12.3e} {hi:>12.3e}")
            assert 0 <= lb - d < 2, "logarithmic law violated"
            assert lo <= ell < hi, "resolution bound violated"
    print("\nThe slack log_B T - d_max is always in [0, 2), uniformly in B and T.")
    print("Resolution improves LINEARLY in the budget (l ~ l0/T) while depth improves")
    print("only LOGARITHMICALLY: levels are expensive, resolution is cheap.\n")


# --------------------------------------------------------------------------- #
# Demonstration 3: exact calibration and unboundedness
# --------------------------------------------------------------------------- #


def demo_calibration() -> None:
    print("=" * 78)
    print("3.  CALIBRATION:  d_max(B, S_B(N)) = N exactly, for every N")
    print("=" * 78)
    for B in (2, 3, 7):
        row = [parameter_depth(B, cascade_cells(B, N)) for N in range(9)]
        print(f"  B = {B:>2}:  N = 0..8  ->  d_max = {row}")
        assert row == list(range(9))
    print("\nBoth bounds of the logarithmic law are therefore attained, and no fixed")
    print("depth is universal: for any target N the budget S_B(N) supports exactly N.\n")


# --------------------------------------------------------------------------- #
# Demonstration 4: universality across cost models
# --------------------------------------------------------------------------- #


def energy_cells(a: int, c: int, B: int, d: int) -> int:
    """Cost charging a units per cell plus a fixed overhead c per level."""
    return a * cascade_cells(B, d) + c * (d + 1)


def demo_universality() -> None:
    print("=" * 78)
    print("4.  UNIVERSALITY:  B^d <= cost(d) <= K B^d  =>  log_B T - (log_B K + 1) <= d <= log_B T")
    print("=" * 78)
    models: List[Tuple[str, Callable[[int, int], int], int]] = [
        ("leaves only      cost = B^d", lambda B, d: B ** d, 1),
        ("full tree        cost = S_B(d)", cascade_cells, 2),
        ("a=2,c=0          cost = 2 S_B(d)", lambda B, d: energy_cells(2, 0, B, d), 4),
        ("a=2,c=3          cost = 2 S_B(d) + 3(d+1)", lambda B, d: energy_cells(2, 3, B, d), 7),
        ("a=5,c=11         cost = 5 S_B(d) + 11(d+1)", lambda B, d: energy_cells(5, 11, B, d), 21),
    ]
    B, T = 2, 10 ** 6
    L = integer_log(B, T)
    print(f"  branching B = {B},  budget T = {T},  floor(log_B T) = {L}\n")
    header = f"{'cost model':<38} {'K':>4} {'window':>12} {'d_max':>7} {'in window':>10}"
    print(header)
    print("-" * len(header))
    for name, cost, K in models:
        d = max_depth_by_search(lambda k, cost=cost, B=B: cost(B, k), T)
        low = max(0, L - (integer_log(B, K) + 1))
        inside = low <= d <= L
        print(f"{name:<38} {K:>4} {f'[{low},{L}]':>12} {d:>7} {'yes' if inside else 'NO':>10}")
        assert inside, "universality window violated"
    print("\nThe entire modelling freedom in how one charges for a level is worth")
    print("floor(log_B K) + 1 levels of depth -- and nothing more.  Changing the cost")
    print("model moves the offset; it never changes the logarithmic law.\n")


# --------------------------------------------------------------------------- #
# Demonstration 5: composition of independent subsystems
# --------------------------------------------------------------------------- #


def demo_composition() -> None:
    print("=" * 78)
    print("5.  COMPOSITION:  d(T1) + d(T2) <= d(T1 T2) <= d(T1) + d(T2) + 2  (sharp)")
    print("=" * 78)
    pairs: List[Tuple[int, int, int]] = [
        (2, 7, 7), (2, 5, 13), (2, 1000, 1000), (3, 100, 100), (10, 10 ** 3, 10 ** 3),
    ]
    header = f"{'B':>4} {'T1':>8} {'T2':>8} {'d(T1)':>7} {'d(T2)':>7} {'d(T1T2)':>9} {'gap':>5}"
    print(header)
    print("-" * len(header))
    for B, T1, T2 in pairs:
        d1, d2, d12 = parameter_depth(B, T1), parameter_depth(B, T2), parameter_depth(B, T1 * T2)
        gap = d12 - d1 - d2
        print(f"{B:>4} {T1:>8} {T2:>8} {d1:>7} {d2:>7} {d12:>9} {gap:>5}")
        assert 0 <= gap <= 2, "composition law violated"

    # Exhaustive sharpness check for binary branching.
    gaps: Dict[int, int] = {0: 0, 1: 0, 2: 0}
    for T1 in range(1, 130):
        for T2 in range(1, 130):
            g = parameter_depth(2, T1 * T2) - parameter_depth(2, T1) - parameter_depth(2, T2)
            assert 0 <= g <= 2
            gaps[g] += 1
    print(f"\n  Exhaustive scan, B = 2, 1 <= T1,T2 <= 129:  gap distribution {gaps}")
    print("  Both endpoints occur: (7,7) is exactly additive, (5,13) attains the +2.")

    # Extensivity: n * d(T) <= d(T^n).
    B, T = 2, 1000
    print(f"\n  Extensivity, B = {B}, T = {T}:")
    for n in range(1, 6):
        print(f"    n = {n}:  n*d(T) = {n * parameter_depth(B, T):>3} "
              f"<= d(T^n) = {parameter_depth(B, T ** n):>3}")
        assert n * parameter_depth(B, T) <= parameter_depth(B, T ** n)
    print()


# --------------------------------------------------------------------------- #
# Demonstration 6: the coarse-level deficit and its density
# --------------------------------------------------------------------------- #


def lossy_count_in_block(B: int, L: int) -> int:
    """Number of budgets T in [B^L, B^(L+1)) with deficit 1, counted directly."""
    return sum(1 for T in range(B ** L, B ** (L + 1)) if deficit(B, T) == 1)


def demo_deficit() -> None:
    print("=" * 78)
    print("6.  COARSE-LEVEL DEFICIT:  lossy budgets = [B^L, S_B(L)),  count = S_B(L-1)")
    print("=" * 78)
    header = (f"{'B':>4} {'L':>3} {'block size':>11} {'counted':>9} {'S_B(L-1)':>10} "
              f"{'density':>9} {'1/(B-1)^2':>10}")
    print(header)
    print("-" * len(header))
    for B in (2, 3, 4, 5):
        for L in range(1, 7):
            if B ** (L + 1) > 400_000:
                continue
            block = B ** (L + 1) - B ** L
            counted = lossy_count_in_block(B, L)
            predicted = cascade_cells(B, L - 1)
            dens = counted / block
            print(f"{B:>4} {L:>3} {block:>11} {counted:>9} {predicted:>10} "
                  f"{dens:>9.5f} {1 / (B - 1) ** 2:>10.5f}")
            assert counted == predicted, "self-similarity identity violated"
    print("\nThe count of budgets that lose a level at scale L is exactly the cell count")
    print("of a cascade one level SHALLOWER -- a genuine self-similarity.  Its density")
    print("inside the block tends to 1/(B-1)^2: equal to 1 for binary branching (almost")
    print("every binary budget pays the overhead), 1/4 for B=3, 1/81 for B=10.\n")

    # The interval description, verified directly.
    B, L = 3, 4
    lossy = [T for T in range(B ** L, B ** (L + 1)) if deficit(B, T) == 1]
    print(f"  Interval check, B = {B}, L = {L}:")
    print(f"    lossy set  = [{min(lossy)}, {max(lossy) + 1})   predicted "
          f"[{B ** L}, {cascade_cells(B, L)})")
    assert min(lossy) == B ** L and max(lossy) + 1 == cascade_cells(B, L)
    print()


# --------------------------------------------------------------------------- #
# Demonstration 7: quenched disorder in the branching schedule
# --------------------------------------------------------------------------- #


def schedule_weight(r: Sequence[int], k: int) -> int:
    """w_r(k) = r(0) r(1) ... r(k-1), the size of a level-k family."""
    w = 1
    for j in range(k):
        w *= r[j]
    return w


def schedule_cells(r: Sequence[int], d: int) -> int:
    """W_r(d) = sum_{k<=d} w_r(k), the cost of a disordered cascade of depth d."""
    return sum(schedule_weight(r, k) for k in range(d + 1))


def demo_disorder() -> None:
    print("=" * 78)
    print("7.  QUENCHED DISORDER:  log_Bmax T - (log_Bmax 2 + 1) <= d <= log_Bmin T")
    print("=" * 78)

    schedules: List[Tuple[str, List[int], int, int]] = [
        ("alternating 2,3,2,3,...", [2 if k % 2 == 0 else 3 for k in range(64)], 2, 3),
        ("homogeneous 2,2,2,...", [2] * 64, 2, 2),
        ("period-3   2,3,4,2,3,4,...", [(k % 3) + 2 for k in range(64)], 2, 4),
        ("front-loaded 5,5,2,2,2,...", [5, 5] + [2] * 62, 2, 5),
    ]
    header = f"{'schedule':<30} {'T':>8} {'window':>12} {'d_max':>7} {'W(d)':>9} {'W(d+1)':>9}"
    print(header)
    print("-" * len(header))
    for name, r, bmin, bmax in schedules:
        for T in (100, 10_000):
            d = max_depth_by_search(lambda k, r=r: schedule_cells(r, k), T)
            low = max(0, integer_log(bmax, T) - (integer_log(bmax, 2) + 1))
            high = integer_log(bmin, T)
            wd, wd1 = schedule_cells(r, d), schedule_cells(r, d + 1)
            print(f"{name:<30} {T:>8} {f'[{low},{high}]':>12} {d:>7} {wd:>9} {wd1:>9}")
            assert low <= d <= high, "disorder window violated"
            assert wd <= T < wd1, "frontier certificate failed"
    print("\nThe alternating 2,3 cascade has costs 1, 3, 9, 21, 57, 129, ...; with a budget")
    print("of 100 cells depth 4 fits (57 <= 100) and depth 5 does not (129 > 100), so the")
    print("maximal depth is exactly 4 -- comfortably inside the predicted window [3, 6].")
    print("Disorder relocates the depth; it cannot destroy the logarithmic law.\n")


# --------------------------------------------------------------------------- #


def main() -> None:
    print()
    print("#" * 78)
    print("#  PARAMETER-DERIVED DEPTH".ljust(77) + "#")
    print("#  The exact maximal refinement level of a budgeted hierarchical cascade".ljust(77) + "#")
    print("#" * 78)
    print()
    demo_closed_form()
    demo_scaling()
    demo_calibration()
    demo_universality()
    demo_composition()
    demo_deficit()
    demo_disorder()
    print("=" * 78)
    print("All demonstrations completed; every asserted bound held in every case.")
    print("=" * 78)


if __name__ == "__main__":
    main()
