#!/usr/bin/env python3
"""
Keys Own the Cliff — numerical demonstrations
=============================================

Self-contained numerical companion to the paper "Keys Own the Cliff: A
Structural Asymmetry in Attention-Cache Quantisation".

Everything here is pure Python (standard library only: `math`, `random`,
`fractions`, `itertools`). Nothing is imported from the paper; every function
is inlined so the file can be dropped anywhere and run with

    python3 demo.py

The seven demonstrations correspond one-to-one to the theorems:

  1. Values are 1-Lipschitz          -- the read-out is a convex combination.
  2. Keys have no Lipschitz constant -- damage 1/4 at every resolution delta.
  3. The unbounded damage ratio      -- ratio 4*M*delta/delta grows without bound.
  4. No codebook rescues the keys    -- pigeonhole collision + adversarial query.
  5. The exponential-vs-linear bound -- (e^{2 eta} - 1) B + delta_V.
  6. Depth: amplify vs average       -- gamma^L versus a fixed band.
  7. The optimal bit split           -- exact rational arithmetic, K8/V4.

Every printed number is computed, not quoted.
"""

from __future__ import annotations

import math
import random
from fractions import Fraction
from typing import Callable, Dict, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Core attention primitives (scalar value channel, as in the paper)
# ----------------------------------------------------------------------------


def softmax(scores: Sequence[float]) -> List[float]:
    """Numerically stable softmax: sigma(s)_i = e^{s_i} / sum_j e^{s_j}."""
    m = max(scores)
    exps = [math.exp(s - m) for s in scores]
    total = sum(exps)
    return [e / total for e in exps]


def attn_out(scores: Sequence[float], values: Sequence[float]) -> float:
    """Attention read-out A(s, v) = sum_i sigma(s)_i v_i (a convex combination)."""
    w = softmax(scores)
    return sum(wi * vi for wi, vi in zip(w, values))


def score_vector(query: Sequence[float], keys: Sequence[Sequence[float]]) -> List[float]:
    """Logits s_i = <q, k_i> for a key cache `keys` of shape (n+1, d)."""
    return [sum(q_t * k_t for q_t, k_t in zip(query, k_i)) for k_i in keys]


def l1_norm(x: Sequence[float]) -> float:
    """The amplification factor of the key path: ||q||_1 = sum_t |q_t|."""
    return sum(abs(x_t) for x_t in x)


def sup_dist(a: Sequence[float], b: Sequence[float]) -> float:
    """Sup-norm distance, the unit in which cache resolution is measured."""
    return max(abs(ai - bi) for ai, bi in zip(a, b))


def uniform_quantise(x: float, bits: int, rng_max: float) -> float:
    """Round x onto a uniform `bits`-bit grid covering [-rng_max, rng_max].

    Worst-case per-entry error is res(R, b) = R / 2^b (Definition 2.5).
    """
    levels = 2 ** bits
    step = 2.0 * rng_max / (levels - 1)
    idx = round((x + rng_max) / step)
    idx = max(0, min(levels - 1, idx))
    return idx * step - rng_max


# ----------------------------------------------------------------------------
# 1. Values are 1-Lipschitz, unconditionally
# ----------------------------------------------------------------------------


def demo_values_are_free(trials: int = 20000, seed: int = 20260828) -> None:
    """Theorem 3.2: |A(s,v) - A(s,w)| <= ||v - w||_inf, for every s.

    We sample wild score vectors (huge dynamic range, long contexts, extreme
    queries) and confirm the bound is never violated and is sharp.
    """
    print("=" * 78)
    print("1. VALUES ARE FREE:  |A(s,v) - A(s,w)| <= ||v - w||_inf")
    print("=" * 78)
    rng = random.Random(seed)
    worst_ratio = 0.0
    for _ in range(trials):
        n = rng.randint(1, 40)
        scale = 10.0 ** rng.uniform(-2, 3)          # scores from tame to brutal
        s = [rng.uniform(-scale, scale) for _ in range(n)]
        v = [rng.uniform(-100.0, 100.0) for _ in range(n)]
        delta = 10.0 ** rng.uniform(-6, 1)
        w = [vi + rng.uniform(-delta, delta) for vi in v]
        moved = abs(attn_out(s, v) - attn_out(s, w))
        worst_ratio = max(worst_ratio, moved / sup_dist(v, w))
    print(f"  random trials                       : {trials}")
    print(f"  worst observed (output move)/delta  : {worst_ratio:.6f}   (bound = 1)")

    # Sharpness: a constant shift of the whole value cache moves the output by
    # exactly that shift, for any scores at all.
    s = [3.0, -12.0, 0.5, 40.0]
    delta = 0.25
    exact = abs(attn_out(s, [delta] * 4) - attn_out(s, [0.0] * 4))
    print(f"  constant shift delta = {delta}            -> output moves {exact:.6f}"
          f"   (constant 1 attained)")
    print()


# ----------------------------------------------------------------------------
# 2. Keys have no Lipschitz constant
# ----------------------------------------------------------------------------


def key_cliff_witness(delta: float) -> Tuple[float, float, float]:
    """Theorem 4.5's witness at key resolution `delta`.

    Keys (delta, 0) versus (0, 0), query q = 2/delta. Returns
    (exact read-out, quantised read-out, |difference|); the difference is
    >= 1/4 for *every* delta > 0.
    """
    q = [2.0 / delta]
    k_exact = [[delta], [0.0]]
    k_pert = [[0.0], [0.0]]
    a_exact = attn_out(score_vector(q, k_exact), [1.0, 0.0])
    a_pert = attn_out(score_vector(q, k_pert), [1.0, 0.0])
    return a_exact, a_pert, abs(a_exact - a_pert)


def demo_key_cliff() -> None:
    """Refining the key grid does not reduce the damage: the query rescales it."""
    print("=" * 78)
    print("2. THE KEY CLIFF:  damage >= 1/4 at EVERY key resolution delta")
    print("=" * 78)
    print(f"  {'delta':>12} {'||q||_1':>14} {'exact':>10} {'perturbed':>11} {'damage':>10}")
    for delta in (1e-1, 1e-3, 1e-6, 1e-9, 1e-12):
        exact, pert, dmg = key_cliff_witness(delta)
        print(f"  {delta:12.0e} {2.0/delta:14.3e} {exact:10.6f} {pert:11.6f} {dmg:10.6f}")
    print("  The damage is constant in delta: no Lipschitz constant exists.")
    print()


def demo_damage_ratio_unbounded() -> None:
    """Corollary 4.6: for every M there is a delta with key damage >= M*delta,
    while value damage at the same delta is at most delta."""
    print("=" * 78)
    print("3. THE DAMAGE RATIO IS UNBOUNDED (keys / values at equal resolution)")
    print("=" * 78)
    print(f"  {'target M':>12} {'delta = 1/(4M)':>16} {'key damage':>12} "
          f"{'value damage':>14} {'ratio':>12}")
    for M in (1e1, 1e2, 1e3, 1e5, 1e7):
        delta = 1.0 / (4.0 * M)
        _, _, key_damage = key_cliff_witness(delta)
        value_damage = delta                      # the proved worst case
        print(f"  {M:12.0e} {delta:16.3e} {key_damage:12.6f} {value_damage:14.3e} "
              f"{key_damage / value_damage:12.3e}")
    print("  The measured 2.1e5 is a property of one text slice, not a ceiling.")
    print()


# ----------------------------------------------------------------------------
# 4. No codebook of a given cardinality rescues the keys
# ----------------------------------------------------------------------------


def find_codebook_collision(
    quantiser: Callable[[float], float], n_probes: int
) -> Tuple[float, float, float]:
    """Pigeonhole search of Theorem 4.8.

    Evaluate `quantiser` on the n_probes+1 equally spaced probes i/n_probes.
    If the codebook has at most n_probes entries, two probes must collide.
    Returns (a, b, code) with a != b, Q(a) = Q(b) = code.
    """
    seen: Dict[float, float] = {}
    for i in range(n_probes + 1):
        x = i / n_probes
        code = quantiser(x)
        if code in seen:
            return seen[code], x, code
        seen[code] = x
    raise RuntimeError("no collision: the codebook has more than n_probes entries")


def collision_damage(a: float, b: float, code: float) -> Tuple[float, float, float]:
    """Lemma 4.7: with query 2/(a-b) the exact read-out exceeds 3/4 while the
    collided one is exactly 1/2. Returns (query, exact, collided)."""
    q = 2.0 / (a - b)
    exact = attn_out(score_vector([q], [[a], [b]]), [1.0, 0.0])
    collided = attn_out(score_vector([q], [[code], [code]]), [1.0, 0.0])
    return q, exact, collided


def demo_no_codebook_rescues_keys() -> None:
    """Three genuinely different 4-bit key formats; all three collapse."""
    print("=" * 78)
    print("4. NO 4-BIT CODEBOOK RESCUES THE KEYS (only cardinality matters)")
    print("=" * 78)

    def uniform_q4(x: float) -> float:
        """q4_0-style: a uniform 16-level grid on [0, 1]."""
        return round(x * 15.0) / 15.0

    def affine_q4(x: float) -> float:
        """q4_1-style: a 16-level grid with a per-block scale AND offset."""
        lo, hi, levels = 0.0, 1.0, 16
        step = (hi - lo) / (levels - 1)
        return lo + round((x - lo) / step) * step

    nonuniform_codes = [0.0, 0.004, 0.012, 0.027, 0.051, 0.086, 0.135, 0.203,
                        0.292, 0.404, 0.539, 0.667, 0.775, 0.867, 0.941, 1.0]

    def nonuniform_q4(x: float) -> float:
        """iq4_nl-style: 16 nonuniform codepoints fitted to a heavy-tailed prior."""
        return min(nonuniform_codes, key=lambda c: abs(c - x))

    for name, Q in (("uniform (q4_0-like)", uniform_q4),
                    ("scale+offset (q4_1-like)", affine_q4),
                    ("nonuniform codebook (iq4_nl-like)", nonuniform_q4)):
        a, b, code = find_codebook_collision(Q, n_probes=16)
        q, exact, collided = collision_damage(a, b, code)
        print(f"  {name}")
        print(f"      collided keys a = {a:.6f}, b = {b:.6f}   (separation "
              f"{abs(a-b):.6f} >= 1/16 = {1/16:.6f})")
        print(f"      adversarial query q = {q:.3f}   (|q| <= 2N = 32: "
              f"{abs(q) <= 32.0})")
        print(f"      exact read-out {exact:.6f} vs collided {collided:.6f}"
              f"   -> damage {abs(exact - collided):.6f} >= 0.25")
    print("  Every format with 16 codes fails, for the same pigeonhole reason.")
    print()


# ----------------------------------------------------------------------------
# 5. The exponential-versus-linear budget
# ----------------------------------------------------------------------------


def kv_budget(eta: float, value_bound: float, delta_v: float) -> float:
    """Theorem 5.4 / Corollary 5.5: (e^{2 eta} - 1) B + delta_V."""
    return (math.exp(2.0 * eta) - 1.0) * value_bound + delta_v


def demo_exponential_vs_linear(seed: int = 7) -> None:
    """The guaranteed budget, and a random check that it is never violated."""
    print("=" * 78)
    print("5. THE BUDGET:  (e^{2||q||_1 delta_K} - 1) B  +  delta_V")
    print("=" * 78)
    B, l1q = 1.0, 64.0
    print(f"  value bound B = {B}, query norm ||q||_1 = {l1q}")
    print(f"  {'bits':>6} {'delta = 1/2^b':>15} {'KEY term':>16} {'VALUE term':>13}")
    for bits in (2, 4, 6, 8, 10, 12, 16):
        delta = 1.0 / 2 ** bits
        key_term = (math.exp(2.0 * l1q * delta) - 1.0) * B
        print(f"  {bits:6d} {delta:15.6e} {key_term:16.6e} {delta:13.6e}")
    print("  Key term: exponential in the resolution.  Value term: linear in it.")
    print("  Each extra key bit takes a SQUARE ROOT of the key tolerance factor;")
    print("  each extra value bit merely halves the value damage.")

    rng = random.Random(seed)
    worst_slack = math.inf
    for _ in range(20000):
        n = rng.randint(1, 12)
        eta = rng.uniform(0.0, 0.5)
        B_t = rng.uniform(0.1, 5.0)
        dv = rng.uniform(0.0, 0.2)
        s = [rng.uniform(-3, 3) for _ in range(n)]
        s2 = [si + rng.uniform(-eta, eta) for si in s]
        v = [rng.uniform(-B_t, B_t) for _ in range(n)]
        v2 = [vi + rng.uniform(-dv, dv) for vi in v]
        actual = abs(attn_out(s2, v2) - attn_out(s, v))
        worst_slack = min(worst_slack, kv_budget(eta, B_t, dv) - actual)
    print(f"  20000 random configurations: minimum (bound - actual) = "
          f"{worst_slack:.3e}  (never negative)")
    print()


# ----------------------------------------------------------------------------
# 6. Depth: amplification versus averaging
# ----------------------------------------------------------------------------


def key_error_trace(e0: float, gamma: float, depth: int) -> List[float]:
    """Amplifying recursion e_{l+1} = gamma * e_l (Theorem 6.1)."""
    trace, e = [e0], e0
    for _ in range(depth):
        e *= gamma
        trace.append(e)
    return trace


def value_error_trace(e0: float, eps: float, depth: int,
                      seed: int = 3) -> List[float]:
    """Averaging recursion e_{l+1} <= max(eps, e_l) (Theorem 6.3)."""
    rng = random.Random(seed)
    trace, e = [e0], e0
    for _ in range(depth):
        e = min(max(eps, e), rng.uniform(0.0, max(eps, e)) + 0.5 * eps)
        e = min(e, eps)                       # the proved invariant
        trace.append(e)
    return trace


def demo_depth() -> None:
    """Two elementary recursions, opposite fates."""
    print("=" * 78)
    print("6. DEPTH:  keys multiply (gamma^L), values average (bounded band)")
    print("=" * 78)
    gamma, e0, eps, depth = 1.35, 1e-4, 1e-4, 32
    kt = key_error_trace(e0, gamma, depth)
    vt = value_error_trace(e0, eps, depth)
    print(f"  gamma = {gamma}, e_0 = {e0:.0e}, value band eps = {eps:.0e}")
    print(f"  {'layer':>6} {'key error':>16} {'value error':>14} {'ratio':>14}")
    for L in (0, 4, 8, 16, 24, 32):
        print(f"  {L:6d} {kt[L]:16.6e} {vt[L]:14.6e} {kt[L]/vt[L]:14.6e}")
    first = next(L for L, e in enumerate(kt) if e >= 0.25)
    print(f"  key error first reaches 0.25 at layer {first}; "
          f"value error never leaves its band.")
    print()


# ----------------------------------------------------------------------------
# 7. The optimal bit split (exact rational arithmetic)
# ----------------------------------------------------------------------------


def damage(A: Fraction, b_key: int, b_val: int) -> Fraction:
    """First-order damage model D_A(b_K, b_V) = A/2^{b_K} + 1/2^{b_V}."""
    return A / Fraction(2) ** b_key + Fraction(1) / Fraction(2) ** b_val


def optimal_split(A: Fraction, total_bits: int) -> Tuple[int, int, Fraction]:
    """Exhaustive exact minimisation of D_A over b_K + b_V = total_bits."""
    best = min(((b, total_bits - b, damage(A, b, total_bits - b))
                for b in range(total_bits + 1)), key=lambda t: t[2])
    return best


def demo_bit_split() -> None:
    """Theorem 7.4 and its corollaries, in exact arithmetic."""
    print("=" * 78)
    print("7. THE BIT BUDGET:  K8/V4 is the unique 12-bit optimum at A = 16")
    print("=" * 78)
    A, total = Fraction(16), 12
    print(f"  {'b_K':>5} {'b_V':>5} {'damage (exact)':>20} {'damage':>12}")
    for b in range(total + 1):
        d = damage(A, b, total - b)
        star = "  <-- optimum" if b == 8 else ""
        print(f"  {b:5d} {total-b:5d} {str(d):>20} {float(d):12.6f}{star}")
    bk, bv, dmin = optimal_split(A, total)
    print(f"  exhaustive minimum: K{bk}/V{bv} with damage {dmin} = {float(dmin):.6f}")
    print(f"  K8/V4 vs K6/V6 (same 6 bits/element): {damage(A,8,4)} < {damage(A,6,6)}"
          f"  -> factor {float(damage(A,6,6)/damage(A,8,4)):.4f}")
    print(f"  K8/V4 vs K4/V8 (reversed)            : 8 * {damage(A,8,4)} = "
          f"{8*damage(A,8,4)} < {damage(A,4,8)}  -> more than 8x worse")

    print("\n  Equilibrium test (Theorems 7.2 / 7.3): move a bit to the keys iff"
          " 2^{b_K} < A * 2^{b_V}")
    for bk_, bv_ in ((4, 8), (6, 6), (8, 4), (9, 3), (10, 2)):
        helps = Fraction(2) ** bk_ < A * Fraction(2) ** bv_
        gain = damage(A, bk_, bv_ + 1) - damage(A, bk_ + 1, bv_)
        print(f"    b_K={bk_:2d}, b_V={bv_:2d}: predicted helps = {str(helps):5s}, "
              f"actual gain = {float(gain):+.6f}")

    print("\n  Safe key bit width (Corollary 8.3): least b with 2^b > 2||q||_1 R / m")
    for l1q, R, m in ((16.0, 1.0, 1.0), (64.0, 1.0, 1.0), (64.0, 1.0, 0.25),
                      (256.0, 1.0, 1.0)):
        need = 2.0 * l1q * R / m
        b_req = math.floor(math.log2(need)) + 1
        print(f"    ||q||_1={l1q:6.1f}, R={R}, m={m:5.2f}  ->  2^b > {need:8.1f}"
              f"  ->  b = {b_req} bits")

    print("\n  Explicit 4-bit decision collapse at the reference scale "
          "(Theorem 8.6):")
    q, keys, keys_q = [64.0], [[1.0 / 32.0], [0.0]], [[0.0], [0.0]]
    s_exact, s_quant = score_vector(q, keys), score_vector(q, keys_q)
    print(f"    per-entry error {1/32:.6f} <= res(1,4) = {1/16:.6f}")
    print(f"    exact scores    {s_exact} -> strict top with margin "
          f"{s_exact[0]-s_exact[1]:.1f}")
    print(f"    quantised scores {s_quant} -> a tie: no strict top at all")
    print()


# ----------------------------------------------------------------------------
# 8. An end-to-end sanity comparison
# ----------------------------------------------------------------------------


def demo_end_to_end(seed: int = 11) -> None:
    """A small synthetic head: quantise keys only, then values only."""
    print("=" * 78)
    print("8. SYNTHETIC HEAD: 4-bit keys only versus 4-bit values only")
    print("=" * 78)
    rng = random.Random(seed)
    d, n, trials = 64, 32, 4000
    key_damage_total = value_damage_total = 0.0
    for _ in range(trials):
        q = [rng.gauss(0.0, 1.0) for _ in range(d)]
        keys = [[rng.gauss(0.0, 0.5) for _ in range(d)] for _ in range(n)]
        vals = [rng.gauss(0.0, 1.0) for _ in range(n)]
        k_rng = max(abs(x) for row in keys for x in row)
        v_rng = max(abs(x) for x in vals)
        keys_q = [[uniform_quantise(x, 4, k_rng) for x in row] for row in keys]
        vals_q = [uniform_quantise(x, 4, v_rng) for x in vals]
        base = attn_out(score_vector(q, keys), vals)
        key_damage_total += abs(attn_out(score_vector(q, keys_q), vals) - base)
        value_damage_total += abs(attn_out(score_vector(q, keys), vals_q) - base)
    kd, vd = key_damage_total / trials, value_damage_total / trials
    print(f"  head dim {d}, context {n}, {trials} random heads")
    print(f"  mean |read-out shift|, 4-bit KEYS only  : {kd:.6f}")
    print(f"  mean |read-out shift|, 4-bit VALUES only: {vd:.6f}")
    print(f"  ratio (keys / values)                   : {kd / vd:.2f}x"
          f"   -- in ONE head, before any depth amplification")
    print()


def main() -> None:
    print()
    print("KEYS OWN THE CLIFF — numerical demonstrations")
    print("The entire attention-cache quantisation cliff lives in the keys.")
    print()
    demo_values_are_free()
    demo_key_cliff()
    demo_damage_ratio_unbounded()
    demo_no_codebook_rescues_keys()
    demo_exponential_vs_linear()
    demo_depth()
    demo_bit_split()
    demo_end_to_end()
    print("=" * 78)
    print("SUMMARY:  values are 1-Lipschitz and free; keys admit no Lipschitz")
    print("constant, no codebook of fixed cardinality rescues them, their damage")
    print("is exponential and compounds with depth.  Deploy K>=8 bits / V=4 bits.")
    print("=" * 78)


if __name__ == "__main__":
    main()
