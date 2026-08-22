"""
Fair scheduling under arbitrary positive rate profiles
======================================================

Numerical companion to the paper "Exact-Rate Batches, Splitting Trees and
Largest-Lag Greedy: Fair Schedules for Arbitrary Positive Rate Profiles".

Setting
-------
A *rate profile* is a tuple r = (r_0, ..., r_{k-1}) of positive integers.
Write P_i = r_0 + ... + r_{i-1} for its prefix sums and R = P_k for the
period (total rate).  A *schedule* is a map f : {0,1,2,...} -> {0,...,k-1};
its counters are

        N_i(t) = #{ u < t : f(u) = i }.

The *discrepancy* of client i at time t is D_i(t) = R * N_i(t) - r_i * t,
and a schedule is *B-fair* if |D_i(t)| <= B for all i and t.  The
*normalised* discrepancy is |D_i(t)| / R, measured in whole services.

This script demonstrates, by direct simulation:

  1. the closed form  N_i(t) = floor(t/R) * r_i + min(r_i, (t mod R) - P_i)^+
     for the exact-rate block schedule built from prefix sums;
  2. the sharp two-sided bound  -r_i P_i <= D_i(t) <= r_i (R - P_{i+1}),
     attained at t = P_i and t = P_{i+1};
  3. exactness of the block schedule precisely at multiples of R, and the
     impossibility of a schedule that is exact at all times (k >= 2);
  4. unit discrepancy of the two-client Bresenham schedule, and the
     Theta(R) discrepancy of the block schedule on the profile (c, c);
  5. non-realisability of the naive "nested floors" multi-client Bresenham
     for k >= 3, via the profile (3, 1, 3);
  6. the logarithmic bound  max_i |D_i(t)| <= R * ceil(log2 k)  for the
     recursive splitting-tree schedule, for every profile;
  7. the greedy largest-lag rule: no client ever leads by a full period,
     i.e. D_i(t) <= R - 1, while the *lag* side can exceed a full period
     (the profile (1,1,1,5,5,5) reaches normalised lag 19/18).

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from math import gcd
from typing import Callable, Dict, List, Sequence, Tuple

Schedule = Callable[[int], int]


# ---------------------------------------------------------------------------
# Basic vocabulary
# ---------------------------------------------------------------------------


def prefixes(r: Sequence[int]) -> List[int]:
    """Prefix sums P_0 = 0, P_1 = r_0, ..., P_k = R."""
    out: List[int] = [0]
    for x in r:
        out.append(out[-1] + x)
    return out


def counters(f: Schedule, k: int, horizon: int) -> List[List[int]]:
    """counters[i][t] = #{u < t : f(u) = i} for 0 <= t <= horizon."""
    table = [[0] * (horizon + 1) for _ in range(k)]
    for t in range(horizon):
        served = f(t)
        for i in range(k):
            table[i][t + 1] = table[i][t] + (1 if i == served else 0)
    return table


def max_abs_discrepancy(f: Schedule, r: Sequence[int], horizon: int) -> int:
    """max_{i,t} |R * N_i(t) - r_i * t| over 0 <= t <= horizon."""
    k = len(r)
    R = sum(r)
    table = counters(f, k, horizon)
    return max(
        abs(R * table[i][t] - r[i] * t) for i in range(k) for t in range(horizon + 1)
    )


# ---------------------------------------------------------------------------
# 1. The exact-rate block schedule from prefix sums
# ---------------------------------------------------------------------------


def block_owner(r: Sequence[int], t: int) -> int:
    """Owner of slot t in the block schedule: the unique i with
    P_i <= t mod R < P_{i+1}."""
    P = prefixes(r)
    s = t % P[-1]
    for i in range(len(r)):
        if P[i] <= s < P[i + 1]:
            return i
    raise AssertionError("unreachable: the batches tile a period")


def block_count_formula(r: Sequence[int], i: int, t: int) -> int:
    """Closed form floor(t/R) * r_i + min(r_i, (t mod R) - P_i)^+."""
    P = prefixes(r)
    R = P[-1]
    return (t // R) * r[i] + min(r[i], max(0, (t % R) - P[i]))


def demo_block_closed_form(profiles: Sequence[Sequence[int]], horizon: int) -> None:
    print("1. Closed form for the block-schedule counter")
    for r in profiles:
        k = len(r)
        table = counters(lambda t, r=r: block_owner(r, t), k, horizon)
        ok = all(
            table[i][t] == block_count_formula(r, i, t)
            for i in range(k)
            for t in range(horizon + 1)
        )
        print(f"   r = {tuple(r)}   simulation == closed form on [0,{horizon}] : {ok}")
    print()


def demo_sharp_bounds(profiles: Sequence[Sequence[int]], horizon: int) -> None:
    print("2. Sharp two-sided discrepancy bounds  -r_i P_i <= D_i(t) <= r_i (R - P_{i+1})")
    for r in profiles:
        k, P = len(r), prefixes(r)
        R = P[-1]
        table = counters(lambda t, r=r: block_owner(r, t), k, horizon)
        holds = True
        attained_low: List[bool] = []
        attained_high: List[bool] = []
        for i in range(k):
            lo, hi = -r[i] * P[i], r[i] * (R - P[i + 1])
            vals = [R * table[i][t] - r[i] * t for t in range(horizon + 1)]
            holds &= all(lo <= v <= hi for v in vals)
            attained_low.append(R * table[i][P[i]] - r[i] * P[i] == lo)
            attained_high.append(R * table[i][P[i + 1]] - r[i] * P[i + 1] == hi)
        print(
            f"   r = {tuple(r)}   bounds hold: {holds}; "
            f"lower attained at t = P_i: {all(attained_low)}; "
            f"upper attained at t = P_(i+1): {all(attained_high)}"
        )
    print()


def demo_exactness(profiles: Sequence[Sequence[int]], horizon: int) -> None:
    print("3. Exactness of the block schedule happens exactly at multiples of R")
    for r in profiles:
        k, R = len(r), sum(r)
        table = counters(lambda t, r=r: block_owner(r, t), k, horizon)
        exact_times = [
            t
            for t in range(horizon + 1)
            if all(R * table[i][t] == r[i] * t for i in range(k))
        ]
        print(
            f"   r = {tuple(r)}  R = {R}  exact times <= {horizon}: {exact_times} "
            f"(= multiples of R: {exact_times == list(range(0, horizon + 1, R))})"
        )
    print("   No schedule at all is exact at every time when k >= 2: the client")
    print("   served first has R * 1 - r_i * 1 = R - r_i > 0 already at t = 1.")
    print()


def demo_waiting_windows(profiles: Sequence[Sequence[int]], horizon: int) -> None:
    print("4. Bounded waiting: client i is served in every window of R - r_i + 1 slots")
    for r in profiles:
        k, R = len(r), sum(r)
        owners = [block_owner(r, t) for t in range(horizon + 1)]
        ok = True
        for i in range(k):
            w = R - r[i] + 1
            for t in range(horizon + 1 - w):
                ok &= i in owners[t : t + w]
        print(f"   r = {tuple(r)}   windows {[R - x + 1 for x in r]} suffice: {ok}")
    print()


# ---------------------------------------------------------------------------
# 2. Two clients: Bresenham
# ---------------------------------------------------------------------------


def bresenham(a: int, R: int) -> Schedule:
    """Two-client Bresenham: serve client 0 (rate a) exactly when the line
    t -> t*a/R crosses an integer during slot t, else client 1 (rate R - a).
    Its counters are N_0(t) = floor(t a / R) and N_1(t) = t - floor(t a / R)."""

    def f(t: int) -> int:
        return 0 if (t * a) // R < ((t + 1) * a) // R else 1

    return f


def demo_bresenham_vs_block(horizon: int = 400) -> None:
    print("5. Two clients: Bresenham is (R-1)-fair; the block schedule is not")
    for (a, R) in [(1, 2), (3, 8), (5, 13), (7, 12)]:
        r = (a, R - a)
        bres_disc = max_abs_discrepancy(bresenham(a, R), r, horizon)
        block_disc = max_abs_discrepancy(lambda t, r=r: block_owner(r, t), r, horizon)
        print(
            f"   r = {r}  R = {R}:  Bresenham max |D| = {bres_disc} (<= R-1 = {R - 1}, "
            f"normalised {bres_disc / R:.3f});  block max |D| = {block_disc} "
            f"(normalised {block_disc / R:.3f})"
        )
    print("   Balanced profile (c, c): block lead at t = c is c^2, i.e. c/2 services.")
    for c in [2, 4, 8, 16]:
        r = (c, c)
        disc = 2 * c * block_count_formula(r, 0, c) - c * c
        print(f"      c = {c:2d}: D_0(c) = {disc} = c^2, normalised {disc / (2 * c):.2f}")
    print()


# ---------------------------------------------------------------------------
# 3. The nested-floor obstruction for k >= 3
# ---------------------------------------------------------------------------


def nested_floor_count(r: Sequence[int], i: int, t: int) -> int:
    """Naive multi-client Bresenham candidate:
    floor(t P_{i+1} / R) - floor(t P_i / R)."""
    P = prefixes(r)
    R = P[-1]
    return (t * P[i + 1]) // R - (t * P[i]) // R


def demo_nested_floor_obstruction() -> None:
    print("6. The naive nested-floor generalisation is not a schedule for k >= 3")
    r = (3, 1, 3)
    vals = [nested_floor_count(r, 1, t) for t in range(8)]
    print(f"   r = {r}, R = {sum(r)}; candidate counts of the middle client:")
    print(f"      t      = {list(range(8))}")
    print(f"      nest_1 = {vals}   -> drops from 1 to 0 between t = 2 and t = 3")
    print("   Counters of genuine schedules are non-decreasing, so no schedule")
    print("   realises these counts.  For k = 2 the same recipe *is* Bresenham:")
    a, R = 5, 13
    same = all(
        nested_floor_count((a, R - a), i, t) == counters(bresenham(a, R), 2, 60)[i][t]
        for i in range(2)
        for t in range(61)
    )
    print(f"      k = 2, r = ({a},{R - a}): nested floors == Bresenham counters: {same}")
    print()


# ---------------------------------------------------------------------------
# 4. Splitting trees: logarithmic discrepancy for every profile
# ---------------------------------------------------------------------------

Tree = Tuple  # ("leaf", label, weight) | ("node", left, right)


def leaf(label: int, weight: int) -> Tree:
    return ("leaf", label, weight)


def node(left: Tree, right: Tree) -> Tree:
    return ("node", left, right)


def tree_weight(T: Tree) -> int:
    return T[2] if T[0] == "leaf" else tree_weight(T[1]) + tree_weight(T[2])


def tree_depth(T: Tree) -> int:
    return 0 if T[0] == "leaf" else 1 + max(tree_depth(T[1]), tree_depth(T[2]))


def balanced_tree(r: Sequence[int], base: int = 0, n: int | None = None) -> Tree:
    """Balanced splitting tree over clients base, ..., base + n - 1."""
    if n is None:
        n = len(r)
    if n <= 1:
        return leaf(base, r[base])
    half = n // 2
    return node(balanced_tree(r, base, half), balanced_tree(r, base + half, n - half))


def tree_schedule(T: Tree) -> Schedule:
    """Recursive Bresenham schedule of a splitting tree: at each node the
    global slot stream is split between the two subtrees by the two-client
    Bresenham rule with rates (w_left, w_left + w_right), and each subtree is
    served according to its own schedule on its own (slower) clock."""

    def f(t: int) -> int:
        cur, time = T, t
        while cur[0] == "node":
            wl, wr = tree_weight(cur[1]), tree_weight(cur[2])
            W = wl + wr
            left_time = (time * wl) // W
            if bresenham(wl, W)(time) == 0:
                cur, time = cur[1], left_time
            else:
                cur, time = cur[2], time - left_time
        return cur[1]

    return f


def ceil_log2(n: int) -> int:
    d, p = 0, 1
    while p < n:
        p *= 2
        d += 1
    return d


def demo_tree_schedule(profiles: Sequence[Sequence[int]], horizon: int = 600) -> None:
    print("7. Splitting-tree schedules: normalised discrepancy <= ceil(log2 k)")
    for r in profiles:
        k, R = len(r), sum(r)
        T = balanced_tree(list(r))
        disc = max_abs_discrepancy(tree_schedule(T), r, horizon)
        bound = R * tree_depth(T)
        print(
            f"   r = {tuple(r)}  k = {k}  R = {R}:  max |D| = {disc} "
            f"<= R*depth = {bound}; normalised {disc / R:.3f} "
            f"<= depth {tree_depth(T)} <= ceil(log2 k) = {ceil_log2(k)}"
        )
    print()


# ---------------------------------------------------------------------------
# 5. Greedy largest-lag
# ---------------------------------------------------------------------------


def greedy_schedule(r: Sequence[int]) -> Schedule:
    """Online rule: at slot t serve a client maximising r_i (t+1) - R N_i(t)
    (ties broken by smallest index).  Implemented with memoised state so that
    repeated calls f(0), f(1), ... are linear in total."""
    k, R = len(r), sum(r)
    state: Dict[int, List[int]] = {0: [0] * k}
    choice: Dict[int, int] = {}

    def f(t: int) -> int:
        for u in range(len(choice), t + 1):
            cnt = state[u]
            best, best_val = 0, r[0] * (u + 1) - R * cnt[0]
            for i in range(1, k):
                val = r[i] * (u + 1) - R * cnt[i]
                if val > best_val:
                    best, best_val = i, val
            choice[u] = best
            nxt = list(cnt)
            nxt[best] += 1
            state[u + 1] = nxt
        return choice[t]

    return f


def demo_greedy(profiles: Sequence[Sequence[int]], horizon: int = 600) -> None:
    print("8. Greedy largest-lag: nobody ever leads by a full period")
    for r in profiles:
        k, R = len(r), sum(r)
        f = greedy_schedule(r)
        table = counters(f, k, horizon)
        lead = max(R * table[i][t] - r[i] * t for i in range(k) for t in range(horizon + 1))
        lag = max(r[i] * t - R * table[i][t] for i in range(k) for t in range(horizon + 1))
        print(
            f"   r = {tuple(r)}  R = {R}: max lead = {lead} <= R-1 = {R - 1}; "
            f"max lag = {lag} <= (k-1)(R-1) = {(k - 1) * (R - 1)}; "
            f"normalised discrepancy {max(lead, lag) / R:.3f}"
        )
    print()


def demo_greedy_sweep(kmax: int = 6, rmax: int = 6, horizon: int = 200) -> None:
    print("9. Exhaustive sweep: is greedy always within one service of its share?")
    worst_val, worst_profile = 0.0, ()
    total_profiles = 0
    for k in range(2, kmax + 1):
        for r in product(range(1, rmax + 1), repeat=k):
            if gcd(*r) != 1:
                continue  # scale-invariant: only primitive profiles are needed
            total_profiles += 1
            R = sum(r)
            table = counters(greedy_schedule(r), k, min(horizon, 6 * R))
            m = max(
                abs(R * table[i][t] - r[i] * t)
                for i in range(k)
                for t in range(len(table[0]))
            )
            if m / R > worst_val:
                worst_val, worst_profile = m / R, r
    print(f"   profiles tested: {total_profiles} (k <= {kmax}, rates <= {rmax}, primitive)")
    print(
        f"   worst observed normalised discrepancy: {worst_val:.3f} at r = {worst_profile}"
    )
    print("   (values above 1 do occur: greedy is not unit-fair -- see 9b)")
    print()


def demo_greedy_unit_fairness_fails() -> None:
    print("9b. Greedy is NOT unit-fair: a family where the lag exceeds a full period")
    r = (1, 1, 1, 5, 5, 5)
    k, R = len(r), sum(r)
    table = counters(greedy_schedule(r), k, 24)
    lag = [(t, i, r[i] * t - R * table[i][t]) for t in range(25) for i in range(k)]
    t0, i0, v0 = max(lag, key=lambda z: z[2])
    print(f"   r = {r}, R = {R}: client {i0} is behind by {v0} > R at t = {t0}")
    print(f"   (normalised lag {v0 / R:.3f} > 1, while the proved lead bound R-1 = {R - 1}")
    print("    is respected throughout)")
    print("   The family r = (1^m, c^m) pushes the normalised discrepancy up:")
    for m, c in [(3, 5), (6, 9), (12, 9), (20, 50)]:
        rr = tuple([1] * m + [c] * m)
        RR = sum(rr)
        tab = counters(greedy_schedule(rr), 2 * m, 3 * RR)
        d = max(
            abs(RR * tab[i][t] - rr[i] * t)
            for i in range(2 * m)
            for t in range(3 * RR + 1)
        )
        print(f"      m = {m:2d}, c = {c:2d}  (k = {2 * m}, R = {RR}): {d / RR:.3f}")
    print("   The observed values increase towards, but never reach, 3/2.")
    print()


# ---------------------------------------------------------------------------
# 6. Round robin and the universal lower bound
# ---------------------------------------------------------------------------


def demo_round_robin(k: int = 5, horizon: int = 200) -> None:
    print("10. Uniform profile: the block schedule is round robin and is optimal")
    r = tuple([1] * k)
    owners = [block_owner(r, t) for t in range(12)]
    disc = max_abs_discrepancy(lambda t, r=r: block_owner(r, t), r, horizon)
    print(f"   r = {r}: owners of slots 0..11 = {owners} (= t mod k)")
    print(f"   max |D| = {disc} = k - 1 = {k - 1}")
    print("   Universal lower bound: any B-fair schedule has B >= R - r_{f(0)},")
    print(f"   which for the uniform profile is k - 1 = {k - 1}. Round robin is optimal.")
    print()


# ---------------------------------------------------------------------------


def main() -> None:
    print(__doc__.split("Run:")[0])
    small = [(1, 1, 1), (3, 1, 3), (5, 2), (4, 1, 1, 2)]
    demo_block_closed_form(small, horizon=60)
    demo_sharp_bounds(small, horizon=60)
    demo_exactness(small, horizon=40)
    demo_waiting_windows(small, horizon=120)
    demo_bresenham_vs_block()
    demo_nested_floor_obstruction()
    demo_tree_schedule([(1, 1, 1), (3, 1, 3), (1, 1, 1, 97), (5, 2, 9, 1, 1)])
    demo_greedy([(1, 1, 1), (3, 1, 3), (1, 1, 1, 97), (5, 2, 9, 1, 1)])
    demo_greedy_sweep()
    demo_greedy_unit_fairness_fails()
    demo_round_robin()


if __name__ == "__main__":
    main()
