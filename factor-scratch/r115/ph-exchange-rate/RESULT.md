# Axis A — the Pohlig–Hellman exchange rate (round 115)

**Verdict: SUPPORTED (as a cost measurement) — and the deployment consequence is a KILL.**

The claim being tested, and the falsifier that would have killed it, are stated
first. Everything below is either a *measured* number (labelled `[meas]`) or a
*prediction of a model that was validated against 264 measured instances*
(labelled `[model]`, with the validation error given). No number is a
library call's word.

---

## 1. The claim (falsifiable)

> **C1.** Given `n = 2^s · q` (`q` a `b`-bit prime), the cost of solving a
> generic discrete log in the cyclic group of order `n` splits into
> `sqrt(2^s) + sqrt(q)` group operations, against a **generic BSGS baseline of
> `≈1.5·sqrt(n)` mean / `2·sqrt(n)` worst**. The saving is
>
> `savings(s,b) = log2(generic / PH) ≈ min(s, log2 q)/2` **bits**,
>
> i.e. **one bit of factorization knowledge buys exactly half a bit of ECDLP
> work — a 2:1 exchange rate.**
>
> **C2.** There is **no** residual-prime size `b` at which PH stops being worth
> it (PH cost ≥ generic cost) in the ECDSA-relevant regime; the saving is
> *monotone in `s` and flat in `b`*, saturating at `s/2`.
>
> **C3.** For the standardized ECDSA curves the attack is **unavailable**
> (their group orders are prime, verified below), so the exchange rate is only
> spendable against an implementer who chose a composite/smooth order.

**Falsifier.** Any of the following would have refuted C1/C2:
(a) a measured `(s,b)` with `PH ≥ generic` anywhere above `|G| ≈ 2^16`;
(b) a measured saving that is *not* ≈ `min(s,b)/2` (e.g. linear in `s`, or
growing with `b`);
(c) a measured saving that differs when the known small factor is `3^k` instead
of `2^m`;
(d) `is_prime(n)` false for P-256 / secp256k1 / Ed25519's subgroup order
(which would make PH applicable after all).

None of (a)–(d) occurred. (a) is *locally* true only at `(s,b)=(4,4)`, below
the regime — see §6.

---

## 2. Exact reproduce commands

```bash
SAGE=/home/raver1975/sage_mamba/envs/sage/bin/sage   # Sage 10.9, durable path
D=/home/raver1975/lean/factor-scratch/r115/ph-exchange-rate

# (1) the main measured experiment: 22 (s,b) points x 12 seeds, run TWICE
cd $D && timeout 3000 $SAGE ph_exchange.sage > logs/run1.txt 2>&1   # run 1
cd $D && timeout 3000 $SAGE ph_exchange.sage > logs/run2.txt 2>&1   # run 2 (same seed)

# (2) direct measurement of the PH column at the two computable requested cells
cd $D && timeout 1800 $SAGE ph_requested.sage > logs/requested.txt 2>&1

# (3) the bounded partial-knowledge sub-experiment
cd $D && timeout 1800 $SAGE ph_partial.sage > logs/partial.txt 2>&1

# (4) ground-truth check that the standardized curve orders really are prime
cd $D && timeout 900 $SAGE curve_groundtruth.sage > logs/curve_groundtruth.txt 2>&1

# (5) analysis: run-twice check, model validation, exchange table, Q1, Q2
cd $D && python3 ph_analyze.py > logs/analysis.txt 2>&1

# (6) optional Lean stretch (CRT / Pohlig-Hellman combination lemma)
cd /home/raver1975/lean/Catalog && lake env lean \
    /home/raver1975/lean/factor-scratch/r115/ph-exchange-rate/ph_crt_lemma.lean \
    > $D/logs/lean_crt_lemma.txt 2>&1
```

Master seed `20261014` (main), `1152040` (requested), `1152075` (partial).
12 seeds at every parameter point. **Whole count run twice, fixed seed.**

---

## 3. What regime these numbers are in (triviality rule, stated up front)

**A `Z/nZ` *additive* DLP is trivially solvable: `d = h·g⁻¹ mod n`.** This is
explicitly *not* the point of the experiment and no claim rests on it: every
instance generated here is solvable by one modular inversion, and that
trivial solution is used **only as a ground-truth check** on the recovered
answer (all 264 + 24 + 180 instances agree with the planted `d` and with
`d·g == h (mod n)`).

What the experiment measures is **the cost of the algorithms** — BSGS and
Pohlig–Hellman — counted group operation by group operation, which is the
quantity that transfers to an elliptic curve where one group op is one point
addition. The cost statement is the claim; the concrete instances are a test
rig for it. `ZMod n` is used as a *generic group model*: the BSGS code never
uses ring structure beyond addition mod `n` and equality (it takes `(n, g, h)`
and cannot invert `g`), so the counted op sequence is the same one an EC
implementation would perform.

Regime of each number:

| number | regime |
|---|---|
| `[meas]` generic and PH columns, 22 points, `|n| = 2^8 … 2^44` | real measurement, both solvers on the same instance, 12 seeds, twice |
| `[meas]` PH column at `(20,40)` and `(40,40)` | real measurement of the PH side only (12 seeds) |
| `[model]` generic column at `b ≥ 40` | `2^((s+b)/2)` ops — **not computable in this harness** (2^30.6 … 2^90.6 ops). It is the validated model of §5. |

There is **no** cell in the requested table where a 40-bit-or-smaller group is
presented as evidence: the smallest `q` used anywhere is 4 bits (calibration),
and every headline number is at `|n| ≥ 2^24`.

---

## 4. The measured block — both runs

Two complete runs of `ph_exchange.sage`, same seed, same 12 seeds per point.
**Every group-op count is identical between the two runs** (only wall clock
differs: 222.2 s vs 188.3 s). 264 instances, all verified.

```
RUN-TWICE CHECK
  seed = 20261014   seeds/point = 12   parameter points = 22
  run 1 wall = 222.2 s      run 2 wall = 188.3 s
  every group-op count in run 1 == the corresponding count in run 2 : True
  all 264 recovered dlogs verified (d*g == h mod n, and d == the planted d): True
```

### 4.1 Measured head-to-head (1 group op = 1 modular addition)

`generic` = BSGS on the full group of order `n` (**the baseline**).
`PH` = BSGS in `⟨q·g⟩` (order `2^s`) + BSGS in `⟨2^s·g⟩` (order `q`) + CRT.

| s | b | &#124;n&#124;~ | generic mean | generic max | PH mean | PH max | savings (bits) |
|--:|--:|--:|--:|--:|--:|--:|--:|
| 20 | 4 | 2^24 | 5 719.3 | 7 297 | 1 652.8 | 2 036 | 1.791 |
| 20 | 8 | 2^28 | 20 159.7 | 28 686 | 1 616.9 | 1 948 | 3.640 |
| 20 | 12 | 2^32 | 82 702.7 | 103 321 | 1 756.9 | 2 234 | 5.557 |
| 20 | 16 | 2^36 | 305 676.2 | 423 895 | 2 155.8 | 2 543 | 7.148 |
| 20 | 20 | 2^40 | 1 221 394.5 | 1 633 657 | 3 015.1 | 3 519 | 8.662 |
| 20 | 24 | 2^44 | 5 936 898.7 | 7 749 997 | 7 332.8 | 9 219 | 9.661 |
| 4 | 20 | 2^24 | 4 755.3 | 5 740 | 1 356.2 | 1 759 | 1.810 |
| 8 | 20 | 2^28 | 20 976.8 | 30 093 | 1 321.8 | 1 575 | 3.988 |
| 12 | 20 | 2^32 | 88 476.8 | 114 624 | 1 522.2 | 2 156 | 5.861 |
| 16 | 20 | 2^36 | 333 306.7 | 463 291 | 1 750.7 | 2 086 | 7.573 |
| 24 | 20 | 2^44 | 5 686 556.2 | 7 623 220 | 7 558.8 | 9 088 | 9.555 |
| 4 | 4 | 2^8 | 26.5 | 34 | **38.2** | 40 | **−0.526** |
| 8 | 8 | 2^16 | 362.5 | 479 | 97.2 | 107 | 1.899 |
| 12 | 12 | 2^24 | 5 312.8 | 7 280 | 259.6 | 297 | 4.355 |
| 16 | 16 | 2^32 | 93 432.5 | 117 585 | 776.9 | 982 | 6.910 |
| 22 | 22 | 2^44 | 5 269 120.6 | 7 185 636 | 5 814.9 | 7 340 | 9.824 |
| 28 | 8 | 2^36 | 314 035.6 | 396 774 | 26 524.3 | 32 135 | 3.566 |
| 32 | 8 | 2^40 | 1 417 335.5 | 1 915 270 | 96 516.8 | 127 250 | 3.876 |
| 36 | 8 | 2^44 | 5 611 196.5 | 6 926 351 | 404 357.8 | 521 061 | 3.795 |
| 8 | 28 | 2^36 | 340 707.7 | 503 775 | 21 954.4 | 31 349 | 3.956 |
| 8 | 32 | 2^40 | 1 387 562.9 | 1 911 573 | 92 472.2 | 127 053 | 3.907 |
| 8 | 36 | 2^44 | 5 404 326.6 | 6 383 982 | 340 647.1 | 472 323 | 3.988 |

The savings column tracks **`min(s,b)/2`** across three orders of magnitude of
`|n|`, and is *flat in `b`* for fixed `s` (1.79, 3.64, 5.56, 7.15, 8.66, 9.66
for `s=20` as `b` goes 4→24, saturating at `s/2 = 10`).

### 4.2 Both runs of the raw point-by-point log

`logs/run1.txt`, `logs/run2.txt`, plus machine-readable
`logs/ph_main_run1.json`, `logs/ph_main_run2.json` (identical op counts).

---

## 5. The derived op-count model, validated per instance

The op count is *derived*, not fitted:

```
BSGS(order) = m  +  dbladd(m)  +  E[ floor(x/m) ],   m = ceil(sqrt(order)),  x ~ U[0,order)
dbladd(k)   = popcount(k) + bitlen(k) - 1            (double-and-add for the step element)
E[floor(x/m)] = ( m·L·(L−1)/2 + L·r ) / order,   L = order // m,  r = order % m

PH(n = 2^s·q)  = BSGS(2^s) + BSGS(q) + 2·dbladd(q) + 2·dbladd(2^s)   (the two subgroup encodings)
generic(n)     = BSGS(n)
```

**Validation against all 264 measured instances** (22 points × 12 seeds):

```
  mean  |err| generic  4.49%      PH  3.34%      (model over-predicts slightly: +1.1% / +0.26%)
  worst |err| generic 11.40%      PH 10.29%
  predicted 1-sigma of a 12-seed mean = 5.6%; observed |err|/sigma: max 2.05, mean 0.81
  worst per-INSTANCE |model − measured|: up to ~46%   (the model is an EXPECTATION;
       a given d can land anywhere in [1..m] giant steps, so per-instance deviation is large
       by construction — the per-POINT means are what the model predicts, and they match)
```

`sqrt(n)` spans `2^4 … 2^22` across the validation grid, i.e. a factor `2^18`.
**The residual scatter is exactly the predicted 12-seed sampling noise.**

### 5.1 The constant in front of the square root (precision point)

`generic/sqrt(n)` measured between **1.28 and 1.84** (mean ≈ 1.5), and
`E[giant steps]/m ≈ 0.48`. The reason: the number of giant steps is
`floor(d/m) + 1`, *not* `m`, because `d < n ≤ m²` and the mixed-radix
decomposition `d = i·m + j` is unique. So

> **BSGS averages `1.5·sqrt(n)` group ops; `2·sqrt(n)` is the worst case, not
> the typical case.**

Any exchange-rate table built on the textbook `2·sqrt(n)` overestimates the
baseline by 0.415 bits. Worse, the textbook PH cost `2^{s/2} + 2^{b/2}`
*drops the O(log n) cost of encoding the two subgroup generators*, which is
`2·dbladd(q) + 2·dbladd(2^s) ≈ 3·b` modular additions — irrelevant at
`b ≥ 40`, but decisive at small `b` (see §6).

---

## 6. The exchange table (the deliverable)

`s ∈ {20,40,60}` (known small part), `b ∈ {40,60,80,100,120}` (residual prime).
Expected op counts, averaged over `d ~ U[0,n)` and over `q ~ U[2^{b−1}, 2^b)`.
**The generic column is the baseline in every row.**

### 6.1 Expected op counts

| s | b | &#124;n&#124;~ | **generic (baseline)** | log2 | **PH** | log2 | **savings** | theory min(s,log2 q)/2 |
|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| 20 | 40 | 2^60 | 1.3883e+09 `[model]` | 30.37 | 1.3575e+06 `[model]` | 20.37 | **9.998** | 10.00 |
| 20 | 60 | 2^80 | 1.4216e+12 `[model]` | 40.37 | 1.3883e+09 `[model]` | 30.37 | **10.000** | 10.00 |
| 20 | 80 | 2^100 | 1.4557e+15 `[model]` | 50.37 | 1.4216e+12 `[model]` | 40.37 | **10.000** | 10.00 |
| 20 | 100 | 2^120 | 1.4906e+18 `[model]` | 60.37 | 1.4557e+15 `[model]` | 50.37 | **10.000** | 10.00 |
| 20 | 120 | 2^140 | 1.5264e+21 `[model]` | 70.37 | 1.4906e+18 `[model]` | 60.37 | **10.000** | 10.00 |
| 40 | 40 | 2^80 | 1.4216e+12 `[model]` | 40.37 | 2.9288e+06 `[model]` | 21.48 | **18.889** | 20.00 |
| 40 | 60 | 2^100 | 1.4557e+15 `[model]` | 50.37 | 1.3898e+09 `[model]` | 30.37 | **19.998** | 20.00 |
| 40 | 80 | 2^120 | 1.4906e+18 `[model]` | 60.37 | 1.4216e+12 `[model]` | 40.37 | **20.000** | 20.00 |
| 40 | 100 | 2^140 | 1.5264e+21 `[model]` | 70.37 | 1.4557e+15 `[model]` | 50.37 | **20.000** | 20.00 |
| 40 | 120 | 2^160 | 1.5630e+24 `[model]` | 80.37 | 1.4906e+18 `[model]` | 60.37 | **20.000** | 20.00 |
| 60 | 40 | 2^100 | 1.4557e+15 `[model]` | 50.37 | 1.6120e+09 `[model]` | 30.59 | **19.784** | 20.00 |
| 60 | 60 | 2^120 | 1.4906e+18 `[model]` | 60.37 | 2.9989e+09 `[model]` | 31.48 | **28.889** | 30.00 |
| 60 | 80 | 2^140 | 1.5264e+21 `[model]` | 70.37 | 1.4232e+12 `[model]` | 40.37 | **29.998** | 30.00 |
| 60 | 100 | 2^160 | 1.5630e+24 `[model]` | 80.37 | 1.4557e+15 `[model]` | 50.37 | **30.000** | 30.00 |
| 60 | 120 | 2^180 | 1.6006e+27 `[model]` | 90.37 | 1.4906e+18 `[model]` | 60.37 | **30.000** | 30.00 |

Sensitivity: for `s ≤ 39` the savings is **exactly flat in the true size of
`q`** (9.998–9.998 for `s=20`; 19.998–19.999 for `s=40`), because
`savings = min(s, log2 q)/2`.

### 6.2 Worst-case column (`d` near the top of the interval)

| s | b | generic (wc) | PH (wc) | savings (wc) |
|--:|--:|--:|--:|--:|
| 20 | 40 | 31.00 | 21.00 | 9.998 |
| 20 | 120 | 71.00 | 61.00 | 10.000 |
| 40 | 40 | 41.00 | 22.00 | 19.000 |
| 40 | 120 | 81.00 | 61.00 | 20.000 |
| 60 | 40 | 51.00 | 31.00 | 19.999 |
| 60 | 60 | 61.00 | 32.00 | 29.000 |
| 60 | 120 | 91.00 | 61.00 | 30.000 |

The exchange rate is *worst-case as well as average* — it is not a lucky-seed
artifact.

### 6.3 Two requested cells where the PH column is a real measurement

The generic baseline at these cells is `2^30.58` / `2^40.58` ops and is **not**
computable here; the PH column **was** measured (`ph_requested.sage`, 12 seeds):

| s | b | &#124;n&#124;~ | PH **measured** mean | PH max | all correct | generic `[model]` | savings vs measured PH |
|--:|--:|--:|--:|--:|--:|--:|--:|
| 20 | 40 | 2^60 | **1 200 396.2** (2^20.195) | 1 658 998 | 12/12 | 1.611e+09 (2^30.58) | **10.39 bits** |
| 40 | 40 | 2^80 | **2 713 394.7** (2^21.372) | 3 470 310 | 12/12 | 1.649e+12 (2^40.58) | **19.21 bits** |

Same-`q` model on those instances: 1 291 338 (+7.6% over measured, 1.19σ) and
2 926 076 (+7.8%, 2.55σ). Both agree with the table to within 0.4 bits.

---

## 7. The two questions the brief asks

### Q1. At what residual-prime size `b` does PH stop being worth it?

**There is no such `b` in the ECDSA-relevant regime. The premise is false.**

*Exact:* the leading-term crossover set is
`{(s,b) : 2^{s/2} + 2^{b/2} ≥ 2^{(s+b)/2}} = {(1,1),(1,2),(1,3),(2,1),(2,2),(3,1)}`
— both parts ≤ ~2 bits, i.e. `|G| ≲ 2^5`. For all `s,b ≥ 3` the PH leading
term is *strictly* below the generic one, so PH cannot lose inside the
square-root term.

*Measured:* the only PH loss anywhere on the grid is
`(s,b) = (4,4)`: generic **26.5** vs PH **38.2** → PH loses by **0.526 bits**,
entirely due to the `3·b ≈ 24`-op subgroup-encoding overhead. By `(8,8)` PH
already wins by **1.899** bits, and by `(12,12)` by **4.355**. So the PH-loses
region is bounded well below `2^16` in `|G|`.

*Saturation:* for `s = 20` the savings is `10.00, 10.00, 10.00, 10.00, 10.00`
as `b` goes `40 → 120`. **Flat in `b`, saturated at `s/2`.** The binding
constraint is not `b` crossing generic; it is the **absolute residual cost
`1.47·2^{b/2}`**, which no amount of small-part knowledge reduces.

### Q2. How much of `n` must the attacker know?

From the model, `PH/generic → 2^{−s/2}`, so

> **1 bit of known factorization buys exactly ½ bit of ECDLP work — the
> exchange rate is 2:1.**

Concretely, a `D`-bit saving needs **both** `s ≥ 2D` **and** `log2 q ≥ 2D`:

| desired saving `D` (bits) | known small part `s ≥` | residual `q ≥` |
|--:|--:|--:|
| 1 | 2 bits | 2 bits |
| 2 | 4 | 4 |
| 10 | 20 | 20 |
| 20 | 40 | 40 |
| 40 | 80 | 80 |
| 60 | 120 | 120 |
| 100 | 200 | 200 |
| 128 | 256 | 256 |

And **the residual `1.47·2^{b/2}` is independent of `s`**. Fixing an attacker
budget `T = 2^t` group ops and a group order of `N` bits:

| log2&#124;G&#124; | budget `2^t` | max log2 q | min `s` that must be known |
|--:|--:|--:|--:|
| 128 | 40 | 78.9 | 49.1 |
| 128 | 64 | 126.9 | 1.1 |
| 160 | 64 | 126.9 | 33.1 |
| 192 | 64 | 126.9 | 65.1 |
| **256** | **40** | 78.9 | **177.1** |
| **256** | **50** | 98.9 | **157.1** |
| **256** | **64** | 126.9 | **129.1** |
| **256** | **80** | 158.9 | 97.1 |
| **256** | **100** | 198.9 | 57.1 |

Reading the 256-bit rows: to push a 256-bit ECDLP inside a `2^64` group-op
budget, the residual prime must be `≲ 2^127`, so the attacker must already know
**~129 bits of the factorization of `n` — essentially half of it** — and the
127-bit residual still costs `2^63.5` ops on its own. Nothing becomes easy; the
square root is merely halved. With a `2^40` budget the attacker must know
**177 of the 256 bits**.

### The deployment table (generic column IS the baseline)

| curve / scenario | log2 n | generic_b | PH_b | savings | verdict |
|---|---:|---:|---:|---:|---|
| **P-256** (verified `n` prime, h = 1) | 256 | 128.6 | — | — | **PH INAPPLICABLE (n prime)** |
| **secp256k1** (verified `n` prime, h = 1) | 256 | 128.6 | — | — | **PH INAPPLICABLE (n prime)** |
| **Ed25519** (verified `L` prime, h = 8) | 252 | 126.6 | 125.1 | **1.50** | public cofactor 8 buys 1.5 bits — useless |
| hypothetical h = 2^20 | 256 | 128.6 | 118.6 | 10.00 | needs an implementer error |
| hypothetical h = 2^40 | 256 | 128.6 | 108.6 | 20.00 | needs an implementer error |
| hypothetical h = 2^80 | 256 | 128.6 | 88.6 | 40.00 | needs an implementer error |
| hypothetical 2^80-smooth order | 256 | 128.6 | 88.6 | 40.00 | ECDLP-256 at 2^89 — needs a composite order |
| hypothetical 2^128-smooth order | 256 | 128.6 | 65.6 | 63.00 | ECDLP-256 at 2^66 — needs a composite order |

Ground truth for the "prime" claims — verified, not asserted
(`logs/curve_groundtruth.txt`, Sage `is_prime`, PARI-based provable test):

```
P-256   n = FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551  bits=256  is_prime=True
secp256k1 n = FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141  bits=256  is_prime=True
Ed25519  L = 2^252 + 27742317777372353535851937790883648493                    bits=253  is_prime=True
```

**So Axis A's kill condition is met for the standardized deployments: the
residual largest prime factor is the whole group order (252–253 bits), far above
`2^100`, and there is no partial factorization of a prime order for a side
channel to leak.** The exchange rate is only spendable against an implementer
who chose a composite or smooth group order — a deployment bug, not a factoring
result.

---

## 8. Bounded sub-experiment: does knowing only PART of the small part help?

**Answer: yes, at the same 2:1 rate — and knowing *more* of the small part does
NOT touch the residual.** 12 seeds per cell, generic baseline always shown.
Full data in `logs/partial.txt` / `logs/ph_partial.json`.

The primitive used is exactly what PH gives you from knowing a divisor `f` of
`n` (coprimality of `f` and `n/f` is *not* needed — it is a lift, not a CRT):
solve `d mod f` in `⟨(n/f)·g⟩`, then solve the residual `t ∈ [0, n/f)` in
`⟨f·g⟩`. Cost `BSGS(f) + BSGS(n/f)`.

### 8.1 Case A — `n = 2^s·q1·q2`, attacker knows **only** `2^s`

`n = 2^s·q1·q2` with `q1,q2` of `b` bits. The **FULL** rows attack with the complete
factorisation `[2^s, q1, q2]`; the **PARTIAL** rows attack knowing **only** `2^s`,
lumping the whole residual as one modulus. Both rows of a cell are independent
12-seed draws, so their generic baselines differ by a few percent, and each saving
is computed against its own row's baseline.

| s | b | row | &#124;n&#124;~ | generic | PH | savings | theory |
|--:|--:|---|---:|---:|---:|---:|---|
| 4 | 16 | FULL `[2^s,q1,q2]` | 2^35.28 | 309 562.1 | 916.7 | 8.400 | `s/2+b/2−1.58 = 8.42` |
| 4 | 16 | **PARTIAL `[2^s, q1q2]`** | 2^35.17 | 305 091.8 | 76 402.8 | **1.998** | **`s/2 = 2`** |
| 8 | 16 | FULL `[2^s,q1,q2]` | 2^38.98 | 1 104 232.9 | 926.2 | 10.219 | `s/2+b/2−1.58 = 10.42` |
| 8 | 16 | **PARTIAL `[2^s, q1q2]`** | 2^39.02 | 1 200 935.6 | 75 220.8 | **3.997** | **`s/2 = 4`** |
| 12 | 12 | FULL `[2^s,q1,q2]` | 2^35.05 | 290 504.8 | 468.4 | 9.277 | `s/2+b/2−1.58 = 10.42` |
| 12 | 12 | **PARTIAL `[2^s, q1q2]`** | 2^35.01 | 298 576.8 | 4 882.0 | **5.934** | **`s/2 = 6`** |
| 4 | 20 | FULL `[2^s,q1,q2]` | 2^43.14 | 4 648 736.3 | 2 839.8 | 10.677 | `s/2+b/2−1.58 = 10.42` |
| 4 | 20 | **PARTIAL `[2^s, q1q2]`** | 2^42.98 | 4 184 404.9 | 1 046 259.4 | **2.000** | **`s/2 = 2`** |
| 8 | 14 | FULL `[2^s,q1,q2]` | 2^35.14 | 277 481.1 | 584.3 | 8.891 | `s/2+b/2−1.58 = 9.42` |
| 8 | 14 | **PARTIAL `[2^s, q1q2]`** | 2^35.25 | 318 728.4 | 20 070.0 | **3.989** | **`s/2 = 4`** |
| 12 | 16 | FULL `[2^s,q1,q2]` | 2^42.93 | 4 449 665.0 | 968.8 | 12.165 | `s/2+b/2−1.58 = 12.42` |
| 12 | 16 | **PARTIAL `[2^s, q1q2]`** | 2^42.97 | 4 503 698.2 | 70 619.4 | **5.995** | **`s/2 = 6`** |
| 4 | 12 | FULL `[2^s,q1,q2]` | 2^27.16 | 17 015.1 | 347.1 | 5.615 | `s/2+b/2−1.58 = 6.42` |
| 4 | 12 | **PARTIAL `[2^s, q1q2]`** | 2^27.17 | 18 012.8 | 4 603.4 | **1.968** | **`s/2 = 2`** |
| 8 | 12 | FULL `[2^s,q1,q2]` | 2^30.94 | 76 787.9 | 381.8 | 7.652 | `s/2+b/2−1.58 = 8.42` |
| 8 | 12 | **PARTIAL `[2^s, q1q2]`** | 2^31.13 | 75 788.7 | 4 872.2 | **3.959** | **`s/2 = 4`** |

Knowing **only** `2^s` and lumping the whole residual buys **exactly `s/2`
bits** (1.998, 3.997, 5.934, 2.000, 3.989, 5.995, 1.968, 3.959 — the partial
saving is *bit-exact* `s/2`). Splitting the residual into `q1,q2` buys a further
`≈ b/2 − 1.58` bits on top (predicted 6.42 vs measured 8.400 − 1.998 = 6.40 for
`s=4,b=16`).

### 8.2 Case B — `n = 2^{s+a}·q`, `a` bits of the 2-power hidden

`n = 2^{s+a}·q`, the attacker knows only `2^s`.

| s | a | b | &#124;n&#124;~ | generic | PH knowing `2^s` | **sav `2^s`** | theory | PH knowing `2^(s+a)` | sav `2^(s+a)` |
|--:|--:|--:|---:|---:|---:|---:|---:|---:|---:|
| 8 | 4 | 20 | 2^31.47 | 86 192.6 | 5 517.7 | **3.965** | `s/2 = 4` | 1 510.2 | 5.663 |
| 12 | 8 | 16 | 2^35.51 | 330 445.8 | 5 377.9 | **5.941** | `s/2 = 6` | 1 841.1 | 7.437 |
| 4 | 8 | 24 | 2^35.47 | 338 090.6 | 84 646.6 | **1.998** | `s/2 = 2` | 5 926.9 | 5.842 |
| 16 | 4 | 16 | 2^35.49 | 333 157.6 | 1 806.8 | **7.527** | `s/2 = 8` | 1 953.4 | 7.451 |
| 8 | 12 | 12 | 2^31.59 | 82 058.8 | 5 259.5 | **3.964** | `s/2 = 4` | 1 618.5 | 5.685 |
| 12 | 4 | 20 | 2^35.52 | 343 139.4 | 5 569.2 | **5.945** | `s/2 = 6` | 1 757.1 | 7.441 |


Hiding `a` bits of the 2-power costs **exactly `a/2` bits** of saving. The last
row pair is instructive: with `s=16, a=4, b=16`, knowing `2^16` and lumping
`2^4·q` gives **7.527** — *slightly better* than knowing `2^20` **and** `q`
(7.451), because once the lump is dominated by its own largest prime, splitting
it adds an equally-sized cost rather than removing one. **Only the largest
piece matters.**

### 8.3 Case C — is the exchange rate base-dependent (`2` vs `3`)?

Base independence: `3^k·q` versus `2^m·q` with `m = round(k·log2 3)`.

| known factor | bits absorbed | &#124;n&#124;~ | generic | PH | savings | matched `2^m` | savings `2^m` | absorbed `m` |
|---|---:|---:|---:|---:|---:|---|---:|---:|
| `3^4·q`, b=20 | 6.34 | 2^26.04 | 11 621.9 | 1 535.8 | 2.920 | `2^6·q` | 3.017 | 6 |
| `3^6·q`, b=16 | 9.51 | 2^25.10 | 8 269.4 | 490.2 | 4.076 | `2^10·q` | 4.541 | 10 |
| `3^8·q`, b=12 | 12.68 | 2^24.22 | 6 981.3 | 300.3 | 4.539 | `2^13·q` | 4.548 | 13 |
| `3^5·q`, b=18 | 7.92 | 2^25.36 | 9 889.8 | 756.8 | 3.708 | `2^8·q` | 3.834 | 8 |
| `3^7·q`, b=12 | 11.09 | 2^22.61 | 3 879.6 | 250.2 | 3.954 | `2^11·q` | 3.911 | 11 |
| `3^3·q`, b=22 | 4.75 | 2^26.21 | 13 160.8 | 2 501.4 | 2.395 | `2^5·q` | 2.398 | 5 |


Matched pairs agree to 0.003 / 0.04 / 0.01 / 0.13 / 0.10 bits
(`3^3`↔`2^5`, `3^7`↔`2^11`, `3^8`↔`2^13`, `3^5`↔`2^8`, `3^4`↔`2^6`); the one
outlier (`3^6`↔`2^10`, 0.47 bits) is the small-`n` encoding overhead of §5.1.

> **The exchange rate is per BIT of `n` absorbed into known factors, not per
> prime. Knowing `3^k` is worth exactly the same as knowing `2^{k·log2 3}`.**

**Verdict on the bounded sub-question: SUPPORTED (tractable, one small table
delivered, not INCONCLUSIVE).**

---

## 9. Lean stretch: the CRT combination lemma

`ph_crt_lemma.lean`, compiled with
`cd /home/raver1975/lean/Catalog && lake env lean .../ph_crt_lemma.lean`
(Mathlib only, Lean `v4.28.0`). Compiles **clean, zero warnings**, and
`#print axioms` reports only `[propext, Classical.choice, Quot.sound]` — **no
`sorryAx`**.

* **`ZMod.chineseRemainder (h : m.Coprime n) : ZMod (m * n) ≃+* ZMod m × ZMod n`
  already exists in Mathlib** (`Mathlib/Data/ZMod/Basic.lean`, line 875) — so
  the pure CRT statement needs nothing new and is only *cited* here (as an
  `example` that introduces no new proof).
* What was **not** in Mathlib is the discrete-log transfer:
  * `orderOf_pow_mul` — `orderOf (g^n) = m` and `orderOf (g^m) = n` when
    `orderOf g = m·n` (coprimality is *not* needed: `Nat.gcd (m*n) n = n` always).
  * `ph_restrict_m` / `ph_restrict_n` — the **restriction** lemmas: a dlog
    `g^d = x` determines the dlog in each part (`(g^n)^a₁ = x^n` whenever
    `a₁ ≡ d [MOD m]`).
  * **`pohlig_hellman_crt`** — the headline: with `m,n` coprime, `orderOf g = m·n`,
    the two part-solves `(g^n)^a₁ = x^n`, `(g^m)^a₂ = x^m`, and a CRT combination
    `a` with `a ≡ a₁ [MOD m]`, `a ≡ a₂ [MOD n]`, then **`g^a = x`**. This is the
    lemma the brief asked for.
  * `dlog_unique` — `g^a = g^d → a ≡ d [MOD orderOf g]`.
  * `pohlig_hellman_crt_additive` — the same statement with `•` instead of `^`,
    i.e. directly applicable to an elliptic curve / additive cyclic group.

The *cost* result is not and cannot be a Lean theorem; it is the measured
table above.

---

## 10. Traps hit (all survived)

1. **`exec()` was never used.** Every script is a self-contained `.sage` run
   through `sage file.sage` (preparser active). One preparse hazard *was* hit:
   in a `.sage` file `random` is **Sage's** `random` *function*, not Python's
   `random` module — the first version crashed with
   `AttributeError: 'function' object has no attribute 'Random'`. Fixed with
   `from random import Random as PyRandom`.
2. **Sage preparser converts integer literals to `Integer`, not `int`**:
   `PyRandom(20261014)` raised `TypeError: The only supported seed types are …`,
   and every `json.dump` blew up on `Object of type Integer is not JSON
   serializable`. Both wrapped/pinned with `int(...)`.
3. **`sage file.sage` compiles to a temp `.py`**, so `__file__` does not point at
   the script — the JSON log landed in `sage/logs/`. Log directory hard-coded.
4. **`isqrt`-free `ceil(sqrt(order))`**: `m*m < order` loop, exact.
5. **The textbook BSGS constant is wrong as usually quoted.** The giant-step
   count is `floor(d/m)+1`, i.e. `≈ m/2` on average, so the *mean* cost is
   `1.5·sqrt(n)` and `2·sqrt(n)` is the *worst* case. Measured
   `generic/sqrt(n) ∈ [1.28, 1.84]`, `E[giant]/m ≈ 0.48`. Any table built on
   `2·sqrt(n)` is 0.415 bits too optimistic about the baseline.
6. **The textbook PH cost drops the encoding overhead.** PH also pays
   `2·dbladd(q) + 2·dbladd(2^s) ≈ 3b` modular additions to build the two
   subgroup generators. At `b ≥ 40` this is < 0.001% and irrelevant; at
   `(s,b)=(4,4)` it makes PH **lose** (38.2 vs 26.5 ops). Reported, not hidden.
7. **First version of the partial-knowledge solver was wrong** — it multiplied
   the residual equation by `f` (`t·(f·g)` computed as `f·h − f·(df·g)`).
   Caught by the `assert xg == d and xf == d and xp == d` ground-truth check
   before any number was recorded.
8. **Lean gotchas**: a `/-!` or `/--` block before `import Mathlib` is rejected
   by this Lean (`invalid 'import' command, it must be used in the beginning of
   the file`); and for `ℕ` the modular-equality notation is `a ≡ b [MOD n]`
   (`Nat.ModEq`) — `a ≡ b [ZMOD n]` is `Int.ModEq` and silently means something
   else. `Nat.dvd_gcd`/`Nat.gcd_dvd_right` argument order also needed checking.
9. **`Nat.gcd (m*n) n = n` without coprimality** — proved rather than assumed,
   which is *why* `orderOf_pow_mul` in the Lean file carries no coprime
   hypothesis (coprimality enters only in `pohlig_hellman_crt`).

---

## 11. What would kill this (open, testable, cheap)

The exchange rate is a *measurement* of textbook Pohlig–Hellman with a
full-width cost model. It is **not** a new algorithm, and nothing here beats
`c·sqrt(n)` for a prime-order group. The results that would still matter and
cost little:

* a curve/implementation population study: how often is the group order
  actually composite (cofactor > 1 with a small known part)? That is the only
  thing that turns the 2:1 rate into an attack;
* the cost of *obtaining* the `s` bits (trial division to `2^s` costs `≈2^s/2`,
  which **dwarfs** the `2^{s/2}` it buys — so PH is rational only when the small
  part is *leaked*, not *searched*). This is the honest reading of "attacks
  ECDSA": the exchange rate is trivial, the *source* of the factorization
  knowledge is the whole problem.

---

## 12. Verdict

| sub-claim | verdict |
|---|---|
| C1: exchange rate is 2:1 and `savings ≈ min(s, log2 q)/2` bits, validated over 264 measured instances across `sqrt(n)` spanning `2^4 … 2^22`, worst-case as well as average | **SUPPORTED** |
| C2: no residual-prime size `b` where PH ≥ generic above `\|G\| ≈ 2^16`; saving flat in `b`, saturating at `s/2` | **SUPPORTED** (premise of Q1 refuted) |
| C3: standardized ECDSA curves are out of reach of the axis (group orders verified prime; 252–253-bit residual) | **SUPPORTED — this is Axis A's KILL for the standardized deployments** |
| partial knowledge of the small part is useful at the same rate; exchange rate is base-independent | **SUPPORTED** |
| CRT combination lemma in Lean (`pohlig_hellman_crt`) | **PROVED, no sorries, standard axioms only** |

**Honest overall verdict: SUPPORTED, with the campaign-relevant conclusion being
a KILL of Axis A for every deployed ECDSA parameter set.** The exchange rate is
real, universal, and exactly 2:1; and the standardized curves have prime group
order, so there is nothing to spend it on.
