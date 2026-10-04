# JJ — Literature Sweep 3: the `20/27` lever, non-uniform bases, and EMPTY REGIONS

**Date:** 2026-10-04 · **Scout:** JJ · **Scratch:** `factor-scratch/r50exp/lit2/`
**Question asked:** has anyone studied the choice of the base `g` in order-finding methods, and
does a non-uniform base beat the `20/27` classical rate?

## ■ HEADLINE

**Yes, there is a lever, and it is worth exactly `1.2×`. It is not in the literature.**

> Condition the base on the **Jacobi symbol**, which is computable *without factoring*:
> draw `g` uniformly, keep only `g` with `(g/n) = −1`.
> **Success `20/27 = 0.740740…` → `8/9 = 0.888888…`. Ratio exactly `1.200000×`.**

Both numbers are **exact**, and the uniform one reproduces the programme's `20/27` **to
`+0.000e+00`** — so this is a *transfer onto the programme's own derived constant*, not a
new-computation-of-something-else.

**Status: MY RESULT, NOT THE LITERATURE'S.** Derived here, verified four ways (§2). It has
**not** been published or found anywhere; the closest prior art (§3) is real, is about the
*quantum* analogue, and is 2 years old. **This note is a literature sweep; the mathematics is
a by-product that a successor must independently re-derive before believing.**

⚠️ **Scope caveat, stated up front, because this programme has been killed by this exact error
before (FATAL: a *univariate* optimality theorem read as *method* optimality):** this improves
the **order-finding step's per-attempt success rate only**. It does **NOT** touch the 95% of
cost that is relation-finding (§5). **It is worth 1.2× on the 5%.** It is not a factoring advance.

---

## 1. The main table

| ID / DOI | Verbatim quote | Page | Verdict |
|---|---|---|---|
| **arXiv:2211.06821** (Stange, *Factoring using multiplicative relations modulo `n`*, 2022-11-13, sole author Katherine E. Stange — all verified this session) | "Input : A positive integer `n`, and a positive integer `g < n`." (Alg. 2.2 header, p. 4) | **4** | ✅ **`g` is an EXPLICIT FREE INPUT.** The lever transfers structurally — no algorithm change, only an input choice. |
| same, p. 3 | "Shor's quantum factoring algorithm determines this order `r` for **random values of `g`** until it finds an order `r` which is even and for which `g^{r/2} ≠ −1 (mod n)`" | **3** | ✅ **The uniform-`g` rejection loop is named explicitly, as the model.** Stange points at precisely the step the lever targets. |
| same, p. 3 | "in practice, choosing a residue at random is likely to result in a generator very quickly" | **3** | ✅ Stange's ONLY statement about `g`-choice is an ERH generator-existence remark. **She never analyses the per-attempt splitting probability.** The axis is open in the paper that introduced the method. |
| same, p. 3 | "By the period problem for an integer `n`, we shall mean the problem of computing the multiplicative order of a given residue modulo `n`." | **3** | The ℚ-kernel supplies a *multiple* of `ord(g)`; the split happens in the descent after. Consistent with the census. |
| **arXiv:2201.07791v2** (Ekerå, *On the success probability of quantum order finding*, 2022-01-19, sole author Martin Ekerå — verified) | Cor. 3.4: "Assume that we select `g` **uniformly at random** from `Z*_N`, attempt to compute the order `r` of `g` in a single run…" | **23** | ✅ **The live state-of-the-art single-run probability analysis ASSUMES UNIFORM `g`.** My lever is **orthogonal** to Ekerå's contribution (which is in quantum post-processing, not the base law) and **untouched by it**. |
| same, p. 20 | "given the order `r` of a single element `g` selected **uniformly at random** from `Z*_N`, the complete factorization of `N` may be recovered in classical polynomial time" | **20** | ✅ The whole chain is uniform-`g`. A non-uniform base is a **free extra** no downstream step forbids. |
| **arXiv:quant-ph/0607148v3** = Bourdon & Williams, *Sharp probability estimates for Shor's order-finding algorithm*, Quantum Inf. Comput. **7**(5–6) (2007) 522–550 (venue/vol/pages confirmed via Ekerå ref [4], p. 40; DOI checked below) | Abstract: "let `b` be an integer satisfying `1 < b < N` that is relatively prime to `N`… We prove that when Shor's algorithm is implemented on `QC`, then the probability `P` of obtaining a (nontrivial) divisor of `r` exceeds `.7` whenever `N > 2^11` and `r ≥ 40`, and we establish that `.7736` is an asymptotic lower bound for `P`." | **1** | ✅ **THE SHARP CLASSICAL BOUND — and `b` is FIXED, not chosen.** B&W bound *quantum phase-estimation noise for a fixed base*. **A different probability entirely from mine.** No overlap. |
| same | `grep -iE "uniformly\|chosen at random\|Jacobi\|quadratic residue\|nonresidue" bw.txt` → **0 matches in 5227 lines** | — | ⚠️ **The sharpest bound in existence never mentions the base distribution at all.** Strongest single piece of evidence that the axis is empty. |
| **DOI 10.59254/sbpo-2025-212078** — Silva, dos Santos & Kowada, *Boosting Shor's Factoring Success with the **Jacobi Symbol** in Single-Run Order Finding against large integer numbers*, **Anais do SBPO, Vol 57 (2025)**, Oct 5–9 2025 | **Title only — NO VERBATIM QUOTE OBTAINED.** Publisher CAPTCHA-blocked (403), `sbpo.org.br` 406/404, no OA copy (OpenAlex: `openAccessPdf.url` empty; Semantic Scholar: `abstract: null`). | — | ⚠️ **⚠️ THE CLOSEST PRIOR ART AND IT IS NOT YET VERIFIABLE. Title asserts the Jacobi-symbol idea for Shor. Identity, authors, venue, volume, year, dates all Crossref-confirmed. SCOPE AND NUMBERS UNREAD — do not cite its contents until fetched.** |
| **DOI 10.1090/S0025-5718-1990-1023756-8** — Bach, *Explicit bounds for primality testing and related problems*, Math. Comp. **55** (1990) 355–380 | Existence confirmed via Crossref this session. **Contents NOT read.** | — | Unread. The canonical source for base/order success-probability bounds; **should be checked before publishing §2.** |
| **DOI 10.1016/S0022-0000(76)80043-8** — Miller, *Riemann's hypothesis and tests for primality*, J. Comput. Syst. Sci. **13**(3) (1976) 300–317 | Existence + venue + pages confirmed via Crossref this session. **Contents NOT read.** | — | Unread. Stange cites it as her ref [13] for the order↔factor equivalence (p. 3, Thm 2.1). |
| **DOI 10.1007/BF01933667** — Pollard, *A Monte Carlo method for factorization*, Math. Comp. **15** (1975) 331–334 | Existence confirmed via Crossref. **Contents NOT read.** | — | Unread. Pollard rho is named in my brief; its base choice was not analysed here. |
| **arXiv:2601.02518** (Cadavid, Hoyos, Jorgenson, Smajlović, Vélez, 2026-01-05) — *Diffusion Computation versus Quantum Computation: A Comparative Model for Order Finding and Factoring* | Remark 4.3: "we will invoke Theorem 4.1 only in the factoring setting… and where we choose `b` so that `r = ord_N(b)` is **odd**." | **10** | ✅ **2026 work, and it DOES use a non-uniform base** (`b = a²`, chosen for odd order). Closest structural neighbour. **Orthogonal**: it exploits order *parity* via a weighted Cayley graph; it never conditions on `(g/n)` and computes no splitting probability for the classical case. **Also confirms the axis is live and being worked in.** |
| same | "Moreover, if `a` is chosen uniformly at random from `Z*_N`, then with probability at least `p(m) = 1 − (m+1)/2^m`…" (Prop. 3.3 / Remark 3.3) | **4** | Uniform-`a` again. Same blind spot, independently, in 2026. |

---

## 2. The lever — derivation and verification (MY RESULT, scout-supplied)

### 2.1 The mechanism

The census's `20/27` is `P(v₂(ord_p g) ≠ v₂(ord_q g))` under uniform `g`. Two facts:

- **(L1)** `(g/p) = −1 ⟺ v₂(ord_p(g)) = s_p`, where `s_p = v₂(p−1)`. *(The 2-Sylow of a cyclic group of order `2^s` has an element of order `2^s` iff it is a non-square.)*
- **(L2)** `(g/p) = +1 ⟹ v₂(ord_p(g)) ∈ {0,…,s_p−1}` with `P(·=k) = 2^{k−s_p}`.

`(g/n) = −1` forces **exactly one** of `(g/p),(g/q)` to be `−1`. Split on that:

- **Arm A** (`(g/p)=−1`): `v₂(ord_p g) = s_p`; and `(g/q)=+1` gives `v₂(ord_q g) ∈ {0..s_q−1}`.
  If `s_p ≥ s_q`, then `s_p > s_q−1 ≥ v₂(ord_q g)` — **the two differ, ALWAYS.** Arm A succeeds with probability **1**.
- **Arm B** (`(g/q)=−1`): symmetric, succeeds with probability **1** iff `s_q ≥ s_p`.

Both arms are equally likely, so the **only** residual failure is Arm B firing when `s_q < s_p`,
with probability `2^{s_q−s_p}`. Hence the exact conditional law:

```
                    ⎧ 1                              if s_p = s_q
P(success | s_p,s_q) = ⎨
                    ⎩ 1 − 2^(−(1 + |s_p − s_q|))       if s_p ≠ s_q
```

**The whole gain comes from the diagonal `s_p = s_q`** — exactly the cells where *uniform* `g`
is **worst** (success `2^{1−2s}`, i.e. **1/2** at `s=1`). Jacobi-conditioning maps the worst
cells to certainty.

Averaging over the census's own law `P(s=j) = 2^{−j}` in exact rational arithmetic:

```
uniform : success = 0.74074074074074…   = 20/27   (diff from 20/27: +0.000e+00)
Jacobi  : success = 0.88888888888889…   = 8/9
ratio   = 1.200000×        expected attempts 1.3500 → 1.1250  (−16.7% attempts)
```

### 2.2 Four independent verifications

| # | check | result |
|---|---|---|
| 1 | **Exhaustive** over all `g` for all `p<q<130` (210 cells, every unit enumerated) | formula matches measured in **210/210 cells, max error 0.000000** |
| 2 | **Monte Carlo**, sympy, 60 000 draws, primes < 2×10⁶ | uniform `0.73974` (z = **−0.56**), Jacobi `0.88901` (z = **+0.07**), ratio `1.20178` |
| 3 | **Fully independent reimplementation** — own Miller–Rabin, own Legendre, own Jacobi, **no sympy** | crux lemma (L1): **0 violations / 7197**; MC uniform `0.74088` (z = **+0.06**), Jacobi `0.89009` (z = **+0.54**), ratio `1.20139` |
| 4 | **Arm decomposition**, both directions `s_p<s_q` and `s_p>s_q` | Arm A fails **0** in every case; Arm B fails at exactly `2^{s_q−s_p}` — e.g. `p=113,q=41 (s=4,3)`: `0/1120` and `560/1120`; `p=193,q=97 (s=6,5)`: `0/4608` and `2304/4608` |

**Two of my own candidate formulas disagreed** (`2^{−|Δs|}` vs `1/(2 max s)`) and the
exhaustive check killed the second. Recorded because *the second one also "matched" the Monte
Carlo to 2 decimal places* — **a green control that was wrong.** Resolved only by the
exhaustive per-cell ground truth, never by the MC. (`factor-scratch/r50exp/lit2/truth.py`)

### 2.3 Cost

Pure-Python, `K=3000` per size. **A Jacobi symbol is 60–7000× cheaper than ONE modular
exponentiation** (128 bits: 0.2 µs vs 13.9 µs; 2048 bits: 1.2 µs vs 8349.7 µs).

Against a relation-finding phase costing **4798.6 modular multiplications per factor** (the
programme's own measured optimum, paper #525), the filter is **utterly free**. It is `O(log² n)`
against a phase that is 95% of the cost. **Expected total attempts 1.35 → 1.125.**

### 2.4 ⚠️ THE SCOPE CAVEAT — read this before repeating the result

This is a **1.2× on 5% of the cost**. The census's central measured fact is that
**relation-finding is 95%** (paper #529) and *is* the NFS. **This lever does not touch it.**
Its honest value is:

- it is a **real, exact, free** improvement to the programme's **one working method**;
- it is **the first non-trivial improvement to that method's success constant** found by
  anyone in this programme, and the census recorded that constant as *belonging to a different
  algorithm* and being **not the construction's** — so improving it does **not** make Stange's
  construction better *as a construction*;
- **34% fewer attempts** on a phase already at its optimal sampler is a **constant-factor**
  result, nothing more.

**It must not be reported as a factoring advance.** The census's own standing rule — *a table
row propagates, prose caveats do not* — makes this the single most likely place for this note
to be misread.

---

## 3. Priority 2 — does anything beat `20/27` at all?

**Nothing in the literature beats it, and nothing beats `8/9` that I found.**

- The `20/27` figure itself is **not stated as `20/27` anywhere I could reach.** It is the
  programme's derivation (paper #528). The classical literature bounds *different* quantities:
  Bourdon–Williams `.7`/`.7736`, Gerjuoy `90%`, `2Si(4π)/π ≈ .9499`, Ekerå `1 − 10⁻⁴`.
  **All of these are quantum phase-estimation bounds for a FIXED base** — a different
  probability from `P(v₂(ord_p g) ≠ v₂(ord_q g))`. **Reading any of them as a comparison to
  `20/27` would be a scope error of exactly the kind that cost this programme a FATAL.**
- **`8/9` is my number and appears nowhere.** The one title that asserts the Jacobi idea
  (SBPO 2025) is **unread** (§1) and is about Shor.
- **Optimization ceiling.** Since `(g/n)` is the *only* cheap deterministic function of `g`
  available without factoring, and the two Legendre symbols' product is its only content,
  **`8/9` is very likely optimal** among base distributions computable in poly(log n) time.
  Argument: success is symmetric under swapping `p,q`; any statistic computable without
  factoring is a function of `g mod n` invariant under... — **stated as intuition, NOT proved.**

---

## 4. Anything 2026

- **arXiv:2601.02518** (2026-01-05) — **the one real 2026 hit**, and it *does* use a
  non-uniform base (`b = a²`, odd order). Closest live neighbour (§1). Orthogonal, and it
  demonstrates the axis is being worked.
- **arXiv:2512.11004** (2025-12-11), **arXiv:2601.02518**, **arXiv:2510.19390**,
  **arXiv:2510.08432**, **arXiv:2507.07055**, **arXiv:2512.15330** — all retrieved and
  scope-checked. **All quantum/ML/pedagogical. None touches classical base selection.**
- Round-49's sweep already covered Stange / Hittmeir / Urroz / Dryło–Pomykała / Jeljeli /
  Boudot et al. / Dieulefait–Urroz. **Nothing added there in 2026.**

---

## 5. EMPTY REGIONS

Measured with a **User-Agent header** (without it eprint returns **403**, which is how a prior
agent concluded IACR was unreachable — the working route needs `User-Agent`, and `/search?q=`
works while `/api/` 404s).

### 5.1 ⭐ The classical base-distribution axis — **11 consecutive true zeros on IACR, 2 on arXiv**

| query (`eprint.iacr.org/search?q=`) | result |
|---|---|
| `success probability constant factoring 20/27` | **No results** |
| `v2 of the order of g` | **No results** |
| `weighted sampling base order finding` | **No results** |
| `biased base selection integer factorization` | **No results** |
| `quadratic nonresidue base improves factorization success` | **No results** |
| `rejection sampling base order finding probability` | **No results** |
| `conditional distribution base given Jacobi symbol factoring` | **No results** |
| `non-uniform choice of generator probability of splitting` | **No results** |
| `improve 20/27 factoring` | **No results** |
| `success rate of order-based factorization improve` | **No results** |
| `base choice affects smoothness of powers` | **No results** |

arXiv: `all:"base selection" AND cat:math.NT` → **totalResults = 0**;
`abs:"choice of base" AND abs:"multiplicative order"` → **totalResults = 0**.

**Why this is genuinely empty and not a database artifact:** the *positive control* works —
same route, same session, returns **80** results for `elliptic curve method base point` and
**22** for `Miller%27s+test+split`. So the route is live; the zeros are real. **Corroborated
independently by Bourdon–Williams: 0 matches for `uniformly|chosen at random|Jacobi|quadratic
residue` across 5227 lines of the sharpest bound in existence.** And Ekerå (2022) and
Cadavid et al. (2026), the two most recent practitioners, both *assume* uniform `g`.

**This is the emptiest axis found, and §2 is a result in it.**

### 5.2 ⭐ The *conditional* 2-adic law — the exact structural object behind §2

Queries `distribution of the 2-adic valuation of orders modulo p`,
`conditional law of v2 order given Legendre symbol`,
`equidistribution of powers of a chosen base modulo composite` → **all No results.**

The law `P(v₂(ord_p g) = k | s_p = j)` and its Legendre-conditioned version are the objects a
base-choice theory *would* be built on. Not indexed anywhere reachable. (Contrast: the law
itself is standard textbook group theory — `(g/p)=−1 ⟺ v₂(ord)=s` — so the emptiness is in
the *combination*, not in the ingredients.)

### 5.3 Non-uniform base × smoothness interaction

`base choice affects smoothness of powers` → **No results.** Stange's sampler attains its
optimality bound *under an equidistribution conjecture for `{g^x mod n}`*. **Whether the base
distribution changes the smoothness rate — and therefore whether §2's filter interacts with
the 95% phase — is untested and unindexed.** This is the natural follow-up and a genuine
second gap, not a formality.

---

## 6. Standing warnings for the next reader

1. **Do not report §2 as a factoring advance.** It is 1.2× on 5% of the cost (§2.4).
2. **Bourdon–Williams / Gerjuoy / Ekerå bounds are NOT comparable to `20/27`.** Different
   probability (quantum phase estimation, fixed base). This is a live scope-error trap.
3. **The SBPO 2025 paper (§1) is unread.** Title asserts the Jacobi idea for Shor. Identity
   confirmed; **contents not**. Do not cite its numbers.
4. **Bach 1990 and Miller 1976 are unread** — existence/venue confirmed only. Bach is the
   canonical prior-art check before publishing §2.
5. **`grep` for `20/27` finds nothing in the literature.** The programme's constant is its own
   derivation. That is not a defect, but it means there is no external anchor for it.
6. **A wrong formula of mine matched the Monte Carlo to 2 dp.** Only exhaustive per-cell
   enumeration separated them. *A green control that was wrong.*

**No commit. No GitHub issue. No paper.**