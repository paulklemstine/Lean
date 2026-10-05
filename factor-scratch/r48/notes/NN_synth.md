# NN — The synthesis nobody ran: Result A's conditioning on Result B's search

**Round 53 · orchestrator · `factor-scratch/r53exp/synth/` · 2026-10-04**
Code: `core.py`, `selftest.py` (**29/29 PASS, exit 0**), `exp_s1.py`, `exp_s2.py`,
`exp_s2b.py`, `exp_s3.py`, `exp_s4.py`, `verify_order/verify.py` (independent agent).
Predictions fixed before measurement; self-test written first; every detector has a
negative control.
**No commit, no issue, no paper.**

---

## 0. VERDICT

> ### The clean negative, and it is the informative one.
>
> **The transplant works, exactly.** Result A's `Jacobi(g/n) = −1` conditioning,
> moved verbatim from the base `g` to the number-field base `b`, reproduces
> `20/27 → 8/9` with ratio **exactly 1.2000**, on 11 per-modulus cells, at
> **q = 1** and zero cost. The 2-adic coupling is **real, large, and free on the
> number-field side** — which is the fact that makes the negative interesting
> rather than expected.
>
> **And it is worth exactly nothing.** For the relation condition
> `a² ≡ b^k (mod n)`:
>
> - **`k` even** — the construction is *already* free of any 2-adic barrier.
>   The base class changes **nothing**: root count **4.000 in 8/8 rows**, CRT
>   ratio flat at **1.01–1.23 with `|z| ≤ 2.23` in 5/5 sizes under both rules**
>   (finite-sampling scatter, sd 0.11–0.69). `s_C/s₀ = 1`,
>   `GAIN = 1`. **Legal, free, rejects nothing, gains nothing.**
> - **`k` odd** — the conditioning is **annihilating**. `P(p) = P(q) = P(n) = 0`
>   **exactly, across every modulus, at every size** (0 roots in 40/40 moduli).
>   `s_C = 0`, `GAIN = 0`.
>
> **So `GAIN ∈ {0, 1}` for every `(k, rule)`. Never `> 1`.** The two results do not
> combine, and the reason is not a phase separation that might be an artefact:
>
> > **The coupling is real and free; it is attached to a variable the polynomial
> > search never reads.** `v₂(ord_p b) ≠ v₂(ord_q b)` is a real, measurable,
> > Jacobi-controllable event on the number-field side — and it is *orthogonal*
> > to the search variable `a`. The barrier the conditioning removes **is not
> > present on the number-field side in the first place**, so there is nothing
> > for it to remove.
>
> **A retraction is also recorded (§6): `MM_design.md` §3c's `ord_n(g)/n = 1.000`
> is an artefact of a broken instrument, and its companion "verified 3/3" is a
> vacuous assertion.** The qualitative conclusion survives on corrected numbers.

---

## 1. THE `q`-TERM FIRST, BEFORE ANY MEASUREMENT

The ordering is the point of Result A, so it comes first.

```
GAIN = (s_C/s₀) · q / (1 + q·c_cond/c_gen)
```

| arm | rejects? | `q` | best `GAIN` (`s_C/s₀=2`, `c_cond=0`) | verdict |
|---|---|---|---|---|
| **`Jacobi(b/n) = −1` on the base** | **no** | **1.0** | **2.00** | **LEGAL — the only unknown is `s_C/s₀`** |
| `Jacobi(b/n) = +1` on the base | no | 1.0 | 2.00 | legal |
| uniform `b` (baseline) | no | 1.0 | 2.00 | legal |
| filter `b` on `(b/p)₃ = +1` | yes | 1/3 | 0.50 | **KILLED algebraically** |
| filter `b` on `(b/p)₂ = +1` | yes | 1/2 | 0.67 | **KILLED algebraically** |
| filter `a` on a Jacobi sign | yes | 1/2 | 0.67 | **KILLED algebraically** |

**The Jacobi-on-`b` arm is legal by construction, not by measurement.** `Jacobi(b/n)`
is a property of the *base*, chosen once per attempt; it rejects no candidate
from any search stream, because the sieve **generates** survivors and never
discards them. So `q = 1`, `c_cond = 0` (`O(log n)` Euclidean algorithm,
`60–7000×` cheaper than a modular exponentiation per `II_baseg.md` §3), and
**`GAIN = s_C/s₀` exactly**. Everything below measures the single remaining
unknown.

---

## 2. S1 — THE CANDIDATE TABLE

Three questions per candidate: **(i)** computable from `n` alone? **(ii)** free
(`q = 1`)? **(iii)** actually coupled to the 2-adic structure, or merely
correlated with it?

| # | candidate | (i) no-factor | (ii) `q=1` | (iii) 2-adic coupled | verdict |
|---|---|---|---|---|---|
| **1** | **`Jacobi(b/n) = −1`** | **YES** — Euclid, `O(log n)` | **YES** | **YES, and the coupling is exactly `lam_p = 0` vs `lam_q = 0`** | **SURVIVES S1. Dies in S2.** |
| 2 | `k`-th power residue symbol `(b/p)_k`, `k ≥ 3` | **NO** — proved by non-injectivity, §2.1 | — | YES in principle | **REFUTED** |
| 3 | choice of the degree-`k` polynomial `f` | YES | YES | **NO** — coupled to the factorisation pattern, not to `lam` (§2.2) | **REJECTED as a 2-adic condition** |
| 4 | `b`-mod-`p` discrete-log parity | NO — needs `p` | — | YES | **REFUTED** (it *is* candidate 2) |
| 5 | `v₂(n−1)`-aware policy | YES | YES | weakly | already measured `z = −0.23` in `II_baseg.md`; not revisited |

### 2.1 Candidate 2 is refuted by an explicit collision, not by assertion

A character of `(ℤ/nℤ)*` computable from `n` alone must be **symmetric** under
`p ↔ q`. For the quadratic character that is harmless — the two local signs
carry only their **sum**, and one sign *is* the sum, so Jacobi is exactly the
information content. For `k = 3` the two local characters live in `μ₃`, and the
product is not injective.

**Measured** (`exp_s4.py`): over 26 moduli with `3 | p−1` and `3 | q−1`,
**935 pairs of bases** share the same symmetric product `(b/p)₃·(b/q)₃` but have
different individual characters. Example, `n = 2479 = 37·67`:

```
b=2 -> ( (b/p)_3, (b/q)_3 ) = (1,1)      b=3 -> (2,0)      products both ≡ 2 (mod 3)
b=2 -> (1,1)                            b=5 -> (2,0)      products both ≡ 2 (mod 3)
```

Two bases indistinguishable from `n` alone, with different cubic characters.
**So `(b/p)₃` is not computable without factoring, and Jacobi is the *unique*
free character — not by a theorem I am asserting, but by the mechanism that
makes it work at all.** This is the sharpest form of `II_baseg.md` §4's
Version-B argument.

### 2.2 Candidate 3 is legal but not coupled

Choosing `f` for irreducibility is free and `q = 1`. But it references the
**factorisation pattern** (the discriminant, the Frobenius cycle type), never
`v₂(p−1)`. Measured on a form that *can* be irreducible (random monic cubic
`a³ + c₁a + c₀` mod `p`): `P(irreducible)` spans **[0.100, 0.700]** across 21
cells with mean **0.3425** against the theoretical **1/3**, and the spread
tracks **cell size** — finite-sample noise, not 2-adic structure.

> ⚠️ **My first form was degenerate and the control caught it.** I used the
> standard NFS form `f(a,b) = (a+b)³ − b³`, whose root `a = 0` satisfies
> `(0+b)³ − b³ = 0` **identically**. So `P(irreducible) = 0.0000` in *every*
> cell, and the table could not distinguish "carries no 2-adic information"
> from "is never irreducible". That is not a code bug — it is the recorded
> `phi-map-forces-f-reducible` pathology, re-observed — but **as a test it
> measures nothing.** Re-run on a non-degenerate form before quoting.

---

## 3. S2 — THE MEASUREMENT

### 3.1 The transplant reproduces exactly

`exp_s1.py`, 150 fresh 26-bit semiprimes × 40 base-trials, **N = 5400 per rule**,
**per-cell 2-adic reporting (`p_split`), never a pooled average alone**:

| cell `(a,b)` | uniform obs | uniform pred | `jac_neg` obs | `jac_neg` pred |
|---|---|---|---|---|
| **(1,1)** | 655/1320 = 0.4962 | 0.5000 | **1320/1320 = 1.0000** | **1.0000** |
| (1,2) | 493/640 = 0.7703 | 0.7500 | 480/640 = 0.7500 | 0.7500 |
| (1,3) | 604/680 = 0.8882 | 0.8750 | 605/680 = 0.8897 | 0.8750 |
| (1,4) | 107/120 = 0.8917 | 0.9375 | 112/120 = 0.9333 | 0.9375 |
| (1,6) | 159/160 = 0.9938 | 0.9844 | 157/160 = 0.9812 | 0.9844 |
| (2,1) | 811/1080 = 0.7509 | 0.7500 | 818/1080 = 0.7574 | 0.7500 |
| **(2,2)** | 279/440 = 0.6341 | 0.6250 | **440/440 = 1.0000** | **1.0000** |
| (2,3) | 182/240 = 0.7583 | 0.8125 | 181/240 = 0.7542 | 0.7500 |
| (3,1) | 325/360 = 0.9028 | 0.8750 | 318/360 = 0.8833 | 0.8750 |
| **(3,3)** | 107/160 = 0.6687 | 0.6562 | **160/160 = 1.0000** | **1.0000** |
| (4,1) | 190/200 = 0.9500 | 0.9375 | 192/200 = 0.9600 | 0.9375 |

Pooled: uniform **0.7244** (between-cell sd 0.1510), `jac_neg` **0.8857** (sd
0.1029). **Ratio 1.2226** against the theoretical **1.2000** — the excess is the
sampling error, and the diagonal came back **1320/1320, 440/440, 160/160,
literally every trial**, as `SUCC_jac(a,a) = 1` predicts.

**The gain is on the diagonal and it LOSES off it** — exactly the per-cell shape
`II_baseg.md` §2 reports, reproduced independently. Quoting only the pooled
1.22× would hide a regression on 2/3 of the weight.

**Instrument calibration, before any cell above is quoted:** identical input,
fixed seeds, run twice → **13 cells, max swing 0.0000%, identical = True**.
(Round 51's agent measured **+22%** on identical input; round 52's **0.00%**.)

### 3.2 ★ The mechanism: solvability sees `lam_p = 0` and *nothing else*

The number-field relation condition is `a² ≡ b^k (mod p)`. Write
`lam_p = v₂(p−1) − v₂(ord_p b)`. Then, **exhaustively verified on 23 004
(base, `k`, prime) triples**:

```
b^k is a quadratic residue mod p   <=>   NOT( lam_p = 0 AND k odd )
```

| `lam_p` | `k` odd | N | `P(b^k is QR mod p)` | predicted | agree |
|---|---|---|---|---|---|
| **0** | no | 5871 | 1.0000 | 1.0000 | 5871/5871 |
| **0** | **yes** | 5871 | **0.0000** | **0.0000** | 5871/5871 |
| 1 | no | 4203 | 1.0000 | 1.0000 | 4203/4203 |
| 1 | yes | 4203 | 1.0000 | 1.0000 | 4203/4203 |
| 2 | no | 1356 | 1.0000 | 1.0000 | 1356/1356 |
| 2 | yes | 1356 | 1.0000 | 1.0000 | 1356/1356 |

**This is the whole negative in one line.** The NFS search's dependence on the
2-adic structure of `b` passes through the **single bit `lam_p = 0`** — the
quadratic character — and **every higher 2-adic digit is invisible to it.**

> ⚠️ **I first wrote this condition as `k_p = 0` instead of `lam_p = 0`, and the
> table refuted itself loudly**: the `k_p = 0 / k odd` cell returned 1.0000
> against a prediction of 0.0000, **0/3978**. That is the **identical `lam`-vs-`k`
> confusion that was bug #1 of `II_baseg.md`**, caught here by the per-cell
> control rather than by a pooled rate — which is the entire argument for making
> that control mandatory. At `p = 101` (`v₂(p−1) = 2`) a non-residue has
> `k_p = 2`, so indexing on `k_p = 0` selects entirely the wrong cells.

### 3.3 The two arms of `GAIN`

**`k` EVEN — legal, free, and worth nothing.** Root count of
`a² = b^k (mod n)` is **4 for every base**, in every cell:

| bits | uniform | `jac_neg` |
|---|---|---|
| 16 | 4.000 | 4.000 |
| 18 | 4.000 | 4.000 |
| 20 | 4.000 | 4.000 |
| 24 | 4.000 | 4.000 |

So `s_C/s₀ = 1`, **`GAIN = 1.000`**. The search sees the same set; the base
class is invisible to the quantity the search enumerates.

**`k` ODD — annihilating, not merely harmful.**

| bits | rule | `P(p)` | `P(q)` | `P(n)` | ratio | roots / moduli |
|---|---|---|---|---|---|---|
| 12 | uniform | 0.0210 | 0.0313 | 0.0006 | 1.172 | 6/24 |
| 12 | **`jac_neg`** | **0.0000** | **0.0000** | **0.0000** | **0** | **0/24 — ANNIHILATED** |
| 13 | uniform | 0.0222 | 0.0240 | 0.0006 | 0.917 | 4/24 |
| 13 | **`jac_neg`** | **0.0000** | **0.0000** | **0.0000** | **0** | **0/24 — ANNIHILATED** |
| 14 | uniform | 0.0090 | 0.0093 | 0.0001 | 0.936 | 5/24 |
| 14 | **`jac_neg`** | **0.0000** | **0.0000** | **0.0000** | **0** | **0/24 — ANNIHILATED** |

`Jacobi(b/n) = −1` puts a non-residue on one side; for odd `k`, `b^k` is a
non-residue there, so **that prime admits no `a` at all**. `P(n) = 0` *exactly*,
at every size, in **40/40 moduli**. `s_C = 0`, **`GAIN = 0`**.

### 3.4 ★ The apparent 1.32× win is noise, and the permutation test says so

Section 3.3's cousin — the usable-relation rate per root — produced, for `k = 2`:

| bits | uniform | `jac_neg` | ratio | power |
|---|---|---|---|---|
| 16 | 39/160 = 0.2437 | 39/160 = 0.2437 | 1.000 | NO |
| **18** | 22/160 = 0.1375 | 29/160 = 0.1812 | **1.318** | **NO** |
| **20** | 24/160 = 0.1500 | 27/160 = 0.1688 | **1.125** | **NO** |

**A 1.32× win would exceed Result A's entire 1.2×.** Every row is
`power = NO` (`E[hits] < 20`), and §3.2 says the effect must be **exactly zero**
for even `k`. Round 51's pooled 1.155× "win" had precisely this shape.

**Tested as a null rather than believed** (`exp_s2b.py`). The permutation test is
exact: the two arms share moduli *and* roots; only the **label** of which bases
count as conditioned moves.

```
replicates        : 40
permutations      : 240
REAL   ratio      : median 1.231   [0.583, 2.000]   (5-95%)
PERMUT ratio      : median 1.062   [0.391, 2.167]   (5-95%)
median real ratio inside permutation band [0.391, 2.167]?   True
permutation p-value  P[perm >= real] = 0.354
```

**The real labelling is indistinguishable from relabelling. It is noise, and
`s_C/s₀ = 1` stands.**

**Positive control — the instrument can fire.** The same statistic on `k = 3`
gives **0 roots in 120/120 moduli** where `k = 2` gives 480 roots and a 0.1458
rate. It cleanly separates a total mechanism-level effect from the §3.4 noise
floor, so the null in §3.4 is a real null and not a broken instrument.

> ⚠️ Two instrument failures here, both caught, both of the dangerous kind.
> **(i)** I sampled `a` uniformly mod `n` and waited for `n | a² − b^k`, which has
> probability `~4/n`; at 20 bits a 6000-trial window collects *nothing*, and the
> first version reported `NO TRIALS` on all 8 rows — which would have shipped as
> a fabricated negative about the pipeline. **The congruence must be
> *enumerated*** (≤ 4 roots, by CRT from local square roots), not sampled.
> **(ii)** I then divided by a *conditional* trial count, which turned a `1e-5`
> unconditional rate into a flattering "40% success". Reported as a rate of what.

---

## 4. S3 — CONFRONTING RESULT C

Result C is the strongest prior objection and it is **not** evaded. It applies,
and it applies *harder* on the number-field side than where it was measured.

### 4.1 It is a theorem here, not a regularity

`MM_design.md` §3b measured CRT-independence at ratio 0.93–1.10 and called it
clean independence. **On this side it is exact**, because
`(a,b) ↦ (a mod p, b mod p, a mod q, b mod q)` is a **bijection** of `(ℤ/nℤ)²`.

Verified by **exhaustion** — every `(a,b)` pair, no sampling, so no sampling
error can hide behind:

```
12 semiprimes n = pq < 46:  [6, 10, 14, 15, 21, 22, 26, 33, 34, 35, 38, 39]
k in {2,3}:   24 (n,k) cells, 0 departures from 1.000
[PASS] exact to machine precision on every cell
```

> ⚠️ **This test was vacuous on its first run and printed `[PASS]` anyway.** I
> filtered `if any(n % d == 0 ...): continue` — skipping the **composites**,
> keeping primes — and then required two prime factors per `n`. Net: **0 cells
> tested, 0 departures, confident-looking PASS.** The tell was in the output the
> whole time (`0 cells` beside a `PASS`), and it took reading the arithmetic
> rather than the verdict. **A vacuous row that reports success is worse than no
> row**, because it is believed.

### 4.2 Does conditioning the base move the coupling? No.

CRT ratio, **computed per base then averaged**, pooled over 8 moduli × 3 bases:

| bits | `k` | rule | bases | annihilated | ratio | z |
|---|---|---|---|---|---|---|
| 12 | 2 | uniform | 24 | 0 | 1.111 | +2.23 |
| 12 | 2 | `jac_neg` | 24 | 0 | 1.015 | +0.32 |
| 13 | 2 | uniform | 24 | 0 | 1.041 | +0.94 |
| 13 | 2 | `jac_neg` | 24 | 0 | 1.014 | +0.62 |
| 14 | 2 | uniform | 24 | 0 | 1.232 | +1.64 |
| 14 | 2 | `jac_neg` | 24 | 0 | 1.027 | +0.48 |
| 15 | 2 | uniform | 24 | 0 | 1.018 | +0.26 |
| 15 | 2 | `jac_neg` | 24 | 0 | 1.094 | +1.32 |
| 16 | 2 | uniform | 20 | 0 | 1.049 | +0.40 |
| 16 | 2 | `jac_neg` | 21 | 0 | 1.105 | +0.81 |
| 12–16 | 3 | `jac_neg` | **0** | **24** | — | **ALL ANNIHILATED** |

For even `k`, uniform and `jac_neg` sit on the same null, `|z| ≤ 2.23`, and the
**per-base scatter (sd 0.11–0.69)** is finite-sampling — the same scatter Result
C reported at 0.93–1.10. **For odd `k`, `jac_neg` annihilates every base**, which
is §3.3, not a coupling gain: a ratio of 0 arising because `P(n)` is identically
0 is the CRT product being zero, not a departure from CRT.

> ⚠️ **My first estimator pooled raw counts across bases and then formed one
> ratio — a biased estimator — and it produced a spurious `z = +5.94` at 13 bits.**
> Bases differ in `P(n|V)` by orders of magnitude (for odd `k`, some are
> identically 0), so `(mean P(p))·(mean P(q))/(mean P(n))` is **not** the mean of
> the per-base ratios, and the distortion is largest exactly in the cells of
> interest. **CRT-exactness is a per-base statement**, so the estimator must be
> per-base, with annihilated bases *counted and reported* (`annih` column) rather
> than dropped — dropping them silently is what made the first version look
> significant.

### 4.3 ★ Result C does not apply — but not for the reason one would expect

**The natural reading of Result C is wrong, and the truth is stronger.**

Result C says a *polynomial condition* carries no 2-adic coupling. The
synthesis question presumed the 2-adic structure lives *in the polynomial*. On the
number-field side it does not — it lives in `b`. So the right question is not
"does the polynomial couple?" but **"does the search read `b`'s 2-adic
structure?"** Measured, both halves:

**(1) The search does NOT read it.** Root count is 4.000 for every base at every
size (§3.3). CRT ratio is flat in the base class (§4.2).

**(2) But the coupling is NOT absent — it is large, real, and free:**

| rule | `P(v₂(ord_p b) ≠ v₂(ord_q b))`, N = 400, 24-bit |
|---|---|
| uniform | 0.7625 |
| **`jac_neg`** | **0.8850** |

> ### So the phase separation is **not** an artefact of where the coupling was looked for.
> ### The coupling is present on the number-field side, controllable for free at
> ### `q = 1`, and **orthogonal to the search variable**. Result C and this note
> ### agree; they simply describe the orthogonality from opposite ends.

**The barrier Result A removes is not present on the number-field side to begin
with.** There is no `20/27`-type per-attempt Bernoulli to lift: the NFS relation
rate is governed by **smoothness**, not by a 2-adic order statistic. So there is
no rate for a free condition to raise, and `s_C/s₀ = 1` is not a failure of the
trick — it is the absence of a target.

---

## 5. S4 — THE OPEN CONSTRUCTION PROBLEM, PRECISELY

> ### **A construction with both properties must make its success event depend on a
> ### local order-statistic of the base that (i) is a quadratic character, so it is
> ### controllable from `n` alone at `q = 1`, AND (ii) enters the relation condition
> ### through a quantity that is NOT already determined by `b mod p` — because every
> ### function of `b mod p` alone is CRT-separated from `b mod q`, and a search that
> ### is polynomial in its index is exactly a function that can only ever see the
> ### joint residue.**
>
> Concretely: **the 2-adic advantage must live in the KERNEL of what the sieve
> index can see, not in the base it is sieved against** — a periodic
> sub-structure in the exponent, as `MM_design.md` §4's third escape route
> already names. **No choice of `b`, and no choice of `f`, can do it.**

That is the single most useful sentence this round leaves behind, and it is a
sharpening rather than a repetition: it says the escape route must live in the
*exponent's* period, because that is the one place the polynomial search does not
already decompose CRT-wise.

---

## 6. ⚠️ RETRACTION: `MM_design.md` §3c's `ord_n(g)/n = 1.000`

Found while building the instrument for this round. Verified independently
(`verify_order/verify.py`, three implementations — λ-strip, baby-step/giant-step,
and `sympy.n_order` — cross-validated at **0 mismatches on 496 random `(n,g)`
pairs, 12–24 bits**).

### 6.1 The bug

`r52exp/design/dcore.py::order_mod` starts from `order = m` and strips prime
factors of `m`. But `ord_m(a) | λ(m) = lcm(p−1,q−1)` for `m = pq`, so `m` is not a
multiple of the order, **the strip test never fires, and the function returns `m`
unchanged.** Measured: **`order_mod(g,n) == n` on 496/496 pairs, zero exceptions.**

It is arithmetically *forced*: at the call site (`exp_d1.py:223`) it is invoked on
the **primes**, where the only strip test is `pow(g,1,p) == g == 1`, false for
`g ≠ 1`. So it returns `p` and `q`, and `lcm(p,q) = pq = n` **exactly**.

### 6.2 Every reported value is exactly `n` — which is impossible for an order

| bits | reported `ord_n(g)` | `= p·q`? | `λ(n)` | true `ord_n(5)` | true ratio |
|---|---|---|---|---|---|
| 16 | 40 301 | 191·211 ✓ | 3 990 | **665** | **0.0165** |
| 20 | 761 029 | 787·967 ✓ | 126 546 | 126 546 | 0.1663 |
| 24 | 11 865 251 | 3257·3643 ✓ | 5 929 176 | 539 016 | 0.0454 |
| 28 | 202 715 707 | 12739·15913 ✓ | 33 781 176 | 33 781 176 | 0.1666 |

Since `λ(n) < n` always, **`ord_n(g) = n` is arithmetically impossible.** These
are not near-misses; they are the modulus.

The header's **"798×, 1813×, 5334× the sieve limit"** traces to the same
artefact (51067/64, 116003/64, 341371/64 = `lcm(223,229)`, `lcm(311,373)`,
`lcm(541,631)`). **Sharpest single correction: at 16 bits the true period is
665 — 10× the sieve limit, not 630×. Overstated ~63×.**

### 6.3 A second, independent defect: the "verified 3/3" is vacuous

`exp_d1.py:236` asserts periodicity via
`all(hits[i]==hits[i+T] for i in range(0, W-T))` with `W = min(2T, 20000)`.
At 16/18/20 bits, `T ≈ 5·10⁴–3·10⁵ > W`, so **`range(0, W−T)` is empty and
`all([])` is vacuously `True`.** All three published `periodic_at_ord_n: true`
entries never tested anything — and `d1.json` itself records
`"spans_two_periods": false` beside them.

**The periodicity claim is nonetheless true**, when properly tested: with a
window spanning ≥ 2 periods, **15/15 periodic at the TRUE `ord_n(g)`**, and
**0/15 had any period ≤ 64**. So the mechanism is real; the verification of it
was empty.

### 6.4 What survives, and on what grounds

| bits | true `ord_n(g)` | /64 | /400 |
|---|---|---|---|
| 16 | 7 770 | 121 | 19 |
| 20 | 261 924 | 4 093 | 655 |
| 24 | 5 548 596 | 86 697 | 13 871 |
| 28 | 78 298 028 | 1 223 407 | 195 745 |
| 32 | 1 555 024 484 | 24 297 258 | 3 887 561 |

**"Period ≫ sieve limit, worsening with `n`" survives** — at 28 bits the median
true period is ~3.4·10⁷ (≈530 000× the limit) and the minimum over 12 samples was
2.05·10⁶ (≈32 000×), growing ~linearly in `n`. **But it does not survive verbatim
at 2^16**, where the true period can be 665–3230, i.e. only **10–50×** the limit.

**Blast radius: narrow.** `dcore.order_mod` is used in exactly one place
(`exp_d1.py:223`). **Unaffected:** the `20/27` barrier, M1 sieveability, the
`q = 1` identity, CRT exactness, `p−1 0/216`, D2c, and this note's every
conclusion. **Poisoned:** `ord_p_g`, `ord_q_g`, `ord_n_g`, `ord_n_over_n`, and
the printed sieve-limit multiple.

> **Adjacent, unaudited:** `r48/exp/02_h1_h2_smoothness.py:38 ord_in_cyclic`
> carries the **identical** starting-multiple bug (`o = M`). Same defect class,
> different file, downstream use not checked.

---

## 7. CITATIONS

`WebSearch` **fabricates citations on this host** (16 recorded instances) and was
**not used at any point**. Routes used: `export.arxiv.org/api/query`, ePrint
search, zbMATH Open API, Crossref (incl. **complete volume TOCs by ISBN**),
OpenAlex, and **direct fetch of OA PDFs** — routes on which **dblp hangs**,
Springer returns 403, and `ams.org` serves cookie HTML instead of the PDF.

**This round found two further phantoms (§7.1, §7.1b), both of which I supplied
to the verification agent myself as candidate leads.** The tally on this host is
therefore **18**, and the failure mode is now bidirectional: not only does the
retriever invent, **the asker invents and the verifier launders the guess into a
checked-looking verdict.** A verification brief must carry only citations some
source already asserts.

**Record for the count: verified against full text, not metadata.** The
quadratic-character mechanism below rests on **five downloaded and read full
texts**, and the "index `2^r`" negative on **eight**.

### 7.1 ★ "Schnorr–Seysen–Bauer" is a PHANTOM — do not cite it

The name is a **fusion of two real, unrelated things**.

- **NOT FOUND as a joint paper.** zbMATH returns 2 hits for "Schnorr Seysen",
  both **single-author Martin Seysen** papers. arXiv: **0 results** for
  `"Schnorr-Seysen"` and for `"Schnorr" AND "Seysen"`. OpenAlex's full author list
  for Seysen (20 works) contains **zero** coauthored with Schnorr or Bauer.
  ePrint: **no results**.
- **What IS real:** M. **Seysen**, *A probabilistic factorization algorithm with
  quadratic forms of negative discriminant*, Math. Comp. **48** (1987) 757–780
  (zbMATH 4004252, DOI `10.2307/2007842`) — and this is the **binary
  quadratic-form / class-group** method, *not* a QS lattice paper. Its thesis
  (Frankfurt, 1984; zbMATH 3879003) builds on **C. P. Schnorr, J. Algorithms 3
  (1982) 101–127** (zbMATH 3762131, DOI `10.1016/0196-6774(82)90012-8`).
- **"Bauer" is unexplained — NOT DETERMINABLE.** I could not identify which
  Bauer, or whether the name refers to any paper at all.
- **The claimed gain constant is NOT DETERMINABLE.** No full text of any
  Schnorr–Seysen item was reachable (Springer/JSTOR paywalled; zbMATH carries no
  English review for 3762131). "√(m/2)" was **not found anywhere**.
- **Scope trap:** **"Coppersmith–Odlyzko–Schroeppel" is real but is a
  DISCRETE-LOGARITHM algorithm**, *Discrete logarithms in GF(p)*, Algorithmica
  **1** (1986) 1–15 (zbMATH 4025541). Confirmed as a factoring citation by **two**
  zbMATH reviews (Schirokauer–Weber–Denny, ANTS-II LNCS 1122; Weber, ASIACRYPT
  LNCS 1403) — **both explicitly about discrete logarithms.** It has **no**
  connection to factoring an RSA modulus or to QS lattices. **Do not cite COS for
  factoring.**

### 7.1b ★★ A SECOND PHANTOM, PROVEN FALSE (not merely unverifiable)

**"Coppersmith, *Two-dimensional lattice based cryptanalysis*, ANTS-I, LNCS 877,
pp. 41–55" does not exist.**

I first recorded this as "the chapter is ANTS-I LNCS 877, not *Des. Codes
Cryptogr.*; page range NOT DETERMINABLE." **That was wrong, and in the
dangerous direction — it left a fabricated citation standing with a caveat
attached.** The verification closes it:

- The **complete ANTS-I table of contents** was pulled from Crossref by ISBN
  (`filter=isbn:9783540586913`, 36 records = 35 chapters + book record).
  **ZERO** of the 35 chapters has Coppersmith in any author field.
- **pp. 41–55 are demonstrably occupied by other papers:** Dodson & Haines (41),
  Paulus (42), Couveignes & Morain (43–58). *There is no room.*
- Corroborating negative: Coppersmith's complete zbMATH bibliography
  (**137 records**, none in ANTS / LNCS 877), with 1995–97 output fully
  enumerated.
- ANTS-I identity: *Algorithmic Number Theory*, First International Symposium,
  **Ithaca, NY, May 6–9 1994**, ed. Adleman/Huang, DOI `10.1007/3-540-58691-1`.
  **`LNCS 877` IS ANTS-I (1994)** — confirmed twice via zbMATH, including the
  volume record *"Lect. Notes Comput. Sci. 877, ix, 323 p. (1994)."*

> **Provenance flag, recorded because it nearly propagated.** A sub-agent on the
> verification asserted **"LNCS 877 is ANTS-II (1996)."** That is **wrong** —
> ANTS-II is ed. Henri Cohen, DOI `10.1007/3-540-61581-4`, ISBN 9783540615811,
> and it is the volume containing Elkenbracht-Huizing (**LNCS 1172**). The
> sub-agent's *conclusion* was right and the volume claim was wrong, which is the
> exact failure mode of this programme: **a correct conclusion laundered through
> a fabricated detail.** The two ANTS volumes must not be conflated in either
> direction.

**Provenance of both phantoms is worth recording.** I supplied both names
("Schnorr–Seysen–Bauer", "Coppersmith two-dimensional") **to the verification
agent myself, as candidate leads.** Neither came from a cited source. So this is
the `fabricated-citations-propagate-agent→subagent` pattern recurring **with me
as the origin**: plausible-looking author strings are manufactured by the asking,
not retrieved by the answering. **A verification brief is not a safe place to
guess a citation — it launders the guess into a checked-looking verdict.**

**The Coppersmith paper that genuinely contains multiple-NFS quadratic-character
work** is *Modifications to the Number Field Sieve*, **J. Cryptology 6**(3)
(1993) 169–180, DOI `10.1007/bf00198464` (Crossref + zbMATH 480520).

### 7.2 What IS verified, with a verbatim quote — and its STANDARD NAME

The quadratic-character rows in NFS linear algebra are **real**. **Five full texts
were downloaded and read**, not one: Elkenbracht-Huizing (ANTS-II 1996 and her
Nieuw Arch. Wiskunde historical paper), Cavallar (ANTS-IV 2000), Cavallar et al.
(*RSA-512*, EUROCRYPT 2000), Kleinjung 2016, and Briggs 1998.

**★ The standard name is "quadratic character base", and it is Briggs's.** M.
Briggs, *An Introduction to the General Number Field Sieve*, MSc thesis, Virginia
Polytechnic Institute 1998, §4.3 (free full text, VTech):
[Landing page](http://hdl.handle.net/10919/36618)):

> "Each binary vector e(a,b) is also augmented with information relating a
> particular `a + bθ` to **the quadratic character base** … If there are `k`
> primes in the rational factor base, `l` first degree prime ideals of `Z[θ]` in
> the algebraic factor base, and `m` first degree prime ideals in **the
> quadratic character base**, then each e(a,b) will be comprised of `1 + k + l + m`
> binary bits…"
>
> "For a fixed `(s, q)` pair the corresponding bit in e(a,b) is set to 0 if the
> **Legendre symbol** `((a + bs)/q)` has value 1 and is set to 1 otherwise."

**Provenance chain, all links verified:** Briggs (1998) → **Buhler–Lenstra–
Pomerance**, "Factoring integers with the number field sieve", **§8 and §12.7**,
in Lenstra & Lenstra (eds.), *The Development of the Number Field Sieve*,
**LNM 1554**, Springer 1993 (DOI `10.1007/bfb0091539`) → **Adleman, STOC 1991,
64–71** (DOI `10.1145/103418.103432`).

The clearest single statement of the mechanism is Elkenbracht-Huizing's, *A
multiple polynomial general number field sieve*, ANTS-II, LNCS 1172, Springer
1996, 99–114 (DOI `10.1007/3-540-61581-4_45`; PDF fetched from
`https://ir.cwi.nl/pub/2175/2175D.pdf`):

> "Finding a vector in the nullspace of this matrix over **1F2** guarantees that,
> for the subset T of the relations …, every exponent in (1) is even. **BY ADDING
> SOME EXTRA ROWS COMING FROM QUADRATIC CHARACTERS** [1] [4, SECTION 8, SECTION
> 12.7], ONE IS **PRACTICALLY CERTAIN** THAT THE SUBSET T IS THE WANTED SET S."

**Four cautions, each load-bearing — and the second is stronger than I first
wrote it.**

1. **"Practically certain" is a heuristic, not a theorem.** Elkenbracht-Huizing
   claims no unconditional result, so any statement that this is *proved* to be an
   index `2^r` and hence a rigorous constant **strengthens the source beyond what
   it says.** The exact statement in Buhler–Lenstra–Pomerance remains **NOT
   DETERMINABLE** — closed access, never reached.
2. **★ The character rows are NOT structurally necessary, and a record-setting
   implementation omitted them entirely.** Briggs's §4.3 treats `m` as a
   **confidence/cost knob** — *"increasing the number of ideals in Q also
   increases the likelihood of identifying squares correctly"* — and Cavallar et
   al., *Factorization of a 512-Bit RSA Modulus*, EUROCRYPT 2000 (DOI
   `10.1007/978-3-540-45772-7_19`, PDF from `https://ir.cwi.nl/pub/10351/10351D.pdf`),
   §3.3 footnote, verbatim:

   > "**In particular, all quadratic character rows are omitted.** The
   > pseudo-dependencies being found for this reduced matrix must be combined to
   > real dependencies afterwards."

   So the apparatus is a **heuristic filter, not a structural requirement** — and
   the 512-bit record factored **without it**. Anyone treating the rows as
   necessary, or quoting a constant gain from them, is over-reading.
3. **★ "index `2^r`" and "2-adic" are NOT in this literature at all.** Searched
   **exhaustively across all eight full texts**: counts for **Jacobi, Legendre,
   "2-adic", torsion, and "index `2^r"` are ZERO in every one**. **Do not
   attribute an index-`2^r` or 2-adic formulation to these papers.** My first
   draft said only "not found in the one full text I reached"; the true statement
   is an eight-text exhaustive negative. "Lovász" and "Schönhage" returned
   **NOT-FOUND**.
4. **★ SCOPE CORRECTION.** **In the quadratic sieve there is no such
   parity/character constraint** — a QS relation already forces `x² = y` exactly,
   so the square condition is built in and there is nothing to find. **The
   apparatus belongs to the NFS**, where `F_i(a,b)` is only *almost* a square.
   Elkenbracht-Huizing's own text makes this explicit. **Do not carry a QS/NFS
   claim across that boundary** — the error class that already cost this
   programme a fatal once.

**★ The failure mode IS documented — and it has no name.** I previously recorded
this as "NOT NAMED, NOT DETERMINABLE". Both halves are now settled, in opposite
directions. Cavallar et al., *RSA-512* §3.4, verbatim:

> "One job found the factorization after 39.4 CPU-hours, **the other three jobs
> found the trivial factorization** after 38.3, 41.9, and 61.6 CPU-hours…"

So the trivial-gcd event is **real and routinely observed** — three of four
dependencies in the 512-bit record factorization — but the literature's **only**
name for it is **"the trivial factorization"**. **There is no named 2-adic or
index-`2^r` phenomenon**, and whether a name exists is **NOT DETERMINABLE**.
Kleinjung 2016 is a **full-text negative** on Jacobi/Legendre/character
mechanisms and should not be leaned on.

**One unread document would settle items 2–5:** Buhler–Lenstra–Pomerance, LNM
1554, **§8 and §12.7** (paywalled). Briggs §4.3 is a free and adequate
substitute, and is what I used.

**SUPERSEDED BY §7.2** — the paragraph previously here read "the mixed-sign /
ramification failure mode is NOT NAMED in the one full text I reached, and I did
not find it documented under any name in zbMATH, Crossref, arXiv, ePrint, or
OpenAlex." **That understates what is now known in both directions:** the
phenomenon is **documented and routinely observed** (Cavallar et al., *RSA-512*
§3.4 — three of four dependencies gave "the trivial factorization"), and its
**only** name in the literature is **"the trivial factorization"**. See §7.2 for
both verbatim quotes.

---

## 8. CONTROLS

| control | status |
|---|---|
| **Self-test written FIRST**, negative controls fire, injection used | ✅ **29/29 PASS, exit 0**; the blindness guard fires on a planted cheater and *accepts* the honest conditions (else it is vacuous) |
| **Instrument calibration before any cell quoted** | ✅ identical input, fixed seeds, twice: **13 cells, max swing 0.0000%** |
| **Per-modulus `p_split` / 2-adic profile, never pooled alone** | ✅ 11-cell table with predictions; between-cell sd reported (0.1510 uniform / 0.1029 `jac_neg`) |
| **Non-vacuity by assertion** | ✅ `all([])` trap reproduced and shown empty; the fixed `order_mod`'s divisor-direction assert **fires on 8/8** broken inputs |
| **A test that can fire must fire** | ✅ positive control: 0 roots/120 moduli at `k=3` vs 480 at `k=2` |
| **Power reported; under-powered rows excluded** | ✅ `E[hits] < 20` labelled `NO`; the 1.32× row was excluded **on this basis** and then confirmed null by permutation |
| **Permutation null, not eyeballing** | ✅ 240 permutations, p = 0.354 |
| **Truncation bounded and reported** | ✅ geometric mean truncated at `a,b < 30`; dropped tail mass `2⁻²⁹ = 1.86e-9`; observed deviations `9.7e-10`, `4.1e-10` |
| **Dickman ρ never used as a null** | ✅ exact `Ψ` verified against brute force at 3 points |
| **Every loop bounded; `V = 0` refused centrally** | ✅ `smooth_exponents` handles `a=8, b=4` once, never re-implemented |
| **Factorisation-blindness enforced structurally** | ✅ `assert_factor_blind` on every condition, at import; conditions see only `(b, n)` and Jacobi is hand-written so it *cannot* see `p` |
| **Regime honesty** | ✅ see §9 |

### The bugs these controls caught in my own code

Ten, each of which would have produced a clean, confident, wrong number.

1. **`order_mod` (inherited) returns its input.** Built the whole round's
   instrument on it before noticing. → §6.
2. **`lam` vs `k` again** — wrote the solvability condition as `k_p = 0`
   instead of `lam_p = 0`; **0/3978** in the offending cell. Same bug as
   `II_baseg.md` #1.
3. **A roll-up compared the wrong columns** (`hits` vs `agreements` instead of
   `agreements` vs `totals`), so a table with **23004/23004** agreement printed
   `[FAIL]` and tripped the assert. Would have shipped as "C1 refuted".
4. **Truncation, not law** — an assertion at `1e-9` fired at `upto = 22` where
   the truncation error is `2.5e-7`. Fixed by *bounding the error*, not loosening
   the test.
5. **Per-modulus dead-flagging** conflated "structurally annihilated" with "one
   unlucky sample", printing `ratio = 0.000` for the **uniform** arm — i.e.
   reporting that **Result C fails**, which is false and is the conclusion under
   test.
6. **A vacuous exhaustive test that printed `[PASS]`** — filtered out composites
   when it needed semiprimes; **0 cells tested**, `0` departures, confident
   verdict. §4.1.
7. **A biased pooled estimator** producing a spurious **`z = +5.94`**. §4.2.
8. **Sampling a congruence** instead of enumerating it — `NO TRIALS` on 8/8 rows,
   which would have been a fabricated negative about the pipeline.
9. **A conditional rate presented as a rate of what** — `1e-5` printed as "40%".
10. **A degenerate test polynomial** — `(a+b)³ − b³` has root `a = 0`
    identically, so `P(irreducible) = 0` everywhere and the table could not
    distinguish "no 2-adic content" from "never irreducible". §2.2.

Plus one in my own fix: the corrected `order_mod`'s assertion was initially
**symmetric** (`order % lam == 0 or lam % order == 0`), which would have
**passed the un-stripped value** — i.e. certified the bug it was written to catch.
Only the divisor direction carries information.

---

## 9. WHAT IS CLAIMED, AND WHAT IS NOT

**Claimed.**

1. **The transplant is exact.** `Jacobi(b/n) = −1` on the number-field base gives
   `20/27 → 8/9`, ratio **1.2000** exact in Rational arithmetic (truncation
   `1.9e-9`), measured pooled **1.2226** over 11 per-modulus cells and N = 5400
   per rule, at **`q = 1` and zero cost**. Diagonal cells **1320/1320, 440/440,
   160/160**.
2. **★ The NFS search reads the base's 2-adic structure through exactly one
   bit.** `b^k` is a QR mod `p` **iff NOT(`lam_p = 0` AND `k` odd)** — exhaustive
   on **23 004/23 004** triples. Higher 2-adic digits are invisible to the search.
3. **★ `GAIN ∈ {0, 1}`, never `> 1`.** Even `k`: root count **4.000 in 8/8 rows**,
   CRT ratio flat, `s_C/s₀ = 1`. Odd `k`: **`P(n) = 0` exactly in 40/40 moduli**,
   `s_C = 0`.
4. **The apparent 1.32× win is noise**: permutation p = **0.354**, real median
   inside the permutation band, with a positive control proving the instrument
   fires.
5. **Result C applies, harder than measured**: CRT-exactness is a **bijection**
   here, exact to machine precision on **24/24** exhaustive cells.
6. **★ The phase separation is not an artefact.** The 2-adic coupling is
   **present** on the number-field side (**0.7625 → 0.8850**, N = 400) and free —
   it is **orthogonal** to the search variable.
7. **The `k`-th power residue symbol (`k ≥ 3`) is not computable from `n`** —
   **935 explicit collisions**, e.g. `n = 2479`: `b=2 → (1,1)` and `b=3 → (2,0)`
   with identical symmetric products.
8. **`MM_design.md` §3c is retracted** (§6), verified by three independent
   implementations at **0/496 mismatches**.

**NOT claimed.**

- **Nothing about the true NFS regime.** `π(B*) ≈ 10¹⁵–10³³` is uninstantiable
  here. The relation-yield rows in §3.4 are at 16–20 bits with **`power = NO`**,
  used **only** to generate the noise hypothesis, which §3.4 then refutes
  independently. **No extrapolation into the real regime.**
- **No factoring was performed** on any modulus of interest. Largest modulus
  `n ~ 2²⁸`; all generated locally. **This is classical factoring of RSA-scale
  integers. It is not a cryptographic break; no deployed scheme is affected.**
- **The dichotomy is not a theorem over all conceivable constructions.** It is a
  mechanism, with the escape route in §4 named explicitly.
- **The soundness numbers for `order_mod`** (§6.4) are true ratios, not bounds.
  The `ord_n(g)` distribution has a **long left tail**: minimum observed
  `ord_n/64` = **15** at 16 bits. §6's "period ≫ sieve limit" is a **typical**
  claim, and it is genuinely weak at small `n`.
- **The Buhler–Lenstra–Pomerance statement itself is NOT DETERMINABLE** (§7.2).
  Only Elkenbracht-Huizing's *pointer* to §8/§12.7 was verified, plus her verbatim
  sentence.
- **No row of the S1 table rests on an unverified citation.** Candidate 2 is
  refuted by **computation**, not by literature.

---

## 10. SCOPE GUARD

**Classical factoring of RSA-scale integers. Not a cryptographic break.** No
deployed scheme is affected, and nothing here improves the ability to factor RSA
in practice. **No factoring was performed on any modulus of cryptographic
interest** — the largest is `n ~ 2²⁸ ≈ 2.7·10⁸`, generated locally. The claims
are about **structure**: which conditions are controllable without factoring,
which are coupled to 2-adic structure, and why the search and the base do not
meet. `π(B*) ≈ 10¹⁵–10³³` makes the true NFS regime **not determinable here**,
and it is not extrapolated into.

---

## 11. REPRODUCE

```
cd factor-scratch/r53exp/synth
python3 selftest.py        # 29/29 PASS, exit 0                          (  1 s)
python3 exp_s1.py          # q-term, exact law, calibration, order step  (  9 s)
python3 exp_s2.py          # C1, C2 annihilation, relation yield           (  7 s)
python3 exp_s2b.py         # permutation null + positive control          (  7 s)
python3 exp_s3.py          # Result C: exhaustive + per-base estimator    ( 11 s)
python3 exp_s4.py          # candidates 2 and 3 falsified                ( <1 s)
cd verify_order && python3 verify.py    # independent order_mod verdict   ( <1 s)
```

Wall-clock above is **measured**, not estimated — I first wrote 25/12/6/14/4/9
minutes from a guess and was wrong by up to 100×. All eight scripts exit 0; total
runtime is **~35 s**, which is worth stating plainly, because a reader who
budgets an hour for this note on the strength of the first version would be
misled about how cheap the negative was to obtain.

Outputs: `results/s1.json`, `s2.json`, `s2b.json`, `s3.json`, `s4.json`,
`verify_order/results.json`. Citation findings: `cites.txt`.

**Dependencies:** Python 3.12, `sympy`. `math.jacobi` **does not exist** in
CPython 3.12, so `core.jacobi` is hand-written — which is also why its
factor-blindness is auditable rather than assumed. Validated against
`sympy.jacobi_symbol` on **3000** random `(a,n)`.
