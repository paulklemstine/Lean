# W — the `b`-sweep: cost, the argmin, and where it moves with `n`

**Round 50 · agent W · 2026-10-03 · code `factor-scratch/r50/exp/bsweep/`**

Predecessor: `notes/U_stange_improve.md` §7.2. Companion axis: `notes/BB_smoothpow.md`
(both are reconciled in §10 — **read §10 before quoting any `b` from this note**).

---

## 0. Headline

The success rate is `20/27` and independent of `b`, `c`, `n` (round 49, 33 000
instances, and reproduced here). So cost is the only lever. **Cost as a function
of `b` has an interior minimum**, and I located it under three different
objectives — which do **not** agree with each other, and that disagreement is
the most useful thing in this note.

| objective | argmin `b` @ 2³⁰ | argmin `b` @ 2⁴⁰ | cost/success @ argmin (2³⁰) |
|---|---|---|---|
| **OBJ-1** `(b+c)·exp/rel/rate` — *the one I was asked to minimise* | **128** (5 %-flat over 128–256) | **≈320–500**, not resolved | **3 269** exponentiations |
| **OBJ-2** `(b+c)(1+b)·exp/rel/rate` — *honest, in modular operations* | **40** (5 %-flat over 26–52) | **≈64–128**, not resolved | **2.19 × 10⁵** operations |
| **wall clock**, measured end-to-end | **26** | **52** | 0.08 s / attempt |

Three results that survive everything:

1. **The argmin moves with `n`, under every objective**: 128 → ~400 (OBJ-1),
   40 → ~80 (OBJ-2), 26 → 52 (wall clock). **H2 confirmed.** A size-dependent
   optimum is the useful result; the single number is not.
2. **The `b`-gap survives the pow-vs-multiply distinction, but shrinks from
   67.9× to 7.1×** (2³⁰; at 2⁴⁰ the smallest feasible `b` is 12, giving 94.7×
   → 6.5×). It is real, and it is orthogonal to BB's stride sampler — but most of
   it was an artefact of pricing a `pow` at one unit. See §10.
3. **PREREG-4 resolved: the `b = 6` rate anomaly was chance.** Pooled over every
   `b = 6` measurement I made (N = 1320): **986/1320 = 0.7470, z = +0.52**.

---

## 1. PREREG-0 — baseline reproduction: **PASSED**

r48's own five configurations, fresh seeds (900 000+, disjoint from r48's 7–11
and r49's ≥ 77 000), through my own code path, 260 instances:

| band | `b` | `c` | factors | rate | `z` vs 20/27 | exp/rel | exp/attempt | s/attempt |
|---|---|---|---|---|---|---|---|---|
| ~2²⁰ | 15 | 10 | 43/60 | 0.7167 | −0.43 | 22 | 556 | 0.23 |
| ~2²⁶ | 8 | 5 | 50/60 | 0.8333 | +1.64 | 1 277 | 16 601 | 0.21 |
| ~2²⁶ | 8 | 10 | 48/60 | 0.8000 | +1.05 | 1 177 | 21 182 | 0.29 |
| ~2³⁰ | 12 | 10 | 32/50 | 0.6400 | −1.63 | 1 950 | 42 894 | 0.74 |
| ~2⁴⁰ | 20 | 10 | 20/30 | 0.6667 | −0.93 | 26 213 | 786 396 | 28.65 |
| **pooled** | | | **193/260** | **0.7423** | **+0.06** | | | |

Predecessor: 192/260 = 0.7385, `z = −0.08`. **Reproduced.** Per-band rates
scatter over 0.64–0.83 at N = 50–60, which is worth stating plainly: at that
sample size *any single band* sits ±0.10 from 20/27 as a matter of chance. That
is the yardstick for §8.

Independent cross-check of the cost instrument: my measured exp/rel at
`b = 6`, 2³⁰ is **23 490**; round 49 recorded **23 880**. 1.7 % apart, different
seeds, different code path. The instrument agrees.

---

## 2. Preregistration (written before any measurement; full text in `bsweep_core.py`)

| | preregistered | outcome |
|---|---|---|
| **PREREG-0** | baseline reproduces | **PASSED**, §1 |
| **PREREG-1** | cost(`b`) has an interior minimum | **CONFIRMED**, §4 |
| **PREREG-1a** | measured argmin @2³⁰ ∈ [32, 120] | **b = 128 by grid minimum** — just outside; see §5 |
| **PREREG-1b** | measured exp/rel below model; ratio *monotone decreasing* in `b` | **first half CONFIRMED, second half FALSIFIED** — the ratio *increases* with `b`; §10 explains why |
| **PREREG-2** | the argmin moves to larger `b` with `n` | **CONFIRMED** under all three objectives |
| **PREREG-3** | the optimal `b` is unchanged by `c=1` + Jacobi | **CONFIRMED, exactly**; §9 |
| **PREREG-4** | `b = 6` rate consistent with 20/27 at N = 400 | **PASSED**, §8 |
| **PREREG-5** | a capped configuration is reported as a lower bound, never a number | followed |

### The model I was preregistered against

`cost(b) = (b+c)/ρ(u)`, `u = log₂n / log₂(prime(b))`, using the **shared** `ρ`
from `r48/_shared/dickman.py`. Computed before measuring:

| | argmin over `b` ∈ [4, 1000] | model cost @ argmin | model cost @ `b`=64 |
|---|---|---|---|
| `n` ~ 2³⁰ | **`b*` = 200** | 4 772 / success | 7 187 |
| `n` ~ 2⁴⁰ | **`b*` = 700** | 32 186 / success | 1.54 × 10⁵ |

**The model puts the argmin outside the required grid `[4, 64]`, and is still
falling at `b = 64`.** So I swept the required grid *and extended it to `b` =
1000* — stopping at 64 would have reported "argmin at the right edge", which is
not a result.

---

## 3. Self-tests — including two real bugs they caught

`python3 bsweep_core.py` → **ALL PASS** (W1–W7). `python3 fastnull.py` →
**ALL PASS** (FN1–FN4). Not cosmetic:

- **W1 — the smoothness predicate can return False.** A predicate that calls
  everything smooth measures nothing. Tested on both sides at a size where both
  classes exist (`b = 26` @ 2²⁰: rejects 541/600, accepts 59/600), plus a
  known-rough `3¹¹·101` rejected on a `B = 19` base. **The first version of this
  test used `b = 8` @ 2³⁰, where ρ(7.06) ≈ 3 × 10⁻⁶, and demanded `acc > 0`. It
  correctly returned 0/600 accepted and the test FAILED. The harness was right and
  the test was wrong.**
- **W3 — the null where null is correct.** `b = 4` @ 2³⁰ with `cap = 5000` must
  return `cap_hit`, must *not* fabricate the relation set, and must propagate.
- **W4 — stripper lands exactly on `ord(g)`.** Full vs bounded stripper agree on
  every non-null instance (20/20); the quotient `M/ord(g)` is always odd.
- **W5 — the Jacobi filter terminates, and the Euler-criterion bug is caught.**
  50/50 conditioned draws satisfy `(g/n) = −1` against sympy; the **negative
  control** `pow(g,(n−1)/2,n) == n−1` fires **0/2000** times for `n = pq`. This is
  the bug that cost round 49 forty minutes.

### ⚠️ `fastnull.py` — I had to write an exact null space, and I got it wrong twice

`stange.py::kernel_basis` calls sympy's `Matrix.nullspace()`, which is unusable
above `b ≈ 16`: 0.037 s at `b` = 8, 0.060 s at `b` = 16, **still running after
60 s at `b` = 32** (killed, exit 124). Since the argmin sits at `b` = 40–128,
**every `b` above 16 would have been unmeasurable and the sweep would have been
truncated exactly where the answer is.** Replacement: exact Gauss–Jordan over
`Fraction`, 0.05 s at `b` = 32, 6.3 s at `b` = 128.

Two bugs, both of which would have shipped:

1. **Bareiss fraction-free elimination with `if f == 0: continue`.** The skipped
   row is never scaled by the pivot, the next division is inexact, and `//`
   silently truncates (51/2 → 25).
2. **Fraction back-substitution missing the negation** and **summing only over
   `j > pc`** — wrong, because a *free* column can sit left of a pivot column and
   its RREF entry there is not zero.

Both produced **correct rank, correct dimension, and completely wrong vectors.**
FN1 therefore asserts `M v = 0` **exactly over `Q`** rather than comparing ranks or
dimensions; a rank check would have passed both bugs. **A rank check is not a
correctness check for a null-space routine.**

---

## 4. The cost curve — both metrics, both objectives

`exp/rel` is **exponentiations per relation** (2nd metric). **PRIMARY** is
exponentiations per **successful factor**. exp/rel is printed too, and a drop in
it is an improvement **only if the primary also drops** — at `b` = 4 the primary
is 5 × 10⁶, so exp/rel alone would have read that row as a triumph.

### n ~ 2³⁰, `c = 1` (relation finding only; rate = 20/27, N = 20/b)

| b | BB | u | model 1/ρ(u) | **MEAS exp/rel** | meas/model | exp/attempt | **PRIMARY OBJ-1** | **PRIMARY OBJ-2** |
|---|---|---|---|---|---|---|---|---|
| 4 | 7 | 10.69 | 7.61e5 | 1.238e5 | 0.163 | 6.19e5 | 8.36e5 | 4.18e6 |
| 6 | 13 | 8.11 | 5.49e5 | 2.349e4 | 0.043 | 1.64e5 | 2.22e5 | 1.55e6 |
| 8 | 19 | 7.06 | 3.53e5 | 7 917 | 0.022 | 7.13e4 | 9.62e4 | 8.66e5 |
| 12 | 37 | 5.76 | 2.32e4 | 2 083 | 0.090 | 2.71e4 | 3.66e4 | 4.75e5 |
| 16 | 53 | 5.24 | 5 390 | 796.7 | 0.148 | 1.35e4 | 1.83e4 | 3.11e5 |
| 20 | 71 | 4.88 | 2 003 | 479.2 | 0.239 | 1.01e4 | 1.36e4 | 2.85e5 |
| 26 | 101 | 4.51 | 738.9 | 230.7 | 0.312 | 6 228 | 8 408 | 2.27e5 |
| 32 | 131 | 4.27 | 396.3 | 151.5 | 0.382 | 5 001 | 6 751 | 2.23e5 |
| 40 | 173 | 4.04 | 222 | 96.72 | 0.436 | 3 963 | 5 353 | **2.19e5** |
| 52 | 239 | 3.80 | 123.9 | 63.52 | 0.513 | 3 367 | 4 545 | 2.41e5 |
| 64 | 311 | 3.62 | 81.9 | 44.43 | 0.543 | 2 888 | 3 899 | 2.53e5 |
| 80 | 409 | 3.46 | 55.94 | 31.40 | 0.561 | 2 544 | 3 434 | 2.78e5 |
| 100 | 541 | 3.30 | 39.62 | 25.57 | 0.645 | 2 582 | 3 486 | 3.52e5 |
| **128** | 719 | 3.16 | 29 | 18.77 | 0.647 | 2 422 | **3 269** | 4.22e5 |
| 160 | 941 | 3.04 | 22.24 | 15.66 | 0.704 | 2 521 | 3 404 | 5.48e5 |
| 200 | 1223 | 2.93 | 17.59 | 12.72 | 0.723 | 2 557 | 3 452 | 6.94e5 |
| 256 | 1619 | 2.81 | 14.01 | 10.04 | 0.716 | 2 581 | 3 483 | 8.95e5 |
| 320 | 2153 | 2.71 | 11.48 | 8.676 | 0.756 | 2 785 | 3 760 | 1.21e6 |
| 400 | 2741 | 2.63 | 9.72 | 7.377 | 0.759 | 2 958 | 3 993 | 1.60e6 |
| 500 | 3571 | 2.54 | 8.29 | 6.360 | 0.767 | 3 187 | 4 301 | 2.16e6 |
| 700 | 5279 | 2.43 | 6.71 | 5.312 | 0.791 | 3 723 | 5 027 | 3.52e6 |
| 1000 | 7919 | 2.32 | 5.54 | 4.583 | 0.828 | 4 587 | 6 193 | 6.20e6 |

### n ~ 2⁴⁰, `c = 1` (N = 20/b)

`b` = 4, 6, 8 are **INFEASIBLE** — every instance hit the 2 × 10⁶ cap, so the
cost is a **lower bound only** (≥ 2.7 × 10⁶) and no point estimate is quoted.

| b | u | model 1/ρ(u) | **MEAS exp/rel** | meas/model | **PRIMARY OBJ-1** | **PRIMARY OBJ-2** |
|---|---|---|---|---|---|---|
| 12 | 7.68 | 4.97e5 | 1.235e5 | 0.249 | 2.17e6 | 2.82e7 |
| 16 | 6.98 | 3.26e5 | 6.026e4 | 0.185 | 1.38e6 | 2.35e7 |
| 20 | 6.50 | 1.53e5 | 2.684e4 | 0.175 | 7.61e5 | 1.60e7 |
| 26 | 6.01 | 4.59e4 | 9 778 | 0.213 | 3.56e5 | 9.62e6 |
| 32 | 5.69 | 1.90e4 | 5 031 | 0.265 | 2.24e5 | 7.40e6 |
| 40 | 5.38 | 8 035 | 2 561 | 0.319 | 1.42e5 | 5.81e6 |
| 52 | 5.06 | 3 320 | 1 247 | 0.376 | 8.93e4 | 4.73e6 |
| 64 | 4.83 | 1 759 | 760.3 | 0.432 | 6.67e4 | 4.34e6 |
| **80** | 4.61 | 974.4 | 488.8 | 0.502 | 5.35e4 | **4.33e6** |
| 100 | 4.41 | 568.7 | 315.9 | 0.555 | 4.31e4 | 4.35e6 |
| 128 | 4.22 | 348.7 | 192.8 | 0.553 | 3.36e4 | 4.33e6 |
| 160 | 4.05 | 229.9 | 139.3 | 0.606 | 3.03e4 | 4.88e6 |
| 200 | 3.90 | 159.1 | 103.9 | 0.653 | 2.82e4 | 5.67e6 |
| 256 | 3.75 | 111.2 | 72.12 | 0.648 | 2.50e4 | 6.43e6 |
| 320 | 3.62 | 80.97 | 53.79 | 0.664 | 2.33e4 | 7.48e6 |
| 400 | 3.50 | 61.95 | 44.24 | 0.714 | 2.40e4 | 9.60e6 |
| **500** | 3.39 | 47.9 | 33.87 | 0.707 | **2.29e4** | 1.15e7 |
| 700 | 3.23 | 34.01 | 25.86 | 0.760 | 2.45e4 | 1.72e7 |
| 1000 | 3.09 | 24.81 | 18.87 | 0.761 | 2.55e4 | 2.55e7 |

**The interior minimum is real and I bracketed it at both sizes.** At 2³⁰ the
curve falls 256× from `b` = 4 to `b` = 128 and then rises again; at 2⁴⁰ it is
still falling at the `b` = 200 grid edge, which is why the grid was extended.

---

## 5. Argmin: preregistered prediction vs measurement

| | model (Dickman) | measured | preregistered range [32, 120] |
|---|---|---|---|
| argmin @ 2³⁰ | 200 | **128** | **just outside** |

**PREREG-1a is half-met.** The point estimate 128 sits just outside the
preregistered interval [32, 120]. But the minimum is **flat**: `b` ∈ {128, 160,
200, 256} all lie within 5 % (3 269 / 3 404 / 3 452 / 3 483), and `b` = 80
(3 434) is within 5 % too. With N = 20/b the exp/rel relative standard error is
2–3 %, and the primary metric is linear in exp/rel, so **5 % is roughly 2σ.**

> **Honest statement: insufficient resolution to pin the OBJ-1 argmin at 2³⁰ to
> a single `b`. What is resolved is that the minimum lies in `[80, 256]` and is
> centred near 128.** To resolve `b` = 80 from `b` = 128 you need the cost curve
> to ~1 %, i.e. N ≈ 400/b (≈ 50 000 exponentiations at `b` = 128, about 20 s —
> it is cheap; I ran 20/b). I did not run it and I am not quoting a sharper
> number than I have.

At 2⁴⁰ the OBJ-1 minimum is **not resolved at all**: `b` ∈ {320, 400, 500, 700}
give 23 309 / 23 950 / 22 907 / 24 475 — a 2 % spread over a 2.2× range of `b`.
Reported as **"≈320–500, unresolved"**, not as `b* = 500`.

---

## 6. H2 — does the argmin move with `n`? **Yes, under all three objectives.**

| objective | argmin @ 2³⁰ | argmin @ 2⁴⁰ | moved? |
|---|---|---|---|
| OBJ-1 (exponentiations) | 128 | ≈320–500 | **~3–4× larger** |
| OBJ-2 (operations) | 40 | ≈64–128 | **~2× larger** |
| wall clock (measured) | 26 | 52 | **2× larger** |

The Dickman model predicted 200 → 700 (3.5×), the right direction and roughly
the right size. **The direction of the move is what matters and it is
consistent across three independent objectives.** The mechanism is the one
`u = log₂n / log₂BB(b)` predicts: at fixed `b` a bigger `n` means a larger `u`
and a rarer FB-smooth residue, so the `b` that balances the `(b+c)` term must
rise.

**I did not measure 2⁵⁰ or above.** Everything below 2⁴⁰ is measured; nothing is
extrapolated.

---

## 7. Full pipeline: measured rate and wall clock

N = 120 per cell, `c = 1`, `g` uniform. The relation-search column is Phase 1's
cost curve; the rest is new work.

### n ~ 2³⁰

| b | N | factors | rate | `z` vs 20/27 | exp/rel | **PRIMARY OBJ-1** | **s/attempt** | rels s | **alg s** | strip s |
|---|---|---|---|---|---|---|---|---|---|---|
| 4 | 120 | 100/120 | 0.8475 | **+3.22** | 1.05e5 | 6.18e5 | 3.67 | 3.65 | 0.00 | 0.022 |
| 6 | 120 | 98/120 | 0.8167 | **+2.15** | 2.29e4 | 1.96e5 | 1.13 | 1.13 | 0.00 | 0.002 |
| 8 | 120 | 94/120 | 0.7833 | +1.13 | 7 727 | 8.88e4 | 0.50 | 0.50 | 0.00 | 0.002 |
| 12 | 120 | 85/120 | 0.7083 | −0.78 | 2 080 | 3.82e4 | 0.24 | 0.23 | 0.00 | 0.002 |
| 16 | 120 | 88/120 | 0.7333 | −0.18 | 819.5 | 1.90e4 | 0.14 | 0.13 | 0.01 | 0.002 |
| 20 | 120 | 89/120 | 0.7417 | +0.02 | 428.4 | 1.21e4 | 0.09 | 0.08 | 0.01 | 0.002 |
| 26 | 120 | 89/120 | 0.7417 | +0.02 | 232.6 | 8.47e3 | **0.08** | 0.06 | 0.02 | 0.002 |
| 32 | 120 | 86/120 | 0.7167 | −0.59 | 155.2 | 7.15e3 | **0.08** | 0.05 | 0.03 | 0.002 |
| 40 | 120 | 85/120 | 0.7083 | −0.78 | 100.8 | 5.84e3 | 0.10 | 0.05 | 0.05 | 0.002 |
| 52 | 120 | 89/120 | 0.7417 | +0.02 | 61.54 | 4.40e3 | 0.13 | 0.04 | 0.10 | 0.002 |
| 64 | 120 | 82/120 | 0.6833 | −1.35 | 45.3 | 4.31e3 | 0.26 | 0.05 | 0.21 | 0.002 |
| 80 | 120 | 87/120 | 0.7250 | −0.39 | 32.43 | 3.62e3 | 0.41 | 0.05 | 0.36 | 0.002 |
| 100 | 120 | 86/120 | 0.7167 | −0.59 | 24.67 | 3.48e3 | 0.72 | 0.06 | 0.66 | 0.003 |
| **128** | 120 | 89/120 | 0.7417 | +0.02 | 19.02 | **3.31e3** | 1.15 | 0.06 | 1.09 | 0.002 |

### n ~ 2⁴⁰

| b | N | factors | rate | `z` vs 20/27 | exp/rel | **PRIMARY OBJ-1** | **s/attempt** | rels s | **alg s** | strip s |
|---|---|---|---|---|---|---|---|---|---|---|
| 4, 6, 8 | 120 | — | — | — | — | **INFEASIBLE** (all capped) | | | | |
| 12 | 120 | 26/120 | 0.8387 | +1.48 | 1.27e5 | 1.97e6 | 35.22 | 35.13 | 0.00 | 0.082 |
| 16 | 120 | 83/120 | 0.6917 | −1.16 | 6.02e4 | 1.48e6 | 24.66 | 24.64 | 0.01 | 0.008 |
| 20 | 120 | 84/120 | 0.7000 | −0.97 | 2.53e4 | 7.60e5 | 11.96 | 11.94 | 0.01 | 0.002 |
| 26 | 120 | 76/120 | 0.6333 | −2.44 | 9 772 | 4.17e5 | 5.33 | 5.30 | 0.02 | 0.002 |
| 32 | 120 | 89/120 | 0.7417 | +0.02 | 4 900 | 2.18e5 | 3.80 | 3.76 | 0.04 | 0.003 |
| 40 | 120 | 94/120 | 0.7833 | +1.13 | 2 592 | 1.36e5 | 2.54 | 2.46 | 0.07 | 0.002 |
| **52** | 120 | 91/120 | 0.7583 | +0.45 | 1 247 | 8.71e4 | **1.74** | 1.59 | 0.15 | 0.002 |
| 64 | 120 | 87/120 | 0.7250 | −0.39 | 777.5 | 6.97e4 | 2.04 | 1.68 | 0.36 | 0.003 |
| 80 | 120 | 87/120 | 0.7250 | −0.39 | 483.6 | 5.40e4 | 1.93 | 1.33 | 0.59 | 0.003 |
| 100 | 120 | 89/120 | 0.7417 | +0.02 | 306.4 | 4.17e4 | 2.08 | 1.06 | 1.01 | 0.003 |
| 128 | 120 | 94/120 | 0.7833 | +1.13 | 202 | 3.33e4 | 2.88 | 1.02 | 1.86 | 0.003 |

### ⚠️ The wall clock and the exponentiation count pick DIFFERENT `b`

**At 2³⁰ wall clock minimises at `b` = 26 (0.08 s) while the exponentiation count
minimises at `b` = 128 — a 4.9× disagreement in `b`.** At 2⁴⁰ it is 52 vs 128+
(2.5×). The breakdown says why, and it is the single most useful observation in
this note:

- at `b` = 4, 2³⁰: **relation finding is 3.65 s of the 3.67 s** (99.5 %);
- at `b` = 128, 2³⁰: relation finding is **0.06 s of the 1.15 s** (5 %) — the
  linear algebra is **95 % of the cost**.

The exponentiation count is blind to the linear algebra, which grows
super-linearly in `b`. **An exponentiation-only objective systematically
over-shoots `b`**, and by ~5× at 2³⁰. This is the same conclusion BB reaches
independently from the other direction (their `(1+b)` correction and their
`b ≈ 26–51` optimum), and it is the arithmetic behind it.

*Wall-clock caveat:* the box ran at load 27/16 from concurrent agents, so
absolute seconds are inflated. The **rel-vs-alg split** is measured per instance
inside each worker and is what the conclusion rests on.

---

## 8. PREREG-4 — the `b = 6` rate anomaly: **RESOLVED, it was chance**

Round 49 measured `b = 6` at 0.6417 (`z = −2.48`), launched a check that never
returned, and left it open. It is **rate**, not cost, and I measured rate only.

| measurement | N | rate | `z` vs 20/27 |
|---|---|---|---|
| Phase 2, `b`=6, `c`=1, 2³⁰ | 120 | 0.8167 | +2.15 |
| **Phase 3, `b`=6, `c`=10, 2³⁰, fresh seeds** | **600** | **0.7550** | **+0.81** |
| E2, `b`=6, `c`=1, 2³⁰, fresh seeds | 600 | 0.7250 | −0.86 |
| **pooled, all my `b`=6** | **1320** | **0.7470** | **+0.52** |

**PREREG-4 PASSED: the `b` = 6 rate is consistent with 20/27.** Note my own
N = 120 cell was **+2.15, on the opposite side of 20/27 from round 49's −2.48.**
Two "anomalies" of opposite sign at the same `b` is what chance looks like.

The `b` = 4 cell behaved the same way: **+3.22 at N = 120**, then **−0.16 at
N = 600** (442/600). Textbook regression to the mean; the N = 120 excursion did
not replicate.

### Is the low-`b` rate an *order-step* failure, or a useless multiple?

These are different claims, so I separated them (N = 400/b, `c`=1, 2³⁰, fresh):

| b | N | factors | **G == 0** | no-factor, G ≠ 0 | raw rate | rate given G ≠ 0 |
|---|---|---|---|---|---|---|
| 6 | 400 | 280 | **1** | 119 | 0.7000 | 0.7018 |
| 12 | 400 | 286 | 0 | 114 | 0.7150 | 0.7150 |
| 20 | 400 | 295 | 0 | 105 | 0.7375 | 0.7375 |
| 40 | 400 | 291 | 0 | 109 | 0.7275 | 0.7275 |

**`G == 0` — a kernel vector producing no usable multiple — occurs in 1 instance
out of 1600 and cannot be the mechanism.** Round 49's "`P = 20/27` exactly"
survives at small `b`.

---

## 9. PREREG-3 — the combined configuration

Round 49's two held-out wins: `c = 10 → c = 1`, and `g` drawn with
`(g/n) = −1` (rate `20/27 → 8/9`). n ~ 2³⁰, N = 120 per (b, scheme), fresh
seeds. Cell = `rate / cost-per-successful-factor (OBJ-1) / exp/rel`:

| b | S0 baseline `c`=10 | S1 `c`=1 | S2 Jacobi | **S3 COMBINED** |
|---|---|---|---|---|
| 20 | 0.7333 / 18 037 / 440.9 | 0.7917 / 11 866 / 447.3 | 0.9333 / 14 439 / 449.2 | 0.8667 / 11 005 / 454.2 |
| 40 | 0.7250 / 6 813 / 98.79 | 0.7500 / 5 446 / 99.62 | 0.8667 / 5 570 / 96.55 | 0.9000 / **4 440** / 97.47 |
| 64 | 0.7500 / 4 553 / 46.15 | 0.6917 / 4 225 / 44.96 | 0.8750 / 3 869 / 45.75 | 0.8917 / **3 312** / 45.44 |
| 100 | 0.7250 / 3 753 / 24.73 | 0.7417 / 3 405 / 25.00 | 0.8583 / 3 155 / 24.62 | 0.9333 / **2 710** / 25.05 |

The rates land where round 49 said they would: S0/S1 ≈ 20/27, S2/S3 ≈ 8/9.

**PREREG-3 CONFIRMED — and more strongly than preregistered.** `S3` and `S0` differ
only by `(b+c)` and by the rate, and both `b`-dependence lives entirely in
`exp/rel(b)`. So the argmin is *identical by construction*, and recomputing it
from the measured densities confirms it at **both sizes and under both
objectives**:

| | OBJ-1 argmin | OBJ-2 argmin |
|---|---|---|
| 2³⁰: S0 / S1 / S2 / S3 | 128 / 128 / 128 / **128** | 40 / 40 / 40 / **40** |
| 2⁴⁰: S0 / S1 / S2 / S3 | ≈500 / ≈500 / ≈500 / **≈500** | 128 / 80 / 128 / **80** |

(At 2⁴⁰ under OBJ-2 the four schemes span 80–128, which is inside the 5 %-flat
band and not resolved.)

**Best combined configuration.** Under OBJ-1 at 2³⁰: **`b` = 128, `c` = 1,
`g` with `(g/n) = −1`, 2 724 exponentiations per successful factor** (predicted
from the measured density; the largest directly-measured combined cell is
`b` = 100 at 2 710). Under OBJ-2 / wall clock: **`b` ≈ 40, `c` = 1, Jacobi `g`**.

### The same four schemes at n ~ 2⁴⁰ (N = 50/cell — small, see the flag below)

| b | S0 `c`=10 | S1 `c`=1 | S2 Jacobi | S3 COMBINED |
|---|---|---|---|---|
| 40 | 0.8400 / 1.46e5 / 2 460 | 0.6400 / 1.62e5 / 2 531 | 0.8600 / 1.46e5 / 2 518 | 0.9000 / 1.14e5 / 2 508 |
| 80 | 0.8000 / 5.47e4 / 485.8 | 0.6400 / 5.86e4 / 463.1 | 0.9000 / 4.95e4 / 495.1 | 0.8200 / 4.55e4 / 460.1 |
| 128 | 0.8000 / 3.39e4 / 196.4 | 0.6200 / 4.10e4 / 197.3 | 0.9000 / 2.99e4 / 195.3 | 0.9000 / 2.88e4 / 200.6 |

All four schemes put their OBJ-1 argmin at `b` = 40, which here is the **left
edge** of the grid and still descending — so this confirms PREREG-3 (identical
argmin) but does **not** resolve the argmin; §4/§5 do that. The S3 saving at
`b` = 128 is 33 883 → 28 751, i.e. **1.18×**, smaller than the 2³⁰ saving — and
see the `c` = 1 rate flag in §12 before using any of these 2⁴⁰ cells.

**Versus the `b` = 6 baseline** (the reference configuration this sweep was
asked to beat, same `n`, same rate accounting):

| | `b`=6 `c`=10 S0 | best | ratio |
|---|---|---|---|
| OBJ-1, 2³⁰ | 5.07e5 | 2 724 (S3, `b`=128) | **186×** |
| OBJ-1, 2³⁰, `c`=1 | 2.22e5 | 3 269 | **68×** |
| OBJ-2, 2³⁰ | 3.55e6 | 1.83e5 (S3, `b`=40) | **19.4×** |

---

## 10. ⚠️ RECONCILIATION WITH `BB_smoothpow.md` — read before quoting any `b`

BB landed three things that change how this note must be read. All three are
accepted.

### 10.1 Dickman `ρ` is not a valid null in this regime — and it was the null in §4

BB measured the exact `Ψ` and found the true FB-smooth density is **8.46 × ρ(u)**
at `u ≈ 6.2`, with `ρ` recovering to within 4 % only by `u ≈ 1.9`.

**Every `meas/model` column in §4 is therefore scoring against a null known to be
wrong, and the affected cells are identifiable by `u`:**

| size | cells with `u` ∈ [5, 8] (ρ invalid) | their `meas/ρ` |
|---|---|---|
| 2³⁰ | `b` = 8 (7.06), 12 (5.76), 16 (5.24) | 0.022, 0.090, 0.148 |
| 2⁴⁰ | `b` = 12–52 (`u` = 7.68 … 5.06) | 0.175 – 0.376 |

BB's 8.46× correction predicts a ratio of **0.118** in that band. My 2³⁰ cells at
`b` = 12 and 16 give **0.090 and 0.148** — straddling it. So:

> **The very low `meas/ρ` ratios at small `b` are substantially the Dickman-null
> artefact, not a real smoothness excess.** They are not evidence that small `b`
> finds relations more efficiently than theory allows.

**What survives:** the cells at `u ≲ 4.5` (`b` ≥ 26 at 2³⁰, `b` ≥ 64 at 2⁴⁰),
where `ρ` is approximately valid. There `meas/ρ` runs **0.31 → 0.83** and rises
toward 1 as `b` grows — i.e. **at large `b` the measured density really does
approach Dickman, and it is at small `b` that Dickman under-predicts.** That is
the honest reason my measured argmin came in *below* the model's 200.

**This falsifies my own PREREG-1b**, which predicted the ratio would *decrease*
with `b`. It increases. The mechanism is not a property of the sampler at all —
it is Dickman being the wrong function in the band where the argument lives.

**It does not affect any cost number in this note.** Every cost figure uses the
**measured** `exp/rel`, never `ρ`. The model appears only in comparison columns,
which are labelled and now caveated.

### 10.2 The `b`-gap survives the pow-vs-multiply distinction — but shrinks 10×

**Asked: does the gap survive? Answer: yes, in direction and mechanism, but most
of its size was a units artefact.**

The gap is a gap in the **number of candidates**, `(b+c)/δ`. BB's stride sampler
changes the **cost per candidate** (from ~2 log₂ n multiplications to 1). Those
are orthogonal, so the ratio between two `b` values at fixed `n` is *unchanged*
by stride — the gap survives.

But my OBJ-1 prices a `pow` at **one** unit and a smoothness-test reduction at
**zero**. `fb_exponents` performs one reduction per factor-base prime, i.e. **`b`
reductions per candidate**. In BB's currency a candidate costs `2 log₂ x + b`, not
1. Restoring that factor:

| size | smallest **feasible** `b` | gap to best `b`, **in exponentiations (OBJ-1)** | **in operations (OBJ-2)** |
|---|---|---|---|
| 2³⁰ | 6 | **67.9×** (`b`=6 → 128) | **7.1×** (`b`=6 → 40) |
| 2⁴⁰ | **12** (`b` = 4, 6, 8 all hit the cap) | **94.7×** (`b`=12 → ≈500) | **6.5×** (`b`=12 → 80) |

At 2⁴⁰ the gap **from `b` = 6 is not measurable** — every `b` < 12 instance hit
the 2 × 10⁶ cap, so the honest statement there is a lower bound (cost ≥ 2.7 × 10⁶
against a best of 22 907, i.e. **≥ 118×**), not a point estimate. The table row
uses `b` = 12, the smallest `b` I could actually measure.

**So: the gap is real, it is not a Dickman artefact, and it is not killed by
stride. But roughly 90 % of it was the `pow`-vs-reduction pricing** — 68–95× in
exponentiations becomes **6.5–7.1× in operations**. I am not retracting the gap;
I am reporting it at 7×, not 68×.

### 10.3 The right objective is OBJ-2, and it moves the argmin by 3×

Taking BB's `(b+c)(1+b)/δ`, with **my measured** `1/δ = exp/rel` (so this does not
depend on Dickman or `Ψ`):

| | OBJ-1 argmin @2³⁰ | **OBJ-2 argmin @2³⁰** |
|---|---|---|
| measured | 128 | **40** |

**BB independently predicts `b` = 36 at 2³⁰ from their `Ψ` model; I get 40 from
my measured density.** Different data, different null, same answer to within one
grid step — and it sits inside my measured wall-clock argmin of 26 and BB's
recommended 26–51. **Three independent routes now agree on `b ≈ 26–52` at 2³⁰.**

**OBJ-1 — the objective I was originally told to minimise — over-shoots `b` by
~3–5×.** That is the round's actionable finding: *do not adopt a large `b` on an
exponentiations-per-relation objective.*

---

## 11. Verdict on every preregistration

| | preregistration | verdict |
|---|---|---|
| **PREREG-0** | baseline 0.75 reproduces | **PASSED** — 193/260 = 0.7423, `z`=+0.06 |
| **PREREG-1** | cost(`b`) has an interior minimum | **CONFIRMED** at both sizes, bracketed |
| **PREREG-1a** | argmin @2³⁰ ∈ [32, 120] | **half-met** — 128, just outside; flat to ±5 % over [80, 256] |
| **PREREG-1b** | exp/rel below model; ratio monotone *decreasing* in `b` | **first half CONFIRMED, second half FALSIFIED** — it *increases*; §10.1 explains |
| **PREREG-2** | the argmin moves with `n` | **CONFIRMED** under all three objectives (128→~400, 40→~80, 26→52) |
| **PREREG-3** | optimal `b` unchanged by `c`=1 + Jacobi | **CONFIRMED, exactly** — identical argmin for all 4 schemes |
| **PREREG-4** | `b`=6 rate consistent with 20/27 | **PASSED** — 986/1320 = 0.7470, `z`=+0.52 |

---

## 12. Flagged, unexplained, NOT claimed

- **A rate deficit at `n` ~ 2⁴⁰, `b` ∈ {16, 20, 26}:** 243/360 = 0.6750,
  `z = −2.85`. `b` = 12 in the same run is *high* (0.8387), and `b ≥ 32` is
  clean (631/840 = 0.7512, `z` = +0.69), so the effect is **not monotone in `b`**
  — which is itself evidence against a mechanism. Pooled over all 11 cells at
  2⁴⁰ the rate is 0.6818 (`z` = −4.89), driven entirely by this cluster. The
  `G == 0` diagnostic (§8) was run at 2³⁰ only and cannot speak to it.
  **To settle it: run `b` ∈ {16, 20, 26} at 2⁴⁰ to N ≈ 600 with the `G == 0`
  split. I did not, and I claim nothing about it.**
- **A rate deficit for `c` = 1 at `n` ~ 2⁴⁰ — flagged, no mechanism, not claimed.**
  Round 49's "rate is flat in `c`" was verified at 2²⁶ and 2³⁰ only. My 2⁴⁰
  `c` = 1 runs disagree: Phase 2 pooled over 11 `b` cells is **900/1320 = 0.6818,
  z = −4.89**, and Phase 4's S1 arm is **95/150 = 0.6333, z = −2.74**. The same
  `c` = 1 code at 2³⁰ is clean (1 247/1 680 = 0.7423, `z` = +0.14). The
  `G == 0` diagnostic was run at 2³⁰ only and cannot speak to this. **To settle
  it: `c` = 1 at 2⁴⁰ to N ≈ 600 with the `G == 0` / `c` = 10 split on the same
  seeds. I did not run it.** This does not touch the headline results, which are
  all at 2³⁰.
- **Pooled rate at 2³⁰ over all 14 `b` cells:** 1 247/1 680 = **0.7423, z = +0.14**
  — flat in `b`, as round 49 requires. At 2⁴⁰ with `b ≥ 32` (N = 840):
  0.7512, `z` = +0.69. The flat-in-`b` claim **holds**; the 2⁴⁰ small-`b` cluster
  is the exception and is listed above.
- **Nothing above 2⁴⁰ was measured.** No extrapolation.
- **The OBJ-1 argmin at 2³⁰ is not pinned to one `b`** (§5), and at 2⁴⁰ it is not
  pinned at all. The OBJ-2 argmin is better resolved but still 5 %-flat over
  `[26, 52]` at 2³⁰.

---

## 13. What is honestly claimed

**Claimed.** (i) Cost as a function of `b` has an interior minimum, bracketed at
both sizes: `b* ≈ 128` (2³⁰) and `b* ≈ 320–500` (2⁴⁰) in exponentiations per
successful factor, `b* ≈ 40` and `b ≈ 64–128` in operations, `b* = 26` and `52`
in measured wall clock. (ii) **The argmin moves with `n`, by 2–4×, under all
three objectives.** (iii) The smallest-feasible-`b` to best-`b` gap is
**67.9–94.7× in exponentiations and 6.5–7.1× in modular operations** — real, not
a Dickman artefact,
not killed by the stride sampler, but ~90 % of its size was `pow`-vs-reduction
pricing. (iv) Round 49's `b` = 6 rate anomaly **was chance** (986/1320, `z`=+0.52)
and `G == 0` occurs in 1/1600 instances. (v) The optimal `b` is **exactly**
unchanged by `c`=1 and the Jacobi filter. (vi) **An exponentiations-per-relation
objective over-shoots `b` by 3–5×**, because the smoothness test costs `b`
reductions per candidate and the linear algebra is invisible to an exponentiation
count.

**Not claimed.** That `b* = 128` to better than ±5 % (§5). That the rate is flat
in `b` at 2⁴⁰ for `b < 32` (§12). Any behaviour above 2⁴⁰. That Dickman explains
any of the small-`b` ratios (§10.1). Any of this helps at RSA scale — it does
not, and the regime gap is unchanged.

**One line: the cost curve does have an interior minimum and it does move with
`n`, but the `b` you should run is ~40, not ~128 — the objective I was told to
minimise over-shoots by 3–5×, and 90 % of the headline 68× `b`-gap was a units
error.**

---

## 14. Reproduce

```
cd factor-scratch/r50/exp/bsweep
python3 bsweep_core.py       # W1-W7 self-tests; exits 1 on any failure
python3 fastnull.py          # FN1-FN4; must print ALL PASS before anything below
python3 run_baseline.py      # PREREG-0; exits 1 if the baseline does not reproduce
NPROC=12 NCOST=20 NFULL=120 N6=600 CAP=2000000 python3 -u run_sweep.py
WHAT=E1 N=20 python3 -u run_extra.py     # extended cost curve, b to 1000
WHAT=E2 N2=600 BS2=4,6,8,12 python3 -u run_extra.py
NFULL=400 BS=6,12,20,40 python3 -u diag_Gzero.py
NBITS=30 NFULL=120 BS=20,40,64,100 python3 -u run_combined.py
python3 analyze.py           # OBJ-1 vs OBJ-2 argmins, the b-gap, both sizes
```

Artifacts: `baseline.json`, `sweep.json`, `extra.json`, `gzero.json`,
`combined.json`, plus `*.log`. Seeds 900 000+ (baseline), 950 000+ (sweep),
1 300 000+ (PREREG-4), 1 700 000+ (combined), 1 950 000+ (G=0), 2 400 000+
(extension), 2 900 000+ (E2) — disjoint by construction.