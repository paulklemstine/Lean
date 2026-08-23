"""Assemble PACKAGE.json from the packaging artefacts in this repository."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Combinatorics/KneeInvariance.lean",
    "Catalog/Combinatorics/MathReadsAsProse.lean",
    "Catalog/Combinatorics/DeploymentEntryCover.lean",
    "Catalog/Combinatorics/KneeQuantile.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== {f} =====\n\n{read(ROOT / f)}" for f in LEAN_FILES
)

ALG_A = '''"""Algorithm A — Monotone-hull knee extraction from a measured sweep."""

from __future__ import annotations

from fractions import Fraction
from typing import Dict, List

Rat = Fraction


def monotone_hull(sweep: Dict[int, Rat]) -> Dict[int, Rat]:
    """Running maximum of a measured sweep, repairing within-noise dips."""
    hull: Dict[int, Rat] = {}
    best = Rat(0)
    for k in sorted(sweep):
        best = max(best, sweep[k])
        hull[k] = best
    return hull


def knee_from_sweep(sweep: Dict[int, Rat], gate: Rat) -> int:
    """Least swept budget whose retained agreement reaches the gate.

    Binary search is valid because the hulled curve is monotone and the knee is
    its left adjoint: knee <= k iff gate <= A(k).
    """
    hull = monotone_hull(sweep)
    budgets: List[int] = sorted(hull)
    lo, hi = 0, len(budgets) - 1
    if hull[budgets[hi]] < gate:
        raise ValueError("gate is not reached anywhere in the swept range")
    while lo < hi:
        mid = (lo + hi) // 2
        if hull[budgets[mid]] >= gate:
            hi = mid
        else:
            lo = mid + 1
    return budgets[lo]


if __name__ == "__main__":
    math_512 = {4: Rat(907, 1000), 8: Rat(959, 1000), 12: Rat(979, 1000),
                16: Rat(987, 1000), 20: Rat(989, 1000), 24: Rat(988, 1000)}
    math_1024 = {8: Rat(952, 1000), 12: Rat(965, 1000), 16: Rat(978, 1000),
                 20: Rat(983, 1000), 24: Rat(985, 1000)}
    g = Rat(981, 1000)
    print("ctx  512: knee =", knee_from_sweep(math_512, g))
    print("ctx 1024: knee =", knee_from_sweep(math_1024, g))
'''

ALG_B = '''"""Algorithm B — Admissible gate window certification."""

from __future__ import annotations

from fractions import Fraction
from typing import Dict, Tuple

Rat = Fraction


def monotone_hull(sweep: Dict[int, Rat]) -> Dict[int, Rat]:
    hull: Dict[int, Rat] = {}
    best = Rat(0)
    for k in sorted(sweep):
        best = max(best, sweep[k])
        hull[k] = best
    return hull


def admissible_gate_window(sweep: Dict[int, Rat], knee: int) -> Tuple[Rat, Rat]:
    """The half-open interval of gates for which this budget is exactly the knee.

    Every gate in (A(previous budget), A(knee)] yields the reported knee, so
    publishing the window rather than a single tuned gate makes the claim
    falsifiable.
    """
    hull = monotone_hull(sweep)
    budgets = sorted(hull)
    i = budgets.index(knee)
    lower = hull[budgets[i - 1]] if i > 0 else Rat(0)
    return lower, hull[knee]


def overlap(w1: Tuple[Rat, Rat], w2: Tuple[Rat, Rat]) -> Tuple[Rat, Rat]:
    """Gates certifying two cells at once — the common-gate increment check."""
    lo, hi = max(w1[0], w2[0]), min(w1[1], w2[1])
    if lo >= hi:
        raise ValueError("windows do not overlap")
    return lo, hi


if __name__ == "__main__":
    math_512 = {4: Rat(907, 1000), 8: Rat(959, 1000), 12: Rat(979, 1000),
                16: Rat(987, 1000), 20: Rat(989, 1000), 24: Rat(988, 1000)}
    math_1024 = {8: Rat(952, 1000), 12: Rat(965, 1000), 16: Rat(978, 1000),
                 20: Rat(983, 1000), 24: Rat(985, 1000)}
    w512 = admissible_gate_window(math_512, 16)
    w1024 = admissible_gate_window(math_1024, 20)
    print("ctx  512 window:", tuple(map(float, w512)))
    print("ctx 1024 window:", tuple(map(float, w1024)))
    print("overlap        :", tuple(map(float, overlap(w512, w1024))),
          "-> one gate certifies both cells; increment 20 - 16 = +4")
'''

ALG_C = '''"""Algorithm C — Minimum deployment entry cover with a packing certificate."""

from __future__ import annotations

from typing import Iterable, List, Sequence, Tuple


def serves(delta: int, entry: int, knee: int) -> bool:
    """Entry serves the knee: clears the gate, wastes at most delta keys."""
    return knee <= entry <= knee + delta


def greedy_entry_cover(knees: Iterable[int], delta: int) -> List[int]:
    """Minimum set of cache-size entries serving every knee at tolerance delta.

    Top-anchored greedy: repeatedly take the largest uncovered knee as an entry
    and delete everything it serves. An entry must never fall below the knee it
    serves, which is why the anchor is the top and not the bottom.
    """
    remaining = sorted(set(knees), reverse=True)
    entries: List[int] = []
    while remaining:
        b = remaining[0]
        entries.append(b)
        remaining = [k for k in remaining if not serves(delta, b, k)]
    return entries


def packing_certificate(knees: Iterable[int], delta: int) -> List[int]:
    """A maximum delta-separated subset: the matching lower-bound witness."""
    chosen: List[int] = []
    for k in sorted(set(knees)):
        if not chosen or chosen[-1] + delta < k:
            chosen.append(k)
    return chosen


def minimum_entries(knees: Sequence[int], delta: int) -> Tuple[int, List[int], List[int]]:
    cover = greedy_entry_cover(knees, delta)
    pack = packing_certificate(knees, delta)
    assert len(cover) == len(pack), "greedy and packing must agree"
    return len(cover), cover, pack


if __name__ == "__main__":
    for delta in range(0, 7):
        m, cover, pack = minimum_entries([16, 12, 16], delta)
        print(f"delta={delta}: minimum {m}  cover {cover}  packing {pack}")
    # extremal configuration: m knees spaced delta+1 apart need exactly m entries
    for delta, m in [(3, 4), (4, 3), (7, 6)]:
        knees = [5 + (delta + 1) * i for i in range(m)]
        print(f"AP(delta={delta}, m={m}) -> minimum {minimum_entries(knees, delta)[0]}")
'''

FUTURE_DIRECTIONS = '# Future Directions\n\n## What this cycle established\n\nA *demand-multiset calculus* for budget/quality knees, applied to the measured\nthree-domain cell.\n\n1. **The knee calculus.** The knee is the left adjoint of the retention curve; the\n   sweep is a function of the demand multiset only; knee and accuracy are\n   *independent coordinates*, in the strong sense that the joint map is surjective;\n   any strictly monotone distortion of the quality axis leaves the knee fixed; a\n   Markov bridge bounds the knee by the mean demand over the gate slack; and every\n   measured count profile is realised by an honest workload.\n2. **The measured verdict.** The knee is $16$ at context $512$ for the whole gate\n   window $(0.979, 0.987]$ and $20$ at context $1024$ on $(0.978, 0.983]$, identical\n   to prose, with measured accuracy gaps of $0.1198$ and $0.1194$ — the prediction\n   that harder text needs more keys is refuted, and the prediction that the knees\n   coincide exactly is confirmed. The $+4$ increment holds on the overlapping gate\n   window, and the result is independent of the corpus mixing ratio.\n3. **The deployment table** as an interval point-cover, with a packing/covering\n   min–max and the exact tolerance threshold $\\delta = 4$ at which prose, mathematics\n   **and** code collapse to a single entry.\n4. **The mechanism.** The knee is the $\\lceil g \\cdot n\\rceil$-th order statistic of\n   the demand distribution, with an exact tail criterion and a\n   perturbation-robustness theorem.\n\nThe structural pattern: **accuracy is a mean of one statistic, the knee is a quantile\nof a different one**, and the two statistics are only coupled through the identity of\nthe windows — which is precisely the coupling the surjectivity theorem destroys.\n\n## Bold, testable conjectures for the next cycle\n\n### D1 — Sub-additivity of the knee under corpus concatenation\n\nMixing *curves* traps the knee between the constituent knees. Concatenating *corpora*\nis a different operation: the demand multisets add.\n\n**Conjecture:** for the union of two workloads with window counts $n_1, n_2$,\n$$\\mathrm{knee}(\\text{union}, g) \\le \\max\\bigl(\\mathrm{knee}(D_1, g_1),\\,\n\\mathrm{knee}(D_2, g_2)\\bigr)$$\nwhenever $g \\le (n_1 g_1 + n_2 g_2)/(n_1+n_2)$, with equality iff one demand multiset\ndominates the other in the tail region.\n\n*The key insight is* that the union\'s agreement curve is the $n$-weighted average of\nthe constituents\', so the quantile of the union is squeezed by the constituents\'\nquantiles at *shifted* gates.\n\n*Why now?* The main external limit of the measured cell is that it uses one corpus\nmix; a proved concatenation law removes the mixing ratio from the deployment argument\nentirely.\n\n### D2 — Knee stability is equivalent to tail-exchangeability\n\n**Conjecture:** two domains have equal knees at every gate in a window if and only if\ntheir demand multisets agree above the corresponding tail threshold. This would\nreplace the sufficient condition "equal demand multisets" by an exact\ncharacterisation, and would predict in advance which domain pairs share a deployment\nentry.\n\n### D3 — Empirical extensions\n\nModern LaTeX-style, notation-dense mathematical text (as opposed to classical\nmathematical prose); non-English domains; whether the $+4$ increment survives to\ncontext $4096$; and the behaviour of the three-domain table at substantially larger\nmodel scale.\n'

INTERACTIVE_LAYOUT = read(A / "interactive_layout.md")

package = {
    "title": "The Knee Is a Quantile: Why Mathematical Text Reads as Prose",
    "domain": "Combinatorics",
    "description": (
        "A demand-multiset calculus proving that the memory budget at which a "
        "truncated predictor still matches the full one is an order statistic of the "
        "per-position demand distribution, hence completely decoupled from prediction "
        "accuracy — explaining why classical mathematical text needs exactly the same "
        "budget as English prose (16 keys at context 512, 20 at 1024) despite being "
        "twelve accuracy points harder. The resulting deployment table is solved as an "
        "interval point-cover problem with a packing–covering min–max duality."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-23",
    "key_results": [
        "The knee is the left adjoint of the budget-quality curve: for a monotone "
        "curve, the knee at gate g is at most k exactly when the curve at k reaches g.",
        "Multiset invariance: two workloads with the same multiset of per-position "
        "demands have identical budget-quality curves and hence identical knees at "
        "every gate, whatever their accuracies.",
        "Decoupling theorem: for every position count, every budget and every "
        "achievable accuracy there is a workload realising both, so the joint map from "
        "workloads to (knee, accuracy) is surjective and no inequality can link "
        "prediction difficulty to memory budget.",
        "Quantile identity: on n positions at gate g the knee equals the ceiling(g n)-th "
        "smallest demand, with the exact criterion that a budget clears the gate iff its "
        "unserved tail is at most (1-g)n, and a robustness theorem allowing the demands "
        "of up to (1-g)n minus the tail positions to be perturbed arbitrarily.",
        "Mathematics reads as prose: on the measured cells the knee is 16 for every gate "
        "in (0.979, 0.987] at context 512 and 20 for every gate in (0.978, 0.983] at "
        "context 1024 — identical to prose — while accuracies differ by exactly 0.1198 "
        "and 0.1194; the context increment is a rigid +4 at a single common gate.",
        "Min-max duality for deployment entries: an entry serves a knee k at tolerance "
        "delta iff k <= b <= k+delta; a greedy top-anchored cover uses at most "
        "floor((b-a)/(delta+1))+1 entries, separated knees force that many, and on knees "
        "in arithmetic progression of step delta+1 the minimum is exactly their number. "
        "For the measured knee set {12, 16} a single entry suffices precisely when "
        "delta is at least 4 — one scale increment.",
    ],
    "keywords": [
        "order statistics", "quantile", "demand multiset", "budget-quality curve",
        "Galois adjunction", "interval point cover", "packing-covering duality",
        "attention sparsity",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "End-to-End Numerical Verification of the Demand-Multiset Calculus",
            "description": (
                "A single self-contained script that reconstructs every result from the "
                "measured numbers using exact rational arithmetic. It builds workloads "
                "from the measured step profiles and recomputes the knees (16 at context "
                "512, 20 at context 1024) together with their admissible gate windows and "
                "the +4 increment at a single common gate; exhibits two workloads with "
                "identical demand multisets, identical knees at every gate and a 0.8 "
                "accuracy gap; demonstrates surjectivity of the (knee, accuracy) pair via "
                "flat workloads; checks the quantile identity knee = ceiling(g n)-th "
                "smallest demand at six gates; verifies the exact tail criterion and the "
                "Markov relaxation; blows up the demands of the hardest positions and "
                "confirms the knee does not move; checks reparametrisation invariance, "
                "the rigid shift and mixture stability; and computes minimum deployment "
                "entry covers, confirming the packing bound matches the greedy cover on "
                "200 random knee sets and locating the exact threshold delta = 4."
            ),
            "code": read(ROOT / "demo.py"),
        }
    ],
    "algorithms": [
        {
            "name": "Monotone-Hull Knee Extraction from a Measured Budget Sweep",
            "description": (
                "Converts a measured sweep of (budget, retained agreement) pairs into the "
                "knee at a prescribed gate. Measured agreement values may dip within a "
                "standard error (the sweep records 0.989 at budget 20 and 0.988 at budget "
                "24), so the procedure first takes the running maximum — the monotone "
                "hull — which is the principled repair and the minimal assumption under "
                "which the knee is well defined. On the hulled curve the knee is the left "
                "adjoint of the curve: knee <= k if and only if gate <= A(k). That "
                "adjunction is precisely the predicate monotonicity binary search needs, "
                "so the search over the swept budgets is correct. Complexity: O(m) for the "
                "hull over m swept budgets, then O(log m) comparisons; exact rational "
                "arithmetic avoids any floating-point boundary error at the gate."
            ),
            "pseudocode": (
                "INPUT  : sweep S = {(k_1,A_1),...,(k_m,A_m)} with k_1 < ... < k_m; gate g\n"
                "OUTPUT : the knee k* = min { k_j : hull(A)_j >= g }\n"
                "\n"
                "1  best <- 0\n"
                "2  for j <- 1 to m do                      // monotone hull\n"
                "3      best <- max(best, A_j)\n"
                "4      H_j  <- best\n"
                "5  if H_m < g then error \"gate unreachable in swept range\"\n"
                "6  lo <- 1 ; hi <- m                       // binary search on the adjunction\n"
                "7  while lo < hi do\n"
                "8      mid <- floor((lo + hi) / 2)\n"
                "9      if H_mid >= g then hi <- mid else lo <- mid + 1\n"
                "10 return k_lo"
            ),
            "code": ALG_A,
        },
        {
            "name": "Admissible Gate Window Certification and Common-Gate Increment Check",
            "description": (
                "A knee reported at a single hand-picked gate is unfalsifiable: the reader "
                "cannot tell whether the gate was chosen to produce the number. This "
                "procedure returns instead the entire half-open interval of gates yielding "
                "the reported knee, namely (A(previous swept budget), A(knee)] — every gate "
                "in it gives the same knee, because the knee is pinned by a witness above "
                "the gate together with sub-gate values everywhere below. For the measured "
                "cells this yields (0.979, 0.987] at context 512 and (0.978, 0.983] at "
                "context 1024. Intersecting the two windows gives (0.979, 0.983], a "
                "nonempty overlap, so a single gate certifies both cells simultaneously and "
                "the reported context increment of +4 keys is not an artefact of using "
                "different gates at different contexts. Complexity: O(m)."
            ),
            "pseudocode": (
                "INPUT  : sweep S with hulled values H; a reported knee k_i\n"
                "OUTPUT : the interval (lo, hi] of gates whose knee is exactly k_i\n"
                "\n"
                "1  lo <- (i > 1) ? H_{i-1} : 0\n"
                "2  hi <- H_i\n"
                "3  assert lo < hi                      // else the budget is not a knee\n"
                "4  return (lo, hi]\n"
                "\n"
                "COMMON-GATE CHECK\n"
                "5  (lo1, hi1) <- window of the context-c cell\n"
                "6  (lo2, hi2) <- window of the context-2c cell\n"
                "7  lo <- max(lo1, lo2) ; hi <- min(hi1, hi2)\n"
                "8  if lo >= hi then report \"no common gate\"\n"
                "9  else report increment = knee_2c - knee_c, certified on (lo, hi]"
            ),
            "code": ALG_B,
        },
        {
            "name": "Minimum Deployment Entry Cover by Top-Anchored Greedy, with Packing Certificate",
            "description": (
                "Solves the fleet-provisioning problem exactly. An entry b serves a domain "
                "of knee k at waste tolerance delta when k <= b <= k + delta, so each "
                "domain is the integer interval [k, k+delta] and an entry set is a set of "
                "points hitting all intervals. The greedy takes the largest uncovered knee "
                "as an entry and deletes everything it serves; anchoring at the top is "
                "essential, since an entry that falls below a knee fails the quality gate "
                "outright. Optimality is certified rather than assumed: the knees that "
                "triggered emissions are pairwise more than delta apart, and no single "
                "entry can serve two such knees, so the number of emissions is also a lower "
                "bound. The procedure therefore returns a cover and a matching packing "
                "witness of equal size. On knees in arithmetic progression of common "
                "difference delta+1 the answer is exactly the number of knees, matching the "
                "closed-form covering bound floor((b-a)/(delta+1)) + 1. Complexity: "
                "O(|K| log |K|) for the sort, then a linear sweep."
            ),
            "pseudocode": (
                "INPUT  : knee set K (finite, nonempty); waste tolerance delta >= 0\n"
                "OUTPUT : a minimum entry set E and a packing certificate S with |E| = |S|\n"
                "\n"
                "COVER\n"
                "1  R <- distinct elements of K, sorted descending\n"
                "2  E <- empty list\n"
                "3  while R is nonempty do\n"
                "4      b <- first element of R                 // largest uncovered knee\n"
                "5      append b to E\n"
                "6      R <- { k in R : not (k <= b <= k + delta) }\n"
                "\n"
                "PACKING CERTIFICATE\n"
                "7  S <- empty list\n"
                "8  for k in distinct elements of K, ascending do\n"
                "9      if S is empty or last(S) + delta < k then append k to S\n"
                "\n"
                "10 assert |E| = |S|                            // packing = covering\n"
                "11 return (E, S)"
            ),
            "code": ALG_C,
        },
    ],
    "visualizations": [
        {
            "name": "Three-Domain Budget Sweeps, Their Knees, and the Accuracy Gap They Ignore",
            "description": (
                "Two panels side by side. The left panel plots the retained-agreement step "
                "curves against key budget for mathematics, prose and code at context 512, "
                "with the gate line at 0.981, the shaded admissible gate window (0.979, "
                "0.987], and a marker at each domain's knee: 16 for mathematics, 16 for "
                "prose, 12 for code. The right panel shows the full-model accuracies, "
                "0.4460 for prose against 0.3262 for mathematics, with the 0.1198 gap "
                "annotated and labelled 'zero extra keys'. The figure is the whole verdict "
                "in one image: the vertical distance on the right buys no horizontal "
                "movement on the left."
            ),
            "code": read(A / "viz_sweeps.py"),
        },
        {
            "name": "Deployment Entries as an Interval Point Cover, and Packing Meeting Covering",
            "description": (
                "The top panel draws, for each tolerance delta from 0 to 6, the intervals "
                "[k, k+delta] of the three domains over the measured knee set {12, 16}, "
                "with the greedy entries marked as vertical points hitting them. The "
                "collapse from two entries to one is visible exactly at delta = 4 — one "
                "scale increment — and is marked by a threshold line. The bottom panel "
                "plots, for several tolerances, the greedy cover size and the packing lower "
                "bound against the number m of knees in arithmetic progression of step "
                "delta+1: all curves coincide with the line y = m, exhibiting the min-max "
                "duality and showing that neither bound can be improved."
            ),
            "code": read(A / "viz_cover.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Knee Laboratory: Drag Difficulty, Watch the Budget Refuse to Move",
            "description": (
                "A three-panel exploratory widget. Panel one draws the retained-agreement "
                "curves for prose, code and mathematics with a draggable quality gate and a "
                "separate slider for the full-model accuracy; the accuracy slider rewrites "
                "the correctness bits of the positions and demonstrably moves nothing else, "
                "while the gate slider walks the knee across the sweep and reports when "
                "prose and mathematics coincide. Panel two visualises the positions sorted "
                "by demand as a coloured strip with the rank ceiling(g n) marked, so the "
                "quantile identity is visible directly; a perturbation slider blows up the "
                "demands of the hardest positions and shows the marker holding still until "
                "the perturbed count crosses the slack (1-g)n, at which point the knee "
                "jumps. Panel three renders each domain as an interval [k, k+delta] on the "
                "cache-size axis with the greedy entries as hitting points, so the reader "
                "can slide the waste tolerance and discover for themselves the exact "
                "threshold delta = 4 at which prose, mathematics and code collapse to the "
                "single entry 16."
            ),
            "html": read(A / "knee_lab.html"),
        }
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {"demo": read(ROOT / "demo.py")},
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False), encoding="utf-8")
print("wrote", out, out.stat().st_size, "bytes")


"""Visualisation: deployment entries as an interval point cover.

Top panel    — for the measured knee set {12, 16}, the intervals [k, k+delta] of each
               domain as delta grows, with the greedy (top-anchored) entries marked;
               the collapse from two entries to one happens exactly at delta = 4.
Bottom panel — packing equals covering on the extremal configuration: m knees spaced
               delta+1 apart need exactly m entries, matching both the greedy bound
               floor((b-a)/(delta+1)) + 1 and the pigeonhole lower bound.

Run:  python3 viz_cover.py       (writes entry_cover.png)
"""

from __future__ import annotations

from typing import Iterable, List

import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

DOMAINS = [("prose", 16, "#2b6cb0"), ("code", 12, "#2f855a"),
           ("mathematics", 16, "#dd6b20")]


def serves(delta: int, b: int, k: int) -> bool:
    return k <= b <= k + delta


def greedy_entries(knees: Iterable[int], delta: int) -> List[int]:
    remaining = sorted(set(knees), reverse=True)
    entries: List[int] = []
    while remaining:
        b = remaining[0]
        entries.append(b)
        remaining = [k for k in remaining if not serves(delta, b, k)]
    return entries


def max_separated(knees: Iterable[int], delta: int) -> List[int]:
    chosen: List[int] = []
    for k in sorted(set(knees)):
        if not chosen or chosen[-1] + delta < k:
            chosen.append(k)
    return chosen


def ap_knees(delta: int, a: int, m: int) -> List[int]:
    return [a + (delta + 1) * i for i in range(m)]


def main() -> None:
    fig, (ax, bx) = plt.subplots(2, 1, figsize=(12, 8.6))

    deltas = range(0, 7)
    for row, delta in enumerate(deltas):
        y0 = row * 3.0
        entries = greedy_entries([16, 12], delta)
        for j, (name, k, col) in enumerate(DOMAINS):
            y = y0 + 0.7 * j
            ax.add_patch(Rectangle((k, y - 0.25), max(delta, 0.18), 0.5,
                                   facecolor=col, alpha=0.28, edgecolor=col, lw=1.3))
            ax.plot([k], [y], "o", ms=5, color=col)
        for b in entries:
            ax.plot([b, b], [y0 - 0.5, y0 + 1.9], color="#6b21a8", lw=1.6, ls="--")
            ax.plot([b], [y0 + 2.05], "v", color="#6b21a8", ms=7)
        ax.text(9.0, y0 + 0.7, rf"$\delta={delta}$", fontsize=11, ha="right",
                va="center", fontweight="bold")
        ax.text(24.5, y0 + 0.7,
                f"{len(entries)} entr{'y' if len(entries) == 1 else 'ies'}: "
                f"{entries}",
                fontsize=10, va="center",
                color="#6b21a8" if len(entries) == 1 else "#334155")

    ax.axhline(11.2, color="#6b21a8", lw=1.2)
    ax.text(20.2, 11.4, "threshold: at δ = 4 the fleet collapses to the single entry 16",
            fontsize=10, color="#6b21a8")
    ax.set_xlim(9, 31)
    ax.set_ylim(-1, 21.5)
    ax.set_yticks([])
    ax.set_xlabel("cache-size entry $b$")
    ax.set_title("Measured knee set {12, 16}: domains as intervals $[k,\\,k+\\delta]$, "
                 "entries as points hitting them")
    ax.grid(axis="x", alpha=0.25)
    for name, k, col in DOMAINS:
        ax.plot([], [], "s", color=col, alpha=0.5, label=f"{name} (knee {k})")
    ax.legend(loc="upper center", ncol=3, fontsize=9)

    ms = list(range(1, 9))
    for delta in (0, 2, 4):
        cover = [len(greedy_entries(ap_knees(delta, 5, m), delta)) for m in ms]
        pack = [len(max_separated(ap_knees(delta, 5, m), delta)) for m in ms]
        bx.plot(ms, cover, "o-", lw=2, label=f"greedy cover, δ={delta}")
        bx.plot(ms, pack, "x--", lw=1.4, label=f"packing bound, δ={delta}")
    bx.plot(ms, ms, color="#94a3b8", lw=1, ls=":", label="$m$ (exact minimum)")
    bx.set_xlabel("number $m$ of knees in arithmetic progression of step $\\delta+1$")
    bx.set_ylabel("entries")
    bx.set_title("Packing meets covering: on the extremal configuration the minimum "
                 "is exactly $m$")
    bx.grid(alpha=0.25)
    bx.legend(fontsize=8, ncol=3)

    fig.tight_layout()
    fig.savefig("entry_cover.png", dpi=160)
    print("wrote entry_cover.png")


if __name__ == "__main__":
    main()


"""Visualisation: the three-domain sweeps, their knees, and the accuracy gap.

Left panel  — retained-agreement curves against key budget, with the gate line and
              the knee marker for each domain, plus the shaded admissible gate
              window on which the mathematics knee is provably 16.
Right panel — full-model accuracy per domain, showing the ~12-point gap that buys
              exactly zero extra keys.

Run:  python3 viz_sweeps.py      (writes knee_sweeps.png)
"""

from __future__ import annotations

from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
import numpy as np

# Mathematics: the measured sweep, monotone hull applied (the 0.988 dip at budget 24
# sits inside one standard error of the 0.989 at budget 20).
# Prose and code: illustrative profiles consistent with their measured knees (16 and
# 12); only their knees, not their full sweeps, enter the results.
SWEEPS: Dict[str, List[Tuple[int, float]]] = {
    "mathematics": [(4, 0.907), (8, 0.959), (12, 0.979), (16, 0.987),
                    (20, 0.989), (24, 0.989)],
    "prose": [(4, 0.912), (8, 0.962), (12, 0.980), (16, 0.988),
              (20, 0.990), (24, 0.990)],
    "code": [(4, 0.930), (8, 0.972), (12, 0.985), (16, 0.991),
             (20, 0.992), (24, 0.992)],
}
KNEES: Dict[str, int] = {"prose": 16, "code": 12, "mathematics": 16}
ACCURACY: Dict[str, float] = {"prose": 0.4460, "mathematics": 0.3262}
COLOR: Dict[str, str] = {"prose": "#2b6cb0", "code": "#2f855a", "mathematics": "#dd6b20"}

GATE = 0.981          # any gate in the overlap window (0.979, 0.983]
WINDOW = (0.979, 0.987)  # admissible gate window for the mathematics cell at ctx 512


def step_curve(sweep: List[Tuple[int, float]]) -> Tuple[np.ndarray, np.ndarray]:
    ks = np.arange(0, 27)
    vals = np.zeros_like(ks, dtype=float)
    for i, k in enumerate(ks):
        v = 0.0
        for b, a in sweep:
            if k >= b:
                v = max(v, a)
        vals[i] = v
    return ks, vals


def main() -> None:
    fig, (ax, bx) = plt.subplots(
        1, 2, figsize=(13, 5.2), gridspec_kw={"width_ratios": [2.2, 1.0]}
    )

    ax.axhspan(WINDOW[0], WINDOW[1], color="#c77dff", alpha=0.10,
               label="admissible gate window (0.979, 0.987]")
    for name, sweep in SWEEPS.items():
        ks, vs = step_curve(sweep)
        ax.step(ks, vs, where="post", lw=2.2, color=COLOR[name], label=name)
        k = KNEES[name]
        a = float(vs[k])
        ax.plot([k], [a], "o", ms=9, color=COLOR[name], zorder=5)
        off = {"prose": (9, 8), "mathematics": (9, -20), "code": (-46, -20)}[name]
        ax.annotate(f"k* = {k}", (k, a), textcoords="offset points",
                    xytext=off, color=COLOR[name], fontweight="bold")

    ax.axhline(GATE, ls="--", lw=1.4, color="#6b21a8")
    ax.text(0.4, GATE + 0.0012, f"gate g = {GATE}", color="#6b21a8", fontsize=10)
    ax.set_xlim(0, 26)
    ax.set_ylim(0.90, 1.0)
    ax.set_xlabel("key budget $k$")
    ax.set_ylabel("retained agreement $A(k)$")
    ax.set_title("Budget–quality sweeps at context 512: prose and mathematics "
                 "knee at the same 16")
    ax.grid(alpha=0.25)
    ax.legend(loc="lower right", fontsize=9)

    names = list(ACCURACY)
    bx.bar(names, [ACCURACY[n] for n in names],
           color=[COLOR[n] for n in names], alpha=0.85)
    for n in names:
        bx.text(n, ACCURACY[n] + 0.006, f"{ACCURACY[n]:.4f}",
                ha="center", fontsize=10, fontweight="bold")
    gap = ACCURACY["prose"] - ACCURACY["mathematics"]
    bx.annotate("", xy=(0.62, ACCURACY["mathematics"]), xytext=(0.62, ACCURACY["prose"]),
                arrowprops=dict(arrowstyle="<->", color="#6b21a8", lw=1.6))
    bx.text(0.66, (ACCURACY["prose"] + ACCURACY["mathematics"]) / 2,
            f"gap = {gap:.4f}\n(0 extra keys)", color="#6b21a8", fontsize=10,
            va="center")
    bx.set_ylim(0, 0.55)
    bx.set_ylabel("full-model accuracy")
    bx.set_title("Difficulty differs by ~12 points")
    bx.grid(axis="y", alpha=0.25)

    fig.suptitle("Accuracy is a mean; the knee is a quantile — they do not move "
                 "together", fontsize=13)
    fig.tight_layout()
    fig.savefig("knee_sweeps.png", dpi=160)
    print("wrote knee_sweeps.png")


if __name__ == "__main__":
    main()


"""
demo.py — Numerical demonstrations of the demand-multiset calculus for
budget-quality curves, and of the interval-cover theory of deployment entries.

Self-contained: standard library only. Run with `python3 demo.py`.

Contents
--------
1. Workloads, agreement curves, knees, accuracy.
2. The measured three-domain panel: knees 16 / 12 / 16, the 12-point accuracy gap,
   the admissible gate windows, and the +4 context increment.
3. Multiset invariance and full decoupling (surjectivity of (knee, accuracy)).
4. The quantile identity: knee = ceil(g*n)-th smallest demand.
5. The exact tail criterion, the Markov relaxation, and perturbation robustness.
6. Reparametrisation invariance, rigid shift, corpus mixing.
7. Deployment entries: single-entry criterion, greedy cover, packing bound,
   min-max duality, and the exact tolerance threshold delta = 4.
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Dict, Iterable, List, Sequence, Tuple

Rat = Fraction

# ----------------------------------------------------------------------------
# 1. Core objects
# ----------------------------------------------------------------------------


class Workload:
    """A finite family of prediction positions.

    demands[i]  : least key budget at which the truncated predictor reproduces
                  the full predictor's output at position i.
    correct[i]  : whether the *full* predictor is correct at position i.
    """

    def __init__(self, demands: Sequence[int], correct: Sequence[bool]) -> None:
        if len(demands) != len(correct):
            raise ValueError("demands and correct must have equal length")
        if len(demands) == 0:
            raise ValueError("workload must be nonempty")
        self.demands: List[int] = list(demands)
        self.correct: List[bool] = list(correct)

    @property
    def n(self) -> int:
        return len(self.demands)

    def agree_count(self, k: int) -> int:
        """Number of positions served by budget k."""
        return sum(1 for r in self.demands if r <= k)

    def agree(self, k: int) -> Rat:
        """Retained-agreement curve A(k) = #{i : r_i <= k} / n."""
        return Rat(self.agree_count(k), self.n)

    def tail(self, k: int) -> int:
        """Number of positions still unserved at budget k."""
        return self.n - self.agree_count(k)

    def accuracy(self) -> Rat:
        """Full-model accuracy: fraction of positions predicted correctly."""
        return Rat(sum(1 for c in self.correct if c), self.n)

    def demand_multiset(self) -> Tuple[int, ...]:
        """The sorted demand multiset — the only thing the sweep sees."""
        return tuple(sorted(self.demands))

    def knee(self, gate: Rat) -> int:
        """Least budget k with A(k) >= gate."""
        for k in range(max(self.demands) + 1):
            if self.agree(k) >= gate:
                return k
        return max(self.demands)

    def demand_quantile(self, m: int) -> int:
        """The m-th smallest demand (m counted from 1)."""
        return sorted(self.demands)[m - 1]


def flat_workload(n: int, k: int, j: int) -> Workload:
    """Every position demands exactly k keys; exactly j positions are correct."""
    return Workload([k] * n, [i < j for i in range(n)])


# ----------------------------------------------------------------------------
# 2. The measured three-domain panel
# ----------------------------------------------------------------------------

MATH_SWEEP_512: Dict[int, Rat] = {
    4: Rat(907, 1000), 8: Rat(959, 1000), 12: Rat(979, 1000),
    16: Rat(987, 1000), 20: Rat(989, 1000), 24: Rat(988, 1000),
}

MATH_SWEEP_1024: Dict[int, Rat] = {
    8: Rat(952, 1000), 12: Rat(965, 1000), 16: Rat(978, 1000),
    20: Rat(983, 1000), 24: Rat(985, 1000),
}

ACC = {
    ("prose", 512): Rat(4460, 10000),
    ("math", 512): Rat(3262, 10000),
    ("prose", 1024): Rat(4612, 10000),
    ("math", 1024): Rat(3418, 10000),
}

KNEES_512 = {"prose": 16, "code": 12, "math": 16}
KNEES_1024 = {"prose": 20, "math": 20}


def monotone_hull(sweep: Dict[int, Rat]) -> Dict[int, Rat]:
    """Running maximum: repairs within-standard-error dips (e.g. 24 -> .988)."""
    out: Dict[int, Rat] = {}
    best = Rat(0)
    for k in sorted(sweep):
        best = max(best, sweep[k])
        out[k] = best
    return out


def knee_from_sweep(sweep: Dict[int, Rat], gate: Rat) -> int:
    """Least swept budget clearing the gate (Algorithm A)."""
    hull = monotone_hull(sweep)
    for k in sorted(hull):
        if hull[k] >= gate:
            return k
    raise ValueError("gate never reached in this sweep")


def admissible_gate_window(sweep: Dict[int, Rat], knee: int) -> Tuple[Rat, Rat]:
    """Open-closed interval of gates yielding exactly this knee (Algorithm B)."""
    hull = monotone_hull(sweep)
    ks = sorted(hull)
    idx = ks.index(knee)
    lower = hull[ks[idx - 1]] if idx > 0 else Rat(0)
    return lower, hull[knee]


def demo_measured_panel() -> None:
    print("=" * 78)
    print("2. THE MEASURED THREE-DOMAIN PANEL")
    print("=" * 78)

    lo512, hi512 = admissible_gate_window(MATH_SWEEP_512, 16)
    lo1024, hi1024 = admissible_gate_window(MATH_SWEEP_1024, 20)
    print(f"math @512  : knee 16 for every gate in ({float(lo512)}, {float(hi512)}]")
    print(f"math @1024 : knee 20 for every gate in ({float(lo1024)}, {float(hi1024)}]")

    overlap_lo, overlap_hi = max(lo512, lo1024), min(hi512, hi1024)
    print(f"overlap    : ({float(overlap_lo)}, {float(overlap_hi)}] "
          "-> one gate certifies both cells")

    g = (overlap_lo + overlap_hi) / 2
    k512 = knee_from_sweep(MATH_SWEEP_512, g)
    k1024 = knee_from_sweep(MATH_SWEEP_1024, g)
    print(f"\nat the common gate g = {float(g):.4f}:")
    print(f"  math knee @512  = {k512}   prose knee @512  = {KNEES_512['prose']}"
          f"   equal: {k512 == KNEES_512['prose']}")
    print(f"  math knee @1024 = {k1024}   prose knee @1024 = {KNEES_1024['prose']}"
          f"   equal: {k1024 == KNEES_1024['prose']}")
    print(f"  context increment 512 -> 1024: +{k1024 - k512} (prose: "
          f"+{KNEES_1024['prose'] - KNEES_512['prose']})")

    gap512 = ACC[("prose", 512)] - ACC[("math", 512)]
    gap1024 = ACC[("prose", 1024)] - ACC[("math", 1024)]
    print(f"\naccuracy gap @512  : {float(ACC[('prose',512)])} - "
          f"{float(ACC[('math',512)])} = {float(gap512)}")
    print(f"accuracy gap @1024 : {float(ACC[('prose',1024)])} - "
          f"{float(ACC[('math',1024)])} = {float(gap1024)}")
    print("verdict: identical budgets, ~12 points of extra difficulty. "
          "P1 refuted, P3 confirmed.")

    print("\nthree-domain table @512:", KNEES_512,
          "-> distinct entries", sorted(set(KNEES_512.values())))


# ----------------------------------------------------------------------------
# 3. Multiset invariance and full decoupling
# ----------------------------------------------------------------------------


def demo_invariance_and_decoupling() -> None:
    print("\n" + "=" * 78)
    print("3. MULTISET INVARIANCE AND FULL DECOUPLING")
    print("=" * 78)

    demands = [3, 3, 7, 7, 7, 11, 16, 16, 16, 16]
    easy = Workload(demands, [True] * 9 + [False])
    hard = Workload(list(reversed(demands)), [False] * 9 + [True])

    print("same demand multiset:", easy.demand_multiset() == hard.demand_multiset())
    print("accuracies:", float(easy.accuracy()), "vs", float(hard.accuracy()))
    gates = [Rat(1, 2), Rat(7, 10), Rat(9, 10), Rat(1)]
    same = all(easy.knee(g) == hard.knee(g) for g in gates)
    for g in gates:
        print(f"  gate {float(g):.2f}: knee {easy.knee(g)} vs {hard.knee(g)}")
    print("knees identical at every gate:", same)

    print("\nsurjectivity of (knee, accuracy): flat workloads realise every pair")
    n = 20
    for k, j in [(3, 0), (3, 20), (16, 7), (16, 19), (41, 10)]:
        W = flat_workload(n, k, j)
        knees = {W.knee(Rat(t, 20)) for t in range(1, 21)}
        print(f"  flat(n={n}, k={k:2d}, j={j:2d}): knee(s) over all gates = {knees}"
              f", accuracy = {float(W.accuracy())}")


# ----------------------------------------------------------------------------
# 4. The quantile identity
# ----------------------------------------------------------------------------


def demo_quantile_identity() -> None:
    print("\n" + "=" * 78)
    print("4. THE KNEE IS AN ORDER STATISTIC:  knee = ceil(g*n)-th smallest demand")
    print("=" * 78)

    demands = [1, 2, 2, 4, 5, 5, 8, 9, 13, 21, 21, 34, 40, 44, 60, 60, 71, 88, 95, 99]
    W = Workload(demands, [i % 3 != 0 for i in range(len(demands))])
    print("demands (sorted):", sorted(demands))
    print(f"{'gate':>6} {'ceil(g n)':>10} {'knee':>6} {'quantile':>9} {'match':>6}")
    for num in (5, 10, 15, 18, 19, 20):
        g = Rat(num, 20)
        m = math.ceil(g * W.n)
        print(f"{float(g):>6.2f} {m:>10} {W.knee(g):>6} {W.demand_quantile(m):>9}"
              f" {str(W.knee(g) == W.demand_quantile(m)):>6}")


# ----------------------------------------------------------------------------
# 5. Tail criterion, Markov bound, robustness
# ----------------------------------------------------------------------------


def demo_tail_markov_robustness() -> None:
    print("\n" + "=" * 78)
    print("5. TAIL CRITERION, MARKOV BOUND, PERTURBATION ROBUSTNESS")
    print("=" * 78)

    n = 1000
    demands = [4] * 900 + [12] * 70 + [16] * 20 + [40] * 10
    W = Workload(demands, [i < 326 for i in range(n)])
    g = Rat(98, 100)

    print("exact gate criterion  A(k) >= g  <=>  tail(k) <= (1-g)*n")
    slack = (1 - g) * n
    for k in (4, 12, 16, 40):
        lhs = W.agree(k) >= g
        rhs = W.tail(k) <= slack
        print(f"  k={k:>2}: A(k)={float(W.agree(k)):.3f}  tail={W.tail(k):>3}"
              f"  slack={float(slack):.1f}  clears={lhs}  criterion={rhs}"
              f"  agree={lhs == rhs}")
    print(f"  => knee at gate {float(g)} is {W.knee(g)}")

    total = sum(demands)
    mean_demand = Rat(total, n)
    print(f"\nMarkov bridge:  sum(demands) <= (1-g)*n*(k+1)  =>  knee <= k")
    print(f"  sum(demands) = {total}, mean demand = {float(mean_demand):.3f}")
    for gg in (Rat(98, 100), Rat(90, 100), Rat(1, 2)):
        least = next(kk for kk in range(0, 20000)
                     if total <= (1 - gg) * n * (kk + 1))
        print(f"  gate {float(gg):.2f}: Markov certifies knee <= {least:>4}"
              f"   (actual knee {W.knee(gg):>2};"
              f" mean/(1-g) = {float(mean_demand / (1 - gg)):.1f})")
    print("  the bound is one-sided and loose, but needs only the mean demand:"
          " a thin tail suffices for a small budget.")

    print("\nperturbation robustness: worsen the hardest positions arbitrarily")
    perturbed = [d if d <= 16 else 5000 for d in demands]
    P = Workload(perturbed, [i < 100 for i in range(n)])
    print(f"  accuracy dropped {float(W.accuracy())} -> {float(P.accuracy())}")
    print(f"  demands of {sum(1 for a,b in zip(demands, perturbed) if a != b)}"
          " positions blown up to 5000")
    print(f"  knee unchanged: {W.knee(g)} -> {P.knee(g)}")


# ----------------------------------------------------------------------------
# 6. Reparametrisation, rigid shift, mixing
# ----------------------------------------------------------------------------


def demo_invariances() -> None:
    print("\n" + "=" * 78)
    print("6. REPARAMETRISATION, RIGID SHIFT, CORPUS MIXING")
    print("=" * 78)

    hull = monotone_hull(MATH_SWEEP_512)
    g = Rat(982, 1000)

    def psi(x: Rat) -> Rat:
        """A strictly monotone distortion of the quality axis."""
        return 3 * x - Rat(1, 7)

    distorted = {k: psi(v) for k, v in hull.items()}
    print(f"knee of raw sweep at gate {float(g)}      : "
          f"{knee_from_sweep(hull, g)}")
    print(f"knee of distorted sweep at psi(gate) : "
          f"{knee_from_sweep(distorted, psi(g))}")

    delta = 4
    shifted = {k + delta: v for k, v in hull.items()}
    print(f"\nrigid shift by +{delta}: knee {knee_from_sweep(hull, g)} -> "
          f"{knee_from_sweep(shifted, g)}")

    prose = {k: (Rat(0) if k < 16 else Rat(1)) for k in sorted(hull)}
    print("\ncorpus mixing (prose knee 16, math knee 16):")
    for num in (0, 1, 3, 7, 10):
        theta = Rat(num, 10)
        mixed = {k: theta * prose[k] + (1 - theta) * hull[k] for k in sorted(hull)}
        print(f"  theta={float(theta):.1f}: mixed knee = {knee_from_sweep(mixed, g)}")


# ----------------------------------------------------------------------------
# 7. Deployment entries as an interval point cover
# ----------------------------------------------------------------------------


def serves(delta: int, b: int, k: int) -> bool:
    """Entry b serves knee k at waste tolerance delta."""
    return k <= b <= k + delta


def single_entry_possible(knees: Iterable[int], delta: int) -> bool:
    ks = list(knees)
    return max(ks) <= min(ks) + delta


def greedy_entries(knees: Iterable[int], delta: int) -> List[int]:
    """Top-anchored greedy: optimal minimum entry set (Algorithm C)."""
    remaining = sorted(set(knees), reverse=True)
    entries: List[int] = []
    while remaining:
        b = remaining[0]
        entries.append(b)
        remaining = [k for k in remaining if not serves(delta, b, k)]
    return entries


def max_separated_subset(knees: Iterable[int], delta: int) -> List[int]:
    """A maximum delta-separated subset — the packing certificate."""
    chosen: List[int] = []
    for k in sorted(set(knees)):
        if not chosen or chosen[-1] + delta < k:
            chosen.append(k)
    return chosen


def ap_knees(delta: int, a: int, m: int) -> List[int]:
    """Extremal configuration: m knees spaced exactly delta+1 apart."""
    return [a + (delta + 1) * i for i in range(m)]


def demo_deployment_cover() -> None:
    print("\n" + "=" * 78)
    print("7. DEPLOYMENT ENTRIES AS AN INTERVAL POINT COVER")
    print("=" * 78)

    net70 = [12, 16]
    print("measured knee set {12, 16} (prose 16, code 12, math 16), spread 4")
    for delta in range(0, 7):
        ok = single_entry_possible(net70, delta)
        E = greedy_entries(net70, delta)
        S = max_separated_subset(net70, delta)
        print(f"  delta={delta}: one entry? {str(ok):>5}   greedy cover {E}"
              f"   packing bound {len(S)}   minimum {len(E)}")
    print("  => exact threshold delta = 4 (one scale increment): the whole fleet"
          " collapses to entry 16")

    print("\nmin-max duality on the extremal configuration (packing = covering):")
    for delta, m in [(3, 4), (4, 3), (0, 5), (7, 6)]:
        K = ap_knees(delta, 5, m)
        E = greedy_entries(K, delta)
        S = max_separated_subset(K, delta)
        upper = (max(K) - min(K)) // (delta + 1) + 1
        print(f"  delta={delta}, m={m}: knees {K}")
        print(f"      greedy cover size {len(E)}, packing bound {len(S)},"
              f" formula floor((b-a)/(delta+1))+1 = {upper}, m = {m}"
              f"  -> all equal: {len(E) == len(S) == upper == m}")

    print("\nrandomised check that greedy is exactly optimal (packing == covering):")
    rng_state = 12345
    worst = 0
    for trial in range(200):
        rng_state = (1103515245 * rng_state + 12345) % (2 ** 31)
        delta = rng_state % 6
        size = 2 + (rng_state // 7) % 8
        K = sorted({(rng_state // (i + 3)) % 60 for i in range(size)})
        cover = len(greedy_entries(K, delta))
        pack = len(max_separated_subset(K, delta))
        worst = max(worst, cover - pack)
    print(f"  200 random knee sets: max(cover - packing) = {worst}"
          "  (0 means greedy is optimal everywhere)")


# ----------------------------------------------------------------------------
# 8. Realisation of the measured profile
# ----------------------------------------------------------------------------


def demo_realisation() -> None:
    print("\n" + "=" * 78)
    print("8. THE MEASURED STEP PROFILE IS REALISED BY AN HONEST WORKLOAD")
    print("=" * 78)

    n = 10000

    def t512(k: int) -> int:
        if k < 4:
            return 0
        if k < 8:
            return 9070
        if k < 12:
            return 9590
        if k < 16:
            return 9790
        if k < 20:
            return 9870
        if k < 512:
            return 9890
        return 10000

    # Build the workload directly from the profile's inverse (fast form).
    demands: List[int] = []
    steps = [(4, 9070), (8, 9590), (12, 9790), (16, 9870), (20, 9890), (512, 10000)]
    prev = 0
    for k, cum in steps:
        demands.extend([k] * (cum - prev))
        prev = cum
    W = Workload(demands, [i < 3262 for i in range(n)])

    print("agree counts match the measured profile at every swept budget:",
          all(W.agree_count(k) == t512(k) for k in (0, 3, 4, 7, 8, 11, 12,
                                                    15, 16, 19, 20, 511, 512)))
    print("accuracy:", float(W.accuracy()), "(measured 0.3262)")
    for num in (9795, 9800, 9850, 9870):
        g = Rat(num, 10000)
        print(f"  gate {float(g):.4f}: knee = {W.knee(g)}")
    print("knee = 16 across the whole admissible window (0.9790, 0.9870].")


# ----------------------------------------------------------------------------


def main() -> None:
    print("MATHEMATICS READS AS PROSE — numerical demonstrations")
    demo_measured_panel()
    demo_invariance_and_decoupling()
    demo_quantile_identity()
    demo_tail_markov_robustness()
    demo_invariances()
    demo_deployment_cover()
    demo_realisation()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
