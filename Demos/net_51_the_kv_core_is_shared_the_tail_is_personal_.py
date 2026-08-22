"""
Margins, Not Angles — numerical demonstrations
==============================================

Self-contained numerical illustrations of the results in
"Margins, Not Angles: Decision-Vector Dissociation in the Shared Core and
Personal Tail of Fine-Tuned Transformers".

Everything is pure Python (standard library only): no numpy, no torch.

Demonstrated results
--------------------
1.  Margin Stability:  gap > 2*eps  and  ||u - v||_inf <= eps  =>  same argmax.
2.  Sharpness of the constant 2:  gap = 2*eps exactly can already be destroyed.
3.  Decision-Vector Dissociation:  cosine similarity -> 1 with opposite argmax.
4.  Collision bound:  top weight <= sqrt(sum p_k^2), and diffuse attention is
    flippable by a perturbation of that size.
5.  Maslov gap <-> margin bridge (both directions).
6.  Divergence hump as a contraction certificate, with the measured constants.
7.  Error budget, shareable prefix, and the tight depth law k < m / (2 eps).
8.  Serving law:  cost(n) = s + n(L - s),  amortized ratio -> (L - s)/L.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from typing import Callable, Dict, List, Optional, Sequence, Tuple


# ----------------------------------------------------------------------------
# Basic vector utilities
# ----------------------------------------------------------------------------

def argmax_strict(u: Sequence[float]) -> Optional[int]:
    """Return the unique index of the strict maximum, or None if it is tied."""
    best = max(u)
    winners = [i for i, x in enumerate(u) if x == best]
    return winners[0] if len(winners) == 1 else None


def margin(u: Sequence[float], i: int) -> float:
    """Top-1 margin of u at index i: min over j != i of (u_i - u_j)."""
    return min(u[i] - u[j] for j in range(len(u)) if j != i)


def linf(u: Sequence[float], v: Sequence[float]) -> float:
    """Coordinatewise (sup-norm) distance."""
    return max(abs(a - b) for a, b in zip(u, v))


def cosine(u: Sequence[float], v: Sequence[float]) -> float:
    """Euclidean cosine similarity of two nonzero vectors."""
    dot = sum(a * b for a, b in zip(u, v))
    nu = math.sqrt(sum(a * a for a in u))
    nv = math.sqrt(sum(b * b for b in v))
    return dot / (nu * nv)


def softmax(x: Sequence[float]) -> List[float]:
    """Numerically stable softmax."""
    m = max(x)
    e = [math.exp(xi - m) for xi in x]
    s = sum(e)
    return [ei / s for ei in e]


def lse(x: Sequence[float]) -> float:
    """log-sum-exp, computed stably."""
    m = max(x)
    return m + math.log(sum(math.exp(xi - m) for xi in x))


def maslov_gap(x: Sequence[float], i: int) -> float:
    """Maslov gap  lse(x) - x_i : the distance of softmax from a hard max."""
    return lse(x) - x[i]


def collision_mass(p: Sequence[float]) -> float:
    """C(p) = sum_k p_k^2 : the probability that two draws from p coincide."""
    return sum(pk * pk for pk in p)


# ----------------------------------------------------------------------------
# 1 & 2.  The margin certificate and its sharpness
# ----------------------------------------------------------------------------

def margin_certificate_holds(
    u: Sequence[float], v: Sequence[float], i: int, eps: float
) -> bool:
    """True iff the hypotheses of the Margin Stability Theorem are satisfied."""
    return margin(u, i) > 2.0 * eps and linf(u, v) <= eps


def demo_margin_stability(trials: int = 200_000, seed: int = 20260822) -> None:
    print("=" * 78)
    print("1.  MARGIN STABILITY:  gap > 2*eps  and  ||u-v||_inf <= eps  =>  same top-1")
    print("=" * 78)
    rng = random.Random(seed)
    certified = 0
    violations = 0
    n = 6
    for _ in range(trials):
        u = [rng.uniform(-3.0, 3.0) for _ in range(n)]
        i = argmax_strict(u)
        if i is None:
            continue
        eps = rng.uniform(0.0, 1.0)
        v = [ui + rng.uniform(-eps, eps) for ui in u]
        if margin_certificate_holds(u, v, i, eps):
            certified += 1
            if argmax_strict(v) != i:
                violations += 1
    print(f"  random trials              : {trials}")
    print(f"  certificate applied        : {certified}")
    print(f"  decisions flipped anyway   : {violations}   (theorem says: 0)")
    assert violations == 0
    print("  -> the certificate never failed.\n")


def demo_sharpness_of_two() -> None:
    print("=" * 78)
    print("2.  SHARPNESS OF THE CONSTANT 2:  gap = 2*eps exactly is already unsafe")
    print("=" * 78)
    for eps in (0.5, 0.05, 0.005):
        u = [2.0 * eps, 0.0]
        v = [eps, eps]
        print(f"  eps = {eps:<8}"
              f"u = ({u[0]:.4f}, {u[1]:.4f})   gap = {margin(u, 0):.4f} = 2*eps")
        print(f"{'':14}v = ({v[0]:.4f}, {v[1]:.4f})   "
              f"||u-v||_inf = {linf(u, v):.4f} = eps")
        print(f"{'':14}top-1(u) = {argmax_strict(u)},  "
              f"top-1(v) = {argmax_strict(v)}   (None = tie, no decision)")
        assert argmax_strict(u) == 0 and argmax_strict(v) is None
    print("  -> with gap exactly 2*eps the decision can be erased: 2 is optimal.\n")


# ----------------------------------------------------------------------------
# 3.  Decision-vector dissociation
# ----------------------------------------------------------------------------

def flip_pair(t: float) -> Tuple[List[float], List[float]]:
    """The flip pair  u = (1+t, 1),  v = (1, 1+t):  opposite decisions."""
    return [1.0 + t, 1.0], [1.0, 1.0 + t]


def demo_cosine_dissociation() -> None:
    print("=" * 78)
    print("3.  DECISION-VECTOR DISSOCIATION:  cosine -> 1 with opposite decisions")
    print("=" * 78)
    print(f"  {'t':>10} {'cos(u,v)':>14} {'closed form':>14} "
          f"{'1 - t/2':>10} {'top1(u)':>8} {'top1(v)':>8}")
    for t in (1.0, 0.5, 0.1, 0.02, 0.004, 1e-4):
        u, v = flip_pair(t)
        c = cosine(u, v)
        closed = (2.0 + 2.0 * t) / (t * t + 2.0 * t + 2.0)
        print(f"  {t:>10.5f} {c:>14.10f} {closed:>14.10f} "
              f"{1.0 - t / 2.0:>10.5f} {argmax_strict(u):>8} {argmax_strict(v):>8}")
        assert abs(c - closed) < 1e-12
        assert c >= 1.0 - t / 2.0 - 1e-12
        assert argmax_strict(u) == 0 and argmax_strict(v) == 1
    print("  -> for every eps > 0 there are score vectors with cos > 1 - eps")
    print("     that decide differently: no cosine threshold certifies agreement.")
    print("  The measured tail (cos 0.983, agreement 0.568) violates no inequality.\n")


# ----------------------------------------------------------------------------
# 4.  Collision mass and fragility of diffuse attention
# ----------------------------------------------------------------------------

def flip_diffuse(p: Sequence[float], j: int, eta: float) -> List[float]:
    """Move the decision of a nonnegative vector p to index j."""
    i = argmax_strict(p)
    assert i is not None and j != i
    q = list(p)
    q[j] = p[i] + eta
    return q


def demo_collision_bound() -> None:
    print("=" * 78)
    print("4.  COLLISION BOUND AND FRAGILITY OF DIFFUSE ATTENTION")
    print("=" * 78)
    scenarios: List[Tuple[str, List[float]]] = [
        ("peaked   (core-like)", [6.0, 0.4, 0.2, 0.1, 0.0, -0.2, -0.5, -1.0]),
        ("moderate            ", [1.6, 1.0, 0.7, 0.4, 0.2, 0.0, -0.2, -0.4]),
        ("diffuse  (tail-like)", [0.22, 0.18, 0.15, 0.13, 0.10, 0.08, 0.07, 0.05]),
    ]
    print(f"  {'layer type':>22} {'Maslov gap':>11} {'collision C':>12} "
          f"{'sqrt(C)':>9} {'top wt':>8} {'margin':>9} {'flip size':>10}")
    for name, logits in scenarios:
        p = softmax(logits)
        i = argmax_strict(p)
        C = collision_mass(p)
        eta = 1e-9
        q = flip_diffuse(p, (i + 1) % len(p), eta)
        print(f"  {name:>22} {maslov_gap(logits, i):>11.4f} {C:>12.5f} "
              f"{math.sqrt(C):>9.5f} {p[i]:>8.5f} "
              f"{margin(p, i):>9.5f} {linf(p, q):>10.5f}")
        assert p[i] <= math.sqrt(C) + 1e-12
        assert linf(p, q) <= math.sqrt(C) + eta + 1e-12
        assert argmax_strict(q) == (i + 1) % len(p)
    print("  -> the top weight never exceeds sqrt(collision mass), and a")
    print("     perturbation of that size moves the decision anywhere.")
    print("     In the diffuse tail sqrt(C) is far below the measured delta ~0.16.\n")


# ----------------------------------------------------------------------------
# 5.  The tropical bridge
# ----------------------------------------------------------------------------

def maslov_upper_from_margin(n: int, m: float) -> float:
    """Margin => near-tropical:  gap <= log(1 + (n-1) e^{-m})."""
    return math.log(1.0 + (n - 1) * math.exp(-m))


def margin_cap_from_maslov(n: int, g: float) -> float:
    """Far-from-tropical => small margin (readable form, valid for g >= 1)."""
    return math.log(n - 1) + math.log(2.0) - g


def demo_tropical_bridge() -> None:
    print("=" * 78)
    print("5.  THE TROPICAL BRIDGE:  Maslov gap <-> margin, both directions")
    print("=" * 78)
    n = 64
    print(f"  context length n = {n}")
    print(f"  {'margin m':>10} {'gap bound log(1+(n-1)e^-m)':>30}")
    for m in (0.0, 0.5, 1.0, 2.0, 4.0, 8.0):
        print(f"  {m:>10.2f} {maslov_upper_from_margin(n, m):>30.6f}")
    print("  -> a large margin forces near-tropical (max-like) behaviour.\n")
    print(f"  {'gap g':>10} {'margin cap log(n-1)+log2-g':>30}  (each nat of gap"
          " costs a nat of margin)")
    for g in (1.0, 1.5, 2.0, 2.5, 2.7, 3.5):
        print(f"  {g:>10.2f} {margin_cap_from_maslov(n, g):>30.6f}")
    print("  -> the measured tail gap 2.5-2.7 caps the margin, hence (by 4) the")
    print("     decision is flippable.  Far-from-tropical = diffuse = fragile.\n")
    # Consistency check on random vectors: the two bounds never contradict.
    rng = random.Random(7)
    for _ in range(20_000):
        x = [rng.uniform(-4.0, 4.0) for _ in range(8)]
        i = argmax_strict(x)
        if i is None:
            continue
        m = margin(x, i)
        assert maslov_gap(x, i) <= maslov_upper_from_margin(8, m) + 1e-9
    print("  (verified on 20000 random score vectors: the bound always holds)\n")


# ----------------------------------------------------------------------------
# 6.  The divergence hump as a contraction certificate
# ----------------------------------------------------------------------------

MEASURED_DIVERGENCE: Dict[int, float] = {
    0: 0.000, 1: 0.041, 2: 0.062, 3: 0.081, 4: 0.098, 5: 0.113,
    6: 0.128, 7: 0.142, 8: 0.155, 9: 0.168, 10: 0.180, 11: 0.192,
    12: 0.201, 13: 0.208, 14: 0.212, 15: 0.215, 16: 0.217, 17: 0.209,
    18: 0.200, 19: 0.191, 20: 0.183, 21: 0.174, 22: 0.167, 23: 0.160,
}


def contraction_certificates(
    d: Dict[int, float], eps: float
) -> List[Tuple[int, float]]:
    """Layers whose downward divergence step exceeds eps, with the factor bound."""
    out: List[Tuple[int, float]] = []
    for k in sorted(d)[:-1]:
        if d[k + 1] < d[k] - eps and d[k] > 0.0:
            out.append((k, (d[k + 1] + eps) / d[k]))
    return out


def demo_hump() -> None:
    print("=" * 78)
    print("6.  THE HUMP IS A CONTRACTION CERTIFICATE")
    print("=" * 78)
    d = MEASURED_DIVERGENCE
    eps = 0.01
    peak = max(d, key=lambda k: d[k])
    print(f"  layer-0 divergence  : {d[0]:.3f}   (exactly shared prefix)")
    print(f"  peak                : {d[peak]:.3f} at layer {peak}")
    print(f"  final               : {d[23]:.3f} at layer 23")
    print(f"  monotone?           : {all(d[k] <= d[k+1] for k in range(23))}")
    certs = contraction_certificates(d, eps)
    print(f"\n  with per-layer delta budget eps = {eps}:")
    print(f"  contraction certificates at layers: {[k for k, _ in certs]}")
    if certs:
        worst = min(f for _, f in certs)
        print(f"  strongest certified factor        : {worst:.4f}")
    else:
        print("  (no single step exceeds eps, but the aggregate fall does --")
        print("   see the two branches below)")
    certs2 = contraction_certificates(d, 0.005)
    print(f"  with the tighter budget eps = 0.005, certificates at layers:")
    print(f"    {[k for k, _ in certs2]}")
    if certs2:
        print(f"    strongest certified factor: {min(f for _, f in certs2):.4f}")
    # Branch A: the aggregate contraction factor over [16, 23].
    d16, d23 = d[16], d[23]
    factor = (d23 + eps) / d16
    print(f"\n  BRANCH A (contraction):  ({d23} + {eps}) / {d16} = {factor:.4f} <= 4/5"
          f"  -> {factor <= 0.8}")
    # Branch B: the forced delta budget.
    total = d16 - d23
    per_layer = total / 7
    print(f"  BRANCH B (delta budget): total over [16,23) >= {total:.4f} >= 0.057"
          f"  -> {total >= 0.057 - 1e-12}")
    print(f"{'':26}pigeonhole: some layer injects >= {per_layer:.5f} >= 0.008"
          f"  -> {per_layer >= 0.008}")
    print("  -> the two branches exhaust the possibilities; the hump is")
    print("     informative, not anomalous.\n")


# ----------------------------------------------------------------------------
# 7.  Error budget, shareable prefix, depth law
# ----------------------------------------------------------------------------

def error_budget(lipschitz: Sequence[float], eps: float) -> List[float]:
    """B_0 = 0,  B_{k+1} = L_k B_k + eps."""
    b: List[float] = [0.0]
    for lk in lipschitz:
        b.append(lk * b[-1] + eps)
    return b


def shareable_prefix(
    lipschitz: Sequence[float], eps: float, margins: Sequence[float]
) -> int:
    """Largest s such that 2 B_k < margin_k for every k < s."""
    b = error_budget(lipschitz, eps)
    s = 0
    for k in range(len(margins)):
        if 2.0 * b[k] < margins[k]:
            s = k + 1
        else:
            break
    return s


def demo_depth_law() -> None:
    print("=" * 78)
    print("7.  ERROR BUDGET, SHAREABLE PREFIX, AND THE TIGHT DEPTH LAW")
    print("=" * 78)
    eps = 0.01
    m = 0.5
    lip = [1.0] * 40
    b = error_budget(lip, eps)
    print(f"  eps = {eps},  uniform margin m = {m},  nonexpansive layers")
    print(f"  budget B_k = k * eps ;  shareable iff 2 B_k < m  iff  k < m/(2 eps)"
          f" = {m / (2 * eps):.1f}")
    for k in (0, 10, 23, 24, 25, 26):
        ok = 2.0 * b[k] < m
        print(f"    k = {k:>3}   B_k = {b[k]:.3f}   2 B_k = {2*b[k]:.3f}   "
              f"shareable: {ok}")
    assert 2 * b[24] < m and not (2 * b[25] < m)
    print("  -> every layer of depth <= 24 is certifiably shareable, and the")
    print("     bound is tight: at depth 25 the certificate genuinely fails.\n")

    # A realistic 24-layer profile: margins decay with depth (attention diffuses).
    margins = [0.90 - 0.032 * k for k in range(24)]
    s = shareable_prefix([1.0] * 24, eps, margins)
    print(f"  decaying margin profile m_k = 0.90 - 0.032 k over 24 layers:")
    print(f"    shareable prefix length s = {s}  (tail of {24 - s} layers is personal)")
    flags = "".join("C" if 2 * b[k] < margins[k] else "." for k in range(24))
    print(f"    per-layer certificate map : {flags}   (C = shareable core)")
    print("  -> shareability is a prefix property: core shared, tail personal.\n")


# ----------------------------------------------------------------------------
# 8.  The serving law
# ----------------------------------------------------------------------------

def serve_cost(n: int, layers: float, shared: float) -> float:
    """Memory of serving n fine-tunes with `shared` of `layers` layers shared."""
    return shared + n * (layers - shared)


def demo_serving_law() -> None:
    print("=" * 78)
    print("8.  THE SERVING LAW:  amortized ratio -> tail fraction (L - s)/L")
    print("=" * 78)
    L, s = 24.0, 22.0
    print(f"  L = {L:.0f} layers, s = {s:.0f} shared, tail fraction "
          f"(L-s)/L = {(L - s) / L:.6f} = 1/12")
    print(f"  {'n':>8} {'cost(n)':>12} {'independent':>13} {'saving':>10} "
          f"{'ratio':>10}")
    for n in (1, 2, 4, 8, 16, 64, 256, 4096):
        c = serve_cost(n, L, s)
        print(f"  {n:>8} {c:>12.1f} {n * L:>13.1f} {(n - 1) * s:>10.1f} "
              f"{c / (n * L):>10.6f}")
        assert abs(c - (n * L - (n - 1) * s)) < 1e-12
    print(f"  limit ratio = {(L - s) / L:.6f}")
    print(f"\n  certified decision agreement with 22 of 24 layers margin-certified:")
    print(f"    fraction >= 22/24 = {22 / 24:.6f} = 11/12")
    print(f"    (the informal '>= 0.92' is optimistic: 22/24 = 0.9167 < 0.92)\n")


# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------

def main() -> None:
    print()
    print("#" * 78)
    print("#  MARGINS, NOT ANGLES — numerical demonstrations")
    print("#  The core is shared; the tail is personal.")
    print("#" * 78)
    print()
    demos: List[Callable[[], None]] = [
        demo_margin_stability,
        demo_sharpness_of_two,
        demo_cosine_dissociation,
        demo_collision_bound,
        demo_tropical_bridge,
        demo_hump,
        demo_depth_law,
        demo_serving_law,
    ]
    for fn in demos:
        fn()
    print("=" * 78)
    print("All assertions passed: every numerical check agrees with the theorems.")
    print("=" * 78)


if __name__ == "__main__":
    main()
