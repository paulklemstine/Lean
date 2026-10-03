# S_supply — is the box→scan overstatement a constant or a power law?

**Round 49, supply axis.** Working files: `factor-scratch/r49/exp/supply/`.
Seed `20261003` throughout. Python 3.12, exact integer arithmetic (`math.isqrt`).

---

## 0. The claim under audit

`Catalog/Cryptography/FactoringBarriers/Round48_CostExponent.md` §3, verbatim:

> **The box is not the algorithm's population.** Supply in the box (`m ~ N^(1/3)`, `c` in a
> 16-value hand-picked pool) is exactly `C·N^(-1/6)`, but the box overstates a scanned
> instance's relation rate by **47× (24 bits) to 326× (32 bits)**, and its `χ_P = −1` fraction
> is ~79% against the scan's ~23%. Every supply number in Rounds 45–47 is a box number; none
> is a rate for the algorithm.

The two numbers `47×` and `326×` are the `A/B` column of
`~/factor47/V4/T1exact.log`, produced by `~/factor47/V4/T1exact.py`.

---

## 1. H, preregistered before measuring

Full text in `00_PREREG.md`, written before any measurement ran.

> **H.** `F(N) := box_rate(N) / scan_rate(N)` grows as a power law `F = N^alpha`.
> **Prediction, reasoned in advance:** `alpha` is **POSITIVE, in [0.3, 0.6]**.
> Derivation: box `|l| ~ N^(1/3) H^4` ⇒ rate `~ N^(-1/6)`; scan `|c| ~ N/3` ⇒
> `|l| ~ N^(4/3) H^4` ⇒ rate `~ N^(-2/3)`; so `F ~ N^(+1/2)` under a `1/(2√l)` density,
> and `F ~ N^beta` under the file's own corrected density `l^(-0.35)` ⇒ `alpha ≈ 0.35`.
> **Mechanism predicted in advance:** a fixed 16-value pool is a CONSTANT and cannot
> produce growth in `N`; the growth must come from `|c|` (box `O(1)`, scan `~N/3`).

---

## 2. Self-test (written first) — `01_selftest.py`

**It caught two real defects in my own harness before any measurement was trusted.**

| gate | result |
|---|---|
| `H=40`, `CPOOL` 16 values, max 31, 1958 coprime pairs | PASS |
| **can the relation counter return ZERO?** generic `(m,c)`: 300/300 instances zero | PASS |
| **can it return NON-ZERO where correct?** box population: 575 relations / 400 inst | PASS |
| vectorised counter == **independent** brute force | PASS 0/90 mismatch |
| known-positive control `(m=4,c=0)` | PASS (27 relations) |
| documented null family `u=-t, c=(2t/v)^3 ⇒ l=36t^4` is a square | PASS |
| **QR speed-filter loses nothing** (scalar == batch, both populations) | PASS after fix |
| `chiP` attains **−1, +1 and 0**; matches independent Legendre | PASS |
| shared harness `dickman.py`: `rho(2)`,`rho(4)`; **`is_smooth` CAN return False** (44.6% False) | PASS |

**Defect 1 (mine):** the QR prefilter had `t[0]=False`, silently discarding every relation
with `l ≡ 0 (mod M)`. **Defect 2 (mine):** the 2-adic QR rule was over-restrictive at `v₂=4`
(at modulus `2⁶` the odd part matters mod 4, not mod 8), discarding true relations. Both were
caught by gate 4 and gate 6. Rebuilt by brute force over the prime-power moduli.

Shared `dickman.py` used as-is for the smoothness gate (its null reproduces `rho` to 1.43σ);
no smoothness function written here.

---

## 3. THE MANDATORY CONTROL — **PASSES at 0.92σ** (`02_control_chip.py`)

My scan sampler, run over the complete `m = 1..N` scan, reproduces `CEIL3b.log` **exactly**:

| bits | N | m-trials | all rel | χ_P=−1 | χ_P=+1 | null | frac −1 |
|---|---|---|---|---|---|---|---|
| 10 | 589 | 581 | **1021** | **211** | 223 | **102** | 0.2067 |
| 12 | 2537 | 2524 | **1753** | **422** | 410 | **50** | 0.2407 |
| 14 | 8509 | 8489 | **2761** | **598** | 613 | **272** | 0.2166 |
| 16 | 32881 | 32849 | **3566** | **899** | 886 | **25** | 0.2521 |

Every count matches `CEIL3b.log` (1021/1753/2761/3566; genuine 211/422/598/899; null
102/50/272/25) **exactly, to the relation**.

```
POOLED scan chi_P = -1 fraction: 2130 / 9101 = 0.2340
the file's scan value:           ~0.23
deviation: 0.92 sigma
CONTROL PASSES
```

**So my sampler is the scan's population, not the box's.** This is the gate the brief demands
and it is satisfied.

> **A transcription bug I introduced is worth recording.** My first `chiP` read `b == p-1`
> where the original `V4/CHI_BOXSCAN.py` reads `b == q-1`. It made `chi_P = −1` return 0 for
> every `w`. The control caught it (0/9101 instead of 2130/9101) — the control is exactly the
> instrument that catches this class. **The original file is correct; only my copy was wrong.**

---

## 4. Reproduction of both arms

### 4a. The BOX arm reproduces (`T1exact.py` arm A: `m ~ U[m0,2m0]`, `c ~ U[CPOOL]`)

200,000 instances per size, vs the file's 20,000/4,000/4,000:

| bits | my box rate (200k inst) | T1exact reported | ratio |
|---|---|---|---|
| 24 | 8.917e-01 | 8.142e-01 | 1.095 |
| 28 | 6.075e-01 | 5.902e-01 | 1.029 |
| 32 | 4.061e-01 | 4.073e-01 | 0.997 |

**The box arm reproduces to within 10%, and at 32 bits to 0.3%.** The box side of `F` is sound.

### 4b. The SCAN arm does **not** reproduce, and the reason is the sample, not the code

`T1exact.py` drew **one** semiprime per bit size (`make_N(bits, Random(4242+bits))`) — a
caveat its own author listed. Measuring the scan rate across **20 distinct semiprimes** at each
size, 15,000 instances each:

| bits | N giving **ZERO** relations | median rate | mean rate | max rate | file's single-N rate |
|---|---|---|---|---|---|
| 24 | **7/20** | 7.667e-03 | 7.030e-03 | 3.127e-02 | 1.715e-02 |
| 28 | **8/20** | 1.533e-03 | 1.327e-03 | 5.600e-03 | 1.000e-02 |
| 32 | **14/20** | **0.000e+00** | 1.700e-04 | 8.667e-04 | 1.250e-03 |

**At 32 bits, 14 of 20 semiprimes yield literally zero relations in 15,000 instances.** The
scan rate is not a function of `N`; it is a heavy-tailed lottery on which `N` you drew. The
observed across-`N` spread (`sd/mean` = 1.13, 1.08, 1.64) exceeds the Poisson floor (0.097,
0.224, 0.626) at 24 and 28 bits — genuine excess variation.

**The file's 32-bit scan rate (1.25e-03) is 7.4× the 20-N mean and 1.44× the 20-N _maximum_.**
It is not a draw from the distribution; it is above every member of a 20-sample. Its `F = 326`
is therefore an **under**statement: a lucky `N` inflated the scan rate and deflated `F`.

### 4c. The reported 32-bit point rests on **five events**

| bits | TRIALS | arm-A events | arm-B events | A/B |
|---|---|---|---|---|
| 24 | 20,000 | 16,284 | 343 | 47.5 |
| 28 | 4,000 | 2,361 | 40 | 59.0 |
| 32 | 4,000 | 1,629 | **5** | 325.8 |

The `47 → 326` growth is `A/B` with **5 events** in the denominator. Exact Poisson 95% CI on
5 events: mean in `[1.62, 11.67]`, a **7.2× width** — so `F` at 32 bits carries a ±3.6× CI
from counting alone, before the across-`N` variation.

The file's own three points are also **not** fit by one power law: OLS on the published triple
gives `alpha = 0.347` with the 28-bit point off by **1.64×** (fitted 97.0 vs observed 59.0).
Three points cannot support a growth rate, and these three do not even lie on a line.

---

## 5. DECOMPOSITION — constant pool bias vs size-dependent bias

### D1: pool composition is a **CONSTANT** (as preregistered)

At 28 bits, one fixed `N`, 8,000 instances each:

| pool | size | rate | ×CPOOL |
|---|---|---|---|
| CPOOL (16 hand-picked) | 16 | 0.59937 | 1.000 |
| all of [1,31] | 31 | 0.81675 | 1.363 |
| evens [2,30] | 15 | 0.76075 | 1.269 |
| primes ≤ 31 | 11 | 0.61275 | 1.022 |

And **is the ratio constant across sizes?** This is the decisive question:

| bits | CPOOL rate | all-[1,31] rate | ratio |
|---|---|---|---|
| 24 | 0.91017 | 1.12367 | **1.235** |
| 28 | 0.62217 | 0.76967 | **1.237** |
| 32 | 0.42017 | 0.56383 | **1.342** |

**The pool-composition factor is 1.24, 1.24, 1.34 across 24→32 bits — flat.** The
16-value hand-picked pool contributes a **constant ≈1.24×**, and **cannot** produce growth in
`N`. This confirms the preregistered mechanism prediction and **refutes** the file's framing
that implicates pool selection in a size-dependent way.

### D2: the growth is in `|c|` — `rate ~ |c|^(-0.30)`, and `beta` predicts `alpha`

Holding `N` **fixed** and varying only the scale of `c` (`m ~ U[m0,2m0]` unchanged), 4,000
instances per point:

| `\|c\|` scale | 31 | 100 | 316 | 1000 | 3162 | 10⁴ | 31623 | 10⁵ | 316228 | 10⁶ |
|---|---|---|---|---|---|---|---|---|---|---|
| rate @24 bits | 1.207 | 0.911 | 0.711 | 0.495 | 0.339 | 0.262 | 0.179 | 0.106 | 0.0655 | 0.040 |

```
beta = -dlog(rate)/dlog|c| :   24 bits  beta = -0.3257   R2 = 0.9868   n = 10
                              32 bits  beta = -0.2645   R2 = 0.9910   n =  5
```

So **`rate ~ |c|^(-0.30)`**, cleanly, at fixed `N` — a 5-decade lever arm in `|c|` with
R² ≈ 0.99. This is the **size-dependent** part of the mechanism, and it is *not* the pool:
it is the magnitude of `c`.

Because the box has `|c| ~ 31` (constant) and the scan has `|c| ~ N/3`:

```
F(N) = rate(|c|=31) / rate(|c|=N/3)  ~  (N/93)^0.30   =>   alpha = beta ~ 0.30
```

**This is the mechanism, isolated and measured without reference to any published number:**
the overstatement is driven by `|c|`, and `alpha` should equal `beta ≈ 0.30`.

### Summary of the decomposition

| component | size-dependent? | size |
|---|---|---|
| **pool composition** (16 hand-picked vs all of [1,31]) | **NO — constant** | ≈1.24×, flat across 24/28/32 bits |
| **`\|c\|` magnitude** (box 31 vs scan `N/3`) | **YES — this is the whole of it** | `N^0.30` |

**The file's mechanism attribution is half wrong.** It names "(i) a 16-value hand-picked pool"
as a source of the overstatement; measured, the pool is a constant 1.24× and contributes
**no** growth in `N`. The growth is entirely `|c|`.


---

## 6. THE FIT — `alpha` is POSITIVE

`F(N)` averaged over **32 distinct semiprimes per bit size**, 20,000 instances each
(640,000 instances per size), seed `20261003`:

| bits | #N | scan mean rate | scan **median** | box mean rate | **F** | F 95% CI | **N giving ZERO** |
|---|---|---|---|---|---|---|---|
| 20 | 32 | 2.6541e-01 | 2.6665e-01 | 1.52405 | **5.74** | [5.46, 6.06] | 0/32 |
| 24 | 32 | 7.0031e-03 | 4.6000e-03 | 0.88165 | **125.9** | [90.2, 191.1] | 8/32 |
| 28 | 32 | 5.9531e-04 | **0.0000** | 0.62027 | **1042** | [671, 2078] | 22/32 |
| 32 | 32 | 9.2187e-05 | **0.0000** | 0.40325 | **4374** | [2032, 64520] | **28/32** |

```
FIT alpha:  log F = alpha * log N + c
n points = 4   (bits 20, 24, 28, 32)

alpha (OLS)              = +0.7942  +- 0.0946   2se [+0.6051, +0.9833]   dof = 2
alpha (inverse-variance) = +0.9914  +- 0.0474   2se [+0.8966, +1.0862]

per-point residuals (OLS): -0.73, +0.78, +0.63, -0.68 sigma   -- all under 0.8 sigma
```

### `alpha` is POSITIVE at 2σ. The exponent `-(1/6)` does **not** survive.

**True supply exponent `-(1/6 + alpha)`:**

| | value |
|---|---|
| from OLS | **−0.961** |
| from inverse-variance | **−1.158 ± 0.047** |
| the record's box exponent | −0.1667 |

The true supply rate for the algorithm's actual population falls as **`N^-0.96` to `N^-1.16`**,
not `N^-1/6`. That is **6–7× steeper** than every supply number in Rounds 45–47.

### Honest reporting: my magnitude prediction was WRONG, my sign prediction was RIGHT

`00_PREREG.md` predicted `alpha ∈ [0.3, 0.6]`. Measured: **0.79–0.99**, **outside** that band.
The prediction is **partially refuted** and I am recording that rather than moving the goalposts.

**Why I was low, and it is a real effect, not noise.** My D2 `beta` was fitted at *small* `|c|`
(31 → 10⁶). Extending the same measurement out to the scan's actual `|c| ~ N/3 ≈ 10⁹` at 32
bits shows the local exponent **steepens monotonically**:

```
|c| scale        1e1      1e3      1e5      1e7      1e9
rate         5.53e-1  2.27e-1  5.01e-2  6.30e-3  8.00e-4
local slope:      -0.256  -0.328  -0.450  -0.448
```

`beta` is **not a constant**: it runs −0.21 (20 bits) → −0.27 (32 bits) → −0.33 (24 bits) at
small `|c|`, and −0.45 at the scan's `|c|`. The correct statement is `rate ~ |c|^{-beta(|c|)}`
with `beta` increasing, so `F ~ N^{beta_eff}` with `beta_eff ≈ 0.45–1.0`. **My preregistration
assumed a constant `beta`; that assumption is what failed, and the correction is that the
square density in `|c|` is not a power law over the full 8 decades the scan traverses.**

### The reported 47×/326× growth is not reproducible

| | file | this audit (32 N / 640k inst) |
|---|---|---|
| F at 24 bits | 47.5 | **125.9** [90, 191] |
| F at 32 bits | 325.8 | **4374** [2032, 64520] |
| implied `alpha` | 0.347 (3 points, not collinear) | **0.794 ± 0.095** |

The file's 24-bit `F` is **2.7× too small** and its 32-bit `F` is **13× too small**. Both
because it drew **one** semiprime per size from a distribution in which, at 32 bits,
**28 of 32 semiprimes yield zero relations in 20,000 instances**.

---

## 7. Verdict: does "the supply is dead at 128 bits" SURVIVE?

**YES — and it is strengthened, not weakened.** But for a reason the record does not give, and
one of its stated supports is wrong.

**Why it survives.** The supply exponent is `-(1/6+alpha) ≈ -0.96` to `-1.16`, far steeper than
the `-1/6` the record assumed. A steeper decay makes the 128-bit zero **more** expected, not
less. At `-1/6`, going 96 → 128 bits costs a factor `2^(32/6) = 40`; at `-1.0` it costs
`2^32 = 4.3·10⁹`. The measured zero at 128 bits is unremarkable under the corrected exponent.

**Which claims move and which do not.**

| claim | verdict |
|---|---|
| **"Supply in the box is exactly `C·N^(-1/6)`"** | **SURVIVES as a box statement**, and my box arm reproduces it (0.997–1.095× the file's own rates). |
| **"The box overstates by 47×–326×"** | **REFUTED as stated.** The numbers are single-`N` draws; the true values are 126× (24 bits) and ~4400× (32 bits). The *direction* is right, the magnitude is 3–13× too small. |
| **"…and its `χ_P=-1` fraction is ~79% against the scan's ~23%"** | **HALF REFUTED.** The scan's 23% **reproduces exactly** (0.2340, 0.92σ). The box's **79% does not reproduce at all** — measured over relations whose instance is a genuine semiprime, the box `χ_P=-1` fraction is **0.001–0.02**. The file's own table (`gen`/nrel = 19/140 = 14%) does not support 79% either; 79% is `1 - (χ_P=+1 fraction)`, which silently counts the **undefined** cases (`p∣w` or `q∣w`, 66% of box relations) as usable. |
| **"Every supply number in Rounds 45–47 is a box number; none is a rate for the algorithm"** | **SURVIVES, and is now quantified**: the correction is `N^(0.79±0.09)`, not a constant. |
| **Round 48's `cost ∝ N^0.534`** | **UNAFFECTED.** It was measured by **stopping times on a real scan** (324 runs, 1.597·10⁷ m-scans, 323 real factors). It is already the algorithm's population; a box→scan correction cannot reach it. **The round-48 audit's worry — that this correction reaches a published claim — is resolved: it does not reach 0.534.** |
| **"the supply is dead at 128 bits"** | **SURVIVES, strengthened** (steeper true exponent). |

**The net correction to the record is therefore larger than the record itself claims, and it
runs against the method, not for it.** The box overstated the cost by 47–326×; it actually
overstated it by ~126–4400×. Every cost estimate built from box rates in Rounds 45–47 is
optimistic by `N^0.79`, not by a constant.

---

## 8. Defects found, in the order they were found

1. **Mine — QR prefilter had `t[0]=False`.** Discarded every relation with `l ≡ 0 (mod M)`.
   Caught by the self-test. Fixed by brute-force table construction.
2. **Mine — 2-adic QR rule over-restrictive at `v₂=4`** (at `2⁶` the odd part matters mod 4,
   not mod 8). Caught by the scalar-vs-batch gate. Same fix.
3. **Mine — `chiP` transcription: `b == p-1` for `b == q-1`.** Made `χ_P=-1` return 0 always.
   **Caught by the mandatory control** (0/9101 vs 2130/9101). The upstream file is correct.
4. **The record — `T1exact.py` used ONE semiprime per bit size.** At 32 bits, 28/32 semiprimes
   give zero relations in 20,000 instances; its scan rate is above the **maximum** of 20
   independent draws. The 326× rests on **5 events**.
5. **The record — the 47→326 "growth" is fitted from 3 points that are not collinear**
   (OLS `alpha=0.347`, 28-bit point off by 1.64×).
6. **The record — the "~79% usable box relations" is an artifact.** It is `1 - (χ_P=+1)`,
   which counts undefined `χ_P` (66% of box relations) as usable. The file's own counts give 14%.
7. **The record — the mechanism attribution is half wrong.** It names the 16-value pool;
   measured, the pool is a **constant 1.24×** and the growth is entirely `|c|`.
8. **Mine — the preregistered constant-`beta` assumption.** `beta` steepens from −0.21 to −0.45
   over the `|c|` range the scan actually traverses; my `[0.3,0.6]` band was too low because
   of it. Reported, not repaired.

---

## 9. Files

```
factor-scratch/r49/exp/supply/
  00_PREREG.md          H and the prediction, written BEFORE measuring
  S_common.py           primitives: exact relation counter, QR filter, chiP, semiprimes
  01_selftest.py        the self-test (caught defects 1-3)
  02_control_chip.py    THE MANDATORY CONTROL -> PASSES at 0.92 sigma
  03_measure.py         F(N), target-events sizing, D1/D2 decomposition
  04_perN.py            per-N variance -> the scan rate is a lottery on N
  05_fit_manyN.py       the many-N fit -> alpha = +0.794 +- 0.095
  03_measure.json, 03_decomp.json, 05_fit.json, *.log
```

Not committed, no GitHub issues, no paper — per instructions.

