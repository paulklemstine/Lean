"""Algorithm 2 -- Punctured Window for Strict Improvement Along the Truncation Tower.

Given the Cauchy data (B, r) of a perturbative family, a phenomenon p at which
the M-th correction a_M(p) does not vanish, and a higher order N > M, compute
delta > 0 such that for every 0 < |eps| < delta the order-N truncation strictly
outpredicts the order-M truncation, both measured against the exact prediction.

Taking the minimum over consecutive steps yields a single window on which the
truncations of orders 0, 1, ..., K are TOTALLY ORDERED by accuracy.
"""

from __future__ import annotations

from typing import Callable, List


def hierarchy_window(
    bound: float,
    ratio: float,
    coeff_m: float,
    m: int,
    n: int,
) -> float:
    """Return delta guaranteeing that order n beats order m at the phenomenon.

    Parameters
    ----------
    bound   : B >= 0 from the uniform Cauchy estimate.
    ratio   : r >= 0 from the uniform Cauchy estimate.
    coeff_m : a_M(p), the first coefficient the coarse theory neglects;
              must be nonzero.
    m, n    : truncation orders with m < n.

    Returns
    -------
    delta = min{ 1, 1/(2(r+1)), c / (2B(r^n + r^(m+1)) + 1) },  c = |a_M(p)|.

    Complexity: O(log n) with fast exponentiation.

    Derivation.  The first two entries place the coupling in the half-disc
    r|eps| <= 1/2 and ensure |eps| < 1, so |eps|^(n+1) <= |eps|^(m+2).  The
    two-sided tail estimates then give
        |R_n| <= 2 B r^n |eps|^(m+2),
        |R_m| >= c |eps|^(m+1) - 2 B r^(m+1) |eps|^(m+2),
    and the third entry is exactly the inequality
        |eps| * 2B (r^n + r^(m+1)) < c
    that makes the first quantity smaller than the second.  Read as a ratio,
    delta is (signal: the first term the coarse theory neglects) divided by
    (noise: the geometric mass of what both theories neglect).
    """
    if not m < n:
        raise ValueError("require m < n")
    c = abs(coeff_m)
    if c == 0.0:
        raise ValueError("the m-th correction vanishes: no improvement guaranteed")
    noise = 2.0 * bound * (ratio ** n + ratio ** (m + 1)) + 1.0
    return min(1.0, 1.0 / (2.0 * (ratio + 1.0)), c / noise)


def chain_window(
    bound: float,
    ratio: float,
    coeff: Callable[[int], float],
    k: int,
) -> float:
    """A single window on which orders 0..k form a strict chain.

    Requires a_M(p) != 0 for every M < k.  Complexity: O(k log k).
    """
    windows: List[float] = [
        hierarchy_window(bound, ratio, coeff(m), m, m + 1) for m in range(k)
    ]
    return min(windows) if windows else 1.0


def optimal_order_asymptotic(ratio: float, eps: float) -> int:
    """Conjectural optimal truncation order for a factorially divergent family.

    For coefficients bounded only by |a_n| <= B n! r^n there is no radius of
    convergence and the chain must terminate.  The heuristic optimum sits where
    successive terms stop shrinking, at N* ~ 1/(r|eps|), with residual error of
    order exp(-1/(r|eps|)).  Included here as a computational conjecture, not a
    proved bound.
    """
    if ratio <= 0.0 or eps == 0.0:
        raise ValueError("require ratio > 0 and eps != 0")
    return max(1, int(round(1.0 / (ratio * abs(eps)))))


if __name__ == "__main__":
    B, r = 1.0, 2.0
    coeff = lambda n: (-2.0) ** n          # noqa: E731  (a_n = (-2)^n)
    for m in range(4):
        d = hierarchy_window(B, r, coeff(m), m, m + 1)
        print(f"order {m} -> {m+1}: window |eps| < {d:.10f}")
    print(f"common chain window for orders 0..4: {chain_window(B, r, coeff, 4):.10f}")
    for e in (0.5, 0.1, 0.01):
        print(f"asymptotic regime, r=1, eps={e}: optimal order ~ "
              f"{optimal_order_asymptotic(1.0, e)}")


"""Algorithm 1 -- Certified Coupling Window for the Meta-Theorem.

Given the Cauchy data (B, r) of a perturbative family and an accuracy
threshold eta > 0, compute a coupling radius delta > 0 such that for every
|eps| < delta, the approximately correct theory T_eps outpredicts EVERY rival
theory C on the entire set of phenomena where C's error is at least eta.

The window depends only on (B, r, eta): it is fixed before any rival is named.
"""

from __future__ import annotations

from typing import Dict, List, Tuple


def meta_window(bound: float, ratio: float, eta: float) -> float:
    """Return delta with the meta-theorem property.

    Parameters
    ----------
    bound : B >= 0 with |a_n(p)| <= B r^n for all n and all phenomena p.
    ratio : r >= 0, the inverse radius of convergence.
    eta   : the accuracy threshold, eta > 0.

    Returns
    -------
    delta > 0 such that |eps| < delta implies |W(eps, p)| < eta uniformly in p,
    hence T_eps beats every rival whose error at p is at least eta.

    Complexity: O(1) arithmetic operations.

    Derivation.  The first entry forces r|eps| <= 1/2, hence 1 - r|eps| >= 1/2,
    so the Cauchy estimate |W| <= B|eps|/(1 - r|eps|) yields |W| <= 2B|eps|.
    The second entry forces (B+1)|eps| < eta/2, hence 2B|eps| < eta.  The
    additive +1 regularisers keep both expressions positive when B = 0 or
    r = 0.
    """
    if bound < 0.0 or ratio < 0.0:
        raise ValueError("bound and ratio must be nonnegative")
    if eta <= 0.0:
        raise ValueError("threshold eta must be positive")
    return min(1.0 / (2.0 * (ratio + 1.0)), eta / (2.0 * (bound + 1.0)))


def certified_superiority_region(
    rival: Dict[str, float],
    truth: Dict[str, float],
    eta: float,
) -> List[str]:
    """Phenomena on which victory is certified, without evaluating the theory.

    By the meta-theorem it suffices to locate the rival's bad set
    {p : |C(p) - t(p)| >= eta}; the approximate theory is guaranteed to win
    there for every coupling inside the window.

    Complexity: O(|Phi|) evaluations.
    """
    return [p for p in rival if abs(rival[p] - truth[p]) >= eta]


def audit_window(
    bound: float,
    ratio: float,
    eta: float,
    wrongness: "Tuple[float, ...] | None" = None,
) -> Tuple[float, str]:
    """Compute the window and report how conservative it is.

    If actual wrongness values inside the window are supplied, the ratio of
    the largest observed |W| to eta measures the slack in the certificate.
    """
    delta = meta_window(bound, ratio, eta)
    if not wrongness:
        return delta, "no observations supplied"
    worst = max(abs(w) for w in wrongness)
    return delta, f"worst observed |W| = {worst:.6g}, i.e. {worst / eta:.1%} of eta"


if __name__ == "__main__":
    B, r, eta = 2.0, 3.0, 0.05
    delta = meta_window(B, r, eta)
    print(f"B = {B}, r = {r}, eta = {eta}  ->  certified window |eps| < {delta:.10f}")

    truth = {"perihelion": 43.0, "redshift": 2.12, "lensing": 1.75, "tide": 0.61}
    rival = {"perihelion": 0.0, "redshift": 2.12, "lensing": 0.87, "tide": 0.60}
    region = certified_superiority_region(rival, truth, eta)
    print("certified superiority region:", region)
    print("(the rival is exact on 'redshift', so no claim is made there)")


"""Algorithm 3 -- Construction and Cycle Detection of the Empirical-Adequacy Tournament.

Predictive superiority is pointwise: theory X beats theory Y at phenomenon p if
|X(p) - t(p)| < |Y(p) - t(p)|.  Aggregating by majority over phenomena produces
a TOURNAMENT (a directed graph on theory-space), and that tournament may contain
cycles -- the Condorcet obstruction.  Consequently no scalar "closeness to
truth" can order theories consistently.

This module builds the tournament from error profiles and searches it for
cycles, certifying non-transitivity constructively.
"""

from __future__ import annotations

from itertools import permutations
from typing import Dict, List, Sequence, Set, Tuple

Profile = Sequence[float]


def beats_at(x: float, y: float, truth: float) -> bool:
    """Does prediction x land strictly closer to the truth than y?"""
    return abs(x - truth) < abs(y - truth)


def majority_beats(x: Profile, y: Profile, truth: Profile) -> bool:
    """Does x beat y on a strict majority of the phenomena?"""
    if not (len(x) == len(y) == len(truth)):
        raise ValueError("profiles and truth must have equal length")
    wins = sum(1 for i in range(len(truth)) if beats_at(x[i], y[i], truth[i]))
    return 2 * wins > len(truth)


def build_tournament(
    theories: Dict[str, Profile], truth: Profile
) -> Dict[str, Set[str]]:
    """Adjacency map: name -> set of theories it majority-beats.

    Complexity: O(|theories|^2 * |Phi|).
    """
    return {
        a: {b for b in theories if b != a and majority_beats(theories[a], theories[b], truth)}
        for a in theories
    }


def find_cycle(graph: Dict[str, Set[str]]) -> List[str]:
    """Return a directed cycle as a list of vertices, or [] if acyclic.

    Iterative depth-first search with a colouring: white (unvisited), grey (on
    the current stack), black (finished).  A grey back-edge closes a cycle.

    Complexity: O(V + E).
    """
    colour: Dict[str, int] = {v: 0 for v in graph}
    parent: Dict[str, str] = {}

    for root in graph:
        if colour[root] != 0:
            continue
        stack: List[Tuple[str, bool]] = [(root, False)]
        while stack:
            v, finishing = stack.pop()
            if finishing:
                colour[v] = 2
                continue
            if colour[v] != 0:
                continue
            colour[v] = 1
            stack.append((v, True))
            for w in sorted(graph[v]):
                if colour[w] == 0:
                    parent[w] = v
                    stack.append((w, False))
                elif colour[w] == 1:
                    cycle = [v]
                    while cycle[-1] != w:
                        cycle.append(parent[cycle[-1]])
                    cycle.reverse()
                    return cycle
    return []


def transitivity_counterexample(
    theories: Dict[str, Profile], truth: Profile
) -> Tuple[str, str, str] | None:
    """Find (x, y, z) with x > y, y > z, but not x > z, if one exists.

    Complexity: O(|theories|^3 * |Phi|).
    """
    for x, y, z in permutations(theories, 3):
        if (
            majority_beats(theories[x], theories[y], truth)
            and majority_beats(theories[y], theories[z], truth)
            and not majority_beats(theories[x], theories[z], truth)
        ):
            return x, y, z
    return None


if __name__ == "__main__":
    truth: Profile = (0.0, 0.0, 0.0)
    theories: Dict[str, Profile] = {
        "A": (1.0, 2.0, 3.0),
        "B": (2.0, 3.0, 1.0),
        "C": (3.0, 1.0, 2.0),
    }
    graph = build_tournament(theories, truth)
    for name in sorted(graph):
        print(f"{name} majority-beats {sorted(graph[name])}")
    print("cycle found:", find_cycle(graph))
    print("transitivity counterexample:", transitivity_counterexample(theories, truth))


"""Assemble PACKAGE.json from the individual deliverables in the project."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Physics/WrongTheories/PerturbativeCore.lean",
    "Catalog/Physics/WrongTheories/MetaTheorem.lean",
    "Catalog/Physics/WrongTheories/TruncationHierarchy.lean",
    "Catalog/Physics/WrongTheories/Boundaries.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== {f} =====\n\n{read(ROOT / f)}" for f in LEAN_FILES
)

FUTURE_DIRECTIONS = """# Future Directions

Derived from the analysis and adversarial review of the results on perturbation
theory in theory-space: the perturbative core, the meta-theorem, the truncation
hierarchy, and the boundary counterexamples.

## What survived, what failed

**Survived (fully established).**  Convergence of the wrongness series with a
sharp Cauchy bound; the meta-theorem that an approximately correct theory
outpredicts every imperfect rival on the rival's bad set inside a coupling
window; the strict ordering of the tower of truncations; the epistemic
half-space theorem; the Condorcet cycle disproving transitivity of majority
empirical adequacy; genericity of nowhere-exact theories; the Wilson
epsilon-expansion as a worked instance.

**Failed (proved false).**  Two natural strengthenings were *disproved* rather
than merely left open: "higher order is always better" (false at eps = 1 for
eps - 3 eps^2) and "the meta-theorem holds at every coupling" (false at
eps = 1/2).  Both failures are of the type *"true only inside a window"*, and
both windows are now explicit and quantitative.

**Needs a different definition.**  Attempts to compare theories by a single
global figure of merit run into the Condorcet obstruction: any aggregation of
pointwise errors into a total order over theories must break either
independence-of-phenomena or transitivity.  Comparative adequacy should be
treated as a *directed graph on theory space*, not a preorder.

## Conjecture 1 (Asymptotic-series regime: optimal truncation)

For a family with only an *asymptotic*, factorially divergent bound
|a_n| <= B * n! * r^n (no convergent radius), there is a truncation order
N*(eps) ~ 1/(r|eps|) such that the order-N*(eps) truncation beats every
truncation of order N != N*(eps), and the resulting error is exponentially
small, O(exp(-1/(r|eps|))).  **The key insight is** that the hierarchy
theorem's inequality |tail_N| >= |a_N||eps|^{N+1} - (rest) reverses direction
once the coefficient growth beats the geometric decay, so the strict chain of
truncations must terminate at a computable order rather than continue forever.
**Why now?**  All the analytic ingredients -- the two-sided tail estimates --
are already established and are stated for arbitrary coefficient bounds; only
the geometric majorant needs to be replaced by a factorial one.

## Conjecture 2 (Measure-theoretic unreasonable effectiveness)

Equip the space of "worlds" (truth functions on a finite phenomenon set of size
k) with Lebesgue measure on a bounded box.  For any two distinct theories the
set of worlds in which one beats the other on a majority of phenomena has
strictly positive measure, and for k odd the measures of the two majority
regions sum to the full measure.  **The key insight is** that the epistemic
half-space theorem already exhibits each pointwise favouring set as an open
half-line, so the majority region is a finite union of intersections of
half-spaces -- a polyhedral set whose measure is in principle computable.

## Further directions

**Directed-graph semantics for adequacy.**  Given the Condorcet obstruction,
comparative adequacy should be studied as a tournament on theory space.  Which
tournaments arise from error profiles?  What is the length distribution of
cycles?  Can a Copeland- or Kemeny-style score be justified as a canonical
scalarisation?

**Windows as a research heuristic.**  The explicit windows suggest a diagnostic
for ongoing calculations: given estimated Cauchy data, compute the coupling
range in which the next order is guaranteed to improve matters, and compare it
with the physical coupling of interest.
"""

package = {
    "title": "The Unreasonable Effectiveness of Wrong Theories: "
             "Perturbation Theory on Theory-Space",
    "domain": "Physics",
    "description": (
        "A quantitative framework in which a physical theory's deviation from "
        "the truth is a convergent power series in a coupling, yielding a "
        "meta-theorem that an approximately correct theory strictly "
        "outpredicts every imperfect rival on the rival's bad set inside an "
        "explicitly computable coupling window. The tower of finite-order "
        "truncations is shown to be strictly ordered by accuracy, and both "
        "guarantees are proved sharp by explicit counterexamples outside "
        "their windows."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-16",
    "key_results": [
        "Convergent Wrongness Theorem: under a uniform Cauchy bound "
        "|a_n(p)| <= B r^n on the correction coefficients, the wrongness "
        "series satisfies |W(eps,p)| <= B|eps|/(1 - r|eps|) for every "
        "phenomenon simultaneously, so accuracy is bought across the entire "
        "domain of application at once.",

        "Meta-theorem on the unreasonable effectiveness of wrong theories: "
        "for every accuracy threshold eta > 0 there is a coupling window, "
        "delta = min{1/(2(r+1)), eta/(2(B+1))}, chosen before any competitor "
        "is named, on which the approximately correct theory strictly "
        "outpredicts every rival theory on the whole class of phenomena where "
        "that rival's error is at least eta.",

        "Wrongness Hierarchy Theorem: whenever the M-th correction is nonzero "
        "at a phenomenon, every truncation of order N > M strictly beats the "
        "M-th truncation on a punctured coupling window, and orders 0 through "
        "K are totally ordered by predictive accuracy on one common window -- "
        "so the wrongness of an approximately correct theory approaches the "
        "truth monotonically in order, not merely in the limit.",

        "Sharpness of both guarantees: at coupling 1/2 the approximately "
        "correct theory eps is beaten by the crude and itself-wrong constant "
        "rival 1/4; and for the family eps - 3 eps^2 at coupling 1 the "
        "first-order truncation errs by 3 while the zeroth-order truncation "
        "errs by only 2, so 'higher order is always better' is false.",

        "Epistemic Half-Space Theorem and the Condorcet obstruction: for any "
        "two distinct predictions the set of possible worlds in which one "
        "beats the other is a nonempty, open, unbounded half-line, so "
        "predictive inferiority is never intrinsic; and three theories with "
        "error profiles (1,2,3), (2,3,1), (3,1,2) form a majority cycle, so "
        "empirical adequacy admits no consistent global ranking.",

        "Universal falsity is compatible with convergence: the sequence of "
        "theories truth + 1/(k+1) is wrong at every phenomenon for every k, "
        "yet its errors converge uniformly to zero, invalidating the "
        "inference from a history of false theories to the absence of "
        "convergence on the truth.",
    ],
    "keywords": [
        "perturbation theory",
        "theory-space",
        "approximate correctness",
        "truncation hierarchy",
        "Cauchy bound",
        "epsilon expansion",
        "Condorcet cycle",
        "philosophy of science",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "Complete Numerical Tour of Perturbative Theory-Space",
            "description": (
                "An eight-part self-contained numerical walkthrough of the "
                "whole framework. It tabulates the wrongness series against "
                "its certified Cauchy bound B|eps|/(1-r|eps|) as the coupling "
                "shrinks; computes the meta-theorem's window from (B, r, eta) "
                "alone and then pits the approximate theory against four "
                "structurally different rivals, showing that every rival past "
                "the threshold loses while a rival inside the threshold band "
                "is deliberately not covered; exhibits the tower of "
                "truncations of orders 0 through 5 with strictly decreasing "
                "errors on a common window; reproduces both sharpness "
                "counterexamples numerically (the crude constant 1/4 beating "
                "the theory eps at eps = 1/2, and the first-order truncation "
                "of eps - 3 eps^2 erring by 3 against the zeroth order's 2 at "
                "eps = 1); verifies the epistemic half-space criterion "
                "(b-a)(2t-a-b) < 0 against direct computation across nine "
                "worlds spanning twelve orders of magnitude; builds the "
                "Condorcet cycle and confirms non-transitivity; runs the "
                "uniformly-false-yet-convergent sequence truth + 1/(k+1); and "
                "closes with Wilson's two-loop anomalous dimension "
                "eta(eps) = eps^2/54, reporting the certified window in terms "
                "of spatial dimension. Standard library only."
            ),
            "code": read(ROOT / "demo.py"),
        },
        {
            "name": "Certified Versus Actual Superiority Regions Over a "
                    "Catalogue of Phenomena",
            "description": (
                "Quantifies how conservative the meta-theorem's certificate "
                "is. Five named phenomena carry a truth function; a "
                "perturbative family with coefficients saturating the uniform "
                "Cauchy bound (B = 1, r = 2) is compared against three rivals "
                "of contrasting character: a crude offset wrong everywhere by "
                "the same amount, a partially tuned theory exact on two "
                "phenomena and badly wrong on three, and a noisy theory with "
                "small alternating errors. For each rival the script computes "
                "the certified region -- the rival's bad set, obtained "
                "without ever evaluating the approximate theory -- and the "
                "actual superiority region, and verifies the containment the "
                "meta-theorem guarantees. On the noisy rival the actual "
                "region is strictly larger, exhibiting a 'bonus victory' the "
                "certificate declines to claim: the guarantee is one-sided "
                "and never over-claims. Standard library only, fully "
                "deterministic."
            ),
            "code": read(A / "demo_superiority.py"),
        },
    ],
    "algorithms": [
        {
            "name": "Certified Coupling Window for the Meta-Theorem",
            "description": (
                "Given the Cauchy data (B, r) of a perturbative family and an "
                "accuracy threshold eta > 0, returns a coupling radius delta "
                "such that for every |eps| < delta the approximately correct "
                "theory outpredicts every rival theory on the entire set of "
                "phenomena where the rival's error is at least eta. The "
                "derivation is two-step: the entry 1/(2(r+1)) forces "
                "r|eps| <= 1/2, hence 1 - r|eps| >= 1/2, so the Cauchy "
                "estimate |W| <= B|eps|/(1 - r|eps|) collapses to "
                "|W| <= 2B|eps|; the entry eta/(2(B+1)) then forces "
                "2B|eps| < eta. The additive regularisers keep both "
                "expressions positive in the degenerate cases B = 0 and "
                "r = 0. Complexity is O(1) arithmetic operations, and the "
                "window depends on neither the rival nor the phenomenon -- it "
                "is fixed before either is named. A companion routine "
                "computes the certified superiority region in O(|Phi|) "
                "evaluations of the rival alone, without ever evaluating the "
                "approximate theory."
            ),
            "pseudocode": (
                "ALGORITHM MetaWindow(B, r, eta)\n"
                "  INPUT   B >= 0, r >= 0   with |a_n(p)| <= B r^n for all n, p\n"
                "          eta > 0          accuracy threshold\n"
                "  OUTPUT  delta > 0        certified coupling radius\n"
                "\n"
                "  1. REQUIRE B >= 0 and r >= 0 and eta > 0\n"
                "  2. d1 <- 1 / (2 * (r + 1))          // forces r|eps| <= 1/2\n"
                "  3. d2 <- eta / (2 * (B + 1))        // forces 2B|eps| < eta\n"
                "  4. RETURN min(d1, d2)\n"
                "\n"
                "  GUARANTEE  for all |eps| < delta and all phenomena p:\n"
                "               |W(eps, p)| < eta\n"
                "             hence for every theory C and every p with\n"
                "               |C(p) - t(p)| >= eta:\n"
                "               |T_eps(p) - t(p)| < |C(p) - t(p)|\n"
                "\n"
                "ALGORITHM CertifiedSuperiorityRegion(C, t, eta)\n"
                "  INPUT   C : Phi -> R     rival predictions\n"
                "          t : Phi -> R     truth values\n"
                "          eta > 0          the same threshold\n"
                "  OUTPUT  S subset of Phi  phenomena where victory is certified\n"
                "\n"
                "  1. S <- empty set\n"
                "  2. FOR each phenomenon p in Phi DO\n"
                "  3.     IF |C(p) - t(p)| >= eta THEN S <- S union {p}\n"
                "  4. RETURN S\n"
                "\n"
                "  NOTE  the approximate theory is never evaluated"
            ),
            "code": read(A / "algo_meta_window.py"),
        },
        {
            "name": "Punctured Window for Strict Improvement Along the "
                    "Truncation Tower",
            "description": (
                "Given Cauchy data (B, r), a phenomenon at which the M-th "
                "correction a_M does not vanish, and a higher order N > M, "
                "returns a radius delta such that for every coupling with "
                "0 < |eps| < delta the order-N truncation strictly "
                "outpredicts the order-M truncation, both measured against "
                "the exact prediction. The mathematical foundation is the "
                "pair of two-sided tail estimates valid in the half-disc "
                "r|eps| <= 1/2: the finer truncation obeys "
                "|R_N| <= 2 B r^N |eps|^(N+1), while the coarser obeys "
                "|R_M| >= |a_M| |eps|^(M+1) - 2 B r^(M+1) |eps|^(M+2). Since "
                "N + 1 >= M + 2 and |eps| < 1, comparing them reduces to the "
                "single linear inequality |eps| * 2B(r^N + r^(M+1)) < |a_M|, "
                "which is exactly the third entry of the returned minimum. "
                "Read as a ratio, delta is signal over noise: the first term "
                "the coarse theory neglects, divided by the geometric mass of "
                "everything both theories neglect. Complexity is O(log N) "
                "with fast exponentiation; taking the minimum over the K "
                "consecutive steps yields, in O(K log K), a single window on "
                "which orders 0 through K are totally ordered by accuracy. A "
                "companion routine implements the conjectural optimal "
                "truncation order N* ~ 1/(r|eps|) for the factorially "
                "divergent regime, where the chain must terminate."
            ),
            "pseudocode": (
                "ALGORITHM HierarchyWindow(B, r, a_M, M, N)\n"
                "  INPUT   B >= 0, r >= 0   Cauchy data\n"
                "          a_M != 0         the first coefficient order M discards\n"
                "          M < N            truncation orders\n"
                "  OUTPUT  delta > 0        punctured window radius\n"
                "\n"
                "  1. REQUIRE M < N and a_M != 0\n"
                "  2. c     <- |a_M|                            // signal\n"
                "  3. noise <- 2*B*(r^N + r^(M+1)) + 1          // regularised noise\n"
                "  4. d1 <- 1                                   // ensures |eps| < 1\n"
                "  5. d2 <- 1 / (2 * (r + 1))                   // ensures r|eps| <= 1/2\n"
                "  6. d3 <- c / noise                           // decisive inequality\n"
                "  7. RETURN min(d1, d2, d3)\n"
                "\n"
                "  GUARANTEE  for all eps with 0 < |eps| < delta:\n"
                "               |R_N(eps)| < |R_M(eps)|\n"
                "\n"
                "ALGORITHM ChainWindow(B, r, a, K)\n"
                "  INPUT   Cauchy data and coefficients a_0, ..., a_{K-1}, all nonzero\n"
                "  OUTPUT  a single delta on which orders 0..K form a strict chain\n"
                "\n"
                "  1. delta <- +infinity\n"
                "  2. FOR M = 0 TO K - 1 DO\n"
                "  3.     delta <- min(delta, HierarchyWindow(B, r, a_M, M, M+1))\n"
                "  4. RETURN delta\n"
                "\n"
                "  GUARANTEE  for 0 < |eps| < delta and all M < N <= K:\n"
                "               |R_N(eps)| < |R_M(eps)|      (by transitivity)"
            ),
            "code": read(A / "algo_hierarchy_window.py"),
        },
        {
            "name": "Construction and Cycle Detection of the "
                    "Empirical-Adequacy Tournament",
            "description": (
                "Predictive superiority is pointwise, so comparing theories "
                "globally requires aggregation -- and aggregation by majority "
                "produces a tournament, a directed graph on theory-space, "
                "which may contain cycles. This algorithm builds that "
                "tournament from error profiles and searches it for a cycle, "
                "certifying non-transitivity constructively. Construction "
                "compares every ordered pair of theories across every "
                "phenomenon, costing O(|theories|^2 * |Phi|). Cycle detection "
                "is an iterative depth-first search with three-colouring: a "
                "vertex is white when unvisited, grey while on the current "
                "stack, black when finished, and a grey back-edge closes a "
                "cycle which is then reconstructed by walking parent "
                "pointers; this costs O(V + E). A third routine performs an "
                "exhaustive O(|theories|^3 * |Phi|) search for an explicit "
                "transitivity counterexample -- a triple with X beating Y and "
                "Y beating Z but X not beating Z. On the canonical profiles "
                "(1,2,3), (2,3,1), (3,1,2) against a truth of zero the "
                "tournament is the three-cycle, and the counterexample search "
                "returns that triple, establishing that majority empirical "
                "adequacy is not even a preorder."
            ),
            "pseudocode": (
                "ALGORITHM BuildTournament(theories, truth)\n"
                "  INPUT   theories : name -> vector of predictions over Phi\n"
                "          truth    : vector of true values over Phi\n"
                "  OUTPUT  graph    : name -> set of names it majority-beats\n"
                "\n"
                "  1. FOR each ordered pair (X, Y) with X != Y DO\n"
                "  2.     wins <- #{ i : |X_i - truth_i| < |Y_i - truth_i| }\n"
                "  3.     IF 2 * wins > |Phi| THEN add edge X -> Y\n"
                "  4. RETURN graph\n"
                "\n"
                "ALGORITHM FindCycle(graph)\n"
                "  INPUT   a directed graph\n"
                "  OUTPUT  a directed cycle as a vertex list, or empty\n"
                "\n"
                "  1. colour[v] <- WHITE for every vertex v\n"
                "  2. FOR each vertex root with colour WHITE DO\n"
                "  3.     push (root, not-finishing) onto stack\n"
                "  4.     WHILE stack nonempty DO\n"
                "  5.         pop (v, finishing)\n"
                "  6.         IF finishing THEN colour[v] <- BLACK; CONTINUE\n"
                "  7.         IF colour[v] != WHITE THEN CONTINUE\n"
                "  8.         colour[v] <- GREY;  push (v, finishing)\n"
                "  9.         FOR each successor w of v DO\n"
                " 10.             IF colour[w] = WHITE THEN\n"
                " 11.                 parent[w] <- v;  push (w, not-finishing)\n"
                " 12.             ELSE IF colour[w] = GREY THEN\n"
                " 13.                 walk parent pointers from v back to w\n"
                " 14.                 RETURN the reversed path\n"
                " 15. RETURN empty\n"
                "\n"
                "ALGORITHM TransitivityCounterexample(theories, truth)\n"
                "  1. FOR each ordered triple (X, Y, Z) of distinct theories DO\n"
                "  2.     IF X majority-beats Y and Y majority-beats Z\n"
                "  3.        and NOT (X majority-beats Z) THEN RETURN (X, Y, Z)\n"
                "  4. RETURN none"
            ),
            "code": read(A / "algo_tournament.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Truncation Tower and Its Window of Validity",
            "description": (
                "A two-panel figure making the wrongness hierarchy and its "
                "sharpness visible side by side. The left panel plots, on "
                "log-log axes, the truncation error |R_N(eps)| against the "
                "coupling for orders N = 0 through 5 of the family with "
                "coefficients a_n = (-r)^n; the curves are strictly nested, "
                "each higher order lying uniformly below its predecessor, and "
                "a shaded band with a crimson boundary marks the certified "
                "chain window computed from the Cauchy data. The right panel "
                "plots the order-0 and order-1 truncation errors of the "
                "explicit counterexample family W(eps) = eps - 3 eps^2 on "
                "linear axes; the two curves cross at eps = 1/6, and beyond "
                "the crossing the higher truncation is strictly worse, with "
                "the values 2 and 3 at eps = 1 marked directly on the plot. "
                "Together the panels say: strict monotone improvement inside "
                "the window, genuine failure outside it. Requires matplotlib "
                "and numpy."
            ),
            "code": read(A / "viz_tower.py"),
        },
        {
            "name": "The Epistemic Landscape: Half-Spaces and the Condorcet "
                    "Cycle",
            "description": (
                "A two-panel figure on the structure of comparative adequacy. "
                "The left panel visualises the epistemic half-space theorem: "
                "two theories predict 2 and 5 at a phenomenon, and as the "
                "unknown truth ranges over all possible worlds their error "
                "curves |t-2| and |t-5| are drawn, with the region favouring "
                "the first shaded. It is exactly the open, unbounded half-line "
                "t < 3.5, annotated at the world where the first theory is "
                "exactly right and at its unbounded end -- so no prediction is "
                "unconditionally inferior. The right panel is a grouped bar "
                "chart of the Condorcet profiles (1,2,3), (2,3,1), (3,1,2) "
                "over three phenomena with truth zero, annotated with the full "
                "cycle of majority verdicts and the observation that A beats C "
                "on one phenomenon only, so majority empirical adequacy is not "
                "transitive. Requires matplotlib and numpy."
            ),
            "code": read(A / "viz_worlds.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Wrongness Laboratory: Dial the Coupling, "
                     "Break the Theorem",
            "description": (
                "A two-tab instrument for the two main theorems, built around "
                "a perturbative family whose coefficients saturate the "
                "uniform Cauchy bound, a_n = B(-r)^n, so the exact deviation "
                "is W(eps) = B eps/(1 + r eps) around a truth of zero. Four "
                "sliders control the bound B, the ratio r, the coupling eps "
                "and the threshold eta. The first tab draws the number line "
                "with the truth at the origin, the approximate theory and a "
                "user-positioned rival marked on it, and the threshold band "
                "shaded; a live verdict panel distinguishes three regimes -- "
                "a guaranteed win inside the window against a rival past the "
                "threshold, an explicit no-claim when the rival is inside the "
                "threshold band, and the loss of all guarantees once eps "
                "exceeds the computed window delta = min{1/(2(r+1)), "
                "eta/(2(B+1))}. Users can reproduce the sharpness "
                "counterexample by hand: push the coupling up and watch a "
                "crude constant rival overtake the approximately correct "
                "theory. The second tab renders the tower of truncations as a "
                "log-scale bar chart with a synchronised numerical table; "
                "bars turn red and are flagged the moment a higher order is "
                "worse than the one below it, so the strict chain and its "
                "breakdown outside the certified window are both directly "
                "observable. Self-contained HTML, CSS and canvas JavaScript "
                "with no dependencies."
            ),
            "html": read(A / "widget_lab.html"),
        },
        {
            "title": "The Epistemic Arena: Drag the Truth, Build a Cycle",
            "description": (
                "Two linked experiments on the structure of comparative "
                "adequacy. In the first, four theories -- labelled Aristotle, "
                "Newton, Einstein and Bohr -- make fixed numerical "
                "predictions on a strip, and the user clicks or drags to move "
                "the unknown truth along it. The strip is partitioned into "
                "coloured ownership bands, each an interval between "
                "consecutive midpoints, and live error chips crown the "
                "current winner. The outermost bands are marked unbounded, "
                "making the epistemic half-space theorem tangible: every "
                "theory that says anything owns an open, unbounded family of "
                "worlds, so predictive inferiority is never intrinsic to a "
                "theory but always a joint fact about theory and world. In "
                "the second experiment three theories carry editable error "
                "profiles over three phenomena, preloaded with the canonical "
                "rotation (1,2,3), (2,3,1), (3,1,2); a tournament graph is "
                "redrawn on every keystroke, with arrows meaning 'majority "
                "beats' and a live message that detects the three-cycle and "
                "explains why its presence rules out any consistent ranking "
                "of theories by closeness to the truth. Users can try to "
                "break the cycle, and discover how easily it comes back. "
                "Self-contained HTML, CSS and canvas JavaScript with no "
                "dependencies."
            ),
            "html": read(A / "widget_arena.html"),
        },
    ],
    "interactive_layout": read(A / "interactive_layout.md"),
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {
        "demo": read(ROOT / "demo.py"),
    },
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False), encoding="utf-8")
print(f"written {out}  ({out.stat().st_size/1024:.1f} KiB)")


"""Superiority regions: certified versus actual, over a catalogue of phenomena.

The meta-theorem certifies victory on the rival's *bad set* -- the phenomena
where the rival's error reaches a threshold eta.  This is a purely one-sided
certificate: it is computed without ever evaluating the approximate theory.
The *actual* superiority region can of course be larger, since the approximate
theory may also beat the rival where the rival is only mildly inaccurate.

This script quantifies the gap.  Five phenomena, a perturbative family whose
corrections saturate the Cauchy bound, and three rivals of very different
character:

  * a crude constant-offset theory (wrong everywhere by the same amount),
  * a partially-tuned theory (exact on two phenomena, badly wrong on one),
  * a noisy theory (small errors of alternating sign).

For each rival we report the certified region, the actual region, and the
containment that the meta-theorem guarantees.

Standard library only.
"""

from __future__ import annotations

from typing import Dict, List, Tuple

PHENOMENA: Tuple[str, ...] = (
    "perihelion shift",
    "gravitational redshift",
    "light deflection",
    "tidal amplitude",
    "orbital decay",
)

TRUTH: Dict[str, float] = {
    "perihelion shift": 43.00,
    "gravitational redshift": 2.12,
    "light deflection": 1.75,
    "tidal amplitude": 0.61,
    "orbital decay": 7.35,
}


def coefficients(n: int, p: str) -> float:
    """Corrections saturating |a_n(p)| <= B r^n with alternating signs.

    The phenomenon enters only through a bounded modulation, so the uniform
    Cauchy estimate holds with the same (B, r) at every phenomenon.
    """
    bound, ratio = 1.0, 2.0
    modulation = 0.40 + 0.15 * PHENOMENA.index(p)   # in (0, 1], so |a_n| <= B r^n
    return bound * modulation * ((-ratio) ** n)


def wrongness(eps: float, p: str, n_max: int = 200) -> float:
    """W(eps, p) = sum_n a_n(p) eps^(n+1); converges for |eps| < 1/2."""
    total = 0.0
    for n in range(n_max):
        total += coefficients(n, p) * eps ** (n + 1)
    return total


def meta_window(bound: float, ratio: float, eta: float) -> float:
    """delta = min{1/(2(r+1)), eta/(2(B+1))}."""
    return min(1.0 / (2.0 * (ratio + 1.0)), eta / (2.0 * (bound + 1.0)))


def certified_region(rival: Dict[str, float], eta: float) -> List[str]:
    """The rival's bad set -- victory here is guaranteed by the meta-theorem."""
    return [p for p in PHENOMENA if abs(rival[p] - TRUTH[p]) >= eta]


def actual_region(rival: Dict[str, float], eps: float) -> List[str]:
    """Where the approximate theory really is closer to the truth."""
    return [
        p
        for p in PHENOMENA
        if abs(wrongness(eps, p)) < abs(rival[p] - TRUTH[p])
    ]


def main() -> None:
    bound, ratio, eta = 1.0, 2.0, 0.05
    delta = meta_window(bound, ratio, eta)
    eps = 0.5 * delta

    print("Perturbative family: B = 1, r = 2 (uniform Cauchy estimate).")
    print(f"Threshold eta = {eta}.  Certified window |eps| < {delta:.8f}.")
    print(f"Working at eps = {eps:.8f}, comfortably inside.\n")

    print("Wrongness of the approximate theory at each phenomenon:")
    for p in PHENOMENA:
        print(f"    {p:<26} |W| = {abs(wrongness(eps, p)):.8f}")
    print()

    rivals: Dict[str, Dict[str, float]] = {
        "crude offset": {p: TRUTH[p] + 0.40 for p in PHENOMENA},
        "partially tuned": {
            **{p: TRUTH[p] for p in PHENOMENA[:2]},
            **{p: TRUTH[p] + 3.0 for p in PHENOMENA[2:]},
        },
        "noisy": {
            p: TRUTH[p] + (0.004 if i % 2 else -0.09)
            for i, p in enumerate(PHENOMENA)
        },
    }

    for name, rival in rivals.items():
        cert = certified_region(rival, eta)
        act = actual_region(rival, eps)
        contained = set(cert) <= set(act)
        print(f"--- rival: {name} " + "-" * (48 - len(name)))
        print(f"    rival errors: "
              f"{ {p: round(abs(rival[p] - TRUTH[p]), 4) for p in PHENOMENA} }")
        print(f"    certified region ({len(cert)}): {cert}")
        print(f"    actual region    ({len(act)}): {act}")
        print(f"    certified subset of actual? {contained}   "
              f"(the meta-theorem guarantees this)")
        extra = sorted(set(act) - set(cert))
        if extra:
            print(f"    bonus victories not certified: {extra}")
        print()

    print("The certificate is one-sided and conservative: it never over-claims,")
    print("and the actual superiority region is at least as large.  Nothing is")
    print("promised where the rival is accurate -- and indeed, on the 'noisy'")
    print("rival's fine phenomena, the certificate stays silent.")


if __name__ == "__main__":
    main()


"""Visualization 1 -- The Truncation Tower and Its Window of Validity.

Two panels, side by side.

LEFT: for the perturbative family with coefficients a_n = (-r)^n (so B = 1),
plot the truncation error |R_N(eps)| against the coupling eps on log-log axes,
for N = 0, 1, ..., 5.  Inside the certified window the curves are strictly
nested -- higher order lies strictly below lower order -- which is the wrongness
hierarchy theorem made visible.  The vertical dashed line marks the certified
window and the shaded band is the region where the guarantee holds.

RIGHT: the sharpness counterexample.  For the family W(eps) = eps - 3 eps^2 the
order-0 and order-1 truncation errors are plotted together.  They cross: beyond
the crossing point the HIGHER truncation is strictly worse, and at eps = 1 the
errors are 2 and 3 respectively.  Monotone improvement is a genuinely
small-coupling phenomenon.

Requires matplotlib and numpy.
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt
import numpy as np


def wrongness_geometric(eps: np.ndarray, ratio: float) -> np.ndarray:
    """Exact sum of a_n = (-ratio)^n: W(eps) = eps / (1 + ratio*eps)."""
    return eps / (1.0 + ratio * eps)


def truncation_geometric(eps: np.ndarray, ratio: float, order: int) -> np.ndarray:
    """Partial sum sum_{n<order} (-ratio)^n eps^(n+1)."""
    out = np.zeros_like(eps)
    for n in range(order):
        out = out + ((-ratio) ** n) * eps ** (n + 1)
    return out


def hierarchy_window(bound: float, ratio: float, c: float, m: int, n: int) -> float:
    noise = 2.0 * bound * (ratio ** n + ratio ** (m + 1)) + 1.0
    return min(1.0, 1.0 / (2.0 * (ratio + 1.0)), c / noise)


def make_figure(path: str = "tower.png") -> None:
    ratio, bound = 2.0, 1.0
    eps = np.logspace(-3.0, np.log10(0.45), 400)

    exact = wrongness_geometric(eps, ratio)
    orders: List[int] = [0, 1, 2, 3, 4, 5]
    window = min(
        hierarchy_window(bound, ratio, abs((-ratio) ** m), m, m + 1)
        for m in orders[:-1]
    )

    fig, (ax_left, ax_right) = plt.subplots(1, 2, figsize=(13.5, 5.4))

    cmap = plt.get_cmap("viridis")
    for k, order in enumerate(orders):
        err = np.abs(exact - truncation_geometric(eps, ratio, order))
        err = np.maximum(err, 1e-24)
        ax_left.loglog(
            eps, err, lw=2.0, color=cmap(k / max(1, len(orders) - 1)),
            label=f"order {order}",
        )
    ax_left.axvspan(1e-3, window, color="0.85", zorder=0)
    ax_left.axvline(window, color="crimson", ls="--", lw=1.6)
    ax_left.text(
        window * 0.9, 1e-14, "certified window", rotation=90,
        ha="right", va="bottom", color="crimson", fontsize=9,
    )
    ax_left.set_xlabel(r"coupling $\varepsilon$")
    ax_left.set_ylabel(r"truncation error $|R_N(\varepsilon)|$")
    ax_left.set_title("The tower of truncations is strictly ordered")
    ax_left.legend(fontsize=8, loc="lower right", ncol=2)
    ax_left.grid(True, which="both", alpha=0.25)

    e = np.linspace(0.0, 1.15, 500)
    w = e - 3.0 * e ** 2
    err0 = np.abs(w)                 # order 0 discards everything
    err1 = np.abs(w - e)             # order 1 keeps the linear term
    ax_right.plot(e, err0, lw=2.4, color="#1f77b4", label="order 0 error")
    ax_right.plot(e, err1, lw=2.4, color="#d62728", label="order 1 error")
    cross = e[np.argmin(np.abs(err0 - err1)[e > 0.05]) + np.sum(e <= 0.05)]
    ax_right.axvline(cross, color="0.4", ls=":", lw=1.5)
    ax_right.annotate(
        "beyond here the HIGHER\ntruncation is worse",
        xy=(cross, 0.35), xytext=(cross + 0.10, 1.15),
        arrowprops=dict(arrowstyle="->", color="0.3"), fontsize=9, color="0.2",
    )
    ax_right.scatter([1.0, 1.0], [2.0, 3.0], zorder=5, color=["#1f77b4", "#d62728"])
    ax_right.annotate("2", xy=(1.0, 2.0), xytext=(1.03, 1.9), fontsize=10)
    ax_right.annotate("3", xy=(1.0, 3.0), xytext=(1.03, 2.9), fontsize=10)
    ax_right.set_xlabel(r"coupling $\varepsilon$")
    ax_right.set_ylabel("error against the exact prediction")
    ax_right.set_title(r"Sharpness: $W(\varepsilon)=\varepsilon-3\varepsilon^{2}$")
    ax_right.legend(fontsize=9)
    ax_right.grid(True, alpha=0.25)

    fig.suptitle(
        "Wrongness as a convergent series: strict improvement inside the window, "
        "failure outside it",
        fontsize=12,
    )
    fig.tight_layout()
    fig.savefig(path, dpi=160)
    print(f"written: {path}   (certified chain window |eps| < {window:.6f})")


if __name__ == "__main__":
    make_figure()


"""Visualization 2 -- The Epistemic Landscape: Half-Spaces and the Condorcet Cycle.

Two panels.

LEFT: the epistemic half-space theorem.  Two theories predict a = 2 and b = 5 at
some phenomenon.  As the unknown truth t ranges over all possible worlds, the
errors |t - a| and |t - b| are plotted; the region where the first theory wins is
shaded.  It is exactly the open, unbounded half-line t < (a+b)/2 -- so no
prediction is unconditionally inferior.  Predictive superiority is a fact about
theory AND world.

RIGHT: the Condorcet cycle.  Three theories with error profiles A = (1,2,3),
B = (2,3,1), C = (3,1,2) against a truth of zero on three phenomena.  A grouped
bar chart shows the profiles; arrows drawn between the group labels show that A
majority-beats B, B majority-beats C, and C majority-beats A -- a cycle.  Since
A does not majority-beat C, majority empirical adequacy is not transitive, and
no scalar ranking of theories by closeness to truth can exist.

Requires matplotlib and numpy.
"""

from __future__ import annotations

import matplotlib.pyplot as plt
import numpy as np


def make_figure(path: str = "worlds.png") -> None:
    fig, (ax_l, ax_r) = plt.subplots(1, 2, figsize=(13.5, 5.4))

    # ---- left: half-space theorem ------------------------------------
    a, b = 2.0, 5.0
    mid = (a + b) / 2.0
    t = np.linspace(-6.0, 12.0, 800)
    ax_l.plot(t, np.abs(t - a), lw=2.4, color="#1f77b4", label=r"error of $a=2$")
    ax_l.plot(t, np.abs(t - b), lw=2.4, color="#d62728", label=r"error of $b=5$")
    ax_l.fill_between(
        t, 0, 9, where=(t < mid), color="#1f77b4", alpha=0.12,
        label=r"worlds favouring $a$",
    )
    ax_l.axvline(mid, color="0.35", ls="--", lw=1.5)
    ax_l.annotate(
        r"midpoint $\frac{a+b}{2}=3.5$", xy=(mid, 8.4), xytext=(mid + 0.4, 8.3),
        fontsize=9, color="0.25",
    )
    ax_l.scatter([a], [0.0], zorder=6, color="#1f77b4")
    ax_l.annotate(
        r"$t=a$: the first theory is exactly right",
        xy=(a, 0.0), xytext=(-5.6, 1.1), fontsize=9,
        arrowprops=dict(arrowstyle="->", color="0.4"),
    )
    ax_l.annotate(
        "unbounded:\nruns to $-\\infty$",
        xy=(-5.7, 2.4), xytext=(-5.7, 2.4), fontsize=9, color="#1f77b4",
    )
    ax_l.set_xlim(-6, 12)
    ax_l.set_ylim(0, 9)
    ax_l.set_xlabel(r"possible world: the unknown truth $t$")
    ax_l.set_ylabel("prediction error")
    ax_l.set_title("Epistemic half-space theorem")
    ax_l.legend(fontsize=9, loc="lower right")
    ax_l.grid(True, alpha=0.25)

    # ---- right: Condorcet cycle --------------------------------------
    profiles = {"A": (1, 2, 3), "B": (2, 3, 1), "C": (3, 1, 2)}
    names = list(profiles)
    x = np.arange(3.0)
    width = 0.26
    colours = {"A": "#4c72b0", "B": "#dd8452", "C": "#55a868"}
    for k, name in enumerate(names):
        ax_r.bar(
            x + (k - 1) * width, profiles[name], width,
            color=colours[name], label=f"theory {name}",
        )
    ax_r.set_xticks(x)
    ax_r.set_xticklabels(["phenomenon 1", "phenomenon 2", "phenomenon 3"])
    ax_r.set_ylabel("error (truth is 0, so error = prediction)")
    ax_r.set_ylim(0, 4.6)
    ax_r.set_title("A Condorcet cycle in theory-space")
    ax_r.legend(fontsize=9, loc="upper left")
    ax_r.grid(True, axis="y", alpha=0.25)

    cycle_text = (
        "A beats B on phenomena 1,2   (majority)\n"
        "B beats C on phenomena 1,3   (majority)\n"
        "C beats A on phenomena 2,3   (majority)\n"
        "but A beats C on phenomenon 1 only\n"
        r"$\Rightarrow$ majority adequacy is NOT transitive"
    )
    ax_r.text(
        0.98, 0.97, cycle_text, transform=ax_r.transAxes, ha="right", va="top",
        fontsize=9,
        bbox=dict(boxstyle="round,pad=0.45", fc="#fff8e1", ec="#c8a415"),
    )

    fig.suptitle(
        "Superiority is world-relative, and it does not aggregate into a ranking",
        fontsize=12,
    )
    fig.tight_layout()
    fig.savefig(path, dpi=160)
    print(f"written: {path}")


if __name__ == "__main__":
    make_figure()


"""
The Unreasonable Effectiveness of Wrong Theories
================================================

Numerical demonstrations of the meta-theorem on perturbative theory-space.

A *theory* assigns a real prediction to each phenomenon.  A *perturbative
family* deforms an (unknowable) truth function by a power series in a coupling
epsilon,

    T_eps(p) = truth(p) + sum_{n >= 0} a_n(p) * eps^(n+1),

whose coefficients obey a uniform Cauchy bound |a_n(p)| <= B * r^n.  The sum
W(eps, p) = T_eps(p) - truth(p) is the *wrongness* of the theory.

This script demonstrates, with explicit numbers:

  1. Quantitative convergence:  |W| <= B|eps| / (1 - r|eps|).
  2. The meta-theorem: inside a computable window a wrong-but-approximately-
     correct theory beats EVERY rival on the rival's bad set.
  3. The wrongness hierarchy: the tower of truncations is strictly ordered by
     accuracy inside a computable punctured window.
  4. Sharpness: at eps = 1/2 the approximate theory eps loses to the crude
     wrong constant 1/4; for eps - 3 eps^2 at eps = 1 the first-order
     truncation is worse than the zeroth-order one.
  5. The epistemic half-space theorem: the set of worlds favouring a given
     prediction is an unbounded open half-line.
  6. The Condorcet cycle: majority empirical adequacy is not transitive.
  7. Pessimistic meta-induction: a sequence of theories, each wrong at every
     phenomenon, whose errors converge uniformly to zero.
  8. Wilson's two-loop anomalous dimension eta(eps) = eps^2 / 54 as a worked
     instance.

Run with:  python3 demo.py     (standard library only)
"""

from __future__ import annotations

import math
from typing import Callable, Dict, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Core objects
# ---------------------------------------------------------------------------


class PerturbativeFamily:
    """A perturbative family of theories over a finite phenomenon set.

    Attributes
    ----------
    truth : mapping phenomenon -> exact value.
    coeff : coefficient function (n, p) -> a_n(p); the coefficient of
            eps^(n+1) in the wrongness series.
    bound : constant B with |a_n(p)| <= B r^n for all n, p.
    ratio : constant r (inverse radius of convergence).
    n_max : practical truncation used for numerically summing the series.
    """

    def __init__(
        self,
        truth: Callable[[str], float],
        coeff: Callable[[int, str], float],
        bound: float,
        ratio: float,
        n_max: int = 400,
        terminating: bool = False,
    ) -> None:
        if bound < 0.0 or ratio < 0.0:
            raise ValueError("bound and ratio must be nonnegative")
        self.truth = truth
        self.coeff = coeff
        self.bound = bound
        self.ratio = ratio
        self.n_max = n_max
        # A terminating series (finitely many nonzero coefficients) converges
        # for every coupling, so the disc-of-convergence guard is waived.
        self.terminating = terminating

    # -- series -----------------------------------------------------------

    def term(self, n: int, eps: float, p: str) -> float:
        """The n-th term a_n(p) eps^(n+1) of the wrongness series."""
        return self.coeff(n, p) * eps ** (n + 1)

    def wrongness(self, eps: float, p: str) -> float:
        """W(eps, p): the total deviation of the theory from the truth."""
        if not self.terminating and self.ratio * abs(eps) >= 1.0:
            raise ValueError("outside the disc of convergence: r|eps| >= 1")
        return math.fsum(self.term(n, eps, p) for n in range(self.n_max))

    def predict(self, eps: float, p: str) -> float:
        """The exact prediction truth(p) + W(eps, p)."""
        return self.truth(p) + self.wrongness(eps, p)

    def truncate(self, order: int, eps: float, p: str) -> float:
        """The order-N truncation: keep n < N, discard the rest."""
        return self.truth(p) + math.fsum(
            self.term(n, eps, p) for n in range(order)
        )

    def tail(self, order: int, eps: float, p: str) -> float:
        """R_N = W - sum_{n<N} w_n: exactly what the truncation throws away."""
        return self.wrongness(eps, p) - math.fsum(
            self.term(n, eps, p) for n in range(order)
        )

    # -- certified bounds and windows -------------------------------------

    def cauchy_bound(self, eps: float) -> float:
        """The uniform estimate B|eps| / (1 - r|eps|) on |W(eps, p)|."""
        denom = 1.0 - self.ratio * abs(eps)
        if denom <= 0.0:
            raise ValueError("outside the disc of convergence")
        return self.bound * abs(eps) / denom

    def meta_window(self, eta: float) -> float:
        """delta such that |eps| < delta implies |W(eps,p)| < eta for all p."""
        if eta <= 0.0:
            raise ValueError("threshold eta must be positive")
        return min(
            1.0 / (2.0 * (self.ratio + 1.0)),
            eta / (2.0 * (self.bound + 1.0)),
        )

    def hierarchy_window(self, m: int, n: int, p: str) -> float:
        """delta such that 0<|eps|<delta implies order-n beats order-m at p."""
        if not m < n:
            raise ValueError("require m < n")
        c = abs(self.coeff(m, p))
        if c == 0.0:
            raise ValueError("the m-th correction vanishes at p")
        noise = 2.0 * self.bound * (self.ratio ** n + self.ratio ** (m + 1)) + 1.0
        return min(1.0, 1.0 / (2.0 * (self.ratio + 1.0)), c / noise)


def pred_err(value: float, truth_value: float) -> float:
    """Pointwise prediction error |value - truth|."""
    return abs(value - truth_value)


def beats(value_a: float, value_b: float, truth_value: float) -> bool:
    """Does prediction a land strictly closer to the truth than b?"""
    return pred_err(value_a, truth_value) < pred_err(value_b, truth_value)


# ---------------------------------------------------------------------------
# Concrete families
# ---------------------------------------------------------------------------


def binomial_family(a0: float, a1: float) -> PerturbativeFamily:
    """Truth 0 on a single phenomenon, wrongness exactly a0*eps + a1*eps^2."""

    def coeff(n: int, _p: str) -> float:
        if n == 0:
            return a0
        if n == 1:
            return a1
        return 0.0

    return PerturbativeFamily(
        truth=lambda _p: 0.0,
        coeff=coeff,
        bound=abs(a0) + abs(a1),
        ratio=1.0,
        n_max=2,
        terminating=True,
    )


def geometric_family(bound: float, ratio: float) -> PerturbativeFamily:
    """A saturating family a_n(p) = B r^n (-1)^n, truth 0: the extreme case."""
    return PerturbativeFamily(
        truth=lambda _p: 0.0,
        coeff=lambda n, _p: bound * (ratio ** n) * (-1.0) ** n,
        bound=bound,
        ratio=ratio,
    )


def wilson_family() -> PerturbativeFamily:
    """Wilson's two-loop anomalous dimension eta(eps) = eps^2 / 54."""
    return binomial_family(0.0, 1.0 / 54.0)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_convergence() -> None:
    print("=" * 74)
    print("1. QUANTITATIVE CONVERGENCE OF WRONGNESS")
    print("=" * 74)
    fam = geometric_family(bound=2.0, ratio=3.0)
    print("Family: a_n = 2 * 3^n * (-1)^n, truth = 0, so B = 2, r = 3.")
    print("Claim:  |W(eps)| <= B|eps| / (1 - r|eps|), uniformly in the")
    print("        phenomenon, whenever r|eps| < 1 (here |eps| < 1/3).\n")
    print(f"{'eps':>10} {'|W(eps)|':>16} {'certified bound':>18} {'slack':>12}")
    for eps in (0.30, 0.20, 0.10, 0.05, 0.01, 0.001):
        w = abs(fam.wrongness(eps, "p"))
        b = fam.cauchy_bound(eps)
        print(f"{eps:>10.4f} {w:>16.10f} {b:>18.10f} {b - w:>12.3e}")
    print("\nThe bound holds at every row and tightens as eps -> 0.")
    print("Note it contains no reference to the phenomenon: shrinking the")
    print("coupling buys accuracy across the whole domain of application")
    print("at once.\n")


def demo_meta_theorem() -> None:
    print("=" * 74)
    print("2. THE META-THEOREM: A WRONG THEORY BEATS EVERY IMPERFECT RIVAL")
    print("=" * 74)
    fam = geometric_family(bound=2.0, ratio=3.0)
    eta = 0.05
    delta = fam.meta_window(eta)
    print(f"Threshold eta = {eta}.  Certified window delta = {delta:.10f}")
    print("The window was computed from B, r and eta ALONE -- before any")
    print("rival was named.  We now try to defeat it with four very")
    print("different rivals.\n")

    eps = 0.5 * delta
    truth_value = 0.0
    approx = fam.predict(eps, "p")
    rivals: Dict[str, float] = {
        "crude constant   ": 0.30,
        "sign-flipped copy": -approx * 3.0 - 0.2,
        "lucky guess      ": 0.004,
        "wildly off       ": 17.0,
    }
    print(f"At eps = {eps:.8f} the approximate theory predicts "
          f"{approx:+.10f}")
    print(f"(its own error is {pred_err(approx, truth_value):.3e}, "
          f"well under eta).\n")
    print(f"{'rival':>20} {'prediction':>14} {'rival error':>14} "
          f"{'>= eta?':>9} {'we win?':>9}")
    for name, value in rivals.items():
        err = pred_err(value, truth_value)
        certified = err >= eta
        won = beats(approx, value, truth_value)
        print(f"{name:>20} {value:>14.6f} {err:>14.6f} "
              f"{str(certified):>9} {str(won):>9}")
    print("\nEvery rival whose error reaches the threshold is beaten -- as")
    print("the meta-theorem guarantees.  Note the 'lucky guess' has error")
    print("below eta, so it is NOT covered by the guarantee; the theorem")
    print("claims victory only on the rival's bad set.\n")


def demo_hierarchy() -> None:
    print("=" * 74)
    print("3. THE WRONGNESS HIERARCHY: THE TOWER OF TRUNCATIONS")
    print("=" * 74)
    fam = geometric_family(bound=1.0, ratio=2.0)
    print("Family: a_n = 2^n (-1)^n, truth = 0, so B = 1, r = 2.")
    windows = [fam.hierarchy_window(m, m + 1, "p") for m in range(5)]
    delta = min(windows)
    print(f"Common punctured window for orders 0..5: delta = {delta:.10f}\n")
    eps = 0.5 * delta
    exact = fam.predict(eps, "p")
    print(f"At eps = {eps:.10f}, the exact prediction is {exact:.12f}.")
    print(f"{'order N':>9} {'truncated value':>20} "
          f"{'|error| vs exact':>20} {'strictly better?':>18}")
    prev: float | None = None
    for order in range(6):
        value = fam.truncate(order, eps, "p")
        err = pred_err(value, exact)
        better = "-" if prev is None else str(err < prev)
        print(f"{order:>9} {value:>20.14f} {err:>20.3e} {better:>18}")
        prev = err
    print("\nThe errors decrease strictly: the tower of knowingly-wrong")
    print("truncations is totally ordered by empirical adequacy.  Each")
    print("added correction genuinely helps -- inside the window.\n")


def demo_sharpness() -> None:
    print("=" * 74)
    print("4. SHARPNESS: BOTH GUARANTEES FAIL OUTSIDE THEIR WINDOWS")
    print("=" * 74)

    print("(a) The meta-theorem needs a small coupling.")
    fam = binomial_family(1.0, 0.0)          # W(eps) = eps, truth 0
    eps = 0.5
    approx = fam.predict(eps, "p")
    rival = 0.25
    print(f"    approximate theory  T_eps = eps, at eps = {eps}: "
          f"prediction {approx}")
    print(f"    crude wrong rival   C = {rival} (itself wrong: truth is 0)")
    print(f"    errors: approximate {pred_err(approx, 0.0)}, "
          f"rival {pred_err(rival, 0.0)}")
    print(f"    does the approximate theory win?  "
          f"{beats(approx, rival, 0.0)}")
    print("    -> at eps = 1/2 the crude guess wins.  The window is real.\n")

    print("(b) Higher order is not always better.")
    fam2 = binomial_family(1.0, -3.0)        # W(eps) = eps - 3 eps^2
    eps = 1.0
    exact = fam2.predict(eps, "p")
    e0 = pred_err(fam2.truncate(0, eps, "p"), exact)
    e1 = pred_err(fam2.truncate(1, eps, "p"), exact)
    print(f"    family W(eps) = eps - 3 eps^2, at eps = {eps}: "
          f"exact value {exact}")
    print(f"    order-0 truncation error: {e0}")
    print(f"    order-1 truncation error: {e1}")
    print(f"    is order 1 better than order 0?  {e1 < e0}")
    print("    -> adding a correction made the prediction WORSE.")
    hw = fam2.hierarchy_window(0, 1, "p")
    print(f"    (the certified window here is only |eps| < {hw:.6f})\n")


def demo_half_space() -> None:
    print("=" * 74)
    print("5. THE EPISTEMIC HALF-SPACE THEOREM")
    print("=" * 74)
    a, b = 2.0, 5.0
    print(f"Two theories predict a = {a} and b = {b} at some phenomenon.")
    print("For which worlds (values t of the unknown truth) does a win?")
    print("Algebra:  |t-a| < |t-b|  <=>  (b-a)(2t-a-b) < 0.")
    midpoint = (a + b) / 2.0
    print(f"Here b > a, so the favouring set is the half-line t < "
          f"{midpoint}.\n")
    print(f"{'world t':>12} {'|t-a|':>10} {'|t-b|':>10} {'a wins?':>10} "
          f"{'predicted':>12}")
    for t in (-1e6, -10.0, 0.0, 2.0, 3.4, 3.5, 3.6, 10.0, 1e6):
        wins = abs(t - a) < abs(t - b)
        predicted = (b - a) * (2.0 * t - a - b) < 0.0
        print(f"{t:>12.4g} {abs(t-a):>10.4g} {abs(t-b):>10.4g} "
              f"{str(wins):>10} {str(predicted):>12}")
    print("\nThe favouring set is open, contains t = a (where the first")
    print("theory is exactly right), and is unbounded (it reaches -1e6 and")
    print("beyond).  No prediction is unconditionally inferior: predictive")
    print("superiority is a fact about theory AND world, never about the")
    print("theory alone.\n")


def demo_condorcet() -> None:
    print("=" * 74)
    print("6. THE CONDORCET CYCLE: ADEQUACY DOES NOT AGGREGATE")
    print("=" * 74)
    truth: Sequence[float] = (0.0, 0.0, 0.0)
    theories: Dict[str, Tuple[float, float, float]] = {
        "A": (1.0, 2.0, 3.0),
        "B": (2.0, 3.0, 1.0),
        "C": (3.0, 1.0, 2.0),
    }
    print("Three phenomena, truth = 0, three theories with error profiles:")
    for name, prof in theories.items():
        print(f"    {name} = {prof}")
    print()

    def majority_wins(x: str, y: str) -> Tuple[int, List[int]]:
        wins = [
            i
            for i in range(3)
            if beats(theories[x][i], theories[y][i], truth[i])
        ]
        return len(wins), wins

    print(f"{'comparison':>14} {'phenomena won':>18} {'majority?':>12}")
    for x, y in (("A", "B"), ("B", "C"), ("C", "A"), ("A", "C")):
        count, which = majority_wins(x, y)
        label = f"{x} beats {y}"
        idx = [i + 1 for i in which]
        print(f"{label:>14} {str(idx):>18} {str(count >= 2):>12}")
    print("\nA majority-beats B, B majority-beats C, C majority-beats A --")
    print("a cycle.  And A does NOT majority-beat C, so the relation is not")
    print("transitive.  There is no consistent global ranking of theories")
    print("by 'closeness to truth': comparative adequacy is a directed")
    print("graph with cycles, not an order.\n")


def demo_meta_induction() -> None:
    print("=" * 74)
    print("7. UNIVERSAL FALSITY IS COMPATIBLE WITH CONVERGENCE")
    print("=" * 74)
    truth_value = 7.25
    print(f"Truth at every phenomenon: {truth_value}.")
    print("Sequence of theories  F_k = truth + 1/(k+1).")
    print("Every single one is wrong at every single phenomenon.\n")
    print(f"{'k':>6} {'prediction':>18} {'exactly right?':>16} "
          f"{'error':>14}")
    for k in (0, 1, 2, 10, 100, 10_000, 1_000_000):
        value = truth_value + 1.0 / (k + 1.0)
        err = pred_err(value, truth_value)
        print(f"{k:>6} {value:>18.12f} "
              f"{str(value == truth_value):>16} {err:>14.3e}")
    eta = 1e-3
    k_star = math.ceil(1.0 / eta)
    print(f"\nFor tolerance eta = {eta}, all theories with k >= {k_star} are")
    print("within eta of the truth, uniformly over phenomena.  A history of")
    print("uniformly false theories is no obstruction to convergence on the")
    print("truth: falsity is binary, accuracy is a magnitude.\n")


def demo_wilson() -> None:
    print("=" * 74)
    print("8. WORKED INSTANCE: THE TWO-LOOP EPSILON-EXPANSION")
    print("=" * 74)
    fam = wilson_family()
    print("At the Wilson-Fisher fixed point in d = 4 - eps dimensions, the")
    print("two-loop anomalous dimension is eta(eps) = eps^2 / 54 + O(eps^3).")
    print("This is a perturbative family with a_0 = 0, a_1 = 1/54,")
    print(f"B = {fam.bound:.8f}, r = {fam.ratio}.\n")
    print(f"{'eps = 4-d':>12} {'dimension d':>13} {'eta(eps)':>16} "
          f"{'series sum':>16}")
    for eps in (0.05, 0.1, 0.25, 0.5, 0.9):
        closed = eps * eps / 54.0
        summed = fam.predict(eps, "p")
        print(f"{eps:>12.3f} {4.0 - eps:>13.3f} {closed:>16.10f} "
              f"{summed:>16.10f}")
    for eta in (1e-2, 1e-3, 1e-4):
        delta = fam.meta_window(eta)
        print(f"\nthreshold eta = {eta:>8}:  certified window "
              f"|eps| < {delta:.8f}   (dimensions d in "
              f"({4 - delta:.6f}, {4 + delta:.6f}))")
    print("\nInside that window the truncated -- and hence strictly wrong --")
    print("two-loop theory outpredicts EVERY rival whose error exceeds the")
    print("threshold.  The physically interesting case is eps = 1 (three")
    print("dimensions), far outside any such window: that the extrapolated")
    print("formula still gives critical exponents good to a few percent is")
    print("good fortune, not theorem.\n")


def main() -> None:
    print()
    print("#" * 74)
    print("#  THE UNREASONABLE EFFECTIVENESS OF WRONG THEORIES".ljust(73) + "#")
    print("#  Numerical demonstrations of perturbation theory on".ljust(73) + "#")
    print("#  theory-space".ljust(73) + "#")
    print("#" * 74)
    print()
    demo_convergence()
    demo_meta_theorem()
    demo_hierarchy()
    demo_sharpness()
    demo_half_space()
    demo_condorcet()
    demo_meta_induction()
    demo_wilson()
    print("=" * 74)
    print("All demonstrations completed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
