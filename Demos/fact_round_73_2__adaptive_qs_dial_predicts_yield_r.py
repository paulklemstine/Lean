"""Allocation audit: predict every policy's yield in O(n) before spending anything.

Given a rate vector r (measured or predicted) and a budget B, the exact yields are

    uniform baseline      B * AM(r)
    inverse-rate policy   B * HM(r)          (always <= the baseline)
    clipped policy, floor f
                          B*n/T + f*(sum r - n^2/T),  T = sum 1/r
    concentrator/oracle   B * max(r)         (the exact supremum)

so the whole policy comparison is decided before any sieving occurs.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import List, Sequence


@dataclass(frozen=True)
class AllocationAudit:
    """Exact yields and diagnostics for a rate vector and a budget."""
    n: int
    budget: Fraction
    arithmetic_mean: Fraction
    harmonic_mean: Fraction
    max_rate: Fraction
    uniform_yield: Fraction
    inverse_rate_yield: Fraction
    oracle_yield: Fraction
    clip_slope: Fraction
    relative_loss_inverse: Fraction
    relative_headroom_oracle: Fraction


def allocation_audit(rates: Sequence[Fraction], budget: Fraction) -> AllocationAudit:
    """Compute all policy yields exactly.  Cost: O(n) rational operations."""
    if not rates:
        raise ValueError("empty rate vector")
    if any(r <= 0 for r in rates):
        raise ValueError("all rates must be strictly positive")
    n = len(rates)
    total = sum(rates, Fraction(0))
    total_inv = sum((1 / r for r in rates), Fraction(0))
    am = total / n
    hm = Fraction(n, 1) / total_inv
    mx = max(rates)
    return AllocationAudit(
        n=n,
        budget=budget,
        arithmetic_mean=am,
        harmonic_mean=hm,
        max_rate=mx,
        uniform_yield=budget * am,
        inverse_rate_yield=budget * hm,
        oracle_yield=budget * mx,
        clip_slope=total - Fraction(n * n, 1) / total_inv,
        relative_loss_inverse=1 - hm / am,
        relative_headroom_oracle=mx / am - 1,
    )


def clipped_yield(rates: Sequence[Fraction], budget: Fraction,
                  floor: Fraction) -> Fraction:
    """Yield of the clipped inverse-rate policy with floor `floor` (affine in floor)."""
    n = len(rates)
    total = sum(rates, Fraction(0))
    total_inv = sum((1 / r for r in rates), Fraction(0))
    return budget * n / total_inv + floor * (total - Fraction(n * n, 1) / total_inv)


def clip_line_samples(rates: Sequence[Fraction], budget: Fraction,
                      steps: int = 10) -> List[tuple]:
    """Sample the clip line from f = 0 (unclipped) to f = B/n (uniform baseline)."""
    n = len(rates)
    return [(budget / n * Fraction(k, steps),
             clipped_yield(rates, budget, budget / n * Fraction(k, steps)))
            for k in range(steps + 1)]


if __name__ == "__main__":
    r = [Fraction(1), Fraction(2), Fraction(5)]
    audit = allocation_audit(r, Fraction(3))
    print(audit)
    for f, y in clip_line_samples(r, Fraction(3), steps=5):
        print(f"  floor {f}  ->  yield {y} ({float(y):.4f})")


"""The discordance ledger: what an imperfect dial actually costs a deferral policy.

For a split of the targets into a retained set K and a deferred set D, the retention
deficit obeys the exact identity

    |K| * (total yield) - |s| * (kept yield)
        = sum over (j, i) in D x K of (r_j - r_i)
        = (paid inversion mass) - (earned concordance mass),

so the one-sided budget  deficit <= inversion mass  is tight exactly when the dial is
never right about a deferred/retained pair.  The inversion mass

    IM = sum over inverted pairs (j, i) of (r_j - r_i)

is never larger than the crude budget M * |Disc| and vanishes exactly for concordant
dials.  Complexity: O(n^2) for the pair enumeration, O(n) for the sums.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from itertools import product
from typing import List, Sequence, Tuple


@dataclass(frozen=True)
class Ledger:
    kept: List[int]
    deferred: List[int]
    deficit: Fraction
    paid_inversion_mass: Fraction
    earned_concordance_mass: Fraction
    global_inversion_mass: Fraction
    discordant_count: int
    crude_budget: Fraction
    identity_holds: bool
    budget_holds: bool


def discordant_pairs(dial: Sequence[Fraction],
                     rates: Sequence[Fraction]) -> List[Tuple[int, int]]:
    """Pairs (j, i) with d_j < d_i but r_i < r_j: the dial's ranking mistakes."""
    n = len(rates)
    return [(j, i) for j, i in product(range(n), repeat=2)
            if dial[j] < dial[i] and rates[i] < rates[j]]


def inversion_mass(dial: Sequence[Fraction], rates: Sequence[Fraction]) -> Fraction:
    return sum((rates[j] - rates[i] for j, i in discordant_pairs(dial, rates)),
               Fraction(0))


def ledger_at(dial: Sequence[Fraction], rates: Sequence[Fraction],
              theta: Fraction) -> Ledger:
    """Full paid/earned accounting for the threshold policy at `theta`."""
    n = len(rates)
    K = [i for i in range(n) if dial[i] >= theta]
    D = [i for i in range(n) if dial[i] < theta]
    paid = sum((max(rates[j] - rates[i], Fraction(0)) for j in D for i in K),
               Fraction(0))
    earned = sum((max(rates[i] - rates[j], Fraction(0)) for j in D for i in K),
                 Fraction(0))
    deficit = (Fraction(len(K)) * sum(rates, Fraction(0))
               - Fraction(n) * sum((rates[i] for i in K), Fraction(0)))
    im = inversion_mass(dial, rates)
    disc = discordant_pairs(dial, rates)
    crude = (max(rates) if rates else Fraction(0)) * len(disc)
    return Ledger(
        kept=K,
        deferred=D,
        deficit=deficit,
        paid_inversion_mass=paid,
        earned_concordance_mass=earned,
        global_inversion_mass=im,
        discordant_count=len(disc),
        crude_budget=crude,
        identity_holds=(deficit == paid - earned),
        budget_holds=(deficit <= im),
    )


if __name__ == "__main__":
    rates = [Fraction(10), Fraction(3), Fraction(2)]
    dial = [Fraction(10), Fraction(2), Fraction(3)]
    for theta in (Fraction(2), Fraction(3), Fraction(10)):
        print(theta, ledger_at(dial, rates, theta))


"""Minimum-work quota schedule by a single dial threshold.

Theory: among subsets of a fixed size, every maximiser of total rate is *separated*
(an exchange argument), so a minimum-work quota-feasible schedule may be taken
separated; and every separated set is exactly the threshold set at its own minimal
rate whenever the rate is injective (which holds on a factor base, where the rate is
2/p).  Hence sorting once and taking a prefix is optimal.

Complexity: O(n log n) for the sort, O(n) afterwards; contrast the 2^n subsets that
a naive search over schedules would consider.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List, Optional, Sequence, Tuple


def threshold_schedule(rates: Sequence[Fraction],
                       quota: Fraction) -> Optional[Tuple[List[int], Fraction]]:
    """Return (retained targets, threshold) of minimum size meeting the quota.

    Returns None if the quota is unattainable even by working on everything.
    """
    if sum(rates, Fraction(0)) < quota:
        return None
    order = sorted(range(len(rates)), key=lambda i: rates[i], reverse=True)
    running = Fraction(0)
    chosen: List[int] = []
    for i in order:
        chosen.append(i)
        running += rates[i]
        if running >= quota:
            break
    theta = min(rates[i] for i in chosen)
    keep = [i for i, r in enumerate(rates) if r >= theta]
    return keep, theta


def throughput(rates: Sequence[Fraction], subset: Sequence[int]) -> Fraction:
    """Relations per unit of work when work is proportional to |subset|."""
    if not subset:
        raise ValueError("empty schedule")
    return sum((rates[i] for i in subset), Fraction(0)) / len(subset)


def schedule_report(rates: Sequence[Fraction], quota: Fraction) -> str:
    """Human-readable before/after report for a quota-driven deferral."""
    result = threshold_schedule(rates, quota)
    if result is None:
        return f"quota {quota} unattainable (total rate {sum(rates, Fraction(0))})"
    keep, theta = result
    n = len(rates)
    total = sum(rates, Fraction(0))
    kept = sum((rates[i] for i in keep), Fraction(0))
    return (f"threshold {theta}: keep {len(keep)}/{n} targets "
            f"({float(len(keep) / n) * 100:.1f}% of the work), "
            f"retain {float(kept / total) * 100:.1f}% of the relations, "
            f"throughput {float(throughput(rates, range(n))):.4f} -> "
            f"{float(throughput(rates, keep)):.4f} "
            f"(+{float(throughput(rates, keep) / throughput(rates, range(n)) - 1) * 100:.1f}%)")


if __name__ == "__main__":
    rates = [Fraction(2, p) for p in (7, 17, 23, 31, 41, 47)] + [Fraction(0)] * 4
    print("factor-base rates (2/p for admissible primes, 0 for null primes):")
    print("  ", [str(r) for r in rates])
    for q in (Fraction(1, 3), Fraction(1, 2), Fraction(3, 5)):
        print(schedule_report(rates, q))


"""Visualisation: the clip line, the three policy yields, and the oracle ceiling.

Left panel: the yield of the clipped inverse-rate policy as a function of the floor f,
which is an exact straight line from the unclipped policy (f = 0, yield B*HM) to the
uniform baseline (f = B/n, yield B*AM), with the oracle ceiling B*max(r) drawn above.

Right panel: how the AM-HM gap - and therefore the loss of the inverse-rate policy -
grows with the spread of the rate distribution.

Requires matplotlib.  Writes clip_line.png.
"""

from __future__ import annotations

from typing import List, Sequence

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np


def clipped_yield(rates: Sequence[float], budget: float, floor: float) -> float:
    n = len(rates)
    total = float(sum(rates))
    total_inv = float(sum(1.0 / r for r in rates))
    return budget * n / total_inv + floor * (total - n * n / total_inv)


def am(rates: Sequence[float]) -> float:
    return float(sum(rates)) / len(rates)


def hm(rates: Sequence[float]) -> float:
    return len(rates) / float(sum(1.0 / r for r in rates))


def make_figure(rates: Sequence[float] = (1.0, 2.0, 5.0),
                budget: float = 3.0,
                outfile: str = "clip_line.png") -> None:
    n = len(rates)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    fs = np.linspace(0.0, budget / n, 200)
    ys = [clipped_yield(rates, budget, f) for f in fs]
    ax1.plot(fs, ys, lw=2.5, color="#2b6cb0", label="clipped inverse-rate yield")
    ax1.axhline(budget * am(rates), ls="--", color="#2f855a",
                label=f"uniform baseline  $B\\cdot AM = {budget * am(rates):.3f}$")
    ax1.axhline(budget * hm(rates), ls="--", color="#c53030",
                label=f"unclipped policy  $B\\cdot HM = {budget * hm(rates):.3f}$")
    ax1.axhline(budget * max(rates), ls=":", color="#6b46c1",
                label=f"oracle ceiling  $B\\cdot\\max r = {budget * max(rates):.3f}$")
    ax1.scatter([0.0, budget / n],
                [clipped_yield(rates, budget, 0.0),
                 clipped_yield(rates, budget, budget / n)],
                zorder=5, s=60, color="#1a202c")
    ax1.set_xlabel("floor $f$ (clip strength)")
    ax1.set_ylabel("total yield")
    ax1.set_title("The clip is a coordinate: yield is affine and increasing in $f$")
    ax1.legend(loc="lower right", fontsize=9)
    ax1.grid(alpha=0.25)

    spreads = np.linspace(0.0, 0.95, 120)
    losses: List[float] = []
    for s in spreads:
        # rates spread symmetrically about 1 by a factor (1 +/- s)
        r = [1.0 - s, 1.0, 1.0 + s]
        losses.append(100.0 * (1.0 - hm(r) / am(r)))
    ax2.plot(spreads, losses, lw=2.5, color="#b7791f")
    ax2.axhline(17.6, ls="--", color="#718096",
                label="measured loss of the deployed run: $17.6\\%$")
    ax2.set_xlabel("rate spread $s$   (rates $1-s,\\ 1,\\ 1+s$)")
    ax2.set_ylabel("loss of the inverse-rate policy (%)")
    ax2.set_title("The loss is the AM-HM gap: it grows with the information in the dial")
    ax2.legend(loc="upper left", fontsize=9)
    ax2.grid(alpha=0.25)

    fig.tight_layout()
    fig.savefig(outfile, dpi=150)
    print(f"wrote {outfile}")


if __name__ == "__main__":
    make_figure()


"""Visualisation: retention versus work fraction along the threshold sweep.

For a factor base with exact per-period rates 2/p (admissible primes) and 0 (null
primes), sweeping the threshold from 0 upwards traces a curve of
(work fraction, retention).  The theory says the curve never dips below the diagonal
when the dial is concordant with the rate; the vertical gap to the diagonal is the
throughput gain, and the flat initial stretch is the null tail, which can be dropped
for free.

Requires matplotlib.  Writes retention_curve.png.
"""

from __future__ import annotations

from typing import List, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def primes_up_to(bound: int) -> List[int]:
    sieve = [True] * (bound + 1)
    sieve[0:2] = [False, False]
    for q in range(2, int(bound ** 0.5) + 1):
        if sieve[q]:
            for m in range(q * q, bound + 1, q):
                sieve[m] = False
    return [q for q in range(bound + 1) if sieve[q]]


def is_residue(p: int, N: int) -> bool:
    return any((x * x - N) % p == 0 for x in range(p))


def factor_base_rates(N: int, bound: int) -> List[float]:
    """Exact rates 2/p (admissible) or 0 (null) for all odd primes up to `bound`."""
    rates = []
    for p in primes_up_to(bound):
        if p == 2:
            continue
        rates.append(2.0 / p if (N % p != 0 and is_residue(p, N)) else 0.0)
    return rates


def sweep(rates: List[float]) -> Tuple[List[float], List[float]]:
    order = sorted(rates, reverse=True)
    total = sum(order)
    n = len(order)
    work, retention, run = [0.0], [0.0], 0.0
    for k, r in enumerate(order, start=1):
        run += r
        work.append(k / n)
        retention.append(run / total if total else 0.0)
    return work, retention


def make_figure(N: int = 2, bound: int = 200,
                outfile: str = "retention_curve.png") -> None:
    rates = factor_base_rates(N, bound)
    work, retention = sweep(rates)
    live = sum(1 for r in rates if r > 0)

    fig, ax = plt.subplots(figsize=(7.5, 6))
    ax.plot(work, retention, lw=2.5, color="#2b6cb0",
            label="threshold sweep (retention vs work)")
    ax.plot([0, 1], [0, 1], ls="--", color="#718096",
            label="diagonal: retention $=$ work fraction")
    ax.axvline(live / len(rates), ls=":", color="#c53030",
               label=f"all null targets deferred ({len(rates) - live} of {len(rates)})")
    ax.fill_between(work, retention, [w for w in work], alpha=0.15, color="#2b6cb0")
    ax.set_xlabel("work fraction $|K|/|s|$")
    ax.set_ylabel("retention $\\sum_K r / \\sum_s r$")
    ax.set_title(f"Retention dominates work fraction  ($N = {N}$, primes $\\leq {bound}$)")
    ax.legend(loc="lower right", fontsize=9)
    ax.grid(alpha=0.25)
    fig.tight_layout()
    fig.savefig(outfile, dpi=150)
    print(f"wrote {outfile}  ({live} admissible of {len(rates)} odd primes)")


if __name__ == "__main__":
    make_figure()


"""Assemble PACKAGE.json from the individual deliverables in this directory."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Probability/AdaptiveQSAllocation.lean",
    "Catalog/Probability/AdaptiveQSSkipFlip.lean",
    "Catalog/Probability/AdaptiveQSDiscordance.lean",
    "Catalog/Probability/AdaptiveQSInversionMass.lean",
    "Catalog/Probability/AdaptiveQSPrefixOptimality.lean",
    "Catalog/Probability/AdaptiveQSThresholdTradeoff.lean",
    "Catalog/Probability/AdaptiveQSResidueRate.lean",
    "Catalog/Probability/AdaptiveQSTieSlack.lean",
    "Catalog/Probability/AdaptiveQSFactorBaseRate.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== {name} =====\n\n{read(name)}" for name in LEAN_FILES
)

FUTURE_DIRECTIONS = """# Future directions — after the adaptive-sieve cycle (ADAPT-NULL-EQUALIZER / SKIP-FLIP-WINS)

The development settles the *sign structure* and, in this cycle, a large part of the
*quantitative structure* of adaptive quadratic sieving at the constants layer:

* inverse-rate reallocation must lose (AM–HM, strict once the dial is informative);
* the floor clip is a monotone parameter of one affine family, not a hack;
* the oracle bound `B · max r` is attained, hence exact;
* skipping by a concordant dial raises throughput, with a **linear discordance budget**
  `M · |Disc|` when the dial is imperfect;
* the null half of the mechanism is exact arithmetic: primes for which `N` is a quadratic
  non-residue have per-period rate exactly `0`, admissible odd primes exactly `2/p`;
* the deployment policy space collapses: every maximal-yield schedule of a given size is
  *separated*, the minimum-work quota-feasible schedule can always be taken separated, and
  every separated schedule sits inside a single dial threshold.

**Closed this cycle** (three of the five directions of the previous cycle):

* *Inversion-mass refinement.*  The penalty `M · |Disc|` is replaced by the **inversion
  mass** `Σ_{(j,i) ∈ Disc} (r j − r i)`, proved with no boundedness and no sign hypothesis,
  shown to dominate the old budget, to vanish exactly for concordant dials, and to be
  strictly smaller on an explicit instance (`1` against `10`).  Its successor question was
  closed at the same time: the deficit is *exactly* the paid inversion mass minus the earned
  concordance mass, which sharpens the budget and characterises its tightness.
* *Tie-multiplicity slack.*  The excess of the threshold set over a minimal separated
  schedule is *exactly* the tie class, it vanishes for an injective dial, and the arithmetic
  rates `2/p` are injective — so on an admissible factor base the threshold policy is
  **exactly** minimal-work.
* *Exact aggregate rate of a factor base.*  The aggregate per-period rate is
  `Σ_{p admissible} 2/p = 2 H_A`, the oracle target is the smallest admissible prime, and
  the headroom ratio is exactly `|A| / (p_min · H_A)`, strictly below the crude ceiling
  `|A|` once the base has two primes.

**What remains open**

1. **Nonlinear yield curves.**  Replace `r_i ℓ_i` by a concave `g_i(ℓ_i)` modelling
   saturation of a sieve target.  Does the sign of the inverse-rate rule survive, and does
   the clip remain a monotone coordinate of one family?
2. **Mertens control of the headroom.**  The headroom ratio is exactly `|A| / (p_min · H_A)`;
   combining this with classical estimates for `Σ_{p ≤ B} 1/p` over an admissible
   (density-`1/2`) subfamily should give a closed-form asymptotic for the maximal adaptive
   headroom of a factor base of bound `B`.
3. **The Pareto frontier in the threshold.**  Throughput rises and total yield falls with
   the threshold; characterise the optimal operating point for a stated exchange rate
   between wall-clock and relations.
4. **Ledger-driven dial design.**  A dial's value for deferral is
   `earned concordance mass − paid inversion mass`, not its rank correlation; design dials
   that maximise net mass directly.
5. **Beyond a single threshold.**  The collapse theorem assumes a common sieve depth on the
   retained set.  Allowing depth to vary reintroduces the allocation problem inside the
   retained set, where the linear model says "concentrate" and practice says otherwise;
   reconciling the two requires the nonlinear model of direction 1.
"""

INTERACTIVE_LAYOUT = read("assets/interactive_layout.md")

package = {
    "title": "Why Inverse-Rate Reallocation Must Lose, and Why Deferral Wins: "
             "Exact Allocation and Skip Theory for an Adaptive Quadratic Sieve",
    "domain": "Computation",
    "description": (
        "A complete constants-layer theory of adaptive sieve scheduling: reallocating effort "
        "in inverse proportion to a predicted relation rate yields the budget times the "
        "harmonic mean of the rates and therefore can never beat the uniform baseline, while "
        "deferring low-rate targets by a single dial threshold is provably optimal and raises "
        "throughput. The per-target rate is computed exactly as 2/p for admissible primes and "
        "0 for the rest."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-31",
    "key_results": [
        "The inverse-rate allocation yields the budget times the harmonic mean of the rates "
        "while the uniform baseline yields the budget times the arithmetic mean, so "
        "inverse-rate reallocation never wins and loses strictly whenever two rates differ — "
        "independently of any prediction error.",
        "The clipped inverse-rate family has yield exactly affine in the floor, with slope "
        "equal to the arithmetic-mean-minus-harmonic-mean gap, interpolating from the "
        "unclipped policy at floor zero to the uniform baseline at floor B/n; the floor is "
        "therefore monotonically load-bearing.",
        "Concentrating the budget on a maximal-rate target beats the uniform baseline and "
        "attains the exact oracle bound: every admissible allocation yields at most the "
        "budget times the largest rate, and the headroom over uniform is exactly the budget "
        "times the maximum-minus-mean rate gap.",
        "Deferral by a rank-faithful dial always retains at least the proportion of relations "
        "that it retains of the work, so throughput never falls; for an imperfect dial the "
        "retention deficit is exactly the paid inversion mass minus the earned concordance "
        "mass, bounded by the inversion mass and hence by the maximal rate times the number "
        "of ranking inversions.",
        "The deployment policy space collapses: every maximal-yield schedule of a given size "
        "is separated, so any attainable relation quota is met by a single dial threshold "
        "with throughput at least that of sieving everything; the threshold's excess over a "
        "minimal schedule is exactly its tie class, which is empty on a factor base because "
        "the exact per-period rate 2/p is injective.",
        "For an odd prime p with N not divisible by p, the congruence x² ≡ N has exactly two "
        "solutions per period when N is a quadratic residue and exactly zero otherwise, so "
        "the per-period rate is exactly 2/p or 0; the aggregate rate of an admissible factor "
        "base A is twice the harmonic sum of its primes, the oracle target is the smallest "
        "admissible prime, and the headroom ratio is exactly |A|/(p_min·H_A).",
    ],
    "keywords": [
        "quadratic sieve",
        "adaptive allocation",
        "AM-HM inequality",
        "harmonic mean",
        "rank concordance",
        "inversion mass",
        "quadratic residues",
        "threshold policy",
    ],
    "article": read("ARTICLE.md"),
    "research_paper": read("RESEARCH_PAPER.md"),
    "research_paper_tex": read("RESEARCH_PAPER.tex"),
    "demo": read("demo.py"),
    "demos": [
        {
            "name": "End-to-End Verification of the Allocation, Deferral and Arithmetic Laws",
            "description": (
                "A self-contained exact-rational demonstration of every result in the paper. "
                "It confirms numerically that the uniform baseline yields the budget times the "
                "arithmetic mean and the inverse-rate policy the budget times the harmonic mean "
                "(and that each target then contributes an identical amount, the signature of "
                "the equalising rule); that the clipped family's yield lies exactly on the "
                "affine line B·n/Σr⁻¹ + f·(Σr − n²/Σr⁻¹) with endpoints the unclipped policy and "
                "the baseline; that the concentrator attains the oracle ceiling B·max r and the "
                "headroom equals B·(max r − mean r); that a threshold deferral retains a larger "
                "fraction of relations than of work; that the retention deficit equals paid "
                "inversion mass minus earned concordance mass on every threshold of an "
                "explicitly inverted dial; that the greedy prefix schedule matches a brute-force "
                "search over all 2^n subsets for the minimum-work quota schedule; and that the "
                "per-period rate of every odd prime up to 60 for N = 2 is exactly 2/p or exactly "
                "0, with the aggregate rate equal to twice the harmonic sum and the headroom "
                "ratio equal to |A|/(p_min·H_A). A 300-instance pseudo-random stress test closes "
                "with zero violations."
            ),
            "code": read("demo.py"),
        }
    ],
    "algorithms": [
        {
            "name": "Exact Allocation Audit: Predicting Every Policy's Yield in Linear Time",
            "description": (
                "Given a rate vector r (measured or predicted) and a budget B, this procedure "
                "computes in O(n) rational operations the exact yield of every policy under "
                "consideration: the uniform baseline B·AM(r), the inverse-rate policy B·HM(r), "
                "the clipped policy at any floor via the affine law "
                "Y(f) = B·n/T + f·(Σr − n²/T) with T = Σ1/r, and the concentrator/oracle "
                "B·max(r). Because the arithmetic mean dominates the harmonic mean, the audit "
                "certifies before any computation is spent that the inverse-rate policy will "
                "lose, by exactly 1 − HM/AM, and that the maximum available gain is "
                "max(r)/AM(r) − 1. The clip slope Σr − n²/T is returned as the diagnostic that "
                "decides whether the floor is load-bearing (positive slope) or inert (zero "
                "slope, i.e. all rates equal). All arithmetic is exact rational, so the audit "
                "is free of floating-point ambiguity even when rates span several orders of "
                "magnitude."
            ),
            "pseudocode": (
                "INPUT  rates r[1..n] > 0, budget B\n"
                "OUTPUT exact yields of all policies and the clip slope\n"
                "\n"
                "1.  if n = 0 or any r[i] <= 0 then reject\n"
                "2.  S    <- sum_{i=1..n} r[i]                      # O(n)\n"
                "3.  T    <- sum_{i=1..n} 1 / r[i]                  # O(n)\n"
                "4.  AM   <- S / n                                  # arithmetic mean\n"
                "5.  HM   <- n / T                                  # harmonic mean\n"
                "6.  MX   <- max_i r[i]\n"
                "7.  Y_uniform  <- B * AM\n"
                "8.  Y_inverse  <- B * HM                           # <= Y_uniform, always\n"
                "9.  Y_oracle   <- B * MX                           # exact supremum, attained\n"
                "10. slope      <- S - n^2 / T                      # >= 0 by AM-HM\n"
                "11. Y_clip(f)  <- B*n/T + f * slope   for f in [0, B/n]\n"
                "12. report loss     <- 1 - HM/AM\n"
                "13. report headroom <- MX/AM - 1\n"
                "14. assert Y_inverse <= Y_uniform <= Y_oracle <= n * Y_uniform"
            ),
            "code": read("assets/algo_allocation_audit.py"),
        },
        {
            "name": "Minimum-Work Quota Scheduling by a Single Dial Threshold",
            "description": (
                "The deployment problem is: collect at least Q relations while working on as "
                "few targets as possible, choosing any of the 2^n subsets. The theory collapses "
                "this search. Among subsets of a fixed size, every maximiser of total rate is "
                "separated — an exchange argument shows one can never improve by retaining a "
                "worse target while deferring a better one — so a minimum-work quota-feasible "
                "schedule may always be taken separated, and every separated set is contained "
                "in the threshold set at its own smallest rate. The algorithm therefore sorts "
                "once by the dial, accumulates rates until the quota is met, and reports the "
                "resulting prefix together with the threshold that realises it. Complexity is "
                "O(n log n) for the sort and O(n) thereafter, against the 2^n subsets a naive "
                "search would examine. On a factor base the schedule is exactly optimal rather "
                "than optimal up to ties, because the exact rate 2/p is injective in p. The "
                "report also prints the before/after throughput, which is guaranteed not to "
                "fall."
            ),
            "pseudocode": (
                "INPUT  rates r[1..n] >= 0, quota Q > 0\n"
                "OUTPUT retained set K of minimum size with sum_K r >= Q, and threshold theta\n"
                "\n"
                "1.  if sum_i r[i] < Q then return INFEASIBLE\n"
                "2.  order <- indices 1..n sorted by r descending      # O(n log n)\n"
                "3.  running <- 0 ;  chosen <- empty list\n"
                "4.  for i in order:\n"
                "5.       append i to chosen ;  running <- running + r[i]\n"
                "6.       if running >= Q then break\n"
                "7.  theta <- min { r[i] : i in chosen }\n"
                "8.  K     <- { i : r[i] >= theta }        # threshold form of the schedule\n"
                "9.  assert sum_K r >= Q                   # threshold is quota-feasible\n"
                "10. assert |K| = |chosen| whenever r is injective  # no tie slack\n"
                "11. report throughput(all) <= throughput(K)\n"
                "12. return (K, theta)"
            ),
            "code": read("assets/algo_threshold_schedule.py"),
        },
        {
            "name": "The Discordance Ledger: Exact Accounting of an Imperfect Dial",
            "description": (
                "This procedure quantifies what a miscalibrated ranking actually costs a "
                "deferral policy. It enumerates the dial's inversion set — the ordered pairs "
                "(j, i) with dial value of j below that of i but true rate of j above that of "
                "i — and accumulates the inversion mass, the total true rate gap carried by "
                "those pairs. At a chosen threshold it then splits the deferred × retained "
                "pairs into the mass paid (positive part of r_j − r_i) and the mass earned "
                "(positive part of r_i − r_j), and verifies the exact identity that the "
                "retention deficit equals paid minus earned. This turns a one-sided bound into "
                "a ledger: a dial is worth deploying when it earns more mass than it pays, "
                "which is a strictly finer criterion than a rank-correlation coefficient. The "
                "procedure also reports the crude budget (largest rate times inversion count) "
                "so the improvement factor of the refinement is visible. Complexity is O(n²) "
                "for the pair enumeration and O(n) for the sums; all arithmetic is exact "
                "rational."
            ),
            "pseudocode": (
                "INPUT  dial d[1..n], rates r[1..n], threshold theta\n"
                "OUTPUT full paid/earned ledger and its consistency check\n"
                "\n"
                "1.  Disc <- { (j,i) : d[j] < d[i]  and  r[i] < r[j] }        # O(n^2)\n"
                "2.  IM   <- sum over (j,i) in Disc of ( r[j] - r[i] )        # inversion mass\n"
                "3.  K    <- { i : d[i] >= theta } ;  D <- { i : d[i] < theta }\n"
                "4.  paid   <- sum_{j in D} sum_{i in K} max( r[j] - r[i], 0 )\n"
                "5.  earned <- sum_{j in D} sum_{i in K} max( r[i] - r[j], 0 )\n"
                "6.  deficit <- |K| * sum_s r  -  n * sum_K r\n"
                "7.  assert deficit = paid - earned                # exact ledger identity\n"
                "8.  assert deficit <= IM                          # refined budget\n"
                "9.  assert IM <= max_i r[i] * |Disc|              # refinement dominates\n"
                "10. report improvement factor  ( max_i r[i] * |Disc| ) / IM\n"
                "11. return (Disc, IM, paid, earned, deficit)"
            ),
            "code": read("assets/algo_discordance_ledger.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Clip Line and the Growth of the Arithmetic–Harmonic Gap",
            "description": (
                "Two panels. The left panel plots the yield of the clipped inverse-rate policy "
                "against the floor f: an exact straight line running from the unclipped policy "
                "(f = 0, yield B times the harmonic mean) up to the uniform baseline "
                "(f = B/n, yield B times the arithmetic mean), with the unattainable-to-exceed "
                "oracle ceiling B·max(r) drawn above. It makes visible why removing the floor "
                "turned a survivable loss into a collapse: the two operating points are two "
                "points on one line. The right panel sweeps the spread of a symmetric "
                "three-rate distribution and plots the resulting loss 1 − HM/AM, showing that "
                "the penalty for equalising grows precisely with the amount of information the "
                "dial has to offer."
            ),
            "code": read("assets/viz_clip_line.py"),
        },
        {
            "name": "Retention Dominates Work Fraction Along the Threshold Sweep",
            "description": (
                "For the true factor-base rates of a target N — exactly 2/p for each admissible "
                "odd prime and exactly 0 for each prime at which N is a quadratic non-residue — "
                "the script sweeps the deferral threshold from keeping everything down to "
                "keeping only the best prime, and plots retained relations against retained "
                "work. The curve never dips below the diagonal, which is the geometric content "
                "of the separation theorem; the vertical gap above the diagonal is exactly the "
                "throughput gain; and the flat stretch at the right-hand end is the null tail, "
                "the primes that produce nothing at any sieve depth and can therefore be "
                "deferred entirely for free."
            ),
            "code": read("assets/viz_retention_curve.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Allocation Laboratory — Four Policies, One Budget, One Straight Line",
            "description": (
                "A four-panel interactive workbench for the whole theory. Panel 1 lets you set "
                "six target rates and a budget and shows, live, the exact yield of the uniform "
                "baseline, the clipped and unclipped inverse-rate policies, and the "
                "concentrator/oracle, together with the verdict that the loss of the "
                "inverse-rate rule is exactly the arithmetic-mean-minus-harmonic-mean gap of "
                "your own rate vector — try the 'equal rates' preset to watch every policy tie "
                "and the gap vanish. Panel 2 draws the clip line and lets you drag the floor "
                "from the unclipped policy to the uniform baseline, with the slope reported "
                "numerically. Panel 3 sweeps the deferral threshold and plots retention against "
                "work fraction, always above the diagonal, while displaying the opposing "
                "movement of throughput and total yield. Panel 4 exposes the dial as a separate "
                "object from the rate: drag the dial values out of order and watch the inversion "
                "count, the inversion mass, the crude budget, and the exact paid-minus-earned "
                "ledger identity update in real time."
            ),
            "html": read("assets/widget_allocation_lab.html"),
        }
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {
        "demo": read("demo.py"),
        "allocation_audit": read("assets/algo_allocation_audit.py"),
        "threshold_schedule": read("assets/algo_threshold_schedule.py"),
        "discordance_ledger": read("assets/algo_discordance_ledger.py"),
    },
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False), encoding="utf-8")
print(f"wrote {out}  ({out.stat().st_size} bytes)")


"""
Numerical demonstrations of the adaptive-sieve allocation and deferral theory.

Everything here is self-contained (standard library only) and checks, on explicit
numbers, the exact statements proved in the accompanying paper:

  1. yield of the uniform baseline   = B * arithmetic mean of the rates
     yield of the inverse-rate rule  = B * harmonic mean of the rates
     hence the inverse-rate rule can never win, and loses strictly
     as soon as two rates differ  (AM-HM).

  2. the clipped inverse-rate family  l_i(f) = f + (B - n f) r_i^-1 / sum r^-1
     has yield affine in the floor f, with slope  sum(r) - n^2 / sum(1/r) >= 0,
     endpoints f = 0 (unclipped rule) and f = B/n (uniform baseline).

  3. concentrating the budget on a maximal-rate target attains the exact oracle
     bound  B * max(r), and the headroom over uniform is  B * (max r - mean r).

  4. deferral: for a separated split, retention >= work fraction, so throughput
     never falls; for an imperfect dial the deficit is exactly
     (paid inversion mass) - (earned concordance mass), and is bounded by the
     inversion mass, itself bounded by M * |Disc|.

  5. the policy space collapses: the minimum-work quota-feasible schedule is a
     prefix of the rate order, i.e. a single threshold.

  6. arithmetic layer: for odd prime p with N not = 0 mod p, x^2 = N mod p has
     exactly 2 solutions if N is a quadratic residue and 0 otherwise, so the
     per-period rate is exactly 2/p or 0; the aggregate rate of an admissible
     factor base A is 2 * sum_{p in A} 1/p, the oracle target is min A, and the
     headroom ratio is |A| / (p_min * H_A).

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Dict, Iterable, List, Sequence, Tuple

Number = Fraction


# ----------------------------------------------------------------------------- #
# 1. The allocation model
# ----------------------------------------------------------------------------- #


def yield_of(rates: Sequence[Number], alloc: Sequence[Number]) -> Number:
    """Total yield sum_i r_i * l_i of an allocation against a rate vector."""
    return sum((r * l for r, l in zip(rates, alloc)), Fraction(0))


def uniform_alloc(n: int, budget: Number) -> List[Number]:
    """Equal sieve length B/n on every target."""
    return [Fraction(budget, 1) / n for _ in range(n)]


def inv_rate_alloc(rates: Sequence[Number], budget: Number) -> List[Number]:
    """Sieve length inversely proportional to the rate, normalised to the budget."""
    total_inv = sum((1 / r for r in rates), Fraction(0))
    return [budget * (1 / r) / total_inv for r in rates]


def clip_inv_alloc(rates: Sequence[Number], budget: Number, floor: Number) -> List[Number]:
    """Floor `floor` for everyone, remaining budget split inversely by rate."""
    n = len(rates)
    total_inv = sum((1 / r for r in rates), Fraction(0))
    residual = budget - n * floor
    return [floor + residual * (1 / r) / total_inv for r in rates]


def conc_alloc(n: int, index: int, budget: Number) -> List[Number]:
    """The whole budget on a single target."""
    return [budget if i == index else Fraction(0) for i in range(n)]


def arithmetic_mean(rates: Sequence[Number]) -> Number:
    return sum(rates, Fraction(0)) / len(rates)


def harmonic_mean(rates: Sequence[Number]) -> Number:
    return Fraction(len(rates), 1) / sum((1 / r for r in rates), Fraction(0))


def throughput(rates: Sequence[Number], kept: Iterable[int]) -> Number:
    kept = list(kept)
    return sum((rates[i] for i in kept), Fraction(0)) / len(kept)


# ----------------------------------------------------------------------------- #
# 2. Deferral: separation, inversions, ledger
# ----------------------------------------------------------------------------- #


def keep_set(dial: Sequence[Number], theta: Number) -> List[int]:
    return [i for i, d in enumerate(dial) if d >= theta]


def skip_set(dial: Sequence[Number], theta: Number) -> List[int]:
    return [i for i, d in enumerate(dial) if d < theta]


def discordant_pairs(dial: Sequence[Number],
                     rates: Sequence[Number]) -> List[Tuple[int, int]]:
    """Ordered pairs (j, i) the dial ranks backwards: d_j < d_i but r_i < r_j."""
    n = len(rates)
    return [(j, i) for j, i in product(range(n), repeat=2)
            if dial[j] < dial[i] and rates[i] < rates[j]]


def inversion_mass(dial: Sequence[Number], rates: Sequence[Number]) -> Number:
    return sum((rates[j] - rates[i] for j, i in discordant_pairs(dial, rates)),
               Fraction(0))


def kept_masses(dial: Sequence[Number], rates: Sequence[Number],
                theta: Number) -> Tuple[Number, Number]:
    """(paid inversion mass, earned concordance mass) across deferred x retained."""
    K, D = keep_set(dial, theta), skip_set(dial, theta)
    paid = sum((max(rates[j] - rates[i], Fraction(0)) for j in D for i in K),
               Fraction(0))
    earned = sum((max(rates[i] - rates[j], Fraction(0)) for j in D for i in K),
                 Fraction(0))
    return paid, earned


def retention_deficit(dial: Sequence[Number], rates: Sequence[Number],
                      theta: Number) -> Number:
    """|K| * total yield  -  |s| * kept yield."""
    K = keep_set(dial, theta)
    n = len(rates)
    return (Fraction(len(K)) * sum(rates, Fraction(0))
            - Fraction(n) * sum((rates[i] for i in K), Fraction(0)))


def min_work_quota_schedule(rates: Sequence[Number],
                            quota: Number) -> Tuple[List[int], Number]:
    """Greedy prefix of the rate order: minimum-work quota-feasible schedule."""
    order = sorted(range(len(rates)), key=lambda i: rates[i], reverse=True)
    total, chosen = Fraction(0), []
    for i in order:
        chosen.append(i)
        total += rates[i]
        if total >= quota:
            break
    theta = min(rates[i] for i in chosen)
    return chosen, theta


def brute_force_min_work(rates: Sequence[Number], quota: Number) -> int:
    """Minimum cardinality over ALL 2^n subsets meeting the quota (for checking)."""
    n = len(rates)
    best = n + 1
    for mask in range(1 << n):
        subset = [i for i in range(n) if mask >> i & 1]
        if sum((rates[i] for i in subset), Fraction(0)) >= quota:
            best = min(best, len(subset))
    return best


# ----------------------------------------------------------------------------- #
# 3. The arithmetic layer
# ----------------------------------------------------------------------------- #


def solution_count(p: int, N: int) -> int:
    """Number of x in {0,...,p-1} with p | x^2 - N."""
    return sum(1 for x in range(p) if (x * x - N) % p == 0)


def is_quadratic_residue(p: int, N: int) -> bool:
    return any((x * x - N) % p == 0 for x in range(p))


def period_rate(p: int, N: int) -> Fraction:
    """Exact per-period hit rate of the prime p for the target N."""
    return Fraction(solution_count(p, N), p)


def admissible(p: int, N: int) -> bool:
    return p != 2 and N % p != 0 and is_quadratic_residue(p, N)


def factor_base_rate(primes: Sequence[int], N: int) -> Fraction:
    return sum((period_rate(p, N) for p in primes), Fraction(0))


def primes_up_to(bound: int) -> List[int]:
    sieve = [True] * (bound + 1)
    sieve[0:2] = [False, False]
    for q in range(2, int(bound ** 0.5) + 1):
        if sieve[q]:
            for m in range(q * q, bound + 1, q):
                sieve[m] = False
    return [q for q in range(bound + 1) if sieve[q]]


# ----------------------------------------------------------------------------- #
# Demonstrations
# ----------------------------------------------------------------------------- #


def demo_allocation() -> None:
    print("=" * 78)
    print("1. THE INVERSE-RATE POLICY MUST LOSE  (arithmetic mean vs harmonic mean)")
    print("=" * 78)
    rates = [Fraction(1), Fraction(2), Fraction(5)]
    budget = Fraction(3)
    n = len(rates)

    y_unif = yield_of(rates, uniform_alloc(n, budget))
    y_inv = yield_of(rates, inv_rate_alloc(rates, budget))
    y_conc = yield_of(rates, conc_alloc(n, 2, budget))

    print(f"  rates            r = {[str(r) for r in rates]},  budget B = {budget}")
    print(f"  arithmetic mean    = {arithmetic_mean(rates)}  (~{float(arithmetic_mean(rates)):.4f})")
    print(f"  harmonic  mean     = {harmonic_mean(rates)}  (~{float(harmonic_mean(rates)):.4f})")
    print(f"  uniform yield      = {y_unif}    = B * AM  -> {y_unif == budget * arithmetic_mean(rates)}")
    print(f"  inverse-rate yield = {y_inv}  (~{float(y_inv):.4f}) = B * HM -> "
          f"{y_inv == budget * harmonic_mean(rates)}")
    print(f"  relative loss      = {float(1 - y_inv / y_unif) * 100:.2f}%   "
          "(measured run: -17.6%)")
    assert y_inv < y_unif

    print()
    print("  every target contributes the SAME yield under the inverse-rate rule:")
    for r, l in zip(rates, inv_rate_alloc(rates, budget)):
        print(f"    r = {str(r):>3}  l = {str(l):>8}  r*l = {r * l}")

    print()
    print(f"  concentrator yield = {y_conc}   oracle bound B*max(r) = {budget * max(rates)}")
    print(f"  concentrator attains the oracle bound -> {y_conc == budget * max(rates)}")
    print(f"  headroom over uniform = {y_conc - y_unif} = B*(max r - mean r) -> "
          f"{y_conc - y_unif == budget * (max(rates) - arithmetic_mean(rates))}")
    print(f"  headroom ratio {float(y_conc / y_unif):.4f} <= n = {n}")
    print()


def demo_clip_line() -> None:
    print("=" * 78)
    print("2. THE FLOOR CLIP IS A COORDINATE: yield is AFFINE and INCREASING in f")
    print("=" * 78)
    rates = [Fraction(1), Fraction(2), Fraction(5)]
    budget, n = Fraction(3), 3
    total_inv = sum((1 / r for r in rates), Fraction(0))
    slope = sum(rates, Fraction(0)) - Fraction(n * n) / total_inv
    intercept = budget * n / total_inv

    print(f"  predicted line:  Y(f) = {intercept} + f * {slope}")
    print(f"  slope >= 0 by AM-HM: sum(r)*sum(1/r) = "
          f"{sum(rates, Fraction(0)) * total_inv} >= n^2 = {n * n}")
    print()
    print("      f          Y(f) exact      Y(f) float   affine check")
    for k in range(6):
        f = budget / n * Fraction(k, 5)
        y = yield_of(rates, clip_inv_alloc(rates, budget, f))
        predicted = intercept + f * slope
        print(f"   {str(f):>7}   {str(y):>14}   {float(y):>10.4f}   {y == predicted}")
    y0 = yield_of(rates, clip_inv_alloc(rates, budget, Fraction(0)))
    yfull = yield_of(rates, clip_inv_alloc(rates, budget, budget / n))
    print()
    print(f"  f = 0    reproduces the unclipped rule  -> {y0 == yield_of(rates, inv_rate_alloc(rates, budget))}")
    print(f"  f = B/n  reproduces the uniform baseline-> "
          f"{yfull == yield_of(rates, uniform_alloc(n, budget))}")
    print("  => removing the clip slides DOWN this line; that is the whole story of")
    print("     '-17.6% clipped' versus '-146.7% unclipped'.")
    print()


def demo_deferral() -> None:
    print("=" * 78)
    print("3. DEFERRAL: retention >= work fraction, and the discordance ledger")
    print("=" * 78)
    rates = [Fraction(1), Fraction(2), Fraction(5)]
    n = len(rates)
    # oracle dial: skip the worst target
    theta = Fraction(2)
    K = keep_set(rates, theta)
    total = sum(rates, Fraction(0))
    kept = sum((rates[i] for i in K), Fraction(0))
    print(f"  rates {[str(r) for r in rates]}, threshold theta = {theta}, kept = {K}")
    print(f"  retention    = {kept}/{total} = {float(kept / total) * 100:.1f}%   (measured: 89.5%)")
    print(f"  work fraction= {len(K)}/{n} = {float(Fraction(len(K), n)) * 100:.1f}%   (measured: 71.7%)")
    print(f"  retention >= work fraction -> {kept / total >= Fraction(len(K), n)}")
    print(f"  throughput  {throughput(rates, range(n))} -> {throughput(rates, K)}  "
          f"(+{float(throughput(rates, K) / throughput(rates, range(n)) - 1) * 100:.1f}%)")
    print()

    print("  an IMPERFECT dial: rates (10, 3, 2) with dial (10, 2, 3)")
    rates2 = [Fraction(10), Fraction(3), Fraction(2)]
    dial2 = [Fraction(10), Fraction(2), Fraction(3)]
    disc = discordant_pairs(dial2, rates2)
    im = inversion_mass(dial2, rates2)
    M = max(rates2)
    print(f"    inversion set   = {disc}  (|Disc| = {len(disc)})")
    print(f"    inversion mass  = {im}     crude penalty M*|Disc| = {M * len(disc)}")
    print(f"    refinement is strictly better -> {im < M * len(disc)}")
    print()
    print("    exact ledger at each threshold: deficit = paid - earned")
    for theta2 in [Fraction(2), Fraction(3), Fraction(10)]:
        paid, earned = kept_masses(dial2, rates2, theta2)
        deficit = retention_deficit(dial2, rates2, theta2)
        ok = deficit == paid - earned
        print(f"      theta = {str(theta2):>3}: kept {keep_set(dial2, theta2)}  "
              f"deficit = {str(deficit):>4}  paid = {str(paid):>3}  earned = {str(earned):>3}"
              f"   identity holds -> {ok}  bound -> {deficit <= im}")
    print()


def demo_policy_collapse() -> None:
    print("=" * 78)
    print("4. THE POLICY SPACE COLLAPSES: one threshold beats all 2^n subsets")
    print("=" * 78)
    rates = [Fraction(3), Fraction(1), Fraction(0), Fraction(4), Fraction(2)]
    n = len(rates)
    for quota in [Fraction(3), Fraction(6), Fraction(9), Fraction(10)]:
        chosen, theta = min_work_quota_schedule(rates, quota)
        best = brute_force_min_work(rates, quota)
        kset = keep_set(rates, theta)
        got = sum((rates[i] for i in kset), Fraction(0))
        print(f"  quota {str(quota):>3}: threshold theta = {str(theta):>3} keeps {kset}, "
              f"yield {got} >= quota -> {got >= quota}; "
              f"|K| = {len(kset)}, brute-force minimum = {best} -> {len(kset) == best}")
    print(f"  (searched all 2^{n} = {2 ** n} subsets for the brute-force minimum)")
    print()
    print("  ties are the only slack: rates (3, 3, 1), quota 3")
    tied = [Fraction(3), Fraction(3), Fraction(1)]
    chosen, theta = min_work_quota_schedule(tied, Fraction(3))
    print(f"    minimal schedule {chosen} has size {len(chosen)}, "
          f"threshold keeps {keep_set(tied, theta)} (size {len(keep_set(tied, theta))})")
    print("    -> excess is exactly the tie class; on a factor base 2/p is injective,")
    print("       so no ties occur and the threshold policy is exactly minimum-work.")
    print()


def demo_arithmetic() -> None:
    print("=" * 78)
    print("5. THE ARITHMETIC LAYER: the rate is exactly 2/p or exactly 0")
    print("=" * 78)
    N = 2
    print(f"  target N = {N}; per-period rate of each odd prime p <= 60")
    print("      p   #solutions   rate      admissible   equals 2/p?")
    for p in primes_up_to(60):
        if p == 2:
            continue
        c = solution_count(p, N)
        rate = period_rate(p, N)
        adm = admissible(p, N)
        check = (rate == Fraction(2, p)) if adm else (rate == 0)
        assert c in (0, 2)
        print(f"    {p:>3}      {c}        {str(rate):>6}     {str(adm):>5}        {check}")
    print()

    A = [p for p in primes_up_to(60) if admissible(p, N)]
    H = sum((Fraction(1, p) for p in A), Fraction(0))
    R = factor_base_rate(A, N)
    print(f"  admissible base A = {A}")
    print(f"  aggregate rate  = {R} = 2 * H_A -> {R == 2 * H}   (H_A = {H})")
    p_min = min(A)
    oracle = max(period_rate(p, N) for p in A)
    print(f"  oracle target = smallest admissible prime = {p_min}, rate {oracle} "
          f"-> {oracle == Fraction(2, p_min)}")
    ratio = oracle / (R / len(A))
    print(f"  headroom ratio = {ratio} (~{float(ratio):.4f}) "
          f"= |A|/(p_min*H_A) -> {ratio == Fraction(len(A), 1) / (p_min * H)}")
    print(f"  strictly below the crude ceiling |A| = {len(A)} -> {ratio < len(A)}")
    print()
    nulls = [p for p in primes_up_to(60) if p != 2 and N % p != 0 and not admissible(p, N)]
    print(f"  null (non-residue) primes: {nulls}")
    print("  each divides NO value x^2 - N; check over a wide window:")
    for p in nulls[:4]:
        hits = sum(1 for x in range(-500, 501) if (x * x - N) % p == 0)
        print(f"    p = {p:>3}: hits in x in [-500, 500] = {hits}")
    print("  -> the hard tail is unreachable by construction; deferral, not depth.")
    print()

    print("  worked example of the paper: N = 2, factor base {7, 17}")
    print(f"    aggregate rate = {factor_base_rate([7, 17], 2)} "
          f"= 2/7 + 2/17 -> {factor_base_rate([7, 17], 2) == Fraction(2, 7) + Fraction(2, 17)}")
    print()


def demo_random_stress() -> None:
    print("=" * 78)
    print("6. STRESS TEST: the inequalities on many pseudo-random rate vectors")
    print("=" * 78)
    seed = 12345
    failures = 0
    trials = 300
    for t in range(trials):
        seed = (1103515245 * seed + 12345) % (1 << 31)
        n = 2 + seed % 7
        rates: List[Fraction] = []
        for _ in range(n):
            seed = (1103515245 * seed + 12345) % (1 << 31)
            rates.append(Fraction(1 + seed % 50, 1 + (seed >> 7) % 9))
        budget = Fraction(1 + seed % 20)
        y_unif = yield_of(rates, uniform_alloc(n, budget))
        y_inv = yield_of(rates, inv_rate_alloc(rates, budget))
        y_conc = budget * max(rates)
        total_inv = sum((1 / r for r in rates), Fraction(0))
        slope = sum(rates, Fraction(0)) - Fraction(n * n) / total_inv
        ok = (y_inv <= y_unif) and (y_unif <= y_conc) and (slope >= 0) \
            and (y_conc <= n * y_unif)
        # affine clip check at a random floor
        f = budget / n * Fraction(seed % 5, 5)
        y_f = yield_of(rates, clip_inv_alloc(rates, budget, f))
        ok = ok and (y_f == budget * n / total_inv + f * slope)
        # deferral check at the median rate
        med = sorted(rates)[n // 2]
        K = keep_set(rates, med)
        if K:
            ok = ok and (Fraction(len(K)) * sum(rates, Fraction(0))
                         <= Fraction(n) * sum((rates[i] for i in K), Fraction(0)))
        if not ok:
            failures += 1
    print(f"  {trials} random instances checked (exact rational arithmetic)")
    print(f"  violations of  HM <= AM <= max, slope >= 0, affine clip law,")
    print(f"  oracle ratio <= n, and retention >= work fraction:  {failures}")
    print()


def main() -> None:
    demo_allocation()
    demo_clip_line()
    demo_deferral()
    demo_policy_collapse()
    demo_arithmetic()
    demo_random_stress()
    print("=" * 78)
    print("All demonstrations completed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
