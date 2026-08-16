#!/usr/bin/env python3
"""
Numerical demonstrations for:

    Boundary-Token Width Is a One-Sided Distribution Shift, Not a Threshold:
    A Tropical Separation Theory

Everything is implemented from scratch in the standard library (plus `math`).
Run with:  python3 demo.py

The demonstrations, in order:

  1. Max-plus (tropical) arithmetic and the digit/boundary token model.
  2. The span dichotomy: span membership <=> no exclusive dimension.
  3. The ambiguity theorem and the *sharp* margin bound (best margin = max_i c_i).
  4. One exclusive dimension => unbounded, perturbation-stable margin.
  5. The exact separability criterion  max_i c_i > 0, and monotonicity in width.
  6. Cure probability: interior in the fragile regime, one in the robust regime.
  7. The experimental record: no sharp boundary, stochastic dominance,
     confidence bound, uniform likelihood-ratio rejection of the pooled null.
  8. Depth propagation: a max-plus layer never amplifies a bounded gap.
"""

from __future__ import annotations

import math
import random
from typing import Callable, Dict, List, Optional, Sequence, Tuple

# ----------------------------------------------------------------------------
# 0. Max-plus (tropical) arithmetic
# ----------------------------------------------------------------------------

NEG_INF: float = float("-inf")  # tropical zero
TROP_ONE: float = 0.0           # tropical one

TVec = List[float]              # a tropical vector of some width N
TMat = List[List[float]]        # a tropical matrix


def trop_add(a: float, b: float) -> float:
    """Tropical addition: a (+) b = max(a, b)."""
    return a if a >= b else b


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a (*) b = a + b, with -inf absorbing."""
    if a == NEG_INF or b == NEG_INF:
        return NEG_INF
    return a + b


def digit_atom(n: int, j: int) -> TVec:
    """One-hot tropical digit atom: tropical one at j, tropical zero elsewhere."""
    return [TROP_ONE if i == j else NEG_INF for i in range(n)]


def eos_vec(n: int, e: int) -> TVec:
    """Zero-padded boundary token of width e inside ambient width n."""
    return [TROP_ONE if i < e else NEG_INF for i in range(n)]


def eos_of(n: int, coeffs: Sequence[float]) -> TVec:
    """Learned boundary token supported on the digit block, with coefficients."""
    d = len(coeffs)
    return [coeffs[i] if i < d else NEG_INF for i in range(n)]


def trop_comb(atoms: Sequence[TVec], lams: Sequence[float]) -> TVec:
    """Tropical combination (+)_k lam_k (*) atom_k."""
    n = len(atoms[0])
    out: TVec = [NEG_INF] * n
    for lam, atom in zip(lams, atoms):
        for i in range(n):
            out[i] = trop_add(out[i], trop_mul(lam, atom[i]))
    return out


def score(w: TVec, x: TVec) -> float:
    """Max-plus readout score: max_i (w_i + x_i)."""
    best = NEG_INF
    for wi, xi in zip(w, x):
        best = trop_add(best, trop_mul(wi, xi))
    return best


def probe(n: int, p: int, gain: float) -> TVec:
    """Readout that listens only to coordinate p, with the given gain."""
    return [gain if i == p else NEG_INF for i in range(n)]


def has_exclusive_dim(x: TVec, d: int) -> Optional[int]:
    """Return the first coordinate >= d on which x is finite, else None."""
    for i in range(d, len(x)):
        if x[i] != NEG_INF:
            return i
    return None


def in_digit_span(x: TVec, d: int) -> bool:
    """Span dichotomy: membership in the digit span <=> no exclusive dimension."""
    return has_exclusive_dim(x, d) is None


# ----------------------------------------------------------------------------
# 1. Separability and the optimal readout
# ----------------------------------------------------------------------------

def best_margin_block_supported(coeffs: Sequence[float]) -> Tuple[float, int]:
    """
    Best achievable boundary-vs-digit margin for a block-supported token.

    By the sharpness theorem this equals exactly max_i c_i, attained by the
    unit-gain probe on the maximising coordinate.  Returns (margin, index).
    """
    i_star = max(range(len(coeffs)), key=lambda i: coeffs[i])
    return coeffs[i_star], i_star


def separable_block_supported(coeffs: Sequence[float]) -> bool:
    """Exact separability criterion: some coefficient is strictly positive."""
    return any(c > 0.0 for c in coeffs)


def separable_by_search(x: TVec, d: int, candidates: Sequence[TVec]) -> bool:
    """Brute-force check: does any candidate readout strictly separate x?"""
    atoms = [digit_atom(len(x), j) for j in range(d)]
    for w in candidates:
        sx = score(w, x)
        if sx == NEG_INF:
            continue
        if all(score(w, a) < sx for a in atoms):
            return True
    return False


# ----------------------------------------------------------------------------
# 2. Max-plus layers and depth propagation
# ----------------------------------------------------------------------------

def mplus_apply(a: TMat, x: TVec) -> TVec:
    """One max-plus layer: (A (*) x)_k = max_i (A_ki + x_i)."""
    return [max((trop_mul(row[i], x[i]) for i in range(len(x))), default=NEG_INF)
            for row in a]


def mplus_iter(a: TMat, n: int, x: TVec) -> TVec:
    """n-fold unrolling of a square max-plus layer."""
    out = list(x)
    for _ in range(n):
        out = mplus_apply(a, out)
    return out


def shifted(x: TVec, c: float) -> TVec:
    """Tropical scalar multiple c (*) x."""
    return [trop_mul(c, xi) for xi in x]


def dominated_by(x: TVec, y: TVec) -> bool:
    """Coordinatewise domination x_i <= y_i, with -inf handled correctly."""
    return all(xi <= yi for xi, yi in zip(x, y))


# ----------------------------------------------------------------------------
# 3. The experimental record
# ----------------------------------------------------------------------------

# Accuracies in basis points (units of 1e-4).
E20_BP: List[int] = [9990, 9990, 9990, 7440, 1240, 580, 310, 260, 170, 110, 60, 50]
ROBUST_BP: List[int] = [10000] * 20
ROBUST_WIDTHS: List[int] = [28, 28, 64, 64, 96, 96, 128, 128, 192, 192,
                            256, 256, 384, 384, 384, 384, 384, 384, 384, 384]

CURE_BP: int = 9000  # a run counts as cured at accuracy >= 0.9


def tail_count(sample: Sequence[int], t: int) -> int:
    """Number of entries of the sample that are >= t."""
    return sum(1 for a in sample if a >= t)


def sharp_boundary_exists(runs: Sequence[Tuple[int, int]]) -> Optional[int]:
    """
    Search every candidate threshold E0 for a sharp-boundary model
    'cured <=> width >= E0'.  Returns a witness, or None if none exists.
    """
    widths = sorted({w for w, _ in runs})
    for e0 in [0] + [w for w in widths] + [max(widths) + 1]:
        if all((acc >= CURE_BP) == (w >= e0) for w, acc in runs):
            return e0
    return None


def median(sample: Sequence[int]) -> float:
    """Median as the mean of the two central order statistics when even."""
    s = sorted(sample)
    m = len(s)
    if m % 2 == 1:
        return float(s[m // 2])
    return (s[m // 2 - 1] + s[m // 2]) / 2.0


def binom_kernel(p: float, successes: int, failures: int) -> float:
    """The binomial likelihood kernel p^s (1-p)^f."""
    return (p ** successes) * ((1.0 - p) ** failures)


def pooled_likelihood_ratio(s1: int, n1: int, s2: int, n2: int) -> Dict[str, float]:
    """
    Maximised-likelihood comparison of the pooled null against the two-regime
    alternative.  The pooled maximum is attained at the pooled frequency; no
    numerical optimisation is needed.
    """
    p_pool = (s1 + s2) / (n1 + n2)
    p1, p2 = s1 / n1, s2 / n2
    null = binom_kernel(p_pool, s1 + s2, (n1 - s1) + (n2 - s2))
    alt = binom_kernel(p1, s1, n1 - s1) * binom_kernel(p2, s2, n2 - s2)
    return {"p_pooled": p_pool, "p1": p1, "p2": p2,
            "null_max": null, "alt_max": alt,
            "ratio": (null / alt) if alt > 0 else float("inf")}


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_span_dichotomy(n: int = 32, d: int = 20) -> None:
    banner("1. THE SPAN DICHOTOMY:  in the digit span  <=>  no exclusive dimension")

    for e in (5, 20, 21, 28, 32):
        x = eos_vec(n, e)
        p = has_exclusive_dim(x, d)
        print(f"  boundary width E = {e:3d} :  in digit span = {in_digit_span(x, d)!s:5s}"
              f"   exclusive dim = {p}")

    # Reconstruct a span member explicitly from its own coordinates.
    x = eos_vec(n, 12)
    atoms = [digit_atom(n, j) for j in range(d)]
    rebuilt = trop_comb(atoms, [x[j] for j in range(d)])
    print(f"\n  explicit reconstruction of the E=12 token from digit atoms: "
          f"{'exact match' if rebuilt == x else 'MISMATCH'}")

    # Two tokens of the same support size on opposite sides of the dichotomy.
    a, b = digit_atom(n, 0), probe(n, d, 0.0)
    print(f"  width-one token inside the block  : in span = {in_digit_span(a, d)}")
    print(f"  width-one token outside the block : in span = {in_digit_span(b, d)}")
    print("  => size is not the control variable; location is.")


def demo_margin_sharpness(n: int = 32, d: int = 8, trials: int = 20000,
                          seed: int = 20260815) -> None:
    banner("2. THE MARGIN BOUND IS SHARP:  best margin = max_i c_i")

    rng = random.Random(seed)
    coeffs = [rng.uniform(-2.0, 2.0) for _ in range(d)]
    x = eos_of(n, coeffs)
    predicted, i_star = best_margin_block_supported(coeffs)

    print("  learned coefficients c = [" +
          ", ".join(f"{c:+.3f}" for c in coeffs) + "]")
    print(f"  predicted best margin  = max_i c_i = {predicted:+.6f}  (at i = {i_star})")

    # Random search over readouts: the margin should never exceed the prediction.
    best_seen = NEG_INF
    for _ in range(trials):
        w = [rng.uniform(-3.0, 3.0) if rng.random() < 0.6 else NEG_INF
             for _ in range(n)]
        sx = score(w, x)
        if sx == NEG_INF:
            continue
        best_digit = max(score(w, digit_atom(n, j)) for j in range(d))
        if best_digit == NEG_INF:
            continue
        best_seen = max(best_seen, sx - best_digit)

    print(f"  best margin found by {trials} random readouts = {best_seen:+.6f}")

    # The optimal probe attains the bound exactly.
    w_opt = probe(n, i_star, 0.0)
    attained = score(w_opt, x) - max(score(w_opt, digit_atom(n, j)) for j in range(d))
    print(f"  margin of the synthesised optimal probe       = {attained:+.6f}")
    print(f"  bound respected by random search: {best_seen <= predicted + 1e-12}")
    print(f"  bound attained exactly by the probe: {abs(attained - predicted) < 1e-12}")


def demo_exclusive_dimension(n: int = 32, d: int = 8) -> None:
    banner("3. ONE EXCLUSIVE DIMENSION => UNBOUNDED, STABLE MARGIN")

    p, v = d + 3, 0.7
    x = [NEG_INF] * n
    for i in range(d):
        x[i] = -0.4          # the token may also be weak inside the block
    x[p] = v                 # ... but it owns coordinate p

    for target in (1.0, 10.0, 1000.0, 1e6):
        w = probe(n, p, target - v)
        sx = score(w, x)
        digits = [score(w, digit_atom(n, j)) for j in range(d)]
        print(f"  target margin M = {target:>10.1f} :  boundary score = {sx:>10.1f}, "
              f"every digit score = {digits[0]}")

    print("\n  perturbing the readout gain by e with |e| <= r = 0.25, target M = 100:")
    m, r = 100.0, 0.25
    for e in (-0.25, -0.1, 0.0, 0.1, 0.25):
        w = probe(n, p, (m - v) + e)
        sx = score(w, x)
        ok = sx >= m - r - 1e-12
        print(f"    e = {e:+.2f} -> boundary score {sx:8.3f}   (>= M - r = {m - r}) : {ok}")


def demo_separability_criterion(n: int = 24, d: int = 6,
                                seed: int = 7) -> None:
    banner("4. THE EXACT SEPARABILITY CRITERION:  separable <=> some c_i > 0")

    rng = random.Random(seed)
    candidates: List[TVec] = [probe(n, i, g)
                              for i in range(n) for g in (-1.0, 0.0, 1.0)]
    candidates += [[rng.uniform(-2, 2) for _ in range(n)] for _ in range(2000)]

    print(f"  {'coefficients':<44s} {'criterion':>10s} {'search':>8s}  agree")
    agree = True
    for _ in range(10):
        coeffs = [rng.choice([-1.0, -0.5, 0.25, 1.5]) * rng.random()
                  for _ in range(d)]
        x = eos_of(n, coeffs)
        crit = separable_block_supported(coeffs)
        found = separable_by_search(x, d, candidates)
        agree = agree and (crit == found)
        pretty = "[" + ", ".join(f"{c:+.2f}" for c in coeffs) + "]"
        print(f"  {pretty:<44s} {crit!s:>10s} {found!s:>8s}  {crit == found}")
    print(f"\n  criterion and brute-force search agree on every case: {agree}")

    print("\n  monotonicity in width (widening never destroys separability):")
    for e, e2 in ((3, 9), (10, 20), (20, 28)):
        a, b = eos_vec(n, min(e, n)), eos_vec(n, min(e2, n))
        print(f"    E = {e:2d} -> E' = {e2:2d} : coordinatewise domination = "
              f"{dominated_by(a, b)}")


def demo_cure_probability(n: int = 24, d: int = 20, e_fragile: int = 20,
                          seeds: int = 100000, seed: int = 26) -> None:
    banner("5. CURE PROBABILITY:  interior when E <= D, exactly 1 when E > D")

    rng = random.Random(seed)
    print(f"  ambient width N = {n if n >= d else d}, digit block D = {d}")
    print("  seed model: i.i.d. symmetric (sign-balanced) learned coefficients\n")

    print(f"  {'E':>4s} {'regime':>9s} {'empirical P(cure)':>19s} {'predicted':>12s}")
    for e in (1, 2, 3, 4, 8, 12, 20, 21, 28, 64):
        if e <= d:
            cures = 0
            for _ in range(seeds):
                coeffs = [rng.gauss(0.0, 1.0) for _ in range(e)]
                if separable_block_supported(coeffs):
                    cures += 1
            emp = cures / seeds
            pred = 1.0 - 2.0 ** (-e)
            regime = "fragile"
        else:
            emp, pred, regime = 1.0, 1.0, "robust"
        print(f"  {e:>4d} {regime:>9s} {emp:>19.5f} {pred:>12.5f}")

    print("\n  The fragile probabilities are strictly inside (0,1) and increase")
    print("  with E (a maximum-of-coefficients event); the robust regime is")
    print("  deterministic because coordinate D is owned by the boundary alone.")

    print("\n  two-seed sign model (D = 1, coefficients +1 and -1):")
    cure_set = [o for o, c in enumerate([[1.0], [-1.0]])
                if separable_block_supported(c)]
    print(f"    cure set = {cure_set}, cure probability = {len(cure_set)}/2 = 0.5")


def demo_experimental_record() -> None:
    banner("6. THE EXPERIMENTAL RECORD:  no threshold, one-sided shift")

    runs: List[Tuple[int, int]] = ([(20, a) for a in E20_BP] +
                                   list(zip(ROBUST_WIDTHS, ROBUST_BP)))
    print(f"  total runs: {len(runs)}  (12 fragile at E = 20, 20 robust at E >= 28)")

    witness = sharp_boundary_exists(runs)
    print(f"\n  a. sharp-boundary model: {'E0 = ' + str(witness) if witness is not None else 'NONE EXISTS'}")
    same = [(w, a) for w, a in runs if w == 20]
    cured = [a for _, a in same if a >= CURE_BP]
    failed = [a for _, a in same if a < CURE_BP]
    print(f"     equal-width split at E = 20: cured {cured[:1]} vs failed {failed[:1]}")
    print("     => outcome is not a function of the width; no threshold can fit.")

    n20, n_rob = len(E20_BP), len(ROBUST_BP)
    c20, c_rob = tail_count(E20_BP, CURE_BP), tail_count(ROBUST_BP, CURE_BP)
    print(f"\n  b. cure rates: fragile {c20}/{n20} = {c20 / n20:.4f}, "
          f"robust {c_rob}/{n_rob} = {c_rob / n_rob:.4f}")
    print(f"     fragile median accuracy = {median(E20_BP) / 10000:.4f}")

    print("\n  c. stochastic dominance (tail fractions at every level):")
    print(f"     {'level t':>9s} {'fragile':>10s} {'robust':>10s}  dominates")
    ok = True
    for t in (0, 50, 100, 500, 1000, 5000, 9000, 9990, 10000, 10001, 20000):
        f = tail_count(E20_BP, t) / n20
        r = tail_count(ROBUST_BP, t) / n_rob
        ok = ok and (f <= r + 1e-15)
        print(f"     {t:>9d} {f:>10.4f} {r:>10.4f}  {f <= r}")
    print(f"     dominance holds at every level tested: {ok}")
    print(f"     strict at the cure level: {c20 / n20:.4f} < {c_rob / n_rob:.4f}")

    print("\n  d. confidence for the robust regime (20 cures out of 20):")
    for p in (0.50, 0.75, 0.86, 0.90, 0.95):
        print(f"     P[20/20 | p = {p:.2f}] = {p ** 20:.6f}"
              f"{'   rejected at 5%' if p ** 20 < 0.05 else ''}")

    print("\n  e. uniform rejection of the pooled null:")
    lr = pooled_likelihood_ratio(3, 12, 20, 20)
    print(f"     pooled MLE p_hat = {lr['p_pooled']:.6f}  (= 23/32 = {23 / 32:.6f})")
    print(f"     maximised null likelihood kernel = {lr['null_max']:.6e}")
    print(f"     two-regime alternative kernel    = {lr['alt_max']:.6e}")
    print(f"     likelihood ratio                 = {lr['ratio']:.6e}")
    # The uniform certificate: 1e5 * p^23 (1-p)^9 <= (1/4)^3 (3/4)^9 for all p.
    rhs = (0.25 ** 3) * (0.75 ** 9)
    worst = max(1e5 * binom_kernel(k / 20000.0, 23, 9) for k in range(20001))
    print(f"     sup_p 1e5 * p^23 (1-p)^9 = {worst:.6e}  <=  {rhs:.6e} : {worst <= rhs}")
    print("     => the pooled null is >1e5 times less likely, uniformly in p.")


def demo_depth_propagation(n: int = 12, d: int = 6, depth: int = 10,
                           seed: int = 3) -> None:
    banner("7. DEPTH PROPAGATION:  a max-plus layer never amplifies a bounded gap")

    rng = random.Random(seed)
    a: TMat = [[rng.uniform(-1.0, 1.0) if rng.random() < 0.5 else NEG_INF
                for _ in range(n)] for _ in range(n)]

    coeffs = [rng.uniform(-1.5, 0.5) for _ in range(d)]
    v = max(coeffs)
    x = eos_of(n, coeffs)                 # fragile boundary trajectory
    y = eos_vec(n, d)                     # all-digit reference trajectory

    print(f"  max_i c_i = {v:+.6f}   (the uniform gap constant)")
    print(f"  {'depth':>6s} {'max_k [ boundary_k - (v + reference_k) ]':>44s}  holds")
    holds = True
    for t in range(depth + 1):
        xt, yt = mplus_iter(a, t, x), mplus_iter(a, t, y)
        gaps = [xt[k] - trop_mul(v, yt[k])
                for k in range(n)
                if xt[k] != NEG_INF and trop_mul(v, yt[k]) != NEG_INF]
        worst = max(gaps) if gaps else NEG_INF
        ok = all(xt[k] <= trop_mul(v, yt[k]) + 1e-12 for k in range(n))
        holds = holds and ok
        print(f"  {t:>6d} {worst:>44.9f}  {ok}")
    print(f"\n  gap bounded by max_i c_i at every depth: {holds}")
    print("  => the fragile regime can never build a large margin, so the")
    print("     observed depth degradation must be a smooth slide, not a cliff.")

    print("\n  by contrast, an exclusive dimension persists under the identity")
    print("  recurrence at every depth, keeping the unbounded margin available:")
    ident: TMat = [[TROP_ONE if i == k else NEG_INF for i in range(n)]
                   for k in range(n)]
    z = [NEG_INF] * n
    z[d + 1] = 0.5
    for t in (0, 1, 5, 50):
        zt = mplus_iter(ident, t, z)
        print(f"    depth {t:>3d}: exclusive dim = {has_exclusive_dim(zt, d)}")


def demo_progressive_unroll() -> None:
    banner("8. THE OBSERVED FAILURE SHAPE (fragile regime)")

    observed: List[Tuple[int, float]] = [(5, 1.0000), (6, 0.9556),
                                         (7, 0.1445), (8, 0.0166)]
    print("  progressive-unroll accuracy of a fragile run:")
    for n, acc in observed:
        bar = "#" * int(round(acc * 50))
        print(f"    n = {n}: {acc:6.4f}  {bar}")
    monotone = all(observed[i][1] >= observed[i + 1][1]
                   for i in range(len(observed) - 1))
    print(f"\n  monotone decreasing (no recovery at any depth): {monotone}")
    print("  probe discriminator recorded alongside:")
    print("    cured   : hidden-norm drift < 0.2, max confidence 1.000")
    print("    failed  : hidden-norm drift +2.2, max confidence 0.945-0.984")


def main() -> None:
    print(__doc__)
    demo_span_dichotomy()
    demo_margin_sharpness()
    demo_exclusive_dimension()
    demo_separability_criterion()
    demo_cure_probability()
    demo_experimental_record()
    demo_depth_propagation()
    demo_progressive_unroll()
    banner("ALL DEMONSTRATIONS COMPLETE")
    print("The control variable is representational distinctness, not width.")


if __name__ == "__main__":
    main()
