# Round 54 — the weights derived, and `1/5` is overdetermined

**2026-10-05. NO new factoring algorithm. The corpus's own open item — "what ARE the
weights `wᵢ` mechanically?" — is ANSWERED, and the answer is a closure STRONGER than
the question it came from.**

Paper: **`Papers/the_weight_sum_is_not_the_whole_balance.md`**.
Code: `factor-scratch/r54exp/weights/` (3 scripts, seeded, byte-identical across runs).
**No RSA-scale or cryptographic modulus was factored.** All computation `n < 2⁴⁰`.

---

## 1. VERDICT

> **`Σw = 3/2` is TWO floors: weight `1/2` on `r`, weight `1` on `m`** — not three of
> `1/2`, not two of `3/4`. **And it is not the whole balance.**

Harvey's Algorithm 4.3 carries a **second, independent balance the design rule never
prices**: the Prop 2.5 screen at `M := ⌈(N/r)^{1/2}⌉`, costing `(N/r)^{1/4}`, balanced
against the same pair floor `r`. **That row has `γ = 1/4`, `Σw = 1/4`, and contains NO
`m` at all** — untouched by any reweighting of the BSGS side. Its optimum is also
exactly `1/5`.

**⇒ `1/5` is OVERDETERMINED: two independent balances both yield exactly `1/5`.**
**Raising `Σw: 3/2 → 2` moves row 1 to `1/6` and leaves row 2 at `1/5` — measured, the
`1/6` claim is missed by EXACTLY `1/30`.**

## 2. The five terms, from Harvey's displayed equations (read off page IMAGES)

| # | term | cost | source |
|---|---|---|---|
| **T1** | **screen** | **`(N/r)^{1/4} lg³ N`** | p.12 Alg 4.3 Step 2 + Prop 2.5 (p.6) — **the omitted row** |
| T2 | large-order | `N^{1/5} lg² N` | p.12 Step 3, Prop 2.7 — `D := ⌈N^{2/5}⌉` **fixed, no free parameter** |
| T3 | pairs | `r lg³ N lg lg N` | p.11: *"The number of pairs `(a,b)` … is `O(r lg r)`"* |
| T4 | interior | `N^{1/2}/(r^{1/2}m) lg⁴ N` | p.10 Prop 4.2 |
| T5 | baby | `m lg² N` | p.10 Prop 4.2 |

**`M = (N/r)^{1/2}` is FORCED, not chosen:** Lemma 3.3's hypothesis (3.1) requires
`(N/r)^{1/2} ⩽ p`, so the Lehman search at parameter `r` is invalid until smaller
factors are excluded.

## 3. The corrected design rule

`beating_one_fifth_requires` (`Σw > 3/2` **OR** `γ < 1/2`) is **correct for row 1** and
**necessary-not-sufficient for the algorithm**:

> **For target `e`: row 1 needs `Σw ⩾ γ₁/e − 1`, AND row 2 needs `θ ⩾ 2e/(1−e)`.**

| target | row 1 `Σw` | row 2 `θ` | Harvey supplies |
|---|---|---|---|
| **1/5** | 3/2 | 1/2 | ✓ both |
| **1/6** | **2** | **2/5** | ✗ ✗ |
| **1/8** | **3** | **1/3** | ✗ ✗ |

**Closure, not construction — no slack was found, and under Harvey's mechanism there
is none to find.**

## 4. ★ Corroboration inside Harvey's own parameters

At Harvey's published `r := ⌈N^{1/5}/lg^{4/5}N⌉`, `m := ⌈N^{1/5}lg^{6/5}N⌉`,
**FOUR of five terms co-bind** at exactly `N^{1/5}lg^{16/5}N`. **The `lg` corrections
exist precisely to co-bind the max** — direct evidence the design is a **FOUR-WAY**
balance, not the three-term shape the design rule assumes.

## 5. ⚠️ Errors, prominently

1. **The screen's `lg` exponent was wrong by a factor 2** — and in `exp_closure.py`
   that made **the closure claim FALSE** (it reported `1/6` reachable).
2. **The Alg 4.2 implementation factored 0 of 8 semiprimes while printing a clean
   table** — `a·isqrt(N)` where eq. (4.1) is `α^{aN+b−⌈(4abN)^{1/2}⌉}`. **A clean
   table over an empty result is the "vacuous test that prints PASS" failure.**
3. **A prediction failed and was kept visible** (`P8`) rather than re-run until it
   passed.
4. **`pdftotext` was trusted nowhere** — every quotation read off a rendered image,
   because the tool silently flattens exponents and this round IS exponents.

## 6. NOT settled

Whether row 2 is **escapable** — it **pins** `1/5`, but that is not the same as
**unavoidable**. Also: Harvey's published Math. Comp. version unread (arXiv v1 only);
`[HW08]`/`[Hit20]`/`[Hit18]` unread; and **whether `finset_barrier_attained_log`
transfers to Harvey's cost — his terms carry DIFFERENT `lg` powers (`lg³` vs `lg²`)
where the Lean file assumes a single `c`.** Flagged, not resolved.

## 7. What this changes

**The `Σw > 3/2` question is RETIRED — answered as a closure stronger than the
question.** The single-scalar framing **priced one row of a two-row design.** Reaching
`1/6` needs **two independent knobs**, one of which (`θ`) is **outside the weight
framework entirely** and has no known improvement.
