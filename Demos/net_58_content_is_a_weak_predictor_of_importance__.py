"""
Numerical demonstrations for
"Content Is a Weak Predictor of Importance: Three Nested Ceilings for
 Key-Content Cache Eviction".

Every routine is self-contained: only the Python standard library is used, so
this file runs anywhere with `python3 demo.py`.

The seven demonstrations, in the order of the paper:

  1. The measured table and the three pre-registered horns (closure fractions).
  2. Dimension blindness: an explicit importance profile, orthogonal to every
     affine probe on a random key matrix, on which every probe scores R^2 <= 0.
  3. The ANOVA (content) ceiling and its degeneracy under injective content.
  4. The swap witness: every static policy loses exactly (u - v) / 2.
  5. The capstone dispersion bound and its exact sqrt(2) looseness.
  6. Budget crossing: policy dominance reverses between B = 1 and B = 2.
  7. Depth heterogeneity strictly improves the aggregate guarantee.

Notation used throughout:
    a       an importance profile, a_i >= 0 is the total future attention of key i
    S       a selection (a set of retained indices), |S| = B
    ret     retained mass, ret(a, S) = sum_{i in S} a_i
    R^2     coefficient of determination of a score against the profile
"""

from __future__ import annotations

import math
import random
from typing import Callable, Dict, Iterable, List, Sequence, Set, Tuple

# --------------------------------------------------------------------------
# Core quantities
# --------------------------------------------------------------------------


def retained(a: Sequence[float], S: Iterable[int]) -> float:
    """Retained mass ret(a, S) = sum of a over the selected indices."""
    return sum(a[i] for i in S)


def top_set(s: Sequence[float], B: int) -> Set[int]:
    """A top-B set for the score s: the B indices of largest score.

    Ties are broken by index, which is a legitimate tie-break in the sense of
    the paper's definition of a top-B set.
    """
    order = sorted(range(len(s)), key=lambda i: (-s[i], i))
    return set(order[:B])


def mean(x: Sequence[float]) -> float:
    return sum(x) / len(x)


def ss_tot(a: Sequence[float]) -> float:
    """Total dispersion of the profile about its mean."""
    m = mean(a)
    return sum((v - m) ** 2 for v in a)


def sse(a: Sequence[float], s: Sequence[float]) -> float:
    """Squared error of a score against the profile."""
    return sum((av - sv) ** 2 for av, sv in zip(a, s))


def r_squared(a: Sequence[float], s: Sequence[float]) -> float:
    """R^2 = 1 - SSE / SS_tot; requires SS_tot > 0."""
    tot = ss_tot(a)
    if tot == 0.0:
        raise ValueError("R^2 undefined for a constant profile")
    return 1.0 - sse(a, s) / tot


def closure_fraction(baseline: float, policy: float, oracle: float) -> float:
    """Fraction of the oracle headroom the policy captures over the baseline."""
    return (policy - baseline) / (oracle - baseline)


# --------------------------------------------------------------------------
# 1. The measured table and the three horns
# --------------------------------------------------------------------------

MEASURED: Dict[int, Tuple[float, float, float]] = {
    #  B : (accumulated usage, static content probe, oracle)
    32: (0.8633, 0.8395, 0.9913),
    64: (0.8822, 0.8938, 0.9953),
    128: (0.9189, 0.9284, float("nan")),
}

PROBE_R2_MEAN, PROBE_R2_MIN, PROBE_R2_MAX = 0.329, 0.113, 0.639


def demo_measured_table() -> None:
    print("=" * 74)
    print("1.  THE MEASURED TABLE AND THE THREE PRE-REGISTERED HORNS")
    print("=" * 74)
    print(f"{'B':>5} {'usage':>9} {'probe':>9} {'oracle':>9} "
          f"{'closure':>10} {'to oracle':>11}")
    for B, (base, probe, oracle) in sorted(MEASURED.items()):
        if math.isnan(oracle):
            print(f"{B:>5} {base:>9.4f} {probe:>9.4f} {'--':>9} "
                  f"{'--':>10} {'--':>11}")
            continue
        clo = closure_fraction(base, probe, oracle)
        print(f"{B:>5} {base:>9.4f} {probe:>9.4f} {oracle:>9.4f} "
              f"{clo:>+9.2%} {oracle - probe:>11.4f}")

    b64, p64, o64 = MEASURED[64]
    b32, p32, o32 = MEASURED[32]
    print()
    print(f"P1  a probe closes >= 33% of the oracle gap"
          f"   -> REFUTED: {closure_fraction(b64, p64, o64):+.2%} at B=64, "
          f"{closure_fraction(b32, p32, o32):+.2%} at B=32")
    print(f"P2  >= 10 points remain to the oracle"
          f"        -> CONFIRMED: {o64 - p64:.4f} at B=64, "
          f"{o32 - p32:.4f} at B=32")
    print(f"P3  probe accuracy is depth-structured"
          f"        -> CONFIRMED: R^2 in [{PROBE_R2_MIN}, {PROBE_R2_MAX}], "
          f"mean {PROBE_R2_MEAN}")
    print()


# --------------------------------------------------------------------------
# 2. Dimension blindness
# --------------------------------------------------------------------------


def _solve_nullspace_vector(rows: List[List[float]], n: int) -> List[float]:
    """Return a nonzero vector orthogonal to every row, by Gaussian elimination.

    `rows` has fewer than n rows, so a nonzero solution always exists.
    """
    m = [row[:] for row in rows]
    pivots: List[int] = []
    r = 0
    for c in range(n):
        piv = None
        for rr in range(r, len(m)):
            if abs(m[rr][c]) > 1e-12:
                piv = rr
                break
        if piv is None:
            continue
        m[r], m[piv] = m[piv], m[r]
        scale = m[r][c]
        m[r] = [v / scale for v in m[r]]
        for rr in range(len(m)):
            if rr != r and abs(m[rr][c]) > 1e-15:
                f = m[rr][c]
                m[rr] = [v - f * w for v, w in zip(m[rr], m[r])]
        pivots.append(c)
        r += 1
        if r == len(m):
            break
    free = [c for c in range(n) if c not in pivots]
    if not free:
        raise RuntimeError("no free column: the system was not underdetermined")
    x = [0.0] * n
    x[free[0]] = 1.0
    for row_index, c in enumerate(pivots):
        x[c] = -m[row_index][free[0]]
    return x


def demo_dimension_blindness(n: int = 24, d: int = 5, seed: int = 20260902) -> None:
    """Build a profile invisible to every affine probe and check R^2 <= 0."""
    print("=" * 74)
    print("2.  DIMENSION BLINDNESS: 'd + 1 < n' FORCES A BLIND SUBSPACE")
    print("=" * 74)
    rng = random.Random(seed)
    key = [[rng.gauss(0.0, 1.0) for _ in range(d)] for _ in range(n)]

    # The moment map has d + 1 rows: the d key moments, plus total mass.
    rows = [[key[i][j] for i in range(n)] for j in range(d)]
    rows.append([1.0] * n)
    a = _solve_nullspace_vector(rows, n)
    norm = math.sqrt(sum(v * v for v in a))
    a = [v / norm for v in a]

    print(f"context length n = {n}, key dimension d = {d}")
    print(f"moment-map rank <= d + 1 = {d + 1}; "
          f"blind subspace has dimension >= n - (d+1) = {n - d - 1}")
    print(f"total mass of the blind profile:  {sum(a):+.3e}  (should be 0)")
    print(f"SS_tot of the blind profile:      {ss_tot(a):.6f}  (must be > 0)")

    worst = -1.0
    for _ in range(2000):
        w = [rng.gauss(0.0, 1.0) for _ in range(d)]
        b = rng.gauss(0.0, 1.0)
        s = [sum(w[j] * key[i][j] for j in range(d)) + b for i in range(n)]
        worst = max(worst, r_squared(a, s))
    print(f"best R^2 over 2000 random affine probes: {worst:+.6f}  (must be <= 0)")

    # Least squares cannot help either: the normal equations give the zero fit.
    print("even the exact least-squares probe is beaten by the mean predictor,")
    print("because every probe score is orthogonal to the profile.")
    print()
    print("At the measured geometry n = 1024, d = 64:")
    print(f"  invisible directions >= {1024 - 65};  "
          f"visible fraction = 65/1024 = {65 / 1024:.4f} < 0.064")
    print(f"  measured probe R^2 = {PROBE_R2_MEAN} is {PROBE_R2_MEAN / (65/1024):.1f}x "
          f"the visible fraction: the probe is NOT failing to fit.")
    print()


# --------------------------------------------------------------------------
# 3. The ANOVA (content) ceiling
# --------------------------------------------------------------------------


def anova_ceiling(content: Sequence[int], a: Sequence[float]) -> Tuple[float, float]:
    """Return (SS_within, ceiling) where ceiling = 1 - SS_within / SS_tot."""
    fibers: Dict[int, List[int]] = {}
    for i, y in enumerate(content):
        fibers.setdefault(y, []).append(i)
    ss_within = 0.0
    for members in fibers.values():
        bar = sum(a[i] for i in members) / len(members)
        ss_within += sum((a[i] - bar) ** 2 for i in members)
    return ss_within, 1.0 - ss_within / ss_tot(a)


def demo_anova_ceiling(seed: int = 7) -> None:
    print("=" * 74)
    print("3.  THE CONTENT (ANOVA) CEILING, AND WHEN IT IS VACUOUS")
    print("=" * 74)
    rng = random.Random(seed)
    n = 40
    content = [i % 8 for i in range(n)]          # 8 content values, 5 keys each
    a = [rng.random() + 0.4 * content[i] for i in range(n)]

    ssw, ceiling = anova_ceiling(content, a)
    print(f"pooled population: n = {n} keys over 8 distinct content values")
    print(f"SS_within = {ssw:.4f},  SS_tot = {ss_tot(a):.4f}")
    print(f"ceiling on R^2 for ANY function of content: {ceiling:.4f}")

    # the conditional mean attains it
    fibers: Dict[int, List[int]] = {}
    for i, y in enumerate(content):
        fibers.setdefault(y, []).append(i)
    cond = {y: sum(a[i] for i in mem) / len(mem) for y, mem in fibers.items()}
    s_star = [cond[content[i]] for i in range(n)]
    print(f"R^2 of the conditional-mean predictor:      {r_squared(a, s_star):.4f}"
          f"   (attains the ceiling)")

    # random content functions never exceed it
    best = -1e9
    for _ in range(5000):
        f = {y: rng.gauss(mean(a), 1.0) for y in fibers}
        best = max(best, r_squared(a, [f[content[i]] for i in range(n)]))
    print(f"best R^2 over 5000 random content functions: {best:.4f}   (below it)")

    injective = list(range(n))
    ssw_inj, ceiling_inj = anova_ceiling(injective, a)
    print()
    print("the honest caveat -- inside ONE context all keys are distinct:")
    print(f"  injective content map: SS_within = {ssw_inj:.1e}, "
          f"ceiling = {ceiling_inj:.4f}  (vacuous)")
    print("  the ceiling bites only on a POOLED, multi-context population.")
    print()


# --------------------------------------------------------------------------
# 4. The swap witness
# --------------------------------------------------------------------------


def demo_swap_witness() -> None:
    print("=" * 74)
    print("4.  THE SWAP WITNESS: IMPORTANCE IS RELATIONAL")
    print("=" * 74)
    print("two contexts, two key contents, roles exchanged, budget B = 1")
    print(f"{'u':>7} {'v':>7} {'avg profile':>13} {'any static':>12} "
          f"{'oracle':>9} {'deficit':>9} {'(u-v)/2':>9}")
    for u, v in [(1.0, 0.0), (0.9, 0.4), (0.99, 0.98), (3.0, 1.0)]:
        contexts = [[u, v], [v, u]]
        avg = [(contexts[0][i] + contexts[1][i]) / 2 for i in range(2)]
        # every singleton selection retains the same average mass
        statics = []
        for S in ({0}, {1}):
            statics.append(sum(retained(c, S) for c in contexts) / 2)
        assert abs(statics[0] - statics[1]) < 1e-12
        oracle = sum(max(c) for c in contexts) / 2
        deficit = oracle - statics[0]
        print(f"{u:>7.2f} {v:>7.2f} {avg[0]:>13.4f} {statics[0]:>12.4f} "
              f"{oracle:>9.4f} {deficit:>9.4f} {(u - v) / 2:>9.4f}")
    print()
    print("the two contents are IDENTICAL on average, so no score of the key --")
    print("linear, nonlinear, or adversarially clairvoyant -- can separate them.")
    print()


# --------------------------------------------------------------------------
# 5. The capstone dispersion bound
# --------------------------------------------------------------------------


def relational_deficit(contexts: Sequence[Sequence[float]], B: int) -> float:
    """avg_w max_{|T|=B} ret(a_w, T)  -  max_{|T|=B} ret(mean profile, T)."""
    W, n = len(contexts), len(contexts[0])
    avg = [sum(contexts[w][i] for w in range(W)) / W for i in range(n)]
    T = top_set(avg, B)
    best_static = sum(retained(contexts[w], T) for w in range(W)) / W
    oracle = sum(retained(contexts[w], top_set(contexts[w], B)) for w in range(W)) / W
    return oracle - best_static


def dispersion(contexts: Sequence[Sequence[float]]) -> float:
    """D = sum_i sum_w (a_w(i) - mean_w a_w(i))^2."""
    W, n = len(contexts), len(contexts[0])
    avg = [sum(contexts[w][i] for w in range(W)) / W for i in range(n)]
    return sum((contexts[w][i] - avg[i]) ** 2 for i in range(n) for w in range(W))


def demo_dispersion_bound(seed: int = 11) -> None:
    print("=" * 74)
    print("5.  THE CAPSTONE BOUND  deficit <= sqrt(B * D / |W|)")
    print("=" * 74)
    rng = random.Random(seed)
    print(f"{'|W|':>5} {'n':>5} {'B':>4} {'deficit':>10} {'bound':>10} {'ratio':>8}")
    for W, n, B in [(2, 8, 2), (4, 16, 4), (8, 32, 4), (16, 64, 8)]:
        contexts = [[abs(rng.gauss(0.0, 1.0)) for _ in range(n)] for _ in range(W)]
        d = relational_deficit(contexts, B)
        bnd = math.sqrt(B * dispersion(contexts) / W)
        print(f"{W:>5} {n:>5} {B:>4} {d:>10.4f} {bnd:>10.4f} {d / bnd:>8.3f}")

    print()
    print("sharpness on the swap witness (B = 1, |W| = 2, D = (u-v)^2):")
    print(f"{'u':>7} {'v':>7} {'deficit':>10} {'bound':>10} "
          f"{'bound/deficit':>15} {'sqrt(2)':>9}")
    for u, v in [(1.0, 0.0), (0.9, 0.4), (0.99, 0.98)]:
        contexts = [[u, v], [v, u]]
        d = relational_deficit(contexts, 1)
        bnd = math.sqrt(1 * dispersion(contexts) / 2)
        print(f"{u:>7.2f} {v:>7.2f} {d:>10.4f} {bnd:>10.4f} "
              f"{bnd / d:>15.6f} {math.sqrt(2):>9.6f}")
    print("the bound is loose by EXACTLY sqrt(2), independently of u and v:")
    print("the sqrt(B * dispersion) shape is right; only the constant is slack.")
    print()


# --------------------------------------------------------------------------
# 6. Budget crossing
# --------------------------------------------------------------------------


def demo_budget_crossing() -> None:
    print("=" * 74)
    print("6.  BUDGET CROSSING: DOMINANCE REVERSES BETWEEN B = 1 AND B = 2")
    print("=" * 74)
    v = [5.0, 1.0, 9.0, 0.0]                # true future attention
    acc = [4.0, 3.0, 2.0, 1.0]              # accumulation-like ranking 0>1>2>3
    probe = [2.0, 4.0, 3.0, 1.0]            # probe-like ranking      1>2>0>3
    print(f"true future attention v = {v}")
    print(f"{'B':>3} {'acc keeps':>12} {'ret':>6} {'probe keeps':>13} {'ret':>6} "
          f"{'oracle keeps':>14} {'ret':>6} {'winner':>8}")
    for B in (1, 2, 3):
        Sa, Sp = top_set(acc, B), top_set(probe, B)
        So = top_set(v, B)
        ra, rp, ro = retained(v, Sa), retained(v, Sp), retained(v, So)
        winner = "acc" if ra > rp else ("probe" if rp > ra else "tie")
        print(f"{B:>3} {str(sorted(Sa)):>12} {ra:>6.1f} {str(sorted(Sp)):>13} "
              f"{rp:>6.1f} {str(sorted(So)):>14} {ro:>6.1f} {winner:>8}")
    print()
    print("at B = 1 accumulation strictly wins (5 vs 1);")
    print("at B = 2 the probe strictly wins (10 vs 6);")
    print("at both budgets BOTH arms are strictly below the oracle.")
    print("=> a single-budget policy comparison extrapolates to nothing.")
    print()


# --------------------------------------------------------------------------
# 7. Depth heterogeneity
# --------------------------------------------------------------------------


def aggregate_bound(r2_values: Sequence[float], B: int, V: float) -> float:
    """Sum over heads of the per-head guarantee 2 sqrt(B (1 - R^2) V)."""
    return sum(2 * math.sqrt(B * (1 - r) * V) for r in r2_values)


def demo_depth_heterogeneity() -> None:
    print("=" * 74)
    print("7.  DEPTH HETEROGENEITY STRICTLY IMPROVES THE GUARANTEE")
    print("=" * 74)
    lo, hi = PROBE_R2_MIN, PROBE_R2_MAX
    het = math.sqrt(1 - hi) + math.sqrt(1 - lo)
    hom = 2 * math.sqrt(1 - (hi + lo) / 2)
    print(f"extreme measured cells: R^2 = {lo} and R^2 = {hi}, mean {(lo+hi)/2:.3f}")
    print(f"  heterogeneous aggregate: sqrt(1-{hi}) + sqrt(1-{lo}) = {het:.4f}")
    print(f"  homogeneous  aggregate: 2 sqrt(1 - {(hi+lo)/2:.3f})       = {hom:.4f}")
    print(f"  strict improvement: {hom - het:.4f} > 0   "
          f"(strict concavity of the square root)")
    print()
    # a spread-out depth profile against its flat counterpart
    depth_profile = [0.639, 0.512, 0.401, 0.288, 0.201, 0.150, 0.113, 0.328]
    flat = [mean(depth_profile)] * len(depth_profile)
    B, V = 64, 1.0
    print(f"an 8-head depth profile with mean R^2 = {mean(depth_profile):.3f}:")
    print(f"  aggregate guarantee, structured: {aggregate_bound(depth_profile, B, V):.4f}")
    print(f"  aggregate guarantee, flat      : {aggregate_bound(flat, B, V):.4f}")
    print("  => reporting only the MEAN R^2 understates the probe,")
    print("     and the probe still fails the 33% horn.")
    print()


# --------------------------------------------------------------------------
# Streaming eviction, for completeness
# --------------------------------------------------------------------------


def stream_evict(score: Callable[[int], float], n: int, B: int) -> Set[int]:
    """Streaming top-B eviction by a static score: O(n log B), O(B) memory."""
    import heapq

    heap: List[Tuple[float, int]] = []
    for i in range(n):
        s = score(i)
        if len(heap) < B:
            heapq.heappush(heap, (s, i))
        elif s > heap[0][0]:
            heapq.heapreplace(heap, (s, i))
    return {i for _, i in heap}


def demo_streaming_equivalence(seed: int = 3) -> None:
    print("=" * 74)
    print("8.  STREAMING EVICTION BY A STATIC SCORE IS EXACTLY TOP-B SELECTION")
    print("=" * 74)
    rng = random.Random(seed)
    n, B = 200, 16
    s = [rng.gauss(0.0, 1.0) for _ in range(n)]
    streamed = stream_evict(lambda i: s[i], n, B)
    offline = top_set(s, B)
    print(f"n = {n}, B = {B}: streaming set == offline top-B set? "
          f"{streamed == offline}")
    print("this is why a content probe is a STATIC policy in the sense of the")
    print("relational ceiling: its selection is a functional of the score alone.")
    print()


# --------------------------------------------------------------------------


def main() -> None:
    demo_measured_table()
    demo_dimension_blindness()
    demo_anova_ceiling()
    demo_swap_witness()
    demo_dispersion_bound()
    demo_budget_crossing()
    demo_depth_heterogeneity()
    demo_streaming_equivalence()
    print("=" * 74)
    print("CONCLUSION: a key's vector knows little about how much attention it")
    print("will receive.  Importance is relational and positional, not intrinsic")
    print("to key identity, and the oracle-to-policy gap is structural.")
    print("=" * 74)


if __name__ == "__main__":
    main()
