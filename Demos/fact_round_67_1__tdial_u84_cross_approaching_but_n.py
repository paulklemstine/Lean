"""
Numerical demonstrations for
"Approaching but Not Crossed: Pooling Geometry, a Kendall-Metric Crossing Budget,
 and the Resolution Wall for a Rank-Correlation Dial".

Self-contained: standard library only (fractions, math, random, itertools).
Every number printed here corresponds to a theorem in the paper.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from fractions import Fraction
from itertools import combinations
from typing import Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Recorded data (exact rationals)
# ----------------------------------------------------------------------------

POOLED84: Fraction = Fraction(558, 1000)
CI_LO84: Fraction = Fraction(536, 1000)
CI_HI84: Fraction = Fraction(581, 1000)
SEEDS: Tuple[Fraction, Fraction, Fraction] = (
    Fraction(572, 1000),
    Fraction(578, 1000),
    Fraction(522, 1000),
)
BAND_FLOOR: Fraction = Fraction(55, 100)
MARGIN84: Fraction = POOLED84 - BAND_FLOOR

LADDER: List[Tuple[int, Fraction]] = [
    (44, Fraction(780, 1000)),
    (52, Fraction(705, 1000)),
    (64, Fraction(648, 1000)),
    (72, Fraction(605, 1000)),
    (76, Fraction(608, 1000)),
    (84, Fraction(558, 1000)),
    (92, Fraction(563, 1000)),
    (96, Fraction(5739, 10000)),
]


def rule(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


# ----------------------------------------------------------------------------
# 1. Pooling geometry
# ----------------------------------------------------------------------------

def pooled(weights: Sequence[Fraction], values: Sequence[Fraction]) -> Fraction:
    """Convex aggregate <w, x>."""
    assert len(weights) == len(values)
    assert all(w >= 0 for w in weights)
    assert sum(weights) == 1
    return sum(w * x for w, x in zip(weights, values))


def pooling_is_lipschitz(
    weights: Sequence[Fraction],
    x: Sequence[Fraction],
    y: Sequence[Fraction],
) -> Tuple[Fraction, Fraction, bool]:
    """Return (sup-distance on components, distance of aggregates, bound holds)."""
    d = max(abs(a - b) for a, b in zip(x, y))
    agg = abs(pooled(weights, x) - pooled(weights, y))
    return d, agg, agg <= d


def demo_pooling() -> None:
    rule("1. POOLING GEOMETRY  -- a pooled cliff is a component cliff")
    w = (Fraction(1, 3),) * 3
    p = pooled(w, SEEDS)
    print(f"  replicates          : {[float(s) for s in SEEDS]}")
    print(f"  equal-weight mean   : {p} = {float(p):.6f}")
    print(f"  pooled reading      : {float(POOLED84):.6f}  "
          f"(|mean - pooled| = {float(abs(p - POOLED84)):.6f} <= 0.001)")
    print(f"  trapped in range    : {min(SEEDS)} <= pooled <= {max(SEEDS)} -> "
          f"{min(SEEDS) <= POOLED84 <= max(SEEDS)}")
    below = [s for s in SEEDS if s < BAND_FLOOR]
    print(f"  replicates below the floor {float(BAND_FLOOR)}: "
          f"{[float(s) for s in below]}  ({len(below)} of 3)")
    print(f"  margin to floor     : {MARGIN84} = {float(MARGIN84):.4f}  -> NOT crossed")
    print(f"  CI straddles floor  : {float(CI_LO84)} < {float(BAND_FLOOR)} < {float(CI_HI84)}"
          f" -> {CI_LO84 < BAND_FLOOR < CI_HI84}")

    # Random Lipschitz check.
    rng = random.Random(20261190)
    worst = Fraction(0)
    for _ in range(20000):
        x = [Fraction(rng.randrange(0, 10 ** 6), 10 ** 6) for _ in range(3)]
        y = [Fraction(rng.randrange(0, 10 ** 6), 10 ** 6) for _ in range(3)]
        d, agg, ok = pooling_is_lipschitz(w, x, y)
        assert ok, "1-Lipschitz property violated"
        if d > 0:
            worst = max(worst, agg / d)
    print(f"  20000 random pairs  : max |Δpooled| / max_i |Δx_i| = {float(worst):.6f} <= 1")


# ----------------------------------------------------------------------------
# 2. Replication fragility and dispersion
# ----------------------------------------------------------------------------

def fourth_replicate_threshold(
    recorded: Sequence[Fraction], floor: Fraction
) -> Fraction:
    """Largest v (exclusive) such that adding one replicate at v crosses the floor."""
    k = len(recorded)
    return (k + 1) * floor - sum(recorded)


def variance(values: Sequence[Fraction]) -> Fraction:
    n = len(values)
    mu = sum(values) / n
    return sum((v - mu) ** 2 for v in values) / n


def bhatia_davis_ceiling(values: Sequence[Fraction]) -> Fraction:
    mu = sum(values) / len(values)
    return (max(values) - mu) * (mu - min(values))


def demo_replication() -> None:
    rule("2. REPLICATION FRAGILITY  -- the non-crossing is one replication deep")
    thr = fourth_replicate_threshold(SEEDS, BAND_FLOOR)
    print(f"  fourth-replicate threshold : v < {thr} = {float(thr):.4f}")
    for label, v in (("recorded minimum", min(SEEDS)), ("recorded maximum", max(SEEDS))):
        new_mean = (sum(SEEDS) + v) / 4
        verdict = "CROSSES" if new_mean < BAND_FLOOR else "survives"
        print(f"    replicate at {label} {float(v):.3f}: pooled -> "
              f"{float(new_mean):.6f}  ({verdict})")

    var = variance(SEEDS)
    ceil_ = bhatia_davis_ceiling(SEEDS)
    print(f"  replicate variance         : {var} = {float(var):.6e}")
    print(f"  Bhatia-Davis ceiling       : {ceil_} = {float(ceil_):.6e}")
    print(f"  ratio (1 = extremal)       : {float(var / ceil_):.4f}")
    sd = math.sqrt(float(var))
    print(f"  s.d. {sd:.5f} vs 3 x margin {3 * float(MARGIN84):.5f} -> "
          f"s.d. exceeds 3x margin: {var > 9 * MARGIN84 ** 2}")


# ----------------------------------------------------------------------------
# 3. Spearman on rankings: transposition identity, step bound, budgets
# ----------------------------------------------------------------------------

def displacement_sum(sigma: Sequence[int]) -> int:
    """D(sigma) = sum_k (sigma(k) - k)^2."""
    return sum((s - k) ** 2 for k, s in enumerate(sigma))


def l1_displacement(sigma: Sequence[int]) -> int:
    """A(sigma) = sum_k |sigma(k) - k|."""
    return sum(abs(s - k) for k, s in enumerate(sigma))


def spearman(sigma: Sequence[int]) -> Fraction:
    """rho = 1 - 6 D / (n (n^2 - 1)), exact."""
    n = len(sigma)
    assert n >= 2
    return Fraction(1) - Fraction(6 * displacement_sum(sigma), n * (n * n - 1))


def transpose_at(sigma: Sequence[int], i: int, j: int) -> List[int]:
    out = list(sigma)
    out[i], out[j] = out[j], out[i]
    return out


def crossing_budget_linear(n: int, margin: Fraction) -> int:
    """Theorem: descending a margin m costs >= m n(n+1)/12 adjacent swaps."""
    b = margin * n * (n + 1) / 12
    return math.ceil(b)


def crossing_budget_quadratic(n: int, target: Fraction) -> int:
    """Theorem: rho >= 1 - 24 K^2/(n(n^2-1)); invert for K given a target rho."""
    drop = Fraction(1) - target
    k_sq = drop * n * (n * n - 1) / 24
    return math.ceil(math.sqrt(float(k_sq)))


def demo_transposition_identity() -> None:
    rule("3a. THE EXACT TRANSPOSITION IDENTITY  (Delta D = 2 (j-i)(sigma_j - sigma_i))")
    rng = random.Random(20261191)
    n = 12
    max_err = 0
    for _ in range(5000):
        sigma = list(range(n))
        rng.shuffle(sigma)
        i, j = sorted(rng.sample(range(n), 2))
        lhs = displacement_sum(transpose_at(sigma, i, j)) - displacement_sum(sigma)
        rhs = 2 * (j - i) * (sigma[j] - sigma[i])
        max_err = max(max_err, abs(lhs - rhs))
    print(f"  5000 random rankings of {n} items: max |LHS - RHS| = {max_err}  (identity, exact)")

    print("\n  Spearman transposition law and the adjacent-step bound:")
    for n in (8, 16, 64, 256, 4096):
        bound = Fraction(12, n * (n + 1))
        # Extremal vector: value n-1 at position 0, value 0 at position 1, identity elsewhere.
        phi = [n - 1, 0] + list(range(2, n))
        attained = spearman(transpose_at(phi, 0, 1)) - spearman(phi)
        print(f"    n = {n:5d}: bound 12/(n(n+1)) = {float(bound):.3e}   "
              f"attained by the extremal vector = {float(attained):.3e}  "
              f"{'(sharp)' if attained == bound else '(MISMATCH)'}")


def demo_endpoints_and_sorting() -> None:
    rule("3b. THE TWO ENDS OF THE SCALE, AND A SORTING LOWER BOUND")
    for n in (2, 5, 10, 64):
        identity = list(range(n))
        reversal = list(range(n - 1, -1, -1))
        print(f"    n = {n:3d}: rho(identity) = {spearman(identity)}   "
              f"rho(reversal) = {spearman(reversal)}   "
              f"D(reversal) = {displacement_sum(reversal)} = n(n^2-1)/3 = "
              f"{n * (n * n - 1) // 3}")
    print("\n  Sorting lower bound (rho drops by 2, so K >= 2 n(n+1)/12 = n(n+1)/6):")
    for n in (10, 100, 4096):
        print(f"    n = {n:5d}: at least {crossing_budget_linear(n, Fraction(2)):>12,d} "
              f"adjacent swaps to reverse  (n(n+1)/6 = {n * (n + 1) // 6:,d})")


def demo_budgets() -> None:
    rule("3c. THE CROSSING BUDGETS AT THE RECORDED NUMBERS")
    n = 4096
    margin_budget = crossing_budget_linear(n, MARGIN84)
    erosion_linear = crossing_budget_linear(n, Fraction(1) - POOLED84)
    erosion_quad = crossing_budget_quadratic(n, POOLED84)
    print(f"  n = {n} paired ranks")
    print(f"    margin {float(MARGIN84):.3f} -> below floor : K >= {margin_budget:,d}")
    print(f"    identity (rho=1) -> {float(POOLED84):.3f}, linear bound  : K >= {erosion_linear:,d}")
    print(f"    identity (rho=1) -> {float(POOLED84):.3f}, quadratic bnd : K >= {erosion_quad:,d}")
    print(f"    linear dominates at this n     : {erosion_linear > erosion_quad}")
    print(f"    margin / erosion distance      : "
          f"{100 * margin_budget / erosion_linear:.2f} %")
    print(f"    margin as a fraction of the full [-1,1] scale : "
          f"{MARGIN84 / 2} = {float(MARGIN84 / 2) * 100:.2f} %")

    print("\n  Scaling of the margin budget (Omega(n^2)):")
    for m in (64, 256, 1024, 4096, 16384):
        print(f"    n = {m:6d}: K >= {crossing_budget_linear(m, MARGIN84):>12,d}")

    print("\n  Crossover of the two budgets at n = 4096, as a function of the drop eps")
    print("  from perfect alignment (theory: the quadratic bound wins for eps < 6/n):")
    for eps in (Fraction(1, 10 ** 5), Fraction(1, 10 ** 4), Fraction(1, 1000),
                Fraction(6, n), Fraction(1, 100), Fraction(442, 1000)):
        lin = crossing_budget_linear(n, eps)
        quad = crossing_budget_quadratic(n, Fraction(1) - eps)
        winner = "linear" if lin >= quad else "quadratic"
        print(f"    eps = {float(eps):.6f}: linear {lin:>10,d}   quadratic {quad:>10,d}   "
              f"-> {winner}")
    print(f"    crossover at eps = 6/n = {6 / n:.6f}, i.e. K ~ n/2 = {n // 2}")


def demo_kendall_descent() -> None:
    rule("3d. AN EXPLICIT KENDALL DESCENT  (greedy adjacent swaps, budgets verified)")
    n = 60
    target = POOLED84
    sigma = list(range(n))
    swaps = 0
    d = 0
    denom = n * (n * n - 1)
    while Fraction(1) - Fraction(6 * d, denom) > target:
        # Choose the adjacent swap maximising the increase of D; incremental update.
        best_i, best_gain = -1, None
        for i in range(n - 1):
            gain = 2 * (sigma[i + 1] - sigma[i])
            if best_gain is None or gain > best_gain:
                best_i, best_gain = i, gain
        if best_gain is None or best_gain <= 0:
            break
        sigma[best_i], sigma[best_i + 1] = sigma[best_i + 1], sigma[best_i]
        d += best_gain
        swaps += 1
    assert d == displacement_sum(sigma), "incremental update disagrees with recomputation"
    rho = spearman(sigma)
    lin = crossing_budget_linear(n, Fraction(1) - rho)
    quad = crossing_budget_quadratic(n, rho)
    print(f"  n = {n}: greedy descent reached rho = {float(rho):.6f} in {swaps} adjacent swaps")
    print(f"    linear budget for that drop    : K >= {lin}   (respected: {swaps >= lin})")
    print(f"    quadratic budget for that drop : K >= {quad}  (respected: {swaps >= quad})")
    print(f"    incremental D update matches recomputation: True")


# ----------------------------------------------------------------------------
# 4. Monotone noise floor and local trend
# ----------------------------------------------------------------------------

def monotone_noise_floor(points: Sequence[Tuple[int, Fraction]]) -> Fraction:
    """Largest (d_j - d_i)/2 over i < j with d_j > d_i: the unavoidable sup-error."""
    best = Fraction(0)
    for (xi, yi), (xj, yj) in combinations(points, 2):
        if xi < xj and yj > yi:
            best = max(best, (yj - yi) / 2)
    return best


def ols_slope(xs: Sequence[Fraction], ys: Sequence[Fraction]) -> Fraction:
    n = len(xs)
    xbar = sum(xs) / n
    ybar = sum(ys) / n
    num = sum((x - xbar) * (y - ybar) for x, y in zip(xs, ys))
    den = sum((x - xbar) ** 2 for x in xs)
    return num / den


def demo_monotone() -> None:
    rule("4. NON-MONOTONICITY: THE LADDER REBOUNDS")
    print("  bitlen  rho")
    for b, r in LADDER:
        mark = "   <-- recorded rung" if b == 84 else ""
        print(f"   {b:3d}   {float(r):.4f}{mark}")
    tail = [(b, r) for b, r in LADDER if b >= 84]
    eta = monotone_noise_floor(tail)
    print(f"\n  rebound 84 -> 96                 : {float(LADDER[7][1] - LADDER[5][1]):.4f}")
    print(f"  monotone-fit noise floor eta     : {eta} = {float(eta):.5f}")
    print(f"  eta as a fraction of the margin  : {eta / MARGIN84} = "
          f"{float(eta / MARGIN84) * 100:.3f} %")
    print(f"  eta < margin (question invisible): {eta < MARGIN84}")

    xs = [Fraction(b) for b, _ in tail]
    ys = [r for _, r in tail]
    slope = ols_slope(xs, ys)
    print(f"\n  local least-squares slope        : {slope} = {float(slope):+.6f} per bit")
    print(f"  slope points AWAY from the floor : {slope > 0}")
    pred100 = ys[-1] + 4 * slope
    print(f"  extrapolated rung at bitlen 100  : {float(pred100):.4f} > floor "
          f"{float(BAND_FLOOR)}: {pred100 > BAND_FLOOR}")


# ----------------------------------------------------------------------------
# 5. The resolution wall
# ----------------------------------------------------------------------------

def resolution_factor(half_width: Fraction, target: Fraction) -> Fraction:
    """Sample-size multiplier (h0/target)^2 under a c/sqrt(m) half-width law."""
    return (half_width / target) ** 2


def demo_resolution() -> None:
    rule("5. THE RESOLUTION WALL")
    h0 = (CI_HI84 - CI_LO84) / 2
    factor = resolution_factor(h0, MARGIN84)
    print(f"  recorded CI            : [{float(CI_LO84)}, {float(CI_HI84)}]")
    print(f"  half-width h0          : {h0} = {float(h0):.4f}")
    print(f"  margin                 : {float(MARGIN84):.4f}")
    print(f"  h0 / margin            : {float(h0 / MARGIN84):.4f}")
    print(f"  required sample factor : {factor} = {float(factor):.3f} x")
    print("\n  Half-width achieved as the sample grows (c/sqrt(m) law, m0 = 1 unit):")
    for mult in (1, 2, 4, 7.91, 16, 64):
        hw = float(h0) / math.sqrt(mult)
        flag = "resolves" if hw <= float(MARGIN84) else "too coarse"
        print(f"    m = {mult:6.2f} m0 : half-width {hw:.5f}   ({flag})")
    print("\n  Hard obstruction: if the point estimate is at or below the bar, then for")
    print("  every half-width w > 0 the lower endpoint is below the bar -- no sample")
    print("  size can produce an interval strictly above it.")
    for w in (1e-2, 1e-4, 1e-8):
        centre = float(BAND_FLOOR)
        print(f"    centre {centre}, w = {w:.0e} -> lower endpoint {centre - w:.8f} "
              f"< bar: {centre - w < centre}")


# ----------------------------------------------------------------------------
# 6. Crossing dichotomy and geometric indistinguishability
# ----------------------------------------------------------------------------

def fade(L: Fraction, a: Fraction, lam: Fraction, j: int) -> Fraction:
    return L + a * lam ** j


def first_crossing(L: Fraction, a: Fraction, lam: Fraction, floor: Fraction,
                   horizon: int = 100000) -> int | None:
    for j in range(horizon):
        if fade(L, a, lam, j) < floor:
            return j
    return None


def max_alignment(a: float, b: float) -> float:
    """Largest possible corr(u,v) given corr(u,w) = a and corr(v,w) = b."""
    return a * b + math.sqrt((1 - a * a) * (1 - b * b))


def demo_dichotomy() -> None:
    rule("6. THE CROSSING DICHOTOMY AND GEOMETRIC INDISTINGUISHABILITY")
    rungs = [Fraction(558, 1000), Fraction(563, 1000), Fraction(5739, 10000)]
    models = {
        "A (never crosses)": (Fraction(5659, 10000), Fraction(1, 10 ** 6), Fraction(1, 2)),
        "B (crosses)":       (Fraction(549, 1000), Fraction(17, 1000), Fraction(499, 500)),
    }
    for name, (L, a, lam) in models.items():
        vals = [fade(L, a, lam, j) for j in range(3)]
        errs = [abs(v - r) for v, r in zip(vals, rungs)]
        cross = first_crossing(L, a, lam, BAND_FLOOR)
        print(f"  Model {name}")
        print(f"    L = {float(L)}  a = {float(a)}  lambda = {float(lam)}")
        print(f"    fitted rungs   : {[f'{float(v):.6f}' for v in vals]}")
        print(f"    max |error|    : {float(max(errs)):.6f}  "
              f"(<= margin {float(MARGIN84)}: {max(errs) <= MARGIN84})")
        print(f"    limit vs floor : L {'<' if L < BAND_FLOOR else '>='} {float(BAND_FLOOR)}")
        print(f"    first crossing : "
              f"{'never (within horizon)' if cross is None else f'rung index {cross}'}")

    print("\n  Both models fit the recorded rungs to within the margin, yet they disagree")
    print("  about the eventual crossing: the ladder does not pin the limit L.")

    a_val, b_val = float(POOLED84), float(BAND_FLOOR)
    align = max_alignment(a_val, b_val)
    angle = math.degrees(math.acos(min(1.0, align)))
    print(f"\n  Geometric indistinguishability:")
    print(f"    corr(u, w) = {a_val}   (uncrossed)   corr(v, w) = {b_val}  (at the floor)")
    print(f"    maximal corr(u, v) = {align:.8f}  (>= 0.9999: {align >= 0.9999})")
    print(f"    separating angle   = {angle:.4f} degrees")

    # Explicit planar realisation.
    th_u, th_v = math.acos(a_val), math.acos(b_val)
    w_vec = (1.0, 0.0)
    u_vec = (math.cos(th_u), math.sin(th_u))
    v_vec = (math.cos(th_v), math.sin(th_v))

    def cosine(p: Tuple[float, float], q: Tuple[float, float]) -> float:
        dot = p[0] * q[0] + p[1] * q[1]
        return dot / (math.hypot(*p) * math.hypot(*q))

    print(f"    explicit realisation: w = {w_vec}, u = ({u_vec[0]:.6f}, {u_vec[1]:.6f}), "
          f"v = ({v_vec[0]:.6f}, {v_vec[1]:.6f})")
    print(f"      corr(u,w) = {cosine(u_vec, w_vec):.6f}   "
          f"corr(v,w) = {cosine(v_vec, w_vec):.6f}   "
          f"corr(u,v) = {cosine(u_vec, v_vec):.8f}")


# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------

def main() -> None:
    print("APPROACHING BUT NOT CROSSED -- numerical demonstrations")
    print(f"pooled reading {float(POOLED84)}, floor {float(BAND_FLOOR)}, "
          f"margin {float(MARGIN84)}")
    demo_pooling()
    demo_replication()
    demo_transposition_identity()
    demo_endpoints_and_sorting()
    demo_budgets()
    demo_kendall_descent()
    demo_monotone()
    demo_resolution()
    demo_dichotomy()
    print("\nAll checks passed.\n")


if __name__ == "__main__":
    main()
