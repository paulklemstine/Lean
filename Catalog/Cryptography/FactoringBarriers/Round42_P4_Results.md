# ROUND 42 — P4 EXECUTED WITH A VALIDATED INSTRUMENT
## Result: P4's effect on `k_success` is REAL, CONTROLLED, and a TAUTOLOGY; on the PAID sieving work it is a SIGN FLIP.

Round 42, 2026-09-25. Scratch: `/home/raver1975/factor-scratch/r42/`
(`f2rank_r42valid.py`, `core.py`, `design.py`, `dose.py`, `regress.py`,
`per_instance.txt`, `p4_rows.json`, `ladder.json`, `robust.json`).

---

## 0. INSTRUMENT VALIDATION (the whole point; the main loop's attempt was discarded)

`f2rank_r42valid.py` — **11/11 PASS**, reported before any measurement was believed.

| test | what it rules out | result |
|---|---|---|
| T1 | `rank ≤ min(nrows,ncols)` | 300/300 |
| **T1b** | **the exact discarded bug: `rank ≤ ncols` on dense 5–11-COLUMN matrices** | **1960/1960** |
| T2 | known full-rank must give full rank | 21 certified, all exact |
| T3 | known rank-1 outer product `uv^T` must give 1 | 80/80 |
| T4 | invariance to row AND column permutation | 600 permutations, 0 mismatches |
| **T5** | **cross-check vs `sympy` `DomainMatrix.convert_to(GF(2)).rank()`** | **300 random matrices, 0 mismatches** |
| T5b | same, on structured (dup/band/block/rank1+) matrices | 120/120 |
| T6 | streaming rank = batch rank at every prefix; dependency really XORs to 0 | 60 streams |
| T7 | first dependence of a rank-`r` stream at exactly `k=r+1` | 200 streams |
| T8 | identical-row stream: rank 1, dependence at k=2 | pass |
| **T9** | **MUTATION TEST — 2 deliberately broken routines must be caught** | **both caught** |
| T10 | the suite can *discriminate*: `Matrix.rank()` defaults to **QQ** | 16/200 disagree with GF(2) |

Three things this suite caught that a weaker one would not:

1. **The recorded bug class.** T1b is aimed at `k_success = 200..800` with 5–11
   columns. That is arithmetically impossible; T1b enumerates 1960 dense
   5–11-column matrices and asserts `rank ≤ ncols`.
2. **A wrong "reference".** sympy's *default* `Matrix.rank()` is rank over **QQ**.
   For a 0/1 matrix read over `F_2` it is wrong **127/1500** of the time. The
   cross-check must be `DomainMatrix.from_list_sympy(...).convert_to(GF(2)).rank()`.
   (I first wrote T10 asserting the *other* popular idiom,
   `rank(iszerofunc=lambda x: x%2==0)`, was also wrong; measurement said it
   agrees 1500/1500, so the test was wrong, not the engine. Corrected.)
3. **A validation suite with no power.** T9 injects two broken routines and
   requires the suite to fail on both. Without it, "validation passed" is
   unfalsifiable.

**Two tests failed on first run and both were bugs in my *tests*, not the
engine** (T7 appended a row that need not be in the span; T8 tested `is not
None` against a routine that yielded `0`). The routine's contract was made
explicit — `dep is None` **iff** the row raised the rank — and the tests were
corrected. Recorded because it is the same failure mode as round 41's.

**The collector is validated against the gold standard independently:** on round
41's own instance (`N=824248710959, B=717, M=43020`) it returns
`nrel = 515` and `yield = 0.01197117619711762` — digit-for-digit round 41's
recorded value. Round 42 did not re-derive round 41; it reproduced it.

---

## 1. DESIGN — and why it is SELECTION, not CRT

P4 as posed asks for `N` with `Q(N,B)` driven low "via CRT / prime selection".

**CRT is infeasible at any size where a real QS can be run, and this is
measurable.** Controlling `(N/r)` for `r ∈ S` requires a modulus `∏S < √N ≈ p`,
because `p, q` must be primes in prescribed progressions:

| `p ≈ 2^20` | `2^25` | `2^30` | `2^35` | `2^40` |
|---|---|---|---|---|
| **6** primes controllable | 7 | 8 | 9 | 10 |

**At most ~6–10 of the `π(B) ≈ 127` columns can be CRT-forced.** Selection on
*measured* `Q` at fixed `B` spans `Q/m = 0.378 … 0.646`. **Selection is a ~30×
stronger lever than CRT**, and is what was used. (This is itself a negative
result about P4's stated method.)

**Arms** (fixed `B=717`, `m=127`, `M=43020`, 41-bit balanced semiprimes):

* **Arm A — REAL.** A real single-polynomial QS `f(x) = (b₀+x)² − N`, segmented
  trial division, relations streamed through the validated engine, `k_success` =
  first dependence whose gcd splits `N`. **68/68 runs verified against ground
  truth `p, q`.**
* **Arm B — SYNTHETIC** (clearly labelled). Uniform `GF(2)` rows on the
  instance's **ON-columns only**. An OFF-column is identically zero for every
  `a`; drawing rows on all `m` columns would measure a different, wrong quantity.

**Matching is exact, not approximate:** the LOW and HIGH arms carry an
*identical* bit-length multiset (mean 41.50 both, sd 0.5075 both), identical
`m`, and matched `u` (3.7368 vs 3.7416, ratio 1.001) — the Dickman variable.

**Generator validated** against the round-40 failure (`q = N//p` with no
`N%p==0`, which produced 18.9% non-semiprimes): every instance asserts
`N%p==0`, `N%q==0`, `N//p==q`, both prime, and `len(factorint(N))==2` squarefree.

---

## 2. PER-INSTANCE TABLE (one row per `N`; error bar = between-instance sd)

Full 68-row table: `per_instance.txt`. Arm means ± between-instance sd:

| quantity | LOW-Q arm (n=34) | HIGH-Q arm (n=34) | ratio H/L | t (between-inst.) |
|---|---|---|---|---|
| `Q` | 51.24 ± 1.56 | 77.29 ± 1.72 | 1.509 | +65.6 |
| `Q/m` | 0.4034 ± 0.0123 | 0.6086 ± 0.0135 | 1.509 | +65.6 |
| **`k_success`** | **44.74 ± 6.99** | **65.09 ± 5.45** | **1.455** | **+13.4** |
| `k_success/Q` | 0.8735 ± 0.1345 | 0.8424 ± 0.0706 | 0.964 | −1.19 (n.s.) |
| `rank_F₂(M)` | 48.94 ± 2.66 | 75.41 ± 1.88 | 1.541 | +47.4 |
| `yield` (relations/position) | 0.00305 ± 0.0015 | 0.01708 ± 0.0046 | **5.599** | +16.9 |
| **`x_success` = PAID WORK** | **10236 ± 8054** | **1440 ± 638** | **0.141** | **−6.35** |
| `u` (Dickman) | 3.7368 ± 0.0177 | 3.7416 ± 0.0211 | 1.001 | — |
| `N` bit-length | 41.50 ± 0.51 | 41.50 ± 0.51 | 1.000 | — |

Cohen's *d*: `k_success` **+3.25**; paid work **−1.54** (large, opposite sign).

---

## 3. THE FINDING — a sign flip, and the reason for it

**P4's prediction is confirmed on `k_success`** — it does drop in the low-`Q`
arm, controlled, `t = +13.4`, and **strictly monotone in `Q`** across a
6-bin dose-response ladder spanning the whole `Q/m` range
(`k_success` bin means 44.0, 52.1, 53.0, 54.9, 56.8, 62.2 — *strictly
increasing*, Spearman +0.734).

**But it buys nothing, for two independent reasons.**

### 3a. The `k_success` effect is a TAUTOLOGY, and the synthetic arm proves it

`k_success/Q` is **independent of `Q`** (`corr(Q/m, k/Q) = +0.012` at `B=717`,
`t = −1.19` n.s.). So `k_success = Q × (a constant)` — the effect is *forced by
the rank ceiling*, not discovered. Arm B (SYNTHETIC, uniform random rows) makes
this exact: `k_success = Q+1` almost surely, `k/Q = 1.0124 ± 0.0287` (LOW) vs
`1.0069 ± 0.0221` (HIGH), `t = −0.89`, i.e. **indistinguishable**.

> **Round 41's `corr(Q/π(B), k_success/m) = +0.77` is not a new per-instance
> statement. It is the statement that a `Q`-dimensional space needs `Q` rows.**

The only *proved* per-instance bound remains `rank_{F₂}(M) ≤ Q(N,B)+1`, and it
**binds**: 0/68 violations, `rank/(Q+1) = 0.950` on average (min 0.784,
max 0.976). It bounds the **rank**, not the paid work.

### 3b. The PAID quantity moves the OTHER way — and `k_success` was the wrong quantity

The price of a relation is `1/yield`, and `yield` is *itself* set by `Q`
(`corr(Q, yield) = +0.624`). So `PAID = k_success / yield`. The yield penalty
(5.60×) **dwarfs** the relation saving (1.46×): paid work **rises 7.1×** in the
low-`Q` arm.

**Mechanism (measured, not asserted).** Only the *small* ON-primes do sieving
work. Counting ON-columns among primes `≤ 50` (15 of 127):
`corr(Q_small_on, yield) = +0.691` (beats total `Q`, +0.624),
`corr(Q_small_on, x_PAID) = −0.776`. The lowest-`Q` instances have 3–5 small
ON-primes and yields of 0.001–0.002; the highest have 10–11 and 0.006–0.027.

**The model-free budget test (no `ρ`, no `u`, no distribution assumed).** Same
instances, shrinking sieve range:

| `M` | LOW-Q failures | HIGH-Q failures |
|---|---|---|
| 43020 | **0/16** | 0/16 |
| 10755 | **8/16** | **0/16** |
| 4302 | **13/16** | **0/16** |

A genuinely cheaper arm must fail *less* at a fixed budget. **The low-`Q` arm
fails 13/16 where the high-`Q` arm fails 0/16.** This is a clean, model-free
demonstration that the low-`Q` arm is the *more* expensive one, and it also
disposes of the obvious objection — the one LOW instance at `x_success/M = 0.96`
is not a truncation artifact, it is the arm genuinely running out of sieve range.

---

## 4. ROBUSTNESS — and the honest complication

The sign flip reproduces at a **second factor base** (`B=2048`, `m=309`,
`M=120000`, 40 fresh instances, all verified):

| `B` | `m` | `corr(Q/m, k_success)` | `corr(Q/m, x_PAID)` | `k`: lo→hi | `x_PAID`: lo→hi |
|---|---|---|---|---|---|
| 717 | 127 | +0.766 | −0.657 | 49.2→59.7 (t=**+6.14**) | 9883→2579 (t=**−3.72**) |
| 2048 | 309 | **+0.193** | −0.666 | 107.2→110.4 (t=**+0.93**) | 4009→1632 (t=**−3.96**) |

**The `k_success` effect is NOT robust across `B`** — at `B=2048` it collapses
to `t = +0.93` (n.s.), because `k/Q` there is no longer constant
(`corr(Q/m, k/Q) = −0.353`, partially cancelling the `Q` factor). **The paid-work
effect IS robust and strengthens.** So the one quantity P4 claimed is the
B-fragile, tautological one; the quantity that is actually paid is the robust one.

**Dickman:** `u` is matched across arms (ratio 1.001), and the arms' yield gap
is therefore **not** a `ρ(u)` effect — it is the ON-column structure. No instance
in this round is a `ρ`-model failure; measured yield/`ρ(u)` is consistent with
round 41's 0.8–1.3× band.

---

## 5. VERDICT

* **Is P4 a CONTROLLED upper bound on the sieving work? NO.** It is a validated
  **negative**, with a sign flip and a measured mechanism.
* **Is the `k_success`↔`Q` relation controlled?** Yes — matched arms, identical
  bit-length multisets, matched `u`, monotone dose-response, `t=+13.4`, and it
  reproduces round 41's +0.77 (+0.766 here). But it is **a correlation whose
  magnitude is a tautology** (`k = Q × const`, and the synthetic arm pins
  `k = Q+1`), so it carries no exploitable information.
* **What DOES survive as controlled:** the proved ceiling
  `rank_{F₂}(M) ≤ Q(N,B)+1` (binds at 95%, 0/68 violations) — a bound on rank,
  and `Q` is computable in `O(π(B) log B)` with no sieving. What does **not**
  survive is any claim that a low-`Q` instance is *cheaper to factor*. It is
  **7.1× more expensive**, model-free confirmed.
* **The methodological finding, which outlives P4:** a per-instance lever on a
  *sieving* cost must act on the **density of usable small primes**, not on the
  count of columns. `Q` counts columns; the paid term is set by the small ON-columns
  (`corr = −0.776`). Optimising `Q` optimises the wrong quantity — and P4 as
  written is that mistake, made measurable.

**What is NOT claimed:** nothing here transfers to NFS (the record's standing
caution), nothing is a factoring method, and the CRT arm was replaced by
selection for the feasibility reason measured in §1, so "P4 by CRT" remains
untested — and at any size where a real QS runs, CRT cannot reach it.
