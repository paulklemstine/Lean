"""Nested cross-window slope certificate."""

from __future__ import annotations

from typing import NamedTuple


class SlopeCertificate(NamedTuple):
    coarse_window: int
    fine_window: int
    refinement_factor: int
    observed_cross_window: float
    certified_slope_floor: float      # L >= N1 * |D|
    generic_slope_floor: float        # what the non-nested bound would give
    sharpening: float                 # ratio of the two
    tightness: float                  # fraction of the true slope the floor recovers


def nested_slope_certificate(coarse: int, fine: int,
                             cross_window_diff: float) -> SlopeCertificate:
    """
    Turn an observed cross-window difference into a certified lower bound on the
    steepness of the underlying response.

    Mathematics
    -----------
    For an antitone, L-Lipschitz response measured on NESTED windows N2 = N1*c with
    the gates held fixed, every bracket in the residual decomposition of

        D = (r_{N2}(t1) - r_{N1}(t1)) - (r_{N2}(t2) - r_{N1}(t2))

    lies in [-L/N1, 0], because refinement can only shrink a nonnegative residual.
    Hence |D| <= L/N1, with NO dependence on the fine window: the coarse window is
    the bottleneck. Reading the bound backwards certifies

        L >= N1 * |D|.

    Without nestedness one only gets |D| <= 2L(1/N1 + 1/N2), i.e. a floor of
    |D| / (2(1/N1 + 1/N2)), which at (240, 960) is 2.5x weaker.

    Tightness: on the linear witness S(x) = -Lx with gates (0, 1/N2) the true value is
    D = L/N1 - L/N2, so the certificate recovers exactly (N2 - N1)/N2 of the slope —
    3/4 at (240, 960). Upper and lower bounds therefore match to the factor c/(c-1).

    Complexity: O(1) time and space.
    """
    if coarse <= 0 or fine <= 0:
        raise ValueError("window sizes must be positive")
    if fine % coarse != 0:
        raise ValueError("windows must be nested: fine must be a multiple of coarse")
    c = fine // coarse
    d = abs(cross_window_diff)
    certified = coarse * d
    generic = d / (2.0 * (1.0 / coarse + 1.0 / fine))
    return SlopeCertificate(
        coarse_window=coarse,
        fine_window=fine,
        refinement_factor=c,
        observed_cross_window=cross_window_diff,
        certified_slope_floor=certified,
        generic_slope_floor=generic,
        sharpening=certified / generic if generic > 0 else float("inf"),
        tightness=(fine - coarse) / fine,
    )


"""Rank-grid realisation and resolution residual evaluation."""

from __future__ import annotations

import math
from typing import Callable, NamedTuple


class GridReading(NamedTuple):
    """One evaluation of a response through the rank grid of a window."""
    nominal_rate: float          # theta, the rate the experimenter asked for
    realised_rate: float         # gr_N(theta) = ceil(theta*N)/N, the rate actually used
    overshoot: float             # gr_N(theta) - theta, in [0, 1/N)
    ideal_value: float           # S(theta)
    measured_value: float        # S_N(theta) = S(gr_N(theta))
    residual: float              # r_N(theta) = S(theta) - S_N(theta)


def grid_up(n: int, theta: float) -> float:
    """
    Realised gate on a window of n items.

    Only the rates k/n are realisable, so a nominal tail rate theta is rounded UP to
    the next available rank: gr_N(theta) = ceil(theta*n)/n. This is the conservative
    convention for a tail gate (never admit more items than requested).

    Guarantees: theta <= gr_N(theta) < theta + 1/n; monotone in theta; and for nested
    windows gr_{nc}(theta) <= gr_n(theta) for every positive integer c.
    """
    if n <= 0:
        raise ValueError("window size must be positive")
    return math.ceil(theta * n) / n


def read_through_grid(s: Callable[[float], float], n: int, theta: float) -> GridReading:
    """Evaluate a response through the rank grid and report the full decomposition."""
    realised = grid_up(n, theta)
    ideal = s(theta)
    measured = s(realised)
    return GridReading(
        nominal_rate=theta,
        realised_rate=realised,
        overshoot=realised - theta,
        ideal_value=ideal,
        measured_value=measured,
        residual=ideal - measured,
    )


def split_gate_drop(s: Callable[[float], float], n: int,
                    soft: float, hard: float) -> dict:
    """
    Split a measured gate drop exactly:

        Delta(N) = Delta(inf) - r_N(soft) + r_N(hard).

    This is an identity, not an approximation; the returned 'identity_error' is
    numerical noise only.
    """
    a = read_through_grid(s, n, soft)
    b = read_through_grid(s, n, hard)
    measured = a.measured_value - b.measured_value
    intrinsic = a.ideal_value - b.ideal_value
    return {
        "window": n,
        "measured_drop": measured,
        "intrinsic_drop": intrinsic,
        "residual_soft": a.residual,
        "residual_hard": b.residual,
        "identity_error": measured - (intrinsic - a.residual + b.residual),
    }


"""Offset-averaged resolution bias estimator."""

from __future__ import annotations

import math
from typing import Callable, NamedTuple


class OffsetAverage(NamedTuple):
    window: int
    cell_index: int
    empirical_mean_residual: float
    predicted_mean_residual: float     # L/(2N) for a locally linear response
    absolute_deviation: float
    local_slope_estimate: float        # 2*N*mean, an unbiased read-off of L


def grid_up(n: int, theta: float) -> float:
    """Realised gate on a window of n items: round up to the next rank rate."""
    return math.ceil(theta * n) / n


def offset_averaged_residual(s: Callable[[float], float], n: int, k: int,
                             local_slope: float,
                             nodes: int = 20001) -> OffsetAverage:
    """
    Average the resolution residual over the position of the gate inside its rank cell,
    and compare against the closed-form law.

    Mathematics
    -----------
    The gate sits somewhere inside a rank cell of width 1/N; where exactly is an
    accident of the population. Averaging over that offset,

        <f>_N = N * integral over t in (0, 1/N] of f(t) dt,

    gives three facts. First, the MEASURED response is constant in the offset: every
    gate in the cell (k/N, (k+1)/N] is realised at the same rate (k+1)/N, so rank
    granularity destroys all offset information. Second, a response that is affine with
    slope -L across the cell averages to its cell MIDPOINT value. Third, subtracting,

        <r_N>  =  L / (2N)   exactly.

    So the widely used "residual proportional to 1/N" ansatz is correct, and its
    constant is HALF THE LOCAL SLOPE — determined, not fitted. Inverting, 2*N*<r_N> is
    a direct read-off of the local slope, which is what an offset-randomised design
    measures.

    For a drop across two gates with local slopes L1 (soft) and L2 (hard), the
    offset-averaged measured drop exceeds the intrinsic one by (L2 - L1)/(2N). Hence a
    drop that SHRINKS with window size requires L2 > L1: the response must be steeper
    at the hard gate.

    Numerics: midpoint rule on `nodes` subintervals, exact for affine integrands up to
    floating point. Complexity O(nodes).
    """
    if n <= 0 or nodes <= 0:
        raise ValueError("window size and node count must be positive")
    step = (1.0 / n) / nodes
    total = 0.0
    for j in range(nodes):
        t = (j + 0.5) * step
        theta = k / n + t
        total += s(theta) - s(grid_up(n, theta))
    mean = total / nodes
    predicted = local_slope / (2.0 * n)
    return OffsetAverage(
        window=n,
        cell_index=k,
        empirical_mean_residual=mean,
        predicted_mean_residual=predicted,
        absolute_deviation=abs(mean - predicted),
        local_slope_estimate=2.0 * n * mean,
    )


"""Richardson intrinsic extrapolation with exact interval propagation."""

from __future__ import annotations

from typing import NamedTuple, Tuple


class RichardsonReport(NamedTuple):
    intrinsic_level: float
    coarse_resolution_part: float
    intrinsic_share: float
    resolution_share: float
    between_cell_recovery: float
    inflation_factor: float
    intrinsic_share_interval: Tuple[float, float]
    third_cell_point: float
    third_cell_interval: Tuple[float, float]


def _intrinsic(d_coarse: float, d_fine: float, c: int) -> float:
    """I from Delta(N) = I + k/N measured at N1 and c*N1."""
    return (c * d_fine - d_coarse) / (c - 1)


def richardson_analyse(d_coarse: float, d_fine: float,
                       coarse_lo: float, coarse_hi: float,
                       fine_lo: float, fine_hi: float,
                       c: int = 4, third_factor: int = 16) -> RichardsonReport:
    """
    Separate the intrinsic level from the resolution part of a measured gate drop,
    given two nested cells, and propagate measurement intervals exactly.

    Mathematics
    -----------
    Assume the drop is affine in the rank step, Delta(N) = I + k/N. This is not an
    assumption pulled from the air: averaging over the position of the gate inside its
    rank cell gives the residual exactly L/(2N) for a locally linear response, so the
    law holds with k determined by half the local slope.

    Two nested cells then determine everything:

        I = (c*Delta(cN1) - Delta(N1)) / (c - 1),
        resolution part of the coarse cell = Delta(N1) - I = (c/(c-1)) * D,

    where D = Delta(N1) - Delta(cN1) is the between-cell recovery. Note the inflation
    factor c/(c-1): the between-cell recovery UNDERSTATES the coarse cell's resolution
    share, because the fine cell still carries 1/c of the coarse residual. At c = 4
    this is exactly 4/3.

    A third nested cell at N3 = f*N1 is then fully determined:
        Delta(N3) = I + (Delta(N1) - I) / f.

    Interval propagation
    --------------------
    Every map above is affine and monotone in each argument: I increases in the fine
    measurement and decreases in the coarse one, and the share I/Delta(N1) decreases
    in the coarse one. Extremes therefore sit at opposite corners of the measurement
    box, so evaluating two corners is EXACT, not a relaxation.

    Complexity: O(1).
    """
    if c < 2:
        raise ValueError("refinement factor must be at least 2")
    intrinsic = _intrinsic(d_coarse, d_fine, c)
    resolution = d_coarse - intrinsic
    share_lo = _intrinsic(coarse_hi, fine_lo, c) / coarse_hi
    share_hi = _intrinsic(coarse_lo, fine_hi, c) / coarse_lo

    def third(dc: float, df: float) -> float:
        i = _intrinsic(dc, df, c)
        return i + (dc - i) / third_factor

    return RichardsonReport(
        intrinsic_level=intrinsic,
        coarse_resolution_part=resolution,
        intrinsic_share=intrinsic / d_coarse,
        resolution_share=resolution / d_coarse,
        between_cell_recovery=(d_coarse - d_fine) / d_coarse,
        inflation_factor=c / (c - 1),
        intrinsic_share_interval=(share_lo, share_hi),
        third_cell_point=third(d_coarse, d_fine),
        third_cell_interval=(third(coarse_hi, fine_lo), third(coarse_lo, fine_hi)),
    )


"""Structural-versus-statistical ambiguity triage for a nested window ladder."""

from __future__ import annotations

from typing import Literal, NamedTuple, Tuple


class TriageVerdict(NamedTuple):
    certified_slope_floor: float
    structural_ambiguity: float           # absolute, in units of the response
    structural_share: float               # as a fraction of the coarse measured drop
    statistical_width: float              # width of the reported share interval
    dominance_ratio: float                # statistical / structural
    recommendation: Literal["more seeds", "finer windows", "both"]
    explanation: str


def triage(coarse_window: int, fine_window: int,
           cross_window_lo: float, coarse_drop: float,
           share_interval: Tuple[float, float],
           tolerance: float = 2.0) -> TriageVerdict:
    """
    Decide whether the uncertainty in a nested window ladder is STRUCTURAL (the design
    literally cannot distinguish the hypotheses, so no amount of data will help) or
    STATISTICAL (the design can distinguish them; there is simply not enough data yet).

    Mathematics
    -----------
    Upper bound on what the design resolves: for nested windows the cross-window
    difference satisfies |D| <= L/N_coarse, so an observed D certifies L >= N_coarse*D.

    Lower bound on what the design CANNOT resolve: there exist two antitone,
    L-Lipschitz responses that agree at every rate the two-cell ladder ever evaluates
    (the reference line of slope -L/2, and an adversary that descends at the maximal
    rate -L on the first half of the first fine cell, is flat on the second half, and
    rejoins the line thereafter), yet whose intrinsic drops differ by exactly

        L / (4 * N_fine).

    That number is the design's blind spot. Compare it, as a fraction of the coarse
    measured drop, to the statistical width of the reported share interval:

      * statistical >> structural  ->  replicate (more seeds);
      * structural >= statistical  ->  refine the grid (finer windows);
      * comparable                 ->  both.

    Complexity: O(1). All inputs are reported summaries; no data pass is required.
    """
    slope_floor = coarse_window * cross_window_lo
    structural = slope_floor / (4.0 * fine_window)
    structural_share = structural / coarse_drop
    statistical = share_interval[1] - share_interval[0]
    ratio = statistical / structural_share if structural_share > 0 else float("inf")

    if ratio >= tolerance:
        rec: Literal["more seeds", "finer windows", "both"] = "more seeds"
        why = ("Statistical width dominates the design's blind spot by "
               f"{ratio:.1f}x. The ladder can already separate the competing "
               "hypotheses; the reported interval is wide because of sampling noise. "
               "Replicate.")
    elif ratio <= 1.0 / tolerance:
        rec = "finer windows"
        why = ("The design's blind spot dominates the statistical width by "
               f"{1/ratio:.1f}x. More replication cannot help: the ladder cannot "
               "separate the hypotheses at all. Refine the grid or add a cell.")
    else:
        rec = "both"
        why = ("Structural and statistical uncertainty are comparable "
               f"(ratio {ratio:.2f}); progress requires attacking both.")

    return TriageVerdict(
        certified_slope_floor=slope_floor,
        structural_ambiguity=structural,
        structural_share=structural_share,
        statistical_width=statistical,
        dominance_ratio=ratio,
        recommendation=rec,
        explanation=why,
    )


#!/usr/bin/env python3
"""Assemble PACKAGE.json from the project's deliverables and the asset sources."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Logic/UHardenResolutionSplit.lean",
    "Catalog/Logic/UHardenSharpResolution.lean",
    "Catalog/Logic/UHardenOffsetAverage.lean",
    "Catalog/Logic/UHardenLadderIdentifiability.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== FILE: {f} =====\n\n{read(ROOT / f)}" for f in LEAN_FILES
)

FUTURE_DIRECTIONS = """# Future directions — u-hardening, rank resolution, and threshold reweighting

Derived from the verified development of this cycle: the rank-grid model with its
intrinsic/resolution split, the decoupled-design identity and the audit of the reported
shares; the nested bound |D| <= L/N1 with its matching 3/4 witness, the agreement-cell
measure and the falsifiable third-cell prediction; the derivation of the c/N law from an
offset average, with c = L/2, and the sign constraint it imposes; and a matching *lower*
bound — two antitone L-Lipschitz responses that every cell of the design measures
identically, yet whose intrinsic drops differ by L/(4*960).

What survived the adversarial pass: the "NEITHER" verdict of the round (both pre-stated
hypotheses fail) is robust; the *share* attributed to resolution is not. Under the round's
own 1/N reading the resolution share of the coarse cell is (4/3) x 41% ~ 54%, and over the
reported confidence box the intrinsic share is only pinned to [0.36, 0.60]. What failed:
the implicit inference "D > 0 => resolution is a minority" — a purely linear response with
no intrinsic window dependence reproduces D > 0 exactly, and the offset-averaged model even
forces the *sign* of D to encode local geometry rather than a share.

---

## 1. Offset-randomised gating (the decoupled follow-up, sharpened)

**The key insight is** that rank granularity is not noise to be averaged away but a
*deterministic* map theta -> ceil(theta*N)/N whose only free parameter is where the gate
sits inside its cell — so randomising that offset turns the resolution component into a
quantity with a computable law, L/(2N) per gate, instead of a residual to be fitted.
**Why now?** The named follow-up already proposes decoupling the strip bound B from the
population median; the decoupled-design identity shows that decoupling alone makes D a pure
residual difference, and the offset-average result says the offset average then has a
closed form, so the experiment becomes a direct measurement of the local slope rather than
a share estimate.

**Conjecture.** In a decoupled design with the gate offset drawn uniformly inside its rank
cell, E[Delta(N)] = Delta(inf) + (L2 - L1)/(2N) exactly, with no fitted constant.

## 2. Sign rigidity of the window effect

**The key insight is** that D > 0 (drop shrinking with window size) is equivalent, on the
offset-averaged model, to the response being *steeper at the hard gate*, which for a
unimodal score distribution with decaying tail density is false. **Why now?** The reported
D = +0.0437 therefore cannot be explained by rank granularity acting on a decaying tail;
the remaining explanations are gate drift in the nested design (bounded by the nested
cross-window bound) or genuine threshold reweighting.

**Conjecture.** For every population whose score density is decreasing across the strip
between the two gates, the offset-averaged decoupled cross-window difference is
nonpositive; hence any decoupled design that still reports D > 0 certifies threshold
reweighting.

## 3. The third cell

Run N = 3840. The 1/N law predicts Delta(3840) = (5*Delta(960) - Delta(240))/4 = 0.0527,
confined by the reported intervals to [0.0459, 0.0607]. A measurement outside that interval
falsifies the law and voids the 41%-versus-54% share arithmetic; a measurement inside it,
with tightened intervals, would collapse the [0.36, 0.60] share interval considerably.

## 4. Beyond two cells

The identifiability limit gives the blind spot of a *two*-cell ladder, L/(4*N_fine). The
natural generalisation asks for the identifiability width of a k-cell nested ladder
N, Nc, Nc^2, ...; each additional cell adds evaluation points and should shrink the
adversary's room, with a plausible target of order L/(4*N*c^(k-1)) — exponentially
decreasing in the number of cells but only linearly in the total sample.

## 5. Non-uniform grids and weighted gates

Real designs sometimes use weighted or stratified selection, where the realisable rates
form a non-uniform grid. The refinement inequality is the only place uniformity is used
essentially, and it survives whenever the fine grid *contains* the coarse one. Extending
the accounting to arbitrary nested grids should be routine and would broaden the
applicability considerably.

## 6. Caveat carried forward

The nested windows conflate sample size with bound growth: the strip bound moves with the
window, so a nonzero D can be produced by gate drift alone. Decoupling the bound from the
median — holding the gates fixed across windows — is the single design change that removes
the confound.
"""

INTERACTIVE_LAYOUT = r"""
# The Ruler That Changes Length
### A guided tour of rank-grid resolution in threshold statistics

---

## 0. The puzzle, in one paragraph

You are studying the extreme tail of a scored population. A gate at tail rate $\theta$
admits the top $\theta$-fraction; hardening the gate makes your quantity of interest drop.
You measure that drop twice — once on a window of $240$ items, once on a window of $960$ —
and the two windows disagree:

$$\Delta(240) = 0.1073, \qquad \Delta(960) = 0.0636, \qquad D = \Delta(240)-\Delta(960) = +0.0437.$$

Quadrupling the window shrank the measured effect by more than a third. **Is that a fact
about the world, or a fact about your ruler?**

Two hypotheses were on the table before the data arrived. *Most of it is the ruler*, said
one; *none of it is*, said the other. The data said **neither** — quadrupling recovered
$41\%$. That is an honest verdict, and it raises a much better question, which is the one
this page answers: **how much can a design like this possibly know?**

---

## 1. Why a finite window has ticks

Here is the geometry that makes the whole story work. A window of $N$ items has exactly
$N+1$ realisable tail rates: $0, \tfrac1N, \tfrac2N, \dots, 1$. You cannot select "the top
$0.37\%$" of $240$ items. You can select the top $0$, or the top $1$, or the top $2$, and
nothing in between. So the gate you *asked for* and the gate you *got* are different
objects, related by

$$\mathrm{gr}_N(\theta) \;=\; \frac{\lceil \theta N \rceil}{N}$$

— round up to the next available rank. This little function is the entire measuring device.

<details>
<summary><b>Click to reveal: the four properties of the rounding map that drive everything</b></summary>

1. **It never undershoots and never overshoots by much:** $\theta \le \mathrm{gr}_N(\theta) < \theta + \tfrac1N$.
   *Proof:* $\lceil x \rceil \ge x$ and $\lceil x \rceil < x+1$ at $x = \theta N$; divide by $N$.
2. **It respects order:** $\theta \le \theta' \Rightarrow \mathrm{gr}_N(\theta) \le \mathrm{gr}_N(\theta')$.
   Immediate from monotonicity of the ceiling.
3. **It is $1$-Lipschitz up to a rank:** $|\mathrm{gr}_N(\theta)-\mathrm{gr}_N(\theta')| \le |\theta-\theta'| + \tfrac1N$.
4. **Refinement only helps:** if $N' = Nc$ with $c$ a positive integer, then
   $\mathrm{gr}_{Nc}(\theta) \le \mathrm{gr}_N(\theta)$ *always*.
   *Proof:* $\theta N \le \lceil \theta N\rceil$ gives $\theta \cdot Nc \le \lceil\theta N\rceil c$,
   and $\lceil\theta N\rceil c$ is an integer, so $\lceil \theta Nc\rceil \le \lceil\theta N\rceil c$;
   divide by $Nc$.

Property 4 is the one the experiment was built on, whether or not anyone said so:
$960 = 240 \times 4$. The design's two windows are *nested*, and that nesting is worth a
factor of $2.5$ in everything below.
</details>

Play with it. Drag the hard gate slowly and watch the coarse staircase *freeze* between
ticks, then jump. That freezing is the whole phenomenon.

{{interactive_demo:0}}

> **What to try first.** Set the response to *Linear*, put the soft gate at $0$ and slide
> the hard gate through the first coarse cell. The blue (fine) drop changes four times as
> often as the red (coarse) one. Then switch to *The indistinguishable pair* — but don't
> read the verdict box yet; we come back to it in §6.

---

## 2. The split that has no error term

Let $S(\theta)$ be the ideal response — the quantity of interest on an infinitely resolved
window. What you measure is $S_N(\theta) = S(\mathrm{gr}_N(\theta))$, and the gap

$$r_N(\theta) \;=\; S(\theta) - S_N(\theta)$$

is the **resolution residual**: the part of your number that exists only because your ruler
has ticks. If $S$ is *antitone* (decreasing in the tail rate — the natural direction, since
letting more items in dilutes the extremes), then rounding up can only lose, so
$r_N \ge 0$; refining can only shrink it, $r_{Nc} \le r_N$; and if $S$ never changes faster
than rate $L$, then $|r_N(\theta)| \le L/N$.

Now split the measured drop:

$$\boxed{\;\Delta(N) \;=\; \Delta(\infty) \;-\; r_N(\theta_1) \;+\; r_N(\theta_2)\;}$$

This is an **identity**, not an approximation. There is no error term. It defines
"intrinsic part" and "resolution part" precisely, which is what makes everything that
follows a theorem rather than a fit.

{{visualization:0}}

---

## 3. The single most important equation

Compare two windows with the gates *held fixed*. The intrinsic drop is the same real
number in both, so it cancels **identically**:

$$D \;=\; \bigl(r_{N_2}(\theta_1)-r_{N_1}(\theta_1)\bigr) \;-\; \bigl(r_{N_2}(\theta_2)-r_{N_1}(\theta_2)\bigr).$$

**A cross-window difference, in a design that does not move its gates, is a pure resolution
quantity.** It contains no information about the intrinsic drop whatsoever. It is the ruler
talking to itself.

Each residual is at most $L/N$, so $|D| \le 2L(1/N_1 + 1/N_2)$ in general. For *nested*
windows the residuals are additionally *ordered*, $0 \le r_{N_2} \le r_{N_1}$, and the
bound collapses to

$$|D| \;\le\; \frac{L}{N_1}$$

with **no dependence on the fine window at all**. Refining the fine window cannot widen
what the comparison sees; the coarse window is the bottleneck.

{{algorithm:1}}

Run that bound backwards and it becomes a certificate. At $(240, 960)$ it reads
$|D| \le L/240$, and the experiment reports $D \ge 0.0346$, so

$$L \;\ge\; 240 \times 0.0346 \;=\; 8.30.$$

**A flat response with a lucky grid cannot produce this effect.** Something in the
population is genuinely steep.

<details>
<summary><b>Click to reveal: the witness that shows the bound is nearly tight — and why
"$D>0$" proves nothing intrinsic</b></summary>

Take the honest linear response $S(x) = -Lx$: as smooth as anything can be, with *no*
intrinsic window dependence anywhere in it. Put the soft gate at $0$ and the hard gate at
$1/960$. Then $\mathrm{gr}_{240}(1/960) = 1/240$ and $\mathrm{gr}_{960}(1/960) = 1/960$, so

$$\Delta(240)=\frac{L}{240},\qquad \Delta(960)=\frac{L}{960},\qquad D = \frac{L}{320} > 0.$$

Stare at that. A perfectly linear response, with nothing intrinsic to say about window
size, still produces a strictly positive $D$. **So the inference "the effect survives
quadrupling, therefore most of it is real" is not valid.** Only the *size* of $D$ relative
to $L/N$ carries information.

On this witness the certificate $L \ge 240D$ returns $\tfrac34 L$: upper and lower bounds
on what a two-cell nested design can learn about the slope match to the factor $4/3$,
which is exactly the price of not knowing where inside its rank cell the gate sits.

There is also a crisp diagnostic. A *positive* nested $D$ **forces** the coarse grid to
move the hard gate. Contrapositively, in any run where the hard gate lands on a grid point
of both windows, $D \le 0$ is guaranteed. And how often does that happen? Inside one coarse
cell of width $1/N_1$, the two grids agree exactly on the top sub-cell of width
$1/(N_1 c)$ — so for a uniformly placed gate the $240 \to 960$ refinement moves the realised
gate with probability exactly $3/4$.
</details>

---

## 4. Where the $1/N$ law comes from — and the sign it demands

The experiment's own reading was that the resolution part scales like $c/N$: "smooth mass
per offset unchanged, only rate granularity changing." That is an *ansatz*, and everything
downstream rests on it. It deserves a derivation.

The gate sits somewhere inside a rank cell; where exactly is an accident of the population,
so average over it: $\langle f\rangle_N = N\int_0^{1/N} f(t)\,dt$. Three short computations:

- **The measured response is constant in the offset.** Every gate inside the cell
  $(k/N,(k+1)/N]$ is realised at the *same* rate $(k+1)/N$. Granularity destroys all offset
  information.
- **The ideal response averages to its cell midpoint.** If $S$ is linear with slope $-L$
  across the cell, $\langle S\rangle = A - L(\tfrac kN + \tfrac1{2N})$.
- **Therefore** $\displaystyle \langle r_N\rangle = \frac{L}{2N}$ exactly.

So the ansatz is correct, and the constant is *not free*: $c = L/2$, **half the local
slope**. Nothing is fitted.

{{algorithm:4}}

Apply it to a drop, with local slope $L_1$ at the soft gate and $L_2$ at the hard gate: the
offset-averaged measured drop exceeds the intrinsic drop by exactly $(L_2-L_1)/(2N)$, which
gives an exact equivalence:

$$D > 0 \iff L_2 > L_1.$$

**The sign of the window effect is a statement about local geometry.** A positive $D$
requires the response to be *steeper at the hard gate*. But for a survival curve over a
tail with a decaying density, the opposite holds — things flatten out as you go further
out — which would give $D < 0$.

So the reported $D = +0.0437$ has the **wrong sign** to be explained by rank granularity
acting on a decaying tail. Try it yourself: in the laboratory above, switch between
*Decaying tail* and *Reweighted* and watch the sign of $D$ flip.

<details>
<summary><b>Click to reveal: the confound the experiment flagged, quantified</b></summary>

The two windows are *nested*, so the strip bound moves with the window: sample size and
bound growth are not separable. If the gates themselves drift by at most $\varepsilon$
between the windows, the measured difference obeys

$$|D| \;\le\; 2L\left(\frac{1}{N_1}+\frac{1}{N_2}\right) \;+\; 2L\left(\varepsilon + \frac{1}{N_2}\right).$$

A nested $D$ can, in principle, be produced by drift alone. Hence the named follow-up:
**hold the gates fixed across windows.** In a decoupled design the intrinsic drop cancels
identically, $D$ becomes a pure residual difference with a known law, and the experiment
stops estimating a share and starts measuring a slope.
</details>

{{demo:1}}

---

## 5. Extrapolating — and discovering the headline is not certified

Grant the $1/N$ law. Then $\Delta(N) = I + k/N$ is affine in the rank step, and two cells
determine everything by [Richardson extrapolation](https://en.wikipedia.org/wiki/Richardson_extrapolation):

$$I = \frac{4\Delta(960) - \Delta(240)}{3} = \frac{4(0.0636)-0.1073}{3} = 0.0490.$$

That is **less than half** of $\Delta(240) = 0.1073$. The resolution part of the coarse
cell is $0.0583$, or $54\%$.

So the reported $41\%$ is the *between-cell recovery*, not the resolution share. The two
differ by exactly $4/3$ — because the fine cell still carries a quarter of the coarse
cell's residual, so the difference between them necessarily misses a quarter of it.

**At the point estimates the headline is reversed:** resolution is the majority, not the
minority. And propagating the reported intervals, the intrinsic share is pinned only to
$[0.36, 0.60]$ — an interval that straddles $1/2$. "Mostly intrinsic" is *consistent with*
the four cells. It is not *certified* by them.

{{algorithm:2}}

The model also makes a falsifiable prediction: a third nested cell at $N = 3840$ is
completely determined,

$$\Delta(3840) = \frac{5\Delta(960)-\Delta(240)}{4} = 0.0527 \in [0.0459,\, 0.0607].$$

Run that cell. If it lands outside, the $1/N$ reading is dead, and with it the entire
$41\%$-versus-$54\%$ arithmetic.

{{visualization:2}}

---

## 6. The wall: what no re-analysis can recover

Here is the question that ought to be asked of every experimental design and almost never
is: **is the uncertainty statistical, or structural?** Would more seeds help, or is the
design itself blind?

The answer comes from an explicit adversary. Fix a slope budget $L$. Let the *reference* be
the straight line $\ell(x) = -\tfrac L2 x$. Let the *adversary* be

$$\kappa(x) = \begin{cases} -Lx, & x \le \tfrac{1}{1920},\\[2pt] -\tfrac{L}{1920}, & \tfrac{1}{1920} < x \le \tfrac{1}{960},\\[2pt] -\tfrac L2 x, & x > \tfrac1{960}, \end{cases}$$

which descends at the maximal admissible rate $-L$ on the first half of the first fine
cell, goes flat on the second half, and rejoins the reference from $1/960$ onwards. Both
are decreasing. Both are $L$-Lipschitz. Both are entirely legitimate.

Now put the soft gate at $0$ and the hard gate at $\tfrac{1}{1920}$ — *inside* the first
fine cell. The design evaluates at exactly three rates: $0$, $1/240$ and $1/960$. And at
all three, $\kappa$ and $\ell$ **agree**.

{{visualization:1}}

So both windows report **identical** drops for the two responses. No re-analysis, no
reweighting, no cleverness can tell them apart. Yet their intrinsic drops differ by exactly

$$\frac{L}{3840} = \frac{L}{4 \cdot 960}.$$

<details>
<summary><b>Click to reveal: why this is the exact identifiability limit</b></summary>

The construction gives a **lower** bound on the design's ignorance: it cannot pin the
intrinsic drop better than $L/(4N_{\text{fine}})$. The nested bound of §3 gives a matching
**upper** bound: it *does* pin it to within $L/N_{\text{coarse}}$. Upper and lower bounds
on the design's power therefore meet up to a constant, which is the strongest statement one
can make about a measuring instrument without specifying the population.

The verification is three lines of arithmetic. Both responses vanish at $0$. At
$1/240 > 1/960$ the third branch of $\kappa$ *is* $\ell$. At $1/960$, $\kappa$ takes its
middle branch, $\kappa(1/960) = -L/1920 = -\tfrac L2 \cdot \tfrac{1}{960} = \ell(1/960)$.
So the measurements coincide. But at the hard gate itself, $\kappa(1/1920) = -L/1920$ while
$\ell(1/1920) = -L/3840$, and the intrinsic drops differ by $L/3840$.
</details>

Now the punchline. With the certified floor $L \ge 8.30$, the structural ambiguity is

$$\frac{8.30}{3840} \approx 0.0022,$$

about **two percent** of $\Delta(240)$. But the intrinsic share was only pinned to
$[0.36, 0.60]$ — a spread of twenty-four percentage points. Those numbers are not in the
same league.

**The wide interval is not a resolution limit of the design. It is statistical width. More
seeds, not finer windows.**

Set it up yourself and watch the two bars move independently:

{{interactive_demo:1}}

> **What to try.** Shrink both interval half-widths toward zero. The orange bar collapses;
> the purple one barely moves. Now inflate the coarse interval until the verdict flips to
> *BOTH*. The point at which it flips is the sample size at which refining the grid would
> start to be worth more than replicating.

{{algorithm:3}}

---

## 7. Everything at once

The full numerical account — grid geometry, the exact split, the pure-resolution identity,
the nested bound and its witness, the derived $1/N$ law, sign rigidity, the $3/4$ agreement
probability, the four-cell audit, the indistinguishable pair, and the triage — verified
line by line against the closed forms:

{{demo:0}}

And the primitive everything is built from:

{{algorithm:0}}

---

## 8. Why this matters beyond one experiment

Every empirical tail statistic — [value-at-risk](https://en.wikipedia.org/wiki/Value_at_risk)
in finance, extreme-quantile calibration in machine learning,
[false-discovery](https://en.wikipedia.org/wiki/False_discovery_rate) thresholds in
genomics, rare-event rates in reliability engineering — is computed on a finite sample, and
therefore on a rank grid. You never set a threshold; you set the nearest available rank.
When you then vary the sample size and compare, part of what you see is the world and part
is the grid, and the two are entangled in a way that is invisible unless you write down the
rounding map explicitly.

Once you do, four things become sayable that were not sayable before:

| statement | why it matters |
|---|---|
| The cross-window difference is a pure ruler quantity when the gates are fixed | The follow-up design is not a refinement — it changes what is being measured |
| The size of the effect certifies a slope, $L \ge N_1\lvert D\rvert$ | An anomaly becomes a lower bound on the population's steepness |
| The sign of the effect constrains local geometry, $D>0 \iff L_2 > L_1$ | Independently checkable — and here it points *against* granularity |
| The design has a blind spot of width $L/(4N_{\text{fine}})$ | Computable *in advance*; tells you whether more data will help |

The last row is the one to take away. There is a real difference between *not knowing yet*
and *not being able to know*, and it is measurable. A nested two-cell ladder is structurally
blind to about $2\%$ of the measured drop — and statistically uncertain about ten times more
than that. Knowing which is which is the difference between running the right next
experiment and running a bigger version of the wrong one.
"""

package = {
    "title": "The Ruler That Changes Length: Rank-Grid Resolution, Sharp Nested Bounds, "
             "and the Identifiability Limit of a Two-Cell Window Ladder",
    "domain": "Logic",
    "description": (
        "An exact order-theoretic calculus for threshold statistics measured on finite "
        "windows, splitting a measured gate drop into an intrinsic part and a rank-grid "
        "resolution residual, with matching upper and lower bounds on what a nested "
        "two-cell window ladder can identify. Applied to a reported four-cell experiment, "
        "it certifies a Lipschitz floor, refutes both pre-stated hypotheses, corrects the "
        "resolution share by a factor of 4/3, and shows the residual uncertainty is "
        "statistical rather than structural."
    ),
    "authors": ["Aristotle"],
    "date": "2026-09-03",
    "key_results": [
        "Exact split of a measured gate drop into an intrinsic drop and two rank-grid "
        "resolution residuals, with no error term",
        "In a design that holds its gates fixed across windows, the cross-window "
        "difference is purely a resolution quantity: the intrinsic drop cancels "
        "identically",
        "Sharp nested cross-window bound |D| <= L/N_coarse, independent of the fine "
        "window, attained within the factor 4/3 by an explicit linear witness; a purely "
        "linear response with no window dependence already produces a strictly positive D",
        "Derivation of the 1/N resolution law by averaging over the gate offset inside its "
        "rank cell, with constant exactly half the local slope, and the resulting sign "
        "rigidity: the measured drop shrinks with window size if and only if the response "
        "is steeper at the hard gate",
        "Identifiability limit of a two-cell nested ladder: two antitone L-Lipschitz "
        "responses measured identically by every cell whose intrinsic drops differ by "
        "exactly L/(4 N_fine), showing the reported share interval is statistical width "
        "rather than a resolution limit of the design",
    ],
    "keywords": [
        "rank grid", "threshold statistics", "resolution bias", "identifiability",
        "Richardson extrapolation", "Lipschitz certificate", "nested window design",
        "order statistics",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "Complete Numerical Verification of the Rank-Grid Resolution Calculus",
            "description": (
                "A ten-part verification suite that checks every closed form in the theory "
                "against direct computation. It confirms the grid bracketing "
                "theta <= gr_N(theta) < theta + 1/N together with monotonicity and the "
                "refinement inequality; the exact split identity to machine precision on a "
                "nonlinear response; that a decoupled cross-window difference is invariant "
                "under an additive shift of the response, hence carries no intrinsic "
                "information; the nested bound |D| <= L/N1 over twenty thousand random gate "
                "pairs, and the linear witness for which the slope certificate recovers "
                "exactly three quarters of the truth; the offset-averaged residual law "
                "L/(2N) to eighteen decimal places across three windows and two cells; sign "
                "rigidity, by driving the local slopes at the two gates in both directions; "
                "the 3/4 agreement probability by Monte Carlo; the full four-cell audit "
                "including the certified Lipschitz floor 8.30, the failure of both "
                "pre-stated hypotheses across the whole reported box, Richardson "
                "extrapolation to an intrinsic level of 0.0490, the exact 4/3 factor "
                "between between-cell recovery and resolution share, the [0.36, 0.60] "
                "intrinsic-share interval and the falsifiable third-cell prediction "
                "[0.0459, 0.0607]; the indistinguishable pair of responses whose intrinsic "
                "drops differ by L/3840; and the final structural-versus-statistical triage."
            ),
            "code": read(ROOT / "demo.py"),
        },
        {
            "name": "Decoupled Versus Nested Designs: How Gate Drift Manufactures a Window Effect",
            "description": (
                "Isolates the confound recorded with the four-cell experiment. In a nested "
                "design the strip bound grows with the window, so the two windows do not "
                "evaluate the same nominal gates and sample size is entangled with bound "
                "growth; in a decoupled design the gates are held fixed and the intrinsic "
                "drop cancels identically. The script measures the decoupled cross-window "
                "difference against the nested bound L/N1, introduces a gate drift of size "
                "eps and verifies the enlarged bound 2L(1/N1 + 1/N2) + 2L(eps + 1/N2), "
                "computes by bisection the drift at which the drift term alone reproduces "
                "the reported effect size of 0.0437 (about 0.63 coarse rank steps), and "
                "confirms over two hundred thousand random gate pairs the diagnostic that "
                "an unmoved hard gate forbids a positive cross-window difference."
            ),
            "code": read(A / "demo_drift.py"),
        },
    ],
    "algorithms": [
        {
            "name": "Rank-Grid Realisation and Exact Resolution Residual Decomposition",
            "description": (
                "The primitive on which the whole calculus rests. Given a response oracle, "
                "a window size N and a nominal tail rate theta, it computes the realised "
                "rate gr_N(theta) = ceil(theta*N)/N — the rate the window can actually "
                "deliver — together with the ideal value, the measured value and their "
                "difference, the resolution residual. The rounding is upward, the "
                "conservative convention for a tail gate: never admit more items than "
                "requested. The realised rate satisfies theta <= gr_N(theta) < theta + 1/N, "
                "is monotone in theta, and for nested windows satisfies "
                "gr_{Nc}(theta) <= gr_N(theta), which is what makes a fine window a genuine "
                "refinement of a coarse one. Building on this, the routine splits a measured "
                "gate drop exactly as Delta(N) = Delta(inf) - r_N(soft) + r_N(hard); the "
                "reported identity error is floating-point noise only, since the identity "
                "has no error term. Complexity is O(1) per evaluation, with two oracle calls "
                "per gate."
            ),
            "pseudocode": (
                "function GRID_UP(N, theta):\n"
                "    require N > 0\n"
                "    return ceil(theta * N) / N\n"
                "\n"
                "function READ_THROUGH_GRID(S, N, theta):\n"
                "    realised  <- GRID_UP(N, theta)\n"
                "    ideal     <- S(theta)\n"
                "    measured  <- S(realised)\n"
                "    return (nominal    = theta,\n"
                "            realised   = realised,\n"
                "            overshoot  = realised - theta,      // lies in [0, 1/N)\n"
                "            ideal      = ideal,\n"
                "            measured   = measured,\n"
                "            residual   = ideal - measured)      // >= 0 if S is antitone\n"
                "\n"
                "function SPLIT_GATE_DROP(S, N, soft, hard):\n"
                "    a <- READ_THROUGH_GRID(S, N, soft)\n"
                "    b <- READ_THROUGH_GRID(S, N, hard)\n"
                "    measured_drop  <- a.measured - b.measured\n"
                "    intrinsic_drop <- a.ideal    - b.ideal\n"
                "    // the identity Delta(N) = Delta(inf) - r(soft) + r(hard)\n"
                "    error <- measured_drop - (intrinsic_drop - a.residual + b.residual)\n"
                "    return (measured_drop, intrinsic_drop,\n"
                "            a.residual, b.residual, error)"
            ),
            "code": read(A / "alg_grid.py"),
        },
        {
            "name": "Nested Cross-Window Slope Certificate",
            "description": (
                "Turns an observed cross-window difference into a certified lower bound on "
                "the steepness of the underlying response. For an antitone, L-Lipschitz "
                "response measured on nested windows N2 = c*N1 with the gates held fixed, "
                "the intrinsic drop cancels and D is a difference of two brackets, each of "
                "which lies in [-L/N1, 0] because refinement can only shrink a nonnegative "
                "residual. Hence |D| <= L/N1 with no dependence on the fine window at all: "
                "the coarse window is the bottleneck. Reading the bound backwards gives "
                "L >= N1*|D|. Without nestedness one only obtains |D| <= 2L(1/N1 + 1/N2), a "
                "certificate 2.5 times weaker at (240, 960). Tightness is exact: on the "
                "linear witness S(x) = -Lx with gates (0, 1/N2) the true value is "
                "D = L/N1 - L/N2, so the certificate recovers precisely (N2-N1)/N2 of the "
                "slope — three quarters at (240, 960) — and upper and lower bounds match to "
                "the factor c/(c-1). Complexity O(1)."
            ),
            "pseudocode": (
                "function NESTED_SLOPE_CERTIFICATE(N1, N2, D):\n"
                "    require N1 > 0 and N2 > 0\n"
                "    require N2 mod N1 = 0        // the windows must be nested\n"
                "    c <- N2 / N1\n"
                "    d <- |D|\n"
                "\n"
                "    // nested bound: |D| <= L / N1   (no N2 dependence)\n"
                "    certified <- N1 * d\n"
                "\n"
                "    // generic bound: |D| <= 2L(1/N1 + 1/N2)\n"
                "    generic   <- d / (2 * (1/N1 + 1/N2))\n"
                "\n"
                "    return (certified_slope_floor = certified,\n"
                "            generic_slope_floor   = generic,\n"
                "            sharpening            = certified / generic,\n"
                "            tightness             = (N2 - N1) / N2)   // 3/4 at (240,960)"
            ),
            "code": read(A / "alg_certificate.py"),
        },
        {
            "name": "Richardson Intrinsic Extrapolation with Exact Interval Propagation",
            "description": (
                "Separates the intrinsic level from the resolution part of a measured gate "
                "drop given two nested cells, and propagates measurement intervals without "
                "any relaxation. The law Delta(N) = I + k/N is not assumed but derived: "
                "averaging over the position of the gate inside its rank cell gives a "
                "residual of exactly L/(2N) for a locally linear response. Two nested cells "
                "then determine I = (c*Delta(cN1) - Delta(N1))/(c-1) and the coarse cell's "
                "resolution part (c/(c-1))*D, where D is the between-cell recovery. The "
                "inflation factor c/(c-1) is the algorithm's central observation: the fine "
                "cell still carries a fraction 1/c of the coarse residual, so the "
                "between-cell recovery systematically understates the resolution share — by "
                "exactly 4/3 at c = 4, which converts a reported 41% minority into a 54% "
                "majority. A third nested cell is then fully determined. Because every map "
                "is affine and monotone in each argument (increasing in the fine "
                "measurement, decreasing in the coarse one), evaluating two opposite corners "
                "of the measurement box gives the exact extremes, not a bound. "
                "Complexity O(1)."
            ),
            "pseudocode": (
                "function INTRINSIC(d_coarse, d_fine, c):\n"
                "    return (c * d_fine - d_coarse) / (c - 1)\n"
                "\n"
                "function RICHARDSON_ANALYSE(d1, d2, d1_lo, d1_hi, d2_lo, d2_hi, c, f):\n"
                "    require c >= 2\n"
                "    I          <- INTRINSIC(d1, d2, c)\n"
                "    resolution <- d1 - I                      // = (c/(c-1)) * (d1 - d2)\n"
                "    recovery   <- (d1 - d2) / d1              // the reported ratio\n"
                "    inflation  <- c / (c - 1)                 // 4/3 at c = 4\n"
                "\n"
                "    // exact interval propagation: opposite corners of the box\n"
                "    share_lo <- INTRINSIC(d1_hi, d2_lo, c) / d1_hi\n"
                "    share_hi <- INTRINSIC(d1_lo, d2_hi, c) / d1_lo\n"
                "\n"
                "    // third nested cell at N3 = f * N1 is fully determined\n"
                "    function THIRD(a, b):\n"
                "        i <- INTRINSIC(a, b, c)\n"
                "        return i + (a - i) / f\n"
                "\n"
                "    return (intrinsic_level        = I,\n"
                "            resolution_share       = resolution / d1,\n"
                "            between_cell_recovery  = recovery,\n"
                "            inflation_factor       = inflation,\n"
                "            intrinsic_share_range  = [share_lo, share_hi],\n"
                "            third_cell             = THIRD(d1, d2),\n"
                "            third_cell_range       = [THIRD(d1_hi, d2_lo),\n"
                "                                      THIRD(d1_lo, d2_hi)])"
            ),
            "code": read(A / "alg_richardson.py"),
        },
        {
            "name": "Structural-Versus-Statistical Ambiguity Triage for a Nested Window Ladder",
            "description": (
                "Decides whether the residual uncertainty in a window ladder is structural — "
                "the design literally cannot separate the competing hypotheses, so no amount "
                "of replication will help — or statistical, in which case replication is "
                "exactly what is needed. It combines the two matching bounds. From above, "
                "the nested bound |D| <= L/N_coarse certifies L >= N_coarse * D. From below, "
                "there exist two antitone L-Lipschitz responses that agree at every rate the "
                "two-cell ladder evaluates (the reference line of slope -L/2 and an "
                "adversary that descends at the maximal rate -L on the first half of the "
                "first fine cell, is flat on the second half, and rejoins the line "
                "thereafter) whose intrinsic drops nevertheless differ by exactly "
                "L/(4*N_fine). That number is the blind spot; expressed as a fraction of the "
                "coarse measured drop it is directly comparable to the statistical width of "
                "the reported share interval. On the four-cell design the blind spot is "
                "about 2% while the share interval spans 24 percentage points, an order of "
                "magnitude larger — hence the recommendation to replicate rather than refine. "
                "Complexity O(1); it consumes only reported summaries, requiring no data pass."
            ),
            "pseudocode": (
                "function TRIAGE(N_coarse, N_fine, D_lower, coarse_drop,\n"
                "                share_interval, tolerance = 2):\n"
                "    // upper bound on ambiguity  ->  certified slope\n"
                "    L <- N_coarse * D_lower\n"
                "\n"
                "    // lower bound on ambiguity  ->  the design's blind spot\n"
                "    structural       <- L / (4 * N_fine)\n"
                "    structural_share <- structural / coarse_drop\n"
                "\n"
                "    statistical <- share_interval.high - share_interval.low\n"
                "    ratio       <- statistical / structural_share\n"
                "\n"
                "    if ratio >= tolerance:\n"
                "        return ('more seeds',\n"
                "                'the ladder can separate the hypotheses; the interval is\n"
                "                 wide because of sampling noise')\n"
                "    else if ratio <= 1 / tolerance:\n"
                "        return ('finer windows',\n"
                "                'replication cannot help: two admissible responses agree\n"
                "                 on every cell of this ladder')\n"
                "    else:\n"
                "        return ('both', 'the two sources are comparable')"
            ),
            "code": read(A / "alg_triage.py"),
        },
        {
            "name": "Offset-Averaged Resolution Bias Estimator",
            "description": (
                "Derives, rather than fits, the 1/N law for resolution bias. The gate sits "
                "somewhere inside a rank cell of width 1/N and where exactly is an accident "
                "of the population, so the estimator averages over that offset. Three facts "
                "then fall out. The measured response is constant in the offset — every gate "
                "in the cell is realised at the same rate, so rank granularity destroys all "
                "offset information. A response that is affine with slope -L across the cell "
                "averages to its cell midpoint value. Subtracting, the offset-averaged "
                "residual is exactly L/(2N): the widely used 'residual proportional to 1/N' "
                "ansatz is correct, and its constant is half the local slope, determined "
                "rather than fitted. Inverting, 2*N times the mean residual is a direct "
                "read-off of the local slope, which is precisely what an offset-randomised "
                "design measures. For a drop across two gates with local slopes L1 and L2 "
                "the bias is (L2 - L1)/(2N), so a drop that shrinks with window size requires "
                "the response to be steeper at the hard gate — a checkable constraint on the "
                "population, not a free parameter. Numerically the routine uses the midpoint "
                "rule, exact for affine integrands up to floating point; complexity O(nodes)."
            ),
            "pseudocode": (
                "function OFFSET_AVERAGED_RESIDUAL(S, N, k, local_slope, nodes):\n"
                "    require N > 0 and nodes > 0\n"
                "    step  <- (1/N) / nodes\n"
                "    total <- 0\n"
                "\n"
                "    for j = 0 .. nodes-1:\n"
                "        t     <- (j + 1/2) * step          // midpoint of the subinterval\n"
                "        theta <- k/N + t                   // gate at offset t in cell k\n"
                "        total <- total + S(theta) - S(GRID_UP(N, theta))\n"
                "\n"
                "    mean      <- total / nodes\n"
                "    predicted <- local_slope / (2 * N)     // the derived law\n"
                "\n"
                "    return (empirical  = mean,\n"
                "            predicted  = predicted,\n"
                "            deviation  = |mean - predicted|,\n"
                "            slope_read = 2 * N * mean)     // inverts to the local slope"
            ),
            "code": read(A / "alg_offset.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Staircase and the Curve: Rank-Grid Rounding and Its Residual",
            "description": (
                "A three-panel portrait of the measuring device. The top panel draws the "
                "rounding map gr_N(theta) = ceil(theta*N)/N as a staircase against the "
                "identity for both windows of the design, making visible both the bracketing "
                "theta <= gr_N(theta) < theta + 1/N and the refinement inequality — the fine "
                "staircase never rises above the coarse one. The middle panel shows what that "
                "does to a smooth response: the measured response is a step function, "
                "evaluable only at rank rates. The bottom panel plots the resolution residual "
                "itself, a sawtooth that is nonnegative, capped by the envelope L/N, and "
                "averages over the gate offset to exactly L/(2N) — both levels drawn for each "
                "window, so the derived 1/N law can be read straight off the picture."
            ),
            "code": read(A / "viz_staircase.py"),
        },
        {
            "name": "Two Responses the Design Cannot Tell Apart",
            "description": (
                "The identifiability limit, made visual. The left panel plots the reference "
                "response of slope -L/2 against the adversary, which descends at the maximal "
                "admissible rate -L on the first half of the first fine cell, is flat on the "
                "second half, and rejoins the reference from 1/960 onwards; both are antitone "
                "and L-Lipschitz. The only three rates the two-cell ladder ever evaluates — "
                "0, 1/240 and 1/960 — are marked, and at all three the curves coincide, while "
                "the shaded bar at the hard gate 1/1920 is the intrinsic gap L/3840 that no "
                "measurement can see. The right panel makes the point quantitatively: both "
                "measured drops are bit-for-bit identical, and only the unmeasurable "
                "intrinsic drop distinguishes the two responses."
            ),
            "code": read(A / "viz_identifiability.py"),
        },
        {
            "name": "Richardson Extrapolation and the Structural-Versus-Statistical Gap",
            "description": (
                "The audit of the four-cell design in one figure. The left panel plots the "
                "measured drop against the rank step 1/N, where the derived law makes the "
                "relationship a straight line whose intercept is the intrinsic level; the "
                "four corners of the reported confidence box are swept as grey lines to show "
                "the family of admissible extrapolations, the star at 1/N = 0 marks the "
                "extrapolated intrinsic level 0.0490, the annotated segment is the coarse "
                "cell's resolution part 0.0583 (54%), and the third-cell prediction at "
                "N = 3840 is drawn with its propagated interval [0.0459, 0.0607]. The right "
                "panel places the design's blind spot, 2.02% of the coarse drop, next to the "
                "statistical width of the intrinsic share interval, 23.8 percentage points — "
                "the comparison that yields the recommendation to add seeds rather than "
                "refine the grid."
            ),
            "code": read(A / "viz_richardson.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Rank-Grid Laboratory",
            "description": (
                "A live bench for the entire calculus. Sliders control the coarse window, the "
                "refinement factor, both gate levels and the slope budget, while four modes "
                "switch the underlying response between a pure line, a decaying tail that "
                "flattens outward, a reweighted population that steepens outward, and the "
                "indistinguishable pair of the identifiability construction. The canvas draws "
                "the ideal response with both measured staircases superimposed, marks where "
                "each nominal gate is actually realised on each grid, and shows the two "
                "measured drops as vertical bars. A live table reports the realised gates, "
                "the two drops, the true intrinsic drop, the cross-window difference D, the "
                "nested bound L/N1 and the slope certificate; a verdict panel checks the "
                "bound, applies the hard-gate diagnostic, and computes the c/(c-1) correction "
                "from between-cell recovery to resolution share. Dragging the hard gate "
                "slowly makes the central phenomenon visceral: the coarse measurement freezes "
                "between rank ticks and then jumps. Switching between the decaying and "
                "reweighted responses flips the sign of D, demonstrating sign rigidity "
                "directly; and in the fourth mode the two curves report identical drops on "
                "every cell while their intrinsic drops differ by the blind-spot width."
            ),
            "html": read(A / "widget_lab.html"),
        },
        {
            "title": "Structural or Statistical? The Design Triage Dashboard",
            "description": (
                "The decision tool that closes the argument. Four sliders set the two measured "
                "drops and the half-widths of their confidence intervals; everything else is "
                "computed live. The left plot shows the two measurements against the rank "
                "step, with the family of admissible extrapolation lines sweeping the "
                "confidence box, the intrinsic level as a star at 1/N = 0, and the "
                "third-cell prediction with its propagated interval. The right plot places "
                "two bars side by side: the design's structural blind spot L/(4*N_fine), "
                "which depends only on the certified slope and the geometry of the ladder, "
                "and the statistical width of the intrinsic share interval, which depends "
                "only on the reported precision. A verdict panel names the winner and says "
                "what to do — replicate, refine, or both — and flags whether the share "
                "interval straddles one half, which is exactly the condition under which "
                "'mostly intrinsic' is consistent with the data but not certified by it. "
                "Shrinking the interval half-widths collapses the orange bar while leaving "
                "the purple one untouched; that asymmetry is the recommendation."
            ),
            "html": read(A / "widget_triage.html"),
        },
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {
        "demo": read(ROOT / "demo.py"),
        "demo_drift": read(A / "demo_drift.py"),
        "alg_grid": read(A / "alg_grid.py"),
        "alg_certificate": read(A / "alg_certificate.py"),
        "alg_richardson": read(A / "alg_richardson.py"),
        "alg_triage": read(A / "alg_triage.py"),
        "alg_offset": read(A / "alg_offset.py"),
        "viz_staircase": read(A / "viz_staircase.py"),
        "viz_identifiability": read(A / "viz_identifiability.py"),
        "viz_richardson": read(A / "viz_richardson.py"),
    },
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {out}  ({out.stat().st_size} bytes)")


#!/usr/bin/env python3
"""
Decoupled versus nested designs: how gate drift manufactures a window effect.

This demonstration isolates the confound recorded with the four-cell experiment. In a
NESTED design the strip bound grows with the window, so the two windows do not evaluate
the same nominal gates: sample size and bound growth move together. In a DECOUPLED
design the gates are held fixed, the intrinsic drop cancels identically, and the
cross-window difference becomes a pure resolution quantity.

The script:

  1. Builds a response with known local geometry and measures the decoupled
     cross-window difference D, verifying it against |D| <= L/N1 (nested windows).
  2. Introduces a gate drift of size eps between the windows and measures how much of
     the observed difference the drift alone can manufacture, verifying the bound
        |Delta(N1; a) - Delta(N2; b)| <= 2L(1/N1 + 1/N2) + 2L(eps + 1/N2).
  3. Sweeps eps and reports the drift at which the drift term alone reaches the
     reported effect size of 0.0437 — i.e. how small the drift must be for the
     observed number to require a genuine explanation.
  4. Confirms the diagnostic: whenever the refinement leaves the hard gate unmoved,
     the cross-window difference is nonpositive.

Self-contained; standard library only.
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Tuple

LIP: float = 8.30
N1: int = 240
N2: int = 960
REPORTED_D: float = 0.0437


def grid_up(n: int, theta: float) -> float:
    """Realised gate on a window of n items."""
    return math.ceil(theta * n) / n


def gate_drop(s: Callable[[float], float], n: int, t1: float, t2: float) -> float:
    """Measured drop on window n between gates t1 (soft) and t2 (hard)."""
    return s(grid_up(n, t1)) - s(grid_up(n, t2))


def two_slope_response(l1: float, l2: float, knee: float) -> Callable[[float], float]:
    """Antitone response with slope -l1 below the knee and -l2 above it."""
    def s(x: float) -> float:
        if x <= knee:
            return -l1 * x
        return -l1 * knee - l2 * (x - knee)
    return s


def decoupled_difference(s: Callable[[float], float], t1: float, t2: float) -> float:
    """D with the gates held fixed across the two windows."""
    return gate_drop(s, N1, t1, t2) - gate_drop(s, N2, t1, t2)


def nested_difference(s: Callable[[float], float], t1: float, t2: float,
                      eps: float) -> float:
    """The coarse window uses gates drifted by +eps relative to the fine window."""
    return gate_drop(s, N1, t1 + eps, t2 + eps) - gate_drop(s, N2, t1, t2)


def drift_bound(eps: float) -> float:
    """2L(1/N1 + 1/N2) + 2L(eps + 1/N2)."""
    return 2 * LIP * (1 / N1 + 1 / N2) + 2 * LIP * (eps + 1 / N2)


def sweep_drift(s: Callable[[float], float], t1: float, t2: float,
                epsilons: List[float]) -> List[Tuple[float, float, float, bool]]:
    """For each drift, report the nested difference, its bound, and whether it holds."""
    out: List[Tuple[float, float, float, bool]] = []
    for eps in epsilons:
        obs = nested_difference(s, t1, t2, eps)
        bnd = drift_bound(eps)
        out.append((eps, obs, bnd, abs(obs) <= bnd + 1e-12))
    return out


def main() -> None:
    print(__doc__)
    s = two_slope_response(l1=LIP * 0.35, l2=LIP, knee=0.010)
    # Gates chosen off both grids, so that the refinement actually moves them; gates that
    # happen to land on a shared rank point give D = 0 identically (the diagnostic of §4).
    soft, hard = 0.00301, 0.01047

    print("=" * 76)
    print("1. Decoupled design: the cross-window difference is PURE resolution")
    print("=" * 76)
    d = decoupled_difference(s, soft, hard)
    print(f"   Delta({N1}) = {gate_drop(s, N1, soft, hard):.6f}")
    print(f"   Delta({N2}) = {gate_drop(s, N2, soft, hard):.6f}")
    print(f"   D           = {d:.6f}")
    print(f"   nested bound L/N1 = {LIP/N1:.6f}   holds = {abs(d) <= LIP/N1 + 1e-12}")
    print(f"   certified slope floor from this D: L >= {N1*abs(d):.4f}  (true L = {LIP})")

    print("\n" + "=" * 76)
    print("2. Nested design: drift adds a second, larger term")
    print("=" * 76)
    print(f"   {'drift eps':>12s} {'observed':>12s} {'bound':>12s}  holds")
    for eps, obs, bnd, ok in sweep_drift(s, soft, hard,
                                         [0.0, 0.0002, 0.001, 0.002, 0.005]):
        print(f"   {eps:12.5f} {obs:12.6f} {bnd:12.6f}  {ok}")

    print("\n" + "=" * 76)
    print("3. How much drift would it take to manufacture the reported effect?")
    print("=" * 76)
    lo, hi = 0.0, 0.05
    for _ in range(200):
        mid = 0.5 * (lo + hi)
        if 2 * LIP * mid >= REPORTED_D:
            hi = mid
        else:
            lo = mid
    print(f"   The pure drift term 2*L*eps reaches D = {REPORTED_D} at "
          f"eps = {hi:.6f}")
    print(f"   i.e. a gate drift of about {hi*100:.4f} percentage points of tail rate,")
    print(f"   which is {hi*N1:.3f} coarse rank steps.  Anything larger and the reported")
    print("   effect needs no intrinsic explanation at all.")

    print("\n" + "=" * 76)
    print("4. Diagnostic: an unmoved hard gate forbids a positive difference")
    print("=" * 76)
    rng = random.Random(20260972)
    checked = 0
    violations = 0
    for _ in range(200_000):
        a = rng.uniform(0.0, 0.03)
        b = a + rng.uniform(1e-6, 0.03)
        if abs(grid_up(N2, b) - grid_up(N1, b)) < 1e-15:
            checked += 1
            if decoupled_difference(s, a, b) > 1e-12:
                violations += 1
    print(f"   draws with the hard gate unmoved by the refinement: {checked}")
    print(f"   of those, draws with D > 0: {violations}  (theory predicts 0)")

    print("\n" + "=" * 76)
    print("Conclusion: with the gates held fixed the window comparison measures the "
          "ruler;\nwith the gates drifting it measures the ruler plus the drift. Only "
          "the first\ndesign can attribute anything to the population.")
    print("=" * 76)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Two responses the design cannot tell apart.

Plots the reference response ell(x) = -(L/2)x against the adversary kappa, which
descends at the maximal admissible rate -L on the first half of the first fine cell,
is flat on the second half, and rejoins ell from 1/960 onwards. Marks the only three
rates a two-cell nested ladder with gates (0, 1/1920) ever evaluates — 0, 1/240 and
1/960 — at which the two curves agree exactly, and shades the intrinsic gap L/3840
that the design can never see.

Output: uharden_identifiability.png
"""

from __future__ import annotations

import math

import matplotlib.pyplot as plt
import numpy as np


LIP = 8.30


def ell(x: float) -> float:
    return -(LIP / 2.0) * x


def kappa(x: float) -> float:
    if x <= 1.0 / 1920.0:
        return -(LIP * x)
    if x <= 1.0 / 960.0:
        return -(LIP / 1920.0)
    return -(LIP / 2.0) * x


def grid_up(n: int, theta: float) -> float:
    return math.ceil(theta * n) / n


def main() -> None:
    xs = np.linspace(0.0, 1.0 / 200.0, 6000)
    fig, axes = plt.subplots(1, 2, figsize=(13, 5.6))

    # --- left: the two responses, zoomed on the first fine cell --------------------
    ax = axes[0]
    zoom = np.linspace(0.0, 1.6 / 960.0, 4000)
    ax.plot(zoom, [ell(x) for x in zoom], color="#2980b9", lw=2.4,
            label=r"reference $\ell(x) = -\frac{L}{2}x$")
    ax.plot(zoom, [kappa(x) for x in zoom], color="#c0392b", lw=2.4, ls="--",
            label=r"adversary $\kappa$")

    hard = 1.0 / 1920.0
    ax.plot([hard, hard], [ell(hard), kappa(hard)], color="#27ae60", lw=3.0,
            solid_capstyle="butt")
    ax.annotate(fr"invisible gap $L/3840 = {LIP/3840:.5f}$",
                xy=(hard, (ell(hard) + kappa(hard)) / 2),
                xytext=(hard * 1.35, (ell(hard) + kappa(hard)) / 2 + 0.0012),
                fontsize=10, color="#27ae60",
                arrowprops=dict(arrowstyle="->", color="#27ae60"))

    for x, lab, dx, dy in [(0.0, "0", 2.2e-4, -0.0011),
                           (1.0 / 960.0, "1/960", 1.6e-4, 0.0013)]:
        ax.plot([x], [ell(x)], "o", color="#111111", ms=7, zorder=5)
        ax.annotate(f"measured at {lab}", xy=(x, ell(x)), xytext=(x + dx, ell(x) + dy),
                    fontsize=9, arrowprops=dict(arrowstyle="->", color="#111111"))
    ax.text(0.98, 0.03,
            "(the coarse window also evaluates at 1/240, off this zoom,\n"
            "where the two curves coincide as well)",
            transform=ax.transAxes, ha="right", fontsize=8.5, color="#555555")
    ax.axvline(1.0 / 1920.0, color="#95a5a6", ls=":", lw=1.0)
    ax.axvline(1.0 / 960.0, color="#95a5a6", ls=":", lw=1.0)
    ax.set_xlabel("tail rate $x$")
    ax.set_ylabel("response")
    ax.set_title("Two admissible responses (both antitone, both $L$-Lipschitz)\n"
                 "that agree at every rate the design evaluates", fontsize=11)
    ax.legend(loc="lower left", fontsize=10)
    ax.grid(alpha=0.25)

    # --- right: the measurements the design makes ----------------------------------
    ax = axes[1]
    soft, hardgate = 0.0, 1.0 / 1920.0
    labels, ell_vals, kap_vals = [], [], []
    for n in (240, 960):
        d_ell = ell(grid_up(n, soft)) - ell(grid_up(n, hardgate))
        d_kap = kappa(grid_up(n, soft)) - kappa(grid_up(n, hardgate))
        labels.append(f"$\\Delta({n})$")
        ell_vals.append(d_ell)
        kap_vals.append(d_kap)
    labels.append(r"$\Delta(\infty)$")
    ell_vals.append(ell(soft) - ell(hardgate))
    kap_vals.append(kappa(soft) - kappa(hardgate))

    idx = np.arange(len(labels))
    ax.bar(idx - 0.19, ell_vals, width=0.36, color="#2980b9", label=r"reference $\ell$")
    ax.bar(idx + 0.19, kap_vals, width=0.36, color="#c0392b", label=r"adversary $\kappa$")
    for i, (a, b) in enumerate(zip(ell_vals, kap_vals)):
        tag = "identical" if abs(a - b) < 1e-15 else f"differ by {b - a:.5f}"
        colour = "#111111" if abs(a - b) < 1e-15 else "#27ae60"
        ax.text(i, max(a, b) * 1.06, tag, ha="center", fontsize=9.5, color=colour)
    ax.set_xticks(idx)
    ax.set_xticklabels(labels, fontsize=12)
    ax.set_ylabel("gate drop")
    ax.set_title("Every cell of the design agrees; only the unmeasurable\n"
                 "intrinsic drop distinguishes them", fontsize=11)
    ax.legend(fontsize=10)
    ax.grid(alpha=0.25, axis="y")

    fig.tight_layout()
    fig.savefig("uharden_identifiability.png", dpi=170)
    print("wrote uharden_identifiability.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Richardson extrapolation and the structural-versus-statistical gap.

Left panel: the measured drop plotted against the rank step 1/N. Under the derived
law Delta(N) = I + k/N the two measured cells lie on a straight line whose intercept
is the intrinsic level I; the whole reported confidence box is swept to show the
family of admissible lines, and the third-cell prediction at N = 3840 is marked with
its propagated interval.

Right panel: the design's blind spot (structural ambiguity L/(4*N_fine), as a
fraction of the coarse drop) shown next to the statistical width of the intrinsic
share interval — the comparison that decides "more seeds" versus "finer windows".

Output: uharden_richardson.png
"""

from __future__ import annotations

import matplotlib.pyplot as plt
import numpy as np

D240, D240_LO, D240_HI = 0.1073, 0.0973, 0.1148
D960, D960_LO, D960_HI = 0.0636, 0.0597, 0.0680
D_LO = 0.0346


def intrinsic(d1: float, d2: float, c: int = 4) -> float:
    return (c * d2 - d1) / (c - 1)


def main() -> None:
    fig, axes = plt.subplots(1, 2, figsize=(13.5, 5.6))

    # --- left: extrapolation in 1/N -------------------------------------------------
    ax = axes[0]
    xs = np.linspace(0.0, 1.0 / 200.0, 400)

    for d1 in (D240_LO, D240_HI):
        for d2 in (D960_LO, D960_HI):
            i = intrinsic(d1, d2)
            k = (d1 - i) * 240.0
            ax.plot(xs, i + k * xs, color="#bdc3c7", lw=1.0, alpha=0.9)

    i0 = intrinsic(D240, D960)
    k0 = (D240 - i0) * 240.0
    ax.plot(xs, i0 + k0 * xs, color="#2c3e50", lw=2.4,
            label=fr"$\Delta(N) = I + k/N$,  $I = {i0:.4f}$")

    ax.errorbar([1 / 240], [D240], yerr=[[D240 - D240_LO], [D240_HI - D240]],
                fmt="o", color="#c0392b", ms=9, capsize=5, label=r"measured $\Delta(240)$")
    ax.errorbar([1 / 960], [D960], yerr=[[D960 - D960_LO], [D960_HI - D960]],
                fmt="o", color="#2980b9", ms=9, capsize=5, label=r"measured $\Delta(960)$")

    p3 = i0 + k0 / 3840.0
    lo3 = intrinsic(D240_HI, D960_LO) + (D240_HI - intrinsic(D240_HI, D960_LO)) / 16
    hi3 = intrinsic(D240_LO, D960_HI) + (D240_LO - intrinsic(D240_LO, D960_HI)) / 16
    ax.errorbar([1 / 3840], [p3], yerr=[[p3 - lo3], [hi3 - p3]], fmt="s",
                color="#27ae60", ms=9, capsize=5,
                label=fr"prediction $\Delta(3840) = {p3:.4f}$")

    ax.plot([0], [i0], "*", color="#8e44ad", ms=16,
            label=fr"intrinsic level $I = {i0:.4f}$")
    ax.axhline(D240, color="#c0392b", ls=":", lw=1.0, alpha=0.6)
    ax.annotate("resolution part of the coarse cell\n"
                fr"$\Delta(240) - I = {D240 - i0:.4f}$  ({(D240-i0)/D240:.0%})",
                xy=(1 / 240, (D240 + i0) / 2), xytext=(0.0012, 0.093), fontsize=9.5,
                arrowprops=dict(arrowstyle="->", color="#444444"))

    ax.set_xlabel(r"rank step $1/N$")
    ax.set_ylabel(r"measured gate drop $\Delta(N)$")
    ax.set_title("Richardson extrapolation to infinite resolution\n"
                 "grey lines sweep the reported confidence box", fontsize=11)
    ax.legend(fontsize=8.5, loc="lower right")
    ax.grid(alpha=0.25)
    ax.set_xlim(-0.00025, 0.0048)

    # --- right: the triage bar chart -------------------------------------------------
    ax = axes[1]
    slope_floor = 240 * D_LO
    structural = slope_floor / (4 * 960) / D240
    share_lo = intrinsic(D240_HI, D960_LO) / D240_HI
    share_hi = intrinsic(D240_LO, D960_HI) / D240_LO
    statistical = share_hi - share_lo

    bars = ax.bar(["structural\n(design blind spot)", "statistical\n(share interval width)"],
                  [structural, statistical],
                  color=["#8e44ad", "#e67e22"], width=0.55)
    for b, v in zip(bars, [structural, statistical]):
        ax.text(b.get_x() + b.get_width() / 2, v * 1.03, f"{v:.4f}\n({v:.2%})",
                ha="center", fontsize=10.5)
    ax.set_ylim(0, statistical * 1.35)
    ax.set_ylabel("width, as a fraction of $\\Delta(240)$")
    ax.set_title(f"What limits the answer?  statistical is "
                 f"{statistical/structural:.0f} times larger\n"
                 "→ MORE SEEDS, NOT FINER WINDOWS", fontsize=11)
    ax.grid(alpha=0.25, axis="y")
    ax.text(0.03, 0.78,
            fr"certified slope floor $L ≥ 240×{D_LO} = {slope_floor:.2f}$"
            "\n"
            fr"blind spot $= L/(4\cdot 960) = {slope_floor/3840:.5f}$"
            "\n"
            fr"intrinsic share $\in [{share_lo:.2f}, {share_hi:.2f}]$",
            transform=ax.transAxes, fontsize=9.5, va="top",
            bbox=dict(boxstyle="round", fc="#f4f6f7", ec="#aab7b8"))

    fig.tight_layout()
    fig.savefig("uharden_richardson.png", dpi=170)
    print("wrote uharden_richardson.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The staircase and the curve.

Draws the rank-grid rounding map gr_N(theta) = ceil(theta*N)/N as a staircase against
the identity, then shows how it turns a smooth response into a step function, and
finally plots the resolution residual r_N(theta) = S(theta) - S(gr_N(theta)) with its
envelope L/N and its offset-average L/(2N).

Output: uharden_staircase.png
"""

from __future__ import annotations

import math
from typing import Callable, List

import matplotlib.pyplot as plt
import numpy as np


def grid_up(n: int, theta: float) -> float:
    return math.ceil(theta * n) / n


def main() -> None:
    lip = 8.30
    response: Callable[[float], float] = lambda x: -(lip * x)

    theta = np.linspace(1e-9, 0.025, 8000)
    fig, axes = plt.subplots(3, 1, figsize=(9.5, 11), sharex=True)

    # --- panel 1: the rounding map -------------------------------------------------
    ax = axes[0]
    for n, colour, label in [(240, "#c0392b", "N = 240 (coarse)"),
                             (960, "#2980b9", "N = 960 (fine)")]:
        g: List[float] = [grid_up(n, t) for t in theta]
        ax.plot(theta, g, color=colour, lw=1.6, label=label)
    ax.plot(theta, theta, color="#7f8c8d", ls="--", lw=1.2, label=r"identity $\theta$")
    ax.set_ylabel(r"realised rate $\mathrm{gr}_N(\theta)$")
    ax.set_title("Rank-grid rounding: the ruler has ticks\n"
                 r"$\theta ≤ \mathrm{gr}_N(\theta) < \theta + 1/N$, and the fine "
                 r"staircase never rises above the coarse one",
                 fontsize=11)
    ax.legend(loc="upper left", fontsize=9)
    ax.grid(alpha=0.25)

    # --- panel 2: measured vs ideal response ---------------------------------------
    ax = axes[1]
    ax.plot(theta, [response(t) for t in theta], color="#2c3e50", lw=2.0,
            label=r"ideal response $S(\theta) = -L\theta$")
    for n, colour in [(240, "#c0392b"), (960, "#2980b9")]:
        ax.plot(theta, [response(grid_up(n, t)) for t in theta], color=colour, lw=1.4,
                label=fr"measured $S_{{{n}}}(\theta)$")
    ax.set_ylabel("response")
    ax.set_title("The measured response is a step function: it can only be evaluated "
                 "at rank rates", fontsize=11)
    ax.legend(loc="lower left", fontsize=9)
    ax.grid(alpha=0.25)

    # --- panel 3: the residual ------------------------------------------------------
    ax = axes[2]
    for n, colour in [(240, "#c0392b"), (960, "#2980b9")]:
        r = [response(t) - response(grid_up(n, t)) for t in theta]
        ax.plot(theta, r, color=colour, lw=1.4, label=fr"$r_{{{n}}}(\theta)$")
        ax.axhline(lip / n, color=colour, ls=":", lw=1.1,
                   label=fr"envelope $L/{n} = {lip/n:.4f}$")
        ax.axhline(lip / (2 * n), color=colour, ls="--", lw=1.0, alpha=0.7,
                   label=fr"offset average $L/(2\cdot{n}) = {lip/(2*n):.4f}$")
    ax.set_xlabel(r"nominal tail rate $\theta$")
    ax.set_ylabel(r"residual $r_N(\theta)$")
    ax.set_title("Resolution residual: nonnegative, bounded by $L/N$, and averaging to "
                 "exactly $L/(2N)$ over the gate offset", fontsize=11)
    ax.legend(loc="upper right", fontsize=8, ncol=2)
    ax.grid(alpha=0.25)

    fig.tight_layout()
    fig.savefig("uharden_staircase.png", dpi=170)
    print("wrote uharden_staircase.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Rank-Grid Resolution in Threshold Statistics — numerical demonstrations.

Self-contained (standard library only). Every function is inlined and type hinted.

The mathematics being demonstrated
----------------------------------
A response S(theta) is measured on a window of N items. Only the rank rates k/N are
realisable, so a nominal tail rate theta is realised at

    gr_N(theta) = ceil(theta * N) / N.

The measured response is S_N(theta) = S(gr_N(theta)), and the resolution residual is
r_N(theta) = S(theta) - S_N(theta).  A measured gate drop splits exactly:

    Delta(N) = Delta(inf) - r_N(theta1) + r_N(theta2).

The demos below verify, numerically:

  1. Grid geometry: 0 <= gr_N(theta) - theta < 1/N, monotonicity, and refinement
     gr_{Nc}(theta) <= gr_N(theta).
  2. The exact split identity (to machine precision) and the residual bound |r_N| <= L/N.
  3. Decoupled cross-window difference is pure resolution: the intrinsic drop cancels.
  4. The nested bound |D| <= L/N1 and the linear witness D = L/320 at (240, 960),
     for which the certificate 240*D recovers exactly (3/4) L.
  5. The 1/N law by offset averaging: mean residual = L/(2N) exactly for a locally
     linear response.
  6. Sign rigidity: D > 0 iff the response is steeper at the hard gate.
  7. The agreement probability: refinement 240 -> 960 moves the realised gate with
     probability exactly 3/4 for a uniformly placed gate.
  8. Richardson extrapolation of the reported four-cell design, the 4/3 factor between
     between-cell recovery and resolution share, the [0.36, 0.60] intrinsic-share
     interval, and the third-cell prediction [0.0459, 0.0607].
  9. The identifiability limit: two admissible responses measured identically by both
     cells whose intrinsic drops differ by L/3840.
 10. Structural-versus-statistical triage on the reported numbers.
"""

from __future__ import annotations

import math
import random
from fractions import Fraction
from typing import Callable, List, Tuple

# ----------------------------------------------------------------------------------
# Reported four-cell measurements (window {240, 960} x threshold {soft, hard})
# ----------------------------------------------------------------------------------

D240: float = 0.1073
D240_LO: float = 0.0973
D240_HI: float = 0.1148

D960: float = 0.0636
D960_LO: float = 0.0597
D960_HI: float = 0.0680

D_CROSS: float = 0.0437
D_CROSS_LO: float = 0.0346
D_CROSS_HI: float = 0.0533

N_COARSE: int = 240
N_FINE: int = 960


# ----------------------------------------------------------------------------------
# Core model
# ----------------------------------------------------------------------------------

def grid_up(n: int, theta: float) -> float:
    """Realised gate on a window of n items: round the nominal rate up to a rank rate."""
    return math.ceil(theta * n) / n


def grid_up_exact(n: int, theta: Fraction) -> Fraction:
    """Exact-rational version of grid_up, for identities that must hold on the nose."""
    return Fraction(math.ceil(theta * n), n)


def measured_response(s: Callable[[float], float], n: int, theta: float) -> float:
    """S_N(theta) = S(gr_N(theta))."""
    return s(grid_up(n, theta))


def residual(s: Callable[[float], float], n: int, theta: float) -> float:
    """r_N(theta) = S(theta) - S_N(theta)."""
    return s(theta) - measured_response(s, n, theta)


def gate_drop(s: Callable[[float], float], n: int, t1: float, t2: float) -> float:
    """Measured drop Delta(N) from soft gate t1 to hard gate t2."""
    return measured_response(s, n, t1) - measured_response(s, n, t2)


def gate_drop_inf(s: Callable[[float], float], t1: float, t2: float) -> float:
    """Intrinsic drop Delta(inf) = S(t1) - S(t2)."""
    return s(t1) - s(t2)


def cross_window(s: Callable[[float], float], n1: int, n2: int,
                 t1: float, t2: float) -> float:
    """D = Delta(N1) - Delta(N2), with the gates held fixed (decoupled design)."""
    return gate_drop(s, n1, t1, t2) - gate_drop(s, n2, t1, t2)


# ----------------------------------------------------------------------------------
# Reference responses
# ----------------------------------------------------------------------------------

def linear_response(lip: float) -> Callable[[float], float]:
    """S(x) = -L x: antitone, Lipschitz budget L, zero intrinsic window dependence."""
    return lambda x: -(lip * x)


def half_slope_response(lip: float) -> Callable[[float], float]:
    """The reference response ell(x) = -(L/2) x of the identifiability construction."""
    return lambda x: -(lip / 2.0) * x


def kink_response(lip: float) -> Callable[[float], float]:
    """
    The adversary kappa: slope -L on [0, 1/1920], flat on [1/1920, 1/960], then -L/2.
    Antitone and L-Lipschitz, and it agrees with ell at 0, 1/240 and 1/960.
    """
    def kappa(x: float) -> float:
        if x <= 1.0 / 1920.0:
            return -(lip * x)
        if x <= 1.0 / 960.0:
            return -(lip / 1920.0)
        return -(lip / 2.0) * x
    return kappa


def survival_response(alpha: float) -> Callable[[float], float]:
    """
    A decaying-tail response: S(x) = -x**alpha with alpha > 1 is antitone on [0,1]
    with slope magnitude alpha*x**(alpha-1) *increasing* in x, i.e. steeper deeper in.
    Taking alpha < 1 gives the flattening behaviour of a decaying tail density.
    """
    return lambda x: -(max(x, 0.0) ** alpha)


# ----------------------------------------------------------------------------------
# Analysis tools
# ----------------------------------------------------------------------------------

def nested_slope_floor(n_coarse: int, d_lower: float) -> float:
    """Certified Lipschitz floor L >= N1 * D for nested windows."""
    return n_coarse * d_lower


def richardson_intrinsic(d_coarse: float, d_fine: float, c: int) -> float:
    """Intrinsic level I from Delta(N) = I + c0/N on nested cells N and cN."""
    return (c * d_fine - d_coarse) / (c - 1)


def richardson_report(d_coarse: float, d_fine: float, c: int = 4) -> dict:
    """Full Richardson report: intrinsic level, resolution part, and both shares."""
    intrinsic = richardson_intrinsic(d_coarse, d_fine, c)
    resolution = d_coarse - intrinsic
    return {
        "intrinsic_level": intrinsic,
        "coarse_resolution_part": resolution,
        "intrinsic_share": intrinsic / d_coarse,
        "resolution_share": resolution / d_coarse,
        "between_cell_recovery": (d_coarse - d_fine) / d_coarse,
        "inflation_factor": c / (c - 1),
    }


def third_cell_prediction(d_coarse: float, d_fine: float) -> float:
    """Delta(3840) = (5 Delta(960) - Delta(240)) / 4 under the 1/N law."""
    return (5.0 * d_fine - d_coarse) / 4.0


def interval_intrinsic_share(lo1: float, hi1: float, lo2: float, hi2: float,
                             c: int = 4) -> Tuple[float, float]:
    """
    Propagate the two measurement intervals through the Richardson map.
    I = (c*d2 - d1)/(c-1) is increasing in d2 and decreasing in d1, and the share
    I/d1 is decreasing in d1, so the extremes sit at opposite corners.
    """
    share_lo = richardson_intrinsic(hi1, lo2, c) / hi1
    share_hi = richardson_intrinsic(lo1, hi2, c) / lo1
    return share_lo, share_hi


def interval_third_cell(lo1: float, hi1: float,
                        lo2: float, hi2: float) -> Tuple[float, float]:
    """Propagate the intervals through the (monotone affine) third-cell map."""
    return third_cell_prediction(hi1, lo2), third_cell_prediction(lo1, hi2)


def offset_average_residual(s: Callable[[float], float], n: int, k: int,
                            samples: int = 200_001) -> float:
    """
    Numerically average r_N(k/N + t) over t uniform in (0, 1/N] by the midpoint rule.
    Theory (locally linear S of slope -L across the cell) predicts exactly L/(2N).
    """
    total = 0.0
    step = (1.0 / n) / samples
    for j in range(samples):
        t = (j + 0.5) * step
        total += residual(s, n, k / n + t)
    return total / samples


def agreement_probability(m: int, c: int, trials: int = 200_000,
                          seed: int = 20260970) -> float:
    """Monte-Carlo probability that refinement m -> m*c MOVES the realised gate."""
    rng = random.Random(seed)
    moved = 0
    for _ in range(trials):
        theta = rng.uniform(1e-15, 1.0 / m)
        if grid_up(m * c, theta) != grid_up(m, theta):
            moved += 1
    return moved / trials


# ----------------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


def demo_1_grid_geometry() -> None:
    banner("1. Grid geometry: bracketing, monotonicity, refinement")
    n = 240
    print(f"  window N = {n}, rank step 1/N = {1/n:.6f}")
    for theta in [0.0, 1 / 1920, 1 / 960, 0.0037, 0.01, 0.5]:
        g = grid_up(n, theta)
        print(f"    theta = {theta:.8f} -> gr_N = {g:.8f}   "
              f"overshoot = {g - theta:.8f}  (< {1/n:.8f}: {g - theta < 1/n + 1e-15})")
    print("\n  refinement gr_960(theta) <= gr_240(theta):")
    ok = True
    for i in range(1, 2000):
        theta = i / 5000.0
        if grid_up(960, theta) > grid_up(240, theta) + 1e-15:
            ok = False
    print(f"    verified on 1999 sample rates: {ok}")
    print("  monotonicity of gr_240:")
    prev = -1.0
    mono = True
    for i in range(0, 2000):
        g = grid_up(240, i / 5000.0)
        if g < prev - 1e-15:
            mono = False
        prev = g
    print(f"    verified: {mono}")


def demo_2_exact_split() -> None:
    banner("2. The exact split  Delta(N) = Delta(inf) - r_N(t1) + r_N(t2)")
    lip = 8.30
    s = survival_response(0.7)
    t1, t2 = 0.004, 0.012
    for n in (240, 960, 3840):
        lhs = gate_drop(s, n, t1, t2)
        rhs = gate_drop_inf(s, t1, t2) - residual(s, n, t1) + residual(s, n, t2)
        print(f"    N = {n:5d}:  Delta(N) = {lhs: .10f}   split = {rhs: .10f}   "
              f"|diff| = {abs(lhs - rhs):.2e}")
    print("\n  residual magnitude bound |r_N| <= L/N for the linear response S(x) = -Lx:")
    lin = linear_response(lip)
    for n in (240, 960, 3840):
        worst = max(abs(residual(lin, n, i / 100000.0)) for i in range(1, 3000))
        print(f"    N = {n:5d}:  max |r_N| = {worst:.6f}   bound L/N = {lip/n:.6f}   "
              f"holds = {worst <= lip / n + 1e-12}")


def demo_3_pure_resolution() -> None:
    banner("3. Decoupled cross-window difference is PURE resolution")
    s = survival_response(0.7)
    t1, t2 = 0.004, 0.012
    n1, n2 = 240, 960
    direct = cross_window(s, n1, n2, t1, t2)
    via_resid = ((residual(s, n2, t1) - residual(s, n1, t1))
                 - (residual(s, n2, t2) - residual(s, n1, t2)))
    print(f"    D computed from the two drops      = {direct: .10f}")
    print(f"    D computed from residuals only     = {via_resid: .10f}")
    print(f"    |difference|                       = {abs(direct - via_resid):.2e}")
    print("    The intrinsic drop appears nowhere on the second line: it cancels.")
    shifted = lambda x: s(x) + 137.0          # noqa: E731  (a pure level shift)
    print(f"    D is unchanged by an additive level shift of S: "
          f"{cross_window(shifted, n1, n2, t1, t2): .10f}")


def demo_4_nested_bound_and_witness() -> None:
    banner("4. Nested bound |D| <= L/N1, the linear witness, and the 3/4 recovery")
    lip = 8.30
    lin = linear_response(lip)
    t1, t2 = 0.0, 1.0 / 960.0
    d = cross_window(lin, 240, 960, t1, t2)
    print(f"    linear witness S(x) = -{lip}x, gates (0, 1/960)")
    print(f"      Delta(240)   = {gate_drop(lin, 240, t1, t2):.8f}   (theory L/240 = "
          f"{lip/240:.8f})")
    print(f"      Delta(960)   = {gate_drop(lin, 960, t1, t2):.8f}   (theory L/960 = "
          f"{lip/960:.8f})")
    print(f"      D            = {d:.8f}   (theory L/320 = {lip/320:.8f})")
    print(f"      certificate 240*D = {240*d:.6f}   (theory (3/4)L = {0.75*lip:.6f})")
    print(f"      recovery fraction = {240*d/lip:.6f}  (exactly 3/4)")
    print("\n    D > 0 for a PERFECTLY LINEAR response with no window dependence:")
    print(f"      so D > 0 certifies nothing intrinsic on its own.  D = {d:.6f} > 0")

    print("\n    nested bound |D| <= L/N1 over random gate pairs (antitone, L-Lipschitz):")
    rng = random.Random(20260971)
    worst = 0.0
    for _ in range(20_000):
        a = rng.uniform(0.0, 0.05)
        b = a + rng.uniform(0.0, 0.05)
        worst = max(worst, abs(cross_window(lin, 240, 960, a, b)))
    print(f"      worst |D| observed = {worst:.8f}   bound L/240 = {lip/240:.8f}   "
          f"holds = {worst <= lip/240 + 1e-12}")


def demo_5_offset_average_law() -> None:
    banner("5. The 1/N law derived: offset-averaged residual = L/(2N)")
    lip = 8.30
    lin = linear_response(lip)
    for n in (240, 960, 3840):
        for k in (0, 3):
            got = offset_average_residual(lin, n, k, samples=40_001)
            print(f"    N = {n:5d}, cell k = {k}:  mean residual = {got:.8f}   "
                  f"theory L/(2N) = {lip/(2*n):.8f}   |diff| = {abs(got - lip/(2*n)):.2e}")
    print("\n    The constant in the c/N ansatz is c = L/2, half the LOCAL SLOPE — "
          "not fitted.")


def demo_6_sign_rigidity() -> None:
    banner("6. Sign rigidity:  D > 0  <=>  response steeper at the hard gate")
    n = 240

    def two_slope(l1: float, l2: float) -> Callable[[float], float]:
        """Slope -l1 across the soft cell (k=0), slope -l2 across the hard cell (k=3)."""
        def s(x: float) -> float:
            if x <= 1.0 / n:
                return -l1 * x
            base = -l1 / n
            if x <= 4.0 / n:
                return base - l2 * (x - 1.0 / n)
            return base - l2 * (3.0 / n)
        return s

    for (l1, l2) in [(4.0, 9.0), (9.0, 4.0), (6.0, 6.0)]:
        s = two_slope(l1, l2)
        bias_meas = (offset_average_residual(s, n, 3, samples=20_001)
                     - offset_average_residual(s, n, 0, samples=20_001))
        theory = (l2 - l1) / (2 * n)
        verdict = "D > 0" if theory > 1e-12 else ("D = 0" if abs(theory) <= 1e-12
                                                  else "D < 0")
        print(f"    L1 = {l1:4.1f}, L2 = {l2:4.1f}:  offset-averaged drop bias = "
              f"{bias_meas: .8f}   theory (L2-L1)/(2N) = {theory: .8f}   -> {verdict}")
    print("\n    A decaying tail density flattens outward (L2 < L1) and forces D < 0.")
    print(f"    The reported D = +{D_CROSS} has the OPPOSITE sign.")


def demo_7_agreement_probability() -> None:
    banner("7. How often refinement moves the realised gate")
    for c in (2, 4, 8):
        p = agreement_probability(240, c, trials=100_000)
        print(f"    240 -> {240*c:5d} (c = {c}):  P[gate moves] = {p:.5f}   "
              f"theory 1 - 1/c = {1 - 1/c:.5f}")
    print("\n    For the design's 240 -> 960 step the probability is exactly 3/4.")


def demo_8_four_cell_audit() -> None:
    banner("8. Auditing the reported four-cell design")
    print(f"    Delta(240) = {D240}  CI [{D240_LO}, {D240_HI}]")
    print(f"    Delta(960) = {D960}  CI [{D960_LO}, {D960_HI}]")
    print(f"    D          = {D_CROSS}  CI [{D_CROSS_LO}, {D_CROSS_HI}]")

    print("\n  (a) Certified Lipschitz floor (nested bound |D| <= L/240):")
    print(f"      L >= 240 * {D_CROSS_LO} = {nested_slope_floor(240, D_CROSS_LO):.4f}")
    print(f"      generic (non-nested) bound would give only "
          f"L >= 96 * {D_CROSS_LO} = {96*D_CROSS_LO:.4f}  (2.5x weaker)")

    print("\n  (b) Both pre-stated hypotheses fail, across the whole reported box:")
    print(f"      H2 'none':  D >= {D_CROSS_LO} > 0, so the coarse residual r1 > 0  -> FAIL")
    worst_ratio = 1.0 - D960_LO / D240_HI
    print(f"      H1 'most':  Delta(240) <= {D240_HI} < {2*D960_LO:.4f} = 2*Delta(960), "
          f"so D/Delta(240) < 1/2")
    print(f"                  worst-case recovery over the box = {worst_ratio:.4f} < 0.5 "
          f"(point estimate {D_CROSS/D240:.4f})  -> FAIL")
    print("      Verdict: NEITHER.  Robust, not a point-estimate artifact.")

    print("\n  (c) Richardson extrapolation (assuming Delta(N) = I + c0/N):")
    rep = richardson_report(D240, D960, c=4)
    print(f"      intrinsic level I         = {rep['intrinsic_level']:.6f}")
    print(f"      coarse resolution part    = {rep['coarse_resolution_part']:.6f}")
    print(f"      intrinsic share I/Delta   = {rep['intrinsic_share']:.4f}")
    print(f"      resolution share          = {rep['resolution_share']:.4f}  "
          f"(the reported 'minority' becomes a MAJORITY)")
    print(f"      between-cell recovery     = {rep['between_cell_recovery']:.4f}  "
          f"(the reported ~41%)")
    print(f"      inflation factor c/(c-1)  = {rep['inflation_factor']:.6f}  (exactly 4/3)")
    check = rep['between_cell_recovery'] * rep['inflation_factor']
    print(f"      4/3 * recovery            = {check:.6f}  vs resolution share "
          f"{rep['resolution_share']:.6f}   |diff| = {abs(check - rep['resolution_share']):.2e}")

    print("\n  (d) Intrinsic share over the reported confidence box:")
    lo, hi = interval_intrinsic_share(D240_LO, D240_HI, D960_LO, D960_HI, c=4)
    print(f"      I/Delta(240) in [{lo:.4f}, {hi:.4f}]   (theory [0.36, 0.60])")
    print(f"      straddles 1/2: 'mostly intrinsic' is CONSISTENT WITH but NOT CERTIFIED BY "
          f"the four cells")

    print("\n  (e) Falsifiable third-cell prediction at N = 3840:")
    pred = third_cell_prediction(D240, D960)
    plo, phi = interval_third_cell(D240_LO, D240_HI, D960_LO, D960_HI)
    print(f"      point prediction Delta(3840) = {pred:.6f}")
    print(f"      interval                     = [{plo:.4f}, {phi:.4f}]   "
          f"(theory [0.0459, 0.0607])")
    print("      A measurement outside this interval refutes the 1/N reading.")


def demo_9_identifiability() -> None:
    banner("9. The identifiability limit: two responses the design cannot separate")
    lip = 8.30
    ell = half_slope_response(lip)
    kappa = kink_response(lip)
    t1, t2 = 0.0, 1.0 / 1920.0

    print("    gates: soft = 0, hard = 1/1920 (INSIDE the first fine cell)")
    print(f"    realised rates:  gr_240(0) = {grid_up(240, t1)}, "
          f"gr_960(0) = {grid_up(960, t1)}")
    print(f"                     gr_240(1/1920) = {grid_up(240, t2):.8f} (= 1/240)")
    print(f"                     gr_960(1/1920) = {grid_up(960, t2):.8f} (= 1/960)")

    print("\n    the two responses at those three rates:")
    for x, label in [(0.0, "0"), (1/240, "1/240"), (1/960, "1/960")]:
        print(f"      x = {label:>8s}:  ell = {ell(x): .10f}   kappa = {kappa(x): .10f}   "
              f"agree = {abs(ell(x)-kappa(x)) < 1e-15}")

    print("\n    measurements:")
    for n in (240, 960):
        de, dk = gate_drop(ell, n, t1, t2), gate_drop(kappa, n, t1, t2)
        print(f"      Delta_ell({n:3d}) = {de: .10f}   Delta_kappa({n:3d}) = {dk: .10f}   "
              f"identical = {abs(de - dk) < 1e-15}")

    ie, ik = gate_drop_inf(ell, t1, t2), gate_drop_inf(kappa, t1, t2)
    print("\n    intrinsic drops:")
    print(f"      Delta_ell(inf)   = {ie:.10f}")
    print(f"      Delta_kappa(inf) = {ik:.10f}")
    print(f"      gap              = {ik - ie:.10f}   theory L/3840 = {lip/3840:.10f}")

    print("\n    Both are antitone and L-Lipschitz — checked numerically:")
    for name, f in [("ell", ell), ("kappa", kappa)]:
        anti, lipok = True, True
        xs = [i / 200000.0 for i in range(0, 800)]
        for a, b in zip(xs, xs[1:]):
            if f(b) > f(a) + 1e-15:
                anti = False
            if abs(f(a) - f(b)) > lip * abs(a - b) + 1e-12:
                lipok = False
        print(f"      {name:>5s}: antitone = {anti}, Lipschitz budget {lip} = {lipok}")


def demo_10_triage() -> None:
    banner("10. Structural vs statistical triage — what to do next")
    lip = nested_slope_floor(240, D_CROSS_LO)
    structural = lip / (4 * N_FINE)
    lo, hi = interval_intrinsic_share(D240_LO, D240_HI, D960_LO, D960_HI, c=4)
    statistical = hi - lo
    print(f"    certified slope floor            L >= {lip:.4f}")
    print(f"    structural ambiguity  L/(4*960)   = {structural:.6f}")
    print(f"      as a fraction of Delta(240)     = {structural/D240:.4%}")
    print(f"    statistical width of share interval = {statistical:.4f} "
          f"({statistical*100:.1f} percentage points)")
    ratio = statistical / (structural / D240)
    print(f"    ratio statistical : structural    = {ratio:.1f} : 1")
    print("\n    CONCLUSION: the [0.36, 0.60] spread is statistical width, not a "
          "resolution limit\n                of the design.  MORE SEEDS, NOT FINER WINDOWS.")


def main() -> None:
    print(__doc__)
    demos: List[Callable[[], None]] = [
        demo_1_grid_geometry,
        demo_2_exact_split,
        demo_3_pure_resolution,
        demo_4_nested_bound_and_witness,
        demo_5_offset_average_law,
        demo_6_sign_rigidity,
        demo_7_agreement_probability,
        demo_8_four_cell_audit,
        demo_9_identifiability,
        demo_10_triage,
    ]
    for d in demos:
        d()
    print("\n" + "=" * 78)
    print("All demonstrations complete.")
    print("=" * 78)


if __name__ == "__main__":
    main()
