"""
Absent increments: the moment geometry of a non-replicating feature.

Self-contained numerical demonstration of the results of the accompanying paper.

Setting.  A finite population of "keys" i = 1, ..., n carries
  * a draw regime  p = (p_1, ..., p_n),  p_i >= 0,  sum p_i = 1;
  * a footprint dial  x : keys -> R  (the validated baseline predictor);
  * a candidate feature  z : keys -> R  (here the 0/1 prime-power indicator);
  * a rate (response)  y : keys -> R.

Everything below is exact rational arithmetic (fractions.Fraction), so the printed
numbers are the true values of the statistics, not floating-point approximations.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction as F
from typing import Callable, List, Sequence, Tuple

Vec = Sequence[F]


# ----------------------------------------------------------------------------- #
# Weighted second-moment toolkit
# ----------------------------------------------------------------------------- #
def wmean(p: Vec, f: Vec) -> F:
    """Draw-regime mean  E_p[f] = sum_i p_i f_i."""
    return sum((pi * fi for pi, fi in zip(p, f)), F(0))


def wip(p: Vec, f: Vec, g: Vec) -> F:
    """Draw-regime inner product  <f, g>_p = sum_i p_i f_i g_i (uncentred)."""
    return sum((pi * fi * gi for pi, fi, gi in zip(p, f, g)), F(0))


def wcov(p: Vec, f: Vec, g: Vec) -> F:
    """Draw-regime covariance  sigma_fg = E_p[(f - Ef)(g - Eg)]."""
    mf, mg = wmean(p, f), wmean(p, g)
    return sum((pi * (fi - mf) * (gi - mg) for pi, fi, gi in zip(p, f, g)), F(0))


def wvar(p: Vec, f: Vec) -> F:
    """Draw-regime variance  sigma_ff."""
    return wcov(p, f, f)


def r2(p: Vec, x: Vec, y: Vec) -> F:
    """Single-predictor variance share  R^2(x, y) = sigma_xy^2 / (sigma_xx sigma_yy)."""
    return wcov(p, x, y) ** 2 / (wvar(p, x) * wvar(p, y))


def ls_fit(p: Vec, x: Vec, y: Vec) -> Tuple[F, F]:
    """Least-squares affine fit  y ~ a + b x  under the draw regime p."""
    b = wcov(p, x, y) / wvar(p, x)
    a = wmean(p, y) - b * wmean(p, x)
    return a, b


def residual(p: Vec, x: Vec, y: Vec) -> List[F]:
    """The least-squares residual  r = y - (a + b x):  centred and orthogonal to x."""
    a, b = ls_fit(p, x, y)
    return [yi - (a + b * xi) for xi, yi in zip(x, y)]


def mse(p: Vec, x: Vec, y: Vec, a: F, b: F) -> F:
    """Weighted mean squared error of the affine predictor a + b x."""
    return sum((pi * (yi - a - b * xi) ** 2 for pi, xi, yi in zip(p, x, y)), F(0))


def gain(p: Vec, r: Vec, z: Vec) -> F:
    """Raw augmentation gain  <r, z>^2 / <z, z>: variance removed from the residual r."""
    return wip(p, r, z) ** 2 / wip(p, z, z)


def partial_feature(p: Vec, x: Vec, z: Vec) -> List[F]:
    """The partialled feature  z~ = z - (a + b x):  what the footprint cannot express."""
    return residual(p, x, z)


def pgain(p: Vec, r: Vec, zt: Vec) -> F:
    """Partialled gain  <r, z~>^2 / <z~, z~> = Delta R^2 * sigma_yy."""
    return wip(p, r, zt) ** 2 / wip(p, zt, zt)


def delta_r2(p: Vec, x: Vec, z: Vec, y: Vec) -> F:
    """Increment of the multiple variance share contributed by z over the footprint x."""
    r = residual(p, x, y)
    zt = partial_feature(p, x, z)
    return pgain(p, r, zt) / wvar(p, y)


def pgain_from_moments(sxx: F, sxy: F, sxz: F, szy: F, szz: F) -> F:
    """Delta R^2 * sigma_yy expressed through five second moments alone."""
    num = szy - sxy * sxz / sxx
    den = szz - sxz ** 2 / sxx
    return num ** 2 / den


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def show(label: str, value: F) -> None:
    print(f"  {label:<52} {str(value):>12}   ({float(value):+.6f})")


# ----------------------------------------------------------------------------- #
# The four-key laboratory population
# ----------------------------------------------------------------------------- #
PU: List[F] = [F(1, 4)] * 4                       # uniform draw regime
FOOT: List[F] = [F(1), F(2), F(3), F(4)]          # footprint dial w
PP: List[F] = [F(1), F(1), F(0), F(0)]            # prime-power indicator


def demo_nonreplication() -> None:
    """Two populations, identical base dial, incompatible increments."""
    banner("1.  NON-REPLICATION:  same base dial, different increment")

    rate_a = [F(12, 7), F(3, 7), F(4), F(27, 7)]
    rate_b = [F(2), F(1), F(2), F(5)]

    for name, y in (("A (the original population)", rate_a), ("B (a fresh population)", rate_b)):
        r = residual(PU, FOOT, y)
        zt = partial_feature(PU, FOOT, PP)
        print(f"\n  population {name}")
        show("base variance share  R^2(w, y)", r2(PU, FOOT, y))
        show("rate variance  sigma_yy", wvar(PU, y))
        show("residual energy  <r, r>", wip(PU, r, r))
        show("raw gain of pp", gain(PU, r, PP))
        show("partialled gain  <r, z~>^2 / <z~, z~>", pgain(PU, r, zt))
        show("increment  Delta R^2(pp)", delta_r2(PU, FOOT, PP, y))

    print("\n  Both populations report R^2 = 5/9 for the footprint dial;")
    print("  the increment is 20/49 on A and exactly 0 on B.")


def demo_marginal_vs_incremental() -> None:
    """A feature can be comonotone with the rate and still contribute nothing."""
    banner("2.  MARGINAL PRESENT, INCREMENTAL ABSENT")

    foot2 = [F(7, 2), F(7, 2), F(1), F(0)]
    rate2 = [F(4), F(3), F(1), F(0)]
    r = residual(PU, foot2, rate2)
    zt = partial_feature(PU, foot2, PP)

    show("marginal covariance  sigma(pp, y)  (uniform regime)", wcov(PU, PP, rate2))
    show("base variance share  R^2(w, y)", r2(PU, foot2, rate2))
    show("residual energy  <r, r>   (model NOT saturated)", wip(PU, r, r))
    show("partialled gain of pp", pgain(PU, r, zt))
    show("increment  Delta R^2(pp)", delta_r2(PU, foot2, PP, rate2))

    # comonotonicity check: (pp_i - pp_j)(y_i - y_j) >= 0 for all i, j
    comonotone = all(
        (PP[i] - PP[j]) * (rate2[i] - rate2[j]) >= 0 for i in range(4) for j in range(4)
    )
    print(f"\n  pp and the rate are comonotone: {comonotone}")
    print("  => the marginal covariance is strictly positive in EVERY full-support regime,")
    print("     yet the increment over the footprint is exactly zero.")


def demo_sign_masking() -> None:
    """Every marginal reading identical; increments 80/149 and 0."""
    banner("3.  SUPPRESSION:  identical marginal dials, opposite increments")

    rate_sb = [F(7, 10), F(-2, 5), F(-3, 10), F(1)]   # suppressed
    rate_sc = [F(3, 10), F(2, 5), F(-7, 10), F(1)]    # active

    rows: List[Tuple[str, Callable[[Vec], F]]] = [
        ("footprint dial  R^2(w, y)", lambda y: r2(PU, FOOT, y)),
        ("marginal pp dial  R^2(pp, y)", lambda y: r2(PU, PP, y)),
        ("rate variance  sigma_yy", lambda y: wvar(PU, y)),
        ("pp-rate covariance  sigma_zy", lambda y: wcov(PU, PP, y)),
        ("INCREMENT  Delta R^2(pp)", lambda y: delta_r2(PU, FOOT, PP, y)),
    ]
    print(f"  {'statistic':<40}{'suppressed':>18}{'active':>18}")
    for label, f in rows:
        print(f"  {label:<40}{str(f(rate_sb)):>18}{str(f(rate_sc)):>18}")

    sxx = wvar(PU, FOOT)
    sxz = wcov(PU, FOOT, PP)
    print("\n  absence quadric  sigma_zy * sigma_xx - sigma_xy * sigma_xz:")
    for name, y in (("suppressed", rate_sb), ("active", rate_sc)):
        val = wcov(PU, PP, y) * sxx - wcov(PU, FOOT, y) * sxz
        show(f"  {name}", val)
    print("  The suppressed population sits exactly on the quadric; the active one does not.")


def demo_moment_sufficiency() -> None:
    """Delta R^2 is a rational function of five second moments and nothing else."""
    banner("4.  MOMENT SUFFICIENCY:  five numbers determine the increment")

    rate_a = [F(12, 7), F(3, 7), F(4), F(27, 7)]
    sxx, sxy = wvar(PU, FOOT), wcov(PU, FOOT, rate_a)
    sxz, szy, szz = wcov(PU, FOOT, PP), wcov(PU, PP, rate_a), wvar(PU, PP)
    direct = pgain(PU, residual(PU, FOOT, rate_a), partial_feature(PU, FOOT, PP))
    viamom = pgain_from_moments(sxx, sxy, sxz, szy, szz)
    show("sigma_xx", sxx)
    show("sigma_xy", sxy)
    show("sigma_xz", sxz)
    show("sigma_zy", szy)
    show("sigma_zz", szz)
    show("pgain computed directly", direct)
    show("pgain from the five moments", viamom)
    assert direct == viamom

    # Corollary: the increment depends on the footprint only through its moment ratios,
    # so an affine reparametrisation of the footprint leaves it untouched.
    print("\n  Affine reparametrisation of the footprint:")
    aff = [F(3) + F(2) * xi for xi in FOOT]
    show("increment on the original footprint", delta_r2(PU, FOOT, PP, rate_a))
    show("increment after  w -> 3 + 2w", delta_r2(PU, aff, PP, rate_a))
    assert delta_r2(PU, FOOT, PP, rate_a) == delta_r2(PU, aff, PP, rate_a)


def demo_collinearity_and_sparsity() -> None:
    """Two structural ceilings on what an extra feature can buy."""
    banner("5.  CEILINGS:  collinearity defect and sparsity")

    rate_a = [F(12, 7), F(3, 7), F(4), F(27, 7)]
    r = residual(PU, FOOT, rate_a)

    # (a) a perfectly collinear feature buys exactly zero
    collinear = [F(5) + F(3) * xi for xi in FOOT]
    show("gain of the collinear feature 5 + 3w", gain(PU, r, collinear))

    # (b) the collinearity-defect bound, at the least-squares reference
    a, b = ls_fit(PU, FOOT, PP)
    defect = [zi - (a + b * xi) for xi, zi in zip(FOOT, PP)]
    bound = wip(PU, r, r) * (wip(PU, defect, defect) / wip(PU, PP, PP))
    show("gain of pp", gain(PU, r, PP))
    show("collinearity-defect ceiling", bound)
    assert gain(PU, r, PP) <= bound

    # (c) the sparsity ceiling  B^2 * delta  for a 0/1 feature
    print("\n  Sparsity ceiling  gain <= B^2 * delta  for a 0/1 feature of density delta:")
    for n in (4, 12, 40, 120):
        keys = list(range(1, n + 1))
        pn = [F(1, n)] * n
        ind = [F(1) if is_prime_power(k) else F(0) for k in keys]
        density = wmean(pn, ind)
        bmax = F(1)
        rr = [F((-1) ** k, 1) for k in keys]        # a bounded residual, |r| <= 1
        rr = [ri - wmean(pn, rr) for ri in rr]
        g = gain(pn, rr, ind) if wip(pn, ind, ind) > 0 else F(0)
        print(
            f"    N = {n:>4}   density = {float(density):.4f}"
            f"   gain = {float(g):.6f}   ceiling B^2*delta = {float(bmax ** 2 * density):.4f}"
        )


def is_prime_power(n: int) -> bool:
    """True iff n = p^k for a prime p and k >= 1."""
    if n < 2:
        return False
    for p in range(2, n + 1):
        if n % p == 0:
            m = n
            while m % p == 0:
                m //= p
            return m == 1
    return False


def demo_attenuation_and_tail() -> None:
    """Transfer-slope attenuation and the replication tail bound."""
    banner("6.  TRANSFER SLOPE AND THE REPLICATION TAIL BOUND")

    # attenuation: measured footprint x + u with u uncorrelated with x and y
    for ratio in (F(1, 100), F(1, 10), F(1, 5), F(1, 2)):
        slope = F(1) / (1 + ratio)
        show(f"slope with Var u / Var x = {ratio}", slope)
    print("  With Var u <= Var x / 5 the slope lies in [5/6, 1); the reading 0.898 is in band.")

    print("\n  Observed augmented-dial readings at u = 3.5 (five fresh populations):")
    obs = [F(49, 100), F(111, 200), F(107, 250), F(133, 250), F(127, 250)]
    print("   ", [float(v) for v in obs])
    mean = sum(obs, F(0)) / 5
    show("mean reading", mean)
    show("target", F(55, 100))
    above = [i for i, v in enumerate(obs) if v >= F(55, 100)]
    print(f"  populations clearing the target: {above}  ({len(above)} of 5)")

    print("\n  Tail bound: if each population cleared the target independently with")
    print("  probability q >= 4/5, then P(at most one success in five) <= 21/3125.")
    for q in (F(4, 5), F(9, 10), F(1)):
        tail = (1 - q) ** 5 + 5 * q * (1 - q) ** 4
        show(f"P(<=1 success)  at q = {q}", tail)
    show("uniform ceiling 21/3125", F(21, 3125))


def demo_sequential_gain() -> None:
    """The two-feature model: gains are sequential, not additive."""
    banner("7.  SEQUENTIAL, NOT ADDITIVE")

    rate_a = [F(12, 7), F(3, 7), F(4), F(27, 7)]
    r = residual(PU, FOOT, rate_a)
    z = PP
    w = [F(1), F(0), F(1), F(0)]                 # a second candidate feature

    c = wip(PU, r, z) / wip(PU, z, z)
    r1 = [ri - c * zi for ri, zi in zip(r, z)]
    d = wip(PU, r1, w) / wip(PU, w, w)
    final = sum((pi * (ri - d * wi) ** 2 for pi, ri, wi in zip(PU, r1, w)), F(0))

    show("residual energy before augmentation", wip(PU, r, r))
    show("gain of z alone", gain(PU, r, z))
    show("gain of w against the z-adjusted residual", gain(PU, r1, w))
    show("gain of w alone (marginal, against r)", gain(PU, r, w))
    show("residual energy after both", final)
    assert final == wip(PU, r, r) - gain(PU, r, z) - gain(PU, r1, w)
    print("  The sequential identity holds exactly; the marginal gain of w differs from")
    print("  its sequential gain, which is why isolated validation does not transfer.")


def main() -> None:
    demo_nonreplication()
    demo_marginal_vs_incremental()
    demo_sign_masking()
    demo_moment_sufficiency()
    demo_collinearity_and_sparsity()
    demo_attenuation_and_tail()
    demo_sequential_gain()
    print("\nAll exact identities asserted above held.\n")


if __name__ == "__main__":
    main()
