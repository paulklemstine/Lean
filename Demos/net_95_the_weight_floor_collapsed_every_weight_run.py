"""
Numerical demonstrations for
"The Weight-Quantisation Floor Is Not a Bit-Width Law".

Self-contained: standard library only (math, random, itertools, fractions).
Run with `python3 demo.py`.

Sections
--------
1. The measured ladder: excess perplexity, relative excess, scorecard.
2. The geometric band [5/2, 3] certified over ALL ordered pairs of rungs.
3. Convexity, monotonicity, and the four-per-bit curvature ceiling.
4. Geometric closure: why a per-bit bound forbids a floor at any finite width.
5. Block scaling: the scale gain, its budget sqrt(B), and the bit shift.
6. Selection vs content: the sharp delta-bound and the flip construction.
7. Stack composition: a + b + 2*sqrt(a*b) versus exact additivity.
"""

from __future__ import annotations

import math
import random
from fractions import Fraction
from itertools import combinations
from typing import Callable, Dict, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# 1. The measured ladder
# ----------------------------------------------------------------------------

FP16_PPL: float = 6.9825

# (label, bits per weight, perplexity)
RUNGS: List[Tuple[str, float, float]] = [
    ("A (8.5 bpw)", 8.5, 6.9781),
    ("B (6.6 bpw)", 6.6, 7.0006),
    ("C (5.5 bpw)", 5.5, 7.0427),
    ("D (4.8 bpw)", 4.8, 7.1093),
    ("E (3.9 bpw)", 3.9, 7.2758),
    ("F (2.6 bpw)", 2.6, 8.1105),
]

# Rung A is below the reference (noise) and is excluded from multiplicative laws.
LADDER: List[Tuple[str, float, float]] = RUNGS[1:]


def excess(ppl: float, reference: float = FP16_PPL) -> float:
    """Excess perplexity over the uncompressed reference."""
    return ppl - reference


def relative_excess(ppl: float, reference: float = FP16_PPL) -> float:
    """Excess perplexity as a fraction of the reference."""
    return excess(ppl, reference) / reference


def show_ladder() -> None:
    print("=" * 74)
    print("1. THE MEASURED LADDER")
    print("=" * 74)
    print(f"{'rung':<14}{'bpw':>6}{'PPL':>10}{'excess E':>12}{'relative':>12}")
    print(f"{'reference':<14}{16.0:>6.1f}{FP16_PPL:>10.4f}{'-':>12}{'-':>12}")
    for label, bpw, ppl in RUNGS:
        print(
            f"{label:<14}{bpw:>6.1f}{ppl:>10.4f}"
            f"{excess(ppl):>12.4f}{relative_excess(ppl) * 100:>11.3f}%"
        )
    print()
    print("Scorecard (pre-registered predictions):")
    b_rel = relative_excess(7.0006)
    e_rel = relative_excess(7.2758)
    f_rel = relative_excess(8.1105)
    a_rel = relative_excess(6.9781)
    print(f"  P1  rung B inside +/-0.5%?          {abs(b_rel) < 0.005}"
          f"   (measured {b_rel * 100:+.3f}%)")
    print(f"  P2  rung E inside [+5%, +30%]?      {0.05 <= e_rel <= 0.30}"
          f"   (measured {e_rel * 100:+.4f}%)  -> refuted narrowly, and > +2%: "
          f"{e_rel > 0.02}")
    print(f"  P3  rung F undeployable (>= +50%)?  {f_rel >= 0.50}"
          f"   (measured {f_rel * 100:+.3f}%)  -> refuted decisively")
    print(f"  rung A within noise (|.| < 0.1%, negative)? "
          f"{a_rel < 0 and abs(a_rel) < 0.001}   ({a_rel * 100:+.4f}%)")
    stack = relative_excess(7.1093) + 0.0014
    print(f"  deployable stack (D weights + K8/V4 cache) = {stack * 100:.3f}% < 2%: "
          f"{stack < 0.02}")
    print()


# ----------------------------------------------------------------------------
# 2. The geometric band, certified over all ordered pairs
# ----------------------------------------------------------------------------

def per_bit_rate(e_hi: float, e_lo: float, bits_hi: float, bits_lo: float) -> float:
    """Multiplicative degradation factor per bit removed, going hi -> lo bits."""
    return (e_lo / e_hi) ** (1.0 / (bits_hi - bits_lo))


def certify_band(
    ladder: Sequence[Tuple[str, float, float]],
    lower: float = 2.5,
    upper: float = 3.0,
) -> Tuple[bool, float, float]:
    """Check that every ordered pair's per-bit rate lies in [lower, upper]."""
    rates: List[float] = []
    for (l1, b1, p1), (l2, b2, p2) in combinations(ladder, 2):
        hi, lo = ((b1, p1), (b2, p2)) if b1 > b2 else ((b2, p2), (b1, p1))
        rates.append(per_bit_rate(excess(hi[1]), excess(lo[1]), hi[0], lo[0]))
    return all(lower <= m <= upper for m in rates), min(rates), max(rates)


def show_band() -> None:
    print("=" * 74)
    print("2. THE ONE-PARAMETER GEOMETRIC LAW  (all ordered pairs)")
    print("=" * 74)
    print(f"{'from':<14}{'to':<14}{'gap (bits)':>12}{'E ratio':>10}{'per-bit m':>12}")
    for (l1, b1, p1), (l2, b2, p2) in combinations(LADDER, 2):
        (bh, ph), (bl, pl) = ((b1, p1), (b2, p2)) if b1 > b2 else ((b2, p2), (b1, p1))
        hi_lab = l1 if b1 > b2 else l2
        lo_lab = l2 if b1 > b2 else l1
        ratio = excess(pl) / excess(ph)
        m = per_bit_rate(excess(ph), excess(pl), bh, bl)
        print(f"{hi_lab:<14}{lo_lab:<14}{bh - bl:>12.1f}{ratio:>10.4f}{m:>12.4f}")
    ok, lo_m, hi_m = certify_band(LADDER)
    print()
    print(f"  all ten pairs inside [2.5, 3.0]: {ok}   "
          f"(observed range {lo_m:.4f} .. {hi_m:.4f})")
    print(f"  no pair reaches the curvature ceiling of 4 per bit: {hi_m < 4.0}")
    print()


def certify_band_exact() -> bool:
    """Exact rational certification of  (5/2)^k E(r)^10 <= E(s)^10 <= 3^k E(r)^10,
    with k the bit gap in tenths of a bit."""
    ladder_q: List[Tuple[int, Fraction]] = [
        (66, Fraction(70006, 10000) - Fraction(69825, 10000)),
        (55, Fraction(70427, 10000) - Fraction(69825, 10000)),
        (48, Fraction(71093, 10000) - Fraction(69825, 10000)),
        (39, Fraction(72758, 10000) - Fraction(69825, 10000)),
        (26, Fraction(81105, 10000) - Fraction(69825, 10000)),
    ]
    ok = True
    for (tb_r, e_r), (tb_s, e_s) in combinations(ladder_q, 2):
        if tb_s >= tb_r:
            tb_r, e_r, tb_s, e_s = tb_s, e_s, tb_r, e_r
        k = tb_r - tb_s
        lhs = Fraction(5, 2) ** k * e_r ** 10
        mid = e_s ** 10
        rhs = Fraction(3) ** k * e_r ** 10
        ok = ok and (lhs <= mid <= rhs)
    return ok


# ----------------------------------------------------------------------------
# 3. Shape: monotone, convex, under the ceiling
# ----------------------------------------------------------------------------

def show_shape() -> None:
    print("=" * 74)
    print("3. SHAPE: STRICTLY DECREASING, STRICTLY CONVEX, UNDER THE CEILING")
    print("=" * 74)
    pts = sorted([(b, excess(p)) for _, b, p in LADDER])
    mono = all(pts[i][1] > pts[i + 1][1] for i in range(len(pts) - 1))
    print(f"  strictly decreasing in bit width: {mono}")
    convex_all = True
    for (ba, ea), (bb, eb), (bc, ec) in combinations(pts, 3):
        lhs = (eb - ea) * (bc - bb)
        rhs = (ec - eb) * (bb - ba)
        convex_all = convex_all and (lhs < rhs)
    print(f"  all ten triples have increasing secant slopes (convex): {convex_all}")
    print(f"  exact rational certification of the [5/2, 3] band:      "
          f"{certify_band_exact()}")
    print()
    print("  Curvature model:  CB(K, b) = K / 4^b,  so CB(K, b) = 4 * CB(K, b+1).")
    K = 1.0
    for b in range(4, 8):
        print(f"    CB(1, {b}) = {K / 4 ** b:.6e}   ratio to b+1 = "
              f"{(K / 4 ** b) / (K / 4 ** (b + 1)):.1f}")
    print()


# ----------------------------------------------------------------------------
# 4. Geometric closure: no floor at any finite bit width
# ----------------------------------------------------------------------------

def geometric_closure_bound(d_anchor: float, m: float, bits_below: float) -> float:
    """Upper bound on degradation `bits_below` bits under an anchor, given a
    per-bit multiplicative factor at most m."""
    return d_anchor * m ** bits_below


def show_closure() -> None:
    print("=" * 74)
    print("4. GEOMETRIC CLOSURE: A PER-BIT BOUND FORBIDS A FLOOR")
    print("=" * 74)
    anchor = excess(8.1105)  # rung F, 2.6 bpw
    print(f"  anchor: E(2.6 bpw) = {anchor:.4f}, fitted upper rate m = 3")
    for k in (0.5, 1.0):
        bound = geometric_closure_bound(anchor, 3.0, k)
        print(f"    {2.6 - k:.1f} bpw:  E <= {bound:8.4f}   "
              f"relative <= {bound / FP16_PPL * 100:7.2f}%"
              f"   under +50%: {bound / FP16_PPL < 0.5}")
    print("  The bound grows geometrically, never divergently: no finite bit")
    print("  width is a pole, which is exactly what a 'floor' would require.")
    print()


# ----------------------------------------------------------------------------
# 5. Block scaling: gain, budget, and the bit shift
# ----------------------------------------------------------------------------

def rms(values: Sequence[float]) -> float:
    """Root mean square."""
    return math.sqrt(sum(v * v for v in values) / len(values))


def scale_gain(block_ranges: Sequence[float]) -> float:
    """R / rms(r): the factor by which per-block scaling shrinks the effective
    dynamic range relative to one tensor-wide scale."""
    return max(block_ranges) / rms(block_ranges)


def bit_gain(block_ranges: Sequence[float]) -> float:
    """log2 of the scale gain: the exact horizontal shift, in bits, that per-block
    scaling buys over a global scale."""
    return math.log2(scale_gain(block_ranges))


def block_ranges_of(tensor: Sequence[float], block_size: int) -> List[float]:
    """Dynamic range (max - min) of each contiguous block."""
    out: List[float] = []
    for start in range(0, len(tensor) - block_size + 1, block_size):
        blk = tensor[start:start + block_size]
        out.append(max(blk) - min(blk))
    return out


def show_block_scaling() -> None:
    print("=" * 74)
    print("5. BLOCK SCALING: WORTH log2(R / rms(r)) BITS, AT MOST log2(B)/2")
    print("=" * 74)
    B = 256
    print(f"  block count B = {B};  budget sqrt(B) = {math.sqrt(B):.1f} = "
          f"2^{math.log2(math.sqrt(B)):.0f}, i.e. at most "
          f"{math.log2(math.sqrt(B)):.0f} bits")
    print()

    flat = [1.0] * B
    outlier = [0.0] * B
    outlier[0] = 1.0
    print(f"{'range profile':<34}{'gain G':>10}{'bits log2 G':>14}")
    print(f"{'all blocks equal (no outliers)':<34}"
          f"{scale_gain(flat):>10.4f}{bit_gain(flat):>14.4f}")
    print(f"{'single-block outlier (extremal)':<34}"
          f"{scale_gain(outlier):>10.4f}{bit_gain(outlier):>14.4f}")

    random.seed(20260826)
    heavy = [abs(random.gauss(0.0, 1.0)) for _ in range(B)]
    heavy[7] = 40.0  # one wild block, as real weight tensors exhibit
    print(f"{'heavy-tailed, one wild block':<34}"
          f"{scale_gain(heavy):>10.4f}{bit_gain(heavy):>14.4f}")

    lognormal = [math.exp(random.gauss(0.0, 1.2)) for _ in range(B)]
    print(f"{'log-normal block ranges':<34}"
          f"{scale_gain(lognormal):>10.4f}{bit_gain(lognormal):>14.4f}")
    print()
    print("  Budget check (1 <= G <= sqrt(B)) on all profiles: "
          f"{all(1.0 - 1e-12 <= scale_gain(p) <= math.sqrt(B) + 1e-9 for p in (flat, outlier, heavy, lognormal))}")
    print()
    print("  The bit shift is exact:  rms^2 / 4^b  ==  R^2 / 4^(b+j)  when R = 2^j rms.")
    r_rms, j, b = 0.37, 3, 5
    R = (2.0 ** j) * r_rms
    print(f"    rms = {r_rms}, j = {j}, b = {b}:  "
          f"{r_rms ** 2 / 4 ** b:.10e}  vs  {R ** 2 / 4 ** (b + j):.10e}")
    print()
    print(f"  Observed floor shift: 6.0 bpw -> 2.6 bpw = 3.4 bits.")
    print(f"  Inside the four-bit budget at B = 256: {3.4 < math.log2(math.sqrt(B))}")
    print("  => quantiser quality alone accounts for the collapse; model scale")
    print("     is not needed as an explanation.")
    print()


# ----------------------------------------------------------------------------
# 6. Selection versus content
# ----------------------------------------------------------------------------

def content_readout_error(
    p: Sequence[float], v: Sequence[float], q: Callable[[float], float]
) -> float:
    """|<p, q(v)> - <p, v>| for a probability vector p."""
    a = sum(pi * q(vi) for pi, vi in zip(p, v))
    b = sum(pi * vi for pi, vi in zip(p, v))
    return abs(a - b)


def adversarial_flip_quantiser(delta: float) -> Callable[[float], float]:
    """A delta-accurate quantiser that reverses the top-1 choice between the
    scores (delta/2, 0)."""
    def q(x: float) -> float:
        return x + delta / 2 if x <= delta / 4 else x - delta / 2
    return q


def top1(u: Sequence[float]) -> int:
    return max(range(len(u)), key=lambda i: u[i])


def flips_and_small_margins(
    scores: Sequence[Sequence[float]], q: Callable[[float], float], eps: float
) -> Tuple[int, int]:
    """(number of top-1 decisions broken by q, number of positions with margin
    at most 2*eps).  Theorem: the first is at most the second."""
    flips = 0
    small = 0
    for u in scores:
        srt = sorted(u, reverse=True)
        margin = srt[0] - srt[1]
        if margin <= 2 * eps:
            small += 1
        if top1([q(x) for x in u]) != top1(u):
            flips += 1
    return flips, small


def show_selection_vs_content() -> None:
    print("=" * 74)
    print("6. SELECTION VERSUS CONTENT")
    print("=" * 74)
    random.seed(11)
    n = 64
    raw = [random.random() for _ in range(n)]
    tot = sum(raw)
    p = [x / tot for x in raw]
    v = [random.gauss(0.0, 3.0) for _ in range(n)]

    print("  Content channel (probability-weighted average of quantised values):")
    print(f"{'delta':>10}{'worst observed error':>24}{'bound delta':>14}")
    for delta in (0.5, 0.1, 0.01, 0.001):
        worst = 0.0
        for _ in range(200):
            offs = [random.uniform(-delta, delta) for _ in range(n)]
            table = dict(zip(v, offs))
            err = content_readout_error(p, v, lambda x: x + table[x])
            worst = max(worst, err)
        # the extremal quantiser: shift everything by +delta
        extremal = content_readout_error(p, v, lambda x: x + delta)
        print(f"{delta:>10.4f}{max(worst, extremal):>24.10f}{delta:>14.4f}")
    print("  Error is Theta(delta) and the bound delta is attained exactly.")
    print()

    print("  Selection channel (argmax of quantised scores):")
    print(f"{'delta':>10}{'top-1 flipped?':>18}{'read-out error C':>20}")
    for delta in (0.5, 0.1, 0.01, 1e-6):
        u = [delta / 2, 0.0]
        q = adversarial_flip_quantiser(delta)
        flipped = top1([q(x) for x in u]) != top1(u)
        C = 1000.0  # values attached to the two branches; freely chosen
        print(f"{delta:>10.6f}{str(flipped):>18}{C:>20.1f}")
    print("  Error is Theta(1) at EVERY precision: no modulus of continuity exists.")
    print()

    print("  Flip counting: #broken decisions <= #positions with margin <= 2*eps")
    random.seed(5)
    L, k = 4000, 8
    scores = [[random.gauss(0.0, 1.0) for _ in range(k)] for _ in range(L)]
    print(f"{'bits b':>8}{'eps = 2^-b':>14}{'flips':>10}{'small margins':>16}"
          f"{'bound holds':>14}")
    for b in (8, 7, 6, 5, 4, 3, 2):
        eps = 2.0 ** (-b)
        q = adversarial_flip_quantiser(2 * eps)
        flips, small = flips_and_small_margins(scores, q, eps)
        print(f"{b:>8}{eps:>14.6f}{flips:>10}{small:>16}{str(flips <= small):>14}")
    print("  The damage tracks the margin CDF at 2*eps: the cliff is a")
    print("  distributional fact about the scores, not about the bit width.")
    print()


# ----------------------------------------------------------------------------
# 7. Stack composition
# ----------------------------------------------------------------------------

def stack_budget(a: float, b: float) -> float:
    """Worst-case composed cost of two compressions costing at most a and b."""
    return a + b + 2.0 * math.sqrt(a * b)


def quad_excess(lam: Sequence[float], e: Sequence[float]) -> float:
    return 0.5 * sum(li * ei * ei for li, ei in zip(lam, e))


def quad_pair(lam: Sequence[float], e: Sequence[float], f: Sequence[float]) -> float:
    return 0.5 * sum(li * ei * fi for li, ei, fi in zip(lam, e, f))


def show_stack() -> None:
    print("=" * 74)
    print("7. STACK COMPOSITION: a + b + 2*sqrt(a*b), EXACT UNDER ORTHOGONALITY")
    print("=" * 74)
    a, b = 0.01816, 0.0014
    print(f"  weights at 4.8 bpw: a = {a * 100:.3f}%")
    print(f"  K8/V4 attention cache: b = {b * 100:.3f}%")
    print(f"  worst-case budget a + b + 2*sqrt(ab) = {stack_budget(a, b) * 100:.3f}% "
          f"< 3%: {stack_budget(a, b) < 0.03}")
    print(f"  orthogonal (independent) prediction a + b = {(a + b) * 100:.3f}%")
    print()

    random.seed(3)
    n = 500
    lam = [abs(random.gauss(0.0, 1.0)) for _ in range(n)]
    ew = [random.gauss(0.0, 1.0) for _ in range(n)]
    ec = [random.gauss(0.0, 1.0) for _ in range(n)]
    # rescale so that quad_excess matches the measured costs
    ew = [x * math.sqrt(a / quad_excess(lam, ew)) for x in ew]
    ec = [x * math.sqrt(b / quad_excess(lam, ec)) for x in ec]
    joint = quad_excess(lam, [x + y for x, y in zip(ew, ec)])
    print(f"{'configuration':<34}{'joint cost':>14}{'<= budget':>12}")
    print(f"{'random (near-orthogonal)':<34}{joint * 100:>13.4f}%"
          f"{str(joint <= stack_budget(a, b) + 1e-12):>12}")
    aligned = [x * math.sqrt(b / a) for x in ew]  # ec parallel to ew
    joint_al = quad_excess(lam, [x + y for x, y in zip(ew, aligned)])
    print(f"{'perfectly aligned (worst case)':<34}{joint_al * 100:>13.4f}%"
          f"{str(joint_al <= stack_budget(a, b) + 1e-9):>12}")
    print(f"  alignment (curvature pairing) of the random pair: "
          f"{quad_pair(lam, ew, ec):.3e}")
    print("  Under exact orthogonality the costs add exactly: "
          f"{(a + b) * 100:.3f}%.")
    print()


# ----------------------------------------------------------------------------

def main() -> None:
    show_ladder()
    show_band()
    show_shape()
    show_closure()
    show_block_scaling()
    show_selection_vs_content()
    show_stack()
    print("=" * 74)
    print("SUMMARY")
    print("=" * 74)
    print("  * Excess perplexity multiplies by 2.54-2.98 per bit removed, over")
    print("    every one of the ten ordered pairs from 6.6 down to 2.6 bpw.")
    print("  * That is strictly under the four-per-bit ceiling second-order")
    print("    theory imposes, and it is strictly convex: no cliff anywhere.")
    print("  * A per-bit multiplicative bound forbids a floor at any finite width.")
    print("  * Block scaling buys exactly log2(R / rms(r)) bits, at most 4 bits at")
    print("    B = 256 -- enough to cover the observed 3.4-bit floor shift alone.")
    print("  * Content read-outs move by at most delta; selection read-outs can")
    print("    move by any amount at any precision. That is where cliffs live.")


if __name__ == "__main__":
    main()
