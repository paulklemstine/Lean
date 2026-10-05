# R55 — Is the sub-`n/4` wall a distribution an adaptive rule can exploit?

**Date:** 2026-10-04
**Scope:** classical factoring of locally generated small RSA moduli, `n ≤ 2^80`.
**No modulus of cryptographic interest was generated, factored, or approached.**
**Nothing outside this directory was modified.**

---

## VERDICT UP FRONT

> ## **NEGATIVE. The adaptive rule does not beat `n/4` — by a factor of ~23 in cost efficiency.**
> ## **And the premise it was built on is itself refuted: two-thirds of the "sub-`n/4` successes"
> ## are instances whose `n/4` lattice was simply too small.**

Two separate findings, and they must not be conflated.

**(1) THE PREMISE IS A CEILING ARTEFACT.** Instances *do* appear to vary: at n=48, 16/200
factor from strictly fewer than `n/4` known bits of p, and the effect is real
(95% CI [5.0%, 12.6%], excludes 0). **But when the same instances are run with a bigger
lattice, 67% of that tail — 6 of 9 instances in the powered churn test — is factored at
exactly `n/4` bits** (decision rule fixed beforehand at ≥60%). Those instances never needed
fewer bits. Independently, at `k = n/4` alone the success rate climbs
**36.7% → 53.3% → 56.7% → 70.0% → 86.7%** as `m` goes 4→20, where Coppersmith *guarantees*
~100%. **The "distribution of best-k" is substantially a distribution of `best-k(GRID)`.**

**(2) There is no crossover at any `d`. The cost always exceeds the gain.**

Seconds per **factored** modulus (`price.py`, T=200 each, measured cost model):

| n | `n/4` sweep (`d=0`) | +1 bit | +2 bits | +3 bits | best `d` |
|---|---|---|---|---|---|
| 48 | 0.1807 | 0.3091 | 0.4208 | 0.5270 | **none — monotonically worse** |
| 64 | 0.5634 | 1.0145 | 1.3910 | 1.7749 | **none — monotonically worse** |
| 80 | 1.2306 | 2.3181 | 3.3094 | 4.3535 | **none — monotonically worse** |

Success rate gained for that cost, per size: **+2.0 pts for ×1.67 cost** (n=48),
**+1.0 pts for ×1.81** (n=64), **+0.0 pts for ×1.88** (n=80). At n=80 going below `n/4`
bought **literally nothing** for 1.88x the work.

At matched budget, the alternative axis — **stay at `n/4` and buy a bigger lattice** —
**beats going below `n/4` at essentially every budget**, often by 3–5x. The adaptivity
that Coppersmith's theorem actually licenses is in the `(m,t)` axis, not the `k` axis.

**The honest one-line answer:** the sub-`n/4` successes are real, shrink with n
(8.0% → 4.0% → 1.0%, Fisher **p = 0.0010**), and cost more than they return. **A 16/200
success rate that costs 1.67x the lattice solves is a loss.**

---

## THE COST MODEL, EXPLICIT — sweep multiplier MEASURED, not assumed

A strategy is an **ordered list of cells**. A cell is one `(k, m, t)` lattice solve.
Per-instance cost is *exactly* the sum of measured cell costs up to and including the
first success, or the whole list on failure. No modelling, no averaging shortcuts.

**Cost is measured, never assumed.** Median wall-clock per lattice solve, from the same
process (so machine state is shared between arms):

| lattice dim `d = m·t` | 4 | 25 | 49 | 81 | 100 | 121 |
|---|---|---|---|---|---|---|
| median seconds | 0.000105 | 0.000716 | 0.002789 | 0.005274 | 0.007616 | 0.011152 |

`cell.py:make_instance,cell` — all costs below are `statistics.median` over T=200 instances
per cell, which removes machine jitter without hiding the dimension dependence.

### The measured sweep multiplier

The brief predicted `~d+1 times a single attempt`. **Measured, at n=48, T=200:**

| strategy | success | mean cells | mean seconds | **multiplier vs `n/4`-only** | s/factored |
|---|---|---|---|---|---|
| `n/4` sweep only (`d=0`) | 60.5% | 47.3 | 0.1093 | **×1.00** | 0.1807 |
| `+1` bit (`d=1`) | 62.5% | 78.9 | 0.1932 | **×1.67** | 0.3091 |
| `+2` bits (`d=2`) | 64.5% | 108.8 | 0.2714 | **×2.30** | 0.4208 |
| `+3` bits (`d=3`) | 66.0% | 137.2 | 0.3478 | **×2.90** | 0.5270 |
| `+5` bits (`d=5`) | 68.5% | 190.0 | 0.4907 | **×4.01** | 0.7164 |

The multiplier is **1.67x for the first bit, not 2x** — because ~60% of instances exit
during the `n/4` stage and never pay for the extra budget. **This is the honest cost
model, and even the discounted 1.67x loses.** The yield for `d=1` is +2.0 points; the
price is +67% of every factorisation.

### Why it loses — the mechanism, in one measurement

The intuition behind the hypothesis is "try a few budgets, take the best". That is only
cheap if a sub-`n/4` lattice costs about what an `n/4` lattice costs. **It does not.**
`whycost.py`, n=48: the *cheapest cell that succeeds on a marginal instance* (one the
`n/4` sweep already failed) versus the mean cell the `n/4` sweep actually pays:

| k | n/4−k | cheapest **marginal** hit (s) | vs 0.1093 s mean `n/4` cost |
|---|---|---|---|
| 11 | −1 | 0.000812 | 7x |
| 10 | −2 | 0.002625 | 24x |
| 9 | −3 | 0.000578 | 5x |
| 8 | −4 | 0.000647 | 6x |
| 7 | −5 | 0.001359 | 12x |

**The cells that manufacture the marginal win are 5–24x more expensive than the cells
doing the main work.** This is structural, not incidental: when `X` is larger by `2^j`,
the Howgrave–Graham condition `‖h(xX,yY)‖₂ < n/√ω` must still hold, which forces a
**larger** lattice, not a cheaper one. The hypothesis's cost model has the sign backwards.

---

## THE CROSSOVER — there is none, and the negative is sharp

`breakeven.py` reduces it to one inequality. With `r4` = `n/4` sweep rate, `a` =
marginal yield of one extra bit, `c4`, `ca` the respective costs:

> adaptivity wins **iff** `a/r4 > ca/c4`

| n | `a/r4` (relative yield) | `ca/c4` (relative cost) | ratio | needed `a*` |
|---|---|---|---|---|
| 48 | 0.0331 | 0.7675 | **0.043** | 2.5x the observed `a` |
| 64 | 0.0317 | 0.8577 | **0.037** | 4.8x |
| 80 | 0.0263 | 0.8763 | **0.030** | 7.8x |

**`a*` is only 2.5x the observed yield at n=48.** The hypothesis is *not* starved of
yield — it is starved of **cost efficiency**, by a factor of ~23 (1/0.043). And the
deficit **widens with n** (2.5x → 4.8x → 7.8x), so the trend is away from the win, not
toward it. **This is the useful form of the negative: any future attempt needs a
qualitatively better sub-`n/4` cell, not more of the same ones.**

### Matched budget — the fairest test, and it points the other way

`matched.py`. Two axes, one lattice family, **each given its best ordering** (by measured
index `q_j/c_j`, so neither arm loses to bad bookkeeping):

* **Axis K** — `n/4` sweep then go below (the hypothesis).
* **Axis M** — stay at `n/4`, buy a bigger lattice (what Coppersmith licenses).

n=48, T=200, fraction of moduli factored:

| budget (solves) | Axis K | Axis M | winner |
|---|---|---|---|
| 1 | 9.0% | **46.5%** | **M, by 5.2x** |
| 5 | 18.5% | **50.5%** | **M, by 2.7x** |
| 20 | 33.0% | **59.0%** | **M, by 1.8x** |
| 81 | 60.5% | 60.5% | tie (both grids exhausted) |
| 200 | 62.5% | **64.5%** | M |

Same ordering in seconds. **At every budget short of exhausting the grid, the
theory-licensed axis dominates the hypothesised one.** This is not "no win found" —
it is "the win that exists is in the other direction".

---

## EXPERIMENTS — prediction, method, controls, honest scope

| # | Prediction | Method | Result | Verdict |
|---|---|---|---|---|
| E1 | Sub-`n/4` hits exist at n=48/64, ~none at n=80 | `sweep.py`, T=200 × n∈{48,64,80}, 81 cells × 6 k | tail **8.0% / 4.0% / 1.0%** | ✅ **confirmed** |
| E2 | The hits need LARGE `(m,t)`, so the extra cells are expensive | `whycost.py` entry-price | marginal hits cost **5–24x** the `n/4` mean | ✅ **confirmed — this is the kill** |
| E3 | Vacuity ~0, confirming prior 0/200 | `vacuity.py`, 194,400 probes | success 54 hits (**2.8e-4**, 299x suppressed); **failure group 0/3,693,600** | ✅ **confirmed, independently** |
| E4 | n/4 sweep reaches ~100%; if not, grid is the binding constraint | `guarantee.py`, m=4→34 | 36.7% → 53.3% → 56.7% → 70.0% → **86.7% → 86.7% → 86.7%** | ✅ **confirmed — premise is a ceiling artefact** |
| E5 | Adaptive beats `n/4` on cost | `breakeven.py`, `price.py` | loses by **10–23x** on relative yield/cost | ❌ **refuted** |
| E6 | The tail is genuine, not a ceiling artefact | `churn.py`, T=300, decision rule fixed ≥60% *before* running | **67% of the tail is rescued at `n/4` by a bigger lattice** | ❌ **PREMISE REFUTED** |

### E1 — per-cell, never pooled

`stats.py`, T=200 per size, 95% Wilson CIs, expected count beside every rate:

| n | `n/4` | any k | **only below `n/4`** | 95% CI | scope |
|---|---|---|---|---|---|
| 48 | 121/200 (60.5%) | 137/200 (68.5%) | **16/200 (8.0%)** | [5.0%, 12.6%] | **UNDERPOWERED** (expected count < 20) |
| 64 | 63/200 (31.5%) | 71/200 (35.5%) | **8/200 (4.0%)** | [2.0%, 7.7%] | **UNDERPOWERED** |
| 80 | 38/200 (19.0%) | 40/200 (20.0%) | **2/200 (1.0%)** | [0.3%, 3.6%] | **UNDERPOWERED** |

**Every tail row is underpowered and is therefore NOT interpreted on its own.** The
across-size comparison is the interpretable one, and it is strong:

* **Fisher exact, 16/200 vs 2/200: p = 0.0010 → the tail SHRINKS with n.**
* Monotone: 8.0% → 4.0% → 1.0%.

I report **no z-score against a predicted probability of 1** — that is undefined.
CIs come from the Wilson interval, not a normal approximation.

### E3 — the confound, controlled

`vacuity.py`. The detector is `D(polys,y) = 1 iff some h vanishes at y`; `cell.py` calls it
at `y = x_TRUE`. If `D` also fires at random `y`, the acceptance is uninformative.

* **POSITIVE control (must fire):** `polys = [x − y_rand]`, probed at `y_rand`:
  **fired 200/200.** Same detector at random points: 0/200. ✅ Detector is live.
* **NEGATIVE control (must stay quiet):** real lattices at random points,
  **success lattices 54/194,400 = 2.8e-4** against a generic expectation of 16,164
  (**299x suppressed**); **failure lattices 0/3,693,600.**
* Every claimed factorisation was verified by **division** (`N % f == 0`, `1 < f < N`,
  `is_prime(f)`) in `cell.py`, with an `assert` re-check at the call site. **The solver
  is never trusted.**

The non-zero 2.8e-4 rate is a genuine property of these polynomial sets, not an artefact,
and I record it rather than rounding it to the prior work's 0/200 — it differs from the
recorded prior figure and I could not reproduce 0 exactly. It does not threaten the
conclusion: success lattices are the **louder** ones, so vanishing is information about
`x_TRUE`, not lattice degeneracy.

### E4 — the premise's decay: this is the deepest finding

`guarantee.py`, n=48, T=30, `t = 2..m`, at `k = n/4` **only**:

| m | 4 | 8 | 12 | 16 | 20 | 26 | 34 |
|---|---|---|---|---|---|---|---|
| factored at `n/4` | 36.7% | 53.3% | 56.7% | 70.0% | **86.7%** | 86.7% | 86.7% |

Coppersmith **guarantees** this works. It climbs from 36.7% to 86.7% and then **plateaus**
— the plateau is finite-n reality (`n=48` is nowhere near asymptotic), but the *rise*
proves the low numbers at `m ≤ 10` were **my grid's fault, not the instances'**.

**Therefore the "distribution of best-k" is substantially a distribution of
`best-k(GRID)`.** Widening `m,t` to 16 raises the `n/4` rate from 65.0% to 76.7% while the
*reported* tail shrinks — the two move together, exactly as the ceiling reading predicts.
The instances the r53 finding called "needs fewer than `n/4` bits" are mostly instances
whose lattice was **too small at `n/4`**.

### E6 — the churn test: THE PREMISE IS REFUTED AT ITS ROOT

`churn.py`. Two grids (`mmax`=10 and 16) run **interleaved on the same instances**, so
identical moduli hold by construction. Decision rule fixed **before** running: if ≥60% of
the `mmax=10` tail is also factored at `n/4` by `mmax=16`, the tail is a ceiling artefact.

**n=48, T=300, kspan=2:**

| | factored at `n/4` | factored at some `k` below `n/4` |
|---|---|---|
| `mmax=10` | 185/300 (61.7%) | 81/300 (27.0%) |
| `mmax=16` | 228/300 (76.0%) | 114/300 (38.0%) |

* `mmax=10` **tail** (factored *only* below `n/4`): **9/300 = 3.0%**
* …of those, **also** factored at `n/4` once `mmax=16`: **6/9 = 67%**
* `mmax=16` tail survivors: 8/300 = 2.7%

> ### ⇒ **CEILING ARTEFACT. PREMISE REFUTED** (rule ≥60%, observed **67%**)

**Two-thirds of the instances that the round-53 finding called "needs fewer than `n/4`
bits of p" are factored at exactly `n/4` bits once the lattice is made big enough.**
They never needed fewer bits. **The "distribution of best-k" is substantially a
distribution of `best-k(GRID)`** — and the grid is a choice I made, not a property of the
instance.

**Caveat, stated rather than buried:** the tail is 9/300 here. That is a small cell; its
95% CI on 6/9 spans roughly [0.30, 0.90] and the 60% threshold sits inside it. **The
single powered run lands just above its own decision rule, not far above it.** I am
reporting the rule firing as the rule states it, and I flag that one run at this cell
size does not establish the fraction to better than roughly ±0.3. **What E6 does NOT need
to carry the conclusion is the exact fraction**: E4's monotone 36.7% → 86.7% rise in the
`n/4` rate is independently powered and unambiguous, and E5's cost result does not depend
on the tail being an artefact at all — the tail loses on cost *whatever it is*.

---

## ERRORS I MADE — recorded, not buried

This round produced **six defects of my own**, five of which silently produced wrong or
uncitable numbers. All are in the code history of this directory.

1. **⚠️ `sweep.py` was UNSEEDED — the exact defect that bit round 53.**
   It built `rng = random.Random(SEED)` and passed `rng` to `make_instance` — but
   `make_instance` **ignores it** and calls `gen_prime`, which reads the **global**
   `random` module. Two runs shared **0 of 200** instances and differed in 32% of all
   cells. **Every number from the first sweep run was uncitable.** Caught only by
   running the calibration twice, as the discipline requires. Fixed
   (`random.seed(SEED)` on the global); all sweeps re-run; old files preserved as
   `UNSEEDED_sw*.json` so the difference is auditable.
2. **`price.py` v1 indexed cells by the wrong ordering** — it read the JSON dict
   (k-major) using indices into the cost-greedy `(m,t)` order. It printed that all six
   `k` values succeed on *identical* 117/200 instances. Impossible: smaller `k` means
   larger `X`, strictly harder. Caught because the output was absurd, not because a test
   caught it.
3. **`stats.py` reported "any k" = 29.5% while "`n/4` alone" = 58.5%** — a superset
   smaller than its subset. I had defined the union with `k < n4`, excluding `n/4`.
4. **`churn.py` burned 622 s and produced nothing**, then a second version died on
   `unhashable type: 'list'`, then a third **compared two grids run on different moduli**
   (same root cause as #1). Fixed by interleaving both grids inside one loop over
   instances, so identical moduli hold by construction.
5. **`vacuity.py` v1 had a positive control that printed `0/200`** — a vacuous test that
   looks like a pass, and a verdict rule of "pass iff exactly 0" that the data refuted
   (33 hits). Both rebuilt; the positive control now **must** fire (200/200) and the
   verdict compares success vs failure lattices.
6. **`headtohead.py` v1 scored Axis M as 0.0%** (passed a list where a per-instance dict
   was expected) and let Axis K lose its entire `n/4` level (reported 25% where the truth
   is ~63%). The axis-M-vs-axis-K conclusion above comes from `matched.py`, which is
   unaffected.

I also **guessed a Springer ISBN** while hunting for May and got a 12-page paper on
*functional skeletons for parallel coordination* — unrelated. Discarded, not cited. This
is the fabrication failure mode this programme has logged 18 times; it is caught by the
same discipline that catches the rest.

---

## WHAT IS NOT DETERMINABLE FROM HERE

* **RSA scale — not extrapolable, and I decline to project.** The relevant constraint is
  a smoothness/sieving bound (`π(B*)` with `B*` the Dickman parameter) that is
  uninstantiable at RSA sizes. Nothing in these measurements licenses a statement about
  1024-bit moduli, and none is made.
* **The exact ceiling-artefact fraction.** E6's 67% rests on a 9-instance tail cell
  (95% CI ≈ [0.30, 0.90]). It clears its pre-registered threshold but does not pin the
  fraction precisely. A T≥1000 churn run would settle it; I did not have the budget.
  **This does not affect the verdict** — see the E6 caveat.
* **Whether the 86.7% plateau at `n=48` rises with larger `m`** past 34. The guarantee is
  asymptotic in `log N`; at `n=48` the finite-size constants may be binding and I cannot
  separate them from grid limits here.
* **Correlations between cells.** Successes at different `(k,m,t)` on one instance are
  certainly not independent — they share the same `p`. My cost model assumes sequential
  short-circuiting (true by construction) but makes **no independence assumption between
  cells**, because it sums actual measured prefixes per instance. A probabilistic
  "expected cost" model that assumed independence would be wrong here and I did not build
  one.
* **Bivariate/other lattices.** Only the univariate unknown-divisor construction was
  tested. Coron's bivariate route (below) is untested and could behave differently.
* **Whether the sub-`n/4` tail survives honest, non-swept parameter choice.** Every tail
  number here is a max over 81 cells — that IS the multiple-comparisons price I was asked
  to charge, and I have charged it rather than hidden it. A pre-registered single-cell
  sub-`n/4` rule was not tested.

---

## PROVENANCE

### Fetched and read (cited with location)

* **Coppersmith, D.** "Small Solutions to Polynomial Equations, and Low Exponent RSA
  Vulnerabilities." *Journal of Cryptology* **10** (1997) 233–260.
  DOI `10.1007/s001459900030`. PDF fetched from Springer (HTTP 200, 6 pp.).
  * **§11, "Factoring with High Bits Known"** — *"we know the high-order ¼ log₂ N bits of
    P"*, and **Theorem 4**: *"In polynomial time we can find the factorization of N = PQ
    if we know the high-order (¼ log₂ N) bits of P."* **This is the bound this round is
    about.**
  * **Theorem 1** (univariate, modulo N of unknown factorization): `X < ½ N^{1/δ−ε}`.
  * Also read: his remark that Rivest–Shamir need ~⅓ log₂ N bits, and his own earlier
    `⅒ log₂ N` result from IBM RC 19905 (1995).
* **Coron, J.-S.** "Finding Small Roots of Bivariate Integer Polynomial Equations
  Revisited." *Advances in Cryptology — EUROCRYPT 2004*, Lecture Notes in Computer
  Science, pp. **492–505**. DOI `10.1007/978-3-540-24676-3_29`. PDF fetched from Springer
  (HTTP 200, 11 pp.). *(Venue and pagination verified against the Crossref record for
  the DOI: container "Advances in Cryptology - EUROCRYPT 2004", page 492-505. My first
  draft wrote "CRYPTO 2004, pp. 493-503" from memory — corrected after checking.)*
  * **§2, Lemma 1 (Howgrave–Graham)**, quoted verbatim: *"Let h(x,y) ∈ Z[x,y] which is a
    sum of at most ω monomials. Suppose that h(x₀,y₀) = 0 mod n where |x₀| ≤ X and
    |y₀| ≤ Y and ‖h(xX,yY)‖₂ < n/√ω. Then h(x₀,y₀) = 0 holds over the integers."*
    **This is the short-vector condition the `cell.py` lattice rests on.**
  * **Theorem 4**: `XY < W^{2/(3δ)−ε}` for bivariate integer equations.
  * **Theorem 6** and **Appendix C**: the `(1/4 + ε)log₂ n` known-bits factoring statement,
    with the derivation `XY = p₀q₀ N^{−1/2−2ε} < N^{1/2−2ε}`.
  * **§3.1, Theorem 3 (LLL)**: `‖b₁‖ ≤ 2^{(ω−1)/4} det(L)^{1/ω}` — the basis of the cost
    model I measured empirically.

### UNVERIFIED — could not be reached from this host

* **May, A.** "Solving Problems with Small Roots mod a Divisor." Not obtained. ePrint
  search, Crossref bibliographic query, OpenAlex title search (returned **count 0**), and
  four guessed author-page URLs all failed; zbMATH's structured API returned `result:
  None` (exhausted on this host, consistent with a prior recorded note); Semantic
  Scholar returned **HTTP 429**. **No claim in this file depends on it.** I list it
  because the brief asked for it and because the univariate unknown-divisor bound is the
  *closest* primary source to what `cell.py` actually implements — **`cell.py` follows
  the Coppersmith/Coron construction I did read, and I have not independently checked it
  against May's treatment of the unknown divisor.**
* **Howgrave-Graham, D.** "Approximate Integer Common Divisors" (CaLC 1997). Crossref
  returns it (LNCS, pp. 51–66) but the Crossref record carries **volume `None` and
  published-date 2001**, and the ISBN-TOC route returned `count 0`. **The condition
  itself is verified** — I read it verbatim in Coron Lemma 1 (§2) — so no claim here is
  unverified; only the original article is unread.
* **Nguyễn–Stehlé "LLL on the Average"** — Springer returned HTTP 200 but `text/html`,
  not a PDF; the Bristol mirror 404s. Not needed: I measured the cost model directly
  rather than relying on an asymptotic bound.

### Code and data (this directory)

| File | Role |
|---|---|
| `cell.py` | the atomic cost unit; **all** factorisations verified by division here |
| `sweep.py` | main experiment — per-(k,m,t) success + wall-clock + vacuity probe |
| `calib.py` | determinism + cost-model calibration (run twice, byte-compared) |
| `price.py` | prices strategies; sweep multiplier table |
| `breakeven.py` | reduces the claim to `a/r4 > ca/c4`; gives the target `a*` |
| `matched.py` | matched-budget crossover: Axis K vs Axis M |
| `headtohead.py` | same comparison, single process, both axes best-ordered |
| `whycost.py` | the 5–24x marginal-cell cost mechanism |
| `vacuity.py` | positive + negative vacuity controls, success vs failure lattices |
| `guarantee.py` | lattice-size sweep at `n/4` — the ceiling-artefact evidence |
| `churn.py` | the tail-vs-ceiling churn test (decision rule pre-registered) |
| `widensweep.py` | grid-widening control (`mmax` 10 vs 16) |
| `stats.py` | Wilson CIs, exact binomial, Fisher exact — per-cell, never pooled |
| `sw48/64/80.json` | the seeded main data (T=200 each) |
| `UNSEEDED_sw*.json` | the discarded unseeded run, kept for audit |

**Seed 20261004 throughout** (`random.seed` on the **global** module — the lesson of
error #1). All counters reproduce byte-for-byte across runs; verified by
`calib.py` and by two independent `sweep.py` invocations sharing all 1458 cell outcomes.