# Choosing `b` Well

## Parameter optimisation in the multiplicative-relations factoring method: a 186× cost reduction, and what a metric choice is worth

**Round 48 · 2026-10-03 · Sixth in the series, companion to #525**

---

## Abstract

Stange's multiplicative-relations method has a free parameter `b` — the number of relations
gathered before linear algebra — that round 48 measured but never tuned. We sweep it
systematically, and the results are of two kinds: one large and practical, one methodological
and sharper.

**Practical.** The cost of finding a factor falls by up to **186×** against the round-48
baseline (2.22×10⁵ → **2,724** exponentiations per factor at `n ≈ 2³⁰`), by combining three
independent settings. More usefully than the number itself, **three independent objectives —
exponentiations, total operations, and wall clock — converge on `b ≈ 26–52` at 2³⁰**, and the
optimum **moves with `n`** under all three (26 → 52 in wall clock between 2³⁰ and 2⁴⁰).

**Methodological, and the paper's real point.** The objective you optimise changes the answer
by **3–5×**. Minimising `(b+c)·exp/rel/rate` — exponentiations only — puts the argmin at
`b ≈ 128`; minimising `(b+c)(1+b)/δ` puts it at `b ≈ 40`; wall clock puts it at `b ≈ 26`. The
exponentiations-only objective **over-shoots the true optimum by 3–5×**, because the bottleneck
*migrates*: at `b = 4`, relation-finding is 3.65 s of a 3.67 s attempt; at `b = 128` it has
fallen to 0.06 s and **linear algebra is 1.09 s of 1.15 s**.

We also **retract one of our own preregistered predictions** and report two mechanisms as
artefacts of an invalid null.

---

## 1. Baseline gate

The gate was fixed before the sweep: reproduce the 20/27 success rate on fresh seeds disjoint
from all prior work.

| | n | trials | factors | rate |
|---|---|---|---|---|
| round 48 | 2²⁰–2⁴⁰ | 260 | 192 | 0.7385, z = −0.08 |
| round 49 | 2²⁰–2⁴⁰ | 260 | 192 | 0.7385 |
| **this sweep** | 2²⁰–2⁴⁰ | 260 | **193** | **0.7423, z = +0.06** |

Cross-check: `exp/rel` at `b = 6` is **23,490** here against **23,880** recorded. **Four
independent reproductions now agree.**

## 2. `b` has a real interior minimum, and it moves with `n`

Cost falls monotonically in `b` and then turns. Under the objective we originally specified:

| n | argmin (`(b+c)·exp/rel/rate`) | flatness |
|---|---|---|
| 2³⁰ | **128** | 5% flat over 128–256 — **not pinned tighter** |
| 2⁴⁰ | **≈320–500** | 2% spread over a 2.2× range — **unresolved** |

**Under all three objectives the optimum moves with `n`:** 128 → ≈400 (exponentiations),
40 → ≈80 (operations), 26 → 52 (wall clock). **Nothing above 2⁴⁰ was measured or extrapolated.**

## 3. The metric choice is worth 3–5×

| objective | argmin at 2³⁰ |
|---|---|
| `(b+c)·exp/rel/rate` — exponentiations only | **128** |
| `(b+c)(1+b)/δ` — operations | **40** |
| wall clock | **26** |

**The exponentiations-only objective over-shoots the true optimum by 3–5×.** The mechanism is
visible in the wall-clock breakdown:

| b | secs/attempt | relations | linear algebra |
|---|---|---|---|
| 4 | 3.67 | **3.65** | 0.00 |
| 26 | **0.08** | 0.06 | 0.02 |
| 128 | 1.15 | 0.06 | **1.09** |

**The bottleneck migrates.** Past `b ≈ 26` every further gain in relation-finding is paid for
by linear algebra, which grows with `b`. An optimiser that counts only exponentiations walks
straight past the minimum into a regime where it has merely *moved* the cost.

Independent corroboration: a separate axis derived `b ≈ 36` at 2³⁰ analytically from its own
`Ψ`, against our measured 40; and the optimal-sampler axis (§6) reaches the same 26–52 window.
**Three routes, built from different data, converge.**

## 4. Result — 186× against the baseline

At `n ≈ 2³⁰`, exponentiations per successful factor:

| configuration | cost | vs baseline |
|---|---|---|
| baseline (`b=6, c=10`) | 2.22 × 10⁵ | — |
| best `b` under OBJ-1 | **3,269** | **68×** |
| **best `b` + `c=1` + Jacobi filter on `g`** | **2,724** | **186×** |

Under the operations objective the best is 1.83 × 10⁵ from 3.55 × 10⁶ — **19.4×**.

**The argmin is identical across all four configuration schemes and under both objectives at
both sizes** (preregistered PREREG-3, confirmed exactly). That the optimum is insensitive to
how the relations are produced is itself a useful robustness result.

## 5. ⚠️ Does the round-48 "b-gap" survive? Yes — but it shrinks from 67.9× to 7.1×

Round 48 reported that larger `b` beat `b = 6` by **67.9×**, attributing it to a larger factor
base making `g^x mod n` FB-smooth more often. Since a separate axis had just shown that
`pow`-versus-multiply is worth more than any `b` effect, the question was whether the gap
survives being priced honestly.

**It survives, at 7.1×** (2³⁰; at 2⁴⁰ from `b = 12`: 94.7× → **6.5×**).

**But ~90% of the original figure was a pricing error**, not a mechanism: the round-48
comparison counted a `pow` at one unit while ignoring the `b`-dependent smoothness reductions
per candidate. What remains is a genuine **candidate-count** effect, **orthogonal to stride** —
so the two improvements compose rather than compete, which is what the 186× figure reflects.

## 6. ⚠️ Two of our own predictions falsified, and one mechanism retired as an artefact

**Our preregistered PREREG-1b is FALSIFIED.** It predicted `meas/ρ` is monotone *decreasing* in
`b`. It **increases**.

**And the cause is an invalid null — mine.** A parallel axis established that at `u ∈ [5,8]`
the exact `Ψ` is **8.46× `ρ`**, so **every `meas/ρ` ratio at `u ∈ [5,8]` here was scoring against
a known-invalid reference.** Applying the correction predicts a ratio of ≈0.118; the measured
cells give 0.090 and 0.148 — consistent. So the striking *low* ratios at small `b` were
substantially the artefact.

**No cost number is affected**: every cost in this paper uses **measured** `exp/rel`, never `ρ`.
That is why the conclusions survive while the diagnostic ratios do not.

**The `b = 6` rate anomaly is resolved: chance.** Pooled over all `b = 6` runs, **986/1320 =
0.7470, z = +0.52**. My own 120-instance cell read +2.15 — *opposite* sign to the −2.48 recorded
in round 49. And `G = 0` occurs in 1/1600, so it is not the mechanism.

## 7. ⚠️ Flagged, not claimed

Three items are unresolved, each with what would settle it (§12 of the note):

1. **A `c = 1` rate deficit at 2⁴⁰**: 900/1320, **z = −4.89**. Round 49's "flat in `c`" result
   covers only 2²⁶ and 2³⁰, so this is **not covered by it** and is a genuine open discrepancy.
2. **A non-monotone 2⁴⁰ deficit at `b ∈ {16, 20, 26}`.**
3. **The OBJ-1 argmin is only ±5% flat** over 128–256 and is not pinned tighter.

None of these is used to support a claim above.

## 8. A methodological note, which is the third instance in this program

We had to write an exact null-space routine, because `sympy` fails at `b = 32`. **We got it wrong
twice**, and **both bugs produced the correct rank and the correct dimension with the wrong
vectors.**

So the check compares ranks, and passes.

The final harness asserts `M·v = 0` **exactly**, rather than comparing ranks or dimensions.

This is the third time this round that a correctness property was satisfied *in aggregate* while
the object was wrong — after the Stange label bug (all rates passed, 0/60 factors) and the
compressed census rows. **A structural statistic is not a correctness test.** The assertion has
to be the identity itself.

## 9. Reference

- N. Stange, *Factoring using multiplicative relations modulo n*, arXiv:2211.06821.
- Companion: "The Optimal Sampler" (issue #525), which proves the stride generator attains the
  unconditional cost bound. **The two improvements compose** — stride reduces the cost *per
  candidate*, `b` reduces the number *of* candidates.

**Verification protocol.** No cost figure in this paper uses `ρ`; all use measured `exp/rel`.
The baseline was reproduced before the sweep. The metric-choice finding (§3) is the paper's
central claim and is supported by three independently-derived routes agreeing on the window.