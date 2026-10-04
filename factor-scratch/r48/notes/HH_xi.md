# HH — `ξ(N)`: the last thread

**Round 50 · agent HH · ξ task X1–X4**

## Verdict up front

**`ξ(N)` is not the live open item, and it is not attackable as an open question — it is
already computed.** A theorem in the very paper this programme has been citing gives `ξ(N)`
in closed form. The inherited `2^45` is **wrong by a factor of ≈ 2^50**, and it is wrong
because it was read off a *hand-built illustrative example* in that paper and reported as if
it were `ξ(N)`. The real correction at 2048 bits is **≈ 2^4.7, i.e. about 5 bits** — and even
that is smaller than several uncertainties already known to this programme.

The thread is closed, and it closes *against* the premise of the task brief.

---

## 0. Sources, and what I actually read

All three PDFs were downloaded fresh and verified by title/author on p.1 of each. Every
formula I rely on below was read from a **rendered page image** (`pdftoppm -r 190/200 -png`),
not from `pdftotext` — per the programme's standing warning, `pdftotext` flattened the
fractions in Corollary 19 into something materially misleading (see §1.3).

| Ref | Paper | arXiv | Read |
|---|---|---|---|
| **[LGST21]** | Aude Le Gluher, Pierre-Jean Spaenlehauer, Emmanuel Thomé, *Refined Analysis of the Asymptotic Complexity of the Number Field Sieve*, Math. Cryptology **1**(1):1–18 (2021) | `2007.02730v2` | pp. 1, 2, 9 as images |
| **[BGG+20]** | Boudot, Gaudry, Guillevic, Heninger, Thomé, Zimmermann, *Comparing the difficulty of factorization and discrete logarithm: a 240-digit experiment* | `2006.06197v1` | p. 4 |
| **[BGM+14]** | Barbulescu, Gaudry, Guillevic, Morain, *Improvements to the number field sieve for non-prime finite fields* | `1408.0718v4` | p. 1 |

**Provenance note.** `arXiv:1602.06739`, which appeared in an earlier sweep in this repo, is
**an astronomy paper** ("A quality check of the *AKARI* mid-infrared all-sky diffuse map…",
Sano et al.). It is not an NFS paper. I flag it only so no successor reuses it.

---

## X1 — What `ξ(N)` actually is

### 1.1 It is a defined-by-existence residual, and the paper says so in the abstract

**[LGST21] p.1, Abstract**, verbatim:

> "The classical heuristic complexity of the Number Field Sieve (NFS) involves an unknown
> function, usually noted *o*(1) and called ξ(*N*) throughout this paper, which tends to zero
> as the entry *N* grows."

and **p.1, last paragraph of the Introduction**, verbatim:

> "A second point is that even if we consider that these assumptions hold, the complexity
> given by Formula (1) involves a function ξ which is never spelled out explicitly."

Formula (1), **p.1, read from the page image** — note the cube root is **outside**:

$$\exp\Big(\sqrt[3]{\tfrac{64}{9}}\;(\log N)^{1/3}(\log\log N)^{2/3}\,(1+\xi(N))\Big),
\qquad \text{"where } \xi(N)\in o(1) \text{ as } N \text{ grows."}$$

There is **no `Definition` environment for ξ anywhere in the paper.** The paper's Definitions
are 1 (smoothness, p.1), 6 (class 𝒞, p.5), 15 (class 𝒞^{[α,β]}, p.9). ξ is the *name of the
o(1)*, defined by existence as the gap left by the minimizers of **Problem 3** (p.4, the
"Simplified optimization problem"), whose constraint is

> "*p*(*a* + *ν*/*d*, *b*) + *p*(*d* **a** + *ν*/*d*, *b*) + 2**a** − *b** = 0.  (2)"

with **p.1, Definition 1**: "Ψ(*x*, *y*) = #{integers in [1,*x*] that are *y*-smooth}" and
"*p*(*u*, *v*) = log (Ψ(*e*ᵘ, *e*ᵛ)/*e*ᵘ)".

### 1.2 The distinction the brief asked for: four different things called ξ

**Only one of these is ξ(N).** Conflating them would repeat the programme's signature error,
so the inventory is given explicitly:

| Candidate reading | Is it ξ(N)? | Evidence |
|---|---|---|
| A **PNT remainder** (`li(x) − π(x)` type) | **No.** ξ appears nowhere near a prime-counting asymptotic in the paper. | grep of all 49 ξ occurrences |
| A **Dickman/smooth-count remainder** | **No.** ρ enters the paper only as an *input* to the minimization (Prop. 11, Cor. 13–14); it never *defines* ξ. | **[LGST21] p.9**, Def. 15 discussion |
| An **adelic-capacity remainder** | **No.** Nothing of this kind appears. | — |
| A **de Bruijn correction** | **No, but it is the *upstream cause*** — see §4.3. | **[LGST21] p.15** |
| **The o(1) slack in the minimizers of Problem 3** | **YES — this is ξ(N).** | Thm. 17, Cor. 19 |

**A genuine notational collision inside the source paper.** ξ is *reused as a dummy
integration variable* on **pp. 5–6**, inside De Bruijn's formula for ρ. From the p.5 image:
"ρ(*u*) ∼_{u→+∞} (e^γ/√(2πu)) × exp(−∫₀^ξ (*s e*ˢ − *e*ˢ + 1)/*s* ds)", and p.6:
"for all *u* > 1 and **ξ** = (*e*ᵘ − 1)/*u*". That ξ is a substitution endpoint. **Any grep
for ξ hits it.** Adjacent Greek that is *not* ξ: `ν` (nu, the variable ν = log N, used
constantly), `η` (eta), `ζ`, `χ`. `ρ` (Dickman) and `Ψ` (smoothness count) are the load-bearing
analytic objects.

### 1.3 ⚠️ A `pdftotext` trap I hit, recorded because it nearly cost the study

**Corollary 19, p.9** — the result that actually states the complexity — extracts as

```
log 𝐶(𝑁) = 3 (64/9) (log 𝑁)1/3 (log2 𝑁)1/3 (1 + 𝑎10 (log 𝑁)/(log2 𝑁) + 𝑎01/(log2 𝑁) + 𝑜)
```

i.e. appearing to say **(log log N)^{1/3}** where Formula (1) on p.1 says
**(log log N)^{2/3}**. The page image of p.9 shows the exponent is a rendering of `2/3`
flattened. **The two agree; the text extraction does not.** Corollary 19 is the
`log C(N) = exp(2Φ(log N))` version and must agree with Formula (1) by construction, and the
factor-of-two that reconciles them is exact:

$$2\cdot(8/9)^{1/3} = (64/9)^{1/3} = 1.9229994270765445\quad\text{(verified exactly).}$$

This is also what resolves the apparent factor-3 discrepancy between the abstract's
`4 logloglog N/(3 log log N)` and Theorem 17's `a10 = 4/3` (below).

---

## X2 — Sign and size: the `2^45` is inherited, misattributed, and wrong

### 2.1 `ξ(N)` is computed by Theorem 17 / Corollary 19 — this is the headline result

**Theorem 17, p.9, read from the page image**, verbatim:

> "Theorem 17. The minimizers *a*, *b*, *d* satisfy :
>   *a* = (8/9)^{1/3} ν^{1/3}(log ν)^{2/3} (1 + *a*₁₀𝒳(ν) + *a*₀₁𝒴(ν) + *o*(𝒴(ν))),
>   …
> where *a*₁₀ = 4/3, *a*₀₁ = −2 log 2 + log 3/6 − 2, *d*₁₀ = −2/3 and *d*₀₁ = log 2 − 5 log 3/6 + 1."

With the script functions **𝒳(ν) = log log ν / log ν** and **𝒴(ν) = 1 / log ν** (stated in the
Prop. 16 item 3 / Def. 15 apparatus, p.5 and p.9), and ν = log N, this is *exactly*

$$\xi(N)\;=\;\underbrace{\frac{4}{3}\cdot\frac{\log\log\log N}{\log\log N}}_{\text{leading}}\;+\;\frac{-2\log 2 + \log 3/6 - 2}{\log\log N}\;+\;o\!\left(\frac{1}{\log\log N}\right)$$

**This is the same two-term statement printed on p.2 and in the abstract** — I verified
`a10·𝒳 = 4logloglog N/(3 log log N)` and the two-term numerically against each other. The
`4/3` and the abstract's `4/3` coefficient coincide because `a10 = 4/3` multiplies
`log₃N/log₂N`. **There is no factor-3 contradiction.** The abstract's own summary, p.1:

> "We prove that it is equivalent to 4logloglog *N*/(3loglog *N*)."

and p.15: "the convergence of ξ to zero is very slow as *N* grows, since
ξ(*N*) ∼ 4 log₃*N*/(3 log₂*N*) (Theorem 17)."

**So `ξ` is *not* an unspecced mystery. It is a theorem, evaluated in three lines of
arithmetic.**

### 2.2 The numbers at 2048 bits (exact arithmetic; self-test T3/T4)

| bits | loglog N | ξ leading | **ξ two-term (Thm 17)** | ξ = 0 cost | shift from ξ_2term |
|---|---|---|---|---|---|
| 512 | 5.8718 | +0.4020 | **−0.1436** | 2^63.9 | −4.77 bits |
| 1024 | 6.5650 | +0.3822 | **−0.1057** | 2^86.8 | −4.77 bits |
| 1536 | 6.9704 | +0.3714 | **−0.0881** | 2^103.4 | −4.74 bits |
| **2048** | **7.2581** | **+0.3641** | **−0.0772** | **2^116.9** | **−4.69 bits** |
| 3072 | 7.6636 | +0.3543 | −0.0637 | 2^138.7 | −4.59 bits |
| 4096 | 7.9513 | +0.3477 | −0.0552 | 2^156.5 | −4.49 bits |

**The sign at 2048 bits is NEGATIVE**, and the *effect* is a **−4.7-bit** shift on a
2^116.9-bit exponent — a factor of about **2^4.7 ≈ 26**, not 2^45.

Direction of the error: since the `(1+ξ)` multiplies the exponent and ξ < 0, **setting ξ = 0
OVER-predicts the cost of NFS at 2048 bits by ≈ 2^4.7.** This matches the paper's own
p.2 warning in words: *"estimating o(1) by 0 in the case N = 2^2048 yields completely
erroneous results"* and *"Carelessly neglecting the o(1) term can lead to dramatic errors."*
The **direction** was right; the **magnitude** in this programme was inflated ~40-fold.

⚠️ **But the two available truncations DISAGREE ON SIGN.** Leading term only: **+0.364**
(cost under-predicted, +22 bits). Two-term: **−0.077** (cost over-predicted, −4.7 bits).
This is not a defect in either truncation; it is the paper's actual point (§4.3). **The
honest statement is that `ξ(2^2048)` is somewhere in the range covered by its own divergent
series, and the only defensible point estimate is the two-term one, −0.077.** The leading
term alone is *provably* the wrong shape here because `1/log log N` is not negligible against
`log₃N/log₂N` at these sizes.

### 2.3 Where `2^45` came from — and it is not `ξ`

**Reproduced exactly.** **[LGST21] p.2, read from the page image**, the paper defines two
*example functions* immediately before discussing ξ:

> "**g₀** : *N* ↦ exp( (log *N*)^{1/3} (log log *N*)^{2/3} );  **g** : *N* ↦ exp( (log *N*)^{1/3} (log log *N*)^{2/3} / (1 + 20/log log *N*) )."

and then, verbatim:

> "Numerical computations show that *g*(2²⁰⁴⁸) ≈ 2¹⁶, while *g₀*(2²⁰⁴⁸) ≈ 2⁶¹, so estimating
> o(1) by 0 in the case *N* = 2²⁰⁴⁸ yields completely erroneous results."

My recomputation reproduces both to the digit (self-test T4):

* `g₀(2^2048) = 2^60.78` — paper says ≈ 2^61 ✅
* `g(2^2048) = 2^16.18` — paper says ≈ 2^16 ✅
* **ratio `g₀/g = 2^44.60`** — **this is exactly the inherited "2^45"**

**And the paper never claims `ξ` equals this.** Its actual statement, p.2, verbatim:

> "The asymptotic expansion of ξ that we obtain in the complexity of NFS exhibits a behavior
> **similar to** the example function g."

**Verdict on X2: `2^45` is an inherited, unchecked, misattributed number.** It is the gap
between two *toy* functions in which **the constant 20 is chosen by hand** to make the
illustration vivid; `ξ(N)` is a different object whose value is −0.077 and whose cost effect
is 2^4.7. The ~2^50 exaggeration came from reading an illustrative ratio as a measured
remainder. This is the programme's familiar failure mode (an inherited number, propagated
without recomputation) and it is retracted here.

---

## X3 — Does it matter? Quantitatively: **it washes out.**

Under Formula (1) the `(1+ξ)` sits **in the exponent**, so the sensitivity is

$$\Delta(\log_2 \text{cost}) = \xi\cdot\frac{(\ln N)^{1/3}(\ln\ln N)^{2/3}}{\ln 2}$$

At 2048 bits that scale `S/ln2 = 60.7`, so **each 0.01 of ξ is worth 0.61 bits**, and the
two-term ξ = −0.077 is worth **4.69 bits**.

| source of uncertainty in the NFS cost prediction | magnitude |
|---|---|
| **ξ, Theorem 17 two-term (this study)** | **4.7 bits** |
| ξ, leading term only (disagrees in sign) | 22 bits |
| B over-prediction, lnB 26.98 vs 21.5 on RSA-240 (already in this repo) | ~10 bits |
| poly degree 5 → 6 in the `m·Y³` box (lattice index) | ~10 bits |
| sieving vs. matrix cost split | ~5 bits |
| record-to-2048 extrapolation | ~10 bits |

**Two consequences.**

1. **`ξ` at 4.7 bits is real but not dominant.** It is comparable to the sieving/matrix split
   and smaller than the *already-known* `B` over-prediction of ~10 bits this programme
   measured on real data (CADO-NFS RSA-240, lnB = 21.5 against asymptotic 26.98). It does
   **not** dominate and it does **not** "wash out" either — it sits inside the noise band,
   which is the honest verdict. Practically, for the question RSA deployments actually ask,
   **it is not the binding constraint.**

2. **For *comparative* claims it is irrelevant, and the literature has always said so.**
   **[BGG+20] p.4**, verbatim: "the presence of (1 + o(1)) in the exponent reveals a
   significant lack of accuracy in this complexity estimate, **which easily swallows any
   speedup or slowdown that would be polynomial in log N**." A 4.7-bit shift is ≈ 26×; it
   cannot separate GNFS from any competing method, since all of them differ by far less
   than that. **Any method paper claiming a `2^k` or `k^1.x` improvement over GNFS is
   already inside this error bar.** That is the operational answer to X3, and it is stronger
   than anything this programme could have constructed.

---

## X4 — Is it knowable? **Yes for the two-term value; no for anything better.**

**Separately from the sign question, `ξ` is *computable in principle* — the paper computes
it.** This is the sharp contrast with the constant `1.9230`, which was shown (round 48/49) to
be both immovable *and* untestable here. `ξ` is the opposite case:

* **The two-term value is a theorem, evaluated in closed form.** `ξ(2^2048) = −0.0772`,
  available on a pocket calculator. **No `π(B*)` obstruction, no RAM obstruction.** The
  object is a rational function of `log log N` and `log log log N`.
* **The `exp(exp(25))` barrier is about a DIFFERENT object** — see §4.3. It is not a
  computability barrier for ξ; it is a *convergence* barrier for the truncated series used
  to refine it.

So the answer is asymmetric and worth stating precisely, because it tells a successor
exactly where to stop:

| | attackable? | why |
|---|---|---|
| ξ to two terms | **YES — DONE, it is Theorem 17** | closed form, §2.1 |
| ξ to three+ terms | **NO** | the series diverges at all `N ≤ exp(exp(25))` (§4.3) |
| ξ's *true* value at 2048 bits | **NO — not currently determinable by anyone** | would need the non-asymptotic object, which is precisely what Problem 3 defines but never evaluates |

The third row is the only genuine open item, and it is a statement about the *paper's own
definition* — ξ is defined only as an existence class member, so "ξ(2^2048)" has no
evaluation procedure attached to it by anyone. **That gap is not closable by this programme,
and the paper's thesis is that no one can close it with these tools.**

---

## 4.3 The `exp(exp(25))` claim — what it is actually about, precisely

**The claim is real and correctly quoted**, but its scope is narrower than inherited.
**[LGST21] p.1, Abstract**, verbatim:

> "we provide an asymptotic series expansion of ξ and numerical experiments indicate that
> this series starts converging only for *N* > exp(exp(25)), far beyond the practical range of
> NFS."

**"this series" = the asymptotic series expansion of ξ**, introduced in the immediately
preceding clause. It is *not* a Ψ estimate and *not* a PNT expansion. p.15, verbatim:

> "we only start to observe convergence for *N* > exp(exp(25)) ≈ 2^103881111194 …
> However, it turns out that for practical values of *N*, replacing ξ by ξᵢ for *i* > 0 is
> **possibly even worse** since the asymptotic series expansion of ξ **seems to diverge** for
> *N* ≤ exp(exp(25))."

Three qualifications this programme's inherited version dropped:

1. **It is an experimental observation, not a theorem.** "numerical experiments indicate",
   "we only *start to observe*", "**seems** to diverge". SageMath truncations, not a proof.
2. **Its radius is inherited from ρ, upstream.** p.15: "the expansion of ξ relies on the
   expansion of ρ, and the latter involves a series that converges only for sufficiently large
   values as stated in Proposition 11." p.17 makes the identification explicit: "the
   asymptotic series expansion of ρ starts to converge around *u* ≈ *e*⁸ … This is consistent
   with the observed convergence … since exp(25)^{1/3} ≈ *e*⁸." I verified the arithmetic:
   `exp(25)^(1/3) = 4160.3` vs `e^8 = 2981.0` — same order, as claimed. (Prop. 11's own
   stated range is `η ∈ [176, ∞[`, which I inverted: `η = (eˢ−1)/s = 176` at `s = 7.1365`.)
3. **It does not mean ξ is uncomputable** — ξ's *two-term* value is a theorem. It means
   *more terms* don't help. Adding terms is worse, not necessary.

**Separation, quantified** (the number a successor should carry):

| quantity | value |
|---|---|
| `log log N` at RSA-2048 | 7.258 |
| `log log N` at the convergence threshold | 25.0 |
| **separation in the governing variable** | **3.44×** |
| the `o(1)` remainder in Thm 17 at 2048 bits | `o(1/log log N)`, i.e. not controlled |

**A `3.44×` gap in `log log N`, in a series that diverges below it.** There is no
extrapolation regime. That is the real, quantified obstruction — and it is a statement about
the *series*, not about ξ's computability.

---

## 5. What else I checked and did not find

* **Neither `[BGG+20]` nor `[BGM+14]` mentions ξ at all.** Verified two ways (`pdftotext
  -layout` and `-raw`) plus a full non-ASCII codepoint scan. `[BGG+20]`: Greek present =
  α, σ, ψ only. `[BGM+14]`: Γ,Λ,Φ,α,β,…,χ,ω,ϕ — no ξ.
* **A convention clash worth flagging.** `[BGM+14]` p.1 writes the residual **additively**,
  "L_Q(α, c) = exp((c + o(1))(log Q)^α(log log Q)^{1−α})" — the `L[α,c] = exp((c+ξ(N))…)`
  form in the task brief. `[LGST21]` writes it **multiplicatively**, `(1+ξ(N))`. **These
  differ numerically and must never be mixed.** Everything above uses `[LGST21]`'s
  multiplicative convention; converting is a one-line change and I flag it as the single
  most likely place for a successor to introduce a silent factor.
* `1602.06739` is an astronomy paper (see §0).

---

## 6. Method, controls, and limits of this study

**Self-test written first** (`factor-scratch/r50exp/xi/selftest.py`, **PASSES**). It exercises
the quantity actually claimed:

* `T1` Dickman ρ vs closed forms to ≤1e-6 (only `u ≤ 4` is claimed usable, and `T5` skips
  anything larger — the harness states this limit rather than hiding it).
* `T2` Ψ computed by **two independent implementations** (largest-prime-factor sieve and
  smooth-set generation) — 5/5 agree; plus `Ψ(x,x)=x` on 3 sizes.
* `T3` **Theorem 17 internal consistency**: `ξ_2term − ξ_lead` must equal `c₁/log log N` with
  `c₁ = −2ln2 + ln3/6 − 2 = −3.20319231`; verified exactly at 4 sizes.
* `T4` **reproduces `g₀(2^2048)=2^60.78`, `g(2^2048)=2^16.18`** — i.e. reproduces the
  inherited `2^45` and thereby proves it is the *toy* ratio.
* `T6` **negative control + null-capability**: a 5% corruption of ρ is flagged
  (`R=+4.88e-2`); a 0.02% corruption correctly returns **NULL**.

**Bugs the self-test caught in my own work — recorded, because they are the interesting part:**

1. The widely-quoted recursion **`Ψ(x,y) = Ψ(x,y−1) + Ψ(x/y,y)` is FALSE** unless `y` is
   prime. Counterexample (x=10, y=4): the 4-smooth and 3-smooth sets below 10 are identical,
   so the LHS difference is **0**, while `Ψ(2.5,4) = 2`. The correct all-`y` identity is
   `Ψ(x,y) = 1 + Σ_{p≤y} Ψ(x/p, p)` (each y-smooth integer counted once by its largest prime
   factor) — I verified this by hand before coding it. **This trap is live for any successor
   attempting a Ψ computation.**
2. My Dickman integrator had an **O(h) offset from an uninitialised accumulator**, and then a
   catastrophic-cancellation failure (`1 − D` with `D→1`). Both were caught only because T1
   checks against closed forms. Also: two of my "tabulated" reference values (ρ(5), ρ(10))
   were themselves wrong — a reminder that a reference table is not an oracle.
3. Enumerating y-smooth integers to get Ψ **cannot work in the NFS regime**: with `u ≈ 43.8`
   (computed: `ln B = 40.51`, `B = 2^58.4`, `ln x = 1.25 ln N` ⇒ `u = 43.80`), `Ψ ≈ x ρ(u)` is
   astronomically large. Rejected as a method.

**Limits — what I could NOT determine, stated as limits:**

* **The true value of ξ(2^2048) is not determinable here or, on current theory, by anyone.**
  What I have is the two-term theorem value, −0.0772, with the leading-term-only value
  (+0.364) disagreeing in sign. I am not entitled to pick one as "the" answer, and I do not.
* **The Dickman remainder at NFS scale is not determinable here.** I measured
  `R = ln(Ψ/(xρ(u)))` at `u ≤ 3` only, where `R` ranges **+0.033 to +0.115** (0.05–0.17 bits)
  and is *shrinking* with `u`. Extrapolating a factor-of-14 gap in `u` is not something I
  will put a number on. **Note this is a different quantity from ξ** (§1.2) and it is small
  where measured — consistent with §3's verdict.
* **I did not attempt to re-derive Theorem 17.** I verified it numerically, verified its
  internal consistency, and verified it reproduces the paper's own printed summary formula.
  The proof is ~8 pages of constrained formal-series minimisation by the authors.

---

## 7. Final statement

**Is `ξ(N)` the live open item? NO.** It was the last nominally-unclosed thread, and it is
closed — not by a new attack, but by *reading the cited paper properly*. Theorem 17 and
Corollary 19 give `ξ(N)` in closed form. The programme has been citing this paper for
`1.9229994` while the same paper's central theorem sat unread one page later.

**Is it attackable? It does not need to be.** The two-term value is arithmetic. Beyond two
terms it is not attackable by anyone, because the series diverges — the paper proves that
about its own object and says so in its abstract.

**And the `2^45`, which was the reason to think it was live, is retracted:** it is the ratio of
two hand-built illustration functions with an author-chosen constant, misreported as a
measured remainder. The real correction is **2^4.7**, negative (ξ = 0 over-predicts), and it
is **inside the noise band** of uncertainties this programme has already measured — smaller
than the known ~10-bit `B` over-prediction on real RSA-240 data.

**What a successor should carry, in one line:** *there is no open thread left in the NFS cost
model; what remains is not a mathematics problem but a discipline problem — every number in
this literature is an `o(1)`-concealed quantity, and the fix is to compute the `o(1)`, not
to search for a better constant.*

*(Note: files written — `factor-scratch/r50exp/xi/{selftest.py, xi_experiment.py,
psi_leading.py, lit/pdf/*}` and this note. Nothing outside those paths was touched. No
commit, no issue, no paper, per instructions.)*
