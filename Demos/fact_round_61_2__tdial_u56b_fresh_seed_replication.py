"""
Numerical demonstrations for "The Block-Count Cap: Universal Ceilings for Rank
Correlation Under Ties, with Application to the 2-adic Zero-Fit Dial".

Everything is computed in exact rational arithmetic (fractions.Fraction) except
where an explicit floating-point display is requested.  Exact arithmetic is not
a stylistic choice: at bit-length 56 the quantities involved span more than
10^50, and IEEE doubles silently annihilate the 1/n^2 corrections that the
continuum sandwich is precisely about.

Contents
--------
1.  Tie profiles, cubic moments, and the exact tie-attenuation ceiling.
2.  The continuum sandwich   1 - C/n^3  <=  rho^2  <=  1 - C/n^3 + 1/n^2.
3.  The power-mean bound     n^3 <= K^2 * C,     equality iff flat.
4.  The block-count cap      rho^2 <= 1 - 1/K^2 + 1/n^2,  and its sharpness.
5.  The 2-adic zero-fit dial: closed-form cubic moment (8^b + 6)/7.
6.  Stratified weightings, the sqrt(7) optimum, and the radix law.
7.  Arbitrary weightings of the bit-length-56 dial.
8.  Adjudication of the recorded bit-length-56 replication.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import isqrt, sqrt
from typing import Iterable, List, Sequence, Tuple

Profile = Sequence[int]

# ----------------------------------------------------------------------------
# 1.  Tie profiles and the exact ceiling
# ----------------------------------------------------------------------------


def mass(profile: Profile) -> int:
    """Total number of observations n = sum_j m_j."""
    return sum(profile)


def cube_sum(profile: Profile) -> int:
    """The cubic moment C(L) = sum_j m_j^3."""
    return sum(m**3 for m in profile)


def tie_correction(profile: Profile) -> Fraction:
    """Kendall tie correction  (1/12) * sum_j (m_j^3 - m_j) = (C - n)/12."""
    return Fraction(cube_sum(profile) - mass(profile), 12)


def spearman_sq_max(profile: Profile) -> Fraction:
    """
    Exact tie-attenuation ceiling

        rho^2_max(L) = 1 - (C(L) - n) / (n^3 - n),

    the largest squared Spearman rank correlation a statistic with tie profile
    ``profile`` can achieve against any response.  Requires n >= 2.
    """
    n = mass(profile)
    if n < 2:
        raise ValueError("the ceiling requires a mass of at least 2")
    return 1 - Fraction(cube_sum(profile) - n, n**3 - n)


def continuum_ceiling(profile: Profile) -> Fraction:
    """The scale-invariant surrogate  1 - C(L)/n^3 = 1 - sum_j f_j^3."""
    n = mass(profile)
    return 1 - Fraction(cube_sum(profile), n**3)


# ----------------------------------------------------------------------------
# 2-4.  The three structural bounds
# ----------------------------------------------------------------------------


def sandwich(profile: Profile) -> Tuple[Fraction, Fraction, Fraction]:
    """Return (lower, exact, upper) for the continuum sandwich."""
    n = mass(profile)
    lo = continuum_ceiling(profile)
    return lo, spearman_sq_max(profile), lo + Fraction(1, n**2)


def power_mean_slack(profile: Profile) -> int:
    """K^2 * C(L) - n^3, which Theorem 4.2 asserts is >= 0 (= 0 iff flat)."""
    return len(profile) ** 2 * cube_sum(profile) - mass(profile) ** 3


def block_count_cap(profile: Profile) -> Fraction:
    """The universal cap  1 - 1/K^2 + 1/n^2  depending only on K and n."""
    k, n = len(profile), mass(profile)
    return 1 - Fraction(1, k**2) + Fraction(1, n**2)


def flat_profile(k: int, m: int) -> List[int]:
    """The extremiser of the block-count cap: K blocks of equal size m."""
    return [m] * k


# ----------------------------------------------------------------------------
# 5.  The 2-adic zero-fit dial
# ----------------------------------------------------------------------------


def dyadic_profile(b: int) -> List[int]:
    """
    Tie profile of T(x) = nu_2(x) (trailing-zero count) on uniform b-bit draws:

        D_0 = [1],   D_{b+1} = [2^b] ++ D_b,

    i.e. D_b = [2^(b-1), 2^(b-2), ..., 2, 1, 1]:  b+1 classes, mass 2^b.
    """
    if b == 0:
        return [1]
    return [2 ** (b - 1 - k) for k in range(b)] + [1]


def dyadic_cube_sum_closed_form(b: int) -> Fraction:
    """Proposition 5.1:  C(D_b) = (8^b + 6)/7."""
    return Fraction(8**b + 6, 7)


def weight(profile: Profile, weights: Sequence[int]) -> List[int]:
    """Coordinatewise reweighting W (*) L.  Length -- the class count -- is fixed."""
    return [w * m for w, m in zip(weights, profile)]


def stratified_weights(b: int, p: int, q: int) -> List[int]:
    """Two-level weighting: p on the dominant odd class, q on every deeper class."""
    return [p] + [q] * b


def equalising_weights(b: int) -> List[int]:
    """Inverse-frequency weights 2^k flattening D_b to b+1 blocks of size 2^(b-1)."""
    return [2**k for k in range(b)] + [2 ** (b - 1)] if b >= 1 else [1]


def strat_ceiling(p: float, q: float, kappa: float = 7.0) -> float:
    """Asymptotic stratified ceiling  1 - (p^3 + q^3/kappa)/(p+q)^3."""
    return 1.0 - (p**3 + q**3 / kappa) / (p + q) ** 3


def kappa_radix(g: float) -> float:
    """Radix constant  kappa_g = (g^3 - 1)/(g - 1)^3;  kappa_2 = 7."""
    return (g**3 - 1.0) / (g - 1.0) ** 3


def strat_optimum(kappa: float) -> float:
    """Sharp maximum of the stratified ceiling:  1 - 1/(1 + sqrt(kappa))^2."""
    return 1.0 - 1.0 / (1.0 + sqrt(kappa)) ** 2


def weight_gain(kappa: float) -> float:
    """Squared-ceiling gain bought by optimal stratified weighting: 1/k - 1/(1+sqrt k)^2."""
    return 1.0 / kappa - 1.0 / (1.0 + sqrt(kappa)) ** 2


def sqrt7_convergents(count: int) -> List[Fraction]:
    """Continued-fraction convergents of sqrt(7) = [2; 1,1,1,4, 1,1,1,4, ...]."""
    terms: List[int] = [2]
    cycle = [1, 1, 1, 4]
    while len(terms) < count:
        terms.append(cycle[(len(terms) - 1) % 4])
    out: List[Fraction] = []
    for i in range(1, count + 1):
        value = Fraction(terms[i - 1])
        for t in reversed(terms[: i - 1]):
            value = t + 1 / value
        out.append(value)
    return out


# ----------------------------------------------------------------------------
# helpers
# ----------------------------------------------------------------------------


def show(label: str, value: Fraction | float, digits: int = 10) -> None:
    v = float(value)
    print(f"    {label:<52s} {v:.{digits}f}")


def rule(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def rho(x: Fraction | float) -> float:
    return sqrt(float(x))


# ----------------------------------------------------------------------------
# demonstrations
# ----------------------------------------------------------------------------


def demo_basic_ceilings() -> None:
    rule("1.  The tie-attenuation law on small profiles")
    examples: List[Tuple[str, List[int]]] = [
        ("no ties, n = 6", [1, 1, 1, 1, 1, 1]),
        ("one constant class, n = 6", [6]),
        ("two equal classes, n = 6", [3, 3]),
        ("three equal classes, n = 6", [2, 2, 2]),
        ("lopsided 4+1+1", [4, 1, 1]),
        ("dyadic dial, b = 3", dyadic_profile(3)),
    ]
    print(f"    {'profile':<28s} {'K':>3s} {'n':>4s} {'rho^2_max':>12s} {'rho_max':>10s}")
    for name, prof in examples:
        s = spearman_sq_max(prof)
        print(
            f"    {str(prof):<28s} {len(prof):>3d} {mass(prof):>4d} "
            f"{float(s):>12.6f} {rho(s):>10.6f}   ({name})"
        )
    print("\n    A tie-free profile reaches 1; a single class reaches 0.")


def demo_sandwich() -> None:
    rule("2.  The continuum sandwich:  1 - C/n^3  <=  rho^2  <=  1 - C/n^3 + 1/n^2")
    profiles: List[List[int]] = [
        [3, 3],
        [4, 1, 1],
        flat_profile(5, 7),
        dyadic_profile(6),
        dyadic_profile(12),
    ]
    print(f"    {'profile (K, n)':<24s} {'lower':>14s} {'exact':>14s} {'upper':>14s} {'width':>12s}")
    for prof in profiles:
        lo, ex, hi = sandwich(prof)
        assert lo <= ex <= hi, "continuum sandwich violated"
        tag = f"K={len(prof)}, n={mass(prof)}"
        print(
            f"    {tag:<24s} {float(lo):>14.10f} {float(ex):>14.10f} "
            f"{float(hi):>14.10f} {float(hi - lo):>12.3e}"
        )
    print("\n    The width is exactly 1/n^2, uniformly over all profiles.")

    b = 56
    n = 2**b
    print(f"\n    At the recorded bit-length b = {b}:  1/n^2 = 2^-112 = {2.0**-112:.4e}")
    print(f"    (n = 2^56 = {n})")


def demo_power_mean_and_cap() -> None:
    rule("3-4.  Power-mean bound  n^3 <= K^2 C,  and the block-count cap")
    print("    Slack K^2*C - n^3 (zero exactly on flat profiles):\n")
    tests: List[List[int]] = [
        flat_profile(4, 5),
        [5, 5, 5, 6],
        [1, 1, 1, 17],
        dyadic_profile(5),
    ]
    for prof in tests:
        slack = power_mean_slack(prof)
        flat = len(set(prof)) == 1
        print(f"      {str(prof):<34s} slack = {slack:>18d}   {'FLAT' if flat else ''}")
        assert slack >= 0, "power-mean bound violated"

    print("\n    Block-count cap versus the true ceiling:\n")
    print(f"    {'profile':<30s} {'rho^2_max':>12s} {'1-1/K^2+1/n^2':>16s}")
    for prof in tests + [dyadic_profile(10)]:
        s = spearman_sq_max(prof)
        cap = block_count_cap(prof)
        assert s <= cap, "block-count cap violated"
        print(f"    {str(prof)[:29]:<30s} {float(s):>12.8f} {float(cap):>16.8f}")

    print("\n    Sharpness: the flat profile attains 1 - 1/K^2 to within 1/n^2.\n")
    print(f"    {'K':>4s} {'m':>4s} {'1 - 1/K^2':>14s} {'rho^2_max(flat)':>18s} {'cap':>16s}")
    for k, m in [(2, 3), (5, 4), (10, 10), (57, 2**55)]:
        prof = flat_profile(k, m)
        lower = 1 - Fraction(1, k**2)
        s = spearman_sq_max(prof)
        cap = block_count_cap(prof)
        assert lower <= s <= cap, "sharpness sandwich violated"
        print(
            f"    {k:>4d} {m if m < 10**6 else '2^55':>4} {float(lower):>14.10f} "
            f"{float(s):>18.10f} {float(cap):>16.10f}"
        )


def demo_dial() -> None:
    rule("5.  The 2-adic zero-fit dial")
    print("    Profile of T(x) = nu_2(x) on uniform b-bit draws, and its cubic moment.\n")
    print(f"    {'b':>3s} {'K = b+1':>8s} {'n = 2^b':>12s} {'C = (8^b+6)/7':>22s} {'rho_max':>11s}")
    for b in range(1, 9):
        prof = dyadic_profile(b)
        c = cube_sum(prof)
        assert Fraction(c) == dyadic_cube_sum_closed_form(b), "closed form mismatch"
        s = spearman_sq_max(prof)
        print(f"    {b:>3d} {len(prof):>8d} {mass(prof):>12d} {c:>22d} {rho(s):>11.7f}")

    print(f"\n    Limit of the unweighted ceiling: rho -> sqrt(6/7) = {sqrt(6 / 7):.7f}")
    for b in (20, 40, 56):
        prof = dyadic_profile(b)
        print(f"      b = {b:>3d}:  rho_max = {rho(spearman_sq_max(prof)):.12f}")
    print("\n    Half the mass in one class costs a permanent 1/7 of squared resolution.")


def demo_stratified_and_radix() -> None:
    rule("6.  Stratified weightings, the sqrt(7) optimum, and the radix law")
    kappa = 7.0
    opt = strat_optimum(kappa)
    print(f"    kappa* = 1 - 1/(1+sqrt 7)^2 = {opt:.10f}")
    print(f"    sqrt(kappa*)                = {sqrt(opt):.10f}")
    print(f"    unweighted sqrt(6/7)        = {sqrt(6 / 7):.10f}")
    print(f"    reweighting budget on rho   = {sqrt(opt) - sqrt(6 / 7):.10f}")
    print("\n    Ceiling kappa(1, s) as the weight ratio s = q/p sweeps past sqrt 7:\n")
    print(f"    {'s':>10s} {'kappa(1,s)':>16s} {'kappa* - kappa':>18s}")
    for s in [1.0, 1.5, 2.0, 2.5, sqrt(7.0), 3.0, 4.0, 8.0]:
        k = strat_ceiling(1.0, s, kappa)
        marker = "   <-- optimum at s = sqrt 7" if abs(s - sqrt(7.0)) < 1e-12 else ""
        print(f"    {s:>10.6f} {k:>16.10f} {opt - k:>18.3e}{marker}")

    print("\n    Rational weightings are never optimal; convergents of sqrt 7 close in fast:\n")
    print(f"    {'q/p':>10s} {'kappa(p,q)':>16s} {'deficit':>14s}")
    for conv in sqrt7_convergents(7)[1:]:
        k = strat_ceiling(1.0, float(conv), kappa)
        print(f"    {str(conv):>10s} {k:>16.10f} {opt - k:>14.3e}")

    print("\n    Radix law  kappa_g = (g^3-1)/(g-1)^3  and the gain it permits:\n")
    print(f"    {'g':>4s} {'kappa_g':>12s} {'1 - 1/kappa_g':>16s} {'optimum':>12s} {'gain':>12s}")
    for g in (2.0, 3.0, 4.0, 10.0, 16.0):
        kg = kappa_radix(g)
        print(
            f"    {g:>4.0f} {kg:>12.6f} {1 - 1 / kg:>16.8f} "
            f"{strat_optimum(kg):>12.8f} {weight_gain(kg):>12.8f}"
        )
    print("\n    The gain is strictly positive and strictly decreasing in kappa.")


def demo_arbitrary_weightings() -> None:
    rule("7.  Arbitrary weightings of the bit-length-56 dial")
    b = 56
    prof = dyadic_profile(b)
    k = len(prof)
    print(f"    The dial has K = b + 1 = {k} tie classes; (b+1)^2 = {k * k}.")
    print(f"    Universal cap on rho^2:  1 - 1/{k * k} + 1/n^2.\n")

    trials: List[Tuple[str, List[int]]] = [
        ("all-ones (no weighting)", [1] * k),
        ("stratified (p,q) = (1,3)", stratified_weights(b, 1, 3)),
        ("stratified (p,q) = (14,37)", stratified_weights(b, 14, 37)),
        ("equalising w_k = 2^k", equalising_weights(b)),
    ]
    print(f"    {'weighting':<28s} {'K':>4s} {'rho_max':>14s} {'cap on rho':>14s}")
    for name, w in trials:
        wl = weight(prof, w)
        s = spearman_sq_max(wl)
        cap = 1 - Fraction(1, k**2) + Fraction(1, mass(wl) ** 2)
        assert len(wl) == k, "weighting changed the class count (impossible)"
        assert s <= cap, "universal cap violated"
        print(f"    {name:<28s} {len(wl):>4d} {rho(s):>14.10f} {rho(cap):>14.10f}")

    universal = 1 - Fraction(1, 3249) + Fraction(1, mass(prof) ** 2)
    print(f"\n    1 - 1/3249 + 2^-112  =>  rho <= {rho(universal):.10f}")
    print("    Attained (to within 1/n^2) by the inverse-frequency weighting w_k = 2^k.")
    print("    Note every weighting leaves K = 57: weighting never creates a tie class.")


def demo_record_adjudication() -> None:
    rule("8.  Adjudicating the recorded bit-length-56 replication")
    pooled = Fraction(669, 1000)
    ci_low, ci_high = Fraction(650, 1000), Fraction(690, 1000)
    band_low, band_high = Fraction(55, 100), Fraction(85, 100)
    advantage, bar = Fraction(45, 1000), Fraction(50, 1000)
    shortfall = bar - advantage

    print("    Recorded quantities")
    show("pooled rho(T, rate)", pooled, 4)
    show("CI low / high", ci_low, 4)
    show("", ci_high, 4)
    show("validation band low / high", band_low, 4)
    show("", band_high, 4)
    show("pooled weighted advantage", advantage, 4)
    show("pre-stated bar", bar, 4)
    show("shortfall", shortfall, 4)
    show("popcount baseline reading", pooled - advantage, 4)

    assert band_low <= ci_low and ci_high <= band_high
    print("\n    (a) H1: the whole CI lies inside the validation band.  PASS")

    unweighted = spearman_sq_max(dyadic_profile(56))
    assert pooled**2 < unweighted
    print("    (b) The reading sits far below the dial's own unweighted ceiling:")
    show("rho^2 recorded", pooled**2)
    show("rho^2 ceiling (unweighted, b = 56)", unweighted)

    opt = strat_optimum(7.0)
    budget = sqrt(opt) - sqrt(6 / 7)
    print("\n    (c) The reweighting budget on the rho scale:")
    show("sqrt(kappa*) - sqrt(6/7)", budget)
    show("recorded shortfall", shortfall, 4)
    show("ratio budget / shortfall", budget / float(shortfall), 4)
    assert budget > 7 * float(shortfall)
    print("        The budget exceeds the shortfall more than sevenfold.")

    universal = float(1 - Fraction(1, 3249) + Fraction(1, mass(dyadic_profile(56)) ** 2))
    print("\n    (d) Headroom left unused by the recorded reading:")
    show("against sqrt(kappa*) (stratified optimum)", sqrt(opt) - float(pooled))
    show("against the universal cap", sqrt(universal) - float(pooled))

    print(
        "\n    Conclusion: the shortfall is a fact about the response variable.\n"
        "    Tie geometry left seven times the missing margin on the table, so the\n"
        "    dial was nowhere near saturated -- count parity in this batch is not\n"
        "    evidence that the trailing-zero statistic has run out of resolution."
    )


def main() -> None:
    print(__doc__.strip().splitlines()[0])
    demo_basic_ceilings()
    demo_sandwich()
    demo_power_mean_and_cap()
    demo_dial()
    demo_stratified_and_radix()
    demo_arbitrary_weightings()
    demo_record_adjudication()
    print("\nAll assertions passed.\n")


if __name__ == "__main__":
    main()
