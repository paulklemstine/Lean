#!/usr/bin/env python3
"""
Numerical demonstration of a complete analysis of a five-rung correlation ladder.

All computations are exact (rational arithmetic) wherever the underlying statement is
exact; floating point is used only for display and for square roots.

Sections mirror the paper:

  1. The recorded ladder and its steps.
  2. The sharp decorrelation bound and its exact defect against the previous certificate.
  3. The model-free noise floor obtained by eliminating the fade parameters.
  4. The Chebyshev equioscillation optimum: the noise floor is attained exactly.
  5. Band loss under contractive models; the expansive local fit and its refuted prediction.
  6. Decisiveness as a location problem.
  7. The arithmetic layer: the two-prime quadratic-residue dial is Binomial(2, 1/2).

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Dict, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Section 1. The recorded ladder
# ---------------------------------------------------------------------------

BIT_LENGTHS: List[int] = [96, 100, 104, 108, 112]

LADDER: List[Fraction] = [
    Fraction(5739, 10000),  # U96
    Fraction(5436, 10000),  # U100
    Fraction(5005, 10000),  # U104
    Fraction(4880, 10000),  # U108
    Fraction(4621, 10000),  # U112
]

RUNG_U116: Fraction = Fraction(4847, 10000)   # recorded later; used only to score predictions
RUNG_U120: Fraction = Fraction(43636, 100000)

BAND_FLOOR: Fraction = Fraction(55, 100)
ADVANTAGE_U112: Fraction = Fraction(47, 1000)
DECISIVENESS_BAR: Fraction = Fraction(5, 100)
CI_U112: Tuple[Fraction, Fraction] = (Fraction(415, 1000), Fraction(508, 1000))
CI_ADVANTAGE: Tuple[Fraction, Fraction] = (Fraction(3, 1000), Fraction(90, 1000))


def steps(ladder: Sequence[Fraction]) -> List[Fraction]:
    """Successive differences d_k = rho_{k+1} - rho_k."""
    return [ladder[k + 1] - ladder[k] for k in range(len(ladder) - 1)]


def step_ratios(ladder: Sequence[Fraction]) -> List[Fraction]:
    """Observed step ratios d_{k+1}/d_k (exact rationals)."""
    d = steps(ladder)
    return [d[k + 1] / d[k] for k in range(len(d) - 1) if d[k] != 0]


def section_1() -> None:
    print("=" * 78)
    print("1. THE RECORDED LADDER")
    print("=" * 78)
    d = steps(LADDER)
    print(f"{'bitlen':>8} {'rho':>12} {'step':>12}")
    for i, n in enumerate(BIT_LENGTHS):
        s = f"{float(d[i - 1]):+.4f}" if i > 0 else ""
        print(f"{n:>8} {float(LADDER[i]):>12.4f} {s:>12}")
    print()
    print("  step ratios d_{k+1}/d_k :")
    for k, r in enumerate(step_ratios(LADDER)):
        print(f"    r_{k} = {str(r):>10} = {float(r):.6f}")
    print()
    print(f"  band floor            : {float(BAND_FLOOR):.4f}")
    print(f"  U112 CI               : [{float(CI_U112[0]):.3f}, {float(CI_U112[1]):.3f}]"
          f"   entire CI below band: {CI_U112[1] < BAND_FLOOR}")
    print(f"  advantage over count  : +{float(ADVANTAGE_U112):.3f}"
          f"   CI [{float(CI_ADVANTAGE[0]):.3f}, {float(CI_ADVANTAGE[1]):.3f}]")
    print(f"  decisiveness bar      : +{float(DECISIVENESS_BAR):.3f}")
    print()


# ---------------------------------------------------------------------------
# Section 2. The sharp decorrelation bound
# ---------------------------------------------------------------------------

def gram_determinant(a: float, b: float, c: float) -> float:
    """det of the 3x3 correlation matrix with off-diagonals c (uv), a (uw), b (vw)."""
    return 1.0 + 2.0 * a * b * c - a * a - b * b - c * c


def sharp_bound(a: float, b: float) -> float:
    """c <= ab + sqrt((1-a^2)(1-b^2)); the spherical triangle inequality in cosines."""
    return a * b + math.sqrt(max(0.0, (1.0 - a * a) * (1.0 - b * b)))


def crude_bound(a: float, b: float) -> float:
    """The previous certificate c <= 1 - (a-b)^2/2."""
    return 1.0 - (a - b) ** 2 / 2.0


def defect_identity(a: float, b: float) -> Tuple[float, float]:
    """Both sides of  (1-ab-(a-b)^2/2)^2 - (1-a^2)(1-b^2) = (a-b)^2 (a+b)^2 / 4."""
    lhs = (1.0 - a * b - (a - b) ** 2 / 2.0) ** 2 - (1.0 - a * a) * (1.0 - b * b)
    rhs = (a - b) ** 2 * (a + b) ** 2 / 4.0
    return lhs, rhs


def extremal_configuration(a: float, b: float) -> Tuple[Tuple[float, float], ...]:
    """Planar unit vectors (u, v, w) attaining the sharp bound exactly."""
    w = (1.0, 0.0)
    u = (a, math.sqrt(max(0.0, 1.0 - a * a)))
    v = (b, math.sqrt(max(0.0, 1.0 - b * b)))
    return u, v, w


def cosine(p: Tuple[float, float], q: Tuple[float, float]) -> float:
    num = p[0] * q[0] + p[1] * q[1]
    den = math.hypot(*p) * math.hypot(*q)
    return num / den


def section_2() -> None:
    print("=" * 78)
    print("2. THE SHARP DECORRELATION BOUND")
    print("=" * 78)
    a = float(LADDER[4])                      # corr(T, rate) at U112
    b = a - float(ADVANTAGE_U112)             # corr(count, rate)
    sh, cr = sharp_bound(a, b), crude_bound(a, b)
    print(f"  a = corr(T, rate)     = {a:.6f}   (angle {math.acos(a):.6f} rad)")
    print(f"  b = corr(count, rate) = {b:.6f}   (angle {math.acos(b):.6f} rad)")
    print(f"  sharp certificate  corr(T, count) <= {sh:.8f}")
    print(f"  previous certificate                {cr:.8f}")
    print(f"  strict improvement                : {sh < cr}  (by {cr - sh:.8f})")
    print(f"  angle check  cos(alpha - beta)    = "
          f"{math.cos(math.acos(a) - math.acos(b)):.8f}")
    print()
    lhs, rhs = defect_identity(a, b)
    print(f"  defect identity LHS = {lhs:.10e}")
    print(f"  defect identity RHS = {rhs:.10e}   (agree: {abs(lhs - rhs) < 1e-12})")
    print()
    u, v, w = extremal_configuration(a, b)
    print("  extremal planar configuration attaining the bound:")
    print(f"    corr(u, w) = {cosine(u, w):.8f}   (target {a:.8f})")
    print(f"    corr(v, w) = {cosine(v, w):.8f}   (target {b:.8f})")
    print(f"    corr(u, v) = {cosine(u, v):.8f}   (bound  {sh:.8f})")
    print(f"    Gram determinant = {gram_determinant(a, b, cosine(u, v)):.3e}  (>= 0, tight)")
    print()
    print("  sharpness sweep: the two bounds coincide only on a = +-b")
    print(f"    {'a':>6} {'b':>6} {'sharp':>12} {'crude':>12} {'gap':>12}")
    for aa, bb in [(0.9, 0.9), (0.9, -0.9), (0.9, 0.5), (0.5, 0.1), (0.462, 0.415)]:
        print(f"    {aa:>6.3f} {bb:>6.3f} {sharp_bound(aa, bb):>12.8f} "
              f"{crude_bound(aa, bb):>12.8f} {crude_bound(aa, bb) - sharp_bound(aa, bb):>12.8f}")
    print()


# ---------------------------------------------------------------------------
# Section 3. The model-free noise floor
# ---------------------------------------------------------------------------

def pairwise_noise_bound(ladder: Sequence[Fraction], i: int, j: int) -> Fraction:
    """|r_i - r_j| / (2 (1/|d_i| + 1/|d_j|)) : a lower bound on eta, exact."""
    d = steps(ladder)
    r_i = d[i + 1] / d[i]
    r_j = d[j + 1] / d[j]
    weight = 2 * (1 / abs(d[i]) + 1 / abs(d[j]))
    return abs(r_i - r_j) / weight


def model_free_noise_floor(ladder: Sequence[Fraction]) -> Tuple[Fraction, Tuple[int, int]]:
    """Maximum over all admissible index pairs; the certified noise floor."""
    d = steps(ladder)
    best, arg = Fraction(0), (0, 0)
    for i in range(len(d) - 1):
        for j in range(i + 1, len(d) - 1):
            if d[i] == 0 or d[j] == 0:
                continue
            val = pairwise_noise_bound(ladder, i, j)
            if val > best:
                best, arg = val, (i, j)
    return best, arg


def section_3() -> None:
    print("=" * 78)
    print("3. THE MODEL-FREE NOISE FLOOR")
    print("=" * 78)
    d = steps(LADDER)
    print(f"    {'pair':>8} {'|r_i - r_j|':>14} {'weight':>12} {'eta >=':>14}")
    for i in range(len(d) - 1):
        for j in range(i + 1, len(d) - 1):
            r_i, r_j = d[i + 1] / d[i], d[j + 1] / d[j]
            weight = 2 * (1 / abs(d[i]) + 1 / abs(d[j]))
            bound = pairwise_noise_bound(LADDER, i, j)
            print(f"    ({i},{j})    {float(abs(r_i - r_j)):>14.6f} "
                  f"{float(weight):>12.4f} {float(bound):>14.8f}")
    floor, arg = model_free_noise_floor(LADDER)
    print()
    print(f"  certified noise floor eta* >= {floor} = {float(floor):.10f}   (from pair {arg})")
    print(f"  U112 step  |d_3| = {float(abs(d[3])):.4f}  -> floor is "
          f"{100 * float(floor / abs(d[3])):.1f}% of the step being read")
    print(f"  U108 step  |d_2| = {float(abs(d[2])):.4f}  -> floor is "
          f"{100 * float(floor / abs(d[2])):.1f}% of that step")
    print("  => at this resolution the SHAPE of the fade is not identifiable.")
    print()


# ---------------------------------------------------------------------------
# Section 4. Chebyshev equioscillation: the floor is attained
# ---------------------------------------------------------------------------

LAMBDA_STAR: Fraction = Fraction(278, 367)
FLOOR_STAR: Fraction = Fraction(725197, 1780000)
ETA_STAR: Fraction = Fraction(73943, 7340000)


def residual(ladder: Sequence[Fraction], L: Fraction, lam: Fraction, k: int) -> Fraction:
    """s_k = rho_{k+1} - (L + lam (rho_k - L))."""
    return ladder[k + 1] - (L + lam * (ladder[k] - L))


def solve_equioscillating_triple(
    ladder: Sequence[Fraction], k: int
) -> Tuple[Fraction, Fraction, Fraction]:
    """Solve s_k = +eta, s_{k+1} = -eta, s_{k+2} = +eta exactly.

    With M = L(1 - lam) the residual is s_k = rho_{k+1} - M - lam rho_k, linear in
    (M, lam, eta).  Eliminating M and eta from the three equations gives lam directly.
    """
    r0, r1, r2, r3 = ladder[k], ladder[k + 1], ladder[k + 2], ladder[k + 3]
    # s_k + s_{k+1} = 0  and  s_{k+1} + s_{k+2} = 0  eliminate eta:
    #   (r1 + r2) - 2M - lam (r0 + r1) = 0
    #   (r2 + r3) - 2M - lam (r1 + r2) = 0
    # Subtract:  (r1 - r3) - lam (r0 - r2) = 0
    lam = (r1 - r3) / (r0 - r2)
    M = ((r1 + r2) - lam * (r0 + r1)) / 2
    L = M / (1 - lam)
    eta = r1 - M - lam * r0
    return L, lam, eta


def section_4() -> None:
    print("=" * 78)
    print("4. THE CHEBYSHEV EQUIOSCILLATION OPTIMUM")
    print("=" * 78)
    L, lam, eta = solve_equioscillating_triple(LADDER, 0)
    print(f"  solved from the alternation equations  s_0=+eta, s_1=-eta, s_2=+eta:")
    print(f"    lambda* = {lam} = {float(lam):.7f}   (matches {LAMBDA_STAR}: {lam == LAMBDA_STAR})")
    print(f"    L*      = {L} = {float(L):.7f}   (matches: {L == FLOOR_STAR})")
    print(f"    eta*    = {eta} = {float(eta):.10f}   (matches: {eta == ETA_STAR})")
    print()
    print("  residuals of the recorded ladder against (L*, lambda*):")
    res = [residual(LADDER, FLOOR_STAR, LAMBDA_STAR, k) for k in range(4)]
    for k, s in enumerate(res):
        tag = "= +eta*" if s == ETA_STAR else ("= -eta*" if s == -ETA_STAR else "")
        print(f"    s_{k} = {float(s):+.10f}   {str(s):>18} {tag}")
    print(f"  equioscillation (+,-,+ of equal magnitude): "
          f"{res[0] == ETA_STAR and res[1] == -ETA_STAR and res[2] == ETA_STAR}")
    print(f"  achieved: max |s_k| = {float(max(abs(s) for s in res)):.10f} = eta*  -> the "
          f"model-free floor is EXACTLY attained")
    print()
    floor, _ = model_free_noise_floor(LADDER)
    print(f"  model-free lower bound   : {floor}")
    print(f"  achieved by the optimum  : {ETA_STAR}     identical: {floor == ETA_STAR}")
    print()
    print("  numerical check of optimality: random parameter search cannot beat eta*")
    best = None
    for i in range(-40, 41):
        for j in range(-40, 41):
            Lc = FLOOR_STAR + Fraction(i, 2000)
            lc = LAMBDA_STAR + Fraction(j, 2000)
            m = max(abs(residual(LADDER, Lc, lc, k)) for k in range(4))
            if best is None or m < best[0]:
                best = (m, Lc, lc)
    assert best is not None
    print(f"    best over a 81x81 grid around (L*, lambda*): "
          f"max|s| = {float(best[0]):.10f}  >= eta* = {float(ETA_STAR):.10f}"
          f"   ({best[0] >= ETA_STAR})")
    print()


# ---------------------------------------------------------------------------
# Section 5. Band loss, expansive local fit, scored prediction
# ---------------------------------------------------------------------------

def floor_bound_from_declining_step(
    rho_next: Fraction, lam: Fraction, eta: Fraction
) -> Fraction:
    """L <= rho_{k+1} + eta / (1 - lam) for a nonnegative contractive fade."""
    return rho_next + eta / (1 - lam)


def aitken(x0: Fraction, x1: Fraction, x2: Fraction) -> Fraction:
    """Aitken Delta^2 extrapolate of three successive values."""
    return x0 - (x1 - x0) ** 2 / (x2 - 2 * x1 + x0)


def local_fit_prediction(ladder: Sequence[Fraction]) -> Tuple[Fraction, Fraction, Fraction]:
    """(ratio, Aitken fixed point, next-rung prediction) from the last three rungs."""
    x0, x1, x2 = ladder[-3], ladder[-2], ladder[-1]
    ratio = (x2 - x1) / (x1 - x0)
    fixed = aitken(x0, x1, x2)
    return ratio, fixed, fixed + ratio * (x2 - fixed)


def section_5() -> None:
    print("=" * 78)
    print("5. BAND LOSS, EXPANSIVE LOCAL FIT, AND A SCORED PREDICTION")
    print("=" * 78)
    lam, eta = Fraction(1, 2), Fraction(2, 100)
    L_max = floor_bound_from_declining_step(LADDER[4], lam, eta)
    print(f"  contractive model with lambda <= 1/2, eta <= 0.02:")
    print(f"    L <= rho_4 + eta/(1-lambda) = {L_max} = {float(L_max):.4f} "
          f"< band floor {float(BAND_FLOOR):.2f}: {L_max < BAND_FLOOR}")
    floor, _ = model_free_noise_floor(LADDER)
    print(f"    noise window [{float(floor):.6f}, 0.02] nonempty: {floor <= eta} "
          f"-> conclusion is not vacuous")
    print(f"  unconditionally, the optimal floor L* = {float(FLOOR_STAR):.6f} "
          f"< {float(BAND_FLOOR):.2f} and below every recorded rung "
          f"(min recorded {float(min(LADDER + [RUNG_U116, RUNG_U120])):.5f})")
    print()
    ratio, fixed, pred = local_fit_prediction(LADDER)
    print(f"  local three-rung fit at U112:")
    print(f"    ratio r          = {ratio} = {float(ratio):.4f}   expansive (>1): {ratio > 1}")
    print(f"    Aitken value     = {fixed} = {float(fixed):.7f}")
    print(f"    above all three rungs it was fitted from: "
          f"{all(fixed > x for x in LADDER[2:5])}   -> repelling fixed point, not a floor")
    print(f"    licensed U116 prediction = {pred} = {float(pred):.7f}")
    err = RUNG_U116 - pred
    print(f"    recorded U116            = {float(RUNG_U116):.4f}")
    print(f"    error                    = {err} = {float(err):.7f} "
          f"= {float(err / ETA_STAR):.2f} x eta*")
    print(f"    exceeds 7 eta* : {err > 7 * ETA_STAR}  -> not attributable to noise")
    print()
    opt_pred = FLOOR_STAR + LAMBDA_STAR * (LADDER[4] - FLOOR_STAR)
    print(f"  by comparison, the globally optimal contractive fade predicts "
          f"{float(opt_pred):.6f}")
    print(f"    error {float(RUNG_U116 - opt_pred):+.6f} "
          f"= {float((RUNG_U116 - opt_pred) / ETA_STAR):.2f} x eta*  (also an under-prediction)")
    print(f"  the ladder then resumed falling: U120 = {float(RUNG_U120):.5f}")
    print()


# ---------------------------------------------------------------------------
# Section 6. Decisiveness is a location problem
# ---------------------------------------------------------------------------

def lower_endpoint(center: float, half_width: float, sample_size: int) -> float:
    """Lower confidence endpoint under the standard 1/sqrt(m) shrinkage."""
    return center - half_width / math.sqrt(sample_size)


def section_6() -> None:
    print("=" * 78)
    print("6. DECISIVENESS IS A LOCATION PROBLEM")
    print("=" * 78)
    c, B = float(ADVANTAGE_U112), float(DECISIVENESS_BAR)
    w = float(CI_ADVANTAGE[1] - ADVANTAGE_U112)   # half-width at the recorded sample size
    print(f"  point estimate c = {c:.3f}, bar B = {B:.3f}, shortfall = "
          f"{float(DECISIVENESS_BAR - ADVANTAGE_U112):.3f}")
    print(f"    {'sample size m':>16} {'lower endpoint':>18} {'clears bar?':>12}")
    for m in [3, 30, 300, 3000, 10 ** 6, 10 ** 12]:
        lo = lower_endpoint(c, w, m)
        print(f"    {m:>16} {lo:>18.8f} {str(lo > B):>12}")
    print("  no sample size ever clears the bar: shrinkage moves endpoints toward the center.")
    print()
    print(f"  significance vs decisiveness on the recorded interval "
          f"[{float(CI_ADVANTAGE[0]):.3f}, {float(CI_ADVANTAGE[1]):.3f}]:")
    print(f"    excludes 0 (significant)      : {CI_ADVANTAGE[0] > 0}")
    print(f"    contains the bar 0.05         : "
          f"{CI_ADVANTAGE[0] < DECISIVENESS_BAR < CI_ADVANTAGE[1]}")
    print("    -> logically independent readings; here one holds without the other.")
    print()


# ---------------------------------------------------------------------------
# Section 7. The arithmetic layer: the two-prime quadratic-residue dial
# ---------------------------------------------------------------------------

def quadratic_residues(p: int) -> List[int]:
    """Nonzero quadratic residues modulo an odd prime p."""
    return sorted({(x * x) % p for x in range(1, p)})


def dial_value(x: int, p: int, q: int) -> int:
    """Number of the two primes at which x is a nonzero quadratic residue."""
    qr_p, qr_q = set(quadratic_residues(p)), set(quadratic_residues(q))
    return int((x % p) in qr_p) + int((x % q) in qr_q)


def dial_distribution(p: int, q: int) -> Dict[int, int]:
    """Exact counts of the dial over the units modulo p*q."""
    qr_p, qr_q = set(quadratic_residues(p)), set(quadratic_residues(q))
    counts: Dict[int, int] = {0: 0, 1: 0, 2: 0}
    for x in range(p * q):
        if x % p == 0 or x % q == 0:
            continue
        t = int((x % p) in qr_p) + int((x % q) in qr_q)
        counts[t] += 1
    return counts


def section_7() -> None:
    print("=" * 78)
    print("7. THE ARITHMETIC LAYER: THE TWO-PRIME QUADRATIC-RESIDUE DIAL")
    print("=" * 78)
    print(f"    {'(p,q)':>10} {'|QR(p)|':>8} {'|QR(q)|':>8} {'counts 0:1:2':>18} "
          f"{'2*sum(T-1)^2':>14} {'(p-1)(q-1)':>12} {'var':>6}")
    for p, q in [(3, 5), (5, 7), (7, 11), (11, 13), (13, 17), (17, 19)]:
        counts = dial_distribution(p, q)
        units = sum(counts.values())
        second = 2 * (counts[0] + counts[2])          # 2 * sum (T - 1)^2
        var = Fraction(counts[0] + counts[2], units)  # mean is exactly 1
        assert 2 * len(quadratic_residues(p)) == p - 1
        assert 4 * counts[0] == (p - 1) * (q - 1)
        assert 2 * counts[1] == (p - 1) * (q - 1)
        assert 4 * counts[2] == (p - 1) * (q - 1)
        assert second == (p - 1) * (q - 1)
        assert var == Fraction(1, 2)
        print(f"    {str((p, q)):>10} {len(quadratic_residues(p)):>8} "
              f"{len(quadratic_residues(q)):>8} "
              f"{f'{counts[0]}:{counts[1]}:{counts[2]}':>18} {second:>14} "
              f"{(p - 1) * (q - 1):>12} {str(var):>6}")
    print()
    print("  every row: the dial is exactly Binomial(2, 1/2), mean 1, variance 1/2.")
    print("  the law does not depend on p, q -- hence not on the bit length of N.")
    print("  => the dial's information content does NOT fade; only its coupling to the")
    print("     downstream rate does.")
    print()


# ---------------------------------------------------------------------------

def main() -> None:
    print()
    print("A COMPLETE ANALYSIS OF A FIVE-RUNG CORRELATION LADDER")
    print("sharp decorrelation | exact minimal noise | refuted extrapolation")
    print()
    section_1()
    section_2()
    section_3()
    section_4()
    section_5()
    section_6()
    section_7()
    print("=" * 78)
    print("SUMMARY")
    print("=" * 78)
    print(f"  minimal noise of the record      eta*    = {ETA_STAR} = {float(ETA_STAR):.10f}")
    print(f"  optimal fade ratio               lambda* = {LAMBDA_STAR} = {float(LAMBDA_STAR):.7f}")
    print(f"  optimal floor                    L*      = {FLOOR_STAR} = {float(FLOOR_STAR):.7f}")
    print(f"  sharp decorrelation certificate           = "
          f"{sharp_bound(float(LADDER[4]), float(LADDER[4] - ADVANTAGE_U112)):.8f}")
    print(f"  previous certificate                      = "
          f"{crude_bound(float(LADDER[4]), float(LADDER[4] - ADVANTAGE_U112)):.8f}")
    _, _, pred = local_fit_prediction(LADDER)
    print(f"  scored extrapolation error                = "
          f"{float(RUNG_U116 - pred):.7f} = {float((RUNG_U116 - pred) / ETA_STAR):.2f} eta*")
    print(f"  decisiveness shortfall                    = "
          f"{float(DECISIVENESS_BAR - ADVANTAGE_U112):.3f} (unreachable by replication)")
    print()


if __name__ == "__main__":
    main()
