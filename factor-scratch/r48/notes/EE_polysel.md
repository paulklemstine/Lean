# EE — NFS polynomial selection: is the round-48 anti-correlation exploitable?

**VERDICT: IT IS AN ARTEFACT, and the counter that produced it is not a relation
counter at all.** Re-measured with a correct exact counter, **larger coefficient
mass yields FEWER relations** — the opposite of the round-48 claim that larger
mass yields more (Spearman(mass, rate) = **−0.841**, where round-48's own five
numbers give +0.20). What does drive the rate is the **size of `f(a,b)` over the
sieving box**, through the ordinary smooth-number law. A weak selection rule
survives, but the exploitable part of it is the classical "search `m` widely"
gain, not anything new from the anti-correlation.

*(Careful with the word "anti-correlated" below: round-48 uses it to mean
"mass and rate move together the wrong way" = positive rank correlation. My result
is that they move the *other* wrong way. I say "opposite sign" where the sign
matters.)*

Everything below was measured on this host. Code: `factor-scratch/r49exp/polysel/`.
Self-test: `python3 selftest.py` → **exits 0**.

---

## 0. The finding I was asked to exploit, and what it actually is

`notes/I_constant.md` C3 reports, at fixed `N = 412333899797`, that

> the LARGEST-mass polynomial (11616) yielded the MOST relations (1090); the
> smallest (6820) the fewest (292) — ANTI-CORRELATED

and separately

> a bad `f` doesn't cost a constant, it costs everything — naive and
> narrow-search polynomials both produced **ZERO relations**.

Both statements come from `r48/exp/find_relations`. **That function is broken in
a way that is decisive for this axis, and the breakage is not subtle.**

### 0.1 The sieve mask is inverted

`find_relations` builds its sieved value as

```
norm(a,b) = sum_i fc[i] * a^(d-i) * b^i  =  b^d * f(a/b)
```

where `f_coeffs_of` returns `fc` **leading-first**, so `f(x) = sum_i fc[i] x^i`.
`split_primes` returns roots of exactly that `f`, and the mask is

```
(a - alpha*b) % p == 0      # i.e. a/b is a root of f
```

which looks right — **but it is not**, because the polynomial `find_relations`
actually evaluates is the *reverse*. With `d=3`, `norm(a,b) = a^d f(b/a)`, not
`b^d f(a/b)`: `a/b` is a root of `g`, while the divisibility condition belongs to
`f = x^d g(1/x)`, whose roots are the **inverses** of `g`'s. Measured directly
(`selftest.py` S6a):

```
fc = [1, -6, -648, -22]     # so g(x) = 1 - 6x - 648x^2 - 22x^3
p=  7  roots of g = [2]   roots of f = [4]     (2*4 = 1 mod 7)
p= 31  roots of g = [7]   roots of f = [9]     (7*9 = 1 mod 31)
```

Over all splitting primes `p <= 200`, **46 of 52** roots used by the mask have an
inverse that is *not* a root — i.e. the mask selects cells where `p` does **not**
divide the norm. For `p=7`, root `α=2`: every masked cell has `a/b ≡ 2`, but
`f(2) = 8−24−1296−22 = −1334 ≡ 3 (mod 7) ≠ 0`, so `7 ∤ norm` for all of them.

### 0.2 It under-counts the true smooth rate by 136×

Same box, same `y`, exact counter vs theirs (`selftest.py` S6b):

```
r48 find_relations   5.778e-04 relations/cell
exact counter        7.862e-02 relations/cell      (136.1x)
```

`find_relations` also deletes each cell on its first small prime and never adds
`log p` back, so its `alive` set is the complement of what a sieve needs, and it
then demands a non-empty factorisation from cells that by construction have none.
Whatever statistic it computes, it is not the y-smooth rate — and it is defined
by the splitting primes of the **wrong** polynomial, so its dependence on the
coefficients is a dependence on the wrong object. **Any correlation read off it
is uninterpretable.**

### 0.3 The round-48 note's own statistic is weak before it is wrong

Re-measuring the five published polynomials at the exact same `N`, with their
exact box (`|a|<600`, `1<=b<=600`, 720 000 cells) and `y=1000`. My masses
reproduce theirs to the digit — 11616, 6352, 4966, 8824, 6820 — so these are
their polynomials, not approximations:

| m | mass | mean log\|f\| | r48 rels | **correct rels** | r48 rate | correct rate |
|---|---|---|---|---|---|---|
| 6698 | 11616 | 24.725 | 1090 | **12007** | 7.57e-04 | 1.668e-02 |
| 7070 |  6352 | 25.220 |  539 | **17245** | 3.74e-04 | 2.395e-02 |
| 7294 |  4966 | 24.198 |  476 | **21485** | 3.31e-04 | 2.984e-02 |
| 7405 |  8824 | 24.803 |  425 | **29521** | 2.95e-04 | 4.100e-02 |
| 7443 |  6820 | 24.981 |  292 | **16173** | 2.03e-04 | 2.246e-02 |

```
Spearman(mass, r48 relation count)      = +0.200    <- the published "finding"
Spearman(mass, CORRECT relation count)  = -0.400    <- this re-measurement
max/min ratio  r48 3.73x   correct 2.46x
```

So even taken at face value the round-48 anti-correlation is **+0.20 over n=5**,
and it is carried entirely by the single most extreme point (m=6698, the only
`0.90·m*` sample); the other four are uninformative. The correct counter gives
the opposite sign.

### 0.4 "A bad f costs everything" is also an artefact

Same box and `y` as the note's claim (box 1500, `y=5000`, 10⁶ sampled cells):

| polynomial | mass | mean log\|f\| | relations | rate |
|---|---|---|---|---|
| standard (`m*`, digits) | 6820 | 27.74 | 35880 | 3.59e-02 |
| mass ≈ 4.3e5 (the "naive/narrow" regime) | 438456 | 31.96 | **12777** | 1.28e-02 |
| mass ≈ 4.3e5 (other sign) | 426202 | 31.93 | **16752** | 1.68e-02 |
| mass ≈ 3.7e6 | 3727820 | 34.09 | **8122** | 8.12e-03 |

**Zero relations is not reproduced.** A polynomial 60× worse costs a factor ~4,
which is a constant. There is no "costs everything" regime: the cost of a bad `f`
is bounded and continuous, exactly as the smooth-number law says it should be.

---

## 1. The harness, and the self-test that came first

`core.py` measures a cell `(a,b)` to be a relation iff `|f(a,b)|` is `y`-smooth,
decided by **exact trial division over every prime ≤ y**, on **every** cell — no
sieve pruning, no log accumulation, no early exit, no degenerate cells skipped.
Polynomials are monic of degree 3 with `f(m) = N` **exactly**, so `m` is a root
of `f` mod `N`, which is what makes them usable NFS polynomials at all
(`r48/exp/make_poly` does *not* have this property: measured on a 44-bit test
modulus, `f(m) mod N = 9882990890283 ≠ 0`. That is a concrete candidate
explanation for why C1 found "0 of 40 rows m-divisible" and reported it as a host
limitation — the Montgomery `m`-divisibility argument needs `m` to be a root of
`f` mod `N`, which this constructor does not deliver. **I did not verify that
link** (it would need a working relation generator, and the round-48 one is the
broken counter above); it is flagged as a lead, not a finding.

Three families, so that `m` and coefficient mass can be decorrelated:

* **A — `m` varies**, `f` from base-`m` digits of `N − m³`, box scaled as
  `0.08·m` (the natural NFS geometry).
* **B — `m` FIXED**, coefficients moved off the digit lattice by an exact
  two-parameter family that preserves `f(m) = N`, so mass can be swept over
  orders of magnitude with the geometry held fixed.

Self-test, all PASS, `python3 selftest.py` exits 0:

| id | property | result |
|----|----------|--------|
| S1 | `f(m)=N` and `f(m)≡0 mod N` | 401 values of m, 0 violations |
| S2 | offset family preserves `f(m)=N`, spans wide mass | 14140 → 6.4e6 |
| S3 | my cubic-irreducibility test == sympy | 20/20 |
| S4 | vectorised norm == brute force over **ALL** `(a,b)`, incl. `f=0` and `|f|=1` cells | 225 pairs, 0 mismatches |
| S5 | exact counter == shared `dickman.is_smooth` on every cell | 6561 cells, 0 disagreements |
| S6 | r48 mask inverted; counter under-counts 136× | 46/52 roots wrong |
| **S7** | **NULL control:** `f̃ = −f(−x)` (same mass, same \|f\| multiset) | 813 vs 808, **0.12σ** |
| **S8** | **NULL control:** same `f`, two independent boxes | 840 vs 845, **0.12σ** |
| S9 | Ψ/ρ measured, not recalled, at u≈4 | 0.88–1.37 |
| S10 | rebuilt ρ agrees with shared harness on u≤5 | 9.9e-03 |

S7 and S8 are the point of writing the harness first: it demonstrably **returns
the null** when the null is correct, so a difference reported from it means
something.

Two bugs the self-test caught in my own code, both recorded in `core.py`:

* `f(a,b)=0` cells made `rem % p == 0` true forever, so the trial-division loop
  never terminated — the first run hung for 10 minutes on the single degenerate
  cell `(0,0)`. This is exactly the degenerate-case class that voided two earlier
  measurements in this program.
* The **Dickman harness warning below** (§5) invalidated one of my statistics.

---

## 2. P1 — is the anti-correlation real, and what is the mechanism?

**Prediction stated before measuring:** the rate should *decrease* with mass, with
slope of order −0.3 to −1.0 per e-fold; and it should be explained by the size of
`f(a,b)`, not by mass.

**Measured: 224 polynomials over 3 moduli (37, 44, 50 bits), rate spanning
1243×.**

| predictor | Spearman ρ | 95% CI | OLS slope | R² |
|---|---|---|---|---|
| coefficient mass | **−0.841** | [−0.881, −0.787] | −0.290 ± 0.013 /e-fold | 0.672 |
| mean log\|f(a,b)\| over the box | **−0.972** | [−0.978, −0.959] | −0.256 ± 0.004 /e-fold | **0.958** |

Broken out, to show it is not a `m`-versus-coefficient confound:

| family | n | rate spread | ρ(mass) | ρ(meanlog) | slope vs log mass (R²) | slope vs meanlog (R²) |
|---|---|---|---|---|---|---|
| A (`m` varies) | 66 | 96× | −0.889 | −0.923 | −1.060 ± 0.049 (0.878) | −0.291 ± 0.008 (0.956) |
| B (`m` fixed) | 158 | 738× | −0.827 | −0.978 | −0.339 ± 0.020 (0.648) | −0.262 ± 0.005 (0.951) |

**P1 verdict: the anti-correlation is exactly backwards.** Larger coefficient mass
gives *fewer* relations, by −0.841 rank correlation with the 95% CI far from
zero. The round-48 sign does not survive.

**Mechanism.** A cell is a relation iff `|f(a,b)|` is `y`-smooth, so the rate is
literally the box-average of the smooth-number density at the size of `f(a,b)`:

```
rate(f) = E_{(a,b) in box} [ Psi(|f(a,b)|, y) / |f(a,b)| ]
```

Nothing about NFS enters. This predicts, and the data bear out, that the driver
is the **size of `f` over the box**, summarised by `mean log|f(a,b)|` — which
attains R² = 0.958 against mass's 0.672, and does so *within* the fixed-`m`
family where geometry cannot be the explanation.

The honest limit of the mechanism: `mean log|f|` is a summary, not the whole
distribution, and it leaves residual structure — the measured rate departs from
the pointwise smooth-number model by a factor of several. So the mechanism
identifies *the right variable* and explains most of the variance; it is not an
exact law. I am not claiming more than R² = 0.958 supports.

**The mechanism is itself rank-ordered better than either summary.** Recomputed
with the *rebuilt* ρ (§5) on family A, where the polynomials are exactly
reconstructible from the log (n=66; the family-B polynomials were not recorded
and are **not** guessed at):

| predictor | Spearman ρ | 95% CI |
|---|---|---|
| coefficient mass | −0.889 | [−0.916, −0.834] |
| mean log\|f\| | −0.923 | [−0.949, −0.865] |
| **pointwise Ψ-model over the box** | **+0.930** | [+0.875, +0.953] |

Measured / pointwise-ρ-prediction: min 0.87, median **1.97**, max 4.98, spread
5.7×. Against the *measured* finite-y gap at `y=1000` — 1.250 at `u=3.33`, 1.318
at `u=4.00`, and growing with `u`, so ≈1.3 is a floor over this family whose `u`
runs to 5.24 — algebraic norms come out **≥1.5× smoother** than uniform random
integers of the same size. They are **not** uniformly distributed over the box,
which is why no summary of `|f|` is a complete substitute for the pointwise model.

---

## 3. P2 — can it be a selection rule, and what is the held-out gain?

A rule does survive, but a weaker one than §2's ranking result suggests, and
**not the one §2 predicts**: the better *predictor* (mean log|f|) turns out to be
the *worse* rule on median gain. **Neither proxy is reliably positive** — both
can lose to the standard choice. Both are cheap: the box average costs one pass
over a sample of cells and no sieving.

Four rules, compared at the NFS operating point (`y = 2^(bits/3.5)`, i.e. `u ≈ 3.5`;
holding `y` fixed instead starves the scan — rates fall to 4e-4 and the measured
gains become noise):

* **R0** standard: `m = floor(N^(1/d))`, base-`m` digits
* **R1** minimise coefficient mass (the classical / round-48 proxy)
* **R2** minimise `mean log|f|` (the rule from §2)
* **R3** oracle: maximise the measured rate (upper bound)

All four rules are **parameter-free** — no constant is fitted anywhere, and the
choices that could have been tuned (which proxy, box fraction `η = 0.08`, scan
range `m ∈ [0.90·m*, m*]`) were fixed before the held-out moduli were run. The
held-out rows are therefore moduli whose results were never looked at while
forming the rule; they are not a fitted-parameter split.

**Results** (rate = relations per cell; gain is against R0 = standard `m*`):

| N bits | y | R0 rate | R1 (min mass) | R2 (min meanlog) | R3 oracle | in-scan resid. sd (mass / meanlog) |
|---|---|---|---|---|---|---|
| 27 | 256 | 2.292e-01 | **1.19×** | 0.69× | 1.19× | **0.417** / 0.428 |
| 32 | 565 | 1.043e-01 | **1.41×** | **1.41×** | 1.75× | 0.463 / **0.394** |
| 36 | 1248 | 6.885e-02 | **1.11×** | **1.66×** | 2.09× | 0.526 / **0.516** |
| **40** | **2756** | **7.527e-02** | **0.66×** | **0.92×** | 1.00× | 0.390 / **0.321** |
| 41 | 4096 | 3.802e-02 | **1.05×** | **1.45×** | 1.92× | 0.422 / **0.406** |
| **43** | **7419** | **4.431e-02** | **1.11×** | **1.63×** | 1.63× | 0.367 / **0.319** |
| **43** | **6086** | **4.613e-02** | **1.02×** | **1.02×** | 1.20× | **0.426** / 0.435 |
| **47** | **13440** | **3.020e-02** | **1.18×** | **1.01×** | 1.27× | 0.376 / **0.353** |
| **49** | **24346** | **5.217e-02** | **1.00×** | **1.00×** | 1.00× | 0.295 / **0.232** |

(The two 43-bit rows are **different moduli** — same bit length, different seed.
Bold on the residual column marks the better predictor for that modulus; bold on
R1/R2 marks that rule beating the standard choice.)

```
ALL 9 MODULI     median  R1 1.11x   R2 1.02x   oracle 1.27x
                 worst   R1 0.66x   R2 0.69x   oracle 1.00x
HELD-OUT ONLY    median  R1 1.07x   R2 1.02x   oracle 1.24x   (40, 43, 43, 47 bits)
```

**Held-out honesty.** The 40-, 43-, 43- and 47-bit moduli are **genuinely
unseen** — never observed while forming the rule. Two caveats that weaken the
claim rather than strengthen it: a 54-bit modulus was abandoned because at
`y = 44102` one scan point costs 9.3 s on a heavily contended host, so the
held-out set is 4 moduli, not the 7+ a finished sweep would have given; and
moduli are generated as `rsa(bits, seed=3000+bits)`, so a given `bits` always
yields the same `N` — the 27-, 32- and 36-bit instances appeared only in the
first sweep and the 36-bit one is therefore **not** strictly held-out over my
whole analysis.

**P2 verdict — three things, and the third overturns what §2 predicted.**

1. **A wide `m` scan pays a little, and this is the classical gain.** Median
   1.11× more relations at fixed cost over all 9 moduli (1.07× held-out), against
   an oracle of 1.27×. It is **instance-dependent with a real downside**: at
   40 bits both rules *lose* (0.66× and 0.92×), and at 40 and 49 bits the oracle
   itself is only 1.00× — on those instances there is nothing in the whole scan
   range to find. There is no guaranteed multiplier.

2. **`mean log|f|` is clearly the better *predictor*.** Spearman −0.972 vs
   −0.841 and R² 0.958 vs 0.672 (§2), and the smaller in-scan residual on **7 of
   9** moduli.

3. **But being the better predictor does not make it the better *rule*.** Over
   all 9 moduli R2's median gain is **1.02×**, *below* R1's 1.11×; held-out it is
   1.02× vs 1.07×. On an 8-modulus subset I had R2 ahead (median 1.22× vs 1.08×)
   and I expected the ordering to hold — the 47-bit instance broke it:
   `meanlog` had the smaller in-scan residual there (0.353 vs 0.376) and R2
   *still* lost to R1 (1.01× vs 1.18×). The in-scan residual sd is therefore
   *not* a reliable diagnostic for which proxy to trust; it is 8/9 predictive at
   best, and I over-read it when I had 8 moduli.

So the honest P2 result is: **the selection gain is real, small, classical, and
instance-dependent — a median ~1.1×, well under the 1.27× oracle, and not
reliably positive.** The better statistic did not buy a better rule, and closing
the remaining gap would require measuring the rate on a handful of candidates,
which is the cost the proxy exists to avoid.

---

## 4. P4 — does the advantage grow or shrink with `n`?

Fitted `meanlog` slope per modulus (log rate per e-fold of `|f|`):

| N bits | n | slope | s.e. | mean u |
|---|---|---|---|---|
| 37 | 78 | −0.2286 | 0.0067 | 4.21 |
| 44 | 78 | −0.2279 | 0.0067 | 5.15 |
| 50 | 68 | −0.2247 | 0.0074 | 5.96 |

**The slope is flat across a 13-bit range** — the advantage neither grows nor
shrinks with `n`.

**Honest caveat, and it matters.** In this sweep `y` was held at 1000 while `N`
grew, so `u = mean log|f| / log y` itself moved from 4.21 to 5.96: this is partly
a `u`-sweep, not a pure `n`-sweep. At the true NFS operating point `y ∝ N^(1/3)`
the geometric mean of `|f|` and `y` both scale like `m³`, so `u` is **constant in
`n`** and the advantage is exactly scale-invariant — but that part is a *model*,
not a measurement here. **Any statement about 1024 bits is a model over `u`, not
a measurement in `n`, and is labelled as such.** Nothing in this note should be
read as "measured at 1024 bits".

---

## 5. Correction to my own analysis: the Dickman harness

Mid-run I was told that `r48/_shared/dickman.py` is wrong for `u > 5` (its fixed-step
integration freezes near the float floor and saturates at ~6.7e-07; its self-test
only probed `u <= 4.2`, so it could not fail there). It now raises above `u = 5`.

**What this touched.** Only one statistic: the pointwise ρ-prediction of the rate.
Everything else in this note — all Spearman correlations, all OLS slopes, all
relation counts, all gains — is a direct measurement and uses no Dickman value at
all. `kappa` in the pointwise model was calibrated at `u = 4.41`, inside the valid
range, so it stands.

**What I did about it.** Rather than trust a rebuilt function, I rebuilt ρ by
direct interval marching of `u ρ'(u) = −ρ(u−1)` (each unit interval is one numpy
cumsum; no fixed-step ODE, no saturation floor), and validated it two ways on this
host: against the shared harness on its valid range (agreement 9.9e-03), and
against **exact Ψ** (`psi_exact`, a memoised enumeration independent of any ODE).
`python3 core.py` → ALL PASS.

The exact-Ψ check also measured the **finite-y** gap, which is a separate and more
general effect than the `u>5` bug and is the reason no conclusion here is stated
as a ratio to ρ:

```
EXACT Psi(1e10, 1000) = 2.956020e+08   Psi/x = 2.956e-02   rho(3.333) = 2.365e-02   Psi/rho = 1.250
EXACT Psi(1e12, 1000) = 6.471275e+09   Psi/x = 6.471e-03   rho(4.000) = 4.911e-03   Psi/rho = 1.318
```

Dickman's theorem is asymptotic in `y`; at `y = 1000` the exact smooth rate is
1.25–1.32× ρ. At `y = 64` (where exact Ψ is cheap) the gap is far larger — 3.4×
at `u=5`, 5.3× at `u=6` — which is the same phenomenon as the brief's `u∈[5,8]`
warning. **Ψ is not ρ at finite `y`, and the shortfall must be measured, not
assumed.**

---

## 6. Overall

| question | verdict |
|---|---|
| P1 — is the mass anti-correlation real? | **No. Sign is reversed.** ρ(mass, rate) = −0.841 [−0.881,−0.787] over 224 polynomials; rate *falls* with mass, −0.290 ± 0.013 per e-fold |
| P1 — mechanism | rate = box-average of the smooth-number density at the size of `f(a,b)`; `mean log|f|` gives R² 0.958 vs mass 0.672, and does so at fixed `m` |
| P2 — is it a rule? | **Weakly, and not the way §2 predicts.** Median over 9 moduli: R1 (mass) **1.11×**, R2 (meanlog) 1.02×, oracle 1.27×; held-out only: 1.07× / 1.02× / 1.24×. `mean log|f|` is the far better *predictor* (Spearman −0.972 vs −0.841) yet is **not** the better rule — R1 beats it on median. Worst cases 0.66× and 0.69×; on 2 of 9 moduli the oracle itself is 1.00× |
| P3 — artefact? | **Yes, decisively.** The round-48 counter's sieve mask is inverted (roots the reverse polynomial) and it under-counts the true smooth rate by **136×**; the published anti-correlation is +0.20 over n=5, carried by one point; "zero relations" is not reproduced — a 60× worse polynomial still yields 12777 relations |
| P4 — size dependence | flat across 37→50 bits; **exactly scale-invariant at the NFS operating point by model, not measurement** |

**The exploitable content is small and classical.** Choosing `m` widely and
picking `f` to be small over the sieving box is worth a median **~1.1×** more
relations at fixed cost — real, but modest, instance-dependent, and not reliably
positive. Notably, the statistic that predicts the rate best (§2) is *not* the
one that selects it best (§3): `mean log|f|` beats coefficient mass on every
ranking metric and still loses on median gain. Both are heuristics for the same
quantity, and the remaining 1.27× oracle would need direct measurement. The
round-48 anti-correlation is withdrawn, and with it any claim that minimising
coefficient mass is *counterproductive* — it is merely suboptimal, and pointing
it the wrong way was an artefact of an inverted sieve.

## 7. What I did not establish

- Size coverage: P1 measured at **37–50 bits**, P2 at **27–49 bits** (9 moduli).
  Nothing at 1024 bits, and nothing above ~54 bits — exact integer norms overflow
  `int64` past that in this box geometry. The 54-bit P2 modulus was abandoned
  mid-run (9.3 s per scan point on a contended host), so the held-out set is 4
  moduli rather than the 7+ a finished sweep would have given.
- The P1 n-sweep in §4 holds `y` fixed at 1000, so it is partly a `u`-sweep; the
  genuine scale-invariance claim is a **model**, not something measured here.
- **I over-read an 8-modulus subset.** Before the 9th modulus landed, R2 led R1
  on median gain (1.22× vs 1.08×) and the in-scan residual looked like a reliable
  diagnostic for which proxy wins. The 9th modulus reversed both. §3 is written to
  the full 9; treat any "residual predicts the winner" reading as 8/9 at best.
- The box is `0.08·m` with `f(m)=N` and degree 3 only. Skewed degree-4/5/6
  polynomials — the actual state of the art — are not in these families.
- The pointwise smooth-number model leaves residual scatter (see §2); I identify
  the governing variable but do not claim an exact law.
- Sieve **cost** is modelled only by a root-hit proxy at `p ≤ 3000`, not measured
  as a real linear-sieve wall clock. Since cost at fixed `(y, box, cells)` is
  nearly polynomial-independent, this affects the cost side of the gains only
  weakly, but it is a proxy.
- The linear-algebra half is untouched, as instructed: LLL is optimal on NFS
  relation lattices (40/40), so polynomial selection cannot move the 1.92299.
- **No literature claim is made.** WebSearch fabricates citations on this host.

## Files

- `polysel/core.py` — polynomials, exact counter, rebuilt+validated ρ, exact Ψ
- `polysel/selftest.py` — self-test, exits 0 (**run first**)
- `polysel/p1_p3.py` — P1 and P3 (`p3()` then `p1()`)
- `polysel/p2_p4.py` — P2 and P4
- `polysel/parse_p1.py`, `polysel/analyse.py` — predictor analysis from `p1.log`

Reproduce: `cd factor-scratch/r49exp/polysel && python3 selftest.py && python3 core.py && python3 -c "import p1_p3; p1_p3.p3()" && python3 -c "import p1_p3; p1_p3.p1()" && python3 parse_p1.py`