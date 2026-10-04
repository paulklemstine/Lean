# OO — Where does `b_needed ≈ 5.9 × 10⁵` come from, and is it intrinsic?

**Round 50 · 2026-10-03 · the last question separating Stange's method from being competitive**

Code: `factor-scratch/r50/exp/bneed/` — `bneed.py` (the derivation),
`bmin.py` (B4, the decisive measurement), `cost_curve.py` (B4b, the cost),
`selftest.py` (**116/116 PASS**), `results_bmin.json`, `bmin.log`,
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
| **B4** — smallest `b` that works | **The method factors at `b = 3` at every completed modulus.** There is no correctness floor on `b` at all. What fails at small `b` is **cost**: measured `1.35 × 10⁶` trials per relation at `b = 3`, `n = 2²⁹`. |

> **The axis is closed, for a structural reason, and the reason is not the one
> two rounds of notes recorded.** `b_needed` is a *runtime* number, and
> Stange's runtime analysis is asymptotic in a regime these experiments do not
> inhabit. The method works far below the `b` that number calls necessary —
> **`b_min = 3` against a `b_needed` of 50–60 at the same `n`.** The
> 4.3-order gap is not a gap in the method; it is a gap in an estimate of its
> cost, and the estimate's own author declined to sharpen it.

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

And the balance point itself — **this is the number B4 is measured against**:

| log₂ n | `b_max` | `b_needed(β=1)` | **`b(balance)`** | `β_bal` | orders saved |
|---|---|---|---|---|---|
| 20 | 10 | 4.188e+02 | **24.81** | 0.53190 | 1.23 |
| 40 | 17 | 1.473e+04 | **158** | 0.52746 | 1.97 |
| 66 | 26 | 5.540e+05 | **1 154** | 0.53313 | 2.68 |
| 200 | 65 | 2.268e+11 | **2.092e+06** | 0.55659 | 5.04 |
| 616 | 166 | 1.218e+22 | **7.55e+12** | 0.58310 | 9.21 |

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
is a claim about correctness, and it is **false**. `b_needed` came from a
*runtime* estimate; Algorithm 2.2 has no correctness floor on `b` at all — it
needs only that `b + c` factor-base-smooth residues can be found.

**Measured, with the 2-adic control on every cell.** `N = 24` trials per cell
(16 at `2³⁹`); each cell reports its own `p_split(p,q)` and the one-sided
binomial p-value for a *shortfall* against it.

| n | `(p, q)` | `p_split` | `b_max` | `b_needed` | **`b_min`** | `b_min / b_needed` |
|---|---|---|---|---|---|---|
| 2²⁷ = 110637763 | 12517 · 8839 | **0.7500** | 12 | 49.7 | **3** | 0.060 |
| 2²⁹ = 450570773 | 18773 · 24001 | **0.9766** | 13 | 60.0 | **3** | 0.050 |
| 2³¹ = 1770089357 | 50069 · 35353 | **0.8125** | 14 | 72.1 | **3** | 0.042 |
| 2³³ = 7202859029 | 75029 · 96001 | **0.9941** | 15 | 86.3 | **3** † | 0.035 |

*(Four completed cells, `b_min = 3` in every one. `b_needed` is the
balanced-`β` value from §1c — the *favourable* estimate; against the inherited
`β = 1` the discrepancy is larger still. **†** the `2³³` cell's `b = 3` row has
`N = 1`: at 4.9 × 10⁶ trials/relation the cap truncated it, so that one cell
is weak evidence on its own — but see the `b = 5` row below, which is `N = 24`
at the same modulus and is at ceiling.)*

> ### `b_min = 3` at every completed modulus — no correctness floor on `b`.
>
> The method factors with a **3-prime factor base** (`{2,3,5}`, `B = 5`) at
> every size tested. **`b_needed` overstates the smallest usable `b` by a
> factor of 17–30** at these `n` (49.7/3 = 16.6 at `2²⁷` up to 86.3/3 = 28.8 at
> `2³³`), and the discrepancy is a property of the *estimate*, not of the
> construction.

**The `p_split` column is the load-bearing control and it is doing real work
here.** Across the four moduli `p_split` ranges **0.750 → 0.813 → 0.977 →
0.994**. Had I compared these fixed-`n` rates against the campaign's
`20/27 = 0.7407`, the `2²⁹` modulus would have shown a spurious excess of
**+0.22** and the `2³³` modulus **+0.25** — both **entirely the modulus's
2-adic structure** (`v₂(q−1)` = 6 and 8 respectively). The per-modulus excess
is what the method contributes, and it is consistent with **zero** everywhere:

| n | `b` | N | rate | `p_split` | excess (Wilson 95%) | one-sided `p` | mean trials/rel | verdict |
|---|---|---|---|---|---|---|---|---|
| 2²⁷ | 3 | 24 | 0.833 | 0.750 | (−0.109, +0.183) | 0.885 | 672 405 | works |
| 2²⁷ | 5 | 24 | 0.667 | 0.750 | (−0.283, +0.070) | 0.234 | 128 322 | works |
| 2²⁷ | 8 | 24 | 0.708 | 0.750 | (−0.242, +0.101) | 0.393 | 35 158 | works |
| 2²⁷ | 11 | 24 | 0.625 | 0.750 | (−0.323, +0.038) | 0.121 | 13 142 | works |
| 2²⁹ | 3 | 19 | 1.000 | 0.977 | (−0.145, +0.023) | 1.000 | 1 351 586 | works |
| 2²⁹ | 5 | 24 | 0.958 | 0.977 | (−0.179, +0.016) | 0.434 | 418 262 | works |
| 2²⁹ | 8 | 24 | 0.958 | 0.977 | (−0.179, +0.016) | 0.434 | 87 622 | works |
| 2²⁹ | 11 | 24 | 1.000 | 0.977 | (−0.115, +0.023) | 1.000 | 35 618 | works |
| 2³¹ | 3 | 12 | 0.750 | 0.812 | (−0.345, +0.099) | 0.397 | 3 820 040 | works |
| 2³¹ | 5 | 24 | 0.750 | 0.812 | (−0.261, +0.068) | 0.287 | 1 166 738 | works |
| 2³¹ | 8 | 24 | 0.833 | 0.812 | (−0.171, +0.121) | 0.684 | 242 714 | works |
| 2³¹ | 11 | 24 | 0.833 | 0.812 | (−0.171, +0.121) | 0.684 | 85 396 | works |
| 2³³ | 3 | **1** | 1.000 | 0.994 | (−0.788, +0.006) | 1.000 | 4 920 551 | works † |
| 2³³ | 5 | 24 | 1.000 | 0.994 | (−0.132, +0.006) | 1.000 | 3 256 747 | works |
| 2³³ | 8 | 24 | 1.000 | 0.994 | (−0.132, +0.006) | 1.000 | 615 542 | works |
| 2³³ | 11 | 24 | 1.000 | 0.994 | (−0.132, +0.006) | 1.000 | 214 928 | works |

Every cell is at its per-modulus ceiling; **no cell shows a detectable
shortfall.** † the `2³³ b=3` row is `N = 1` — the relation-finding cap (5M)
truncated it, since that cell needs 4.9M trials *per relation*. It is reported
for completeness and is **not** the load-bearing evidence; the `2³³ b=5` row
(`N = 24`, same modulus) is.

**A note on the caps.** At small `b` the cap is what actually bounds the
experiment, and it silently reduces `N` (19, 12, 1 in the rows above). This is
why I report `N` in every cell. The verdict "works" only needs the data to be
*consistent with* the ceiling, and low `N` biases that test toward passing —
**it cannot manufacture a false "works"**, but it can hide a real shortfall.
The `b ≥ 5` rows, which all reached `N = 24`, are the ones that carry the claim.

### 4a. The cost is what fails, and it fails fast

The trials column is the real constraint, and it moves by **two orders of
magnitude** across the same range of `b`:

| `b` | 3 | 5 | 8 | 11 |
|---|---|---|---|---|
| mean trials/relation, `n = 2²⁷` | **672 405** | 128 322 | 35 158 | 13 142 |
| mean trials/relation, `n = 2²⁹` | **1 351 586** | 418 262 | 87 622 | 35 618 |
| mean trials/relation, `n = 2³³` | **4 920 551** | 3 256 747 | 615 542 | 214 928 |

The factor base at `b = 3` is `{2, 3, 5}`. A residue mod `n` of size `~n` is
`{2,3,5}`-smooth with probability `~2^{-u}` where `u = log n / log 5 ≈ 11.6` to
`14.2` across these runs — so the relation search is starved, and the algorithm
is **grinding, not failing**.

**But the growth of that cost with `n` is the number that decides whether small
`b` could ever scale**, and it is better than a naive reading suggests:

| `n` | `u` | trials/relation | `log₂(trials)` |
|---|---|---|---|
| 2²⁷ | 11.63 | 672 405 | 19.36 |
| 2²⁹ | 12.49 | 1 351 586 | 20.37 |
| 2³¹ | 13.35 | 3 820 040 | 21.87 |
| 2³³ | 14.21 | 4 920 551 | 22.23 |

> **Measured slope `d(log₂ trials)/d(log₂ n) ≈ 0.51`** over four points.

So at fixed small `b` the relation-finding cost grows like roughly `√n`, not
`n`. That is **sublinear** and it is the most favourable fact measured in this
round. I do **not** extrapolate it — four points with `u` confined to
[11.6, 14.2] cannot support a slope that is supposed to steepen as `u` grows,
and a log-scale fit to four points is a weak instrument. But it is the reason
the §5c conclusion is "the squeeze is intact" rather than "the method is
hopeless at small `b`".

### 4b. A bug this experiment caught in my own harness, and the fix

My first `classify()` used `excess_lo ≥ −0.10` — an arbitrary tolerance. At the
`2²⁹` modulus (`p_split = 0.9766`, `N = 24`) the Wilson half-width alone is
≈ 0.09, so the rule could not resolve anything smaller than ~0.10 and it
reported **`b_min = None`** — "the method never works" — on a modulus where it
had just factored **23 of 24 times**.

The correct statistic is the hypothesis's own: the method is *perfect*, so the
count is `Binomial(N, p_split)`, and one asks only whether the data are
inconsistent with that, **one-sided**. The tolerance version is **kept in the
test file** (`selftest` T8) and shown to produce the false null, so the bug
cannot silently return.

---

## 5. What the measurement means — and one claim I had to retract

### 5a. The cost curve, measured

`cost_curve.py` measures the smoothness rate by **sampling actual residues**
against the actual factor base. **No Dickman appears in the estimate** —
`r48/_shared/dickman.py` is broken above `u = 5`, and `ρ` is the wrong null for
a ratio test (`Ψ/x → e^{−γ}/ln B > 0` while `ρ → 0`). 4 × 10⁵ residues per row:

`n = 2³⁰`:

| `b` | `B` | `u` | `P(smooth)` | trials/relation | `u^u` (Stange p.5) | `u^u / measured` |
|---|---|---|---|---|---|---|
| 3 | 5 | 12.463 | 0.000005 | **729 298** | 4.510e+13 | **6.19e+07** |
| 5 | 11 | 8.365 | 0.000028 | 65 121 | 5.202e+07 | 7.99e+02 |
| 8 | 19 | 6.812 | 0.000152 | 8 422 | 4.747e+05 | 5.63e+01 |
| 11 | 31 | 5.841 | 0.000395 | 2 958 | 2.999e+04 | 1.01e+01 |
| 15 | 47 | 5.210 | 0.001030 | 1 069 | 5.424e+03 | 5.07e+00 |
| 20 | 71 | 4.705 | 0.002413 | 442 | 1.462e+03 | 3.31e+00 |
| 33 | 137 | 4.077 | 0.007298 | 142 | 3.077e+02 | — |
| 50 | 229 | 3.691 | 0.016123 | 64 | 1.241e+02 | — |

At `n = 2⁵⁰` the small-`b` rows get worse in the sharpest possible way: at
`b = 3, 5, 8, 11` the smoothness rate is **0 hits in 4 × 10⁵ samples**.

### 5b. RETRACTION — `u^u` is not the culprit I first blamed

My first draft of this section claimed Stange's `u^u` "overshoots the true cost
by up to 1e6", and that this explained the gap. **That is wrong, and I checked
it rather than shipping it.**

I computed the Dickman function `ρ` from scratch (`cost_curve.dickman_rho`,
solving `ρ′(u) = −ρ(u−1)/u`, `ρ ≡ 1` on `[0,1]`, trapezoid on a 1/M grid in
60-digit arithmetic — `r48`'s copy is not used) and validated it against eight
published values (`selftest` T13, agreement to 7–9 significant digits for
`u ≤ 7`):

| `u` | `u^u` | `1/ρ(u)` | ratio `u^u·ρ(u)` |
|---|---|---|---|
| 3 | 2.700e+01 | 2.057e+01 | 1.31 |
| 4 | 2.560e+02 | 2.036e+02 | 1.26 |
| 5 | 3.125e+03 | 2.819e+03 | 1.11 |
| 6 | 4.666e+04 | 5.089e+04 | 0.92 |
| 7 | 8.235e+05 | 1.143e+06 | 0.72 |
| 8 | 1.678e+07 | 3.094e+07 | 0.54 |

> **`u^u` and `1/ρ(u)` agree to within a factor ~2 over the whole range. The
> model is not grossly wrong about the number of trials.**

So the measured 6.2 × 10⁷ discrepancy at `b = 3` is **not** a defect peculiar to
`u^u`. The honest explanation is that **both** estimates are asymptotics in
`x → ∞` at fixed `u`, and these runs are at `x = 2³⁰` with `u = 12.5` — deep
outside both. **The only trustworthy number is the measured one.**

*(Two of my `ρ` implementations were also wrong before the right one: a
recursive ODE integration that did not terminate in time, and a marching
scheme whose "Simpson" midpoint index `(2i−1)//2` always equals `i−1`, so it
silently degenerated to a trapezoid and converged to `ρ ≈ 1/u`. Validated
against published values in T13; the value at `u = 2` must be `1 − ln 2 =
0.306852`.)*

### 5c. So what does the measurement mean?

It means the 4.3-order gap is a statement about **an estimate evaluated outside
the regime where it is valid**, not about the construction. Concretely:

- `b_needed = L_n(1/2, β)` is what Stange's asymptotic says the algorithm
  *costs*, at a `b` far above where the cost model has any purchase.
- `b_min = 3` is where the algorithm **works**.
- These are consistent, because `b_needed` was never a correctness claim — and
  two rounds of notes treated it as one.

**But this does not make the method a route.** The cost curve says the same
thing from the other side: at `b = 3` the relation search needs `~10⁶` trials
per relation at `n = 2³⁰`, and at `n = 2⁵⁰` the small-`b` rows find **zero**
smooth residues in 4 × 10⁵ samples. The method is not cheap at `b_min`; it is
cheap only at `b ≈ b_needed`, which is where `b_max` forbids it. That is the
squeeze, and it is intact.

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
python3 selftest.py     # 116/116 PASS
python3 cost_curve.py   # B4b: measured smoothness/cost curve
python3 bmin.py         # B4:  b_min at several n, with the 2-adic control
```

**Self-test: 116 checks, 0 failures.** Every control the brief demanded is
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
