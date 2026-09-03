"""Gap audit: separating genuine signal from tie-granularity advantage.

Given a recorded rank correlation for the trailing-zero dial and for a
quadratic-residue baseline measured on the same sample, this routine computes the
largest advantage that the difference in tie granularity alone could possibly
produce (the *geometric budget*), and the *forced slack* -- the amount by which the
baseline must be underperforming its own ceiling if the recorded advantage is real.
A positive forced slack certifies that the advantage is not a resolution artefact.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import sqrt


def dyadic_ceiling_sq(bitlen: int) -> Fraction:
    """Exact ceiling (6/7)(1 + 1/(N(N+1))) of the trailing-zero dial, N = 2^bitlen."""
    n = 2 ** bitlen
    return Fraction(6, 7) * (Fraction(1) + Fraction(1, n * (n + 1)))


def qr_ceiling_sq() -> Fraction:
    """Exact ceiling 3/4 of the bare quadratic-residue count -- for every odd prime."""
    return Fraction(3, 4)


@dataclass(frozen=True)
class AuditResult:
    """Outcome of a gap audit, all quantities in correlation units."""

    rho_max_dial: float
    rho_max_baseline: float
    geometric_budget: float
    recorded_advantage: float
    forced_slack: float
    dial_admissible: bool
    baseline_admissible: bool

    @property
    def verdict(self) -> str:
        if not (self.dial_admissible and self.baseline_admissible):
            return "INADMISSIBLE: a recorded reading exceeds its own ceiling"
        if self.forced_slack > 0.0:
            return (f"SIGNAL: advantage exceeds the geometric budget by "
                    f"{self.forced_slack:.4f}")
        return "INCONCLUSIVE: tie granularity alone could explain the advantage"


def audit(bitlen: int, dial_rho: float, baseline_rho: float) -> AuditResult:
    """Audit one paired reading at the given bit-length."""
    rm_dial = sqrt(float(dyadic_ceiling_sq(bitlen)))
    rm_base = sqrt(float(qr_ceiling_sq()))
    budget = rm_dial - rm_base
    advantage = dial_rho - baseline_rho
    return AuditResult(
        rho_max_dial=rm_dial,
        rho_max_baseline=rm_base,
        geometric_budget=budget,
        recorded_advantage=advantage,
        forced_slack=advantage - budget,
        dial_admissible=dial_rho <= rm_dial,
        baseline_admissible=baseline_rho <= rm_base,
    )


if __name__ == "__main__":
    print(f"{'seed':>10} {'rho(T)':>8} {'rho(QR)':>8} {'budget':>9} {'slack':>9}  verdict")
    for seed, t in (("20261080", 0.777), ("20261081", 0.755), ("20261082", 0.801)):
        for adv in (0.09, 0.13):
            r = audit(48, t, t - adv)
            print(f"{seed:>10} {t:>8.3f} {t-adv:>8.3f} {r.geometric_budget:>9.5f}"
                  f" {r.forced_slack:>9.5f}  {r.verdict}")


"""Exact resolution-ceiling calculus for a tie profile.

Given the multiset of level-set sizes of a discrete statistic, this module returns
the exact largest squared Spearman rank correlation the statistic can attain with
any target variable, together with the comparison primitive that ranks two
statistics of equal sample size.
"""

from __future__ import annotations

from fractions import Fraction
from math import sqrt
from typing import Sequence


def cube_sum(profile: Sequence[int]) -> int:
    """Sum of cubes of the block sizes -- the sole functional the ceiling depends on."""
    return sum(m ** 3 for m in profile)


def tie_correction(profile: Sequence[int]) -> Fraction:
    """Kendall tie correction  T(L) = sum_j (m_j^3 - m_j) / 12."""
    return Fraction(cube_sum(profile) - sum(profile), 12)


def ceiling_sq(profile: Sequence[int]) -> Fraction:
    """Exact squared resolution ceiling  1 - (cube(L) - n) / (n^3 - n)."""
    n = sum(profile)
    if n < 2:
        raise ValueError("sample size must be at least 2")
    return Fraction(1) - Fraction(cube_sum(profile) - n, n ** 3 - n)


def ceiling_rho(profile: Sequence[int]) -> float:
    """Resolution ceiling in correlation units, rho_max = sqrt(ceil)."""
    return sqrt(float(ceiling_sq(profile)))


def dominates(finer: Sequence[int], coarser: Sequence[int]) -> bool:
    """True iff `finer` has a provably higher-or-equal ceiling than `coarser`.

    Valid only when the two profiles share a sample size; the test is the
    cube-sum comparison, which is equivalent to the ceiling comparison.
    """
    if sum(finer) != sum(coarser):
        raise ValueError("profiles must have equal sample size to be comparable")
    return cube_sum(finer) <= cube_sum(coarser)


def merge_blocks(profile: Sequence[int], i: int, j: int) -> list[int]:
    """Coarsen a profile by merging blocks i and j; always lowers the ceiling."""
    if i == j:
        raise ValueError("indices must differ")
    lo, hi = sorted((i, j))
    out = list(profile)
    merged = out[lo] + out[hi]
    del out[hi]
    out[lo] = merged
    return out


if __name__ == "__main__":
    dyadic48 = [2 ** (47 - k) for k in range(48)] + [1]
    qr = [1, 2]  # the Legendre indicator modulo 3; the same ceiling for every odd prime
    print("dyadic 48 ceiling :", float(ceiling_sq(dyadic48)), "rho_max", ceiling_rho(dyadic48))
    print("QR ceiling        :", ceiling_sq(qr), "rho_max", ceiling_rho(qr))
    fine = [4, 2, 1, 1]
    print("merge 0,1         :", fine, "->", merge_blocks(fine, 0, 1),
          "ceiling", float(ceiling_sq(fine)), "->", float(ceiling_sq(merge_blocks(fine, 0, 1))))


"""Legendre tower profiles: joint symbol vectors versus summed symbol counts.

Builds the tie profile of the joint quadratic-residue statistic over a list of odd
primes in both of its natural encodings -- the full symbol vector and the collapsed
symbol count -- and returns their exact resolution ceilings.  The vector profile has
2^r blocks and is built by iterated Chinese-Remainder product; the count profile has
r+1 blocks and is built by polynomial convolution.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List, Sequence, Tuple


def _ceiling_sq(profile: Sequence[int]) -> Fraction:
    n = sum(profile)
    return Fraction(1) - Fraction(sum(m ** 3 for m in profile) - n, n ** 3 - n)


def qr_blocks(p: int) -> List[int]:
    """Tie profile (m, m+1) of the QR indicator modulo the odd prime p = 2m+1."""
    if p < 3 or p % 2 == 0:
        raise ValueError("p must be an odd prime")
    m = (p - 1) // 2
    return [m, m + 1]


def vector_profile(primes: Sequence[int]) -> List[int]:
    """Tie profile of the joint Legendre VECTOR: all CRT products of block sizes."""
    out: List[int] = [1]
    for p in reversed(primes):
        blocks = qr_blocks(p)
        out = [a * b for a in blocks for b in out]
    return out


def count_profile(primes: Sequence[int]) -> List[int]:
    """Tie profile of the Legendre COUNT: coefficients of prod_p ((m+1) + m z)."""
    coeffs: List[int] = [1]
    for p in primes:
        m = (p - 1) // 2
        new = [0] * (len(coeffs) + 1)
        for i, c in enumerate(coeffs):
            new[i] += (m + 1) * c
            new[i + 1] += m * c
        coeffs = new
    return coeffs


def tower_report(primes: Sequence[int]) -> Tuple[Fraction, Fraction, Fraction]:
    """Return (vector ceiling, count ceiling, collapse loss) for a list of primes."""
    vec, cnt = vector_profile(primes), count_profile(primes)
    if sum(vec) != sum(cnt):
        raise AssertionError("profiles must share a sample size")
    cv, cc = _ceiling_sq(vec), _ceiling_sq(cnt)
    return cv, cc, cv - cc


def tower_closed_form(primes: Sequence[int]) -> Fraction:
    """Multiplicative tower law: 1 - (prod(m^3+(m+1)^3) - N)/(N^3 - N)."""
    big_n, big_c = 1, 1
    for p in primes:
        m = (p - 1) // 2
        big_n *= p
        big_c *= m ** 3 + (m + 1) ** 3
    return Fraction(1) - Fraction(big_c - big_n, big_n ** 3 - big_n)


if __name__ == "__main__":
    for primes in ([3], [3, 5], [3, 5, 7], [3, 5, 7, 11], [3, 3], [3, 3, 3]):
        cv, cc, loss = tower_report(primes)
        assert cv == tower_closed_form(primes)
        assert cc <= cv, "counting collapse"
        print(f"primes {str(primes):<16} N={sum(vector_profile(primes)):<6}"
              f" vector {str(cv):>18} = {float(cv):.6f}"
              f"   count {str(cc):>20} = {float(cc):.6f}   loss {float(loss):.6f}")


#!/usr/bin/env python3
"""Assemble PACKAGE.json from the individual deliverables."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
A = ROOT / ".assets"


def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILE = "Catalog/Cryptography/ZeroFitDialQRUnif48.lean"

INTERACTIVE_LAYOUT = read(A / "interactive_layout.md")

package = {
    "title": "Tie Geometry of Arithmetic Statistics: Exact Resolution Ceilings for the "
             "2-adic Dial and its Quadratic-Residue Baselines",
    "domain": "Cryptography",
    "description": (
        "An exact calculus for the maximal rank correlation a discrete statistic can attain, "
        "showing that the trailing-zero (2-adic) dial has ceiling 6/7·(1+1/(N(N+1))) at bit-length "
        "b while a bare quadratic-residue indicator has ceiling exactly 3/4 for every odd prime. "
        "The resulting gap law proves that the recorded 0.09–0.13 advantage of the dial over the "
        "quadratic-residue baseline on uniform 48-bit draws exceeds anything tie granularity could "
        "produce, and therefore is genuine signal."
    ),
    "authors": ["Aristotle"],
    "date": "2026-09-03",
    "key_results": [
        "Tie-attenuation law: the squared Spearman ceiling of a statistic with level-set sizes "
        "m_1,...,m_k on n items equals 1 - (Σ m_j³ - n)/(n³ - n), a strictly decreasing function "
        "of the cube sum Σ m_j³ at fixed n, so coarsening a statistic can only lower its ceiling.",
        "Prime-independence law: the bare quadratic-residue indicator has resolution ceiling "
        "exactly ρ² = 3/4 for every odd prime modulus, with no dependence on the modulus at all; "
        "the underlying arithmetic bridge is that modulo p = 2m+1 there are exactly m+1 squares "
        "and m non-squares.",
        "Dyadic ceiling: the trailing-zero dial at bit-length b has ceiling exactly "
        "6/7·(1 + 1/(N(N+1))) with N = 2^b, hence essentially the constant 6/7, and it varies by "
        "less than 2^-80 across bit-lengths 44 to 52.",
        "Gap law and forced slack: the entire tie-geometry advantage of the dial over the bare "
        "quadratic-residue count is √(6/7) − √(3/4) < 0.06 in correlation units at every odd prime, "
        "so a recorded advantage of at least 0.09 forces the baseline reading at least 0.03 below "
        "its own ceiling and cannot be a resolution artefact.",
        "Counting collapse and crossover hierarchy: summing a Legendre vector into a count can only "
        "lower the ceiling for any list of primes, and at bit-length 48 one symbol (3/4) and two "
        "counted symbols (117/140) sit below the dyadic ceiling 6/7 while three counted symbols "
        "(2433/2756) and two vector symbols (51/56) sit above it.",
    ],
    "keywords": [
        "Spearman rank correlation",
        "tie correction",
        "2-adic valuation",
        "Legendre symbol",
        "quadratic residues",
        "quadratic character sums",
        "Chinese Remainder Theorem",
        "resolution ceilings",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "End-to-End Verification of the Resolution-Ceiling Calculus and the Gap Audit",
            "description": (
                "A single self-contained script that reproduces every numerical claim of the paper "
                "in exact rational arithmetic. It verifies the tie-attenuation law and cube-sum "
                "monotonicity on hand-checkable profiles; recomputes the dyadic tie profile by brute "
                "enumeration of the 2-adic valuation and matches it against the closed form "
                "6/7·(1+1/(N(N+1))); confirms the prime-independence law ρ² = 3/4 at twelve odd "
                "primes up to 2^61 − 1 and cross-checks the underlying square/non-square split by "
                "enumeration; builds joint Legendre vector and count profiles for several prime "
                "lists, validates the multiplicative tower law against the CRT product formula, and "
                "confirms the counting collapse; tabulates the crossover hierarchy at bit-length 48; "
                "evaluates the replicated-symbol tower against its geometric lower bound "
                "1 − 2·3^(−r); and finally runs the forced-slack audit on the three recorded seeds, "
                "asserting that every implied baseline reading respects its own ceiling while the "
                "slack always exceeds 0.03. All checks are assertions, so a clean run is a proof of "
                "internal consistency."
            ),
            "code": read(ROOT / "demo.py"),
        }
    ],
    "algorithms": [
        {
            "name": "The Cube-Sum Ceiling Calculus for Discrete Statistics",
            "description": (
                "Computes the exact largest squared Spearman rank correlation attainable by a "
                "statistic from its tie profile alone, together with the comparison primitive that "
                "ranks two statistics of equal sample size. The mathematical foundation is the "
                "identity 12·T(L) = Σ m_j³ − n for the Kendall tie correction, which turns the "
                "ceiling into 1 − (Σ m_j³ − n)/(n³ − n). Since the denominator is fixed by the "
                "sample size, the ceiling is a strictly decreasing affine function of the single "
                "integer Σ m_j³, so comparing two statistics reduces to comparing cube sums; and "
                "because (a+b)³ > a³ + b³ for positive a, b, any merge of two level sets strictly "
                "increases that integer. Complexity is O(k) big-integer cubes and one exact "
                "division for a profile of k blocks; with exact rational arithmetic the output is "
                "a fraction in lowest terms, so ceilings such as 3/4, 51/56 and 2433/2756 come out "
                "symbolically rather than as floating-point approximations. This routine is the "
                "primitive that every other result in the pipeline calls."
            ),
            "pseudocode": (
                "ALGORITHM CeilingOfProfile(L = (m_1, ..., m_k))\n"
                "  REQUIRE  every m_j is a positive integer\n"
                "  n  <- SUM over j of m_j\n"
                "  IF n < 2 THEN ERROR 'sample size too small'\n"
                "  c  <- SUM over j of m_j^3\n"
                "  RETURN exact rational  1 - (c - n) / (n^3 - n)\n"
                "\n"
                "ALGORITHM Dominates(F, C)          -- does F provably out-resolve C ?\n"
                "  REQUIRE  SUM(F) = SUM(C)         -- comparison needs equal sample size\n"
                "  RETURN  CubeSum(F) <= CubeSum(C)\n"
                "\n"
                "ALGORITHM MergeBlocks(L, i, j)     -- the canonical coarsening\n"
                "  REQUIRE  i /= j\n"
                "  M <- L with entries m_i and m_j deleted and m_i + m_j appended\n"
                "  ASSERT   CubeSum(M) >= CubeSum(L)            -- (a+b)^3 >= a^3 + b^3\n"
                "  ASSERT   CeilingOfProfile(M) <= CeilingOfProfile(L)\n"
                "  RETURN M"
            ),
            "code": read(A / "alg_ceiling.py"),
        },
        {
            "name": "Construction of Legendre Tower Profiles: Symbol Vectors versus Symbol Counts",
            "description": (
                "Builds the tie profile of the joint quadratic-residue statistic over a list of odd "
                "primes in each of its two natural encodings and returns their exact ceilings. The "
                "vector encoding records the full tuple of Legendre symbols: by the Chinese "
                "Remainder Theorem its level sets are indexed by tuples of individual level sets, so "
                "the profile is the set of all products of one block size per prime, built by "
                "iterated product in O(2^r) time and space for r primes. The count encoding records "
                "only how many symbols reported 'non-square': its profile is the coefficient list of "
                "the polynomial ∏((m_i+1) + m_i·z), built by convolution in O(r²) time with r+1 "
                "blocks. Both encodings share the sample size N = ∏ p_i (evaluate the polynomial at "
                "z = 1), so their ceilings are directly comparable through the cube-sum criterion. "
                "The vector ceiling satisfies the multiplicative tower law 1 − (C − N)/(N³ − N) with "
                "C = ∏(m_i³ + (m_i+1)³) — the sample size and the cube sum are both multiplicative "
                "across CRT factors, so the ceiling factorises with no interaction term — and the "
                "routine asserts this closed form against the explicitly built profile. It also "
                "asserts the counting collapse: the count ceiling never exceeds the vector ceiling."
            ),
            "pseudocode": (
                "ALGORITHM QRBlocks(p)                    -- p = 2m+1 an odd prime\n"
                "  m <- (p - 1) / 2\n"
                "  RETURN (m, m + 1)     -- m non-squares, m+1 squares (0 counts as a square)\n"
                "\n"
                "ALGORITHM VectorProfile(p_1, ..., p_r)\n"
                "  V <- (1)\n"
                "  FOR i FROM r DOWNTO 1 DO\n"
                "      V <- ( a * b : a IN QRBlocks(p_i), b IN V )     -- CRT product profile\n"
                "  RETURN V                                            -- 2^r blocks\n"
                "\n"
                "ALGORITHM CountProfile(p_1, ..., p_r)\n"
                "  coeffs <- (1)\n"
                "  FOR i FROM 1 TO r DO\n"
                "      m <- (p_i - 1) / 2\n"
                "      new <- zero list of length len(coeffs) + 1\n"
                "      FOR each index j with coefficient c IN coeffs DO\n"
                "          new[j]     <- new[j]     + (m + 1) * c      -- symbol says 'square'\n"
                "          new[j + 1] <- new[j + 1] + m * c            -- symbol says 'non-square'\n"
                "      coeffs <- new\n"
                "  RETURN coeffs                                       -- r+1 blocks\n"
                "\n"
                "ALGORITHM TowerReport(p_1, ..., p_r)\n"
                "  V <- VectorProfile(...);  K <- CountProfile(...)\n"
                "  ASSERT SUM(V) = SUM(K) = PRODUCT of p_i\n"
                "  cv <- CeilingOfProfile(V);  cc <- CeilingOfProfile(K)\n"
                "  ASSERT cv = 1 - (PRODUCT of (m_i^3 + (m_i+1)^3) - N) / (N^3 - N)\n"
                "  ASSERT cc <= cv                                     -- counting collapse\n"
                "  RETURN (cv, cc, cv - cc)"
            ),
            "code": read(A / "alg_tower.py"),
        },
        {
            "name": "The Gap Audit: Separating Genuine Signal from Tie-Granularity Advantage",
            "description": (
                "Decides whether a measured advantage of one statistic over another can be explained "
                "by the difference in their tie granularity. Given a bit-length and a paired reading, "
                "it evaluates the two ceilings in closed form — 6/7·(1+1/(N(N+1))) for the "
                "trailing-zero dial and exactly 3/4 for the bare quadratic-residue count, the latter "
                "holding for every odd prime so that no modulus need be supplied — converts them to "
                "correlation units, and reports two diagnostics. The geometric budget G is the "
                "difference of the two ceilings: the largest advantage that granularity alone could "
                "ever produce. The forced slack S = (measured advantage) − G is the amount by which "
                "the baseline must be underperforming its own ceiling if the reading is genuine; a "
                "strictly positive S certifies signal. The routine also flags inadmissible readings, "
                "namely any correlation exceeding its own statistic's ceiling, which would indicate a "
                "measurement or bookkeeping error. Cost is O(1) after one exact rational evaluation "
                "of the dyadic ceiling; at bit-length 48 the budget is 0.059795, so the recorded "
                "advantages of 0.09 and 0.13 force slacks of 0.0302 and 0.0702 respectively."
            ),
            "pseudocode": (
                "ALGORITHM GapAudit(bitlen b, dial reading t, baseline reading q)\n"
                "  N        <- 2^b\n"
                "  ceilDial <- (6/7) * (1 + 1 / (N * (N + 1)))        -- exact rational\n"
                "  ceilBase <- 3/4                                    -- every odd prime, exactly\n"
                "  rhoDial  <- sqrt(ceilDial)\n"
                "  rhoBase  <- sqrt(ceilBase)\n"
                "  budget   <- rhoDial - rhoBase                      -- geometric budget G\n"
                "  advantage<- t - q\n"
                "  slack    <- advantage - budget                     -- forced slack S\n"
                "  IF t > rhoDial OR q > rhoBase THEN\n"
                "      RETURN 'INADMISSIBLE: a reading exceeds its own ceiling'\n"
                "  IF slack > 0 THEN\n"
                "      RETURN 'SIGNAL: baseline lies at least S below its own ceiling'\n"
                "  ELSE\n"
                "      RETURN 'INCONCLUSIVE: granularity alone could explain the advantage'"
            ),
            "code": read(A / "alg_audit.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Ceiling Ladder and the Crossover at Bit-Length 48",
            "description": (
                "A two-panel figure. The left panel places every baseline on a single vertical scale "
                "of squared resolution ceilings — one Legendre symbol at 3/4, two counted symbols at "
                "117/140, the trailing-zero dial at 6/7, three counted symbols at 2433/2756, and two "
                "vector symbols at 51/56 — with the dial's ceiling drawn as a horizontal reference "
                "line so the crossover is visible at a glance: three counted symbols are needed to "
                "pass the dial, but only two vector symbols. The right panel converts the same data "
                "to correlation units, shades the validation band [0.55, 0.85], plots the three "
                "recorded readings together with the baseline values they imply, and annotates the "
                "geometric budget 0.0598 as a double-headed arrow between the two ceilings — making "
                "visually obvious both the band-saturation asymmetry and the fact that the recorded "
                "advantage overshoots the budget."
            ),
            "code": read(A / "viz_ladder.py"),
        },
        {
            "name": "Growing the Arithmetic Baseline and the Invariance of the Dyadic Dial",
            "description": (
                "A two-panel figure on how resolution can be bought and how flat the dial's ceiling "
                "is. The left panel tracks r replicated Legendre symbols at the prime 3 for r = 1..8, "
                "plotting the exact vector ceiling 1 − (9^r − 3^r)/(27^r − 3^r) against the ceiling "
                "of the summed count and against the geometric lower bound 1 − 2·3^(−r); the shaded "
                "region between the two curves is the counting collapse, and it widens with r, "
                "showing that the penalty for summing grows rather than washing out. The right panel "
                "plots the distance of the dyadic ceiling from 6/7 on a logarithmic scale against "
                "bit-length, with the deployment envelope 44–52 highlighted, demonstrating that the "
                "dial's ceiling decays to 6/7 like 4^(−b) and is, across the whole envelope, a "
                "constant for every practical purpose."
            ),
            "code": read(A / "viz_tower.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Tie-Ceiling Laboratory — Build a Statistic, Watch its Ceiling",
            "description": (
                "A hands-on workbench for the central formula. Choose a statistic — the trailing-zero "
                "dial at an adjustable bit-length, a single Legendre symbol at an adjustable prime, "
                "or a joint Legendre statistic kept as a vector or collapsed to a count — and its tie "
                "profile is drawn live as a row of bars, one per value the statistic takes, with the "
                "exact sample size, block count and cube sum reported alongside. The resolution "
                "ceiling is computed in exact big-integer rational arithmetic and displayed both as "
                "a fraction and as a correlation, and your statistic is placed in gold on a ladder of "
                "reference ceilings so you can see instantly whether it out-resolves the dial. Two "
                "discoveries are built in for the reader to make themselves: slide the prime modulus "
                "and watch the Legendre ceiling refuse to move from exactly 3/4, and click any two "
                "bars to merge them and watch the ceiling fall — the coarsening principle made "
                "tactile."
            ),
            "html": read(A / "widget_lab.html"),
        },
        {
            "title": "The Gap Audit Console — Is the Margin Signal or Geometry?",
            "description": (
                "An analyst's console for the question the whole paper answers. Set the bit-length, "
                "the recorded correlation of the dial, and the advantage it shows over the "
                "quadratic-residue baseline, and the console draws both ceilings, the validation "
                "band, the recorded reading and the implied baseline reading on one correlation "
                "scale, with the geometric budget marked as a bracket between the two ceilings. It "
                "then reports the budget and the forced slack numerically and delivers a verdict: "
                "SIGNAL when the advantage overshoots anything granularity could produce, "
                "INCONCLUSIVE when it does not, and IMPOSSIBLE READING when a supplied correlation "
                "exceeds its own statistic's ceiling. One-click presets load the three recorded "
                "seeds, and a summary table audits the entire round at both ends of the recorded "
                "advantage range, showing band membership, ceiling-normalised correlation and forced "
                "slack for each."
            ),
            "html": read(A / "widget_audit.html"),
        },
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": read(ROOT / LEAN_FILE),
    "future_directions": read(A / "future_directions.md"),
    "modules": {"demo": read(ROOT / "demo.py")},
    "lean_files": [LEAN_FILE],
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False), encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size} bytes)")


"""Visualization: the resolution-ceiling ladder and the crossover at bit-length 48.

Draws every baseline discussed in the paper on a single vertical scale of squared
resolution ceilings, with the trailing-zero dial's ceiling 6/7 as a horizontal
reference line, so that the crossover -- three counted Legendre symbols but only two
vector symbols -- is visible at a glance.  A second panel converts the same data to
correlation units and overlays the recorded readings and the validation band, making
the band-saturation asymmetry immediate.

Requires: matplotlib.  Produces `ceiling_ladder.png`.
"""

from __future__ import annotations

from fractions import Fraction
from math import sqrt
from typing import List, Sequence, Tuple

import matplotlib.pyplot as plt


def ceiling_sq(profile: Sequence[int]) -> Fraction:
    n = sum(profile)
    return Fraction(1) - Fraction(sum(m ** 3 for m in profile) - n, n ** 3 - n)


def dyadic(b: int) -> List[int]:
    return [2 ** (b - 1 - k) for k in range(b)] + [1]


def qr_vector(primes: Sequence[int]) -> List[int]:
    out: List[int] = [1]
    for p in reversed(primes):
        m = (p - 1) // 2
        out = [a * b for a in (m, m + 1) for b in out]
    return out


def qr_count(primes: Sequence[int]) -> List[int]:
    coeffs: List[int] = [1]
    for p in primes:
        m = (p - 1) // 2
        new = [0] * (len(coeffs) + 1)
        for i, c in enumerate(coeffs):
            new[i] += (m + 1) * c
            new[i + 1] += m * c
        coeffs = new
    return coeffs


def main() -> None:
    dial = float(ceiling_sq(dyadic(48)))
    entries: List[Tuple[str, float, str]] = [
        ("1 symbol\n(any odd p)", float(ceiling_sq([1, 2])), "#c0392b"),
        ("2 symbols (3,5)\ncounted", float(ceiling_sq(qr_count([3, 5]))), "#e67e22"),
        ("trailing-zero dial\n48 bits", dial, "#2c3e50"),
        ("3 symbols (3,5,7)\ncounted", float(ceiling_sq(qr_count([3, 5, 7]))), "#16a085"),
        ("2 symbols at 3\nvector", float(ceiling_sq(qr_vector([3, 3]))), "#2980b9"),
        ("2 symbols (3,5)\nvector", float(ceiling_sq(qr_vector([3, 5]))), "#8e44ad"),
    ]
    entries.sort(key=lambda e: e[1])

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6.5))

    labels = [e[0] for e in entries]
    values = [e[1] for e in entries]
    colors = [e[2] for e in entries]
    bars = ax1.bar(range(len(entries)), values, color=colors, edgecolor="black", linewidth=0.7)
    ax1.axhline(dial, color="#2c3e50", linestyle="--", linewidth=1.6,
                label=r"dial ceiling $6/7 = 0.8571$")
    ax1.set_xticks(range(len(entries)))
    ax1.set_xticklabels(labels, fontsize=8.5)
    ax1.set_ylim(0.70, 1.0)
    ax1.set_ylabel(r"squared resolution ceiling  $\rho^2_{\max}$", fontsize=11)
    ax1.set_title("The crossover hierarchy at bit-length 48", fontsize=13, weight="bold")
    ax1.legend(fontsize=9, loc="upper left")
    ax1.grid(axis="y", alpha=0.25)
    for bar, v in zip(bars, values):
        ax1.text(bar.get_x() + bar.get_width() / 2, v + 0.004, f"{v:.4f}",
                 ha="center", fontsize=8.5)

    rho_dial, rho_qr = sqrt(dial), sqrt(0.75)
    ax2.axhspan(0.55, 0.85, color="#f1c40f", alpha=0.18, label="validation band [0.55, 0.85]")
    ax2.axhline(rho_dial, color="#2c3e50", linewidth=2,
                label=fr"dial ceiling $\sqrt{{6/7}} = {rho_dial:.4f}$")
    ax2.axhline(rho_qr, color="#c0392b", linewidth=2,
                label=fr"QR ceiling $\sqrt{{3}}/2 = {rho_qr:.4f}$")
    seeds = [("20261080", 0.777), ("20261081", 0.755), ("20261082", 0.801)]
    ax2.scatter([0, 1, 2], [s[1] for s in seeds], s=110, zorder=5, color="#2c3e50",
                marker="o", label="recorded dial readings")
    ax2.scatter([0, 1, 2], [s[1] - 0.09 for s in seeds], s=110, zorder=5, color="#c0392b",
                marker="v", label="implied baseline (advantage 0.09)")
    for i, (name, v) in enumerate(seeds):
        ax2.annotate(f"{v:.3f}", (i, v), textcoords="offset points", xytext=(10, 2), fontsize=9)
    ax2.annotate("", xy=(2.55, rho_dial), xytext=(2.55, rho_qr),
                 arrowprops=dict(arrowstyle="<->", color="black", linewidth=1.4))
    ax2.text(2.62, (rho_dial + rho_qr) / 2,
             f"geometric\nbudget\n{rho_dial - rho_qr:.4f}", fontsize=9, va="center")
    ax2.set_xticks([0, 1, 2])
    ax2.set_xticklabels([s[0] for s in seeds])
    ax2.set_xlim(-0.5, 3.4)
    ax2.set_ylim(0.55, 0.98)
    ax2.set_ylabel(r"rank correlation  $\rho$", fontsize=11)
    ax2.set_title("Recorded readings against the two ceilings", fontsize=13, weight="bold")
    ax2.legend(fontsize=8.5, loc="lower right")
    ax2.grid(axis="y", alpha=0.25)

    fig.suptitle("Tie geometry cannot explain the recorded advantage", fontsize=15, weight="bold")
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("ceiling_ladder.png", dpi=160)
    print("wrote ceiling_ladder.png")


if __name__ == "__main__":
    main()


"""Visualization: vector versus count -- how resolution grows with Legendre symbols.

Left panel: for r = 1..8 replicated Legendre symbols at the prime 3, plots the exact
ceiling of the joint symbol VECTOR, 1 - (9^r - 3^r)/(27^r - 3^r), against the ceiling
of the summed symbol COUNT, together with the geometric lower bound 1 - 2*3^(-r).
The gap between the two curves is the counting collapse, and it widens with r.

Right panel: the dyadic ceiling 6/7 (1 + 1/(N(N+1))) as a function of bit-length,
on a log scale of its distance from 6/7, showing that across the deployment envelope
44-52 the ceiling is effectively a constant.

Requires: matplotlib.  Produces `tower_and_flatness.png`.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List, Sequence

import matplotlib.pyplot as plt


def ceiling_sq(profile: Sequence[int]) -> Fraction:
    n = sum(profile)
    return Fraction(1) - Fraction(sum(m ** 3 for m in profile) - n, n ** 3 - n)


def qr_vector_at_3(r: int) -> Fraction:
    return Fraction(1) - Fraction(9 ** r - 3 ** r, 27 ** r - 3 ** r)


def qr_count_at_3(r: int) -> Fraction:
    coeffs: List[int] = [1]
    for _ in range(r):
        new = [0] * (len(coeffs) + 1)
        for i, c in enumerate(coeffs):
            new[i] += 2 * c
            new[i + 1] += 1 * c
        coeffs = new
    return ceiling_sq(coeffs)


def dyadic_ceiling(b: int) -> Fraction:
    n = 2 ** b
    return Fraction(6, 7) * (Fraction(1) + Fraction(1, n * (n + 1)))


def main() -> None:
    rs = list(range(1, 9))
    vec = [float(qr_vector_at_3(r)) for r in rs]
    cnt = [float(qr_count_at_3(r)) for r in rs]
    bound = [1 - 2 / 3 ** r for r in rs]
    dial48 = float(dyadic_ceiling(48))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    ax1.plot(rs, vec, "o-", color="#2980b9", linewidth=2, markersize=7,
             label=r"symbol VECTOR: $1-\frac{9^r-3^r}{27^r-3^r}$")
    ax1.plot(rs, cnt, "s-", color="#e67e22", linewidth=2, markersize=7,
             label="symbol COUNT (summed)")
    ax1.plot(rs, bound, ":", color="#7f8c8d", linewidth=2,
             label=r"lower bound $1-2\cdot 3^{-r}$")
    ax1.axhline(dial48, color="#2c3e50", linestyle="--", linewidth=1.6,
                label=r"trailing-zero dial, 48 bits ($6/7$)")
    ax1.fill_between(rs, cnt, vec, color="#e74c3c", alpha=0.13,
                     label="counting collapse")
    ax1.set_xlabel("number of Legendre symbols at the prime 3, $r$", fontsize=11)
    ax1.set_ylabel(r"squared resolution ceiling  $\rho^2_{\max}$", fontsize=11)
    ax1.set_title("Vector versus count: the cost of summing", fontsize=13, weight="bold")
    ax1.set_ylim(0.70, 1.005)
    ax1.legend(fontsize=9, loc="lower right")
    ax1.grid(alpha=0.25)

    bs = list(range(2, 25))
    dist = [float(dyadic_ceiling(b) - Fraction(6, 7)) for b in bs]
    ax2.semilogy(bs, dist, "o-", color="#8e44ad", linewidth=2, markersize=5,
                 label=r"$\mathrm{ceil}(D_b) - 6/7 = \frac{6}{7N(N+1)}$")
    ax2.semilogy(bs, [4.0 ** -b for b in bs], ":", color="#7f8c8d", linewidth=2,
                 label=r"$4^{-b}$")
    ax2.axvspan(44, 52, color="#f1c40f", alpha=0.25)
    ax2.set_xlabel("bit-length $b$", fontsize=11)
    ax2.set_ylabel(r"distance of the ceiling from $6/7$", fontsize=11)
    ax2.set_title("Envelope flatness: the dial's ceiling is a constant",
                  fontsize=13, weight="bold")
    ax2.text(0.98, 0.92, "across bit-lengths 44-52 the ceiling\nmoves by less than $2^{-80}$",
             transform=ax2.transAxes, ha="right", fontsize=10,
             bbox=dict(boxstyle="round", facecolor="#fdf3d0", edgecolor="#b7950b"))
    ax2.legend(fontsize=9, loc="lower left")
    ax2.grid(alpha=0.25, which="both")

    fig.suptitle("Growing the arithmetic baseline, and the invariance of the dyadic dial",
                 fontsize=15, weight="bold")
    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("tower_and_flatness.png", dpi=160)
    print("wrote tower_and_flatness.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Tie Geometry of Arithmetic Statistics — numerical demonstration
================================================================

This self-contained script reproduces, in exact rational arithmetic, every
numerical claim of the accompanying paper:

  1. The tie-attenuation law:      ceil(L) = 1 - (sum m_j^3 - n) / (n^3 - n).
  2. The dyadic ceiling:           ceil(D_b) = (6/7)(1 + 1/(N(N+1))),  N = 2^b.
  3. The prime-independence law:   ceil(Q_m) = 3/4 exactly, for every odd prime 2m+1.
  4. The multiplicative tower law for joint Legendre vectors (CRT factorisation).
  5. The counting collapse:        ceil(count) <= ceil(vector), for every prime list.
  6. The crossover hierarchy at bit-length 48.
  7. The replicated-symbol tower:  1 - (9^r - 3^r)/(27^r - 3^r) >= 1 - 2/3^r.
  8. The gap law and the forced-slack audit of the recorded round-52 readings.
  9. Band-saturation asymmetry and envelope flatness.

Every ceiling is computed with `fractions.Fraction`, so the printed rationals are
exact; floats appear only for human-readable display.  Brute-force checks recompute
tie profiles directly from the definitions of the 2-adic valuation and of the
quadratic-residue indicator, independently of the closed forms.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from math import isqrt, sqrt
from typing import Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# 1. The cube-sum calculus
# ----------------------------------------------------------------------------


def cube_sum(profile: Sequence[int]) -> int:
    """Return sum_j m_j^3, the only functional of a tie profile the ceiling sees."""
    return sum(m ** 3 for m in profile)


def sample_size(profile: Sequence[int]) -> int:
    """Return n = sum_j m_j, the population size recovered from the profile."""
    return sum(profile)


def tie_correction(profile: Sequence[int]) -> Fraction:
    """Kendall tie correction  T(L) = sum_j (m_j^3 - m_j)/12."""
    return Fraction(cube_sum(profile) - sample_size(profile), 12)


def ceiling_sq(profile: Sequence[int]) -> Fraction:
    """Exact squared Spearman resolution ceiling of a tie profile.

    ceil(L) = 1 - (cube(L) - n) / (n^3 - n),  requires n >= 2.
    """
    n = sample_size(profile)
    if n < 2:
        raise ValueError("profile must have sample size at least 2")
    return Fraction(1) - Fraction(cube_sum(profile) - n, n ** 3 - n)


def ceiling_rho(profile: Sequence[int]) -> float:
    """Resolution ceiling in correlation units, rho_max = sqrt(ceil)."""
    return sqrt(float(ceiling_sq(profile)))


# ----------------------------------------------------------------------------
# 2. The two profiles, from first principles and in closed form
# ----------------------------------------------------------------------------


def trailing_zeros(x: int) -> int:
    """2-adic valuation v_2(x) of a positive integer; v_2(0) is treated as +infinity."""
    if x == 0:
        raise ValueError("v_2(0) is not finite")
    return (x & -x).bit_length() - 1


def dyadic_profile(b: int) -> List[int]:
    """Closed-form tie profile of the trailing-zero dial on Z/2^b: (2^(b-1),...,2,1,1)."""
    return [2 ** (b - 1 - k) for k in range(b)] + [1]


def dyadic_profile_bruteforce(b: int) -> List[int]:
    """Recompute the dyadic profile by direct enumeration of Z/2^b (small b only)."""
    counts: Dict[int, int] = {}
    for x in range(2 ** b):
        v = b if x == 0 else trailing_zeros(x)
        counts[v] = counts.get(v, 0) + 1
    return [counts[v] for v in sorted(counts)]


def dyadic_ceiling_closed_form(b: int) -> Fraction:
    """(6/7)(1 + 1/(N(N+1))) with N = 2^b."""
    n = 2 ** b
    return Fraction(6, 7) * (Fraction(1) + Fraction(1, n * (n + 1)))


def qr_profile(m: int) -> List[int]:
    """Closed-form tie profile of the QR indicator mod the odd prime 2m+1: (m, m+1)."""
    return [m, m + 1]


def qr_profile_bruteforce(p: int) -> List[int]:
    """Recompute the QR profile by enumerating squares mod p (0 counted as a square)."""
    squares = {(a * a) % p for a in range(p)}
    n_sq = len(squares)
    return [p - n_sq, n_sq]


# ----------------------------------------------------------------------------
# 3. Legendre towers: vector profiles and count profiles
# ----------------------------------------------------------------------------


def product_profile(a: Sequence[int], b: Sequence[int]) -> List[int]:
    """Tie profile of a pair of CRT-independent statistics: all pairwise products."""
    return [x * y for x in a for y in b]


def qr_vector_profile(ms: Sequence[int]) -> List[int]:
    """Tie profile of the joint Legendre VECTOR over the primes 2*m_i+1."""
    out: List[int] = [1]
    for m in reversed(ms):
        out = product_profile(qr_profile(m), out)
    return out


def qr_count_profile(ms: Sequence[int]) -> List[int]:
    """Tie profile of the Legendre COUNT: coefficients of prod_i ((m_i+1) + m_i z)."""
    coeffs: List[int] = [1]
    for m in ms:
        a, b = m, m + 1
        new = [0] * (len(coeffs) + 1)
        for i, c in enumerate(coeffs):
            new[i] += b * c
            new[i + 1] += a * c
        coeffs = new
    return coeffs


def qr_count_profile_bruteforce(primes: Sequence[int]) -> List[int]:
    """Recompute the count profile by CRT enumeration over prod(primes) residues."""
    modulus = 1
    for p in primes:
        modulus *= p
    squares = [{(a * a) % p for a in range(p)} for p in primes]
    counts: Dict[int, int] = {}
    for x in range(modulus):
        k = sum(1 for p, sq in zip(primes, squares) if (x % p) not in sq)
        counts[k] = counts.get(k, 0) + 1
    return [counts.get(k, 0) for k in range(len(primes) + 1)]


# ----------------------------------------------------------------------------
# 4. The gap audit
# ----------------------------------------------------------------------------


def gap_audit(bitlen: int, t: float, q: float) -> Tuple[float, float, float, float]:
    """Return (rho_max_dial, rho_max_qr, geometric_budget, forced_slack).

    The geometric budget G is the largest advantage tie granularity alone can
    produce; the forced slack S = (t - q) - G is how far below its own ceiling the
    baseline reading must lie.  S > 0 certifies genuine signal.
    """
    rho_dial = ceiling_rho(dyadic_profile(bitlen))
    rho_qr = sqrt(0.75)  # exact for every odd prime, by prime independence
    budget = rho_dial - rho_qr
    return rho_dial, rho_qr, budget, (t - q) - budget


# ----------------------------------------------------------------------------
# Presentation helpers
# ----------------------------------------------------------------------------


def rule(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


def show(label: str, value: Fraction, width: int = 46) -> None:
    print(f"  {label:<{width}} {str(value):>18}  = {float(value):.12f}")


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def demo_cube_sum_calculus() -> None:
    rule("1.  The cube-sum calculus")
    print("  ceil(L) = 1 - (cube(L) - n)/(n^3 - n);  12*T(L) = cube(L) - n.\n")
    for profile in ([1, 1, 1, 1], [2, 2], [3, 1], [4], [2, 1, 1]):
        n = sample_size(profile)
        print(
            f"  profile {str(profile):<14} n={n:<3} cube={cube_sum(profile):<5}"
            f" 12T={str(12*tie_correction(profile)):<5} ceil={str(ceiling_sq(profile)):>8}"
            f"  rho_max={ceiling_rho(profile):.6f}"
        )
    print("\n  Coarsening check: merging blocks raises the cube sum, lowers the ceiling.")
    fine, coarse = [2, 1, 1], [2, 2]
    print(
        f"    {fine} -> {coarse}:  cube {cube_sum(fine)} -> {cube_sum(coarse)},"
        f"  ceil {ceiling_sq(fine)} -> {ceiling_sq(coarse)}"
    )
    assert cube_sum(fine) <= cube_sum(coarse)
    assert ceiling_sq(coarse) <= ceiling_sq(fine)


def demo_dyadic_ceiling() -> None:
    rule("2.  The dyadic ceiling:  6/7 (1 + 1/(N(N+1))),  N = 2^b")
    print(f"  {'b':>3}  {'ceil (exact)':>26}  {'ceil - 6/7':>14}  {'rho_max':>10}")
    for b in (2, 3, 4, 8, 16, 44, 48, 52):
        c = ceiling_sq(dyadic_profile(b))
        assert c == dyadic_ceiling_closed_form(b), "closed form must match"
        shown = str(c) if b <= 8 else f"{float(c):.15f}"
        print(f"  {b:>3}  {shown:>26}  {float(c - Fraction(6,7)):>14.3e}  {sqrt(float(c)):>10.7f}")
    print("\n  Brute-force cross-check of the profile for small b:")
    for b in (2, 3, 4, 5):
        bf = sorted(dyadic_profile_bruteforce(b), reverse=True)
        cf = sorted(dyadic_profile(b), reverse=True)
        assert bf == cf, (b, bf, cf)
        print(f"    b={b}: enumerated {bf}  ==  closed form {cf}")


def demo_prime_independence() -> None:
    rule("3.  Prime independence:  ceil(Q_m) = 3/4 EXACTLY, for every odd prime")
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 97, 1009, 65537, 2 ** 61 - 1]
    print(f"  {'p':>22}  {'profile (m, m+1)':>28}  {'ceil':>8}")
    for p in primes:
        m = (p - 1) // 2
        prof = qr_profile(m)
        c = ceiling_sq(prof)
        assert c == Fraction(3, 4), f"prime independence failed at p={p}"
        prof_shown = f"({m}, {m+1})" if p < 10 ** 6 else f"(~{m:.3e}, ...)".replace("e+", "e")
        print(f"  {p:>22}  {prof_shown:>28}  {str(c):>8}")
    print("\n  Arithmetic bridge, verified by enumeration (squares include 0):")
    for p in (3, 5, 7, 11, 13, 17, 19, 23):
        non_sq, sq = qr_profile_bruteforce(p)
        assert sq == non_sq + 1 == (p + 1) // 2
        print(f"    p={p:>3}:  {sq} squares, {non_sq} non-squares   (squares = non-squares + 1)")
    print(f"\n  rho_max(QR) = sqrt(3)/2 = {sqrt(0.75):.10f}, independent of the modulus.")


def demo_tower_and_collapse() -> None:
    rule("4-5.  Multiplicative tower law and the counting collapse")
    cases: List[Tuple[List[int], List[int]]] = [
        ([3], [1]),
        ([3, 5], [1, 2]),
        ([3, 5, 7], [1, 2, 3]),
        ([3, 5, 7, 11], [1, 2, 3, 5]),
        ([5, 13], [2, 6]),
    ]
    print(f"  {'primes':>18} {'N':>7} {'ceil(vector)':>14} {'ceil(count)':>14}  {'loss':>9}")
    for primes, ms in cases:
        vec, cnt = qr_vector_profile(ms), qr_count_profile(ms)
        assert sample_size(vec) == sample_size(cnt)
        cv, cc = ceiling_sq(vec), ceiling_sq(cnt)
        assert cc <= cv, "counting collapse violated"
        # Multiplicative tower law, checked against the CRT product formula.
        big_n = 1
        big_c = 1
        for m in ms:
            big_n *= 2 * m + 1
            big_c *= m ** 3 + (m + 1) ** 3
        assert cv == Fraction(1) - Fraction(big_c - big_n, big_n ** 3 - big_n)
        print(
            f"  {str(primes):>18} {sample_size(vec):>7} {str(cv):>14} {str(cc):>14}"
            f"  {float(cv - cc):>9.6f}"
        )
    print("\n  Brute-force CRT check of the count profile:")
    for primes, ms in (([3, 5], [1, 2]), ([3, 5, 7], [1, 2, 3])):
        bf = qr_count_profile_bruteforce(primes)
        cf = qr_count_profile(ms)
        assert sorted(bf) == sorted(cf), (primes, bf, cf)
        print(f"    primes {primes}: enumerated {bf}  ==  convolution {cf}")


def demo_crossover() -> None:
    rule("6.  The crossover hierarchy at bit-length 48")
    d48 = ceiling_sq(dyadic_profile(48))
    rows = [
        ("one Legendre symbol (any odd p)", ceiling_sq(qr_profile(1))),
        ("two symbols (3,5), counted", ceiling_sq(qr_count_profile([1, 2]))),
        ("TRAILING-ZERO DIAL, 48 bits", d48),
        ("three symbols (3,5,7), counted", ceiling_sq(qr_count_profile([1, 2, 3]))),
        ("two symbols (3,5), as a vector", ceiling_sq(qr_vector_profile([1, 2]))),
        ("two symbols at 3, as a vector", ceiling_sq(qr_vector_profile([1, 1]))),
    ]
    print(f"  {'baseline':<36} {'ceil (exact)':>14} {'ceil':>10} {'rho_max':>10}  vs dial")
    for name, c in rows:
        exact = str(c) if c.denominator < 10 ** 6 else "6/7 + eps"
        verdict = "---" if name.startswith("TRAILING") else ("ABOVE" if c > d48 else "below")
        print(f"  {name:<36} {exact:>14} {float(c):>10.6f} {sqrt(float(c)):>10.6f}  {verdict}")
    assert ceiling_sq(qr_profile(1)) < ceiling_sq(qr_count_profile([1, 2])) < d48
    assert d48 < ceiling_sq(qr_count_profile([1, 2, 3])) < ceiling_sq(qr_vector_profile([1, 2]))
    print(
        "\n  => three COUNTED symbols, but only two VECTOR symbols, out-resolve the dial."
    )


def demo_replicated_tower() -> None:
    rule("7.  The replicated-symbol tower at the prime 3")
    print("  ceil = 1 - (9^r - 3^r)/(27^r - 3^r)  >=  1 - 2/3^r\n")
    print(f"  {'r':>3} {'N=3^r':>10} {'ceil (exact)':>18} {'ceil':>12} {'bound 1-2/3^r':>15}")
    for r in range(1, 9):
        prof = qr_vector_profile([1] * r) if r <= 12 else None
        closed = Fraction(1) - Fraction(9 ** r - 3 ** r, 27 ** r - 3 ** r)
        if prof is not None:
            assert ceiling_sq(prof) == closed
        bound = Fraction(1) - Fraction(2, 3 ** r)
        assert bound <= closed
        exact = str(closed) if closed.denominator < 10 ** 7 else f"{float(closed):.12f}"
        print(f"  {r:>3} {3**r:>10} {exact:>18} {float(closed):>12.9f} {float(bound):>15.9f}")


def demo_gap_law() -> None:
    rule("8.  The gap law and the forced-slack audit of the recorded readings")
    rho_dial = ceiling_rho(dyadic_profile(48))
    rho_qr = sqrt(0.75)
    print(f"  rho_max(dial, 48 bits) = sqrt(6/7 + eps) = {rho_dial:.10f}")
    print(f"  rho_max(bare QR count) = sqrt(3)/4^(1/2) = {rho_qr:.10f}")
    print(f"  geometric budget G     =                   {rho_dial - rho_qr:.10f}  (< 0.06)")
    assert rho_dial - rho_qr < 0.06
    print("\n  Recorded round-52 readings (uniform draws, bit-length 48):")
    print(
        f"  {'seed':>10} {'rho(T)':>8} {'advantage':>10} {'implied rho(QR)':>16}"
        f" {'forced slack':>13} {'rho/rho_max':>12}"
    )
    readings = [("20261080", 0.777), ("20261081", 0.755), ("20261082", 0.801)]
    for seed, t in readings:
        for adv in (0.09, 0.13):
            q = t - adv
            _, _, budget, slack = gap_audit(48, t, q)
            assert q ** 2 < 0.75, "implied QR reading must respect its own ceiling"
            assert t ** 2 < float(ceiling_sq(dyadic_profile(48)))
            assert slack > 0.03 - 1e-12
            print(
                f"  {seed:>10} {t:>8.3f} {adv:>10.2f} {q:>16.3f}"
                f" {slack:>13.4f} {t/rho_dial:>12.4f}"
            )
    print("\n  Every forced slack exceeds 0.03: the recorded advantage is NOT tie geometry.")


def demo_calibration() -> None:
    rule("9.  Band-saturation asymmetry and envelope flatness")
    band_low, band_high = 0.55, 0.85
    rho_dial = ceiling_rho(dyadic_profile(48))
    rho_qr = sqrt(0.75)
    print(f"  validation band = [{band_low}, {band_high}]")
    print(f"    headroom above band top for the QR baseline: {rho_qr - band_high:.6f}  (< 0.017)")
    print(f"    headroom above band top for the dial:        {rho_dial - band_high:.6f}  (> 0.07)")
    assert rho_qr - band_high < 0.017
    assert rho_dial - band_high > 0.07
    print("\n  Envelope flatness across bit-lengths 44-52:")
    c44, c52 = ceiling_sq(dyadic_profile(44)), ceiling_sq(dyadic_profile(52))
    print(f"    ceil(44) - ceil(52) = {float(c44 - c52):.6e}   (bound 2^-80 = {2.0**-80:.3e})")
    assert c52 < c44 and float(c44 - c52) < 2.0 ** -80
    print("    strictly decreasing, but by less than 2^-80: bit-length effects are")
    print("    substantive, not geometric.")


def main() -> None:
    print(__doc__)
    demo_cube_sum_calculus()
    demo_dyadic_ceiling()
    demo_prime_independence()
    demo_tower_and_collapse()
    demo_crossover()
    demo_replicated_tower()
    demo_gap_law()
    demo_calibration()
    rule("All assertions passed.")


if __name__ == "__main__":
    main()
