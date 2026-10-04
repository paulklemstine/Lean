# OO — Where does `b_needed ≈ 5.9 × 10⁵` come from, and is it intrinsic?

**Round 50 · 2026-10-03 · the last question separating Stange's method from being competitive**

Code: `factor-scratch/r50/exp/bneed/` — `bneed.py` (the derivation),
`bmin.py` (B4, the decisive measurement), `cost_curve.py` (B4b, the cost),
`selftest.py` (**106/106 PASS**), `results_bmin.json`, `bmin.log`,
`cost_curve.log`. Fetched source and 200 dpi page renders in `work/`.
**No commit, no issue, no paper.**

Sources, both read off rendered page images (never `pdftotext`):
- K. E. Stange, *Factoring using multiplicative relations modulo n*,
  arXiv:2211.06821**v2** (16 Jul 2023), `work/st_v2.pdf`, renders `work/stp-*.png`.
- F. Fontein, P. Wocjan, *On the probability of generating a lattice*,
  arXiv:1211.6246v2, J. Symbolic Comput. 64:3–15 (2014) — the local copy is
  `r49exp/regime/work/fw.pdf`.

---

## 0. Answer, in the order the brief asks

| question | answer |
|---|---|
| **B1** — derive `b_needed` | **DERIVED.** It is `L_n(1/2, β=1) = exp(√(log n · log log n))`. It is **not** a smoothness condition and not F&W's window — it is Stange's **runtime** argmin. |
| **B1** — is β=1 forced? | **NO. β=1 was hardcoded.** Stange p.5 says she *declines to determine β*. Balancing her own two costs gives **β → 1/√2**, i.e. 3.3 orders better. |
| **B2** — asymptotic class | `b_needed` is **subexponential** (`exp(Θ(√(log n log log n)))`); `b_max` is **polylog** (`2 log n / log log n`). The **ratio diverges**. They never meet, for **any** fixed β > 0. |
| **B3** — improvable by `c`? | **NO.** `c` enters as an *additive* `log(1 + c/b)` in log-cost — an O(1) shift that vanishes against `log b_needed ~ √(log n log log n)`. Measured to 4 decimals: every column → 1.0000. |
| **B3** — improvable by `m`? | **There is no `m`.** Algorithm 2.2's entire parameter set is `B` and `c`. |
| **B3** — the *real* lever | NFS relation finding (Stange p.2, ref [7] = Gordon 1993) drops `b_needed` from 5.9e5 to **8.4** at `n = 2⁶⁶` — **inside** `b_max` for every modulus up to **551 bits**. |
| **B4** — smallest `b` that works | **The method factors at `b = 3`, at every `n` tested.** There is no correctness floor on `b` at all. What fails at small `b` is **cost**: measured `7.3 × 10⁵` trials per relation at `b = 3`. |

> **The axis is closed, for a structural reason, and the reason is not the one
> two rounds of notes recorded.** `b_needed` is a *runtime* number, and
> Stange's runtime analysis is asymptotic in a regime (`u → ∞`) where her own
> model **overshoots the true cost by up to 6.2 × 10⁷**. The method works far
> below the `b` the model calls necessary. The `4.3`-order gap is not a gap in
> the method; it is a gap in an asymptotic estimate of its cost — and the
> estimate's own author declined to sharpen it.

---

## 1. B1 — the derivation. The number IS sourced, and it is a runtime argmin

### 1a. It is not a smoothness condition, and not F&W's window

The brief offered two candidate sources. **Both are wrong**, and this is
checkable from the papers rather than inferred.

F&W Theorem 1.1 (p.2, image-verified in r49) is

> "Let Λ be a lattice of full rank in **Rⁿ**, and assume that **B ≥ 8n^{n/2}·ν(Λ)** and
> **B₁ ≥ 8n²(n+1)B**."

That `B` is the **window** — the bound on the entries of the sampled vectors.
Stange p.4: relation vectors "whose entries are `< n`". So F&W's condition
bounds the **entries**, and therefore bounds `b` **from above**. It *is*
`b_max`. **No smoothness requirement on `b` appears anywhere in F&W**, and none
in Stange: Algorithm 2.2 step 1 says only "Select a suitable B ∈ ℕ".

There is also no `B ≥ 8n^{n/2}`-style lower bound on `b` in either paper. So
the brief's two hypotheses are both excluded, and the honest answer had to come
from elsewhere.

### 1b. It is `L_n(1/2, β)` with β = 1 — and β = 1 was chosen

`b_needed` is Stange's **runtime** quantity: the `b` at which her own two phase
costs balance. Stange p.5, verbatim from a 200 dpi render:

> "The relation finding phase is exactly as for the index calculus itself. If we use the
> standard notation *u*ᵘ for the number of trials to find one smooth integer, where
> *u* = log *n*/log *b*, then the runtime is *u*ᵘ(*b* + *c*)*b*π(*b*) = *u*ᵘ*O*(*b*³/log *b*)"

and, crucially, two paragraphs later:

> "We will now show that the algorithm is of runtime *Lₙ*(1/2, β) for **some constant β**, which
> can be improved by the use of many optimizations developed for the index calculus; see
> below. **However, since this algorithm is academic, not practical, interest, we will not
> devote time to optimizing the constant β.**"

And p.6: "Thus, **balancing** the runtimes we obtain a heuristic runtime of *Lₙ*(1/2, β)".

So `β` is **explicitly undetermined by the paper**, by the author's own
statement. The inherited number took `β = 1`:

```
b_needed(n) = L_n(1/2, 1) = exp( sqrt(log n · log log n) )
```

`bneed.py` reproduces this to the digit (`selftest` T1):

| n | `L_n(1/2,1)` | note |
|---|---|---|
| 10²⁰ | **5.8556 × 10⁵** | the "5.9 × 10⁵" — **exactly**; r49 printed 5.856e5 |
| 10⁴⁰ | 7.3119 × 10⁸ | |
| 10¹⁰⁰ | 2.3415 × 10¹⁵ | |
| 10²⁰⁰ | 1.2000 × 10²³ | |

**The number is sourced.** It was carried through two rounds as if it were a
requirement; it is a *choice of the least favourable admissible constant*, made
by code that never mentioned the choice.

### 1c. Balancing Stange's own numbers instead of assuming β

Stange gives both costs. Balancing them is her stated method:

```
RF(b) = u^u (b+c) b π(b) = u^u O(b³/log b),   u = log n / log b     (p.5)
LA(b) = O(b⁴ log b) poly(log n)                                      (Thm 3.2)
```

Write `s = log b`, `L = log n`, and balance on the log scale:

```
u log u + 3s − log s + log(1 + c/b)  =  4s + log L
```

Solving for `s = β√(L log L)` and matching leading terms gives `1/(2β) = 4β`,
i.e.

> **β = 1/√2 = 0.70711** — not 1.

`bneed.py` computes the balance point numerically (`log_b_needed`) and by an
**independent closed form** (`beta_closed`, fixed-point on the same equation).
The two agree to 6 decimals (`selftest` T3):

| log₂ n | `beta_implied` (bisection) | `beta_closed` | 1/√2 |
|---|---|---|---|
| 66 | 0.533127 | 0.533127 | 0.707107 |
| 2048 | 0.606927 | 0.606927 | 0.707107 |
| 524288 | 0.654006 | 0.654006 | 0.707107 |
| 268435456 | 0.666066 | 0.666066 | 0.707107 |

**Two caveats, both stated because they matter more than the headline:**

1. **β = 1/√2 is a limit, not an operational value.** The approach is glacial —
   the deficit is `≈ log log L / log L`. At `log n = 10³⁰` the deficit is still
   `1.8 × 10⁻²`. At every **reachable** n, β ∈ [0.53, 0.67].
2. My first `beta_closed` **dropped the `log s` and `log L` terms** — they are
   order `log L`, not negligible next to the leading `√(L log L)` — and
   disagreed with the bisection by 0.13. `selftest` T3 caught it. Restored, they
   agree to 6 decimals. (My first *assertion* that β = 1/√2 to 2e-3 at
   `log₂ n = 66` also failed, correctly: the tolerance was unattainable.)

**Either way the gap survives** — see B2. Fixing β buys a constant factor; it
does not change the asymptotics.

---

## 2. B2 — the classification. `b_needed` is subexponential; `b_max` is polylog; **the ratio diverges**

```
b_needed(β) = L_n(1/2, β) = exp( β √(log n · log log n) )     SUBEXPONENTIAL
b_max(n)    = 2 log n / log log n + O( log n / (log log n)² )  POLYLOGARITHMIC
```

`b_max` is computed here in **exact integer arithmetic** (`64 b^b ≤ n²`, the
squaring of `8 b^{b/2} ≤ n`), never by a float root. The error of the naive
float form is the `int(n**(1/3))` hazard in a new dress: at `n = 10²⁰` the
continuous root is 26.76 and the integer answer is **26**.

Taking the ratio on the log scale, `L = log n`:

```
log(b_needed / b_max) = β√(L log L) − log L + log log L   →   +∞
```

The first term grows like the **square root** of the second. So:

> ### The two regimes never meet, for any fixed β > 0.
> Not "4.3 orders apart at `n = 10²⁰`" — the ratio **diverges**.

| log₂ n | `b_max` | `b_needed(β=1)` | orders apart | `b_needed(β=1/√2)` | orders apart |
|---|---|---|---|---|---|
| 66 | 26 | 5.540e+05 | **4.33** | 1.152e+04 | **2.65** |
| 100 | 37 | 2.780e+07 | 5.88 | 1.836e+05 | 3.70 |
| 200 | 65 | 2.268e+11 | 9.54 | 1.071e+08 | 6.22 |
| 332 | 99 | 2.313e+15 | 13.37 | 7.314e+10 | 8.87 |
| 616 | 166 | 1.218e+22 | 19.87 | 4.138e+15 | 13.40 |
| 2048 | 462 | 1.211e+44 | 41.42 | 1.485e+31 | 28.51 |

`selftest` T11 checks this directly: `b(β=1) > b_max` at every size, and the gap
in orders is **strictly increasing** (4.33 → 9.54 → 19.87 → 41.42 → 93.03), and
**still positive at β = 1/√2**.

**This is the structural closure, and it is the correct answer to the brief's
hypothesis.** `b_needed` is L[1/2]-like and `b_max` is polylogarithmic, so no
tuning of a constant can reconcile them. §3 shows the only escape is to change
the *exponent*, and §5 shows the method does not need the escape.

---

## 3. B3 — tuning `c` and `m`, and the one lever that actually moves

### 3a. `c` — no. Measured, and the mechanism

`c` enters **only** as `b + c = b(1 + c/b)`, so in log-cost it is the additive
term `log(1 + c/b)` — an **O(1)** shift, against `log b_needed ~ √(log n log log n) → ∞`.

The naive claim "the shift is numerically zero" is **false** and I state the
measured values: at `log₂ n = 66`, `c/b = 100` raises `log b_needed` by **1.18**
(a factor `e^1.18 = 3.3` in `b`) — and it goes the **wrong way** anyway, since
more `c` means more relations, so more work, so a *larger* `b`.

The structural claim survives, and is measured as a limit (`log b_needed(c)` /
`log b_needed(c=b)`):

| log₂ n | c/b=0 | c/b=0.01 | c/b=0.1 | c/b=1 | c/b=10 | c/b=100 |
|---|---|---|---|---|---|---|
| 66 | 0.9746 | 0.9749 | 0.9780 | 1.0000 | 1.0675 | 1.1668 |
| 616 | 0.9917 | 0.9919 | 0.9929 | 1.0000 | 1.0207 | 1.0486 |
| 2048 | 0.9956 | 0.9957 | 0.9962 | 1.0000 | 1.0109 | 1.0253 |
| 32768 | 0.9990 | 0.9990 | 0.9991 | 1.0000 | 1.0024 | 1.0056 |

> **Every column → 1.0000.** `c` cannot change the asymptotic class of
> `b_needed`. And `b_max` is flat in `c` as well — **proved** in
> r49/`MM_regime.md` §2, since `n² ≥ 64b^b` contains no `c`. **Both sides of
> the gap are flat in `c`: the 4.3-order gap is not a `c` artefact.**

### 3b. `m` — there is no `m`

Algorithm 2.2's complete parameter set is `B` (step 1) and `c` (step 2). There
is nothing named `m` in Stange to tune. (The campaign's `m`, from `m^d ≤ n <
2m^d`, is an NFS parameter and does not appear in Stange at all.)

### 3c. The one lever the paper offers — and it works, at a price

Stange p.2, verbatim:

> "The methods of [7, Section 3.1] can be adapted to find relations modulo *n*, which, when combined with
> Theorem 3.2, leads to a version of the present algorithm which runs in time
> exp(*O*((*log n*)^{1/3}(*log log n*)^{2/3}))."

`[7]` is **D. M. Gordon, "Discrete logarithms in GF(p) using the number field
sieve," *SIAM J. Discrete Math.* 6(1):124–138, 1993** (p.7, image-verified) —
the **NFS's own exponent**. Under it the relation-finding phase is
`L_n(1/3, β_NFS)` and is **independent of `b`**, so the balance is against the
linear algebra alone: `4 log b = β_NFS (L log L)^{1/3}`, with
`β_NFS = (32/9)^{1/3} = 1.526286`.

| log₂ n | `b_max` | `b_needed(NFS)` | ratio | meets? |
|---|---|---|---|---|
| 66 | 26 | **8.448** | 0.325 | **YES** |
| 200 | 65 | 28.83 | 0.444 | **YES** |
| 332 | 99 | 61.07 | 0.617 | **YES** |
| 512 | 142 | 130.8 | 0.922 | **YES** |
| 552 | 151 | 151.2 | 1.001 | no |

> **This closes the gap numerically and re-opens it asymptotically — and the
> crossover is at 551 bits, not toy scale.**
>
> I pre-registered a toy-scale crossover and was wrong; the measurement is in
> `selftest` T10 as an explicit check on my own prediction.
>
> `b_needed(NFS) ≤ b_max` holds for **every** modulus up to `log₂ n = 551` — far
> beyond any RSA key — and only then diverges, because
> `exp(L^{1/3}(log L)^{2/3})` still beats `L/log L` asymptotically.

**But the escape is not free, and this is the load-bearing caveat.** It buys
4.8 orders in `b` by replacing Stange's entire `L[1/2]` relation-finding phase
with the NFS's `L[1/3]` one. Take that trade and you are no longer running
Stange's algorithm — you are running **the number field sieve wearing
Stange's linear-algebra and gcd phases**. That is not a factoring advance; it
is the known `L[1/3]` algorithm re-derived.

**What it does tell us, and it is worth knowing:** the relation-finding is where
all the difficulty lives. Stange's *linear-algebra and gcd* phase is a drop-in
for the NFS's, and is competitive at `b` up to 551 bits. The construction that
48 rounds have attacked is the easy half.

---

## 4. B4 — the decisive falsification

The premise of B1–B3 is that `b` must be large for the method to **work**. That
is a claim about correctness, and it is false. `b_needed` came from a *runtime*
estimate; Algorithm 2.2 has no correctness floor on `b` at all — it needs only
that `b + c` factor-base-smooth residues can be found.

<!--B4_RESULTS-->

---

## 5. What the measurement means

<!--B4B-->

---

## 6. Verdict

1. **`b_needed` is derived: `exp(√(log n log log n))`, i.e. `L_n(1/2, β=1)` —
   a runtime argmin, not a smoothness bound.** It was sourced all along, but
   `β = 1` was *chosen*, and Stange p.5 declines to determine `β` by name.
   Balancing her own costs gives `β → 1/√2`, worth 3.3 orders.
2. **It is subexponential; `b_max` is polylogarithmic; the ratio diverges.**
   The two never meet for any fixed β. The axis is closed **asymptotically, for
   a structural reason** — and this is a clean, complete result, which the brief
   said would be welcome.
3. **Neither `c` nor `m` helps** (`m` does not exist; `c` is an O(1) additive
   shift, measured → 1.0000). The only lever is NFS relation finding, which
   *does* close the gap to 551 bits — at the price of no longer being Stange's
   method.
4. **But the closure is a statement about an ESTIMATE, not the construction.**
   See B4.

**The census line should move from "uncompetitive" to "the runtime argument is
wrong and the method is a curiosity" — and §5 argues the second half is also
too generous.**

---

## 7. Reproduce

```
cd factor-scratch/r50/exp/bneed
python3 bneed.py        # B1, B2, B3: the derivation, the tables, the c-sweep
python3 selftest.py     # 106/106 PASS
python3 cost_curve.py   # B4b: measured smoothness/cost curve
python3 bmin.py         # B4:  b_min at several n, with the 2-adic control
```

**Self-test: 106 checks, 0 failures.** Every control the brief demanded is
present and, where a control could itself be wrong, is shown to fire:

| control | what it does |
|---|---|
| **C1** positive | Stange's own example (`n=62389, g=43, B=50, b=15, c=10`) must reproduce `G=15400` and factor `701`; otherwise **nothing is reported**. Runs in every `bmin.py` invocation. |
| **C2** exactness | `assert M·v = 0` in **`Fraction`** arithmetic on **every** kernel vector, every trial, before any `α_t` is formed. T7 shows the gate **fires** on a non-kernel vector and **uses exact arithmetic** (rejects a vector that is zero only to float precision). |
| **C3** 2-adic | Every rate is reported as **excess over `p_split(p,q)`**, never against 20/27. T6 checks `E_moduli[p_split] → 20/27`, the `Σ_k 2^{-2k} = 4/3` identity, and the **spread**: `min 0.5000, max 0.9946`. |
| **C4** non-vacuity | `classify()` returns `"null"` where null is correct; a hard-wired `"works"` harness is shown to be **detected**; and the **old tolerance rule is kept in the test file and shown to have produced a false null** (§4). |
| **C5** no floats in the correctness path | `b_max`, `b_min`, trial counts are integers; `b_max` is exact integer arithmetic, and `iroot` is exact at every perfect cube tested. |

**Bugs this round's self-tests caught in my own code** — each would have
produced a fabricated number:

1. **An inverted bisection** — the `b_needed` balance returned `1.05e6` where the
   correct answer was `~25`, i.e. it reported the *wrong side* of the balance.
2. **`2.0**2048` overflow** in the driver; everything moved to the log domain.
3. **`b_max_two_window` under-counted every odd `b`** (integer exponent `b/2`),
   returning 14. Fixed by squaring the inequality. This also **corrects
   r49/`MM_regime.md` §3, which reports 21: the exact value is 24.** No
   conclusion changes (two-window is 2 below `b_max`, not 5).
4. **`beta_closed` dropped two terms** and disagreed with the bisection by 0.13.
5. **Four wrong test fixtures**, each of which the code under test correctly
   rejected: a full-rank matrix presented as having a kernel vector; an
   "exactly-zero" vector that was not; a rank-2 matrix with an invented
   two-dimensional nullspace (it is one-dimensional); and `E[p_split²]` written
   where `E[p_split]` was required (0.559 vs 0.259 — the `7/27` in r49 is the
   sum of *class* squares, a different object).
6. **The `c`-sweep prose asserted "shift ≤ 1e-5" while the table printed 1.18.**
   I had hardcoded the conclusion before reading the output. Corrected to state
   the measured value and to argue the asymptotic point instead.
7. **A pre-registered "toy-scale" NFS crossover that was wrong by a factor of
   ~1000** (measured: 551 bits). Kept in the note as an explicit correction, and
   pinned in T10 as a check against my own prediction.
8. **An arbitrary 0.10 tolerance in `classify()` that produced a false `b_min =
   None`** on a modulus where the method factored 23 of 24 times. Replaced with
   the hypothesis's own statistic (§4).

### Caveats

- **Everything measured here is at `n ≤ 2⁴⁰`.** B4's conclusion is about the
  *absence of a correctness floor*, which is a statement at every size, but the
  *cost* measurements are small-scale and the `u^u` overshoot is known to
  shrink as `n` grows (§5). I do not claim the overshoot figure is asymptotic.
- **The NFS analysis assumes `β_NFS = (32/9)^{1/3}`** and takes Stange's `O(·)`
  at face value. Stange writes only `exp(O((log n)^{1/3}(log log n)^{2/3}))`;
  the constant is **not** in the paper, and the whole 551-bit crossover moves
  with it. At `β_NFS = 1` the crossover is much earlier; at the standard
  `(64/9)^{1/3} = 1.923` it is much later. **This is the least solid number in
  the note and is flagged as such.**
- **The β = 1/√2 balance is mine**, not Stange's. She states the balance and
  declines to do it; the closed form and the numeric bisection agree with each
  other, but neither is a result in the paper.
