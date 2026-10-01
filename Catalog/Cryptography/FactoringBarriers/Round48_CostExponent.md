# Round 48 — the cost exponent: N^0.534 ± 0.029, measured with 324 uncensored runs

**2026-09-30. This supersedes the previous round's conclusion that the method is dead, and
itself supersedes two of my own intermediate claims from the same day.**

Compute was stopped here — the host was at load ~190 on 16 cores and this campaign was the
cause. Full working files live outside the repo in `~/factor47/` (`SETTLEMENT.md`, `V4/`,
`V5/`, `V6/`).

---

## 1. The headline

The construction **factors real semiprimes**. Over 24→42 bits, using **stopping times** (scan
until the first `χ_P = −1` relation, record the `m`):

```
324 runs, 1.597e7 m-scans
0 censored, 0 spurious, 0 trivial, 323 real factors out of 324

log2(cost in m-scans) = -4.04 + 0.534 * bits
cost ∝ N^0.534          se 0.029   chi2/dof 6.9   2se = [0.476, 0.593]
```

Plus independently verified factors at 48 and 52 bits. Sub-ranges: 24–40 → 0.526,
**24–42 → 0.534**, 30–42 → 0.652, 36–42 → 0.535, 24–44 → 0.469.

**⚠ CORRECTION (2026-10-01). An earlier version of this document claimed that `α < 1` makes
this "polynomial-time factoring". That is a category error and is withdrawn.**

The input length is `b = log₂N`. A cost of `N^α` is `2^{αb}` — **exponential in `b`** for every
`α > 0`. Polynomial time means `poly(b)`, not `poly(N)`. Every cost here is exponential; a
smaller α is just a smaller exponential.

This inverts the comparison. The best **rigorous probabilistic** bound is `L_N[1/2,1]`
(Lenstra–Pomerance 1992), `exp(√(ln N · ln ln N))`, and the best **rigorous deterministic** is
`N^{1/5+o(1)}` (Harvey 2021, arXiv:2010.05450). **Both are faster than `N^0.534`.** Comparing
against GNFS was also the wrong target: GNFS is the heuristic best, while `L_N[1/2,1]` is both
faster *and* proven.

α = 0.534 remains a correct measurement. What it does *not* support is any claim of
polynomial-time factoring.

Separately, **the method is prior art**: Kameswari–Prasamsa–Kantham, *"Factorization via
Difference of Squares using Ambiguous Forms"*, IOSR J. Math. 12(5):19–29 (2016), publishes the
same pipeline — scan from the 1/3 power, gate on an exact square. This campaign's contribution
is a genus-1 form substituted for a genus-0 one.

This is stated plainly because the previous round asserted the opposite and used the
assertion to dismiss inconvenient data. Two of my own intermediate claims this day did the
same. That was the recurring methodological failure, not a slip.

---

## 2. Why three different exponents appeared

Budgeted rates gave 0.71, stopping times 0.53, complete-scan totals 1.0. **These were never
contradictory — they measure different things**, and one formula covers all three:

```
rate(M,N) ≈ 22·H·g(M) / √(N·M)        cost = √(N·M) / (22·H·g(M))
exponent  = 1 − ½·dlog g / dlog M
```

Everything reduces to **one saturation factor `g`**:

| regime of `g` | growth | cost exponent |
|---|---|---|
| saturated | `g` = const | **1.0** |
| ladder regime (measured 24→42) | `g ~ N^0.45` | **0.53** |

Back-solving `g = N/(22·H·T)` from the ladder: **35.5 at 24 bits → 12,430 at 42 bits.** The
complete-scan ladder sees `g` saturated at ≈29 with the total plateauing at **1.07×10⁴**
(b = 10…28: 1021, 1753, 2761, 3566, 4926, 6643, 7372, 8602, 10184, 10678 — last increment 494
against 1582 the step before).

**The open question is exactly: how fast does `g` grow, and where does it stop?** One scalar.

---

## 3. Corrections to the record

**The GNFS anchor was wrong by 8.6×10¹⁰.** The previous round reported
`GNFS(128) = 6.8e8` core-seconds — 21.5 core-years to factor a 128-bit semiprime, which
factors in milliseconds. Correctly anchored (`K = 5.8559e-13`, fixed by RSA-768 at 2000
core-years, checked against RSA-250 and RSA-1024) the model tracks real GNFS records to ~10³.
**Both prior headline claims — "faster than GNFS through 64 bits" and "~1.3×10⁴× cheaper at
128 bits" — are void.**

**The box is not the algorithm's population.** Supply in the box (`m ~ N^(1/3)`, `c` in a
16-value hand-picked pool) is exactly `C·N^(−1/6)`, but the box overstates a scanned
instance's relation rate by **47× (24 bits) to 326× (32 bits)**, and its `χ_P = −1` fraction
is ~79% against the scan's ~23%. Every supply number in Rounds 45–47 is a box number; none is
a rate for the algorithm.

**Square density is false.** `l(m)` is not a random integer. Treating it as one is off by
**99–157×, essentially all of it 2-adic**, and changes `T(M)` from `M^0.50` to `M^0.70`. My
algebraic derivation (`ALGEBRAIC_EXPONENT.md`, in `~/factor47/V4/`) rests on this assumption
and is wrong; its functional form and budget arithmetic survive, its exponent does not.

**Lowering `H` is counterproductive.** At 28 bits, `f_chi` ≈ 0.21–0.26 for `H ≤ 12` against
~0.75 at `H = 40`. `H = 8` scans 9× faster and is **2× worse per usable relation**. The ladder
is locked to `H = 40`; there is no cheap lever to extend it.

**Vacuous instances.** For `m < N^(1/3)`, `c = m³` unreduced and `m³ − c = 0` — a root over ℤ,
not ℤ/Nℤ. One run produced **78,320 relations of which zero had `χ_P = −1`.**

**A null-relation family, verified.** `u = −t`, `c = (2t/v)³ ⟹ l = 36t⁴ = (6t²)²`, constant
in `m`, `χ_P = +1`, never a factor. 54 triples, 0 failures; `c ∈ {1,8,27,64,125,216}`, none of
which are in CPOOL.

---

## 4. Two errors the instruments made, both of which bent the exponent

Recorded because they are the exact defect class of this campaign.

- **Stale base in the incremental cubic.** Computing `c` from closed form `(m₀+i)³` while
  advancing the recurrence to `m₀+B` made chunk 1 correct and every later chunk wrong.
  Symptom: one `N` reported `rel=3322 chi=1675 trivial=1675` — a **100% trivial rate** — while
  other `N`s factored in under 512 scans. Only `c(m) == pow(m,3,N)` caught it.
- **Wrong denominator for `1/λ`.** `sum(TRIALS)/sum(chi)` on stopping-time runs, where
  `TRIALS` is quantised to chunks of 1024, overstated short runs ~2× and **flattened the
  exponent from ~0.6 to ~0.49.**

And one of mine: **`scans/FACTOR = TRIALS/2` read as a cost exponent.** Every run in the
budgeted set found exactly 2 factors and consumed its whole allocation, so the "cost" was the
budget schedule. I published `N^0.85` from it before noticing.

---

## 5. What is not established

1. **Whether α = 0.53 is asymptotic.** No measurement above 52 bits; n = 2 at 48 and 52, and
   the 48-bit pair spans 3.5× on its own. The 30–42 fit (0.652) against the wide fits
   (0.47–0.53) is range-dependence of unknown origin — it is `g`'s growth, unresolved.
2. **`g(M)` beyond 42 bits.** The measurement that would settle §2, not made. It is cheap —
   counting *all* relations in a controlled-length scan is an O(1)-event measurement — but the
   host was saturated before it ran.
3. **Whether a non-depressed short relation converts to a square relation.** If it does, the
   selector barrier dissolves and the whole cost model changes. Worked by an agent; **not
   audited.**
4. **Prior art — settled, and it is not new.** Kameswari–Prasamsa–Kantham, *"Factorization via
   Difference of Squares using Ambiguous Forms"*, IOSR J. Math. 12(5):19–29 (2016), publishes
   the same pipeline. **Correction to an earlier version of this document:** Blömer–May is
   **EUROCRYPT 2005, pp. 251–267, DOI 10.1007/11426639_15**, *A Tool Kit for Finding Small
   Roots of Bivariate Polynomials over the Integers* — not "CRYPTO LNCS 2132:4–19 (2001)".
   Coppersmith 1997 (`J. Cryptology` 10(4):233–260) is correct.
5. **No known hardness result.** No published work establishes that finding a small
   representative of `m^k mod N`, `k ≥ 2`, is as hard as factoring. Stated caveat: AMS,
   ScienceDirect, ACM, Semantic Scholar, dblp and CORE were unreachable, so this is a negative
   over the reachable indexes, not a universal one.
6. **Coppersmith's domain is provably disjoint from this scan range.** Theorem 3 with
   `f(x)=x³−c`, `d=3`, guarantees all roots `|m| ≤ N^{1/3−ε}` — strictly inside `m < N^{1/3}`,
   which is exactly the vacuous region measured here (`c = m³` unreduced, `m³−c = 0`). The
   scan begins precisely where the theorem stops guaranteeing anything.

---

## 6. Do not restart the ladder

Waiting for a factor is a **rare-event** measurement and starves above ~44 bits; that is why
48/52 produced n = 2. The right instrument is `g(M)`: count **all** relations over a scan of
controlled length `M`, at several `N`, fit `dlog g/dlog M`, find the plateau. One scalar,
O(1) events, cheap at any size, and every open question above follows from it.

---

## 7. The two rules that would have caught everything

> **Never report cost-per-factor from a run that stopped at its budget.** Record the stopping
> time.

> **Print what population produced the number, next to the number.** A rate is always a rate
> *of something*.

Nine-plus defective results in the previous round and four more this one were **all a
measurement of the wrong population made to look rigorous by exact arithmetic**: nine vacuous
controls; a base rate of 0.88 used where the valid rate was 0.21; a probability keyed on `m`
instead of `(m,c)`; the GNFS anchor off by 8.6×10¹⁰; a "1900/√N ceiling" from a scan silently
restricted to `c ∈ CPOOL`; vacuous instances inflating totals 15×; a budget-schedule read as
a cost exponent.

And twice I asserted "it cannot be polynomial" and used the belief to explain away data. **An
assumption about the world is not evidence about the world.**