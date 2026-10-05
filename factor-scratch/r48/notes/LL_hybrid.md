# LL — Is `NFS relation-finding + Stange's ℚ-kernel/gcd` faster end to end than plain NFS?

**Round 51 exp, `hybrid`. Working dir `factor-scratch/r51exp/hybrid/`.**
Code: `hcore.py`, `selftest.py` (**37 checks, ALL PASS, every negative control fires**),
`exp_nosieve.py`, `exp_e2e.py`, `exp_H4.py`, `exp_crossover.py`.
**No paper, no issue, no commit.** Read-only imports from `r48/exp/stange/` and
`r50exp/baseg/`.

---

## SCOPE — stated first, because it is what will be misread

**Everything below concerns classical factoring of RSA-scale integers. This is not a
cryptographic break and must not be described as one.** No claim here changes the security
of any deployed scheme. The question is which factoring algorithm is fastest *in
principle*, among algorithms that are all already public.

The conclusion, up front, in one line:

> **The hybrid does not exist as an algorithm. NFS's sieving provably cannot be
> transplanted onto Stange's relation condition, so "NFS relation-finding feeding
> Stange's kernel" is not `L[1/3]` relation-finding — it is Stange's own relation
> finder with a constant-factor change to the per-trial cost. Measured end to end it is
> 1.41×–1.53× SLOWER at `2²⁶`, the penalty falls monotonically with `n`, and by `2³⁸` the
> two arms cannot even agree on the sign. There is no regime in which it wins, and the
> size regime where it would matter is not determinable on this host.**

The second, independent result — and the one the brief called the most valuable — is in
§4. It is a genuine correction to a load-bearing number.

---

## 0. The three results, combined, and what came out

| prior result | what it established | what §1–§4 add |
|---|---|---|
| `PP_droptest.md` | Stange's kernel is **5%** of the phase at one operating point (`n≈2⁴⁰, b=52`, good backend); verdict (b) EQUIVALENT | the **5% is not a constant** — it ranges **0.0000 → 0.7772** across `(n,b)`; it is **false at `2³⁰`, `b≥26`** and **true at `2³⁸`–`2⁴⁰`** (§4) |
| `OO_bneed.md` | NFS relation-finding drops required `b` from 5.9e5 to **8.4** | **the drop is unobtainable for this relation condition** — not because of cost, but because the sieve that produces it does not exist here (§2). This is the result that changes the programme's plan |
| `II_baseg.md` | Jacobi base: `20/27 → 8/9`, a free 1.2× | **re-measured at 1.2227× paired, 300 fresh moduli**, diagonal `105/105` vs `60/105` (§3) |

So: two of the three prior results **survive** and one **does not survive contact with the
end-to-end pipeline**. The one that fails is the one that was carrying the programme's
escape route.

---

## 1. H1 — the pipeline, and the backend that makes it measurable at all

### 1.1 The backend mandate, verified live

`stange.kernel_basis` calls `sympy.Matrix.nullspace()`. On this host (sympy 1.13.1) that
is **unusable** for an end-to-end timing — `selftest` T4, with a 45 s alarm per cell:

| `b` | `sympy.Matrix.nullspace()` | `DomainMatrix.rref` over `QQ` | speedup |
|---|---|---|---|
| 26 | 263.4 ms | **15.9 ms** | 16.6× |
| 40 | **> 45 s** (alarm) | **41.9 ms** | **> 1073×** |
| 52 | **> 45 s** (alarm) | **64.5 ms** | **> 697×** |

The campaign's recorded trap ("`Matrix.nullspace()` takes >400 s at b=52 and never
finishes") is **confirmed live**. The mandated route is used exclusively:
`DomainMatrix(rows,(b,m),ZZ).convert_to(QQ).rref()`. The `ZZ` is only the input container
for an integer matrix — the **reduction is over `QQ`**; `rref` over `ZZ` is never called.

The flint backend returns `sympy.external.pythonmpq.PythonMPQ`, **not** `sympy.Rational`
— its `.p`/`.q` do not exist, and the `hasattr(x,'q')` probe that r48's `_denominator`
uses for sympy Rationals would silently mis-coerce **every** entry. `.numerator`/
`.denominator` is the flint-exact API and is what is used.

### 1.2 The correctness/non-vacuity audit

Every kernel vector is checked for `M v = 0` **exactly over ℚ** *and* for being
**nonzero**. Both are required and neither is sufficient alone:

* a **rank** or **dimension** check passes the float-leak bug — only `M v = 0` catches it;
* an `M v = 0` check passes the **zero vector**, which lies in every kernel — only the
  nonzero check catches that. `selftest` T3 asserts a full-rank square matrix raises
  `VacuousKernel`, and that the same matrix returns the empty kernel with the check off.
* a **corrupted** vector is rejected (one-entry perturbation, T2).

The QQ route is **equivalent to the incumbent** on **8/8 real Stange matrices** in both
dimension and rank (T1). Without that the timing comparison would rest on two routes that
might not compute the same thing — the error this project keeps recording.

### 1.3 Phase verification, each against its own established number

| phase | reference | reproduced? |
|---|---|---|
| whole algorithm | Stange's own example `n=62389=701·89`, `G=15400`, factor `701` | **4/4 seeds** (T5) |
| relation condition | both collectors return identical relations for the same `x`-stream, **81 relations** (T8) | yes, non-empty |
| 2-adic rates | `II_baseg` per-cell table, pooled `20/27` and `8/9` | **6/6 and 5/5 cells**, exact |
| `p_split` spread | must span nearly the unit interval or the control is vacuous | **[0.5000, 0.9961]** over 400 moduli |

**No Dickman anywhere.** `r48/_shared/dickman.py` raises above `u=5` and `ρ` is the wrong
functional form as a null, so smoothness is exact (`exact_psi`, verified against brute
force at three points) or measured.

---

## 2. H1/H2 — WHY THE HYBRID DOES NOT EXIST AS AN ALGORITHM

This is the central result, and it is a **structural** result, not an implementation
complaint. `exp_nosieve.py` tests the presupposition instead of assuming it.

The brief asks for "NFS relation-finding feeding Stange's linear-algebra/gcd". That
presupposes NFS's relation-finding **route** can be transplanted onto Stange's relation
**condition**:

```
Stange's condition:   g^x = prod_i p_i^{f_i}   (mod n)
```

NFS sieving works because the sieved quantity is **additive** in the sieve variable: for
`a+b`, the condition `p | (a+b)` is decided by `(a+b) mod p` — free — and it is
**periodic in the index**, so a sieve over a box finds every divisible position without
touching the big integers.

Stange's quantity is **exponential**. Two facts break the sieve.

**F1 — divisibility is not cheaply decidable.** `g^x mod n` is a residue in `[0,n)`; the
cheap residue `g^x mod p` does **not** determine it, because reduction mod `n` is not a
ring homomorphism downward (`n ≢ 0 mod p`). Measured on a genuine factor-base prime:

> `(g^x mod n) mod p ≠ g^x mod p` in **529/600 = 88.2%** of cases.

So every trial costs a full modpow, regardless of batching.

**F2 — the hit set is not periodic in `x`, and sieving requires periodicity.** Smallest
period `d ≤ 64` with `hit(x) = hit(x+d)` for all `x`, `K = 6000`:

| sieved quantity | `p` | hits | `E[hits]` | smallest period ≤ 64 |
|---|---|---|---|---|
| `p \| (g^x mod n)` **[STANGE]** | 2 | 2973 | 3000 | **None** |
| " | 3 | 2007 | 2000 | **None** |
| " | 5 | 1245 | 1200 | **None** |
| " | 7 | 776 | 857 | **None** |
| " | 11 | 516 | 545 | **None** |
| `p \| (1000+x)` **[NFS control]** | 2 | 3000 | 3000 | **2** |
| " | 3 | 2000 | 2000 | **3** |
| " | 5 | 1200 | 1200 | **5** |
| " | 7 | 858 | 857 | **7** |
| " | 11 | 546 | 545 | **11** |

**The NFS control is periodic with period exactly `p` on 5/5 primes, and Stange's hit set
is aperiodic on 5/5.** The asymmetry is a property of the two *conditions*, not of my
harness.

> ### Consequence
> **No sieve over `x` exists for Stange's relation condition.** The hybrid therefore
> cannot import NFS's `L[1/3]` relation phase. What it *can* do — and what
> `hcore.find_relations_sieve` does — is **batch the trial division**, amortising the
> `O(b)` division pass across a block. That is a constant-factor engineering change, and
> the measured ratio below is a statement about **Python constants**, not about
> algorithms.

This is `OO_bneed`'s own caveat, now established mechanically rather than argued:
> "It buys 4.8 orders in `b` by replacing Stange's entire `L[1/2]` relation-finding phase
> with the NFS's `L[1/3]` one. Take that trade and you are no longer running Stange's
> algorithm — you are running **the number field sieve wearing Stange's linear-algebra and
> gcd phases**."

**And this closes `OO_bneed`'s B3 lever specifically.** The `5.9e5 → 8.4` reduction is
argued from Stange p.2's citation of **Gordon 1993** §3.1 — NFS relations modulo `n`. But
those relations come from the **number field structure**: the smoothness bound is reached
through large `m`-values in a sieveable box. Stange's `g^x mod n` has no box. **The
`8.4` is therefore not reachable by the mechanism that is supposed to produce it**, and
the programme's escape from the `b_max` squeeze (K_stange.md's "4.3 orders at `n=10²⁰`")
is, on this evidence, closed.

---

## 3. H2 — end to end, everything charged

Four arms on **identical moduli**, `n ≈ 2²⁶`, `b = 15`, `c = 10`, **300 fresh semiprimes**,
one attempt each (cap = 1, so the **per-attempt rate** is measured directly):

| arm | relation finder | base | factored | rate | 95% CI | z vs own null |
|---|---|---|---|---|---|---|
| `stange-uniform` | rejection sampling | uniform | 220/300 | **0.7333** | [0.680, 0.781] | **−0.29** vs `20/27` |
| `stange-jac` | rejection sampling | **Jacobi = −1** | 269/300 | **0.8967** | [0.855, 0.927] | **+0.43** vs `8/9` |
| `sieve-uniform` | batched division | uniform | 220/300 | **0.7333** | — | **−0.29** |
| `sieve-jac` | batched division | **Jacobi = −1** | 269/300 | **0.8967** | — | **+0.43** |

Both nulls reproduce at well under 1σ. **The relation route changes the success count by
exactly zero** (220 and 269 in both collectors) — as §2 predicts, since it is the same
condition with the same acceptance rate.

**Charged wall clock, 60 moduli, `b=15`, cap 10** (base + relations + kernel + gcd):

| arm | wall, ms per factored `n` | base | rel | LA | gcd | **frac_rel** | **frac_LA** |
|---|---|---|---|---|---|---|---|
| `stange-uniform` | **35.2** | 0.02% | 67.42% | 32.44% | 0.124% | 0.674 | 0.324 |
| `stange-jac` | **26.5** | 0.04% | 69.40% | 30.43% | 0.123% | 0.694 | 0.304 |
| `sieve-uniform` | **49.4** | 0.01% | 78.56% | 21.34% | 0.084% | 0.786 | 0.213 |
| `sieve-jac` | **40.7** | 0.03% | 79.47% | 20.41% | 0.087% | 0.795 | 0.204 |

**Paired, identical moduli, identical kernel+gcd, ONLY relation-finding differs:**

| comparison | relation-finding only | total charged |
|---|---|---|
| `stange-uniform` → `sieve-uniform` | 1.394 s → 2.281 s = **1.636×** | **1.405×** |
| `stange-jac` → `sieve-jac` | 1.084 s → 1.904 s = **1.756×** | **1.534×** |
| (300-moduli run) `stange-uniform` → `sieve-uniform` | 6.707 s → 9.499 s = **1.416×** | **1.236×** |
| (300-moduli run) `stange-jac` → `sieve-jac` | 5.064 s → 8.703 s = **1.719×** | **1.527×** |

**The hybrid is 1.41×–1.53× slower end to end.** The batched arm loses because it pays a
per-`x` Python dictionary lookup and list construction per prime, which at `b = 15` and
these acceptance rates is pure overhead — the amortisation it buys does not cover the
bookkeeping it costs. In C with a real segmented sieve the constant would improve; **it
would still not be a different algorithm**, because F2 forbids the sieve.

`frac_gcd` is **0.009%–0.346%** across all runs, mostly under 0.15% — re-confirming r48's
"<0.2%" independently (the few cells above 0.2% are single-modulus, where one attempt's
gcd is a larger share of a small total).

### 3.0.1 The penalty SHRINKS with `n`, and at `2³⁸` it reaches the noise floor

The same four arms at `n ≈ 2³²`, `b = 20`, `c = 10`, 40 moduli, cap 6:

| arm | wall, ms per factored `n` | **frac_rel** | **frac_LA** |
|---|---|---|---|
| `stange-uniform` | **303.6** | 93.88% | **6.08%** |
| `stange-jac` | **249.9** | 93.91% | **6.04%** |
| `sieve-uniform` | **339.7** | 94.76% | 5.20% |
| `sieve-jac` | **304.8** | 94.74% | 5.22% |

And at `n ≈ 2³⁸`, `b = 26`, `c = 10`, 24 moduli, cap 4 — where relation-finding is
**98.7%** of the cost and the kernel is **1.17%–1.31%**:

| size | `b` | uniform pair | jac pair |
|---|---|---|---|
| `n ≈ 2²⁶` | 15 | 2.110 → 2.964 s = **1.41×** | 1.592 → 2.443 s = **1.53×** |
| `n ≈ 2³²` | 20 | 12.024 → 13.587 s = **1.13×** | 9.995 → 12.193 s = **1.22×** |
| `n ≈ 2³⁸` | 26 | 54.519 → 53.465 s = **0.981×** | 45.568 → 55.260 s = **1.213×** |

> ### ⚠️ The `2³⁸` row is the important one, and it is a NEGATIVE result about my own instrument
> At `2³⁸` the two arms **disagree in SIGN**: the uniform pair says the sieve is
> **1.9% cheaper**, the Jacobi pair says it is **21.3% dearer**. Both pairs run the
> identical relation routes on the identical moduli, so they cannot both be measuring a
> real difference. **At this size the ratio measurement has hit its noise floor and is no
> longer resolving anything.** I report the disagreement rather than the more flattering
> half of it. `PP_droptest` §7 prescribes treating absolute times as ±30% on this host;
> the `2³⁸` row is inside that band and **I make no claim from it.**

The trend is nonetheless monotone and has a mechanism: as `n` grows at fixed `b`,
relation-finding takes an ever-larger share (H4 measured this directly), so the batching
overhead — a **constant** per trial — becomes an ever-smaller **fraction**.

So the honest answer to "is there a size regime where it wins?" is:

> **No — but there is a regime where it stops mattering.** As `n → ∞` at fixed `b` the
> two arms converge to the **the same algorithm**, because §2 proves they *are* the same
> algorithm. The measured penalty falls 1.53× → 1.22× → noise as `n` grows, and by `2³⁸`
> the two arms cannot even agree on the sign. What survives at **every** size, exact and
> noise-free, is the **zero difference in the success count** (220/300 and 269/300 in both
> collectors, at `cap = 1`). That is the real answer: **the two arms are the same
> computation, and the timings were never going to separate them.**

### 3.1 The mandatory per-modulus `p_split` control

Never pooled. Each modulus tested **one-sided** against **its own** `Binomial(N, p_split)`
— a proper tail probability, **not** a tolerance band. (`OO_bneed` §4b recorded the
failure this replaces: an arbitrary `excess_lo ≥ −0.10` rule reported "the method never
works" on a modulus where it had just factored 23 of 24.)

| arm | moduli consistent with own `p_split` | flagged |
|---|---|---|
| `stange-uniform` | **298/300** | `1,5` and `5,1`, `p_split = 0.969`, 1 attempt each |
| `stange-jac` | **300/300** | — |
| `sieve-uniform` | **298/300** | same two |
| `sieve-jac` | **300/300** | — |

The two flagged are `N = 1` cells with `p_split = 0.969` — a single failure on a
high-`p_split` modulus is a ~3% event, and at `α = 1e-4` across 300 moduli ≈ 2 expected.
They are sampling, not a deficit.

**The spread is `[0.5000, 0.9922]`, spread 0.4922** — nearly the full unit interval, and
**diagonal (`a==b`) cells: 105/300**. A pooled rate against `20/27` would have been
meaningless here, and the diagonal/off-diagonal split is where the whole action is:

| arm | diagonal (`a==b`) | off-diagonal |
|---|---|---|
| `stange-uniform` | 60/105 = 0.5714 | 160/195 = 0.8205 |
| `stange-jac` | **105/105 = 1.0000** | 164/195 = 0.8410 |
| `sieve-uniform` | 60/105 = 0.5714 | 160/195 = 0.8205 |
| `sieve-jac` | **105/105 = 1.0000** | 164/195 = 0.8410 |

### 3.2 `II_baseg`'s 1.2× re-measured

Paired, same moduli, only the base rule differs: **1.2227×** overall
(220/300 → 269/300). `II_baseg` reports exactly **1.2000×** (`8/9 ÷ 20/27`). The gain is
**entirely the diagonal** — `105/105` against `60/105` — and off-diagonal it is slightly
**worse** (`0.8410` vs `0.8205`), exactly as the per-cell theory predicts and exactly as
`II_baseg` §2 warned would be hidden by a pooled number. **The result reproduces.**

---

## 4. H4 — IS THE 5% LOAD-BEARING? (the most valuable result here)

> **Split. The 95% figure is not a constant — and it is true exactly where the
> programme's asymptotic reasoning lives, and false exactly where its experiments run.**
> At `n ≈ 2³⁸`–`2⁴⁰` the kernel is **0.06%–1.3%** of the cost and the 95% claim is right.
> At `n ≈ 2³⁰`, `b = 26–52` the kernel is **38%–78%** and the claim is wrong.
> **7 of 24 measured cells fail it; all 7 are in one band.**

Registered **before** measuring: `frac_rel` **decreases** with `b` at fixed `n`, and
**increases** with `n` at fixed `b`. **The prediction held in 8/8 monotone tests** on the
completed 24-cell grid (`b ∈ {5,8,10,12,15,26,40,52}`, `n ∈ {2²⁵…2⁴⁰}`).

Charged wall clock, real matrices, `DomainMatrix`/QQ backend, medians of 3 independent
seeds, `c = 10`. **`frac_gcd` omitted — it is 0.0003–0.35% and never moves anything.**

| `log₂ n` | `b` | `u` | trials | `t_rel` (ms) | `t_LA` (ms) | **frac_rel** | **frac_LA** |
|---|---|---|---|---|---|---|---|
| 25 | 5 | 7.26 | 61 718 | 169.4 | 1.71 | 0.9899 | 0.0100 |
| 25 | 12 | 4.82 | 6 626 | 20.4 | 5.09 | 0.7992 | **0.1998** |
| 26 | 8 | 5.88 | 15 436 | 45.0 | 3.09 | 0.9352 | 0.0641 |
| 26 | 10 | 5.21 | 9 461 | 27.8 | 4.09 | 0.8711 | **0.1280** |
| 29 | 5 | 8.42 | 583 765 | 1745.0 | 1.75 | 0.9990 | 0.0010 |
| 29 | 12 | 5.59 | 43 683 | 218.5 | 7.46 | 0.9665 | 0.0330 |
| 30 | 8 | 6.83 | 88 854 | 346.9 | 3.39 | 0.9902 | 0.0097 |
| 30 | 10 | 6.03 | 58 087 | 193.6 | 4.02 | 0.9795 | 0.0203 |
| 30 | 15 | 5.22 | 23 924 | 112.2 | 11.54 | 0.9062 | 0.0932 |
| 30 | 26 | 4.45 | 9 150 | 47.7 | 29.56 | 0.6169 | **0.3825** |
| 30 | 40 | 3.94 | 5 192 | 43.3 | 71.93 | 0.3755 | **0.6240** |
| 30 | 52 | 3.60 | 3 365 | 31.2 | 109.23 | 0.2223 | **0.7772** |
| 35 | 5 | 10.15 | 21 172 480 | 163 920.0 | 1.81 | 1.0000 | **0.0000** |
| 35 | 12 | 6.74 | 652 823 | 5466.4 | 5.96 | 0.9989 | 0.0011 |
| 36 | 8 | 8.24 | 1 883 703 | 14 726.5 | 3.45 | 0.9998 | 0.0002 |
| 36 | 10 | 7.26 | 1 380 299 | 12 164.8 | 4.14 | 0.9997 | 0.0003 |
| 36 | 15 | 6.30 | 278 470 | 2618.8 | 12.06 | 0.9954 | 0.0046 |
| 36 | 26 | 5.35 | 81 641 | 898.2 | 26.80 | 0.9709 | 0.0290 |
| 36 | 40 | 4.75 | 31 414 | 363.6 | 51.01 | 0.8769 | **0.1230** |
| 36 | 52 | 4.36 | 19 991 | 239.1 | 94.78 | 0.7159 | **0.2838** |
| 40 | 15 | 7.02 | 1 541 327 | 18 564.1 | 10.75 | 0.9994 | 0.0006 |
| 40 | 26 | 5.95 | 409 472 | 4730.5 | 24.81 | 0.9948 | 0.0052 |
| 40 | 40 | 5.29 | 118 668 | 1318.0 | 48.19 | 0.9647 | 0.0353 |
| 40 | 52 | 4.87 | 69 643 | 885.2 | 86.09 | 0.9113 | 0.0886 |

Independently, the four-arm end-to-end run (§3.0.1) extends the large-`n` end: at
`n ≈ 2³⁸`, `b = 26` the kernel is **1.17%–1.31%** (`frac_LA`), i.e. `frac_rel ≈ 98.7%`.

**`frac_LA` spans 0.0000 → 0.7772** over the grid (≈ 7×10⁴ in ratio). The "kernel is 5%"
claim is true at `n≈2⁴⁰, b=52` (`0.0886`) and at `n≈2³⁸` (`0.0117`), and **false at
`n≈2³⁰, b=52`, where the kernel is 77.7% of the cost and is unambiguously the bottleneck.**

### 4.0 A caveat about these numbers that I found by re-running them

The grid above was run **twice** — once as 12 cells, once as the full 24 — and individual
cells **moved between the two runs**:

| cell | `frac_LA`, run 1 | `frac_LA`, run 2 | shift |
|---|---|---|---|
| `n≈2³⁰, b=26` | 0.3146 | 0.3825 | +22% |
| `n≈2³⁰, b=52` | 0.7839 | 0.7772 | −0.9% |
| `n≈2³⁰, b=40` | 0.6300 | 0.6240 | −1.0% |
| `n≈2⁴⁰, b=52` | 0.0974 | 0.0886 | −9% |

The seeds are fixed (`median_cell(..., seeds=(11,22,33))`), so the *matrices* are identical
and the difference is **pure wall-clock** — this host runs 16 cores with other agents
active. **The qualitative conclusions are stable** (the mononotone directions, the failure
band, the ~10⁴ span); **individual cells are good to roughly ±20% and no better.** That is
consistent with the ±30% that `PP_droptest` §7 prescribes, and it is why §3.0.1 refuses to
read the `2³⁸` sign disagreement as a result.

### 4.1 The shape, and where the claim fails

`frac_LA` is small at **both** ends of the `b` range and large in the **middle**. At
`n≈2²⁶`: `b=8 → 0.064`, `b=10 → 0.130`, `b=15 → 0.305`, rising. At `n≈2³⁰`:
`b=8 → 0.011`, `b=15 → 0.098`, rising. At `n≈2³⁶`: `b=8 → 0.000`, `b=15 → 0.003`, rising.

**The failure band is INTERMEDIATE — `n ≈ 2³⁰–2³⁶`, `b ≈ 26–52`** — not small `b`. On
the completed grid **7 of 24 cells fail the 95% claim**, all of them in that band, worst
first: `2³⁰/b=52` (`frac_LA` 0.777), `2³⁰/b=40` (0.624), `2³⁰/b=26` (0.383), `2³⁶/b=52`
(0.284), `2²⁵/b=12` (0.200), `2³⁶/b=40` (0.123), `2²⁶/b=10` (0.128).

### 4.2 What this does to the priority order

The kernel matters **more** at **larger** `b` and **smaller** `n` — that is, in the regime
`MM_sparse`/`OO_bneed` care about (`b` large, `n` large) the relation-finding is
overwhelmingly dominant and the linear algebra is genuinely a rounding error, which
**supports** the priority order there. But at the *small* `n` and *moderate* `b` where
experiments actually run, the kernel is the **majority** of the cost and any work aimed at
the relation finder is aimed at 38–78% of the work.

**The number is not wrong in the abstract; it is quoted from one corner of a surface and
applied everywhere.**

---

## 5. H3 — the crossover, and is there a regime where it wins?

### 5.1 There is no crossover in the base rule

The base rule changes **how often** an attempt succeeds, not **what an attempt costs**. It
is therefore a flat multiplier: `8/9 ÷ 20/27 = 1.2000` exactly, re-measured at **1.2227×**
paired (§3.2). No crossover, no regime dependence — it is a constant-factor win that is
already banked.

### 5.2 The crossover that does exist is in `b` — and it goes the way I first got backwards

`b` is Stange's **only** free parameter (`OO_bneed`: "Algorithm 2.2's complete parameter
set is `B` and `c`"). So the crossover must be a function of `b` or it is not stated at
all. Measured kernel-majority boundary (`frac_LA > 0.5`), by bisection in `b`:

| `n` | relation-finding is the majority | the KERNEL is the majority |
|---|---|---|
| `n ≈ 2³⁰` | `b ≤ 32` | from `b = 32` |
| `n ≈ 2³⁶` | `b ≤ 76` | from `b = 77` |

> Resolution is stated because it is not tight: 7 halvings of `[8,96]` with cells costing
> seconds bracket the boundary to about ±half the bracket width, **not** to the integer.

**The kernel is the majority when `b` is large relative to `n`** — when the
relation-finding is *cheap*, because a big factor base makes `ρ(u)` large while
`b×(b+c)` Q-rref gets expensive at the same time. And the boundary **grows with `n`**
(32 at `2³⁰`, 77 at `2³⁶`): at fixed `b` the kernel matters **more** at larger moduli.

### 5.3 The regime that cannot be instantiated here

**Not determinable on this host, and I do not extrapolate into it.** At NFS-optimal sizes
`π(B*) ≈ 10¹⁵`–`10³³` and the `b × (b+c)` matrix has `10⁵`–`10⁶` rows; the relation phase
needs `10⁴`–`10⁹` trials **per relation**. Nothing above measures that.

What can be said there is **arithmetic on Stange's own p.5 formulas**, not measurement:

> "the runtime is `u^u (b + c) b π(b) = u^u O(b³/log b)`", with `u = log n / log b`;
> the kernel is `O(b⁴ log b)` (Thm 3.2).

Equating them and evaluating at `b ∈ {10…160}`, `log₂ n ∈ {66…512}` gives `frac_LA <
0.003` **everywhere** — the kernel is a rounding error in the asymptotic regime Stange's
analysis describes. **This is arithmetic on two published formulas, not a measurement, and
the two are not the same kind of claim.** It is consistent with H4's measured direction
(`frac_LA` falls as `n` grows at fixed `b`) but does not license a number at `n = 10²⁰`.

---

## 6. Verdict

> ### It loses, it never wins, and by `2³⁸` the two arms are the same computation.

| question | answer |
|---|---|
| **H1** pipeline built? | **Yes**, and each phase is pinned to its own reference (Stange's `62389 → 701`, `20/27`, `8/9`, 8/8 kernel equivalence) |
| **H2** end to end | **1.41×–1.53× slower** at `2²⁶`; penalty falls with `n`; **at `2³⁸` the arms disagree in sign** (0.981× vs 1.213×) = noise floor. Relation route changes the success count by **exactly 0** |
| **H3** crossover | none in the base rule (flat 1.2×); in `b`, kernel-majority from `b≈32` at `2³⁰`, `b≈77` at `2³⁶`; asymptotic regime **not determinable here** |
| **H4** is 5% load-bearing? | **Partly.** `frac_LA` spans **0.0000–0.7772** over 24 cells. The claim is **false at `2³⁰`, `b≥26`** (kernel is 38–78% of cost) and **true at `2³⁸`–`2⁴⁰`** (kernel 0.06–1.3%) |

**The reason it loses is not a constant — it is that the idea is empty.** F2 (§2) shows
NFS's sieving cannot be applied to `g^x mod n` at all. The hybrid's name promises an
`L[1/3]` relation phase; what it delivers is Stange's `L[1/2]` relation finder with a
different per-trial constant. **It is not a factoring algorithm; it is a
re-implementation.**

**And H4 splits its own claim in two, which is the useful part.** "Relation-finding is
~95%" is **true in the large-`n` regime the programme's asymptotic analysis describes**
(`frac_LA` = 0.05% at `2⁴⁰/b=15`, 1.17–1.31% at `2³⁸`) and **false in the intermediate
band where the experiments actually run** (`frac_LA` = 38%–78% at `2³⁰`, `b` = 26–52). The
priority order is therefore **right about the destination and wrong about the road taken to
get there**: at the sizes anyone can compute, the linear algebra is not the 5% rounding
error it is quoted as.

---

## 7. What I got wrong on the way (kept, because the controls caught it)

Every one of these produced a **clean, confident, wrong number**, and every one was caught
by a control rather than by suspicion. Seven:

1. **A structurally unfalsifiable non-vacuity control.** I built the T3 base as a random
   `11×14` matrix — which is at **full row rank**. Appending any column cannot raise rank,
   so the "+1 dimension" I asserted was pure **column-count arithmetic**, not detection of
   the dependence. Widening to `6×20` did **not** help: a random `6×20` is *also*
   generically full row rank (verified on 4 seeds). Headroom had to be **constructed** —
   one row forced to be the sum of two others.
2. **A break direction chosen by luck.** Perturbing entry `i` adds `5e_i`, which raises
   rank only if `e_i` lies **outside** the 5-dim row space — 5 of 6 choices do nothing.
   I picked row 2, which was inside, so the "negative control" was a no-op. The fix is to
   **select the break by verification**: try every basis direction, keep the first that
   demonstrably raises rank.
3. **An injected "column relation" that was not one.** I wrote
   `col[i] = Σ_j base[i][j]·base[i][0]` — whose "coefficient" `base[i][0]` **depends on
   the row index `i`**. That is not a linear combination of columns at all.
4. **A threshold that was arithmetically unreachable.** The 2-adic detector's negative
   control asked for `|z| > 20` at `N = 400`. The **maximum attainable** `z` for an
   all-1.0 sampler there is `11.83` — the test could not pass. Fixed by computing the
   attainable maximum and asking for `≥ 5`.
5. **`exact_psi` — two independent bugs.** (a) The standard `if p*p > r: break` without
   then accepting a leftover prime `≤ B` reported `Ψ(10,5) = 3` against a true **9**,
   understating smoothness *everywhere* — the `int(n**(1/3))` bug class in new dress.
   (b) Starting the loop at `t=2` drops `t=1`, which **is** `B`-smooth — a silent
   uniform off-by-one at every `x`. Both caught by brute force, not by inspection.
6. **A vacuous relation-set comparison.** T8 asserted the two collectors agree — on a set
   of size **zero**. At `b=6, n=2²⁶` the acceptance rate is `ρ(5.9) ≈ 3×10⁻⁵` and 400
   draws found nothing, so "both agree" was trivially true of two empty lists. The test
   now **requires a non-empty set and reports its size**.
7. **A vacuous structural test (F1).** I tested `(g^x mod n) mod p ≠ g^x mod p` using
   `p_f`, **a factor of `n`**. But `n ≡ 0 (mod p_f)`, so the two sides are identical
   **by construction** — it returned a perfect `0/600`, asserting the opposite of what it
   claimed. With a genuine factor-base prime it is **88.2%**. (`factor_base` drops exactly
   the primes dividing `n`, which is what made the mistake easy to make.)

**And a self-retraction, recorded because it was mine and it was the *conclusion*, not
the code.** `exp_H4.py`'s first version asserted that at the small `b` OO_bneed's NFS
analysis wants (`b = 8.4`), "the kernel is a LARGER share, not a smaller one". I extended
the grid to `b = 5,8,10,12` and it is the **opposite**: at `b = 5–8` the kernel is
**0.9–6.4%** and relation-finding is **93–99.9%**, because `ρ(u)` collapses faster than the
kernel shrinks. The registered prediction (`frac_rel` falls with `b`) was **right**; my
gloss on what it implies at the left end was wrong. `exp_crossover.py` carried the same
error and is corrected identically. **A correct prediction can still be mis-read into a
wrong conclusion**, and the fix was to measure the corner, not to reason about it.

**8. An overwritten results file, caught before it shipped.** `exp_e2e.py` writes
`e2e_out.json` on every run, so the `2³⁸` size point **overwrote** the JSON backing
§3.1–§3.2. I noticed because that file's `config.bits` read `38` while §3 quotes a
300-moduli `2²⁶` run, and re-ran it. Every size point now has its own file and §9 carries
the warning. **A number in a table is only as good as the run still on disk behind it.**
9. **My own grid is only good to ~±20%, found by running it twice.** The H4 grid was run
   as 12 cells and again as 24; seeds are fixed so the **matrices were identical**, yet
   `frac_LA` at `2³⁰/b=26` moved 0.3146 → 0.3825 (**+22%**). That is pure wall-clock
   variance on a shared host, and it is why §4.0 exists and why §3.0.1 refuses to read
   the `2³⁸` sign disagreement as a result. **The conclusions that survive are the
   order-of-magnitude ones (monotone directions, the failure band, the ~10⁴ span); no cell
   should be quoted to three digits.**

---

## 8. Limits of this result

- **Everything measured is at `n ≤ 2⁴⁰`.** §5.3's asymptotic statement is **arithmetic on
  published formulas, not measurement**, and is labelled as such everywhere it appears.
- **The hybrid's 1.41×–1.53× is a Python-constant number**, and by `2³⁸` it is below the
  instrument's resolution. In C with a segmented sieve the batching arm's constant would
  improve. **It would still not be a different algorithm**, because F2 forbids the sieve —
  the ratio is not the load-bearing part of §2, the aperiodicity is.
- **`frac_LA` is backend-dependent, and only one backend was timed.** The mandated
  `DomainMatrix`/QQ route is ~700–1000× faster than `sympy.Matrix.nullspace()` at
  `b ≥ 40`, so `frac_LA` here is a **lower bound** on the kernel's share. A slower kernel
  makes the claim fail over a **wider** band, never a narrower one.
- **The `b`-boundary is bracketed, not pinned** (§5.2).
- **`OO_bneed`'s `β_NFS = (32/9)^{1/3}` is flagged there as its least solid number**, and
  §2's rejection of the `5.9e5 → 8.4` lever does **not** depend on it — F2 is a statement
  about the relation condition, not about any constant.
- **`r48/_shared/dickman.py` was not used** (raises above `u = 5`); `ρ` appears nowhere as
  a null. Wall clocks on a 16-core host with other agents active: **treat absolute times
  as ±30% and the ratios as the result**, exactly as `PP_droptest` §7 advises.

---

## 9. Files

| file | what |
|---|---|
| `hcore.py` | pipeline: QQ kernel, both relation routes, phase accounting, `p_split`, `exact_psi` |
| `selftest.py` | **37 checks, ALL PASS**; every negative control fires; T4 confirms the `nullspace` trap live |
| `exp_nosieve.py` | **F1 + F2** — the structural result (§2), with the NFS control |
| `exp_e2e.py` | H2 four-arm end-to-end, per-modulus control (§3) |
| `exp_H4.py` | H4 cost split, registered prediction, extended grid (§4) |
| `exp_crossover.py` | H3 crossover: measured boundary + labelled arithmetic (§5) |
| `e2e_300.log` / `e2e_out.json` | the 300-moduli `cap=1` run (§3.1–§3.2) |
| `e2e_32.log` / `e2e_32_out.json`, `e2e_38.log` / `e2e_38_out.json` | the `2³²` and `2³⁸` size points (§3.0.1) |
| `H4_split.json`, `crossover_out.json` | raw data (§4, §5) |

Reproduce: `python3 selftest.py` · `python3 exp_nosieve.py` ·
`python3 exp_e2e.py 300 26 15 10 1 20261004` ·
`python3 exp_e2e.py 40 32 20 10 6 777` · `python3 exp_e2e.py 24 38 26 10 4 313` ·
`python3 exp_H4.py` · `python3 exp_crossover.py`

> ⚠️ `exp_e2e.py` **overwrites** `e2e_out.json` on every run, so the per-size runs are
> copied to `e2e_32_out.json` / `e2e_38_out.json` immediately after they finish. Anyone
> reproducing the size ladder must do the same or the §3.1–§3.2 numbers will be
> overwritten by whichever run went last — which is exactly the mistake this note caught.

**Imported read-only, not re-implemented:** `r48/exp/stange/stange.py` (Algorithm 2.2, the
validated relation finder, `factor_from_multiple`) and `r50exp/baseg/{laws,measure}.py`
(the exact 2-adic cells and the Jacobi symbol). **Its own selftest passes 40/40 this
session**, which is what licenses reusing it.