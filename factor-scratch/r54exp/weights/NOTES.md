# r54: what the weights w_i actually ARE — derivation from Harvey's displayed equations

## VERDICT UP FRONT

**Σw = 3/2 is mechanically correct but INCOMPLETE, and it is NOT the only thing
pinning 1/5. Harvey's Algorithm 4.3 has a *second, independent* balance that
the corpus's model omits entirely, and its optimum is also exactly 1/5. So the
answer to "is Σw = 3/2 forced?" is: it is forced *given the corpus's three-term
shape*, but 1/5 is **overdetermined** — you cannot beat 1/5 by changing Σw
alone, and the corpus's design rule prices only one of two rows.**

Concretely: `Σw = 3/2` is **two floors, weights 1/2 on r and 1 on m** (not
three of 1/2, not two of 3/4). But Harvey's cost also contains the
Prop 2.5 screen `(N/r)^{1/4}`, balanced against the same pair-enumeration floor
`r`. That second row has `Σw = 1/4` and **contains no `m` at all**, so it is
untouched by any reweighting of the BSGS side. Raising Σw from 3/2 to 2 moves
row 1 from 1/5 to 1/6 while **row 2 stays pinned at 1/5**. Reaching 1/6 requires
*both* rows to move: Σw: 3/2 → 2 **and** the screen exponent θ: 1/2 → 2/5.

---

## THE DERIVATION

### 1. The five cost terms, from Harvey's displayed equations

All from **arXiv:2010.05450v1**, verified on rendered page images (see
Provenance). Each term is transcribed from the paper, not recalled.

**(T1) Screen.** p.12, Algorithm 4.3 Step 2: "Apply Proposition 2.5 with
`M := ⌈(N/r)^{1/2}⌉`." Prop 2.5 (p.6): find a prime divisor `p ⩽ M` in time
`O(M^{1/2} lg³ N)`. Hence

> screen = `M^{1/2} lg³ N` = `((N/r)^{1/2})^{1/2} lg³ N` = **`(N/r)^{1/4} lg³ N`**

The range `M = (N/r)^{1/2}` is *forced*, not chosen: Lemma 3.3's hypothesis
(3.1) is `(N/r)^{1/2} ⩽ p < N^{1/2}` (p.6, verified on image), so the Lehman
search with parameter `r` is only valid once all factors below `(N/r)^{1/2}`
have been excluded. That is exactly what Step 2 does. **This term is the one the
corpus never mentions.**

**(T2) Large-order.** p.12, Step 3: Prop 2.7 with `D := ⌈N^{2/5}⌉`, cost
`O(D^{1/2} lg² N)` = `N^{1/5} lg² N`. `D` is **fixed** by the hypothesis
`N^{2/5} ⩽ D` of Prop 2.7 — there is no free parameter, so this term is
*not* part of any balance. (Remark 2.8 notes `D ⩾ N^{2/5}` "is not the sharpest
possible"; `D = Ω(N^{1/3+o(1)})` is claimed possible. It does not bind anyway.)

**(T3) Pair enumeration.** p.11: "The number of pairs `(a,b)` examined in Step
(2) is `O(r lg r)`", cost `O(r lg³ N lg lg N)`. p.7 Remark 3.4 (on image):
`Σ_{k=1}^{r} ⌊N^{1/2}/(4rk^{1/2})⌋ = O(N^{1/2}/r^{1/2} + r)`. So the pair
floor is **`r`** in exponent.

**(T4) BSGS interior + (T5) baby-step floor.** p.10, Proposition 4.2,
**verbatim**:

> "For `r, m = O(N)`, its running time is
> **`O(( N^{1/2}/(r^{1/2}m) + r ) lg⁴ N + m lg² N)`."**

which is `(T3) + (T4) + (T5)` with `interior = N^{1/2}/(r^{1/2}m)`,
`m-floor = m`.

### 2. The weights, mechanically

| row | terms | γ | w_r | w_m | Σw | optimum |
|---|---|---|---|---|---|---|
| **1 — BSGS** | `r`, `m`, `N^{1/2}/(r^{1/2}m)` | 1/2 | **1/2** | **1** | **3/2** | 1/5 |
| **2 — screen** | `r`, `(N/r)^{1/4}` | 1/4 | **1/4** | — | **1/4** | 1/5 |

**So Σw = 3/2 is two floors: weight 1/2 on r, weight 1 on m.** The mechanisms:

- **w_r = 1/2** comes from the `r^{1/2}` in the denominator of Prop 4.2's
  interior. Mechanically it traces to Remark 3.4's `N^{1/2}/(r^{1/2})`: one unit
  of `r` buys `r^{1/2}` units of range reduction. Harvey's Step (2b) j-interval
  `0 ⩽ j < N^{1/2}/(4rm(ab)^{1/2})` (p.9, verified on image) carries the same
  `r^{1/2}`.
- **w_m = 1** comes from `m` appearing to the **first power** in the interior,
  i.e. one unit of `m` buys one unit of range reduction. It is the baby-step
  budget; the Step (1) precomputation `α⁰,…,α^{m-1}` costs `O(m lg² N)` (p.11).

### 3. The second balance — the actual finding

Row 2 is `max( r , (N/r)^{1/4} )`, which is the corpus's own search-floor shape
with `γ = 1/4`, `w_r = 1/4`:

> `γ/(1+Σw) = (1/4)/(1+1/4) = **1/5**`

**It contains no `m`.** Its optimum is attained at `r = N^{1/5}` and is
completely independent of the BSGS weights. Hence:

> **1/5 is overdetermined.** Two independent balances both yield exactly 1/5.
> Raising `Σw` from 3/2 to 2 moves row 1 to 1/6 and leaves row 2 at 1/5.

This is why Harvey's Algorithm 4.3 chooses `r := ⌈N^{1/5}/lg^{4/5} N⌉` and
`m := ⌈N^{1/5} lg^{6/5} N⌉` (p.12, on image): at those settings **four** of the
five terms co-bind at exactly `N^{1/5} lg^{16/5} N` (T1, T3, T4, T5), with only
T2 below. The `lg` corrections exist precisely to co-bind the max, which is
direct evidence the design is a four-way balance, not a three-term one.

**Consequence — the corpus's design rule is incomplete.** `beating_one_fifth_requires`
(`Σw > 3/2` **OR** `γ < 1/2`) is a correct dichotomy *for row 1*. But it is
necessary-not-sufficient for the algorithm: the true requirement is

> **for target `e`: row 1 needs `Σw ⩾ γ₁/e − 1`, AND row 2 needs `θ ⩾ 2e/(1−e)`**,
> where θ is the screen exponent (Strassen: θ = 1/2).

| target | row 1 Σw | row 2 θ | Harvey supplies |
|---|---|---|---|
| 1/5 | 3/2 | 1/2 | ✓ both |
| 1/6 | **2** | **2/5** | ✗ ✗ |
| 1/8 | **3** | **1/3** | ✗ ✗ |

This is a *closure*, not a construction: I did not find slack. Under Harvey's
mechanism there is none to find. Note this closure is **stronger** than the
corpus's, and it does not contradict it — it adds a second conjunct.

---

## EXPERIMENTS

Three scripts, all **seeded** (`random.seed(20261004)`), all run **twice with
byte-identical output** (verified by `diff`). Exact arithmetic uses
`fractions.Fraction`; a float path checks it independently.

Scope guard: all factoring is on **locally generated semiprimes with
n < 2⁴⁰**. No RSA-scale or cryptographic moduli were factored. Nothing is
extrapolated to the NFS/UMW regime.

### E1 — `exp_balance.py`: exact five-term bookkeeping
**Prediction (stated first):** max N-exponent = 1/5; **four** terms co-bind at
`N^{1/5}lg^{16/5}`, only Prop 2.7 below; corpus 3-term model reproduces 1/5.

**Result: all confirmed.** Independent float path at N = 2^128…2^4096 agrees to
< 1.2e-13 in log-space, co-attainers identical at every size.

**Controls:** positive — the corpus 3-term model *does* return 1/5, so the
instrument fires (a miss would have been a real signal). Brute-force
minimisation of row 2 on a 1/200000 grid returns exactly 1/5 at `r = N^{1/5}`,
independently of the closed form.

### E2 — `exp_closure.py`: does improving row 1 move the total?
**Prediction:** total optimum stays exactly 1/5 for every row-1 weight with
`Σw > 3/2`; and (negative control) improving row 2 *alone* should let the total
drop.

**Result: first clause CONFIRMED (the closure). Second clause FAILED** — with
θ < 1/2 the total *still* sat at 1/5. The failure is informative and corrected
the claim:

> The total is **`max(row 1, row 2)`**, not row 1 alone. Improving *either* row
> alone leaves the total at 1/5; **both** must improve simultaneously. Verified
> over 7 (Σw, θ) combinations; the total drops below 1/5 only when both rows are
> strictly better than 1/5.

I cross-validated this script against E1 with an explicit `assert` on the
Harvey setting (both agree: all four N-terms tie at 1/5).

### E3 — `exp_alg.py`: faithful Algorithm 4.2 at small scale
A real implementation of Alg 4.2 (steps 1–4, eq. (4.1), (4.2), Lemma 3.1, and
the Step (4)/Alg 4.1 fallback), run on locally generated semiprimes.

**Prediction:** factors the test semiprimes; reports "prime" on prime inputs.

**Result:** **7 of 8** semiprimes factored correctly; 3 of 3 primes correctly
returned no factors (negative control passes). The single miss (30 bits) is a
**granularity artifact**, not a logic error: hypothesis (3.1) holds there, but
with `m = 41` and `N^{1/2} ≈ 10⁴` the j-interval is too coarse to contain
Lemma 3.3's witness. Harvey's own `lg^{6/5}` correction is not in its small-n
range at 30 bits. Labelled as a scope limit, not a refutation.

**P15 (argmin over r), honest reporting — three versions, two failures:**
- v1 **vacuous**: minimised a unit-weight sum over *all* r; small r gives
  `jmax = 0`, so work collapses while covering nothing.
- v2 **wrong metric**: restricted to successful r but kept the sum; Harvey's
  cost is a **max** including the screen `(N/r)^{1/4}`, which *decreases* in r,
  so a sum always prefers the smallest usable r. Gave `r*/N^{1/5} ≈ 0.06–0.22`.
- v3 **correct**: Harvey's actual max-cost over successful r. Gives
  `r*/N^{1/5} ≈ 0.41, 0.42, 0.42, 0.20` (34–40 bits) — **not** 1.0.

The 0.41 offset is *explained*, not anomalous: Remark 3.4 and Prop 4.2 give the
pair count as `Θ(r lg r)`, not `Θ(r)`, and balancing `r·lg r` against
`(N/r)^{1/4}` predicts `r*/N^{1/5} = (ln r*)^{-4/5} = 0.41, 0.34, 0.35` for the
first three cells — within 0.07 of measurement. Direct count check: pair count /
`(r ln r)` = 1.09, 1.06, 1.06, 1.07. The 40-bit cell (0.20) is **UNDERPOWERED**
— only 32 of 398 r values succeeded — and is not interpreted. **The exponent
(weight 1) is unaffected; only the small-n prefactor is.**

---

## ERRORS I MADE (recorded, not hidden)

1. **Screen log-exponent, factor 2.** First draft of `exp_balance.py` computed
   the screen's `lg` power as `3 − r_lg/2`; correct is `3 − r_lg/4`, because
   `M = (N/r)^{1/2}` already contains the square root. Caught because the
   independent float path disagreed (17/5 vs 16/5). Had it gone unnoticed it
   would have broken the four-way co-binding claim.
2. **Same bug, load-bearing, in `exp_closure.py`:** I wrote
   `screen = θ/2 − θ·r_exp` instead of `θ/2 − (θ/2)·r_exp`. **This made the
   closure claim FALSE** (row 2 would have optimised to 1/6). Caught by
   cross-checking against `exp_balance.py`. Now guarded by an `assert`.
3. **Grid domain too small.** `optimise()` searched `r_exp ⩽ 1/10`, silently
   excluding the true optimum at `1/5`. Produced a confident, wrong `7/20`.
4. **Vacuous test.** E3 v1 factored **0 of 8** semiprimes while still printing a
   clean table — the exact "PASS with no cells" failure. Root cause: equation
   (4.1) is `α^{aN + b − ⌈(4abN)^{1/2}⌉}` (p.9, verified on image) and I had
   used `a·isqrt(N)`. **Read the page image; do not trust the flattened text.**
5. **Missing Step (4).** Omitting Alg 4.2's Alg-4.1 fallback gave 2/8 instead of
   7/8 — Prop 4.2 states outright that Step (3) solves the *stronger* congruence
   mod N and that on a miss the witness survives into Step (4).
6. **P8 prediction failed** (row 2 alone should suffice) → corrected to the
   two-sided `max` closure. Recorded in E2 rather than quietly re-run.
7. **pdftotext mangles this paper.** It rendered Remark 3.4's `+ r` as
   `+ r^{1/2}`, and flattened exponents throughout. Every load-bearing formula
   quoted above was re-read from a rendered page image.

---

## WHAT IS NOT DETERMINABLE FROM HERE

- **Whether the second balance is escapable.** I showed row 2 pins 1/5, not
  that row 2 is unavoidable. Row 2 is escapeable in principle — by a
  small-factor screen better than Strassen's `M^{1/2}` at the specific range
  `M = (N/r)^{1/2}`, or by a Lehman-type lemma whose hypothesis (3.1) needs a
  *smaller* `M`. I did not find one, and I have no lower bound ruling it out.
- **Whether θ = 2/5 is achievable.** The requirement for 1/6 is exact
  arithmetic; its *satisfiability* is a separate open question I did not touch.
  Note Remark 2.8 says Prop 2.7's `D ⩾ N^{2/5}` is already improvable to
  `D = Ω(N^{1/3+o(1)})` — but T2 does not bind, so that slack buys nothing here.
- **Whether a `k > 2`-floor scheme could lower γ.** I analysed the 2-row case
  because that is what Harvey's equations give. A genuinely different mechanism
  is outside this derivation by definition.
- **Any measurement at cryptographic scale.** Everything numeric here is
  n < 2⁴⁰ and is about *cost-model structure*, not factoring performance.
- **Corollary attacks on the GFHP log-lock.** `HarveyFloor.lean`'s log-exponent
  lock assumes a single per-step primitive cost `c`. Harvey's real cost has
  terms with *different* lg powers (`lg³` on the screen and interior, `lg²` on
  the m-floor). Whether `finset_barrier_attained_log` transfers to that
  multi-`c` structure is a real question I did not resolve.

---

## FULL PROVENANCE

**Fetched and read (all verified against rendered page images):**

- `arXiv:2010.05450v1`, "An exponent one-fifth algorithm for deterministic
  integer factorisation", David Harvey. `https://arxiv.org/pdf/2010.05450`
  → `harvey.pdf` (14 pp., 210 KB). Read as `harvey.txt` **and** re-read the
  load-bearing pages as images (`p06`, `p07`, `p10`, `p12`, `eq41b`).
  - p.6: Prop 2.5 (`O(M^{1/2} lg³ N)`), Prop 2.7 (`D` range, `O(D^{1/2} lg² N)`),
    Remark 2.8, **Lemma 3.3 and hypothesis (3.1) — on image.**
  - p.7: **Lemma 3.3 proof and Remark 3.4 — on image** (the `O(N^{1/2}/r^{1/2} + r)`
    candidate count; pdftotext corrupted this).
  - p.9: **Algorithm 4.2, eq. (4.1) `α^{aN+b−⌈(4abN)^{1/2}⌉}` and (4.2)'s
    j-interval — on image, high-res crop.**
  - p.10: **Proposition 4.2 cost, verbatim — on image.**
  - p.12: **Algorithm 4.3 (r, m, Step 2's `M := ⌈(N/r)^{1/2}⌉`, Step 3's
    `D := ⌈N^{2/5}⌉`) and Proposition 4.3 — on image.**
- Local corpus: `Catalog/Cryptography/FactoringBarriers/HarveyFloor.lean` (read
  in full; hypotheses of `weighted_amgm_finset`, `finset_barrier_attained`,
  `beating_one_fifth_requires`, `required_weight` all as quoted above).
- `Catalog/Cryptography/FactoringBarriers/RESEARCH.md` lines 3647–3800
  ("THE BALANCE DILEMMA" and "THE LOG-EXPONENT LOCK").

**UNVERIFIED — not fetched, not relied on:**

- Harvey's *published* Math. Comp. 90 (2021) 2937–2950 version. Only the arXiv
  v1 was read. Published versions sometimes differ; every claim here is about
  **v1** as fetched.
- `[HW08]` Theorem 36 (the Dirichlet-type lemma Harvey invokes in Lemma 3.3's
  proof, p.7) — cited by Harvey, **not read by me**. Its statement is quoted only
  as Harvey quotes it.
- `[Hit20]` (Hittmeir, Algorithm 6.1 / Lemma 4.1) and `[Hit18]` (Prop 2.7,
  Remark 6.4) — cited by Harvey, **not read by me**. The claim in Remark 2.8
  about `D = Ω(N^{1/3+o(1)})` is **Harvey's assertion, unverified here**.
- The published `lg^{16/5}` for GFHP and its `1/6`/`1/8` roadmap sentence —
  quoted from RESEARCH.md §2, not from GFHP itself. **Not used** in any
  derivation above.

**Files written** (all under `factor-scratch/r54exp/weights/`):
`harvey.pdf`, `harvey.txt`, `harvey_abs.html`, `p06/p07/p10/p12/eq41b*.png`,
`exp_balance.py`, `exp_closure.py`, `exp_alg.py`, `lgcheck.py`,
`run1.txt`, `run2.txt`, `c1.txt`, `c2.txt`, `a1.txt`, `a2.txt`, `NOTES.md`.

No files outside this directory were modified. No commits, no issues, no writes
to `Papers/` or `Catalog/`.
