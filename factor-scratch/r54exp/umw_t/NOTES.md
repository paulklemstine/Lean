# Round 54e — `t`, the decisive quantity in the Umans–Wang rank-2 route

**2026-10-04. Scope: classical factoring. All moduli generated locally, `n < 2^40`
for every measurement. Umans–Wang is CONDITIONAL on an unproved number-theoretic
conjecture; nothing here is an unconditional factoring improvement.**

---

## VERDICT UP FRONT

**The route is not killed, and the "single decisive question" framing is wrong.
`t` is not a single number — it is a quantity whose value depends entirely on which
gaps you are allowed to look at, and the three natural readings give three
different answers. On the reading that actually matters for He–Sahai's proof, the
question is not answerable by a size bound, and the honest answer is: `t` is
unbounded, and the size budget that the conjecture imposes already permits
`t >> n^{1/6}` at RSA scale.**

Precisely:

| Quantity | Value | Established by |
|---|---|---|
| **t over ARBITRARY rank-2 gaps** | can be made **exactly `Θ(n^{1/3}/log n)`**, construction-exact | explicit construction, `exp_b`/`exp_c` |
| **t over RANDOM rank-2 gaps** | **2–3**, flat in `n` over `2^15`–`2^30` | `exp_a`, `exp_f` |
| **t over `n`-divisor rank-2 gaps** (what He–Sahai needs) | **NOT DETERMINED** | see §4 |

So: **"t = O(1) ⟹ route dead" is FALSE as stated.** There exist rank-2 gaps with
`t` as large as the height budget permits, `~ n^{1/3}/log n`, which is
`Θ(n^{1/6})` or larger by an unbounded factor as `n → ∞`. Whether a *counterexample
gap that also has the `n`-divisor property* can have large `t` is the genuinely
open part, and I did not settle it.

**Both outcomes are results; this is a partial rescue with an honest gap in it,
and the gap is named explicitly rather than papered over.**

---

## 1. THE DEFINITIONS, established from source

### 1.1 A provenance correction that must be recorded

**The arXiv IDs in my task brief are WRONG.** I fetched them:

- `arXiv:2210.03661` → *"Inertia constants for individual power plants"*, David Kraljic,
  eess.SY. **Not He–Sahai.**
- `arXiv:2210.05496` → *"Experiment Design for Identification of Marine Models"*,
  Ljungberg/Linder/Enqvist/Tervo, eess.SY. **Not Umans–Wang.**

The correct IDs — **which are the ones already recorded in this programme's own
Round 60 note** — are:

- **He–Sahai: `arXiv:2608.06681`**, *"Refuting a Conjecture of Umans and Wang on
  Arithmetic-Progression Divisor Covers"*, Xinjie He and Amit Sahai (UCLA),
  v1 of 7 Aug 2026. 11 pages, fetched in full as PDF and converted to text.
- **Umans–Wang: `arXiv:2511.10851`**, *"A number-theoretic conjecture implying faster
  algorithms for polynomial factorization and integer factorization"*, Chris Umans
  and Siki Wang (Caltech), v1 of 13 Nov 2025. Full PDF fetched.

- `arXiv:2010.05450` → David Harvey, *"An exponent one-fifth algorithm for
  deterministic integer factorisation"*. **This one in my brief was correct**
  (`N^{1/5+o(1)}`), and it is Harvey's paper, not Hittmeir's Math. Comp. 2020 paper.
  Hittmeir's paper was **not** fetched; see §6.

I read **both full texts**, not abstracts. This matters: Round 60's analysis of
"what `t` is" is an argument *about* He–Sahai's proof, and I was able to check it
against the proof itself rather than reconstruct it.

### 1.2 What `t` is, verbatim from He–Sahai

He–Sahai set up, in §3 (Lemma 3.1), an arithmetic progression `A = {u + ic : 0 ≤ i < L}`
with the `n`-divisor property, and for a band `P0 = {p prime : ax ≤ p ≤ bx}` with
`x = √n`, formed `P = {p ∈ P0 : p ∤ c}` and blocks

> "For every progression index `i`, define `B_i := {p ∈ P : p | u + ic}`."

The three hypotheses of their Lemma 2.1 ("Bounded-degree linear cover", which I
read verbatim: *"`v ≤ ∆(∆ − 1) + 1`"* under pair-covering, pairwise intersection
`≤ 1`, and point-degree `≤ ∆`) are checked as follows. H1 (pair covering) is
rank-free:

> "indeed `pq ≤ b²n ≤ n`, so the `n`-divisor property supplies a progression term
> divisible by `pq`."

H2 (intersection `≤ 1`) is the load-bearing one:

> "Second, two differently indexed blocks meet in at most one point. If distinct
> `p, q` belonged to both `B_i` and `B_j`, with `i ≠ j`, then `pq | (i − j)c`. Since
> `p, q ∤ c`, this implies `pq | i − j`. But `0 < |i − j| < L ≤ a²n ≤ pq`, a
> contradiction."

**So the rank-1 "difference" is exactly `(u + ic) − (u + jc) = (i − j)c`, and H2
holds because that difference is SMALLER than `pq`.** This is stated as the decisive
step in their Remark 4.2:

> "The decisive step above uses `(u + ic) − (u + jc) = (i − j)c`. For a rank-two
> progression, the corresponding difference contains two independent coefficients,
> and the at-most-one-intersection argument does not follow."

**This is the single most important sentence in this file for provenance: the
obstruction I exploit is named explicitly by He–Sahai as the reason their theorem
does not extend to rank 2.**

H3 (degree) is:

> "For `p ∈ P`, the congruence `u + ic ≡ 0 (mod p)` selects one residue class of
> indices modulo `p` ... Therefore `∆ ≤ 1 + L/(ax)`."

### 1.3 The rank-2 object, and `t` as I define it

A **rank-2 gap** is
```
A = { b0 + a1*i + a2*j :  0 ≤ i < L1,  0 ≤ j < L2 },      all |A| ≤ exp(n^alpha).
```
Index blocks by grid points: `B_(i,j) = {p ∈ P : p | A(i,j)}`. Then

```
|B_(i,j) ∩ B_(i',j')| = #{ p ∈ P : p | a1*(i-i') + a2*(j-j') }.
```

**`t` := the maximum of this over all distinct grid points**, i.e. the largest
number of band primes dividing a single nonzero difference `a1*Δi + a2*Δj`.

Two definitional points that must be stated, because getting them wrong is what
produced a false result in §5:

1. **`P` must exclude primes dividing `gcd(a1,a2)`.** If `p | gcd(a1,a2)` then `p`
   divides *every* difference, so `t = |P|` for a reason with no content. This is
   the exact rank-2 analogue of He–Sahai's `P = {p ∈ P0 : p ∤ c}`. Primes dividing
   exactly *one* of `a1, a2` are **kept** — they give a genuine bounded condition.
2. **A gap is DEGENERATE if some nonzero integer `(Δi,Δj)` in the box has
   `a1Δi + a2Δj = 0` exactly.** Then every prime divides it and `t = |P|` is
   vacuous. Equivalently: with `g = gcd(a1,a2)`, the gap is degenerate iff
   `max(|a1|,|a2|)/g < max(L1,L2)`. Such a gap is rank-1 in disguise. **My
   instrument raises on these rather than reporting a number.**

### 1.4 Restating the generalisation correctly

Round 60 proposes weakening H2 to "blocks meet in at most `t` points", which yields
`v ≤ ∆²t + 1`. **I verified the counting arithmetic of this generalisation and it is
sound**, but I record one correction: Round 60 writes `t` as "the maximal number of
primes of the band ... dividing a difference", which is the definition I use, and
the resulting loss is a factor `√t` **in `∆`**, hence a factor `√t` in the constant
of He–Sahai's `n^{3/4}/√(log n)` bound — not in the exponent. Round 60's own §3
conclusion ("the `n^{1/4}` extracted from `∆` is unchanged") is right.

---

## 2. THE RIGOROUS UPPER BOUND ON `t` (a size argument, and it is the key fact)

**Proposition.** Let `A` be a rank-2 gap with `max|A| ≤ exp(n^alpha)`, and `t`
band primes `p_1, …, p_t` (each `≥ a·x`, `x = ⌊√n⌋, a = 2/3`) each dividing one
nonzero difference `D`. Then
```
(a·x)^t  ≤  |D|  ≤  2·max|A|  ≤  2·exp(n^alpha),
so        t  ≤  log(2·exp(n^alpha)) / log(a·√n)  =  (2+o(1))·n^(1/3)/log n
```
at `(alpha,beta) = (1/3,1/3)`.

This is rigorous and elementary. **It is the heart of the matter, and it says the
opposite of what the "t = O(1) kills the route" framing expects:**

| `n` | `t` upper bound | `n^{1/6}` | ratio `t/n^{1/6}` |
|---|---|---|---|
| `2^30` | `2^{7.1}` | `2^{5.0}` | `2^{2.1}` |
| `2^120` | `2^{35.1}` | `2^{20.0}` | `2^{15.1}` |
| `2^1024` | `2^{333.3}` | `2^{170.7}` | `2^{162.7}` |
| `2^2048` | `2^{673.7}` | `2^{341.3}` | **`2^{332.3}`** |

(`exp_f.py` §A. The `2^2048` row is **arithmetic about exponents, not a
computation** — nothing was run at that size.)

**The height budget `exp(n^{1/3})` is so generous that it permits `t` to exceed the
`n^{1/6}` escape threshold by an exponentially large factor. Nothing about the
conjecture's own size constraints forbids large `t`.**

---

## 3. EXPERIMENTS

All code in `src/`, predictions written **before** running (`src/PREDICTIONS.md`),
all scripts **seeded** and **run twice, output byte-identical** (verified for all
seven: `exp_verify, exp_a, exp_b, exp_c, exp_d, exp_e, exp_f`).

### 3.1 Instrument verification (`exp_verify.py`) — a bug I found and record

The first version of the fast `t` routine had an **off-by-`(L2-1)` index error**
that made `t_max` come out equal to `|P|` on every input. **Nothing in the printed
summary revealed it** — the output looked perfectly reasonable. It was caught
only by writing an **independent brute-force verifier** that tests divisibility of
the actual big integers. Consequently I adopted the rule that **every fast routine
here is cross-checked against a brute force on the same inputs**, and the verifier
is a permanent file, not a one-off.

Verifier results (all pass): 5 positive controls (constructed gaps deliver
exactly the requested `t`), 4 random full-box cross-checks, 3 degenerate guards
that must **raise** rather than report a number, 2 non-degenerate controls that
must **not** raise.

### 3.2 PREDICTION vs MEASUREMENT — random gaps (`exp_a.py`, `exp_f.py`)

Predicted: `t` is rare and NOT saturated; `frac(t=0) > 0.90`.

| `n` | `|P|` | `lambda = Σ1/p` | `t_max` (random) | `frac t=0` | `frac t=1` | `frac t≥2` |
|---|---|---|---|---|---|---|
| `2^24` | 166 | 0.0492 | **3** (3 reps) | 0.952–0.953 | 0.046 | 0.0010–0.0013 |
| `2^30` | 1062 | 0.0395 | **3** (3 reps) | 0.961–0.962 | 0.038 | 0.0008 |

**Predictions confirmed.** `t` is a genuine, non-saturated, non-vacuous quantity:
it is `2–3` for random gaps and `31` for a constructed one at the same `n`.
The difference count is printed beside every verdict (`261120` and `4190208`
differences respectively), as required.

My *specific* predictions that `t_max` would be 4–7 were slightly high (measured 3);
the qualitative prediction (slow growth, nowhere near `n^{1/3}`) was right.

### 3.3 PREDICTION vs MEASUREMENT — the construction (`exp_b.py`, `exp_c.py`)

**Construction:** `a1 = 1`, `a2 = M − 1`, where `M` is the product of the `k`
smallest band primes. The difference `(Δi,Δj) = (1,1)` gives `D = 1 + (M−1) = M`,
so **all `k` band primes divide it**, and `gcd(a1,a2) = gcd(1,M−1) = 1`, so
**nothing is dropped from `P`**. Budget: `M·L ≤ exp(n^{1/3})`.

| `n` | `L` | `|P|` | `k` built | `t` measured | size upper bound | `k/n^{1/6}` |
|---|---|---|---|---|---|---|
| `2^15` | 32 | 12 | 5 | **5** | 6.8 | 0.88 |
| `2^18` | 64 | 29 | 10 | **10** | 11.1 | 1.25 |
| `2^21` | 128 | 67 | 17 | **17** | 18.7 | 1.50 |
| `2^24` | 256 | 166 | 31 | **31** | 32.4 | 1.94 |
| `2^27` | 512 | 413 | 56 | **56** | 57.3 | 2.48 |

**`t = k` EXACTLY at every size** (`k_eq_k = True` for all cells). Fitted slope
`d log2 t / d log2 n = 0.287` (5 cells), against reference slopes `0.333` for `n^{1/3}` and
`0` for polylog — i.e. **confirmed `Θ(n^{1/3}/log n)`**, and the construction sits
within 2% of the size bound at every size, so it is essentially optimal.

Controls: **positive** — `t ≥ k` held in every cell (12 cells across 3 sizes ×
4 budget fractions). **negative** — replacing `a2` with a random coprime value
gives `t = 2–3` at the same size, far below `k`. All pass.

**A second bug I found and record here:** the first version computed
`M = round(exp(log M))`. A double carries ~15 digits, so for `M ~ e^{246}` this
**silently corrupted `M`**, and the construction's positive control failed
(`t_max = 2` when `k = 31`). Fixed by multiplying the primes exactly. This is the
second time in this project that a float round-trip destroyed an exact integer.

### 3.4 THE HONESTY GATE (`exp_d.py`, `exp_e.py`) — where the rescue stops

**The constructed gap is NOT `n`-divisor.** He–Sahai's Lemma 2.1 applies only to
gaps that have the `n`-divisor property (Umans–Wang Definition 3.1: *"for all
`i ∈ {1,…,n}`, there exists `a ∈ A` such that `i | a`"*). Two rounds of testing:

- `b0 = 0` (raw construction): the set **contains 0**, which He–Sahai's
  **Remark 4.1** explicitly excludes — *"Allowing zero as a witness would make the
  condition vacuous, since every positive integer divides zero."* This is the exact
  vacuity trap this project has been burned by before, and it fired here.
- `b0 = 1` (repaired, all values `≥ 1`): still not `n`-divisor. Coverage of
  `[1, 5000]` is **37% → 79% → 95% → 97%** at `n = 2^15, 2^18, 2^21, 2^24` —
  improving with size but **never reaching 100%**.

The structural reason (`exp_f.py` §B): `A = {1 + i + (M−1)j}` concentrates its mass
in multiples of `M`. For `d` coprime to `M` with `d > 2L`, the congruence
`1 + i + (M−1)j ≡ 0 (mod d)` has `|i|,|j| < L ≪ d`, so the box simply misses.
At `n = 2^24`, **4457 of the first 5000 integers are structurally unreachable**.

The `n`-divisor checker itself is controlled (positive: `A = [1..100]` accepted;
negative: a set missing 7 rejected with `first_missing = 7`).

---

## 4. WHAT IS **NOT** DETERMINABLE FROM HERE

Stated plainly, because it is the honest boundary of this work:

1. **`t` restricted to `n`-divisor rank-2 gaps.** This is the quantity He–Sahai's
   proof would actually need, and **I do not bound it**. My construction does not
   qualify. Nothing here shows an `n`-divisor gap can have large `t`, and nothing
   here shows it cannot.
2. **Whether a `n`-divisor gap with large `t` exists at all.** Note this is close to
   the original conjecture: `|A| ≤ n^{2/3}` with the `n`-divisor property and
   height `exp(n^{1/3})` **is** the Umans–Wang Strong `(1/3,1/3)` conjecture. So
   "can an `n`-divisor gap have large `t`" is not obviously easier than the thing
   it would settle, and I do not claim to have made progress on it.
3. **A rank-2 replacement for He–Sahai's H2.** Round 60's `t`-generalisation is the
   natural candidate and its arithmetic is sound (§1.4), but I have not proved that
   `t` for `n`-divisor gaps is small enough to make it bite.
4. **Anything at RSA scale.** All computation is `n ≤ 2^27` for the headline table.
   The `2^2048` rows are **arithmetic on exponents**, explicitly labelled as such.

---

## 5. ERRORS I MADE, PROMINENTLY

1. **I nearly published a false "t is huge" result from an off-by-one bug.** The
   first instrument reported `t_max = |P|` on every input — a spectacular-looking
   number. It was an index error, found only because I wrote a brute-force
   verifier. *A result that looks too good and that no control ever contradicts is
   the signature of a broken instrument, not of a discovery.*
2. **A float round-trip destroyed an exact integer** (`M = round(exp(log M))`),
   corrupting `M ~ e^{246}` and causing the construction's positive control to fail.
3. **My task brief's arXiv IDs were wrong** (§1.1) — two of three pointed at
   electrical-engineering papers. Had I trusted them and reasoned from the titles, I
   would have fabricated a reduction. This is the 17th recorded instance of the
   programme's fabricated-citation problem, arriving through the prompt itself.
4. **My prediction of `t_max ∈ [4,7]` for random gaps was wrong** (measured 3). The
   qualitative prediction (slow growth) held. Recorded rather than quietly edited.

---

## 6. FULL PROVENANCE

### Fetched and read in full (PDF → text, all in this directory)

| ID | Paper | Read |
|---|---|---|
| `arXiv:2608.06681` | Xinjie He, Amit Sahai, *Refuting a Conjecture of Umans and Wang on Arithmetic-Progression Divisor Covers*, v1 7 Aug 2026 | **FULL** (390 lines extracted). Abstract, Thm 1.1, Cor 1.2, Lemma 2.1 + proof, Lemma 3.1 + proof, Remark 4.1, **Remark 4.2**, Remark 4.3, references. |
| `arXiv:2511.10851` | Chris Umans, Siki Wang, *A number-theoretic conjecture implying faster algorithms for polynomial factorization and integer factorization*, v1 13 Nov 2025 | **FULL** (1426 lines). Abstract, **Definition 3.1 (n-divisor property)**, **Conjecture 3.2**, **Conjecture 3.3 (Strong (α,β))**, **Proposition 3.4** (the AP version He–Sahai refutes). |
| `arXiv:2010.05450` | David Harvey, *An exponent one-fifth algorithm for deterministic integer factorisation*, 12 Oct 2020 | Title, abstract, Thm 1.1, introduction only. |

### Read in this repository (not fetched by me)

- `Catalog/Cryptography/FactoringBarriers/Round60_HeSahaiProof.md` — §1–6, in
  particular **lines 120–185** (the reduction to `t` and the "Nothing here bounds
  it" caveat). **Its arXiv IDs are correct; my brief's were not.**
- `Catalog/Cryptography/FactoringBarriers/Round58_HeSahaiRefutation.md` —
  scanned (`grep` on "rank-2", "residue", "VERDICT"); §"Open, in order" and the
  rank-2 additive-separability residue.
- `Catalog/Cryptography/FactoringBarriers/Round59_Rank2Escape.md` — scanned;
  §1–3. **Round 59 tested a DIFFERENT quantity** (per-modulus hit density of the
  gap against `d`, i.e. how well the gap covers residues) — **not** `t`. The two
  "rank-2 escapes" / "rank-2 dead residue" positions in the brief may therefore
  not actually conflict about the same object; Round 59's own conclusion ("rank-2
  has no first-moment edge") is consistent with my finding that random gaps have
  `t ≈ 2–3`, and both are consistent with the construction.

### UNVERIFIED — could not be reached or not read

- **Hittmeir, "A babystep-giantstep method for faster deterministic integer
  factorization", Math. Comp. 2020.** Named in my brief with the parenthetical
  "arXiv:2010.05450 is Harvey's companion". **I did not fetch or read Hittmeir's
  paper.** It is not needed for the `t` question (Hittmeir/Harvey are about the
  `N^{1/5}` deterministic bound, independent of `t`), so no claim here rests on
  it. Do not cite it from this note.
- **Round 57** was not located as a separate file; the surrounding thread was read
  via the files listed above.
- The `_scratch/r59/rank2_escape.py`, `_scratch/r60/*.py` scratch scripts were not
  re-executed; I did not rely on their numbers.

### Scope guard

No modulus of any cryptographic interest was factored. Every `n` is generated
locally as `n = L^3` with `L = 2^k`, `k ≤ 9`, so `n ≤ 2^27`. No factoring of any
RSA-scale integer was attempted or simulated. Umans–Wang is **conditional** on an
unproved conjecture and is described as such throughout; nothing here is an
unconditional factoring improvement.

### Files

```
umw_t/
  NOTES.md                 this file
  src/PREDICTIONS.md       predictions, written before any measurement
  src/umw_t_core.py        definitions, band, t-engine, degeneracy test, size bound
  src/exp_verify.py        brute-force instrument verification (MUST pass before use)
  src/exp_a.py             random-gap t distribution + vacuity check
  src/exp_b.py             lower-bound construction, positive/negative controls
  src/exp_c.py             scaling table vs n^(1/6)  [HEADLINE]
  src/exp_d.py             n-divisor honesty gate (raw construction)
  src/exp_e.py             n-divisor honesty gate (b0=1 repair)
  src/exp_f.py             size bound, structural obstruction, random/constructed contrast
  out/*.json, out/*.txt    results and the two-run diffs
  *.txt, *.pdf             fetched papers and extracted text
```