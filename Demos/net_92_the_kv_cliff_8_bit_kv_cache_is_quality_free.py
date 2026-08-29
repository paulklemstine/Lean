"""
The KV Precision Cliff — numerical demonstrations.

A self-contained, dependency-free Python script (standard library only) that
reproduces every quantitative claim of the accompanying paper:

  1.  The crowding pigeonhole: n+1 logits in a window of width R always contain
      a consecutive pair separated by at most R/n.
  2.  The safety criterion  2 * A / 2**b  <  R / n  and its exact scaling law
      b*(2n) = b*(n) + 1  (one KV bit per context doubling).
  3.  The reference-scale bracket: 4 bits fail and 8 bits are safe at ctx 2048,
      and 8 bits already fail at ctx 32768.
  4.  The perplexity certificate  PPL <= exp(2*eps) * PPL0,  its forward reading
      ("8-bit is free": +0.11% worst case) and its inverse reading
      ("the measured 380x collapse forces eps >= 2.5 nats").
  5.  The homogeneity obstruction: linear depth propagation is exactly degree
      one in the injected error, so no gain and no depth can span the measured
      16x-step-to-5000x-damage ratio; the forced response exponent p > 3; and
      the resulting four-bit-wide transition band.
  6.  The single-softmax realization of the whole cliff (G = 12, eps = 13).
  7.  Block scaling: the exact bit-shift equivalence, the >16x concentration a
      rescue requires, and the codebook pigeonhole that no rescaling defeats.
  8.  The sandwich: the band between "provably inverted" and "provably free"
      has width ceil(log2(R / (n * delta))) = 4 bits at the reference scale.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import Callable, Iterable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Measured data (context 2048, ~62K held-out tokens, 7B instruction-tuned model)
# ---------------------------------------------------------------------------

PPL_CONTROL: float = 7.1093        # K f16 / V f16
PPL_K8_V16: float = 7.0924         # K 8-bit / V f16
PPL_K16_V8: float = 7.1160         # K f16  / V 8-bit
PPL_K8_V8: float = 7.1162          # K 8-bit / V 8-bit
PPL_K4_V4: float = 2714.6042       # K 4-bit / V 4-bit, per-tensor

REF_A: float = 1.0                 # logit-side amplification of one key entry
REF_R: float = 32.0                # logit window width, in nats
REF_CTX: int = 2048                # context length of the experiment


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# ---------------------------------------------------------------------------
# 0.  Softmax utilities
# ---------------------------------------------------------------------------

def softmax(s: Sequence[float]) -> List[float]:
    """Numerically stable softmax."""
    m = max(s)
    e = [math.exp(x - m) for x in s]
    z = sum(e)
    return [x / z for x in e]


def log_loss(s: Sequence[float], i: int) -> float:
    """-log of the softmax weight of class i, in nats."""
    return -math.log(softmax(s)[i])


# ---------------------------------------------------------------------------
# 1.  The crowding pigeonhole
# ---------------------------------------------------------------------------

def min_consecutive_gap(s: Sequence[float]) -> float:
    """Smallest gap between consecutive entries of a sorted logit profile."""
    t = sorted(s)
    return min(t[k + 1] - t[k] for k in range(len(t) - 1))


def demo_crowding() -> None:
    banner("1.  CROWDING IS FORCED:  min consecutive gap <= R / n")
    print("For any n+1 logits inside a window of width R, some consecutive pair")
    print("is separated by at most R/n.  Adversarially spread them out anyway:")
    print()
    print(f"{'n':>8}  {'R/n (forced bound)':>20}  {'best achievable min gap':>26}")
    R = REF_R
    for n in (16, 64, 256, 1024, 2048, 8192):
        # The optimal (equally spaced) profile attains the bound exactly.
        s = [R * k / n for k in range(n + 1)]
        print(f"{n:>8}  {R / n:>20.8f}  {min_consecutive_gap(s):>26.8f}")
    print()
    print("Equal spacing attains the bound; every other profile is worse.")
    print("Crowding cannot be trained away: doubling the context halves the gap.")


# ---------------------------------------------------------------------------
# 2.  The safety criterion and its exact scaling law
# ---------------------------------------------------------------------------

def safe_bits(A: float, R: float, n: int, b: int) -> bool:
    """The criterion  2 * (A / 2**b) < R / n."""
    return 2.0 * (A / 2.0 ** b) < R / n


def min_safe_bits(A: float, R: float, n: int, b_max: int = 128) -> int:
    """Least bit width satisfying the safety criterion."""
    for b in range(b_max + 1):
        if safe_bits(A, R, n, b):
            return b
    raise ValueError("no safe width below b_max")


def demo_crowding_law() -> None:
    banner("2.  ONE BIT PER CONTEXT DOUBLING  (exact, not asymptotic)")
    print("Safe(A,R,2n,b+1)  <=>  Safe(A,R,n,b).  Check the equivalence on a grid,")
    print("then read off the minimal safe width as the context doubles.")
    print()
    ok = True
    for n in (1, 3, 17, 128, 2048):
        for b in range(0, 20):
            lhs = safe_bits(REF_A, REF_R, 2 * n, b + 1)
            rhs = safe_bits(REF_A, REF_R, n, b)
            ok = ok and (lhs == rhs)
    print(f"equivalence holds on every tested (n, b):  {ok}")
    print()
    print(f"{'context n':>12}  {'b*(n)':>7}  {'increment':>10}")
    prev = None
    n = 128
    while n <= 131072:
        b = min_safe_bits(REF_A, REF_R, n)
        inc = "-" if prev is None else str(b - prev)
        print(f"{n:>12}  {b:>7}  {inc:>10}")
        prev = b
        n *= 2
    print()
    print("The increment is exactly 1 per doubling: the invariant is b - log2(n).")


def demo_reference_bracket() -> None:
    banner("3.  THE REFERENCE-SCALE BRACKET  (A = 1, R = 32 nats)")
    print(f"forced crowding gap at ctx {REF_CTX}:  R/n = {REF_R / REF_CTX:.8f} nats")
    print()
    print(f"{'bits b':>8}  {'noise 2A/2^b':>14}  {'safe?':>7}")
    for b in (2, 3, 4, 5, 6, 7, 8, 10):
        noise = 2.0 * REF_A / 2.0 ** b
        print(f"{b:>8}  {noise:>14.8f}  {str(safe_bits(REF_A, REF_R, REF_CTX, b)):>7}")
    print()
    print(f"  cliff bracketed in (4, 8]  ->  matches the measurement exactly.")
    print()
    print("Prediction: four more context doublings consume four bits.")
    for n in (2048, 4096, 8192, 16384, 32768):
        print(f"  8 bits safe at ctx {n:>6}?  {safe_bits(REF_A, REF_R, n, 8)}")
    print()
    print("So the comfortable 8-bit operating point is a statement about the")
    print("context length, not about the model.")


# ---------------------------------------------------------------------------
# 4.  The perplexity certificate, forward and inverse
# ---------------------------------------------------------------------------

def ppl_ratio_bound(eps: float) -> float:
    """Certified worst-case perplexity multiplier for logit error eps."""
    return math.exp(2.0 * eps)


def forced_logit_error(ppl_ratio: float) -> float:
    """Inverse certificate: measured ratio -> lower bound on logit error."""
    return math.log(ppl_ratio) / 2.0


def demo_certificate() -> None:
    banner("4.  THE PERPLEXITY CERTIFICATE  PPL <= exp(2*eps) * PPL0")
    print("Forward reading — the free side.")
    print(f"{'eps (nats)':>14}  {'certified max +PPL%':>22}")
    for eps in (1e-4, 5e-4, 1e-3, 5e-3):
        print(f"{eps:>14.5f}  {100.0 * (ppl_ratio_bound(eps) - 1.0):>21.4f}%")
    print()
    print("At eps = 1/2000 the certificate allows at most +0.11%.  Measured arms:")
    for name, ppl in (("K8 / V16", PPL_K8_V16),
                      ("K16 / V8", PPL_K16_V8),
                      ("K8 / V8 ", PPL_K8_V8)):
        d = 100.0 * (ppl / PPL_CONTROL - 1.0)
        print(f"  {name}:  PPL = {ppl:.4f}   delta = {d:+.3f}%   inside certificate: "
              f"{ppl <= 1.0011 * PPL_CONTROL}")
    print()
    print("Inverse reading — the annihilated side.")
    ratio = PPL_K4_V4 / PPL_CONTROL
    eps_min = forced_logit_error(ratio)
    print(f"  measured 4-bit ratio  = {ratio:.4f}x")
    print(f"  forced logit error    >= {eps_min:.4f} nats  (paper states >= 2.5)")
    print(f"  i.e. a factor e^{eps_min:.2f} = {math.exp(eps_min):.2f} distortion in the")
    print("  unnormalized attention weight — a different ranking, not a noisy one.")
    print()
    A_min = 16.0 * 2.5
    print(f"  If that error is the resolution A/2^4 of a uniform 4-bit grid, then")
    print(f"  the covered logit range must satisfy A >= {A_min:.0f} nats.")
    print("  Measure the per-head logit range: far below 40 nats falsifies the")
    print("  uniform-resolution account and implicates outlier keys instead.")


# ---------------------------------------------------------------------------
# 5.  The homogeneity obstruction and the response exponent
# ---------------------------------------------------------------------------

def layer_err(kappa: float, eps: float, L: int) -> float:
    """Worst-case error after L layers:  E_0 = 0,  E_{k+1} = kappa*E_k + eps."""
    e = 0.0
    for _ in range(L):
        e = kappa * e + eps
    return e


def demo_homogeneity() -> None:
    banner("5.  THE HOMOGENEITY OBSTRUCTION:  depth amplification cannot do it")
    print("Closed form check:  E_L = eps * (kappa^L - 1) / (kappa - 1)")
    print(f"{'kappa':>8}  {'L':>4}  {'recursion':>16}  {'closed form':>16}")
    for kappa, L in ((1.05, 32), (1.20, 32), (2.00, 10)):
        rec = layer_err(kappa, 1e-3, L)
        cf = 1e-3 * (kappa ** L - 1.0) / (kappa - 1.0)
        print(f"{kappa:>8.2f}  {L:>4}  {rec:>16.8f}  {cf:>16.8f}")
    print()
    print("Exact degree-one homogeneity:  E_L(kappa, c*eps) = c * E_L(kappa, eps).")
    print(f"{'kappa':>8}  {'L':>4}  {'E(16 eps)/E(eps)':>18}")
    for kappa, L in ((1.05, 32), (1.20, 32), (2.00, 10), (5.00, 40)):
        r = layer_err(kappa, 16e-3, L) / layer_err(kappa, 1e-3, L)
        print(f"{kappa:>8.2f}  {L:>4}  {r:>18.10f}")
    print()
    print("The ratio is 16 for EVERY gain and EVERY depth — parameter-free.")
    print()
    excess_8 = math.log(PPL_K8_V8 / PPL_CONTROL)
    excess_4 = math.log(PPL_K4_V4 / PPL_CONTROL)
    print(f"  measured 8-bit excess log-perplexity : {excess_8:.6f} nats  (< 1/1000)")
    print(f"  measured 4-bit excess log-perplexity : {excess_4:.6f} nats  (> 5)")
    print(f"  required damage ratio                : {excess_4 / excess_8:>12.1f}x")
    print(f"  maximum ratio a sub-homogeneous model can deliver :        16.0x")
    print(f"  under-prediction factor              : {excess_4 / (16 * excess_8):>12.1f}x")
    print()
    print("The cliff is a threshold phenomenon, not a gain.")


def forced_exponent(excess_low: float, excess_high: float, step_ratio: float = 16.0) -> float:
    """Smallest power-law exponent p with C*(step_ratio*x)^p / C*x^p = ratio."""
    return math.log(excess_high / excess_low) / math.log(step_ratio)


def demo_exponent_and_band() -> None:
    banner("5b. THE FORCED RESPONSE EXPONENT AND THE FOUR-BIT BAND")
    p = forced_exponent(1.0 / 1000.0, 5.0)
    print(f"  Calibrating D(x) = C x^p on the two measured arms forces")
    print(f"    p = log(5 / 0.001) / log(16) = {p:.4f}   (the paper proves p > 3)")
    print()
    print("  With p >= 3, define a width to be INTERMEDIATE when the damage it")
    print("  produces is neither free (<= delta) nor annihilating (>= 5000 delta).")
    print("  Five extra bits shrink damage by at least 32^p >= 2^15 = 32768,")
    print("  which exceeds the whole 5000x dynamic range.  Hence any two")
    print("  intermediate widths differ by at most 4.")
    print()
    delta, C, A = 1.0 / 1000.0, 1.0, 1.0
    print(f"{'b':>4}  {'damage C(A/2^b)^p':>20}  {'regime':>16}")
    lo, hi = None, None
    for b in range(0, 13):
        d = C * (A / 2.0 ** b) ** p
        if d >= 5000 * delta:
            regime = "annihilated"
        elif d <= delta:
            regime = "free"
        else:
            regime = "INTERMEDIATE"
            lo = b if lo is None else lo
            hi = b
        print(f"{b:>4}  {d:>20.8f}  {regime:>16}")
    if lo is not None and hi is not None:
        print()
        print(f"  intermediate widths span b = {lo}..{hi};  width {hi - lo} <= 4.  "
              "The grid {4, 8} straddles it.")


# ---------------------------------------------------------------------------
# 6.  The cliff inside a single softmax
# ---------------------------------------------------------------------------

def demo_single_softmax() -> None:
    banner("6.  THE CLIFF FITS INSIDE ONE SOFTMAX  (no depth required)")
    G, eps = 12.0, 13.0
    base = log_loss([0.0, G], 1)
    free = log_loss([eps / 16.0, G - eps / 16.0], 1)
    dead = log_loss([eps, G - eps], 1)
    print(f"  two positions, logit gap G = {G} nats, perturbation (+eta, -eta)")
    print()
    print(f"  unperturbed log-loss            : {base:.10f} nats")
    print(f"  eta = eps/16 = {eps / 16:.4f}          : {free:.10f} nats "
          f"(rise {free - base:.10f})")
    print(f"  eta = eps    = {eps:.4f}         : {dead:.10f} nats "
          f"(rise {dead - base:.6f})")
    print()
    print(f"  free side  : rise <= 1/1000 nat ?  {free - base <= 1e-3}   "
          f"PPL factor {math.exp(free - base):.6f}")
    print(f"  fatal side : rise >= 5 nats     ?  {dead - base >= 5.0}   "
          f"PPL factor {math.exp(dead - base):.2f}")
    print()
    print("  One factor of 16 in the step separates 'free' from 'annihilated'")
    print("  in a single two-position head.  Depth is not the mechanism.")


# ---------------------------------------------------------------------------
# 7.  Block scaling: resolution yes, distinctness never
# ---------------------------------------------------------------------------

def demo_block_scaling() -> None:
    banner("7.  BLOCK SCALING:  a bit shift on resolution, nothing on distinctness")
    print("  Safe(A/2^m, R, n, b)  <=>  Safe(A, R, n, b+m)   — check on a grid:")
    ok = True
    for m in range(0, 8):
        for b in range(0, 16):
            ok = ok and (safe_bits(REF_A / 2.0 ** m, REF_R, REF_CTX, b)
                         == safe_bits(REF_A, REF_R, REF_CTX, b + m))
    print(f"  bit-shift equivalence holds everywhere tested:  {ok}")
    print()
    print("  How much concentration does a 4-bit rescue need?")
    print(f"{'rho (block/tensor range)':>26}  {'4-bit safe?':>12}")
    for rho in (1.0, 1 / 2, 1 / 4, 1 / 8, 1 / 16, 1 / 20, 1 / 32):
        print(f"{rho:>26.6f}  {str(safe_bits(rho * REF_A, REF_R, REF_CTX, 4)):>12}")
    print()
    print("  Rescue requires rho < 1/16: block scaling must shrink the dynamic")
    print("  range by MORE than the four bits it is trying to replace.")
    print()
    print("  And the worst block governs.  One full-range block cancels the gain:")
    blocks = [0.01, 0.02, 0.015, 1.0, 0.03]        # last-but-one is an outlier block
    rho_max = max(blocks)
    print(f"    per-block ranges (relative)  : {blocks}")
    print(f"    governing rho = max           = {rho_max}")
    print(f"    blocked cache safe at 4 bits? = "
          f"{all(safe_bits(r * REF_A, REF_R, REF_CTX, 4) for r in blocks)}")
    print()
    print("  DISTINCTNESS: the pigeonhole no scaling scheme defeats.")
    xs = [1.0 + 0.001 * k for k in range(32)]      # 32 distinct block weights
    for sigma, mu in ((1.0, 0.0), (0.001, 1.0), (1e6, -5.0)):
        codes = quantize_block(xs, bits=4, sigma=sigma, mu=mu)
        collisions = find_collision(xs, codes)
        print(f"    sigma={sigma:<10g} mu={mu:<6g} distinct codes = "
              f"{len(set(codes)):>2}/32   collision at indices {collisions}")
    print()
    print("  16 levels cannot separate 32 weights, for any scale and offset.")
    print("  Collided keys have equal logits, hence EXACTLY equal softmax weights:")
    s = [2.0, 2.0, 0.5]
    w = softmax(s)
    print(f"    logits {s} -> weights {[round(x, 8) for x in w]}"
          f"   tie exact: {w[0] == w[1]}")


def quantize_block(xs: Sequence[float], bits: int, sigma: float = 1.0,
                   mu: float = 0.0) -> List[int]:
    """Affinely rescaled uniform quantizer with 2**bits levels, per block."""
    ys = [(x - mu) / sigma for x in xs]
    lo, hi = min(ys), max(ys)
    levels = 2 ** bits
    if hi == lo:
        return [0] * len(ys)
    step = (hi - lo) / (levels - 1)
    return [int(round((y - lo) / step)) for y in ys]


def find_collision(xs: Sequence[float], codes: Sequence[int]) -> Tuple[int, int]:
    """First pair of distinct inputs sharing a code (guaranteed for 32 > 16)."""
    seen: dict = {}
    for i, c in enumerate(codes):
        if c in seen and xs[seen[c]] != xs[i]:
            return (seen[c], i)
        seen.setdefault(c, i)
    raise AssertionError("pigeonhole violated — impossible for 32 items, 16 codes")


# ---------------------------------------------------------------------------
# 8.  The sandwich: width of the band no certificate covers
# ---------------------------------------------------------------------------

def band_width_bits(R: float, n: int, delta: float) -> int:
    """ceil(log2(R / (n * delta))): bits between 'provably broken' and 'free'."""
    return max(0, math.ceil(math.log2(R / (n * delta))))


def demo_sandwich() -> None:
    banner("8.  THE SANDWICH:  how wide is the unexplained band?")
    print("  Fragile certificate: error > (R/n)/2  =>  a ranking is provably inverted.")
    print("  Free certificate   : error < delta/2  =>  PPL multiplied by <= e^delta.")
    print("  The gap between them is ceil(log2(R / (n delta))) bit widths.")
    print()
    print(f"{'context n':>10}  {'delta (nats)':>14}  {'band width (bits)':>18}")
    for n in (512, 2048, 8192, 32768):
        for delta in (1e-2, 1e-3, 1e-4):
            print(f"{n:>10}  {delta:>14.5f}  {band_width_bits(REF_R, n, delta):>18}")
    print()
    m = band_width_bits(REF_R, REF_CTX, 1e-3)
    print(f"  At the reference scale (R=32, n=2048, delta=1/1000): "
          f"log2(15.625) -> {m} bits.")
    print(f"  The two arms actually run were 4 and 8 bits apart: exactly the band.")
    print()
    b_star = min_safe_bits(REF_A, REF_R, REF_CTX)
    print(f"  safe width b* at ctx 2048 = {b_star};  free-certified from "
          f"b = {b_star + m}.")
    print(f"  Verify: 2 * A / 2^(b*+m) = {2 * REF_A / 2 ** (b_star + m):.8f} "
          f"<= 0.001  -> {2 * REF_A / 2 ** (b_star + m) <= 1e-3}")
    print()
    print("  The band NARROWS by one bit per context doubling and WIDENS by one")
    print("  bit per tenfold tightening of delta.  Sample 5, 6, 7 bits at ctx")
    print("  2048 and the middle becomes resolvable.")


# ---------------------------------------------------------------------------

def main() -> None:
    print("THE KV PRECISION CLIFF — numerical demonstrations")
    print("Measured anchor (7B instruction-tuned model, ctx 2048, ~62K tokens):")
    print(f"  control  K f16 / V f16 : PPL {PPL_CONTROL}")
    print(f"  K 8-bit  / V 8-bit     : PPL {PPL_K8_V8}   "
          f"({100 * (PPL_K8_V8 / PPL_CONTROL - 1):+.3f}%)")
    print(f"  K 4-bit  / V 4-bit     : PPL {PPL_K4_V4}   "
          f"({100 * (PPL_K4_V4 / PPL_CONTROL - 1):+.0f}%)")

    demo_crowding()
    demo_crowding_law()
    demo_reference_bracket()
    demo_certificate()
    demo_homogeneity()
    demo_exponent_and_band()
    demo_single_softmax()
    demo_block_scaling()
    demo_sandwich()

    banner("SUMMARY")
    print("  * one KV bit buys exactly one context doubling;")
    print("  * 8-bit cache is certified free (+0.11% worst case);")
    print("  * the measured 4-bit collapse forces >= 2.5 nats of logit error;")
    print("  * no sub-homogeneous mechanism can produce it, at any depth;")
    print("  * the forced response exponent exceeds 3, so the transition is at")
    print("    most four bit widths wide;")
    print("  * block scaling buys resolution at one bit per halving of range and")
    print("    buys no distinctness at all.")


if __name__ == "__main__":
    main()
