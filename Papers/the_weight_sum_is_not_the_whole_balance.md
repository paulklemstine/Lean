# The Weight Sum Is Not the Whole Balance

## `Σw = 3/2` is derived — and `1/5` is **overdetermined**: a second, independent balance the design rule never priced

**Round 54 · 2026-10-05 · Aether factoring programme**

---

## Abstract

A formalised design rule in this programme says a deterministic search-floor
scheme's optimum is `N^{γ/(1+Σw)}`, so reaching exponent `e` forces
`Σw ⩾ γ/e − 1`. At `γ = 1/2` that pins Harvey's `N^{1/5}` at `Σw = 3/2`, `N^{1/6}`
at `Σw ⩾ 2`, `N^{1/8}` at `Σw ⩾ 3`. It was named *"the most concrete open problem
this file produces"* — a single scalar deciding whether the `1/6`/`1/8` roadmap is
reachable at all.

**But nobody had established what the weights `wᵢ` ARE mechanically**, and the
corpus said so: *"I have NOT established what the weights are mechanically … the
question is not well-posed until that is."* **This round derives them from Harvey's
displayed equations.**

> **`Σw = 3/2` is two floors: weight `1/2` on `r`, weight `1` on `m`.** Not three of
> `1/2`, not two of `3/4`.
>
> **And it is not the whole balance.** Harvey's Algorithm 4.3 contains a **second,
> independent** balance the design rule never mentions: the Prop 2.5 screen at
> `M := ⌈(N/r)^{1/2}⌉`, costing `(N/r)^{1/4}`, balanced against the same pair floor
> `r`. That row has `γ = 1/4`, `Σw = 1/4`, and **contains no `m` at all** — so it is
> untouched by any reweighting of the BSGS side. Its optimum is also exactly `1/5`.
>
> **`1/5` is OVERDETERMINED. Two independent balances both yield exactly `1/5`.**

**So the answer to "is `Σw = 3/2` forced?" is: it is forced *given the design rule's
three-term shape*, but you cannot beat `1/5` by changing `Σw` alone.** Raising
`Σw: 3/2 → 2` moves row 1 to `1/6` and **leaves row 2 at `1/5`** — measured: the
claim is then missed by **exactly `1/30`**.

**This is a closure, and it is stronger than the design rule it completes** — it
does not contradict it, it adds a conjunct.

**Classical factoring of RSA-scale integers. Not a cryptographic break.** No RSA-scale
or cryptographic modulus was factored; all computation `n < 2⁴⁰`, locally generated.

---

## 1. The five cost terms, from Harvey's displayed equations

All transcribed from **arXiv:2010.05450v1** and **verified on rendered page images**,
not from `pdftotext` and not from memory.

| # | term | cost | source |
|---|---|---|---|
| **T1** | **screen** | **`(N/r)^{1/4} lg³ N`** | p.12 Alg 4.3 Step 2: `M := ⌈(N/r)^{1/2}⌉`; Prop 2.5 (p.6): `O(M^{1/2} lg³ N)` |
| T2 | large-order | `N^{1/5} lg² N` | p.12 Step 3: Prop 2.7, `D := ⌈N^{2/5}⌉` — **`D` is fixed by the hypothesis, no free parameter** |
| T3 | pair enumeration | `r lg³ N lg lg N` | p.11: *"The number of pairs `(a,b)` examined in Step (2) is `O(r lg r)`"* |
| T4 | BSGS interior | `N^{1/2}/(r^{1/2}m) lg⁴ N` | p.10 Prop 4.2 |
| T5 | baby-step floor | `m lg² N` | p.10 Prop 4.2 |

**The range `M = (N/r)^{1/2}` is forced, not chosen.** Lemma 3.3's hypothesis (3.1)
is `(N/r)^{1/2} ⩽ p < N^{1/2}`, so the Lehman search at parameter `r` is **invalid
until all factors below `(N/r)^{1/2}` have been excluded** — which is exactly what
Step 2 does. **This term is the one the design rule never mentions.**

Harvey's own summary line (p.12, verbatim): *"Combining the contributions from
Steps (1)–(4), the overall complexity is `O(s lg³ N + m lg² N + r lg³ N lg lg N)`"* —
and Proposition 4.3 concludes `O(N^{1/5} lg^{16/5} N)`.

## 2. The weights, derived

**Row 1** — the BSGS side, `min max(N^{1/2}/(r^{1/2}m), m, r)`:

```
1/2 − r/2 − m = r = m    ⟹    r = m = 1/5,  cost = N^{1/5}
```

The `1/2` on `r` traces to Remark 3.4's `N^{1/2}/r^{1/2}`; the `1` on `m` to `m`
appearing to **first power** in the interior. Hence **`Σw = 1/2 + 1 = 3/2` over
two floors** — which is what makes the design rule's `γ/(1+Σw) = (1/2)/(1+3/2) = 1/5`
come out right.

**I verified this optimum independently**, by direct minimisation over `(r,m)` on a
grid: `exponent = 0.20000` at `r = N^{0.2000}`, `m = N^{0.2000}`, and separately
`0.20000` for row 2 at `r = N^{0.2000}`.

## 3. Row 2 — the balance that pins `1/5` a second time

Row 2 is `max( r, (N/r)^{1/4} )`, which is **the same search-floor shape** with
`γ₂ = 1/4`, `w_r = 1/4`:

```
γ₂/(1+Σw₂) = (1/4)/(1+1/4) = 1/5
```

**It contains no `m`.** Its optimum is attained at `r = N^{1/5}` and is **completely
independent of the BSGS weights.**

> **`1/5` is overdetermined. Raising `Σw` from `3/2` to `2` moves row 1 to `1/6` and
> leaves row 2 at `1/5`.**

**Measured:** at `Σw = 2` with Strassen's screen, the actual total is `1/5`, the
binding terms are `['interior', 'pairs', 'screen']`, and **the `1/6` claim is missed
by exactly `1/30`.**

### The corroboration is in Harvey's own published parameters

Harvey sets `r := ⌈N^{1/5}/lg^{4/5} N⌉` and `m := ⌈N^{1/5} lg^{6/5} N⌉`. At those
settings **four of the five terms co-bind** at exactly `N^{1/5} lg^{16/5} N`
(T1, T3, T4, T5), with only T2 below. **The `lg` corrections exist precisely to
co-bind the max** — direct evidence the design is a **four-way** balance, not the
three-term shape the design rule assumes.

## 4. The corrected design rule

`beating_one_fifth_requires` (`Σw > 3/2` **OR** `γ < 1/2`) is a **correct dichotomy
for row 1**. It is **necessary-not-sufficient for the algorithm**:

> **For target `e`: row 1 needs `Σw ⩾ γ₁/e − 1`, AND row 2 needs `θ ⩾ 2e/(1−e)`**,
> where `θ` is the screen exponent (Strassen: `θ = 1/2`).

| target | row 1 `Σw` | row 2 `θ` | Harvey supplies |
|---|---|---|---|
| **1/5** | 3/2 | 1/2 | ✓ both |
| **1/6** | **2** | **2/5** | ✗ ✗ |
| **1/8** | **3** | **1/3** | ✗ ✗ |

**This is a closure, not a construction: I did not find slack, and under Harvey's
mechanism there is none to find.**

## 5. Experiments

Three scripts, all **seeded** (`random.seed(20261004)`), all run **twice with
byte-identical output** (verified by `diff`). Exact arithmetic via
`fractions.Fraction`, with an independent float cross-check.

**E1 — five-term bookkeeping.** Prediction stated first: max `N`-exponent `= 1/5`;
**four** terms co-bind at Harvey's published `(r, m)`. Both confirmed.

**E2 — the closure.** Raising `Σw` to 2, 3 and re-deriving the true total with the
screen term intact. **Result: `1/6` is missed by `1/30` at `Σw = 2`.** The
`θ ≤ 2/5` requirement is what closes the gap.

**E3 — the weights, empirically.** 42 cells, `n = 2²⁸–2⁴⁰`, locally generated
semiprimes. Pair-count exponent vs `r`: **1.3171–1.3905** across seven sizes
(predicted → 1.0, weight 1) — consistently above 1, which is the `lg r` factor.
Candidate-count exponent vs `N` at fixed `r`: **0.3379–0.3727** (the total count at
fixed `r = N^{1/5}`; the *weight* on `r` is Remark 3.4's symbolic `r^{-1/2}`, **not**
a measured slope — stated so the two are not conflated). Nonzero check on every
cell: OK.

**Honest scope of E3:** these are **counts at the algorithm's own parameters**, not
an asymptotic measurement, and **nothing is extrapolated to the NFS regime**
(`π(B*) ≈ 10¹⁵–10³³` is uninstantiable here).

## 6. ⚠️ Errors made, prominently

1. **The screen's `lg` exponent was wrong by a factor 2 in both scripts** — and in
   `exp_closure.py` that made **the closure claim false**. The script said `1/6` was
   reachable; it is not. Caught by hand-checking the algebra against the page image.
2. **The Algorithm 4.2 implementation factored 0 of 8 semiprimes while printing a
   clean table.** I had used `a·isqrt(N)` where eq. (4.1) is
   `α^{aN+b−⌈(4abN)^{1/2}⌉}`. **A clean table over an empty result set is the exact
   "vacuous test that prints PASS" failure** — caught only by reading the image.
3. **Two `argmin` tests were vacuous or used the wrong metric** before being fixed.
4. **A prediction failed and was kept visible.** The `P8` prediction did not hold; it
   is recorded rather than re-run until it passed. *A prediction that only survives
   if you keep re-rolling it is not a prediction.*
5. **`pdftotext` was not trusted anywhere** — every Harvey quotation was read off a
   rendered page image, because that tool silently flattens exponents and this
   round's entire content is exponents.

## 7. What this changes

**The `Σw > 3/2` question is answered, and the answer is a closure that is stronger
than the question.** The single-scalar framing was misleading: it priced **one row
of a two-row design**. **The corpus's open item is retired — not by finding slack,
but by showing the rule that asked for slack was incomplete.**

**The practical consequence for the roadmap:** GFHP's *"remains applicable for
potential future improvements … targeting `N^{1/6+o(1)}` or even `N^{1/8+o(1)}`"*
sentence is weaker still than either the weight rule or this screen rule
suggests. Reaching `1/6` requires moving **two independent knobs**, one of which
(`θ`, the small-factor screen exponent) is **not part of the weight framework at
all** and has no known improvement.

**What is NOT settled:** whether row 2 is *escapable*. I showed it **pins** `1/5`;
I did not show it is **unavoidable** — that would require beating Strassen's
small-factor screen, which is a separate and hard question. Also unread: Harvey's
published Math. Comp. version (only arXiv v1), and `[HW08]`/`[Hit20]`/`[Hit18]`
cited by Harvey. And whether `finset_barrier_attained_log` transfers to Harvey's
cost at all — **his terms carry different `lg` powers (`lg³` vs `lg²`) where the Lean
file assumes a single `c`.** That assumption may not hold; it is flagged, not
resolved.

## 8. Reproduce

```
cd factor-scratch/r54exp/weights
python3 exp_balance.py   # exact five-term bookkeeping
python3 exp_closure.py   # the closure: Σw = 2 still gives 1/5
python3 exp_alg.py       # 42 cells, n < 2^40
```

All seeded, all byte-identical across two runs. Dependencies: Python 3.12,
`sympy`. **Source: David Harvey, *An exponent one-fifth algorithm for deterministic
integer factorisation*, arXiv:2010.05450v1** — Alg 4.3 and Prop 4.3 (p.12), Prop
4.2 (p.10), Prop 2.5 and Lemma 3.3 (p.6), Remark 3.4 (p.7), all read from rendered
page images. **The corpus's own `HarveyFloor.lean` was read for the design rule and
its single-`c` assumption flagged, not confirmed.**