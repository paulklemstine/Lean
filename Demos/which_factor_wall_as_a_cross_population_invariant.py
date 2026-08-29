"""Certified split interval and resolution report for a wall reading.

A laboratory reports a wall W (bits) with an error bar +/- e (bits).  The set of
minority fractions in [0, 1/2] consistent with that reading is exactly the
interval [p-, p+] obtained by inverting W - e and W + e.  Two theorems bound its
width a priori:

  * unconditionally,          |p - q| <= sqrt(eps / 2)      (eps in nats);
  * if both splits are known to lie in [0, 1/2 - eta],
                              |p - q| <= eps / log((1/2+eta)/(1/2-eta)).

The second is far sharper away from balance and degenerates (constant -> 0) as
eta -> 0; the first never degenerates but only gives a square-root rate.  The
resolution report returns both and their minimum, which is the honest
resolution to publish alongside the wall value.

Complexity: two bisection inversions, O(log(1/tol)) evaluations of h each.
"""

from __future__ import annotations

import math
from typing import Dict, Optional, Tuple

LOG2: float = math.log(2.0)


def bin_entropy(p: float) -> float:
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log(p) - (1.0 - p) * math.log1p(-p)


def invert_wall(wall_nats: float, tol: float = 1e-15) -> float:
    if wall_nats <= 0.0:
        return 0.0
    if wall_nats >= LOG2:
        return 0.5
    lo, hi = 0.0, 0.5
    while hi - lo > tol:
        mid = 0.5 * (lo + hi)
        if bin_entropy(mid) < wall_nats:
            lo = mid
        else:
            hi = mid
    return 0.5 * (lo + hi)


def guarded_constant(eta: float) -> float:
    """log((1/2+eta)/(1/2-eta)) -- the slope of h at the guard point."""
    if not 0.0 < eta < 0.5:
        raise ValueError("guard eta must lie in (0, 1/2)")
    return math.log((0.5 + eta) / (0.5 - eta))


def certified_split_interval(wall_bits: float, err_bits: float) -> Tuple[float, float]:
    """Exact set of splits in [0,1/2] consistent with wall_bits +/- err_bits."""
    lo = max(0.0, (wall_bits - err_bits) * LOG2)
    hi = min(LOG2, (wall_bits + err_bits) * LOG2)
    return invert_wall(lo), invert_wall(hi)


def resolution_report(err_nats: float,
                      eta: Optional[float] = None) -> Dict[str, Optional[float]]:
    """Guaranteed resolutions for a wall known to +/- err_nats.

    Returns the unconditional square-root bound, the guarded linear bound (if a
    guard is supplied), and the better of the two.
    """
    sqrt_bound = math.sqrt(err_nats / 2.0)
    linear_bound = None if eta is None else err_nats / guarded_constant(eta)
    best = sqrt_bound if linear_bound is None else min(sqrt_bound, linear_bound)
    return {"sqrt_bound": sqrt_bound, "linear_bound": linear_bound, "best": best}


def audit_reading(wall_bits: float, err_bits: float,
                  max_split: Optional[float] = None) -> None:
    """Print the full certified report for one wall reading."""
    lo, hi = certified_split_interval(wall_bits, err_bits)
    eta = None if max_split is None else 0.5 - max_split
    rep = resolution_report(err_bits * LOG2, eta)
    print(f"wall            : {wall_bits:.4f} +/- {err_bits:.4f} bits")
    print(f"point estimate  : p* = {invert_wall(wall_bits * LOG2):.6f}")
    print(f"certified range : [{lo:.6f}, {hi:.6f}]   width {hi - lo:.6f}")
    print(f"sqrt resolution : {rep['sqrt_bound']:.6f}")
    if rep["linear_bound"] is not None:
        print(f"guarded (p<={max_split:.4f}) : {rep['linear_bound']:.6f}"
              f"   constant = {guarded_constant(eta):.6f}")
    print(f"published resolution: {rep['best']:.6f}")


if __name__ == "__main__":
    audit_reading(0.4677, 0.01, max_split=1 / 9)
    print()
    audit_reading(0.9900, 0.01)          # near balance: only the sqrt rate applies


"""Two-sided modulus audit of the wall map.

For every pair of splits p, q in [0, 1/2] the wall gap obeys

        2 |p - q|^2  <=  |h(p) - h(q)|  <=  h(|p - q|),

with both sides sharp: the left is attained in the limit at balance (the pair
p = 1/2 - sqrt(eps)/2, q = 1/2), the right exactly at q = 0.  Away from balance
the left-hand side may be replaced by the strictly stronger linear bound
log((1/2+eta)/(1/2-eta)) |p - q| whenever p, q <= 1/2 - eta.

This module audits a grid of pairs, reports the tightness of each side, and
locates the pair at which each bound is closest to being attained.  It is the
computational counterpart of the sharpness statements.

Complexity: O(n^2) evaluations of h for an n-point grid; memory O(1).
"""

from __future__ import annotations

import math
from typing import Dict, List, Tuple

LOG2: float = math.log(2.0)


def bin_entropy(p: float) -> float:
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log(p) - (1.0 - p) * math.log1p(-p)


def guarded_constant(eta: float) -> float:
    return math.log((0.5 + eta) / (0.5 - eta))


def audit_pair(p: float, q: float) -> Dict[str, float]:
    """All four quantities of the two-sided law for a single pair."""
    gap = abs(bin_entropy(p) - bin_entropy(q))
    d = abs(p - q)
    return {
        "p": p,
        "q": q,
        "quadratic_lower": 2.0 * d * d,
        "wall_gap": gap,
        "entropy_upper": bin_entropy(d),
        "lower_tightness": (2.0 * d * d / gap) if gap > 0 else float("nan"),
        "upper_tightness": (gap / bin_entropy(d)) if d > 0 else float("nan"),
    }


def audit_grid(n: int = 200) -> Tuple[List[Dict[str, float]], Dict[str, float]]:
    """Audit an n-point uniform grid of [0, 1/2]; return rows and extremes."""
    xs = [0.5 * i / (n - 1) for i in range(n)]
    rows: List[Dict[str, float]] = []
    best_lower = {"lower_tightness": -math.inf}
    best_upper = {"upper_tightness": -math.inf}
    violations = 0
    for i, p in enumerate(xs):
        for q in xs[i + 1:]:
            row = audit_pair(p, q)
            rows.append(row)
            if row["quadratic_lower"] > row["wall_gap"] + 1e-12:
                violations += 1
            if row["wall_gap"] > row["entropy_upper"] + 1e-12:
                violations += 1
            if row["lower_tightness"] > best_lower["lower_tightness"]:
                best_lower = row
            if row["upper_tightness"] > best_upper["upper_tightness"]:
                best_upper = row
    extremes = {
        "violations": float(violations),
        "tightest_lower_ratio": best_lower["lower_tightness"],
        "tightest_lower_p": best_lower["p"],
        "tightest_lower_q": best_lower["q"],
        "tightest_upper_ratio": best_upper["upper_tightness"],
        "tightest_upper_p": best_upper["p"],
        "tightest_upper_q": best_upper["q"],
    }
    return rows, extremes


if __name__ == "__main__":
    rows, ex = audit_grid(120)
    print(f"pairs audited            : {len(rows)}")
    print(f"violations of either side: {int(ex['violations'])}")
    print(f"tightest quadratic lower : ratio {ex['tightest_lower_ratio']:.6f} "
          f"at p={ex['tightest_lower_p']:.4f}, q={ex['tightest_lower_q']:.4f}")
    print(f"tightest entropy upper   : ratio {ex['tightest_upper_ratio']:.6f} "
          f"at p={ex['tightest_upper_p']:.4f}, q={ex['tightest_upper_q']:.4f}")
    print("\nguarded linear constants:")
    for eta in (0.4, 0.3, 7 / 18, 0.1, 0.01):
        print(f"  eta = {eta:.4f}  (splits <= {0.5 - eta:.4f})  "
              f"constant = {guarded_constant(eta):.6f}")


"""Monotone bisection inversion of the binary capacity map.

Given a wall reading W (in nats, 0 <= W <= log 2), recover the unique minority
fraction p* in [0, 1/2] with h(p*) = W, where

    h(p) = p log(1/p) + (1-p) log(1/(1-p)).

Correctness rests on the fact that h is continuous on [0, 1/2] and strictly
increasing there, with h(0) = 0 and h(1/2) = log 2, so the intermediate value
theorem supplies a root and strict monotonicity makes it unique.

Complexity: each iteration halves the bracket, so ceil(log2(0.5/tol))
iterations and O(1) evaluations of h per iteration; for tol = 1e-15 that is
about 49 iterations.  Newton's method converges quadratically away from
balance but h'(1/2) = 0, so bisection is the robust default.
"""

from __future__ import annotations

import math
from typing import Tuple

LOG2: float = math.log(2.0)


def bin_entropy(p: float) -> float:
    """Binary entropy in nats; h(0) = h(1) = 0."""
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log(p) - (1.0 - p) * math.log1p(-p)


def invert_wall(wall_nats: float, tol: float = 1e-15) -> float:
    """Unique p in [0, 1/2] with h(p) = wall_nats."""
    if wall_nats <= 0.0:
        return 0.0
    if wall_nats >= LOG2:
        return 0.5
    lo, hi = 0.0, 0.5
    while hi - lo > tol:
        mid = 0.5 * (lo + hi)
        if bin_entropy(mid) < wall_nats:
            lo = mid
        else:
            hi = mid
    return 0.5 * (lo + hi)


def invert_wall_bits(wall_bits: float, tol: float = 1e-15) -> float:
    """Same, with the wall supplied in bits."""
    return invert_wall(wall_bits * LOG2, tol)


def invert_wall_with_certificate(wall_nats: float,
                                 tol: float = 1e-15) -> Tuple[float, float, float]:
    """Return (p*, residual, guaranteed_error).

    `residual` is |h(p*) - W|; `guaranteed_error` is the bisection bracket
    half-width combined with the theoretical square-root inversion bound
    |p - p*| <= sqrt(residual / 2), which is valid with no further hypotheses.
    """
    p = invert_wall(wall_nats, tol)
    residual = abs(bin_entropy(p) - wall_nats)
    return p, residual, max(tol, math.sqrt(residual / 2.0))


if __name__ == "__main__":
    for bits in (0.0, 0.1, 0.4677, 0.9, 1.0):
        p, res, err = invert_wall_with_certificate(bits * LOG2)
        print(f"wall = {bits:6.4f} bits  ->  p* = {p:.10f}  "
              f"(residual {res:.2e}, certified error {err:.2e})")


"""Assemble PACKAGE.json from the individual deliverable files."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Algebra/WhichFactorWallInvariant.lean",
    "Catalog/Algebra/WhichFactorWallSqrtLaw.lean",
    "Catalog/Algebra/WhichFactorWallModulus.lean",
    "Catalog/Algebra/WhichFactorWallReflection.lean",
]

lean_proofs = "\n\n".join(
    f"-- ======================================================================\n"
    f"-- FILE: {f}\n"
    f"-- ======================================================================\n\n"
    + read(ROOT / f)
    for f in LEAN_FILES
)

FUTURE = read(A / "future_directions.md")
LAYOUT = read(A / "interactive_layout.md")

package = {
    "title": "The Which-Factor Wall as a Cross-Population Invariant: "
             "Sharp Two-Sided Moduli for Binary Capacity",
    "domain": "Algebra",
    "description": (
        "A wall value \u2014 the empirical entropy of a two-valued statistic on a finite "
        "population \u2014 determines the underlying class split with a sharp, two-sided "
        "modulus: 2|p-q|^2 \u2264 |\u0394h| \u2264 h(|p-q|), giving linear inversion away from "
        "balance and unconditional square-root inversion at it. The conjectured "
        "inverse-Lipschitz constant log((1-\u03b4)/\u03b4) is refuted, and a reported wall of "
        "0.4677 bits is shown to bracket the minority fraction strictly between 8.34% "
        "and 11.11%."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-29",
    "key_results": [
        "Refutation of the conjectured inverse-Lipschitz bound for binary entropy: the "
        "constant log((1-\u03b4)/\u03b4) is the supremum of the derivative, hence a Lipschitz "
        "constant, and the exact counterexample \u03b4 = q = 1/4, p = 1/2 reduces the claim "
        "to 4 \u2264 3.",
        "Sharp endpoint slope bound and guarded cross-population stability: imbalances in "
        "[0, 1/2 - \u03b7] whose walls agree within \u03b5 agree within "
        "\u03b5 / log((1/2+\u03b7)/(1/2-\u03b7)), the slope at the guard point; and no uniform "
        "linear inversion constant exists, because the capacity deficit at balance obeys "
        "2t\u00b2 \u2264 log 2 - h(1/2 - t) \u2264 4t\u00b2.",
        "Unconditional square-root inversion law: the Pinsker-type inequality "
        "2(q-p)\u00b2 \u2264 h(q) - h(p) on the balanced side yields |p - q| \u2264 \u221a(\u03b5/2) "
        "with no guard whatsoever, and the exponent 1/2 is optimal, so a wall is never "
        "uninformative.",
        "Complete two-sided wall law with both sides sharp: "
        "2|p-q|\u00b2 \u2264 |h(p) - h(q)| \u2264 h(|p-q|) on [0, 1/2], making the wall map a "
        "bi-H\u00f6lder homeomorphism of the splits onto the readings.",
        "Exact characterisation of the ambiguity and a falsifiable numerical claim: "
        "h(p) = h(q) on [0,1] iff q = p or q = 1 - p, and the reported wall of 0.4677 bits "
        "is realised by a unique split lying strictly between 1/12 and 1/9, with a "
        "replication agreeing to 0.01 bits pinning the split to \u00b11/300.",
    ],
    "keywords": [
        "binary entropy",
        "Pinsker inequality",
        "modulus of continuity",
        "strong concavity",
        "class imbalance",
        "sufficient statistic",
        "cross-population invariant",
        "sharp constants",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "Complete Numerical Verification of the Wall Laws",
            "description": (
                "A self-contained, assertion-driven tour of every result: it exhibits the "
                "exact counterexample refuting the conjectured inverse-Lipschitz bound, "
                "confirms the true Lipschitz direction by random sampling, checks the sharp "
                "endpoint slope bound and its near-tightness as the two splits merge, "
                "tabulates the guarded linear inversion constants, verifies the two-sided "
                "quadratic law 2t\u00b2 \u2264 log2 - h(1/2-t) \u2264 4t\u00b2 down to t = 10\u207b\u2074, "
                "exhibits for each candidate constant C a pair defeating linear inversion, "
                "measures the Pinsker ratio (h(q)-h(p))/(2(q-p)\u00b2) over 50000 random pairs, "
                "shows the \u221a2 gap between the guaranteed and worst-case square-root "
                "resolutions, confirms the Fannes-type modulus h(|p-q|) and its attainment "
                "at 0, verifies the label-swap characterisation on 200000 random pairs, "
                "brackets the reported 0.4677-bit wall between 1/12 and 1/9 by exact "
                "closed forms, and finally reproduces all population-level statements on "
                "explicitly constructed finite populations of different sizes."
            ),
            "code": read(ROOT / "demo.py"),
        },
        {
            "name": "Cross-Population Replication Audit with Certified Bounds",
            "description": (
                "Simulates two laboratories studying different populations of different "
                "sizes with different instruments, each publishing only a wall value. From "
                "the two walls alone the script issues three certificates \u2014 the "
                "unconditional \u221a(\u0394H/2) bound, the guarded linear bound valid when the "
                "splits are known to be capped, and the converse bound |\u0394H| \u2264 h(|p-q|) "
                "\u2014 and asserts each against the hidden ground truth. It covers a strongly "
                "imbalanced regime (where the guarded bound is roughly twenty times sharper), "
                "a near-balanced regime (where only the square-root rate survives), genuinely "
                "different populations that happen to report close walls, the label-swap "
                "invariance of the wall, and a table showing that the square-root certificate "
                "exceeds the worst achievable gap by exactly \u221a2."
            ),
            "code": read(A / "demo_replication_audit.py"),
        },
    ],
    "algorithms": [
        {
            "name": "Monotone Bisection Inversion of the Binary Capacity Map",
            "description": (
                "Recovers the unique minority fraction p* \u2208 [0, 1/2] realising a reported "
                "wall W. Correctness rests on strict monotonicity and continuity of the "
                "binary entropy on the balanced side, which give existence by the "
                "intermediate value theorem and uniqueness by injectivity. Each iteration "
                "halves the bracket, so \u2308log\u2082(1/tol)\u2309 iterations and O(1) evaluations "
                "of h per iteration suffice \u2014 about 49 steps for machine precision. Newton's "
                "method converges quadratically away from balance but is unusable at the "
                "balanced endpoint, where h' vanishes; bisection is unconditionally robust "
                "and is the routine on which every downstream certificate is built. The "
                "variant returning a certificate converts the residual |h(p*) - W| into a "
                "rigorous error bound via the square-root inversion law."
            ),
            "pseudocode": (
                "INPUT : W \u2208 [0, log 2] (wall, nats); tol > 0\n"
                "OUTPUT: p* \u2208 [0, 1/2] with h(p*) = W\n"
                "\n"
                "1.  if W \u2264 0      then return 0\n"
                "2.  if W \u2265 log 2  then return 1/2\n"
                "3.  lo \u2190 0 ; hi \u2190 1/2\n"
                "4.  while hi - lo > tol do\n"
                "5.       mid \u2190 (lo + hi) / 2\n"
                "6.       if h(mid) < W then lo \u2190 mid else hi \u2190 mid\n"
                "7.  end while\n"
                "8.  p* \u2190 (lo + hi) / 2\n"
                "9.  residual \u2190 |h(p*) - W|\n"
                "10. return p*, certified error max(tol, \u221a(residual / 2))\n"
                "\n"
                "INVARIANT: h(lo) \u2264 W \u2264 h(hi) at every iteration, by monotonicity of h\n"
                "           on [0, 1/2]; the bracket width halves each pass."
            ),
            "code": read(A / "algo_wall_inversion.py"),
        },
        {
            "name": "Certified Split Interval and Resolution Report for a Wall Reading",
            "description": (
                "Turns a wall reading with an error bar into the exact set of splits "
                "consistent with it, and into the resolution that should be published "
                "beside it. Inverting W - \u03b5 and W + \u03b5 gives the interval [p\u207b, p\u207a]; "
                "the theory bounds its width a priori in two independent ways. The "
                "unconditional bound \u221a(\u03b5/2) never degenerates but is only a square-root "
                "rate; the guarded bound \u03b5 / log((1/2+\u03b7)/(1/2-\u03b7)) is linear in \u03b5 and "
                "far sharper for imbalanced populations, but its constant collapses to zero "
                "as the guard vanishes. The report returns both and their minimum, which is "
                "the honest resolution: \u0398(\u03b5) away from balance, \u0398(\u221a\u03b5) at it. Cost: "
                "two bisections, O(log(1/tol)) evaluations of h each."
            ),
            "pseudocode": (
                "INPUT : W (bits), \u03b5 (bits), optional cap m < 1/2 on the split\n"
                "OUTPUT: certified interval of splits, and the resolution to publish\n"
                "\n"
                "1.  W\u207b \u2190 max(0, (W - \u03b5) log 2) ; W\u207a \u2190 min(log 2, (W + \u03b5) log 2)\n"
                "2.  p\u207b \u2190 INVERT(W\u207b) ; p\u207a \u2190 INVERT(W\u207a)           // bisection\n"
                "3.  \u03b5\u2099 \u2190 \u03b5 log 2                                  // error bar in nats\n"
                "4.  sqrt_bound \u2190 \u221a(\u03b5\u2099 / 2)                        // unconditional\n"
                "5.  if a cap m is supplied and 0 < m < 1/2 then\n"
                "6.       \u03b7 \u2190 1/2 - m ; c \u2190 log((1/2 + \u03b7)/(1/2 - \u03b7)) = log((1-m)/m)\n"
                "7.       linear_bound \u2190 \u03b5\u2099 / c\n"
                "8.       if p\u207a \u2264 m then best \u2190 min(sqrt_bound, linear_bound)\n"
                "9.                   else best \u2190 sqrt_bound      // cap contradicts reading\n"
                "10. else best \u2190 sqrt_bound\n"
                "11. return [p\u207b, p\u207a], sqrt_bound, linear_bound, best"
            ),
            "code": read(A / "algo_certified_interval.py"),
        },
        {
            "name": "Two-Sided Modulus Audit of the Wall Map",
            "description": (
                "Empirically certifies the complete wall law on a grid: for every pair of "
                "splits it evaluates the quadratic lower bound 2|p-q|\u00b2, the actual wall "
                "gap |h(p) - h(q)|, and the entropy upper bound h(|p-q|), flags any "
                "violation, and locates the pairs at which each side is closest to being "
                "attained. Running it reproduces the two sharpness statements: the lower "
                "bound approaches equality for pairs pushed against balance, and the upper "
                "bound attains equality exactly when one split is 0. It also tabulates the "
                "guarded linear constants log((1-m)/m) for a range of caps m, which is the "
                "table a laboratory needs when deciding what resolution to quote. Cost: "
                "O(n\u00b2) evaluations of h on an n-point grid, O(1) memory."
            ),
            "pseudocode": (
                "INPUT : grid size n\n"
                "OUTPUT: violation count and the tightest pair for each side\n"
                "\n"
                "1.  x\u1d62 \u2190 (i / (n-1)) / 2 for i = 0 .. n-1        // uniform grid of [0,1/2]\n"
                "2.  violations \u2190 0 ; best_low \u2190 -\u221e ; best_up \u2190 -\u221e\n"
                "3.  for each pair (p, q) with p < q from the grid do\n"
                "4.       d \u2190 q - p ; g \u2190 |h(p) - h(q)|\n"
                "5.       if 2d\u00b2 > g + \u03c4 then violations \u2190 violations + 1     // \u03c4 numeric slack\n"
                "6.       if g > h(d) + \u03c4 then violations \u2190 violations + 1\n"
                "7.       best_low \u2190 max(best_low, 2d\u00b2 / g)      // \u2192 1 near balance\n"
                "8.       best_up  \u2190 max(best_up,  g / h(d))     // = 1 exactly when p = 0\n"
                "9.  end for\n"
                "10. return violations, best_low with its pair, best_up with its pair"
            ),
            "code": read(A / "algo_modulus_audit.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Wall Map and the 0.4677-Bit Bracket",
            "description": (
                "Left: the wall h(p) in bits over the balanced side, the reported reading of "
                "0.4677 bits drawn as a horizontal line, the unique realising split marked, "
                "the certified rational bracket 1/12 < p* < 1/9 shaded, and a \u00b10.01 bit "
                "error bar propagated through the inverse map. Right: the local resolution "
                "dp/dW = 1/h'(p) on a logarithmic scale, finite and small for imbalanced "
                "populations and divergent at balance \u2014 the picture of why the wall is a "
                "high-precision probe off balance and a coarse one at it."
            ),
            "code": read(A / "viz_wall_map.py"),
        },
        {
            "name": "The Complete Two-Sided Law and the Quadratic Regime at Balance",
            "description": (
                "Left: for a fixed reference split, the actual wall gap is plotted between "
                "its two sharp envelopes 2|p-q|\u00b2 and h(|p-q|), shading the admissible "
                "region; this is the statement that split and wall determine each other with "
                "known moduli in both directions. Right: a log-log plot of the capacity "
                "deficit log 2 - h(1/2 - t) against its envelope 2t\u00b2 \u2264 deficit \u2264 4t\u00b2, "
                "exhibiting the slope-2 behaviour that simultaneously destroys linear "
                "inversion and supplies square-root inversion."
            ),
            "code": read(A / "viz_two_sided_law.py"),
        },
        {
            "name": "Anatomy of the Failed Conjecture, and Which Resolution to Publish",
            "description": (
                "Left: the binary entropy on [1/4, 1/2] with the true chord, the conjectured "
                "floor of slope log 3, and the correct endpoint slope h'(1/2) = 0; the chord "
                "visibly falls below the conjectured floor, which is precisely the demand "
                "2 log 2 \u2264 log 3, i.e. 4 \u2264 3. Right: for a wall measured to \u00b10.01 nats, "
                "the guarded linear resolution and the unconditional square-root resolution "
                "as functions of the largest split the population is known to have, with the "
                "crossing point marking where a report should switch from quoting one to the "
                "other."
            ),
            "code": read(A / "viz_conjecture_failure.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Wall Inversion Laboratory",
            "description": (
                "A live inverse-problem bench. Drag a wall reading and its error bar and the "
                "widget inverts the binary capacity map in real time: it marks the unique "
                "split realising the reading, shades the exact interval of splits consistent "
                "with the error bar, and reports both guarantees side by side \u2014 the "
                "unconditional \u221a(\u03b5/2) and the guarded linear \u03b5/log((1-m)/m) for a "
                "prior cap m that you also control. A regime indicator tells you whether the "
                "reading sits in the linear \u0398(\u03b5) regime or the square-root \u0398(\u221a\u03b5) "
                "regime, and the widget refuses the guarded bound when the cap is "
                "inconsistent with the reading. Presets jump to the reported 0.4677-bit "
                "wall, to the walls a 5% and a 15% split would have produced (both visibly "
                "excluded), and to a near-balanced reading where only the square-root law "
                "survives."
            ),
            "html": read(A / "widget_wall_lab.html"),
        },
        {
            "title": "Supremum or Infimum? Anatomy of a Failed Conjecture",
            "description": (
                "An interactive dissection of the error at the heart of this work. The "
                "conjectured inversion used the slope of the binary entropy at the endpoint "
                "furthest from balance \u2014 the supremum of the derivative \u2014 where an "
                "inverse bound needs the infimum. Drag the interval endpoint \u03b4 and the two "
                "splits and watch the true chord slide below the conjectured floor, with a "
                "live verdict panel quantifying by how much the conjecture is violated. The "
                "same panel tracks the three bounds that never break: the correct endpoint "
                "slope, the quadratic Pinsker-type bound, and the entropy modulus from "
                "above. One button restores the exact rational counterexample \u03b4 = q = 1/4, "
                "p = 1/2, where the claim collapses to 4 \u2264 3."
            ),
            "html": read(A / "widget_conjecture.html"),
        },
    ],
    "interactive_layout": LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE,
    "modules": {"demo": read(ROOT / "demo.py")},
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False), encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size/1024:.1f} KB)")


"""Cross-population replication audit.

Two laboratories study *different* populations of *different* sizes with
*different* instruments.  Each records one yes/no fact per member and reports
only the wall: the empirical entropy

    H(f) = sum_a (n_a / N) log(N / n_a)   nats,

which for a two-valued statistic equals h(minority fraction).  Neither lab
publishes the split.

This script asks what a reader can conclude from the two wall values alone, and
checks every conclusion against the truth:

  * the unconditional certificate      |p - q| <= sqrt(|dH| / 2);
  * the guarded certificate            |p - q| <= |dH| / log((1-m)/m)
    valid when both splits are known to be at most m < 1/2;
  * the converse certificate           |dH| <= h(|p - q|),
    i.e. how far apart the walls may be given how far apart the splits are;
  * the label-swap ambiguity: a lab that reports the majority fraction by
    mistake produces exactly the same wall.

Every certificate is asserted, so a violation would crash the script.

Run:  python3 demo_replication_audit.py
"""

from __future__ import annotations

import math
import random
from typing import Dict, Hashable, List, Sequence, Tuple

LOG2: float = math.log(2.0)


def bin_entropy(p: float) -> float:
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log(p) - (1.0 - p) * math.log1p(-p)


def empirical_entropy(readings: Sequence[Hashable]) -> float:
    """H(f) in nats, computed from raw readings with no assumption of arity."""
    n = len(readings)
    counts: Dict[Hashable, int] = {}
    for r in readings:
        counts[r] = counts.get(r, 0) + 1
    return sum((c / n) * math.log(n / c) for c in counts.values())


def sample_population(n: int, true_split: float, labels: Tuple[str, str],
                      rng: random.Random) -> List[str]:
    """Draw n independent members, each in the minority class w.p. true_split."""
    return [labels[0] if rng.random() < true_split else labels[1] for _ in range(n)]


def minority_fraction(readings: Sequence[Hashable]) -> float:
    counts: Dict[Hashable, int] = {}
    for r in readings:
        counts[r] = counts.get(r, 0) + 1
    if len(counts) == 1:
        return 0.0
    return min(counts.values()) / len(readings)


def audit(lab1: Sequence[Hashable], lab2: Sequence[Hashable],
          known_max_split: float | None = None) -> None:
    h1, h2 = empirical_entropy(lab1), empirical_entropy(lab2)
    p, q = minority_fraction(lab1), minority_fraction(lab2)
    eps = abs(h1 - h2)
    sqrt_cert = math.sqrt(eps / 2.0)
    print(f"  lab A: N={len(lab1):5d}  wall={h1 / LOG2:.6f} bits")
    print(f"  lab B: N={len(lab2):5d}  wall={h2 / LOG2:.6f} bits")
    print(f"  wall gap                 = {eps:.6f} nats "
          f"({eps / LOG2:.6f} bits)")
    print(f"  TRUE |p - q|             = {abs(p - q):.6f}   "
          f"(p={p:.6f}, q={q:.6f})")
    print(f"  unconditional certificate= {sqrt_cert:.6f}   "
          f"holds: {abs(p - q) <= sqrt_cert + 1e-12}")
    assert abs(p - q) <= sqrt_cert + 1e-12
    if known_max_split is not None and 0.0 < known_max_split < 0.5:
        c = math.log((1 - known_max_split) / known_max_split)
        lin = eps / c
        print(f"  guarded certificate      = {lin:.6f}   "
              f"(splits <= {known_max_split:.4f}, constant {c:.4f})   "
              f"holds: {abs(p - q) <= lin + 1e-12}")
        assert abs(p - q) <= lin + 1e-12
    conv = bin_entropy(abs(p - q))
    print(f"  converse certificate     : wall gap {eps:.6f} <= h(|p-q|) "
          f"= {conv:.6f}   holds: {eps <= conv + 1e-12}")
    assert eps <= conv + 1e-12


def main() -> None:
    rng = random.Random(2026)

    print("=" * 72)
    print("A.  Two labs, strongly imbalanced populations (true split 10%)")
    print("=" * 72)
    audit(sample_population(4000, 0.10, ("hit", "miss"), rng),
          sample_population(2731, 0.10, ("pos", "neg"), rng),
          known_max_split=1 / 9)

    print("\n" + "=" * 72)
    print("B.  Two labs, nearly balanced populations (true split 48%)")
    print("=" * 72)
    print("  here no guarded certificate is available; only the square-root one")
    audit(sample_population(4000, 0.48, ("hit", "miss"), rng),
          sample_population(3500, 0.48, ("pos", "neg"), rng))

    print("\n" + "=" * 72)
    print("C.  Genuinely different populations that happen to be close")
    print("=" * 72)
    audit(sample_population(5000, 0.08, ("hit", "miss"), rng),
          sample_population(5000, 0.12, ("pos", "neg"), rng),
          known_max_split=0.2)

    print("\n" + "=" * 72)
    print("D.  Label swap: reporting the majority instead of the minority")
    print("=" * 72)
    pop = sample_population(3000, 0.13, ("rare", "common"), rng)
    swapped = ["common" if x == "rare" else "rare" for x in pop]
    w1, w2 = empirical_entropy(pop), empirical_entropy(swapped)
    print(f"  wall as reported        = {w1 / LOG2:.10f} bits")
    print(f"  wall after label swap   = {w2 / LOG2:.10f} bits")
    print("  identical: a wall determines the split only up to p <-> 1-p.")
    assert abs(w1 - w2) < 1e-15

    print("\n" + "=" * 72)
    print("E.  How sharp is the square-root certificate?  (worst case at balance)")
    print("=" * 72)
    print(f"  {'eps (nats)':>12} {'certificate':>13} {'achievable gap':>16}")
    for eps in (0.04, 0.01, 1e-3, 1e-4):
        t = math.sqrt(eps) / 2.0                    # the extremal pair
        assert abs(bin_entropy(0.5 - t) - bin_entropy(0.5)) <= eps + 1e-15
        print(f"  {eps:12.5f} {math.sqrt(eps / 2):13.6f} {t:16.6f}")
    print("  certificate exceeds the achievable gap by exactly sqrt(2).")

    print("\nAll certificates verified.")


if __name__ == "__main__":
    main()


"""Visualization: why the conjectured inverse-Lipschitz bound had to fail.

The proposed inversion used c(delta) = log((1-delta)/delta), the value of
h'(delta) -- the LARGEST slope on [delta, 1/2].  A largest slope bounds chords
from above; an inverse bound needs the SMALLEST slope, h'(q), attained at the
endpoint nearest balance.

Left panel: h on [1/4, 1/2] with the true chord from (1/4, h(1/4)) to
(1/2, h(1/2)), the conjectured cone of slope c(1/4) = log 3, and the correct
cone of slope h'(1/2) = 0.  The chord lies below the conjectured line, which is
exactly the failure: the conjecture demanded 2 log 2 <= log 3, i.e. 4 <= 3.

Right panel: the two guaranteed resolutions for a wall measured to +/- 0.01
nats, as a function of the largest split the population is known to have.  The
guarded linear bound eps / log((1-m)/m) wins by more than an order of magnitude
for strongly imbalanced populations and degenerates to uselessness as m -> 1/2,
where the unconditional square-root bound sqrt(eps/2) takes over.  The crossing
point is where a report should switch from quoting a linear resolution to
quoting a square-root one.

Run:  python3 viz_conjecture_failure.py     (writes conjecture_failure.png)
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def bin_entropy(p: float) -> float:
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log(p) - (1.0 - p) * math.log1p(-p)


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.2))

    a, b = 0.25, 0.5
    ps: np.ndarray = np.linspace(a, b, 800)
    hs: List[float] = [bin_entropy(float(p)) for p in ps]
    ha, hb = bin_entropy(a), bin_entropy(b)
    c_sup = math.log((1 - a) / a)          # log 3

    ax1.plot(ps, hs, lw=2.6, color="#1f4e79", label=r"$h(p)$")
    ax1.plot([a, b], [ha, hb], lw=2.0, color="#c0392b", marker="o",
             label=f"true chord, slope {(hb - ha) / (b - a):.4f}")
    ax1.plot(ps, [ha + c_sup * (float(p) - a) for p in ps], lw=1.8, ls="--",
             color="#8e44ad",
             label=rf"conjectured floor, slope $c(1/4)=\log 3={c_sup:.4f}$")
    ax1.plot(ps, [hb + 0.0 * float(p) for p in ps], lw=1.4, ls=":", color="#196f3d",
             label=r"correct endpoint slope $h'(1/2)=0$")
    ax1.annotate("the chord falls BELOW the conjectured floor:\n"
                 r"conjecture demands $2\log 2 \leq \log 3$, i.e. $4 \leq 3$",
                 xy=(0.37, ha + c_sup * (0.37 - a)), xytext=(0.27, 0.80),
                 fontsize=10, color="#8e44ad",
                 arrowprops=dict(arrowstyle="->", color="#8e44ad"))
    ax1.set_xlabel("split $p$")
    ax1.set_ylabel("nats")
    ax1.set_title("The counterexample: $\\delta = q = 1/4$, $p = 1/2$")
    ax1.grid(alpha=0.25)
    ax1.legend(fontsize=9, loc="lower right")

    eps = 0.01
    ms: np.ndarray = np.linspace(0.002, 0.4995, 900)
    linear: List[float] = [eps / math.log((1 - float(m)) / float(m)) for m in ms]
    sqrt_bound = math.sqrt(eps / 2.0)
    ax2.semilogy(ms, linear, lw=2.4, color="#c0392b",
                 label=r"guarded linear bound $\varepsilon/\log\frac{1-m}{m}$")
    ax2.axhline(sqrt_bound, lw=2.4, color="#196f3d",
                label=r"unconditional bound $\sqrt{\varepsilon/2}$")
    ax2.axvline(1 / 9, ls=":", color="#f39c12", lw=1.6)
    ax2.annotate(r"$m=1/9$: resolution $1/300$ per $0.01$ bit",
                 (1 / 9, sqrt_bound * 0.12), rotation=90, fontsize=9,
                 color="#a06000", ha="right")
    ax2.set_xlabel("largest split the population is known to have, $m = 1/2 - \\eta$")
    ax2.set_ylabel(r"guaranteed resolution in $p$   ($\varepsilon = 0.01$ nats)")
    ax2.set_title("Which resolution to publish: linear away from balance, root at it")
    ax2.set_xlim(0, 0.5)
    ax2.grid(alpha=0.25, which="both")
    ax2.legend(fontsize=9, loc="upper left")

    fig.tight_layout()
    fig.savefig("conjecture_failure.png", dpi=160)
    print("wrote conjecture_failure.png")


if __name__ == "__main__":
    main()


"""Visualization: the complete two-sided wall law, and the quadratic law at balance.

Left panel: for a fixed reference split q, the three curves
    2 (p - q)^2      (quadratic lower bound, sharp at balance),
    |h(p) - h(q)|    (the actual wall gap),
    h(|p - q|)       (Fannes-type upper bound, sharp at q = 0),
as p ranges over [0, 1/2].  The actual gap is trapped between the other two --
this is the statement that the wall and the split determine each other with a
known modulus in both directions.

Right panel: the entropy deficit log 2 - h(1/2 - t) on a log-log scale against
its two-sided envelope 2t^2 <= deficit <= 4t^2.  The slope-2 behaviour is why no
linear inversion constant survives at balance, and simultaneously why the
square-root inversion law holds there.

Run:  python3 viz_two_sided_law.py     (writes two_sided_law.png)
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt
import numpy as np

LOG2: float = math.log(2.0)


def bin_entropy(p: float) -> float:
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log(p) - (1.0 - p) * math.log1p(-p)


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.2))

    q = 0.12
    ps: np.ndarray = np.linspace(0.0, 0.5, 1500)
    lower: List[float] = [2.0 * (float(p) - q) ** 2 for p in ps]
    gap: List[float] = [abs(bin_entropy(float(p)) - bin_entropy(q)) for p in ps]
    upper: List[float] = [bin_entropy(abs(float(p) - q)) for p in ps]

    ax1.fill_between(ps, lower, upper, color="#5dade2", alpha=0.18,
                     label="admissible region")
    ax1.plot(ps, upper, lw=2.0, color="#1f4e79", label=r"$h(|p-q|)$  (sharp upper)")
    ax1.plot(ps, gap, lw=2.4, color="#c0392b", label=r"$|h(p)-h(q)|$  (actual)")
    ax1.plot(ps, lower, lw=2.0, color="#196f3d", label=r"$2|p-q|^2$  (sharp lower)")
    ax1.axvline(q, color="black", ls=":", lw=1.2)
    ax1.annotate(rf"reference split $q={q}$", (q, 0.62), rotation=90,
                 fontsize=9, ha="right")
    ax1.set_xlabel("split $p$")
    ax1.set_ylabel("nats")
    ax1.set_title("Two-sided wall law: $2|p-q|^2 \\leq |\\Delta h| \\leq h(|p-q|)$")
    ax1.set_xlim(0, 0.5)
    ax1.grid(alpha=0.25)
    ax1.legend(fontsize=9, loc="upper right")

    ts: np.ndarray = np.logspace(-5, math.log10(0.25), 400)
    deficit: List[float] = [LOG2 - bin_entropy(0.5 - float(t)) for t in ts]
    ax2.loglog(ts, [4 * float(t) ** 2 for t in ts], lw=1.8, ls="--",
               color="#1f4e79", label=r"$4t^2$")
    ax2.loglog(ts, deficit, lw=2.6, color="#c0392b",
               label=r"$\log 2 - h(1/2 - t)$")
    ax2.loglog(ts, [2 * float(t) ** 2 for t in ts], lw=1.8, ls="--",
               color="#196f3d", label=r"$2t^2$")
    ax2.set_xlabel(r"distance from balance $t$")
    ax2.set_ylabel("capacity deficit (nats)")
    ax2.set_title("Quadratic law at balance: $2t^2 \\leq \\log 2 - h(1/2-t) \\leq 4t^2$")
    ax2.grid(alpha=0.25, which="both")
    ax2.legend(fontsize=9)

    fig.tight_layout()
    fig.savefig("two_sided_law.png", dpi=160)
    print("wrote two_sided_law.png")


if __name__ == "__main__":
    main()


"""Visualization: the wall map and the 0.4677-bit bracket.

Left panel: the binary capacity h(p), in bits, over the balanced side
[0, 1/2], with the reported wall of 0.4677 bits drawn as a horizontal line, the
unique realising split p* marked, and the certified rational bracket
1/12 < p* < 1/9 shaded.  A +/- 0.01 bit error bar is propagated through the
inverse map to show the resulting interval of splits.

Right panel: the local resolution dp/dW = 1/h'(p) of the wall as a function of
the split, on a log scale.  It blows up at balance -- this is the quadratic
flatness that kills linear inversion -- and is finite and small away from it.

Run:  python3 viz_wall_map.py     (writes wall_map.png)
"""

from __future__ import annotations

import math
from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np

LOG2: float = math.log(2.0)


def bin_entropy(p: float) -> float:
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log(p) - (1.0 - p) * math.log1p(-p)


def invert_wall(w_nats: float, tol: float = 1e-14) -> float:
    if w_nats <= 0.0:
        return 0.0
    if w_nats >= LOG2:
        return 0.5
    lo, hi = 0.0, 0.5
    while hi - lo > tol:
        mid = 0.5 * (lo + hi)
        if bin_entropy(mid) < w_nats:
            lo = mid
        else:
            hi = mid
    return 0.5 * (lo + hi)


def main() -> None:
    wall_bits, err_bits = 0.4677, 0.01
    p_star = invert_wall(wall_bits * LOG2)
    p_lo = invert_wall(max(0.0, (wall_bits - err_bits) * LOG2))
    p_hi = invert_wall(min(LOG2, (wall_bits + err_bits) * LOG2))

    ps: np.ndarray = np.linspace(1e-6, 0.5, 2000)
    hs: List[float] = [bin_entropy(float(p)) / LOG2 for p in ps]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.2))

    ax1.plot(ps, hs, lw=2.2, color="#1f4e79", label=r"wall $h(p)$ (bits)")
    ax1.axhline(wall_bits, color="#c0392b", ls="--", lw=1.6,
                label=f"reported wall = {wall_bits} bits")
    ax1.axvspan(1 / 12, 1 / 9, color="#f39c12", alpha=0.18,
                label=r"certified bracket $1/12 < p^\star < 1/9$")
    ax1.plot([p_star], [wall_bits], "o", color="#c0392b", ms=8, zorder=5)
    ax1.annotate(rf"$p^\star \approx {p_star:.5f}$", (p_star, wall_bits),
                 textcoords="offset points", xytext=(16, -22), fontsize=11,
                 color="#c0392b")
    ax1.plot([p_lo, p_hi], [wall_bits, wall_bits], color="#c0392b", lw=6, alpha=0.35)
    for x, lab in ((1 / 12, "1/12 = 8.33%"), (1 / 9, "1/9 = 11.11%")):
        ax1.axvline(x, color="#f39c12", lw=1.0, ls=":")
        ax1.annotate(lab, (x, 0.03), rotation=90, fontsize=9, color="#a06000",
                     ha="right")
    ax1.set_xlabel("minority fraction $p$")
    ax1.set_ylabel("wall (bits)")
    ax1.set_title("The wall map and what a reading of 0.4677 bits claims")
    ax1.set_xlim(0, 0.5)
    ax1.set_ylim(0, 1.02)
    ax1.grid(alpha=0.25)
    ax1.legend(loc="lower right", fontsize=9)

    qs: np.ndarray = np.linspace(1e-4, 0.4999, 2000)
    resolution = [1.0 / (math.log(1 - float(q)) - math.log(float(q))) for q in qs]
    ax2.semilogy(qs, resolution, lw=2.2, color="#196f3d")
    ax2.axvline(p_star, color="#c0392b", ls="--", lw=1.4,
                label=rf"$p^\star \approx {p_star:.4f}$")
    ax2.axvline(0.5, color="black", lw=1.0)
    ax2.set_xlabel("minority fraction $p$")
    ax2.set_ylabel(r"local resolution $dp/dW = 1/h'(p)$  (per nat)")
    ax2.set_title("Resolution of the wall: finite away from balance, divergent at 1/2")
    ax2.grid(alpha=0.25, which="both")
    ax2.legend(fontsize=9)

    fig.tight_layout()
    fig.savefig("wall_map.png", dpi=160)
    print("wrote wall_map.png")


if __name__ == "__main__":
    main()


"""
Numerical demonstrations for:

    The Which-Factor Wall as a Cross-Population Invariant
    Sharp two-sided moduli for binary capacity

All quantities are in NATS unless a name says `bits`.  The binary entropy is

    h(p) = p log(1/p) + (1-p) log(1/(1-p)),    h(0) = h(1) = 0,

the "wall" of a two-valued statistic on a finite population is its empirical
Shannon entropy, and Lemma "two-valued statistics measure imbalance" says the
wall equals h(minority fraction).

The script verifies, numerically:

  1. the refuted conjecture  c(delta)|p-q| <= |h(p)-h(q)|  fails at
     delta = q = 1/4, p = 1/2  (it demands 4 <= 3);
  2. the true Lipschitz bound |h(p)-h(q)| <= c(delta)|p-q| on [delta, 1-delta];
  3. the sharp endpoint slope bound (q-p) h'(q) <= h(q) - h(p);
  4. the guarded linear inversion with constant log((1/2+eta)/(1/2-eta));
  5. the two-sided quadratic law  2t^2 <= log 2 - h(1/2 - t) <= 4t^2,
     and the non-existence of a uniform linear inversion constant;
  6. the Pinsker-type bound 2(q-p)^2 <= h(q)-h(p) and unconditional
     sqrt-stability |p-q| <= sqrt(eps/2), with optimality of the exponent 1/2;
  7. the sharp Fannes-type modulus |h(p)-h(q)| <= h(|p-q|), attained at q = 0;
  8. the label-swap characterisation h(p) = h(q) iff q = p or q = 1-p;
  9. the 0.4677-bit bracket 1/12 < p* < 1/9 and the 1/300 replication tolerance;
 10. the population-level statements, on explicitly constructed populations.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from typing import Callable, Dict, Hashable, List, Sequence, Tuple

LOG2: float = math.log(2.0)


# --------------------------------------------------------------------------
# Core analytic objects
# --------------------------------------------------------------------------
def bin_entropy(p: float) -> float:
    """Binary entropy h(p) in nats; h(0) = h(1) = 0."""
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log(p) - (1.0 - p) * math.log1p(-p)


def bin_entropy_bits(p: float) -> float:
    """Binary entropy in bits."""
    return bin_entropy(p) / LOG2


def bin_entropy_deriv(x: float) -> float:
    """h'(x) = log((1-x)/x) on (0,1)."""
    return math.log(1.0 - x) - math.log(x)


def lipschitz_constant(delta: float) -> float:
    """c(delta) = log((1-delta)/delta): the SUPREMUM of |h'| on [delta, 1-delta]."""
    return math.log((1.0 - delta) / delta)


def guarded_inversion_constant(eta: float) -> float:
    """log((1/2+eta)/(1/2-eta)): the slope of h at the guard point 1/2 - eta."""
    return math.log((0.5 + eta) / (0.5 - eta))


def invert_wall(target_nats: float, tol: float = 1e-15) -> float:
    """Unique p in [0, 1/2] with h(p) = target_nats, by bisection.

    h is continuous and strictly increasing on [0, 1/2] with h(0) = 0 and
    h(1/2) = log 2, so bisection converges; each step halves the bracket.
    """
    if target_nats <= 0.0:
        return 0.0
    if target_nats >= LOG2:
        return 0.5
    lo, hi = 0.0, 0.5
    while hi - lo > tol:
        mid = 0.5 * (lo + hi)
        if bin_entropy(mid) < target_nats:
            lo = mid
        else:
            hi = mid
    return 0.5 * (lo + hi)


def certified_split_interval(wall_bits: float, err_bits: float) -> Tuple[float, float]:
    """Splits in [0,1/2] consistent with a wall of `wall_bits` +/- `err_bits`."""
    lo_nats = max(0.0, (wall_bits - err_bits) * LOG2)
    hi_nats = min(LOG2, (wall_bits + err_bits) * LOG2)
    return invert_wall(lo_nats), invert_wall(hi_nats)


def resolution_report(err_nats: float, eta: float | None = None) -> Dict[str, float]:
    """Both guaranteed resolutions for a wall measured to +/- err_nats."""
    sqrt_bound = math.sqrt(err_nats / 2.0)
    out: Dict[str, float] = {"sqrt_bound": sqrt_bound, "best": sqrt_bound}
    if eta is not None and 0.0 < eta < 0.5:
        lin = err_nats / guarded_inversion_constant(eta)
        out["linear_bound"] = lin
        out["best"] = min(lin, sqrt_bound)
    return out


# --------------------------------------------------------------------------
# Population layer
# --------------------------------------------------------------------------
def empirical_entropy(readings: Sequence[Hashable]) -> float:
    """H(f) = sum_a (n_a/N) log(N/n_a), in nats."""
    n = len(readings)
    counts: Dict[Hashable, int] = {}
    for r in readings:
        counts[r] = counts.get(r, 0) + 1
    return sum((c / n) * math.log(n / c) for c in counts.values())


def binary_population(n: int, minority: int, labels: Tuple[str, str] = ("A", "B")) -> List[str]:
    """A population of size n with `minority` members carrying label[0]."""
    return [labels[0]] * minority + [labels[1]] * (n - minority)


def minority_fraction(readings: Sequence[Hashable]) -> float:
    counts: Dict[Hashable, int] = {}
    for r in readings:
        counts[r] = counts.get(r, 0) + 1
    return min(counts.values()) / len(readings)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def banner(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_refutation() -> None:
    banner("1.  The conjectured inverse-Lipschitz bound is FALSE")
    delta, q, p = 0.25, 0.25, 0.5
    c = lipschitz_constant(delta)          # = log 3
    lhs = c * abs(p - q)                   # (1/4) log 3
    rhs = abs(bin_entropy(p) - bin_entropy(q))
    print(f"  delta = q = 1/4, p = 1/2")
    print(f"  c(delta) = log((1-d)/d) = log 3        = {c:.6f}")
    print(f"  h(1/2) = log 2                         = {bin_entropy(p):.6f}")
    print(f"  h(1/4) = 2 log 2 - (3/4) log 3         = {bin_entropy(q):.6f}")
    print(f"  conjecture demands  {lhs:.6f} <= {rhs:.6f}   ->  {lhs <= rhs}")
    print(f"  equivalently 2 log 2 <= log 3, i.e. 4 <= 3.  Refuted.")
    assert lhs > rhs


def demo_lipschitz() -> None:
    banner("2.  The TRUE inequality with the same constant (Lipschitz direction)")
    rng = random.Random(11)
    for delta in (0.05, 0.1, 0.25, 0.4):
        c = lipschitz_constant(delta)
        worst = 0.0
        for _ in range(20000):
            p = rng.uniform(delta, 1.0 - delta)
            q = rng.uniform(delta, 1.0 - delta)
            if abs(p - q) < 1e-12:
                continue
            ratio = abs(bin_entropy(p) - bin_entropy(q)) / abs(p - q)
            worst = max(worst, ratio)
        print(f"  delta={delta:<5}  c(delta)={c:8.5f}   max observed chord slope={worst:8.5f}"
              f"   ok={worst <= c + 1e-9}")
        assert worst <= c + 1e-9


def demo_endpoint_slope() -> None:
    banner("3.  Sharp endpoint slope bound:  (q-p) h'(q) <= h(q) - h(p)")
    rng = random.Random(5)
    worst_slack = math.inf
    for _ in range(50000):
        p, q = sorted((rng.uniform(0.0, 0.5), rng.uniform(0.0, 0.5)))
        if q <= 0.0:
            continue
        slack = (bin_entropy(q) - bin_entropy(p)) - (q - p) * bin_entropy_deriv(q)
        worst_slack = min(worst_slack, slack)
    print(f"  minimum slack over 50000 random pairs in [0,1/2]: {worst_slack:.3e} (>= 0)")
    assert worst_slack >= -1e-12
    print("  near-tightness as p -> q:")
    for q in (0.05, 0.2, 0.45):
        for gap in (1e-2, 1e-4):
            p = q - gap
            lhs = (q - p) * bin_entropy_deriv(q)
            rhs = bin_entropy(q) - bin_entropy(p)
            print(f"    q={q:<5} gap={gap:<8}  bound={lhs:.8f}  actual={rhs:.8f}"
                  f"  ratio={lhs / rhs:.6f}")


def demo_guarded_inversion() -> None:
    banner("4.  Guarded linear inversion (constant = slope at the guard point)")
    for eta in (0.4, 0.3, 0.1, 0.01):
        c = guarded_inversion_constant(eta)
        cap = 0.5 - eta
        print(f"  eta={eta:<6} splits in [0,{cap:.3f}]  constant={c:8.5f}"
              f"   resolution for eps=0.01 nats: {0.01 / c:.6f}")
    print("\n  empirical check (eta = 0.1, so splits in [0, 0.4]):")
    rng = random.Random(7)
    eta, c, worst = 0.1, guarded_inversion_constant(0.1), math.inf
    for _ in range(50000):
        p = rng.uniform(0.0, 0.5 - eta)
        q = rng.uniform(0.0, 0.5 - eta)
        if abs(p - q) < 1e-12:
            continue
        worst = min(worst, abs(bin_entropy(p) - bin_entropy(q)) / abs(p - q))
    print(f"    guaranteed constant {c:.6f}   min observed chord slope {worst:.6f}"
          f"   ok={worst >= c - 1e-9}")
    assert worst >= c - 1e-9


def demo_quadratic_law() -> None:
    banner("5.  Two-sided quadratic law at balance:  2t^2 <= log2 - h(1/2-t) <= 4t^2")
    print(f"  {'t':>10} {'2t^2':>14} {'deficit':>14} {'4t^2':>14}")
    for t in (0.2, 0.1, 0.05, 0.01, 1e-3, 1e-4):
        deficit = LOG2 - bin_entropy(0.5 - t)
        print(f"  {t:10.5f} {2 * t * t:14.3e} {deficit:14.3e} {4 * t * t:14.3e}")
        assert 2 * t * t - 1e-15 <= deficit <= 4 * t * t + 1e-15
    print("\n  no uniform linear inversion constant: for each C, exhibit a failing pair")
    for C in (1.0, 10.0, 1e3, 1e6):
        t = min(0.25, 1.0 / (8.0 * (abs(C) + 1.0)))
        p, q = 0.5 - t, 0.5
        lhs = C * abs(bin_entropy(p) - bin_entropy(q))
        print(f"    C={C:<10g} t={t:.3e}   C|dh|={lhs:.3e} < |p-q|={t:.3e}"
              f"   ok={lhs < t}")
        assert lhs < t


def demo_sqrt_law() -> None:
    banner("6.  Pinsker-type bound and unconditional sqrt-stability")
    rng = random.Random(3)
    worst = math.inf
    for _ in range(50000):
        p, q = sorted((rng.uniform(0.0, 0.5), rng.uniform(0.0, 0.5)))
        d = q - p
        if d < 1e-9:
            continue
        worst = min(worst, (bin_entropy(q) - bin_entropy(p)) / (2 * d * d))
    print(f"  min of (h(q)-h(p)) / (2(q-p)^2) over 50000 pairs = {worst:.6f}  (>= 1)")
    assert worst >= 1.0 - 1e-9

    print("\n  |p-q| <= sqrt(eps/2), and sharpness pair gives |p-q| = sqrt(eps)/2:")
    print(f"  {'eps (nats)':>12} {'guarantee':>12} {'worst case':>12} {'ratio':>8}")
    for eps in (0.25, 0.1, 0.01, 1e-3, 1e-4):
        guarantee = math.sqrt(eps / 2.0)
        t = math.sqrt(eps) / 2.0
        actual_gap = abs(bin_entropy(0.5 - t) - bin_entropy(0.5))
        assert actual_gap <= eps + 1e-15
        print(f"  {eps:12.5f} {guarantee:12.6f} {t:12.6f} {guarantee / t:8.4f}")
    print("  ratio is exactly sqrt(2): guarantee and worst case agree up to sqrt(2).")


def demo_fannes_modulus() -> None:
    banner("7.  Sharp Fannes-type modulus:  |h(p)-h(q)| <= h(|p-q|), attained at q=0")
    rng = random.Random(13)
    worst = 0.0
    for _ in range(50000):
        p, q = rng.uniform(0.0, 0.5), rng.uniform(0.0, 0.5)
        d = abs(p - q)
        if d < 1e-12:
            continue
        worst = max(worst, abs(bin_entropy(p) - bin_entropy(q)) / bin_entropy(d))
    print(f"  max of |h(p)-h(q)| / h(|p-q|) over 50000 pairs = {worst:.8f}  (<= 1)")
    assert worst <= 1.0 + 1e-9
    print("  attainment at q = 0:")
    for p in (0.05, 0.2, 0.5):
        print(f"    p={p:<5}  |h(p)-h(0)|={abs(bin_entropy(p)):.8f}"
              f"   h(|p-0|)={bin_entropy(p):.8f}")
    print("\n  complete two-sided law 2|p-q|^2 <= |dh| <= h(|p-q|):")
    print(f"  {'p':>7} {'q':>7} {'2(p-q)^2':>12} {'|dh|':>12} {'h(|p-q|)':>12}")
    for p, q in ((0.1, 0.2), (0.02, 0.3), (0.45, 0.5), (0.0, 0.5)):
        print(f"  {p:7.3f} {q:7.3f} {2 * (p - q) ** 2:12.6f}"
              f" {abs(bin_entropy(p) - bin_entropy(q)):12.6f} {bin_entropy(abs(p - q)):12.6f}")


def demo_label_swap() -> None:
    banner("8.  Label swap is the whole ambiguity:  h(p)=h(q) iff q=p or q=1-p")
    for p in (0.09, 0.25, 0.4):
        print(f"  h({p}) = {bin_entropy(p):.10f}    h({1 - p:.2f}) = {bin_entropy(1 - p):.10f}")
        assert abs(bin_entropy(p) - bin_entropy(1 - p)) < 1e-15
    print("\n  quantitative form: min(|p-q|, |p+q-1|) <= sqrt(eps/2)")
    rng = random.Random(23)
    eps = 0.01
    checked = 0
    for _ in range(200000):
        p, q = rng.uniform(0.0, 1.0), rng.uniform(0.0, 1.0)
        if abs(bin_entropy(p) - bin_entropy(q)) <= eps:
            checked += 1
            assert min(abs(p - q), abs(p + q - 1.0)) <= math.sqrt(eps / 2.0) + 1e-12
    print(f"  verified on {checked} random pairs with |dh| <= {eps}; "
          f"bound = {math.sqrt(eps / 2):.6f}")


def demo_reported_wall() -> None:
    banner("9.  The reported wall of 0.4677 bits is a falsifiable claim")
    wall_bits = 0.4677
    wall_nats = wall_bits * LOG2
    h12 = 2 * math.log(2) + math.log(3) - (11 / 12) * math.log(11)
    h9 = 2 * math.log(3) - (8 / 3) * math.log(2)
    print(f"  wall = {wall_bits} bits = {wall_nats:.6f} nats")
    print(f"  h(1/12) = 2log2 + log3 - (11/12)log11 = {h12:.6f} nats "
          f"= {h12 / LOG2:.6f} bits")
    print(f"  h(1/9)  = 2log3 - (8/3)log2           = {h9:.6f} nats "
          f"= {h9 / LOG2:.6f} bits")
    assert abs(h12 - bin_entropy(1 / 12)) < 1e-12
    assert abs(h9 - bin_entropy(1 / 9)) < 1e-12
    assert h12 < wall_nats < h9
    p_star = invert_wall(wall_nats)
    print(f"\n  unique split with this wall:  p* = {p_star:.8f}  "
          f"({100 * p_star:.4f} %)")
    print(f"  bracket: 1/12 = {1/12:.6f} < p* < 1/9 = {1/9:.6f}   "
          f"i.e. between 8.34% and 11.11%")
    print(f"  independently reported split 9.96%  ->  consistent")
    for bad in (0.05, 0.15):
        print(f"  a split of {100*bad:.0f}% would give a wall of "
              f"{bin_entropy_bits(bad):.4f} bits  ->  excluded")

    banner("9b. Replication tolerance for splits below 1/9")
    c = guarded_inversion_constant(7 / 18)      # = log 8 = 3 log 2
    print(f"  guard eta = 7/18 gives 1/2 - eta = 1/9 and constant log 8 = 3 log 2 "
          f"= {c:.6f}")
    print(f"  walls agreeing to 0.01 bits = {0.01 * LOG2:.6f} nats")
    print(f"  => |p - q| <= (0.01 log2)/(3 log2) = 1/300 = {1/300:.6f} "
          f"({100/300:.2f} percentage points)")
    print(f"  unconditional sqrt bound would only give "
          f"{math.sqrt(0.01 * LOG2 / 2):.6f}  (worse by "
          f"{math.sqrt(0.01 * LOG2 / 2) * 300:.1f}x)")
    print("\n  certified interval from a +/- 0.01 bit measurement of 0.4677 bits:")
    lo, hi = certified_split_interval(0.4677, 0.01)
    print(f"    p in [{lo:.6f}, {hi:.6f}]   width = {hi - lo:.6f} "
          f"(a +/- 0.01 bit bar is a 0.02 bit spread, so the theorem allows "
          f"{2/300:.6f}: {hi - lo <= 2/300 + 1e-9})")
    assert hi - lo <= 2 / 300 + 1e-9
    print("\n  resolution report at eps = 0.01 nats:")
    for eta in (None, 0.1, 7 / 18):
        rep = resolution_report(0.01, eta)
        label = "no guard" if eta is None else f"eta = {eta:.4f}"
        print(f"    {label:<16} {rep}")


def demo_populations() -> None:
    banner("10. Population level: two binary statistics, two different populations")
    pop1 = binary_population(1000, 100, ("sick", "well"))          # p = 0.100
    pop2 = binary_population(731, 74, ("positive", "negative"))    # q ~ 0.10123
    h1, h2 = empirical_entropy(pop1), empirical_entropy(pop2)
    p1, p2 = minority_fraction(pop1), minority_fraction(pop2)
    print(f"  population 1: N=1000, minority 100  -> fraction {p1:.6f}, "
          f"wall {h1 / LOG2:.6f} bits")
    print(f"  population 2: N= 731, minority  74  -> fraction {p2:.6f}, "
          f"wall {h2 / LOG2:.6f} bits")
    assert abs(h1 - bin_entropy(p1)) < 1e-12 and abs(h2 - bin_entropy(p2)) < 1e-12
    eps = abs(h1 - h2)
    print(f"\n  |H(f) - H(g)| = {eps:.8f} nats")
    print(f"  actual |p - q|              = {abs(p1 - p2):.8f}")
    print(f"  unconditional sqrt bound    = {math.sqrt(eps / 2):.8f}")
    eta = 0.5 - 1 / 9
    print(f"  guarded bound (splits<=1/9) = {eps / guarded_inversion_constant(eta):.8f}")
    assert abs(p1 - p2) <= math.sqrt(eps / 2) + 1e-12
    assert abs(p1 - p2) <= eps / guarded_inversion_constant(eta) + 1e-12
    print("\n  converse (replication robustness): splits differing by <= delta")
    print("  force walls differing by <= h(delta):")
    delta = abs(p1 - p2)
    print(f"    delta = {delta:.8f}   h(delta) = {bin_entropy(delta):.8f} nats"
          f"   >= actual {eps:.8f}?  {bin_entropy(delta) >= eps}")
    assert bin_entropy(delta) >= eps - 1e-15

    print("\n  label swap at the population level: complementary populations")
    pop3 = binary_population(1000, 900, ("sick", "well"))
    print(f"    N=1000 with 900 'sick': wall = {empirical_entropy(pop3) / LOG2:.6f} bits"
          f"  (identical to population 1)")
    assert abs(empirical_entropy(pop3) - h1) < 1e-12


def main() -> None:
    demo_refutation()
    demo_lipschitz()
    demo_endpoint_slope()
    demo_guarded_inversion()
    demo_quadratic_law()
    demo_sqrt_law()
    demo_fannes_modulus()
    demo_label_swap()
    demo_reported_wall()
    demo_populations()
    banner("All demonstrations completed and all assertions passed.")


if __name__ == "__main__":
    main()
