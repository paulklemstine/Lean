#!/usr/bin/env python3
"""
Numerical demonstrations of the additive-hybrid eviction law.

Self-contained: standard library only.  Every function is inlined and typed.

The setting.  There are `n` items, a budget `B`, and each item `i` carries an
unobservable true value `v[i]`.  Two cheap observable signals are available: an
accumulated-usage score `a[i]` and a static content-probe score `p[i]`.  The
additive hybrid policy scores each item by

        s_lambda(i) = a[i] + lambda * p[i]

and retains a *top set*: a `B`-element set no member of which is outscored by a
discarded item.  The retained value of a kept set `S` is  R(S) = sum_{i in S} v[i].
The *oracle* is the policy that scores with `v` itself.

The demos below verify, numerically:

  1. the exchange kernel (pairwise domination between the halves of a symmetric
     difference orders the sums);
  2. the universal oracle bound (no score beats the oracle at matched budget),
     over randomly generated instances and arbitrary random scores;
  3. the single-crossing lemma (raising lambda exchanges items only toward the
     probe) and the monotone trade-off path (probe mass up, usage mass down);
  4. the monotone-degradation law and the optimality of lambda = 0 under an
     anti-aligned probe;
  5. the calibrated four-item instance:  hybrid retains 0.9384 for every
     lambda >= 0, oracle retains 0.9954, gap exactly 0.0570;
  6. sharpness: a two-item instance where a positive lambda strictly helps;
  7. z-score invariance: the standardised sweep is a reparametrisation;
  8. budget monotonicity of the oracle;
  9. the sequential factor-B separation: an adaptive adversary forces any
     deterministic eviction rule to fault on every request of a length-m
     stream over B+1 live items, while the furthest-in-the-future schedule
     faults at most ceil(m / B) times.
"""

from __future__ import annotations

import random
from fractions import Fraction
from itertools import combinations
from typing import Callable, Dict, List, Sequence, Set, Tuple

Number = float


# --------------------------------------------------------------------------
# Core static model
# --------------------------------------------------------------------------


def top_set(scores: Sequence[Number], budget: int) -> Set[int]:
    """Return a top-`budget` set for `scores`: the `budget` highest-scoring
    indices, ties broken by index.  Any such set satisfies the defining
    property `scores[j] <= scores[i]` for kept `i` and discarded `j`."""
    order = sorted(range(len(scores)), key=lambda i: (-scores[i], i))
    return set(order[:budget])


def is_top_set(scores: Sequence[Number], budget: int, kept: Set[int]) -> bool:
    """Check the defining property of a top set directly."""
    if len(kept) != budget:
        return False
    dropped = [j for j in range(len(scores)) if j not in kept]
    return all(scores[j] <= scores[i] for i in kept for j in dropped)


def retained(values: Sequence[Number], kept: Set[int]) -> Number:
    """R_v(S) = sum of true values over the kept set."""
    return sum(values[i] for i in kept)


def hybrid(a: Sequence[Number], p: Sequence[Number], lam: Number) -> List[Number]:
    """The additive hybrid score a + lambda * p."""
    return [ai + lam * pi for ai, pi in zip(a, p)]


def zscore(x: Sequence[Number]) -> List[Number]:
    """Standardise a signal to mean 0, variance 1 (constant signals unchanged)."""
    n = len(x)
    mu = sum(x) / n
    var = sum((xi - mu) ** 2 for xi in x) / n
    sd = var ** 0.5
    if sd == 0.0:
        return [0.0] * n
    return [(xi - mu) / sd for xi in x]


# --------------------------------------------------------------------------
# 1. The exchange kernel
# --------------------------------------------------------------------------


def check_exchange_kernel(trials: int = 20000, seed: int = 20260823) -> Tuple[int, int]:
    """Sample equicardinal pairs (S, T) and random values; whenever every
    element of T \\ S has value at most every element of S \\ T, verify
    R(T) <= R(S).  Returns (number of applicable samples, number of violations).
    """
    rng = random.Random(seed)
    applicable = 0
    violations = 0
    for _ in range(trials):
        n = rng.randint(2, 9)
        k = rng.randint(1, n - 1)
        universe = list(range(n))
        S = set(rng.sample(universe, k))
        T = set(rng.sample(universe, k))
        v = [rng.uniform(-3.0, 3.0) for _ in range(n)]
        only_T = T - S
        only_S = S - T
        if any(v[j] > v[i] for j in only_T for i in only_S):
            continue
        applicable += 1
        if retained(v, T) > retained(v, S) + 1e-12:
            violations += 1
    return applicable, violations


# --------------------------------------------------------------------------
# 2. The universal oracle bound
# --------------------------------------------------------------------------


def check_oracle_bound(trials: int = 20000, seed: int = 7) -> Tuple[int, int, float]:
    """For random instances and *arbitrary* random scores s, verify
    R(top set of s) <= R(oracle top set).  Returns (trials, violations,
    largest observed gap)."""
    rng = random.Random(seed)
    violations = 0
    worst_gap = 0.0
    for _ in range(trials):
        n = rng.randint(2, 12)
        B = rng.randint(1, n - 1)
        v = [rng.uniform(0.0, 1.0) for _ in range(n)]
        s = [rng.uniform(-5.0, 5.0) for _ in range(n)]
        cheap = retained(v, top_set(s, B))
        oracle = retained(v, top_set(v, B))
        if cheap > oracle + 1e-12:
            violations += 1
        worst_gap = max(worst_gap, oracle - cheap)
    return trials, violations, worst_gap


# --------------------------------------------------------------------------
# 3. Single crossing and the monotone trade-off path
# --------------------------------------------------------------------------


def crossing_lambdas(a: Sequence[Number], p: Sequence[Number]) -> List[float]:
    """All positive lambdas at which some pair of items exchanges rank.  The
    kept set is constant between consecutive crossings, so this finite set of
    breakpoints determines the *entire* lambda-response exactly."""
    out: List[float] = []
    n = len(a)
    for i, j in combinations(range(n), 2):
        dp = p[i] - p[j]
        if dp == 0.0:
            continue
        lam = -(a[i] - a[j]) / dp
        if lam > 0.0:
            out.append(lam)
    return sorted(set(out))


def exact_lambda_regimes(
    a: Sequence[Number], p: Sequence[Number], budget: int
) -> List[Tuple[float, Set[int]]]:
    """Return one representative (lambda, kept set) per regime of the sweep on
    [0, infinity), using the breakpoints of `crossing_lambdas`."""
    breaks = crossing_lambdas(a, p)
    probes = [0.0]
    for k in range(len(breaks)):
        lo = breaks[k]
        hi = breaks[k + 1] if k + 1 < len(breaks) else lo + 1.0
        probes.append((lo + hi) / 2.0)
    regimes: List[Tuple[float, Set[int]]] = []
    for lam in probes:
        kept = top_set(hybrid(a, p, lam), budget)
        if not regimes or kept != regimes[-1][1]:
            regimes.append((lam, kept))
    return regimes


def check_single_crossing(
    trials: int = 5000, seed: int = 11
) -> Tuple[int, int, int, int]:
    """Verify: (i) entering items have probe score >= leaving items;
    (ii) probe mass is non-decreasing in lambda; (iii) usage mass is
    non-increasing in lambda.  Returns counts of violations of each plus the
    number of trials."""
    rng = random.Random(seed)
    bad_cross = bad_probe = bad_usage = 0
    for _ in range(trials):
        n = rng.randint(2, 8)
        B = rng.randint(1, n - 1)
        a = [rng.uniform(-2.0, 2.0) for _ in range(n)]
        p = [rng.uniform(-2.0, 2.0) for _ in range(n)]
        lam1 = rng.uniform(0.0, 2.0)
        lam2 = lam1 + rng.uniform(0.01, 3.0)
        S1 = top_set(hybrid(a, p, lam1), B)
        S2 = top_set(hybrid(a, p, lam2), B)
        if any(p[i] > p[j] + 1e-12 for j in S2 - S1 for i in S1 - S2):
            bad_cross += 1
        if retained(p, S1) > retained(p, S2) + 1e-9:
            bad_probe += 1
        if retained(a, S2) > retained(a, S1) + 1e-9:
            bad_usage += 1
    return trials, bad_cross, bad_probe, bad_usage


# --------------------------------------------------------------------------
# 4. Monotone degradation under an anti-aligned probe
# --------------------------------------------------------------------------


def anti_aligned_instance(n: int, rng: random.Random) -> Tuple[List[float], List[float], List[float]]:
    """Build an instance whose probe is anti-aligned with true value: p and v
    are ordered oppositely (p strictly decreasing in the index, v strictly
    increasing), while usage a is arbitrary."""
    p = sorted((rng.uniform(0.0, 5.0) for _ in range(n)), reverse=True)
    v = sorted(rng.uniform(0.0, 1.0) for _ in range(n))
    a = [rng.uniform(-1.0, 1.0) for _ in range(n)]
    return a, p, v


def check_monotone_degradation(trials: int = 4000, seed: int = 3) -> Tuple[int, int, int]:
    """On anti-aligned instances, verify the retained value is non-increasing
    in lambda and that lambda = 0 is optimal over a dense sweep."""
    rng = random.Random(seed)
    bad_mono = bad_zero = 0
    for _ in range(trials):
        n = rng.randint(2, 8)
        B = rng.randint(1, n - 1)
        a, p, v = anti_aligned_instance(n, rng)
        lams = [0.0] + sorted(rng.uniform(0.0, 8.0) for _ in range(6))
        vals = [retained(v, top_set(hybrid(a, p, lam), B)) for lam in lams]
        if any(vals[k + 1] > vals[k] + 1e-9 for k in range(len(vals) - 1)):
            bad_mono += 1
        if any(x > vals[0] + 1e-9 for x in vals):
            bad_zero += 1
    return trials, bad_mono, bad_zero


# --------------------------------------------------------------------------
# 5. The calibrated four-item instance
# --------------------------------------------------------------------------

A4: List[Fraction] = [Fraction(4), Fraction(3), Fraction(2), Fraction(1)]
P4: List[Fraction] = [Fraction(8), Fraction(6), Fraction(4), Fraction(2)]
V4: List[Fraction] = [
    Fraction(4692, 10000),
    Fraction(4692, 10000),
    Fraction(4977, 10000),
    Fraction(4977, 10000),
]


def calibrated_gap(lams: Sequence[Fraction]) -> List[Tuple[Fraction, Set[int], Fraction]]:
    """Exact rational evaluation of the calibrated instance at budget 2."""
    rows: List[Tuple[Fraction, Set[int], Fraction]] = []
    for lam in lams:
        s = [A4[i] + lam * P4[i] for i in range(4)]
        kept = top_set(s, 2)  # type: ignore[arg-type]
        rows.append((lam, kept, sum(V4[i] for i in kept)))
    return rows


# --------------------------------------------------------------------------
# 6. Sharpness
# --------------------------------------------------------------------------

A2: List[float] = [1.0, 0.0]
P2: List[float] = [0.0, 1.0]
V2: List[float] = [0.0, 1.0]


# --------------------------------------------------------------------------
# 9. The sequential model
# --------------------------------------------------------------------------


def furthest_in_future_cost(stream: Sequence[int], cache: Set[int]) -> int:
    """Offline (hindsight) cost: on a fault, evict the resident item whose next
    request is furthest in the future.  This is an optimal demand-paging
    schedule, and on B+1 live items it faults at most ceil(m / B) times."""
    C = set(cache)
    faults = 0
    for t, r in enumerate(stream):
        if r in C:
            continue
        faults += 1
        if len(C) > 0:
            def next_use(x: int) -> int:
                for u in range(t + 1, len(stream)):
                    if stream[u] == x:
                        return u
                return len(stream) + 1
            victim = max(C, key=next_use)
            C.discard(victim)
        C.add(r)
    return faults


EvictionRule = Callable[[Set[int], int], int]


def run_cost(rule: EvictionRule, stream: Sequence[int], cache: Set[int]) -> int:
    """Cost of the deterministic policy given by `rule`, which names the victim."""
    C = set(cache)
    faults = 0
    for r in stream:
        if r in C:
            continue
        faults += 1
        victim = rule(C, r)
        C.discard(victim)
        C.add(r)
    return faults


def adversary_stream(
    rule: EvictionRule, m: int, cache: Set[int], universe_size: int
) -> List[int]:
    """The adaptive adversary on B+1 live items: always request the single item
    currently absent from the cache, i.e. exactly the one the policy just threw
    away.  Every request is a fault."""
    C = set(cache)
    stream: List[int] = []
    for _ in range(m):
        absent = next(x for x in range(universe_size) if x not in C)
        stream.append(absent)
        victim = rule(C, absent)
        C.discard(victim)
        C.add(absent)
    return stream


def hybrid_evictor(a: Dict[int, float], p: Dict[int, float], lam: float) -> EvictionRule:
    """The sequential hybrid rule: evict the resident item of least a + lambda*p."""

    def rule(C: Set[int], _r: int) -> int:
        return min(C, key=lambda i: (a[i] + lam * p[i], i))

    return rule


def check_factor_B_separation(
    B: int, m: int, lams: Sequence[float], seed: int = 5
) -> List[Tuple[float, int, int, int]]:
    """For each lambda, build the adversarial stream against the hybrid evictor
    on B+1 items and compare the online cost with the offline cost.  Returns
    rows (lambda, online faults, offline faults, ceil(m / B))."""
    rng = random.Random(seed)
    universe = B + 1
    a = {i: rng.uniform(0.0, 1.0) for i in range(universe)}
    p = {i: rng.uniform(0.0, 1.0) for i in range(universe)}
    cache = set(range(B))
    rows: List[Tuple[float, int, int, int]] = []
    for lam in lams:
        rule = hybrid_evictor(a, p, lam)
        stream = adversary_stream(rule, m, cache, universe)
        online = run_cost(rule, stream, cache)
        offline = furthest_in_future_cost(stream, cache)
        rows.append((lam, online, offline, -(-m // B)))
    return rows


# --------------------------------------------------------------------------
# Presentation
# --------------------------------------------------------------------------


def rule(title: str) -> None:
    print()
    print("=" * 72)
    print(title)
    print("=" * 72)


def main() -> None:
    rule("1.  The exchange kernel")
    applicable, violations = check_exchange_kernel()
    print(f"  samples satisfying the domination hypothesis : {applicable}")
    print(f"  violations of  R(T) <= R(S)                  : {violations}")
    print("  -> pairwise domination between the two halves of the symmetric")
    print("     difference orders the sums; no matching argument is needed.")

    rule("2.  The universal oracle bound (score-blind)")
    trials, viol, worst = check_oracle_bound()
    print(f"  random instances with arbitrary random scores : {trials}")
    print(f"  violations of  R(top set of s) <= R(oracle)   : {viol}")
    print(f"  largest observed oracle gap                   : {worst:.4f}")
    print("  -> the bound never inspects the score, so accumulation, recency,")
    print("     content probes and all their combinations are bounded at once.")

    rule("3.  Single crossing and the monotone trade-off path")
    trials, bad_cross, bad_probe, bad_usage = check_single_crossing()
    print(f"  random additive-hybrid pairs lam1 < lam2                : {trials}")
    print(f"  violations of  p(entering) >= p(leaving)                : {bad_cross}")
    print(f"  violations of  probe mass non-decreasing in lambda      : {bad_probe}")
    print(f"  violations of  usage mass non-increasing in lambda      : {bad_usage}")
    print("  -> the sweep is a one-dimensional monotone path: probe mass is")
    print("     purchased with usage mass, at a rate that never reverses.")

    rule("4.  Monotone degradation and the optimality of lambda = 0")
    trials, bad_mono, bad_zero = check_monotone_degradation()
    print(f"  anti-aligned instances tested                    : {trials}")
    print(f"  violations of monotone decrease in lambda        : {bad_mono}")
    print(f"  cases where some lambda > 0 beat lambda = 0      : {bad_zero}")
    print("  -> with an anti-aligned probe, no probe weight can beat pure usage.")

    rule("5.  The calibrated four-item instance (exact rational arithmetic)")
    print("  a = (4, 3, 2, 1)   p = (8, 6, 4, 2)   B = 2")
    print("  v = (0.4692, 0.4692, 0.4977, 0.4977)")
    print()
    print(f"  {'lambda':>8}  {'kept set':>10}  {'retained':>10}")
    lams = [Fraction(0), Fraction(1, 4), Fraction(1), Fraction(4), Fraction(1000)]
    for lam, kept, val in calibrated_gap(lams):
        print(f"  {float(lam):>8.2f}  {str(sorted(kept)):>10}  {float(val):>10.4f}")
    oracle_kept = top_set(V4, 2)  # type: ignore[arg-type]
    oracle_val = sum(V4[i] for i in oracle_kept)
    print(f"  {'oracle':>8}  {str(sorted(oracle_kept)):>10}  {float(oracle_val):>10.4f}")
    gap = oracle_val - sum(V4[i] for i in top_set(hybrid(A4, P4, Fraction(1)), 2))  # type: ignore[arg-type]
    print()
    print(f"  gap, exactly and uniformly in lambda >= 0 : {gap}  =  {float(gap):.4f}")
    print("  -> 0.9384 retained by every hybrid arm, 0.9954 by the oracle:")
    print("     5.7 points, matching the measured sweep to four decimals.")

    rule("6.  Sharpness: a positive lambda can strictly help")
    print("  a = (1, 0)   p = (0, 1)   v = (0, 1)   B = 1")
    for lam in (0.0, 2.0):
        kept = top_set(hybrid(A2, P2, lam), 1)
        print(f"  lambda = {lam:>4.1f} -> kept {sorted(kept)}, retained {retained(V2, kept):.1f}")
    print("  -> anti-alignment is not removable.  The monotone-degradation law")
    print("     is a verdict on the probe, not on additive fusion.")

    rule("7.  z-scoring is only a reparametrisation")
    rng = random.Random(99)
    n, B = 7, 3
    a = [rng.uniform(-2, 2) for _ in range(n)]
    p = [rng.uniform(-2, 2) for _ in range(n)]
    za, zp = zscore(a), zscore(p)
    sig = (sum((x - sum(a) / n) ** 2 for x in a) / n) ** 0.5
    tau = (sum((x - sum(p) / n) ** 2 for x in p) / n) ** 0.5
    mismatches = 0
    for lam in (0.0, 0.25, 1.0, 4.0, 25.0):
        kept_z = top_set([za[i] + lam * zp[i] for i in range(n)], B)
        kept_raw = top_set(hybrid(a, p, lam * sig / tau), B)
        mismatches += int(kept_z != kept_raw)
        print(f"  lambda = {lam:>5.2f}: z-scored kept {sorted(kept_z)}, "
              f"raw at lambda*sigma/tau = {lam * sig / tau:>6.3f} kept {sorted(kept_raw)}")
    print(f"  mismatches: {mismatches}")

    rule("8.  Budget monotonicity: the one knob that provably helps")
    rng = random.Random(2024)
    v = [rng.uniform(0.0, 1.0) for _ in range(12)]
    print(f"  {'B':>4}  {'oracle retained':>16}")
    for B in (1, 2, 4, 8, 12):
        print(f"  {B:>4}  {retained(v, top_set(v, B)):>16.4f}")
    print("  -> non-decreasing in B, since any small optimal set can be padded.")

    rule("9.  The sequential factor-B separation")
    B, m = 8, 200
    print(f"  B = {B} slots, B+1 = {B+1} live items, stream length m = {m}")
    print()
    print(f"  {'lambda':>8}  {'online faults':>14}  {'offline faults':>15}  {'ceil(m/B)':>10}")
    for lam, online, offline, bound in check_factor_B_separation(B, m, [0.0, 0.25, 1.0, 4.0]):
        print(f"  {lam:>8.2f}  {online:>14}  {offline:>15}  {bound:>10}")
    print()
    print("  -> against the adaptive adversary the hybrid evictor faults on")
    print("     EVERY request, for every probe weight, while hindsight faults")
    print("     at most ceil(m/B) times: a factor-B separation no score escapes.")

    rule("10.  The lambda-response has finitely many regimes")
    rng = random.Random(4242)
    n, B = 7, 3
    a = [rng.uniform(-2, 2) for _ in range(n)]
    p = [rng.uniform(-2, 2) for _ in range(n)]
    regimes = exact_lambda_regimes(a, p, B)
    print(f"  n = {n}, B = {B}: pairs = {n * (n - 1) // 2}, "
          f"boundary pairs B(n-B) = {B * (n - B)}")
    print(f"  distinct kept sets over lambda in [0, infinity): {len(regimes)}")
    for lam, kept in regimes:
        print(f"    lambda ~ {lam:>7.3f}  ->  kept {sorted(kept)}")
    print("  -> a lambda-grid finer than the breakpoint set is provably redundant.")

    print()
    print("All checks completed.")


if __name__ == "__main__":
    main()
