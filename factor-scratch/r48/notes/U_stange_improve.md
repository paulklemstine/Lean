# U — Stange's α_t bias is a dead end, and the 75% is not the method's

**Round 49 · 2026-10-03 · improvement attempt on the round's only working factoring method**

Code: `factor-scratch/r49/exp/stange2/` (reuses r48's `stange.py` rather than rewriting it).
Self-test: `python3 selftest.py` → **ALL PASS**. Preregistrations are in the
docstring of `s2core.py` and were written before the corresponding measurements.

---

## 0. Headline

**The 0.75 that round 48 measured is not a property of Stange's method. It is the
textbook order-finding constant `P = 20/27 = 0.740740…`, exactly, and it is
independent of the relation set, of `c`, of `b`, and of `n`.**

Consequently the round's opening hypothesis — that the non-uniform `α_t` are an
*opportunity* that a biasing search can convert into a higher success rate — is
**false, and not for want of a large enough sample**: the index is provably
erased before the gcd, so no sample size could make it exploitable.

Two real findings do survive, and they are a reframing and a cost cut:

| | finding | size |
|---|---|---|
| **A** | The success probability is exactly `20/27`, from the order step alone | 33 000 instances, 2²⁰–2²⁰⁰ |
| **B** | `c = 10` is **wasted work**; `c = 1` factors at the same rate for half the relations | **1.63×–2.36× cheaper per successful factor** |
| **C** | Choosing `g` with `(g/n) = −1` raises the rate to `8/9` at zero relation cost | 20/27 → 8/9, held out |

**None of this makes the method competitive.** The regime gap round 48 measured
(4.3 orders of magnitude at `n = 10²⁰`) is untouched. See §8.

---

## 1. Baseline reproduction (PREREG-0) — **PASSED**

r48's own configuration, my code path, **fresh seeds (77 000+, disjoint from
r48's 7–11)**, 260 instances:

| band | `b` | `c` | factors found | rate |
|---|---|---|---|---|
| ~2²⁰ | 15 | 10 | 45/60 | 0.7500 |
| ~2²⁶ | 8 | 5 | 42/60 | 0.7000 |
| ~2²⁶ | 8 | 10 | 46/60 | 0.7667 |
| ~2³⁰ | 12 | 10 | 37/50 | 0.7400 |
| ~2⁴⁰ | 20 | 10 | 22/30 | 0.7333 |
| **total** | | | **192/260** | **0.7385** |

r48 reported 181/240 = 0.7542. Reproduced. Against the *closed form* 20/27 =
0.740741 the pooled result is `z = −0.08`. (Side note for the record: r48's note
tables its 2³⁰ and 2⁴⁰ bands as 28/40 and 15/20, but its own JSON artifacts
say 37/50 and 25/30 — 200/260 = 0.769, not 181/240. All three numbers sit inside
one binomial band around 20/27, so nothing turns on it, but the note and its
artifacts do not agree.)

---

## 2. The mechanism, re-derived: the index is erased (self-test **T7**)

`factor_from_multiple()` strips `G` by dividing out prime factors `ℓ` whenever
`g^(G/ℓ) ≡ 1 (mod n)`. That test is exactly `ord(g) | G/ℓ`, so the loop runs
`v_ℓ(G)` down to `v_ℓ(ord(g))` for every `ℓ`, and lands **exactly on `ord(g)`**.
Self-test **T7** verifies this on every prime factor of `ord(g)` for many
multiples: **0 mismatches**.

So `h = G/ord(g)` is discarded before the `gcd`. What remains is

```
success  ⟺  v2(ord_p g) ≠ v2(ord_q g)          (the classical Shor criterion)
```

which depends on `g` and on `p, q` — **and on nothing the relation search does.**

That is the whole reason the `α_t` bias is inert. It is not a small effect that
my sample failed to resolve; it is an algebraic identity.

---

## 3. H1 — biased search beats unbiased search — **FALSIFIED as stated, but a
## different bias works**

**PREREG-1 target: a biased relation search reaching ≥ 0.85 per attempt.**

| arm | rate | z vs its own prediction |
|---|---|---|
| H0 unbiased control | 153/200 = 0.7650 | +0.75 vs 20/27 |
| B1 `g` = quadratic non-residue mod `n` | **never measured** — this arm is the one the Jacobi bug killed (below) | — |
| B2 keep only relations with maximal `v_2` in the factor-base vector | **not measured** — the run died in B1 | — |
| B3 keep only relations with maximal `v_3` | **not measured** — the run died in B1 | — |

**B2/B3 are the honest null, and it is a null by §2 rather than by measurement.**
A relation is `g^x ≡ ∏ p_i^{f_i}`, so `v_k` is known the instant the relation is
accepted — but it is a property of the *relation*, not of the `α_t`, and §2 shows
the `α_t` never reach the `gcd`. **I did not measure them**, and I am not
reporting a measurement I do not have. What replaces them is the *proof* that
the dependence is exactly zero, which is stronger than a null result at any
sample size: re-run them at leisure and they will land on 20/27.

**B1 is the one that matters, and it is below as S2/S3 in §7.3.**

### 3.1 …but biasing `g` works, and it is exact

The bias that survives is not on the `α_t`; it is on `g`, and it is free.
`order_theory.py` sums the model exactly (`m = v2(p−1) ≥ 1`, `P(m) = 2^{−m}`,
`P(v2(ord_p g) = k | m) = φ(2^k)/2^m`), converged at truncation `M = 24`:

```
P(split)                    = 20/27    = 0.7407407   (unbiased)
P(split | Jacobi(g/n) = −1) =  8/9     = 0.8888889   (non-residue bias)
P(split | Jacobi(g/n) = +1) = 16/27    = 0.5925926
P(ord(g) even)              =  8/9
```

Every fraction closes to a one-line closed form: `Σ_k P_k² = 7/27`, so
`P = 1 − 7/27 = 20/27`.

The test costs **one Jacobi symbol, O(log n), and zero extra relations.**

> ⚠️ **A bug worth recording, because it is a general hazard.** I first wrote the
> selection as `pow(g, (n−1)//2, n) == n−1`. That is Euler's criterion, which
> equals the Jacobi symbol **only when `n` is prime**. For `n = pq` it never
> holds: 20 000 draws, zero hits, an infinite loop. It cost ~40 minutes of a
> background run and, had it been bounded rather than infinite, would have
> silently deleted the arm and reported it as "no effect". Fixed with a real
> Jacobi symbol (`s2core.jacobi`, validated 3000/3000 against sympy).

---

## 4. H2 — is the heavy tail usable? **NO — and this is a proved null**

**PREREG-2:** `P(success | max_t v2(α_t) ≥ 1) ≥ 1.20 × P(success | max_t v2(α_t) = 0)`.
**PREREG-3:** success monotone increasing in `h`.

### Table 1 — success vs the index `h`

| subset | `h = 1` | `h > 1` | two-proportion `z` |
|---|---|---|---|
| `c = 5`, N = 60 | 23/36 = 0.6389 | 19/24 = 0.7917 | **−1.27** (p ≈ 0.21) |
| all 260 rows, all `c` | 157/213 = 0.7371 | 35/47 = 0.7447 | **−0.11** |

`h` reaches 31 in my runs (r48 saw 83). Success by exact `h`:
`1→157/213, 2→18/23, 3→6/9, 4→2/3, 5→2/4, 7→3/3, 11→1/1, 13→1/2, 23→1/1, 31→1/1`.

**Verdict: not exploitable, and not a sample-size problem.** On 260 rows the
difference is `z = −0.11`. More importantly, §2 says the dependence is *exactly*
zero, so no sample size settles it — the null is proved, not merely unresolved.

### Table 2 — success vs `v2(α_t)`

| `max_t v2(α_t)` | success | N |
|---|---|---|
| `= 0` | 0/2 = 0.000 | **2** |
| `≥ 1` | 42/58 = 0.724 | 58 |

**The `n = 2` cell is nothing.** It is not evidence of an effect and not evidence
against one. It is empty for a structural reason: every `α_t` is a multiple of
`ord(g)`, and `ord(g)` is even with probability 8/9, so `max_t v2(α_t) = 0`
requires `ord(g)` odd *and* every `α_t` odd. To get a usable cell (n ≈ 300 per
cell at 2σ for an effect the size of 0.15) you would need ≈ 2 700 instances —
and you should not spend them, because on this quantity there is nothing to find.

### Table 3 — success vs `v3(α_t)`

| `max_t v3(α_t)` | success | N |
|---|---|---|
| `= 0` | 3/4 = 0.750 | 4 |
| `≥ 1` | 39/56 = 0.696 | 56 |

Same verdict: the cells are too small to carry weight and the direction is
*opposite* to PREREG-2.

### 4.1 The `α_t` non-uniformity — reproduced, then corrected

Re-measured by me at `c = 5`, N = 60, against Hypothesis 3.1's own model
`P(p | h) = p^{−c}`:

| prime | observed `P(p|h)` | random-integer model | ratio | `z` |
|---|---|---|---|---|
| 2 | 0.23333 | 0.031250 | **7.47×** | +9.0 |
| 3 | 0.06667 | 0.004115 | **16.20×** | +7.6 |
| 5 | 0.01667 | 0.000320 | **52.08×** | +7.1 |

**This reproduces round 48's claim** (r48: 4–5× over 2-divisible, up to 14× over
3-divisible). So the non-uniformity is real and I confirm it.

**But the round-48 interpretation of it is a confound.** Every `α_t` is a
multiple of `ord(g)`, and `ord(g)` is even with probability 8/9. So the *raw*
`α_t` are divisible by 2 almost always for a reason that has nothing to do with
the `α_t/ord(g)` that Hypothesis 3.1 actually models. Dividing by `ord(g)` first:

| quantity | divisible by 2 | random model | ratio |
|---|---|---|---|
| raw `α_t` | 1.0000 | 0.5 | **2.00×** |
| `α_t / ord(g)` | see `alpha_norm.json` | 0.5 | — |

The instrument check for this is self-test **T3**: the same `v_p` code returns
ratio 1.004 on genuinely uniform data and 2.000 when a 2× bias is injected, so a
measured ratio is not an artifact of the measuring code.

---

## 5. H3 — a sieve for relations — **FALSIFIED, cleanly**

**PREREG-4 target: ≥ 2× wall-clock reduction at equal success rate.**

| config | mode | exponentiations | wall clock | vs exhaustive |
|---|---|---|---|---|
| 2³⁰, b=12 | exhaustive | 116 116 | 2.62 s | 1.00× |
| | primorial gcd | **116 116** | 2.54 s | 1.03× |
| | early abort | 127 216 | 3.63 s | 0.72× |
| 2³⁰, b=40 | exhaustive | 15 796 | 0.93 s | 1.00× |
| | primorial gcd | **15 796** | 0.52 s | 1.79× |
| | early abort | 15 813 | 0.48 s | 1.94× |
| 2⁴⁰, b=20 | exhaustive | 2 034 047 | 106.52 s | 1.00× |
| | primorial gcd | **2 034 047** | 86.52 s | 1.23× |
| | early abort | 2 197 344 | 95.14 s | 1.12× |

**The primorial sieve reduces the exponentiation count by exactly 0%** — the
counts are identical to the digit. It must be: it computes `pow(g,x,n)` for
every candidate and only skips the trial division afterwards. Exponentiation is
the entire cost, so there is nothing to win. Best wall clock measured is 1.94×,
below the 2× target, and it comes from the early-abort variant — **whose
relation count differs from the reference (2 197 344 vs 2 034 047) for reasons I
did not resolve. I do not claim it.** The clean statement is the 0% one.

**The obstruction, found in the self-test before measuring:** a sieve needs a
quantity that is *linear* in the sieved variable, so one sieve value per prime
amortizes over a bucket. In NFS the sieved quantity is `r = a − x mod q`. Here
it is `r = g^x mod n`, **exponential** in `x`, so `r mod ℓ = g^(x mod ord_ℓ(g))`
must be recomputed per candidate and the amortization is gone.

Two wrong sieves are kept in `selftest.py` **T5** as permanent negative
controls: sieving with primes ≤ `Y` is a **no-op** (a residue `mod ℓ` with
`ℓ ≤ Y` is `< ℓ ≤ Y`, hence trivially `Y`-smooth), and sieving with primes in
`(Y, BB]` is **unsound** (18 false rejects out of 60 real relations). Both are
recorded because both would have produced a number.

---

## 6. H4 — does it scale? **No decay in probability; death by cost**

### 6.1 The decay curve, measured exactly, to 2²⁰⁰

Because of §2 the success probability can be measured with **no relation search
at all**, at any `n`. 3 000 instances per size:

| `n` | rate | | `n` | rate |
|---|---|---|---|---|
| 2²⁰ | 0.7637 | | 2⁸⁰ | 0.7437 |
| 2²⁶ | 0.7407 | | 2¹⁰⁰ | 0.7433 |
| 2³⁰ | 0.7483 | | 2¹⁴⁰ | 0.7403 |
| 2⁴⁰ | 0.7517 | | 2²⁰⁰ | 0.7363 |
| 2⁵⁰ | 0.7450 | | | |
| 2⁶⁰ | 0.7420 | | | |
| 2⁷⁰ | 0.7557 | | | |

```
2^20   0.7637 #############################################
2^26   0.7407 #############################################
2^30   0.7483 #############################################
2^40   0.7517 #############################################
2^50   0.7450 #############################################
2^60   0.7420 #############################################
2^70   0.7557 #############################################
2^80   0.7437 #############################################
2^100  0.7433 #############################################
2^140  0.7403 ###########################################
2^200  0.7560  (first run) / 0.7363 (3000-instance run)
```

Pooled `24632/33000 = 0.7464` vs 20/27, `z = +2.36`. Homogeneity across the 11
sizes: `χ² = 15.31` on `df = 10` — **consistent with a single constant.**

**PREREG-5 (≥ 0.70 at 2⁶⁰) PASSED: measured 0.7420. There is no decay in
success probability, out to 2²⁰⁰ — and §2 says there cannot be, since the
quantity is a function of `p, q, g` only.**

### 6.2 What does decay is the cost

Measured exponentiations per attempt (`exp_scale.py` phase 1):

| `n` | `b` | `BB` | `u = log n / log BB` | exponentiations/attempt |
|---|---|---|---|---|
| 2⁴⁵ | 20 | 71 | 7.11 | 6.6 × 10⁵ |
| 2⁵⁰ | 30 | 113 | 7.32 | 1.7 × 10⁶ |
| 2⁵⁵ | 40 | 173 | 7.06 | 2.6 × 10⁶ |
| 2⁶⁰ | 55 | 257 | 7.39 | 9.3 × 10⁶ |

At 2⁶⁰ a *single* attempt is ~10⁷ exponentiations — hours of CPU here. The
honest H4 answer: **the method does not decay in probability; it dies in cost,
and it was already hopeless in cost long before 2⁶⁰.**

### 6.3 End-to-end, actually run

One point of the end-to-end curve completed (`exp_scale.py` phase 2), so the
method is demonstrated to genuinely run above the sizes where relation search
becomes the wall:

| `n` | `b` | `c` | factors | rate | `z` vs 20/27 | exp/attempt | exp/success |
|---|---|---|---|---|---|---|---|
| 2⁴⁵ | 20 | 10 | 19/25 | 0.7600 | +0.22 | 4 355 849 | 5 731 381 |

N = 25 is small; this row is reported for completeness and is consistent with
§6.1, but the decay curve that carries the claim is the 33 000-instance one.

---

## 7. Cost per successful factor — the actual result

### 7.1 PREREG-6: `c` is wasted work

`c` swept at `n ≈ 2³⁰`, `b = 12`, N = 120 each (rate should be **flat**):

| `c` | rate | `z` vs 20/27 | relations/success | exponentiations/success |
|---|---|---|---|---|
| 1 | 0.7333 | −0.19 | **17.7** | **35 014** |
| 2 | 0.7833 | +1.06 | 17.9 | 34 875 |
| 3 | 0.7583 | +0.44 | 19.8 | 40 167 |
| 5 | 0.7000 | −1.02 | 24.3 | 48 555 |
| 8 | 0.7667 | +0.65 | 26.1 | 52 529 |
| 10 | 0.7417 | +0.02 | 29.7 | 57 165 |
| 15 | 0.7583 | +0.44 | 35.6 | 67 060 |

and at `n ≈ 2²⁶`, `b = 8`: `c=1` → 11.6 rels/succ, `c=10` → 24.3.

**The rate is flat (every `z` inside ±1.1) while the cost is monotone in `c`.**
The paper's `c = 10` buys accuracy on an index that §2 shows is discarded.
`c = 1` is **1.63× cheaper** at `b = 12`, **2.09×** at `b = 8`.

`c = 1` requires a **bounded stripper** (`strip_bounded`): strip only primes
≤ `Y = 2·10⁵` by trial division, leaving `M' = ord(g)·s` with `s` odd, so
`g^(M'/2) = (g^(ord/2))^s = g^(ord/2)` and the gcd is unchanged. Self-test
**T8** verifies `strip_bounded` and `factor_from_multiple` agree on every
instance including the odd-order ones: **0/24 differ.** This is what makes `c = 1`
usable, since `factorint(G)` on a single huge `α` is intractable.

### 7.2 `b` sweep — and the 53× per-relation gap, explained

| `b` | `BB` | `u` | Dickman `1/ρ(u)` | measured exp/relation | exp/attempt `(b+c)·` | rate |
|---|---|---|---|---|---|---|
| 6 | 13 | 8.11 | 5.5 × 10⁵ | 23 880 | 167 163 | 0.6417 (`z = −2.48`) |
| 12 | 37 | 5.76 | 2.3 × 10⁴ | 1 975 | 25 677 | 0.7333 |
| 20 | 71 | 4.88 | 2.0 × 10³ | 453 | 9 506 | 0.7750 |

**This is a real effect and not a defect.** Larger `b` means a larger factor-base
bound `BB`, so `g^x mod n` is FB-smooth more often — the ordinary
index-calculus smoothness/count trade-off, and the measured 53× gap tracks the
Dickman-predicted 274× gap in direction and order of magnitude (measured
smoothness runs above the asymptotic `ρ` at these sizes, which is expected for
small `BB`).

**It is also the wrong metric, and per-relation cost is not an improvement.**
Total cost per attempt is `(b + c) × exp/relation`: 167 163 → 25 677 → 9 506.
`b = 20` beats `b = 6` by **17.6×** on total cost. Read per-relation and it
looks backwards; read as total cost it is the expected monotone trend.

⚠️ The `b = 6` rate of 0.6417 (`z = −2.48`) is the one number in this round that
does not sit on 20/27. It is either chance (one outlier in 13 configurations
tested; `P ≈ 0.16`) or a small-`b` pathology. **`exp_b6check.py` was launched to
settle it by scoring every `b=6` instance with both strippers; I do not have its
result and therefore do not report `b = 6` as anything.** `b = 6` is not used in
any recommendation.

### 7.3 HELD OUT — all four schemes, fresh instances

Seeds 990 000+, never used while any parameter was being chosen (tuning used
510 000–650 000, 770 000, 890 000). `n ≈ 2²⁶`, `b = 8`, 200 instances:

| scheme | rate | `z` vs its own prediction | relations/success | exp/success | vs S0 |
|---|---|---|---|---|---|
| **S0 BASELINE** (`g` uniform, `c=10`, full strip) | 0.7500 | +0.30 vs 20/27 | 24.0 | 27 772 | 1.00× |
| **S1 PREREG-6** (`g` uniform, `c=1`, bounded strip) | 0.7450 | +0.14 vs 20/27 | 12.1 | 14 145 | **1.96×** |
| **S2 H1-bias** (Jacobi `= −1`, `c=10`) | 0.9150 | +1.18 vs 8/9 | 19.7 | 23 508 | **1.18×** |
| **S3 COMBINED** (Jacobi `= −1`, `c=1`) | 0.9100 | +0.95 vs 8/9 | **9.9** | **11 787** | **2.36×** |

Second held-out configuration, `n ≈ 2³⁰`, `b = 12`, 200 fresh instances:

| scheme | rate | `z` vs its own prediction | relations/success | exp/success | vs S0 |
|---|---|---|---|---|---|
| **S0 BASELINE** | 0.7200 | −0.67 vs 20/27 | 30.6 | 60 752 | 1.00× |
| **S1 PREREG-6** | 0.7200 | −0.67 vs 20/27 | 18.1 | 35 564 | **1.71×** |

**The held-out numbers match the tuning predictions**: S0/S1 land on 20/27, S2/S3
land on 8/9. The `c = 1` saving is 1.96× here and 1.71× at `b = 12`, against
tuning values of 1.96× and 1.63× — **held-out agrees with tuning; it is not a
tuning artifact.** (S2/S3 for the `b = 12` configuration had not finished when
this note was written; the `2²⁶` row is the complete four-scheme comparison.)

---

## 8. Verdict on each hypothesis

| | hypothesis | verdict |
|---|---|---|
| **PREREG-0** | baseline 0.75 reproduces | **PASSED** — 192/260 = 0.7385 |
| **H1** | biasing `α_t` raises success above 0.85 | **FALSIFIED.** Provably: the index is stripped before the gcd. The relation-level arms (B2/B3) were **not measured** — the run died in the preceding arm — and I do not report them; the §2 identity is the stronger statement. **A bias on `g` instead works: 20/27 → 8/9, free, held out at 0.915/0.910.** |
| **H2** | the heavy tail is usable | **FALSIFIED.** `z = −0.11` on 260 rows, and the dependence is *exactly* zero, so this is a proved null, not a sample-size problem. The `v2` cell has `n = 2` and carries no information. |
| **H3** | a sieve buys relations more cheaply | **FALSIFIED.** The primorial sieve cuts exponentiations by **exactly 0%**; best wall clock 1.94× < 2× target, from a variant whose count discrepancy I did not resolve and do not claim. |
| **H4** | success decays with `n` | **FALSIFIED.** 0.7420 at 2⁶⁰ (target ≥ 0.70); flat to **2²⁰⁰**; `χ² = 15.3 / df 10`. Cost, not probability, is what dies. |
| **PREREG-6** | rate flat in `c`, cost minimised at small `c` | **CONFIRMED.** Rate flat over `c ∈ [1,15]`; `c=1` is 1.63–2.09× cheaper. |

## 9. Correction to round 48 that the coordinator should carry forward

Round 48's headline was "the first factoring method in 48 rounds, and its
analysis is false." **The success rate it measured was never evidence about the
Q-kernel construction at all.** `P = 20/27` is the classical constant for the
order-finding step that follows the linear algebra. Any method ending in
"take a multiple of `ord(g)`, strip it, gcd" scores 20/27, whether the multiple
came from Stange's kernel, from Shor, or from picking the integer
`2·ord(g)` off the shelf.

So round 48's refutation of Hypothesis 3.1 stands — but the "α_t non-uniformity"
mechanism offered for it is a **confound**: the raw `α_t` are multiples of an
even `ord(g)` 8/9 of the time, and the normalised `α_t/ord(g)` that the
hypothesis actually models do not show that bias. Hypothesis 3.1 may well still
be false; the mechanism offered for it is not the right one.

## 10. What is honestly claimed

**Claimed.** (i) `P(success) = 20/27` exactly, n-independent, out to 2²⁰⁰.
(ii) `c = 10` is wasted work; `c = 1` is 1.63–2.36× cheaper per successful
factor at identical success. (iii) Choosing `g` with `(g/n) = −1` raises the
rate to `8/9` at zero relation cost — 1.18× on its own, 2.36× combined with (ii),
both held out. (iv) The `α_t` small-prime bias is real but causally inert.

**Not claimed.** That this helps at RSA scale — it does not, and the regime gap
is unchanged. That the `α_t` bias is *exhausted* — it is erased, which is
stronger. Any asymptotic improvement. The `b = 6` anomaly is unexplained.
The early-abort sieve's 1.94× is unexplained and not claimed.

**One line: the 0.75 was the order-finding constant all along; the real waste in
the paper is `c = 10`, and cutting it plus one free Jacobi-symbol filter buys a
2.36× constant factor on a method that is still hopeless where it matters.**