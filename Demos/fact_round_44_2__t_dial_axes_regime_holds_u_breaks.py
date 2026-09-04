"""Threshold operating-point audit against the block ceiling.

Given a population size, a flagged-block size, and a pre-registered correlation
floor, decides whether the floor is attainable at all -- and, if not, reports the
loosest threshold (largest flag rate) at which it becomes attainable.
"""

from __future__ import annotations

from fractions import Fraction
from math import sqrt
from typing import Dict, Optional, Union


def block_ceiling_squared(n: int, m: int) -> Fraction:
    """Exact ceiling 3 m (n - m) / (n^2 - 1) on the squared correlation.

    No statistic and no ranking can exceed this: the flagged block of size m can
    carry at most the m largest ranks and at least the m smallest, which bounds
    the covariance with any rank vector, and the two variances are fixed.
    """
    if not 0 < m < n:
        raise ValueError("need 0 < m < n")
    return Fraction(3 * m * (n - m), n * n - 1)


def largest_feasible_flag_rate(n: int, floor: float, tol: float = 1e-12) -> Optional[float]:
    """Largest flag rate p <= 1/2 at which the correlation floor is attainable.

    The ceiling p -> 3 p (1 - p) n^2 / (n^2 - 1) is strictly increasing on
    [0, 1/2], so a bisection converges monotonically.  Returns None when even a
    50 % flag rate cannot reach the floor.  O(log(1/tol)) evaluations.
    """
    target = floor * floor
    peak = 3.0 * 0.25 * n * n / (n * n - 1)
    if peak < target:
        return None
    lo, hi = 0.0, 0.5
    while hi - lo > tol:
        mid = 0.5 * (lo + hi)
        if 3.0 * mid * (1.0 - mid) * n * n / (n * n - 1) < target:
            lo = mid
        else:
            hi = mid
    return hi


def audit_operating_point(n: int, m: int, floor: float) -> Dict[str, Union[int, float, bool, str, None]]:
    """Full audit of a thresholded dial at a given operating point.

    Reports the exact squared ceiling, the implied bound on |r|, whether the
    pre-registered floor is reachable in principle, and a recommendation.
    """
    cap_sq = block_ceiling_squared(n, m)
    cap = sqrt(float(cap_sq))
    feasible = cap >= floor
    p_max = largest_feasible_flag_rate(n, floor)
    if feasible:
        recommendation = "deploy: the floor is attainable at this operating point"
    elif p_max is None:
        recommendation = ("recalibrate the band: the floor exceeds the global maximum "
                          f"{sqrt(3.0 * 0.25 * n * n / (n * n - 1)):.4f} at any flag rate")
    else:
        recommendation = (f"do not deploy: loosen the threshold to a flag rate of at least "
                          f"{p_max:.4f} ({int(round(p_max * n))} of {n}), or recalibrate the band")
    return {
        "n": n,
        "m": m,
        "flag_rate": m / n,
        "ceiling_squared_exact": str(cap_sq),
        "ceiling_squared": float(cap_sq),
        "ceiling_abs_r": cap,
        "floor": floor,
        "floor_reachable": feasible,
        "largest_feasible_flag_rate": p_max,
        "recommendation": recommendation,
    }


if __name__ == "__main__":
    for n, m, floor in [(100, 30, 0.71), (100, 10, 0.71), (100, 50, 0.90)]:
        a = audit_operating_point(n, m, floor)
        print(f"n = {a['n']}, m = {a['m']} (p = {a['flag_rate']:.2f}), floor = {a['floor']}")
        print(f"   ceiling |r| <= {a['ceiling_abs_r']:.4f}  "
              f"(r^2 <= {a['ceiling_squared_exact']})")
        print(f"   {a['recommendation']}")
        print()


"""Inversion counting by merge sort, with a Diaconis-Graham certificate.

Counts inverted pairs in O(n log n) and returns the full sandwich of ranking
metrics together with the inequalities that relate them.
"""

from __future__ import annotations

from typing import Dict, List, Sequence, Tuple, Union


def count_inversions(values: Sequence[int]) -> int:
    """Number of pairs i < j with values[i] > values[j], in O(n log n).

    Standard merge sort: while merging two sorted halves, emitting an element of
    the right half when k elements remain unemitted in the left half accounts for
    exactly k inversions, since every one of those k exceeds it.
    """

    def sort_count(arr: List[int]) -> Tuple[List[int], int]:
        if len(arr) <= 1:
            return arr, 0
        mid = len(arr) // 2
        left, cl = sort_count(arr[:mid])
        right, cr = sort_count(arr[mid:])
        merged: List[int] = []
        total = cl + cr
        i = j = 0
        while i < len(left) and j < len(right):
            if left[i] <= right[j]:
                merged.append(left[i])
                i += 1
            else:
                merged.append(right[j])
                j += 1
                total += len(left) - i
        merged.extend(left[i:])
        merged.extend(right[j:])
        return merged, total

    return sort_count(list(values))[1]


def cayley_length(sigma: Sequence[int]) -> int:
    """Minimal number of transpositions expressing sigma, in O(n).

    Equal to (number of non-fixed points) minus (number of nontrivial cycles).
    """
    n = len(sigma)
    seen = [False] * n
    moved = 0
    cycles = 0
    for start in range(n):
        if seen[start]:
            continue
        length = 0
        j = start
        while not seen[j]:
            seen[j] = True
            j = sigma[j]
            length += 1
        if length > 1:
            moved += length
            cycles += 1
    return moved - cycles


def diaconis_graham_certificate(sigma: Sequence[int]) -> Dict[str, Union[int, bool]]:
    """All three ranking metrics of sigma against the identity, plus their relations.

    Returns the footrule F, the squared distance D, the inversion number, the
    Cayley length T, and the status of:

      F <= D <= (n-1) F        (l^1 and l^2 readings are equivalent)
      F^2 <= n D               (Cauchy-Schwarz refinement)
      F <= 2 * inv             (Diaconis-Graham upper bound; constant 2 is sharp)
      inv + T <= F             (Diaconis-Graham lower bound; verified small n)
      D <= 2 (n-1) inv         (l^2 bound from purely combinatorial data)
    """
    n = len(sigma)
    footrule = sum(abs(v - i) for i, v in enumerate(sigma))
    squared = sum((v - i) ** 2 for i, v in enumerate(sigma))
    inv = count_inversions(sigma)
    cayley = cayley_length(sigma)
    return {
        "n": n,
        "footrule": footrule,
        "sum_d2": squared,
        "inversions": inv,
        "cayley": cayley,
        "l1_le_l2": footrule <= squared,
        "l2_le_scaled_l1": squared <= (n - 1) * footrule,
        "cauchy_schwarz": footrule ** 2 <= n * squared,
        "dg_upper": footrule <= 2 * inv,
        "dg_upper_tight": footrule == 2 * inv,
        "dg_lower": inv + cayley <= footrule,
        "combinatorial_l2_bound": squared <= 2 * (n - 1) * inv,
    }


if __name__ == "__main__":
    for sigma in [(0, 1, 2, 3), (1, 0, 2, 3), (2, 3, 1, 0), (3, 2, 1, 0)]:
        c = diaconis_graham_certificate(sigma)
        print(f"sigma = {sigma}:  F = {c['footrule']:2d}  sum d^2 = {c['sum_d2']:2d}  "
              f"inv = {c['inversions']:2d}  T = {c['cayley']:2d}   "
              f"F <= 2 inv: {c['dg_upper']}   inv + T <= F: {c['dg_lower']}")


"""Exact Spearman reading with a parity audit.

Computes the raw statistic, the footrule, the exact rational correlation, and the
rigidity-gap diagnostic in a single O(n) pass over two rank vectors.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Dict, Sequence, Union


def spearman_exact(sigma: Sequence[int], tau: Sequence[int]) -> Dict[str, Union[int, Fraction, bool, str]]:
    """Exact Spearman reading of two tie-free rank vectors of the same length.

    Both arguments must be permutations of {0, 1, ..., n-1}.  Returns the raw
    statistic ``sum_d2``, the footrule ``F``, the exact rational correlation
    ``rho``, the rigidity gap ``gap = 12/(n^3-n)``, and two audits:

    * ``parity_ok`` -- ``sum_d2`` must be even, because the displacement vector
      sums to zero and ``x^2`` has the parity of ``x``.  An odd value can only
      arise from ties or a non-bijective rank assignment, i.e. from a bug.
    * ``verdict``   -- whether the reading lies inside the forbidden window
      ``(1 - gap, 1)``, which is impossible, or equals 1, which certifies that
      the two rankings are literally identical.
    """
    n = len(sigma)
    if n != len(tau):
        raise ValueError("rank vectors must have equal length")
    if sorted(sigma) != list(range(n)) or sorted(tau) != list(range(n)):
        raise ValueError("both arguments must be permutations of {0, ..., n-1}")
    if n < 2:
        raise ValueError("need at least two items")

    sum_d2 = 0
    footrule = 0
    for a, b in zip(sigma, tau):
        d = a - b
        sum_d2 += d * d
        footrule += d if d >= 0 else -d

    denominator = n ** 3 - n
    rho = Fraction(1) - Fraction(6 * sum_d2, denominator)
    gap = Fraction(12, denominator)
    diameter = n * (n * n - 1) // 3

    if rho == 1:
        verdict = "identical rankings"
    elif rho > 1 - gap:
        verdict = "IMPOSSIBLE: reading inside the rigidity gap"
    elif rho == -1:
        verdict = "antipodal: the two rankings are exact reverses"
    else:
        verdict = "ordinary reading"

    return {
        "n": n,
        "sum_d2": sum_d2,
        "footrule": footrule,
        "rho": rho,
        "rho_float": float(rho),
        "gap": gap,
        "diameter": diameter,
        "parity_ok": sum_d2 % 2 == 0,
        "diameter_ok": sum_d2 <= diameter,
        "verdict": verdict,
    }


if __name__ == "__main__":
    for name, s, t in [
        ("identical", (0, 1, 2, 3, 4), (0, 1, 2, 3, 4)),
        ("one adjacent swap", (1, 0, 2, 3, 4), (0, 1, 2, 3, 4)),
        ("reversed", (4, 3, 2, 1, 0), (0, 1, 2, 3, 4)),
        ("scrambled", (2, 4, 0, 3, 1), (0, 1, 2, 3, 4)),
    ]:
        out = spearman_exact(s, t)
        print(f"{name:>18}:  sum d^2 = {out['sum_d2']:3d}   F = {out['footrule']:3d}   "
              f"rho = {str(out['rho']):>6} = {out['rho_float']:+.4f}   {out['verdict']}")


#!/usr/bin/env python3
"""Assemble PACKAGE.json from the project files, so the bundle can never drift."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Geometry/SpearmanPermutohedronGap.lean",
    "Catalog/Geometry/SpearmanFootruleInversions.lean",
    "Catalog/Geometry/SpearmanThresholdCeiling.lean",
    "Catalog/Geometry/SpearmanNullMean.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== FILE: {f} =====\n\n{read(ROOT / f)}" for f in LEAN_FILES
)

FUTURE_DIRECTIONS = """# Future directions — geometry of the Spearman `T`-dial (round-44 #2, exp 499)

This cycle re-founded the `T`-dial's Spearman reading on permutohedron geometry.  Four
compiling, sorry-free files were added under `Catalog/Geometry/`:

* `SpearmanPermutohedronGap.lean` — the dial as a chordal distance between cospherical
  vertices; the exact diameter; the parity/quantisation invariant and the rigidity gap
  `12/(n^3 - n)`; the identity "Spearman = Pearson of the ranks".
* `SpearmanFootruleInversions.lean` — the `l^1` face: the footrule as a right-invariant metric
  and length function, `F <= D <= (n-1)F`, `F^2 <= nD`, and the Diaconis–Graham upper bound
  `F <= 2*inv`.
* `SpearmanThresholdCeiling.lean` — the block ceiling `corr^2 <= 3m(n-m)/(n^2-1)`: a *structural*
  explanation of the "u breaks" axis, with the numeric consequence that at a 10 % flagged
  fraction the pre-registered `0.71` floor is unreachable.
* `SpearmanNullMean.lean` — the ensemble is exactly unbiased: `sum_sigma sprho sigma 1 = 0`, with
  the exact first moment `E[sum d^2] = (n^3 - n)/6`.

What survived, what failed, and why:

* **Survived (true and provable).**  Everything that is a *cosphericity* consequence: the
  quantisation gap, the diameter, the Pearson identity, the null mean.  These all reduce to the
  single structural fact that the `n!` rank vectors lie on one sphere inside one hyperplane, so
  `sum d^2` is affine in the inner product.
* **Survived (harder, but provable).**  The Diaconis–Graham *upper* bound `F <= 2*inv`.  The
  working proof is a two-sided displacement count: `sigma(i) - i` forced right-inversions and
  `i - sigma(i)` forced left-inversions, then the two groupings of the inversion set are matched
  by exchanging the order of summation.
* **Not settled (true but hard).**  The Diaconis–Graham *lower* bound `inv + T <= F`.  Two
  natural routes fail for identifiable reasons: bubble-sort induction fails because an adjacent
  transposition can change `F` by `0` while changing `inv` by `1`; per-index charging fails
  because `#{j > i : sigma(j) < sigma(i)}` is not bounded by `(sigma(i) - i)^+` (witness
  `sigma = [2,3,1,0]` at `i = 2`).  A genuinely global argument is needed.  Verified exhaustively
  for `n <= 6`.
* **Needed a different definition.**  The "threshold" axis could not be modelled as a
  perturbation of a permutation at all; it had to be modelled as a *two-block* variable, at
  which point the ceiling `3p(1-p)` appears and is sharp.

---

## Direction 1 — Diaconis–Graham lower bound as a permutohedron facet inequality

**The key insight is** that `inv sigma + T sigma <= F sigma 1` should be read not as a
combinatorial identity but as the statement that the linear functional `sigma -> F sigma 1`
dominates the sum of two *independent* word-length functions on `S_n` — the Coxeter length
(`inv`) and the Cayley length (`T`) — and both are subadditive length functions for which `F` is
already known (subadditivity of the footrule, and the exact transposition cost `2|a-b|`) to be a
length function too.

**Why now?**  The footrule development supplies exactly the missing infrastructure: subadditivity
and the exact cost of a transposition give strong control over `F` along transposition
factorisations, which is precisely what a global exchange argument needs.  Success would close the
sandwich and give mutual bi-Lipschitz equivalence of the three classical ranking metrics with
explicit constants.

## Direction 2 — k-block and quantile coarsening ceilings

Generalise the block ceiling from a two-block indicator to an arbitrary `k`-block quantile
bucketing with profile `(m_1, ..., m_k)`.  The extremal fibre-sum argument goes through verbatim;
what is needed is the right normalisation, after which one should recover `3p(1-p)` at `k = 2` and
`1` in the limit `k = n`.  This would give an operational "resolution versus attainable
correlation" curve for any bucketing scheme.

## Direction 3 — ties and the permutohedron of a composition

Extend the parity invariant and the rigidity gap to tied data, where rank vectors lie on faces of
the permutohedron rather than at vertices.  The expected outcome is a gap of the form
`12/(n^3 - n - sum_t (t^3 - t))`, matching the classical tie correction to Spearman's coefficient,
with a geometric derivation.

## Direction 4 — quantisation and exact tests

Since the reading takes only `O(n^3)` distinct values, exact permutation tests on small `n` have an
atomically supported null distribution.  Combining the exact null mean with the quantisation grid
should yield exact, non-asymptotic critical values and, in particular, exact rather than
conservative p-values for small-`n` rank tests.

## Direction 5 — dynamic thresholds

The block ceiling is static, but in practice the operating point drifts and the flag rate with it.
One would like a bound on the achievable correlation of a *time-averaged* dial in terms of the
trajectory `p(t)`; concavity of `p -> 3p(1-p)` suggests the average ceiling is bounded by the
ceiling of the average flag rate, which would make a fluctuating threshold strictly worse than its
mean.
"""

package = {
    "title": "Rank Correlation as Chordal Distance on the Permutohedron: "
             "Quantisation, Metric Equivalence, and a Ceiling for Thresholded Statistics",
    "domain": "Geometry",
    "description": (
        "Spearman's rank correlation on n tie-free items is a rescaled squared Euclidean distance "
        "between two vertices of the permutohedron; cosphericity of those vertices forces the "
        "statistic to be an even integer, yields a forbidden window of width 12/(n^3-n) just below 1, "
        "an exact diameter n(n^2-1)/3, and an exactly zero null mean. Coarsening the data by a "
        "threshold that flags a fraction p of items caps the attainable correlation at "
        "sqrt(3p(1-p)) for every statistic, which explains structurally why a correlation "
        "acceptance band survives changes of population size but fails systematically when the "
        "threshold is tightened."
    ),
    "authors": ["Aristotle"],
    "date": "2026-09-04",
    "key_results": [
        "Spearman-Pearson identity: the normalisation 1 - 6*sum(d^2)/(n^3-n) is exactly the "
        "Pearson correlation coefficient of the two rank vectors, a consequence of the fact that "
        "all n! rank vectors lie on a common sphere inside a common hyperplane.",
        "Rigidity gap theorem: the raw statistic sum(d^2) is always even, so distinct rankings "
        "are separated by at least 2 and no attainable rank correlation lies in the open interval "
        "(1 - 12/(n^3-n), 1); a reading in that window certifies that the two rankings coincide.",
        "Exact diameter: the reversal ranking is the antipode of the permutohedron, realising "
        "max sum(d^2) = n(n^2-1)/3, and the reading -1 occurs precisely at that diameter.",
        "Exact unbiasedness: the uniform ensemble of rankings has first moment "
        "E[sum(d^2)] = (n^3-n)/6 and the rank correlations sum to exactly zero at every finite n, "
        "not merely asymptotically.",
        "Metric equivalence and the Diaconis-Graham upper bound: Spearman's footrule is a "
        "right-invariant metric and a length function with F(swap(a,b)) = 2|a-b|, satisfying "
        "F <= sum(d^2) <= (n-1)F, F^2 <= n*sum(d^2), and F <= 2*inv with the constant 2 sharp.",
        "Block ceiling for thresholded statistics: flagging m of n items caps the squared "
        "correlation with any ranking at 3m(n-m)/(n^2-1), approximately 3p(1-p); at a 10 % flag "
        "rate this bounds |r| by 0.520, making a 0.71 acceptance floor unreachable in principle.",
    ],
    "keywords": [
        "permutohedron",
        "Spearman rank correlation",
        "Spearman's footrule",
        "inversions",
        "Diaconis-Graham inequality",
        "point-biserial correlation",
        "quantisation gap",
        "symmetric group",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "Complete Verification Suite for the Permutohedron Geometry of Rank Correlation",
            "description": (
                "Exhaustively verifies every theorem of the development in exact rational "
                "arithmetic. Enumerates the symmetric group for n up to 7 and confirms: the "
                "cosphericity of rank vectors (constant coordinate sum n(n-1)/2 and constant "
                "squared norm n(n-1)(2n-1)/6); the chordal identity sum(d^2) = 2(R - inner "
                "product); right-invariance of the statistic under relabelling; the "
                "Spearman-Pearson identity 12(n<s,t> - L^2) = n^2(n^2-1)rho; the parity invariant "
                "and the resulting quantisation of the dial, printing the attainable spectrum and "
                "the width of the forbidden window near 1; the exact diameter n(n^2-1)/3 realised "
                "by the reversal; exact unbiasedness (the readings sum to zero and E[sum d^2] = "
                "(n^3-n)/6); the metric comparisons F <= D <= (n-1)F and F^2 <= nD; the "
                "Diaconis-Graham upper bound F <= 2*inv together with a count of the rankings "
                "where it is tight; the conjectural lower bound inv + T <= F (checked on all of "
                "S_n for n <= 7) and an explicit witness for why per-index charging cannot prove "
                "it; and finally the block ceiling, verified to be attained exactly by exhaustive "
                "search at n = 5, followed by a table of ceilings against flag rate and a full "
                "audit of the calibration study's operating point."
            ),
            "code": read(ROOT / "demo.py"),
        },
        {
            "name": "Exact Null Distribution and Non-Asymptotic Critical Values from the Quantisation Grid",
            "description": (
                "Builds the exact null distribution of the rank correlation by enumerating the "
                "symmetric group, exploiting the fact that the statistic is supported on a finite "
                "grid of even squared distances. For each n from 3 to 8 it reports the size of the "
                "support, the exact first moment (n^3-n)/6, the identically-zero sum of readings, "
                "the largest attainable reading below 1 (verified equal to 1 - 12/(n^3-n)), and "
                "the exact 5 % critical value together with the level actually achieved -- a "
                "discrepancy that no normal approximation can see. It closes by printing the full "
                "null distribution at n = 6, all 36 atoms with their probabilities and upper-tail "
                "masses. Every assertion is checked in exact rational arithmetic."
            ),
            "code": read(A / "demo_exact_null.py"),
        },
    ],
    "algorithms": [
        {
            "name": "Exact Rational Evaluation of the Rank Correlation with Parity and Rigidity Audit",
            "description": (
                "Computes, in a single O(n) pass over two rank vectors and with O(1) extra space, "
                "the raw statistic sum(d^2), Spearman's footrule, and the exact rational value of "
                "the correlation 1 - 6 sum(d^2)/(n^3 - n). Two structural audits ride along at no "
                "cost. The parity audit uses the theorem that the displacement vector between two "
                "permutohedron vertices sums to zero, forcing sum(d^2) to be even: an odd value "
                "cannot arise from valid tie-free rankings and therefore diagnoses a bug (ties, or "
                "a non-bijective rank assignment). The rigidity audit compares the reading against "
                "the forbidden window (1 - 12/(n^3-n), 1), which contains no attainable value; a "
                "reading inside it is impossible, and a reading equal to 1 certifies that the two "
                "rankings are literally identical. Rational arithmetic throughout means the output "
                "is exact, with no floating-point drift in the tail where the gap lives."
            ),
            "pseudocode": (
                "INPUT   sigma, tau : permutations of {0, ..., n-1},  n >= 2\n"
                "OUTPUT  sum_d2, footrule, rho (exact rational), audits\n"
                "\n"
                "1.  assert len(sigma) = len(tau) = n and both are bijections onto {0,...,n-1}\n"
                "2.  sum_d2   <- 0\n"
                "3.  footrule <- 0\n"
                "4.  for i = 0 to n-1 do\n"
                "5.        d        <- sigma[i] - tau[i]\n"
                "6.        sum_d2   <- sum_d2 + d*d\n"
                "7.        footrule <- footrule + |d|\n"
                "8.  denom    <- n^3 - n\n"
                "9.  rho      <- 1 - Fraction(6 * sum_d2, denom)          // exact\n"
                "10. gap      <- Fraction(12, denom)\n"
                "11. diameter <- n(n^2 - 1)/3\n"
                "12. parity_ok   <- (sum_d2 mod 2 = 0)                    // theorem: always true\n"
                "13. diameter_ok <- (sum_d2 <= diameter)                  // theorem: always true\n"
                "14. if   rho = 1            then verdict <- 'identical rankings'\n"
                "15. elif rho > 1 - gap      then verdict <- 'IMPOSSIBLE: inside the rigidity gap'\n"
                "16. elif rho = -1           then verdict <- 'antipodal: exact reverses'\n"
                "17. else                         verdict <- 'ordinary reading'\n"
                "18. return (sum_d2, footrule, rho, gap, diameter, parity_ok, diameter_ok, verdict)\n"
                "\n"
                "COMPLEXITY  time O(n), space O(1) beyond the inputs."
            ),
            "code": read(A / "algo_spearman_exact.py"),
        },
        {
            "name": "Merge-Sort Inversion Counting with a Full Diaconis-Graham Certificate",
            "description": (
                "Counts inverted pairs in O(n log n) rather than the naive Theta(n^2), and returns "
                "the complete sandwich of ranking metrics with the inequalities that bind them. The "
                "inversion count is obtained by instrumenting merge sort: when merging two sorted "
                "halves, emitting an element of the right half while k elements remain unemitted in "
                "the left half accounts for exactly k inversions, since each of those k exceeds it. "
                "The Cayley length -- the minimum number of transpositions expressing the "
                "permutation -- is computed in O(n) by cycle decomposition as (number of non-fixed "
                "points) minus (number of nontrivial cycles). The certificate then reports the "
                "status of five relations: the two-sided comparison F <= sum(d^2) <= (n-1)F, the "
                "Cauchy-Schwarz refinement F^2 <= n sum(d^2), the Diaconis-Graham upper bound "
                "F <= 2 inv with a flag for tightness, the still-open lower bound inv + T <= F, and "
                "the derived Euclidean bound sum(d^2) <= 2(n-1) inv, which controls an l^2 quantity "
                "using purely combinatorial disorder data. Overall complexity O(n log n) time and "
                "O(n) space."
            ),
            "pseudocode": (
                "FUNCTION count_inversions(values):\n"
                "  1.  if len(values) <= 1 then return (values, 0)\n"
                "  2.  mid <- len(values) / 2\n"
                "  3.  (L, cL) <- count_inversions(values[0 : mid])\n"
                "  4.  (R, cR) <- count_inversions(values[mid : end])\n"
                "  5.  merged <- empty; total <- cL + cR; i <- 0; j <- 0\n"
                "  6.  while i < |L| and j < |R| do\n"
                "  7.        if L[i] <= R[j] then append L[i]; i <- i + 1\n"
                "  8.        else                 append R[j]; j <- j + 1; total <- total + (|L| - i)\n"
                "  9.  append the remaining tails of L and R\n"
                " 10.  return (merged, total)\n"
                "\n"
                "FUNCTION cayley_length(sigma):\n"
                " 11.  seen <- all false; moved <- 0; cycles <- 0\n"
                " 12.  for start = 0 to n-1 do\n"
                " 13.        if seen[start] then continue\n"
                " 14.        len <- 0; j <- start\n"
                " 15.        while not seen[j] do  seen[j] <- true;  j <- sigma[j];  len <- len + 1\n"
                " 16.        if len > 1 then moved <- moved + len; cycles <- cycles + 1\n"
                " 17.  return moved - cycles\n"
                "\n"
                "FUNCTION certificate(sigma):\n"
                " 18.  F     <- sum over i of |sigma[i] - i|\n"
                " 19.  D     <- sum over i of (sigma[i] - i)^2\n"
                " 20.  inv   <- count_inversions(sigma)\n"
                " 21.  T     <- cayley_length(sigma)\n"
                " 22.  return { F, D, inv, T,\n"
                "               F <= D,  D <= (n-1)*F,  F^2 <= n*D,\n"
                "               F <= 2*inv,  F = 2*inv,  inv + T <= F,\n"
                "               D <= 2*(n-1)*inv }\n"
                "\n"
                "COMPLEXITY  time O(n log n), space O(n)."
            ),
            "code": read(A / "algo_inversions_dg.py"),
        },
        {
            "name": "Pre-Flight Feasibility Audit of a Thresholded Dial Against the Block Ceiling",
            "description": (
                "Decides, before any data is collected, whether a pre-registered correlation floor "
                "is attainable at a proposed threshold. The mathematical foundation is the block "
                "ceiling: a flagged block of size m receives m distinct ranks, so its total rank is "
                "trapped between the sum of the m smallest and the sum of the m largest ranks, "
                "which bounds its covariance with any rank vector; dividing by the two fixed "
                "variances gives r^2 <= 3m(n-m)/(n^2-1), a bound that holds for every statistic and "
                "every ranking and is attained. Evaluating it is O(1) in exact rational arithmetic. "
                "When the floor is unreachable, the audit reports the loosest threshold that would "
                "restore feasibility, by bisecting the ceiling function on [0, 1/2] where it is "
                "strictly increasing -- O(log(1/tol)) evaluations, monotone convergence. A separate "
                "branch detects the case where the floor exceeds the global maximum sqrt(3)/2 "
                "attained at a 50 % flag rate, in which case no threshold can help and the "
                "acceptance band itself must be recalibrated."
            ),
            "pseudocode": (
                "FUNCTION block_ceiling_squared(n, m):\n"
                "  1.  require 0 < m < n\n"
                "  2.  return Fraction(3*m*(n - m), n^2 - 1)               // exact, O(1)\n"
                "\n"
                "FUNCTION largest_feasible_flag_rate(n, floor, tol):\n"
                "  3.  target <- floor^2\n"
                "  4.  peak   <- 3 * (1/4) * n^2 / (n^2 - 1)               // ceiling at p = 1/2\n"
                "  5.  if peak < target then return NONE                   // no threshold suffices\n"
                "  6.  lo <- 0;  hi <- 1/2\n"
                "  7.  while hi - lo > tol do                              // ceiling increasing on [0,1/2]\n"
                "  8.        mid <- (lo + hi)/2\n"
                "  9.        if 3*mid*(1 - mid)*n^2/(n^2 - 1) < target then lo <- mid else hi <- mid\n"
                " 10.  return hi\n"
                "\n"
                "FUNCTION audit_operating_point(n, m, floor):\n"
                " 11.  cap_sq   <- block_ceiling_squared(n, m)\n"
                " 12.  cap      <- sqrt(cap_sq)\n"
                " 13.  feasible <- (cap >= floor)\n"
                " 14.  p_max    <- largest_feasible_flag_rate(n, floor, 1e-12)\n"
                " 15.  if feasible          then recommend 'deploy'\n"
                " 16.  elif p_max = NONE    then recommend 'recalibrate the band'\n"
                " 17.  else                      recommend 'loosen threshold to flag rate >= p_max'\n"
                " 18.  return (cap_sq, cap, feasible, p_max, recommendation)\n"
                "\n"
                "COMPLEXITY  O(1) per ceiling evaluation; O(log(1/tol)) for the bisection."
            ),
            "code": read(A / "algo_ceiling_audit.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Hexagon and the Quantised Dial: Attainable Readings and the Forbidden Window",
            "description": (
                "A two-panel figure. The left panel draws the permutohedron of three items -- a "
                "regular hexagon whose six corners are the six rankings of {0,1,2}, with solid "
                "edges joining rankings that differ by one adjacent swap and dashed diagonals "
                "joining reversed pairs, which sit at the exact diameter sum(d^2) = 8 = n(n^2-1)/3. "
                "The right panel enumerates, for n from 3 to 7, every attainable value of the rank "
                "correlation and plots them as a discrete grid. Because the raw statistic is always "
                "an even integer, the grid is coarse, and the open window of width 12/(n^3-n) "
                "immediately below 1 is empty; that window is shaded in red and its width printed. "
                "The figure makes visible, at a glance, that 'almost perfect agreement' is a "
                "discrete rather than a continuous notion on finite data."
            ),
            "code": read(A / "viz_quantisation.py"),
        },
        {
            "name": "The Block Ceiling: How Tightening a Threshold Makes an Acceptance Band Unreachable",
            "description": (
                "A two-panel figure. The left panel plots the exact ceiling "
                "sqrt(3m(n-m)/(n^2-1)) on the correlation between a two-block indicator flagging m "
                "of n items and any ranking, as a function of the flagged fraction, for a "
                "population of 100 strata. An acceptance band [0.71, 0.76] is drawn, the region "
                "where the ceiling falls below the band floor is shaded as structurally infeasible, "
                "and the two operating points of the calibration study are marked -- one comfortably "
                "above the floor at a 30 % flag rate, the other at 0.520 and demonstrably below it "
                "at 10 %. The right panel is a sharpness check: for a population of six items it "
                "compares, for every block size, the closed-form ceiling against an exhaustive "
                "maximisation over all blocks of that size and all 720 rankings. The two coincide "
                "at every point, so the bound is attained and cannot be improved."
            ),
            "code": read(A / "viz_ceiling.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Ranking Laboratory: A Walk on the Permutohedron",
            "description": (
                "An interactive workbench for building intuition about rankings as points. Choose "
                "a population size from 3 to 10 and rearrange the ranking by clicking pairs of "
                "cells, or use the shortcuts for a random shuffle, a single adjacent swap, or a "
                "jump to the antipode. Four readings update live -- the squared travel sum(d^2), "
                "the footrule, the inversion count, and the transposition length -- alongside the "
                "exact rational value of the rank correlation. A checklist shows, in real time, the "
                "seven inequalities that bind them, including the parity of sum(d^2), the "
                "comparisons F <= sum(d^2) <= (n-1)F, the Cauchy-Schwarz refinement, the "
                "Diaconis-Graham upper bound and its open lower companion. A number line displays "
                "every attainable value of the correlation, with the current ranking highlighted "
                "and the forbidden window near 1 shaded in red -- the user can try, and fail, to "
                "land in it. At n = 3 a geometric panel draws the hexagon itself with the current "
                "corner marked; at larger n it draws the displacement profile, colour-coded by "
                "direction, which is precisely the quantity the Diaconis-Graham double count "
                "charges to inversions."
            ),
            "html": read(A / "widget_ranking_lab.html"),
        },
        {
            "title": "The Threshold Ceiling: Watching an Acceptance Band Become Unreachable",
            "description": (
                "An interactive exploration of the central operational result. Drag a threshold "
                "across a score distribution and watch the flagged fraction shrink; a live panel "
                "reports the exact ceiling sqrt(3m(n-m)/(n^2-1)) on the correlation between the "
                "resulting flag and any ranking, and delivers a verdict against a user-adjustable "
                "acceptance floor -- attainable, or structurally unreachable for every statistic. A "
                "second sliding control varies the population size, and a third the floor itself. "
                "The main chart plots the full ceiling curve with the infeasible operating regions "
                "shaded and the current point marked, showing clearly the peak of sqrt(3)/2 at a "
                "50 % flag rate and the symmetric collapse on either side. A reference table gives "
                "the ceiling at standard flag rates with a per-row verdict. Two progressive-"
                "disclosure panels reveal, on demand, the full derivation of the ceiling from the "
                "extremal block sums, and the empirical story it explains: a dial insensitive to "
                "eleven binary orders of magnitude in population size that nonetheless failed on "
                "every seed when the threshold was tightened."
            ),
            "html": read(A / "widget_threshold_ceiling.html"),
        },
    ],
    "interactive_layout": read(A / "interactive_layout.md"),
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {
        "demo": read(ROOT / "demo.py"),
        "demo_exact_null": read(A / "demo_exact_null.py"),
        "algo_spearman_exact": read(A / "algo_spearman_exact.py"),
        "algo_inversions_dg": read(A / "algo_inversions_dg.py"),
        "algo_ceiling_audit": read(A / "algo_ceiling_audit.py"),
        "viz_quantisation": read(A / "viz_quantisation.py"),
        "viz_ceiling": read(A / "viz_ceiling.py"),
    },
    "lean_files": LEAN_FILES,
}


def main() -> None:
    out = ROOT / "PACKAGE.json"
    out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"wrote {out} ({out.stat().st_size} bytes)")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Exact null distribution of the rank correlation from its quantisation grid.

Because a rank correlation is a chordal distance between corners of the
permutohedron, its null distribution is supported on a finite, explicitly
computable grid of EVEN squared distances.  This demo builds that distribution by
exhaustive enumeration and uses it to produce exact -- not asymptotic -- critical
values and p-values for the one-sided test "the two rankings agree".

It also confirms, at each n, the two exact moment facts:

    sum over all rankings of rho  =  0        (the dial is unbiased, identically)
    E[sum d^2]                    =  (n^3 - n)/6

and displays the rigidity gap: the largest attainable rho below 1 is exactly
1 - 12/(n^3 - n), so the open window just below 1 carries no probability at all.

Standard library only.
"""

from __future__ import annotations

from collections import Counter
from fractions import Fraction
from itertools import permutations
from typing import Dict, List, Tuple


def squared_distance(sigma: Tuple[int, ...], tau: Tuple[int, ...]) -> int:
    """Raw Spearman statistic sum d^2 between two rank vectors."""
    return sum((a - b) ** 2 for a, b in zip(sigma, tau))


def null_distribution(n: int) -> Counter:
    """Exact distribution of sum d^2 against the identity, over all n! rankings."""
    ident = tuple(range(n))
    return Counter(squared_distance(s, ident) for s in permutations(range(n)))


def rho_of(d: int, n: int) -> Fraction:
    """The Spearman reading corresponding to a raw statistic d."""
    return Fraction(1) - Fraction(6 * d, n ** 3 - n)


def exact_critical_value(n: int, alpha: Fraction) -> Tuple[Fraction, Fraction]:
    """Smallest rho whose upper-tail probability is at most alpha, and that probability.

    The support is finite, so the achieved level is generally strictly below the
    nominal alpha; both are returned, which is exactly the information an
    asymptotic approximation throws away.
    """
    dist = null_distribution(n)
    total = sum(dist.values())
    # walk the grid from rho = 1 downwards, i.e. from d = 0 upwards
    cumulative = 0
    best = (Fraction(1), Fraction(0))
    for d in sorted(dist):
        cumulative += dist[d]
        level = Fraction(cumulative, total)
        if level > alpha:
            break
        best = (rho_of(d, n), level)
    return best


def main() -> None:
    print(__doc__)
    alpha = Fraction(5, 100)
    print(f"{'n':>3} {'|S_n|':>7} {'support':>8} {'E[sum d^2]':>12} {'sum rho':>9} "
          f"{'max rho < 1':>12} {'1 - gap':>10} {'exact 5% crit':>15} {'achieved':>10}")
    print("-" * 96)
    for n in range(3, 9):
        dist = null_distribution(n)
        total = sum(dist.values())
        mean_d = Fraction(sum(d * c for d, c in dist.items()), total)
        sum_rho = sum(rho_of(d, n) * c for d, c in dist.items())
        second = min(d for d in dist if d > 0)
        gap = Fraction(12, n ** 3 - n)
        crit, achieved = exact_critical_value(n, alpha)

        assert all(d % 2 == 0 for d in dist), "parity invariant violated"
        assert mean_d == Fraction(n ** 3 - n, 6), "first moment wrong"
        assert sum_rho == 0, "null mean is not exactly zero"
        assert rho_of(second, n) == 1 - gap, "rigidity gap not attained"

        print(f"{n:>3} {total:>7} {len(dist):>8} {str(mean_d):>12} {str(sum_rho):>9} "
              f"{float(rho_of(second, n)):>12.5f} {float(1 - gap):>10.5f} "
              f"{float(crit):>15.5f} {float(achieved):>10.5f}")

    print()
    print("Every assertion above is exact rational arithmetic:")
    print("  * the support consists only of EVEN squared distances;")
    print("  * the mean of sum d^2 is exactly (n^3 - n)/6;")
    print("  * the readings sum to exactly zero over the whole ensemble;")
    print("  * the largest reading below 1 is exactly 1 - 12/(n^3 - n).")
    print()
    print("Consequence for testing: the achieved level of a nominal 5% test differs")
    print("from 5% by an amount that is visible in the table and that no normal")
    print("approximation can see. On a quantised grid, exact tests are available.")

    print()
    n = 6
    dist = null_distribution(n)
    total = sum(dist.values())
    print(f"Full null distribution at n = {n} ({total} rankings):")
    print(f"  {'sum d^2':>8} {'rho':>9} {'count':>7} {'P':>9} {'upper tail':>11}")
    cum = 0
    for d in sorted(dist):
        cum += dist[d]
        print(f"  {d:>8} {float(rho_of(d, n)):>9.4f} {dist[d]:>7} "
              f"{dist[d] / total:>9.5f} {cum / total:>11.5f}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualisation: the block ceiling sqrt(3p(1-p)) and the failure of a tightened threshold.

Produces a two-panel figure.

LEFT  — the exact ceiling sqrt(3m(n-m)/(n^2-1)) on the correlation between a two-block
        indicator flagging m of n items and ANY ranking, plotted against the flagged
        fraction p = m/n.  The acceptance band [0.71, 0.76] is drawn; the region where
        the ceiling falls below the band floor is shaded as structurally infeasible.
        Two illustrative operating points are marked: a looser cut flagging 30 % of
        items, and a tighter cut flagging 10 %.

RIGHT — exhaustive verification at n = 6: for every block size m, the maximum squared
        point-biserial correlation over all blocks of that size and all 720 rankings,
        plotted against the closed-form ceiling.  They coincide: the bound is sharp.

Requires matplotlib.  Writes block_ceiling.png.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations, permutations
from math import sqrt
from typing import List, Sequence, Tuple

import matplotlib.pyplot as plt


def lin_sum(n: int) -> int:
    """L(n) = 0 + 1 + ... + (n-1)."""
    return n * (n - 1) // 2


def block_cov(sigma: Sequence[int], block: Sequence[int]) -> int:
    """Un-normalised covariance n * sum_{i in B} sigma(i) - |B| * L(n)."""
    n = len(sigma)
    return n * sum(sigma[i] for i in block) - len(block) * lin_sum(n)


def pb_corr_sq(sigma: Sequence[int], block: Sequence[int]) -> Fraction:
    """Squared point-biserial correlation between the indicator of B and rk sigma."""
    n, m = len(sigma), len(block)
    return Fraction(12 * block_cov(sigma, block) ** 2,
                    n ** 2 * m * (n - m) * (n ** 2 - 1))


def ceiling(n: int, m: int) -> float:
    """The exact ceiling on |r| for a block of size m out of n."""
    return sqrt(3.0 * m * (n - m) / (n ** 2 - 1))


def exhaustive_max(n: int, m: int) -> float:
    """Maximum attainable |r| over all blocks of size m and all rankings of n items."""
    best = Fraction(0)
    perms = list(permutations(range(n)))
    for block in combinations(range(n), m):
        for sigma in perms:
            v = pb_corr_sq(sigma, block)
            if v > best:
                best = v
    return sqrt(float(best))


def main() -> None:
    fig, (axL, axR) = plt.subplots(1, 2, figsize=(13.5, 5.3))
    fig.patch.set_facecolor("#ffffff")

    # ---- left: the ceiling curve ------------------------------------------
    n = 100
    ps = [m / n for m in range(1, n)]
    caps = [ceiling(n, m) for m in range(1, n)]
    floor, top = 0.71, 0.76

    axL.plot(ps, caps, color="#2f6f9f", lw=2.6, label=r"ceiling $\sqrt{3m(n-m)/(n^2-1)}$")
    axL.axhspan(floor, top, color="#4ea36a", alpha=0.18, label="acceptance band [0.71, 0.76]")
    axL.axhline(floor, color="#b4453f", lw=1.6, ls="--")

    infeasible = [p for p, c in zip(ps, caps) if c < floor]
    if infeasible:
        axL.fill_between([p for p in ps if p <= max(x for x in infeasible if x < 0.5)],
                         0, 1, color="#e26d6d", alpha=0.10)
    axL.fill_between([p for p in ps if p >= min(x for x in infeasible if x > 0.5)],
                     0, 1, color="#e26d6d", alpha=0.10)

    for label, p in (("looser cut", 0.30), ("tighter cut", 0.10)):
        m = round(p * n)
        c = ceiling(n, m)
        axL.scatter([p], [c], s=90, zorder=4,
                    color="#4ea36a" if c >= floor else "#b4453f")
        axL.annotate(f"{label}\n$|r|\\leq{c:.3f}$", (p, c), xytext=(8, -34),
                     textcoords="offset points", fontsize=9.5)

    axL.set_xlim(0, 1)
    axL.set_ylim(0, 1)
    axL.set_xlabel("flagged fraction $p = m/n$")
    axL.set_ylabel("largest attainable $|r|$")
    axL.set_title("Thresholding caps the correlation\n"
                  "shaded red: acceptance floor unreachable for any statistic", fontsize=11)
    axL.legend(loc="lower center", fontsize=9)
    for side in ("top", "right"):
        axL.spines[side].set_visible(False)

    # ---- right: exhaustive sharpness check --------------------------------
    nn = 6
    ms = list(range(1, nn))
    exact = [ceiling(nn, m) for m in ms]
    found = [exhaustive_max(nn, m) for m in ms]
    axR.plot(ms, exact, "o-", color="#2f6f9f", lw=2.2, ms=9,
             label=r"closed-form ceiling $\sqrt{3m(n-m)/(n^2-1)}$")
    axR.plot(ms, found, "x", color="#b4453f", ms=13, mew=2.6,
             label=f"exhaustive maximum over all blocks and all {nn}! rankings")
    axR.set_xticks(ms)
    axR.set_xlabel(f"block size $m$   (n = {nn})")
    axR.set_ylabel("largest attainable $|r|$")
    axR.set_ylim(0, 1)
    axR.set_title("The ceiling is sharp, not an estimate\n"
                  "every point is attained by an explicit block and ranking", fontsize=11)
    axR.legend(loc="lower center", fontsize=9)
    for side in ("top", "right"):
        axR.spines[side].set_visible(False)

    fig.tight_layout()
    fig.savefig("block_ceiling.png", dpi=170)
    print("wrote block_ceiling.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualisation: the quantised Spearman dial and the permutohedron hexagon.

Produces a two-panel figure.

LEFT  — the hexagon Pi_2, the permutohedron of three items.  Its six vertices are
        the six rankings of {0,1,2}; edges join rankings differing by one adjacent
        swap.  Opposite vertices are reversed rankings, at squared distance 8, the
        exact diameter n(n^2-1)/3.

RIGHT — the attainable values of Spearman's rho for n = 3..7, obtained by exhaustive
        enumeration.  Every value comes from an EVEN squared distance, so the grid
        has a visible hole: the open window (1 - 12/(n^3-n), 1) is empty.  That
        window is shaded; a reading inside it would certify that the two rankings
        are literally identical.

Requires matplotlib.  Writes spearman_quantisation.png.
"""

from __future__ import annotations

from itertools import permutations
from math import cos, pi, sin
from typing import Dict, List, Sequence, Set, Tuple

import matplotlib.pyplot as plt


def squared_distance(sigma: Sequence[int], tau: Sequence[int]) -> int:
    """Raw Spearman statistic sum d^2 between two rank vectors."""
    return sum((a - b) ** 2 for a, b in zip(sigma, tau))


def attainable_rho(n: int) -> List[float]:
    """All values of rho = 1 - 6D/(n^3-n) realised by some ranking against identity."""
    ident = tuple(range(n))
    values: Set[int] = {squared_distance(s, ident) for s in permutations(range(n))}
    return sorted(1.0 - 6.0 * d / (n ** 3 - n) for d in values)


def hexagon_layout() -> Tuple[List[Tuple[int, int, int]], Dict[int, Tuple[float, float]]]:
    """The six rankings of three items, arranged so neighbours are adjacent swaps."""
    ring: List[Tuple[int, int, int]] = [
        (0, 1, 2), (0, 2, 1), (2, 0, 1), (2, 1, 0), (1, 2, 0), (1, 0, 2)
    ]
    pos = {i: (cos(-pi / 2 + i * pi / 3), sin(-pi / 2 + i * pi / 3)) for i in range(6)}
    return ring, pos


def main() -> None:
    fig, (axL, axR) = plt.subplots(1, 2, figsize=(13.5, 5.6))
    fig.patch.set_facecolor("#ffffff")

    # ---- left: the hexagon -------------------------------------------------
    ring, pos = hexagon_layout()
    for i in range(6):
        x1, y1 = pos[i]
        x2, y2 = pos[(i + 1) % 6]
        axL.plot([x1, x2], [y1, y2], color="#9aa7b8", lw=2, zorder=1)
    # the three long diagonals: antipodal (reversed) pairs, at the diameter
    for i in range(3):
        x1, y1 = pos[i]
        x2, y2 = pos[i + 3]
        axL.plot([x1, x2], [y1, y2], color="#e26d6d", lw=1.2, ls="--", zorder=1)
    for i, p in enumerate(ring):
        x, y = pos[i]
        axL.scatter([x], [y], s=230, color="#2f6f9f", zorder=3)
        axL.annotate(f"({p[0]},{p[1]},{p[2]})", (x, y), xytext=(0, 20),
                     textcoords="offset points", ha="center", fontsize=11)
    d_opposite = squared_distance(ring[0], ring[3])
    axL.set_title("The permutohedron $\\Pi_2$: all six rankings of three items\n"
                  f"dashed diagonals are reversed pairs at the diameter $\\sum d^2 = {d_opposite}"
                  " = n(n^2-1)/3$", fontsize=11)
    axL.set_xlim(-1.55, 1.55)
    axL.set_ylim(-1.5, 1.6)
    axL.set_aspect("equal")
    axL.axis("off")

    # ---- right: the quantisation grid -------------------------------------
    for row, n in enumerate(range(3, 8)):
        vals = attainable_rho(n)
        gap = 12.0 / (n ** 3 - n)
        axR.hlines(row, -1.03, 1.03, color="#dde3ea", lw=1)
        axR.scatter(vals, [row] * len(vals), s=16, color="#2f6f9f", zorder=3)
        axR.add_patch(plt.Rectangle((1 - gap, row - 0.28), gap, 0.56,
                                    color="#e26d6d", alpha=0.35, zorder=2))
        axR.text(-1.10, row, f"$n={n}$", ha="right", va="center", fontsize=11)
        axR.text(1.06, row, f"gap {gap:.3f}", ha="left", va="center",
                 fontsize=9, color="#b4453f")
    axR.set_xlim(-1.35, 1.30)
    axR.set_ylim(-0.7, 4.7)
    axR.set_yticks([])
    axR.set_xticks([-1, -0.5, 0, 0.5, 1])
    axR.set_xlabel("Spearman's $\\rho$")
    axR.set_title("Attainable readings are a discrete grid\n"
                  "shaded: the forbidden window $(1-12/(n^3-n),\\,1)$", fontsize=11)
    for side in ("top", "right", "left"):
        axR.spines[side].set_visible(False)

    fig.tight_layout()
    fig.savefig("spearman_quantisation.png", dpi=170)
    print("wrote spearman_quantisation.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Rank Correlation as Chordal Distance on the Permutohedron
=========================================================

Self-contained numerical demonstration of every result in the accompanying
paper.  No third-party dependencies; standard library only.

A tie-free ranking of n items is a permutation sigma of {0, ..., n-1}.  Its
rank vector (sigma(0), ..., sigma(n-1)) is a vertex of the permutohedron
Pi_{n-1} in R^n.  We verify, by exhaustive enumeration for small n and by
closed-form evaluation for large n:

  1.  Cosphericity        sum sigma(i) = n(n-1)/2,  sum sigma(i)^2 = n(n-1)(2n-1)/6
  2.  Chordal form        D = 2(R(n) - <sigma, tau>)
  3.  Right invariance    D(sigma*pi, tau*pi) = D(sigma, tau)
  4.  Spearman = Pearson  12(n<sigma,tau> - L(n)^2) = n^2(n^2-1) rho
  5.  Parity              D is always even; hence D >= 2 for distinct rankings
  6.  Rigidity gap        rho <= 1 - 12/(n^3 - n) for distinct rankings
  7.  Diameter            max D = n(n^2 - 1)/3, attained only by the reversal
  8.  Exact null mean     sum_sigma rho(sigma, id) = 0;  E[D] = (n^3 - n)/6
  9.  Metric comparison   F <= D <= (n-1)F  and  F^2 <= n D
 10.  Diaconis-Graham     F(sigma) <= 2 inv(sigma), sharp at adjacent swaps
 11.  DG lower bound      inv(sigma) + T(sigma) <= F(sigma)   (checked, n <= 7)
 12.  Block ceiling       r^2 <= 3 m (n-m)/(n^2 - 1) ~ 3p(1-p)
"""

from __future__ import annotations

from fractions import Fraction
from itertools import permutations
from math import sqrt
from typing import List, Sequence, Set, Tuple

Perm = Tuple[int, ...]


# ---------------------------------------------------------------------------
# Section 0.  Basic permutation utilities
# ---------------------------------------------------------------------------


def identity(n: int) -> Perm:
    """The identity ranking on n items."""
    return tuple(range(n))


def reversal(n: int) -> Perm:
    """The reversal ranking i -> n-1-i: the antipode of the identity."""
    return tuple(n - 1 - i for i in range(n))


def compose(sigma: Perm, pi: Perm) -> Perm:
    """(sigma * pi)(i) = sigma(pi(i))."""
    return tuple(sigma[pi[i]] for i in range(len(pi)))


def inverse(sigma: Perm) -> Perm:
    """The inverse permutation."""
    out = [0] * len(sigma)
    for i, v in enumerate(sigma):
        out[v] = i
    return tuple(out)


def transposition(n: int, a: int, b: int) -> Perm:
    """The transposition swapping positions a and b."""
    out = list(range(n))
    out[a], out[b] = out[b], out[a]
    return tuple(out)


def lin_sum(n: int) -> int:
    """L(n) = 0 + 1 + ... + (n-1)."""
    return n * (n - 1) // 2


def norm_sq(n: int) -> int:
    """R(n) = 0^2 + 1^2 + ... + (n-1)^2."""
    return n * (n - 1) * (2 * n - 1) // 6


# ---------------------------------------------------------------------------
# Section 1.  The three readings of disagreement
# ---------------------------------------------------------------------------


def D(sigma: Perm, tau: Perm) -> int:
    """Raw Spearman statistic: squared Euclidean distance of rank vectors."""
    return sum((a - b) ** 2 for a, b in zip(sigma, tau))


def footrule(sigma: Perm, tau: Perm) -> int:
    """Spearman's footrule: the l^1 distance of rank vectors."""
    return sum(abs(a - b) for a, b in zip(sigma, tau))


def inner(sigma: Perm, tau: Perm) -> int:
    """Euclidean inner product of two rank vectors."""
    return sum(a * b for a, b in zip(sigma, tau))


def spearman_rho(sigma: Perm, tau: Perm) -> Fraction:
    """Spearman's rank correlation 1 - 6 D / (n^3 - n), computed exactly."""
    n = len(sigma)
    return Fraction(1) - Fraction(6 * D(sigma, tau), n ** 3 - n)


def inversions(sigma: Perm) -> int:
    """Number of inverted pairs, by merge sort in O(n log n)."""

    def sort_count(arr: List[int]) -> Tuple[List[int], int]:
        if len(arr) <= 1:
            return arr, 0
        mid = len(arr) // 2
        left, cl = sort_count(arr[:mid])
        right, cr = sort_count(arr[mid:])
        merged: List[int] = []
        count = cl + cr
        i = j = 0
        while i < len(left) and j < len(right):
            if left[i] <= right[j]:
                merged.append(left[i])
                i += 1
            else:
                # left[i:] are all greater than right[j]: that many inversions
                merged.append(right[j])
                j += 1
                count += len(left) - i
        merged.extend(left[i:])
        merged.extend(right[j:])
        return merged, count

    return sort_count(list(sigma))[1]


def cayley_length(sigma: Perm) -> int:
    """T(sigma): minimal number of transpositions, = #moved - #nontrivial cycles."""
    n = len(sigma)
    seen = [False] * n
    moved = 0
    cycles = 0
    for i in range(n):
        if seen[i]:
            continue
        length = 0
        j = i
        while not seen[j]:
            seen[j] = True
            j = sigma[j]
            length += 1
        if length > 1:
            moved += length
            cycles += 1
    return moved - cycles


# ---------------------------------------------------------------------------
# Section 2.  The block ceiling for thresholded statistics
# ---------------------------------------------------------------------------


def block_cov(sigma: Perm, block: Sequence[int]) -> int:
    """Un-normalised covariance n*sum_{i in B} sigma(i) - |B| * L(n)."""
    n = len(sigma)
    return n * sum(sigma[i] for i in block) - len(block) * lin_sum(n)


def pb_corr_sq(sigma: Perm, block: Sequence[int]) -> Fraction:
    """Squared point-biserial correlation between the indicator of B and rk sigma."""
    n = len(sigma)
    m = len(block)
    return Fraction(12 * block_cov(sigma, block) ** 2,
                    n ** 2 * m * (n - m) * (n ** 2 - 1))


def block_ceiling(n: int, m: int) -> Fraction:
    """The exact ceiling 3 m (n - m) / (n^2 - 1) on the squared correlation."""
    return Fraction(3 * m * (n - m), n ** 2 - 1)


def max_flag_fraction_for_floor(n: int, floor: float) -> float:
    """Largest flag rate p at which a correlation floor is attainable (bisection)."""
    target = floor ** 2
    if 3 * 0.25 * n ** 2 / (n ** 2 - 1) < target:
        return 0.0
    lo, hi = 0.0, 0.5
    for _ in range(80):
        mid = (lo + hi) / 2
        val = 3 * mid * (1 - mid) * n ** 2 / (n ** 2 - 1)
        if val < target:
            lo = mid
        else:
            hi = mid
    return hi


# ---------------------------------------------------------------------------
# Section 3.  Demonstrations
# ---------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_cosphericity(nmax: int = 7) -> None:
    banner("1. Cosphericity: all n! vertices share a hyperplane and a sphere")
    for n in range(2, nmax + 1):
        sums: Set[int] = set()
        sqs: Set[int] = set()
        for sigma in permutations(range(n)):
            sums.add(sum(sigma))
            sqs.add(sum(v * v for v in sigma))
        assert sums == {lin_sum(n)} and sqs == {norm_sq(n)}
        print(f"  n = {n}:  sum sigma(i) = {lin_sum(n):5d} (unique),"
              f"   sum sigma(i)^2 = {norm_sq(n):6d} (unique)")
    print("  -> the rank vectors are cospherical, so D is affine in <sigma, tau>.")


def demo_chordal_and_pearson(n: int = 6) -> None:
    banner("2-4. Chordal form, right invariance, and Spearman = Pearson")
    perms = list(permutations(range(n)))
    R = norm_sq(n)
    L = lin_sum(n)
    for sigma in perms[:400]:
        for tau in perms[:40]:
            assert D(sigma, tau) == 2 * (R - inner(sigma, tau))
            lhs = 12 * (n * inner(sigma, tau) - L * L)
            rhs = Fraction(n ** 2 * (n ** 2 - 1)) * spearman_rho(sigma, tau)
            assert Fraction(lhs) == rhs
    pi = perms[7 * len(perms) // 11]
    for sigma in perms[:200]:
        for tau in perms[:20]:
            assert D(compose(sigma, pi), compose(tau, pi)) == D(sigma, tau)
            assert D(sigma, tau) == D(compose(sigma, inverse(tau)), identity(n))
    print(f"  n = {n}:  D = 2(R(n) - <sigma,tau>)                        verified")
    print(f"  n = {n}:  D(sigma*pi, tau*pi) = D(sigma, tau)              verified")
    print(f"  n = {n}:  D(sigma,tau) = D(sigma tau^-1, id)               verified")
    print(f"  n = {n}:  12(n<sigma,tau> - L^2) = n^2(n^2-1) rho          verified")
    print("  -> the classical normalisation IS the Pearson coefficient of the ranks.")


def demo_quantisation(nmax: int = 7) -> None:
    banner("5-7. Quantisation, the rigidity gap, and the exact diameter")
    for n in range(3, nmax + 1):
        vals: Set[int] = set()
        idp = identity(n)
        for sigma in permutations(range(n)):
            vals.add(D(sigma, idp))
        assert all(v % 2 == 0 for v in vals), "parity violated"
        assert 1 not in vals
        diam = max(vals)
        assert 3 * diam == n * (n ** 2 - 1)
        assert D(reversal(n), idp) == diam
        # rigidity gap
        gap = Fraction(12, n ** 3 - n)
        second = min(v for v in vals if v > 0)
        best_nontrivial = Fraction(1) - Fraction(6 * second, n ** 3 - n)
        assert best_nontrivial <= 1 - gap
        missing = [v for v in range(0, diam + 1, 2) if v not in vals]
        shown = sorted(vals)[:8]
        print(f"  n = {n}:  attainable sum d^2 = {shown}{' ...' if len(vals) > 8 else ''}"
              f"   ({len(vals)} values; even values in [0, diam] never realised: "
              f"{missing if missing else 'none'})")
        print(f"          all even, 1 absent | diameter {diam} = n(n^2-1)/3"
              f" | gap 12/(n^3-n) = {float(gap):.6f}")
        print(f"          largest rho below 1 : {float(best_nontrivial):.6f}"
              f"  (= 1 - gap)")
    print("  -> no reading lies in the open window (1 - 12/(n^3-n), 1).")
    for n in (100, 1000, 10 ** 4):
        print(f"  n = {n:>6}: forbidden window width = {12 / (n ** 3 - n):.3e}")


def demo_null_mean(nmax: int = 7) -> None:
    banner("8. The dial is exactly unbiased: null mean zero, E[sum d^2] = (n^3-n)/6")
    for n in range(2, nmax + 1):
        idp = identity(n)
        total_D = 0
        total_rho = Fraction(0)
        count = 0
        for sigma in permutations(range(n)):
            total_D += D(sigma, idp)
            total_rho += spearman_rho(sigma, idp)
            count += 1
        assert 6 * total_D == count * (n ** 3 - n)
        assert total_rho == 0
        print(f"  n = {n}:  |S_n| = {count:5d}   sum_sigma sum d^2 = {total_D:8d}"
              f"   = |S_n|(n^3-n)/6   sum_sigma rho = {total_rho}")
    print("  -> exactly zero, at every finite n; not an asymptotic statement.")


def demo_metric_equivalence(nmax: int = 7) -> None:
    banner("9-11. Footrule, inversions, and the Diaconis-Graham sandwich")
    for n in range(2, nmax + 1):
        idp = identity(n)
        worst_lo = None  # tightness of F <= D
        worst_hi = None  # tightness of D <= (n-1) F
        dg_tight = 0
        dg_lower_ok = True
        for sigma in permutations(range(n)):
            f = footrule(sigma, idp)
            d = D(sigma, idp)
            iv = inversions(sigma)
            t = cayley_length(sigma)
            assert f <= d <= (n - 1) * f or sigma == idp
            assert f * f <= n * d
            assert f <= 2 * iv                      # Diaconis-Graham upper
            dg_lower_ok &= (iv + t <= f)            # Diaconis-Graham lower
            if f == 2 * iv and sigma != idp:
                dg_tight += 1
            if f > 0:
                ratio = Fraction(d, f)
                worst_lo = ratio if worst_lo is None else min(worst_lo, ratio)
                worst_hi = ratio if worst_hi is None else max(worst_hi, ratio)
        print(f"  n = {n}:  F <= D <= (n-1)F holds; observed D/F in "
              f"[{float(worst_lo):.3f}, {float(worst_hi):.3f}] (bound {n - 1})")
        print(f"          F^2 <= nD holds | F <= 2*inv holds, tight on "
              f"{dg_tight} nontrivial rankings")
        print(f"          conjectural lower bound inv + T <= F: "
              f"{'holds on all' if dg_lower_ok else 'FAILS on some'} of S_{n}")
    n = 3
    print(f"  sharpness at n = {n}: swap(0,1) has F = "
          f"{footrule(transposition(n, 0, 1), identity(n))}, 2*inv = "
          f"{2 * inversions(transposition(n, 0, 1))}  (equality)")
    print(f"                       swap(0,2) has F = "
          f"{footrule(transposition(n, 0, 2), identity(n))}, 2*inv = "
          f"{2 * inversions(transposition(n, 0, 2))}  (strict)")
    bad = (2, 3, 1, 0)
    print(f"  why per-index charging fails: sigma = {bad}, at i = 2 there is "
          f"1 right-inversion but sigma(2) - 2 = {bad[2] - 2}")


def demo_block_ceiling() -> None:
    banner("12. The block ceiling: thresholding caps the attainable correlation")
    # exhaustive sharpness check, n = 5
    n = 5
    print(f"  Exhaustive check, n = {n}: max over all rankings and blocks vs ceiling")
    for m in range(1, n):
        blocks = [tuple(b) for b in permutations(range(n), m)]
        seen: Set[Tuple[int, ...]] = set()
        best = Fraction(0)
        for b in blocks:
            key = tuple(sorted(b))
            if key in seen:
                continue
            seen.add(key)
            for sigma in permutations(range(n)):
                best = max(best, pb_corr_sq(sigma, key))
        ceil = block_ceiling(n, m)
        assert best <= ceil
        status = "ATTAINED" if best == ceil else "not attained"
        print(f"    m = {m}: max r^2 = {str(best):>8}   ceiling = {str(ceil):>8}"
              f"   ({status})")

    print()
    print("  Ceiling as a function of the flagged fraction p (asymptotic 3p(1-p)):")
    print("     p        ceiling on |r|     verdict against a 0.71 acceptance floor")
    for p in (0.50, 0.40, 0.30, 0.25, 0.21, 0.20, 0.15, 0.10, 0.05, 0.02):
        c = sqrt(3 * p * (1 - p))
        verdict = "reachable" if c >= 0.71 else "STRUCTURALLY UNREACHABLE"
        print(f"    {p:5.2f}        {c:6.4f}            {verdict}")

    print()
    n, m = 100, 10
    ceil = block_ceiling(n, m)
    print(f"  Operating point of the calibration study: n = {n} strata, m = {m} flagged")
    print(f"    exact ceiling r^2 <= {ceil} = {float(ceil):.5f},  |r| <= "
          f"{sqrt(float(ceil)):.4f}")
    print(f"    band floor 0.71 needs r^2 >= 0.5041, i.e. c^2(n^2-1) = "
          f"{0.71 ** 2 * (n ** 2 - 1):.1f} > 3m(n-m) = {3 * m * (n - m)}")
    print(f"    => the pre-registered band is unreachable for ANY statistic.")
    print(f"    observed worst reading 0.487 sits just below the ceiling "
          f"{sqrt(float(ceil)):.4f}: consistent, and not a sampling fluctuation.")
    print()
    pmax = max_flag_fraction_for_floor(100, 0.71)
    print(f"  Largest flag rate at which a 0.71 floor is attainable (n = 100): "
          f"p <= {pmax:.4f}")
    print(f"  Largest flag rate at which a 0.76 ceiling-of-band is attainable:  "
          f"p <= {max_flag_fraction_for_floor(100, 0.76):.4f}")


def demo_two_axes() -> None:
    banner("Summary: why one validation axis holds and the other breaks")
    print("  POPULATION AXIS.  rho is scale-free: the Pearson identity normalises")
    print("  by n, and the geometry of the permutohedron is identical at every n.")
    print("  Populations spanning 2^27 to 2^38 therefore give the same reading, up")
    print("  to sampling noise. Observed: 5/5 in band, mean 0.713 vs anchor 0.717.")
    print()
    print("  THRESHOLD AXIS.  A threshold does not perturb a ranking; it collapses")
    print("  one into a two-block indicator, and the ceiling sqrt(3p(1-p)) applies")
    print("  to EVERY statistic. Raising u shrinks p, lowering the ceiling until it")
    print("  passes below the band floor. Observed: 5/5 seeds degrade, worst 0.487.")
    print()
    print("  Illustrative flag rates (the ceiling depends on p alone):")
    for label, p in (("looser operating point ", 0.30), ("tighter operating point", 0.10)):
        print(f"    {label}: flag rate p = {p:.2f}  ->  ceiling |r| <= "
              f"{sqrt(3 * p * (1 - p)):.4f}")
    print()
    print("  Practical rule: before tightening a threshold, compute sqrt(3p(1-p)).")
    print("  If it is below your acceptance floor, no experiment is needed.")


def main() -> None:
    print(__doc__)
    demo_cosphericity()
    demo_chordal_and_pearson()
    demo_quantisation()
    demo_null_mean()
    demo_metric_equivalence()
    demo_block_ceiling()
    demo_two_axes()
    banner("All assertions passed.")


if __name__ == "__main__":
    main()
