"""
Numerical demonstrations for
"The Agreement Geometry of Layer Transplants and the Capacity of Shared Serving".

Self-contained: standard library only (math, itertools, random). Every helper is
inlined below and fully type-hinted.

Contents
--------
 1. Agreement geometry primitives (agreement, Hamming distance, novelty).
 2. The measured layer-transplant profile, realised exactly on 10,000 positions,
    and the both-parents-collapse certificate evaluated on it.
 3. The portability budget (Hamming triangle inequality) checked by brute force.
 4. Sharing gaps of the two swap arms and the 22x separation.
 5. The balanced compromise: attaining the pairwise sharing ceiling.
 6. The Lipschitz dose-response principle and the causal swap-site separation.
 7. Cost/agreement dissociation and reverse-Markov cost localisation.
 8. Multi-fine-tune serving: the pairwise ceiling, the multiplicity bound,
    the serving-capacity curve, the phase transition at k(1-beta) = 2, and
    the sqrt(beta) limit.
 9. Extremal families: the hub construction and the complete c-designs, with
    the quantisation of extremal serving values verified numerically.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from itertools import combinations, product
from typing import Dict, List, Sequence, Tuple

Predictor = Sequence[int]

# ----------------------------------------------------------------------------
# 1. Agreement geometry primitives
# ----------------------------------------------------------------------------


def agree_frac(f: Predictor, g: Predictor) -> float:
    """Fraction of positions where two predictors choose the same token."""
    if len(f) != len(g):
        raise ValueError("predictors must be defined on the same positions")
    n: int = len(f)
    return sum(1 for a, b in zip(f, g) if a == b) / n


def dis_frac(f: Predictor, g: Predictor) -> float:
    """Normalized Hamming distance = 1 - agreement."""
    return 1.0 - agree_frac(f, g)


def novel_frac(h: Predictor, a: Predictor, b: Predictor) -> float:
    """Fraction of positions where the hybrid matches neither parent."""
    n: int = len(h)
    return sum(1 for x, p, q in zip(h, a, b) if x != p and x != q) / n


def is_parent_selector(h: Predictor, a: Predictor, b: Predictor) -> bool:
    """True iff the hybrid always reproduces one of the two parents' tokens."""
    return all(x == p or x == q for x, p, q in zip(h, a, b))


def collapse_certificate(h: Predictor, a: Predictor, b: Predictor) -> float:
    """Lower bound on novelty: agr(A,B) - min(agr(H,A), agr(H,B))."""
    return agree_frac(a, b) - min(agree_frac(h, a), agree_frac(h, b))


def sharing_gap(h: Predictor, a: Predictor, b: Predictor) -> float:
    """Unused portability budget: 1 + agr(A,B) - (agr(H,A) + agr(H,B))."""
    return 1.0 + agree_frac(a, b) - (agree_frac(h, a) + agree_frac(h, b))


# ----------------------------------------------------------------------------
# 2. The measured profile, realised exactly
# ----------------------------------------------------------------------------

# Measured values (12 held-out windows, context length 512).
BETA: float = 0.8327  # cross-parent baseline
TAIL_HOST: float = 0.5845  # tail hybrid vs base
TAIL_DONOR: float = 0.5443  # tail hybrid vs instruct
BULK_HOST: float = 0.9635  # bulk hybrid vs base
BULK_DONOR: float = 0.8385  # bulk hybrid vs instruct
TAIL_HOST_REV: float = 0.5887
TAIL_DONOR_REV: float = 0.6289
TAIL_DELTA_CE: float = 0.4652  # nats


def realize_measured_profile() -> Tuple[List[int], List[int], List[int]]:
    """Explicit 10,000-position realisation of the measured tail-swap profile.

    Five behavioural classes, tokens in {0, 1, 2}:

        class  size   parents        hybrid
          0    5000   A = B          follows both
          1    3327   A = B          novel
          2     845   A != B         follows A
          3     443   A != B         follows B
          4     385   A != B         novel

    Returns (A, B, H) with agr(A,B)=0.8327, agr(H,A)=0.5845, agr(H,B)=0.5443
    and novelty exactly 0.3712.
    """
    sizes: List[int] = [5000, 3327, 845, 443, 385]
    a_tok: List[int] = [0, 0, 0, 0, 0]
    b_tok: List[int] = [0, 0, 1, 1, 1]
    h_tok: List[int] = [0, 1, 0, 1, 2]
    a: List[int] = []
    b: List[int] = []
    h: List[int] = []
    for cls, size in enumerate(sizes):
        a.extend([a_tok[cls]] * size)
        b.extend([b_tok[cls]] * size)
        h.extend([h_tok[cls]] * size)
    return a, b, h


def demo_collapse_certificate() -> None:
    print("=" * 78)
    print("2. THE MEASURED PROFILE AND THE BOTH-PARENTS-COLLAPSE CERTIFICATE")
    print("=" * 78)
    a, b, h = realize_measured_profile()
    print(f"  positions N                       = {len(a)}")
    print(f"  agr(A, B)  cross-parent baseline  = {agree_frac(a, b):.4f}   (target {BETA})")
    print(f"  agr(H, A)  tail hybrid vs host    = {agree_frac(h, a):.4f}   (target {TAIL_HOST})")
    print(f"  agr(H, B)  tail hybrid vs donor   = {agree_frac(h, b):.4f}   (target {TAIL_DONOR})")
    print(f"  novelty nu(H; A, B)               = {novel_frac(h, a, b):.4f}")
    print(f"  certificate lower bound           = {collapse_certificate(h, a, b):.4f}")
    print(f"  certificate satisfied             = {novel_frac(h,a,b) >= collapse_certificate(h,a,b) - 1e-12}")
    print(f"  hybrid is a parent selector?      = {is_parent_selector(h, a, b)}  (must be False)")
    print()
    print("  Certificate applied to the measured numbers only (no construction):")
    print(f"    tail, base<-instruct : novelty >= {BETA - min(TAIL_HOST, TAIL_DONOR):.4f}")
    print(f"    tail, instruct<-base : novelty >= {BETA - min(TAIL_HOST_REV, TAIL_DONOR_REV):.4f}"
          f"   (donor-side form alone gives {BETA - TAIL_DONOR_REV:.4f})")
    print(f"    bulk control         : novelty >= {BETA - min(BULK_HOST, BULK_DONOR):.4f}"
          "   (<= 0: vacuous, no collapse)")
    print()


# ----------------------------------------------------------------------------
# 3. The portability budget, brute-forced
# ----------------------------------------------------------------------------


def demo_triangle_inequality(n_positions: int = 4, n_tokens: int = 3) -> None:
    print("=" * 78)
    print("3. THE PORTABILITY BUDGET: agr(f,g) + agr(g,h) <= 1 + agr(f,h)")
    print("=" * 78)
    worst_slack: float = math.inf
    witness: Tuple[Tuple[int, ...], ...] = ()
    space = list(product(range(n_tokens), repeat=n_positions))
    for f in space:
        for g in space:
            for h in space:
                slack = 1.0 + agree_frac(f, h) - agree_frac(f, g) - agree_frac(g, h)
                if slack < worst_slack:
                    worst_slack = slack
                    witness = (f, g, h)
    print(f"  exhaustive over {len(space)}^3 = {len(space)**3} triples on "
          f"{n_positions} positions, {n_tokens} tokens")
    print(f"  minimum slack found = {worst_slack:.6f}  (must be >= 0)")
    print(f"  a tight witness     = {witness}")
    print()


# ----------------------------------------------------------------------------
# 4. Sharing gaps of the two arms
# ----------------------------------------------------------------------------


def demo_sharing_gap() -> None:
    print("=" * 78)
    print("4. SHARING GAPS: HOW MUCH OF THE BUDGET EACH ARM WASTES")
    print("=" * 78)
    gap_tail: float = 1.0 + BETA - (TAIL_HOST + TAIL_DONOR)
    gap_bulk: float = 1.0 + BETA - (BULK_HOST + BULK_DONOR)
    print(f"  budget                = 1 + beta = {1.0 + BETA:.4f}")
    print(f"  tail arm agreement sum= {TAIL_HOST + TAIL_DONOR:.4f}   gap = {gap_tail:.4f}")
    print(f"  bulk arm agreement sum= {BULK_HOST + BULK_DONOR:.4f}   gap = {gap_bulk:.4f}")
    print(f"  ratio gap_tail/gap_bulk = {gap_tail / gap_bulk:.2f}x   (theorem: >= 22x)")
    print()


# ----------------------------------------------------------------------------
# 5. The balanced compromise
# ----------------------------------------------------------------------------


def balanced_compromise(a: Predictor, b: Predictor) -> List[int]:
    """Split the parents' disagreement set in half: follow B on the first half,
    A elsewhere. Saturates agr(H,A) + agr(H,B) = 1 + agr(A,B) exactly."""
    disagree: List[int] = [i for i, (p, q) in enumerate(zip(a, b)) if p != q]
    half = set(disagree[: len(disagree) // 2])
    return [b[i] if i in half else a[i] for i in range(len(a))]


def demo_balanced_sharing(n: int = 10_000, seed: int = 20260823) -> None:
    print("=" * 78)
    print("5. THE BALANCED COMPROMISE ATTAINS THE PAIRWISE SHARING CEILING")
    print("=" * 78)
    rng = random.Random(seed)
    # Random parents with cross-parent agreement close to the measured beta.
    a: List[int] = [rng.randrange(50) for _ in range(n)]
    b: List[int] = [x if rng.random() < BETA else (x + 1 + rng.randrange(49)) % 50 for x in a]
    h: List[int] = balanced_compromise(a, b)
    beta_emp: float = agree_frac(a, b)
    print(f"  empirical beta = agr(A,B)          = {beta_emp:.4f}")
    print(f"  agr(H, A)                          = {agree_frac(h, a):.4f}")
    print(f"  agr(H, B)                          = {agree_frac(h, b):.4f}")
    print(f"  sum                                = {agree_frac(h,a)+agree_frac(h,b):.6f}")
    print(f"  ceiling 1 + agr(A,B)               = {1.0 + beta_emp:.6f}   (equality expected)")
    print(f"  imbalance |agr(H,A) - agr(H,B)|    = {abs(agree_frac(h,a)-agree_frac(h,b)):.6f}"
          f"   (<= 1/N = {1.0/n:.6f})")
    print(f"  min over parents                   = {min(agree_frac(h,a), agree_frac(h,b)):.4f}")
    print(f"  optimum (1 + beta)/2               = {(1.0 + beta_emp)/2:.4f}")
    print()
    print(f"  At the measured beta = {BETA}: a balanced shared model holds "
          f"{(1.0 + BETA)/2:.4f} with BOTH fine-tunes.")
    print(f"  The tail hybrid holds only {TAIL_DONOR:.4f} with its donor: it forfeits "
          f"{(1.0 + BETA)/2 - TAIL_DONOR:.4f}.")
    print(f"  In MEAN agreement over the two parents the bulk hybrid reaches "
          f"{(BULK_HOST + BULK_DONOR)/2:.4f},")
    print(f"  within {(1.0 + BETA)/2 - (BULK_HOST + BULK_DONOR)/2:.4f} of the optimal mean "
          f"{(1.0 + BETA)/2:.4f}; the tail hybrid reaches only "
          f"{(TAIL_HOST + TAIL_DONOR)/2:.4f}.")
    print()


# ----------------------------------------------------------------------------
# 6. Lipschitz dose-response and swap-site separation
# ----------------------------------------------------------------------------


def demo_lipschitz(n: int = 2000, trials: int = 300, seed: int = 7) -> None:
    print("=" * 78)
    print("6. 1-LIPSCHITZ DOSE-RESPONSE AND THE CAUSAL SWAP-SITE SEPARATION")
    print("=" * 78)
    rng = random.Random(seed)
    a: List[int] = [rng.randrange(8) for _ in range(n)]
    b: List[int] = [rng.randrange(8) for _ in range(n)]
    worst_ratio_agr: float = 0.0
    worst_ratio_nov: float = 0.0
    for _ in range(trials):
        h1: List[int] = [rng.randrange(8) for _ in range(n)]
        # perturb h1 on a random subset to get h2
        k = rng.randrange(1, n)
        idx = rng.sample(range(n), k)
        h2: List[int] = list(h1)
        for i in idx:
            h2[i] = rng.randrange(8)
        d = dis_frac(h1, h2)
        if d == 0.0:
            continue
        worst_ratio_agr = max(worst_ratio_agr, abs(agree_frac(h1, a) - agree_frac(h2, a)) / d)
        worst_ratio_nov = max(
            worst_ratio_nov, abs(novel_frac(h1, a, b) - novel_frac(h2, a, b)) / d
        )
    print(f"  worst |d agr| / Hamming distance over {trials} random pairs = "
          f"{worst_ratio_agr:.4f}   (must be <= 1)")
    print(f"  worst |d nu | / Hamming distance                            = "
          f"{worst_ratio_nov:.4f}   (must be <= 1)")
    print()
    sep: float = BULK_HOST - TAIL_HOST
    print("  Run backwards on the measurement (no weights needed):")
    print(f"    agr(H_bulk, A) - agr(H_tail, A) = {sep:.4f}")
    print(f"    => dis(H_bulk, H_tail) >= {sep:.4f}")
    print(f"    parents' own distance dis(A,B)  = {1.0 - BETA:.4f}")
    print(f"    two transplants are further apart than the two parents: "
          f"{sep > 1.0 - BETA}")
    print()


# ----------------------------------------------------------------------------
# 7. Cost/agreement dissociation and cost localisation
# ----------------------------------------------------------------------------


def cross_entropy(p: Sequence[float], q: Sequence[float]) -> float:
    """-sum_i p_i log q_i."""
    return -sum(pi * math.log(qi) for pi, qi in zip(p, q))


def demo_cost_dissociation() -> None:
    print("=" * 78)
    print("7a. ZERO COST DOES NOT CERTIFY AGREEMENT")
    print("=" * 78)
    p: List[float] = [0.5, 0.5]
    for t in (0.05, 0.2, 0.45):
        q1: List[float] = [0.5 + t, 0.5 - t]
        q2: List[float] = [0.5 - t, 0.5 + t]
        ce1, ce2 = cross_entropy(p, q1), cross_entropy(p, q2)
        top1, top2 = max(range(2), key=lambda i: q1[i]), max(range(2), key=lambda i: q2[i])
        print(f"  t = {t:.2f}:  CE(p,q1) = {ce1:.10f}   CE(p,q2) = {ce2:.10f}   "
              f"|diff| = {abs(ce1-ce2):.2e}   top-1: {top1} vs {top2}")
    print("  Identical cost, opposite decisions at every position.")
    print()

    print("=" * 78)
    print("7b. BOUNDED LOG-RATIO DOES CONTROL THE COST GAP")
    print("=" * 78)
    rng = random.Random(11)
    kappa: float = 0.3
    worst: float = 0.0
    for _ in range(5000):
        raw = [rng.random() + 1e-3 for _ in range(4)]
        s = sum(raw)
        q1 = [r / s for r in raw]
        q2 = [qi * math.exp(rng.uniform(-kappa, kappa)) for qi in q1]
        pr = [rng.random() for _ in range(4)]
        sp = sum(pr)
        pv = [x / sp for x in pr]
        worst = max(worst, abs(cross_entropy(pv, q1) - cross_entropy(pv, q2)))
    print(f"  kappa = {kappa}:  worst observed |CE gap| = {worst:.6f}   (theorem: <= {kappa})")
    print()


def demo_cost_localization(n_windows: int = 12, cap: float = 2.0) -> None:
    print("=" * 78)
    print("7c. REVERSE MARKOV: A MACROSCOPIC COST IS A LOCALISED COST")
    print("=" * 78)
    delta: float = TAIL_DELTA_CE
    bound: float = delta / (2.0 * cap)
    print(f"  measured mean excess Delta = {delta} nats, per-window cap C = {cap} nats")
    print(f"  theorem: fraction of windows with excess >= Delta/2 = {delta/2:.4f} "
          f"is at least Delta/(2C) = {bound:.4f}")
    print(f"  with {n_windows} windows that is at least "
          f"{math.ceil(bound * n_windows)} window(s)")
    print()
    print("  Numerical check on adversarial profiles that try to spread the damage:")
    rng = random.Random(3)
    worst_frac: float = 1.0
    for _ in range(5000):
        # random profile with mean >= delta and cap C
        vals: List[float] = [rng.uniform(0.0, cap) for _ in range(n_windows)]
        if sum(vals) / n_windows < delta:
            continue
        frac = sum(1 for v in vals if v >= delta / 2) / n_windows
        worst_frac = min(worst_frac, frac)
    print(f"  minimum heavy-window fraction observed = {worst_frac:.4f}  "
          f"(never below {bound:.4f})")
    print()


# ----------------------------------------------------------------------------
# 8. Multi-fine-tune serving
# ----------------------------------------------------------------------------


def capacity_curve(k: int, beta: float) -> float:
    """M*(k, beta) = (1 + sqrt(1 + 4 k (k-1) beta)) / (2k):
    the positive root of k x^2 - x - (k-1) beta."""
    return (1.0 + math.sqrt(1.0 + 4.0 * k * (k - 1) * beta)) / (2.0 * k)


def pairwise_ceiling(beta: float) -> float:
    """(1 + beta)/2: the triangle-inequality ceiling, independent of k."""
    return (1.0 + beta) / 2.0


def demo_capacity() -> None:
    print("=" * 78)
    print("8. SHARED SERVING: CEILING, CAPACITY CURVE, PHASE TRANSITION")
    print("=" * 78)
    beta = BETA
    ceil_val = pairwise_ceiling(beta)
    threshold = 2.0 / (1.0 - beta)
    print(f"  beta = {beta}")
    print(f"  pairwise ceiling (1+beta)/2      = {ceil_val:.6f}")
    print(f"  threshold k* = 2/(1-beta)        = {threshold:.4f}")
    print(f"  => at most {math.floor(threshold)} fine-tunes can be served at the ceiling")
    print(f"  geometric-mean limit sqrt(beta)  = {math.sqrt(beta):.6f}")
    print()
    print("     k    M*(k,beta)    (1+beta)/2     binding bound    k(1-beta)")
    print("  " + "-" * 66)
    for k in (2, 5, 8, 11, 12, 13, 20, 50, 100, 1000, 10000):
        mstar = capacity_curve(k, beta)
        binding = "capacity curve" if mstar < ceil_val else "pairwise ceiling"
        print(f"  {k:6d}   {mstar:.6f}     {ceil_val:.6f}     {binding:<16s} "
              f"{k*(1-beta):.4f}")
    print()
    print("  Crossing check: the two bounds agree exactly at k(1-beta) = 2.")
    for k in (4, 7, 12, 40):
        b_star = 1.0 - 2.0 / k  # threshold budget for this k
        print(f"    k = {k:3d}, beta* = 1 - 2/k = {b_star:.6f}:  "
              f"M*(k,beta*) = {capacity_curve(k, b_star):.6f}, "
              f"(1+beta*)/2 = {pairwise_ceiling(b_star):.6f}")
    print()
    print("  Sandwich sqrt(beta) <= M*(k) <= sqrt(beta) + 1/k:")
    for k in (2, 10, 100, 10000):
        m = capacity_curve(k, beta)
        print(f"    k = {k:6d}:  {math.sqrt(beta):.6f} <= {m:.6f} <= "
              f"{math.sqrt(beta) + 1.0/k:.6f}   -> {math.sqrt(beta) <= m <= math.sqrt(beta)+1.0/k}")
    print()


# ----------------------------------------------------------------------------
# 9. Extremal families: hub and complete c-designs
# ----------------------------------------------------------------------------


def hub_family(k: int) -> Tuple[List[List[int]], List[int]]:
    """k fine-tunes on k positions: A_i is the indicator of {i}; H is constant 0.
    Pairwise agreement exactly 1 - 2/k; agr(H, A_i) = 1 - 1/k = ceiling."""
    models: List[List[int]] = [[1 if x == i else 0 for x in range(k)] for i in range(k)]
    hub: List[int] = [0] * k
    return models, hub


def complete_design_family(k: int, c: int) -> Tuple[List[List[int]], List[int]]:
    """Complete c-design: positions are the c-subsets of {0,...,k-1}.
    Fine-tune i predicts the neutral token 0 on blocks containing i, and its own
    private token i+1 elsewhere. The shared model is constant 0."""
    blocks: List[Tuple[int, ...]] = list(combinations(range(k), c))
    models: List[List[int]] = [
        [0 if i in S else i + 1 for S in blocks] for i in range(k)
    ]
    hub: List[int] = [0] * len(blocks)
    return models, hub


def mean_agree(hub: Predictor, models: Sequence[Predictor]) -> float:
    return sum(agree_frac(hub, m) for m in models) / len(models)


def max_pairwise(models: Sequence[Predictor]) -> float:
    k = len(models)
    return max(agree_frac(models[i], models[j]) for i in range(k) for j in range(k) if i != j)


def demo_extremal_families() -> None:
    print("=" * 78)
    print("9. EXTREMAL FAMILIES: HUBS, COMPLETE DESIGNS, AND QUANTISATION")
    print("=" * 78)
    print("  (a) The hub family attains the pairwise ceiling exactly at k(1-beta) = 2:")
    print("       k      beta = agr(A_i,A_j)    M = mean agr(H,A_i)   (1+beta)/2   k(1-beta)")
    print("  " + "-" * 76)
    for k in (2, 3, 5, 8, 12):
        models, hub = hub_family(k)
        b = max_pairwise(models)
        m = mean_agree(hub, models)
        print(f"    {k:4d}     {b:.6f}              {m:.6f}         "
              f"{pairwise_ceiling(b):.6f}    {k*(1-b):.4f}")
    print()
    print("  (b) Complete c-designs realise every quantised pair "
          "(beta, M) = (c(c-1)/(k(k-1)), c/k):")
    print("      k   c    N=C(k,c)   agr(A_i,A_j)   c(c-1)/(k(k-1))   M       c/k     "
          "saturates?")
    print("  " + "-" * 84)
    for k in (4, 5, 6):
        for c in range(2, k + 1):
            models, hub = complete_design_family(k, c)
            b = max_pairwise(models)
            m = mean_agree(hub, models)
            b_pred = c * (c - 1) / (k * (k - 1))
            m_pred = c / k
            s = sum(agree_frac(hub, mm) for mm in models)
            sat = abs(s * s - (s + k * (k - 1) * b)) < 1e-9
            print(f"    {k:2d}  {c:2d}   {len(models[0]):7d}    {b:.6f}       {b_pred:.6f}"
                  f"      {m:.4f}  {m_pred:.4f}   {sat}")
    print()
    print("  (c) The design sits exactly on the capacity curve at its own budget:")
    for (k, c) in ((6, 3), (6, 4), (8, 5)):
        b_pred = c * (c - 1) / (k * (k - 1))
        print(f"    k={k}, c={c}: beta = {b_pred:.6f},  M*(k,beta) = "
              f"{capacity_curve(k, b_pred):.6f},  c/k = {c/k:.6f}")
    print()
    print("  (d) Quantisation excludes the measured budget at k = 12:")
    k = 12
    target = BETA
    solutions = [c for c in range(2, k + 1)
                 if abs(c * (c - 1) / (k * (k - 1)) - target) < 1e-12]
    print(f"    integers c <= {k} with c(c-1)/({k}*{k-1}) = {target}: {solutions}")
    print(f"    required c(c-1) = {target * k * (k-1):.4f}, which is not a product of "
          "consecutive integers")
    print("    => no family of twelve fine-tunes saturates at the measured budget.")
    print()


# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------


def main() -> None:
    print()
    print("#" * 78)
    print("#  AGREEMENT GEOMETRY OF LAYER TRANSPLANTS AND SHARED-SERVING CAPACITY")
    print("#" * 78)
    print()
    demo_collapse_certificate()
    demo_triangle_inequality()
    demo_sharing_gap()
    demo_balanced_sharing()
    demo_lipschitz()
    demo_cost_dissociation()
    demo_cost_localization()
    demo_capacity()
    demo_extremal_families()
    print("All demonstrations complete.")
    print()


if __name__ == "__main__":
    main()
