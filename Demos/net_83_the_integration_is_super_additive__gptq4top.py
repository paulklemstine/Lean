"""
Numerical demonstrations of the quantization x sparse-attention interaction.

Self-contained (standard library only).  Every function is inlined and typed.

Contents
--------
1. The measured integration table and its interaction costs.
2. The four-key counterexample refuting additivity, and its negative twin.
3. The exact worst-case interaction  eps * min(1, (n-k)/k)  and its attainment.
4. The mean-square identity  sigma^2 (1/k - 1/n)  checked by exhaustive
   enumeration of the 2^n Rademacher dither ensemble.
5. Noise gain of softmax patterns versus the Cauchy-Schwarz floor 1/k.
6. Group-correlated quantization: the pair statistic P(S) = sum_t m_t(m_t-1),
   spread vs aligned selections, and the total loss of averaging at rho = 1.
7. The smoothing (Schur-convexity) step, verified by enumeration.
8. Selection-aware recentering, which removes the interaction.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Vector = Sequence[float]
Selection = Sequence[int]

# --------------------------------------------------------------------------
# Core model
# --------------------------------------------------------------------------


def avg_on(f: Vector, S: Selection) -> float:
    """Average of f over the index set S (0.0 if S is empty)."""
    if len(S) == 0:
        return 0.0
    return sum(f[i] for i in S) / len(S)


def dense_avg(f: Vector) -> float:
    """Average of f over the full context."""
    return avg_on(f, range(len(f)))


def deg_attention(v: Vector, S: Selection) -> float:
    """Degradation of the attention-only arm: |avg_S v - avg v|."""
    return abs(avg_on(v, S) - dense_avg(v))


def deg_quant(eta: Vector) -> float:
    """Degradation of the quantization-only arm: |avg eta|."""
    return abs(dense_avg(eta))


def deg_combined(v: Vector, eta: Vector, S: Selection) -> float:
    """Degradation of the combined arm: |avg_S (v + eta) - avg v|."""
    perturbed = [v[i] + eta[i] for i in range(len(v))]
    return abs(avg_on(perturbed, S) - dense_avg(v))


def interaction(v: Vector, eta: Vector, S: Selection) -> float:
    """Interaction cost = combined - attention-only - quantization-only."""
    return deg_combined(v, eta, S) - deg_attention(v, S) - deg_quant(eta)


def worst_bound(n: int, k: int, eps: float) -> float:
    """Worst-case interaction of a k-sparse head: eps * min(1, (n-k)/k)."""
    return eps * min(1.0, (n - k) / k)


# --------------------------------------------------------------------------
# 1.  The measured table
# --------------------------------------------------------------------------


def measured_table() -> None:
    print("=" * 74)
    print("1.  MEASURED INTEGRATION TABLE  (retained accuracy, cross-entropy)")
    print("=" * 74)

    ret_full, ce_full = 1.0000, 2.697
    ret_quant, ce_quant = 0.9081, 3.015
    attn: Dict[int, Tuple[float, float]] = {
        16: (0.9768, 2.774),
        20: (0.9803, 2.755),
        24: (0.9851, 2.742),
    }
    both: Dict[int, Tuple[float, float]] = {
        16: (0.8598, 3.220),
        20: (0.8707, 3.180),
        24: (0.8772, 3.155),
    }

    print(f"{'k':>4} {'L_attn':>9} {'L_quant':>9} {'additive':>10} "
          f"{'L_both':>9} {'interaction':>12}")
    interactions: Dict[int, float] = {}
    for k in (16, 20, 24):
        l_attn = ret_full - attn[k][0]
        l_quant = ret_full - ret_quant
        l_both = ret_full - both[k][0]
        add = l_attn + l_quant
        inter = l_both - add
        interactions[k] = inter
        print(f"{k:>4} {100*l_attn:>8.2f}% {100*l_quant:>8.2f}% "
              f"{100*add:>9.2f}% {100*l_both:>8.2f}% {100*inter:>11.2f}%")

    assert all(v > 0 for v in interactions.values()), "super-additivity"
    assert interactions[16] > interactions[20] > interactions[24], "antitone in k"
    print("\n  all interactions positive  -> super-additive (P2 confirmed)")
    print("  interactions decreasing in k -> antitone, as predicted")

    ce_excess_both = both[16][1] - ce_full
    ce_excess_add = (attn[16][1] - ce_full) + (ce_quant - ce_full)
    print(f"\n  cross-entropy at k=16: combined excess {ce_excess_both:.3f} nats"
          f"  vs additive {ce_excess_add:.3f} nats"
          f"  ({100*(ce_excess_both/ce_excess_add - 1):.0f}% shortfall)")

    # 1/k extrapolation anchored at k = 16.
    print("\n  1/k extrapolation anchored at k=16:")
    for k in (20, 24):
        pred = interactions[16] * 16 / k
        print(f"    k={k}: predicted {100*pred:.2f}%   measured "
              f"{100*interactions[k]:.2f}%")


# --------------------------------------------------------------------------
# 2.  The four-key counterexample
# --------------------------------------------------------------------------


def four_key_counterexample() -> None:
    print("\n" + "=" * 74)
    print("2.  FOUR-KEY COUNTEREXAMPLE:  additivity and independence refuted")
    print("=" * 74)

    v: List[float] = [0.0, 0.0, 3.0, 3.0]
    S: List[int] = [0, 1]

    eta_bad: List[float] = [-1.0, -1.0, -1.0, 1.0]
    print(f"  v = {v},  S = {S},  eta = {eta_bad}")
    print(f"    deg_A  = {deg_attention(v, S):.3f}")
    print(f"    deg_Q  = {deg_quant(eta_bad):.3f}")
    print(f"    deg_AQ = {deg_combined(v, eta_bad, S):.3f}")
    print(f"    I      = {interaction(v, eta_bad, S):+.3f}   (> 0: super-additive)")
    assert abs(interaction(v, eta_bad, S) - 0.5) < 1e-12

    eta_good: List[float] = [1.0, 1.0, 1.0, -1.0]
    print(f"\n  same v and S, eta' = {eta_good}")
    print(f"    deg_AQ = {deg_combined(v, eta_good, S):.3f}")
    print(f"    I      = {interaction(v, eta_good, S):+.3f}   (< 0: the effect is "
          f"NOT a pointwise law)")
    assert abs(interaction(v, eta_good, S) + 1.5) < 1e-12


# --------------------------------------------------------------------------
# 3.  Worst case
# --------------------------------------------------------------------------


def worst_case_demo(n: int = 12, eps: float = 0.1) -> None:
    print("\n" + "=" * 74)
    print(f"3.  EXACT WORST CASE  eps*min(1,(n-k)/k)   (n = {n}, eps = {eps})")
    print("=" * 74)

    print(f"{'k':>4} {'bound':>10} {'attained avg_S eta':>22}")
    for k in range(1, n):
        S = list(range(k))
        bound = worst_bound(n, k, eps)
        # Extremal zero-mean, eps-bounded error: +eps on S, balancing off S.
        off = -eps * k / (n - k)
        eta = [eps if i in S else off for i in range(n)]
        assert abs(sum(eta)) < 1e-12, "zero mean"
        attained = avg_on(eta, S)
        feasible = max(abs(x) for x in eta) <= eps + 1e-12
        note = f"{attained:.5f}" if feasible else "(infeasible: 2k > n)"
        print(f"{k:>4} {bound:>10.5f} {note:>22}")
        assert abs(avg_on(eta, S)) <= bound + 1e-12 or not feasible

    print("\n  the bound is antitone in k, and equals eps exactly when 2k <= n")


# --------------------------------------------------------------------------
# 4.  Mean-square identity by exhaustive Rademacher enumeration
# --------------------------------------------------------------------------


def rademacher_meansquare_identity(n: int = 10, sigma: float = 0.4) -> None:
    print("\n" + "=" * 74)
    print(f"4.  MEAN-SQUARE IDENTITY  sigma^2 (1/k - 1/n)   "
          f"(n = {n}, sigma = {sigma}, 2^{n} dithers)")
    print("=" * 74)

    v: List[float] = [math.sin(1.7 * i) + 0.3 * i for i in range(n)]
    ensemble: List[Tuple[int, ...]] = list(itertools.product((-1, 1), repeat=n))
    m = len(ensemble)
    vbar = dense_avg(v)

    print(f"{'k':>4} {'measured':>14} {'predicted':>14} {'abs err':>12}")
    for k in (1, 2, 3, 5, 7, n):
        S = list(range(k))
        combined = 0.0
        quant_only = 0.0
        for w in ensemble:
            eta = [sigma * s for s in w]
            perturbed = [v[i] + eta[i] for i in range(n)]
            combined += (avg_on(perturbed, S) - vbar) ** 2
            quant_only += dense_avg(eta) ** 2
        combined /= m
        quant_only /= m
        attn_only = (avg_on(v, S) - vbar) ** 2
        measured = combined - attn_only - quant_only
        predicted = sigma ** 2 * (1.0 / k - 1.0 / n)
        print(f"{k:>4} {measured:>14.9f} {predicted:>14.9f} "
              f"{abs(measured - predicted):>12.2e}")
        assert abs(measured - predicted) < 1e-9


# --------------------------------------------------------------------------
# 5.  Noise gain of softmax patterns
# --------------------------------------------------------------------------


def softmax_on(scores: Vector, S: Selection, beta: float) -> List[float]:
    """Softmax with inverse temperature beta, restricted to the support S."""
    mx = max(scores[i] for i in S)
    exps = {i: math.exp(beta * (scores[i] - mx)) for i in S}
    Z = sum(exps.values())
    return [exps[i] / Z if i in set(S) else 0.0 for i in range(len(scores))]


def noise_gain_demo(n: int = 32, k: int = 8) -> None:
    print("\n" + "=" * 74)
    print(f"5.  NOISE GAIN  sum_i w_i^2  vs the Cauchy-Schwarz floor 1/k "
          f"(n = {n}, k = {k})")
    print("=" * 74)

    scores: List[float] = [math.cos(0.9 * i) for i in range(n)]
    S: List[int] = sorted(range(n), key=lambda i: -scores[i])[:k]

    print(f"{'beta':>8} {'noise gain':>14} {'floor 1/k':>12} {'x dense (1/n)':>15}")
    for beta in (0.0, 1.0, 2.0, 5.0, 20.0):
        w = softmax_on(scores, S, beta)
        gain = sum(x * x for x in w)
        print(f"{beta:>8.1f} {gain:>14.6f} {1.0/k:>12.6f} {gain*n:>15.2f}")
        assert gain >= 1.0 / k - 1e-12, "Cauchy-Schwarz floor"

    print("\n  uniform weights (beta = 0) attain the floor exactly;")
    print("  every peaked softmax pays strictly more, so the uniform top-k head")
    print("  is the BEST case among all patterns with that support.")


# --------------------------------------------------------------------------
# 6.  Group-correlated quantization
# --------------------------------------------------------------------------


def pair_statistic(S: Selection, grp: Callable[[int], int]) -> int:
    """P(S): number of ORDERED same-group pairs inside the selection."""
    return sum(1 for i in S for j in S if i != j and grp(i) == grp(j))


def occupancy_profile(S: Selection, grp: Callable[[int], int]) -> Dict[int, int]:
    """Group occupancy profile (m_t) of the selection."""
    prof: Dict[int, int] = {}
    for i in S:
        prof[grp(i)] = prof.get(grp(i), 0) + 1
    return prof


def grouped_meansquare(k: int, P: int, sigma: float, rho: float) -> float:
    """Transmitted variance (sigma^2 k + rho sigma^2 P) / k^2."""
    return (sigma ** 2 * k + rho * sigma ** 2 * P) / k ** 2


def grouped_demo(n: int = 24, group_size: int = 4, k: int = 4,
                 sigma: float = 1.0, rho: float = 1.0) -> None:
    print("\n" + "=" * 74)
    print(f"6.  GROUP-CORRELATED QUANTIZATION  (n = {n}, group size = "
          f"{group_size}, k = {k}, rho = {rho})")
    print("=" * 74)

    def grp(i: int) -> int:
        return i // group_size

    selections: Dict[str, List[int]] = {
        "spread  (k distinct groups)": [0, 4, 8, 12],
        "half-mixed (2 + 2)":          [0, 1, 4, 5],
        "three-in-one (3 + 1)":        [0, 1, 2, 4],
        "aligned (single group)":      [0, 1, 2, 3],
    }

    print(f"{'selection':>28} {'profile':>16} {'P(S)':>6} {'E[(avg_S eta)^2]':>18}")
    for name, S in selections.items():
        prof = occupancy_profile(S, grp)
        P = pair_statistic(S, grp)
        # Profile identity: P(S) = sum_t m_t (m_t - 1).
        assert P == sum(m * (m - 1) for m in prof.values())
        ms = grouped_meansquare(k, P, sigma, rho)
        prof_str = "+".join(str(m) for m in sorted(prof.values(), reverse=True))
        print(f"{name:>28} {prof_str:>16} {P:>6} {ms:>18.6f}")

    print(f"\n  ideal (uncorrelated) transmitted variance sigma^2/k = "
          f"{sigma**2/k:.6f}")
    print(f"  aligned bound  sigma^2 (1 + rho(k-1))/k        = "
          f"{sigma**2*(1+rho*(k-1))/k:.6f}")
    print(f"  at rho = 1 the aligned selection transmits the FULL variance "
          f"sigma^2 = {sigma**2:.6f}:")
    print("  the sparse weighted sum averages nothing at all.")

    # Exhaustive check that the aligned selection is the global maximum.
    best = max(pair_statistic(S, grp)
               for S in itertools.combinations(range(n), k))
    print(f"\n  exhaustive check over all C({n},{k}) selections: max P(S) = "
          f"{best} = k(k-1) = {k*(k-1)}")
    assert best == k * (k - 1)


# --------------------------------------------------------------------------
# 7.  The smoothing (Schur-convexity) step
# --------------------------------------------------------------------------


def smoothing_step_demo(limit: int = 12) -> None:
    print("\n" + "=" * 74)
    print("7.  SMOOTHING STEP:  moving a key to an emptier group strictly helps")
    print("=" * 74)

    violations = 0
    for a in range(0, limit + 1):
        for b in range(0, a - 1):
            before = a * (a - 1) + b * (b - 1)
            after = (a - 1) * (a - 2) + (b + 1) * b
            if not after < before:
                violations += 1
            assert before - after == 2 * (a - b - 1)
    print(f"  checked all integer pairs with b + 2 <= a <= {limit}: "
          f"{violations} violations")
    print("  and the exact gap is  before - after = 2(a - b - 1) > 0.")

    # Balanced profiles minimise the penalty among profiles summing to k.
    k, n_groups, cap = 6, 3, 4
    print(f"\n  minimising sum_t m_t(m_t-1) over profiles with sum = {k}, "
          f"{n_groups} groups, capacity {cap}:")
    best_val, best_prof = None, None
    for prof in itertools.product(range(cap + 1), repeat=n_groups):
        if sum(prof) != k:
            continue
        val = sum(m * (m - 1) for m in prof)
        if best_val is None or val < best_val:
            best_val, best_prof = val, prof
    print(f"    minimiser {best_prof} with penalty {best_val} "
          f"(balanced), versus aligned-as-possible penalty "
          f"{max(sum(m*(m-1) for m in p) for p in itertools.product(range(cap+1), repeat=n_groups) if sum(p)==k)}")


# --------------------------------------------------------------------------
# 8.  Selection-aware recentering removes the interaction
# --------------------------------------------------------------------------


def recentering_demo(n: int = 12, k: int = 4, eps: float = 0.25) -> None:
    print("\n" + "=" * 74)
    print(f"8.  SELECTION-AWARE RECENTERING  (n = {n}, k = {k})")
    print("=" * 74)

    v: List[float] = [math.sin(0.8 * i) for i in range(n)]
    S: List[int] = list(range(k))
    eta: List[float] = [eps * math.cos(1.3 * i + 0.9) for i in range(n)]

    print(f"  before recentering:  I = {interaction(v, eta, S):+.6f}")

    shift = avg_on(eta, S)
    eta_rc: List[float] = [eta[i] - shift for i in range(n)]
    assert abs(sum(eta_rc[i] for i in S)) < 1e-12, "centred on S"

    print(f"  after  recentering:  I = {interaction(v, eta_rc, S):+.6f} "
          f"(= -deg_Q = {-deg_quant(eta_rc):+.6f})")
    print(f"  and deg_AQ = deg_A exactly: "
          f"{deg_combined(v, eta_rc, S):.6f} = {deg_attention(v, S):.6f}")
    assert abs(deg_combined(v, eta_rc, S) - deg_attention(v, S)) < 1e-12
    assert interaction(v, eta_rc, S) <= 1e-12


# --------------------------------------------------------------------------


def main() -> None:
    measured_table()
    four_key_counterexample()
    worst_case_demo()
    rademacher_meansquare_identity()
    noise_gain_demo()
    grouped_demo()
    smoothing_step_demo()
    recentering_demo()
    print("\n" + "=" * 74)
    print("All assertions passed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
