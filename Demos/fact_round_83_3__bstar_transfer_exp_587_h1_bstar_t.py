"""
Window saturation, the matched filter, and the interior-argmax certificate
==========================================================================

Numerical demonstrations of the results on window curves.

Setting.  A response y in R^n is regressed on the *window statistic*

    S(w, B) = sum_{i < B} w_i * v_i,

where v_0, ..., v_{m-1} are pairwise orthogonal nonzero columns in R^n.  With
masses s_i = <v_i, v_i> and signals a_i = <v_i, y>, the score is

    R2(w, B) = A_B^2 / (Sigma_B * ||y||^2),
    A_B     = sum_{i<B} w_i a_i,       Sigma_B = sum_{i<B} w_i^2 s_i.

The script verifies, on explicit rational/floating examples:

  1. the window score equals the ordinary-least-squares R^2 of the regression
     of y on S(w, B) (residual decomposition);
  2. the exact one-step law for R2(w, B+1) - R2(w, B);
  3. the saturation theorem: matched signal block then noise => unique
     interior argmax (standard-basis and Hadamard examples);
  4. matched-filter dominance at every cutoff, and the global cap
     E(m)/||y||^2 with E(B) = sum_{i<B} a_i^2 / s_i;
  5. the interior-argmax certificate: an interior peak proves mismatch;
  6. the peak-margin identity and the sharp delta/2 argmax stability budget;
  7. realizability: inside a fixed orthogonal family, every interior location
     is the unique argmax for a suitable response;
  8. failure of unimodality: orthonormal columns, unit weights, sorted
     efficiencies, and yet two local maxima.

Only the standard library is used.
"""

from __future__ import annotations

import math
import random
from fractions import Fraction
from typing import Callable, Dict, List, Sequence, Tuple

Number = float

# ----------------------------------------------------------------------------
# Core linear algebra on explicit column families
# ----------------------------------------------------------------------------


def dot(u: Sequence[float], v: Sequence[float]) -> float:
    """Euclidean inner product."""
    return sum(ui * vi for ui, vi in zip(u, v))


def masses(columns: Sequence[Sequence[float]]) -> List[float]:
    """s_i = ||v_i||^2 for each column."""
    return [dot(c, c) for c in columns]


def signals(columns: Sequence[Sequence[float]], y: Sequence[float]) -> List[float]:
    """a_i = <v_i, y> for each column."""
    return [dot(c, y) for c in columns]


def is_orthogonal_family(columns: Sequence[Sequence[float]], tol: float = 1e-12) -> bool:
    """Check pairwise orthogonality and nonvanishing of the columns."""
    m = len(columns)
    for i in range(m):
        if dot(columns[i], columns[i]) <= tol:
            return False
        for k in range(i + 1, m):
            if abs(dot(columns[i], columns[k])) > tol:
                return False
    return True


def window_statistic(
    columns: Sequence[Sequence[float]], w: Sequence[float], B: int
) -> List[float]:
    """S(w, B) = sum_{i<B} w_i v_i, computed as an explicit vector."""
    n = len(columns[0])
    out = [0.0] * n
    for i in range(B):
        for j in range(n):
            out[j] += w[i] * columns[i][j]
    return out


# ----------------------------------------------------------------------------
# Algorithm A: the window curve from column statistics
# ----------------------------------------------------------------------------


def window_curve(
    s: Sequence[float], a: Sequence[float], yy: float, w: Sequence[float]
) -> List[float]:
    """R2(w, B) for B = 0, 1, ..., m, in one left-to-right pass.  O(m)."""
    curve = [0.0]
    A = 0.0
    Sigma = 0.0
    for i in range(len(s)):
        A += w[i] * a[i]
        Sigma += w[i] ** 2 * s[i]
        curve.append(0.0 if Sigma == 0.0 else A * A / (Sigma * yy))
    return curve


def explained_signal(s: Sequence[float], a: Sequence[float]) -> List[float]:
    """E(B) = sum_{i<B} a_i^2 / s_i for B = 0, ..., m."""
    out = [0.0]
    total = 0.0
    for si, ai in zip(s, a):
        total += ai * ai / si
        out.append(total)
    return out


def matched_filter(s: Sequence[float], a: Sequence[float]) -> List[float]:
    """The matched filter w_i = a_i / s_i."""
    return [ai / si for ai, si in zip(a, s)]


# ----------------------------------------------------------------------------
# Algorithm B/C: audit and stability budget
# ----------------------------------------------------------------------------


def matched_audit(
    s: Sequence[float], a: Sequence[float], yy: float, w: Sequence[float]
) -> Dict[str, object]:
    """Matched-filter audit of a user weight: dominance, cap, certificate."""
    m = len(s)
    user = window_curve(s, a, yy, w)
    mf = matched_filter(s, a)
    matched = window_curve(s, a, yy, mf)
    cap = explained_signal(s, a)[m] / yy
    peak_B = max(range(m + 1), key=lambda B: user[B])
    return {
        "user_curve": user,
        "matched_curve": matched,
        "global_cap": cap,
        "dominance_holds": all(user[B] <= matched[B] + 1e-12 for B in range(m + 1)),
        "argmax": peak_B,
        "interior_peak": peak_B < m and user[peak_B] > user[m] + 1e-15,
        "mismatch_certified": peak_B < m and user[peak_B] > user[m] + 1e-15,
    }


def stability_budget(curve: Sequence[float], grid: Sequence[int]) -> Tuple[int, float]:
    """Return (argmax over the grid, delta/2) where delta is the top-two gap.

    By the stability theorem the argmax is invariant under every perturbation of
    sup-norm below delta/2, and by the sharpness theorem some perturbation of
    size delta/2 + eps flips it.
    """
    values = sorted(((curve[B], B) for B in grid), reverse=True)
    best_value, best_B = values[0]
    runner_up = values[1][0]
    return best_B, (best_value - runner_up) / 2.0


# ----------------------------------------------------------------------------
# Example families
# ----------------------------------------------------------------------------


def standard_basis(m: int) -> List[List[float]]:
    """The standard orthonormal basis of R^m as a column family."""
    return [[1.0 if j == i else 0.0 for j in range(m)] for i in range(m)]


def hadamard4() -> List[List[float]]:
    """Rows of the order-4 Hadamard matrix, a strength-two +/-1 design."""
    return [
        [1.0, 1.0, 1.0, 1.0],
        [1.0, -1.0, 1.0, -1.0],
        [1.0, 1.0, -1.0, -1.0],
        [1.0, -1.0, -1.0, 1.0],
    ]


def fmt(xs: Sequence[float], places: int = 4) -> str:
    return "[" + ", ".join(f"{x:.{places}f}" for x in xs) + "]"


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# ----------------------------------------------------------------------------
# 1. The window score is the OLS coefficient of determination
# ----------------------------------------------------------------------------


def demo_residual_decomposition() -> None:
    banner("1. Residual decomposition: the window score really is the OLS R^2")
    columns = hadamard4()
    y = [2.0, 0.0, 2.0, 0.0]
    s, a = masses(columns), signals(columns, y)
    yy = dot(y, y)
    w = [1.0] * 4
    B = 2

    S = window_statistic(columns, w, B)
    r2 = window_curve(s, a, yy, w)[B]
    SS, Sy = dot(S, S), dot(S, y)

    print(f"  columns pairwise orthogonal : {is_orthogonal_family(columns)}")
    print(f"  ||S||^2 = {SS:.4f}   <S,y> = {Sy:.4f}   ||y||^2 = {yy:.4f}")
    print(f"  R^2 from column statistics  : {r2:.6f}")
    print(f"  R^2 as squared cosine       : {Sy ** 2 / (SS * yy):.6f}")

    print("\n  residual identity  ||y - bS||^2 = ||y||^2 (1 - R^2) + ||S||^2 (b - b*)^2")
    b_star = Sy / SS
    for b in (-0.5, 0.0, b_star, 0.7, 1.3):
        resid = sum((yi - b * si) ** 2 for yi, si in zip(y, S))
        model = yy * (1 - r2) + SS * (b - b_star) ** 2
        print(f"    b = {b:+.4f}:  ||y-bS||^2 = {resid:.8f}   identity = {model:.8f}")
    print(f"  minimum attained at the OLS slope b* = {b_star:.6f}")


# ----------------------------------------------------------------------------
# 2. The exact step law
# ----------------------------------------------------------------------------


def demo_step_law() -> None:
    banner("2. Exact step law and the rise/fall dichotomy")
    columns = standard_basis(5)
    y = [3.0, 2.0, 1.0, 0.0, 0.0]
    s, a = masses(columns), signals(columns, y)
    yy = dot(y, y)
    w = [1.0] * 5
    curve = window_curve(s, a, yy, w)

    A = 0.0
    Sigma = 0.0
    print("   B    A_B    Sigma_B      p        c     predicted dR2     actual dR2")
    for B in range(5):
        p = w[B] * a[B]
        c = w[B] ** 2 * s[B]
        if Sigma > 0:
            predicted = (Sigma * p * (2 * A + p) - A * A * c) / (
                Sigma * (Sigma + c) * yy
            )
        else:
            predicted = curve[B + 1] - curve[B]
        actual = curve[B + 1] - curve[B]
        print(
            f"  {B:2d}  {A:6.3f}  {Sigma:7.3f}  {p:7.3f}  {c:7.3f}   "
            f"{predicted:+12.8f}   {actual:+12.8f}"
        )
        A += p
        Sigma += c
    print(f"\n  curve = {fmt(curve)}")
    print("  a column with a_B = 0 and w_B != 0 strictly dilutes (steps 3, 4).")


# ----------------------------------------------------------------------------
# 3. The saturation theorem
# ----------------------------------------------------------------------------


def demo_saturation() -> None:
    banner("3. Saturation: matched signal block, then noise => unique interior argmax")

    print("  (a) standard basis of R^4, y = (1,1,0,0), unit weights, t = 2")
    columns = standard_basis(4)
    y = [1.0, 1.0, 0.0, 0.0]
    s, a = masses(columns), signals(columns, y)
    curve = window_curve(s, a, dot(y, y), [1.0] * 4)
    print(f"      curve = {fmt(curve)}          (exactly 0, 1/2, 1, 2/3, 1/2)")
    print(f"      argmax = {max(range(5), key=lambda B: curve[B])}  (interior)")

    print("\n  (b) order-4 Hadamard design, y = h0 + h1 = (2,0,2,0), unit weights")
    columns = hadamard4()
    y = [2.0, 0.0, 2.0, 0.0]
    s, a = masses(columns), signals(columns, y)
    yy = dot(y, y)
    curve = window_curve(s, a, yy, [1.0] * 4)
    print(f"      masses  = {fmt(s, 1)}    signals = {fmt(a, 1)}   ||y||^2 = {yy:.1f}")
    print(f"      curve = {fmt(curve)}          (exactly 0, 1/2, 1, 2/3, 1/2)")
    print(f"      argmax = {max(range(5), key=lambda B: curve[B])}  (interior)")

    Sigma = [sum(s[:B]) for B in range(5)]
    margin = curve[2] - curve[4]
    predicted = curve[2] * (Sigma[4] - Sigma[2]) / Sigma[4]
    print(
        f"      peak margin: observed {margin:.6f}, "
        f"identity R^2(t)*(Sigma_m - Sigma_t)/Sigma_m = {predicted:.6f}"
    )


# ----------------------------------------------------------------------------
# 4-5. Matched-filter dominance, global cap, and the mismatch certificate
# ----------------------------------------------------------------------------


def demo_dominance_and_certificate() -> None:
    banner("4-5. Matched-filter dominance, the global cap, and the certificate")
    random.seed(20260826)
    m = 12
    columns = standard_basis(m)
    # geometric signal profile with a noise tail; masses spread over a decade
    s = [1.0 + 3.0 * random.random() for _ in range(m)]
    a = [(0.9 ** i) * math.sqrt(s[i]) if i < 8 else 0.0 for i in range(m)]
    yy = sum(ai * ai / si for ai, si in zip(a, s)) + 4.0  # unexplainable remainder

    weights: Dict[str, List[float]] = {
        "unit           ": [1.0] * m,
        "harmonic 1/l   ": [1.0 / (i + 1) for i in range(m)],
        "sqrt   1/sqrt l": [1.0 / math.sqrt(i + 1) for i in range(m)],
        "matched a/s    ": matched_filter(s, a),
    }

    print("  R^2 curves (B = 0 .. 12):")
    for name, w in weights.items():
        print(f"    {name}: {fmt(window_curve(s, a, yy, w), 4)}")

    mf_curve = window_curve(s, a, yy, weights["matched a/s    "])
    print("\n  dominance check (matched >= every rival at EVERY cutoff):")
    for name, w in weights.items():
        c = window_curve(s, a, yy, w)
        ok = all(c[B] <= mf_curve[B] + 1e-12 for B in range(m + 1))
        gap = max(mf_curve[B] - c[B] for B in range(m + 1))
        print(f"    {name}: holds = {ok},  largest shortfall = {gap:.6f}")

    cap = explained_signal(s, a)[m] / yy
    print(f"\n  global cap E(m)/||y||^2 = {cap:.6f}")
    print(f"  matched filter at full window = {mf_curve[m]:.6f}  (cap attained)")
    worst = max(max(window_curve(s, a, yy, w)) for w in weights.values())
    print(f"  best score achieved by any (weight, cutoff) pair = {worst:.6f} <= cap")

    print("\n  interior-argmax certificates:")
    for name, w in weights.items():
        audit = matched_audit(s, a, yy, w)
        print(
            f"    {name}: argmax B* = {audit['argmax']:2d}, "
            f"interior peak = {str(audit['interior_peak']):5s} "
            f"=> weight provably unmatched = {audit['mismatch_certified']}"
        )
    print("  note: the matched filter itself never produces an interior peak.")


# ----------------------------------------------------------------------------
# 6. Peak margin and the sharp delta/2 stability budget
# ----------------------------------------------------------------------------


def demo_margin_and_stability() -> None:
    banner("6. Peak margin and the sharp delta/2 argmax stability budget")

    # A five-point grid mimicking the reported instrument.
    grid = [100, 200, 400, 800, 1600]
    observed = {100: 0.5279, 200: 0.5976, 400: 0.6242, 800: 0.5913, 1600: 0.6137}
    curve: Dict[int, float] = observed
    values = sorted(observed.values(), reverse=True)
    delta = values[0] - values[1]
    print(f"  observed curve      : {[f'{observed[B]:.4f}' for B in grid]}")
    print(f"  argmax              : B* = {max(grid, key=lambda B: observed[B])}")
    print(f"  top-two gap delta   : {delta:.4f}")
    print(f"  stability budget    : delta/2 = {delta / 2:.5f}")

    print("\n  stability theorem: perturbations of sup-norm < delta/2 keep the argmax.")
    random.seed(7)
    flips_small = 0
    flips_large = 0
    trials = 20000
    for _ in range(trials):
        eps_small = delta / 2 * 0.98
        eps_large = delta / 2 * 1.10
        pert_s = {B: observed[B] + random.uniform(-eps_small, eps_small) for B in grid}
        pert_l = {B: observed[B] + random.uniform(-eps_large, eps_large) for B in grid}
        if max(grid, key=lambda B: pert_s[B]) != 400:
            flips_small += 1
        if max(grid, key=lambda B: pert_l[B]) != 400:
            flips_large += 1
    print(f"    perturbations bounded by 0.98 * delta/2 : {flips_small} flips "
          f"out of {trials}  (theory: 0)")
    print(f"    perturbations bounded by 1.10 * delta/2 : {flips_large} flips "
          f"out of {trials}  (theory: possible)")

    print("\n  explicit flip witness (sharpness), size delta/2 + eps:")
    eps = 1e-4
    g = dict(observed)
    g[1600] += delta / 2 + eps
    g[400] -= delta / 2 + eps
    print(f"    perturbed argmax = {max(grid, key=lambda B: g[B])} "
          f"with sup-norm {delta / 2 + eps:.5f}")
    print("  a bimodal bootstrap argmax is therefore EXPECTED here, not anomalous.")
    _ = curve


# ----------------------------------------------------------------------------
# 7. Realizability: every interior location occurs in a fixed column family
# ----------------------------------------------------------------------------


def demo_realizability() -> None:
    banner("7. Realizability: inside ONE fixed column family, every interior "
           "location is the argmax")
    m = 8
    columns = standard_basis(m)  # any fixed orthogonal family works
    print(f"  fixed family: {m} orthonormal columns; response y = v_0 + ... + v_(t-1)")
    print("     t   argmax   curve")
    for t in range(1, m):
        y = [1.0 if j < t else 0.0 for j in range(m)]
        s, a = masses(columns), signals(columns, y)
        curve = window_curve(s, a, dot(y, y), [1.0] * m)
        argmax = max(range(m + 1), key=lambda B: curve[B])
        print(f"    {t:2d}    {argmax:3d}     {fmt(curve, 3)}")
    print("  the peak location tracks the RESPONSE, never the columns.")


# ----------------------------------------------------------------------------
# 8. Failure of unimodality
# ----------------------------------------------------------------------------


def demo_bimodality() -> None:
    banner("8. Window curves need not be unimodal (exact rational arithmetic)")
    s = [Fraction(1), Fraction(1), Fraction(1)]
    a = [Fraction(3), Fraction(1), Fraction(1)]
    yy = Fraction(11)

    def exact_curve(weights: Sequence[Fraction]) -> List[Fraction]:
        out = [Fraction(0)]
        A = Fraction(0)
        Sigma = Fraction(0)
        for i in range(3):
            A += weights[i] * a[i]
            Sigma += weights[i] ** 2 * s[i]
            out.append(A * A / (Sigma * yy))
        return out

    unit = exact_curve([Fraction(1)] * 3)
    print("  orthonormal columns e0,e1,e2 in R^3, response y = (3,1,1), unit weights")
    print(f"  efficiencies a_i/s_i = {[str(ai / si) for ai, si in zip(a, s)]}"
          "  (already sorted, decreasing)")
    print(f"  curve = {[str(x) for x in unit]}")
    print(f"        = {[f'{float(x):.5f}' for x in unit]}")
    print(f"  R2(2) < R2(1): {unit[2] < unit[1]}      R2(2) < R2(3): {unit[2] < unit[3]}")
    print("  => strict interior local MINIMUM at B = 2, two local maxima at B = 1, 3")

    def unimodal(curve: Sequence[Fraction]) -> bool:
        m = len(curve) - 1
        for t in range(m + 1):
            up = all(curve[B] <= curve[B + 1] for B in range(t))
            down = all(curve[B + 1] <= curve[B] for B in range(t, m))
            if up and down:
                return True
        return False

    print(f"  unimodal? {unimodal(unit)}")

    mf = [ai / si for ai, si in zip(a, s)]
    matched = exact_curve(mf)
    print(f"\n  same data, matched filter w = {[str(x) for x in mf]}:")
    print(f"  curve = {[str(x) for x in matched]}  -> strictly increasing to 1")
    print(f"  unimodal? {unimodal(matched)}   (monotone curves are unimodal)")


# ----------------------------------------------------------------------------
# 9. A synthetic reproduction of the reported instrument
# ----------------------------------------------------------------------------


def demo_synthetic_instrument() -> None:
    banner("9. Synthetic instrument: two weights on the same columns")
    random.seed(587)
    m = 64                       # 'primes' indexed 1..m
    columns = standard_basis(m)
    s = masses(columns)
    # signal concentrated on the first 16 columns, decaying, then pure noise
    a = [1.0 / math.sqrt(i + 1) if i < 16 else 0.0 for i in range(m)]
    yy = sum(ai * ai for ai in a) / 0.65     # 65% of variance is explainable

    harmonic = [1.0 / (i + 1) for i in range(m)]
    sqrtw = [1.0 / math.sqrt(i + 1) for i in range(m)]
    grid = [4, 8, 16, 32, 64]

    c_sqrt = window_curve(s, a, yy, sqrtw)
    c_harm = window_curve(s, a, yy, harmonic)
    print("     B    R^2(sqrt)   R^2(harmonic)   dR^2")
    for B in grid:
        print(f"    {B:3d}    {c_sqrt[B]:.4f}       {c_harm[B]:.4f}      "
              f"{c_sqrt[B] - c_harm[B]:+.4f}")
    b_sqrt, budget = stability_budget(c_sqrt, grid)
    b_harm, budget_h = stability_budget(c_harm, grid)
    cap = explained_signal(s, a)[m] / yy
    print(f"\n  sqrt weight     : argmax {b_sqrt}, stability budget {budget:.5f}")
    print(f"  harmonic weight : argmax {b_harm}, stability budget {budget_h:.5f}")
    print(f"  global cap E(m)/||y||^2 = {cap:.4f} "
          f"(matched filter attains it at the full window)")
    n_pos = sum(1 for B in grid if c_sqrt[B] > c_harm[B])
    print(f"  the sqrt weight leads the harmonic weight at {n_pos}/{len(grid)} cutoffs;")
    print("  both curves peak in the interior, which certifies that NEITHER weight")
    print("  is matched -- only the matched filter reaches the cap, monotonically.")


def main() -> None:
    demo_residual_decomposition()
    demo_step_law()
    demo_saturation()
    demo_dominance_and_certificate()
    demo_margin_and_stability()
    demo_realizability()
    demo_bimodality()
    demo_synthetic_instrument()
    print()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
