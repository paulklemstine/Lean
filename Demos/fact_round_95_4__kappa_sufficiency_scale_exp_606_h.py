"""Assemble PACKAGE.json from the individual artefacts in the repository."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
A = ROOT / "assets"

LEAN_FILES = [
    "Catalog/Novelty/KappaCellPeriod.lean",
    "Catalog/Novelty/KappaWindowError.lean",
    "Catalog/Novelty/KappaSufficiencyScale.lean",
    "Catalog/Novelty/KappaResidualVariance.lean",
    "Catalog/Novelty/KappaOlsResidual.lean",
]

HEADER = (
    "from __future__ import annotations\n\n"
    "from fractions import Fraction\n"
    "from itertools import combinations\n"
    "from math import sqrt\n"
    "from typing import Callable, Dict, FrozenSet, List, NamedTuple, Sequence, Tuple\n\n"
    "Cell = FrozenSet[int]\n\n\n"
)


def algo_section(src: str, start_marker: str, end_marker: str | None) -> str:
    i = src.index(start_marker)
    j = len(src) if end_marker is None else src.index(end_marker)
    body = src[i:j]
    # drop the banner comment block itself
    body = re.sub(r"^# =+\n#.*\n# =+\n\n", "", body)
    return HEADER + body.rstrip() + "\n"


def main() -> None:
    article = (ROOT / "ARTICLE.md").read_text()
    paper = (ROOT / "RESEARCH_PAPER.md").read_text()
    tex = (ROOT / "RESEARCH_PAPER.tex").read_text()
    demo = (ROOT / "demo.py").read_text()
    algos_src = (A / "algorithms.py").read_text()
    viz1 = (A / "viz_cell_measure.py").read_text()
    viz2 = (A / "viz_slope_and_boundary.py").read_text()
    w1 = (A / "widget_weight_lab.html").read_text()
    w2 = (A / "widget_boundary.html").read_text()
    layout = (A / "_src_interactive_layout.md").read_text()
    future = (A / "_src_future_directions.md").read_text()

    m = {
        "A": "# ======================================================================================\n# A.",
        "B": "# ======================================================================================\n# B.",
        "C": "# ======================================================================================\n# C.",
        "D": "# ======================================================================================\n# D.",
        "END": '# ======================================================================================\n\nif __name__',
    }

    lean_proofs = "\n\n".join(
        f"-- ============================================================================\n"
        f"-- FILE: {f}\n"
        f"-- ============================================================================\n\n"
        + (ROOT / f).read_text()
        for f in LEAN_FILES
    )

    pkg = {
        "title": "Composition Order as a Sufficient Statistic: Exact Small-Prime Cell Measures, "
                 "Slope Laws, and the Boundary of Kappa-Sufficiency",
        "domain": "Novelty",
        "description": (
            "An exact arithmetic theory of the small-prime cell of an integer, showing that "
            "over one period the divisibility events are exactly independent Bernoulli "
            "variables, and that within the additive log-rate model the sufficiency of the "
            "composition order, the cross-scale stability of the fitted slope, and the size of "
            "the identity increment are all equivalent statements about a single weight profile. "
            "The identity increment is given in closed form as a normalised pairwise "
            "weight-spread energy with a sharp Popoviciu bound, and the observed sufficiency "
            "boundary is localised strictly between 96 and 128 bits."
        ),
        "authors": ["Aristotle"],
        "date": "2026-09-04",
        "key_results": [
            "Exact cell counts over a period: the number of residues below the product of the "
            "base primes whose small-prime cell is exactly S equals the product of (p-1) over "
            "the primes outside S; consequently the divisibility events are exactly independent "
            "Bernoulli variables with biases 1/p, and the mean composition order over a period "
            "is precisely the truncated Mertens sum.",
            "A window error bound uniform in the window length: for every base, cell and window "
            "length N the cell count deviates from the periodic prediction by at most two to the "
            "power of the number of base primes outside the cell, so empirical cell frequencies "
            "converge to the exact periodic densities with a fully explicit constant.",
            "The sufficiency dichotomy: composition order is a sufficient statistic for the "
            "additive log-rate if and only if every small prime carries the same weight, with "
            "failure already visible between two singleton cells, so there is no intermediate "
            "regime inside a fixed additive model.",
            "The slope law: the least-squares slope of the log-rate on composition order equals "
            "the Bernoulli-variance-weighted mean of the negated weights, so a homogeneous "
            "weight profile forces the same slope at every base, every marginal profile and "
            "every scale; cross-scale slope stability is therefore equivalent to weight "
            "homogeneity rather than independent evidence for it.",
            "A closed form for the identity increment as a normalised pairwise weight-spread "
            "energy, vanishing exactly when composition order is sufficient, together with a "
            "sharp Popoviciu bound whose contrapositive converts a measured increment into a "
            "certified lower bound on the weight spread; the least-squares residual is centred "
            "and orthogonal to composition order, giving an exact Pythagorean variance "
            "decomposition and hence an exact explained-fraction statement.",
            "A boundary calculus for the sufficiency verdict: a monotone identity increment "
            "makes the verdict downward closed and forbids a TRUE/FALSE/TRUE pattern across "
            "increasing scales, a continuous strictly increasing increment crosses the bar "
            "exactly once, the observed bracket localises that unique boundary strictly inside "
            "the interval from 96 to 128 bits, and the 72-bit verdict is forced by the 96-bit "
            "one rather than being independent evidence.",
        ],
        "keywords": [
            "composition order", "smooth numbers", "sufficient statistic",
            "exact independence", "Lagrange identity", "Popoviciu inequality",
            "least-squares slope", "Dickman function",
        ],
        "article": article,
        "research_paper": paper,
        "research_paper_tex": tex,
        "demo": demo,
        "demos": [
            {
                "name": "Exact-Arithmetic Verification of the Cell Measure, Slope Law, "
                        "Identity Increment and Sufficiency Boundary",
                "description": (
                    "A single self-contained program that checks every quantitative claim of the "
                    "development in exact rational arithmetic. It brute-force enumerates one full "
                    "period of the bases {2,3,5} and {2,3,5,7} and confirms that each cell fibre "
                    "has exactly the predicted size, that the fibres partition the period, that "
                    "every cell is populated, and that the mean composition order equals the "
                    "truncated Mertens sum. It then tabulates the windowed cell count against the "
                    "periodic prediction at window lengths spanning four orders of magnitude and "
                    "verifies that the error stays inside the proved envelope without growing. On "
                    "the product cell measure it recomputes all four moments from their "
                    "definitions as sums over the full power set and matches them against the "
                    "closed forms, confirms the least-squares slope, checks the sufficiency "
                    "dichotomy against a direct pairwise scan over equal-order cells, verifies "
                    "the closed form for the identity increment, and demonstrates orthogonality "
                    "of the least-squares residual together with the Pythagorean variance "
                    "decomposition. Finally it applies the Popoviciu certificate to the reported "
                    "increments at three bit-widths and bisects a strictly increasing interpolant "
                    "to localise the unique sufficiency boundary. All identities are asserted as "
                    "exact equalities between fractions, so a failure would abort rather than "
                    "pass silently."
                ),
                "code": demo,
            }
        ],
        "algorithms": [
            {
                "name": "Exact Cell Census over a Period by Totient Factorisation",
                "description": (
                    "Computes, for a base B of distinct primes and every one of the two-to-the-"
                    "size-of-B subsets S, the exact number of residues below the period whose "
                    "small-prime cell is exactly S, together with the exact density. The "
                    "mathematical foundation is the bijection sending u to d times u, where d is "
                    "the product of the primes in S: it identifies the fibre over S with the "
                    "residues below the product of the primes outside S that are coprime to it, "
                    "whose number is Euler's totient of a squarefree integer, namely the product "
                    "of (p-1). The census therefore requires no enumeration of the period, which "
                    "is astronomically large for a realistic base, and no sampling at all; it is "
                    "the ground truth against which every empirical cell frequency is compared. "
                    "Complexity is O(2^|B| |B|) arithmetic operations and O(2^|B|) memory, "
                    "entirely independent of the size of the period. In the pipeline it supplies "
                    "the population layer: the exact distribution on which the regression, the "
                    "slope law and the sufficiency criterion are all defined."
                ),
                "pseudocode": (
                    "INPUT   B = (p_1, ..., p_n), distinct primes\n"
                    "OUTPUT  for each S subset of B: count(S) and density(S)\n"
                    "\n"
                    "1  for k := 0 to n do\n"
                    "2      for each S in Combinations(B, k) do\n"
                    "3          count   := 1\n"
                    "4          density := 1                       // exact rational\n"
                    "5          for each p in B do\n"
                    "6              if p in S then\n"
                    "7                  density := density * (1 / p)\n"
                    "8              else\n"
                    "9                  count   := count * (p - 1)   // Euler totient factor\n"
                    "10                 density := density * (1 - 1 / p)\n"
                    "11         emit (S, |S|, count, density)\n"
                    "12 // invariants, checkable in O(2^n):\n"
                    "13 //   sum over S of count(S) = product of B     (fibres partition period)\n"
                    "14 //   count(S) > 0 for every S                  (every cell populated)\n"
                    "15 //   sum over v < period of kappa(v) / period = sum over p of 1/p"
                ),
                "code": algo_section(algos_src, m["A"], m["B"]),
            },
            {
                "name": "Windowed Cell Count with a Length-Uniform Error Certificate via "
                        "Mobius Truncation",
                "description": (
                    "Returns the exact number of integers below a window length N whose "
                    "small-prime cell equals a prescribed S, together with a certified bound on "
                    "its deviation from the periodic prediction. The foundation is the pointwise "
                    "Mobius expansion of the cell indicator: the indicator that the cell equals S "
                    "is the alternating sum, over subsets T of the primes outside S, of the "
                    "indicator that the product of the primes in S union T divides v. Summing "
                    "over the window replaces each term by a count of multiples, which is a "
                    "ceiling and therefore within one of N over the divisor; there are two to the "
                    "power of the number of primes outside S such terms, so the total error is "
                    "bounded by that number, uniformly in N. That uniformity is the whole point: "
                    "a naive argument bounding the discrepancy by the incomplete final period "
                    "yields a constant of the size of the period, which is vacuous precisely in "
                    "the regime where experiments operate. Complexity is O(2^{|B \\ S|}) "
                    "arithmetic operations; the window is never scanned, so the cost is "
                    "independent of N. In the pipeline this is the bridge that licenses treating "
                    "frequencies measured on a sampled window as exact periodic densities."
                ),
                "pseudocode": (
                    "INPUT   B distinct primes, S subset of B, window length N\n"
                    "OUTPUT  exact count, periodic prediction, error, certified bound\n"
                    "\n"
                    "1  outside := B \\ S\n"
                    "2  forced  := product of p over p in S\n"
                    "3  total   := 0\n"
                    "4  for k := 0 to |outside| do\n"
                    "5      for each T in Combinations(outside, k) do\n"
                    "6          d     := forced * product of p over p in T\n"
                    "7          total := total + (-1)^k * ceil(N / d)   // multiples of d in [0,N)\n"
                    "8  density := product over p in S of 1/p\n"
                    "9             * product over p in outside of (1 - 1/p)\n"
                    "10 predicted := N * density\n"
                    "11 bound     := 2^{|outside|}                      // proved, uniform in N\n"
                    "12 assert |total - predicted| <= bound\n"
                    "13 return (total, predicted, |total - predicted|, bound)"
                ),
                "code": algo_section(algos_src, m["B"], m["C"]),
            },
            {
                "name": "Least-Squares Slope, Identity Increment and Popoviciu Weight-Spread "
                        "Certificate",
                "description": (
                    "Given marginals q and a weight profile w on the base, this evaluates every "
                    "quantity the experiment reports, from closed forms rather than from "
                    "simulation. Writing v_p for the Bernoulli variance q_p(1-q_p), the mean "
                    "composition order is the sum of the q_p, its variance is the sum of the v_p, "
                    "the log-rate variance is the v-weighted sum of the squared weights, and the "
                    "least-squares slope is the v-weighted mean of the negated weights. The "
                    "identity increment, that is the variance the composition-order regression "
                    "cannot explain, has the closed form obtained from the finite Lagrange "
                    "identity: one half the double sum of v_p v_r times the squared weight "
                    "difference, normalised by the sum of the v_p. It is manifestly non-negative "
                    "and vanishes exactly when the weights agree, so the quantitative and "
                    "qualitative sufficiency verdicts coincide. The routine also returns the "
                    "sharp Popoviciu cap, attained on a balanced two-prime base, and its "
                    "contrapositive reading: a measured increment g certifies a weight spread of "
                    "at least twice the square root of g over the sum of the v_p. Complexity is "
                    "O(|B|^2) for the pairwise energy, reducible to O(|B|) through the moment "
                    "form. The dial cancels from every output and is therefore not an input."
                ),
                "pseudocode": (
                    "INPUT   B, marginals q, weights w, sufficiency bar\n"
                    "OUTPUT  slope, increment, explained fraction, cap, certified spread, verdict\n"
                    "\n"
                    "1  for each p in B: v[p] := q[p] * (1 - q[p])\n"
                    "2  sumV      := sum of v[p]\n"
                    "3  meanKappa := sum of q[p]\n"
                    "4  varLambda := sum of w[p]^2 * v[p]\n"
                    "5  slope     := - (sum of w[p] * v[p]) / sumV        // v-weighted mean of -w\n"
                    "6  energy    := 0\n"
                    "7  for each p in B do\n"
                    "8      for each r in B do\n"
                    "9          energy := energy + v[p] * v[r] * (w[p] - w[r])^2\n"
                    "10 increment := (energy / 2) / sumV                  // Lagrange identity\n"
                    "11 explained := 1 - increment / varLambda            // exact R^2\n"
                    "12 lo := min w[p];  hi := max w[p]\n"
                    "13 cap := sumV * (hi - lo)^2 / 4                     // sharp Popoviciu\n"
                    "14 assert increment <= cap\n"
                    "15 spread := 2 * sqrt(increment / sumV)              // certified lower bound\n"
                    "16 return (meanKappa, sumV, varLambda, slope, increment,\n"
                    "17         explained, cap, spread, increment <= bar)"
                ),
                "code": algo_section(algos_src, m["C"], m["D"]),
            },
            {
                "name": "Unique Sufficiency-Boundary Localisation by Monotone Bisection",
                "description": (
                    "Locates the unique scale at which a continuous, strictly increasing identity "
                    "increment crosses the pre-registered sufficiency bar. Existence of the "
                    "crossing is the intermediate value theorem applied on a bracket where the "
                    "increment starts at or below the bar and ends strictly above it; uniqueness "
                    "is injectivity of a strictly increasing map. Because the verdict is then "
                    "literally the statement that the scale lies at or below the crossing, three "
                    "structural facts follow at once and are enforced by the routine: the verdict "
                    "is downward closed in the scale, a TRUE then FALSE then TRUE pattern across "
                    "increasing scales is impossible and would refute monotonicity outright, and "
                    "any verdict at a scale below one that already passed is a prediction rather "
                    "than independent evidence. The routine refuses to run when the bracket "
                    "hypothesis fails, since without it no crossing is implied. Complexity is "
                    "logarithmic in the ratio of bracket width to tolerance, with one evaluation "
                    "of the increment per step. Applied to the reported measurements 0.0084 at 96 "
                    "bits and 0.0346 at 128 bits with a bar of 0.02, the log-linear interpolant "
                    "places the boundary strictly inside the interval from 96 to 128 bits."
                ),
                "pseudocode": (
                    "INPUT   increment model g (continuous, strictly increasing), bar,\n"
                    "        bracket [lo, hi], tolerance eps\n"
                    "OUTPUT  the unique u* in (lo, hi] with g(u*) = bar\n"
                    "\n"
                    "1  if not (g(lo) <= bar < g(hi)) then\n"
                    "2      abort: bracket hypothesis fails, no crossing is implied\n"
                    "3  a := lo;  b := hi\n"
                    "4  while b - a > eps do\n"
                    "5      mid := (a + b) / 2\n"
                    "6      if g(mid) <= bar then a := mid else b := mid\n"
                    "7  u* := (a + b) / 2\n"
                    "8  // consequences, valid for every scale u:\n"
                    "9  //   verdict(u) holds  <=>  u <= u*        (downward closed)\n"
                    "10 //   no TRUE / FALSE / TRUE pattern is possible\n"
                    "11 //   any scale below an already-passing scale is FORCED, not measured\n"
                    "12 return u*"
                ),
                "code": algo_section(algos_src, m["D"], m["END"]),
            },
        ],
        "visualizations": [
            {
                "name": "The Exact Cell Measure and Its Uniform Window Convergence",
                "description": (
                    "A three-panel figure establishing the population layer. The first panel plots "
                    "the observed density of every one of the sixteen cells over one full period "
                    "of the base {2,3,5,7} and overlays the product-measure prediction, which "
                    "coincides to the last digit: the small-prime divisibility events are exactly, "
                    "not asymptotically, independent. The second panel shows the induced "
                    "distribution of the composition order as a sum of independent Bernoulli "
                    "variables with biases 1/p, marking the exact mean, the truncated Mertens sum, "
                    "and reporting the exact variance. The third panel plots the absolute error "
                    "between the windowed cell count and the periodic prediction across window "
                    "lengths spanning four orders of magnitude, against the proved envelope: the "
                    "error visibly does not grow with the window length, which is exactly the "
                    "content of the certificate that transports the periodic theory to sampled "
                    "populations."
                ),
                "code": viz1,
            },
            {
                "name": "The Slope Law, the Popoviciu Certificate and the Sufficiency Boundary",
                "description": (
                    "A four-panel figure covering the response layer. The first two panels plot "
                    "the log-rate against composition order for every cell of a six-prime base, "
                    "with disc areas proportional to exact cell probabilities. Under a homogeneous "
                    "weight profile the cells of a given composition order collapse onto a single "
                    "point, the fit is exact, and the slope is the negated common weight; under a "
                    "Dickman-type profile proportional to the logarithm of the prime, cells of "
                    "equal composition order fan out vertically, and that vertical fan is "
                    "precisely what the identity increment measures. The third panel traces the "
                    "increment against the weight spread along a one-parameter family of profiles, "
                    "together with the sharp Popoviciu envelope, and shades the region of weight "
                    "spreads that a measured increment provably excludes. The fourth panel shows "
                    "the boundary calculus: a strictly increasing increment through the two "
                    "measurements crosses the pre-registered bar exactly once, with the crossing "
                    "localised strictly inside the interval from 96 to 128 bits and the smallest "
                    "scale falling out as a prediction."
                ),
                "code": viz2,
            },
        ],
        "interactive_demos": [
            {
                "title": "The Weight Profile Laboratory: One Hidden Object, Four Verdicts",
                "description": (
                    "A live laboratory for the single object that controls the entire theory: the "
                    "per-prime weight profile. Choose the size of the small-prime base, then set "
                    "each prime's penalty by hand or load one of four presets, including the "
                    "homogeneous profile that realises the graded law and the Dickman-type profile "
                    "proportional to the logarithm of the prime. The main panel plots the log-rate "
                    "of every cell against its composition order, with each disc's area equal to "
                    "that cell's exact arithmetic probability under the marginals one over p, and "
                    "draws the least-squares fit. Four numbers update in real time: the fitted "
                    "slope, the identity increment, the explained fraction, and the sharp "
                    "Popoviciu cap. A second panel renders the pairwise energy matrix whose "
                    "normalised sum is the increment, term by term, making visible exactly which "
                    "pairs of primes are responsible for the failure of sufficiency; a uniformly "
                    "black matrix is, precisely, the statement that composition order is a "
                    "sufficient statistic. The verdict banner reports the sufficiency call against "
                    "the pre-registered bar, and the footer reads the Popoviciu bound backwards to "
                    "show the weight spread that the increment alone certifies. Users discover for "
                    "themselves that flattening the profile simultaneously drives the increment to "
                    "zero, locks the slope to the negated common weight at every base size, and "
                    "collapses the vertical fan at each composition order."
                ),
                "html": w1,
            },
            {
                "title": "The Sufficiency Boundary Explorer: What Is Deduced, Not Measured",
                "description": (
                    "An interactive treatment of the regime-boundary calculus. Drag the two "
                    "measured increments and the pre-registered bar, and the widget fits the "
                    "unique strictly increasing log-linear increment through them, bisects to "
                    "locate the unique crossing of the bar, and shades the scales at which "
                    "composition order suffices against those where the identity of the dividing "
                    "primes matters too. Verdict tiles at five scales update live, and the "
                    "smallest-scale point is drawn in a different colour because it is a "
                    "prediction rather than an input: whenever the middle measurement sits at or "
                    "below the bar, monotonicity forces the smaller-scale verdict, so the reported "
                    "value there is a consistency check on monotonicity rather than independent "
                    "evidence, and the widget says so explicitly. Pushing the middle measurement "
                    "above the bar flips the annotation and explains why a TRUE then FALSE then "
                    "TRUE pattern across increasing scales would refute monotonicity outright, "
                    "which is what makes the three-scale design falsifiable."
                ),
                "html": w2,
            },
        ],
        "interactive_layout": layout,
        "lean_proofs": lean_proofs,
        "future_directions": future,
        "modules": {"demo": demo},
        "lean_files": LEAN_FILES,
    }

    (ROOT / "PACKAGE.json").write_text(json.dumps(pkg, indent=2, ensure_ascii=False) + "\n")
    print("wrote PACKAGE.json")


if __name__ == "__main__":
    main()


"""
Visualization 1 -- The exact small-prime cell measure and its window convergence.

Three panels:
  (a) exact cell densities over one period for B = {2,3,5,7}, ordered by composition
      order kappa, with the product-measure prediction overlaid;
  (b) the distribution of kappa itself against the Poisson-binomial prediction with
      marginals 1/p, and the exact mean sum_p 1/p;
  (c) the window error |count_{v<N} - N*density| for a fixed cell, against the proved
      bound 2^{|B \ S|}, showing that the error does NOT grow with the window length.

Self-contained: standard library + matplotlib + numpy.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from typing import Dict, FrozenSet, List, Sequence, Tuple

import matplotlib.pyplot as plt
import numpy as np

Cell = FrozenSet[int]


def subsets(base: Sequence[int]) -> List[Cell]:
    out: List[Cell] = []
    for k in range(len(base) + 1):
        for combo in combinations(base, k):
            out.append(frozenset(combo))
    return out


def period(base: Sequence[int]) -> int:
    m = 1
    for p in base:
        m *= p
    return m


def cell_of(v: int, base: Sequence[int]) -> Cell:
    return frozenset(p for p in base if v % p == 0)


def predicted_fiber_size(base: Sequence[int], S: Cell) -> int:
    out = 1
    for p in base:
        if p not in S:
            out *= p - 1
    return out


def predicted_density(base: Sequence[int], S: Cell) -> Fraction:
    d = Fraction(1)
    for p in base:
        d *= Fraction(1, p) if p in S else (1 - Fraction(1, p))
    return d


def window_count(base: Sequence[int], S: Cell, N: int) -> int:
    """Exact count via the Moebius expansion of the cell indicator."""
    outside = [p for p in base if p not in S]
    forced = 1
    for p in S:
        forced *= p
    total = 0
    for k in range(len(outside) + 1):
        for extra in combinations(outside, k):
            d = forced
            for p in extra:
                d *= p
            total += (-1) ** k * (-(-N // d))
    return total


def main() -> None:
    base: Tuple[int, ...] = (2, 3, 5, 7)
    M = period(base)
    cells = sorted(subsets(base), key=lambda S: (len(S), sorted(S)))

    # brute-force tally over one period, to be compared with the closed form
    tally: Dict[Cell, int] = {S: 0 for S in cells}
    for v in range(M):
        tally[cell_of(v, base)] += 1

    obs = np.array([tally[S] / M for S in cells])
    pred = np.array([float(predicted_density(base, S)) for S in cells])
    kappas = np.array([len(S) for S in cells])
    labels = ["{}" if not S else "".join(str(p) for p in sorted(S)) for S in cells]

    fig, axes = plt.subplots(1, 3, figsize=(16.5, 5.0))
    palette = plt.cm.viridis(kappas / max(1, kappas.max()))

    # ---- (a) exact cell densities -------------------------------------------------
    ax = axes[0]
    x = np.arange(len(cells))
    ax.bar(x, obs, color=palette, edgecolor="black", linewidth=0.4, label="observed over one period")
    ax.plot(x, pred, "r_", markersize=14, markeredgewidth=2.0,
            label=r"product measure $\prod_S 1/p\ \prod_{B\setminus S}(1-1/p)$")
    ax.set_xticks(x)
    ax.set_xticklabels(labels, rotation=90, fontsize=7)
    ax.set_xlabel("cell $S$ (primes dividing $v$), grouped by $\\kappa=|S|$")
    ax.set_ylabel("density over one period")
    ax.set_title(f"(a) Exact cell measure, $B=\\{{2,3,5,7\\}}$, period $M={M}$\n"
                 "observed = predicted, to the last digit")
    ax.legend(fontsize=8)
    ax.grid(axis="y", alpha=0.25)

    # ---- (b) distribution of kappa -------------------------------------------------
    ax = axes[1]
    kmax = len(base)
    dist = np.zeros(kmax + 1)
    for S in cells:
        dist[len(S)] += float(predicted_density(base, S))
    ax.bar(np.arange(kmax + 1), dist, color=plt.cm.viridis(np.arange(kmax + 1) / kmax),
           edgecolor="black", linewidth=0.5)
    mean_kappa = sum(1.0 / p for p in base)
    var_kappa = sum((1.0 / p) * (1 - 1.0 / p) for p in base)
    ax.axvline(mean_kappa, color="crimson", linestyle="--", linewidth=2,
               label=fr"$\mathbb{{E}}[\kappa]=\sum 1/p={mean_kappa:.4f}$")
    ax.set_xlabel(r"composition order $\kappa$")
    ax.set_ylabel("probability")
    ax.set_title("(b) $\\kappa$ is a sum of independent Bernoulli($1/p$)\n"
                 fr"$\mathrm{{Var}}(\kappa)=\sum q_p(1-q_p)={var_kappa:.4f}$")
    ax.legend(fontsize=9)
    ax.grid(axis="y", alpha=0.25)

    # ---- (c) window error, uniform in N ---------------------------------------------
    ax = axes[2]
    S = frozenset({2})
    bound = 2 ** len([p for p in base if p not in S])
    dens = float(predicted_density(base, S))
    Ns = np.unique(np.round(np.logspace(1, 5, 90)).astype(int))
    errs = np.array([abs(window_count(base, S, int(N)) - N * dens) for N in Ns])
    ax.semilogx(Ns, errs, "o-", color="#1f77b4", markersize=3, linewidth=1.0,
                label=r"$|\#\{v<N:\mathrm{cell}(v)=S\}-N\pi_S|$")
    ax.axhline(bound, color="crimson", linestyle="--", linewidth=2,
               label=fr"proved bound $2^{{|B\setminus S|}}={bound}$")
    ax.set_ylim(0, bound * 1.25)
    ax.set_xlabel("window length $N$")
    ax.set_ylabel("absolute cell-count error")
    ax.set_title("(c) The window error is uniform in $N$\n"
                 "$S=\\{2\\}$: frequencies converge at rate $2^{|B|}/N$")
    ax.legend(fontsize=8, loc="upper right")
    ax.grid(alpha=0.25)

    fig.suptitle("The small-prime cell measure is exactly a product of independent coins -- "
                 "and survives truncation to a finite window", fontsize=13)
    fig.tight_layout(rect=(0, 0, 1, 0.94))
    fig.savefig("cell_measure.png", dpi=160)
    print("wrote cell_measure.png")


if __name__ == "__main__":
    main()


"""
Visualization 2 -- The slope law, the identity increment, and the sufficiency boundary.

Four panels:
  (a) log-rate against composition order for a HOMOGENEOUS weight profile: every cell of
      a given kappa collapses onto a single point, the fit is exact, and the slope is -beta
      whatever the base or the marginals;
  (b) the same for a HETEROGENEOUS profile: cells of equal kappa fan out, and the vertical
      spread is precisely what the identity increment measures;
  (c) the identity increment as a function of the weight spread, against the sharp
      Popoviciu envelope (sum v)(Mx-m)^2/4, with the certified-spread reading shown for a
      measured increment;
  (d) the sufficiency boundary: a strictly increasing increment crosses the pre-registered
      bar exactly once, and the observed bracket localises the crossing in (96, 128].

Self-contained: standard library + matplotlib + numpy.
"""

from __future__ import annotations

import math
from itertools import combinations
from typing import Callable, Dict, FrozenSet, List, Sequence, Tuple

import matplotlib.pyplot as plt
import numpy as np

Cell = FrozenSet[int]


def subsets(base: Sequence[int]) -> List[Cell]:
    out: List[Cell] = []
    for k in range(len(base) + 1):
        for combo in combinations(base, k):
            out.append(frozenset(combo))
    return out


def cell_prob(base: Sequence[int], q: Dict[int, float], S: Cell) -> float:
    out = 1.0
    for p in base:
        out *= q[p] if p in S else (1.0 - q[p])
    return out


def slope_and_increment(base: Sequence[int], q: Dict[int, float],
                        w: Dict[int, float]) -> Tuple[float, float]:
    """beta_OLS = -(sum w v)/(sum v);  R = (1/2 sum_{p,r} v_p v_r (w_p-w_r)^2)/(sum v)."""
    v = {p: q[p] * (1.0 - q[p]) for p in base}
    sv = sum(v.values())
    beta = -sum(w[p] * v[p] for p in base) / sv
    energy = sum(v[p] * v[r] * (w[p] - w[r]) ** 2 for p in base for r in base)
    return beta, (0.5 * energy) / sv


def main() -> None:
    base: Tuple[int, ...] = (2, 3, 5, 7, 11, 13)
    q = {p: 1.0 / p for p in base}
    v = {p: q[p] * (1 - q[p]) for p in base}
    sum_v = sum(v.values())
    dial = 0.0
    cells = subsets(base)

    fig, axes = plt.subplots(2, 2, figsize=(14.5, 10.5))

    # ---- (a) homogeneous weights -------------------------------------------------
    beta0 = 0.35
    w_hom = {p: beta0 for p in base}
    ax = axes[0][0]
    ks = np.array([len(S) for S in cells], dtype=float)
    lam = np.array([dial - sum(w_hom[p] for p in S) for S in cells])
    sizes = np.array([600.0 * cell_prob(base, q, S) for S in cells]) + 4.0
    ax.scatter(ks + np.random.default_rng(0).normal(0, 0.045, ks.size), lam,
               s=sizes, alpha=0.65, color="#2a9d8f", edgecolor="k", linewidth=0.2)
    b, R = slope_and_increment(base, q, w_hom)
    xs = np.linspace(-0.2, len(base) + 0.2, 50)
    ax.plot(xs, dial + b * xs, "r-", linewidth=2,
            label=fr"fit: $\Lambda=\mathrm{{dial}}{b:+.4f}\,\kappa$")
    ax.set_xlabel(r"composition order $\kappa$")
    ax.set_ylabel(r"log-rate $\Lambda(S)$")
    ax.set_title(f"(a) Homogeneous $w\\equiv{beta0}$: $\\kappa$ IS sufficient\n"
                 fr"slope $={b:+.6f}=-\beta$ exactly; increment $R={R:.2e}$")
    ax.legend(fontsize=9)
    ax.grid(alpha=0.25)

    # ---- (b) heterogeneous weights (log p profile) ---------------------------------
    c = beta0 / math.log(3.0)
    w_het = {p: c * math.log(p) for p in base}
    ax = axes[0][1]
    lam = np.array([dial - sum(w_het[p] for p in S) for S in cells])
    ax.scatter(ks + np.random.default_rng(0).normal(0, 0.045, ks.size), lam,
               s=sizes, alpha=0.65, color="#e76f51", edgecolor="k", linewidth=0.2)
    b, R = slope_and_increment(base, q, w_het)
    ax.plot(xs, dial + b * xs, "r-", linewidth=2,
            label=fr"fit: slope $={b:+.4f}$")
    ax.set_xlabel(r"composition order $\kappa$")
    ax.set_ylabel(r"log-rate $\Lambda(S)$")
    ax.set_title(r"(b) Dickman-type $w_p\propto\log p$: $\kappa$ is NOT sufficient" "\n"
                 fr"cells of equal $\kappa$ fan out; increment $R={R:.5f}$")
    ax.legend(fontsize=9)
    ax.grid(alpha=0.25)

    # ---- (c) increment vs weight spread, with Popoviciu envelope --------------------
    ax = axes[1][0]
    spreads = np.linspace(0.0, 1.0, 220)
    # a one-parameter family: w_p interpolates linearly across the base with given spread
    idx = {p: i / (len(base) - 1) for i, p in enumerate(base)}
    incs = []
    for s in spreads:
        w_s = {p: beta0 - s / 2 + s * idx[p] for p in base}
        incs.append(slope_and_increment(base, q, w_s)[1])
    incs = np.array(incs)
    envelope = sum_v * spreads ** 2 / 4.0
    ax.plot(spreads, envelope, "--", color="crimson", linewidth=2,
            label=r"sharp Popoviciu envelope $(\sum v_p)(M_x-m)^2/4$")
    ax.plot(spreads, incs, "-", color="#264653", linewidth=2,
            label="identity increment $R$ (linear weight ramp)")
    g_obs = 0.0346
    ax.axhline(g_obs, color="#ff9f1c", linewidth=1.6,
               label=fr"measured 128-bit increment $g={g_obs}$")
    cert = 2 * math.sqrt(g_obs / sum_v)
    ax.axvline(cert, color="#ff9f1c", linestyle=":", linewidth=1.6,
               label=fr"certified spread $\geq 2\sqrt{{g/\sum v_p}}={cert:.4f}$")
    ax.fill_betweenx([0, ax.get_ylim()[1]], 0, cert, color="grey", alpha=0.12)
    ax.set_xlabel(r"weight spread $M_x-m$")
    ax.set_ylabel("identity increment $R$")
    ax.set_ylim(0, float(envelope.max()) * 0.55)
    ax.set_title("(c) A measured increment certifies a minimum weight spread\n"
                 "the shaded region is excluded by the measurement")
    ax.legend(fontsize=8, loc="upper left")
    ax.grid(alpha=0.25)

    # ---- (d) the sufficiency boundary ------------------------------------------------
    ax = axes[1][1]
    bar = 0.02
    u1, g1, u2, g2 = 96.0, 0.0084, 128.0, 0.0346
    k = (math.log(g2) - math.log(g1)) / (u2 - u1)
    A = g1 * math.exp(-k * u1)
    g: Callable[[float], float] = lambda u: A * math.exp(k * u)
    us = np.linspace(64, 140, 400)
    gs = np.array([g(u) for u in us])
    ax.plot(us, gs, "-", color="#264653", linewidth=2, label="identity increment $g(u)$")
    ax.axhline(bar, color="crimson", linestyle="--", linewidth=2,
               label=fr"pre-registered bar $={bar}$")
    lo, hi = 96.0, 128.0
    for _ in range(80):
        mid = 0.5 * (lo + hi)
        if g(mid) <= bar:
            lo = mid
        else:
            hi = mid
    u_star = 0.5 * (lo + hi)
    ax.axvline(u_star, color="#2a9d8f", linewidth=2,
               label=fr"unique boundary $u^\ast={u_star:.1f}$ bits")
    ax.fill_between(us, 0, gs, where=(us <= u_star), color="#2a9d8f", alpha=0.15)
    ax.fill_between(us, 0, gs, where=(us > u_star), color="#e76f51", alpha=0.15)
    for u, gv, lab in ((72, 0.0071, "72"), (96, 0.0084, "96"), (128, 0.0346, "128")):
        ax.plot([u], [gv], "o", color="black", markersize=7, zorder=5)
        ax.annotate(f"{lab} bits\n{gv}", (u, gv), textcoords="offset points",
                    xytext=(6, 8), fontsize=8)
    ax.set_xlabel("scale (bits)")
    ax.set_ylabel("identity increment")
    ax.set_title("(d) A monotone increment crosses the bar exactly once\n"
                 r"observed bracket localises $u^\ast$ strictly inside $(96,128]$")
    ax.legend(fontsize=8, loc="upper left")
    ax.grid(alpha=0.25)

    fig.suptitle("Everything reduces to the weight profile: its homogeneity is sufficiency and "
                 "scale stability; its spread is the increment", fontsize=13)
    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("slope_and_boundary.png", dpi=160)
    print("wrote slope_and_boundary.png")


if __name__ == "__main__":
    main()


"""
Numerical demonstrations for
"Composition Order as a Sufficient Statistic:
 Exact Cell Measures, Slope Laws, and the Boundary of kappa-Sufficiency".

Everything here is self-contained (standard library only) and uses exact rational
arithmetic wherever the theory claims an exact identity, so the checks are equalities
rather than approximations.

Setting
-------
B          a finite base of distinct primes
cell(v)    = { p in B : p | v }                       (the "cell" of v)
kappa(v)   = |cell(v)|                                (the "composition order")
per(B)     = prod_{p in B} p                          (the period)

Results demonstrated
--------------------
 1. Exact cell counts over a period:  |{v < per(B) : cell(v) = S}| = prod_{p not in S} (p-1)
 2. Exact independence of divisibility: density(S) = prod_{S} 1/p * prod_{B\S} (1 - 1/p)
 3. Mean composition order over a period = sum_{p in B} 1/p  (truncated Mertens sum)
 4. Window error bound: |count_{v<N} - N*density| <= 2^{|B \ S|}, uniform in N
 5. Slope law: beta_OLS = -(sum_p w_p v_p) / (sum_p v_p),  v_p = q_p (1 - q_p)
 6. Sufficiency dichotomy: kappa is sufficient  <=>  w is constant on B
 7. Closed form for the identity increment:
        R = ( 1/2 * sum_{p,r} v_p v_r (w_p - w_r)^2 ) / sum_p v_p
 8. Orthogonality: E[residual] = 0, Cov(residual, kappa) = 0, Var(residual) = R,
        Var(Lambda) = beta^2 Var(kappa) + Var(residual)
 9. Sharp Popoviciu bound  R <= (sum v_p)(Mx - m)^2 / 4  and the certified weight spread
        Mx - m >= 2 sqrt( R / sum v_p )
10. Boundary calculus: the observed increments 0.0084 (96 bits) and 0.0346 (128 bits)
        against a bar of 0.02 localise a unique sufficiency boundary strictly in (96, 128].
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from math import sqrt
from typing import Callable, Dict, FrozenSet, List, Sequence, Tuple

Cell = FrozenSet[int]


# ----------------------------------------------------------------------------------
# 0. Basic combinatorics of cells
# ----------------------------------------------------------------------------------

def subsets(base: Sequence[int]) -> List[Cell]:
    """All 2^{|B|} subsets of the base, as frozensets."""
    out: List[Cell] = []
    for k in range(len(base) + 1):
        for combo in combinations(base, k):
            out.append(frozenset(combo))
    return out


def period(base: Sequence[int]) -> int:
    """per(B) = prod_{p in B} p."""
    m = 1
    for p in base:
        m *= p
    return m


def cell_of(v: int, base: Sequence[int]) -> Cell:
    """cell(v) = { p in B : p | v }."""
    return frozenset(p for p in base if v % p == 0)


# ----------------------------------------------------------------------------------
# 1-3. Exact counts, exact independence, mean composition order
# ----------------------------------------------------------------------------------

def predicted_fiber_size(base: Sequence[int], S: Cell) -> int:
    """Theorem (exact cell counts): |F_B(S)| = prod_{p in B \\ S} (p - 1)."""
    out = 1
    for p in base:
        if p not in S:
            out *= p - 1
    return out


def predicted_density(base: Sequence[int], S: Cell) -> Fraction:
    """Theorem (exact independence):  prod_{p in S} 1/p * prod_{p not in S} (1 - 1/p)."""
    d = Fraction(1)
    for p in base:
        d *= Fraction(1, p) if p in S else (1 - Fraction(1, p))
    return d


def brute_force_fiber_sizes(base: Sequence[int]) -> Dict[Cell, int]:
    """Enumerate one full period and tally the cells."""
    tally: Dict[Cell, int] = {S: 0 for S in subsets(base)}
    for v in range(period(base)):
        tally[cell_of(v, base)] += 1
    return tally


def demo_exact_cell_counts(base: Sequence[int]) -> None:
    print(f"--- 1-3.  Exact cell measure for B = {sorted(base)},  per(B) = {period(base)} ---")
    tally = brute_force_fiber_sizes(base)
    total = 0
    print(f"{'cell S':>18} {'observed':>9} {'predicted':>10} {'density':>12} {'as float':>10}")
    for S in subsets(base):
        obs = tally[S]
        pred = predicted_fiber_size(base, S)
        dens = predicted_density(base, S)
        assert obs == pred, (S, obs, pred)
        assert Fraction(obs, period(base)) == dens, (S, obs, dens)
        assert obs > 0, "every cell must be populated"
        label = "{}" if not S else "{" + ",".join(str(p) for p in sorted(S)) + "}"
        print(f"{label:>18} {obs:>9} {pred:>10} {str(dens):>12} {float(dens):>10.5f}")
        total += obs
    assert total == period(base)
    print(f"  fibres partition the period:  sum = {total} = per(B)   OK")

    # mean composition order = truncated Mertens sum
    kappa_total = sum(len(cell_of(v, base)) for v in range(period(base)))
    mean_kappa = Fraction(kappa_total, period(base))
    mertens = sum((Fraction(1, p) for p in base), Fraction(0))
    assert mean_kappa == mertens
    print(f"  mean kappa = {mean_kappa} = sum 1/p = {mertens}  ({float(mertens):.6f})   OK\n")


# ----------------------------------------------------------------------------------
# 4. The window error bound
# ----------------------------------------------------------------------------------

def window_count_bruteforce(base: Sequence[int], S: Cell, N: int) -> int:
    return sum(1 for v in range(N) if cell_of(v, base) == S)


def window_count_inclusion_exclusion(base: Sequence[int], S: Cell, N: int) -> int:
    """Exact count via the Moebius expansion of the cell indicator (no enumeration of [0,N))."""
    outside = [p for p in base if p not in S]
    forced = 1
    for p in S:
        forced *= p
    total = 0
    for k in range(len(outside) + 1):
        for extra in combinations(outside, k):
            d = forced
            for p in extra:
                d *= p
            # number of multiples of d in [0, N) is ceil(N/d)
            total += (-1) ** k * (-(-N // d))
    return total


def demo_window_bound(base: Sequence[int], S: Cell, lengths: Sequence[int]) -> None:
    label = "{" + ",".join(str(p) for p in sorted(S)) + "}"
    bound = 2 ** len([p for p in base if p not in S])
    dens = float(predicted_density(base, S))
    print(f"--- 4.  Window error bound for B = {sorted(base)}, S = {label} ---")
    print(f"  exact density = {predicted_density(base, S)} = {dens:.6f};  proved bound = 2^|B\\S| = {bound}")
    print(f"{'N':>8} {'count':>8} {'N*density':>12} {'error':>9} {'<= bound?':>10}")
    for N in lengths:
        c_bf = window_count_bruteforce(base, S, N)
        c_ie = window_count_inclusion_exclusion(base, S, N)
        assert c_bf == c_ie, (N, c_bf, c_ie)
        err = abs(c_bf - N * dens)
        assert err <= bound + 1e-9
        print(f"{N:>8} {c_bf:>8} {N * dens:>12.3f} {err:>9.3f} {'yes':>10}")
    print("  the error does not grow with N -- that is the content of the theorem\n")


# ----------------------------------------------------------------------------------
# 5-8. The product cell measure, slope law, increment, orthogonality
# ----------------------------------------------------------------------------------

def cell_prob(base: Sequence[int], q: Dict[int, Fraction], S: Cell) -> Fraction:
    """Product cell measure P_q(S) = prod_{S} q_p * prod_{B\\S} (1 - q_p)."""
    out = Fraction(1)
    for p in base:
        out *= q[p] if p in S else (1 - q[p])
    return out


def expectation(base: Sequence[int], q: Dict[int, Fraction],
                f: Callable[[Cell], Fraction]) -> Fraction:
    return sum((cell_prob(base, q, S) * f(S) for S in subsets(base)), Fraction(0))


def covariance(base: Sequence[int], q: Dict[int, Fraction],
               f: Callable[[Cell], Fraction],
               g: Callable[[Cell], Fraction]) -> Fraction:
    return (expectation(base, q, lambda S: f(S) * g(S))
            - expectation(base, q, f) * expectation(base, q, g))


def log_rate(dial: Fraction, w: Dict[int, Fraction]) -> Callable[[Cell], Fraction]:
    """Lambda(S) = dial - sum_{p in S} w_p."""
    return lambda S: dial - sum((w[p] for p in S), Fraction(0))


def kappa_stat(S: Cell) -> Fraction:
    return Fraction(len(S))


def bernoulli_variances(base: Sequence[int], q: Dict[int, Fraction]) -> Dict[int, Fraction]:
    """v_p = q_p (1 - q_p)."""
    return {p: q[p] * (1 - q[p]) for p in base}


def slope_law(base: Sequence[int], q: Dict[int, Fraction],
              w: Dict[int, Fraction]) -> Fraction:
    """Theorem (slope law): beta_OLS = -(sum_p w_p v_p) / (sum_p v_p)."""
    v = bernoulli_variances(base, q)
    num = sum((w[p] * v[p] for p in base), Fraction(0))
    den = sum((v[p] for p in base), Fraction(0))
    return -num / den


def pair_energy_increment(base: Sequence[int], q: Dict[int, Fraction],
                          w: Dict[int, Fraction]) -> Fraction:
    """Theorem (closed form): R = (1/2 sum_{p,r} v_p v_r (w_p - w_r)^2) / sum_p v_p."""
    v = bernoulli_variances(base, q)
    energy = Fraction(0)
    for p in base:
        for r in base:
            energy += v[p] * v[r] * (w[p] - w[r]) ** 2
    den = sum((v[p] for p in base), Fraction(0))
    return (energy / 2) / den


def demo_slope_and_increment(base: Sequence[int],
                             q: Dict[int, Fraction],
                             w: Dict[int, Fraction],
                             dial: Fraction,
                             title: str) -> None:
    print(f"--- 5-8.  {title} ---")
    print(f"  base B = {sorted(base)},  q_p = {[str(q[p]) for p in sorted(base)]}")
    print(f"  weights w_p = {[str(w[p]) for p in sorted(base)]},  dial = {dial}")

    lam = log_rate(dial, w)
    total_mass = sum((cell_prob(base, q, S) for S in subsets(base)), Fraction(0))
    assert total_mass == 1
    print(f"  total mass                        = {total_mass}   (probability measure)")

    e_kappa = expectation(base, q, kappa_stat)
    var_kappa = covariance(base, q, kappa_stat, kappa_stat)
    cov_lk = covariance(base, q, lam, kappa_stat)
    var_lam = covariance(base, q, lam, lam)
    v = bernoulli_variances(base, q)

    # moment identities of the theory
    assert e_kappa == sum((q[p] for p in base), Fraction(0))
    assert var_kappa == sum((v[p] for p in base), Fraction(0))
    assert cov_lk == -sum((w[p] * v[p] for p in base), Fraction(0))
    assert var_lam == sum((w[p] ** 2 * v[p] for p in base), Fraction(0))
    print(f"  E[kappa]   = {e_kappa}  = sum q_p                    OK")
    print(f"  Var[kappa] = {var_kappa}  = sum v_p                    OK")
    print(f"  Cov(Lambda,kappa) = {cov_lk} = -sum w_p v_p           OK")
    print(f"  Var[Lambda]       = {var_lam} = sum w_p^2 v_p         OK")

    beta = cov_lk / var_kappa
    assert beta == slope_law(base, q, w)
    print(f"  beta_OLS = {beta} = {float(beta):+.6f}   (v-weighted mean of -w)   OK")

    # closed form for the identity increment
    increment = var_lam - cov_lk ** 2 / var_kappa
    assert increment == pair_energy_increment(base, q, w)
    print(f"  identity increment R = {increment} = {float(increment):.8f}")
    print("    ...equals the pairwise weight-spread energy formula                OK")

    # sufficiency dichotomy, checked directly against the definition
    ws = {w[p] for p in base}
    sufficient_direct = all(
        lam(S) == lam(T)
        for S in subsets(base) for T in subsets(base) if len(S) == len(T)
    )
    assert sufficient_direct == (len(ws) == 1)
    assert sufficient_direct == (increment == 0)
    print(f"  kappa sufficient?  {sufficient_direct}   "
          f"(weights constant: {len(ws) == 1}; increment zero: {increment == 0})   OK")

    # orthogonality / Pythagoras
    intercept = expectation(base, q, lam) - beta * e_kappa
    resid: Callable[[Cell], Fraction] = lambda S: lam(S) - (intercept + beta * kappa_stat(S))
    e_r = expectation(base, q, resid)
    cov_rk = covariance(base, q, resid, kappa_stat)
    var_r = covariance(base, q, resid, resid)
    assert e_r == 0 and cov_rk == 0 and var_r == increment
    assert var_lam == beta ** 2 * var_kappa + var_r
    print(f"  E[R] = {e_r},  Cov(R,kappa) = {cov_rk},  Var[R] = {var_r}          OK")
    print(f"  Pythagoras: Var(Lambda) = beta^2 Var(kappa) + Var(R):  "
          f"{var_lam} = {beta ** 2 * var_kappa} + {var_r}                        OK")
    if var_lam != 0:
        r2 = 1 - increment / var_lam
        print(f"  explained fraction R^2 = 1 - R/Var(Lambda) = {r2} = {float(r2):.6f}")

    # sharp Popoviciu bound and the certified weight spread
    m, mx = min(ws), max(ws)
    sum_v = sum((v[p] for p in base), Fraction(0))
    popoviciu = sum_v * (mx - m) ** 2 / 4
    assert increment <= popoviciu
    print(f"  Popoviciu bound: R = {float(increment):.8f} <= "
          f"(sum v)(Mx-m)^2/4 = {float(popoviciu):.8f}   OK")
    if increment > 0:
        certified = 2 * sqrt(float(increment) / float(sum_v))
        print(f"  certified weight spread from R alone: Mx - m >= {certified:.6f}  "
              f"(true spread {float(mx - m):.6f})")
    print()


# ----------------------------------------------------------------------------------
# 9. Popoviciu certificate applied to the reported experimental increments
# ----------------------------------------------------------------------------------

def certified_spread(increment: float, sum_v: float) -> float:
    """Mx - m >= 2 sqrt(increment / sum_p v_p)  (contrapositive of the Popoviciu bound)."""
    return 2.0 * sqrt(increment / sum_v)


def demo_certificates(base: Sequence[int]) -> None:
    q = {p: Fraction(1, p) for p in base}
    sum_v = float(sum((q[p] * (1 - q[p]) for p in base), Fraction(0)))
    print("--- 9.  What a measured increment certifies about the weight profile ---")
    print(f"  base B = {sorted(base)} (arithmetic marginals q_p = 1/p),  sum_p v_p = {sum_v:.6f}")
    print(f"{'scale (bits)':>13} {'increment':>11} {'verdict vs bar 0.02':>21} {'forced spread >=':>18}")
    for bits, g in ((72, 0.0071), (96, 0.0084), (128, 0.0346)):
        verdict = "sufficient" if g <= 0.02 else "NOT sufficient"
        print(f"{bits:>13} {g:>11.4f} {verdict:>21} {certified_spread(g, sum_v):>18.6f}")
    print("  a larger increment provably requires a wider spread of per-prime penalties\n")


# ----------------------------------------------------------------------------------
# 10. The boundary calculus
# ----------------------------------------------------------------------------------

def bisect_boundary(g: Callable[[float], float], bar: float,
                    lo: float, hi: float, tol: float = 1e-9) -> float:
    """Locate the unique crossing g(u) = bar of a strictly increasing g on [lo, hi]."""
    assert g(lo) <= bar < g(hi), "the bracket hypothesis of the boundary theorem must hold"
    while hi - lo > tol:
        mid = 0.5 * (lo + hi)
        if g(mid) <= bar:
            lo = mid
        else:
            hi = mid
    return 0.5 * (lo + hi)


def demo_boundary() -> None:
    print("--- 10.  Locating the sufficiency boundary ---")
    bar = 0.02
    # A strictly increasing interpolant matching the two measured increments exactly.
    # Log-linear in the scale:  g(u) = A * exp(k*u), fitted to g(96)=0.0084, g(128)=0.0346.
    import math
    u1, g1 = 96.0, 0.0084
    u2, g2 = 128.0, 0.0346
    k = (math.log(g2) - math.log(g1)) / (u2 - u1)
    A = g1 * math.exp(-k * u1)
    g: Callable[[float], float] = lambda u: A * math.exp(k * u)

    assert abs(g(96) - g1) < 1e-12 and abs(g(128) - g2) < 1e-12
    print(f"  interpolant g(u) = A e^(k u) with g(96) = {g(96):.4f}, g(128) = {g(128):.4f}")

    # downward closure: the 72-bit verdict is forced, not independent evidence
    print(f"  g(72) = {g(72):.6f} <= {bar}:  the 72-bit verdict is FORCED by the 96-bit one")

    u_star = bisect_boundary(g, bar, 96.0, 128.0)
    print(f"  unique boundary u* = {u_star:.4f} bits   (theory: strictly inside (96, 128])")
    assert 96.0 < u_star <= 128.0
    print(f"  check: g(u*) = {g(u_star):.8f} ~= bar = {bar}")

    # the verdict is exactly "below the boundary"
    print(f"{'u':>8} {'g(u)':>12} {'verdict':>16}")
    for u in (72, 96, 110, int(u_star), 120, 128):
        print(f"{u:>8} {g(u):>12.6f} {('sufficient' if g(u) <= bar else 'NOT sufficient'):>16}")
    print("  monotonicity forbids a TRUE / FALSE / TRUE pattern outright\n")


# ----------------------------------------------------------------------------------

def main() -> None:
    print("=" * 88)
    print("Composition order as a sufficient statistic -- numerical demonstrations")
    print("=" * 88 + "\n")

    base3 = (2, 3, 5)
    demo_exact_cell_counts(base3)
    demo_exact_cell_counts((2, 3, 5, 7))

    demo_window_bound((2, 3, 5), frozenset({2}), (10, 50, 97, 1000, 10_000))

    q_arith3 = {p: Fraction(1, p) for p in base3}

    demo_slope_and_increment(
        base3, q_arith3,
        {2: Fraction(35, 100), 3: Fraction(35, 100), 5: Fraction(35, 100)},
        Fraction(0),
        "Homogeneous weights w == 0.35: kappa IS sufficient, slope is exactly -0.35",
    )

    demo_slope_and_increment(
        base3, q_arith3,
        {2: Fraction(50, 100), 3: Fraction(35, 100), 5: Fraction(20, 100)},
        Fraction(0),
        "Heterogeneous weights w = (0.50, 0.35, 0.20): kappa is NOT sufficient",
    )

    # a log p profile, the Dickman-type prediction, on a five-prime base
    import math
    base5 = (2, 3, 5, 7, 11)
    q_arith5 = {p: Fraction(1, p) for p in base5}
    scale = Fraction(35, 100) / Fraction(round(1000 * math.log(3)), 1000)  # normalise at p = 3
    w_logp = {p: scale * Fraction(round(1000 * math.log(p)), 1000) for p in base5}
    demo_slope_and_increment(
        base5, q_arith5, w_logp, Fraction(0),
        "Dickman-type profile w_p proportional to log p (normalised at p = 3)",
    )

    demo_certificates((2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47))
    demo_boundary()

    print("=" * 88)
    print("All exact identities verified in rational arithmetic; all bounds satisfied.")
    print("=" * 88)


if __name__ == "__main__":
    main()
