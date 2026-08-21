"""
Dense sets and the sumsets they cannot escape
=============================================

Numerical companion to "The Exact Threshold for Sumsets in Dense Sets of Integers".

Everything here is exact integer arithmetic (Python ints are unbounded), so the
"certificates" printed below are genuine verifications of the counting criteria,
not floating-point approximations.

Contents
--------
1.  counting_criterion / max_guaranteed_k
        The exact criterion  k*|D|^k <= |S|*(|S|-k)^k  and the largest k it certifies.
2.  greedy_sumset
        The constructive greedy shift algorithm: given a concrete dense set S,
        it produces A, B with A + B subset of S.
3.  greedy_cube / is_proper_cube
        The same engine iterated on its own output, producing affine cubes
        u + {0,a_1} + ... + {0,a_d}.
4.  avoidance_threshold
        The first-moment (avoidance) threshold  (1+eps) log n / log(1/delta).
5.  Verification of the four effective instances stated in the paper.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from itertools import combinations
from typing import Dict, Iterable, List, Optional, Sequence, Set, Tuple

# ----------------------------------------------------------------------------
# 1. The exact counting criterion
# ----------------------------------------------------------------------------


def counting_criterion(k: int, window: int, s_card: int) -> bool:
    """Exact criterion of the greedy shift argument.

    Returns True iff  k * window**k <= s_card * (s_card - k)**k,
    where `window` is the size of the admissible shift domain D and `s_card` = |S|.

    Whenever this holds (and k <= min(|S|, |D|)), *every* set S of that size inside
    the corresponding ambient interval/group contains a sumset A + B with
    |A| = |B| = k and A drawn from the shift window.
    """
    if k <= 0:
        return True
    if k > s_card or k > window:
        return False
    return k * window**k <= s_card * (s_card - k) ** k


def _log_criterion(k: int, window: int, s_card: int) -> bool:
    """Logarithmic screening version of `counting_criterion` (cheap for huge inputs)."""
    if k <= 0:
        return True
    if k > s_card or k > window:
        return False
    return math.log(k) + k * math.log(window) <= math.log(s_card) + k * math.log(s_card - k)


def max_guaranteed_k(window: int, s_card: int) -> int:
    """Largest k certified by `counting_criterion` (the criterion is monotone in k).

    A logarithmic screening pass locates the crossover cheaply even for astronomically
    large windows; the answer is then confirmed with exact integer arithmetic.
    """
    lo, hi = 0, min(window, s_card)
    while lo < hi:
        mid = (lo + hi + 1) // 2
        if _log_criterion(mid, window, s_card):
            lo = mid
        else:
            hi = mid - 1
    # exact confirmation in a small neighbourhood of the float crossover
    k = lo
    while k > 0 and not counting_criterion(k, window, s_card):
        k -= 1
    while counting_criterion(k + 1, window, s_card):
        k += 1
    return k


def interval_guarantee(n: int, delta: float) -> int:
    """Guaranteed sumset size for a delta-dense subset of [0, n), naive window D = (-n, n)."""
    return max_guaranteed_k(2 * n, math.ceil(delta * n))


def group_guarantee(order: int, delta: float) -> int:
    """Guaranteed sumset size for a delta-dense subset of an abelian group of given order."""
    return max_guaranteed_k(order, math.ceil(delta * order))


def asymptotic_prediction(n: int, delta: float) -> float:
    """The theoretical value log n / log(1/delta)."""
    return math.log(n) / math.log(1.0 / delta)


# ----------------------------------------------------------------------------
# 2. Constructive greedy shift extraction of a sumset
# ----------------------------------------------------------------------------


def greedy_sumset(
    S: Set[int], n: int, k: int
) -> Optional[Tuple[List[int], List[int]]]:
    """Greedy shift algorithm.

    Repeatedly pick the unused shift a in (-n, n) maximising |{u in U : u + a in S}|,
    and replace U by that surviving set.  After k rounds, if |U| >= k, the collected
    shifts A and any k-subset B of U satisfy A + B subset of S.

    Returns (A, B) or None if the greedy run does not reach size k.
    """
    U: Set[int] = set(S)
    A: List[int] = []
    used: Set[int] = set()
    for _ in range(k):
        best_a, best_survivors = None, None
        # candidate shifts: differences of S are the only ones that can help
        candidates = {s - u for s in S for u in U} - used if len(U) < 200 else None
        if candidates is None:
            candidates = set(range(-n + 1, n)) - used
        for a in candidates:
            surv = {u for u in U if u + a in S}
            if best_survivors is None or len(surv) > len(best_survivors):
                best_a, best_survivors = a, surv
        if best_a is None or not best_survivors:
            return None
        used.add(best_a)
        A.append(best_a)
        U = best_survivors
    if len(U) < k:
        return None
    B = sorted(U)[:k]
    return A, B


def verify_sumset(A: Sequence[int], B: Sequence[int], S: Set[int]) -> bool:
    """Check that every one of the |A|*|B| sums lies in S."""
    return all(a + b in S for a in A for b in B)


# ----------------------------------------------------------------------------
# 3. Affine cubes
# ----------------------------------------------------------------------------


def cube_points(u: int, gens: Sequence[int]) -> List[int]:
    """All 2^d subset sums u + sum_{i in I} gens[i]."""
    pts = [u]
    for g in gens:
        pts = pts + [p + g for p in pts]
    return pts


def is_proper_cube(u: int, gens: Sequence[int]) -> bool:
    """True iff the 2^d subset sums are pairwise distinct."""
    pts = cube_points(u, gens)
    return len(set(pts)) == len(pts)


def greedy_cube(
    S: Set[int], n: int, d: int, proper: bool = True
) -> Optional[Tuple[int, List[int]]]:
    """Greedy affine-cube extraction.

    Invariant: U is a set such that u + x lies in S for every u in U and every subset
    sum x of the generators collected so far.  One round replaces U by
    U intersect (U - a) for the shift a maximising that intersection; if `proper`,
    the shift is additionally forbidden to lie in (cube - cube).
    """
    U: Set[int] = set(S)
    gens: List[int] = []
    for _ in range(d):
        cube = cube_points(0, gens)
        forbidden = {x - y for x in cube for y in cube} if proper else {0}
        best_a, best_surv = None, None
        candidates = {v - u for u in U for v in U} - forbidden
        for a in candidates:
            surv = {u for u in U if u + a in U}
            if best_surv is None or len(surv) > len(best_surv):
                best_a, best_surv = a, surv
        if best_a is None or not best_surv:
            return None
        gens.append(best_a)
        U = best_surv
    if not U:
        return None
    return min(U), gens


def cube_existence_bound(n: int, delta: float, proper: bool = False) -> int:
    """Largest d with (4/delta)^(2^d) [* 4^d] <= 2n, i.e. the guaranteed cube dimension."""
    d = 0
    while True:
        lhs = math.log(4.0 / delta) * (2 ** (d + 1)) + (
            (d + 1) * math.log(4.0) if proper else 0.0
        )
        if lhs > math.log(2.0 * n):
            return d
        d += 1


def cube_avoidance_dimension(n: int, delta: float, eps: float = 0.0) -> int:
    """Least d with (1+eps)(d+1) log n <= 2^d log(1/delta): avoidance becomes possible."""
    d = 1
    while (1 + eps) * (d + 1) * math.log(n) > (2**d) * math.log(1.0 / delta):
        d += 1
        if d > 200:
            raise RuntimeError("no such dimension")
    return d


# ----------------------------------------------------------------------------
# 4. The avoidance (first moment) threshold
# ----------------------------------------------------------------------------


def avoidance_threshold(n: int, delta: float, eps: float = 0.0) -> float:
    """(1 + eps) * log n / log(1/delta): beyond this length, dense progression-free-sumset
    sets exist."""
    return (1 + eps) * math.log(n) / math.log(1.0 / delta)


def naive_first_moment(n: int, delta: float, K: int) -> float:
    """The wasteful union bound  n^3 * delta^(2K-1)  (L-shaped witness, constant 3/2)."""
    return math.exp(3 * math.log(n) + (2 * K - 1) * math.log(delta))


def witness_size(K: int, Q: int) -> int:
    """Number of points a sumset of two K-term progressions is forced to contain.

    With d1 = g e1, d2 = g e2, gcd(e1,e2) = 1 and Q = max(e1,e2), the sumset contains a
    K x min(Q,K) block, and always the (2K-1)-point L-shape.
    """
    return max(2 * K - 1, K * min(Q, K))


def weighted_first_moment(n: int, delta: float, K: int, qmax: int = 200) -> float:
    """The weighted union bound  sum_Q 2 n^2 delta^(witness_size(K,Q))  (constant 1).

    Only O(n^2) parameter triples give a fixed ratio Q, so the sum is geometric; the
    binding term is Q = 1, contributing 2 n^2 delta^(2K-1) and hence the threshold
    K ~ log n / log(1/delta).
    """
    total = 0.0
    for Q in range(1, qmax + 1):
        total += 2 * n * n * delta ** witness_size(K, Q)
    return total


# ----------------------------------------------------------------------------
# 5. Reporting
# ----------------------------------------------------------------------------


def hr(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_criterion_tables() -> None:
    hr("1.  The exact counting criterion in [n]:  k (2n)^k <= |S| (|S|-k)^k")
    print(f"{'n':>12} {'delta':>7} {'|S|':>12} {'guaranteed k':>13} {'log n/log(1/d)':>16}")
    for delta in (0.5, 0.25, 0.125):
        for e in (10, 14, 18, 20, 22, 26, 30):
            n = 2**e
            k = interval_guarantee(n, delta)
            print(
                f"{n:>12} {delta:>7} {math.ceil(delta*n):>12} {k:>13} "
                f"{asymptotic_prediction(n, delta):>16.2f}"
            )
        print()
    print("The guaranteed k grows linearly in log n; the naive window costs a factor")
    print("log(1/delta)/log(2/delta), which the short-window refinement removes.")

    hr("2.  Finite abelian groups: no window loss")
    print(f"{'|G|':>12} {'delta':>7} {'guaranteed k':>13} {'interval k':>11} {'log|G|/log(1/d)':>17}")
    for delta in (0.5, 0.125):
        for e in (14, 20, 26, 30):
            N = 2**e
            print(
                f"{N:>12} {delta:>7} {group_guarantee(N, delta):>13} "
                f"{interval_guarantee(N, delta):>11} "
                f"{asymptotic_prediction(N, delta):>17.2f}"
            )
        print()


def demo_effective_instances() -> None:
    hr("3.  The four effective instances of the paper (exact integer checks)")

    checks = [
        ("S subset [0,2^20), |S| >= 2^19  =>  sumset with |A|=|B|=7", 7, 2 * 2**20, 2**19),
        ("S subset [0,2^22), |S| >= 2^19  =>  sumset with |A|=|B|=4", 4, 2 * 2**22, 2**19),
    ]
    for label, k, window, card in checks:
        ok = counting_criterion(k, window, card)
        lhs = k * window**k
        rhs = card * (card - k) ** k
        print(f"  {label}")
        print(f"      k|D|^k = 2^{math.log2(lhs):.3f}   <=   |S|(|S|-k)^k = 2^{math.log2(rhs):.3f}   -> {ok}")

    # cubes: 2 (4n)^(2^d - 1) <= |S|^(2^d)
    for label, n, card, d, extra in [
        ("S subset [0,4096),  |S| >= 2048   =>  affine 2-cube", 4096, 2048, 2, 1),
        ("S subset [0,32768), |S| >= 16384  =>  PROPER 2-cube", 32768, 16384, 2, 4**2),
    ]:
        lhs = 2 * extra * (4 * n) ** (2**d - 1)
        rhs = card ** (2**d)
        print(f"  {label}")
        print(f"      2*{extra}*(4n)^(2^d-1) = 2^{math.log2(lhs):.3f}  <=  |S|^(2^d) = 2^{math.log2(rhs):.3f}"
              f"   -> {lhs <= rhs}")


def demo_constructive() -> None:
    hr("4.  Constructive greedy extraction on concrete dense sets")
    random.seed(20260821)

    for n, delta, k in [(400, 0.5, 4), (600, 0.4, 4), (300, 0.6, 5)]:
        m = int(delta * n)
        S = set(random.sample(range(n), m))
        out = greedy_sumset(S, n, k)
        if out is None:
            print(f"  n={n:4d} delta={delta} k={k}: greedy did not reach size {k}")
            continue
        A, B = out
        ok = verify_sumset(A, B, S)
        print(f"  n={n:4d} delta={delta} |S|={m:4d}: found |A|=|B|={k}, all {k*k} sums in S -> {ok}")
        print(f"      A = {sorted(A)}")
        print(f"      B = {sorted(B)[:8]}{' ...' if len(B) > 8 else ''}")
        print(f"      criterion would only certify k = {interval_guarantee(n, delta)}"
              " (greedy beats the guarantee in practice)")

    hr("5.  Greedy affine cubes")
    for n, delta, d in [(200, 0.5, 3), (400, 0.4, 3), (600, 0.35, 3)]:
        m = int(delta * n)
        S = set(random.sample(range(n), m))
        out = greedy_cube(S, n, d, proper=True)
        if out is None:
            print(f"  n={n:5d} delta={delta} d={d}: not found")
            continue
        u, gens = out
        pts = cube_points(u, gens)
        ok = all(p in S for p in pts) and is_proper_cube(u, gens)
        print(f"  n={n:5d} delta={delta} d={d}: base u={u}, generators {gens}")
        print(f"      all 2^{d} = {2**d} subset sums in S and distinct -> {ok}")
        print(f"      certified existence dimension (proper) = {cube_existence_bound(n, delta, True)}, "
              f"avoidance dimension = {cube_avoidance_dimension(n, delta)}")


def demo_thresholds() -> None:
    hr("6.  The two sides of the threshold  (delta = 1/4)")
    delta = 0.25
    print(f"{'n':>12} {'existence k':>12} {'avoid (1+e)L':>13} {'L=log n/log(1/d)':>18}")
    for e in (16, 20, 24, 28, 32):
        n = 2**e
        L = asymptotic_prediction(n, delta)
        print(f"{n:>12} {interval_guarantee(n, delta):>12} "
              f"{avoidance_threshold(n, delta, 0.05):>13.2f} {L:>18.2f}")
    print()
    print("  Both sides are  c * log n / log(1/delta)  with c -> 1: the constant is exact.")

    hr("7.  Why the block witness beats the L-shaped witness")
    n, delta = 2**24, 0.25
    L = asymptotic_prediction(n, delta)
    print(f"  n = 2^24, delta = 1/4,  log n / log(1/delta) = {L:.2f}")
    print(f"{'K':>6} {'naive n^3 d^(2K-1)':>22} {'weighted sum':>18}")
    for K in range(10, 26, 2):
        print(f"{K:>6} {naive_first_moment(n, delta, K):>22.4g} "
              f"{weighted_first_moment(n, delta, K):>18.4g}")
    print()
    print("  The naive bound drops below 1 near K = 1.5 L; the weighted bound near K = L.")
    kn = min(K for K in range(1, 200) if naive_first_moment(n, delta, K) < 1)
    kw = min(K for K in range(1, 200) if weighted_first_moment(n, delta, K) < 1)
    print(f"  crossover: naive K = {kn}  (= {kn/L:.2f} L),   weighted K = {kw}  (= {kw/L:.2f} L)")

    hr("8.  Cube dimension window: existence range and avoidance range are disjoint")
    print(f"{'n':>14} {'delta':>7} {'d_exist':>8} {'d_proper':>9} {'d_avoid':>8}")
    for delta in (0.5, 0.25):
        for e in (16, 24, 32, 48, 64):
            n = 2**e
            print(f"{n:>14} {delta:>7} {cube_existence_bound(n, delta):>8} "
                  f"{cube_existence_bound(n, delta, True):>9} "
                  f"{cube_avoidance_dimension(n, delta, 0.05):>8}")
        print()
    print("  d_proper <= d_exist < d_avoid always: the greedy construction stops strictly")
    print("  before the first-moment construction becomes possible.")


def main() -> None:
    demo_criterion_tables()
    demo_effective_instances()
    demo_constructive()
    demo_thresholds()
    print("\nAll checks completed.\n")


if __name__ == "__main__":
    main()
