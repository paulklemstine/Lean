"""
Algorithm A — Explained-Fraction (Capture) Estimator with Dispersion Audit.

Given a nonnegative count sample x_1,...,x_n and a covariate dial s_1,...,s_n,
compute the dial's explained-variance fraction eta^2, the raw and residual
dispersion indices, and verify the dispersion-reduction identity

        (D - D_within) / D  =  eta^2

numerically.  Also returns the squared correlation r^2 and certifies the
theoretical ordering r^2 <= eta^2 <= 1.
"""

from __future__ import annotations

from typing import Dict, List, NamedTuple, Sequence


class CaptureReport(NamedTuple):
    """Complete capture and dispersion audit of one dial."""

    n: int
    mean: float
    variance: float
    within_variance: float
    between_variance: float
    eta_sq: float
    corr_sq: float
    dispersion: float
    dispersion_within: float
    dispersion_reduction: float
    identity_residual: float
    anova_residual: float
    meets_bar: bool


def _avg(x: Sequence[float]) -> float:
    return sum(x) / len(x)


def _cov(x: Sequence[float], y: Sequence[float]) -> float:
    mx, my = _avg(x), _avg(y)
    return sum((a - mx) * (b - my) for a, b in zip(x, y)) / len(x)


def _var(x: Sequence[float]) -> float:
    return _cov(x, x)


def capture_report(
    counts: Sequence[float],
    dial: Sequence[float],
    bar: float = 0.30,
) -> CaptureReport:
    """
    Audit one dial against a count sample.

    Complexity: O(n) time with hashing on the dial values (O(n log n) if the
    level sets are formed by sorting), O(k) extra memory for k distinct dial
    levels.  All quantities are exact finite-sample statistics; nothing is
    asymptotic.

    Args:
        counts: the per-unit counts, with strictly positive mean.
        dial:   the covariate value per unit; its distinct values define cells.
        bar:    the acceptance threshold on the dispersion reduction.

    Returns:
        A CaptureReport.  `identity_residual` and `anova_residual` should both
        be at floating-point noise level: they are numerical checks of the
        dispersion-reduction identity and of the variance decomposition.
    """
    n = len(counts)
    if n == 0:
        raise ValueError("empty sample")
    mean = _avg(counts)
    if mean <= 0.0:
        raise ValueError("dispersion index requires a strictly positive mean")
    variance = _var(counts)
    if variance <= 0.0:
        raise ValueError("degenerate sample: zero variance")

    sums: Dict[float, float] = {}
    sizes: Dict[float, int] = {}
    for c, d in zip(counts, dial):
        sums[d] = sums.get(d, 0.0) + c
        sizes[d] = sizes.get(d, 0) + 1
    cell_mean = {k: sums[k] / sizes[k] for k in sums}

    within = sum((c - cell_mean[d]) ** 2 for c, d in zip(counts, dial)) / n
    between = sum((cell_mean[d] - mean) ** 2 for d in dial) / n

    eta_sq = between / variance
    corr_sq = _cov(counts, dial) ** 2 / (variance * _var(dial)) if _var(dial) > 0 else 0.0
    dispersion = variance / mean
    dispersion_within = within / mean
    reduction = (dispersion - dispersion_within) / dispersion

    return CaptureReport(
        n=n,
        mean=mean,
        variance=variance,
        within_variance=within,
        between_variance=between,
        eta_sq=eta_sq,
        corr_sq=corr_sq,
        dispersion=dispersion,
        dispersion_within=dispersion_within,
        dispersion_reduction=reduction,
        identity_residual=abs(reduction - eta_sq),
        anova_residual=abs(variance - within - between),
        meets_bar=eta_sq >= bar,
    )


def residual_dispersion_floor(dispersion: float, eta_cap: float) -> float:
    """
    Certified lower bound on the residual dispersion index after conditioning
    on ANY dial whose explained fraction is at most `eta_cap`:
        D_within >= (1 - eta_cap) * D.
    """
    return (1.0 - eta_cap) * dispersion


def unexplained_excess_fraction(dispersion: float, eta_cap: float) -> float:
    """
    Fraction of the Poisson excess D - 1 that survives every dial-based
    recalibration whose explained fraction is capped at `eta_cap`.
    """
    if dispersion <= 1.0:
        raise ValueError("no Poisson excess to account for")
    return (residual_dispersion_floor(dispersion, eta_cap) - 1.0) / (dispersion - 1.0)


if __name__ == "__main__":
    # The certified reading of the experiment.
    d_raw, eta_cap = 7.27, 0.1422
    floor = residual_dispersion_floor(d_raw, eta_cap)
    frac = unexplained_excess_fraction(d_raw, eta_cap)
    print(f"D_raw = {d_raw}, eta^2 cap = {eta_cap}")
    print(f"residual dispersion floor       = {floor:.6f}   (>= 6.23: {floor >= 6.23})")
    print(f"surviving Poisson-excess share  = {frac:.6f}   (>= 0.83: {frac >= 0.83})")

    # A toy audit.
    counts: List[float] = [29, 41, 55, 63, 70, 77, 84, 96, 130, 151, 172, 60]
    dial: List[float] = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 2]
    rep = capture_report(counts, dial)
    print()
    print(f"n = {rep.n}, mean = {rep.mean:.4f}, D = {rep.dispersion:.4f}")
    print(f"eta^2 = {rep.eta_sq:.6f}, r^2 = {rep.corr_sq:.6f}, "
          f"r^2 <= eta^2 : {rep.corr_sq <= rep.eta_sq + 1e-12}")
    print(f"D_within = {rep.dispersion_within:.4f}, "
          f"reduction = {100 * rep.dispersion_reduction:.2f}%")
    print(f"identity residual = {rep.identity_residual:.3e}, "
          f"ANOVA residual = {rep.anova_residual:.3e}")
    print(f"meets the 30% bar : {rep.meets_bar}")


"""
Algorithm B — Orthogonal-Family Capture Budget and Pre-Registered Stopping Rule.

For a family of pairwise-uncorrelated dials s_1,...,s_m over the same n sample
units, the total linearly explained fraction of a target y is exactly the sum
of the individual squared correlations,

        C = sum_j r^2(y, s_j),

and no joint affine recalibration can push the residual below (1 - C)*Var(y).
The Bessel inequality for dials caps C at 1.  This turns the acceptance test
into a single scalar comparison C >= bar, computable in one streaming pass,
with none of the convergence hazards of an iteratively fitted generalized
linear model: a sum of nonnegative scalars cannot diverge.
"""

from __future__ import annotations

from typing import Iterable, Iterator, List, NamedTuple, Sequence, Tuple


class BudgetReport(NamedTuple):
    """Result of a capture-budget scan over a dial family."""

    n_units: int
    n_dials: int
    budget: float
    max_share: float
    argmax_index: int
    residual_fraction: float
    bessel_ok: bool
    meets_bar: bool
    carrier_dimension_lower_bound: float


def _avg(x: Sequence[float]) -> float:
    return sum(x) / len(x)


def _cov(x: Sequence[float], y: Sequence[float]) -> float:
    mx, my = _avg(x), _avg(y)
    return sum((a - mx) * (b - my) for a, b in zip(x, y)) / len(x)


def _var(x: Sequence[float]) -> float:
    return _cov(x, x)


def squared_correlation(y: Sequence[float], s: Sequence[float]) -> float:
    """Sample r^2(y, s); returns 0 for a degenerate dial."""
    vy, vs = _var(y), _var(s)
    if vy <= 0.0 or vs <= 0.0:
        return 0.0
    return _cov(y, s) ** 2 / (vy * vs)


def capture_budget(
    y: Sequence[float],
    dials: Iterable[Sequence[float]],
    bar: float = 0.30,
) -> BudgetReport:
    """
    Stream a family of dials and accumulate the capture budget.

    Complexity: O(n*m) time, O(n) memory — the dials are consumed one at a time
    and never stored.  For the 78,498-symbol follow-up over 128 targets this is
    about 10^7 elementary operations.

    Args:
        y:     the target (e.g. per-unit log rates).
        dials: an iterable of per-unit dial vectors, assumed pairwise
               uncorrelated (which independent characters guarantee for
               distinct primes).
        bar:   the acceptance threshold on the total explained fraction.
    """
    budget, best, arg, m = 0.0, 0.0, -1, 0
    for j, s in enumerate(dials):
        share = squared_correlation(y, s)
        budget += share
        if share > best:
            best, arg = share, j
        m += 1
    dim = bar / best if best > 0.0 else float("inf")
    return BudgetReport(
        n_units=len(y),
        n_dials=m,
        budget=budget,
        max_share=best,
        argmax_index=arg,
        residual_fraction=max(0.0, 1.0 - budget),
        bessel_ok=budget <= 1.0 + 1e-9,
        meets_bar=budget >= bar,
        carrier_dimension_lower_bound=dim,
    )


def window_transfer_requirement(tested_cap: float, bar: float = 0.30) -> float:
    """Aggregate squared correlation the untested window must supply on its own."""
    if tested_cap >= bar:
        return 0.0
    return bar - tested_cap


def per_symbol_threshold(required_budget: float, window_size: int) -> float:
    """
    Pigeonhole floor: if the window must supply `required_budget` in aggregate,
    some single dial in it carries at least required_budget / window_size.
    """
    if window_size <= 0:
        raise ValueError("empty window")
    return required_budget / window_size


def dilution_ceiling(n_dials: int) -> float:
    """Largest common share m equally strong orthogonal dials can each carry: 1/m."""
    if n_dials <= 0:
        raise ValueError("empty family")
    return 1.0 / n_dials


def joint_residual_floor(variance: float, shares: Sequence[float]) -> float:
    """Certified residual floor (1 - sum_j r_j^2) * Var(y) for an orthogonal family."""
    return (1.0 - sum(shares)) * variance


def orthogonalise(dials: Sequence[Sequence[float]]) -> List[List[float]]:
    """
    Gram-Schmidt in the sample-covariance inner product, used to construct a
    genuinely orthogonal family from correlated raw dials.  O(n*m^2).
    """
    basis: List[List[float]] = []
    for s in dials:
        v = list(s)
        for b in basis:
            c = _cov(v, b) / _var(b)
            v = [vi - c * bi for vi, bi in zip(v, b)]
        if _var(v) > 1e-12:
            basis.append(v)
    return basis


if __name__ == "__main__":
    import random

    rng = random.Random(576)
    n, m = 128, 24
    raw = [[rng.gauss(0.0, 1.0) for _ in range(n)] for _ in range(m)]
    fam = orthogonalise(raw)
    y = [0.55 * fam[0][i] + 0.30 * fam[1][i] + 1.4 * rng.gauss(0.0, 1.0) for i in range(n)]

    rep = capture_budget(y, fam)
    print(f"units {rep.n_units}, dials {rep.n_dials}")
    print(f"budget            = {rep.budget:.6f}   (Bessel ok: {rep.bessel_ok})")
    print(f"strongest share   = {rep.max_share:.6f} at index {rep.argmax_index}")
    print(f"residual fraction = {rep.residual_fraction:.6f}")
    print(f"meets 0.30 bar    : {rep.meets_bar}")
    print(f"carrier dimension >= {rep.carrier_dimension_lower_bound:.4f}")
    print(f"dilution ceiling for {rep.n_dials} equal dials: "
          f"{dilution_ceiling(rep.n_dials):.6f}")

    print()
    need = window_transfer_requirement(0.1422)
    print(f"tested cap 0.1422 -> extension must supply {need:.4f}")
    print(f"forced per-symbol floor over 78498 primes: "
          f"{per_symbol_threshold(need, 78498):.4e}")
    print(f"carrier dimension at strength 0.0781: >= {0.30 / 0.0781:.4f}")


"""
Algorithm C — Resolution-Cell Inversion and Feasibility-Margin Audit.

When a quantity P was never stored raw but is recovered by inverting a law f
from a stored anchor R held to precision delta, the honest output is not a
point but the resolution cell

        C(R, delta) = { P in W : |f(P) - R| <= delta }.

If f is m-expansive and L-Lipschitz-above on the admissible window W, the cell
is an interval whose width is at most 2*delta/m and at least 2*delta/L: an
inversion can never report more than the cell.  Running the Lipschitz estimate
forwards bounds the anchor movement caused by a discrepancy eps in P by L*eps,
and a perturbation below a recorded feasibility margin cannot break the
corresponding feasibility inequality.

This module implements the certified bisection inversion, the cell bracket, the
forward amplification bound, and the margin audit.
"""

from __future__ import annotations

from typing import Callable, List, NamedTuple, Sequence, Tuple


class ResolutionCell(NamedTuple):
    """A two-sided description of what a stored anchor pins down."""

    centre: float
    lower: float
    upper: float
    width: float
    width_upper_bound: float
    width_lower_bound: float
    bounds_consistent: bool


def certified_inverse(
    f: Callable[[float], float],
    target: float,
    window: Tuple[float, float],
    tol: float = 1e-14,
    max_iter: int = 200,
) -> float:
    """
    Bisection inversion of a strictly increasing law f on `window`.

    Complexity: O(log((hi-lo)/tol)) evaluations of f — about 50 iterations for
    double precision on a unit window.  Requires f(lo) <= target <= f(hi).
    """
    lo, hi = window
    flo, fhi = f(lo), f(hi)
    if not (flo <= target <= fhi):
        raise ValueError("target outside the range of f on this window")
    for _ in range(max_iter):
        mid = 0.5 * (lo + hi)
        if f(mid) < target:
            lo = mid
        else:
            hi = mid
        if hi - lo < tol:
            break
    return 0.5 * (lo + hi)


def resolution_cell(
    f: Callable[[float], float],
    window: Tuple[float, float],
    anchor: float,
    delta: float,
    expansive_rate: float,
    lipschitz_rate: float,
) -> ResolutionCell:
    """
    Bracket the set of probabilities compatible with a stored anchor.

    The endpoints are obtained by two certified inversions, at anchor - delta
    and anchor + delta, clipped to the admissible window.  The returned width is
    then checked against the two theoretical bounds 2*delta/L <= width <=
    2*delta/m.

    Complexity: two bisections, i.e. O(log(1/tol)) evaluations of f.
    """
    lo_w, hi_w = window
    try:
        lower = certified_inverse(f, anchor - delta, window)
    except ValueError:
        lower = lo_w
    try:
        upper = certified_inverse(f, anchor + delta, window)
    except ValueError:
        upper = hi_w
    centre = certified_inverse(f, anchor, window)
    width = upper - lower
    ub = 2.0 * delta / expansive_rate
    lb = 2.0 * delta / lipschitz_rate
    return ResolutionCell(
        centre=centre,
        lower=lower,
        upper=upper,
        width=width,
        width_upper_bound=ub,
        width_lower_bound=lb,
        bounds_consistent=(lb - 1e-12 <= width <= ub + 1e-12),
    )


def forward_amplification(lipschitz_rate: float, discrepancy: float) -> float:
    """Upper bound L*|eps| on the anchor movement caused by a discrepancy eps in P."""
    return lipschitz_rate * abs(discrepancy)


def margins_survive(
    margins: Sequence[float], perturbation: float
) -> Tuple[bool, List[bool]]:
    """
    Check that every recorded feasibility margin exceeds the rebooking
    perturbation.  If margin >= perturbation then S_raw + margin <= S_A and
    |S_A' - S_A| <= perturbation together give S_raw <= S_A'.
    """
    flags = [perturbation <= mu for mu in margins]
    return all(flags), flags


if __name__ == "__main__":
    # Illustrative amplification law with a pole at P = 1.
    def inv_law(p: float) -> float:
        return 1.0 / (1.0 - p)

    window = (0.98, 0.99)
    m_rate, l_rate = 2500.0, 10000.0
    anchor = inv_law(0.985)
    delta = 2.0e-4
    cell = resolution_cell(inv_law, window, anchor, delta, m_rate, l_rate)
    print("Resolution cell for f(P) = 1/(1-P) on [0.98, 0.99]")
    print(f"  anchor R          = {anchor:.9f}, delta = {delta:.1e}")
    print(f"  centre  P0        = {cell.centre:.12f}")
    print(f"  cell    [lo, hi]  = [{cell.lower:.12f}, {cell.upper:.12f}]")
    print(f"  width             = {cell.width:.6e}")
    print(f"  theory 2d/L <= w <= 2d/m : [{cell.width_lower_bound:.3e}, "
          f"{cell.width_upper_bound:.3e}]  consistent: {cell.bounds_consistent}")

    print()
    print("Printed-anchor overstatement at the 29.1x locus")
    booked, certified = 0.9853, 0.985068
    shift = forward_amplification(826.0, booked - certified)
    print(f"  discrepancy   = {booked - certified:.3e}")
    print(f"  L * eps       = {shift:.6f}   (<= 0.192: {shift <= 0.192})")
    print(f"  printed 29.3152 vs certified 29.125437 -> drift "
          f"{29.3152 - 29.125436718134:.4f}")

    print()
    ok, flags = margins_survive([0.212, 0.242, 0.183, 0.190], 0.18)
    print(f"Feasibility margins survive a 0.18 rebooking: {ok}  {flags}")


#!/usr/bin/env python3
"""Assemble PACKAGE.json from the individual deliverable files."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Logic/QRDialDispersionLaws.lean",
    "Catalog/Logic/QRDialOrthogonality.lean",
    "Catalog/Logic/QRDialMultiCapture.lean",
    "Catalog/Logic/QRDialWindowExtension.lean",
    "Catalog/Logic/AnchorResolutionLimit.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== FILE: {f} =====\n\n" + read(ROOT / f) for f in LEAN_FILES
)

demo_src = read(ROOT / "demo.py")
spectrum_src = read(A / "demo_capture_spectrum.py")

package = {
    "title": "Capture Ceilings for Covariate Dials: Exact Limits on Explaining "
             "Overdispersion",
    "domain": "Logic",
    "description": (
        "An exact finite-sample theory of how much of a count sample's overdispersion any "
        "covariate dial can explain, proving that the dispersion reduction equals the "
        "explained-variance fraction, that no affine or cell-wise recalibration beats it, "
        "and that orthogonal dial families obey an additive capture ceiling bounded by one. "
        "Applied to a sevenfold Poisson overdispersion in per-integer hit counts, it "
        "certifies that at least 83% of the excess survives every small-prime "
        "quadratic-residue dial and converts the natural follow-up into a per-symbol "
        "threshold of 2e-6."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-25",
    "key_results": [
        "Dispersion-Reduction Identity: the relative reduction in the variance-to-mean "
        "ratio obtained by conditioning on a dial's level sets equals exactly the dial's "
        "explained-variance fraction, so a two-legged acceptance bar tests one scalar.",
        "Conditional-Mean Optimality and the Linear Capture Bound: the cell-mean predictor "
        "beats every dial-measurable predictor and the least-squares line attains the "
        "residual floor (1 - r^2)Var(y), giving r^2 <= eta^2 and a ceiling over all "
        "recalibrations.",
        "Certified residual dispersion: with a raw dispersion index of 7.27 and a best-dial "
        "explained fraction of at most 0.1422, the residual dispersion index is at least "
        "6.23 and at least 83% of the Poisson excess survives every dial.",
        "Exact Dial Orthogonality: under independent uniform Legendre symbols the "
        "individual-symbol and product-symbol quadratic-residue dials have covariance "
        "exactly zero for every prime-window size, by a parity identity on the four sign "
        "patterns at a single prime.",
        "Family Capture Ceiling with a Bessel inequality: explained shares of pairwise "
        "uncorrelated dials add and never exceed one, collapsing a window into a single "
        "count statistic can only lose, and meeting the 0.30 bar forces the untested prime "
        "window to supply 0.1578, hence some single Legendre symbol to reach r^2 >= 2e-6.",
        "Two-sided Resolution Limit: a value recovered by inverting a law from an anchor "
        "stored to precision delta is pinned only to a cell of diameter between 2*delta/L "
        "and 2*delta/m, and the resulting anchor overstatement of at most 0.192 leaves all "
        "four recorded feasibility margins intact.",
    ],
    "keywords": [
        "overdispersion",
        "variance decomposition",
        "explained-variance fraction",
        "quadratic residues",
        "Legendre symbol",
        "Bessel inequality",
        "capture ceiling",
        "resolution limit",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": demo_src,
    "demos": [
        {
            "name": "End-to-End Verification of the Capture Ceilings, Exact Dial "
                    "Orthogonality, and the Resolution Cell",
            "description": (
                "A complete numerical walk-through of every quantitative claim. It builds a "
                "synthetic overdispersed count sample in the observed regime (mean about 77 "
                "hits, dispersion index near 7), then verifies to machine precision that the "
                "relative dispersion reduction equals the explained-variance fraction and "
                "that total variance splits exactly into within-cell and between-cell parts. "
                "It stress-tests the linear capture bound against 200 randomly perturbed "
                "affine fits and conditional-mean optimality against 200 randomly perturbed "
                "cell-wise predictors, confirming that neither floor is ever breached. It "
                "reproduces the certified readings D_within >= 6.23 and a surviving Poisson "
                "excess of at least 83%. It then tabulates the four sign patterns at a single "
                "prime to exhibit the odd-against-even parity, and brute-forces the "
                "covariance of the individual-symbol and product-symbol dials over all 4^k "
                "patterns for k up to 6, obtaining exactly zero each time. Finally it "
                "constructs an orthogonal dial family to check the Bessel budget, the "
                "tightness of the family ceiling at coordinatewise least squares, and the "
                "aggregation loss, and closes with the window-transfer requirement, the "
                "forced per-symbol threshold, and the two-sided resolution-cell bounds."
            ),
            "code": demo_src,
        },
        {
            "name": "The Prime-Window Capture Spectrum and the Pre-Registered Stopping Rule",
            "description": (
                "Builds the monotone capture curve C(X) = sum of r^2 over primes at most X "
                "under three hypothetical share profiles: a flat dilution profile in which "
                "every prime is equally and negligibly informative, a scale-shifted profile "
                "in which a log-Gaussian band of informative primes sits far beyond the "
                "tested window, and a null profile whose weight is concentrated on the small "
                "primes already found wanting. Each profile is normalised so its total "
                "respects the Bessel budget of one. For each, the script prints the spectrum "
                "at a ladder of prime cuts, the implied residual dispersion floor at each "
                "cut, and the exact prime at which the acceptance bar is first crossed, if "
                "ever. It then applies the pre-registered decision rule -- tested cap 0.1422, "
                "bar 0.30, hence an extension requirement of 0.1578 over roughly 78,000 "
                "primes -- to derive the forced per-symbol floor, and closes with an explicit "
                "finite-sample check that a collapsed sum statistic captures no more than the "
                "orthogonal family it aggregates."
            ),
            "code": spectrum_src,
        },
    ],
    "algorithms": [
        {
            "name": "Explained-Fraction Capture Estimator with Dispersion Audit",
            "description": (
                "Given a nonnegative count sample and a covariate dial, this procedure forms "
                "the level sets of the dial, computes cell means, and returns the exact "
                "within-cell and between-cell variances, the explained-variance fraction "
                "eta^2, the squared correlation r^2, the raw and residual dispersion indices, "
                "and the achieved dispersion reduction. Two numerical residuals are reported "
                "as self-checks: the variance decomposition residual and the "
                "dispersion-reduction identity residual, both of which must sit at "
                "floating-point noise level. Mathematically the procedure rests on the "
                "variance decomposition Var = Var_within + Var_between and on the fact that "
                "both dispersion indices share the same denominator, so their relative "
                "difference is exactly eta^2. Because conditioning on the dial's cells is the "
                "optimal use of the dial among all dial-measurable predictors, the returned "
                "eta^2 is a ceiling rather than a fitted value, and the companion routines "
                "convert it into a certified residual dispersion floor and a surviving "
                "Poisson-excess fraction. Complexity is O(n) time with hashing on the dial "
                "values (O(n log n) if the level sets are formed by sorting) and O(k) memory "
                "for k distinct levels; everything is exact finite-sample arithmetic with no "
                "asymptotics."
            ),
            "pseudocode": (
                "INPUT:  counts x[1..n] with positive mean, dial s[1..n], bar b\n"
                "OUTPUT: eta^2, r^2, D, D_within, reduction, self-check residuals\n"
                "\n"
                " 1. mean  <- (1/n) * sum_i x[i]\n"
                " 2. var   <- (1/n) * sum_i (x[i] - mean)^2\n"
                " 3. assert mean > 0 and var > 0\n"
                " 4. for each distinct level k of s:\n"
                " 5.     C[k]     <- { i : s[i] = k }\n"
                " 6.     cmean[k] <- (1/|C[k]|) * sum_{i in C[k]} x[i]\n"
                " 7. within  <- (1/n) * sum_i (x[i] - cmean[s[i]])^2\n"
                " 8. between <- (1/n) * sum_i (cmean[s[i]] - mean)^2\n"
                " 9. eta2    <- between / var\n"
                "10. r2      <- Cov(x,s)^2 / (var * Var(s))          # 0 if Var(s) = 0\n"
                "11. D       <- var / mean\n"
                "12. Dw      <- within / mean\n"
                "13. red     <- (D - Dw) / D\n"
                "14. CHECK   |red - eta2| ~ 0                        # identity\n"
                "15. CHECK   |var - within - between| ~ 0            # decomposition\n"
                "16. ASSERT  r2 <= eta2                              # conditioning wins\n"
                "17. return (eta2, r2, D, Dw, red, eta2 >= b)\n"
                "\n"
                "CERTIFIED CONSEQUENCES (any dial with eta^2 <= e):\n"
                "18. D_within_floor      <- (1 - e) * D\n"
                "19. surviving_excess    <- (D_within_floor - 1) / (D - 1)"
            ),
            "code": read(A / "algo_capture_estimator.py"),
        },
        {
            "name": "Orthogonal-Family Capture Budget with Pigeonhole Decision Rule",
            "description": (
                "For a family of pairwise uncorrelated dials over the same sample units, the "
                "joint recalibration error expands with vanishing cross terms, so completing "
                "the square in each coefficient independently shows that the total linearly "
                "explained fraction is exactly the sum of the individual squared "
                "correlations, attained at coordinatewise least squares. This procedure "
                "streams the family, accumulating that budget in one pass, and reports the "
                "strongest individual share, the residual fraction, whether the Bessel bound "
                "of one is respected, whether the acceptance bar is met, and the implied "
                "lower bound on the number of orthogonal mechanisms the carrier must contain. "
                "It then applies two pigeonhole steps: the window-transfer requirement, which "
                "subtracts the tested window's cap from the bar to obtain what the untested "
                "window must supply on its own, and the per-symbol threshold, which divides "
                "that requirement by the window size to force at least one individual symbol "
                "above an explicit floor. Complexity is O(n*m) time and O(n) memory since "
                "dials are consumed one at a time and never stored -- about 10^7 elementary "
                "operations for 78,498 symbols over 128 units. A Gram-Schmidt helper in the "
                "sample-covariance inner product is supplied for constructing genuinely "
                "orthogonal families from correlated raw dials, at O(n*m^2). Numerically the "
                "method is unconditionally stable: a sum of nonnegative scalars cannot "
                "diverge, unlike the iteratively reweighted fit it replaces."
            ),
            "pseudocode": (
                "INPUT:  target y[1..n], stream of dials s_1, ..., s_m (pairwise\n"
                "        uncorrelated), acceptance bar b, tested-window cap c,\n"
                "        extension window size W\n"
                "OUTPUT: capture budget, verdict, forced per-symbol threshold\n"
                "\n"
                "PHASE 1 -- accumulate the budget\n"
                " 1. budget <- 0 ; best <- 0 ; arg <- none\n"
                " 2. for j = 1 .. m:\n"
                " 3.     share <- Cov(y, s_j)^2 / (Var(y) * Var(s_j))\n"
                " 4.     budget <- budget + share\n"
                " 5.     if share > best: best <- share ; arg <- j\n"
                " 6. CHECK budget <= 1                       # Bessel inequality\n"
                "\n"
                "PHASE 2 -- adjudicate\n"
                " 7. residual_floor <- (1 - budget) * Var(y)  # attained at OLS\n"
                " 8. if budget >= b: report H1 MET, strongest symbol arg\n"
                " 9. else:           report H0 STANDS, residual fraction 1 - budget\n"
                "\n"
                "PHASE 3 -- pigeonhole the untested window\n"
                "10. need <- max(0, b - c)                    # window transfer\n"
                "11. thr  <- need / W                         # forced per-symbol floor\n"
                "12. report: some single dial in the extension window must reach thr,\n"
                "            otherwise the extension hypothesis is refuted\n"
                "13. dim  <- b / best                         # carrier dimension bound\n"
                "14. report: at least ceil(dim) mutually uncorrelated mechanisms needed"
            ),
            "code": read(A / "algo_family_budget.py"),
        },
        {
            "name": "Resolution-Cell Inversion and Feasibility-Margin Audit",
            "description": (
                "When a quantity was never stored raw but is recovered by inverting a law "
                "from a stored anchor held to finite precision, the honest output is an "
                "interval, not a point. This procedure computes that interval by two "
                "certified bisections, at anchor minus delta and anchor plus delta, and "
                "checks the resulting width against both theoretical bounds: at most "
                "2*delta/m for an m-expansive law, and at least 2*delta/L for an "
                "L-Lipschitz-above law. It also runs the Lipschitz estimate forwards to bound "
                "the anchor movement caused by a discrepancy in the recovered value, and "
                "audits a list of recorded feasibility margins against the resulting "
                "rebooking perturbation, using the fact that a perturbation no larger than "
                "the recorded slack cannot flip a feasibility inequality. Bisection costs "
                "O(log((hi - lo)/tol)) evaluations of the law -- about fifty iterations for "
                "double precision on a unit window -- and the margin audit is linear in the "
                "number of loci. The illustrative law 1/(1 - P) on the interval [0.98, 0.99] "
                "has expansive rate 2500 and Lipschitz rate 10000, so its resolution cell is "
                "bracketed by a factor of eight: a concrete demonstration that the two-sided "
                "bound is not vacuous."
            ),
            "pseudocode": (
                "INPUT:  strictly increasing law f, admissible window W = [lo, hi],\n"
                "        stored anchor R, precision delta, rates m (expansive) and\n"
                "        L (Lipschitz-above), booked value P_b, margins mu[1..k],\n"
                "        rebooking perturbation eps\n"
                "OUTPUT: resolution cell, forward drift bound, margin verdicts\n"
                "\n"
                "PROCEDURE invert(f, t, [a, b]):            # certified bisection\n"
                " 1.   require f(a) <= t <= f(b)\n"
                " 2.   repeat until b - a < tol:\n"
                " 3.       mid <- (a + b)/2\n"
                " 4.       if f(mid) < t then a <- mid else b <- mid\n"
                " 5.   return (a + b)/2\n"
                "\n"
                "CELL\n"
                " 6. P_lo <- clip(invert(f, R - delta, W), lo, hi)\n"
                " 7. P_hi <- clip(invert(f, R + delta, W), lo, hi)\n"
                " 8. width <- P_hi - P_lo\n"
                " 9. CHECK 2*delta/L <= width <= 2*delta/m\n"
                "10. report the CELL [P_lo, P_hi], not a point\n"
                "\n"
                "FORWARD DRIFT\n"
                "11. P_c   <- invert(f, R, W)               # certified preimage\n"
                "12. drift <- |f(P_b) - f(P_c)|\n"
                "13. CHECK drift <= L * |P_b - P_c|\n"
                "\n"
                "MARGIN AUDIT\n"
                "14. for i = 1 .. k:\n"
                "15.     survives[i] <- (eps <= mu[i])\n"
                "16. report: feasibility holds at every locus with survives[i] true"
            ),
            "code": read(A / "algo_resolution_cell.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Dispersion Ladder and the Capture Plane",
            "description": (
                "A two-panel figure. The left panel is a dispersion ladder: horizontal bars "
                "showing the certified residual dispersion floor (1 - eta^2) times the raw "
                "dispersion index for each measured dial, against the Poisson baseline of one "
                "and against the floor the 30% acceptance bar would have demanded. The visual "
                "point is stark: the best dial moves the index from 7.27 only down to 6.24, "
                "while clearing the bar would have required reaching 5.09. The right panel is "
                "the capture plane, in which each dial is a point at (r^2, eta^2). The region "
                "below the diagonal is shaded as forbidden, since no affine fit can beat "
                "conditioning on the dial's level sets; the band above 0.30 is shaded as the "
                "acceptance region; and an arrow shows that even adding the two orthogonal "
                "dials' shares lands at 0.0908, far short of the bar."
            ),
            "code": read(A / "viz_capture_ladder.py"),
        },
        {
            "name": "The Capture Spectrum and the Resolution Cell",
            "description": (
                "A two-panel figure. The left panel draws the monotone capture spectrum C(X) "
                "on a logarithmic prime axis for three hypothetical share profiles -- flat "
                "dilution, a scale-shifted band of informative primes, and a null profile "
                "concentrated on the tested small primes -- with the tested cut at 400 and its "
                "measured cap marked, the 0.30 acceptance bar drawn as a line, and the Bessel "
                "budget of one drawn as a ceiling. The question 'did the informative window "
                "move?' becomes the visual question 'does the curve cross the line?'. The "
                "right panel draws the amplification law 1/(1 - P) on [0.98, 0.99] together "
                "with the tolerance band of a stored anchor and the resolution cell it induces "
                "on the probability axis, marking the booked and certified values and the "
                "amplified anchor drift between them."
            ),
            "code": read(A / "viz_spectrum_and_cell.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Overdispersion &amp; Capture-Ceiling Laboratory",
            "description": (
                "A live sandbox for the single-dial theory. Sliders control the number of "
                "targets, the base hit rate, how much of the log rate the observable dial "
                "drives, how much is driven by a hidden carrier the dial cannot see, and the "
                "dial's resolution. The panel reports the mean, the raw and residual "
                "dispersion indices, the explained-variance fraction, the squared "
                "correlation, the achieved dispersion reduction, and the numerical residual "
                "of the dispersion-reduction identity -- which stays at floating-point noise "
                "level however the sliders are moved. A canvas shows the counts sorted and "
                "coloured by dial level with each cell's mean overlaid, beside an exact "
                "stacked split of the total variance into the part the dial explains and the "
                "part it cannot, next to what the 30% bar would demand. A second panel pits "
                "the certified floors against 300 randomly perturbed affine fits and 300 "
                "randomly perturbed cell-wise predictors and confirms that neither floor is "
                "ever breached. Two collapsible sections give the full proofs of "
                "conditional-mean optimality and of the dispersion-reduction identity."
            ),
            "html": read(A / "widget_capture_lab.html"),
        },
        {
            "title": "The Prime-Window Capture Spectrum &amp; the Pre-Registered Decision Rule",
            "description": (
                "An explorer for the family theory. Choose among three hypotheses about how "
                "explanatory power is distributed across the primes -- a scale-shifted band, "
                "a flat dilution, or a null concentrated on the small primes -- then tune the "
                "total capture budget, the band centre, the acceptance bar, and the tested "
                "window's measured cap. A live plot draws the running capture spectrum on a "
                "logarithmic prime axis against the acceptance bar and the Bessel ceiling of "
                "one, and the verdict panel reports the exact prime at which the bar is first "
                "crossed, if ever. A table below turns the settings into the pre-registered "
                "decision rule: the window-transfer requirement, the forced per-symbol floor "
                "over the roughly 78,000 primes of the extension window, the implied residual "
                "dispersion floor, and the minimum number of mutually uncorrelated mechanisms "
                "the carrier would need. Three collapsible sections prove the additivity and "
                "Bessel bound, the aggregation loss via Cauchy-Schwarz in Engel form, and the "
                "pigeonhole origin of the 2e-6 threshold."
            ),
            "html": read(A / "widget_window_spectrum.html"),
        },
        {
            "title": "The Resolution-Cell Inspector",
            "description": (
                "A hands-on illustration of what a value recovered by inverting a law "
                "actually pins down. Sliders set the anchor precision, the exact preimage, "
                "the local sensitivity used for the forward estimate, and the booked value. "
                "A canvas draws the amplification law near the locus of interest, the "
                "tolerance band of the stored anchor, and the resolution cell it induces on "
                "the probability axis, with the booked and certified values marked. The "
                "readings table reports the measured cell width against the two certified "
                "bounds 2*delta/L and 2*delta/m, the discrepancy between booked and certified "
                "values, the resulting anchor drift against its Lipschitz bound, and whether "
                "the booked value is indistinguishable from the certified one given the "
                "stored data. A second table audits all four recorded feasibility margins "
                "against the rebooking perturbation of 0.18. Collapsible sections explain why "
                "the cell is a genuine interval rather than a point, and how a discrepancy of "
                "two parts in ten thousand becomes a visible drift of 0.19."
            ),
            "html": read(A / "widget_resolution_cell.html"),
        },
    ],
    "interactive_layout": read(A / "interactive_layout.md"),
    "lean_proofs": lean_proofs,
    "future_directions": read(A / "phaseA_directions_source.md"),
    "modules": {
        "demo": demo_src,
        "capture_spectrum": spectrum_src,
        "algo_capture_estimator": read(A / "algo_capture_estimator.py"),
        "algo_family_budget": read(A / "algo_family_budget.py"),
        "algo_resolution_cell": read(A / "algo_resolution_cell.py"),
    },
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {out}  ({out.stat().st_size} bytes)")


#!/usr/bin/env python3
"""
The prime-window capture spectrum: does the informative window move with scale?
===============================================================================

The central open question left by the analysis is whether the dial that failed
at primes l <= 400 would succeed over a wider window.  Because per-prime
character dials are pairwise uncorrelated under independent characters, the
capture ceiling of a whole window is simply the SUM of the individual squared
correlations,

    C(X) = sum over primes l <= X of  r^2(y, s_l),

which is monotone increasing in the cut X and, by the Bessel inequality for
dials, bounded above by 1.  The follow-up therefore reduces to a single scalar
curve and a proved stopping rule: does C(X) cross the acceptance bar 0.30?

This demo builds that curve in three regimes and reports, for each:

  * the capture spectrum C(X) at a ladder of cuts;
  * whether and where it crosses the bar;
  * the residual dispersion implied by the ceiling at each cut,
        D_within >= (1 - C(X)) * D_raw;
  * the forced per-symbol threshold for the untested extension window;
  * the check that the collapsed count statistic (a sum of per-prime
    indicators, which is exactly what a product-form dial is) captures no more
    than the family it aggregates.

Regimes:
  "flat"    -- every prime carries the same tiny share (the dilution scenario);
  "shifted" -- the informative primes sit in a band beyond the tested window
               (the scale-shift hypothesis);
  "null"    -- shares decay fast with l, so the window never crosses the bar.

Self-contained: standard library only.
"""

from __future__ import annotations

import math
import random
from typing import Callable, Dict, List, Sequence, Tuple

BAR: float = 0.30
TESTED_CUT: int = 400
FULL_CUT: int = 1_000_000
TESTED_CAP: float = 0.1422


# ---------------------------------------------------------------------------
# Prime generation
# ---------------------------------------------------------------------------


def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes.  O(n log log n) time, O(n) bits of memory."""
    if n < 2:
        return []
    sieve = bytearray([1]) * (n + 1)
    sieve[0] = sieve[1] = 0
    for p in range(2, int(n**0.5) + 1):
        if sieve[p]:
            sieve[p * p :: p] = bytearray(len(sieve[p * p :: p]))
    return [i for i in range(2, n + 1) if sieve[i]]


# ---------------------------------------------------------------------------
# Sample functionals
# ---------------------------------------------------------------------------


def avg(x: Sequence[float]) -> float:
    return sum(x) / len(x)


def cov(x: Sequence[float], y: Sequence[float]) -> float:
    mx, my = avg(x), avg(y)
    return sum((a - mx) * (b - my) for a, b in zip(x, y)) / len(x)


def var(x: Sequence[float]) -> float:
    return cov(x, x)


def corr_sq(y: Sequence[float], s: Sequence[float]) -> float:
    vy, vs = var(y), var(s)
    if vy <= 0.0 or vs <= 0.0:
        return 0.0
    return cov(y, s) ** 2 / (vy * vs)


# ---------------------------------------------------------------------------
# Synthetic per-symbol shares in three regimes
# ---------------------------------------------------------------------------


def share_profile(
    regime: str, primes: List[int], budget: float
) -> Callable[[int, int], float]:
    """
    Return a function (rank, prime) -> r^2 giving the squared correlation of the
    Legendre-symbol dial at that prime with the target.  Each profile is
    normalised so that the TOTAL budget equals `budget`, which must not exceed
    1: the Bessel inequality for orthogonal dials caps the sum of shares at the
    whole variance of the target, so no profile may overdraw it.

      "flat"    -- every prime carries the same tiny share (dilution);
      "shifted" -- a log-Gaussian band of informative primes beyond the tested
                   window (the scale-shift hypothesis);
      "null"    -- shares decay fast with l, concentrated on the small primes
                   that were already tested and found wanting.
    """
    if budget > 1.0:
        raise ValueError("budget exceeds the Bessel bound of 1")

    if regime == "flat":
        weights = [1.0 for _ in primes]
    elif regime == "shifted":
        centre, width = math.log(5.0e4), 0.9
        weights = [
            math.exp(-0.5 * ((math.log(p) - centre) / width) ** 2) for p in primes
        ]
    elif regime == "null":
        weights = [1.0 / (1.0 + p) ** 1.05 for p in primes]
    else:
        raise ValueError(f"unknown regime {regime!r}")

    total = sum(weights)
    shares = [budget * w / total for w in weights]

    def f(rank: int, p: int) -> float:
        return shares[rank]

    return f


def capture_spectrum(
    primes: List[int], share: Callable[[int, int], float], cuts: Sequence[int]
) -> Dict[int, float]:
    """
    Cumulative capture C(X) = sum_{l <= X} r_l^2 at each requested cut.
    Single pass: O(|primes| + |cuts| log |cuts|).
    """
    cuts_sorted = sorted(cuts)
    out: Dict[int, float] = {}
    running, ci = 0.0, 0
    for rank, p in enumerate(primes):
        while ci < len(cuts_sorted) and p > cuts_sorted[ci]:
            out[cuts_sorted[ci]] = running
            ci += 1
        running += share(rank, p)
    while ci < len(cuts_sorted):
        out[cuts_sorted[ci]] = running
        ci += 1
    return out


def crossing_cut(primes: List[int], share: Callable[[int, int], float],
                 bar: float = BAR) -> int | None:
    """Smallest prime cut at which the cumulative capture reaches the bar."""
    running = 0.0
    for rank, p in enumerate(primes):
        running += share(rank, p)
        if running >= bar:
            return p
    return None


# ---------------------------------------------------------------------------
# Aggregation-loss check on an explicit finite sample
# ---------------------------------------------------------------------------


def aggregation_loss_check(n: int = 128, m: int = 40, seed: int = 5761) -> Tuple[float, float]:
    """
    Build m orthogonalised per-symbol dials over n targets and a target y,
    then compare r^2 of the collapsed sum against the family budget.
    Returns (aggregate r^2, family budget); theory says the first is <= second.
    """
    rng = random.Random(seed)
    raw = [[rng.gauss(0.0, 1.0) for _ in range(n)] for _ in range(m)]
    basis: List[List[float]] = []
    for s in raw:
        v = list(s)
        for b in basis:
            c = cov(v, b) / var(b)
            v = [vi - c * bi for vi, bi in zip(v, b)]
        if var(v) > 1e-12:
            basis.append(v)
    y = [
        sum(0.5 / (j + 1) * basis[j][i] for j in range(len(basis)))
        + 1.1 * rng.gauss(0.0, 1.0)
        for i in range(n)
    ]
    aggregate = [sum(s[i] for s in basis) for i in range(n)]
    return corr_sq(y, aggregate), sum(corr_sq(y, s) for s in basis)


# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------


def main() -> None:
    print(__doc__.split("Self-contained")[0].rstrip())
    primes = primes_up_to(FULL_CUT)
    n_ext = sum(1 for p in primes if p > TESTED_CUT)
    print()
    print(f"primes up to {FULL_CUT}: {len(primes)}   "
          f"(extension window 400 < l <= 10^6: {n_ext})")

    cuts = [100, 400, 1_000, 10_000, 100_000, 1_000_000]
    d_raw = 7.27
    for regime, budget in (("flat", 0.45), ("shifted", 0.42), ("null", 0.16)):
        share = share_profile(regime, primes, budget)
        spectrum = capture_spectrum(primes, share, cuts)
        print()
        print("-" * 74)
        print(f"regime: {regime}")
        print("-" * 74)
        print("    cut X        C(X) = sum_{l<=X} r_l^2     implied D_within floor")
        for X in cuts:
            c = spectrum[X]
            print(f"  {X:>9d}        {c:>10.6f}                    "
                  f"{(1 - min(c, 1.0)) * d_raw:>7.4f}")
        cross = crossing_cut(primes, share)
        if cross is None:
            print(f"  bar {BAR} never crossed up to 10^6  ->  H0 stands")
        else:
            print(f"  bar {BAR} first crossed at l = {cross}  ->  H1 window located")
        budget = spectrum[FULL_CUT]
        print(f"  Bessel check: total budget {budget:.6f} <= 1 : {budget <= 1.0}")

    print()
    print("-" * 74)
    print("Pre-registered decision rule for the extension window")
    print("-" * 74)
    need = BAR - TESTED_CAP
    thresh = need / n_ext
    print(f"  tested window capped at        {TESTED_CAP}")
    print(f"  extension must supply          {need:.4f}")
    print(f"  extension window size          {n_ext}")
    print(f"  forced per-symbol floor        {thresh:.4e}")
    print(f"  rounded published threshold    2.0e-06   (attainable: {thresh >= 2e-6})")
    print("  => if EVERY symbol in 400 < l <= 10^6 measures below 2e-6, the")
    print("     scale-shift hypothesis is refuted.")

    print()
    print("-" * 74)
    print("Aggregation loses: collapsed count vs. the family it summarises")
    print("-" * 74)
    agg, fam = aggregation_loss_check()
    print(f"  r^2(y, sum_j s_j)   = {agg:.6f}")
    print(f"  sum_j r^2(y, s_j)   = {fam:.6f}")
    print(f"  aggregate <= family : {agg <= fam + 1e-12}")
    print("  Hence a measured product-form reading is a LOWER bound for its window.")


if __name__ == "__main__":
    main()


"""
Visualization — The Dispersion Ladder and the Capture Ceiling.

Two panels.

LEFT: the dispersion ladder.  A horizontal bar chart showing the raw dispersion
index D_raw = 7.27 against the certified residual floors (1 - eta^2) * D_raw for
each measured dial, plus the floor that the pre-registered 30% bar would have
required.  The Poisson baseline D = 1 is marked.  The visual point is that the
best dial moves the bar from 7.27 only down to 6.24, while clearing the H1 bar
would have required reaching 5.09.

RIGHT: the capture plane.  Each dial is a point at (r^2, eta^2).  The forbidden
region r^2 > eta^2 is shaded out (no affine fit can beat conditioning on the
dial's level sets), the acceptance region eta^2 >= 0.30 is shaded in, and the
orthogonal joint ceiling of the two deployed dials is drawn as an arrow showing
that even summing their shares lands at 0.0908, far short of the bar.

Run:  python3 viz_capture_ladder.py       (writes capture_ladder.png)
Needs matplotlib; numpy is not required.
"""

from __future__ import annotations

from typing import List, Tuple

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
from matplotlib.patches import Rectangle  # noqa: E402

D_RAW: float = 7.27
BAR: float = 0.30

DIALS: List[Tuple[str, float, float]] = [
    # (label, r^2, eta^2 = dispersion reduction)
    ("individual-symbol\n$\\ell \\leq 100$", 0.0127, 0.0088),
    ("product-symbol\n$\\ell \\leq 100$", 0.0781, 0.1422),
    ("wider window\n$\\ell \\leq 400$", 0.0565, 0.0907),
]


def residual_floor(eta_sq: float) -> float:
    """Certified residual dispersion index (1 - eta^2) * D_raw."""
    return (1.0 - eta_sq) * D_RAW


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.5, 5.6))

    # ---------------- LEFT: dispersion ladder ----------------
    labels = ["Poisson\nbaseline", "H1 bar\n(30% reduction)"] + [d[0] for d in DIALS]
    values = [1.0, residual_floor(BAR)] + [residual_floor(d[2]) for d in DIALS]
    colours = ["#2b8a3e", "#f08c00"] + ["#adb5bd", "#1c7ed6", "#adb5bd"]

    ypos = list(range(len(values)))[::-1]
    ax1.barh(ypos, values, color=colours, edgecolor="black", linewidth=0.6, height=0.62)
    ax1.axvline(D_RAW, color="#c92a2a", linestyle="--", linewidth=1.8)
    ax1.text(
        D_RAW - 0.08,
        len(values) - 0.35,
        f"$D_{{\\rm raw}} = {D_RAW}$",
        color="#c92a2a",
        ha="right",
        va="center",
        fontsize=11,
        fontweight="bold",
    )
    for y, v in zip(ypos, values):
        ax1.text(v + 0.09, y, f"{v:.2f}", va="center", fontsize=10)
    ax1.set_yticks(ypos)
    ax1.set_yticklabels(labels, fontsize=9)
    ax1.set_xlim(0, D_RAW + 1.1)
    ax1.set_xlabel("residual dispersion index  $D_{\\rm within}$", fontsize=11)
    ax1.set_title(
        "Certified residual dispersion floors\n"
        "$D_{\\rm within} \\geq (1-\\eta^2)\\, D_{\\rm raw}$",
        fontsize=12,
    )
    ax1.grid(axis="x", alpha=0.25)

    # ---------------- RIGHT: capture plane ----------------
    ax2.add_patch(
        Rectangle((0, 0), 0.36, 0.36, facecolor="none", edgecolor="none")
    )
    # forbidden region r^2 > eta^2
    ax2.fill_between([0, 0.36], [0, 0.36], [0, 0], color="#ffe3e3", zorder=0)
    ax2.plot([0, 0.36], [0, 0.36], color="#c92a2a", linewidth=1.4, zorder=1)
    ax2.text(
        0.235,
        0.135,
        "forbidden:  $r^2 > \\eta^2$",
        color="#c92a2a",
        fontsize=10,
        rotation=38,
        ha="center",
    )
    # acceptance band eta^2 >= 0.30
    ax2.axhspan(BAR, 0.36, color="#d3f9d8", zorder=0)
    ax2.axhline(BAR, color="#2b8a3e", linewidth=1.6)
    ax2.text(0.012, BAR + 0.008, "H1 acceptance:  $\\eta^2 \\geq 0.30$",
             color="#2b8a3e", fontsize=10)

    for label, r2, e2 in DIALS:
        ax2.scatter([r2], [e2], s=95, zorder=4, edgecolor="black", linewidth=0.7,
                    color="#1c7ed6")
        ax2.annotate(
            label.replace("\n", " "),
            (r2, e2),
            textcoords="offset points",
            xytext=(11, 7),
            fontsize=9,
        )

    joint = DIALS[0][1] + DIALS[1][1]
    ax2.annotate(
        "",
        xy=(joint, 0.0088 + 0.1422),
        xytext=(DIALS[1][1], DIALS[1][2]),
        arrowprops=dict(arrowstyle="->", color="#5f3dc4", linewidth=1.6),
    )
    ax2.scatter([joint], [0.0088 + 0.1422], marker="*", s=230, color="#5f3dc4",
                zorder=5, edgecolor="black", linewidth=0.5)
    ax2.annotate(
        "orthogonal joint ceiling\n$r_1^2 + r_2^2 = 0.0908$",
        (joint, 0.0088 + 0.1422),
        textcoords="offset points",
        xytext=(12, -4),
        fontsize=9,
        color="#5f3dc4",
    )

    ax2.set_xlim(0, 0.36)
    ax2.set_ylim(0, 0.36)
    ax2.set_xlabel("linear capture  $r^2$", fontsize=11)
    ax2.set_ylabel("cell-conditioning capture  $\\eta^2$", fontsize=11)
    ax2.set_title(
        "The capture plane: every dial sits far below the bar,\n"
        "and above the line because conditioning beats fitting",
        fontsize=12,
    )
    ax2.grid(alpha=0.25)

    fig.suptitle(
        "At least 83% of a sevenfold Poisson excess survives every "
        "quadratic-residue dial",
        fontsize=13,
        fontweight="bold",
    )
    fig.tight_layout(rect=(0, 0, 1, 0.94))
    fig.savefig("capture_ladder.png", dpi=170)
    print("wrote capture_ladder.png")


if __name__ == "__main__":
    main()


"""
Visualization — The Prime-Window Capture Spectrum and the Resolution Cell.

LEFT: the capture spectrum.  For per-prime dials that are pairwise
uncorrelated, the capture ceiling of a window is the running sum
C(X) = sum_{l <= X} r_l^2, a monotone curve in the prime cut X bounded above by
1 (the Bessel inequality for dials).  Three hypothetical share profiles are
drawn on a logarithmic prime axis — a flat dilution profile, a scale-shifted
band of informative primes beyond the tested window, and a null profile
concentrated on the already-tested small primes.  The tested cut l = 400 and
its measured cap 0.1422 are marked, along with the acceptance bar 0.30; the
question "did the informative window move?" is exactly "does the curve cross
the green line?".

RIGHT: the resolution cell.  For the amplification law f(P) = 1/(1-P) on
[0.98, 0.99], a stored anchor R held to precision delta is compatible with a
whole interval of probabilities.  The plot shows the law, the tolerance band
[R - delta, R + delta], the induced cell on the P axis, and the two certified
width bounds 2*delta/L <= width <= 2*delta/m with L = 10000 and m = 2500.  The
booked and certified probabilities at the 29.1x locus are marked to show that
they are separated by 2.32e-4 and amplified to a 0.19 anchor drift.

Run:  python3 viz_spectrum_and_cell.py    (writes spectrum_and_cell.png)
Needs matplotlib.
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

BAR: float = 0.30
TESTED_CUT: int = 400
TESTED_CAP: float = 0.1422
FULL_CUT: int = 1_000_000


def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    sieve = bytearray([1]) * (n + 1)
    sieve[0] = sieve[1] = 0
    for p in range(2, int(n**0.5) + 1):
        if sieve[p]:
            sieve[p * p :: p] = bytearray(len(sieve[p * p :: p]))
    return [i for i in range(2, n + 1) if sieve[i]]


def normalised_shares(weights: List[float], budget: float) -> List[float]:
    """Rescale nonnegative weights so that they sum to `budget` (<= 1 by Bessel)."""
    total = sum(weights)
    return [budget * w / total for w in weights]


def running_curve(primes: List[int], shares: List[float]) -> Tuple[List[int], List[float]]:
    """Cumulative capture C(X) evaluated at each prime."""
    out, acc = [], 0.0
    for s in shares:
        acc += s
        out.append(acc)
    return primes, out


def main() -> None:
    primes = primes_up_to(FULL_CUT)

    profiles: List[Tuple[str, List[float], float, str]] = [
        ("flat dilution", [1.0 for _ in primes], 0.45, "#868e96"),
        (
            "scale-shifted band",
            [math.exp(-0.5 * ((math.log(p) - math.log(5e4)) / 0.9) ** 2) for p in primes],
            0.42,
            "#1c7ed6",
        ),
        ("null (small primes only)", [1.0 / (1.0 + p) ** 1.05 for p in primes], 0.16,
         "#c92a2a"),
    ]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.5, 5.6))

    # ---------------- LEFT: capture spectrum ----------------
    for name, w, budget, colour in profiles:
        xs, ys = running_curve(primes, normalised_shares(w, budget))
        ax1.plot(xs, ys, label=name, color=colour, linewidth=2.0)

    ax1.axhline(BAR, color="#2b8a3e", linewidth=1.8)
    ax1.text(3, BAR + 0.012, "acceptance bar  $0.30$", color="#2b8a3e", fontsize=10)
    ax1.axvline(TESTED_CUT, color="#f08c00", linestyle="--", linewidth=1.5)
    ax1.scatter([TESTED_CUT], [TESTED_CAP], s=90, color="#f08c00", zorder=5,
                edgecolor="black", linewidth=0.6)
    ax1.annotate(
        f"tested window\n$\\ell \\leq 400$: $\\leq {TESTED_CAP}$",
        (TESTED_CUT, TESTED_CAP),
        textcoords="offset points",
        xytext=(14, -30),
        fontsize=9,
        color="#f08c00",
    )
    ax1.axhline(1.0, color="black", linestyle=":", linewidth=1.2)
    ax1.text(3, 1.012, "Bessel budget  $\\sum_j r_j^2 \\leq 1$", fontsize=9)

    ax1.set_xscale("log")
    ax1.set_xlim(2, FULL_CUT)
    ax1.set_ylim(0, 1.12)
    ax1.set_xlabel("prime cut  $X$", fontsize=11)
    ax1.set_ylabel("capture spectrum  $C(X) = \\sum_{\\ell \\leq X} r_\\ell^2$",
                   fontsize=11)
    ax1.set_title("Does the informative prime window move past 400?", fontsize=12)
    ax1.legend(fontsize=9, loc="center left")
    ax1.grid(alpha=0.25, which="both")

    # ---------------- RIGHT: resolution cell ----------------
    def inv_law(p: float) -> float:
        return 1.0 / (1.0 - p)

    lo, hi = 0.9846, 0.9854
    xs = [lo + (hi - lo) * i / 800 for i in range(801)]
    ys = [inv_law(x) for x in xs]
    ax2.plot(xs, ys, color="#5f3dc4", linewidth=2.2, label="$f(P) = 1/(1-P)$")

    p_cert, p_booked = 0.985068, 0.9853
    anchor = inv_law(p_cert)
    delta = 0.30  # anchor precision drawn to scale for visibility
    ax2.axhspan(anchor - delta, anchor + delta, color="#e5dbff", zorder=0)
    ax2.axhline(anchor, color="#5f3dc4", linestyle="--", linewidth=1.2)
    ax2.text(lo + 0.00004, anchor + delta + 0.06,
             "stored anchor $\\pm\\,\\delta$", color="#5f3dc4", fontsize=10)

    # induced cell on the P axis
    def invert(target: float) -> float:
        a, b = lo, hi
        for _ in range(200):
            mid = 0.5 * (a + b)
            if inv_law(mid) < target:
                a = mid
            else:
                b = mid
        return 0.5 * (a + b)

    cell_lo, cell_hi = invert(anchor - delta), invert(anchor + delta)
    ax2.axvspan(cell_lo, cell_hi, color="#fff3bf", zorder=0)
    ax2.annotate(
        f"resolution cell\nwidth $\\approx$ {cell_hi - cell_lo:.2e}",
        (0.5 * (cell_lo + cell_hi), inv_law(lo) + 0.3),
        ha="center",
        fontsize=9,
        color="#e67700",
    )

    for p, name, colour in [
        (p_cert, "certified $\\hat P = 0.985068$", "#2b8a3e"),
        (p_booked, "booked $\\hat P = 0.9853$", "#c92a2a"),
    ]:
        ax2.scatter([p], [inv_law(p)], s=95, color=colour, zorder=6,
                    edgecolor="black", linewidth=0.6)
        ax2.annotate(name, (p, inv_law(p)), textcoords="offset points",
                     xytext=(-4, 12), fontsize=9, color=colour, ha="right")

    ax2.annotate(
        "",
        xy=(p_booked, inv_law(p_booked)),
        xytext=(p_booked, inv_law(p_cert)),
        arrowprops=dict(arrowstyle="<->", color="black", linewidth=1.3),
    )
    ax2.annotate(
        "anchor drift $\\leq L\\varepsilon = 826 \\times 2.32\\times 10^{-4} "
        "= 0.192$",
        (p_booked, 0.5 * (inv_law(p_booked) + inv_law(p_cert))),
        textcoords="offset points",
        xytext=(-12, 0),
        fontsize=9,
        ha="right",
    )

    ax2.set_xlim(lo, hi)
    ax2.set_xlabel("hit probability  $\\hat P$", fontsize=11)
    ax2.set_ylabel("printed anchor  $f(\\hat P)$", fontsize=11)
    ax2.set_title(
        "A booked value recovered by inversion is pinned\nonly to a cell, never to a point",
        fontsize=12,
    )
    ax2.grid(alpha=0.25)
    ax2.legend(fontsize=9, loc="upper left")

    fig.tight_layout()
    fig.savefig("spectrum_and_cell.png", dpi=170)
    print("wrote spectrum_and_cell.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Capture ceilings for covariate dials — numerical demonstration.
==============================================================

This self-contained script demonstrates, on synthetic and on hand-checked data,
every quantitative claim of the accompanying paper:

  1.  The dispersion-reduction identity
          (D - D_within) / D  =  eta^2
      so the two legs of a two-part acceptance bar measure one scalar.

  2.  The linear capture bound
          MSE(y ~ a + b*s)  >=  (1 - r^2) * Var(y),
      attained exactly at the least-squares coefficients, and the sharper
      conditional-mean optimality, giving r^2 <= eta^2.

  3.  The certified numeric readings of the experiment:
          D_raw = 7.27, eta^2 <= 0.1422  ==>  D_within >= 6.23
          and at least 83% of the Poisson excess D - 1 survives every dial.

  4.  Exact orthogonality of the individual-symbol and product-symbol
      quadratic-residue dials under independent characters: covariance is
      identically zero for every prime-window size k, verified by brute-force
      enumeration of all 4^k sign patterns for small k.

  5.  The family capture ceiling and Bessel inequality
          sum_j r_j^2 <= 1,
      the aggregation loss  r^2(y, sum_j s_j) <= sum_j r_j^2,
      the window-transfer requirement 0.1578 and the forced per-symbol
      threshold 2e-6 over 78,498 primes, and the carrier-dimension bound
      (at least 4 uncorrelated mechanisms at strength 0.0781).

  6.  The resolution-cell theorems for a booked anchor recovered by inverting
      a law, including the two-sided cell width for f(P) = 1/(1-P) on
      [0.98, 0.99] and the printed-anchor overstatement 826 * 2.32e-4 <= 0.192.

Run with:   python3 demo.py
Requires:   Python 3.9+, standard library only.
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# 1. Sample functionals
# ----------------------------------------------------------------------------


def avg(x: Sequence[float]) -> float:
    """Uniform sample average."""
    return sum(x) / len(x)


def cov(x: Sequence[float], y: Sequence[float]) -> float:
    """Uniform sample covariance (divisor n, not n-1)."""
    mx, my = avg(x), avg(y)
    return sum((xi - mx) * (yi - my) for xi, yi in zip(x, y)) / len(x)


def var(x: Sequence[float]) -> float:
    """Uniform sample variance."""
    return cov(x, x)


def disp(x: Sequence[float]) -> float:
    """Dispersion index Var/mean; equals 1 for a Poisson sample."""
    return var(x) / avg(x)


def corr_sq(y: Sequence[float], s: Sequence[float]) -> float:
    """Squared sample correlation r^2(y, s)."""
    vy, vs = var(y), var(s)
    if vy <= 0.0 or vs <= 0.0:
        return 0.0
    return cov(y, s) ** 2 / (vy * vs)


# ----------------------------------------------------------------------------
# 2. Cells, ANOVA, explained fraction
# ----------------------------------------------------------------------------


def cell_means(x: Sequence[float], g: Sequence[int]) -> Dict[int, float]:
    """Mean of x inside each level set of the cell label g."""
    sums: Dict[int, float] = {}
    counts: Dict[int, int] = {}
    for xi, ki in zip(x, g):
        sums[ki] = sums.get(ki, 0.0) + xi
        counts[ki] = counts.get(ki, 0) + 1
    return {k: sums[k] / counts[k] for k in sums}


def within_var(x: Sequence[float], g: Sequence[int]) -> float:
    """Average squared deviation of each observation from its own cell mean."""
    m = cell_means(x, g)
    return sum((xi - m[ki]) ** 2 for xi, ki in zip(x, g)) / len(x)


def between_var(x: Sequence[float], g: Sequence[int]) -> float:
    """Average squared deviation of cell means from the grand mean."""
    m = cell_means(x, g)
    mu = avg(x)
    return sum((m[ki] - mu) ** 2 for ki in g) / len(x)


def eta_sq(x: Sequence[float], g: Sequence[int]) -> float:
    """Explained-variance fraction (correlation ratio) of the cell structure."""
    return between_var(x, g) / var(x)


def disp_within(x: Sequence[float], g: Sequence[int]) -> float:
    """Residual dispersion index after conditioning on the cells."""
    return within_var(x, g) / avg(x)


def mse_affine(y: Sequence[float], s: Sequence[float], a: float, b: float) -> float:
    """Mean squared error of the affine recalibration y ~ a + b*s."""
    return sum((yi - (a + b * si)) ** 2 for yi, si in zip(y, s)) / len(y)


def ols_coefficients(y: Sequence[float], s: Sequence[float]) -> Tuple[float, float]:
    """Least-squares intercept and slope for y ~ a + b*s."""
    b = cov(y, s) / var(s)
    a = avg(y) - b * avg(s)
    return a, b


# ----------------------------------------------------------------------------
# 3. A synthetic overdispersed sample with a partially-informative dial
# ----------------------------------------------------------------------------


def synthetic_sample(
    n: int = 128,
    base_rate: float = 76.7,
    dial_levels: int = 9,
    dial_strength: float = 0.115,
    extra_heterogeneity: float = 0.245,
    seed: int = 20260826,
) -> Tuple[List[float], List[int]]:
    """
    Build a count sample whose per-unit rate is driven partly by an observable
    dial and partly by an unobserved carrier, then draw Poisson counts.

    The dial value is an integer level in {0, ..., dial_levels-1}; the log rate
    is base + dial_strength * (centred dial) + extra_heterogeneity * noise.
    The default constants are tuned so that the resulting sample reproduces the
    empirical regime of interest: mean about 77 hits, dispersion index of order
    7, and a dial that explains roughly one seventh of the log-rate variance.
    Returns (counts, dial_levels_per_unit).
    """
    rng = random.Random(seed)
    counts: List[float] = []
    dials: List[int] = []
    centre = (dial_levels - 1) / 2.0
    scale = max(centre, 1.0)
    for _ in range(n):
        k = rng.randrange(dial_levels)
        z = (k - centre) / scale
        log_rate = math.log(base_rate) + dial_strength * z
        log_rate += extra_heterogeneity * rng.gauss(0.0, 1.0)
        lam = math.exp(log_rate)
        counts.append(float(poisson_draw(lam, rng)))
        dials.append(k)
    return counts, dials


def poisson_draw(lam: float, rng: random.Random) -> int:
    """Draw a Poisson variate (Knuth for small lambda, normal-ish for large)."""
    if lam < 30.0:
        target = math.exp(-lam)
        k, p = 0, 1.0
        while True:
            p *= rng.random()
            if p <= target:
                return k
            k += 1
    # Large lambda: transformed rejection is overkill here; use a
    # normal approximation with continuity correction, clipped at 0.
    val = int(round(rng.gauss(lam, math.sqrt(lam))))
    return max(val, 0)


# ----------------------------------------------------------------------------
# 4. The independent-character model for the two quadratic-residue dials
# ----------------------------------------------------------------------------


def indiv_count(u: Tuple[bool, bool]) -> float:
    """Per-prime individual-symbol contribution: how many of the two symbols are +1."""
    return (1.0 if u[0] else 0.0) + (1.0 if u[1] else 0.0)


def prod_count(u: Tuple[bool, bool]) -> float:
    """Per-prime product-symbol indicator: 1 iff N is a QR mod this prime."""
    return 1.0 if u[0] == u[1] else 0.0


def enumerate_patterns(k: int) -> Iterable[Tuple[Tuple[bool, bool], ...]]:
    """All 4^k sign patterns across k primes."""
    single = [(False, False), (False, True), (True, False), (True, True)]
    return itertools.product(single, repeat=k)


def exact_dial_covariance(k: int) -> float:
    """
    Brute-force covariance of (S_indiv, S_prod) over the uniform measure on all
    4^k sign patterns.  The theorem says this is exactly 0 for every k.
    """
    s_indiv: List[float] = []
    s_prod: List[float] = []
    for w in enumerate_patterns(k):
        s_indiv.append(sum(indiv_count(u) for u in w))
        s_prod.append(sum(prod_count(u) for u in w))
    return cov(s_indiv, s_prod)


# ----------------------------------------------------------------------------
# 5. Family capture budget, aggregation loss, window transfer
# ----------------------------------------------------------------------------


def gram_schmidt(dials: List[List[float]]) -> List[List[float]]:
    """Orthogonalise a family of dials w.r.t. the sample covariance inner product."""
    basis: List[List[float]] = []
    for s in dials:
        v = list(s)
        for b in basis:
            coef = cov(v, b) / var(b)
            v = [vi - coef * bi for vi, bi in zip(v, b)]
        if var(v) > 1e-12:
            basis.append(v)
    return basis


def family_budget(y: Sequence[float], dials: List[List[float]]) -> float:
    """Total squared correlation of a family of dials with the target."""
    return sum(corr_sq(y, s) for s in dials)


def mse_family(
    y: Sequence[float], dials: List[List[float]], a: float, b: Sequence[float]
) -> float:
    """Mean squared error of the joint affine recalibration y ~ a + sum_j b_j s_j."""
    n = len(y)
    total = 0.0
    for i in range(n):
        pred = a + sum(bj * s[i] for bj, s in zip(b, dials))
        total += (y[i] - pred) ** 2
    return total / n


def window_transfer_requirement(tested_cap: float, bar: float = 0.30) -> float:
    """How much aggregate squared correlation the untested window must supply."""
    return bar - tested_cap


def per_symbol_threshold(budget: float, window_size: int) -> float:
    """Pigeonhole floor: some single symbol must reach budget / window_size."""
    return budget / window_size


def carrier_dimension_lower_bound(cap: float, bar: float = 0.30) -> float:
    """Minimum number of orthogonal mechanisms of strength <= cap to reach the bar."""
    return bar / cap


# ----------------------------------------------------------------------------
# 6. Resolution cells for a booked anchor
# ----------------------------------------------------------------------------


def inv_law(p: float) -> float:
    """Illustrative amplification law with a pole at P = 1."""
    return 1.0 / (1.0 - p)


def resolution_cell(
    f: Callable[[float], float],
    window: Tuple[float, float],
    anchor: float,
    delta: float,
    grid: int = 2_000_001,
) -> Tuple[float, float]:
    """
    Numerically bracket the set { P in window : |f(P) - anchor| <= delta }
    by scanning a fine grid.  Returns (min compatible P, max compatible P).
    """
    lo, hi = window
    best_lo, best_hi = None, None
    for i in range(grid):
        p = lo + (hi - lo) * i / (grid - 1)
        if abs(f(p) - anchor) <= delta:
            if best_lo is None:
                best_lo = p
            best_hi = p
    if best_lo is None:
        raise ValueError("empty resolution cell on this grid")
    return best_lo, best_hi


def anchor_shift(lipschitz: float, eps: float) -> float:
    """Forward amplification bound: a P-discrepancy eps moves the anchor by <= L*eps."""
    return lipschitz * eps


def margin_stable(s_raw: float, s_a: float, margin: float, perturbation: float) -> bool:
    """A perturbation below the recorded margin cannot break feasibility."""
    return perturbation <= margin and s_raw <= s_a - perturbation


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def rule(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_dispersion_identity() -> None:
    rule("1.  The dispersion-reduction identity  (D - D_within)/D = eta^2")
    counts, dials = synthetic_sample()
    d = disp(counts)
    dw = disp_within(counts, dials)
    e2 = eta_sq(counts, dials)
    print(f"  n                       = {len(counts)}")
    print(f"  mean                    = {avg(counts):.4f}")
    print(f"  raw dispersion  D       = {d:.6f}   (Poisson would give 1)")
    print(f"  residual        D_within= {dw:.6f}")
    print(f"  explained fraction eta^2= {e2:.6f}")
    lhs = (d - dw) / d
    print(f"  (D - D_within)/D        = {lhs:.12f}")
    print(f"  eta^2                   = {e2:.12f}")
    print(f"  identity holds to       = {abs(lhs - e2):.3e}")
    # ANOVA identity
    print(
        f"  ANOVA: Var - (within + between) = "
        f"{var(counts) - within_var(counts, dials) - between_var(counts, dials):.3e}"
    )


def demo_capture_bounds() -> None:
    rule("2.  Linear capture bound, OLS tightness, and r^2 <= eta^2")
    counts, dials = synthetic_sample()
    s = [float(k) for k in dials]
    r2 = corr_sq(counts, s)
    e2 = eta_sq(counts, dials)
    floor = (1.0 - r2) * var(counts)
    a_star, b_star = ols_coefficients(counts, s)
    print(f"  r^2(y, s)               = {r2:.6f}")
    print(f"  eta^2(y | cells)        = {e2:.6f}")
    print(f"  r^2 <= eta^2            : {r2 <= e2 + 1e-12}")
    print(f"  Var(y)                  = {var(counts):.4f}")
    print(f"  linear residual floor   = {floor:.6f}")
    print(f"  MSE at OLS (a*,b*)      = {mse_affine(counts, s, a_star, b_star):.6f}")
    print("  MSE at 200 random (a,b) — none may go below the floor:")
    rng = random.Random(7)
    worst = math.inf
    for _ in range(200):
        a = a_star + rng.gauss(0.0, 20.0)
        b = b_star + rng.gauss(0.0, 5.0)
        worst = min(worst, mse_affine(counts, s, a, b))
    print(f"    minimum MSE observed  = {worst:.6f}  (floor {floor:.6f})")
    print(f"    bound respected       : {worst >= floor - 1e-9}")
    print("  cell-mean predictor beats every alternative cell-wise predictor:")
    cm = within_var(counts, dials)
    rng2 = random.Random(11)
    beaten = True
    for _ in range(200):
        h = {k: v + rng2.gauss(0.0, 8.0) for k, v in cell_means(counts, dials).items()}
        alt = sum((xi - h[ki]) ** 2 for xi, ki in zip(counts, dials)) / len(counts)
        beaten &= cm <= alt + 1e-12
    print(f"    within-cell MSE       = {cm:.6f};  never beaten: {beaten}")


def demo_certified_readings() -> None:
    rule("3.  Certified numeric readings of the experiment")
    d_raw = 7.27
    eta_cap = 0.1422
    d_within_floor = (1.0 - eta_cap) * d_raw
    print(f"  D_raw                        = {d_raw}")
    print(f"  best dial explained fraction = {eta_cap}   (14.22%)")
    print(f"  residual dispersion floor    = {d_within_floor:.6f}  >= 6.23  "
          f"{d_within_floor >= 6.23}")
    excess = d_raw - 1.0
    resid_excess = d_within_floor - 1.0
    print(f"  Poisson excess  D - 1        = {excess:.4f}")
    print(f"  surviving excess             = {resid_excess:.4f}")
    print(f"  surviving fraction           = {resid_excess / excess:.6f}  >= 0.83  "
          f"{resid_excess / excess >= 0.83}")
    print(f"  H1 bar was a 30% dispersion reduction; best achieved is "
          f"{100 * eta_cap:.2f}%.")
    print("  Every dial reading, against the bar:")
    for name, r2, dred in [
        ("individual-symbol, l <= 100", 0.0127, 0.0088),
        ("product-symbol,    l <= 100", 0.0781, 0.1422),
        ("wider form,        l <= 400", 0.0565, 0.0907),
    ]:
        print(f"    {name}:  R^2 = {r2:.4f} (bar 0.25),  D-red = "
              f"{100*dred:5.2f}% (bar 30%)  -> MISS")


def demo_exact_orthogonality() -> None:
    rule("4.  Exact orthogonality of the two quadratic-residue dials")
    print("  Single-prime table over the four sign patterns:")
    print("    pattern     iota  centred   pi   centred   product")
    for u in [(True, True), (True, False), (False, True), (False, False)]:
        ic, pc = indiv_count(u), prod_count(u)
        print(f"    {str(u):<12} {ic:.0f}     {ic - 1:+.1f}    {pc:.0f}    "
              f"{pc - 0.5:+.1f}      {(ic - 1) * (pc - 0.5):+.2f}")
    total = sum(
        (indiv_count(u) - 1) * (prod_count(u) - 0.5)
        for u in [(True, True), (True, False), (False, True), (False, False)]
    )
    print(f"    single-prime inner product = {total:+.1f}   (odd x even = 0)")
    print()
    print("  Brute-force covariance over all 4^k patterns:")
    for k in range(0, 7):
        c = exact_dial_covariance(k)
        print(f"    k = {k:2d}   patterns = {4**k:7d}   Cov(S_indiv, S_prod) = {c:+.3e}")
    print("  (Measured in the experiment: r = -0.01, a sampling artifact around")
    print("   an exact zero.  The dials are complementary, so their shares ADD.)")
    r1, r2 = 0.0127, 0.0781
    print(f"  joint ceiling r1^2 + r2^2 = {r1 + r2:.4f};  residual fraction "
          f"= {1 - r1 - r2:.4f}")


def demo_family_ceiling() -> None:
    rule("5.  Family capture ceiling, Bessel inequality, aggregation loss")
    rng = random.Random(2026)
    n = 128
    raw = [[rng.gauss(0.0, 1.0) for _ in range(n)] for _ in range(6)]
    dials = gram_schmidt(raw)
    y = [
        0.7 * dials[0][i] + 0.4 * dials[1][i] + 1.6 * rng.gauss(0.0, 1.0)
        for i in range(n)
    ]
    shares = [corr_sq(y, s) for s in dials]
    budget = sum(shares)
    print("  orthogonal family of %d dials; individual shares:" % len(dials))
    for j, sh in enumerate(shares):
        print(f"    r_{j}^2 = {sh:.6f}")
    print(f"  budget  sum_j r_j^2      = {budget:.6f}   <= 1 : {budget <= 1.0}")
    # coordinatewise OLS attains the ceiling
    b = [cov(y, s) / var(s) for s in dials]
    a = avg(y) - sum(bj * avg(s) for bj, s in zip(b, dials))
    predicted_floor = (1.0 - budget) * var(y)
    achieved = mse_family(y, dials, a, b)
    print(f"  Var(y)                   = {var(y):.6f}")
    print(f"  family residual floor    = {predicted_floor:.6f}")
    print(f"  MSE at coordinatewise OLS= {achieved:.6f}   (equality: "
          f"{abs(achieved - predicted_floor) < 1e-9})")
    # aggregation loses
    aggregate = [sum(s[i] for s in dials) for i in range(n)]
    print(f"  r^2(y, sum_j s_j)        = {corr_sq(y, aggregate):.6f}")
    print(f"  <= sum_j r_j^2           = {budget:.6f} : "
          f"{corr_sq(y, aggregate) <= budget + 1e-12}")
    print()
    print("  Decision rule for the prime-window extension:")
    tested = 0.1422
    need = window_transfer_requirement(tested)
    window = 78_498
    thresh = per_symbol_threshold(need, window)
    print(f"    tested window (l <= 400) capped at      {tested}")
    print(f"    bar                                     0.30")
    print(f"    extension window must supply            {need:.4f}")
    print(f"    primes in 400 < l <= 10^6 (at most)     {window}")
    print(f"    forced per-symbol floor                 {thresh:.3e}  >= 2e-6 : "
          f"{thresh >= 2e-6}")
    cap = 0.0781
    dim = carrier_dimension_lower_bound(cap)
    print(f"    carrier dimension at strength {cap}:      >= {dim:.4f}  ->  "
          f"at least {math.ceil(dim)} mechanisms")


def demo_resolution_cell() -> None:
    rule("6.  Resolution-limited inversion of a booked anchor")
    window = (0.98, 0.99)
    m_exp, l_lip = 2500.0, 10000.0
    p0 = 0.985
    anchor = inv_law(p0)
    delta = 2.0e-4
    lo, hi = resolution_cell(inv_law, window, anchor, delta, grid=400_001)
    print(f"  law f(P) = 1/(1-P) on [{window[0]}, {window[1]}]")
    print(f"  expansive rate m = {m_exp:.0f},  Lipschitz rate L = {l_lip:.0f}")
    print(f"  exact preimage P0 = {p0},  anchor R = f(P0) = {anchor:.6f}")
    print(f"  precision delta   = {delta:.1e}")
    print(f"  numerically scanned cell = [{lo:.9f}, {hi:.9f}]")
    print(f"  observed cell width      = {hi - lo:.6e}")
    print(f"  theory: width <= 2d/m    = {2 * delta / m_exp:.6e}   "
          f"({hi - lo <= 2 * delta / m_exp + 1e-9})")
    print(f"  theory: width >= 2d/L    = {2 * delta / l_lip:.6e}   "
          f"({hi - lo >= 2 * delta / l_lip - 1e-9})")
    print("  => the cell is a genuine interval, not a point.")
    print()
    print("  Printed-anchor overstatement at the 29.1x locus:")
    booked, certified = 0.9853, 0.985068
    eps = booked - certified
    l_local = 826.0
    shift = anchor_shift(l_local, eps)
    print(f"    booked P-hat     = {booked}")
    print(f"    certified P-hat  = {certified}")
    print(f"    discrepancy eps  = {eps:.3e}")
    print(f"    local sensitivity L = {l_local:.0f}")
    print(f"    anchor shift <= L*eps = {shift:.6f}  <= 0.192 : {shift <= 0.192}")
    print(f"    printed 29.3152 vs certified 29.1254 -> drift "
          f"{29.3152 - 29.125436718134:.4f}")
    print()
    print("  All four booked loci, full-precision anchors and implied probabilities:")
    loci = [
        (5.193592154916, 0.841617, 0.212),
        (6.914724537168, 0.894868, 0.242),
        (4.353075657862, 0.800308, 0.183),
        (29.125436718134, 0.985068, 0.190),
    ]
    perturbation = 0.18
    for anchor_val, phat, margin in loci:
        ok = margin_stable(s_raw=1.0, s_a=1.0 + margin, margin=margin,
                           perturbation=perturbation)
        print(f"    anchor {anchor_val:>16.12f}   implied P-hat {phat:.6f}   "
              f"margin {margin:.3f}   feasible after rebooking: {ok}")
    print(f"  perturbation {perturbation} is below every recorded margin "
          f"-> all four hold.")


def main() -> None:
    print(__doc__.split("Run with:")[0].rstrip())
    demo_dispersion_identity()
    demo_capture_bounds()
    demo_certified_readings()
    demo_exact_orthogonality()
    demo_family_ceiling()
    demo_resolution_cell()
    rule("Summary")
    print("  * The two acceptance legs are the single scalar eta^2.")
    print("  * No affine or cell-wise recalibration beats eta^2; r^2 <= eta^2.")
    print("  * D_raw = 7.27 with eta^2 <= 0.1422 leaves D_within >= 6.23 and")
    print("    at least 83% of the Poisson excess unexplained.")
    print("  * The two deployed dials are exactly uncorrelated, so their shares add")
    print("    to a joint ceiling of about 9%.")
    print("  * The orthogonal-family budget is capped at 1; the l <= 10^6 extension")
    print("    must supply 0.1578, forcing one symbol to reach r^2 >= 2e-6.")
    print("  * Booked anchors recovered by inversion are pinned only to a cell of")
    print("    width between 2d/L and 2d/m; all four feasibility margins survive.")


if __name__ == "__main__":
    main()
