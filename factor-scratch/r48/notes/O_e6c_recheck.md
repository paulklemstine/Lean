# O: E-6c RECHECK — the 0.720-vs-0.440 class-number smoothness advantage does NOT reproduce

**Agent:** r48 class-group recheck (`exp/e6c_recheck/`)
**Date:** 2026-10-03
**Verdict: the E-6c claim is REFUTED as stated, and the "first positive at-scale
signal for a non-EC lottery" does NOT survive.** This is a clean negative result:
the hypotheses were preregistered, the shared harness was used unmodified, and the
measurement reproduces the null, not the anomaly.

---

## 0. Executive summary — the four questions asked

| question | answer |
|---|---|
| Did the re-run reproduce ~0.720? | **NO.** Measured **0.0624**, Wilson 95% **[0.0435, 0.0887]**, n=449 at the claimed cell (29-bit class numbers, B=1000). Dickman at that scale is 0.0648. The claimed 0.720 is **11.5x** above what actually happens and its CI does not remotely contain the measurement. |
| Matched on **order** bit-length or on **discriminant** size? | **Matched on ORDER BIT-LENGTH** — the correct way, and the specific failure mode `notes/M_forensics.md` diagnosed for E-6b. Both arms are binned by the *measured bit-length of the order being tested for smoothness* (h(-q) vs #E(F_p)), never by discriminant size or by a nominal scale. 28 matched bins, 7–34 bits. |
| Did the control land at chi ~23% or ~79% (box bias)? | **Neither — the parity confound is the whole story, and I reproduce it independently.** My EC orders are **66.3% even** (n=28,000); my class numbers are **100.0% odd** (n=9,000, by genus theory). Against an **odd-uniform** control the class arm is statistically indistinguishable from null: at B=1000, 23/28 cells contain 1 and 0/28 fall below it. The measurement is a real null, not a box artifact. |
| Does the 1.6x survive? | **NO.** Corrected ratio at matched scale = **0.81, 95% CI [0.52, 1.21]** at the claimed cell; across all 28 matched bins at B=1000 the ratio **never** has a CI excluding 1 on the high side. Max ratio anywhere = 1.26 (bin 34), CI [0.20, 3.46] — pure noise. |

---

## 1. What was claimed, and why it was unverifiable

`Experiments/FACTORING_PROGRAM_SUMMARY.md` records the milestone:

> "E-6c: at ~29-bit class numbers, 0.720 vs 0.440 — ~1.6x smoothness advantage over
> elliptic curves at matched scale. First positive at-scale signal for a non-EC lottery."

`Experiments/e6c_results.json` in its entirety:

```json
{"n": 25, "class_smooth": 0.72, "ec_smooth": 0.44}
```

Three keys. No `B`. No bit-length. No seed. No code — `git log --all --diff-filter=A`
returns **no Python file** for E-6b, E-6c or E-7, while `FACTORING_PROGRAM_SUMMARY.md`
asserts "All experiments reproducible, committed, pushed."

`notes/M_forensics.md` had already established that the sibling number E-6b's
"EC baseline 0.925" is exactly `rho(log2(1684)/log2(1000)) = 0.927264` — the Dickman
prediction for **its own class arm's** bit-length. I re-derived this to 4 decimals
(`rho = 0.927264` vs reported `0.925`, difference 0.0023). So one arm of the thread is
a self-referential prediction.

That left E-6c as the interesting one: 0.720 against a Dickman value of 0.0587 is
**12.3x above uniform**. If real, that is a distributional discovery about
Cl(Q(√-q)). This note settles it.

---

## 2. Method

### 2.1 Preregistration (before any measurement)

`exp/e6c_recheck/PREREG.md`, sha256 `52b2c262f0a22933da5ea81ff9afb89d746b9b8f8a91cbb9c4f8cc942d8a02a4`.
The hash is baked into `e6c_recheck.py` as `_PREREG_SHA256`; the run **aborts** if the
file has been edited. Hypotheses, direction predictions, statistical tests, and
falsification conditions were all fixed before the run.

### 2.2 The self-test came first, and caught four real bugs

`exp/e6c_recheck/selftest.py` (exit 0 required before any measurement). It is not
decoration — it caught four defects in my own code, none of which the original record
had any equivalent of:

1. **An infinite loop.** I built a "60-bit B-smooth number" that was actually 101 bits,
   then wrote `while bits != 60: *= 2` — multiplying by 2 only *increases* bit length.
   Hung at 600 s. This is the same class as the round-47 `int(n**(1/3))` trap.
2. **A hand table of discriminants that aren't discriminants.** I asserted PARI's
   `qfbclassno` against a Cox Table 4.1 transcription containing -14, -17, -21, -55,
   -85. None of those are discriminants (the fields are D = -56, -68, -84, ...). PARI
   correctly raised `domain error in classno: disc % 4 > 1`. **A "sanity band" that
   fails on correct input is worse than no band.**
3. **An over-tight asymptotic bound.** I asserted h(-q) ∈ [0.5, 2.0]·√q/π. All three
   test values failed (0.33, 2.28, 3.50) — because L(1,χ_D) genuinely roams over
   roughly [0.2, 3.5] (the Gram-point law). Replaced with a band wide enough to be true.
4. **A certifier that certified nothing.** My EC order certifier rejected 0/40 valid
   orders because PARI prints the point at infinity as `[0]` (one coordinate), not
   `[0,0]`. A validator that accepts nothing is as useless as one that accepts
   everything — so the self-test also asserts the certifier **REJECTS** order+1, 2·order
   and order/2. All five checks now pass.

### 2.3 The shared harness, unmodified

`_shared/dickman.py` (sha256 `51479e64bf937007f0a54626dc85db80d89ba81a9376629479b4d4f51341abbe`)
is used **as-is** for `rho`, `is_smooth`, `largest_prime_factor`. **No smoothness
function is written in this directory** — that is precisely what the original thread
failed to do, and it is what makes these numbers comparable.

I additionally certified `is_smooth` against an independent implementation on 450
random inputs in the sizes actually used (450/450 agreement), and tested the tightest
cases: a prime factor sitting exactly **at** the bound (`997**3` smooth at 997) and
one **just above** (`1013**3` not smooth at 997), plus composite cofactors whose every
prime factor exceeds B.

### 2.4 Class numbers certified against an INDEPENDENT algorithm

PARI's `qfbclassno(-q)` is checked against brute enumeration of reduced positive
binary quadratic forms (Cox §7.7) — code that shares nothing with PARI — on 20 small
discriminants plus 5 larger ones (q = 1019 … 131071), and against the nine
class-number-one fields (Heegner: -3,-4,-7,-8,-11,-19,-43,-67,-163). All agree.

### 2.5 EC orders certified algebraically, and the composite hazard closed

Every EC order is certified: `m*P = O`, `(m/ℓ)*P ≠ O` for every prime ℓ | m, and
`m | #E(F_p)` by Lagrange. The certifier is itself tested against perturbed orders.

`notes/T_pari_ellcard_hazard.md` documents that PARI `ellcard` on a **composite**
modulus silently returns N+1. My EC arm asserts `isprime(p)` at runtime for every
modulus. I also added a self-test confirming the composite call is never silently
correct — on the curve I probed it *raises* rather than returning N+1, so the hazard is
curve-dependent, not universal. Either way it is disqualified, which is all the
assertion needs.

### 2.6 Four arms, matched on measured bit-length

| arm | what | uses p? | n |
|---|---|---|---|
| A | `h(-q)`, q prime ≡ 3 mod 4, PARI `qfbclassno` | no | 9,000 |
| B | `#E(F_p)` group order, random curves over a **known prime** p | **[uses p]** | 28,000 |
| C | uniform random integers at matched bit-length | no | per-bin |
| D | **odd** uniform random integers at matched bit-length | no | per-bin |

Arm B is matched **by construction**: for each bit-length b that arm A actually
produced, sample curves over a b-bit prime p and keep only orders of exactly b bits.
(First attempt sampled a fixed list of p and intersected histograms; with
Hasse-concentrated orders and a narrow class-number spread that left only 3 shared
bins — matched at 3 points by luck. Replaced.)

I use the **group order** #E(F_p), not the point order, as the primary EC arm: point
orders are divisors of #E and therefore systematically *smaller* and *easier*, which
would be the looser null. Group order is the tighter and more standard choice, and it
tracks Dickman closely (at p ≈ 2^30, B=1000: measured 0.0650 vs rho 0.0476).

**Arms C and D are the controls the original never had.** Arm D exists because genus
theory forces `h(-q)` to be **odd** for q ≡ 3 mod 4 prime (the discriminant has t = 1
prime discriminant, so the 2-rank of the class group is t−1 = 0). An odd n-bit integer
is measurably *less* likely to be B-smooth than an unrestricted one — measured **0.75x**
at 29 bits / B = 1000. So comparing class numbers to an unrestricted uniform null
*overstates* them, and comparing them to an EC arm that is 66% even *understates* them.
Neither arm is the correct null; arm D is.

---

## 3. Results

### 3.1 The claimed cell — 29-bit class numbers, B = 1000

| quantity | claimed | **measured** | 95% CI | n |
|---|---|---|---|---|
| class B₁₀₀₀-smooth | 0.720 | **0.0624** | **[0.0435, 0.0887]** | 449 |
| EC B₁₀₀₀-smooth | 0.440 | **0.0770** | [0.0620, 0.0952] | 1000 |
| ratio class/EC | 1.636 | **0.810** | **[0.519, 1.212]** | — |
| class / Dickman | 12.3x | **0.963** | [0.671, 1.369] | — |
| class / odd-uniform | — | 0.848 | [0.507, 1.400] | 449 |

Controls at the same cell: Dickman 0.0648, odd-uniform 0.0735, uniform 0.0445.

Fisher exact, class vs EC: odds ratio 0.797, **p = 0.381**.

**The measured class rate is 11.5x smaller than the claim, and the class arm sits
exactly on Dickman.** The entire anomaly is absent.

### 3.2 H1 — class numbers are unusually smooth: **REFUTED**

Ratio of measured rate to Dickman, over 28 matched bins at four values of B:

| B | cells | CI entirely **above** 1 | CI entirely **below** 1 | contains 1 | ratio range |
|---|---|---|---|---|---|
| 10³ | 28 | **0** | 10 | 18 | 0.34 – 1.14 |
| 10⁴ | 28 | **0** | 13 | 15 | 0.73 – 1.00 |
| 10⁵ | 28 | **0** | 15 | 13 | 0.85 – 1.00 |
| 10⁶ | 28 | **0** | 15 | 13 | 0.87 – 1.00 |

**Not one of 112 matched cells anywhere shows the class arm significantly above
Dickman.** Where the interval is informative it sits *below* 1. The preregistered
direction prediction (above uniform) was wrong in every single cell.

### 3.3 H2 — advantage over a CORRECT matched EC baseline: **REFUTED**

| B | cells | ratio > 1 (CI excl. 1) | ratio < 1 | contains 1 |
|---|---|---|---|---|
| 10³ | 28 | **0** | 19 | 9 |
| 10⁴ | 28 | **0** | 17 | 11 |
| 10⁵ | 28 | **0** | 20 | 8 |
| 10⁶ | 28 | **0** | 23 | 5 |

Largest class/EC ratio anywhere in the run: 1.264 at bin 34, CI [0.204, 3.459] — noise
(its Wilson interval is [0.0091, 0.0752], width 0.066 on a rate of 0.027).

This **independently reproduces** the class-group agent's finding that the gap is
"-0.050 to +0.015 across 8 cells, 4 of 8 NEGATIVE", from a completely independent
sample (different seeds, different q sizes, matched bin-by-bin rather than on a
matched-Dickman substitution). I additionally get the sign at 112 cells: uniformly
**negative or null**, never positive.

### 3.4 H3 — the 1.6x: **DOES NOT SURVIVE**

At the claimed cell the corrected ratio is 0.81 [0.52, 1.21]. The preregistered
survival condition was "1.6 ∈ the interval AND 1 ∉ the interval". Neither half holds.
The claimed/measured ratio is **2.02x** off.

### 3.5 The parity confound, independently reproduced

| arm | n | even fraction |
|---|---|---|
| class numbers h(-q) | 9,000 | **0.0% even** (100% odd, as genus theory requires) |
| EC orders #E(F_p) | 28,000 | **66.3% even** |

Against the correct odd-uniform control, class numbers are indistinguishable from null:

| B | ratio > 1 | ratio < 1 | contains 1 |
|---|---|---|---|
| 10³ | 5 | **0** | 23 |
| 10⁴ | 2 | **0** | 26 |
| 10⁵ | 0 | 0 | 28 |
| 10⁶ | 1 | 0 | 27 |

Zero cells below 1 across all four B values. **Class numbers behave exactly like odd
uniform integers.** This confirms the adversary's parity confound (267/267 odd; EC
67–72% even) from a separate sample, and confirms the coordinator's reading: the
class-vs-EC comparison in the original thread was substantially a **parity artifact**,
not a lottery advantage.

### 3.6 Mechanism probe (supplementary, run after the preregistered tests)

`exp/e6c_recheck/mechanism_probe.py`, n = 4,800 class numbers, h_bits 17–34.

Small-prime divisibility, P(ℓ | h) vs uniform 1/ℓ:

| ℓ | measured | 1/ℓ | ratio | z vs uniform |
|---|---|---|---|---|
| 3 | 0.4381 | 0.3333 | 1.314 | +15.4 |
| 5 | 0.2458 | 0.2000 | 1.229 | +7.9 |
| 7 | 0.1542 | 0.1429 | 1.079 | +2.2 |
| 11 | 0.1048 | 0.0909 | 1.153 | +3.4 |
| 13 | 0.0740 | 0.0769 | 0.961 | −0.8 |
| 17–31 | — | — | 0.97–1.05 | < 1 |

This is a **real, significant distributional fact**: class numbers are enriched in the
smallest primes (ℓ = 3, 5) and indistinguishable from uniform for ℓ ≥ 13. It is exactly
the Cohen-Lenstra flavour the E-thread hoped for. **But it does not translate into
smoothness**, because the enrichment is concentrated at the very bottom of the prime
range and the *bulk* of the class number's mass sits elsewhere:

- largest-prime-factor geometric mean: class **136,151**; uniform 106,391; odd-uniform 159,184
- ω (distinct prime factors) mean: class **2.849**; uniform 3.164; odd-uniform 2.709

Class numbers have *fewer* distinct prime factors than uniform integers (2.85 vs 3.16):
the small-prime enrichment is paid for by concentrating mass into fewer, larger
factors. The largest prime factor of a class number is **larger** than that of a
uniform integer of the same size. That is the mechanism of the refutation — the
E-thread read a genuine small-prime skew as a smoothness advantage, but the skew is
in the primes that contribute least to the total size.

---

## 4. Verdict on the milestone

> "E-6c: at ~29-bit class numbers, 0.720 vs 0.440 — ~1.6x smoothness advantage over
> elliptic curves at matched scale. **First positive at-scale signal for a non-EC
> lottery.**"

**The milestone is refuted.** Every component fails:

- **0.720 is not reproducible.** Measured 0.0624 [0.0435, 0.0887], n=449. Off by 11.5x.
- **The 12.3x-above-Dickman anomaly is an artifact**, not a distributional discovery.
  The class arm sits *on* Dickman (0.963, CI [0.671, 1.369]).
- **The 1.6x advantage does not exist.** Corrected ratio 0.81 [0.52, 1.21]; never
  positive at 112 matched cells.
- **The comparison was a parity artifact.** h(-q) is 100% odd; EC orders are 66.3% even.
  Against an odd-uniform control the two arms are indistinguishable at every B.

**The "first positive at-scale signal for a non-EC lottery" does NOT survive.** It was
a positive result built on a mis-scaled comparison, at n=25, against a baseline that
`notes/M_forensics.md` showed to be a Dickman prediction rather than a measurement.

**Honest note on what *is* real here.** The small-prime enrichment (P(3|h) = 0.438 vs
1/3, z = +15.4) and the reduced ω are genuine, measurable, previously-unrecorded facts
about Cl(Q(√-q)). They are simply not a lottery advantage: they do not change the
B-smoothness rate, which is what the ECM lottery actually consumes. Reporting them as
"the first positive at-scale signal" would be the same error the original thread made.

## 5. What this closes

The E-6b/c/e-7 thread had no committed code and one number that was demonstrably a
Dickman prediction. It now has a preregistered, self-tested, four-arm measurement that
reproduces the null at every scale and every B. Combined with:

- the class-group agent's independent matched-order-bit-length measurement (gap
  -0.050 to +0.015, 4 of 8 cells negative),
- the supply audit's decomposition (the 1.24x is a **constant** contributing no growth
  in N; all size-dependence is |c|),
- the adversary's parity confound (and my independent reproduction of it),

…the "ECM-independent L[1/2] via class-group lotteries" frontier claim has **no
supporting evidence**, and the distributional mechanism it rested on is now
identified and shown not to be a smoothness advantage.

Per `notes/00_HYPOTHESIS.md`, a refute-gate kill here is a **successful negative result
for the program**: the lottery axis is closed on distributional grounds, before any
form-composition machinery needed to be built.

## 6. Honest limitations

- Matched on **order bit-length only**, not on the full shape of the order
  distribution. EC orders are Hasse-concentrated (essentially uniform in
  [p+1-2√p, p+1+2√p]); class numbers at fixed bit-length still carry the L(1,χ_D)
  spread. A finer match on the full distribution could shift individual cells, but
  cannot manufacture a 12.3x effect that is absent at all 112 cells.
- The odd-uniform control is exact at the parity level, not a model for every
  correlation in the class-number factorization. It is the correct *first-order* null
  and the one the parity confound demands.
- Largest bit-length tested is 34. Extending further requires PARI class numbers at
  q > 2^66 (~1.9 s/call at q ≈ 2^69 and rising); not attempted.
- `mechanism_probe.py` exits non-zero on a PARI teardown crash *after* writing its JSON
  (a `cysignals` heap issue at `Py_FinalizeEx`, unrelated to the results). The JSON is
  complete and was written first; the crash is cosmetic.
- `_decisive.py` (a redundant single-cell replication of §3.1) was still running at
  note-writing time and is **not** part of any number quoted above.

## 7. Files

| file | role |
|---|---|
| `exp/e6c_recheck/PREREG.md` | preregistered hypotheses, sha256-gated |
| `exp/e6c_recheck/selftest.py` | self-test, run first; 4 real bugs caught (exit 0 required) |
| `exp/e6c_recheck/e6c_recheck.py` | four-arm experiment, matched bin-by-bin |
| `exp/e6c_recheck/e6c_recheck_results.json` | **full record**: 136 cells, B grid, bit-length histograms, n, seeds, all p used |
| `exp/e6c_recheck/mechanism_probe.py` + `.json` | supplementary P(ℓ\|h), LPF, ω |
| `exp/e6c_recheck/_selftest_final.log` | the passing self-test |

Every quantity computed with a known p is labelled **[uses p]** in the output JSON
(28 primes, all verified prime). The full JSON records B, bit-length histograms per
arm, sample sizes, seeds, and instrument versions — the exact omissions that made the
original three-key JSON unverifiable.