"""
Algorithm: exact effective dimension of a divisibility cell sweep.
==================================================================

Given a finite set P of distinct primes, a "cell sweep" evaluates one statistic
per divisibility cell, i.e. 2^|P| statistics.  This is the wrong number to use
in a max-statistic selection correction, for two reasons that the algorithm below
makes exact:

  * the rate of the cell with required set T is kappa_T = prod_{p not in T}(p-1),
    so the prime 2 contributes a factor 2 - 1 = 1 and is a DEAD COORDINATE;
  * distinct odd subsets can still collide, e.g. (3-1)(7-1) = 12 = 13-1.

Hence the number of genuinely distinct rate statistics is

    #K(P) = #{ prod_{p in S} (p-1) : S subset of P \\ {2} }  <=  2^(|P|-1),

with equality exactly when {p-1 : p odd in P} is a MULTIPLICATIVE SIDON SYSTEM
(pairwise distinct subset products).  All rates divide phi(L), so the sweep
explores a sub-family of a single divisor lattice rather than free values.

Complexity: enumerating the 2^k subsets of the k odd primes and hashing their
products costs O(2^k * k) integer multiplications and O(2^k) memory; the
collision report costs the same.  For the k <= 20 relevant to any realistic
sweep this is milliseconds.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from itertools import combinations
from math import log, prod, sqrt
from typing import Dict, FrozenSet, List, Tuple


@dataclass
class SweepReport:
    """Complete effective-dimension analysis of a divisibility cell sweep."""

    primes: Tuple[int, ...]
    period: int
    totient: int
    n_cells: int
    n_distinct_rates: int
    upper_bound: int
    is_multiplicative_sidon: bool
    rates: Dict[FrozenSet[int], int] = field(default_factory=dict)
    collisions: List[Tuple[int, List[FrozenSet[int]]]] = field(default_factory=list)

    @property
    def naive_selection_drift(self) -> float:
        """E[max of n iid standard normals] ~ sqrt(2 log n), naive count."""
        return sqrt(2.0 * log(self.n_cells)) if self.n_cells > 1 else 0.0

    @property
    def effective_selection_drift(self) -> float:
        """The same quantity computed with the honest effective count."""
        n = self.n_distinct_rates
        return sqrt(2.0 * log(n)) if n > 1 else 0.0


def cell_rate(primes: Tuple[int, ...], required: FrozenSet[int]) -> int:
    """kappa_T = product of (p - 1) over the CLEARED primes of P."""
    return prod((1 if p in required else p - 1) for p in primes)


def analyse_sweep(primes: Tuple[int, ...]) -> SweepReport:
    """Compute the exact effective dimension of the cell sweep over `primes`.

    Steps
    -----
    1. Enumerate all 2^|P| required-divisor sets T and their rates kappa_T.
    2. Group the rates by value to expose collisions; the number of groups is
       the effective dimension #K(P).
    3. Compute the theoretical bound 2^|P \\ {2}| and test the multiplicative
       Sidon criterion, which holds iff bound == effective dimension.
    """
    primes = tuple(sorted(set(primes)))
    odd = tuple(p for p in primes if p != 2)

    rates: Dict[FrozenSet[int], int] = {}
    for k in range(len(primes) + 1):
        for combo in combinations(primes, k):
            T = frozenset(combo)
            rates[T] = cell_rate(primes, T)

    by_value: Dict[int, List[FrozenSet[int]]] = {}
    for T, value in rates.items():
        by_value.setdefault(value, []).append(T)

    # Genuine collisions: two cells whose odd required-parts differ but whose
    # rates nevertheless agree.  Dead-2 duplicates are filtered out.
    collisions: List[Tuple[int, List[FrozenSet[int]]]] = []
    for value, cells in sorted(by_value.items()):
        odd_parts = {frozenset(T & set(odd)) for T in cells}
        if len(odd_parts) > 1:
            collisions.append((value, sorted(odd_parts, key=lambda s: sorted(s))))

    bound = 2 ** len(odd)
    distinct = len(by_value)

    return SweepReport(
        primes=primes,
        period=prod(primes),
        totient=prod(p - 1 for p in primes),
        n_cells=2 ** len(primes),
        n_distinct_rates=distinct,
        upper_bound=bound,
        is_multiplicative_sidon=(distinct == bound),
        rates=rates,
        collisions=collisions,
    )


def format_report(report: SweepReport) -> str:
    lines: List[str] = []
    P = "{" + ", ".join(map(str, report.primes)) + "}"
    lines.append(f"P = {P}   L = {report.period}   phi(L) = {report.totient}")
    lines.append(f"  cells swept                : {report.n_cells}")
    lines.append(f"  distinct rate statistics   : {report.n_distinct_rates}")
    lines.append(f"  theoretical maximum        : {report.upper_bound}")
    lines.append(f"  multiplicative Sidon       : {report.is_multiplicative_sidon}")
    lines.append(
        f"  all rates divide phi(L)    : "
        f"{all(report.totient % r == 0 for r in report.rates.values())}"
    )
    lines.append(
        f"  selection drift  naive/eff : "
        f"{report.naive_selection_drift:.3f} / {report.effective_selection_drift:.3f} sigma"
    )
    for value, odd_parts in report.collisions:
        pretty = "  ~  ".join(
            "{" + ",".join(map(str, sorted(s))) + "}" if s else "\u2205" for s in odd_parts
        )
        lines.append(f"  COLLISION at rate {value}: {pretty}")
    return "\n".join(lines)


if __name__ == "__main__":
    for candidate in [
        (2, 3, 5, 7),
        (3, 7, 13),
        (2, 3, 7, 13),
        (3, 5, 7, 11),
        (2, 3, 5, 7, 11, 13),
    ]:
        print(format_report(analyse_sweep(candidate)))
        print()


"""Assemble PACKAGE.json from the individual deliverable files."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")


article = read(ROOT / "ARTICLE.md")
paper_md = read(ROOT / "RESEARCH_PAPER.md")
paper_tex = read(ROOT / "RESEARCH_PAPER.tex")
demo = read(ROOT / "demo.py")
viz = read(A / "viz_rate_dial.py")
algo = read(A / "algo_sweep_dimension.py")
widget = read(A / "widget_dial_lab.html")

lean_files = [
    "Catalog/Combinatorics/KappaRateDial.lean",
    "Catalog/Combinatorics/KappaDialRefinement.lean",
]
lean_proofs = "\n\n".join(
    f"-- ===== {f} =====\n\n" + read(ROOT / f) for f in lean_files
)

future_directions = read(A / "future_directions.md")
interactive_layout = read(A / "interactive_layout.md")

package = {
    "title": "Divisibility Cells as Rate Dials: Exact Counting, Coprime-Scale "
             "Independence, and the Effective Dimension of a Cell Sweep",
    # The concept domain is combinatorics; within the allowed vocabulary the
    # closest fit for this elementary-number-theory counting work is Algebra.
    "domain": "Algebra",
    "description": (
        "For a finite set P of primes with period L = prod(P), the divisibility cell of a "
        "signature contains exactly kappa = prod (1 or p-1) residues per period and is exactly "
        "independent of every observable measurable at a scale coprime to L; consequently "
        "divisibility acts as an exact multiplicative rate dial with an identically flat "
        "positional profile, and a sweep across all 2^|P| cells tests at most 2^(|P|-1) "
        "genuinely distinct statistics."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-26",
    "key_results": [
        "Exact rate law: the divisibility cell of a signature sigma contains exactly "
        "kappa(sigma) = prod over p in P of (1 if p is required to divide, else p-1) residues "
        "in every period L = prod(P), hence exactly m*kappa(sigma) integers in any window of m "
        "whole periods.",
        "Coprime-statistic no-go theorem: for every modulus M coprime to L and every predicate "
        "depending only on the residue mod M, the divisibility cell and the predicate are "
        "exactly independent over one common period; in particular every residue class mod M "
        "receives exactly kappa(sigma) cell members, so the positional profile is identically "
        "flat rather than merely unreplicated.",
        "Valuation ladder: refining divisibility to exact p-adic valuation v_p(v) = e_p yields, "
        "over the refined period prod p^(e_p+1), a cell of size exactly prod (p-1) independently "
        "of the exponents, so the density is the pure geometric expression "
        "prod p^(-e_p)(1 - 1/p).",
        "Structure of the dial: every cell rate divides Euler's totient phi(L), the rates sum "
        "over all cells to L, the extremes 1 and phi(L) are attained exactly by the all-required "
        "and all-cleared cells, and the prime 2 is a dead coordinate whose signature bit never "
        "changes a rate.",
        "Effective sweep dimension: a sweep over all 2^|P| divisibility cells explores at most "
        "2^(|P|-1) distinct rate values when 2 is in P, with equality precisely when the shifted "
        "primes p-1 over the odd primes of P have pairwise distinct subset products; the "
        "criterion is non-vacuous, since (3-1)(7-1) = 13-1 collapses two cells of P = {3,7,13}.",
    ],
    "keywords": [
        "divisibility cells",
        "Chinese Remainder Theorem",
        "Euler totient",
        "p-adic valuation",
        "equidistribution",
        "multiplicative Sidon set",
        "max-statistic selection",
        "exact counting",
    ],
    "article": article,
    "research_paper": paper_md,
    "research_paper_tex": paper_tex,
    "demo": demo,
    "demos": [
        {
            "name": "Exhaustive Verification of the Rate Law, Positional Flatness, "
                    "Coprime Independence, and the Valuation Ladder",
            "description": (
                "A self-contained enumeration suite that checks every exact statement of the "
                "theory by brute force. It tabulates all 2^|P| cell rates for P = {2,3,5,7} and "
                "confirms each against a direct count over [0,210); verifies that the rates sum "
                "to the period, all divide phi(210) = 48, and span exactly [1, 48]; counts three "
                "cells in twenty consecutive period blocks and asserts zero drift; instantiates "
                "the coprime-statistic no-go theorem at M = 11 for three genuinely different "
                "statistics (quadratic residuacity, a half-interval indicator, primality of the "
                "residue) and for all eleven residue classes, each receiving exactly 48 members; "
                "enumerates valuation cells for exponent vectors up to (2,2) and confirms the "
                "count is frozen at prod (p-1); computes the effective sweep dimension for five "
                "prime sets and cross-checks the multiplicative Sidon criterion; and finally "
                "quantifies the selection drift sqrt(2 log n) of a max-over-cells statistic under "
                "the naive versus the honest count of tests."
            ),
            "code": demo,
        }
    ],
    "algorithms": [
        {
            "name": "Exact Effective Dimension of a Divisibility Cell Sweep via the "
                    "Multiplicative Sidon Criterion",
            "description": (
                "Given a finite set P of distinct primes, this algorithm computes the number of "
                "genuinely distinct statistics that a sweep over all 2^|P| divisibility cells "
                "performs. The mathematical foundation is the identity kappa_T = prod over the "
                "cleared primes p in P \\ T of (p - 1): since 2 - 1 = 1, the prime 2 is a dead "
                "coordinate, so the reachable rates are exactly the subset products of the "
                "shifted odd primes; the count of distinct rates therefore equals 2^|P \\ {2}| "
                "precisely when those subset products are pairwise distinct, i.e. when the "
                "shifted odd primes form a multiplicative Sidon system. The algorithm enumerates "
                "the 2^|P| required-divisor sets, computes each rate, groups by value to expose "
                "collisions, reports the bound and the Sidon verdict, verifies that every rate "
                "divides Euler's totient of the period, and converts the naive and honest test "
                "counts into the corresponding max-statistic selection drifts sqrt(2 log n). "
                "Complexity is O(2^k * k) integer multiplications and O(2^k) memory in the number "
                "k = |P \\ {2}| of odd primes, which is milliseconds for any realistic sweep."
            ),
            "pseudocode": (
                "INPUT:  a finite set P of distinct primes\n"
                "OUTPUT: effective dimension, bound, Sidon verdict, collisions, drift figures\n"
                "\n"
                " 1. P    <- sorted distinct primes of the input\n"
                " 2. odd  <- P minus {2};  L <- prod(P);  phi <- prod_{p in P} (p - 1)\n"
                " 3. rates <- empty map from required-set to integer\n"
                " 4. for each subset T of P:\n"
                " 5.       rates[T] <- prod_{p in P, p not in T} (p - 1)\n"
                " 6. byValue <- empty map from integer to list of required-sets\n"
                " 7. for each (T, k) in rates:  append T to byValue[k]\n"
                " 8. distinct <- |byValue|                       // effective dimension #K(P)\n"
                " 9. bound    <- 2^|odd|                          // theoretical maximum\n"
                "10. sidon    <- (distinct = bound)               // multiplicative Sidon test\n"
                "11. collisions <- empty list\n"
                "12. for each (k, cells) in byValue:\n"
                "13.       oddParts <- { T intersect odd : T in cells }\n"
                "14.       if |oddParts| > 1:  append (k, oddParts) to collisions\n"
                "15. assert every k in byValue divides phi          // divisor-lattice constraint\n"
                "16. driftNaive <- sqrt(2 * ln(2^|P|))\n"
                "17. driftEff   <- sqrt(2 * ln(distinct))\n"
                "18. return (distinct, bound, sidon, collisions, driftNaive, driftEff)"
            ),
            "code": algo,
        }
    ],
    "visualizations": [
        {
            "name": "Four Faces of the Divisibility Dial: Rates, Flatness, "
                    "Equidistribution, and the Valuation Ladder",
            "description": (
                "A four-panel figure for P = {2,3,5,7}, period L = 210. Panel (a) plots the "
                "sixteen cell rates sorted, with the extremes 1 and phi(L) = 48 marked; equal-"
                "height bars are exactly the pairs a sweep cannot distinguish. Panel (b) plots "
                "the count of three different cells in each of twenty consecutive period blocks: "
                "the lines are perfectly horizontal, which is the content of the exact flatness "
                "theorem. Panel (c) shows the members of the all-cleared cell in each residue "
                "class mod 11 inside [0, 2310): eleven bars, each of height exactly 48. Panel (d) "
                "plots the density of the 3-adic valuation cell against the resolution e on a "
                "log scale, exhibiting the perfect geometric ladder 2 * 3^-(e+1) whose numerator "
                "never moves."
            ),
            "code": viz,
        }
    ],
    "interactive_demos": [
        {
            "title": "The Divisibility Dial Laboratory",
            "description": (
                "A single-page laboratory in which the reader chooses the prime set P from "
                "{2,3,5,7,11,13} and watches every theorem of the paper recompute live by direct "
                "enumeration. It displays the period L, the top rate phi(L), and the full table "
                "of cell rates with a brute-force count beside each formula value, highlighting "
                "the rows whose rates collide. Selecting a cell drives three linked views: a bar "
                "chart of that cell's count in each successive period block, whose drift is "
                "reported and is always exactly zero; a coloured number-line strip with period "
                "rules, making the periodicity visible; and a bar chart of the cell's members in "
                "each residue class of a user-chosen modulus M coprime to L, every bar of "
                "identical height, which is the coprime-scale no-go theorem in action. A final "
                "panel computes the effective sweep dimension, states the multiplicative Sidon "
                "verdict, names the colliding patterns, and contrasts the naive with the honest "
                "max-statistic selection drift. Choosing P = {3,7,13} makes the collision "
                "(3-1)(7-1) = 13-1 appear on screen."
            ),
            "html": widget,
        }
    ],
    "interactive_layout": interactive_layout,
    "lean_proofs": lean_proofs,
    "future_directions": future_directions,
    "modules": {"demo": demo},
    "lean_files": lean_files,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size} bytes)")


"""
Visualization: the four faces of the divisibility dial.
=======================================================

Produces a single four-panel figure for P = {2, 3, 5, 7} (period L = 210):

  (a) THE RATE DIAL.  The sixteen cell rates kappa_T, sorted, with the extremes
      1 and phi(L) = 48 marked.  Bars sharing a height are cells that a sweep
      cannot distinguish; the visible plateaus are exactly the dead-2-coordinate
      pairs.

  (b) EXACT POSITIONAL FLATNESS.  Counts of three different cells in each of
      twenty consecutive blocks [mL, mL + L).  The lines are perfectly
      horizontal: the drift is identically zero, which is the content of the
      flatness theorem, not a statistical approximation.

  (c) COPRIME-SCALE EQUIDISTRIBUTION.  Members of the all-cleared cell in each
      residue class mod 11 inside [0, 2310).  Every bar has height exactly 48.

  (d) THE VALUATION LADDER.  Density of the 3-adic valuation cell {v_3(v) = e}
      against e, on a log scale: a perfect geometric ladder 2 * 3^-(e+1),
      because the numerator prod (p-1) is frozen under refinement.

Requires matplotlib.  Run:  python3 viz_rate_dial.py
"""

from __future__ import annotations

from itertools import combinations
from math import prod
from typing import Dict, FrozenSet, List, Sequence

import matplotlib.pyplot as plt

PRIMES: List[int] = [2, 3, 5, 7]
L: int = prod(PRIMES)
PHI: int = prod(p - 1 for p in PRIMES)


def kappa(primes: Sequence[int], required: FrozenSet[int]) -> int:
    return prod((1 if p in required else p - 1) for p in primes)


def in_cell(primes: Sequence[int], required: FrozenSet[int], v: int) -> bool:
    return all(((v % p == 0) == (p in required)) for p in primes)


def all_signatures(primes: Sequence[int]) -> List[FrozenSet[int]]:
    out: List[FrozenSet[int]] = []
    for k in range(len(primes) + 1):
        out.extend(frozenset(c) for c in combinations(primes, k))
    return out


def label(T: FrozenSet[int]) -> str:
    return "\u2205" if not T else ",".join(str(p) for p in sorted(T))


def main() -> None:
    fig, axes = plt.subplots(2, 2, figsize=(13, 9))
    fig.suptitle(
        "Divisibility cells for $P=\\{2,3,5,7\\}$, period $L=210$: "
        "an exact rate dial with an identically flat position profile",
        fontsize=13,
    )

    # (a) the rate dial ------------------------------------------------------
    ax = axes[0][0]
    sigs = sorted(all_signatures(PRIMES), key=lambda T: (-kappa(PRIMES, T), sorted(T)))
    heights = [kappa(PRIMES, T) for T in sigs]
    ax.bar(range(len(sigs)), heights, color="#3b6ea5", edgecolor="black", linewidth=0.4)
    ax.set_xticks(range(len(sigs)))
    ax.set_xticklabels([label(T) for T in sigs], rotation=70, fontsize=7)
    ax.axhline(PHI, color="crimson", ls="--", lw=1, label=f"$\\varphi(L)={PHI}$ (top)")
    ax.axhline(1, color="darkgreen", ls="--", lw=1, label="$1$ (bottom)")
    ax.set_ylabel("cell rate $\\kappa_T$ per period")
    ax.set_xlabel("required divisor set $T$")
    ax.set_title("(a) the rate dial: 16 cells, 8 distinct rates, spread $=\\varphi(L)$")
    ax.legend(fontsize=8)

    # (b) positional flatness ------------------------------------------------
    ax = axes[0][1]
    blocks = 20
    for T, colour in [
        (frozenset(), "#3b6ea5"),
        (frozenset({7}), "#e08214"),
        (frozenset({3, 5}), "#7b3294"),
    ]:
        counts = [
            sum(1 for v in range(m * L, m * L + L) if in_cell(PRIMES, T, v))
            for m in range(blocks)
        ]
        ax.plot(range(blocks), counts, "o-", color=colour, ms=4,
                label=f"$T={label(T)}$, $\\kappa={kappa(PRIMES, T)}$")
    ax.set_xlabel("block index $m$  (window $[mL,\\,mL+L)$)")
    ax.set_ylabel("cell members in block")
    ax.set_title("(b) exact positional flatness: drift is identically zero")
    ax.set_ylim(bottom=0)
    ax.legend(fontsize=8)

    # (c) coprime-scale equidistribution -------------------------------------
    ax = axes[1][0]
    M = 11
    T = frozenset()
    per_class = [
        sum(1 for v in range(L * M) if in_cell(PRIMES, T, v) and v % M == r)
        for r in range(M)
    ]
    ax.bar(range(M), per_class, color="#2c7fb8", edgecolor="black", linewidth=0.4)
    ax.axhline(PHI, color="crimson", ls="--", lw=1, label=f"$\\kappa={PHI}$ exactly")
    ax.set_xticks(range(M))
    ax.set_xlabel(f"residue class $r$ mod ${M}$")
    ax.set_ylabel(f"cell members in $[0,{L * M})$")
    ax.set_title("(c) coprime-scale equidistribution: every class gets exactly $\\kappa$")
    ax.legend(fontsize=8)

    # (d) the valuation ladder ----------------------------------------------
    ax = axes[1][1]
    exps = list(range(7))
    densities = [2 / 3 ** (e + 1) for e in exps]
    ax.semilogy(exps, densities, "s-", color="#d95f02", ms=6,
                label="density of $\\{v_3(v)=e\\}$")
    for e, d in zip(exps, densities):
        ax.annotate(f"$2/3^{{{e + 1}}}$", (e, d), textcoords="offset points",
                    xytext=(6, 6), fontsize=7)
    ax.set_xlabel("resolution $e$  (exact $3$-adic valuation)")
    ax.set_ylabel("density (log scale)")
    ax.set_title("(d) the valuation ladder: numerator frozen at $p-1=2$")
    ax.legend(fontsize=8)

    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("rate_dial_panels.png", dpi=160)
    print("wrote rate_dial_panels.png")


if __name__ == "__main__":
    main()


"""
Divisibility cells as rate dials — numerical demonstration.
===========================================================

This self-contained script verifies, by brute-force enumeration, every exact
statement of the accompanying paper:

  1. THE RATE LAW.  For a finite set P of distinct primes with period
     L = prod(P), the cell of a signature sigma (which primes of P must divide v)
     contains exactly

         kappa(sigma) = prod_{p in P} (1 if sigma(p) else p - 1)

     residues in [0, L), hence exactly m * kappa(sigma) integers in [0, mL).

  2. EXACT POSITIONAL FLATNESS.  Every period block [mL, mL + L) contains
     exactly the same count.  Zero drift, not small drift.

  3. THE COPRIME-STATISTIC NO-GO THEOREM.  For any M coprime to L and any
     predicate Q depending only on v mod M, the cell and the event Q are
     exactly independent over [0, LM):

         #{v < LM : v in C_sigma and Q(v)} = kappa(sigma) * #{r < M : Q(r)}.

     In particular each residue class mod M receives exactly kappa(sigma)
     cell members (coprime-scale equidistribution).

  4. THE VALUATION LADDER.  Refining "p | v" to "v_p(v) = e_p" gives, over the
     refined period prod p^(e_p + 1), a cell of size exactly prod (p - 1),
     independently of the exponents e.

  5. STRUCTURE OF THE DIAL.  Rates range from 1 to phi(L) with sharp
     attainment criteria; the prime 2 is a dead coordinate; every rate divides
     phi(L); the rates sum over all cells to L.

  6. EFFECTIVE SWEEP DIMENSION.  A sweep over all 2^|P| cells explores at most
     2^(|P| - 1) distinct rate values when 2 in P, with equality exactly when
     the shifted primes {p - 1 : p odd in P} have pairwise distinct subset
     products.  P = {3, 7, 13} violates this: (3-1)(7-1) = 13-1 = 12.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations
from math import gcd, prod
from typing import Callable, Dict, FrozenSet, Iterable, List, Sequence, Set, Tuple

# ---------------------------------------------------------------------------
# Core objects
# ---------------------------------------------------------------------------


def modulus(primes: Sequence[int]) -> int:
    """The period L = prod(P) of the divisibility cell decomposition."""
    return prod(primes)


def kappa(primes: Sequence[int], required: FrozenSet[int]) -> int:
    """The rate of the cell whose *required* divisor set is `required`.

    kappa_T = prod over cleared primes p in P \\ T of (p - 1).
    """
    return prod((1 if p in required else p - 1) for p in primes)


def in_cell(primes: Sequence[int], required: FrozenSet[int], v: int) -> bool:
    """Does v realise the divisibility signature with required set `required`?"""
    return all(((v % p == 0) == (p in required)) for p in primes)


def cell_count(primes: Sequence[int], required: FrozenSet[int], a: int, b: int) -> int:
    """Number of members of the cell in the window [a, b)."""
    return sum(1 for v in range(a, b) if in_cell(primes, required, v))


def euler_phi_squarefree(primes: Sequence[int]) -> int:
    """phi(L) for the squarefree L = prod(P)."""
    return prod(p - 1 for p in primes)


def all_signatures(primes: Sequence[int]) -> List[FrozenSet[int]]:
    """All 2^|P| required-divisor sets, i.e. all cells."""
    out: List[FrozenSet[int]] = []
    for k in range(len(primes) + 1):
        for combo in combinations(primes, k):
            out.append(frozenset(combo))
    return out


def p_adic_valuation(v: int, p: int) -> int:
    """The exponent of p in v (convention: 0 for v = 0 is never used here)."""
    e = 0
    while v % p == 0:
        v //= p
        e += 1
    return e


def in_val_cell(primes: Sequence[int], exponents: Dict[int, int], v: int) -> bool:
    """Does v have p-adic valuation exactly exponents[p] for every p in P?"""
    return all(
        v % p ** exponents[p] == 0 and v % p ** (exponents[p] + 1) != 0 for p in primes
    )


def val_period(primes: Sequence[int], exponents: Dict[int, int]) -> int:
    """The refined period prod p^(e_p + 1)."""
    return prod(p ** (exponents[p] + 1) for p in primes)


def sweep_values(primes: Sequence[int]) -> Set[int]:
    """The set of distinct rate values realised across all cells."""
    return {kappa(primes, T) for T in all_signatures(primes)}


def subset_products_distinct(odd_primes: Sequence[int]) -> bool:
    """Is {p - 1 : p in odd_primes} a multiplicative Sidon system?"""
    seen: Set[int] = set()
    for k in range(len(odd_primes) + 1):
        for combo in combinations(odd_primes, k):
            value = prod(p - 1 for p in combo)
            if value in seen:
                return False
            seen.add(value)
    return True


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def fmt_set(T: Iterable[int]) -> str:
    xs = sorted(T)
    return "{" + ", ".join(str(x) for x in xs) + "}" if xs else "{}"


def demo_rate_law(primes: Sequence[int]) -> None:
    L = modulus(primes)
    print(f"\n=== 1. THE RATE LAW —  P = {fmt_set(primes)},  L = {L} ===")
    print(f"{'required set T':>20} | {'kappa_T (formula)':>18} | {'counted in [0,L)':>17}")
    print("-" * 62)
    total = 0
    for T in all_signatures(primes):
        predicted = kappa(primes, T)
        counted = cell_count(primes, T, 0, L)
        assert predicted == counted, (T, predicted, counted)
        total += predicted
        print(f"{fmt_set(T):>20} | {predicted:>18} | {counted:>17}")
    print("-" * 62)
    print(f"sum of rates = {total}   (tiling theorem predicts L = {L})")
    assert total == L

    phi = euler_phi_squarefree(primes)
    rates = sorted(sweep_values(primes))
    print(f"phi(L) = {phi};  distinct rates = {rates}")
    assert all(phi % r == 0 for r in rates), "every rate must divide phi(L)"
    assert min(rates) == 1 and max(rates) == phi
    print(f"range of the dial: [1, phi(L)] = [1, {phi}]  -> spread factor {phi}x")

    odd = [p for p in primes if p != 2]
    top = frozenset()                 # all cleared
    bottom = frozenset(primes)        # all required
    assert kappa(primes, top) == phi
    assert kappa(primes, bottom) == 1
    if 2 in primes:
        assert kappa(primes, frozenset({2})) == phi, "the prime 2 is a dead coordinate"
        print("dead 2-coordinate confirmed: kappa({2}) == kappa({}) ==", phi)
    print(f"odd primes carrying all modulation: {fmt_set(odd)}")


def demo_positional_flatness(primes: Sequence[int], blocks: int = 10) -> None:
    L = modulus(primes)
    print(f"\n=== 2. EXACT POSITIONAL FLATNESS —  {blocks} blocks of length {L} ===")
    for T in [frozenset(), frozenset({7}) & frozenset(primes), frozenset(primes)]:
        counts = [cell_count(primes, T, m * L, m * L + L) for m in range(blocks)]
        cumulative = cell_count(primes, T, 0, blocks * L)
        drift = max(counts) - min(counts)
        print(
            f"  cell {fmt_set(T):>12}: per-block counts {counts[:5]}... "
            f"drift = {drift}, total = {cumulative} = {blocks} x {kappa(primes, T)}"
        )
        assert drift == 0
        assert cumulative == blocks * kappa(primes, T)
    print("  every block identical; drift is exactly zero, not merely small.")


def demo_coprime_no_go(primes: Sequence[int], M: int) -> None:
    L = modulus(primes)
    assert gcd(L, M) == 1, "M must be coprime to L"
    print(f"\n=== 3. COPRIME-SCALE NO-GO —  L = {L},  M = {M},  window [0, {L * M}) ===")

    # (a) equidistribution across residue classes mod M
    T = frozenset()  # all-cleared cell = totatives of L
    per_class = [
        sum(1 for v in range(L * M) if in_cell(primes, T, v) and v % M == r)
        for r in range(M)
    ]
    print(f"  all-cleared cell, members per residue class mod {M}: {per_class}")
    assert all(c == kappa(primes, T) for c in per_class)
    print(f"  every class receives exactly kappa = {kappa(primes, T)}; total = {sum(per_class)}")

    # (b) an arbitrary coprime-measurable statistic Q
    statistics: List[Tuple[str, Callable[[int], bool]]] = [
        (f"v mod {M} is a quadratic residue", lambda v: pow(v % M, (M - 1) // 2, M) in (0, 1)),
        (f"v mod {M} < {M // 2}", lambda v: v % M < M // 2),
        (f"v mod {M} is prime", lambda v: (v % M) in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29)),
    ]
    print(f"  {'statistic Q':>36} | {'joint':>7} | {'kappa * #Q':>11}")
    print("  " + "-" * 60)
    for name, Q in statistics:
        joint = sum(1 for v in range(L * M) if in_cell(primes, T, v) and Q(v))
        predicted = kappa(primes, T) * sum(1 for r in range(M) if Q(r))
        assert joint == predicted, (name, joint, predicted)
        print(f"  {name:>36} | {joint:>7} | {predicted:>11}")
    print("  exact independence for every coprime-measurable statistic: no error term.")


def demo_valuation_ladder() -> None:
    print("\n=== 4. THE VALUATION LADDER ===")
    print("  P = {3}: integers of 3-adic valuation exactly e, over period 3^(e+1)")
    for e in range(4):
        primes = [3]
        exps = {3: e}
        Le = val_period(primes, exps)
        count = sum(1 for v in range(Le) if in_val_cell(primes, exps, v))
        print(f"    e = {e}: period {Le:>4}, count {count}, density {count}/{Le}")
        assert count == 2

    print("  P = {2, 3}: count is always (2-1)(3-1) = 2, independent of exponents")
    for e2 in range(3):
        for e3 in range(3):
            primes = [2, 3]
            exps = {2: e2, 3: e3}
            Le = val_period(primes, exps)
            members = [v for v in range(Le) if in_val_cell(primes, exps, v)]
            assert len(members) == prod(p - 1 for p in primes)
            print(
                f"    e = (v_2={e2}, v_3={e3}): period {Le:>4}, "
                f"count {len(members)}, members {members}"
            )
    print("  numerator frozen at prod (p-1); refinement only enlarges the denominator.")


def demo_sweep_dimension(prime_sets: Sequence[Sequence[int]]) -> None:
    print("\n=== 5/6. EFFECTIVE DIMENSION OF A CELL SWEEP ===")
    header = f"{'P':>16} | {'cells':>5} | {'distinct rates':>14} | {'bound':>6} | Sidon?"
    print(header)
    print("-" * len(header))
    for primes in prime_sets:
        odd = [p for p in primes if p != 2]
        cells = 2 ** len(primes)
        distinct = len(sweep_values(primes))
        bound = 2 ** len(odd)
        sidon = subset_products_distinct(odd)
        assert distinct <= bound
        assert (distinct == bound) == sidon, "sharp Sidon criterion"
        print(
            f"{fmt_set(primes):>16} | {cells:>5} | {distinct:>14} | {bound:>6} | {sidon}"
        )
    print("\n  P = {3, 7, 13}: (3-1)(7-1) = 12 = 13-1, so two distinct cells share")
    print("  the rate 12 and the sweep tests only 7 genuinely different statistics.")
    collide = [
        (fmt_set(T), kappa([3, 7, 13], T))
        for T in all_signatures([3, 7, 13])
        if kappa([3, 7, 13], T) == 12
    ]
    print(f"  colliding cells: {collide}")


def demo_selection_inflation(primes: Sequence[int]) -> None:
    """How a max-over-cells statistic inflates against a nominal null."""
    print("\n=== 7. WHY A CELL SWEEP INFLATES A SCORE ===")
    n_cells = 2 ** len(primes)
    n_eff = len(sweep_values(primes))
    print(f"  P = {fmt_set(primes)}: {n_cells} cells but only {n_eff} distinct rate statistics.")
    print("  A maximum of n independent standard normals has expectation ~ sqrt(2 log n):")
    from math import log, sqrt

    for n in (n_eff, n_cells, 30):
        print(f"    n = {n:>3}:  E[max] ~ {sqrt(2 * log(n)):.3f} sigma of pure selection drift")
    print("  Scoring the maximum of a ~30-cell sweep against a nominal (uncalibrated)")
    print("  null therefore carries roughly 2.6 sigma of drift before any real effect,")
    print("  which is the order of the discrepancy between a raw score of 4.11 and a")
    print("  calibrated score of +1.53 — and the fresh-population score of -1.08.")


def main() -> None:
    print("=" * 66)
    print(" DIVISIBILITY CELLS ARE A RATE DIAL, NOT A POSITION DIAL ")
    print("=" * 66)

    P4 = [2, 3, 5, 7]
    demo_rate_law(P4)
    demo_positional_flatness(P4, blocks=10)
    demo_coprime_no_go(P4, M=11)
    demo_valuation_ladder()
    demo_sweep_dimension([[2, 3, 5, 7], [3, 7, 13], [2, 3, 5], [3, 5, 7, 11], [2, 3, 7, 13]])
    demo_selection_inflation(P4)

    # Cross-check the rate law on a second prime set.
    demo_rate_law([3, 5, 11])

    print("\nAll assertions passed: every exact statement verified by enumeration.")


if __name__ == "__main__":
    main()
