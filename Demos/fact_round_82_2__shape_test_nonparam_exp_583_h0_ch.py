"""Amplitude-Scaling Discriminator: is an observed bump leakage or a real mode?

The leakage mechanism makes two independent predictions about an endpoint-matched
residual bump:

  (i)  its height is EXACTLY proportional to the curvature mismatch d, with slope
       log(L/A) - 1 + A/L, where A = 1+l and L is the logarithmic mean of the
       window edges;
  (ii) its location does NOT depend on d at all.

The test injects a controlled curvature perturbation into the baseline exponent,
recomputes the edge-matched residual, and checks both predictions.  A genuine
positional mode fails at least one of them.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Callable, List, Sequence, Tuple


def log_mean(A: float, B: float) -> float:
    return A if abs(B - A) < 1e-15 else (B - A) / (math.log(B) - math.log(A))


def matching_tilt(d: float, l: float, u: float) -> float:
    """Tilt making the log-residual agree at both window edges."""
    return -d * (math.log(1.0 + u) - math.log(1.0 + l)) / (u - l)


def log_residual(d: float, b: float, x: float) -> float:
    return d * math.log(1.0 + x) + b * x


def argmax_on_grid(f: Callable[[float], float], l: float, u: float,
                   n: int = 100001) -> Tuple[float, float]:
    best_x, best_v = l, f(l)
    for i in range(n):
        x = l + (u - l) * i / (n - 1)
        v = f(x)
        if v > best_v:
            best_x, best_v = x, v
    return best_x, best_v


@dataclass(frozen=True)
class ScalingReport:
    mismatches: List[float]
    heights: List[float]
    locations: List[float]
    fitted_slope: float
    predicted_slope: float
    location_spread: float
    verdict: str


def amplitude_scaling_test(l: float, u: float,
                           mismatches: Sequence[float] = (0.05, 0.1, 0.2, 0.4, 0.8),
                           slope_tol: float = 1e-6,
                           location_tol: float = 1e-4) -> ScalingReport:
    """Run the discriminator on the analytic residual for the window [l, u]."""
    A, B = 1.0 + l, 1.0 + u
    L = log_mean(A, B)
    predicted_slope = math.log(L / A) - 1.0 + A / L

    heights: List[float] = []
    locations: List[float] = []
    for d in mismatches:
        b = matching_tilt(d, l, u)
        x_max, v_max = argmax_on_grid(lambda x: log_residual(d, b, x), l, u)
        heights.append(v_max - log_residual(d, b, l))
        locations.append(x_max)

    # least-squares slope through the origin: sum(d*h) / sum(d*d)
    num = sum(d * h for d, h in zip(mismatches, heights))
    den = sum(d * d for d in mismatches)
    fitted_slope = num / den
    spread = max(locations) - min(locations)

    linear = abs(fitted_slope - predicted_slope) < slope_tol
    immobile = spread < location_tol
    if linear and immobile:
        verdict = "LEAKAGE: height linear in the mismatch, location immobile"
    elif immobile:
        verdict = "NOT LEAKAGE: location immobile but height does not scale"
    else:
        verdict = "NOT LEAKAGE: the peak moves with the mismatch"

    return ScalingReport(list(mismatches), heights, locations,
                         fitted_slope, predicted_slope, spread, verdict)


if __name__ == "__main__":
    rep = amplitude_scaling_test(0.0, 1.0)
    print(f"{'d':>8} {'height':>14} {'location':>12}")
    for d, h, x in zip(rep.mismatches, rep.heights, rep.locations):
        print(f"{d:8.3f} {h:14.8f} {x:12.8f}")
    print(f"\nfitted slope    : {rep.fitted_slope:.10f}")
    print(f"predicted slope : {rep.predicted_slope:.10f}")
    print(f"location spread : {rep.location_spread:.2e}")
    print(rep.verdict)


"""Logarithmic-Mean Ghost Locator: predicting where a leakage artefact must sit.

Given only the window [l, u] (no data), this returns the exact location that an
endpoint-matched curvature-leakage artefact must occupy, together with the
two-sided trap (geometric mean, midpoint) inside which it is confined.

Because the prediction is made *before* inspecting the residual, it functions as
a falsifier: an interior peak found outside the trap cannot be leakage of this
kind.
"""

from __future__ import annotations

import math
from dataclasses import dataclass


@dataclass(frozen=True)
class GhostPrediction:
    """Prediction for an endpoint-matched curvature-leakage artefact."""
    window: tuple[float, float]
    location: float           # x* = L(1+l, 1+u) - 1
    lower_bound: float        # geometric mean of the edges, shifted
    upper_bound: float        # window midpoint
    window_fraction: float    # (x* - l) / (u - l), always in (0, 1/2)
    unit_amplitude: float     # bump height per unit curvature mismatch

    def contains(self, x: float) -> bool:
        """Is a candidate peak position compatible with the leakage mechanism?"""
        return self.lower_bound < x < self.upper_bound

    def amplitude(self, mismatch: float) -> float:
        """Predicted bump height for a given curvature mismatch d = a' - a."""
        return mismatch * self.unit_amplitude


def log_mean(A: float, B: float) -> float:
    """Logarithmic mean (B - A) / (log B - log A) for 0 < A < B."""
    if A <= 0.0 or B <= 0.0:
        raise ValueError("logarithmic mean requires positive arguments")
    if abs(B - A) < 1e-15:
        return A
    return (B - A) / (math.log(B) - math.log(A))


def locate_ghost(l: float, u: float) -> GhostPrediction:
    """Locate the leakage ghost for the window [l, u], with -1 < l < u."""
    if not (-1.0 < l < u):
        raise ValueError("require -1 < l < u")
    A, B = 1.0 + l, 1.0 + u
    L = log_mean(A, B)
    x_star = L - 1.0
    return GhostPrediction(
        window=(l, u),
        location=x_star,
        lower_bound=math.sqrt(A * B) - 1.0,
        upper_bound=0.5 * (l + u),
        window_fraction=(x_star - l) / (u - l),
        unit_amplitude=math.log(L / A) - 1.0 + A / L,
    )


if __name__ == "__main__":
    for window in ((0.0, 1.0), (0.02, 1.0), (0.0, 9.0), (1.0, 100.0)):
        p = locate_ghost(*window)
        print(f"window {p.window}:  x* = {p.location:.6f}  in "
              f"({p.lower_bound:.6f}, {p.upper_bound:.6f}), "
              f"fraction {p.window_fraction:.4f}, "
              f"amplitude per unit mismatch {p.unit_amplitude:.6f}")
        print(f"    a peak at the 65% point would be leakage? "
              f"{p.contains(p.window[0] + 0.65 * (p.window[1] - p.window[0]))}")


"""Shape-Channel Verdict Procedure: separating curvature from location.

A likelihood-ratio test against a linear model measures CURVATURE; the position
of the profile's maximum measures LOCATION.  Conflating the two is the fallacy
this procedure prevents.

The procedure reports:
  * the curvature verdict (from the likelihood-ratio statistic and its
    permutation calibration);
  * the location verdict (from the bootstrap distribution of the argmax);
  * the combined shape verdict, which declares a positional mode only when the
    argmax is interior with a stable bootstrap distribution.

A bootstrap argmax pinned at an edge closes the mode channel no matter how
extreme the likelihood-ratio statistic is.
"""

from __future__ import annotations

import math
import random
from dataclasses import dataclass
from typing import Callable, List, Sequence, Tuple


@dataclass(frozen=True)
class ShapeVerdict:
    lrt_stat: float
    perm_exceedances: int
    perm_reps: int
    argmax_estimate: float
    argmax_ci: Tuple[float, float]
    edge_pinned_fraction: float
    curvature_verdict: str
    location_verdict: str
    combined: str


def profile_argmax(profile: Sequence[float], grid: Sequence[float]) -> float:
    """Argmax of a tabulated profile."""
    k = max(range(len(profile)), key=lambda i: profile[i])
    return grid[k]


def bootstrap_argmax(sampler: Callable[[random.Random], List[float]],
                     grid: Sequence[float], reps: int,
                     seed: int = 20260904) -> List[float]:
    """Bootstrap distribution of the profile argmax."""
    rng = random.Random(seed)
    return [profile_argmax(sampler(rng), grid) for _ in range(reps)]


def shape_verdict(lrt_stat: float, perm_exceedances: int, perm_reps: int,
                  argmax_draws: Sequence[float], l: float, u: float,
                  registered_band: Tuple[float, float] = (0.4, 0.8),
                  edge_tol_fraction: float = 0.02) -> ShapeVerdict:
    """Combine the curvature and location channels into a single verdict."""
    draws = sorted(argmax_draws)
    n = len(draws)
    lo = draws[max(0, int(0.025 * n) - 1)]
    hi = draws[min(n - 1, int(0.975 * n))]
    point = draws[n // 2]

    span = u - l
    edge_tol = edge_tol_fraction * span
    pinned = sum(1 for x in draws if x <= l + edge_tol or x >= u - edge_tol) / n

    perm_p = (perm_exceedances + 1) / (perm_reps + 1)
    curvature = ("NONLINEAR: linear model rejected"
                 if perm_p <= 0.05 else "no evidence against linearity")

    band_lo = l + registered_band[0] * span
    band_hi = l + registered_band[1] * span
    if pinned >= 0.5:
        location = ("EDGE-PINNED: the maximum sits at a window edge; "
                    "no interior mode")
    elif band_lo <= point <= band_hi:
        location = "INTERIOR MODE inside the registered band"
    else:
        location = "interior maximum, but outside the registered band"

    if pinned >= 0.5:
        combined = ("MONOTONE DECLINE. Nonlinearity, however significant, is "
                    "curvature only: the mode channel closes.")
    elif band_lo <= point <= band_hi:
        combined = "POSITIONAL MODE claim supported; test for baseline leakage next."
    else:
        combined = "Interior maximum outside the registered band; claim not supported."

    return ShapeVerdict(lrt_stat, perm_exceedances, perm_reps, point, (lo, hi),
                        pinned, curvature, location, combined)


if __name__ == "__main__":
    # The recorded absolute-shape channel: enormous curvature signal, argmax
    # pinned at the left edge in every bootstrap replicate.
    draws = [0.020] * 150
    v = shape_verdict(lrt_stat=100.574, perm_exceedances=0, perm_reps=400,
                      argmax_draws=draws, l=0.020, u=1.000)
    print(f"LRT               : {v.lrt_stat} ({v.perm_exceedances}/{v.perm_reps} "
          f"permutation exceedances)")
    print(f"argmax            : {v.argmax_estimate} CI {v.argmax_ci}")
    print(f"edge-pinned share : {v.edge_pinned_fraction:.3f}")
    print(f"curvature verdict : {v.curvature_verdict}")
    print(f"location verdict  : {v.location_verdict}")
    print(f"combined          : {v.combined}")


"""Assemble PACKAGE.json from the individual deliverables in this project."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Novelty/ShapeTestMonotoneDecline.lean",
    "Catalog/Novelty/ShapeGhostPeakBounds.lean",
    "Catalog/Novelty/ShapeBinningInvariance.lean",
]

lean_proofs = "\n\n".join(
    f"-- FILE: {f}\n{read(ROOT / f)}" for f in LEAN_FILES
)

FUTURE_DIRECTIONS = read(A / "pkg_future_directions.md")
INTERACTIVE_LAYOUT = read(A / "pkg_interactive_layout.md")

package = {
    "title": "The Ghost in the Baseline: Monotone Decline, Interior Modes, "
             "and the Logarithmic-Mean Location of Curvature Leakage",
    "domain": "Novelty",
    "description": (
        "A shape/leakage decomposition for positional rate profiles: the power law "
        "T(x) = C(1+x)^(-a) is genuinely nonlinear yet provably free of interior modes, "
        "while an endpoint-matched residual against a more-curved baseline manufactures a "
        "strict interior peak located exactly at the logarithmic mean of the window edges, "
        "trapped in the left half of the window and with amplitude exactly proportional to "
        "the curvature mismatch."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-25",
    "key_results": [
        "Nonlinearity without a mode: the power-law rate T(x) = C(1+x)^(-a) with C, a > 0 has a "
        "strictly convex log-rate, so no affine model fits it on any window, yet it is strictly "
        "decreasing and therefore has no interior maximum — a decisive rejection of linearity "
        "carries no information about the location of a peak.",
        "Baseline curvature leakage: against a baseline C'(1+x)^(-a')e^(-bx) whose curvature "
        "exceeds the signal's (d = a' - a > 0), the edge-matched log-residual acquires a strict "
        "interior maximum located exactly at the logarithmic mean of the window edges, "
        "1 + x* = (u - l)/(log(1+u) - log(1+l)), independently of the size of the mismatch.",
        "The left-half trap and its falsifier: the manufactured peak always lies strictly between "
        "the geometric mean of the window edges and the window midpoint, so an interior peak "
        "observed in the right half of the window cannot be produced by endpoint-matched "
        "curvature leakage.",
        "Amplitude law: the bump height equals d·[log(L/A) − 1 + A/L] with A = 1+l and L the "
        "logarithmic mean — exactly proportional to the curvature mismatch, while its location is "
        "entirely independent of it; and the sign of the mismatch decides bump versus no bump, "
        "since an under-curved baseline yields a convex residual with no interior maximum for any tilt.",
        "Binning invariance: equal-width block averages of a continuous strictly declining shape "
        "are strictly declining for every bin width, so no coarse-graining can manufacture an "
        "interior peak that the underlying shape does not have.",
    ],
    "keywords": [
        "power-law rate profile",
        "interior mode",
        "logarithmic mean",
        "baseline misspecification",
        "curvature leakage",
        "likelihood-ratio test",
        "binning invariance",
        "Dickman-type decline",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "Shape/Leakage Decomposition: A Seven-Part Numerical Tour",
            "description": (
                "A dependency-free numerical companion that verifies every result of the theory. "
                "It confirms that the power law T(x) = 0.0295(1+x)^(-1.104) is strictly decreasing "
                "with its maximum at the left edge while the best affine fit to its log-rate leaves "
                "an irreducible misfit; recovers the exponent exactly from peak-to-end ratios across "
                "four windows via a = log R / log rho and exercises the steepness criterion R > rho "
                "<=> a > 1; builds an explicit curvature-mismatched baseline, verifies that the "
                "edge-matched log-residual agrees at both window edges and that its numerical argmax "
                "coincides with the logarithmic mean to eight digits; tabulates the two-sided trap "
                "(geometric mean, midpoint) for five windows of increasing ratio; demonstrates that "
                "the bump height is exactly linear in the curvature mismatch while the location does "
                "not move at all; shows that a non-positive mismatch admits no interior maximum for "
                "any of seven tilts; verifies binning invariance by Simpson quadrature of equal-width "
                "block averages at five bin widths; and finally runs the full verdict pipeline on five "
                "synthetic profiles, correctly classifying each as monotone, trap-compatible leakage, "
                "or a right-half peak that excludes leakage."
            ),
            "code": read(ROOT / "demo.py"),
        }
    ],
    "algorithms": [
        {
            "name": "Logarithmic-Mean Ghost Locator",
            "description": (
                "Given only the window [l, u] — before any residual is inspected — this procedure "
                "returns the exact position an endpoint-matched curvature-leakage artefact must "
                "occupy, together with the two-sided interval that confines it. The mathematical "
                "foundation is the stationarity condition of the log-residual d·log(1+x) + b·x: with "
                "the edge-matching tilt b* = -d[log(1+u) - log(1+l)]/(u-l), the mismatch d cancels "
                "and the stationary point becomes 1 + x* = (u-l)/(log(1+u) - log(1+l)), the "
                "logarithmic mean of the shifted edges. The mean inequality chain GM < LM < AM — "
                "equivalent, in the normal form B = A·e^(2s), to s < sinh s and tanh s < s — confines "
                "x* strictly between sqrt((1+l)(1+u)) - 1 and (l+u)/2, hence to the left half of the "
                "window. The routine also returns the amplitude slope log(L/A) - 1 + A/L, so that the "
                "predicted bump height for any mismatch follows by one multiplication. Complexity: "
                "O(1) — a handful of logarithms and a square root, with no data access at all, which "
                "is precisely what makes the output a genuine pre-registered falsifier."
            ),
            "pseudocode": (
                "procedure LOCATE-GHOST(l, u)\n"
                "  require -1 < l < u\n"
                "  A <- 1 + l                                  # shifted left edge\n"
                "  B <- 1 + u                                  # shifted right edge\n"
                "  L <- (B - A) / (log B - log A)              # logarithmic mean\n"
                "  x_star <- L - 1                             # predicted ghost location\n"
                "  lower  <- sqrt(A * B) - 1                   # geometric-mean bound\n"
                "  upper  <- (l + u) / 2                       # window midpoint\n"
                "  assert lower < x_star < upper               # guaranteed by GM < LM < AM\n"
                "  frac   <- (x_star - l) / (u - l)            # always in (0, 1/2)\n"
                "  slope  <- log(L / A) - 1 + A / L            # amplitude per unit mismatch\n"
                "  return (x_star, lower, upper, frac, slope)\n"
                "\n"
                "procedure COMPATIBLE(prediction, x_observed)\n"
                "  return prediction.lower < x_observed < prediction.upper\n"
                "\n"
                "procedure PREDICTED-HEIGHT(prediction, d)\n"
                "  return d * prediction.slope"
            ),
            "code": read(A / "alg_ghost_locator.py"),
        },
        {
            "name": "Amplitude-Scaling Discriminator for Baseline Leakage",
            "description": (
                "A decisive experimental protocol separating a leakage artefact from a genuine "
                "positional mode. The leakage mechanism makes two independent predictions: the bump "
                "height is exactly proportional to the curvature mismatch d, with the closed-form "
                "slope log(L/A) - 1 + A/L; and the bump location, being the logarithmic mean of the "
                "window edges, does not depend on d at all. The discriminator injects a ladder of "
                "controlled curvature perturbations into the baseline exponent, recomputes the "
                "edge-matched residual at each level, extracts height and argmax, fits a "
                "through-the-origin regression of height on mismatch, and compares the fitted slope "
                "with the closed form while checking that the argmax spread is numerically zero. A "
                "genuine mode fails at least one test: it either does not scale, or it moves. "
                "Complexity: O(K·G) for K perturbation levels and grid resolution G, or O(K) if the "
                "argmax is taken analytically."
            ),
            "pseudocode": (
                "procedure AMPLITUDE-SCALING-TEST(l, u, D = [d_1, ..., d_K], tol_slope, tol_loc)\n"
                "  A <- 1 + l;  B <- 1 + u\n"
                "  L <- (B - A) / (log B - log A)\n"
                "  predicted_slope <- log(L / A) - 1 + A / L\n"
                "  for k = 1 to K do\n"
                "     b_k     <- -d_k * (log B - log A) / (u - l)          # edge-matching tilt\n"
                "     r_k(x)  <- d_k * log(1 + x) + b_k * x\n"
                "     x_k     <- argmax of r_k over [l, u]\n"
                "     h_k     <- r_k(x_k) - r_k(l)                          # bump height\n"
                "  fitted_slope <- (sum_k d_k * h_k) / (sum_k d_k^2)        # regression through 0\n"
                "  spread       <- max_k x_k - min_k x_k\n"
                "  if |fitted_slope - predicted_slope| < tol_slope and spread < tol_loc then\n"
                "     return LEAKAGE\n"
                "  else if spread < tol_loc then\n"
                "     return NOT-LEAKAGE (height does not scale)\n"
                "  else\n"
                "     return NOT-LEAKAGE (the peak moves)"
            ),
            "code": read(A / "alg_amplitude_scaling_test.py"),
        },
        {
            "name": "Shape-Channel Verdict Procedure: Separating Curvature from Location",
            "description": (
                "The procedure that prevents the central fallacy. It runs two logically independent "
                "channels and refuses to let one speak for the other. The curvature channel reports "
                "the likelihood-ratio statistic of a free smooth log-rate against a linear-in-x null, "
                "calibrated by within-stratum label permutations; because a power law has a strictly "
                "convex log-rate, this channel must reject asymptotically whenever the truth is any "
                "power law, so its verdict is 'nonlinear' and nothing more. The location channel "
                "bootstraps the argmax of the fitted profile over the window and measures the share "
                "of replicates in which the argmax is pinned within a small tolerance of an edge. The "
                "combined verdict declares a positional mode only when the argmax is interior, stable "
                "across replicates, and inside the pre-registered band; an edge-pinned bootstrap "
                "distribution closes the mode channel regardless of how extreme the likelihood ratio "
                "is. Complexity: O(R·N) for R bootstrap replicates over N observations, plus O(B·N) "
                "for B permutation replicates."
            ),
            "pseudocode": (
                "procedure SHAPE-VERDICT(profile_fit, data, window [l,u], band, R, B)\n"
                "  # -- curvature channel ---------------------------------------------\n"
                "  LRT      <- 2 * (loglik(free spline) - loglik(linear in x))\n"
                "  for j = 1 to B do\n"
                "     LRT_j <- LRT recomputed on within-stratum permuted labels\n"
                "  perm_p   <- (#{ j : LRT_j >= LRT } + 1) / (B + 1)\n"
                "  curvature <- (perm_p <= 0.05) ? NONLINEAR : NO-EVIDENCE\n"
                "  # -- location channel ----------------------------------------------\n"
                "  for r = 1 to R do\n"
                "     x_r   <- argmax over [l,u] of the profile fitted to bootstrap sample r\n"
                "  point    <- median{ x_r };  CI <- 2.5% and 97.5% quantiles of { x_r }\n"
                "  pinned   <- fraction of x_r within tol*(u-l) of an edge\n"
                "  # -- combination -----------------------------------------------------\n"
                "  if pinned >= 1/2 then\n"
                "     return MONOTONE DECLINE  (curvature only; the mode channel closes)\n"
                "  else if point lies inside the pre-registered band then\n"
                "     return POSITIONAL MODE supported -> now run the leakage tests\n"
                "  else\n"
                "     return interior maximum outside the registered band; claim unsupported"
            ),
            "code": read(A / "alg_shape_verdict.py"),
        },
    ],
    "visualizations": [
        {
            "name": "Anatomy of a Leakage Ghost: Signal, Baseline, Residual, Amplitude Law",
            "description": (
                "A three-panel figure telling the whole leakage story at a glance. The top panel "
                "draws the power-law signal and a curvature-mismatched baseline, both strictly "
                "declining and visually almost indistinguishable — neither has an interior peak. The "
                "middle panel shows their edge-matched log-residual bulging into a clean interior "
                "maximum, with the predicted logarithmic-mean location marked and the two-sided trap "
                "(geometric mean to midpoint) shaded, making visible that the ghost lives strictly in "
                "the left half of the window. The bottom panel sweeps the curvature mismatch across "
                "sixteen values and overlays the measured bump heights on the closed-form prediction "
                "d·[log(L/A) − 1 + A/L], while a second axis records the peak location, which sits on "
                "a perfectly flat line: the height scales, the position never moves."
            ),
            "code": read(A / "viz_ghost_anatomy.py"),
        },
        {
            "name": "The Mean-Inequality Trap and the Innocence of Binning",
            "description": (
                "A two-panel figure. The left panel plots the geometric, logarithmic and arithmetic "
                "means of the shifted window edges as functions of the window ratio, with the band "
                "between the outer two shaded: the logarithmic mean — the ghost — is pinned inside it "
                "for every ratio. A dotted overlay gives the ghost's position as a fraction of the "
                "window, showing it approach one half only in the limit of a vanishingly narrow "
                "window and crowd the left edge as the window widens, so that the fraction never "
                "reaches one half. The right panel superimposes equal-width block averages at three "
                "bin widths on the declining power law and asserts strict decline of the block means "
                "at each resolution, illustrating that coarse-graining can attenuate a feature but "
                "cannot create one."
            ),
            "code": read(A / "viz_mean_trap_and_binning.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Ghost Hunter — Try to Push the Peak Past the Midpoint",
            "description": (
                "The centrepiece widget. Sliders control the signal exponent a, the curvature "
                "mismatch d = a' − a, and both window edges. The upper canvas draws the signal and "
                "the baseline, both strictly declining; the lower canvas draws their edge-matched "
                "log-residual, with the manufactured peak marked and the trap between the geometric "
                "mean and the midpoint shaded. A live readout reports the window ratio, the "
                "geometric-mean bound, the logarithmic-mean location, the midpoint, the ghost's "
                "position as a percentage of the window, the matching tilt, and the bump amplitude "
                "with its per-unit-mismatch slope. A 'double the mismatch' button makes the amplitude "
                "law tangible: the bump doubles in height and does not budge. Setting d below zero "
                "flips the residual to convex and the maximum jumps to an edge, demonstrating the "
                "sign dichotomy. No matter how the sliders are moved, the ghost's position stays "
                "below fifty percent of the window — the left-half trap made visceral."
            ),
            "html": read(A / "widget_ghost_hunter.html"),
        },
        {
            "title": "Curvature Is Not Location — A Tiny p-Value with No Peak in Sight",
            "description": (
                "An interactive dismantling of the central fallacy. Sliders control the power-law "
                "exponent, the window width, and the number of bins. The upper canvas plots the "
                "log-rate against its best least-squares straight line and shades the irreducible "
                "gap between them: the misfit that a linearity test converts into an arbitrarily "
                "small p-value as data accumulate. The lower canvas plots the rate itself with its "
                "block averages superimposed, and marks the maximum, which is always at the left "
                "edge. A readout gives the peak-to-end ratio, the window ratio, the exponent "
                "recovered exactly as log R / log rho, the verdict of the steepness criterion R > "
                "rho, the maximum misfit of the best line, the argmax, and a live check that the "
                "block averages are strictly declining at the chosen resolution. Increasing the "
                "exponent inflates the misfit without ever moving the maximum — curvature and "
                "location are independent, and only the latter is evidence for a mode."
            ),
            "html": read(A / "widget_curvature_not_location.html"),
        },
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {"demo": read(ROOT / "demo.py")},
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False), encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size} bytes)")


"""Anatomy of a Leakage Ghost: signal, baseline, residual and the location trap.

Produces a three-panel figure.

  Top:    the power-law signal T(x) = C(1+x)^{-a} and the curvature-mismatched
          baseline B(x) = C'(1+x)^{-a'}e^{-b x}, both strictly declining.
  Middle: their edge-matched log-residual, which bulges into a strict interior
          maximum at the logarithmic mean of the window edges, with the trap
          [geometric mean, midpoint] shaded.
  Bottom: the amplitude law -- bump height exactly linear in the curvature
          mismatch d, with the location held fixed.

Run:  python3 viz_ghost_anatomy.py   (writes ghost_anatomy.png)
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def log_mean(A: float, B: float) -> float:
    return (B - A) / (math.log(B) - math.log(A))


def matching_tilt(d: float, l: float, u: float) -> float:
    return -d * (math.log(1.0 + u) - math.log(1.0 + l)) / (u - l)


def main() -> None:
    C, a = 0.0295, 1.104
    l, u = 0.0, 1.0
    d = 0.35
    ap = a + d
    b = matching_tilt(d, l, u)

    A, B = 1.0 + l, 1.0 + u
    L = log_mean(A, B)
    x_star = L - 1.0
    gm = math.sqrt(A * B) - 1.0
    mid = 0.5 * (l + u)

    x = np.linspace(l, u, 800)
    T = C * (1.0 + x) ** (-a)
    Bl = C * (1.0 + x) ** (-ap) * np.exp(-b * x)      # same amplitude for display
    r = d * np.log(1.0 + x) + b * x

    fig, axes = plt.subplots(3, 1, figsize=(8.5, 11.0))

    ax = axes[0]
    ax.plot(x, T, lw=2.2, label=r"signal $T(x)=C(1+x)^{-a}$")
    ax.plot(x, Bl, lw=2.2, ls="--", label=r"baseline $B(x)=C'(1+x)^{-a'}e^{-bx}$")
    ax.set_title("Both curves decline strictly — neither has an interior peak")
    ax.set_xlabel("position $x$")
    ax.set_ylabel("rate")
    ax.legend()
    ax.grid(alpha=0.3)

    ax = axes[1]
    ax.axvspan(gm, mid, color="orange", alpha=0.18,
               label="trap: geometric mean → midpoint")
    ax.plot(x, r - r[0], lw=2.4, color="crimson",
            label=r"edge-matched log-residual $r(x)-r(l)$")
    ax.axvline(x_star, color="black", ls=":", lw=1.6,
               label=fr"logarithmic mean $x^\star={x_star:.4f}$")
    ax.axhline(0.0, color="grey", lw=1.0)
    ax.set_title("Their ratio invents a mid-window peak, trapped in the left half")
    ax.set_xlabel("position $x$")
    ax.set_ylabel("log-residual, edge-anchored")
    ax.legend(loc="lower center", fontsize=9)
    ax.grid(alpha=0.3)

    ax = axes[2]
    ds: List[float] = [0.05 * k for k in range(1, 17)]
    heights = []
    locs = []
    for dd in ds:
        bb = matching_tilt(dd, l, u)
        rr = dd * np.log(1.0 + x) + bb * x
        heights.append(float(rr.max() - rr[0]))
        locs.append(float(x[int(np.argmax(rr))]))
    slope = math.log(L / A) - 1.0 + A / L
    ax.plot(ds, heights, "o", ms=5, label="measured bump height")
    ax.plot(ds, [slope * dd for dd in ds], lw=2.0,
            label=fr"predicted $d\,[\log(L/A)-1+A/L]$, slope $={slope:.5f}$")
    ax2 = ax.twinx()
    ax2.plot(ds, locs, "s", ms=4, color="green", alpha=0.7)
    ax2.set_ylabel("peak location (green squares)", color="green")
    ax2.set_ylim(l, u)
    ax.set_title("Height scales exactly with the mismatch; location never moves")
    ax.set_xlabel(r"curvature mismatch $d=a'-a$")
    ax.set_ylabel("bump height")
    ax.legend(loc="upper left", fontsize=9)
    ax.grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("ghost_anatomy.png", dpi=160)
    print("wrote ghost_anatomy.png")


if __name__ == "__main__":
    main()


"""The Mean Inequality Trap and the Innocence of Binning.

Two panels.

  Left:  the chain GM < LM < AM, drawn as functions of the window ratio
         rho = B/A with A fixed, together with the ghost's position as a
         fraction of the window.  The fraction never reaches 1/2: an
         endpoint-matched leakage artefact is confined to the left half,
         approaching the midpoint only in the limit of a vanishingly narrow
         window and crowding the left edge for wide ones.

  Right: equal-width block averages of the declining power law for several bin
         widths, showing that coarse-graining preserves strict decline — no
         binning can manufacture an interior peak.

Run:  python3 viz_mean_trap_and_binning.py   (writes mean_trap_and_binning.png)
"""

from __future__ import annotations

import math
from typing import Callable, List

import matplotlib.pyplot as plt
import numpy as np


def log_mean(A: float, B: float) -> float:
    return (B - A) / (math.log(B) - math.log(A))


def simpson(f: Callable[[float], float], a: float, b: float, n: int = 600) -> float:
    h = (b - a) / n
    total = f(a) + f(b)
    for i in range(1, n):
        total += (4.0 if i % 2 else 2.0) * f(a + i * h)
    return total * h / 3.0


def main() -> None:
    fig, axes = plt.subplots(1, 2, figsize=(13.0, 5.2))

    # ---------------- Panel 1: the mean trap ----------------
    ax = axes[0]
    A = 1.0
    rhos = np.linspace(1.02, 12.0, 500)
    gm, lm, am, frac = [], [], [], []
    for rho in rhos:
        B = A * rho
        gm.append(math.sqrt(A * B))
        L = log_mean(A, B)
        lm.append(L)
        am.append(0.5 * (A + B))
        frac.append((L - A) / (B - A))

    ax.plot(rhos, gm, lw=2.0, label=r"geometric mean $\sqrt{AB}$")
    ax.plot(rhos, lm, lw=2.6, color="crimson",
            label=r"logarithmic mean $L(A,B)$ — the ghost")
    ax.plot(rhos, am, lw=2.0, label=r"arithmetic mean $(A+B)/2$")
    ax.fill_between(rhos, gm, am, color="orange", alpha=0.15)
    ax.set_xlabel(r"window ratio $\rho=B/A$   (with $A=1$)")
    ax.set_ylabel("mean value")
    ax.set_title("The ghost is trapped: GM < LM < AM")
    ax.legend(fontsize=9)
    ax.grid(alpha=0.3)

    axf = ax.twinx()
    axf.plot(rhos, frac, ls=":", color="black", lw=1.8)
    axf.axhline(0.5, color="black", lw=1.0, alpha=0.4)
    axf.set_ylim(0.0, 0.55)
    axf.set_ylabel("ghost position as a fraction of the window (dotted)")

    # ---------------- Panel 2: binning invariance ----------------
    ax = axes[1]
    C, a, l = 0.0295, 1.104, 0.0
    x = np.linspace(0.0, 4.0, 600)
    ax.plot(x, C * (1.0 + x) ** (-a), color="black", lw=2.0,
            label=r"$T(x)=C(1+x)^{-a}$")
    for h, colour in ((1.0, "tab:blue"), (0.5, "tab:green"), (0.25, "tab:red")):
        edges = [l + k * h for k in range(int(4.0 / h) + 1)]
        means: List[float] = [
            simpson(lambda t: C * (1.0 + t) ** (-a), e, e + h) / h for e in edges[:-1]
        ]
        for e, m in zip(edges[:-1], means):
            ax.plot([e, e + h], [m, m], color=colour, lw=2.4,
                    label=f"block means, h={h}" if e == edges[0] else None)
        assert all(means[i + 1] < means[i] for i in range(len(means) - 1))
    ax.set_xlabel("position $x$")
    ax.set_ylabel("rate")
    ax.set_title("Block averages of a decline still decline (every bin width)")
    ax.legend(fontsize=9)
    ax.grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("mean_trap_and_binning.png", dpi=160)
    print("wrote mean_trap_and_binning.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Monotone decline versus interior modes: numerical demonstrations
================================================================

Self-contained numerical companion to the shape/leakage decomposition for
positional rate profiles.  No third-party dependencies (standard library only).

The script demonstrates, numerically, every result of the theory:

  1.  NONLINEARITY WITHOUT MODE.
      The power-law rate T(x) = C (1+x)^{-a} has a strictly convex log-rate
      (so no affine fit exists, and a likelihood-ratio test against a linear
      model must reject) yet is strictly decreasing, hence has no interior
      maximum on any window.

  2.  EXPONENT IDENTIFICATION AND THE STEEPNESS TEST.
      T(l)/T(u) = rho^a with rho = (1+u)/(1+l); hence a = log R / log rho, and
      R > rho  <=>  a > 1.

  3.  CURVATURE LEAKAGE.
      Against a mixture-proxy baseline B(x) = C'(1+x)^{-a'} e^{-b x}, the
      log-residual is r(x) = d log(1+x) + b x with d = a' - a.  With the tilt
      calibrated so that r(l) = r(u), a positive mismatch d > 0 creates a
      strict interior maximum at the logarithmic mean of the window edges.

  4.  THE LOCATION TRAP AND THE AMPLITUDE LAW.
      GM - 1 < x* < (l+u)/2, so a leakage ghost always lives in the LEFT HALF
      of the window; and the bump height is exactly proportional to d while
      its location does not depend on d at all.

  5.  SIGN DICHOTOMY.
      d <= 0 gives a convex residual: no interior maximum for ANY tilt.

  6.  BINNING INVARIANCE.
      Equal-width block averages of a strictly declining continuous shape are
      strictly declining, for every bin width.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Recorded experimental constants (absolute-shape channel)
# ----------------------------------------------------------------------------

C_HAT: float = 0.0295          # fitted amplitude of the power law
A_HAT: float = 1.104           # fitted exponent of the power law
R_OBS: float = 2.54            # observed peak/end rate ratio
R_CI: Tuple[float, float] = (2.243, 2.798)
LRT_STAT: float = 100.574      # free-vs-linear likelihood ratio statistic
LRT_DF: int = 3
X_STAR_OBS: float = 0.020      # observed interior maximum: the left edge
DECILE_ENDPOINTS: Tuple[int, int] = (1554, 694)   # first and last decile counts


# ----------------------------------------------------------------------------
# 1.  Core shape objects
# ----------------------------------------------------------------------------

def rate_T(C: float, a: float, x: float) -> float:
    """Power-law positional rate T(x) = C (1+x)^{-a}, defined for x > -1."""
    if x <= -1.0:
        raise ValueError("x must exceed -1")
    return C * (1.0 + x) ** (-a)


def log_rate_T(C: float, a: float, x: float) -> float:
    """log T(x) = log C - a log(1+x)."""
    return math.log(C) - a * math.log(1.0 + x)


def baseline_B(Cp: float, ap: float, b: float, x: float) -> float:
    """Mixture-proxy baseline B(x) = C' (1+x)^{-a'} exp(-b x)."""
    return Cp * (1.0 + x) ** (-ap) * math.exp(-b * x)


def log_residual(d: float, b: float, x: float) -> float:
    """Log-residual r_{d,b}(x) = d log(1+x) + b x (curvature mismatch d, tilt b)."""
    return d * math.log(1.0 + x) + b * x


def matching_tilt(d: float, l: float, u: float) -> float:
    """The tilt making the log-residual agree at both window edges."""
    return -d * (math.log(1.0 + u) - math.log(1.0 + l)) / (u - l)


def log_mean(A: float, B: float) -> float:
    """Logarithmic mean L(A,B) = (B-A)/(log B - log A), for 0 < A < B."""
    if A <= 0.0 or B <= 0.0:
        raise ValueError("logarithmic mean needs positive arguments")
    if abs(B - A) < 1e-15:
        return A
    return (B - A) / (math.log(B) - math.log(A))


def ghost_location(l: float, u: float) -> float:
    """Predicted location of an endpoint-matched curvature-leakage ghost."""
    return log_mean(1.0 + l, 1.0 + u) - 1.0


def ghost_trap(l: float, u: float) -> Tuple[float, float]:
    """(geometric-mean bound, window midpoint): the interval trapping the ghost."""
    return (math.sqrt((1.0 + l) * (1.0 + u)) - 1.0, 0.5 * (l + u))


def ghost_amplitude(d: float, l: float, u: float) -> float:
    """Height of the manufactured bump above the common edge value."""
    b = matching_tilt(d, l, u)
    return log_residual(d, b, ghost_location(l, u)) - log_residual(d, b, l)


def ghost_amplitude_closed_form(d: float, l: float, u: float) -> float:
    """Closed form  d * [ log(L/A) - 1 + A/L ]  with A = 1+l, L = log-mean."""
    A = 1.0 + l
    L = log_mean(A, 1.0 + u)
    return d * (math.log(L / A) - 1.0 + A / L)


# ----------------------------------------------------------------------------
# 2.  Numerical helpers
# ----------------------------------------------------------------------------

def argmax_on_grid(f: Callable[[float], float], l: float, u: float,
                   n: int = 200001) -> Tuple[float, float]:
    """Grid argmax of f on [l,u]; returns (x_max, f(x_max))."""
    best_x, best_v = l, f(l)
    for i in range(n):
        x = l + (u - l) * i / (n - 1)
        v = f(x)
        if v > best_v:
            best_x, best_v = x, v
    return best_x, best_v


def simpson(f: Callable[[float], float], a: float, b: float, n: int = 2000) -> float:
    """Composite Simpson quadrature of f on [a,b] with an even number of panels."""
    if n % 2 == 1:
        n += 1
    h = (b - a) / n
    total = f(a) + f(b)
    for i in range(1, n):
        total += (4.0 if i % 2 == 1 else 2.0) * f(a + i * h)
    return total * h / 3.0


def block_mean(f: Callable[[float], float], l: float, h: float, k: int) -> float:
    """Average of f over the k-th equal-width block [l+kh, l+(k+1)h]."""
    return simpson(f, l + k * h, l + (k + 1) * h) / h


def is_strictly_decreasing(values: Sequence[float], tol: float = 0.0) -> bool:
    return all(values[i + 1] < values[i] - tol for i in range(len(values) - 1))


def banner(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


# ----------------------------------------------------------------------------
# Demonstration 1 -- nonlinearity without a mode
# ----------------------------------------------------------------------------

def demo_nonlinearity_without_mode() -> None:
    banner("1.  NONLINEARITY WITHOUT A MODE")
    C, a = C_HAT, A_HAT
    l, u = 0.02, 1.00

    print(f"Power law  T(x) = {C} (1+x)^(-{a})  on the window [{l}, {u}]")

    # (i) strict decline
    grid = [l + (u - l) * i / 400 for i in range(401)]
    vals = [rate_T(C, a, x) for x in grid]
    print(f"  strictly decreasing on a 401-point grid : {is_strictly_decreasing(vals)}")

    # (ii) the maximum sits at the left edge
    x_max, v_max = argmax_on_grid(lambda x: rate_T(C, a, x), l, u, 20001)
    print(f"  grid argmax                             : x = {x_max:.6f}  (left edge = {l})")
    print(f"  T(left)/T(right)                        : {rate_T(C,a,l)/rate_T(C,a,u):.6f}")

    # (iii) yet the log-rate is strictly convex: no affine fit
    m = 0.5 * (l + u)
    lhs = log_rate_T(C, a, m)
    rhs = 0.5 * (log_rate_T(C, a, l) + log_rate_T(C, a, u))
    print(f"  log T at midpoint                       : {lhs:.10f}")
    print(f"  average of log T at the edges           : {rhs:.10f}")
    print(f"  strict convexity gap (must be > 0)      : {rhs - lhs:.3e}")

    # worst-case error of the best affine fit to the log-rate (uniform grid LS)
    n = len(grid)
    sx = sum(grid); sy = sum(log_rate_T(C, a, x) for x in grid)
    sxx = sum(x * x for x in grid); sxy = sum(x * log_rate_T(C, a, x) for x in grid)
    q = (n * sxy - sx * sy) / (n * sxx - sx * sx)
    p = (sy - q * sx) / n
    worst = max(abs(log_rate_T(C, a, x) - (p + q * x)) for x in grid)
    print(f"  best affine fit to log T : p={p:.6f}, q={q:.6f}")
    print(f"  max |log T - (p+qx)| on the window      : {worst:.3e}  (> 0: no affine fit)")

    print("\n  CONCLUSION: the shape is genuinely nonlinear (a linearity test must")
    print("  reject) AND strictly declining (no interior mode).  Both at once.")
    print(f"  Recorded experiment: LRT = {LRT_STAT} on {LRT_DF} df, yet the profile's")
    print(f"  interior maximum was pinned at x* = {X_STAR_OBS} -- the left edge.")


# ----------------------------------------------------------------------------
# Demonstration 2 -- exponent identification and the steepness test
# ----------------------------------------------------------------------------

def demo_exponent_identification() -> None:
    banner("2.  EXPONENT IDENTIFICATION FROM THE PEAK/END RATIO")
    print("  a = log R / log rho,  rho = (1+u)/(1+l);  and  R > rho  <=>  a > 1.")

    rho_eff = R_OBS ** (1.0 / A_HAT)
    print(f"\n  observed ratio R                 : {R_OBS}")
    print(f"  recorded exponent a              : {A_HAT}")
    print(f"  implied effective window ratio   : rho = R^(1/a) = {rho_eff:.4f}")

    lo, hi = R_CI
    a_lo = math.log(lo) / math.log(rho_eff)
    a_hi = math.log(hi) / math.log(rho_eff)
    print(f"  ratio CI {R_CI} maps to exponent CI [{a_lo:.3f}, {a_hi:.3f}]")
    a_point = math.log(R_OBS) / math.log(rho_eff)
    print(f"  steepness test at rho = {rho_eff:.4f}: R > rho ? {R_OBS > rho_eff}"
          f"  ==>  a > 1 ? {a_point > 1.0}")

    print("\n  round-trip check across several windows (C, a recovered exactly):")
    print(f"  {'window':>18} {'rho':>8} {'R':>10} {'a recovered':>13}")
    for (l, u) in ((0.02, 1.0), (0.0, 3.0), (0.5, 2.0), (1.0, 9.0)):
        rho = (1.0 + u) / (1.0 + l)
        R = rate_T(C_HAT, A_HAT, l) / rate_T(C_HAT, A_HAT, u)
        a_rec = math.log(R) / math.log(rho)
        print(f"  [{l:6.2f},{u:6.2f}] {rho:8.4f} {R:10.4f} {a_rec:13.9f}")


# ----------------------------------------------------------------------------
# Demonstration 3 -- curvature leakage manufactures a mid-window peak
# ----------------------------------------------------------------------------

def demo_curvature_leakage() -> None:
    banner("3.  CURVATURE LEAKAGE:  A GHOST PEAK OUT OF A MONOTONE SIGNAL")
    C, a = C_HAT, A_HAT
    l, u = 0.0, 1.0
    d = 0.35                     # baseline exponent exceeds the signal's by d
    ap = a + d
    b = matching_tilt(d, l, u)
    Cp = 1.0

    print(f"  signal   T(x) = {C} (1+x)^(-{a})            (strictly declining)")
    print(f"  baseline B(x) = {Cp} (1+x)^(-{ap:.3f}) exp({-b:+.6f} x)")
    print(f"  curvature mismatch d = a' - a = {d}")
    print(f"  endpoint-matching tilt b* = {b:.6f}  (negative, as required)")

    # the residual really does match at the edges
    r_l = log_residual(d, b, l)
    r_u = log_residual(d, b, u)
    print(f"\n  r(l) = {r_l:.12f},  r(u) = {r_u:.12f}   ->  edge-matched: "
          f"{abs(r_l - r_u) < 1e-12}")

    # direct log-ratio of the two models reproduces the residual up to a constant
    x_test = 0.37
    direct = math.log(rate_T(C, a, x_test) / baseline_B(Cp, ap, b, x_test))
    predicted = math.log(C / Cp) + log_residual(d, b, x_test)
    print(f"  log(T/B) at x={x_test}: direct {direct:.12f} vs normal form "
          f"{predicted:.12f}  ->  agree: {abs(direct-predicted) < 1e-12}")

    # the manufactured mode
    x_grid, v_grid = argmax_on_grid(lambda x: log_residual(d, b, x), l, u, 400001)
    x_pred = ghost_location(l, u)
    gm, mid = ghost_trap(l, u)
    print(f"\n  numerical argmax of the residual   : {x_grid:.8f}")
    print(f"  predicted logarithmic-mean location: {x_pred:.8f}")
    print(f"  agreement                          : {abs(x_grid-x_pred) < 1e-5}")
    print(f"  trap:  GM-1 = {gm:.8f}  <  x* = {x_pred:.8f}  <  midpoint = {mid:.8f}")
    print(f"  ghost lies in the LEFT half        : {x_pred < mid}")

    print("\n  meanwhile the SIGNAL itself, on the same window, is mode-free:")
    xs, _ = argmax_on_grid(lambda x: rate_T(C, a, x), l, u, 20001)
    print(f"    argmax of T on [{l},{u}] = {xs:.6f} (the left edge)")

    print("\n  profile of the residual (bump visible in the middle):")
    for i in range(11):
        x = l + (u - l) * i / 10
        r = log_residual(d, b, x)
        bar = "#" * int(round(240 * max(r - r_l, 0.0)))
        mark = "   <== ghost" if abs(x - x_pred) < 0.05 else ""
        print(f"    x={x:4.2f}  r-r(l)={r-r_l:+.6f}  {bar}{mark}")


# ----------------------------------------------------------------------------
# Demonstration 4 -- location trap and amplitude law
# ----------------------------------------------------------------------------

def demo_trap_and_amplitude() -> None:
    banner("4.  THE LOCATION TRAP AND THE AMPLITUDE LAW")

    print("  (a) The ghost sits strictly between the geometric mean of the edges")
    print("      and the window midpoint -- always in the left half.\n")
    print(f"  {'window':>18} {'GM-1':>10} {'x*':>10} {'midpoint':>10} {'frac':>8}")
    for (l, u) in ((0.0, 1.0), (0.02, 0.06), (0.02, 1.0), (0.0, 9.0), (1.0, 100.0)):
        gm, mid = ghost_trap(l, u)
        xs = ghost_location(l, u)
        frac = (xs - l) / (u - l)
        ok = gm < xs < mid
        print(f"  [{l:6.2f},{u:7.2f}] {gm:10.5f} {xs:10.5f} {mid:10.5f} {frac:8.5f}"
              f"   trapped: {ok}")

    print("\n  As the window ratio rho -> 1 the fraction tends to 1/2 (never above);")
    print("  as rho -> infinity it tends to 0.  A right-half peak is therefore NOT")
    print("  explicable by endpoint-matched curvature leakage.")

    print("\n  (b) Amplitude is exactly linear in the mismatch d; location is not.\n")
    l, u = 0.0, 1.0
    unit = ghost_amplitude(1.0, l, u)
    print(f"  {'d':>7} {'amplitude':>13} {'amp/d':>13} {'location':>12}")
    for d in (0.05, 0.1, 0.2, 0.4, 0.8, 1.6):
        amp = ghost_amplitude(d, l, u)
        loc = ghost_location(l, u)       # independent of d by construction
        b = matching_tilt(d, l, u)
        loc_num, _ = argmax_on_grid(lambda x: log_residual(d, b, x), l, u, 200001)
        print(f"  {d:7.3f} {amp:13.8f} {amp/d:13.8f} {loc_num:12.8f}")
    print(f"  unit amplitude A(1) = {unit:.8f};  closed form "
          f"{ghost_amplitude_closed_form(1.0, l, u):.8f}")
    print("  Doubling d doubles the bump and does not move it: the decisive")
    print("  experimental signature separating leakage from a genuine mode.")


# ----------------------------------------------------------------------------
# Demonstration 5 -- the sign dichotomy
# ----------------------------------------------------------------------------

def demo_sign_dichotomy() -> None:
    banner("5.  SIGN DICHOTOMY:  UNDER-CURVED BASELINES CANNOT LEAK A PEAK")
    l, u = 0.0, 1.0
    print(f"  {'d':>7} {'curvature':>12} {'argmax on [l,u]':>18} {'interior mode?':>16}")
    for d in (0.6, 0.2, 0.0, -0.2, -0.6):
        b = matching_tilt(d, l, u)
        xm, _ = argmax_on_grid(lambda x: log_residual(d, b, x), l, u, 100001)
        interior = (l + 1e-6 < xm < u - 1e-6)
        curv = "concave" if d > 0 else ("linear" if d == 0 else "convex")
        print(f"  {d:7.2f} {curv:>12} {xm:18.6f} {str(interior):>16}")

    print("\n  Even an adversarially chosen tilt cannot rescue a bump when d < 0:")
    d = -0.4
    worst_interior = False
    for b in (-2.0, -1.0, -0.3, 0.0, 0.3, 1.0, 2.0):
        xm, _ = argmax_on_grid(lambda x: log_residual(d, b, x), l, u, 50001)
        worst_interior = worst_interior or (l + 1e-6 < xm < u - 1e-6)
    print(f"    d = {d}: any interior maximum over 7 tilts ? {worst_interior}")


# ----------------------------------------------------------------------------
# Demonstration 6 -- binning invariance
# ----------------------------------------------------------------------------

def demo_binning_invariance() -> None:
    banner("6.  BINNING INVARIANCE:  BLOCK AVERAGES OF A DECLINE STILL DECLINE")
    C, a, l = C_HAT, A_HAT, 0.0
    print("  Equal-width block averages of T(x) = C (1+x)^(-a), several bin widths:\n")
    for h in (0.05, 0.1, 0.25, 0.5, 1.0):
        means = [block_mean(lambda x: rate_T(C, a, x), l, h, k) for k in range(8)]
        dec = is_strictly_decreasing(means)
        head = " ".join(f"{m:.6f}" for m in means[:5])
        print(f"  h = {h:4.2f}:  {head} ...   strictly decreasing: {dec}")

    lo_first, hi_last = DECILE_ENDPOINTS
    print("\n  Recorded decile profile from the experiment (already coarse-grained)")
    print(f"    was strictly declining, from {lo_first} in the first decile down to")
    print(f"    {hi_last} in the last -- a fall of a factor "
          f"{lo_first / hi_last:.3f} across the window.")
    print("  Binning can blur or attenuate a peak; it cannot manufacture one.")


# ----------------------------------------------------------------------------
# Demonstration 7 -- the full verdict pipeline on synthetic data
# ----------------------------------------------------------------------------

def demo_verdict_pipeline() -> None:
    banner("7.  THE VERDICT PIPELINE ON SYNTHETIC PROFILES")
    l, u = 0.0, 1.0
    gm, mid = ghost_trap(l, u)
    x_ghost = ghost_location(l, u)

    def verdict(name: str, f: Callable[[float], float]) -> None:
        xm, _ = argmax_on_grid(f, l, u, 200001)
        interior = (l + 1e-4 < xm < u - 1e-4)
        if not interior:
            call = "MONOTONE / EDGE MAXIMUM -- no positional mode"
        elif gm < xm < mid:
            call = "INTERIOR PEAK IN THE LEFT-HALF TRAP -- consistent with leakage"
        else:
            call = "INTERIOR PEAK IN THE RIGHT HALF -- leakage EXCLUDED"
        print(f"  {name:<34} argmax={xm:8.5f}   {call}")

    d = 0.35
    b = matching_tilt(d, l, u)
    verdict("pure power law", lambda x: rate_T(C_HAT, A_HAT, x))
    verdict("edge-matched residual (d>0)", lambda x: log_residual(d, b, x))
    verdict("edge-matched residual (d<0)", lambda x: log_residual(-d, matching_tilt(-d, l, u), x))
    verdict("genuine mode at 0.65", lambda x: -((x - 0.65) ** 2))
    verdict("genuine mode at 0.43", lambda x: -((x - 0.43) ** 2))

    print(f"\n  (trap for this window: ({gm:.5f}, {mid:.5f}); predicted ghost at "
          f"{x_ghost:.5f})")
    print("  Note the last two lines: a peak inside the trap is ambiguous and must")
    print("  be settled by the amplitude-scaling test; a peak in the right half is")
    print("  already incompatible with endpoint-matched curvature leakage.")


# ----------------------------------------------------------------------------

def main() -> None:
    print(__doc__)
    demo_nonlinearity_without_mode()
    demo_exponent_identification()
    demo_curvature_leakage()
    demo_trap_and_amplitude()
    demo_sign_dichotomy()
    demo_binning_invariance()
    demo_verdict_pipeline()
    banner("SUMMARY")
    print("  * A crushing rejection of linearity is exactly what a mode-free steep")
    print("    decline predicts: nonlinearity is curvature, not location.")
    print("  * An endpoint-matched residual against a more-curved baseline must peak")
    print("    at the logarithmic mean of the window edges -- in the left half,")
    print("    with height exactly proportional to the curvature mismatch.")
    print("  * Binning is innocent: block averages of a decline still decline.")
    print("  * Verdict: steep monotone decline; the mid-window peak was a ghost.")


if __name__ == "__main__":
    main()
