#!/usr/bin/env python3
"""
Censored steepness and uniform kernel detection
===============================================

Numerical demonstration of the identifiability dichotomy for the
"flat bulk + left-edge spike" profile on [0, 1]:

    f(x) = (1 - rho) * 1  +  rho * b * exp(-b x) / (1 - exp(-b)),   x in [0,1]

observed only through binned counts.

WHAT IS DEMONSTRATED
--------------------
A. The steepness b is CENSORED.
   A1. Edge mass F(b,t) is strictly increasing in b but bounded, and
       1 - F(b,t) <= 2 exp(-b t)   for b >= 1, t <= 1.
   A2. If the empirical edge fraction h is at least the ceiling
       P_inf = (1-rho) t + rho, the two-cell log-likelihood is strictly
       increasing in b: every box-constrained optimum sits ON the cap.
   A3. All log-likelihood available above a cap B is at most
       C exp(-B t) with C = 2 rho / min((1-rho) t, 1 - P_inf).
   A4. The identified set at tolerance eps contains a ray [B0, infinity).
   A5. Lower bounds nevertheless survive, and at the population level the
       map b -> edge mass is injective (tolerance identifiability).

B. The EXISTENCE of the spike is identified, uniformly in b.
   B1. The log-convexity defect D(x,y,z) = x z - y^2 vanishes identically on
       the whole single-truncated-exponential family, for every bin count k.
   B2. On the mixture it equals rho(1-rho)/k * q_j (1-r)^2 > 0, and is at
       least rho(1-rho)/(8k) once r = exp(-b/k) <= 1/2.
   B3. D is 4-Lipschitz in sup-norm, hence the mixture is at sup-distance at
       least rho(1-rho)/(32 k) from EVERY single law.
   B4. The "steepness valley": all bin vectors with b >= B lie within
       4 rho exp(-B/3) of one another.

C. An EXACT second non-identifiability: the component role swap.

D. A synthetic end-to-end fit reproducing the empirically observed
   cap-riding, plus a control with no spike.

Pure standard library; no third-party dependencies.
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Section 0 -- core model quantities
# ----------------------------------------------------------------------------


def trunc_exp_cdf(b: float, t: float) -> float:
    """Mass in [0, t] of an exponential of rate b conditioned to [0, 1].

    F(b, t) = (1 - exp(-b t)) / (1 - exp(-b)).
    """
    if b <= 0.0:
        raise ValueError("steepness b must be positive")
    return (1.0 - math.exp(-b * t)) / (1.0 - math.exp(-b))


def edge_prob(rho: float, t: float, b: float) -> float:
    """Edge-bin probability of the flat-bulk-plus-spike profile."""
    return (1.0 - rho) * t + rho * trunc_exp_cdf(b, t)


def edge_prob_limit(rho: float, t: float) -> float:
    """Ceiling P_inf = (1-rho) t + rho, the b -> infinity limit of edge_prob."""
    return (1.0 - rho) * t + rho


def bin_log_lik(h: float, p: float) -> float:
    """Two-cell (edge vs. rest) per-observation log-likelihood."""
    return h * math.log(p) + (1.0 - h) * math.log(1.0 - p)


# ----------------------------------------------------------------------------
# Section A1 -- saturation and the censoring bound
# ----------------------------------------------------------------------------


def demo_saturation(rho: float = 0.48, t: float = 0.036) -> None:
    print("=" * 78)
    print("A1.  SATURATION OF THE EDGE MASS AND THE CENSORING BOUND")
    print("=" * 78)
    print(f"     rho = {rho},  edge bin width t = {t}")
    print(f"     ceiling P_inf = (1-rho)t + rho = {edge_prob_limit(rho, t):.8f}\n")
    print(f"{'b':>8} {'F(b,t)':>12} {'1-F(b,t)':>12} {'2 exp(-bt)':>12} "
          f"{'p(b)':>12} {'P_inf - p(b)':>14}")
    print("-" * 78)
    p_inf = edge_prob_limit(rho, t)
    prev_f = -1.0
    for b in (1.0, 2.0, 5.0, 10.0, 15.0, 20.0, 40.0, 80.0, 160.0, 400.0):
        f = trunc_exp_cdf(b, t)
        bound = 2.0 * math.exp(-b * t)
        p = edge_prob(rho, t, b)
        assert f > prev_f, "strict monotonicity must hold"
        assert 1.0 - f <= bound + 1e-12, "censoring bound must hold"
        prev_f = f
        print(f"{b:8.1f} {f:12.8f} {1.0 - f:12.8f} {bound:12.8f} "
              f"{p:12.8f} {p_inf - p:14.3e}")
    print("\n     Monotone, bounded, and the gap to the ceiling is dominated")
    print("     by 2 exp(-b t) at every row: the parameter saturates.\n")


# ----------------------------------------------------------------------------
# Section A2 -- forced cap-riding
# ----------------------------------------------------------------------------


def constrained_argmax_b(h: float, rho: float, t: float, cap: float,
                         grid: int = 4000) -> Tuple[float, float]:
    """Grid-maximise b -> bin_log_lik(h, edge_prob(rho, t, b)) on (0, cap]."""
    best_b, best_v = 0.0, -math.inf
    for i in range(1, grid + 1):
        b = cap * i / grid
        v = bin_log_lik(h, edge_prob(rho, t, b))
        if v > best_v:
            best_b, best_v = b, v
    return best_b, best_v


def demo_cap_riding(rho: float = 0.48, t: float = 0.036) -> None:
    print("=" * 78)
    print("A2.  FORCED CAP-RIDING  (h >= ceiling  =>  optimum sits ON the cap)")
    print("=" * 78)
    p_inf = edge_prob_limit(rho, t)
    h = min(p_inf + 0.01, 0.999)   # empirical edge fraction at/above ceiling
    print(f"     rho = {rho}, t = {t}, ceiling = {p_inf:.6f}, "
          f"observed edge fraction h = {h:.6f}\n")
    print(f"{'cap B':>10} {'argmax b':>12} {'on cap?':>10} "
          f"{'loglik at opt':>16} {'gain vs prev cap':>18}")
    print("-" * 78)
    prev = None
    for cap in (10.0, 20.0, 40.0, 80.0, 160.0, 320.0):
        b_hat, v = constrained_argmax_b(h, rho, t, cap)
        on_cap = abs(b_hat - cap) < cap / 4000.0 + 1e-12
        gain = "-" if prev is None else f"{v - prev:.6e}"
        print(f"{cap:10.1f} {b_hat:12.4f} {str(on_cap):>10} {v:16.9f} {gain:>18}")
        assert on_cap, "cap-riding is forced when h >= ceiling"
        prev = v
    print("\n     The estimate IS the cap, at every cap, and the improvement")
    print("     from doubling the cap collapses geometrically.\n")


# ----------------------------------------------------------------------------
# Section A3 -- the exponential cap-gain bound
# ----------------------------------------------------------------------------


def cap_gain_bound(rho: float, t: float, b: float) -> float:
    """C exp(-b t) with C = 2 rho / min((1-rho) t, 1 - P_inf)."""
    p_inf = edge_prob_limit(rho, t)
    m = min((1.0 - rho) * t, 1.0 - p_inf)
    return (2.0 * rho / m) * math.exp(-b * t)


def demo_cap_gain(rho: float = 0.48, t: float = 0.036) -> None:
    print("=" * 78)
    print("A3.  EXPONENTIALLY SMALL CAP GAINS")
    print("=" * 78)
    p_inf = edge_prob_limit(rho, t)
    h = min(p_inf + 0.01, 0.999)
    print(f"     bound:  loglik(h, P_inf) - loglik(h, p(b))  <=  C exp(-b t)\n")
    print(f"{'b':>8} {'actual deficit':>18} {'bound C exp(-bt)':>20} {'ratio':>10}")
    print("-" * 78)
    ceiling_ll = bin_log_lik(h, p_inf)
    for b in (1.0, 5.0, 10.0, 20.0, 40.0, 80.0, 160.0):
        actual = ceiling_ll - bin_log_lik(h, edge_prob(rho, t, b))
        bound = cap_gain_bound(rho, t, b)
        assert actual <= bound + 1e-12, "cap-gain bound must hold"
        print(f"{b:8.1f} {actual:18.10f} {bound:20.10f} {actual / bound:10.5f}")
    print("\n     The bound holds at every b, and both sides decay like exp(-b t).\n")


# ----------------------------------------------------------------------------
# Section A4/A5 -- the identified ray, surviving lower bounds, injectivity
# ----------------------------------------------------------------------------


def ray_threshold(rho: float, t: float, eps: float) -> float:
    """Smallest B0 >= 1 with 2 rho exp(-B0 t) <= eps."""
    if 2.0 * rho <= eps:
        return 1.0
    return max(1.0, math.log(2.0 * rho / eps) / t)


def demo_identified_ray(rho: float = 0.48, t: float = 0.036,
                        eps: float = 5e-3) -> None:
    print("=" * 78)
    print("A4/A5.  THE IDENTIFIED SET IS A RAY; LOWER BOUNDS SURVIVE")
    print("=" * 78)
    p_inf = edge_prob_limit(rho, t)
    v = p_inf - 0.4 * eps            # observation within eps of the ceiling
    b0 = ray_threshold(rho, t, eps)
    print(f"     rho = {rho}, t = {t}, tolerance eps = {eps}")
    print(f"     ceiling  = {p_inf:.8f}")
    print(f"     observed = {v:.8f}   (within eps of the ceiling)")
    print(f"     ray threshold B0 = {b0:.4f}\n")
    print(f"{'b':>10} {'p(b)':>14} {'|p(b) - v|':>14} {'<= eps?':>10}")
    print("-" * 78)
    for b in (b0, 2 * b0, 5 * b0, 20 * b0, 1000 * b0, 1e6):
        d = abs(edge_prob(rho, t, b) - v)
        ok = d <= eps + 1e-15
        assert ok, "every b above the threshold must be compatible"
        print(f"{b:10.2f} {edge_prob(rho, t, b):14.8f} {d:14.3e} {str(ok):>10}")
    print("\n     Compatible for arbitrarily large b: NO finite upper limit.\n")

    # lower bounds survive
    print("     Lower bounds, by contrast, are perfectly valid:")
    print(f"{'b':>10} {'p(b)':>14} {'|p(b) - v|':>14} {'excluded?':>12}")
    print("-" * 78)
    for b in (0.5, 1.0, 2.0, 5.0, 10.0):
        d = abs(edge_prob(rho, t, b) - v)
        print(f"{b:10.2f} {edge_prob(rho, t, b):14.8f} {d:14.3e} "
              f"{str(d > eps):>12}")

    # population injectivity: exact recovery from an exact observable
    print("\n     Population identification (bisection on an EXACT observable):")
    b_true = 12.345
    v_exact = edge_prob(rho, t, b_true)
    lo, hi = 1e-6, 1e4
    for _ in range(200):
        mid = 0.5 * (lo + hi)
        if edge_prob(rho, t, mid) < v_exact:
            lo = mid
        else:
            hi = mid
    print(f"       true b = {b_true},  recovered b = {0.5 * (lo + hi):.9f}")
    print("       -> the map is injective; the failure is one of TOLERANCE.\n")


# ----------------------------------------------------------------------------
# Section B -- the log-convexity defect
# ----------------------------------------------------------------------------


def defect(x: float, y: float, z: float) -> float:
    """Three-term log-convexity defect D(x, y, z) = x z - y^2."""
    return x * z - y * y


def geom_bin_k(k: int, r: float, j: int) -> float:
    """Bin j of a truncated exponential on k equal cells, r = exp(-b/k)."""
    return r ** j * (1.0 - r) / (1.0 - r ** k)


def mix_bin_k(k: int, rho: float, r: float, j: int) -> float:
    """Bin j of the flat-bulk-plus-spike profile on k equal cells."""
    return (1.0 - rho) / k + rho * geom_bin_k(k, r, j)


def demo_defect(rho: float = 0.48) -> None:
    print("=" * 78)
    print("B1/B2.  THE LOG-CONVEXITY DEFECT: ZERO ON THE NULL, POSITIVE ON THE MIX")
    print("=" * 78)
    print("     Single-law family (k = 3), across every conceivable steepness:\n")
    print(f"{'b':>10} {'r=exp(-b/3)':>14} {'p0':>10} {'p1':>10} {'p2':>10} "
          f"{'defect':>14}")
    print("-" * 78)
    for b in (0.1, 0.5, 1.1596, 5.0, 15.0, 40.0, 80.0):
        r = math.exp(-b / 3.0)
        g = [geom_bin_k(3, r, j) for j in range(3)]
        d = defect(*g)
        assert abs(d) < 1e-14, "the single-law family is a zero set of D"
        print(f"{b:10.4f} {r:14.8f} {g[0]:10.6f} {g[1]:10.6f} {g[2]:10.6f} "
              f"{d:14.3e}")

    print("\n     Mixture (k = 3, rho = %.2f): closed form vs. direct evaluation,"
          % rho)
    print("     together with the cap-uniform floor rho(1-rho)/21:\n")
    floor3 = rho * (1.0 - rho) / 21.0
    print(f"{'b':>10} {'r':>12} {'D direct':>14} {'D closed form':>16} "
          f"{'>= rho(1-rho)/21?':>20}")
    print("-" * 78)
    for b in (2.1, 5.0, 15.0, 40.0, 80.0, 400.0):
        r = math.exp(-b / 3.0)
        m = [mix_bin_k(3, rho, r, j) for j in range(3)]
        d_direct = defect(*m)
        d_closed = rho * (1.0 - rho) / 3.0 * (1.0 - r) ** 2 / (1 + r + r * r)
        assert abs(d_direct - d_closed) < 1e-12, "closed form must match"
        ok = d_direct >= floor3 - 1e-15
        assert ok or r > 0.5, "floor holds once r <= 1/2"
        print(f"{b:10.2f} {r:12.8f} {d_direct:14.8f} {d_closed:16.8f} "
              f"{str(ok):>20}")
    print(f"\n     floor rho(1-rho)/21 = {floor3:.8f}: independent of b.\n")


def sup_distance_to_single_law(k: int, rho: float, r: float,
                               grid: int = 20001) -> Tuple[float, float]:
    """Minimise over r' the sup-norm distance (first 3 bins) mixture vs. single law."""
    m = [mix_bin_k(k, rho, r, j) for j in range(3)]
    best_d, best_rp = math.inf, 0.0
    for i in range(1, grid):
        rp = i / grid
        d = max(abs(m[j] - geom_bin_k(k, rp, j)) for j in range(3))
        if d < best_d:
            best_d, best_rp = d, rp
    return best_d, best_rp


def demo_separation(rho: float = 0.48) -> None:
    print("=" * 78)
    print("B3.  UNIFORM SEPARATION FROM *EVERY* SINGLE LAW")
    print("=" * 78)
    print("     Guarantee (k bins):  sup-distance >= rho(1-rho)/(32 k).")
    print("     For k = 3 the sharper three-bin form gives rho(1-rho)/84.\n")
    guarantee3 = rho * (1.0 - rho) / 84.0
    print(f"{'b (spike)':>12} {'best r*':>12} {'achieved sup-dist':>20} "
          f"{'guarantee':>14} {'ok?':>6}")
    print("-" * 78)
    for b in (2.1, 5.0, 15.0, 40.0, 80.0, 400.0):
        r = math.exp(-b / 3.0)
        d, rp = sup_distance_to_single_law(3, rho, r)
        ok = d >= guarantee3 - 1e-9
        assert ok, "uniform separation must hold"
        print(f"{b:12.2f} {rp:12.6f} {d:20.8f} {guarantee3:14.8f} {str(ok):>6}")

    print("\n     Dependence on the number of bins (spike steepness b = 40):\n")
    print(f"{'k':>6} {'achieved sup-dist':>20} {'rho(1-rho)/(32k)':>20} {'ok?':>6}")
    print("-" * 78)
    for k in (3, 5, 10, 20, 28):
        r = math.exp(-40.0 / k)
        d, _ = sup_distance_to_single_law(k, rho, r)
        g = rho * (1.0 - rho) / (32.0 * k)
        ok = d >= g - 1e-9
        assert ok, "k-bin separation must hold"
        print(f"{k:6d} {d:20.8f} {g:20.8f} {str(ok):>6}")
    print("\n     Detectability degrades only like 1/k -- and not at all in b.\n")


def demo_valley(rho: float = 0.48) -> None:
    print("=" * 78)
    print("B4.  THE STEEPNESS VALLEY")
    print("=" * 78)
    print("     For b, b' >= B, every bin probability differs by <= 4 rho exp(-B/3).\n")
    print(f"{'B':>8} {'max |diff| over b,b' + chr(39):>24} "
          f"{'bound 4 rho exp(-B/3)':>24} {'ok?':>6}")
    print("-" * 78)
    for B in (1.0, 3.0, 6.0, 12.0, 24.0, 48.0):
        worst = 0.0
        for b in (B, 1.5 * B, 4 * B, 100 * B, 1e6):
            for bp in (B, 1.5 * B, 4 * B, 100 * B, 1e6):
                for j in range(3):
                    worst = max(worst, abs(
                        mix_bin_k(3, rho, math.exp(-b / 3.0), j)
                        - mix_bin_k(3, rho, math.exp(-bp / 3.0), j)))
        bound = 4.0 * rho * math.exp(-B / 3.0)
        ok = worst <= bound + 1e-12
        assert ok, "valley bound must hold"
        print(f"{B:8.1f} {worst:24.10f} {bound:24.10f} {str(ok):>6}")
    print("\n     Above a modest threshold, all steepnesses look alike.\n")


# ----------------------------------------------------------------------------
# Section C -- the exact role swap
# ----------------------------------------------------------------------------


def two_comp_bin(rho: float, b1: float, b2: float, j: int) -> float:
    """Bin j of a genuine two-component mixture of truncated exponentials."""
    return (rho * geom_bin_k(3, math.exp(-b1 / 3.0), j)
            + (1.0 - rho) * geom_bin_k(3, math.exp(-b2 / 3.0), j))


def demo_role_swap() -> None:
    print("=" * 78)
    print("C.  THE EXACT ROLE SWAP: INTERIORITY IS NOT IDENTIFICATION")
    print("=" * 78)
    rho, b1, b2 = 0.545, 30.0, 0.8326
    print(f"     point P  = (rho, b1, b2) = ({rho}, {b1}, {b2})")
    print(f"     point P' = (1-rho, b2, b1) = ({1 - rho}, {b2}, {b1})\n")
    print(f"{'bin j':>8} {'T_j(P)':>16} {'T_j(P prime)':>18} {'difference':>14}")
    print("-" * 78)
    for j in range(3):
        a = two_comp_bin(rho, b1, b2, j)
        c = two_comp_bin(1.0 - rho, b2, b1, j)
        assert abs(a - c) < 1e-15, "role swap must be exact"
        print(f"{j:8d} {a:16.12f} {c:18.12f} {a - c:14.3e}")
    print("\n     Every observable is identical, so EVERY criterion computed from")
    print("     the bin probabilities has (at least) two distinct global optima.")
    print("     This is the branch on which a nominally 'interior' steepness of")
    print("     0.83 was reported while the other parameter rode its own bound.\n")


# ----------------------------------------------------------------------------
# Section D -- an end-to-end synthetic experiment (treatment and control)
# ----------------------------------------------------------------------------


def geometric_edges(k: int, first: float) -> List[float]:
    """k+1 bin edges on [0,1], geometrically graded, leftmost bin of width ~first."""
    ratio = (1.0 / first) ** (1.0 / (k - 1))
    raw = [0.0] + [first * ratio ** i for i in range(k)]
    return [min(1.0, e / raw[-1]) for e in raw]


def sample_profile(n: int, rho: float, b: float, rng: random.Random) -> List[float]:
    """Draw n positions from (1-rho) Uniform[0,1] + rho TruncExp(b) on [0,1]."""
    out: List[float] = []
    for _ in range(n):
        if rng.random() < rho:
            u = rng.random()
            out.append(-math.log(1.0 - u * (1.0 - math.exp(-b))) / b)
        else:
            out.append(rng.random())
    return out


def histogram(xs: Sequence[float], edges: Sequence[float]) -> List[int]:
    counts = [0] * (len(edges) - 1)
    for x in xs:
        lo, hi = 0, len(edges) - 2
        while lo < hi:
            mid = (lo + hi) // 2
            if x < edges[mid + 1]:
                hi = mid
            else:
                lo = mid + 1
        counts[lo] += 1
    return counts


def multinomial_loglik(counts: Sequence[int], probs: Sequence[float]) -> float:
    return sum(c * math.log(max(p, 1e-300)) for c, p in zip(counts, probs))


def profile_bin_probs(edges: Sequence[float], rho: float, b: float) -> List[float]:
    """Bin probabilities of the flat-bulk-plus-spike profile on arbitrary edges."""
    den = 1.0 - math.exp(-b)
    out = []
    for lo, hi in zip(edges[:-1], edges[1:]):
        spike = (math.exp(-b * lo) - math.exp(-b * hi)) / den
        out.append((1.0 - rho) * (hi - lo) + rho * spike)
    return out


def single_bin_probs(edges: Sequence[float], b: float) -> List[float]:
    den = 1.0 - math.exp(-b)
    return [(math.exp(-b * lo) - math.exp(-b * hi)) / den
            for lo, hi in zip(edges[:-1], edges[1:])]


def maximise(f: Callable[[float], float], lo: float, hi: float,
             coarse: int = 400, refine: int = 60) -> Tuple[float, float]:
    """Coarse grid then golden-section-style bisection refinement."""
    best_x, best_v = lo, f(lo)
    for i in range(coarse + 1):
        x = lo + (hi - lo) * i / coarse
        v = f(x)
        if v > best_v:
            best_x, best_v = x, v
    step = (hi - lo) / coarse
    for _ in range(refine):
        step *= 0.6
        for cand in (best_x - step, best_x + step):
            if lo <= cand <= hi:
                v = f(cand)
                if v > best_v:
                    best_x, best_v = cand, v
    return best_x, best_v


def aicc(loglik: float, npar: int, n: int) -> float:
    return -2.0 * loglik + 2.0 * npar + 2.0 * npar * (npar + 1) / max(n - npar - 1, 1)


def demo_end_to_end(seed: int = 594) -> None:
    print("=" * 78)
    print("D.  SYNTHETIC END-TO-END FIT: THE CAP LADDER, TREATMENT AND CONTROL")
    print("=" * 78)
    rng = random.Random(seed)
    n, k = 9594, 28
    edges = geometric_edges(k, 0.036)

    # --- treatment: a genuinely censored spike (b t = 14.4) ---------------
    xs = sample_profile(n, rho=0.48, b=400.0, rng=rng)
    counts = histogram(xs, edges)

    def fit(counts_: Sequence[int], cap: float) -> Tuple[float, float, float]:
        def obj(rho_: float) -> float:
            bb, vv = maximise(
                lambda b: multinomial_loglik(counts_,
                                             profile_bin_probs(edges, rho_, b)),
                1e-3, cap)
            return vv
        rho_hat, _ = maximise(obj, 1e-4, 0.999, coarse=60, refine=25)
        b_hat, ll = maximise(
            lambda b: multinomial_loglik(counts_,
                                         profile_bin_probs(edges, rho_hat, b)),
            1e-3, cap)
        return rho_hat, b_hat, ll

    b_single, ll_single = maximise(
        lambda b: multinomial_loglik(counts, single_bin_probs(edges, b)),
        1e-3, 80.0)
    a_single = aicc(ll_single, 1, n)
    print(f"     treatment: n = {n}, {k} geometric bins, "
          f"leftmost bin width {edges[1]:.4f}")
    print(f"     best single law: b = {b_single:.4f}, AICc = {a_single:.2f}\n")
    print(f"{'cap':>8} {'rho_hat':>10} {'b_hat':>12} {'on cap?':>10} "
          f"{'dAICc vs single':>18}")
    print("-" * 78)
    for cap in (10.0, 20.0, 40.0, 80.0):
        rho_hat, b_hat, ll = fit(counts, cap)
        d = aicc(ll, 2, n) - a_single
        print(f"{cap:8.1f} {rho_hat:10.4f} {b_hat:12.4f} "
              f"{str(b_hat > 0.97 * cap):>10} {d:18.2f}")
    print("\n     Strongly negative dAICc at every cap (kernel present), while")
    print("     the steepness estimate tracks the cap instead of the truth.\n")

    # --- control: no spike at all -----------------------------------------
    xs0 = [rng.random() for _ in range(n)]
    counts0 = histogram(xs0, edges)
    b_single0, ll_single0 = maximise(
        lambda b: multinomial_loglik(counts0, single_bin_probs(edges, b)),
        1e-3, 80.0)
    a_single0 = aicc(ll_single0, 1, n)
    print(f"     control (uniform data): best single law b = {b_single0:.4f}\n")
    print(f"{'cap':>8} {'rho_hat':>10} {'b_hat':>12} {'dAICc vs single':>18}")
    print("-" * 78)
    for cap in (10.0, 20.0, 40.0, 80.0):
        rho_hat, b_hat, ll = fit(counts0, cap)
        d = aicc(ll, 2, n) - a_single0
        print(f"{cap:8.1f} {rho_hat:10.6f} {b_hat:12.4f} {d:18.2f}")
    print("\n     Positive dAICc at every cap: the machinery does NOT")
    print("     manufacture a spike where none exists.\n")


# ----------------------------------------------------------------------------


def main() -> None:
    print()
    print("#" * 78)
    print("#  CENSORED STEEPNESS AND UNIFORM KERNEL DETECTION -- NUMERICAL DEMO")
    print("#" * 78)
    print()
    demo_saturation()
    demo_cap_riding()
    demo_cap_gain()
    demo_identified_ray()
    demo_defect()
    demo_separation()
    demo_valley()
    demo_role_swap()
    demo_end_to_end()
    print("=" * 78)
    print("ALL ASSERTED BOUNDS VERIFIED NUMERICALLY.")
    print("=" * 78)
    print("Identified:   whether the second component exists")
    print("              (margin rho(1-rho)/(32k), uniform in the steepness).")
    print("Unidentified: how steep it is")
    print("              (sensitivity decays like exp(-b t); the identified")
    print("               set is a ray -- a lower bound with no upper limit).")
    print()


if __name__ == "__main__":
    main()
