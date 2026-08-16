"""
Numerical demonstrations for
"The Geometry of Attention Sparsification: Concentration Floors, Tail Ceilings,
and the Concavity of the Selection Gap".

Self-contained: standard library only (math, random, itertools, fractions).

An attention row is a probability vector p on n keys.  We study

    M(k) = max_{|S| <= k} sum_{i in S} p_i        (top-k captured mass)
    G(k) = M(k) - k/n                             (selection gap)
    eff  = 1 / sum_i p_i^2                        (participation ratio)

and verify, numerically, each theorem of the paper:

  1. concentration floor              k >= tau^2 * eff
  2. sharpness of the square          spike profile refutes k >= tau * eff
  3. power-tail ceiling               M(k) >= 1 - c/(alpha-1) * k^(1-alpha)
  4. exact random control             E[mass of random k-set] = k/n
  5. concavity by exchange            M(k+2) + M(k) <= 2 M(k+1)
  6. unimodality of the gap           min(G(i), G(m)) <= G(j) for i <= j <= m
  7. peak location and height         argmax G = |{i : p_i > 1/n}|, max G = TV(p, unif)
  8. Lipschitz accuracy ceiling       g(M(k)) - g(k/n) <= L * TV
  9. knee brackets and grid resolution
 10. depth law arithmetic and speedup
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Iterable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Core quantities
# ---------------------------------------------------------------------------


def normalize(w: Sequence[float]) -> List[float]:
    """Turn a nonnegative weight vector into an attention row (sums to 1)."""
    total = float(sum(w))
    if total <= 0.0:
        raise ValueError("weights must have positive total")
    return [float(x) / total for x in w]


def mass_curve(p: Sequence[float]) -> List[float]:
    """M(0), M(1), ..., M(n): prefix sums of the descending sort.  O(n log n)."""
    srt = sorted(p, reverse=True)
    out = [0.0]
    acc = 0.0
    for x in srt:
        acc += x
        out.append(acc)
    return out


def best_mass(p: Sequence[float], k: int) -> float:
    """Mass captured by the best width-k selection."""
    return mass_curve(p)[min(k, len(p))]


def selection_gap_curve(p: Sequence[float]) -> List[float]:
    """G(k) = M(k) - k/n for k = 0..n."""
    n = len(p)
    return [m - k / n for k, m in enumerate(mass_curve(p))]


def eff_support(p: Sequence[float]) -> float:
    """Participation ratio eff(p) = 1 / sum_i p_i^2."""
    return 1.0 / sum(x * x for x in p)


def tv_to_uniform(p: Sequence[float]) -> float:
    """Total-variation distance between p and the uniform row."""
    n = len(p)
    return 0.5 * sum(abs(x - 1.0 / n) for x in p)


def excess_mass(p: Sequence[float]) -> float:
    """sum_i (p_i - 1/n)^+ ; equals tv_to_uniform(p)."""
    n = len(p)
    return sum(max(x - 1.0 / n, 0.0) for x in p)


def above_average_count(p: Sequence[float]) -> int:
    """|{i : p_i > 1/n}| -- the peak width of the selection gap."""
    n = len(p)
    return sum(1 for x in p if x > 1.0 / n)


# ---------------------------------------------------------------------------
# Profile families
# ---------------------------------------------------------------------------


def uniform_row(n: int) -> List[float]:
    return [1.0 / n] * n


def spike_row() -> List[float]:
    """The five-key spike profile (1/2, 1/8, 1/8, 1/8, 1/8)."""
    return [0.5, 0.125, 0.125, 0.125, 0.125]


def power_row(n: int, alpha: float) -> List[float]:
    """Normalised power-law profile p_(i) proportional to (i+1)^(-alpha)."""
    return normalize([(i + 1.0) ** (-alpha) for i in range(n)])


def mixture_row(n: int, head: int, head_share: float, seed: int = 0) -> List[float]:
    """`head` keys share `head_share` of the mass; the rest is noisy background."""
    rng = random.Random(seed)
    w = [0.0] * n
    for i in range(head):
        w[i] = head_share / head * (0.8 + 0.4 * rng.random())
    for i in range(head, n):
        w[i] = (1.0 - head_share) / (n - head) * (0.5 + rng.random())
    return normalize(w)


# ---------------------------------------------------------------------------
# 1-2. Concentration floor and its sharpness
# ---------------------------------------------------------------------------


def concentration_floor(tau: float, p: Sequence[float]) -> float:
    """Theorem: any k with M(k) >= tau obeys k >= tau^2 * eff(p)."""
    return tau * tau * eff_support(p)


def demo_concentration() -> None:
    print("=" * 74)
    print("1. CONCENTRATION FLOOR   k >= tau^2 * eff")
    print("=" * 74)
    for name, p in [
        ("uniform(512)", uniform_row(512)),
        ("power alpha=1.1", power_row(512, 1.1)),
        ("power alpha=2.0", power_row(512, 2.0)),
        ("mixture head=180", mixture_row(512, 180, 0.90)),
    ]:
        e = eff_support(p)
        tau = 0.92
        floor = concentration_floor(tau, p)
        curve = mass_curve(p)
        true_k = next(k for k in range(len(p) + 1) if curve[k] >= tau)
        print(
            f"  {name:>18}:  eff={e:8.2f}   floor(tau=0.92)={floor:8.2f}"
            f"   true minimal k={true_k:4d}   OK={true_k >= floor - 1e-9}"
        )

    print("\n  Measured cell (reported eff = 216.92, tau = 0.92):")
    print(f"    floor = 0.92^2 * 216.92 = {0.92 ** 2 * 216.92:.3f}  >  183"
          "   -> no width below 184 can reach mass 0.92")

    print("\n2. SHARPNESS: the square in tau^2 cannot be removed")
    q = spike_row()
    e = eff_support(q)
    print(f"    spike profile {q}")
    print(f"    eff = {e:.4f} = 16/5,   M(1) = {best_mass(q, 1):.4f} = 1/2")
    print(f"    proved floor  tau^2*eff = {0.5 ** 2 * e:.4f} <= 1   (holds)")
    print(f"    false 'floor' tau  *eff = {0.5 * e:.4f}  > 1   (would be violated)")
    print()


# ---------------------------------------------------------------------------
# 3. Power-tail ceiling
# ---------------------------------------------------------------------------


def power_tail_mass_bound(c: float, alpha: float, k: int) -> float:
    """Guaranteed mass 1 - c/(alpha-1) * k^(1-alpha) under p_(i) <= c (i+1)^(-alpha)."""
    return 1.0 - c / (alpha - 1.0) * k ** (1.0 - alpha)


def power_tail_knee_ceiling(c: float, alpha: float, tau: float) -> float:
    """Sufficient width: (c / ((alpha-1)(1-tau)))^(1/(alpha-1))."""
    return (c / ((alpha - 1.0) * (1.0 - tau))) ** (1.0 / (alpha - 1.0))


def demo_tail_ceiling() -> None:
    print("=" * 74)
    print("3. POWER-TAIL CEILING   M(k) >= 1 - c/(alpha-1) k^(1-alpha)")
    print("=" * 74)
    cases = [(20.0, 2.0), (0.6, 1.5), (2.0, 1.25)]
    for c, alpha in cases:
        bound = power_tail_mass_bound(c, alpha, 256)
        ceil = power_tail_knee_ceiling(c, alpha, 0.92)
        print(f"  c={c:5.2f}, alpha={alpha:4.2f}:  certified M(256) >= {bound:6.4f}"
              f"    knee ceiling for tau=0.92: k* <= {ceil:9.2f}")

    print("\n  Verification against genuine power-law rows (n = 512):")
    for alpha in (1.5, 2.0, 3.0):
        p = power_row(512, alpha)
        # a valid majorant constant for this normalised row
        c = max(p[i] * (i + 1.0) ** alpha for i in range(512))
        bound = power_tail_mass_bound(c, alpha, 256)
        actual = best_mass(p, 256)
        print(f"    alpha={alpha:4.2f}:  fitted c={c:7.4f}   bound={bound:7.4f}"
              f"   actual M(256)={actual:7.4f}   valid={actual >= bound - 1e-12}")
    print()


# ---------------------------------------------------------------------------
# 4. Exact random control
# ---------------------------------------------------------------------------


def exact_expected_random_mass(p: Sequence[float], k: int) -> float:
    """Brute-force average of captured mass over ALL k-subsets (small n only)."""
    n = len(p)
    idx = range(n)
    total = 0.0
    count = 0
    for S in itertools.combinations(idx, k):
        total += sum(p[i] for i in S)
        count += 1
    return total / count


def demo_random_control() -> None:
    print("=" * 74)
    print("4. RANDOM CONTROL:  E[mass of a uniformly random k-set] = k/n exactly")
    print("=" * 74)
    p = normalize([7.0, 3.0, 1.0, 0.4, 0.05, 0.02, 0.9, 2.2])
    n = len(p)
    print(f"  row (n={n}): " + ", ".join(f"{x:.4f}" for x in p))
    for k in range(1, n + 1):
        emp = exact_expected_random_mass(p, k)
        print(f"    k={k}:  exact average over C({n},{k}) subsets = {emp:.12f}"
              f"   k/n = {k / n:.12f}   match={abs(emp - k / n) < 1e-12}")

    print("\n  Monte-Carlo at the measured cell (n=512, k=256, 20000 draws):")
    row = mixture_row(512, 180, 0.90)
    rng = random.Random(43)
    draws = 20000
    acc = 0.0
    for _ in range(draws):
        S = rng.sample(range(512), 256)
        acc += sum(row[i] for i in S)
    print(f"    empirical mean = {acc / draws:.6f}   theory k/n = {256 / 512:.6f}")
    print(f"    top-256 mass   = {best_mass(row, 256):.6f}"
          f"   mass gap = {best_mass(row, 256) - 0.5:.6f}")
    print()


# ---------------------------------------------------------------------------
# 5-7. Concavity, unimodality, peak
# ---------------------------------------------------------------------------


def is_concave_sequence(f: Sequence[float], tol: float = 1e-12) -> bool:
    return all(f[k + 2] + f[k] <= 2.0 * f[k + 1] + tol for k in range(len(f) - 2))


def is_unimodal(f: Sequence[float], tol: float = 1e-12) -> bool:
    """min(f[i], f[m]) <= f[j] for all i <= j <= m (checked exhaustively)."""
    n = len(f)
    for i in range(n):
        for j in range(i, n):
            for m in range(j, n):
                if min(f[i], f[m]) > f[j] + tol:
                    return False
    return True


def chord_extrapolation(f_at_i: float, f_at_j: float, i: int, j: int, t: int) -> float:
    """Concavity cap on f(j+t) given f(i), f(j) with j - i = t."""
    if j - i != t:
        raise ValueError("chord comparison needs equal step lengths")
    return f_at_j + (f_at_j - f_at_i)


def demo_shape() -> None:
    print("=" * 74)
    print("5-7. CONCAVITY, UNIMODALITY, PEAK LOCATION")
    print("=" * 74)
    rows = {
        "uniform(64)": uniform_row(64),
        "power alpha=1.5 (64)": power_row(64, 1.5),
        "spike (5)": spike_row(),
        "mixture head=20 (64)": mixture_row(64, 20, 0.85, seed=7),
    }
    for name, p in rows.items():
        M = mass_curve(p)
        G = selection_gap_curve(p)
        peak_k = max(range(len(G)), key=lambda k: G[k])
        print(f"  {name:>22}: M concave={is_concave_sequence(M)}"
              f"  G concave={is_concave_sequence(G)}"
              f"  G unimodal={is_unimodal(G)}")
        print(f"      argmax G = {peak_k:3d}   |above-average keys| = "
              f"{above_average_count(p):3d}   max G = {G[peak_k]:.6f}"
              f"   TV = {tv_to_uniform(p):.6f}   excess = {excess_mass(p):.6f}")
        print(f"      G(0) = {G[0]:.1e}   G(n) = {G[-1]:.1e}   min G = {min(G):.1e}")

    print("\n  Chord extrapolation of the measured accuracy gaps:")
    cap = chord_extrapolation(2.6, 1.7, 256, 384, 128)
    print(f"    gap(256)=+2.6, gap(384)=+1.7  =>  gap(512) <= {cap:.2f}"
          "   (concavity; measured value above this refutes it)")
    print()


# ---------------------------------------------------------------------------
# 8. Accuracy transfer
# ---------------------------------------------------------------------------


def demo_accuracy_transfer() -> None:
    print("=" * 74)
    print("8. ACCURACY TRANSFER:  concave response, Lipschitz ceiling L * TV")
    print("=" * 74)
    p = mixture_row(512, 180, 0.90, seed=11)
    M = mass_curve(p)
    scale, rate = 0.15, 3.0  # accuracy scale and saturation rate

    def g(x: float) -> float:
        """Concave nondecreasing response g(x) = scale * (1 - exp(-rate x)).

        Its derivative scale*rate*exp(-rate x) is positive and decreasing, so g is
        nondecreasing, concave, and Lipschitz with constant L = scale * rate.
        """
        x = min(max(x, 0.0), 1.0)
        return scale * (1.0 - math.exp(-rate * x))

    lipschitz = scale * rate
    acc = [g(m) for m in M]
    print(f"  response g(x) = {scale} (1 - e^(-{rate}x)): concave, nondecreasing,"
          f" L = {lipschitz:.3f}")
    print(f"  accuracy curve k -> g(M(k)) concave = {is_concave_sequence(acc)}")
    incs = [acc[k + 1] - acc[k] for k in range(len(acc) - 1)]
    print("  increments nonincreasing (diminishing returns) = "
          f"{all(incs[k + 1] <= incs[k] + 1e-12 for k in range(len(incs) - 1))}")
    tv = tv_to_uniform(p)
    worst = max(g(M[k]) - g(k / len(p)) for k in range(len(p) + 1))
    print(f"  TV(p, uniform) = {tv:.6f}")
    print(f"  max_k [ g(M(k)) - g(k/n) ] = {worst:.6f}"
          f"   <=  L * TV = {lipschitz * tv:.6f}   ->"
          f" {worst <= lipschitz * tv + 1e-12}")
    print(f"  width-free mass-gap cap  max_k G(k) = {max(selection_gap_curve(p)):.6f}"
          f"  (equals TV: {abs(max(selection_gap_curve(p)) - tv) < 1e-12})")
    print()


# ---------------------------------------------------------------------------
# 9. Knee brackets and grid resolution
# ---------------------------------------------------------------------------

SWEEP_GRID: Tuple[int, ...] = (96, 128, 160, 192, 224, 240, 256, 288, 320, 384, 512)


def certified_bracket(grid: Sequence[int], passes: Callable[[int], bool]) -> Tuple[int, int]:
    """Least passing grid point b and its predecessor a; the knee lies in (a, b]."""
    lo, hi = 0, len(grid) - 1
    if not passes(grid[hi]):
        raise ValueError("no grid point passes")
    while lo < hi:
        mid = (lo + hi) // 2
        if passes(grid[mid]):
            hi = mid
        else:
            lo = mid + 1
    b = grid[lo]
    a = grid[lo - 1] if lo > 0 else 0
    return a, b


def grid_resolution(a: int, b: int) -> float:
    """(1 - 1/rho) * b with rho = b / a: the residual uncertainty of reporting b."""
    rho = b / a
    return (1.0 - 1.0 / rho) * b


def demo_protocol() -> None:
    print("=" * 74)
    print("9. KNEE BRACKETS, GRID UNIQUENESS, RESOLUTION")
    print("=" * 74)
    # Measured seed-2 accuracy ratios (bar = 0.98)
    measured = {96: 0.902, 128: 0.930, 160: 0.951, 192: 0.966, 224: 0.973,
                240: 0.978, 256: 0.982, 288: 0.988, 320: 0.992, 384: 0.997,
                512: 1.000}
    bar = 0.98
    a, b = certified_bracket(SWEEP_GRID, lambda k: measured[k] >= bar)
    print(f"  measured ratios (bar = {bar}):")
    for k in SWEEP_GRID:
        print(f"     k={k:4d}  ratio={measured[k]:.3f}  {'PASS' if measured[k] >= bar else 'fail'}")
    print(f"\n  certified bracket = ({a}, {b}]")
    inside = [k for k in SWEEP_GRID if a < k <= b]
    print(f"  grid points inside the bracket: {inside}  -> unique = {len(inside) == 1}")
    print(f"  => two seeds bracketed alike must report the same knee, k* = {b}")
    print(f"  resolution: |b - k*| <= (1 - 1/rho) b = {grid_resolution(a, b):.2f}"
          f"   with rho = {b}/{a} = {b / a:.6f}")
    print(f"  attained by the step curve r(k) = 1[k > {a}], whose true knee is {a + 1}")
    print()


# ---------------------------------------------------------------------------
# 10. Depth law and speedup
# ---------------------------------------------------------------------------


def kstar_law(C: float, d: float) -> float:
    return C * d ** (2.0 / 3.0)


def speedup(ctx: int, k: int) -> float:
    return ctx / k


def demo_depth_law() -> None:
    print("=" * 74)
    print("10. DEPTH LAW  k*(d) = 24.7 d^(2/3),  AND THE SPEEDUP")
    print("=" * 74)
    C = 24.7
    print("   d    concave law   affine 8d+32   product law (ctx=512)")
    for d in (4, 8, 16, 32, 64):
        print(f"  {d:3d}   {kstar_law(C, d):10.2f}   {8 * d + 32:12d}   {512:12d}")
    print(f"\n  at d=32:  32^(2/3) = {32 ** (2 / 3):.6f} in (10.079, 10.080)")
    print(f"            law prediction = {kstar_law(C, 32):.3f} in (248.9, 249)")
    print(f"            measured knee  = 256   relative error ="
          f" {abs(kstar_law(C, 32) - 256) / 256 * 100:.2f}%  (< 3%)")
    print(f"            affine 288 vs 1.11*256 = {1.11 * 256:.2f}"
          f"   over-prediction = {(288 / 256 - 1) * 100:.1f}%")
    print(f"\n  per-doubling factor 2^(2/3) = {2 ** (2 / 3):.6f} in (1.58, 1.59), < 2")
    prod = 1.50 * 1.58 * 1.68
    a_emp = math.log(prod, 2) / 3
    print(f"  measured ratios 1.50, 1.58, 1.68  product = {prod:.4f}")
    print(f"  implied exponent a with 2^(3a) = product:  a = {a_emp:.6f}"
          f"   in (0.6, 2/3) = ({0.6}, {2 / 3:.6f}) -> {0.6 < a_emp < 2 / 3}")
    print(f"\n  speedup ctx/k:  product law k=512 -> {speedup(512, 512):.3f}x"
          f"   (no saving)")
    print(f"                   measured knee k=256 -> {speedup(512, 256):.3f}x")
    print(f"  any knee with 2k <= ctx gives at least 2x:"
          f" e.g. k=200 -> {speedup(512, 200):.3f}x")
    print()


# ---------------------------------------------------------------------------


def main() -> None:
    print()
    print("#" * 74)
    print("#  ATTENTION SPARSIFICATION GEOMETRY -- NUMERICAL DEMONSTRATIONS")
    print("#" * 74)
    print()
    demo_concentration()
    demo_tail_ceiling()
    demo_random_control()
    demo_shape()
    demo_accuracy_transfer()
    demo_protocol()
    demo_depth_law()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
