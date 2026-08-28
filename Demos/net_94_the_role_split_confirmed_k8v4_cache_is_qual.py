"""
Role-asymmetric attention-cache quantisation: numerical demonstrations.

This self-contained script illustrates, with explicit numbers, every result of the
accompanying paper:

  1. Value path stability          -- perturbing cached values by <= eps moves the
                                      attention output by <= eps (1-Lipschitz, dimension
                                      free), and the bound is attained.
  2. Softmax log-odds translation  -- a logit shift multiplies the odds by exactly
                                      exp(d_i - d_j); the exp(2 eps) weight bound is tight.
  3. Doubling vs. squaring         -- value distortion doubles per lost bit; the key
                                      distortion *factor* squares per lost bit.
  4. No value cliff                -- no quantiser range reproduces the measured collapse
                                      from the value side.
  5. Model refutation              -- any law multiplicative in bit width fitting both
                                      measured arms needs per-bit shrink base K > 18;
                                      the uniform step law (K = 2) is impossible; a
                                      power-law response needs exponent gamma >= 5, and
                                      gamma = 5 is attained.
  6. Depth composition             -- L layers of gain lambda multiply the prefactor by
                                      sum_{i<L} lambda^i and leave the exponent unchanged.
  7. Argmax inversion              -- once the key noise beats the top-two logit gap the
                                      ranking flips and the output error is at least
                                      1/2 - 1/(1 + exp(2h)).
  8. Critical band uniqueness      -- at most one bit width b has A/2^b in [g/2, g).
  9. Bit allocation                -- at equal memory (8,4) beats (6,6).

Run:  python3 demo.py           (standard library only)
"""

from __future__ import annotations

import math
import random
from typing import Callable, Dict, List, Sequence, Tuple

# --------------------------------------------------------------------------------------
# Measured constants (perplexity degradation expressed as a multiplicative excess).
# --------------------------------------------------------------------------------------

PPL_CONTROL: float = 7.1093        # implied full-precision control, PPL_K8V4/1.00142
PPL_K8V4: float = 7.1194           # keys 8 bits, values raw 4 bits
PPL_K5V5: float = 68.7963          # keys 5 bits, values 5 bits
D_AT_8_BITS: float = 0.00142       # +0.142 %
D_AT_5_BITS: float = 8.67694       # +867.694 %


# --------------------------------------------------------------------------------------
# Core primitives
# --------------------------------------------------------------------------------------

def softmax(logits: Sequence[float]) -> List[float]:
    """Softmax weights w_i = exp(s_i) / sum_j exp(s_j) (shift-stabilised)."""
    m = max(logits)
    exps = [math.exp(s - m) for s in logits]
    z = sum(exps)
    return [e / z for e in exps]


def attention_output(logits: Sequence[float], values: Sequence[float]) -> float:
    """Attention output sum_i w_i(s) v_i for a scalar readout coordinate."""
    w = softmax(logits)
    return sum(wi * vi for wi, vi in zip(w, values))


def value_distortion(rng: float, bits: int) -> float:
    """Value-side distortion law D_V(R, b) = R * 2^-b (response exponent exactly 1)."""
    return rng / 2.0 ** bits


def key_distortion(c: float, bits: int) -> float:
    """Key-side distortion law D_K(c, b) = exp(c * 2^-b) - 1 (squaring law)."""
    return math.exp(c / 2.0 ** bits) - 1.0


def total_distortion(c: float, rng: float, key_bits: int, value_bits: int) -> float:
    """Total distortion of a cache configuration."""
    return key_distortion(c, key_bits) + value_distortion(rng, value_bits)


def power_response(c: float, gamma: float, rng: float, bits: int) -> float:
    """Power-law response c * (R * 2^-b)^gamma."""
    return c * (rng / 2.0 ** bits) ** gamma


def shrink_base(d_low_bits: float, d_high_bits: float, b_low: int, b_high: int) -> float:
    """Per-bit shrink base K of a multiplicative law D(b) = c / K^b fitted to two arms."""
    return (d_low_bits / d_high_bits) ** (1.0 / (b_high - b_low))


def err_after(lam: float, e: float, layers: int) -> float:
    """Deviation after L layers of the recursion delta -> lambda*delta + e."""
    delta = 0.0
    for _ in range(layers):
        delta = lam * delta + e
    return delta


def geometric_depth_factor(lam: float, layers: int) -> float:
    """sum_{i<L} lambda^i."""
    return sum(lam ** i for i in range(layers))


def inversion_lower_bound(h: float) -> float:
    """1/2 - 1/(1 + exp(2h)): the order-1 lower bound on the argmax-inversion error."""
    return 0.5 - 1.0 / (1.0 + math.exp(2.0 * h))


def critical_band_widths(amplitude: float, gap: float, max_bits: int = 32) -> List[int]:
    """All bit widths b <= max_bits with A/2^b in [g/2, g). Provably at most one."""
    out: List[int] = []
    for b in range(max_bits + 1):
        noise = amplitude / 2.0 ** b
        if gap / 2.0 <= noise < gap:
            out.append(b)
    return out


def banner(title: str) -> None:
    print()
    print("=" * 86)
    print(title)
    print("=" * 86)


# --------------------------------------------------------------------------------------
# 1. Value path stability: 1-Lipschitz, dimension free, and attained
# --------------------------------------------------------------------------------------

def demo_value_path_stability(trials: int = 20000, seed: int = 20260827) -> None:
    banner("1. Value path stability: |Att(w, v+e) - Att(w, v)| <= eps, dimension free")
    rnd = random.Random(seed)
    eps = 0.05
    worst_by_dim: Dict[int, float] = {}
    for n in (2, 8, 64, 512):
        worst = 0.0
        for _ in range(trials // 4):
            logits = [rnd.gauss(0.0, 3.0) for _ in range(n)]
            values = [rnd.gauss(0.0, 50.0) for _ in range(n)]  # huge values: irrelevant
            noise = [rnd.uniform(-eps, eps) for _ in range(n)]
            perturbed = [v + e for v, e in zip(values, noise)]
            worst = max(worst, abs(attention_output(logits, perturbed)
                                   - attention_output(logits, values)))
        worst_by_dim[n] = worst
        print(f"  n = {n:4d}   worst observed output move = {worst:.6f}   bound = {eps:.6f}"
              f"   {'OK' if worst <= eps + 1e-12 else 'VIOLATED'}")

    # Attainment: constant noise e_i = eps moves the output by exactly eps.
    logits = [0.3, -1.2, 2.5, 0.0]
    values = [1.0, -2.0, 0.5, 3.0]
    moved = abs(attention_output(logits, [v + eps for v in values])
                - attention_output(logits, values))
    print(f"  attained with constant noise: move = {moved:.12f} (= eps = {eps})")
    print("  The bound does not grow with n: the value response exponent is exactly 1.")


# --------------------------------------------------------------------------------------
# 2. The key path is exponential, and the exponential is exact
# --------------------------------------------------------------------------------------

def demo_log_odds_translation(seed: int = 7) -> None:
    banner("2. Softmax log-odds translate exactly; the exp(2 eps) weight bound is tight")
    rnd = random.Random(seed)
    n = 6
    s = [rnd.gauss(0.0, 2.0) for _ in range(n)]
    d = [rnd.uniform(-0.4, 0.4) for _ in range(n)]
    w, wp = softmax(s), softmax([si + di for si, di in zip(s, d)])
    i, j = 0, 3
    lhs = (wp[i] / wp[j])
    rhs = math.exp(d[i] - d[j]) * (w[i] / w[j])
    print(f"  odds after / odds before  = {lhs:.12f}")
    print(f"  exp(d_i - d_j) * (odds)   = {rhs:.12f}   (identity, not an estimate)")

    eps = 0.4
    worst_ratio = max(wpi / wi for wpi, wi in zip(wp, w))
    print(f"  worst weight inflation observed = {worst_ratio:.6f}"
          f"   bound exp(2 eps) = {math.exp(2 * eps):.6f}")

    # Tightness: the extreme perturbation +eps on one coordinate, -eps on all others.
    s2 = [0.0] * n
    d2 = [eps] + [-eps] * (n - 1)
    w2, wp2 = softmax(s2), softmax([a + b for a, b in zip(s2, d2)])
    print(f"  extreme configuration inflation = {wp2[0] / w2[0]:.6f}"
          f"   -> approaches exp(2 eps) = {math.exp(2 * eps):.6f} as n grows")


# --------------------------------------------------------------------------------------
# 3-4. Doubling vs squaring, and the impossibility of a value cliff
# --------------------------------------------------------------------------------------

def demo_doubling_vs_squaring() -> None:
    banner("3. Doubling (values) vs. squaring (keys), and 4. no value cliff")
    c, rng = 0.7, 1.0
    print("  bits |   D_V = R/2^b   |  1 + D_K = exp(c/2^b)  | (1+D_K at b+1)^2")
    for b in (8, 7, 6, 5, 4):
        factor = 1.0 + key_distortion(c, b)
        sq = (1.0 + key_distortion(c, b + 1)) ** 2
        print(f"  {b:4d} | {value_distortion(rng, b):.10f}  |    {factor:.10f}      |  {sq:.10f}")
    print("  Value distortion doubles per lost bit; the key distortion FACTOR squares.")

    print()
    # Any R free at 8 bits gives D_V(R,5) = 8 * D_V(R,8) <= 0.01136, far below 8.67694.
    r_max = D_AT_8_BITS * 2.0 ** 8
    print(f"  Largest range free at 8 bits: R = {r_max:.6f}")
    print(f"  Its 5-bit distortion:         {value_distortion(r_max, 5):.6f}"
          f"   (measured collapse needs {D_AT_5_BITS})")
    print("  => No value configuration can produce the collapse: it is a key-side event.")


# --------------------------------------------------------------------------------------
# 5. Model refutation and the response-exponent gap
# --------------------------------------------------------------------------------------

def demo_model_refutation() -> None:
    banner("5. Model refutation: shrink base K > 18, response exponent gamma >= 5")
    k = shrink_base(D_AT_5_BITS, D_AT_8_BITS, 5, 8)
    print(f"  Required ratio over 3 bits:   {D_AT_5_BITS / D_AT_8_BITS:.1f}"
          f"   (18^3 = {18 ** 3})")
    print(f"  Implied per-bit shrink base:  K = {k:.4f}  > 18   -> super-binary")
    print(f"  Uniform quantiser has K = 2:  ratio over 3 bits = {2 ** 3}  -> REFUTED")

    gamma_real = math.log2(k)
    print(f"  Implied real-valued exponent: gamma = log2(K) = {gamma_real:.4f}")
    print("  Integrality (2^gamma > 18, 2^4 = 16) forces gamma >= 5.")

    # Sharpness: gamma = 5 with prefactor 8.67694 * 2^25 fits both arms.
    c_star = D_AT_5_BITS * 2.0 ** 25
    d8 = power_response(c_star, 5, 1.0, 8)
    d5 = power_response(c_star, 5, 1.0, 5)
    print(f"  Sharpness witness: c = 8.67694 * 2^25, gamma = 5, R = 1")
    print(f"     D(8) = {d8:.10f} <= {D_AT_8_BITS}   D(5) = {d5:.6f} >= {D_AT_5_BITS}")
    print("  => gamma = 5 is attained; the bound cannot be improved to gamma >= 6.")

    print()
    print("  Response-exponent gap:  key gamma >= 5, value gamma = 1  ->  gap >= 4.")

    # Smooth-softmax model: cliff width needed vs. available.
    widths = math.log2(math.log(1 + D_AT_5_BITS) / math.log(1 + D_AT_8_BITS))
    print(f"  Smooth law needs >= log2(log 9.67694 / log 1.00142) = {widths:.2f} bit widths")
    print("  to travel from +0.142% to +867.694%; the measurement brackets it in (5, 8].")


# --------------------------------------------------------------------------------------
# 6. Depth composition preserves the exponent
# --------------------------------------------------------------------------------------

def demo_depth_composition() -> None:
    banner("6. Depth moves the constant, never the slope")
    c, rng, gamma = 3.0, 1.0, 5
    for lam in (0.5, 1.0, 1.3):
        for layers in (1, 4, 16):
            factor = geometric_depth_factor(lam, layers)
            composed_8 = err_after(lam, power_response(c, gamma, rng, 8), layers)
            predicted_8 = power_response(c * factor, gamma, rng, 8)
            composed_5 = err_after(lam, power_response(c, gamma, rng, 5), layers)
            ratio = composed_5 / composed_8
            print(f"  lambda={lam:<4} L={layers:<3} depth factor={factor:9.4f}"
                  f"  composed(8)={composed_8:.6e}  predicted={predicted_8:.6e}"
                  f"  D(5)/D(8)={ratio:.1f}")
    print(f"  The ratio D(5)/D(8) is always 2^(3*gamma) = {2 ** 15}, independent of depth:")
    print("  composition rescales the prefactor and leaves the response exponent fixed.")

    e = 0.01
    print(f"  Value side (lambda = 1): err_after(1, {e}, L) = L * {e} ->"
          f" L=10 gives {err_after(1.0, e, 10):.4f}, linear in depth, never a cliff.")


# --------------------------------------------------------------------------------------
# 7. Argmax inversion: the order-1 lower bound
# --------------------------------------------------------------------------------------

def demo_argmax_inversion() -> None:
    banner("7. Argmax inversion: an order-1 LOWER bound on the key-side damage")
    g = 1.0
    readout = (0.0, 1.0)
    print("     h   |  eps = (g+2h)/2 |  clean out | perturbed out |  |error|  |  lower bound")
    for h in (0.0, 0.25, 0.5, 1.0, 2.0, 4.0):
        eps = (g + 2 * h) / 2.0
        clean = attention_output([0.0, g], readout)
        pert = attention_output([0.0 + eps, g - eps], readout)
        err = abs(pert - clean)
        lb = inversion_lower_bound(h)
        flag = "OK" if err >= lb - 1e-12 else "VIOLATED"
        print(f"   {h:5.2f} |     {eps:6.3f}      |   {clean:.6f} |    {pert:.6f}   |"
              f" {err:.6f} |   {lb:.6f}  {flag}")
    print("  As the overshoot h grows the guaranteed error tends to 1/2: the model attends")
    print("  to the wrong token, an error no Lipschitz constant can bound away.")

    # Rank inversion in a larger, random setting.
    rnd = random.Random(11)
    n, inverted = 8, 0
    for _ in range(5000):
        s = [rnd.gauss(0.0, 1.0) for _ in range(n)]
        order = sorted(range(n), key=lambda t: s[t])
        i, j = order[-2], order[-1]
        gap = s[j] - s[i]
        d = [0.0] * n
        d[i], d[j] = 0.6 * gap, -0.6 * gap        # differential 1.2 * gap > gap
        sp = [a + b for a, b in zip(s, d)]
        if softmax(sp)[j] < softmax(sp)[i]:
            inverted += 1
    print(f"  Random check: differential 1.2 * gap inverted the top-two ranking in"
          f" {inverted}/5000 trials.")


# --------------------------------------------------------------------------------------
# 8. The critical band contains at most one bit width
# --------------------------------------------------------------------------------------

def demo_critical_band(seed: int = 2718) -> None:
    banner("8. The critical band [g/2, g) contains at most one bit width")
    rnd = random.Random(seed)
    max_hits = 0
    for _ in range(20000):
        g = rnd.uniform(0.05, 4.0)
        amplitude = rnd.uniform(0.01, 500.0)
        hits = critical_band_widths(amplitude, g)
        max_hits = max(max_hits, len(hits))
    print(f"  Over 20000 random (A, g) pairs, the maximum number of widths in band"
          f" = {max_hits}")

    g, amplitude = 0.9, 30.0
    print(f"  Example A = {amplitude}, g = {g}:")
    for b in range(2, 10):
        noise = amplitude / 2.0 ** b
        if noise >= g:
            tag = "argmax INVERTS (noise beats the gap)"
        elif noise >= g / 2:
            tag = "CRITICAL BAND"
        else:
            tag = "safe (noise below half the gap)"
        print(f"     b = {b}:  noise = {noise:8.4f}   {tag}")
    print("  A threshold mechanism therefore has a 1-2 bit transition window;")
    print("  the smooth law would need more than 10. Measurement brackets (5, 8].")


# --------------------------------------------------------------------------------------
# 9. Bit allocation at fixed memory
# --------------------------------------------------------------------------------------

def demo_bit_allocation() -> None:
    banner("9. Equal memory, unequal quality: (8,4) beats (6,6)")
    c = math.log(2.0) * 2.0 ** 8      # makes 1 + D_K(c, 8) exactly 2
    rng = 256.0
    print(f"  Key constant c chosen so that 1 + D_K(c, 8) = {1 + key_distortion(c, 8):.6f}")
    print("  bK  bV  avg bits |    D_K       +     D_V      =   total")
    best: Tuple[float, Tuple[int, int]] = (float("inf"), (0, 0))
    for bk, bv in ((4, 8), (5, 7), (6, 6), (7, 5), (8, 4), (9, 3), (10, 2)):
        dk, dv = key_distortion(c, bk), value_distortion(rng, bv)
        tot = dk + dv
        if tot < best[0]:
            best = (tot, (bk, bv))
        print(f"  {bk:2d}  {bv:2d}     {(bk + bv) / 2:.1f}    | {dk:12.6f} + {dv:11.6f}"
              f" = {tot:12.6f}")
    print(f"  Minimiser over this ladder: (bK, bV) = {best[1]} with total {best[0]:.6f}")
    print("  Every minimiser is key rich (bK > bV), as the two laws predict.")
    print(f"  (8,4) total = {total_distortion(c, rng, 8, 4):.6f} <"
          f" (6,6) total = {total_distortion(c, rng, 6, 6):.6f}, at identical memory.")


# --------------------------------------------------------------------------------------
# Measured arms, restated
# --------------------------------------------------------------------------------------

def demo_measurements() -> None:
    banner("0. The two measured arms")
    print(f"  full-precision control (implied)   PPL = {PPL_CONTROL:.4f}")
    print(f"  keys 8 bits / values raw 4 bits    PPL = {PPL_K8V4:.4f}"
          f"   -> +{100 * (PPL_K8V4 / PPL_CONTROL - 1):.3f} %   (~6 average bits/element)")
    print(f"  keys 5 bits / values 5 bits        PPL = {PPL_K5V5:.4f}"
          f"   -> +{100 * (PPL_K5V5 / PPL_CONTROL - 1):.3f} %")
    print("  Same order of memory; one is a working model, the other is noise.")


def main() -> None:
    demos: List[Callable[[], None]] = [
        demo_measurements,
        demo_value_path_stability,
        demo_log_odds_translation,
        demo_doubling_vs_squaring,
        demo_model_refutation,
        demo_depth_composition,
        demo_argmax_inversion,
        demo_critical_band,
        demo_bit_allocation,
    ]
    for d in demos:
        d()
    print()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
